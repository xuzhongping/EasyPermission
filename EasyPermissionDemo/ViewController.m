//
//  ViewController.m
//  EasyPermissionDemo
//
//  Created by JungHsu on 2017/11/16.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import "ViewController.h"
#import "EasyPermission+PhotoLibrary.h"
#import "Person.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [EasyPermission requestPhotoLibrayPermission:^(EasyAuthorityStatus status) {
        [EasyPermission alertTitle:@"" message:@""];
    }];
}

- (void)test{
    NSLog(@"%s",__func__);
}
- (void)dealloc{
    
}
@end
