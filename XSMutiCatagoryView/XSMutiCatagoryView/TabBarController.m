//
//  TabBarController.m
//  XSMutiCatagoryView
//
//  Created by 薛纪杰 on 15/8/13.
//  Copyright (c) 2015年 薛纪杰. All rights reserved.
//

#import "TabBarController.h"
#import "XSMutiCatagoryViewController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    XSMutiCatagoryViewController *mcv = [[XSMutiCatagoryViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mcv];
    self.viewControllers = @[nav];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
