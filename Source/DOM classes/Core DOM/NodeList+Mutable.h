/**
 Makes the writable properties all package-private, effectively
 */

#import "DOMNodeList.h"

@interface DOMNodeList()

@property(nonatomic,strong) NSMutableArray* internalArray;

@end
