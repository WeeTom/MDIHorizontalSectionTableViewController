//
//  MDIHorizontalSectionTableViewController.m
//  folder
//
//  Created by Wee Tom on 15/7/1.
//  Copyright (c) 2015年 Mingdao. All rights reserved.
//

#import "MDIHorizontalSectionTableViewController.h"

@interface MDIHorizontalSectionTableViewController () <UIScrollViewDelegate, MovingViewDelegate, MDITableViewControllerDataSource, MDITableViewControllerDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) MDIMovingView *movingView;
@property (strong, nonatomic) NSMutableArray *movingViews, *shadowViews, *tableVCs;
@property (strong, nonatomic) NSTimer *pageTimer;
@end

@implementation MDIHorizontalSectionTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageControl = [[UIPageControl alloc] init];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(40, 0, self.view.frame.size.width - 80, self.view.frame.size.height)];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.scrollView.delegate = self;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.pagingEnabled = YES;
    [self.view addSubview:self.scrollView];
}

- (void)reloadData
{
    self.pageControl.numberOfPages = self.sections.count;
    self.pageControl.currentPage = 0;
    self.scrollView.contentOffset = CGPointMake(0, 0);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width*self.pageControl.numberOfPages, self.scrollView.frame.size.height);
    
    NSMutableArray *array = [NSMutableArray array];
    NSMutableArray *mvcs = [NSMutableArray array];
    NSMutableArray *shadows = [NSMutableArray array];
    for (int i = 0 ; i < self.pageControl.numberOfPages; i ++) {
        UIView *shadow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width - 20, self.scrollView.frame.size.height - 80)];
        shadow.backgroundColor = [UIColor grayColor];
        shadow.alpha = 1;
        CGPoint pageCenter = CGPointMake((i + 0.5)*self.scrollView.frame.size.width, self.scrollView.frame.size.height/2.0);
        shadow.center = pageCenter;
        [shadows addObject:shadow];
        [self.scrollView addSubview:shadow];
        
        MDIMovingView *mv = [[MDIMovingView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width - 20, self.scrollView.frame.size.height - 80)];
        mv.identity = 1;
        mv.delegate = self;
        mv.backgroundColor = [UIColor colorWithRed:(rand()%256)/256.0 green:(rand()%256)/256.0 blue:(rand()%256)/256.0 alpha:1];
        mv.center = pageCenter;
        [array addObject:mv];
        [self.scrollView addSubview:mv];
        
        MDITableViewController *vc = [[MDITableViewController alloc] init];
        [mvcs addObject:vc];
        vc.objects = self.dataDic[self.sections[i]];
        vc.delegate = self;
        vc.dataSoure = self;
        vc.movingViewDelegate = self;
        [self addChildViewController:vc];
        vc.view.frame = CGRectMake(10, 60, mv.frame.size.width - 20, mv.frame.size.height - 80);
        [mv addSubview:vc.view];
    }
    self.shadowViews = shadows;
    self.movingViews = array;
    self.tableVCs = mvcs;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = scrollView.contentOffset.x/scrollView.frame.size.width;
}

#pragma mark - MD
- (void)movingViewDidStart:(MDIMovingView *)theMovingView
{
    if (theMovingView.identity == 1) {
        [self cancelTimer];
        self.movingView = theMovingView;
        [self.movingView.superview bringSubviewToFront:self.movingView];
        [UIView animateWithDuration:0.2 animations:^{
            self.movingView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(0.02), 1.02, 1.02);
            UIView *shaC = self.shadowViews[self.pageControl.currentPage];
            shaC.alpha = 0.5;
        }];
    } else if (theMovingView.identity == 2) {
        [self cancelTimer];
        self.movingView = theMovingView;
        CGPoint lsatCenter = self.movingView.center;
        self.movingView.center = [self.movingView.superview convertPoint:self.movingView.center toView:self.scrollView];
        [self.scrollView addSubview:self.movingView];
        CGPoint currentCenter = self.movingView.center;
        [self.movingView positionChanged:CGPointMake(currentCenter.x - lsatCenter.x, currentCenter.y - lsatCenter.y)];
        [UIView animateWithDuration:0.2 animations:^{
            self.movingView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(0.02), 1.02, 1.02);
        }];
        MDITableViewController *vc = self.tableVCs[self.pageControl.currentPage];
        [vc movingViewDidStart:theMovingView];
    }
}

