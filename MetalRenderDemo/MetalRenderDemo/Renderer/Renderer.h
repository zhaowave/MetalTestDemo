//
//  Renderer.h
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/7/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>

#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

@interface RenderContex : NSObject

- (instancetype)initWithMTLDevice:(nonnull id<MTLDevice>)device;

@property (nonatomic, assign) CGSize size;

- (id<MTLDevice>)device;
- (id<MTLCommandQueue>)queue;
- (id<MTLCommandBuffer>)commandBuffer;
- (void)updateCommandBuffer;


@end

@interface Renderer : NSObject

@property(nonatomic, weak) RenderContex* context;

+(instancetype) shared;

- (id<MTLRenderPipelineState>)newStateWithShader:(NSString*)vsh andFsh:(NSString*)fsh;

- (id<MTLDepthStencilState>)newDepthSetncilState;

- (MTLRenderPassDescriptor*)newRenderPassDescriptor;

- (MTLRenderPassDescriptor*)newRenderPassDescriptorWithTexture:(NSInteger)width height:(NSInteger)height;

- (MTLRenderPassDescriptor*)newRenderPassDescriptorWithTextureAndDepthAttachment:(NSInteger)width height:(NSInteger)height;


- (id<MTLTexture>)newTexture:(NSInteger)width height:(NSInteger)height;




@end

NS_ASSUME_NONNULL_END
