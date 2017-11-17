//
//  EasyPermission.m
//  EasyPermissionDemo
//
//  Created by JungHsu on 2017/11/16.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import "EasyPermission.h"
#import <Photos/PHPhotoLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <Contacts/Contacts.h>
#import <pthread.h>
#import <CoreLocation/CoreLocation.h>
#import <EventKit/EventKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface EasyPermissionHelper:NSObject<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *clmgr;
@property (nonatomic,   weak) StatusBlock statusBlock;
@property (nonatomic, assign) BOOL isRequestStatus;

@end

@implementation  EasyPermissionHelper
/*
 *  locationManager:didChangeAuthorizationStatus:
 *
 *  Discussion:
 *    Invoked when the authorization status changes for this application.
 */
extern inline void asyncMainQueue_block(void(^block)(void));
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (!self.isRequestStatus) return;
    
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        asyncMainQueue_block(^{
            if (self.statusBlock) {
                self.statusBlock(EasyAuthorizationStatusAuthorized);
            }
        });
    }
    [self setIsRequestStatus:NO];
}
@end


@implementation EasyPermission

static dispatch_queue_t         _concurrentQueue;
static pthread_mutex_t          _photoLibrary_lock;
static pthread_mutex_t          _camera_lock;
static pthread_mutex_t          _addressBook_lock;
static pthread_mutex_t          _microphone_lock;
static pthread_mutex_t          _mediaLibrary_lock;
static pthread_mutex_t          _location_lock;
static pthread_mutex_t          _bluetooth_lock;
static pthread_mutex_t          _notifications_lock;
static pthread_mutex_t          _calendar_lock;
static pthread_mutex_t          _reminder_lock;

static EasyPermissionHelper     *_helper;

static inline double currentVersion(){
    return [[UIDevice currentDevice].systemVersion doubleValue];
}

inline void asyncMainQueue_block(void(^block)(void)){
    if (block) {
        if ([NSThread currentThread]) {
            block();
        }else{
            dispatch_async(_concurrentQueue, ^{
                block();
            });
        }
    }
}

+ (void)load{
    _concurrentQueue = dispatch_queue_create("com.queue.easypermission", DISPATCH_QUEUE_CONCURRENT);
    pthread_mutex_init(&_photoLibrary_lock, NULL);
    pthread_mutex_init(&_camera_lock, NULL);
    pthread_mutex_init(&_addressBook_lock, NULL);
    pthread_mutex_init(&_microphone_lock, NULL);
    pthread_mutex_init(&_mediaLibrary_lock, NULL);
    pthread_mutex_init(&_location_lock, NULL);
    pthread_mutex_init(&_bluetooth_lock, NULL);
    pthread_mutex_init(&_notifications_lock, NULL);
    pthread_mutex_init(&_calendar_lock, NULL);
    pthread_mutex_init(&_reminder_lock, NULL);
    
    _helper = [[EasyPermissionHelper alloc]init];
    [_helper setIsRequestStatus:NO];
    _helper.clmgr = [[CLLocationManager alloc]init];
    [_helper.clmgr setDelegate:_helper];
}

+ (void)openSetting{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        if (currentVersion() < 10.0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
            [[UIApplication sharedApplication] openURL:url];
#pragma clang diagnostic pop
        }else{
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }

    
}

@end

@implementation EasyPermission(PhotoLibray)
+ (EasyAuthorityStatus)checkPhotoLibrayAuthority{
    return (EasyAuthorityStatus)[PHPhotoLibrary authorizationStatus];
}
+ (void)requestPhotoLibrayPermission:(StatusBlock)statusBlock{
    pthread_mutex_lock(&_photoLibrary_lock);
    EasyAuthorityStatus st = [self checkPhotoLibrayAuthority];
    dispatch_async(_concurrentQueue, ^{
        switch (st) {
            case EasyAuthorizationStatusNotDetermined:
            {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    pthread_mutex_unlock(&_photoLibrary_lock);
                    asyncMainQueue_block(^{
                        statusBlock((EasyAuthorityStatus)status);
                    });
                }];
            }
                break;
            case EasyAuthorizationStatusRestricted:
            {
                pthread_mutex_unlock(&_photoLibrary_lock);
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusRestricted);
                });
            }
                break;
            case EasyAuthorizationStatusDenied:
            {
                pthread_mutex_unlock(&_photoLibrary_lock);
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusDenied);
                });
                
            }
                break;
            case EasyAuthorizationStatusAuthorized:
            {
                pthread_mutex_unlock(&_photoLibrary_lock);
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusAuthorized);
                });
                
            }
                break;
                
            default:
                break;
        }
    });
}
@end


