// Copyright 2014-present 650 Industries. All rights reserved.

#import "_BKServiceTreeNode.h"

@implementation _BKServiceTreeNode
- (instancetype)initWithService:(id<BKService>)service key:(NSString *)key dependencies:(NSArray *)dependencies
{
    if (self = [super init]) {
        _service = service;
        _key = [key copy];
        _dependencies = [dependencies copy];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[%@] => running=%d <%@: %p> dependencies: %@", _key, _running, NSStringFromClass([_service class]), _service, _dependencies];
}
@end
