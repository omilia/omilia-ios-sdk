//
//  AppDelegate.m
//  OmiliaDemo
//
//  Created by Dimitris Togias on 09/08/16.
//  Copyright © 2016 Omilia S.A. All rights reserved.
//

#import "AppDelegate.h"

#import <OmiliaSdk/OmiliaSdk.h>

#define OMILIA_API_KEY   @""

////////////////////////////////////////////////////////////////////////////////
@implementation AppDelegate

////////////////////////////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self _customizeAppearance];
    
    // settings
    [self _registerDefaultsFromSettingsBundle];
    
    // For debugging purposes
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [standardUserDefaults stringForKey:@"user_id"];
    [OmiliaClient setUserId:userId];
    
    NSString *dmtUrl = [standardUserDefaults stringForKey:@"url"];
    [OmiliaClient setUrl:dmtUrl];
        
    [OmiliaClient launchWithApiKey:OMILIA_API_KEY];
    
    return YES;
}

#pragma mark - Private
////////////////////////////////////////////////////////////////////////////////
- (void)_customizeAppearance
{    
    UIColor *brandColor = [UIColor colorWithRed:120.0/255.0 green:120.0/255.0 blue:184.0/255.0 alpha:1.0];
    UIColor *tintColor = [UIColor whiteColor];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : tintColor}];
    [[UINavigationBar appearance] setBarTintColor:brandColor];
    [[UINavigationBar appearance] setTintColor:tintColor];
}

////////////////////////////////////////////////////////////////////////////////
/// Add all variables from Settings.bundle
- (void)_registerDefaultsFromSettingsBundle
{
    NSLog(@"Settings: Registering default values from Settings.bundle");
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults synchronize];
    
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if (settingsBundle == nil) {
        NSLog(@"Settings: Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingString:@"/Root.plist"]];
    if (settings == nil) {
        NSLog(@"Settings: Could not find Root.plist");
        return;
    }
    
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    NSMutableDictionary *defaultsToRegister = [NSMutableDictionary new];
    
    for (NSDictionary *prefSpecification in preferences) {
        NSString *currentKey = prefSpecification[@"Key"];
        if (currentKey == nil) {
            continue;
        }
        
        NSString *currentObject = [standardUserDefaults objectForKey:currentKey];
        if (currentObject == nil) {
            NSObject *currentDefaultValue = prefSpecification[@"DefaultValue"];
            defaultsToRegister[currentKey] = currentDefaultValue;
        }
    }
    
    [standardUserDefaults registerDefaults:defaultsToRegister];
    [standardUserDefaults synchronize];
}


@end
