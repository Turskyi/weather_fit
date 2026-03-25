@file:Suppress("RedundantSuppression")

package com.turskyi.weather_fit

import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

@Suppress("unused")
class MainActivity : FlutterActivity() {
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

				else -> result.notImplemented()
			}
		}
	}

	private companion object {
		private const val DEVICE_CHANNEL = "com.turskyi.weather_fit/device"
		private const val IS_WEAR_DEVICE_METHOD = "isWearDevice"
	}
}
