//
//  RenderPass.h
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/7/11.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <UIKit/UIKit.h>
#import "Renderer.h"
NS_ASSUME_NONNULL_BEGIN



@protocol RenderPass <NSObject>
- (instancetype)initWithContext:(RenderContex*)context;
- (void)resize:(CGSize)size;
- (void)render;

@end

NS_ASSUME_NONNULL_END
