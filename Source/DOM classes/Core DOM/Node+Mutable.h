/**
 Makes the writable properties all package-private, effectively
 */
#import "SVGCNode.h"

@interface SVGCNode()
@property(nonatomic,strong,readwrite) NSString* nodeName;
@property(nonatomic,strong,readwrite) NSString* nodeValue;

@property(nonatomic,readwrite) SVGCNodeType nodeType;
@property(nonatomic,weak,readwrite) SVGCNode* parentNode;
@property(nonatomic,strong,readwrite) SVGCNodeList* childNodes;
@property(nonatomic,strong,readwrite) NamedNodeMap* attributes;

@property(nonatomic,weak,readwrite) Document* ownerDocument;

// Introduced in DOM Level 2:
@property(nonatomic,strong,readwrite) NSString* namespaceURI;

// Introduced in DOM Level 2:
@property(nonatomic,strong,readwrite) NSString* prefix;

// Introduced in DOM Level 2:
@property(nonatomic,strong,readwrite) NSString* localName;

@end
