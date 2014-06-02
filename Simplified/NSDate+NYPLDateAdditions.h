#import <Foundation/Foundation.h>

@interface NSDate (NYPLDateAdditions)

// This correctly parses fractional seconds, but ignores them due to |NSDate| limitations.
+ (NSDate *)dateWithRFC3339:(NSString *)string;

@end
