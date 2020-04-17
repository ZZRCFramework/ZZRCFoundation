#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "UIDeviceHardware.h"

FOUNDATION_EXPORT double UIDeviceIdentifierVersionNumber;
FOUNDATION_EXPORT const unsigned char UIDeviceIdentifierVersionString[];

