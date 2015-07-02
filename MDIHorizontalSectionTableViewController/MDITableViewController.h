//
//  MDITableViewController.h
//  folder
//
//  Created by Wee Tom on 15/6/30.
//  Copyright (c) 2015年 Mingdao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDIMovingView.h"

@class MDITableViewController;
@protocol MDITableViewControllerDelegate <NSObject>
- (CGFloat)hsTableViewController:(MDITableViewController *)theController heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)hsTableViewController:(MDITableViewController *)theController didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@protocol MDITableViewControllerDataSource <NSObject>
- (void)renderCellForRowInRow:(NSInteger)row baseOnMovingView:(MDIMovingView *)parentView data:(id)data controller:(MDITableViewController *)controller;
@end

@interface MDITableViewController : UIViewController
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *objects;
@property (weak, nonatomic) id<MDITableViewControllerDelegate> delegate;
@property (weak, nonatomic) id<MDITableViewControllerDataSource> dataSoure;
@property (weak, nonatomic) id<MovingViewDelegate> movingViewDelegate;

- (void)movingViewDidStart:(MDIMovingView *)theMovingView;
- (void)movingViewDidMove:(MDIMovingView *)theMovingView;
- (void)movingViewDidEnd:(MDIMovingView *)theMovingView;
- (void)movingViewDidCancel:(MDIMovingView *)theMovingView;
@end
