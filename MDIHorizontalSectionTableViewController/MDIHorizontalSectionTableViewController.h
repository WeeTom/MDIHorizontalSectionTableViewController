//
//  MDIHorizontalSectionTableViewController.h
//  folder
//
//  Created by Wee Tom on 15/7/1.
//  Copyright (c) 2015年 Mingdao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDITableViewController.h"

@class MDIHorizontalSectionTableViewController;
@protocol MDIHorizontalSectionTableViewControllerDataSource <NSObject>
// TODO:MORE CUSTOM VIEWS
- (void)renderCellForRowInSection:(NSInteger)section row:(NSInteger)row baseOnMovingView:(MDIMovingView *)parentView data:(id)data;
@end

@protocol MDIHorizontalSectionTableViewControllerDelegate <NSObject>
- (CGFloat)hsTableViewController:(MDIHorizontalSectionTableViewController *)controller tableView:(UITableView *)tableView heightForRowInSection:(NSInteger)section row:(NSInteger)row;
- (void)hsTableViewController:(MDIHorizontalSectionTableViewController *)controller tableView:(UITableView *)tableView didSelectRowInSection:(NSInteger)section row:(NSInteger)row;
- (void)hsTableViewControllerSectionViewOrderChanged:(MDIHorizontalSectionTableViewController *)controller section:(id)section;
- (void)hsTableViewControllerDataOrderChanged:(MDIHorizontalSectionTableViewController *)controller data:(id)data;
@end

@interface MDIHorizontalSectionTableViewController : UIViewController
/**
 * section = [@[AnyObject1, AnyObject2...] mutableCopy];
 * dataDics = [@{AnyObject1:[[SomeObject1, SomeObject2...] mutableCopy]...} mutableCopy];
 */
@property (strong, nonatomic) NSMutableArray *sections;
@property (strong, nonatomic) NSMutableDictionary *dataDic;
@property (weak, nonatomic) id<MDIHorizontalSectionTableViewControllerDataSource> dataSource;
@property (weak, nonatomic) id<MDIHorizontalSectionTableViewControllerDelegate> delegate;

- (void)reloadData;

- (void)deleteSection:(NSInteger)section;
- (void)updateSection:(NSInteger)section;
- (void)insertSectionAtSection:(id)object atIndex:(NSInteger)section withDatas:(NSArray *)datas;
- (void)moveSectionDataFromSection:(NSInteger)fromSection toSection:(NSInteger)toSection;

- (void)deleteDataInSection:(NSInteger)section row:(NSInteger)row;
- (void)updateData:(id)data inSection:(NSInteger)section row:(NSInteger)row;
- (void)insertData:(NSArray *)datas inSection:(NSInteger)section row:(NSInteger)row;
- (void)moveDataFromSection:(NSInteger)fromSection fromRow:(NSInteger)fromRow toSection:(NSInteger)toSection toRow:(NSInteger)toRow;

- (void)scrollToSection:(NSInteger)section;

- (MDIMovingView *)sectionViewInSection:(NSInteger)section;
- (UITableView *)tableViewInSection:(NSInteger)section;
- (MDIMovingView *)rowViewInSection:(NSInteger)section inRow:(NSInteger)row;
@end
