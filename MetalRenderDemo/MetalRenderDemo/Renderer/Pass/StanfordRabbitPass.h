//
//  StanfordRabbitPass.h
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/7/11.
//

#import <Foundation/Foundation.h>
#import "RenderPass.h"

NS_ASSUME_NONNULL_BEGIN

@interface StanfordRabbitPass : NSObject<RenderPass>
- (id<MTLTexture>)targetTexture;
@end

NS_ASSUME_NONNULL_END
