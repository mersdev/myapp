// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:myapp/presentation/screens/set_shifting_game_screen.dart';
import 'package:myapp/presentation/providers/set_shifting_game_provider.dart';

void main() {
  testWidgets('SetShiftingGameScreen UI test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => SetShiftingGameProvider(),
          child: const SetShiftingGameScreen(),
        ),
      ),
    );

    // Verify that the game title is displayed
    expect(find.text('Set Shifting Game'), findsOneWidget);
    
    // Verify that the score is displayed
    expect(find.text('Score: 0'), findsOneWidget);
    
    // Verify that there are three selectable objects
    expect(find.byType(ShapeWidget), findsNWidgets(4)); // 3 choices + 1 target
  });
}
