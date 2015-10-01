//
//  ETFlowView+Text.m
//  InEvent
//
//  Created by Pedro Góes on 9/30/15.
//  Copyright © 2015 Pedro G√≥es. All rights reserved.
//

#import "ETFlowView+Text.h"
#import "ETFlowView+Resize.h"
#import "UIView+Bounds.h"

@implementation ETFlowView (Text)

// Text
- (void)resizeAndSetText:(NSString *)text forTextInput:(UIView *)textInput {
    [self resizeAndSetText:text forTextInput:textInput withMinimumHeight:0.0f];
}

- (void)resizeAndSetText:(NSString *)text forTextInput:(UIView *)textInput withMinimumHeight:(CGFloat)mininumHeight {
    [self setHeight:[textInput setText:text withMinimumHeight:mininumHeight andResize:NO] forView:textInput];
}

- (void)resizeAndSetText:(NSString *)text forTextInput:(UIView *)textInput expandingWrapperWithMinimumHeight:(CGFloat)wrapperMininumHeight {
    [self expandFrame:([text length] != 0) forView:textInput.superview withHeight:((textInput.superview.frame.size.height > wrapperMininumHeight) ? textInput.superview.frame.size.height : wrapperMininumHeight)];
    [self resizeAndSetText:text forTextInput:textInput];
}

- (void)resizeAndSetEditable:(BOOL)editable forTextInput:(UITextView *)textInput withMinimumHeight:(CGFloat)mininumHeight expandingWrapperWithMinimumHeight:(CGFloat)wrapperMininumHeight {
    [self expandFrame:editable forView:textInput.superview withHeight:((textInput.superview.frame.size.height > wrapperMininumHeight) ? textInput.superview.frame.size.height : wrapperMininumHeight)];
    [self resizeAndSetText:textInput.text forTextInput:textInput withMinimumHeight:mininumHeight];
    [textInput setEditable:editable];
}

// Attributed Text
- (void)resizeAndSetAttributedText:(NSAttributedString *)text forTextInput:(UIView *)textInput {
    [self setHeight:[textInput setAttributedText:text withMinimumHeight:0.0f andResize:NO] forView:textInput];
}

- (void)resizeAndSetAttributedText:(NSAttributedString *)text forTextInput:(UIView *)textInput withMinimumHeight:(CGFloat)mininumHeight {
    [self setHeight:[textInput setAttributedText:text withMinimumHeight:mininumHeight andResize:NO] forView:textInput];
}

@end
