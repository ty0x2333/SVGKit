//
//  Node.m
//  SVGKit
//
//  Created by adam on 22/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SVGCNode.h"
#import "Node+Mutable.h"

#import "NodeList+Mutable.h"
#import "NamedNodeMap.h"

#import "NamedNodeMap_Iterable.h" // Needed for the optional (non-SVG spec) "recursive toXML" method

@implementation SVGCNode

@synthesize nodeName;
@synthesize nodeValue;

@synthesize nodeType;
@synthesize parentNode;
@synthesize childNodes;
@synthesize attributes;

// Modified in DOM Level 2:
@synthesize ownerDocument;

@synthesize hasAttributes, hasChildNodes;

@synthesize localName;


- (id)init
{
    NSAssert( FALSE, @"This class has no init method - it MUST NOT be init'd via init - you MUST use one of the multi-argument constructors instead" );
	
    return nil;
}

- (id)initType:(SVGCNodeType) nt name:(NSString*) n value:(NSString*) v
{
	if( [v isKindOfClass:[NSMutableString class]])
	{
		/** Apple allows this, but it breaks the whole of Obj-C / cocoa, which is damn stupid
		 So we have to fix it.*/
		v = [NSString stringWithString:v];
	}
	
    self = [super init];
    if (self) {
		self.nodeType = nt;
        switch( nt )
		{
				
			case SVGCNodeType_ATTRIBUTE_NODE:
			case SVGCNodeType_CDATA_SECTION_NODE:
			case SVGCNodeType_COMMENT_NODE:
			case SVGCNodeType_PROCESSING_INSTRUCTION_NODE:
			case SVGCNodeType_TEXT_NODE:
			{
				self.nodeName = n;
				self.nodeValue = v;
			}break;
			
				
			case SVGCNodeType_DOCUMENT_NODE:
			case SVGCNodeType_DOCUMENT_TYPE_NODE:
			case SVGCNodeType_DOCUMENT_FRAGMENT_NODE:
			case SVGCNodeType_ENTITY_REFERENCE_NODE:
			case SVGCNodeType_ENTITY_NODE:
			case SVGCNodeType_NOTATION_NODE:
			case SVGCNodeType_ELEMENT_NODE:
			{
				NSAssert( FALSE, @"NodeType = %i cannot be init'd with a value; nodes of that type have no value in the DOM spec", nt);
				
				self = nil;
			}break;
		}
		
		self.childNodes = [[SVGCNodeList alloc] init];
    }
    return self;
}

- (id)initType:(SVGCNodeType) nt name:(NSString*) n
{
    self = [super init];
    if (self) {
		self.nodeType = nt;
        switch( nt )
		{
				
			case SVGCNodeType_ATTRIBUTE_NODE:
			case SVGCNodeType_CDATA_SECTION_NODE:
			case SVGCNodeType_COMMENT_NODE:
			case SVGCNodeType_PROCESSING_INSTRUCTION_NODE:
			case SVGCNodeType_TEXT_NODE:
			{
				NSAssert( FALSE, @"NodeType = %i cannot be init'd without a value; nodes of that type MUST have a value in the DOM spec", nt);
				
				self = nil;
			}break;
				
				
			case SVGCNodeType_DOCUMENT_NODE:
			case SVGCNodeType_DOCUMENT_TYPE_NODE:
			case SVGCNodeType_DOCUMENT_FRAGMENT_NODE:
			case SVGCNodeType_ENTITY_REFERENCE_NODE:
			case SVGCNodeType_ENTITY_NODE:
			case SVGCNodeType_NOTATION_NODE:
			{
				self.nodeName = n;
			}break;
				
			case SVGCNodeType_ELEMENT_NODE:
			{
				
				self.nodeName = n;
				
				self.attributes = [[NamedNodeMap alloc] init];
			}break;
		}
		
		self.childNodes = [[SVGCNodeList alloc] init];
    }
    return self;
}


