//
//  ViewController.m
//  folder
//
//  Created by Wee Tom on 15/6/29.
//  Copyright (c) 2015年 Mingdao. All rights reserved.
//

#import "ViewController.h"
#import "MDIHorizontalSectionTableViewController.h"

@interface ViewController () <MDIHorizontalSectionTableViewControllerDataSource, MDIHorizontalSectionTableViewControllerDelegate>
@property (strong, nonatomic) MDIHorizontalSectionTableViewController *vc;
@end

@implementation ViewController
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    MDIHorizontalSectionTableViewController *vc = [[MDIHorizontalSectionTableViewController alloc] init];
    vc.sections = [@[@"A", @"B", @"C", @"D"] mutableCopy];
    vc.dataDic = [@{vc.sections[0]:[@[@1, @2, @3] mutableCopy], vc.sections[1]:[@[@3, @4, @6] mutableCopy], vc.sections[2]:[@[@4, @5, @7] mutableCopy], vc.sections[3]:[@[@3, @5, @7, @99] mutableCopy]} mutableCopy];
    vc.dataSource = self;
    vc.delegate = self;
    [self addChildViewController:vc];
    vc.view.frame = self.view.bounds;
    [self.view addSubview:vc.view];
    [vc reloadData];
    self.vc = vc;
}

- (IBAction)action:(id)sender {
    // edit views by code
//    [self.vc moveSectionDataFromSection:1 toSection:0];
//    [self.vc moveSectionDataFromSection:0 toSection:1];
//    [self.vc insertSectionAtSection:@"X" atIndex:0 withDatas:@[@44]];
//    NSMutableArray *array = self.vc.dataDic[self.vc.sections[0]];
//    [array insertObject:@80 atIndex:0];
//    [self.vc updateSection:0];
//    [self.vc deleteSection:self.vc.sections.count - 1];
//    [self.vc deleteDataInSection:0 row:0];
//    [self.vc updateData:@90 inSection:0 row:0];
//    [self.vc insertData:@[@33, @4] inSection:0 row:1];
//    [self.vc moveDataFromSection:0 fromRow:0 toSection:1 toRow:2];
}

#pragma mark - Delegate
- (void)hsTableViewControllerSectionViewOrderChanged:(MDIHorizontalSectionTableViewController *)controller
{
    //NSArray *sections = controller.sections;
}

- (void)hsTableViewControllerDataOrderChanged:(MDIHorizontalSectionTableViewController *)controller
{
    //NSArray *sections = controller.sections;
    //NSDictionary *dataDic = controller.dataDic;
}

#pragma mark - DataSource
- (void)renderCellForRowInSection:(NSInteger)section row:(NSInteger)row baseOnMovingView:(MDIMovingView *)parentView data:(id)data
{
    UILabel *label = (UILabel *)[parentView viewWithTag:2];
    if (!label) {
        label = [[UILabel alloc] initWithFrame:parentView.bounds];
        label.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        label.tag = 2;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [parentView addSubview:label];
    }
    label.text = [data stringValue];
}
@end
