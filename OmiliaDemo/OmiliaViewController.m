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
    
    // state
    BOOL _shouldMicBeEnabled;
    BOOL _hasMicPermissions;
    
    // ui
    UIButton *_sendButton;
    UIButton *_micButton;
    
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
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_menu"]
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(_openMenu)];
    self.navigationItem.leftBarButtonItem = menuButton;
    
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
    
    _micButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
    [_micButton setImage:[UIImage imageNamed:@"mic"] forState:UIControlStateNormal];
    [_micButton setImage:[UIImage imageNamed:@"mic_selected"] forState:UIControlStateHighlighted];
    [_micButton setImage:[UIImage imageNamed:@"mic_selected"] forState:UIControlStateSelected];
    [_micButton setImage:[UIImage imageNamed:@"mic_disabled"] forState:UIControlStateDisabled];
    
    self.inputToolbar.contentView.leftBarButtonItem = _micButton;


    /// omilia servers
    _client = [OmiliaClient sharedClient];
    _client.delegate = self;
}

////////////////////////////////////////////////////////////////////////////////
- (void)_openMenu
{
    [_client startRecognition];
}

////////////////////////////////////////////////////////////////////////////////
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self _applicationEnterForeground];
}

////////////////////////////////////////////////////////////////////////////////
- (void)onMicPermissions:(BOOL)granted
{
    _hasMicPermissions = granted;
    [self performSelectorOnMainThread:@selector(_refreshMicState) withObject:nil waitUntilDone:NO];
    
    if (!granted) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"mic_permission_title", nil)
                                                                       message:NSLocalizedString(@"mic_permission_message", nil)
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil)
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self presentViewController:alert animated:true completion:nil];
    }
}

////////////////////////////////////////////////////////////////////////////////
- (void)_showAlertAndReconnect:(NSString *)message
{
    _shouldMicBeEnabled = false;
    [self performSelectorOnMainThread:@selector(_refreshMicState) withObject:nil waitUntilDone:NO];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", nil)
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"retry", nil)
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                
                                                if ([[OMIReachability reachabilityWithHostname:[OmiliaClient host]] isReachable]) {
                                                    [self->_client connect];
                                                    self->_shouldMicBeEnabled = true;
                                                    [self _refreshMicState];
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
    _shouldMicBeEnabled = true;
    [self performSelectorOnMainThread:@selector(_refreshMicState) withObject:nil waitUntilDone:NO];
}

////////////////////////////////////////////////////////////////////////////////
- (void)_handleStopRecognition:(NSString *)command
{
    _micButton.selected = false;
    [self _showMessageView];
    
    _shouldMicBeEnabled = true;
    [self performSelectorOnMainThread:@selector(_refreshMicState) withObject:nil waitUntilDone:NO];

}

////////////////////////////////////////////////////////////////////////////////
- (void)_handleText:(NSString *)command
{
    if (command == nil) {
        return;
    }
    
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
    if (_partialMessage == nil) {
        _partialMessage = [[JSQMessage alloc] initWithSenderId:self.senderId
                                             senderDisplayName:self.senderDisplayName
                                                          date:[NSDate date]
                                                          text:command];
        [self.items addObject:_partialMessage];
        
        [self.collectionView insertItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:(self.items.count - 1) inSection:0] ]];
        [self scrollToBottomAnimated:YES];
        _partialMessage = nil;
        return;
    }
    
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

////////////////////////////////////////////////////////////////////////////////
- (void)_disableControls
{
    _micButton.enabled = false;
    _sendButton.enabled = false;
    self.inputToolbar.contentView.textView.userInteractionEnabled = false;
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

////////////////////////////////////////////////////////////////////////////////
- (void)didPressAccessoryButton:(UIButton *)sender
{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    /// toggle recognition
    if (_client.state == OmiliaClientStateRecognizing) {
        [_client stopRecognition];
        _micButton.selected = false;
        [self _showMessageView];
    } else {
        [_client startRecognition];
        _micButton.selected = true;
        [self _hideMessageView];
    }
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
- (void)clientDidConnect:(OmiliaClient *)client
{
    [client startDialog];
}

////////////////////////////////////////////////////////////////////////////////
- (void)client:(OmiliaClient *)client didFailWithError:(NSError *)error
{
    [self _showAlertAndReconnect:error.localizedDescription];
}

////////////////////////////////////////////////////////////////////////////////
- (void)client:(OmiliaClient *)client didReceiveMessageType:(OmiliaClientMessageType)type withResponse:(NSString *)response
{
    // text
    if (type == OmiliaClientMessageTypeTyping) {
        [self _handleTyping:YES];
        return;
    }
    
    if (type == OmiliaClientMessageTypeText) {
        [self _handleTyping:NO];
        [self _handleText:response];
        return;
    }
    
    if (type == OmiliaClientMessageTypeDialogStop) {
        [self _disableControls];
        return;
    }
    
    // speech recognition
    if (type == OmiliaClientMessageTypeStartRecognition) {
        [self _handleStartRecognition:response];
        return;
    }
    
    if (type == OmiliaClientMessageTypeStopRecognition) {
        [self _handleStopRecognition:response];
        return;
    }
    
    if (type == OmiliaClientMessageTypePartialResult) {
        [self _handleTyping:NO];
        [self _handlePartialResult:response];
        return;
    }
    
    if (type == OmiliaClientMessageTypeFinalResult) {
        [self _handleStopRecognition:response];
        [self _handleFinalResult:response];
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
    [_client disconnect];
}

////////////////////////////////////////////////////////////////////////////////
- (void)_showMessageView
{
    [UIView animateWithDuration:0.4 animations:^{
        self.inputToolbar.contentView.textView.userInteractionEnabled = YES;
        self->_sendButton.enabled = YES;
    }];
}

////////////////////////////////////////////////////////////////////////////////
- (void)_hideMessageView
{
    [UIView animateWithDuration:0.4 animations:^{
        self.inputToolbar.contentView.textView.userInteractionEnabled = NO;
        self->_sendButton.enabled = NO;
    }];
}

////////////////////////////////////////////////////////////////////////////////
- (void)_resetData
{
    self.items = [NSMutableArray new];
    [self.collectionView reloadData];
}

////////////////////////////////////////////////////////////////////////////////
- (void)_refreshMicState
{
    _micButton.enabled = (_shouldMicBeEnabled && _hasMicPermissions);
}

////////////////////////////////////////////////////////////////////////////////
- (void)_normalEnterForeground
{
    if ([[OMIReachability reachabilityWithHostname:[OmiliaClient host]] isReachable]) {
        [self _resetData];
        [_client connect];
    } else {
        [self _showAlertAndReconnect:NSLocalizedString(@"error_cannot_connect", nil)];
    }
    
    /// audio
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        [self onMicPermissions:granted];
    }];
}

@end
