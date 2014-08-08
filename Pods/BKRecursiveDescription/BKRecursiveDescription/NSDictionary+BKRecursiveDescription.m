// Copyright 2014-present 650 Industries. All rights reserved.

#import "NSDictionary+BKRecursiveDescription.h"

#import "BKDescribable.h"
#import "NSObject+BKRecursiveDescription.h"

@implementation NSDictionary (BKRecursiveDescription)

- (void)bk_addRecursiveDescriptionToString:(NSMutableString *)string level:(NSUInteger)level
{
  DESCRIBE_SELF(string, self);

  for (NSObject *key in self) {
    NSString *name = [NSString stringWithFormat:@"[%@]", [key description]];
    DESCRIBE_OBJECT(string, level, name, self[key]);
  }
}

@end
