//
//  CubePass.h
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/7/14.
//

#import <Foundation/Foundation.h>
#import "RenderPass.h"
#import "../SharedTypes.h"
NS_ASSUME_NONNULL_BEGIN

static float cubeVertices[] =
{
    -0.5, 0.5, 0.5,1,
    -0.5,-0.5, 0.5,1,
    0.5,-0.5, 0.5,1,
    0.5, 0.5, 0.5,1,

    -0.5, 0.5,-0.5,1,
    -0.5,-0.5,-0.5,1,
    0.5,-0.5,-0.5,1,
    0.5, 0.5,-0.5,1,

};

const uint16_t indices[] = {
    3,2,6,6,7,3,
    4,5,1,1,0,4,
    4,0,3,3,7,4,
    1,5,6,6,2,1,
    0,1,2,2,3,0,
    7,6,5,5,4,7
};

@interface CubePass : NSObject<RenderPass>

- (id<MTLTexture>)targetTexture;
- (void)renderToTexture:(id<MTLTexture>)texture;
@end

NS_ASSUME_NONNULL_END
