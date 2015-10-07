//
//  ETFlowView+Resize.m
//  InEvent
//
//  Created by Pedro Góes on 9/30/15.
//  Copyright © 2015 Pedro G√≥es. All rights reserved.
//

#import "ETFlowView+Resize.h"
#import "UIView+Bounds.h"

@implementation ETFlowView (Resize)

/*
 Default methods
 */

- (void)expandFrame:(BOOL)expand forView:(UIView *)view {
    [self expandFrame:expand forView:view withHeight:36.0f];
}

- (void)expandFrame:(BOOL)expand forWrapperOfView:(UIView *)view {
    [self expandFrame:expand forWrapperOfView:view withHeight:44.0f];
}

- (void)expandFrame:(BOOL)expand forWrapperOfSquareView:(UIView *)view {
    [self expandFrame:expand forWrapperOfView:view withHeight:52.0f];
}

- (void)expandFrame:(BOOL)expand forWrapperOfView:(UIView *)view withHeight:(CGFloat)height {
    [self expandFrame:expand forView:view.superview withHeight:height];
}

- (void)expandFrame:(BOOL)expand forView:(UIView *)view withHeight:(CGFloat)height {
    
    // Search flowView's between given view and our root
    UIView *currentView = view;
    BOOL foundAnyFlowView = NO;
    while (currentView != self) {
        
        // Resize if we found an action wrapper
        if ([currentView isKindOfClass:[ETFlowView class]] && [(ETFlowView *)currentView isMatrix]) {
    
            // Configure as a matrix
            [(ETFlowView *)currentView setHeight:(expand ? height : 0.0f) forView:view];
            
            // Rerun algorithm on master view (since we have a flow view inside another flow view)
            [self updateView:currentView toFrame:CGRectMake(currentView.frame.origin.x, currentView.frame.origin.y, ((ETFlowView *)currentView).contentSize.width, ((ETFlowView *)currentView).contentSize.height)];
            
            // Mark as been found
            foundAnyFlowView = YES;
        }
        
        // Go to our superview (up the chain)
        currentView = currentView.superview;
        
    }
    
    // Finalize and set our height
    if (!foundAnyFlowView) {
        [self setHeight:(expand ? height : 0.0f) forView:view];
    }
}

- (void)setHeight:(CGFloat)height forView:(UIView *)view {
    [self updateView:view toFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, height)];
}

/*
 Custom methods
 */

- (void)hideFrameForView:(UIView *)view; {
    [self setHeight:0.0f forView:view];
}

- (void)updateFrameForSubview:(UIView *)view forString:(NSString *)string {
    [self expandFrame:([string length] > 1) forWrapperOfView:view];
}

@end