import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application/RecogScreen.dart';
import './DB.dart';
import './Model/Photo.dart';
import './Util/PhotoConvert.dart';

class SaveScreen extends StatefulWidget {
  const SaveScreen({super.key});

  @override
  State<SaveScreen> createState() => _SaveScreenState();
}

class _SaveScreenState extends State<SaveScreen> {
  late DB _db;
  final List<Photo> _documents = [];

  @override
  void initState() {
    super.initState();
    _db = DB();
    refreshDocs();
  }

  void refreshDocs() {
    _db.getPhotos().then((docs) {
      setState(() {
        _documents.clear();
        _documents.addAll(docs);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.blueAccent,
        title: const Text("Saved Documents",
            style: TextStyle(color: Colors.white)),
      ),
      body: Expanded(
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 5,
          child: GridView.builder(
            scrollDirection: Axis.vertical,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ),
            itemCount: _documents.length,
            itemBuilder: (context, index) {
              return InkWell(
                child: Photoconvert.imageFromBase64String(
                    _documents[index].photoName),
                onTap: () async {
                  File file = Photoconvert.fileFromBase64String(
                      _documents[index].photoName) as File;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return RecogScreen(file);
                    }),
                  );
                  // handle tap on saved image. (route that to RecogScreen).
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
