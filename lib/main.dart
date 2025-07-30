import 'package:basket_training/test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'models/shot_tracker.dart';
import 'services/speech_service.dart';
import 'widgets/stat_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShotTracker()),
        Provider(
          create: (context) => SpeechService(context.read<ShotTracker>()),
        ),
      ],
      child: MaterialApp(
        title: 'Basketball Shot Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final SpeechService _speechService;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Request microphone permission
      final status = await Permission.microphone.request();
      if (status.isDenied) {
        setState(() {
          _errorMessage =
              'Microphone permission is required for voice commands';
          _isLoading = false;
        });
        return;
      }

      // Initialize speech service
      if (!mounted) return;
      _speechService = context.read<SpeechService>();
      final isInitialized = await _speechService.initialize();

      if (!isInitialized) {
        setState(() {
          _errorMessage = 'Speech recognition not available';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing app: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    try {
      _speechService.dispose();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error disposing speech service: $e');
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shotTracker = context.watch<ShotTracker>();

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Stats Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    StatCard(
                      icon: Icons.sports_basketball,
                      title: 'Total Shots',
                      value: '${shotTracker.totalShots}',
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    StatCard(
                      icon: Icons.check_circle,
                      title: 'Good',
                      value: '${shotTracker.goodShots}',
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    StatCard(
                      icon: Icons.cancel,
                      title: 'Miss',
                      value: '${shotTracker.missShots}',
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    StatCard(
                      icon: Icons.bar_chart,
                      title: 'Accuracy',
                      value: '${shotTracker.accuracy.toStringAsFixed(1)}%',
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: IntrinsicHeight(
          child: Container(
            alignment: Alignment.bottomCenter,
            child: Column(
              children: [
                // Voice Button
                GestureDetector(
                  onTap: () => _speechService.toggleListening(),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: shotTracker.isListening ? Colors.red : Colors.blue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      shotTracker.isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Status Text
                Text(
                  shotTracker.recognitionText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),

                // Restart Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 20.0,
                  ),
                  child: ElevatedButton(
                    onPressed: shotTracker.reset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Restart',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
