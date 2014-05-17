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
    isUpdating = NO;
    isScrolling = NO;

    // Content
    self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    self.delegate = self;
	[self flashScrollIndicators];
}

#pragma mark - Swizzling Methods

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [UIView class];
        
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        
        NSArray *methods = @[@"didAddSubview", @"didRemoveSubview"];
        
        for (int i = 0; i < [methods count]; i++) {
        
            SEL originalSelector = NSSelectorFromString([methods objectAtIndex:i]);
            SEL swizzledSelector = NSSelectorFromString([@"ss_" stringByAppendingString:[methods objectAtIndex:i]]);
            
            Method originalMethod = class_getInstanceMethod(class, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
            
            BOOL didAddMethod =
            class_addMethod(class,
                            originalSelector,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod));
            
            if (didAddMethod) {
                class_replaceMethod(class,
                                    swizzledSelector,
                                    method_getImplementation(originalMethod),
                                    method_getTypeEncoding(originalMethod));
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
    });
}

#pragma mark - View Cycle

- (void)ss_didAddSubview:(UIView *)view {
    // KVO
    [self registerRecursively:view];
}

- (void)ss_willRemoveSubview:(UIView *)subview {
    // KVO
    [self unregisterRecursively:subview];
}

- (void)dealloc {
    // KVO
    [self unregisterRecursively:self];
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


#pragma mark - Resizing Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (!isUpdating && !isScrolling) {
    
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
                    [self updateViewHeight:((UIView *)object) basedOnFrame:oldSize by:delta];
                    isUpdating = NO;
                }
            }
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
    isScrolling = decelerate;
}

@end
