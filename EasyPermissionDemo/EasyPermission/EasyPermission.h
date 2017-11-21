//
//  EasyPermission.h
//  EasyPermissionDemo
//
//  Created by JungHsu on 2017/11/16.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <pthread.h>
#import <CoreLocation/CoreLocation.h>


/**
 about EasyPermission's status enum
 */
typedef NS_ENUM(NSInteger,EasyAuthorityStatus){
    EasyAuthorizationStatusNotDetermined = 0, // User has not yet made a choice with regards to this application
    EasyAuthorizationStatusRestricted = 1, // This application is not authorized
    EasyAuthorizationStatusDenied = 2, // User has explicitly denied this application
    EasyAuthorizationStatusAuthorized = 3, // User has authorized this application
    EasyAuthorizationStatusTurnOff = 4 // the function not open,for location.....
};


/**
 about location type
 */
typedef NS_ENUM(NSInteger,EasyLocationRequestType){
    EasyLocationRequestTypeWhenInUse = 0, // location when in use
    EasyLocationRequestTypeAlway = 1  // alway location
};

typedef void(^StatusBlock)(EasyAuthorityStatus status);


/**
 unavailable class,don`t use
 */
@interface EasyPermissionHelper:NSObject<CLLocationManagerDelegate>
{
    @public
    CLLocationManager *_lmg;
    StatusBlock _locationBlock;
}
@end


@interface EasyPermission : NSObject

/**
 jump to setting
 */
+ (void)openSetting;

/**
 alert guide view
 This method only supports simple guide,
 if you should other guide,can custom
 
 @param title big title
 @param message subtitle
 */
+ (void)alertTitle:(nullable NSString *)title message:(nullable NSString *)message;
@end


