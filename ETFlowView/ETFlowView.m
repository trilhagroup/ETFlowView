//
//  ETFlowView.m
//  InEvent
//
//  Created by Pedro Góes on 05/10/12.
//  Copyright (c) 2012 Pedro Góes. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "ETFlowView.h"

@interface ETFlowView () {
    BOOL isUpdating;
    BOOL isScrolling;
}

@end

@implementation ETFlowView

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initParams];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self initParams];
}

- (void)initParams {
    // Params
    _shouldBind = NO;
    isUpdating = NO;
    isScrolling = NO;

    // Content
    self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    self.delegate = self;
	[self flashScrollIndicators];
}

#pragma mark - View Cycle

- (void)didAddSubview:(UIView *)subview {
    // KVO
    if (_shouldBind) [self registerRecursively:subview];
}

- (void)willRemoveSubview:(UIView *)subview {
    // KVO
    if (_shouldBind) [self unregisterRecursively:subview];
}

- (void)dealloc {
    // KVO
    if (_shouldBind) [self unregisterRecursively:self];
}

#pragma mark - Setters

- (void)setShouldBind:(BOOL)shouldBind {
    
    if (_shouldBind != shouldBind) {
        
        if (shouldBind == YES) {
            [self registerRecursively:self];
        } else {
            [self unregisterRecursively:self];
        }
        
        _shouldBind = shouldBind;
    }
}

#pragma mark - Private Methods

- (void)registerRecursively:(UIView *)masterView {
    
    // Register masterView
    [self addKeyPathObserver:masterView];
    
    // Register all views
    for (UIView *view in masterView.subviews) {
        [self registerRecursively:view];
    }
}

- (void)unregisterRecursively:(UIView *)masterView {
    
    // Unregister masterView
    [self removeKeyPathObserver:masterView];

    // Unregister all views
    for (UIView *view in masterView.subviews) {
        [self unregisterRecursively:view];
    }
}

#pragma mark - Public methods

- (void)updateView:(UIView *)view toFrame:(CGRect)newFrame {
    CGRect oldFrame = view.frame;
    view.frame = newFrame;
    [self updateHierarchyForView:view fromOldFrame:oldFrame toNewFrame:newFrame];
}

#pragma mark - KVO methods

- (void)addKeyPathObserver:(UIView *)view {
    [view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}

- (void)removeKeyPathObserver:(UIView *)view {
    
    @try {
        [view removeObserver:self forKeyPath:@"frame" context:NULL];
    }
    @catch (NSException * __unused exception) {
        // Nothing important, just log for know reasons
        NSLog(@"%@, %@", exception.name, exception.reason);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    // We cannot be on scroll mode
    if (!isScrolling) {
        
        // Make sure we are dealing with frames
        if ([keyPath isEqualToString:@"frame"]) {
            
            // Capture some properties
            CGRect newFrame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
            CGRect oldFrame = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
            
            // See if we have a view
            if ([object isKindOfClass:[UIView class]]) {
                // Update hierarchy
                [self updateHierarchyForView:((UIView *)object) fromOldFrame:oldFrame toNewFrame:newFrame];
            }
        }
    }
    
}

#pragma mark - Resizing Methods
    
- (void)updateHierarchyForView:(UIView *)view fromOldFrame:(CGRect)oldFrame toNewFrame:(CGRect)newFrame {
    
    // Make sure our view is static at this moment
    if (!isUpdating) {
        
        // Get their delta
        CGFloat delta = newFrame.size.height - oldFrame.size.height;
        
        // Limit to relevant values
        if (delta != 0.0f) {
            isUpdating = YES;
            [self updateViewHeight:view basedOnFrame:CGRectZero by:delta];
            isUpdating = NO;
        }
    }
}

- (void)updateViewHeight:(UIView *)masterView basedOnFrame:(CGRect)innerFrame by:(CGFloat)delta {
    
    CGRect frame;
    
    if ([masterView.superview.subviews count] > 0) {
        
        // Loop through all the siblings elements
        for (UIView *view in masterView.superview.subviews) {
            
            /* Make sure that the position of the view inside a view with a very big height is not considered below an external but closer to top view.
             
             Let's draw an example:
             
             /////////     /////////
             /       /     /       /
             /       /  ///////////////
             /       /  / BBBBBBBBBBB /
             /  ///  /  ///////////////
             / /AAA/ /     /       /
             /  ///  /     /       /
             /       /     /       /
             /////////     /////////
            
             Even tough view's A parent has a smaller .y compared to view's B, view B shall not be moved, because externally it is below view A.
             
             If you didn't understand, I don't care :)
             
             */
            
            // Check if they are below the current view
            if (view.frame.origin.y > (masterView.frame.origin.y + innerFrame.origin.y) && view != masterView) {
                
                // Update view frame
                frame = view.frame;
                frame.origin.y += delta;
                view.frame = frame;
            }
        }
        
        // Resize our view content size or go through its childs
        if (masterView.superview == self) {
            // Change to fit perfectly
            self.contentSize = CGSizeMake(self.contentSize.width, self.contentSize.height + delta);
            
        } else {
            // Resize the view frame
            frame = masterView.superview.frame;
            frame.size.height += delta;
            masterView.superview.frame = frame;
            
            // Update parent views
            [self updateViewHeight:masterView.superview basedOnFrame:masterView.frame by:delta];
        }
    }
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    isScrolling = YES;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    isScrolling = scrollView.decelerating;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    isScrolling = !decelerate;
}

@end
