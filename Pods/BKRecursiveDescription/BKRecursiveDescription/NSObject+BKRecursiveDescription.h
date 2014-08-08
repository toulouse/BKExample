// Copyright 2014-present 650 Industries. All rights reserved.

@import Foundation;
@import UIKit.UIGeometry;

@interface NSObject (BKRecursiveDescription)

- (NSString *)bk_recursiveDescription;
- (NSString *)bk_describeLevel:(NSUInteger)level;
- (NSString *)bk_describeLevel:(NSUInteger)level withKey:(NSString *)key;

@end

#define DESCRIBE_SELF(string, object) [string appendFormat:@"<%@: %p>\n", NSStringFromClass([object class]), object]

#define DESCRIBE_OBJECT(string, level, name, object) \
do { \
    if (object) { \
        [string appendString:[object bk_describeLevel:level + 1 withKey:name]]; \
    } else { \
        [string appendString:[@"(nil)" bk_describeLevel:level + 1 withKey:name]]; \
    } \
} while(0)

#define DESCRIBE_VALUE_WITH_FORMAT(string, level, name, format, value) \
do { \
    [string appendString:[[NSString stringWithFormat:format, value] bk_describeLevel:level + 1 withKey:name]]; \
} while(0)

__attribute__((__always_inline__)) static inline void _RD_DESCRIBE_FLOAT(NSMutableString *string, NSUInteger level, NSString *name, float value) {
    DESCRIBE_VALUE_WITH_FORMAT(string, level, name, @"(float)%f", value);
}

__attribute__((__always_inline__)) static inline void _RD_DESCRIBE_DOUBLE(NSMutableString *string, NSUInteger level, NSString *name, double value) {
    DESCRIBE_VALUE_WITH_FORMAT(string, level, name, @"(double)%f", value);
}

__attribute__((__always_inline__)) static inline void _RD_DESCRIBE_SHORT(NSMutableString *string, NSUInteger level, NSString *name, short value) {
    DESCRIBE_VALUE_WITH_FORMAT(string, level, name, @"(short)%d", value);
}

__attribute__((__always_inline__)) static inline void _RD_DESCRIBE_UNSIGNED_SHORT(NSMutableString *string, NSUInteger level, NSString *name, unsigned short value) {
    DESCRIBE_VALUE_WITH_FORMAT(string, level, name, @"(unsigned short)%u", value);
}

__attribute__((__always_inline__)) static inline void _RD_DESCRIBE_INT(NSMutableString *string, NSUInteger level, NSString *name, int value) {
    DESCRIBE_VALUE_WITH_FORMAT(string, level, name, @"(int)%d", value);
}

__attribute__((__always_inline__)) static inline void _RD_DESCRIBE_UNSIGNED_INT(NSMutableString *string, NSUInteger level, NSString *name, unsigned int value) {
    DESCRIBE_VALUE_WITH_FORMAT(string, level, name, @"(unsigned int)%u", value);
}

__attribute__((__always_inline__)) static inline void _RD_DESCRIBE_LONG(NSMutableString *string, NSUInteger level, NSString *name, long value) {
    DESCRIBE_VALUE_WITH_FORMAT(string, level, name, @"(long)%ld", value);
}

__attribute__((__always_inline__)) static inline void _RD_DESCRIBE_UNSIGNED_LONG(NSMutableString *string, NSUInteger level, NSString *name, unsigned long value) {
    DESCRIBE_VALUE_WITH_FORMAT(string, level, name, @"(unsigned long)%lu", value);
}

__attribute__((__always_inline__)) static inline void _RD_DESCRIBE_LONG_LONG(NSMutableString *string, NSUInteger level, NSString *name, long long value) {
    DESCRIBE_VALUE_WITH_FORMAT(string, level, name, @"(long long)%lld", value);
}

__attribute__((__always_inline__)) static inline void _RD_DESCRIBE_UNSIGNED_LONG_LONG(NSMutableString *string, NSUInteger level, NSString *name, unsigned long long value) {
    DESCRIBE_VALUE_WITH_FORMAT(string, level, name, @"(unsigned long long)%llu", value);
}

__attribute__((__always_inline__)) static inline void _RD_DESCRIBE_BOOL(NSMutableString *string, NSUInteger level, NSString *name, BOOL value) {
    DESCRIBE_VALUE_WITH_FORMAT(string, level, name, @"(BOOL)%@", value ? @"YES" : @"NO");
}

__attribute__((__always_inline__)) static inline void _RD_DESCRIBE_CGPOINT(NSMutableString *string, NSUInteger level, NSString *name, CGPoint value) {
    DESCRIBE_VALUE_WITH_FORMAT(string, level, name, @"(CGPoint)%@", NSStringFromCGPoint(value));
}

__attribute__((__always_inline__)) static inline void _RD_DESCRIBE_CGRECT(NSMutableString *string, NSUInteger level, NSString *name, CGRect value) {
    DESCRIBE_VALUE_WITH_FORMAT(string, level, name, @"(CGRect)%@", NSStringFromCGRect(value));
}

__attribute__((__always_inline__)) static inline void _RD_DESCRIBE_UIEDGEINSETS(NSMutableString *string, NSUInteger level, NSString *name, UIEdgeInsets value) {
    DESCRIBE_VALUE_WITH_FORMAT(string, level, name, @"(UIEdgeInsets)%@", NSStringFromUIEdgeInsets(value));
}

__attribute__((__always_inline__)) static inline void _RD_DESCRIBE_PROBABLY_OBJECT(NSMutableString *string, NSUInteger level, NSString *name, id value) {
    DESCRIBE_OBJECT(string, level, name, value);
}


#if __has_feature(c_generic_selections)
#define DESCRIBE_VALUE(string, level, name, value) _Generic((value), \
float: _RD_DESCRIBE_FLOAT, \
double: _RD_DESCRIBE_DOUBLE, \
short: _RD_DESCRIBE_SHORT, \
unsigned short: _RD_DESCRIBE_UNSIGNED_SHORT, \
int: _RD_DESCRIBE_INT, \
unsigned int: _RD_DESCRIBE_UNSIGNED_INT, \
long: _RD_DESCRIBE_LONG, \
unsigned long: _RD_DESCRIBE_UNSIGNED_LONG, \
long long: _RD_DESCRIBE_LONG_LONG, \
unsigned long long: _RD_DESCRIBE_UNSIGNED_LONG_LONG, \
BOOL: _RD_DESCRIBE_BOOL, \
CGPoint: _RD_DESCRIBE_CGPOINT, \
CGRect: _RD_DESCRIBE_CGRECT, \
UIEdgeInsets: _RD_DESCRIBE_UIEDGEINSETS, \
default: _RD_DESCRIBE_PROBABLY_OBJECT \
)(string, level, name, value)

#define DESCRIBE_VARIABLE(string, level, variable) DESCRIBE_VALUE(string, level, @#variable, variable)
#endif
