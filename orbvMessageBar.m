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
        self.inputView.contentInset = UIEdgeInsetsMake(4, 0, -2, 0);
        
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

#pragma mark - Instance Functions

- (void)sendAction {
    // TODO: Make the animation smoother. For larger lines of text, resetting the view will
    // show a gap between the keyboard for a short period of time.
    // Send whatever is in the textview as a delegate and remove text from textview
    NSString *message = self.inputView.text;
    [self.orbv_delegate sendPressed:message];
        
    // Change the view
    [self resetView];
    
    // Resign the responder
    [self endEditing:YES];
}

- (void)dismissKeyboard:(NSNotification *)notification {
    [self closedView];
}

- (void)showKeyboard:(NSNotification *)notification {
    // Get the keyboard frame
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
    // Move the toolbar back to its original position
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    
    CGRect frame = self.frame;
    frame.origin.y = self.superview.frame.size.height - keyboardSize.height - self.frame.size.height;
    self.frame = frame;
    
    [UIView commitAnimations];
}

#pragma mark - UITextViewDelegate Functions

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
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
    
    return YES;
}

- (void)closedView {
    // Move the toolbar back to its original position
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    
    CGRect frame = self.frame;
    frame.origin.y = self.superview.frame.size.height - self.frame.size.height;
    self.frame = frame;
    
    [UIView commitAnimations];
}

- (void)resetView {
    // Resets the toolbar size to defaults; does not change origin
    // Set text to empty so resize will return to default
    self.inputView.text = @"";
    CGRect frame = self.inputView.frame;
    frame.size.height = self.inputView.contentSize.height;
    self.inputView.frame = frame;
    
    // Reset toolbar size.
    self.frame = CGRectMake(0,
                            self.frame.origin.y,
                            self.superview.frame.size.width,
                            ORBV_DEF_H);
}

@end

