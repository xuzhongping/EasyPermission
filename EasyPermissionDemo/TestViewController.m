//
//  TestViewController.m
//  EasyPermissionDemo
//
//  Created by JungHsu on 2017/11/16.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import "TestViewController.h"
#import "ViewController.h"
#import "EasyPermission.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    ViewController *vc = [ViewController new];
    [self.navigationController pushViewController:vc animated:YES];
//    [EasyPermission alertTitle:@"开启权限" message:@"请前往开启权限"];
}
@end
