//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <file_selector_windows/file_selector_plugin.h>
#include <sentry_flutter/sentry_flutter_plugin.h>
#include <windows_documents/windows_documents_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FileSelectorPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FileSelectorPlugin"));
  SentryFlutterPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("SentryFlutterPlugin"));
  WindowsDocumentsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowsDocumentsPlugin"));
}
