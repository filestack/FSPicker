###Enabling APIs for Google Services###

1. In your web browser navigate to [Google console](https://console.developers.google.com) and sign in with your Google account.
2. Select “Dashboard” and click on the “Create Project” button, creating a new project for your app (following Google’s steps).
3. Once the project is successfully created, click on your project name in the upper bar of the Google console. Select the “Credentials” tab on the left Menu.
4. Click on the “Create Credentials” button, and select “OAuth Client ID” in the sub-menu.
5. Select iOS in the list and complete the required information based on your app. Click “Create” and close the confirmation popup.
6. Return to the Dashboard section and click on “Enable API”.
7. Depending on the services you want to include:
	- **For Google Drive and/or Google Photos**: select “Drive API” under “Google Apps APIs” and click “Enable”.
	- **For Gmail**: select “Gmail API” under “Google Apps APIs” and click “Enable”.

8. Open [Google Developers mobile](https://developers.google.com/mobile/add) pick iOS platform. Choose App Name and bundle. Choose and Enable Google SignIn. Generate and download configuration file. Add “GoogleService-Info.plist” to app bundle.
9. Add ```REVERSED_CLIENT_ID``` to URL Scheme base on [Google SignIn integration](https://developers.google.com/identity/sign-in/ios/start-integrating)
10. Double check ```CLIENT_ID```, ```REVERSED_CLIENT_ID```, ```URLScheme``` equal to ```OAuth 2.0 client IDs``` in google console. Some times ```GoogleService-Info.plist``` has ID for WEB client.
11. Add FSPicker to pod file and install pods ``` pod "FSPicker", :git => 'https://github.com/swebdevelopment/FSPicker.git', :branch => 'google-services-universal'```
12. Add code to AppDelegate:

Objective-C:

```objectivec
#import <FSPicker/FSPicker.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[FSGoogleServicesManager shared] application:application didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}

- (BOOL)application:(UIApplication *)app
openURL:(NSURL *)url
options:(NSDictionary *)options {
    
    return [[FSGoogleServicesManager shared] application:app openURL:url options:options];    
}
```
SWIFT:

```swift
import FSPicker

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FSGoogleServicesManager.shared().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FSGoogleServicesManager.shared().application(app, open: url, options: options)
    }

```