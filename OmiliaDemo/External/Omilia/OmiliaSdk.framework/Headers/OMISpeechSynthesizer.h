//
//  OMISpeechSynthesizer.h
//  Omilia
//
//  Created by Dimitris Togias on 03/06/16.
//  Copyright © 2016 Omilia S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, OMISpeechSynthesizerState) {
    OMISpeechSynthesizerStateIdle,
    OMISpeechSynthesizerStatePlaying,
    OMISpeechSynthesizerStateFinished,
};

@protocol OMISpeechSynthesizerDelegate;

@interface OMISpeechSynthesizer : NSObject

@property(nonatomic, readonly) OMISpeechSynthesizerState state;
@property(nonatomic, assign) BOOL synthesizerOn;

- (instancetype)initWithDelegate:(id<OMISpeechSynthesizerDelegate>)delegate;
- (void)enqueue:(NSArray *)array;
- (void)interrupt;

@end

@protocol OMISpeechSynthesizerDelegate <NSObject>

- (void)synthesizer:(OMISpeechSynthesizer *)synthesizer didChangeState:(OMISpeechSynthesizerState)state;

@optional
- (void)synthesizer:(OMISpeechSynthesizer *)synthesizer error:(NSError *)error;

@end
