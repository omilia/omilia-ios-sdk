//
//  OmiliaClient.h
//  Omilia
//
//  Created by Dimitris Togias on 12/04/16.
//  Copyright © 2016 Omilia S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, OmiliaClientState) {
    OmiliaClientStateUndefined,
    OmiliaClientStateError,
    OmiliaClientStateReady,
    OmiliaClientStateConnecting,
    OmiliaClientStateRecognizing
};

typedef NS_ENUM(NSUInteger, OmiliaClientCommandId) {
    OmiliaClientCommandIdError,             // 0
    OmiliaClientCommandIdStartRecognition,  // 1
    OmiliaClientCommandIdStopRecognition,   // 2
    OmiliaClientCommandIdStartSpeech,       // 3
    OmiliaClientCommandIdStopSpeech,        // 4
    OmiliaClientCommandIdPartialResult,     // 5
    OmiliaClientCommandIdFinalResult,       // 6
    OmiliaClientCommandIdText,              // 7
    OmiliaClientCommandIdTyping,            // 8
    OmiliaClientCommandIdAppUrl,            // 9
};

@protocol OmiliaClientDelegate;

@interface OmiliaClient : NSObject

@property(nonatomic, readonly) OmiliaClientState state;
@property(nonatomic, weak, readwrite) id<OmiliaClientDelegate> delegate;

+ (NSString *)version;
+ (instancetype)sharedClient;

+ (void)setUserId:(NSString *)userId;
+ (NSString *)host;
+ (void)setUrl:(NSString *)url;
+ (void)launchWithApiKey:(NSString *)apiKey;
+ (void)launchWithApiKey:(NSString *)apiKey options:(NSDictionary *)launchOptions;

- (void)sendText:(NSString *)message;

- (BOOL)isConnected;
- (void)start;
- (void)stop;

@end

@protocol OmiliaClientDelegate <NSObject>
@optional

- (void)onCommand:(int)commandID withResponse:(NSString *)response;

@end
