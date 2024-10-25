import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class RecogScreen extends StatefulWidget {
  File image;
  RecogScreen(this.image);

  @override
  State<RecogScreen> createState() => _RecogScreenState();
}

class _RecogScreenState extends State<RecogScreen> {
  late TextRecognizer textRecognizer;
  @override
  void initState() {
    super.initState();
    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    recognizeText();
  }

  String results = "";
  void recognizeText() async {
    InputImage inputImage = InputImage.fromFile(widget.image);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    results = recognizedText.text;
    setState(() {
      results;
    });
    for (TextBlock block in recognizedText.blocks) {
      final Rect rect = block.boundingBox;
      final List<Point<int>> cornerPoints = block.cornerPoints;
      final String text = block.text;
      final List<String> languages = block.recognizedLanguages;

      for (TextLine line in block.lines) {
        // Same getters as TextBlock
        for (TextElement element in line.elements) {
          // Same getters as TextBlock
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Recognizer",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Image.file(widget.image),
              Card(
                margin: EdgeInsets.all(10),
                color: Colors.grey.shade400,
                child: Column(
                  children: [
                    Container(
                      color: Colors.blueAccent,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              "Results",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            Icon(
                              Icons.copy,
                              color: Colors.white,
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        ),
                      ),
                    ),
                    Text(
                      results,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
