//
//  ETFlowView+Text.h
//  InEvent
//
//  Created by Pedro Góes on 9/30/15.
//  Copyright © 2015 Pedro G√≥es. All rights reserved.
//

#import "ETFlowView.h"

@interface ETFlowView (Text)

// Text
- (void)resizeAndSetText:(NSString *)text forTextInput:(UIView *)textInput;
- (void)resizeAndSetText:(NSString *)text forTextInput:(UIView *)textInput withMinimumHeight:(CGFloat)mininumHeight;
- (void)resizeAndSetText:(NSString *)text forTextInput:(UIView *)textInput expandingWrapperWithMinimumHeight:(CGFloat)wrapperMininumHeight;
- (void)resizeAndSetEditable:(BOOL)editable forTextInput:(UITextView *)textInput withMinimumHeight:(CGFloat)mininumHeight expandingWrapperWithMinimumHeight:(CGFloat)wrapperMininumHeight;

// Attributed Text
- (void)resizeAndSetAttributedText:(NSAttributedString *)text forTextInput:(UIView *)textInput;
- (void)resizeAndSetAttributedText:(NSAttributedString *)text forTextInput:(UIView *)textInput withMinimumHeight:(CGFloat)mininumHeight;

@end
