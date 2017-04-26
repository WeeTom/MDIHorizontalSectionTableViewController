//
//  MDITableViewController.m
//  folder
//
//  Created by Wee Tom on 15/6/30.
//  Copyright (c) 2015年 Mingdao. All rights reserved.
//

#import "MDITableViewController.h"

@interface MDITableViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSIndexPath *tempIndexPath;
@end

@implementation MDITableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"MovingView Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    if ([self.tempIndexPath isEqual:indexPath]) {
        [[cell viewWithTag:1] removeFromSuperview];
        cell.contentView.backgroundColor = [UIColor grayColor];
    } else {
        MDIMovingView *mv = (MDIMovingView *)[cell viewWithTag:1];
        if (!mv) {
            mv = [[MDIMovingView alloc] initWithFrame:cell.contentView.bounds];
            mv.identity = 2;
            mv.tag = 1;
            mv.delegate = self.movingViewDelegate;
            mv.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            mv.backgroundColor = [UIColor blueColor];
            [cell.contentView addSubview:mv];
        }
        mv.identity = 2;
        mv.delegate = self.movingViewDelegate;
        mv.alpha = 1;
        mv.userInfo = @{@"indexPath":indexPath, @"object":self.objects[indexPath.row]};
        
        [self.dataSoure renderCellForRowInRow:indexPath.row baseOnMovingView:mv data:self.objects[indexPath.row] controller:self];
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.delegate hsTableViewController:self heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate hsTableViewController:self didSelectRowAtIndexPath:indexPath];
}

static CGPoint lastPosition;
- (void)movingViewDidStart:(MDIMovingView *)theMovingView
{
    self.tempIndexPath = theMovingView.userInfo[@"indexPath"];
    lastPosition = [theMovingView.superview convertPoint:theMovingView.center toView:self.tableView];
}

