//
//  RenderPass.h
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/7/11.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface RenderContex : NSObject

- (instancetype)initWithMTLDevice:(nonnull id<MTLDevice>)device;

- (id<MTLDevice>) device;
- (id<MTLCommandQueue>) queue;

@end

@protocol RenderPass <NSObject>
- (instancetype)initWithContext:(RenderContex*)context;
- (void)resize:(CGSize)size;
- (void)render;

@end

NS_ASSUME_NONNULL_END
