// Copyright (c) 2014-present 650 Industries, Inc. All rights reserved.

#include "BKGeometry.h"

#include <CoreGraphics/CGAffineTransform.h>

CGRect BKRectIntegralScaled(CGRect input, CGFloat scale) {
    if (scale == 0) {
        return CGRectZero;
    }

    CGRect scaled = CGRectApplyAffineTransform(input, CGAffineTransformMakeScale(scale, scale));
    CGRect integral = CGRectIntegral(scaled);
    CGRect result = CGRectApplyAffineTransform(integral, CGAffineTransformMakeScale(1.0/scale, 1.0/scale));
    return  result;
}