- (void)movingViewDidMove:(MDIMovingView *)theMovingView
{
    if (theMovingView.identity == 2) {
        MDITableViewController *vc = self.tableVCs[self.pageControl.currentPage];
        [vc movingViewDidMove:theMovingView];
    }
    float leftBorder = self.pageControl.currentPage*self.scrollView.frame.size.width;
    float rightBorder = (self.pageControl.currentPage + 1)*self.scrollView.frame.size.width;
    float viewCenter = theMovingView.center.x;
    if ((viewCenter - leftBorder) < theMovingView.frame.size.width/2 - 30) {
        if (self.pageTimer) {
            if ([self.pageTimer.userInfo[@"D"] isEqualToString:@"P"]) {
                return;
            }
        }
        [self startTimer:YES];
    } else if ((rightBorder - viewCenter) < theMovingView.frame.size.width/2 - 30) {
        if (self.pageTimer) {
            if ([self.pageTimer.userInfo[@"D"] isEqualToString:@"N"]) {
                return;
            }
        }
        [self startTimer:NO];
    } else {
        [self cancelTimer];
    }
}

- (void)movingViewDidEnd:(MDIMovingView *)theMovingView
{
    if (theMovingView.identity == 1) {
        [self cancelTimer];
        [UIView animateWithDuration:0.2 animations:^{
            self.movingView.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(1.0, 1.0), 0);
            UIView *shaC = self.shadowViews[self.pageControl.currentPage];
            shaC.alpha = 0;
            CGPoint pageCenter = CGPointMake((self.pageControl.currentPage + 0.5)*self.scrollView.frame.size.width, self.scrollView.frame.size.height/2.0);
            self.movingView.center = pageCenter;
        }];
        [self.delegate hsTableViewControllerSectionViewOrderChanged:self section:self.sections[[self.movingViews indexOfObject:self.movingView]]];
        self.movingView = nil;
    } else if (theMovingView.identity == 2) {
        id data = self.movingView.userInfo[@"object"];
        [self cancelTimer];
        [UIView animateWithDuration:0.2 animations:^{
            self.movingView.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(1.0, 1.0), 0);
        }];
        MDITableViewController *vc = self.tableVCs[self.pageControl.currentPage];
        [vc movingViewDidEnd:theMovingView];
        [self.delegate hsTableViewControllerDataOrderChanged:self data:data];
    }
}

- (void)cancelTimer
{
    [self.pageTimer invalidate];
    self.pageTimer = nil;
}

- (void)startTimer:(BOOL)previoisOrNext
{
    self.pageTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:previoisOrNext?@selector(previousPage):@selector(nextPage) userInfo:@{@"D":previoisOrNext?@"P":@"N"} repeats:NO];
}

- (void)nextPage
{
    [self cancelTimer];
    if (self.movingView.identity == 1) {
        if (self.pageControl.currentPage < self.pageControl.numberOfPages - 1) {
            [UIView animateWithDuration:0.2 animations:^{
                UIView *shaC = self.shadowViews[self.pageControl.currentPage];
                shaC.alpha = 0;
                [shaC.superview sendSubviewToBack:shaC];
                UIView *shaN = self.shadowViews[self.pageControl.currentPage + 1];
                shaN.alpha = 0.5;
                [shaN.superview sendSubviewToBack:shaN];
                
                self.scrollView.contentOffset = CGPointMake(MIN((self.pageControl.currentPage + 1)*self.scrollView.frame.size.width, self.scrollView.contentSize.width - self.scrollView.frame.size.width), 0);
                CGPoint lastCenter = self.movingView.center;
                self.movingView.center = CGPointMake(lastCenter.x + self.scrollView.frame.size.width, lastCenter.y);
                [self.movingView positionChanged:CGPointMake(self.scrollView.frame.size.width, 0)];
            } completion:^(BOOL finished) {
                if (finished) {
                    [UIView animateWithDuration:0.2 animations:^{
                        MDIMovingView *movingN = self.movingViews[self.pageControl.currentPage];
                        CGPoint pageCenter = CGPointMake((self.pageControl.currentPage - 1 + 0.5)*self.scrollView.frame.size.width, self.scrollView.frame.size.height/2.0);
                        movingN.center = pageCenter;
                        [self.sections exchangeObjectAtIndex:self.pageControl.currentPage - 1 withObjectAtIndex:self.pageControl.currentPage];
                        [self.tableVCs exchangeObjectAtIndex:self.pageControl.currentPage - 1 withObjectAtIndex:self.pageControl.currentPage];
                        [self.movingViews exchangeObjectAtIndex:self.pageControl.currentPage - 1 withObjectAtIndex:self.pageControl.currentPage];
                    }];
                }
            }];
        }
    } else {
        if (self.pageControl.currentPage < self.pageControl.numberOfPages - 1) {
            [UIView animateWithDuration:0.2 animations:^{
                self.scrollView.contentOffset = CGPointMake(MIN((self.pageControl.currentPage + 1)*self.scrollView.frame.size.width, self.scrollView.contentSize.width - self.scrollView.frame.size.width), 0);
                CGPoint lastCenter = self.movingView.center;
                self.movingView.center = CGPointMake(lastCenter.x + self.scrollView.frame.size.width, lastCenter.y);
                [self.movingView positionChanged:CGPointMake(self.scrollView.frame.size.width, 0)];
            } completion:^(BOOL finished) {
                if (finished) {
                    MDITableViewController *vc = self.tableVCs[self.pageControl.currentPage - 1];
                    [vc movingViewDidCancel:self.movingView];
                }
            }];
        }
    }
}

