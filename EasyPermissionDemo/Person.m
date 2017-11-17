//
//  Person.m
//  EasyPermissionDemo
//
//  Created by JungHsu on 2017/11/17.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import "Person.h"

@implementation Person
+ (void)testBlock:(void (^)(void))block{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        block();
    });
}
@end
