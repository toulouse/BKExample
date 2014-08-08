// Copyright 2014-present 650 Industries. All rights reserved.

#import "NSObject+BKRecursiveDescription.h"

#import "BKDescribable.h"

static const NSUInteger indentWidth = 2;

@implementation NSObject (BKRecursiveDescription)

- (NSString *)bk_recursiveDescription
{
    return [self bk_describeLevel:0];
}

- (NSString *)bk_describeLevel:(NSUInteger)level withKey:(NSString *)key
{
    NSString *tab =
    [[@"" stringByPaddingToLength:indentWidth - 1 withString:@" " startingAtIndex:0] stringByAppendingString:@"|"];
    NSString *indent = [@"" stringByPaddingToLength:indentWidth * level withString:tab startingAtIndex:0];

    NSMutableString *string = [[NSMutableString alloc] initWithString:indent];
    if (key) {
        // Currently, showing collection count only supports collections that implement fast enumeration, and assumes that
        // -count is sane and returns NSUInteger.
        if ([self conformsToProtocol:@protocol(NSFastEnumeration)]) {
            [string appendFormat:@"%@{count=%lu} = ", key, (unsigned long)[(id)self count]];
        } else {
            [string appendFormat:@"%@ = ", key];
        }
    }

    if ([self respondsToSelector:@selector(bk_addRecursiveDescriptionToString:level:)]) {
        [self bk_addRecursiveDescriptionToString:string level:level];
    } else {
        [string appendString:[self description]];
    }

    [string appendString:@"\n"];
    return [string copy];
}

- (NSString *)bk_describeLevel:(NSUInteger)level
{
    return [self bk_describeLevel:level withKey:nil];
}

@end
