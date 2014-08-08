// Copyright 2014-present 650 Industries. All rights reserved.

#import "BKServiceRegistrar.h"
#import "BKServiceRegistrar_Internal.h"

#import "BKServiceController.h"
#import "BKServiceController_Internal.h"
#import "_BKServiceTreeNode.h"

@implementation BKServiceRegistrar {
    __weak BKServiceController *_serviceController;
}

- (instancetype)initWithController:(BKServiceController *)controller
{
    if (self = [super init]) {
        _serviceController = controller;
        _addedServices = [NSMapTable strongToStrongObjectsMapTable];
    }
    return self;
}

- (BOOL)_shouldRegisterService:(id<BKService>)service forKey:(NSString *)key
{
    if ([_serviceController.services objectForKey:key]) {
        NSLog(@"ERROR: Service already registered in the Service Controller");
        return NO;
    }
    NSEnumerator *serviceEnumerator = [_addedServices objectEnumerator];
    _BKServiceTreeNode *node;
    while (node = [serviceEnumerator nextObject]) {
        if (node.service == service) {
            NSLog(@"ERROR: This service is already added to the current service registrar");
            return NO;
        } else if ([node.key isEqualToString:key]) {
            NSLog(@"ERROR: A service with an identical key is already added to the current service registrar: %@", [node.service description]);
            return NO;
        }
    }
    return YES;
}

- (BOOL)registerBlock:(void (^)())block forKey:(NSString *)key
{
    return [self registerBlock:block forKey:key dependencies:nil];
}

- (BOOL)registerBlock:(void (^)())block forKey:(NSString *)key dependencies:(NSArray *)dependencies
{
    BKBlockService *blockService = [[BKBlockService alloc] initWithBlock:block];
    return [self registerService:blockService forKey:key dependencies:dependencies];
}

- (BOOL)registerService:(id<BKService>)service forKey:(NSString *)key
{
    return [self registerService:service forKey:key dependencies:nil];
}

- (BOOL)registerService:(id<BKService>)service forKey:(NSString *)key dependencies:(NSArray *)dependencies
{
    if (![self _shouldRegisterService:service forKey:key]) {
        return NO;
    }

    NSMutableArray *dependencyNodes;
    if (dependencies.count) {
        dependencyNodes = [NSMutableArray array];
        for (NSString *dependencyKey in dependencies) {
            _BKServiceTreeNode *dependencyNode = [_addedServices objectForKey:dependencyKey];
            if (!dependencyNode) {
                dependencyNode = [_serviceController.services objectForKey:dependencyKey];
            }
            NSAssert(dependencyNode != nil, @"Expected non-nil value");
            [dependencyNodes addObject:dependencyNode];
        }
    } else {
        dependencyNodes = nil;
    }

    _BKServiceTreeNode *node = [[_BKServiceTreeNode alloc] initWithService:service key:key dependencies:dependencyNodes];
    [_addedServices setObject:node forKey:key];
    return YES;
}

@end


@implementation BKBlockService

- (instancetype)initWithBlock:(void (^)())block
{
    if (self = [super init]) {
        _block = [block copy];
    }
    return self;
}

- (void)loadServiceWithCallback:(service_load_callback_t)callback
{
    _block();
    callback(self, YES, nil);
}

@end
