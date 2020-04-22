import 'dart:io';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:path_provider_platform_interface/src/method_channel_path_provider.dart';

class BitterPlatformPathProvider extends MethodChannelPathProvider {
  @override
  Future<String> getDownloadsPath() {
    if (!Platform.isMacOS && !Platform.isLinux) {
      throw UnsupportedError('Functionality only available on macOS and Linux');
    }
    return methodChannel.invokeMethod<String>('getDownloadsDirectory');
  }
}
