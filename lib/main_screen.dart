import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';
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
      final currentFile = audioFiles[currentIndex];

      // Set audio
      await player.setAsset(currentFile);
      await player.play();

      // Detect language (simulated) and set flag
      final flagCode = _detectFlagFromFilename(currentFile);

      setState(() {
        currentLanguageCode = flagCode;
      });

      print("File: $currentFile → Flag: $flagCode");
    } catch (e) {
      print("Error loading audio: $e");
      setState(() {
        currentLanguageCode = 'un';
      });
    }
  }

  String _detectFlagFromFilename(String path) {
    if (path.contains('arabic')) return 'sa'; // Saudi Arabia
    if (path.contains('english')) return 'us'; // United States
    if (path.contains('japanese')) return 'jp'; // Japan
    return 'un'; // Unknown
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
                errorBuilder: (context, error, stackTrace) =>
                    Text('Flag not found'),
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
