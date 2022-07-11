//
//  MTLRenderer.h
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/6/27.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <MetalKit/MTKView.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTLRenderer : NSObject

- (instancetype)initWithMTKView:(nonnull MTKView *)view;

- (void)mtkView:(nonnull MTKView *)view resize:(CGSize)size;

- (void)render:(nonnull MTKView *)view;

@end

NS_ASSUME_NONNULL_END
