//
//  ETFlowView.h
//  InEvent
//
//  Created by Pedro Góes on 21/09/13.
//  Copyright (c) 2013 Pedro Góes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETFlowView : UIScrollView <UIScrollViewDelegate>

@property (assign, nonatomic) BOOL bindKVO;
@property (assign, nonatomic) BOOL isMatrix;
@property (assign, nonatomic) BOOL fitFrameToContentSize;
@property (assign, nonatomic) CGFloat matrixHorizontalPadding;
@property (assign, nonatomic) CGFloat matrixVerticalPadding;

- (void)updateView:(UIView *)view toFrame:(CGRect)newFrame;

@end