- (void)movingViewDidMove:(MDIMovingView *)theMovingView
{
    CGPoint convertedCenter = [theMovingView.superview convertPoint:theMovingView.center toView:self.tableView];
    BOOL goingUp = (convertedCenter.y - lastPosition.y) < 0;
    BOOL goingDown = (convertedCenter.y - lastPosition.y) > 0;
    lastPosition = convertedCenter;
    CGFloat mvBottom = convertedCenter.y + theMovingView.frame.size.height/2.0;
    CGFloat mvTop = convertedCenter.y - theMovingView.frame.size.height/2.0;
    
    if (goingUp) {
        if (!self.tempIndexPath) {
            UITableViewCell *nearstCell = nil;
            NSArray *visibleCells = self.tableView.visibleCells;
            if (visibleCells.count > 0) {
                for (int i = 0; i < visibleCells.count; i++) {
                    UITableViewCell *cell = visibleCells[i];
                    CGPoint cellCenter = [cell.superview convertPoint:cell.center toView:self.tableView];
                    CGFloat top = cellCenter.y - cell.frame.size.height/2.0;
                    if (mvTop < top) {
                        nearstCell = cell;
                        break;
                    }
                }
                if (!nearstCell) {
                    [self.objects addObject:theMovingView.userInfo[@"object"]];
                    NSIndexPath *upperIndexPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] inSection:0];
                    self.tempIndexPath = upperIndexPath;
                    [self.tableView insertRowsAtIndexPaths:@[self.tempIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                } else {
                    NSIndexPath *upperIndexPath = [self.tableView indexPathForCell:nearstCell];
                    [self.tableView beginUpdates];
                    id object = theMovingView.userInfo[@"object"];
                    NSInteger tempIndex = MAX(0, upperIndexPath.row - 1);
                    [self.objects insertObject:object atIndex:tempIndex];
                    NSIndexPath *tempIP = [NSIndexPath indexPathForRow:tempIndex inSection:upperIndexPath.section];
                    self.tempIndexPath = tempIP;
                    [self.tableView insertRowsAtIndexPaths:@[tempIP] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView endUpdates];
                }
            } else {
                [self.objects addObject:theMovingView.userInfo[@"object"]];
                NSIndexPath *upperIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                self.tempIndexPath = upperIndexPath;
                [self.tableView insertRowsAtIndexPaths:@[self.tempIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        } else if (self.tempIndexPath.row > 0) {
            NSIndexPath *upperIndexPath = [NSIndexPath indexPathForRow:self.tempIndexPath.row - 1 inSection:self.tempIndexPath.section];
            UITableViewCell *upperCell = [self.tableView cellForRowAtIndexPath:upperIndexPath];
            if (![self.tableView.visibleCells containsObject:upperCell]) {
                [self.tableView scrollToRowAtIndexPath:upperIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
            CGPoint cellCenter = [upperCell.superview convertPoint:upperCell.center toView:self.tableView];
            CGFloat bottom = cellCenter.y + upperCell.frame.size.height/2.0;
            if (mvTop < bottom) {
                [self.tableView beginUpdates];
                id object = self.objects[self.tempIndexPath.row];
                [self.objects removeObjectAtIndex:self.tempIndexPath.row];
                [self.objects insertObject:object atIndex:self.tempIndexPath.row - 1];
                NSIndexPath *tempIP = self.tempIndexPath;
                self.tempIndexPath = [NSIndexPath indexPathForRow:self.tempIndexPath.row - 1 inSection:self.tempIndexPath.section];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:tempIP.row - 1 inSection:tempIP.section],[NSIndexPath indexPathForRow:tempIP.row inSection:tempIP.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
                return;
            }
        }
    } else if (goingDown) {
        if (!self.tempIndexPath) {
            UITableViewCell *nearstCell = nil;
            NSArray *visibleCells = self.tableView.visibleCells;
            if (visibleCells.count > 0) {
                for (int i = 0; i < visibleCells.count; i++) {
                    UITableViewCell *cell = visibleCells[i];
                    CGPoint cellCenter = [cell.superview convertPoint:cell.center toView:self.tableView];
                    CGFloat bottom = cellCenter.y + cell.frame.size.height/2.0;
                    if (mvBottom < bottom) {
                        nearstCell = cell;
                        break;
                    }
                }
                if (!nearstCell) {
                    [self.objects addObject:theMovingView.userInfo[@"object"]];
                    NSIndexPath *downIndexPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] inSection:0];
                    self.tempIndexPath = downIndexPath;
                    [self.tableView insertRowsAtIndexPaths:@[self.tempIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                } else {
                    NSIndexPath *downIndexPath = [self.tableView indexPathForCell:nearstCell];
                    [self.tableView beginUpdates];
                    id object = theMovingView.userInfo[@"object"];
                    [self.objects insertObject:object atIndex:downIndexPath.row];
                    NSIndexPath *tempIP = [NSIndexPath indexPathForRow:downIndexPath.row inSection:downIndexPath.section];
                    self.tempIndexPath = tempIP;
                    [self.tableView insertRowsAtIndexPaths:@[tempIP] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView endUpdates];
                }
            } else {
                [self.objects addObject:theMovingView.userInfo[@"object"]];
                NSIndexPath *upperIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                self.tempIndexPath = upperIndexPath;
                [self.tableView insertRowsAtIndexPaths:@[self.tempIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        } else if (self.tempIndexPath.row < [self.tableView numberOfRowsInSection:self.tempIndexPath.section] - 1) {
            NSIndexPath *downIndexPath = [NSIndexPath indexPathForRow:self.tempIndexPath.row + 1 inSection:self.tempIndexPath.section];
            UITableViewCell *downCell = [self.tableView cellForRowAtIndexPath:downIndexPath];
            if (![self.tableView.visibleCells containsObject:downCell]) {
                [self.tableView scrollToRowAtIndexPath:downIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
            CGPoint cellCenter = [downCell.superview convertPoint:downCell.center toView:self.tableView];
            CGFloat top = cellCenter.y - downCell.frame.size.height/2.0;
            if (mvBottom > top) {
                [self.tableView beginUpdates];
                id object = self.objects[self.tempIndexPath.row];
                [self.objects removeObjectAtIndex:self.tempIndexPath.row];
                [self.objects insertObject:object atIndex:self.tempIndexPath.row + 1];
                NSIndexPath *tempIP = self.tempIndexPath;
                self.tempIndexPath = [NSIndexPath indexPathForRow:tempIP.row+1 inSection:tempIP.section];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:tempIP.row inSection:tempIP.section],[NSIndexPath indexPathForRow:tempIP.row + 1 inSection:tempIP.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            }
        }
    }
}

- (void)movingViewDidEnd:(MDIMovingView *)theMovingView
{
    if (self.tempIndexPath) {
        NSMutableDictionary *mDic = [theMovingView.userInfo mutableCopy];
        [mDic setObject:self.tempIndexPath forKey:@"indexPath"];
        theMovingView.userInfo = mDic;
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.tempIndexPath];
        [[cell viewWithTag:1] removeFromSuperview];
        self.tempIndexPath = nil;
        [UIView animateWithDuration:0.2 animations:^{
            theMovingView.center = [cell.contentView.superview convertPoint:cell.contentView.center toView:theMovingView.superview];
        } completion:^(BOOL finished) {
            if (finished) {
                theMovingView.center = CGPointMake(cell.contentView.bounds.size.width/2.0, cell.contentView.bounds.size.height/2.0);
                [cell.contentView addSubview:theMovingView];
                [self.tableView reloadData];
            }
        }];
    } else {
        [theMovingView removeFromSuperview];
        if (self.objects.count > 0) {
            [self.objects insertObject:theMovingView.userInfo[@"object"] atIndex:0];
        } else {
            [self.objects addObject:theMovingView.userInfo[@"object"]];
        }
        [self.tableView reloadData];
    }
}

- (void)movingViewDidCancel:(MDIMovingView *)theMovingView
{
    if (self.tempIndexPath) {
        [self.objects removeObjectAtIndex:self.tempIndexPath.row];
        [self.tableView reloadData];
        self.tempIndexPath = nil;
    }
}
@end
