//
//  EasyPermission+AddressBook.m
//  EasyPermissionDemo
//
//  Created by JungHsu on 2017/11/21.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import "EasyPermission+AddressBook.h"
#import <Contacts/Contacts.h>

extern pthread_mutex_t          _addressBook_lock;
extern dispatch_queue_t         _concurrentQueue;
extern inline void asyncMainQueue_block(void(^block)(void));

@implementation EasyPermission (AddressBook)


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
                        statusBlock == nil?:statusBlock(cst);
                    });
                }];
                
            }
                break;
            case EasyAuthorizationStatusRestricted:
            {
                pthread_mutex_unlock(&_addressBook_lock);
                asyncMainQueue_block(^{
                    statusBlock == nil?:statusBlock(EasyAuthorizationStatusRestricted);
                });
            }
                break;
            case EasyAuthorizationStatusDenied:
            {
                pthread_mutex_unlock(&_addressBook_lock);
                asyncMainQueue_block(^{
                    statusBlock == nil?:statusBlock(EasyAuthorizationStatusDenied);
                });
            }
                break;
            case EasyAuthorizationStatusAuthorized:
            {
                pthread_mutex_unlock(&_addressBook_lock);
                asyncMainQueue_block(^{
                    statusBlock == nil?:statusBlock(EasyAuthorizationStatusAuthorized);
                });
            }
                break;
                
            default:
                break;
        }
    });
}
@end
