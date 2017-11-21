//
//  EasyPermission+Location.m
//  EasyPermissionDemo
//
//  Created by JungHsu on 2017/11/21.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import "EasyPermission+Location.h"
#import <CoreLocation/CoreLocation.h>


extern inline void asyncMainQueue_block(void(^block)(void));
extern pthread_mutex_t          _location_lock;
extern EasyPermissionHelper     *_helper;

@implementation EasyPermission (Location)

+ (EasyAuthorityStatus)checkLocationAuthority{
    if (![CLLocationManager locationServicesEnabled]) {
        return EasyAuthorizationStatusTurnOff;
    }
    CLAuthorizationStatus st = [CLLocationManager authorizationStatus];
    if (st == kCLAuthorizationStatusAuthorizedAlways ||
        st == kCLAuthorizationStatusAuthorizedWhenInUse) {
        return EasyAuthorizationStatusAuthorized;
    }
    return (EasyAuthorityStatus)[CLLocationManager authorizationStatus];
}
+ (void)requestLocationPermissionType:(EasyLocationRequestType)type completion:(StatusBlock)statusBlock{
    pthread_mutex_lock(&_location_lock);
    EasyAuthorityStatus st = [self checkLocationAuthority];
    switch (st) {
        case EasyAuthorizationStatusNotDetermined:
        {
            CLLocationManager *lmg = [CLLocationManager new];
            _helper->_lmg = lmg;
            _helper->_locationBlock = statusBlock;
            lmg.delegate = _helper;
            if (type == EasyLocationRequestTypeWhenInUse) {
                [lmg requestWhenInUseAuthorization];
            }else{
                [lmg requestAlwaysAuthorization];
            }
        }
            break;
        case EasyAuthorizationStatusRestricted:
        {
            pthread_mutex_unlock(&_location_lock);
            asyncMainQueue_block(^{
                statusBlock == nil?:statusBlock(EasyAuthorizationStatusRestricted);
            });
        }
            break;
        case EasyAuthorizationStatusDenied:
        {
            pthread_mutex_unlock(&_location_lock);
            asyncMainQueue_block(^{
                statusBlock == nil?:statusBlock(EasyAuthorizationStatusDenied);
            });
        }
            break;
        case EasyAuthorizationStatusAuthorized:
        {
            pthread_mutex_unlock(&_location_lock);
            asyncMainQueue_block(^{
                statusBlock == nil?:statusBlock(EasyAuthorizationStatusAuthorized);
            });
        }
            break;
        case EasyAuthorizationStatusTurnOff:
        {
            pthread_mutex_unlock(&_location_lock);
            asyncMainQueue_block(^{
                statusBlock == nil?:statusBlock(EasyAuthorizationStatusTurnOff);
            });
        }
            break;
            
        default:
            break;
    }
}
@end
