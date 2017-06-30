//
//  FSGoogleServicesManager.h
//  Pods
//
//  Created by Alexanedr on 4/18/17.
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GoogleAPIClientForREST/GTLRGmail.h>
#import <GoogleAPIClientForREST/GTLRDrive.h>

#import <AppAuth/AppAuth.h>
#import <GTMAppAuth/GTMAppAuth.h>

@protocol FSGoogleServicesManagerDelegate <NSObject>
- (void)authForScopes:(NSArray*)scopes;
@end

@interface FSGoogleServicesManager : NSObject

@property (nonatomic, weak) id <FSGoogleServicesManagerDelegate>delegate;

@property (strong, nonatomic) id<OIDAuthorizationFlowSession> currentAuthorizationFlow;

@property (strong, nonatomic) NSString* clientId;
@property (strong, nonatomic) NSString* redirectURI;

+ (FSGoogleServicesManager*)shared;
    
- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options;

@end
