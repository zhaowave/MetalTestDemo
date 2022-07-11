//
//  Renderer.m
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/7/11.
//

#import "Renderer.h"

@implementation Renderer

+(instancetype) shared
{
    static Renderer* single = nil;
    dispatch_once_t token;
    dispatch_once(&token, ^{
        single = [[self alloc] init];
    });
    return single;
}

@end
