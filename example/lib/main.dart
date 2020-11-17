import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fotoapparat/controller.dart';
import 'package:fotoapparat/fotoapparat.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FotoapparatCameraController _controller;
  File _imageFile;

  var _isFlashOn = false;

  get _isCameraView => _imageFile == null;

  @override
  void initState() {
    super.initState();
    _controller = FotoapparatCameraController();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (_, w) => Material(
        child: Stack(children: [
          if (_isCameraView) ...[
            Positioned.fill(
              child: FotoapparatCameraView(
                cameraController: _controller,
                previewFlashMode: CameraFlashMode.on,
              ),
            ),
            Positioned.fill(
                child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      icon: Icon(Icons.camera),
                      iconSize: 32,
                      onPressed: () async {
                        var path = await _controller.takePicture();
                        final file = File(path);
                        print(await file.exists());
                        setState(() {
                          _imageFile = file;
                        });
                      }),
                  IconButton(
                      icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        if (!_isFlashOn) {
                          _controller.changeFlashMode(CameraFlashMode.on);
                          setState(() {
                            _isFlashOn = true;
                          });
                        } else {
                          _controller.changeFlashMode(CameraFlashMode.off);
                          setState(() {
                            _isFlashOn = false;
                          });
                        }
                      }),
                ],
              ),
            ))
          ] else ...[
            Positioned.fill(
                child: Image.file(
              _imageFile,
              fit: BoxFit.fill,
            )),
            Positioned.fill(
                child: Padding(
              padding: const EdgeInsets.all(8),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RaisedButton(
                      onPressed: () {
                        setState(() {
                          _imageFile = null;
                        });
                      },
                      child: Text("İptal"),
                    ),
                    RaisedButton(
                      onPressed: () {
                        Navigator.pop(context, _imageFile);
                      },
                      child: Text("Tamam"),
                    )
                  ],
                ),
              ),
            ))
          ]
        ]),
      ),
    );
  }
}
