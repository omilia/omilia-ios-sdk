//
//  OMISpeechRecognizer.h
//  Omilia SDK
//
//  Created by Dimitris Togias on 14/06/16.
//  Copyright © 2016 Omilia S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, OMISpeechRecognizerState) {
    OMISpeechRecognizerStateConnecting,
    OMISpeechRecognizerStateIdle,
    OMISpeechRecognizerStateRecognizing
};

@protocol OMISpeechRecognizerDelegate;

@interface OMISpeechRecognizer : NSObject

@property(nonatomic, readonly) OMISpeechRecognizerState state;

- (instancetype)initWithDelegate:(id<OMISpeechRecognizerDelegate>)delegate;
- (void)config;
- (void)start;
- (void)stop;
- (BOOL)isStopped;

@end

@protocol OMISpeechRecognizerDelegate <NSObject>

- (void)recognizer:(OMISpeechRecognizer *)recognizer didChangeState:(OMISpeechRecognizerState)state;

@optional
- (void)recognizer:(OMISpeechRecognizer *)recognizer error:(NSError *)error;

- (void)recognizer:(OMISpeechRecognizer *)recognizer didWriteData:(NSData *)data;

@end
