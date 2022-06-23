//
//  AppDelegate.m
//  OmiliaDemo
//
//  Created by Dimitris Togias on 09/08/16.
//  Copyright © 2016 Omilia S.A. All rights reserved.
//

#import "AppDelegate.h"

#import <OmiliaSdk/OmiliaSdk.h>

#define OMILIA_API_KEY   @"cb2e0f9b5cbDC43Fe46b0939452625ECBE494a52addc3f182cc51214ba69d903607CB75559D8FA44b8828222c7b1688108872c405DA30Cfda946a6e9"

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
    
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = brandColor;
        
        appearance.titleTextAttributes = @{ NSForegroundColorAttributeName : tintColor};
        appearance.shadowImage = [UIImage new];
        appearance.shadowColor = [UIColor clearColor];
        [UINavigationBar appearance].standardAppearance = appearance;
        [UINavigationBar appearance].scrollEdgeAppearance = appearance;
        
        [[UINavigationBar appearance] setTintColor:tintColor];
         
         return;
    }
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : tintColor}];
    [[UINavigationBar appearance] setBarTintColor:brandColor];
    [[UINavigationBar appearance] setTintColor:tintColor];
    [UINavigationBar appearance].shadowImage = [UIImage new];
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
