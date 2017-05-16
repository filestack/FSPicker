

@interface FSGoogleServicesManager : NSObject

+ (FSGoogleServicesManager*)shared;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options;

@end
