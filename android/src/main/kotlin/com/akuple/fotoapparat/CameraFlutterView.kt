package com.akuple.fotoapparat

import android.Manifest
import android.content.pm.PackageManager
import android.view.View
import androidx.core.app.ActivityCompat
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.platform.PlatformView


class CameraFlutterView(
    private var activityPluginBinding: ActivityPluginBinding,
    dartExecutor: BinaryMessenger,
    viewId: Int
) : PlatformView, MethodChannel.MethodCallHandler, FlutterMethodListener {

    private var channel: MethodChannel = MethodChannel(dartExecutor, "plugins/fotoapparat$viewId")
    private var cameraView = CameraBaseView(activityPluginBinding.activity, this)

    init {
        channel.setMethodCallHandler(this)
    }

    override fun getView(): View = cameraView.view

    override fun dispose() = cameraView.dispose();

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "requestPermission") {
            if (ActivityCompat.checkSelfPermission(
                    activityPluginBinding.activity,
                    Manifest.permission.CAMERA
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                ActivityCompat.requestPermissions(
                    activityPluginBinding.activity,
                    arrayOf(Manifest.permission.CAMERA),
                    REQUEST_CAMERA_PERMISSION
                )
                activityPluginBinding.addRequestPermissionsResultListener(object :
                    PluginRegistry.RequestPermissionsResultListener {
                    override fun onRequestPermissionsResult(
                        requestCode: Int,
                        permissions: Array<out String>,
                        grantResults: IntArray
                    ): Boolean {
                        for (i in grantResults) {
                            if (i == PackageManager.PERMISSION_DENIED) {
                                try {
                                    result.success(false)
                                } catch (e: Exception) {
                                }
                                return false
                            }
                        }
                        result.success(true)
                        return false
                    }
                })
                return
            } else {
                result.success(true)
            }
        } else if (call.method == "resumeCamera") {
            cameraView.resumeCamera()
        } else if (call.method == "pauseCamera") {
            cameraView.pauseCamera()
        } else if (call.method == "takePicture") {
            cameraView.takePicture(result)
        } else if (call.method == "changeFlashMode") {
            val captureFlashMode = call.argument<Int>("flashMode") ?: 0
            cameraView.changeFlashMode(captureFlashMode)
        } else if (call.method == "dispose") {
            dispose()
        } else {
            result.notImplemented()
        }
    }

    override fun onTakePicture(result: MethodChannel.Result?, filePath: String?) {
        activityPluginBinding.activity.runOnUiThread(Runnable { result?.success(filePath) })
    }

    override fun onTakePictureFailed(result: MethodChannel.Result?, errorCode: String?, errorMessage: String?) {
        activityPluginBinding.activity.runOnUiThread(Runnable { result?.error(errorCode ?: "Error message null", errorMessage, null) })
    }

    companion object {
        private const val REQUEST_CAMERA_PERMISSION = 10001
    }
}
