import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/sortable_object.dart';
import '../providers/set_shifting_game_provider.dart';
import '../widgets/shape_widget.dart';
import '../widgets/app_drawer.dart';

class SetShiftingGameScreen extends StatefulWidget {
  const SetShiftingGameScreen({Key? key}) : super(key: key);

  @override
  State<SetShiftingGameScreen> createState() => _SetShiftingGameScreenState();
}

class _SetShiftingGameScreenState extends State<SetShiftingGameScreen> {
  Timer? _timer;

  Future<void> _showFeedbackAnimation(bool isCorrect) async {
    showDialog(
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        builder: (context, value, child) => Transform.scale(
          scale: value,
          child: AlertDialog(
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
              ],
            ),
          ),
        ),
      ),
    );

    // Wait for 2 seconds before dismissing the dialog
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showGameOverDialog(SetShiftingGameProvider gameProvider) {
    showDialog(
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Correct Answers: ${gameProvider.correctAnswers} / ${gameProvider.totalQuestions}'),
            Text('Duration: ${gameProvider.gameDuration.inSeconds} seconds'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              gameProvider.resetGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() { 
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SetShiftingGameProvider>(
      builder: (context, gameProvider, child) {
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
              child: Stack( // Use Stack to overlay the navbar
                children: [
                  _buildGameContent(context, gameProvider),
                  Positioned( // Position the navbar at the bottom
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

  Widget _buildGameContent(BuildContext context, SetShiftingGameProvider gameProvider) {
    return Column(
              child: Column(
                children: [
                Padding(
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
                                'Score: ${gameProvider.currentScore}',
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
                  ),
                  Container(
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
                              'Current Rule: ${gameProvider.currentRule.ruleName}',
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
                        _buildObjectWidget(gameProvider.targetObject, null),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: gameProvider.currentObjects
                          .map((obj) => _buildSelectableObjectWidget(
                                obj,
                                () async {
                                  final isCorrect = await gameProvider.handleObjectSelection(obj);

                                  if (mounted) {
                                    await _showFeedbackAnimation(isCorrect);

                                    if (gameProvider.totalQuestions == 5) {
                                      _timer?.cancel(); // Stop the timer if the game is over
                                      _showGameOverDialog(gameProvider);
                                    } else if (isCorrect && gameProvider.totalQuestions < 5) {
                                      gameProvider.generateNextQuestion(); 
                                    }
                                  }
                                },
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20), // Add some space before the Reset button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: gameProvider.resetGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text(
                        'Reset Game',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80), // Adjust space for the navbar
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

  Widget _buildSelectableObjectWidget(SortableObject object, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 1.0),
        duration: const Duration(milliseconds: 200),
        builder: (context, scale, child) => Transform.scale(
          scale: scale,
          child: Container(
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: onTap,
                child: ShapeWidget(
                  object: object,
                  size: 80,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 