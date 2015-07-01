//
//  MDIMovingView.m
//  folder
//
//  Created by Wee Tom on 15/6/29.
//  Copyright (c) 2015年 Mingdao. All rights reserved.
//

#import "MDIMovingView.h"

@implementation MDIMovingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(buttonLongPressAction:)];
        [self addGestureRecognizer:longGesture];
        self.moveEnabled = YES;
    }
    return self;
}

static BOOL moving = NO;
static CGPoint lastPosition;
- (void)buttonLongPressAction:(UILongPressGestureRecognizer *)gesture
{
    if (!self.moveEnabled) {
        return;
    }
    switch (gesture.state) {
            case UIGestureRecognizerStateBegan:
            self.backgroundColor = [UIColor redColor];
            moving = YES;
            lastPosition = [gesture locationInView:self.superview];
            [self.delegate movingViewDidStart:self];
            break;
            case UIGestureRecognizerStateCancelled:
            break;
            case UIGestureRecognizerStateChanged:
            self.backgroundColor = [UIColor greenColor];
            if (moving) {
                CGPoint newPosition = [gesture locationInView:self.superview];
                CGPoint lastCenter = self.center;
                self.center = CGPointMake(lastCenter.x + newPosition.x - lastPosition.x, lastCenter.y + newPosition.y - lastPosition.y);
                lastPosition = newPosition;
                [self.delegate movingViewDidMove:self];
            }
            break;
            case UIGestureRecognizerStateEnded:
            self.backgroundColor = [UIColor blackColor];
            moving = NO;
            [self.delegate movingViewDidEnd:self];
            break;
            case UIGestureRecognizerStateFailed:
            break;
            case UIGestureRecognizerStatePossible:
            break;
        default:
            break;
    }
}

- (void)positionChanged:(CGPoint)delta
{
    lastPosition = CGPointMake(lastPosition.x + delta.x, lastPosition.y + delta.y);
}
@end
