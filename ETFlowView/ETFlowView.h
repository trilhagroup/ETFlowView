//
//  ETFlowView.h
//  InEvent
//
//  Created by Pedro Góes on 21/09/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETFlowView : UIScrollView <UIScrollViewDelegate>

@property (assign, nonatomic) BOOL shouldBind;

- (void)updateView:(UIView *)view toFrame:(CGRect)newFrame;

@end
