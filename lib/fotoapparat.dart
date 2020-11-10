import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'controller.dart';

enum CameraFlashMode { on, off, auto }

class FotoapparatCameraView extends StatefulWidget {
  ///After android and iOS user deny run time permission, this method is called.
  final Function onPermissionDenied;

  ///This parameter accepts 3 values. `CameraFlashMode.auto`, `CameraFlashMode.on` and `CameraFlashMode.off`.
  /// For changing value after initial use `changeFlashMode` method in controller.
  final CameraFlashMode previewFlashMode;

  ///Controller for this widget
  final FotoapparatCameraController cameraController;

  _CameraViewState viewState;

  FotoapparatCameraView({
    Key key,
    this.previewFlashMode = CameraFlashMode.auto,
    this.cameraController,
    this.onPermissionDenied,
  }) : super(key: key);

  dispose() {
    viewState.disposeView();
  }

  @override
  State<StatefulWidget> createState() {
    if (cameraController != null) cameraController.setView(this);
    viewState = _CameraViewState();
    return viewState;
  }
}

class _CameraViewState extends State<FotoapparatCameraView>
    with WidgetsBindingObserver {
  NativeCameraController controller;
  Widget view;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (Platform.isAndroid) {
      view = AndroidView(
        viewType: 'plugins/fotoapparat',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return view;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("Flutter Life Cycle: resumed");
        if (controller != null) controller.resumeCamera();
        break;
      case AppLifecycleState.inactive:
        print("Flutter Life Cycle: inactive");
        if (Platform.isIOS) {
          controller.pauseCamera();
        }
        break;
      case AppLifecycleState.paused:
        print("Flutter Life Cycle: paused");
        controller.pauseCamera();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onPlatformViewCreated(int id) {
    this.controller = NativeCameraController._(id, context, widget);
    this.controller.initCamera();
  }

  void disposeView() {
    controller.dispose();
  }
}

///View State controller. User works with CameraKitController
///and CameraKitController Works with this controller.
class NativeCameraController {
  BuildContext context;
  FotoapparatCameraView widget;

  NativeCameraController._(int id, this.context, this.widget)
      : _channel = MethodChannel('plugins/fotoapparat' + id.toString());

  final MethodChannel _channel;

  int _getCharFlashMode(CameraFlashMode cameraFlashMode) {
    int flashMode;
    switch (cameraFlashMode) {
      case CameraFlashMode.auto:
        flashMode = 0;
        break;
      case CameraFlashMode.on:
        flashMode = 1;
        break;
      case CameraFlashMode.off:
        flashMode = 2;
        break;
    }
    return flashMode;
  }

  void initCamera() async {
    _channel.invokeMethod('requestPermission').then((value) {
      if (!value) {
        widget.onPermissionDenied?.call();
      } else {
        resumeCamera();
      }
    });
  }

  ///Call resume camera in Native API
  Future<void> resumeCamera() async {
    return _channel.invokeMethod('resumeCamera');
  }

  ///Call pause camera in Native API
  Future<void> pauseCamera() async {
    return _channel.invokeMethod('pauseCamera');
  }

  ///Call close camera in Native API
  Future<void> closeCamera() {
    return _channel.invokeMethod('closeCamera');
  }

  ///Call take picture in Native API
  Future<String> takePicture() async {
    return _channel.invokeMethod('takePicture', null);
  }

  ///Call change flash mode in Native API
  Future<void> changeFlashMode(CameraFlashMode captureFlashMode) {
    return _channel.invokeMethod(
        'changeFlashMode', {"flashMode": _getCharFlashMode(captureFlashMode)});
  }

  ///Call dispose in Native API
  Future<void> dispose() {
    return _channel.invokeMethod('dispose', "");
  }
}
