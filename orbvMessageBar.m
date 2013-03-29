//
//  orbvMessageBar.m
//  orbvMessageBar
//
//  Created by orbv on 3/27/13.
//

#import "orbvMessageBar.h"

@implementation orbvMessageBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect new_frame = CGRectMake(0,
                               frame.size.height - ORBV_DEF_H,
                               frame.size.width,
                               ORBV_DEF_H);
        self.frame = new_frame;
        
        // Change tint color
        self.tintColor = [UIColor darkGrayColor];
        
        // Insert text view
        CGRect input_frame = CGRectMake(0, 0, ORBV_DEF_TEXT_W, ORBV_DEF_TEXT_H);
        self.inputView = [[UITextView alloc] initWithFrame:input_frame];
        [self.inputView.layer setCornerRadius:10.0];
        self.inputView.delegate = self;
        self.inputView.contentInset = UIEdgeInsetsMake(4, 0, -4, 0);
        
        UIBarButtonItem *textView = [[UIBarButtonItem alloc] initWithCustomView:self.inputView];
        
        // Insert post button        
        self.postButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonSystemItemAction target:self action:@selector(sendAction)];
        
        // Add items to the array
        self.items = [NSArray arrayWithObjects:textView, self.postButton, nil];
        
        // Add notifications for keyboard
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissKeyboard:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

- (id)initWithController:(UIViewController *)viewcontroller {
    CGRect frame = viewcontroller.view.frame;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialize message bar
        CGRect newFrame;
        CGFloat y_offset = ORBV_DEF_H;
        
        // Detect nav bar and tab bar
        if (viewcontroller.tabBarController) {
            self.hasTabBar = true;
            y_offset += ORBV_DEF_TAB_H;
        }
        
        if (viewcontroller.navigationController) {
            self.hasNavBar = true;
            y_offset += ORBV_DEF_NAV_H;
        }
        
        // Set new_frame
        newFrame = CGRectMake(0,
                              frame.size.height - y_offset,
                              frame.size.width,
                              ORBV_DEF_H);
        self.frame = newFrame;
        
        // Change tint color
        self.tintColor = [UIColor darkGrayColor];
        
        // Insert text view
        CGRect input_frame = CGRectMake(0, 0, ORBV_DEF_TEXT_W, ORBV_DEF_TEXT_H);
        self.inputView = [[UITextView alloc] initWithFrame:input_frame];
        [self.inputView.layer setCornerRadius:10.0];
        self.inputView.delegate = self;
        self.inputView.contentInset = UIEdgeInsetsMake(4, 0, -4, 0);
        
        UIBarButtonItem *textView = [[UIBarButtonItem alloc] initWithCustomView:self.inputView];
        
        // Insert post button
        self.postButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonSystemItemAction target:self action:@selector(sendAction)];
        
        // Add items to the array
        self.items = [NSArray arrayWithObjects:textView, self.postButton, nil];
        
        // Add notifications for keyboard
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissKeyboard:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - Instance Functions

- (void)sendAction {
    // TODO: Make the animation smoother. For larger lines of text, resetting the view will
    // show a gap between the keyboard for a short period of time.
    // Send whatever is in the textview as a delegate and remove text from textview
    NSString *message = self.inputView.text;
    [self.orbvDelegate sendPressed:message];
    
    // Resign the responder
    if ([self.inputView isFirstResponder]) {
        [self.inputView resignFirstResponder];
    }
    
    // Change the view
    [self resetView];
}

- (void)dismissKeyboard:(NSNotification *)notification {
    [self closedView];
}

- (void)showKeyboard:(NSNotification *)notification {
    // Local Variables
    CGRect frame = CGRectZero;
    CGFloat y_offset = 0.0;
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    // Get the keyboard frame
    self.keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
    // Move the toolbar back to its original position
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    
    // Calculate the y offset. If the view has a tabbar, the returned value will
    // already account for the offsets. Check for orientation as well.
    if (self.hasTabBar) {
        y_offset = self.frame.size.height - ORBV_DEF_TAB_H;
    } else {
        y_offset = self.frame.size.height;
    }
    
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        y_offset += self.keyboardSize.width;
    } else {
        y_offset += self.keyboardSize.height;
    }
    
    // Adjust the frame
    frame = self.frame;
    frame.origin.y = self.superview.frame.size.height - y_offset;
    self.frame = frame;
    
    [UIView commitAnimations];
}

- (void)orientationChanged:(NSNotification *)notification {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    CGRect newFrame = CGRectZero, frame = CGRectZero;
    CGFloat y_offset = 0.0, frameResize = 0.0;
    
    // Note: The width had to change before the contentSize would
    // update correctly. Otherwise it would show the contentsize
    // for the previous view and display incorrectly. There is probably
    // a better way to do this.
    // Update the frame to fit the content - width first
    frame = self.inputView.frame;
    frame.size.width = self.superview.frame.size.width * .865;
    self.inputView.frame = frame;
    
    // Then height
    frame = self.inputView.frame;
    frame.size.height = self.inputView.contentSize.height;
    self.inputView.frame = frame;
    
    // Get the frameResize height value
    frameResize = frame.size.height + 10.0; // gap between textview and toolbar
    
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        // Check if the inputView is first responder (for keyboard)
        if ([self.inputView isFirstResponder]) {
            // Make adjustments for the keyboard height
            y_offset += self.keyboardSize.width - ORBV_DEF_TAB_H + frameResize;
        } else {
            y_offset += frameResize;
        }
    } else {
        // Portrait
        if ([self.inputView isFirstResponder]) {
            // Make adjustments for the keyboard height
            y_offset += self.keyboardSize.height - ORBV_DEF_TAB_H + frameResize;
        } else {
            y_offset += frameResize;
        }
        // Change the frame of inputView
        self.inputView.frame = CGRectMake(0, 0, ORBV_DEF_TEXT_W, self.inputView.contentSize.height);
    }
    
    // Adjust frame
    newFrame = CGRectMake(0,
                          self.superview.frame.size.height - y_offset,
                          self.superview.frame.size.width,
                          frameResize);
    
    self.frame = newFrame;
}

#pragma mark - UITextViewDelegate Functions

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // Make sure the height does not grow forever
    if (self.frame.origin.y > ORBV_GROWTH_MARGIN) {
        // Update the frame to fit the content
        CGRect frame = textView.frame;
        frame.size.height = textView.contentSize.height;
        textView.frame = frame;
        
        // Calculate new height
        CGFloat new_height = frame.size.height + 10.0; // The added float leaves a gap for the toolbar
        
        // Move the toolbar so that it stays "connected" to the keyboard
        self.frame = CGRectMake(0,
                                self.frame.origin.y + self.frame.size.height - new_height,
                                self.superview.frame.size.width,
                                new_height);
    }
    
    return YES;
}

- (void)closedView {
    // Move the toolbar back to its original position
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    
    // Reset the frame
    CGRect frame = self.frame;
    frame.origin.y = self.superview.frame.size.height - self.frame.size.height;
    self.frame = frame;
    
    [UIView commitAnimations];
}

- (void)resetView {
    // Resets the toolbar size to defaults;
    // Set text to empty so resize will return to default
    self.inputView.text = @"";
    CGRect frame = self.inputView.frame;
    frame.size.height = self.inputView.contentSize.height;
    self.inputView.frame = frame;
    
    // Reset toolbar size.
    self.frame = CGRectMake(0,
                            self.superview.frame.size.height - ORBV_DEF_H,
                            self.superview.frame.size.width,
                            ORBV_DEF_H);
}

@end

