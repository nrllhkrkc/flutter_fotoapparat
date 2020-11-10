package com.akuple.fotoapparat

import android.app.Activity
import android.graphics.Color
import android.view.View
import android.widget.LinearLayout
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.fotoapparat.Fotoapparat
import io.fotoapparat.configuration.CameraConfiguration
import io.fotoapparat.parameter.ScaleType
import io.fotoapparat.selector.*
import io.fotoapparat.view.CameraView
import java.io.File
import java.io.FileNotFoundException
import java.io.IOException


class CameraBaseView(var activity: Activity, var flutterMethodListener: FlutterMethodListener) : PlatformView {

    private val cameraView = CameraView(activity.baseContext)

    private val linearLayout = LinearLayout(activity).apply {
        layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT)
        setBackgroundColor(Color.parseColor("#000000"))
        addView(cameraView)
    }


    private val fotoapparat = Fotoapparat(
            activity.baseContext,
            view = cameraView,
            scaleType = ScaleType.CenterCrop,
            lensPosition = back(),
            cameraConfiguration = CameraConfiguration(
                    flashMode = autoFlash(),
                    jpegQuality = highestQuality()
            ),
            cameraErrorCallback = { error -> println(error.message) }
    )

    fun takePicture(result: MethodChannel.Result) {
        val photoResult = fotoapparat.takePicture()

        val pictureFile = File(activity.externalCacheDir, "${System.currentTimeMillis()}.jpg")
        try {
            photoResult.saveToFile(pictureFile).whenAvailable {
                flutterMethodListener.onTakePicture(result, pictureFile.absolutePath + "")
            }
        } catch (e: FileNotFoundException) {
            flutterMethodListener.onTakePictureFailed(result, "-101", "File not found")
        } catch (e: IOException) {
            flutterMethodListener.onTakePictureFailed(result, "-102", e.message)
        }
    }

    fun resumeCamera() {
        fotoapparat.start()
    }

    fun pauseCamera() {
        fotoapparat.stop()
    }

    override fun getView(): View = linearLayout

    override fun dispose() {
        fotoapparat.stop()
    }

    fun changeFlashMode(flashMode: Int) {
        val flash = when (flashMode) {
            0 -> autoFlash()
            1 -> torch()
            2 -> off()
            else -> autoFlash()
        }
        fotoapparat.updateConfiguration(CameraConfiguration(
                flashMode = flash
        ))
    }
}