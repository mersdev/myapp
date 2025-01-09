import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/sortable_object.dart';
import '../providers/set_shifting_game_provider.dart';
import '../widgets/shape_widget.dart';
import '../widgets/app_drawer.dart';

class SetShiftingGameScreen extends StatelessWidget {
  const SetShiftingGameScreen({super.key});

  void _showFeedbackDialog(BuildContext context, bool isCorrect) {
    if (!context.mounted) return;
    
    final provider = Provider.of<SetShiftingGameProvider>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: isCorrect 
            ? Colors.green.withOpacity(0.95) 
            : Colors.red.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                isCorrect ? 'Correct!' : 'Try Again!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Question ${provider.questionNumber} of $maxQuestions',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.of(context).pop();
        
        if (provider.isGameOver) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StatsScreen()),
          );
        } else {
          provider.nextQuestion();
        }
      }
    });
  }

  Widget _buildGameContent(BuildContext context, SetShiftingGameProvider provider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildScoreSection(context, provider),
        const SizedBox(height: 20),
        _buildTargetObject(context, provider),
        const SizedBox(height: 40),
        _buildSelectableObjects(context, provider),
      ],
    );
  }

  Widget _buildScoreSection(BuildContext context, SetShiftingGameProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Set Shifting Game',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Score: ${provider.currentScore}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetObject(BuildContext context, SetShiftingGameProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.rule,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'Current Rule: ${provider.currentRule.ruleName}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Match with:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          _buildObjectWidget(provider.targetObject, null),
        ],
      ),
    );
  }

  Widget _buildObjectWidget(SortableObject object, VoidCallback? onTap) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ShapeWidget(object: object),
    );
  }

  Widget _buildSelectableObjects(BuildContext context, SetShiftingGameProvider provider) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: provider.currentObjects.map((obj) {
        return GestureDetector(
          onTap: () async {
            if (provider.isGameOver) return;
            final isCorrect = await provider.handleObjectSelection(obj);
            if (context.mounted) {
              _showFeedbackDialog(context, isCorrect);
            }
          },
          child: ShapeWidget(object: obj),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SetShiftingGameProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          drawer: const AppDrawer(),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade100,
                  Colors.blue.shade50,
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  _buildGameContent(context, provider),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: BottomNavigationBar(
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.logout),
                          label: 'Logout',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.bar_chart),
                          label: 'Stats',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.settings),
                          label: 'Other',
                        ),
                      ],
                      onTap: (index) {
                        // Handle navigation based on the selected index
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 