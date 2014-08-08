// Copyright 2014-present 650 Industries. All rights reserved.

#import "BKServiceController.h"
#import "BKServiceController_Internal.h"

#import "BKService.h"
#import "BKServiceRegistrar.h"
#import "BKServiceRegistrar_Internal.h"
#import "_BKServiceTreeNode.h"

@implementation BKServiceController {
    dispatch_queue_t _serviceQueue;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred;
    static BKServiceController *shared = nil;

    dispatch_once(&pred, ^{
        shared = [[BKServiceController alloc] init];
    });
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self = [super init]) {
        _services = [NSMapTable strongToStrongObjectsMapTable];
        _serviceQueue = dispatch_queue_create("net.sixfivezero.services", DISPATCH_QUEUE_CONCURRENT);
        dispatch_set_target_queue(_serviceQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    }
    return self;
}

- (id<BKService>)serviceForKey:(NSString *)key
{
    _BKServiceTreeNode *node = [_services objectForKey:key];
    if (!node) {
        return nil;
    }

    return node.service;
}

- (NSArray *)serviceKeys
{
    return [[_services dictionaryRepresentation] allKeys];
}

- (void)registerServicesImmediately:(service_registration_block_t)registrationBlock
{
    BKServiceRegistrar *registrar = [[BKServiceRegistrar alloc] initWithController:self];
    registrationBlock(self, registrar);
    for (NSString *key in registrar.addedServices) {
        NSAssert([_services objectForKey:key] == nil, @"Expected nil");
        id node = [registrar.addedServices objectForKey:key];
        [_services setObject:node forKey:key];
    }

    for (NSString *key in registrar.addedServices) {
        _BKServiceTreeNode *node = [registrar.addedServices objectForKey:key];
        NSLog(@"Serially starting service: %@", [node description]);

        // FIXME TODO: linearize the DAG.
        for (_BKServiceTreeNode *dependencyNode in node.dependencies) {
            if (!dependencyNode.running) {
                // TODO: error reporting here?
                NSAssert(NO, @"A needed dependency is not running!");
            }
        }

        [node.service loadServiceWithCallback:^(id<BKService> service, BOOL loaded, NSError *error) {
            node.running = loaded;
            NSAssert(loaded, @"Failed to load service: %@ with error: %@", service, error);
        }];
        node.running = YES;
    }

    NSLog(@"Finished registering immediate services");
}

- (void)registerServices:(service_registration_block_t)registrationBlock
{
    BKServiceRegistrar *registrar = [[BKServiceRegistrar alloc] initWithController:self];
    registrationBlock(self, registrar);
    for (NSString *key in registrar.addedServices) {
        NSAssert([_services objectForKey:key] == nil, @"Expected nil");
        id<BKService> service = [registrar.addedServices objectForKey:key];
        [_services setObject:service forKey:key];
    }

    [self _recursiveLoad];
}

- (void)_recursiveLoad
{
    NSArray *servicesToLoad = [self _calculateNextServicesToLoad];
    if (!servicesToLoad.count) {
        return;
    }

    NSLog(@"Concurrently starting services: %@", servicesToLoad);
    dispatch_group_t group = dispatch_group_create();
    for (_BKServiceTreeNode *node in servicesToLoad) {
        dispatch_group_enter(group);
        dispatch_async(_serviceQueue, ^{
            [node.service loadServiceWithCallback:^(id<BKService> service, BOOL loaded, NSError *error) {
                node.running = loaded;
                dispatch_group_leave(group);
                NSAssert(loaded, @"Failed to load service: %@ with error: %@", service, error);
            }];
        });
    }

    [self _blockThenContinueWithGroup:group];
}

- (void)_blockThenContinueWithGroup:(dispatch_group_t)group
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
        if (result != 0) { // Dispatch group didn't finish
            NSLog(@"ERROR: Timeout reached while launching services!");
            [self _blockThenContinueWithGroup:group];
        } else { // Dispatch group did finish
            NSLog(@"Current wave of services loaded!");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _recursiveLoad];
            });
        }
    });
}

- (NSArray *)_calculateNextServicesToLoad
{
    NSMutableArray *servicesToLoad = [NSMutableArray array];

    // Select non-running nodes whose dependencies are all running (no dependencies == all running).
    NSEnumerator *serviceEnumerator = [_services objectEnumerator];
    _BKServiceTreeNode *currentNode;
    while (currentNode = [serviceEnumerator nextObject]) {
        if (currentNode.running) {
            continue;
        }

        NSIndexSet *runningDependencies = [currentNode.dependencies indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return ((_BKServiceTreeNode *)obj).running;
        }];
        if (runningDependencies.count == currentNode.dependencies.count) {
            [servicesToLoad addObject:currentNode];
        }
    }

    return [servicesToLoad copy];
}

@end


