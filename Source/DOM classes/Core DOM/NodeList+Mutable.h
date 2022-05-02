/**
 Makes the writable properties all package-private, effectively
 */

#import "SVGCNodeList.h"

@interface SVGCNodeList()

@property(nonatomic,strong) NSMutableArray* internalArray;

@end
