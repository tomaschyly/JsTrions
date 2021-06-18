//
//  Generated file. Do not edit.
//

#include "generated_plugin_registrant.h"

#include <file_selector_linux/file_selector_plugin.h>
#include <tch_common_widgets/tch_common_widgets_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) file_selector_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FileSelectorPlugin");
  file_selector_plugin_register_with_registrar(file_selector_linux_registrar);
  g_autoptr(FlPluginRegistrar) tch_common_widgets_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "TchCommonWidgetsPlugin");
  tch_common_widgets_plugin_register_with_registrar(tch_common_widgets_registrar);
}
