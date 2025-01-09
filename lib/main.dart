import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/set_shifting_game_provider.dart';
import 'presentation/screens/set_shifting_game_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cognitive Training Games',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: ChangeNotifierProvider(
        create: (_) => SetShiftingGameProvider(),
        child: const SetShiftingGameScreen(),
      ),
    );
  }
}
