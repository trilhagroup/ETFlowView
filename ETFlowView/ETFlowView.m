//
//  ETFlowView.m
//  InEvent
//
//  Created by Pedro Góes on 05/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ETFlowView.h"

@interface ETFlowView () {
    BOOL isUpdating;
}

@end

@implementation ETFlowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isUpdating = NO;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    isUpdating = NO;
    [self registerRecursively:self];
}

#pragma mark - View cycle

- (void)addSubview:(UIView *)view {
    
    [super addSubview:view];
    
    // KVO
    [self registerRecursively:view];
//    [view addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}

- (void)willRemoveSubview:(UIView *)subview {
    
    [self removeKeyPathObserver:subview];
    
    [super removeFromSuperview];
}

- (void)dealloc {
    
    for (UIView *view in self.subviews) {
        [self removeKeyPathObserver:view];
    }
}

#pragma mark - Private Methods

- (void)registerRecursively:(UIView *)masterView {
    
    if ([masterView.subviews count] > 0) {
        
        // Register all views
        for (UIView *view in masterView.subviews) {
            [self addKeyPathObserver:view];
            [self registerRecursively:view];
        }
    }
}

#pragma mark - KVO methods

- (void)addKeyPathObserver:(UIView *)view {
    
    [view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [view.layer addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [view.layer addObserver:self forKeyPath:@"transform" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [view.layer addObserver:self forKeyPath:@"position" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [view.layer addObserver:self forKeyPath:@"zPosition" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [view.layer addObserver:self forKeyPath:@"anchorPoint" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [view.layer addObserver:self forKeyPath:@"anchorPointZ" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [view.layer addObserver:self forKeyPath:@"zPosition" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [view.layer addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [view.layer addObserver:self forKeyPath:@"transform" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}

- (void)removeKeyPathObserver:(UIView *)view {
    
    @try {
        [view removeObserver:self forKeyPath:@"frame"];
        [view.layer removeObserver:self forKeyPath:@"bounds"];
        [view.layer removeObserver:self forKeyPath:@"transform"];
        [view.layer removeObserver:self forKeyPath:@"position"];
        [view.layer removeObserver:self forKeyPath:@"zPosition"];
        [view.layer removeObserver:self forKeyPath:@"anchorPoint"];
        [view.layer removeObserver:self forKeyPath:@"anchorPointZ"];
        [view.layer removeObserver:self forKeyPath:@"zPosition"];
        [view.layer removeObserver:self forKeyPath:@"frame"];
        [view.layer removeObserver:self forKeyPath:@"transform"];
    }
    @catch (NSException * __unused exception) {
        // Nothing important
    }
}


#pragma mark - Resizing methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (!isUpdating) {
    
        if ([keyPath isEqualToString:@"frame"]) {
            
            // Pick values
            CGRect newSize = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
            CGRect oldSize = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
            CGFloat delta = newSize.size.height - oldSize.size.height;
            
            // Limit to relevant values
            if (delta != 0.0f) {
            
                // See if we have a view
                if ([object isKindOfClass:[UIView class]]) {
                    
                    isUpdating = YES;
                    [self updateViewHeight:((UIView *)object) by:delta];
                    isUpdating = NO;
                }
            }
        }
    }
}

- (void)updateViewHeight:(UIView *)masterView by:(CGFloat)delta {
    
    CGRect frame;
    
    if ([masterView.superview.subviews count] > 0) {
        
        // Loop through all the elements
        for (UIView *view in masterView.superview.subviews) {
            
            // Check if they are below the current view
            if (masterView.frame.origin.y <= view.frame.origin.y && view != masterView) {
                
                // Update view frame
                frame = view.frame;
                frame.origin.y -= delta;
                frame.size.height += delta;
                view.frame = frame;
            }
        }
        
        if (masterView.superview != self) {
            // Update parent views
            [self updateViewHeight:masterView.superview by:delta];
        }
    }
}

@end
