// Copyright 2014-present 650 Industries. All rights reserved.

@import Foundation;

@protocol BKService;

typedef void (^service_load_callback_t)(id<BKService> service, BOOL loaded, NSError *error);

@protocol BKService <NSObject>

- (void)loadServiceWithCallback:(service_load_callback_t)callback;

@end
