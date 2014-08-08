# BKRecursiveDescription

## Installation

1. Add BKRecursiveDescription to your Podfile.
2. In your terminal, run `pod install`.

## Usage


1. Add `#import <BKRecursiveDescription/BKRecursiveDescription.h>` to your source file (or to your prefix header, if you want to access it anywhere in your project).
2. Implement the method `- (void)bk_addRecursiveDescriptionToString:(NSMutableString *)string level:(NSUInteger)level` on your class.
3. Call `[yourObject bk_recursiveDescription]` on your object to get an `NSString` containing the recursive description of your object.

```objc
// Implemented in a class named "BKSomeClass" (adapted from the example project)
- (void)bk_addRecursiveDescriptionToString:(NSMutableString *)string level:(NSUInteger)level
{
    DESCRIBE_SELF(string, self);

    DESCRIBE_VARIABLE(string, level, _drawerPosition); // enum
    DESCRIBE_VARIABLE(string, level, _bounds); // CGRect
    DESCRIBE_VARIABLE(string, level, _drawerOffset); // CGFloat
    DESCRIBE_VARIABLE(string, level, _drawerInsets); // UIEdgeInsets
    DESCRIBE_VARIABLE(string, level, _acceptSpec); // NSObject with its own recursive description method
}
```

Outputs:

```
<BKSomeClass: 0x15695620>
 |_drawerPosition = (unsigned int)1
 |_bounds = (CGRect){{0, 0}, {320, 568}}
 |_drawerOffset = (float)198.500000
 |_drawerInsets = (UIEdgeInsets){44, 0, 172.5, 0}
 |_acceptSpec = <BKCameraRollButtonSpec: 0x15695790>
 | |_bounds = (CGRect){{0, 0}, {40, 40}}
 | |_center = (CGPoint){280, 168.5}
 | |_alpha = (float)0.473901
```

## FAQ

**Q:** What's with that `string` and `level` stuff in the macros?  
**A:** It might not always be practical to recursively *implement* a recursive description method on a tree of objects, and some wiggle room is needed for those implementations. As such, the raw string that's being built is provided directly. This also allows for custom strings to be inserted, such as headers or separators, when organizing the description of properties.

The level allows collections to indent their contents appropriately - or, again, for custom implementations to tweak the description levels as needed for complex descriptions if needed. **Most developers need not worry about this, and can simply pass the parameters in unchanged.**

**Q:** C11 generics?  
**A:** Yep. They're disabled if you don't support them, though, via `#if __has_feature(c_generic_selections)`. You can still access the underlying C functions that the generic macro resolves to, i.e. `_RD_DESCRIBE_CGRECT`, if you prefer. Those methods' declarations specify that they should always be inlined.

Incidentally, the C functions are necessary because C11 generics only seem to select __expressions__, not __statements__.

**Q:** Why the `do {} while(0)` wrapping? Does that even do anything?  
**A:** Yep - it's par for the course for C preprocessor programming. It groups a series of statements into one, so that the curly braces don't disrupt, for example, braceless if statements when the macros are expanded.

## Documentation

### The magic

* `DESCRIBE_VARIABLE(string, level, variable)`
    * Stringifies and uses the expression `variable` as the name in the description, then resolves the macro to `DESCRIBE_VALUE`.
* `DESCRIBE_VALUE(string, level, name, value)`
    * Appends a variable to `string`, formatted according to parameter type, using C11 generic expressions. Supports `float`,`double`, `short`, `unsigned short`, `int`, `unsigned int`, `long`, `unsigned long`, `long long`, `unsigned long long`, `BOOL`, `CGPoint`, `CGRect`, `UIEdgeInsets`, and `NSObject` (+ subclasses).

### The usual

* `DESCRIBE_SELF(string, object)`
    * Appends the class name of `object` followed by its pointer value to `string`. By convention, always the first statement in the recursive description implementation.
* `DESCRIBE_OBJECT(string, level, name, object)`
    * Appends the description for `object` with the given `name` to `string`. If `object` supports recursive description, its recursive description will be used. `object` may be nil.
* `DESCRIBE_VALUE_WITH_FORMAT(string, level, name, format, value)`
    * Appends a description with an explicit format string to `string`.