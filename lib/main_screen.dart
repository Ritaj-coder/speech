import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class MainScreen extends StatefulWidget {
  static const String routename = 'lan';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AudioPlayer player = AudioPlayer();
  int currentIndex = 0;
  String currentLanguageCode = 'un';

  final List<String> audioFiles = [
    'assets/data/arabic101.mp3',
    'assets/data/arabic102.mp3',
    'assets/data/english578.mp3',
    'assets/data/japanese17.mp3',
  ];

  @override
  void initState() {
    super.initState();
    loadCurrentAudio();
  }

  Future<void> loadCurrentAudio() async {
    try {
      await player.setAsset(audioFiles[currentIndex]);
      await player.play();
      await detectLanguageFromFile(audioFiles[currentIndex]);
    } catch (e) {
      print("Audio load/play error: $e");
    }
    setState(() {});
  }

  Future<void> detectLanguageFromFile(String assetPath) async {
    try {
      // Simulated API detection logic (mock response)
      String mockAccent = 'us'; // Default mock
      if (assetPath.contains('arabic')) mockAccent = 'arabic';
      if (assetPath.contains('english')) mockAccent = 'english';
      if (assetPath.contains('japanese')) mockAccent = 'japanese';

      await Future.delayed(Duration(seconds: 1)); // simulate delay

      setState(() {
        currentLanguageCode = _mapAccentToFlag(mockAccent);
      });

      print("Simulated accent: $mockAccent for $assetPath");
    } catch (e) {
      print("Language detection error: $e");
      setState(() {
        currentLanguageCode = 'un';
      });
    }
  }

  String _mapAccentToFlag(String accent) {
    switch (accent.toLowerCase()) {
      case 'us':
        return 'us';
      case 'indian':
        return 'in';
      case 'british':
        return 'gb';
      case 'australian':
        return 'au';
      case 'canadian':
        return 'ca';
      case 'arabic':
        return 'sa';
      default:
        return 'un';
    }
  }

  void goToNext() {
    player.stop();
    if (currentIndex < audioFiles.length - 1) {
      setState(() {
        currentIndex++;
      });
      loadCurrentAudio();
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Audio Language Detector')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Audio ${currentIndex + 1}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              IconButton(
                icon: Icon(Icons.play_arrow, size: 32),
                onPressed: () => player.play(),
              ),
              IconButton(
                icon: Icon(Icons.pause, size: 32),
                onPressed: () => player.pause(),
              ),
              SizedBox(height: 16),
              Image.network(
                'https://flagcdn.com/48x36/${currentLanguageCode.toLowerCase()}.png',
                height: 36,
                errorBuilder: (context, error, stackTrace) => Text('Flag not found'),
              ),
              SizedBox(height: 24),
              if (currentIndex < audioFiles.length - 1)
                ElevatedButton.icon(
                  onPressed: goToNext,
                  icon: Icon(Icons.arrow_forward),
                  label: Text("Next"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
