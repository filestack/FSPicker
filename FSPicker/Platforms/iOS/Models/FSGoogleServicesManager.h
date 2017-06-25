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

@protocol FSGoogleServicesManagerDelegate <NSObject>
- (void)authForScopes:(NSArray*)scopes;
@end

@interface FSGoogleServicesManager : NSObject

@property (nonatomic, weak) id <FSGoogleServicesManagerDelegate>delegate;

    
+ (FSGoogleServicesManager*)shared;

- (NSString*)clientID;
    
- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options;

@end
