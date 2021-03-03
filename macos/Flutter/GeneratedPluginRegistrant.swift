//
//  Generated file. Do not edit.
//

// clang-format off

import FlutterMacOS
import Foundation

import file_chooser
import package_info
import path_provider_macos
import sqflite

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  FileChooserPlugin.register(with: registry.registrar(forPlugin: "FileChooserPlugin"))
  FLTPackageInfoPlugin.register(with: registry.registrar(forPlugin: "FLTPackageInfoPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  SqflitePlugin.register(with: registry.registrar(forPlugin: "SqflitePlugin"))
}
