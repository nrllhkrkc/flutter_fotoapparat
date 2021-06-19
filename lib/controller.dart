import 'package:fotoapparat/fotoapparat.dart';

class FotoapparatCameraController {
  late FotoapparatCameraView cameraView;

  ///pause camera while stop camera preview.
  ///Plugin manage automatically pause camera based android, iOS lifecycle and widget visibility
  pauseCamera() {
    cameraView.viewState.controller.pauseCamera();
  }

  ///Closing camera and dispose all resource
  closeCamera() {
    cameraView.viewState.controller.closeCamera();
  }

  ///resume camera while resume camera preview.
  ///Plugin manage automatically resume camera based android, iOS lifecycle and widget visibility
  resumeCamera() {
    cameraView.viewState.controller.resumeCamera();
  }

  ///Use this method for taking picture in take picture mode
  ///This method return path of image
  Future<String?> takePicture() {
    return cameraView.viewState.controller.takePicture();
  }

  ///Change flash mode between auto, on and off
  changeFlashMode(CameraFlashMode captureFlashMode) {
    cameraView.viewState.controller.changeFlashMode(captureFlashMode);
  }

  ///Connect view to this controller
  void setView(FotoapparatCameraView cameraKitView) {
    this.cameraView = cameraKitView;
  }
}
