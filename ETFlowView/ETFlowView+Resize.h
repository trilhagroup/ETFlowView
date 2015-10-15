//
//  ETFlowView+Resize.h
//  InEvent
//
//  Created by Pedro Góes on 9/30/15.
//  Copyright © 2015 Pedro G√≥es. All rights reserved.
//

#import "ETFlowView.h"

@interface ETFlowView (Resize)

// Default Methods
- (void)expandFrame:(BOOL)expand forView:(UIView *)view;
- (void)expandFrame:(BOOL)expand forView:(UIView *)view withHeight:(CGFloat)height;
- (void)expandFrame:(BOOL)expand forView:(UIView *)view withAdditionalHeight:(CGFloat)additionalHeight;

- (void)expandFrame:(BOOL)expand forWrapperOfView:(UIView *)view;
- (void)expandFrame:(BOOL)expand forWrapperOfSquareView:(UIView *)view;
- (void)expandFrame:(BOOL)expand forWrapperOfView:(UIView *)view withHeight:(CGFloat)height;
- (void)expandFrame:(BOOL)expand forWrapperOfView:(UIView *)view withAdditionalHeight:(CGFloat)additionalHeight;

// Custom methods
- (void)toggleFrameForWrapperOfView:(UIView *)view basedOnText:(NSString *)text;
- (void)toggleFrameForWrapperOfView:(UIView *)view basedOnText:(NSString *)text withHeight:(CGFloat)height;
- (void)toggleFrameForWrapperOfView:(UIView *)view basedOnText:(NSString *)text withAdditionalHeight:(CGFloat)additionalHeight;

@end
