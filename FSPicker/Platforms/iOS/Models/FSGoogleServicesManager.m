
#import "FSGoogleServicesManager.h"


@interface FSGoogleServicesManager()

@end


@implementation FSGoogleServicesManager
#pragma mark _______________________ Class Methods _________________________

#pragma mark - Shared Instance and Init
+ (FSGoogleServicesManager *)shared {
    
    static FSGoogleServicesManager *shared = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

#pragma mark ____________________________ Init _____________________________

-(id)init{
    
    self = [super init];
    if (self) {
   		// your initialization here
        
    }
    return self;
}

#pragma mark _______________________ Privat Methods ________________________



#pragma mark _______________________ Delegates _____________________________


#pragma mark _______________________ Public Methods ________________________

- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString* path = [[NSBundle mainBundle] pathForResource:@"GoogleService-Info" ofType:@"plist"];
    NSDictionary* googleServiceInfo = [NSDictionary dictionaryWithContentsOfFile:path];
    self.clientId = [googleServiceInfo objectForKey:@"CLIENT_ID"];
    self.redirectURI = [googleServiceInfo objectForKey:@"REVERSED_CLIENT_ID"];

}


- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options {
    
    // Sends the URL to the current authorization flow (if any) which will process it if it relates to
    // an authorization response.
    if ([_currentAuthorizationFlow resumeAuthorizationFlowWithURL:url]) {
        _currentAuthorizationFlow = nil;
        return YES;
    }
    
    return NO;
}


#pragma mark _______________________ Notifications _________________________



@end
