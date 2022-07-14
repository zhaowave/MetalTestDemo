//
//  MTLLayerRenderer.m
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/6/30.
//

#import "MTLLayerRenderer.h"
#import "SharedTypes.h"
#import "AAPLMathUtilities.h"

#import "RenderPass.h"
#import "Renderer.h"
#import "CubesPass.h"
#import "CubePass.h"
#import "QuadPass.h"
#import "StanfordRabbitPass.h"
#include "ObjParser.hpp"
#import <UIKit/UIKit.h>


@implementation MTLLayerRenderer
{
    RenderContex* _context;
    id<MTLRenderPipelineState> _state;
    id<MTLDepthStencilState> _dsState;
    id<MTLBuffer> _vertices;
    id<MTLTexture> _texture;
    
    MTLRenderPassDescriptor* _renderPassdesc;
    
    vector_int2 _viewport;
    
    CubesPass* _cubesPass;
    
    QuadPass* _quadPass;
    StanfordRabbitPass* _rabbitPass;
    CubePass* _cubePass;
    
}

- (instancetype)initWithMTLDevice:(nonnull id<MTLDevice>)dvc andPixelFormat:(MTLPixelFormat)format
{
    if (self = [super init]) {
        _context = [[RenderContex alloc] initWithMTLDevice:dvc];
        CGSize size = [UIScreen mainScreen].bounds.size;
        size.width = size.width * [UIScreen mainScreen].nativeScale;
        size.height = size.height * [UIScreen mainScreen].nativeScale;
        _context.size =  size;
        [[Renderer shared] setContext:_context];
        
        _cubesPass = [[CubesPass alloc] initWithContext:_context];
//        _cubePass = [[CubePass alloc] initWithContext:_context];
        _quadPass = [[QuadPass alloc] initWithContext:_context];
        _rabbitPass = [[StanfordRabbitPass alloc] initWithContext:_context];
    
    }
    return self;
}

- (void)loadTexture
{
    UIImage* image = [UIImage imageNamed:@"00-apple.png"];
    if (image != nil)
    {
        MTLTextureDescriptor* desc = [[MTLTextureDescriptor alloc] init];
        desc.width = image.size.width;
        desc.height = image.size.height;
        desc.pixelFormat = MTLPixelFormatRGBA8Unorm;
        
        _texture = [_context.device newTextureWithDescriptor:desc];
        MTLRegion region = {{0,0,0}, {(NSUInteger)image.size.width,(NSUInteger)image.size.height,1}};
        
        Byte* data = [self loadImage:image];
        if (data)
        {
            [_texture replaceRegion:region mipmapLevel:0 withBytes:data bytesPerRow:image.size.width * 4];
            free(data);
            data = NULL;
        }
        
    }
   
    
}

- (Byte *)loadImage:(UIImage *)image {
    // 1.获取图片的CGImageRef
    CGImageRef spriteImage = image.CGImage;
    
    // 2.读取图片的大小
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
   
    //3.计算图片大小.rgba共4个byte
    Byte * spriteData = (Byte *) calloc(width * height * 4, sizeof(Byte));
    
    //4.创建画布
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    //5.在CGContextRef上绘图
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    //6.图片翻转过来
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextTranslateCTM(spriteContext, rect.origin.x, rect.origin.y);
    CGContextTranslateCTM(spriteContext, 0, rect.size.height);
    CGContextScaleCTM(spriteContext, 1.0, -1.0);
    CGContextTranslateCTM(spriteContext, -rect.origin.x, -rect.origin.y);
    CGContextDrawImage(spriteContext, rect, spriteImage);
    
    //7.释放spriteContext
    CGContextRelease(spriteContext);
    
    return spriteData;
}

- (void)renderToMetalLayer:(nonnull CAMetalLayer*)layer
{
    id<CAMetalDrawable> drawable = [layer nextDrawable];
    
    [_context updateCommandBuffer];
    
    [_rabbitPass render];
    [_cubesPass renderToTexture:_rabbitPass.targetTexture];
//    [_cubePass render];
    
    
    
    [_quadPass setTexture:_cubesPass.targetTexture];
    [_quadPass renderToTexture:drawable.texture];
    
    id<MTLCommandBuffer> cb = _context.commandBuffer;

    [cb presentDrawable:drawable];
    [cb commit];
}

- (void)resize:(CGSize)size
{
    _context.size = size;
    _viewport.x = size.width;
    _viewport.y = size.height;
    [_cubesPass resize:size];
}


@end
