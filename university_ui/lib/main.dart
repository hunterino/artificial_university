import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'services/data_service.dart';
import 'services/grading_service.dart';
import 'services/llm_service.dart';
import 'services/ollama_llm_service.dart';

void main() {
  runApp(const ArtificialUniversityApp());
}

class ArtificialUniversityApp extends StatelessWidget {
  const ArtificialUniversityApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Change this one line to switch LLM providers
    final llmConfig = LlmConfig.ollama();
    final llmService = OllamaLlmService(config: llmConfig);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataService()),
        ChangeNotifierProvider(create: (_) => GradingService(llmService: llmService)),
      ],
      child: MaterialApp(
        title: 'Artificial University',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          textTheme: GoogleFonts.interTextTheme(),
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
