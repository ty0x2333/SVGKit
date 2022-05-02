/*
 From SVG-DOM, via Core-DOM:
 
 http://www.w3.org/TR/DOM-Level-2-Core/core.html#ID-1780488922
 
 interface NamedNodeMap {
 Node               getNamedItem(in DOMString name);
 Node               setNamedItem(in Node arg)
 raises(DOMException);
 Node               removeNamedItem(in DOMString name)
 raises(DOMException);
 Node               item(in unsigned long index);
 readonly attribute unsigned long    length;
 // Introduced in DOM Level 2:
 Node               getNamedItemNS(in DOMString namespaceURI, 
 in DOMString localName);
 // Introduced in DOM Level 2:
 Node               setNamedItemNS(in Node arg)
 raises(DOMException);
 // Introduced in DOM Level 2:
 Node               removeNamedItemNS(in DOMString namespaceURI, 
 in DOMString localName)
 raises(DOMException);
 };

 */

#import <Foundation/Foundation.h>

@class SVGCNode;
#import "SVGCNode.h"

@interface NamedNodeMap : NSObject </** needed so we can output SVG text in the [Node appendToXML:..] methods */ NSCopying>

-(SVGCNode*) getNamedItem:(NSString*) name;
-(SVGCNode*) setNamedItem:(SVGCNode*) arg;
-(SVGCNode*) removeNamedItem:(NSString*) name;
-(SVGCNode*) item:(unsigned long) index;

@property(readonly) unsigned long length;

// Introduced in DOM Level 2:
-(SVGCNode*) getNamedItemNS:(NSString*) namespaceURI localName:(NSString*) localName;

// Introduced in DOM Level 2:
-(SVGCNode*) setNamedItemNS:(SVGCNode*) arg;

// Introduced in DOM Level 2:
-(SVGCNode*) removeNamedItemNS:(NSString*) namespaceURI localName:(NSString*) localName;

#pragma mark - MISSING METHOD FROM SVG Spec, without which you cannot parse documents (don't understand how they intended you to fulfil the spec without this method)

-(SVGCNode*) setNamedItemNS:(SVGCNode*) arg inNodeNamespace:(NSString*) nodesNamespace;

@end
