package com.akuple.fotoapparat

import android.content.Context
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class CameraFactory(var pluginBinding: ActivityPluginBinding, var messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        return CameraFlutterView(pluginBinding, messenger, viewId)
    }

}