#pragma mark - Objective-C init methods DOM LEVEL 2 (preferred init - safer/better!)
-(void) postInitNamespaceHandling:(NSString*) nsURI
{
	NSArray* nameSpaceParts = [self.nodeName componentsSeparatedByString:@":"];
	self.localName = [nameSpaceParts lastObject];
	if( [nameSpaceParts count] > 1 )
		self.prefix = [nameSpaceParts objectAtIndex:0];
		
	self.namespaceURI = nsURI;
}

- (id)initType:(SVGCNodeType) nt name:(NSString*) n inNamespace:(NSString*) nsURI
{
	self = [self initType:nt name:n];
	
	if( self )
	{
		[self postInitNamespaceHandling:nsURI];
	}
	
	return self;
}

- (id)initType:(SVGCNodeType) nt name:(NSString*) n value:(NSString*) v inNamespace:(NSString*) nsURI
{
	if( [v isKindOfClass:[NSMutableString class]])
	{
		/** Apple allows this, but it breaks the whole of Obj-C / cocoa, which is damn stupid
		 So we have to fix it.*/
		v = [NSString stringWithString:v];
	}
	
	self = [self initType:nt name:n value:v];
	
	if( self )
	{
		[self postInitNamespaceHandling:nsURI];
	}
	
	return self;
}

#pragma mark - Official DOM method implementations

-(SVGCNode *)firstChild
{
    if( [self.childNodes length] < 1 )
        return nil;
    else
        return [self.childNodes item:0];
}

-(SVGCNode *)lastChild
{
    if( [self.childNodes length] < 1 )
        return nil;
    else
        return [self.childNodes item: [self.childNodes length] - 1];
}

-(SVGCNode *)previousSibling
{
    if( self.parentNode == nil )
        return nil;
    else
    {
        NSUInteger indexInParent = [self.parentNode.childNodes.internalArray indexOfObject:self];
        
        if( indexInParent < 1 )
            return nil;
        else
            return [self.parentNode.childNodes item:indexInParent-1];
    }
}

-(SVGCNode *)nextSibling
{
    if( self.parentNode == nil )
        return nil;
    else
    {
        NSUInteger indexInParent = [self.parentNode.childNodes.internalArray indexOfObject:self];
        
        if( indexInParent >= [self.parentNode.childNodes length] )
            return nil;
        else
            return [self.parentNode.childNodes item:indexInParent + 1];
    }
}

-(SVGCNode*) insertBefore:(SVGCNode*) newChild refChild:(SVGCNode*) refChild
{
	if( refChild == nil )
	{
		[self.childNodes.internalArray addObject:newChild];
		newChild.parentNode = self;
	}
	else
	{
		[self.childNodes.internalArray insertObject:newChild atIndex:[self.childNodes.internalArray indexOfObject:refChild]];
	}
	
	return newChild;
}

-(SVGCNode*) replaceChild:(SVGCNode*) newChild oldChild:(SVGCNode*) oldChild
{
	if( newChild.nodeType == SVGCNodeType_DOCUMENT_FRAGMENT_NODE )
	{
		/** Spec:
		 
		 "If newChild is a DocumentFragment object, oldChild is replaced by all of the DocumentFragment children, which are inserted in the same order. If the newChild is already in the tree, it is first removed."
		 */
		
		NSUInteger oldIndex = [self.childNodes.internalArray indexOfObject:oldChild];
		
		NSAssert( FALSE, @"We should be recursing down the tree to find 'newChild' at any location, and removing it - required by spec - but we have no convenience method for that search, yet" );
		
		for( SVGCNode* child in newChild.childNodes.internalArray )
		{
			[self.childNodes.internalArray insertObject:child atIndex:oldIndex++];
		}
		
		newChild.parentNode = self;
		oldChild.parentNode = nil;
		
		return oldChild;
	}
	else
	{
		[self.childNodes.internalArray replaceObjectAtIndex:[self.childNodes.internalArray indexOfObject:oldChild] withObject:newChild];
		
		newChild.parentNode = self;
		oldChild.parentNode = nil;
		
		return oldChild;
	}
}
-(SVGCNode*) removeChild:(SVGCNode*) oldChild
{
	[self.childNodes.internalArray removeObject:oldChild];
	
	oldChild.parentNode = nil;
	
	return oldChild;
}

