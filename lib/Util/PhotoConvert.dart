import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Photoconvert {
  static String base64String(Uint8List data) {
    return base64Encode(data);
  }

  static Image imageFromBase64String(String base64String) {
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.fill,
    );
  }

  static Future<File> fileFromBase64String(String base64String) async {
    final bytes = base64.decode(base64String);
    final dir = await getTemporaryDirectory();
    final file =
        File('${dir.path}/image_${DateTime.now().millisecondsSinceEpoch}.png');

    await file.writeAsBytes(bytes);
    return file;
  }
}
