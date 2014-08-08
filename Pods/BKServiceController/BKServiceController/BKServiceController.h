// Copyright 2014-present 650 Industries. All rights reserved.

@import Foundation;

@class BKServiceController;
@class BKServiceRegistrar;
@protocol BKService;

typedef void (^service_registration_block_t)(BKServiceController *controller, BKServiceRegistrar *registrar);

@interface BKServiceController : NSObject

+ (instancetype)sharedInstance;
- (id<BKService>)serviceForKey:(NSString *)key;
- (NSArray *)serviceKeys;

- (void)registerServices:(service_registration_block_t)registrationBlock;
- (void)registerServicesImmediately:(service_registration_block_t)registrationBlock;

@end
