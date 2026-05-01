import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/arduino_repository.dart';
import 'package:quiz_app/cubit/quiz_game_cubit.dart';
import 'package:quiz_app/quiz_game_screen.dart';

void main() {
  runApp(
    BlocProvider(
      create: (_) => QuizGameCubit(ArduinoRepository()),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5C6BC0),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'Quiz buzzer',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F1419),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F1419),
          foregroundColor: Colors.white,
        ),
      ),
      home: const QuizGameScreen(),
    );
  }
}