- (void)previousPage
{
    [self cancelTimer];
    if (self.movingView.identity == 1) {
        if (self.pageControl.currentPage > 0) {
            [UIView animateWithDuration:0.2 animations:^{
                UIView *shaC = self.shadowViews[self.pageControl.currentPage];
                shaC.alpha = 0;
                [shaC.superview sendSubviewToBack:shaC];
                UIView *shaP = self.shadowViews[self.pageControl.currentPage - 1];
                shaP.alpha = 0.5;
                [shaP.superview sendSubviewToBack:shaP];
                
                self.scrollView.contentOffset = CGPointMake(MAX(0, (self.pageControl.currentPage - 1)*self.scrollView.frame.size.width), 0);
                CGPoint lastCenter = self.movingView.center;
                self.movingView.center = CGPointMake(lastCenter.x - self.scrollView.frame.size.width, lastCenter.y);
                [self.movingView positionChanged:CGPointMake(-self.scrollView.frame.size.width, 0)];
            } completion:^(BOOL finished) {
                if (finished) {
                    [UIView animateWithDuration:0.2 animations:^{
                        MDIMovingView *movingP = self.movingViews[self.pageControl.currentPage];
                        CGPoint pageCenter = CGPointMake((self.pageControl.currentPage + 1 + 0.5)*self.scrollView.frame.size.width, self.scrollView.frame.size.height/2.0);
                        movingP.center = pageCenter;
                        [self.sections exchangeObjectAtIndex:self.pageControl.currentPage withObjectAtIndex:self.pageControl.currentPage + 1];
                        [self.tableVCs exchangeObjectAtIndex:self.pageControl.currentPage withObjectAtIndex:self.pageControl.currentPage + 1];
                        [self.movingViews exchangeObjectAtIndex:self.pageControl.currentPage withObjectAtIndex:self.pageControl.currentPage + 1];
                    }];
                }
            }];
        }
    } else {
        if (self.pageControl.currentPage > 0) {
            [UIView animateWithDuration:0.2 animations:^{
                self.scrollView.contentOffset = CGPointMake(MAX(0, (self.pageControl.currentPage - 1)*self.scrollView.frame.size.width), 0);
                CGPoint lastCenter = self.movingView.center;
                self.movingView.center = CGPointMake(lastCenter.x - self.scrollView.frame.size.width, lastCenter.y);
                [self.movingView positionChanged:CGPointMake(-self.scrollView.frame.size.width, 0)];
            } completion:^(BOOL finished) {
                if (finished) {
                    MDITableViewController *vc = self.tableVCs[self.pageControl.currentPage + 1];
                    [vc movingViewDidCancel:self.movingView];
                }
            }];
        }
    }
}

#pragma mark -
- (CGFloat)hsTableViewController:(MDITableViewController *)theController heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.delegate hsTableViewController:self tableView:theController.tableView heightForRowInSection:[self.tableVCs indexOfObject:theController] row:indexPath.row];
}

- (void)hsTableViewController:(MDITableViewController *)theController didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate hsTableViewController:self tableView:theController.tableView didSelectRowInSection:[self.tableVCs indexOfObject:theController] row:indexPath.row];
}

#pragma mark - 
- (void)renderCellForRowInRow:(NSInteger)row baseOnMovingView:(MDIMovingView *)parentView data:(id)data controller:(MDITableViewController *)controller
{
    [self.dataSource renderCellForRowInSection:[self.tableVCs indexOfObject:controller] row:row baseOnMovingView:parentView data:data];
}

