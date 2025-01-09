import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/sortable_object.dart';
import '../providers/set_shifting_game_provider.dart';
import '../widgets/shape_widget.dart';

class SetShiftingGameScreen extends StatelessWidget {
  const SetShiftingGameScreen({super.key});

  Future<void> _showFeedbackAnimation(BuildContext context, bool isCorrect) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isCorrect ? Colors.green.withOpacity(0.9) : Colors.red.withOpacity(0.9),
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
    );
    await Future.delayed(const Duration(milliseconds: 500));
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SetShiftingGameProvider>(
      builder: (context, gameProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Set Shifting Game'),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Score: ${gameProvider.currentScore}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Current Rule: ${gameProvider.currentRule.ruleName}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 20),
                // Target object
                Card(
                  elevation: 8,
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text('Match with:'),
                        const SizedBox(height: 8),
                        _buildObjectWidget(gameProvider.targetObject, null),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Selectable objects
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: gameProvider.currentObjects
                        .map((obj) => _buildObjectWidget(
                              obj,
                              () async {
                                final isCorrect = await gameProvider.handleObjectSelection(obj);
                                if (context.mounted) {
                                  await _showFeedbackAnimation(context, isCorrect);
                                }
                              },
                            ))
                        .toList(),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: gameProvider.resetGame,
            child: const Icon(Icons.refresh),
          ),
        );
      },
    );
  }

  Widget _buildObjectWidget(SortableObject object, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(8),
          child: ShapeWidget(object: object),
        ),
      ),
    );
  }
} 