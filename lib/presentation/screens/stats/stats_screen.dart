import 'package:flutter/material.dart';
import '../../../services/game_service.dart';
import '../../../models/game_session.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic>? _userStats;
  List<GameSession>? _userSessions;
  List<Map<String, dynamic>>? _leaderboard;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final futures = await Future.wait([
        GameService.instance.getUserStats(),
        GameService.instance.getUserSessions(),
        GameService.instance.getLeaderboard(),
      ]);
      setState(() {
        _userStats = futures[0] as Map<String, dynamic>;
        _userSessions = futures[1] as List<GameSession>;
        _leaderboard = futures[2] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading stats: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Statistics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'History'),
            Tab(text: 'Leaderboard'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildHistoryTab(),
                _buildLeaderboardTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    if (_userStats == null) {
      return const Center(child: Text('No stats available'));
    }

    final stats = _userStats!;
    final highScore = stats['high_score'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScoreCard(highScore),
          const SizedBox(height: 24),
          _buildPerformanceChart(),
          const SizedBox(height: 24),
          _buildStatsList(stats),
        ],
      ),
    );
  }

  Widget _buildScoreCard(Map<String, dynamic> highScore) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'High Scores',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScoreItem('Color', highScore['color']),
                _buildScoreItem('Shape', highScore['shape']),
                _buildScoreItem('Size', highScore['size']),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildScoreItem('Total', highScore['total'], isLarge: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, int score, {bool isLarge = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 18 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: isLarge ? 32 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceChart() {
    if (_userSessions == null || _userSessions!.isEmpty) {
      return const SizedBox.shrink();
    }

    final sessions = _userSessions!.take(10).toList().reversed.toList();
    final scores = sessions.map((s) => s.score['total']?.toDouble() ?? 0).toList();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(scores.length, (i) => FlSpot(i.toDouble(), scores[i])),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsList(Map<String, dynamic> stats) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatItem('Total Games', stats['total_games']),
            _buildStatItem('Average Score', stats['average_score'].toStringAsFixed(1)),
            _buildStatItem('Total Rule Changes', stats['total_rule_changes']),
            _buildStatItem('Average Time', '${stats['average_duration_seconds']} seconds'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_userSessions == null || _userSessions!.isEmpty) {
      return const Center(child: Text('No game history available'));
    }

    return ListView.builder(
      itemCount: _userSessions!.length,
      itemBuilder: (context, index) {
        final session = _userSessions![index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text('Score: ${session.score['total']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${session.createdAt.toLocal().toString().split('.')[0]}'),
                Text('Duration: ${session.durationSeconds} seconds'),
                Text('Rule Changes: ${session.ruleChanges}'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('C: ${session.score['color']}'),
                Text('S: ${session.score['shape']}'),
                Text('Z: ${session.score['size']}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeaderboardTab() {
    if (_leaderboard == null || _leaderboard!.isEmpty) {
      return const Center(child: Text('No leaderboard available'));
    }

    return ListView.builder(
      itemCount: _leaderboard!.length,
      itemBuilder: (context, index) {
        final entry = _leaderboard![index];
        final score = entry['high_score'] as Map<String, dynamic>;
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text('${index + 1}'),
            ),
            title: Text(entry['user_email'] as String),
            subtitle: Text(
              'Games: ${entry['total_games']} | Avg: ${entry['average_score'].toStringAsFixed(1)}',
            ),
            trailing: Text(
              '${score['total']}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
} 