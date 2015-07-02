//
//  MDIMovingView.h
//  folder
//
//  Created by Wee Tom on 15/6/29.
//  Copyright (c) 2015年 Mingdao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDIMovingView;
@protocol MovingViewDelegate <NSObject>
- (void)movingViewDidStart:(MDIMovingView *)theMovingView;
- (void)movingViewDidMove:(MDIMovingView *)theMovingView;
- (void)movingViewDidEnd:(MDIMovingView *)theMovingView;
@end

@interface MDIMovingView : UIView
@property (assign, nonatomic) BOOL moveEnabled;
@property (assign, nonatomic) int identity;
@property (strong, nonatomic) NSDictionary *userInfo;
@property (weak, nonatomic) id<MovingViewDelegate> delegate;
- (void)positionChanged:(CGPoint)delta;
@end
