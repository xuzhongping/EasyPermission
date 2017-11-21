//
//  EasyPermission+Microphone.h
//  EasyPermissionDemo
//
//  Created by JungHsu on 2017/11/21.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import "EasyPermission.h"

NS_ASSUME_NONNULL_BEGIN

@interface EasyPermission (Microphone)
+ (EasyAuthorityStatus)checkMicrophoneAuthority;
+ (void)requestMicrophonePermission:(StatusBlock)statusBlock;
@end

NS_ASSUME_NONNULL_END