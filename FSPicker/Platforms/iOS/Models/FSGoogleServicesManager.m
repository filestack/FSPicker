//
//  FSGoogleServicesManager.m
//  Pods
//
//  Created by Alexanedr on 4/18/17.
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//

#import "FSGoogleServicesManager.h"
#import <Google/SignIn.h>


@interface FSGoogleServicesManager()<GIDSignInDelegate>

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
    
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError: &configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
//    [GIDSignIn sharedInstance].delegate = self;
//    [GIDSignIn sharedInstance].scopes = @[@"https://www.googleapis.com/auth/drive"];

}


- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options {
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                      annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}


#pragma mark _______________________ Notifications _________________________



@end
