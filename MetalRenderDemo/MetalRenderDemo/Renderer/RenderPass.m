//
//  RenderPass.m
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/7/11.
//

#import "RenderPass.h"

@implementation RenderContex
{
    id<MTLDevice> _device;
    id<MTLCommandQueue> _queue;
}


- (instancetype)initWithMTLDevice:(nonnull id<MTLDevice>)device
{
    if (self = [super init])
    {
        _device = device;
        _queue = [_device newCommandQueue];
    }
    return  self;
}

- (id<MTLDevice>) device
{
    return _device;
}
- (id<MTLCommandQueue>) queue
{
    return _queue;
}

@end
