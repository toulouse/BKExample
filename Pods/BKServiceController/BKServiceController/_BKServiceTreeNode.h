// Copyright 2014-present 650 Industries. All rights reserved.

@import Foundation;

#import "BKService.h"

@interface _BKServiceTreeNode : NSObject
@property (nonatomic, assign) BOOL running;

@property (nonatomic, copy, readonly) NSString *key;
@property (nonatomic, strong, readonly) id<BKService> service;
@property (nonatomic, copy, readonly) NSArray *dependencies;

- (instancetype)initWithService:(id<BKService>)service key:(NSString *)key dependencies:(NSArray *)dependencies;
@end
