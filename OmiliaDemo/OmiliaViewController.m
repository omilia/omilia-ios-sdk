//
//  OmiliaViewController.m
//  OmiliaDemo
//
//  Created by Dimitris Togias on 05/04/16.
//  Copyright © 2016 Omilia S.A. All rights reserved.
//

#import "OmiliaViewController.h"

#import <OmiliaSdk/OmiliaSdk.h>

////////////////////////////////////////////////////////////////////////////////
@interface OmiliaViewController () <OmiliaClientDelegate>
{
    OmiliaClient *_client;
    
    // ui
    UIButton *_sendButton;
    
    JSQMessagesBubbleImage *_outgoingBubbleImageData;
    JSQMessagesBubbleImage *_incomingBubbleImageData;
    
    JSQMessage *_partialMessage;
}

@property(nonatomic, strong) NSMutableArray *items;

@end

////////////////////////////////////////////////////////////////////////////////
@implementation OmiliaViewController

////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.items = [NSMutableArray new];
    self.title = NSLocalizedString(@"main_title", nil);
    
    ////////////////////////////////////////////////////////////////////////////////
    /// config
    UIColor *brandColor = [UIColor colorWithRed:120.0/255.0 green:120.0/255.0 blue:184.0/255.0 alpha:1.0];
    UIColor *greyColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0];
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [JSQMessagesBubbleImageFactory new];
    _outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:greyColor];
    _incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:brandColor];
    
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    
    _sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
    [_sendButton setImage:[UIImage imageNamed:@"send_active"] forState:UIControlStateNormal];
    [_sendButton setImage:[UIImage imageNamed:@"send_active"] forState:UIControlStateHighlighted];
    [_sendButton setImage:[UIImage imageNamed:@"send"] forState:UIControlStateDisabled];
    
    self.inputToolbar.contentView.rightBarButtonItem = _sendButton;
    
    self.inputToolbar.contentView.leftBarButtonItem = nil;

    /// omilia servers
    _client = [OmiliaClient sharedClient];
    _client.delegate = self;
}

////////////////////////////////////////////////////////////////////////////////
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self _applicationEnterForeground];
}

////////////////////////////////////////////////////////////////////////////////
- (void)_showAlertAndReconnect:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", nil)
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"retry", nil)
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                
                                                if ([[OMIReachability reachabilityWithHostname:[OmiliaClient host]] isReachable]) {
                                                    [self->_client start];
                                                } else {
                                                    [self dismissViewControllerAnimated:YES completion:nil];
                                                    [self presentViewController:alert animated:true completion:nil];
                                                }
                                            }]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self presentViewController:alert animated:true completion:nil];}

#pragma mark - Handlers
////////////////////////////////////////////////////////////////////////////////
- (void)_handleStartRecognition:(NSString *)command
{
    // TODO: TO BE IMPLEMENTED
}

////////////////////////////////////////////////////////////////////////////////
- (void)_handleStopRecognition:(NSString *)command
{
    // TODO: TO BE IMPLEMENTED
}

////////////////////////////////////////////////////////////////////////////////
- (void)_handleText:(NSString *)command
{
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:@"user"
                                             senderDisplayName:@"USR"
                                                          date:[NSDate date]
                                                          text:command];
    
    [self.items addObject:message];
    [self.collectionView reloadData];
    [self scrollToBottomAnimated:YES];
}

////////////////////////////////////////////////////////////////////////////////
- (void)_handlePartialResult:(NSString *)command
{
    if (_partialMessage == nil) {
        _partialMessage = [[JSQMessage alloc] initWithSenderId:self.senderId
                                             senderDisplayName:self.senderDisplayName
                                                          date:[NSDate date]
                                                          text:command];
        [self.items addObject:_partialMessage];
        
        [self.collectionView insertItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:(self.items.count - 1) inSection:0] ]];
        [self scrollToBottomAnimated:YES];
        return;
    }
    
    _partialMessage.text = command;
    [self.collectionView reloadItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:(self.items.count - 1) inSection:0]]];
    [self scrollToBottomAnimated:YES];
}

