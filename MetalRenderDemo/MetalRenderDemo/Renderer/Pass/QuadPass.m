//
//  QuadPass.m
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/7/13.
//

#import "QuadPass.h"

static const float quad[] = {
    -1.f,   1.f,
    -1.f,  -1.f,
     1.f,  -1.f,
    
    -1.f,   1.f,
     1.f,  -1.f,
     1.f,   1.f
};

@implementation QuadPass
{
    id<MTLBuffer> _vertices;
    id<MTLTexture> _inputTexture;
    
    id<MTLRenderPipelineState> _state;
    MTLRenderPassDescriptor* _renderPassDesc;
    RenderContex* _context;
}

- (instancetype)initWithContext:(RenderContex*)context
{
    if (self = [super init]) {
        _context = context;
        _vertices = [context.device newBufferWithBytes:quad length:sizeof(quad) options:MTLResourceStorageModeShared];
        
        _state = [[Renderer shared] newStateWithShader:@"quad_vs" andFsh:@"quad_fs"];
        _renderPassDesc = [[Renderer shared] newRenderPassDescriptorWithTextureAndDepthAttachment:_context.size.width height:_context.size.height];
        
    }
    return self;
}

- (void)setTexture:(id<MTLTexture>)texture
{
    _inputTexture = texture;
}
- (void)resize:(CGSize)size
{
    
}
- (void)render
{
    id<MTLCommandBuffer> cb = _context.commandBuffer;
    id<MTLRenderCommandEncoder> encoder = [cb renderCommandEncoderWithDescriptor:_renderPassDesc];
    
    [encoder setRenderPipelineState:_state];
    [encoder setVertexBuffer:_vertices offset:0 atIndex:0];
    [encoder setFragmentTexture:_inputTexture atIndex:0];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
    [encoder endEncoding];
//    [cb commit];
}

- (void)renderToTexture:(id<MTLTexture>)texture
{
    _renderPassDesc.colorAttachments[0].texture = texture;
    [self render];
}

@end
