//
//  EasyPermission.h
//  EasyPermissionDemo
//
//  Created by JungHsu on 2017/11/16.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import <UIKit/UIKit.h>


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

NS_ASSUME_NONNULL_BEGIN
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

@interface EasyPermission(PhotoLibray)
+ (EasyAuthorityStatus)checkPhotoLibrayAuthority;
+ (void)requestPhotoLibrayPermission:(StatusBlock)statusBlock;
@end

@interface EasyPermission(Camera)
+ (EasyAuthorityStatus)checkCameraAuthority;
+ (void)requestCameraPermission:(StatusBlock)statusBlock;
@end

@interface EasyPermission(AddressBook)
+ (EasyAuthorityStatus)checkAddressBookAuthority;
+ (void)requestAddressBookPermission:(StatusBlock)statusBlock;
@end

@interface EasyPermission(Microphone)
+ (EasyAuthorityStatus)checkMicrophoneAuthority;
+ (void)requestMicrophonePermission:(StatusBlock)statusBlock;
@end

@interface EasyPermission(MediaLibrary)
+ (EasyAuthorityStatus)checkMediaLibraryAuthority;
+ (void)requestMediaLibraryPermission:(StatusBlock)statusBlock;
@end

@interface EasyPermission(Location)
+ (EasyAuthorityStatus)checkLocationAuthority;
+ (void)requestLocationPermissionType:(EasyLocationRequestType)type completion:(StatusBlock)statusBlock;
@end

@interface EasyPermission(Notification)
+ (void)checkNotificationAuthorityStatus:(StatusBlock)statusBlock;
@end

@interface EasyPermission(Calendar)
+ (EasyAuthorityStatus)checkCalendarAuthority;
+ (void)requestCalendarPermission:(StatusBlock)statusBlock;
@end

@interface EasyPermission(Reminder)
+ (EasyAuthorityStatus)checkReminderAuthority;
+ (void)requestReminderPermission:(StatusBlock)statusBlock;
@end

NS_ASSUME_NONNULL_END
