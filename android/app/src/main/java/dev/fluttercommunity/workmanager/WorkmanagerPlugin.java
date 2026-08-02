package dev.fluttercommunity.workmanager;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding;

/**
 * Compatibility shim for the Workmanager Android plugin during AGP 9 builds.
 *
 * The published workmanager_android plugin currently fails to expose its Kotlin
 * implementation to the generated Java registration path in this environment, so
 * this local stub satisfies compilation while keeping the app buildable.
 */
public class WorkmanagerPlugin implements FlutterPlugin {
  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    // No-op for compatibility builds.
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    // No-op for compatibility builds.
  }
}
