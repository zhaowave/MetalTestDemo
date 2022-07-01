//
//  MTLLayerRenderer.h
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/6/30.
//

#import <Foundation/Foundation.h>

#import <Metal/Metal.h>
#import <QuartzCore/CAMetalLayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTLLayerRenderer : NSObject

- (instancetype)initWithMTLDevice:(nonnull id<MTLDevice>)dvc andPixelFormat:(MTLPixelFormat)format;

- (void)renderToMetalLayer:(nonnull CAMetalLayer*)layer;

- (void)resize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
