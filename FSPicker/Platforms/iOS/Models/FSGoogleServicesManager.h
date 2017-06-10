//
//  FSGoogleServicesManager.h
//  Pods
//
//  Created by Alexanedr on 4/18/17.
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FSGoogleServicesManager : NSObject

+ (FSGoogleServicesManager*)shared;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options;

@end
