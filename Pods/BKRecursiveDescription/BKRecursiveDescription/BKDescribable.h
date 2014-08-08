// Copyright 2014-present 650 Industries. All rights reserved.

@import Foundation;

@protocol BKDescribable <NSObject>

@optional
- (void)bk_addRecursiveDescriptionToString:(NSMutableString *)string level:(NSUInteger)level;

@end

@interface NSObject () <BKDescribable>
@end
