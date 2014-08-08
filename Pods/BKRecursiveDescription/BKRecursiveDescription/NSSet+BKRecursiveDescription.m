// Copyright 2014-present 650 Industries. All rights reserved.

#import "NSSet+BKRecursiveDescription.h"

#import "BKDescribable.h"
#import "NSObject+BKRecursiveDescription.h"

@implementation NSSet (BKRecursiveDescription)

- (void)bk_addRecursiveDescriptionToString:(NSMutableString *)string level:(NSUInteger)level
{
  DESCRIBE_SELF(string, self);

  for (NSObject *object in self) {
    DESCRIBE_OBJECT(string, level, @"[*]", object);
  }
}

@end
