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
#define ORBV_DEF_NAV_H 44.0
#define ORBV_DEF_TAB_H 49.0
#define ORBV_DEF_LNDS_H 32.0
#define ORBV_GROWTH_MARGIN 50.0

// Protocol for delegate
@protocol orbvMessageDelegate <NSObject>

- (void)sendPressed:(NSString *)message;

@end

@interface orbvMessageBar : UIToolbar <UIGestureRecognizerDelegate, UITextViewDelegate>

// Delegate
@property (strong, nonatomic) id<orbvMessageDelegate> orbvDelegate;

// Properties
@property (strong, nonatomic) UITextView *inputView;
@property (strong, nonatomic) UIBarButtonItem *postButton;
@property (nonatomic) CGSize keyboardSize;
@property (nonatomic) BOOL hasTabBar;
@property (nonatomic) BOOL hasNavBar;

// Instance Functions
- (void)sendAction;
- (void)dismissKeyboard:(NSNotification *)notification;
- (void)showKeyboard:(NSNotification *)notification;
- (void)orientationChanged:(NSNotification *)notification;
- (void)closedView;
- (void)resetView;

// Init function
- (id)initWithController:(UIViewController *)viewcontroller;

@end
