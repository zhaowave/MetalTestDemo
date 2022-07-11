//
//  StanfordRabbitPass.m
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/7/11.
//

#import "StanfordRabbitPass.h"
#import "ObjParser.hpp"

@implementation StanfordRabbitPass
{
    ObjParser::ObjData _objData;
}

- (instancetype)initWithContext:(RenderContex*)context
{
    if (self = [super init]) {
        NSString* file = [[NSBundle mainBundle] pathForResource:@"stanfordbunny" ofType:@"obj"];
        _objData = ObjParser::ParseObj(file.UTF8String);
        
    }
    return self;
}
- (void)resize:(CGSize)size
{
    
}
- (void) render
{
    
}

@end
