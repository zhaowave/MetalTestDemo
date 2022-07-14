//
//  Renderer.m
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/7/11.
//

#import "Renderer.h"


@implementation RenderContex
{
    id<MTLDevice> _device;
    id<MTLCommandQueue> _queue;
    id<MTLCommandBuffer> _buffer;
}


- (instancetype)initWithMTLDevice:(nonnull id<MTLDevice>)device
{
    if (self = [super init])
    {
        _device = device;
        _queue = [_device newCommandQueue];
        _buffer = [_queue commandBuffer];
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

- (id<MTLCommandBuffer>)commandBuffer
{
    return _buffer;
}

- (void) updateCommandBuffer
{
    _buffer = [_queue commandBuffer];
}
@end

@implementation Renderer


+(instancetype) shared
{
    static Renderer* single = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        single = [[self alloc] init];
    });
    return single;
}


- (id<MTLRenderPipelineState>)newStateWithShader:(NSString*)vsh andFsh:(NSString*)fsh
{
    MTLRenderPipelineDescriptor* desc = [MTLRenderPipelineDescriptor new];
    id<MTLLibrary> lib = [self.context.device newDefaultLibrary];
    desc.vertexFunction = [lib newFunctionWithName:vsh];
    desc.fragmentFunction = [lib newFunctionWithName:fsh];
    desc.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    desc.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    
    NSError* error;
    return [self.context.device newRenderPipelineStateWithDescriptor:desc error:&error];
}

- (id<MTLDepthStencilState>)newDepthSetncilState
{
    MTLDepthStencilDescriptor* desc = [MTLDepthStencilDescriptor new];
    desc.depthCompareFunction = MTLCompareFunctionLess;
    desc.depthWriteEnabled = YES;
    return [self.context.device newDepthStencilStateWithDescriptor:desc];
}

- (id<MTLTexture>)newTexture:(NSInteger)width height:(NSInteger)height
{
    MTLTextureDescriptor *texDescriptor = [MTLTextureDescriptor new];
    texDescriptor.textureType = MTLTextureType2D;
    texDescriptor.width = width;
    texDescriptor.height = height;
    texDescriptor.pixelFormat = MTLPixelFormatBGRA8Unorm;
    texDescriptor.usage = MTLTextureUsageRenderTarget |
                          MTLTextureUsageShaderRead;
    return [self.context.device newTextureWithDescriptor:texDescriptor];
}

- (MTLRenderPassDescriptor*)newRenderPassDescriptor
{
    MTLRenderPassDescriptor* desc = [MTLRenderPassDescriptor new];
    desc.colorAttachments[0].loadAction = MTLLoadActionClear;
    desc.colorAttachments[0].storeAction = MTLStoreActionStore;
    desc.colorAttachments[0].clearColor = MTLClearColorMake(0., 0., 0., 0.);
    
    return desc;
}

- (MTLRenderPassDescriptor*)newRenderPassDescriptorWithTexture:(NSInteger)width height:(NSInteger)height
{
    MTLRenderPassDescriptor* desc = [self newRenderPassDescriptor];
    id<MTLTexture> texture = [self newTexture:width height:height];
    
    desc.colorAttachments[0].texture = texture;
    return desc;
}


- (MTLRenderPassDescriptor*)newRenderPassDescriptorWithTextureAndDepthAttachment:(NSInteger)width height:(NSInteger)height
{
    MTLRenderPassDescriptor* desc = [self newRenderPassDescriptorWithTexture:width height:height];
    desc.depthAttachment.texture = [self createDepthStencilTextureWithWidth:self.context.size.width height:self.context.size.height];
    return desc;
}

- (id<MTLTexture>)createDepthStencilTextureWithWidth:(size_t)width height:(size_t)height {
    
    MTLTextureDescriptor *texDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat: MTLPixelFormatDepth32Float width: width height: height mipmapped: false];
    texDescriptor.usage = MTLTextureUsageRenderTarget;
    texDescriptor.storageMode = MTLStorageModePrivate;
    
    id<MTLTexture> texture = [_context.device newTextureWithDescriptor: texDescriptor];
    
    return texture;
}

@end