@implementation EasyPermission(Camera)
+ (EasyAuthorityStatus)checkCameraAuthority{
    return (EasyAuthorityStatus)[AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
}
+ (void)requestCameraPermission:(StatusBlock)statusBlock{
    pthread_mutex_lock(&_camera_lock);
    EasyAuthorityStatus st = [self checkCameraAuthority];
    dispatch_async(_concurrentQueue, ^{
        switch (st) {
            case EasyAuthorizationStatusNotDetermined:
            {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    pthread_mutex_unlock(&_camera_lock);
                    EasyAuthorityStatus cst = EasyAuthorizationStatusDenied;
                    if (granted) {
                        cst = EasyAuthorizationStatusAuthorized;
                    }
                    asyncMainQueue_block(^{
                        statusBlock(cst);
                    });
                }];
            }
                break;
            case EasyAuthorizationStatusRestricted:
            {
                pthread_mutex_unlock(&_camera_lock);
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusRestricted);
                });
            }
                break;
            case EasyAuthorizationStatusDenied:
            {
                pthread_mutex_unlock(&_camera_lock);
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusDenied);
                });
            }
                break;
            case EasyAuthorizationStatusAuthorized:
            {
                pthread_mutex_unlock(&_camera_lock);
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusAuthorized);
                });
            }
                break;
                
            default:
                break;
        }
    });
}
@end

@implementation EasyPermission(AddressBook)
+ (EasyAuthorityStatus)checkAddressBookAuthority{
    return (EasyAuthorityStatus)[CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
}
+ (void)requestAddressBookPermission:(StatusBlock)statusBlock{
    pthread_mutex_lock(&_addressBook_lock);
    EasyAuthorityStatus st = [self checkAddressBookAuthority];
    dispatch_async(_concurrentQueue, ^{
        switch (st) {
            case EasyAuthorizationStatusNotDetermined:
            {
                [[CNContactStore new] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                    pthread_mutex_unlock(&_addressBook_lock);
                    EasyAuthorityStatus cst = EasyAuthorizationStatusDenied;
                    if (granted) {
                        cst = EasyAuthorizationStatusAuthorized;
                    }
                    asyncMainQueue_block(^{
                        statusBlock(cst);
                    });
                }];
                
            }
                break;
            case EasyAuthorizationStatusRestricted:
            {
                pthread_mutex_unlock(&_addressBook_lock);
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusRestricted);
                });
            }
                break;
            case EasyAuthorizationStatusDenied:
            {
                pthread_mutex_unlock(&_addressBook_lock);
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusDenied);
                });
            }
                break;
            case EasyAuthorizationStatusAuthorized:
            {
                pthread_mutex_unlock(&_addressBook_lock);
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusAuthorized);
                });
            }
                break;
                
            default:
                break;
        }
    });
}
@end

@implementation EasyPermission(Microphone)
+ (EasyAuthorityStatus)checkMicrophoneAuthority{
    return (EasyAuthorityStatus)[AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
}
+ (void)requestMicrophonePermission:(StatusBlock)statusBlock{
    pthread_mutex_lock(&_microphone_lock);
    EasyAuthorityStatus st = [self checkMicrophoneAuthority];
    dispatch_async(_concurrentQueue, ^{
        switch (st) {
            case AVAuthorizationStatusNotDetermined:
            {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                    pthread_mutex_unlock(&_microphone_lock);
                    EasyAuthorityStatus cst = EasyAuthorizationStatusDenied;
                    if (granted) {
                        cst = EasyAuthorizationStatusAuthorized;
                    }
                    asyncMainQueue_block(^{
                        statusBlock(cst);
                    });
                }];
            }
                break;
            case AVAuthorizationStatusRestricted:
            {
                pthread_mutex_unlock(&_microphone_lock);
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusRestricted);
                });
            }
                break;
            case AVAuthorizationStatusDenied:
            {
                pthread_mutex_unlock(&_microphone_lock);
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusDenied);
                });
            }
                break;
            case AVAuthorizationStatusAuthorized:
            {
                pthread_mutex_unlock(&_microphone_lock);
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusAuthorized);
                });
            }
                break;
                
            default:
                break;
        }
    });
}
@end

@implementation EasyPermission(MediaLibrary)
+ (EasyAuthorityStatus)checkMediaLibraryAuthority{
    return (EasyAuthorityStatus)[MPMediaLibrary authorizationStatus];
}
+ (void)requestMediaLibraryPermission:(StatusBlock)statusBlock{
    pthread_mutex_lock(&_mediaLibrary_lock);
    EasyAuthorityStatus st = [self checkMicrophoneAuthority];
    dispatch_async(_concurrentQueue, ^{
        switch (st) {
            case AVAuthorizationStatusNotDetermined:
            {
                [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
                    pthread_mutex_unlock(&_mediaLibrary_lock);
                    asyncMainQueue_block(^{
                        statusBlock((EasyAuthorityStatus)status);
                    });
                }];
            }
                break;
            case AVAuthorizationStatusRestricted:
            {
                pthread_mutex_unlock(&_mediaLibrary_lock);
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusRestricted);
                });
            }
                break;
            case AVAuthorizationStatusDenied:
            {
                pthread_mutex_unlock(&_mediaLibrary_lock);
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusDenied);
                });
            }
                break;
            case AVAuthorizationStatusAuthorized:
            {
                pthread_mutex_unlock(&_mediaLibrary_lock);
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusAuthorized);
                });
            }
                break;
                
            default:
                break;
        }
    });
}
@end

