// Copyright 2014-present 650 Industries. All rights reserved.

#import "BKServiceRegistrar.h"

#import "BKService.h"

@class BKServiceController;

@interface BKServiceRegistrar ()

@property (nonatomic, strong, readonly) NSMapTable *addedServices;

- (instancetype)initWithController:(BKServiceController *)controller;

@end

@interface BKBlockService : NSObject <BKService>
@property (nonatomic, copy, readonly) void (^block)();

- (instancetype)initWithBlock:(void (^)())block;
@end