-(SVGCNode*) appendChild:(SVGCNode*) newChild
{
	[self.childNodes.internalArray removeObject:newChild]; // required by spec
	[self.childNodes.internalArray addObject:newChild];
	
	newChild.parentNode = self;
	
	return newChild;
}

-(BOOL)hasChildNodes
{
	return (self.childNodes.length > 0);
}

-(SVGCNode*) cloneNode:(BOOL) deep
{
	NSAssert( FALSE, @"Not implemented yet - read the spec. Sounds tricky. I'm too tired, and would probably screw it up right now" );
	return nil;
}

// Modified in DOM Level 2:
-(void) normalize
{
	NSAssert( FALSE, @"Not implemented yet - read the spec. Sounds tricky. I'm too tired, and would probably screw it up right now" );
}

// Introduced in DOM Level 2:
-(BOOL) isSupportedFeature:(NSString*) feature version:(NSString*) version
{
	NSAssert( FALSE, @"Not implemented yet - read the spec. I have literally no idea what this is supposed to do." );
	return FALSE;
}

// Introduced in DOM Level 2:
@synthesize namespaceURI;

// Introduced in DOM Level 2:
@synthesize prefix;

// Introduced in DOM Level 2:
-(BOOL)hasAttributes
{
	if( self.attributes == nil )
		return FALSE;
	
	return (self.attributes.length > 0 );
}

#pragma mark - SPECIAL CASE: DOM level 3 method

/** 
 
 Note that the DOM 3 spec defines this as RECURSIVE:
 
 http://www.w3.org/TR/2004/REC-DOM-Level-3-Core-20040407/core.html#Node3-textContent
 */
-(NSString *)textContent
{
	switch( self.nodeType )
	{
		case SVGCNodeType_ELEMENT_NODE:
		case SVGCNodeType_ATTRIBUTE_NODE:
		case SVGCNodeType_ENTITY_NODE:
		case SVGCNodeType_ENTITY_REFERENCE_NODE:
		case SVGCNodeType_DOCUMENT_FRAGMENT_NODE:
		{
			/** DOM 3 Spec:
			 "concatenation of the textContent attribute value of every child node, excluding COMMENT_NODE and PROCESSING_INSTRUCTION_NODE nodes. This is the empty string if the node has no children."
			 */
			NSMutableString* stringAccumulator = [[NSMutableString alloc] init];
			for( SVGCNode* subNode in self.childNodes.internalArray )
			{
				NSString* subText = subNode.textContent; // don't call this method twice; it's expensive to calculate!
				if( subText != nil ) // Yes, really: Apple docs require that you never append a nil substring. Sigh
					[stringAccumulator appendString:subText];
			}
			
			return [NSString stringWithString:stringAccumulator];
		}
			
		case SVGCNodeType_TEXT_NODE:
		case SVGCNodeType_CDATA_SECTION_NODE:
		case SVGCNodeType_COMMENT_NODE:
		case SVGCNodeType_PROCESSING_INSTRUCTION_NODE:
		{
			return self.nodeValue; // should never be nil; anything with a valid value will be at least an empty string i.e. ""
		}
			
		case SVGCNodeType_DOCUMENT_NODE:
		case SVGCNodeType_NOTATION_NODE:
		case SVGCNodeType_DOCUMENT_TYPE_NODE:
		{
			return nil;
		}
	}
}

#pragma mark - ADDITIONAL to SVG Spec: useful debug / output / description methods