#pragma mark -
- (void)deleteSection:(NSInteger)section
{
    UIView *shaC = self.shadowViews[self.pageControl.numberOfPages - 1];
    [shaC removeFromSuperview];
    
    [self.dataDic removeObjectForKey:self.sections[section]];
    [self.sections removeObjectAtIndex:section];
    MDIMovingView *mv = self.movingViews[section];
    [UIView animateWithDuration:0.2 animations:^{
        mv.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [mv removeFromSuperview];
            [UIView animateWithDuration:0.2 animations:^{
                for (NSInteger i = section + 1; i < self.movingViews.count; i++) {
                    MDIMovingView *otherMV = self.movingViews[i];
                    otherMV.center = CGPointMake(otherMV.center.x - self.scrollView.frame.size.width, otherMV.center.y);
                }
            } completion:^(BOOL finished) {
                if (finished) {
                    [self.movingViews removeObjectAtIndex:section];
                    self.pageControl.numberOfPages = self.movingViews.count;
                    if (self.pageControl.currentPage > self.pageControl.numberOfPages - 1) {
                        self.pageControl.currentPage = self.pageControl.numberOfPages - 1;
                    }
                    [UIView animateWithDuration:0.2 animations:^{
                        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width*self.pageControl.numberOfPages, self.scrollView.frame.size.height);
                        self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width*self.pageControl.currentPage, 0);
                    }];
                }
            }];
        }
    }];
}

- (void)updateSection:(NSInteger)section
{
    [[self tableViewInSection:section] reloadData];
}

- (void)insertSectionAtSection:(id)object atIndex:(NSInteger)section withDatas:(NSArray *)datas;
{
    [self.sections insertObject:object atIndex:section];
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:datas];
    [self.dataDic setObject:array forKey:object];
    
    [UIView animateWithDuration:0.2 animations:^{
        for (NSInteger i = section; i < self.movingViews.count; i++) {
            MDIMovingView *otherMV = self.movingViews[i];
            otherMV.center = CGPointMake(otherMV.center.x + self.scrollView.frame.size.width, otherMV.center.y);
            [self.scrollView bringSubviewToFront:otherMV];
        }
    } completion:^(BOOL finished) {
        if (finished) {
            UIView *shadow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width - 20, self.scrollView.frame.size.height - 80)];
            shadow.backgroundColor = [UIColor grayColor];
            shadow.alpha = 1;
            shadow.center = CGPointMake((self.sections.count - 1 + 0.5)*self.scrollView.frame.size.width, self.scrollView.frame.size.height/2.0);
            [self.shadowViews addObject:shadow];
            [self.scrollView addSubview:shadow];
            [self.scrollView sendSubviewToBack:shadow];

            MDIMovingView *mv = [[MDIMovingView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width - 20, self.scrollView.frame.size.height - 80)];
            mv.identity = 1;
            mv.delegate = self;
            mv.backgroundColor = [UIColor colorWithRed:(rand()%256)/256.0 green:(rand()%256)/256.0 blue:(rand()%256)/256.0 alpha:1];
            mv.center = CGPointMake((section + 0.5)*self.scrollView.frame.size.width, self.scrollView.frame.size.height/2.0);
            mv.alpha = 0.5;
            
            [self.movingViews insertObject:mv atIndex:section];
            [self.scrollView addSubview:mv];
            
            MDITableViewController *vc = [[MDITableViewController alloc] init];
            [self.tableVCs insertObject:vc atIndex:section];
            vc.objects = array;
            vc.dataSoure = self;
            vc.movingViewDelegate = self;
            [self addChildViewController:vc];
            vc.view.frame = CGRectMake(10, 60, mv.frame.size.width - 20, mv.frame.size.height - 80);
            [mv addSubview:vc.view];
            [UIView animateWithDuration:0.2 animations:^{
                mv.alpha = 1;
            } completion:^(BOOL finished) {
                if (finished) {
                    self.pageControl.numberOfPages = self.movingViews.count;
                    [UIView animateWithDuration:0.2 animations:^{
                        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width*self.pageControl.numberOfPages, self.scrollView.frame.size.height);
                        self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width*self.pageControl.currentPage, 0);
                    }];
                }
            }];
        }
    }];
}

