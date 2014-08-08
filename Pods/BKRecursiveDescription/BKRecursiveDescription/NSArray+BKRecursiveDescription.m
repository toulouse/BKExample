// Copyright 2014-present 650 Industries. All rights reserved.

#import "NSArray+BKRecursiveDescription.h"

#import "BKDescribable.h"
#import "NSObject+BKRecursiveDescription.h"

@implementation NSArray (BKRecursiveDescription)

- (void)bk_addRecursiveDescriptionToString:(NSMutableString *)string level:(NSUInteger)level
{
  DESCRIBE_SELF(string, self);

  unsigned int index = 0;
  for (NSObject *object in self) {
    NSString *name = [NSString stringWithFormat:@"[%u]", index];
    DESCRIBE_OBJECT(string, level, name, object);
    index++;
  }
}

@end
