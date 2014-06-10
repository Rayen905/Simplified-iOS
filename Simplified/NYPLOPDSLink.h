@import Foundation;

#import <SMXMLDocument/SMXMLDocument.h>

@interface NYPLOPDSLink : NSObject

@property (nonatomic, readonly) NSURL *href;
@property (nonatomic, readonly) NSString *rel;
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSString *hreflang;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *length;

// designated initializer
- (id)initWithElement:(SMXMLElement *)element;

@end