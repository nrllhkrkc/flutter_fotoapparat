package com.akuple.fotoapparat

import io.flutter.plugin.common.MethodChannel


interface FlutterMethodListener {

    fun onTakePicture(result: MethodChannel.Result?, filePath: String?)

    fun onTakePictureFailed(result: MethodChannel.Result?, errorCode: String?, errorMessage: String?)
}