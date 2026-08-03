@file:Suppress("RedundantSuppression")

package com.turskyi.weather_fit

import android.app.ActivityManager.TaskDescription
import android.app.RemoteInput
import android.content.Intent
import android.content.pm.PackageManager
import androidx.wear.input.RemoteInputIntentHelper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

@Suppress("unused")
class MainActivity : FlutterActivity() {
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DEVICE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                IS_WEAR_DEVICE_METHOD -> {
                    val isWatch = packageManager.hasSystemFeature(
                        PackageManager.FEATURE_WATCH,
                    )
                    result.success(isWatch)
                }

                OPEN_REMOTE_INPUT_METHOD -> {
                    pendingResult = result
                    val label = call.argument<String>("label") ?: "Search..."
                    val remoteInputs = listOf(
                        RemoteInput.Builder(INPUT_RESULT_KEY)
                            .setLabel(label)
                            .build(),
                    )
                    val intent =
                        RemoteInputIntentHelper.createActionRemoteInputIntent()
                    RemoteInputIntentHelper.putRemoteInputsExtra(
                        intent,
                        remoteInputs
                    )
                    startActivityForResult(intent, REMOTE_INPUT_REQUEST_CODE)
                }

                UPDATE_TILE_METHOD -> {
                    androidx.wear.tiles.TileService.getUpdater(this)
                        .requestUpdate(com.turskyi.weather_fit.glance.WeatherTileService::class.java)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?
    ) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REMOTE_INPUT_REQUEST_CODE) {
            if (resultCode == RESULT_OK && data != null) {
                val results = RemoteInput.getResultsFromIntent(data)
                val text = results?.getCharSequence(INPUT_RESULT_KEY)
                pendingResult?.success(text?.toString())
            } else {
                pendingResult?.success(null)
            }
            pendingResult = null
        }
    }

    override fun setTaskDescription(taskDescription: TaskDescription?) {
        try {
            super.setTaskDescription(taskDescription)
        } catch (e: Exception) {
            // Silently catch to prevent the app from crashing on some devices.
        }
    }

    private companion object {
        private const val DEVICE_CHANNEL = "com.turskyi.weather_fit/device"
        private const val IS_WEAR_DEVICE_METHOD = "isWearDevice"
        private const val OPEN_REMOTE_INPUT_METHOD = "openRemoteInput"
        private const val UPDATE_TILE_METHOD = "updateTile"
        private const val INPUT_RESULT_KEY = "search_query"
        private const val REMOTE_INPUT_REQUEST_CODE = 1001
    }
}
