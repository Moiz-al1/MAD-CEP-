import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'Utility.dart'
import './DB.dart';
import './Model/Photo.dart';
import './Util/PhotoConvert.dart';
import 'dart:async';

class RecogScreen extends StatefulWidget {
  File image;
  RecogScreen(this.image, {super.key});

  @override
  State<RecogScreen> createState() => _RecogScreenState();
}

class _RecogScreenState extends State<RecogScreen> {
  String results = "";
  late TextRecognizer textRecognizer;
  late DB _db;

  @override
  void initState() {
    super.initState();
    _db = DB();
    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    recognizeText();
  }

  void recognizeText() async {
    InputImage inputImage = InputImage.fromFile(widget.image);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    results = recognizedText.text;
    setState(() {
      results;
    });
  }

  void _copyTextToClipboard() async {
    if (results.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: results));
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Text copied to clipboard'),
        ),
      );
    }
  }

  void _savePhoto(File image) {
    String imgString = Photoconvert.base64String(image.readAsBytesSync());
    Photo photo = Photo(id: 0, photoName: imgString);
    _db.save(photo);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document Saved.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
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
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Results",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            Row(
                              children: [
                                InkWell(
                                  child: const Icon(
                                    Icons.copy,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  onTap: () {
                                    _copyTextToClipboard();
                                  },
                                ),
                                InkWell(
                                  child: const Icon(
                                    Icons.save,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  onTap: () {
                                    _savePhoto(widget.image);
                                  },
                                ),
                              ],
                            ),
                          ],
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