@implementation EasyPermission(Location)
+ (EasyAuthorityStatus)checkLocationAuthority{
    if (![CLLocationManager locationServicesEnabled]) {
        return EasyAuthorizationStatusTurnOff;
    }
    CLAuthorizationStatus st = [CLLocationManager authorizationStatus];
    if (st == kCLAuthorizationStatusAuthorizedAlways || st == kCLAuthorizationStatusAuthorizedWhenInUse) {
        return EasyAuthorizationStatusAuthorized;
    }
    return (EasyAuthorityStatus)[CLLocationManager authorizationStatus];
}
+ (void)requestLocationPermissionType:(EasyLocationRequestType)type completion:(StatusBlock)statusBlock{
    _helper.statusBlock = statusBlock;
    EasyAuthorityStatus st = [self checkLocationAuthority];
    dispatch_async(_concurrentQueue, ^{
        switch (st) {
            case kCLAuthorizationStatusNotDetermined:
            {
                [_helper setIsRequestStatus:YES];
                if (type == EasyLocationRequestTypeWhenIn) {
                    [_helper.clmgr requestWhenInUseAuthorization];
                }else{
                    [_helper.clmgr requestAlwaysAuthorization];
                }
            }
                break;
            case kCLAuthorizationStatusRestricted:
            {
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusRestricted);
                });
            }
                break;
            case kCLAuthorizationStatusDenied:
            {
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusDenied);
                });
            }
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
            {
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusAuthorized);
                });
            }
                break;
            case kCLAuthorizationStatusAuthorizedWhenInUse:
            {
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusAuthorized);
                });
            }
                break;
                
            default:
                break;
        }
    });

}

@end


@implementation EasyPermission(Notification)
- (void)s{
    [[UIApplication sharedApplication] currentUserNotificationSettings];
}
@end

@implementation EasyPermission(Calendar)
+ (EasyAuthorityStatus)checkCalendarAuthority{
    return (EasyAuthorityStatus)[EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
}
+ (void)requestCalendarPermission:(StatusBlock)statusBlock{
    pthread_mutex_lock(&_calendar_lock);
    EasyAuthorityStatus st = [self checkCalendarAuthority];
    dispatch_async(_concurrentQueue, ^{
        switch (st) {
            case AVAuthorizationStatusNotDetermined:
            {
                [[EKEventStore new] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
                    pthread_mutex_unlock(&_calendar_lock);
                    EasyAuthorityStatus cst = EasyAuthorizationStatusDenied;
                    if (granted) {
                        cst = EasyAuthorizationStatusAuthorized;
                    }
                    asyncMainQueue_block(^{
                        statusBlock(cst);
                    });
                }];
            }
                break;
            case AVAuthorizationStatusRestricted:
            {
                pthread_mutex_unlock(&_calendar_lock);
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusRestricted);
                });
            }
                break;
            case AVAuthorizationStatusDenied:
            {
                pthread_mutex_unlock(&_calendar_lock);
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusDenied);
                });
            }
                break;
            case AVAuthorizationStatusAuthorized:
            {
                pthread_mutex_unlock(&_calendar_lock);
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusAuthorized);
                });
            }
                break;
                
            default:
                break;
        }
    });
}
@end

@implementation EasyPermission(Reminder)
+ (EasyAuthorityStatus)checkReminderAuthority{
    return (EasyAuthorityStatus)[EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
}
+ (void)requestReminderPermission:(StatusBlock)statusBlock{
    pthread_mutex_lock(&_reminder_lock);
    EasyAuthorityStatus st = [self checkCalendarAuthority];
    dispatch_async(_concurrentQueue, ^{
        switch (st) {
            case AVAuthorizationStatusNotDetermined:
            {
                [[EKEventStore new] requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
                    pthread_mutex_unlock(&_reminder_lock);
                    EasyAuthorityStatus cst = EasyAuthorizationStatusDenied;
                    if (granted) {
                        cst = EasyAuthorizationStatusAuthorized;
                    }
                    asyncMainQueue_block(^{
                        statusBlock(cst);
                    });
                }];
            }
                break;
            case AVAuthorizationStatusRestricted:
            {
                pthread_mutex_unlock(&_reminder_lock);
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusRestricted);
                });
            }
                break;
            case AVAuthorizationStatusDenied:
            {
                pthread_mutex_unlock(&_reminder_lock);
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusDenied);
                });
            }
                break;
            case AVAuthorizationStatusAuthorized:
            {
                pthread_mutex_unlock(&_reminder_lock);
                asyncMainQueue_block(^{
                    statusBlock(EasyAuthorizationStatusAuthorized);
                });
            }
                break;
                
            default:
                break;
        }
    });
}
@end
