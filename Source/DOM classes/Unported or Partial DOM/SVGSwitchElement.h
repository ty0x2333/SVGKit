

#import "SVGElement.h"

#import "ConverterSVGToCALayer.h"

@interface SVGSwitchElement : SVGElement <ConverterSVGToCALayer>

@property (nonatomic, readonly, strong) SVGCNodeList * visibleChildNodes;

@end
