//
//  OmiliaClient.h
//  Omilia SDK
//
//  Created by Dimitris Togias on 12/04/16.
//  Copyright © 2016 Omilia S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSErrorDomain const kOMIErrorDomain;

typedef NS_ENUM(NSUInteger, OmiliaClientState) {
    OmiliaClientStateUndefined,
    OmiliaClientStateError,
    OmiliaClientStateReady,
    OmiliaClientStateConnecting,
    OmiliaClientStateRecognizing
};

typedef NS_ENUM(NSUInteger, OmiliaClientMessageType) {
    OmiliaClientMessageTypeError,             // 0
    OmiliaClientMessageTypeStartRecognition,  // 1
    OmiliaClientMessageTypeStopRecognition,   // 2
    OmiliaClientMessageTypeStartSpeech,       // 3
    OmiliaClientMessageTypeStopSpeech,        // 4
    OmiliaClientMessageTypePartialResult,     // 5
    OmiliaClientMessageTypeFinalResult,       // 6
    OmiliaClientMessageTypeText,              // 7
    OmiliaClientMessageTypeTyping,            // 8
    OmiliaClientMessageTypeAppUrl,            // 9
    OmiliaClientMessageTypeDialogStop,        // 10
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

- (BOOL)isConnected;
- (void)connect;
- (void)disconnect;

- (void)startDialog;
- (void)startDialogWithContext:(NSDictionary *)context;
- (void)endDialog;
- (void)sendText:(NSString *)message;
- (void)startRecognition;
- (void)stopRecognition;

@end

@protocol OmiliaClientDelegate <NSObject>

@optional
- (void)clientDidConnect:(OmiliaClient *)client;
- (void)client:(OmiliaClient *)client didFailWithError:(NSError *)error;
- (void)client:(OmiliaClient *)client didReceiveMessageType:(OmiliaClientMessageType)type withResponse:(NSString *)response;

@end
