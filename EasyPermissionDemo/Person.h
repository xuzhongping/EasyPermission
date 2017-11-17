//
//  Person.h
//  EasyPermissionDemo
//
//  Created by JungHsu on 2017/11/17.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject
+ (void)testBlock:(void(^)(void))block;
@end