-(NSString *)description
{
	NSString* nodeTypeName;
	switch( self.nodeType )
	{
		case SVGCNodeType_ELEMENT_NODE:
			nodeTypeName = @"ELEMENT";
			break;
		case SVGCNodeType_TEXT_NODE:
			nodeTypeName = @"TEXT";
			break;
		case SVGCNodeType_ENTITY_NODE:
			nodeTypeName = @"ENTITY";
			break;
		case SVGCNodeType_COMMENT_NODE:
			nodeTypeName = @"COMMENT";
			break;
		case SVGCNodeType_DOCUMENT_NODE:
			nodeTypeName = @"DOCUMENT";
			break;
		case SVGCNodeType_NOTATION_NODE:
			nodeTypeName = @"NOTATION";
			break;
		case SVGCNodeType_ATTRIBUTE_NODE:
			nodeTypeName = @"ATTRIBUTE";
			break;
		case SVGCNodeType_CDATA_SECTION_NODE:
			nodeTypeName = @"CDATA";
			break;
		case SVGCNodeType_DOCUMENT_TYPE_NODE:
			nodeTypeName = @"DOC TYPE";
			break;
		case SVGCNodeType_ENTITY_REFERENCE_NODE:
			nodeTypeName = @"ENTITY REF";
			break;
		case SVGCNodeType_DOCUMENT_FRAGMENT_NODE:
			nodeTypeName = @"DOC FRAGMENT";
			break;
		case SVGCNodeType_PROCESSING_INSTRUCTION_NODE:
			nodeTypeName = @"PROCESSING INSTRUCTION";
			break;
			
		default:
			nodeTypeName = @"N/A (DATA IS MISSING FROM NODE INSTANCE)";
	}
	return [NSString stringWithFormat:@"Node: %@ (%@) value:[%@] @@%ld attributes + %ld x children", self.nodeName, nodeTypeName, [self.nodeValue length]<11 ? self.nodeValue : [NSString stringWithFormat:@"%@...",[self.nodeValue substringToIndex:10]], self.attributes.length, (unsigned long)self.childNodes.length];
}

#pragma mark - Objective-C serialization method to serialize a DOM tree back to XML (used heavily in SVGKit's output/conversion features)

/** EXPERIMENTAL: not fully implemented or tested - this correctly outputs most SVG files, but is missing esoteric
 features such as EntityReferences, currently they are simply ignored
 
 This method should be used hand-in-hand with the proprietary SVGDocument method "allNamespaces" and the SVGSVGElement method "
 
 @param outputString an empty MUTABLE string we can accumulate with output (NB: this method uses a lot of memory, needs to accumulate data)
 
 @param prefixesByKNOWNNamespace (required): a dictionary mapping "XML namespace URI" to "prefix to use inside the xml-tags", e.g. "http://w3.org/2000/svg" usually is mapped to "svg" (or to "", signifying it's the default namespace). This MUST include ALL NAMESPACES FOUND IN THE DOCUMENT (it's recommended you use SVGDocument's "allPrefixesByNamespace" method, and some post-processing, to get an accurate input here)
 
 @param prefixesByACTIVENamespace (required): a mutable dictionary listing which elements of the other dictionary are active in-scope - i.e. which namespaces have been output by this node or a higher node in the tree. You pass-in an empty dictionary to the root SVG node and it fills it in as required.
 */
