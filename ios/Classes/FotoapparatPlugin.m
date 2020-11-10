#import "FotoapparatPlugin.h"
#if __has_include(<fotoapparat/fotoapparat-Swift.h>)
#import <fotoapparat/fotoapparat-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "fotoapparat-Swift.h"
#endif

@implementation FotoapparatPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFotoapparatPlugin registerWithRegistrar:registrar];
}
@end
