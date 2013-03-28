//
//  orbvMessageBar.h
//  orbvMessageBar
//
//  Created by orbv on 3/27/13.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define ORBV_DEF_H 33.0
#define ORBV_DEF_TEXT_H 23.0
#define ORBV_DEF_TEXT_W 240.0
#define ORBV_DEF_BUTTON_W 40.0
#define ORBV_DEF_BUTTON_H 20.0

@protocol orbvMessageDelegate <NSObject>

- (void)sendPressed:(NSString *)message;

@end

@interface orbvMessageBar : UIToolbar <UIGestureRecognizerDelegate, UITextViewDelegate>

// Delegate
@property (strong, nonatomic) id<orbvMessageDelegate> orbv_delegate;

// Properties
@property (strong, nonatomic) UITextView *inputView;
@property (strong, nonatomic) UIBarButtonItem *postButton;

// Instance Functions
- (void)sendAction;
- (void)dismissKeyboard:(NSNotification *)notification;
- (void)showKeyboard:(NSNotification *)notification;
- (void)closedView;
- (void)resetView;

@end
