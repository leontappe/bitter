import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider_platform_interface/src/method_channel_path_provider.dart';

class BitterPlatformPathProvider extends MethodChannelPathProvider {
  @override
  MethodChannel methodChannel = MethodChannel('plugins.flutter.io/path_provider');

  @override
  Future<String> getDownloadsPath() {
    if (!Platform.isMacOS && !Platform.isLinux) {
      throw UnsupportedError('Functionality only available on macOS and Linux');
    }
    return methodChannel.invokeMethod<String>('getDownloadsDirectory');
  }
}
