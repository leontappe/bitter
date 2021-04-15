//
//  Generated file. Do not edit.
//

#include "generated_plugin_registrant.h"

#include <file_selector_windows/file_selector_plugin.h>
#include <windows_documents/windows_documents_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FileSelectorPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FileSelectorPlugin"));
  WindowsDocumentsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowsDocumentsPlugin"));
}