////////////////////////////////////////////////////////////////////////////////
- (void)_handleFinalResult:(NSString *)command
{
    _partialMessage.text = command;
    [self.collectionView reloadItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:(self.items.count - 1) inSection:0]]];
    [self scrollToBottomAnimated:YES];
    _partialMessage = nil;
}

////////////////////////////////////////////////////////////////////////////////
- (void)_handleTyping:(BOOL)on
{
    self.showTypingIndicator = on;
    [self scrollToBottomAnimated:YES];
}

#pragma mark - Overrides
////////////////////////////////////////////////////////////////////////////////
- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    [self.items addObject:message];
    
    [_client sendText:text];
    [self finishSendingMessageAnimated:YES];
}

#pragma mark - JSQMessages CollectionView DataSource
////////////////////////////////////////////////////////////////////////////////
- (NSString *)senderId
{
    return @"omilia";
}

////////////////////////////////////////////////////////////////////////////////
- (NSString *)senderDisplayName
{
    return @"OMI";
}

////////////////////////////////////////////////////////////////////////////////
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView
       messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [_items objectAtIndex:indexPath.item];
}

////////////////////////////////////////////////////////////////////////////////
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [self.items count];
}

////////////////////////////////////////////////////////////////////////////////
- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *msg = [self.items objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        } else {
            cell.textView.textColor = [UIColor whiteColor];
        }
    }
    
    return cell;
}

////////////////////////////////////////////////////////////////////////////////
- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.items objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        return _outgoingBubbleImageData;
    }
    
    return _incomingBubbleImageData;
}

////////////////////////////////////////////////////////////////////////////////
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

#pragma mark - OmiliaClientDelegate
////////////////////////////////////////////////////////////////////////////////
- (void)onCommand:(int)commandID withResponse:(NSString *)response
{
    if (commandID == OmiliaClientCommandIdError) {
        [self _showAlertAndReconnect:response];
        return;
    }
    
    if (commandID == OmiliaClientCommandIdStartRecognition) {
        [self _handleStartRecognition:response];
        return;
    }
    
    if (commandID == OmiliaClientCommandIdStopRecognition) {
        [self _handleStopRecognition:response];
        return;
    }
    
    if (commandID == OmiliaClientCommandIdText) {
        [self _handleTyping:NO];
        [self _handleText:response];
        return;
    }
    
    if (commandID == OmiliaClientCommandIdPartialResult) {
        [self _handleTyping:NO];
        [self _handlePartialResult:response];
        return;
    }
    
    if (commandID == OmiliaClientCommandIdFinalResult) {
        [self _handleFinalResult:response];
        return;
    }
    
    if (commandID == OmiliaClientCommandIdTyping) {
        [self _handleTyping:YES];
        return;
    }
}

#pragma mark - Private
////////////////////////////////////////////////////////////////////////////////
- (void)_applicationEnterForeground
{
    if (![_client isConnected]) {
        [self _normalEnterForeground];
    }
}

////////////////////////////////////////////////////////////////////////////////
- (void)_applicationWillResignActive
{
    [_client stop];
}

////////////////////////////////////////////////////////////////////////////////
- (void)_showMessageView
{
    [UIView animateWithDuration:0.4 animations:^{
        self.inputToolbar.contentView.textView.alpha = 1.0;
        self->_sendButton.alpha = 1.0;
    }];
}

////////////////////////////////////////////////////////////////////////////////
- (void)_hideMessageView
{
    [UIView animateWithDuration:0.4 animations:^{
        self.inputToolbar.contentView.textView.alpha = 0.0;
        self->_sendButton.alpha = 0.0;
    }];
}

////////////////////////////////////////////////////////////////////////////////
- (void)_resetData
{
    self.items = [NSMutableArray new];
    [self.collectionView reloadData];
}

////////////////////////////////////////////////////////////////////////////////
- (void)_normalEnterForeground
{
    if ([[OMIReachability reachabilityWithHostname:[OmiliaClient host]] isReachable]) {
        [self _resetData];
        [_client start];
    } else {
        [self _showAlertAndReconnect:NSLocalizedString(@"error_cannot_connect", nil)];
    }
}

@end