- (void)moveSectionDataFromSection:(NSInteger)fromSection toSection:(NSInteger)toSection
{
    if (fromSection != toSection) {
        if (fromSection > toSection) {
            id object = [self.sections objectAtIndex:fromSection];
            [self.sections removeObjectAtIndex:fromSection];
            [self.sections insertObject:object atIndex:toSection];
            MDIMovingView *mv = self.movingViews[fromSection];
            [self.scrollView bringSubviewToFront:mv];
            [UIView animateWithDuration:0.2 animations:^{
                mv.center = CGPointMake((toSection + 0.5)*self.scrollView.frame.size.width, self.scrollView.frame.size.height/2.0);
                for (NSInteger i = toSection; i < fromSection; i++) {
                    MDIMovingView *otherMV = self.movingViews[i];
                    otherMV.center = CGPointMake(otherMV.center.x + self.scrollView.frame.size.width, otherMV.center.y);
                    [self.scrollView bringSubviewToFront:otherMV];
                }
                [self.scrollView bringSubviewToFront:mv];
            }];
            [self.movingViews removeObjectAtIndex:fromSection];
            [self.movingViews insertObject:mv atIndex:toSection];
        } else {
            id object = [self.sections objectAtIndex:fromSection];
            [self.sections removeObjectAtIndex:fromSection];
            [self.sections insertObject:object atIndex:toSection];
            MDIMovingView *mv = self.movingViews[fromSection];
            [self.scrollView bringSubviewToFront:mv];
            [UIView animateWithDuration:0.2 animations:^{
                mv.center = CGPointMake((toSection + 0.5)*self.scrollView.frame.size.width, self.scrollView.frame.size.height/2.0);
                for (NSInteger i = fromSection + 1; i < toSection + 1; i++) {
                    MDIMovingView *otherMV = self.movingViews[i];
                    otherMV.center = CGPointMake(otherMV.center.x - self.scrollView.frame.size.width, otherMV.center.y);
                }
            }];
            [self.movingViews removeObjectAtIndex:fromSection];
            [self.movingViews insertObject:mv atIndex:toSection];
        }
    }
}

- (void)deleteDataInSection:(NSInteger)section row:(NSInteger)row
{
    NSMutableArray *origianlDatas = self.dataDic[self.sections[section]];
    [origianlDatas removeObjectAtIndex:row];
    UITableView *tv = [self tableViewInSection:section];
    [tv deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)updateData:(id)data inSection:(NSInteger)section row:(NSInteger)row
{
    NSMutableArray *origianlDatas = self.dataDic[self.sections[section]];
    [origianlDatas replaceObjectAtIndex:row withObject:data];
    UITableView *tv = [self tableViewInSection:section];
    [tv reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)insertData:(NSArray *)datas inSection:(NSInteger)section row:(NSInteger)row
{
    NSMutableArray *origianlDatas = self.dataDic[self.sections[section]];
    [origianlDatas insertObjects:datas atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(row, datas.count)]];
    UITableView *tv = [self tableViewInSection:section];
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < datas.count; i ++) {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:row + i inSection:0];
        [array addObject:ip];
    }
    [tv insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)moveDataFromSection:(NSInteger)fromSection fromRow:(NSInteger)fromRow toSection:(NSInteger)toSection toRow:(NSInteger)toRow
{
    NSMutableArray *fromDatas = self.dataDic[self.sections[fromSection]];
    NSMutableArray *toDatas = self.dataDic[self.sections[toSection]];
    id fromObject = fromDatas[fromRow];
    [fromDatas removeObjectAtIndex:fromRow];
    [toDatas insertObject:fromObject atIndex:toRow];

    if (fromSection == toSection) {
        UITableView *fromTV = [self tableViewInSection:fromSection];
        [fromTV beginUpdates];
        [fromTV moveRowAtIndexPath:[NSIndexPath indexPathForRow:fromRow inSection:0] toIndexPath:[NSIndexPath indexPathForRow:toRow inSection:0]];
        [fromTV endUpdates];
    } else {
        UITableView *fromTV = [self tableViewInSection:fromSection];
        UITableView *toTV = [self tableViewInSection:toSection];
        [fromTV deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:fromRow inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [toTV insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:toRow inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)scrollToSection:(NSInteger)section
{
    if (section >= self.sections.count) {
        section = self.sections.count - 1;
    }
    [self.scrollView setContentOffset:CGPointMake(section*self.scrollView.frame.size.width, 0) animated:YES];
}

- (MDIMovingView *)sectionViewInSection:(NSInteger)section
{
    return self.movingViews[section];
}

- (UITableView *)tableViewInSection:(NSInteger)section
{
    return [self.tableVCs[section] tableView];
}

- (MDIMovingView *)rowViewInSection:(NSInteger)section inRow:(NSInteger)row
{
    UITableView *tv = [self tableViewInSection:section];
    UITableViewCell *cell = [tv cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    MDIMovingView *mv = (MDIMovingView *)[cell.contentView viewWithTag:1];
    return mv;
}
@end