-(void) appendXMLToString:(NSMutableString*) outputString availableNamespaces:(NSDictionary*) prefixesByKNOWNNamespace activeNamespaces:(NSMutableDictionary*) prefixesByACTIVENamespace
{
//	NSAssert(namespaceShortnames != nil, @"Must supply an empty dictionary for me to fill with encountered namespaces, and the shortnames I invented for them!");
	
	/** Opening */
	switch( self.nodeType )
	{
		case SVGCNodeType_ATTRIBUTE_NODE:
		{
			// ?
		}break;
			
		case SVGCNodeType_CDATA_SECTION_NODE:
		{
			[outputString appendFormat:@"<!--"];
		}break;
			
		case SVGCNodeType_COMMENT_NODE:
		{
			[outputString appendFormat:@"<![CDATA["];
		}break;
			
		case SVGCNodeType_DOCUMENT_FRAGMENT_NODE:
		case SVGCNodeType_DOCUMENT_NODE:
		case SVGCNodeType_ELEMENT_NODE:
		{
			[outputString appendFormat:@"<%@", self.nodeName];
		}break;
			
		case SVGCNodeType_DOCUMENT_TYPE_NODE:
		case SVGCNodeType_ENTITY_NODE:
		case SVGCNodeType_ENTITY_REFERENCE_NODE:
		case SVGCNodeType_NOTATION_NODE:
		case SVGCNodeType_PROCESSING_INSTRUCTION_NODE:
		case SVGCNodeType_TEXT_NODE:
		{
			// ?
		}break;
	}
	
	/** ATTRIBUTES on the node (generally only applies to things of type "SVGCNodeType_ELEMENT_NODE") */
	NSDictionary* nodeMapsByNamespace = [self.attributes allNodesUnsortedDOM2];
	NSMutableDictionary* newlyActivatedPrefixesByNamespace = [NSMutableDictionary dictionary];
	/**
	 First, find all the attributes that declare a new Namespace at this point */
	NSString* xmlnsNamespace = @"http://www.w3.org/2000/xmlns/";
	NSDictionary* xmlnsNodemap = [nodeMapsByNamespace objectForKey:xmlnsNamespace];
	/** ... output them, making them 'active' in the output tree */
	for( NSString* xmlnsNodeName in xmlnsNodemap )
	{
		SVGCNode* attribute = [xmlnsNodemap objectForKey:xmlnsNodeName];
		
		if( [prefixesByACTIVENamespace objectForKey:xmlnsNodeName] == nil )
		{
			[newlyActivatedPrefixesByNamespace setObject:xmlnsNodeName forKey:attribute.nodeValue];
			if( xmlnsNodeName.length == 0 ) // special case: the "default" namespace we encode elsewhere in SVGKit as a namespace of ""
				[outputString appendFormat:@" xmlns=\"%@\"", attribute.nodeValue];
			else
				[outputString appendFormat:@" xmlns:%@=\"%@\"", xmlnsNodeName, attribute.nodeValue];
		}
	}
	
	/**
	 Second, process "all" attributes, by namespace. Any time we find an attribute that "needs" a new
	 namespace, we ACTIVATE it, and store it in the set of newly-activated namespaces.
	 
	 We will later replace our current "active" set with this new "active" set before we recurse to our
	 child nodes
	 */
	for( NSString* namespace in nodeMapsByNamespace )
	{
		if( [namespace isEqualToString:xmlnsNamespace] )
			continue; // we had to handle this FIRST, so we've already done it
		
		NSString* localPrefix = [prefixesByACTIVENamespace objectForKey:namespace];
		if( localPrefix == nil )
		{
			/** check if it's one of our freshly-activated ones */
			localPrefix = [newlyActivatedPrefixesByNamespace objectForKey:namespace];
		}
		
		if( localPrefix == nil )
		{
			/** If it STILL isn't active, (no parent Node has output it yet), we must activate it */
			
			localPrefix = [prefixesByKNOWNNamespace objectForKey:namespace];
			
			NSAssert( localPrefix != nil, @"Found a namespace (%@) in node (%@) which wasn't listed in the KNOWN namespaces you provided (%@); you MUST provide a COMPLETE list of known-namespaces to this method", namespace, self.nodeName, prefixesByKNOWNNamespace );
			
			[newlyActivatedPrefixesByNamespace setObject:localPrefix forKey:namespace];
			[outputString appendFormat:@" xmlns:%@=\"%@\"", localPrefix, namespace];
		}
		
		/** Finally: output the plain-old-attributes, overwriting their prefixes where necessary */
		NSDictionary* nodeMap = [nodeMapsByNamespace objectForKey:namespace];
		for( NSString* nodeNameFromMap in nodeMap )
		{
			SVGCNode* attribute = [nodeMap objectForKey:nodeNameFromMap];
			
			attribute.prefix = localPrefix; /** Overrides any default pre-existing value */
			
			[outputString appendFormat:@" %@=\"%@\"", attribute.nodeName, attribute.nodeValue];
		}
	}
	/** Post-processing: after ATTRIBUTES, we need to modify the "ACTIVE" set of namespaces we're passing-down
	 to our child nodes
	 
	 Create a NEW dictionary to pass to our descendents, so that our ancestors don't get to see it
	 */
	prefixesByACTIVENamespace = [NSMutableDictionary dictionaryWithDictionary:prefixesByACTIVENamespace];
	[prefixesByACTIVENamespace addEntriesFromDictionary:newlyActivatedPrefixesByNamespace];
	switch( self.nodeType )
	{
		case SVGCNodeType_ATTRIBUTE_NODE:
		case SVGCNodeType_CDATA_SECTION_NODE:
		case SVGCNodeType_COMMENT_NODE:
		{
			// nothing
		}break;
			
		case SVGCNodeType_DOCUMENT_FRAGMENT_NODE:
		case SVGCNodeType_DOCUMENT_NODE:
		case SVGCNodeType_ELEMENT_NODE:
		{
			[outputString appendString:@">"];
		}break;
			
		case SVGCNodeType_DOCUMENT_TYPE_NODE:
		case SVGCNodeType_ENTITY_NODE:
		case SVGCNodeType_ENTITY_REFERENCE_NODE:
		case SVGCNodeType_NOTATION_NODE:
		case SVGCNodeType_PROCESSING_INSTRUCTION_NODE:
		case SVGCNodeType_TEXT_NODE:
		{
			// nothing
		}break;
	}
	
	/** Middle: include child nodes (only applies to some nodes - others will have values, others will have simply "zero children") */
	switch( self.nodeType )
	{
		case SVGCNodeType_ATTRIBUTE_NODE:
		case SVGCNodeType_CDATA_SECTION_NODE:
		case SVGCNodeType_COMMENT_NODE:
		case SVGCNodeType_DOCUMENT_TYPE_NODE:
		case SVGCNodeType_ENTITY_NODE:
		case SVGCNodeType_ENTITY_REFERENCE_NODE:
		case SVGCNodeType_NOTATION_NODE:
		case SVGCNodeType_PROCESSING_INSTRUCTION_NODE:
		case SVGCNodeType_TEXT_NODE:
		{
			[outputString appendString:self.nodeValue];
		}break;
			
		case SVGCNodeType_DOCUMENT_FRAGMENT_NODE:
		case SVGCNodeType_DOCUMENT_NODE:
		case SVGCNodeType_ELEMENT_NODE:
		{
			for( SVGCNode* child in self.childNodes )
			{
				[child appendXMLToString:outputString availableNamespaces:prefixesByKNOWNNamespace activeNamespaces:prefixesByACTIVENamespace];
			}
		}break;
	}
	
	/** End: close any nodes that opened an XML tag, or an XML comment or CDATA, during Opening */
	switch( self.nodeType )
	{
		case SVGCNodeType_ATTRIBUTE_NODE:
		{
			// nothing
		}break;
		
		case SVGCNodeType_CDATA_SECTION_NODE:
		{
			[outputString appendFormat:@"-->"];
		}break;
			
		case SVGCNodeType_COMMENT_NODE:
		{
			[outputString appendFormat:@"]]>"];
		}break;
		
		case SVGCNodeType_DOCUMENT_FRAGMENT_NODE:
		case SVGCNodeType_DOCUMENT_NODE:
		case SVGCNodeType_ELEMENT_NODE:
		{
			[outputString appendFormat:@"</%@>", self.nodeName];
		}break;
			
		case SVGCNodeType_DOCUMENT_TYPE_NODE:
		case SVGCNodeType_ENTITY_NODE:
		case SVGCNodeType_ENTITY_REFERENCE_NODE:
		case SVGCNodeType_NOTATION_NODE:
		case SVGCNodeType_PROCESSING_INSTRUCTION_NODE:
		case SVGCNodeType_TEXT_NODE:
		{
			// nothing
		}break;
	}
}

@end
