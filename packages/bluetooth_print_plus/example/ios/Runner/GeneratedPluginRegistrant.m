//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<bluetooth_print_plus/BluetoothPrintPlusPlugin.h>)
#import <bluetooth_print_plus/BluetoothPrintPlusPlugin.h>
#else
@import bluetooth_print_plus;
#endif

#if __has_include(<integration_test/IntegrationTestPlugin.h>)
#import <integration_test/IntegrationTestPlugin.h>
#else
@import integration_test;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [BluetoothPrintPlusPlugin registerWithRegistrar:[registry registrarForPlugin:@"BluetoothPrintPlusPlugin"]];
  [IntegrationTestPlugin registerWithRegistrar:[registry registrarForPlugin:@"IntegrationTestPlugin"]];
}

@end
