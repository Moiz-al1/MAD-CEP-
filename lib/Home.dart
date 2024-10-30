import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application/RecogScreen.dart';
import 'package:flutter_application/SaveScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  late ImagePicker imagePicker;
  bool _isPermissionGranted = false;
  late final Future<void> _future;
  //
  CameraController? _cameraController;
  bool showFocusCircle = false;
  double x = 0;
  double y = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _requestCameraPermission();
    imagePicker = ImagePicker();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 5, bottom: 15, left: 5, right: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Card(
                color: Colors.blueAccent,
                child: Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  child: const Center(
                    child: Text(
                      "ScanScribe",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                ),
              ),
              Card(
                child: !_isPermissionGranted
                    ? Container(
                        color: Colors.black,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height - 200,
                        child: const Center(
                          child: Text(
                            "Camera Permission Denied.",
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTapUp: (details) {
                          _onTap(details);
                        },
                        child: FutureBuilder<List<CameraDescription>>(
                          future: availableCameras(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              _initCameraController(snapshot.data!);
                              return Stack(
                                children: [
                                  Center(
                                    child: CameraPreview(_cameraController!),
                                  ),
                                  if (showFocusCircle)
                                    Positioned(
                                      top: y - 20,
                                      left: x - 20,
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white,
                                                width: 1.5)),
                                      ),
                                    )
                                ],
                              );
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          },
                        ),
                      ),
              ),
              Card(
                color: Colors.blueAccent,
                child: Container(
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        child: const Icon(
                          Icons.pages,
                          size: 45,
                          color: Colors.white,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return const SaveScreen();
                            }),
                          );
                        },
                      ),
                      InkWell(
                        child: const Icon(
                          Icons.camera,
                          size: 50,
                          color: Colors.white,
                        ),
                        onTap: () async {
                          if (_cameraController == null) return;
                          final file = await _cameraController!.takePicture();
                          final image = File(file.path);

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return RecogScreen(image);
                            }),
                          );
                        },
                      ),
                      InkWell(
                        child: const Icon(
                          Icons.image_outlined,
                          size: 45,
                          color: Colors.white,
                        ),
                        onTap: () async {
                          XFile? xfile = await imagePicker.pickImage(
                              source: ImageSource.gallery);
                          if (xfile != null) {
                            File image = File(xfile.path);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return RecogScreen(image);
                              }),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  // Method to initialize camera
  void _initCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }
    // Select the first rear camera.
    CameraDescription? camera;
    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription current = cameras[i];
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }
    if (camera != null) {
      _cameraSelected(camera);
    }
  }

// Method to select camera
  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _onTap(TapUpDetails details) async {
    if (_cameraController!.value.isInitialized) {
      showFocusCircle = true;
      x = details.localPosition.dx;
      y = details.localPosition.dy;

      double fullWidth = MediaQuery.of(context).size.width;
      double cameraHeight = fullWidth * _cameraController!.value.aspectRatio;

      double xp = x / fullWidth;
      double yp = y / cameraHeight;

      Offset point = Offset(xp, yp);

      // Manually focus
      await _cameraController!.setFocusPoint(point);

      setState(() {
        Future.delayed(const Duration(seconds: 2)).whenComplete(() {
          setState(() {
            showFocusCircle = false;
          });
        });
      });
    }
  }
}
