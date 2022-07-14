//
//  Cubes.m
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/7/13.
//

#import "CubePass.h"
#import "AAPLMathUtilities.h"

@implementation CubePass
{
    RenderContex* _context;
    id<MTLRenderPipelineState> _state;
    id<MTLDepthStencilState> _dsState;
    id<MTLBuffer> _vertices;
    id<MTLBuffer> _indices;
    id<MTLTexture> _texture;
    
    MTLRenderPassDescriptor* _renderPassdesc;
    
    vector_int2 _viewport;
    matrix_float4x4 _mvp;
}

- (instancetype)initWithContext:(RenderContex*)context
{
    if (self = [super init]) {
        _context = context;
        [[Renderer shared] setContext:_context];
        _renderPassdesc = [[Renderer shared] newRenderPassDescriptorWithTextureAndDepthAttachment:_context.size.width height:_context.size.height];


        _vertices = [_context.device newBufferWithBytes:cubeVertices length:sizeof(cubeVertices) options:MTLResourceOptionCPUCacheModeDefault];
        _vertices.label = @"vertices";
        _indices = [_context.device newBufferWithBytes:indices length:sizeof(indices) options:MTLResourceOptionCPUCacheModeDefault];
        
        _state = [[Renderer shared] newStateWithShader:@"cube_vs" andFsh:@"cube_fs"];
        _dsState = [[Renderer shared] newDepthSetncilState];
        
        _mvp = matrix_identity_float4x4;//matrix4x4_rotation(_frameNum * (M_PI / 180.), 0., 0., 1.);
        
        matrix_float4x4 view = matrix_look_at_right_hand(3 ,3 , 3, 0.,0.,0., 0.,1.,0.);//matrix4x4_translation(0., 0., -3.); //按照右手坐标系，要远离z=0的平面
        
        matrix_float4x4 projection = matrix_perspective_right_hand(60.0f * (M_PI / 180.0f), 9./16., 0.1, 5000.0);
        
        _mvp = matrix_multiply(view, _mvp);
        _mvp = matrix_multiply(projection, _mvp);

    }
    return self;
}

- (void)resize:(CGSize)size
{
    _viewport.x = size.width;
    _viewport.y = size.height;
}

- (void)render
{
    id<MTLCommandBuffer> cb = _context.commandBuffer;
    
    id<MTLRenderCommandEncoder> encoder = [cb renderCommandEncoderWithDescriptor:_renderPassdesc];
    if (encoder)
    {
        
        [encoder setDepthStencilState:_dsState];
        [encoder setRenderPipelineState:_state];
    
        [encoder setVertexBuffer:_vertices offset:0 atIndex:0];
        
        [encoder setVertexBytes:&_mvp length:sizeof(_mvp) atIndex:1];
        [encoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle indexCount:[_indices length]/sizeof(uint16_t) indexType:MTLIndexTypeUInt16 indexBuffer:_indices indexBufferOffset:0];

        [encoder endEncoding];
    }
}


- (void)renderToTexture:(id<MTLTexture>)texture
{
    _renderPassdesc.colorAttachments[0].texture = texture;
    [self render];
}

- (id<MTLTexture>)targetTexture
{
    return _renderPassdesc.colorAttachments[0].texture;
}

@end
