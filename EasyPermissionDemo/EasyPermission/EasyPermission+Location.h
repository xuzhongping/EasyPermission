//
//  EasyPermission+Location.h
//  EasyPermissionDemo
//
//  Created by JungHsu on 2017/11/21.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import "EasyPermission.h"

NS_ASSUME_NONNULL_BEGIN

@interface EasyPermission (Location)
+ (EasyAuthorityStatus)checkLocationAuthority;
+ (void)requestLocationPermissionType:(EasyLocationRequestType)type completion:(StatusBlock)statusBlock;
@end

NS_ASSUME_NONNULL_END
