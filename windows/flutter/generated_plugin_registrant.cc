//
//  Generated file. Do not edit.
//

#include "generated_plugin_registrant.h"

#include <file_selector_windows/file_selector_plugin.h>
#include <tch_common_widgets/tch_common_widgets_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FileSelectorPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FileSelectorPlugin"));
  TchCommonWidgetsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("TchCommonWidgetsPlugin"));
}
