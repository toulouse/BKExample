// Copyright 2014-present 650 Industries. All rights reserved.

@import Foundation;

@protocol BKService;

@interface BKServiceRegistrar : NSObject

- (BOOL)registerBlock:(void (^)())block forKey:(NSString *)key;
- (BOOL)registerBlock:(void (^)())block forKey:(NSString *)key dependencies:(NSArray *)dependencies;
- (BOOL)registerService:(id<BKService>)service forKey:(NSString *)key;
- (BOOL)registerService:(id<BKService>)service forKey:(NSString *)key dependencies:(NSArray *)dependencies;

@end
