//
//  QuadPass.h
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/7/13.
//

#import <Foundation/Foundation.h>
#import "RenderPass.h"

NS_ASSUME_NONNULL_BEGIN

@interface QuadPass : NSObject<RenderPass>

- (void)setTexture:(id<MTLTexture>)texture;
- (void)renderToTexture:(id<MTLTexture>)texture;
@end

NS_ASSUME_NONNULL_END
