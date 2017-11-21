//
//  EasyPermission+Reminder.h
//  EasyPermissionDemo
//
//  Created by JungHsu on 2017/11/21.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import "EasyPermission.h"

NS_ASSUME_NONNULL_BEGIN

@interface EasyPermission (Reminder)
+ (EasyAuthorityStatus)checkReminderAuthority;
+ (void)requestReminderPermission:(StatusBlock)statusBlock;
@end

NS_ASSUME_NONNULL_END
