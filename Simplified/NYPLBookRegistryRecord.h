// This class is intended for internal use by NYPLBookRegistry.

#import "NYPLBookState.h"

@class NYPLBook;
@class NYPLBookLocation;
@class NYPLReaderBookmark;

@interface NYPLBookRegistryRecord : NSObject

@property (nonatomic, readonly) NYPLBook *book;
@property (nonatomic, readonly) NYPLBookLocation *location; // nilable
@property (nonatomic, readonly) NYPLBookState state;
@property (nonatomic, readonly) NSString *fulfillmentId; // nilable
@property (nonatomic, readonly) NSArray<NYPLReaderBookmark *> *bookmarks;

+ (id)new NS_UNAVAILABLE;
- (id)init NS_UNAVAILABLE;

// designated initializer
- (instancetype)initWithBook:(NYPLBook *)book
                    location:(NYPLBookLocation *)location
                       state:(NYPLBookState)state
               fulfillmentId:(NSString *)fulfillmentId
                   bookmarks:(NSArray<NYPLReaderBookmark *> *)bookmarks;

// designated initializer
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)dictionaryRepresentation;

- (instancetype)recordWithBook:(NYPLBook *)book;

- (instancetype)recordWithLocation:(NYPLBookLocation *)location;

- (instancetype)recordWithState:(NYPLBookState)state;

- (instancetype)recordWithFulfillmentId:(NSString *)fulfillmentId;

- (instancetype)recordWithBookmarks:(NSArray<NYPLReaderBookmark *> *)bookmarks;
  
@end
