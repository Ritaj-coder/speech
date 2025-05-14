import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
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

  Future<void> loadCurrentAudio() async {
    await player.setAsset(audioFiles[currentIndex]);
    detectLanguageFromFile(audioFiles[currentIndex]);
    setState(() {});
  }

  Future<void> detectLanguageFromFile(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/temp_audio.mp3');
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());

      final uri = Uri.parse('http://192.168.100.9:5000/predict'); // Replace with your backend IP
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', tempFile.path));

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final jsonResp = jsonDecode(respStr);

      if (jsonResp.containsKey('accent')) {
        setState(() {
          currentLanguageCode = _mapAccentToFlag(jsonResp['accent']);
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  String _mapAccentToFlag(String accent) {
    switch (accent.toLowerCase()) {
      case 'us': return 'us';
      case 'indian': return 'in';
      case 'british': return 'gb';
      case 'australian': return 'au';
      case 'canadian': return 'ca';
      default: return 'un';
    }
  }

  @override
  void initState() {
    super.initState();
    loadCurrentAudio();
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
