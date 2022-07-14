//
//  StanfordRabbitPass.m
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/7/11.
//

#import "StanfordRabbitPass.h"
#import "ObjParser.hpp"
#import "AAPLMathUtilities.h"

#import "CubePass.h"

@implementation StanfordRabbitPass
{
    ObjParser::ObjData _objData;
    id<MTLBuffer> _vertices;
    id<MTLBuffer> _indices;
    id<MTLRenderPipelineState> _renderState;
    id<MTLDepthStencilState> _dsState;
    id<MTLTexture> _texture;
    MTLRenderPassDescriptor* _renderPassDesc;
    RenderContex* _context;
    NSInteger _frameNum;
}

- (instancetype)initWithContext:(RenderContex*)context
{
    if (self = [super init]) {
        _frameNum = 0;
        _context = context;
        NSString* file = [[NSBundle mainBundle] pathForResource:@"stanfordbunny" ofType:@"obj"];
        _objData = ObjParser::ParseObj(file.UTF8String);
        
        _renderState = [[Renderer shared] newStateWithShader:@"rabbit_vs" andFsh:@"rabbit_fs"];
        
        _dsState = [[Renderer shared] newDepthSetncilState];
        
        _renderPassDesc = [[Renderer shared] newRenderPassDescriptorWithTextureAndDepthAttachment:_context.size.width height:_context.size.height];
        
        
        NSInteger verticesLen = _objData.vertices.size() * sizeof(float);
        NSInteger indicesLen = _objData.indices.size() * sizeof(int);
        
        _vertices = [context.device newBufferWithBytes:_objData.vertices.data() length:verticesLen options:MTLResourceOptionCPUCacheModeDefault];
        _indices = [context.device  newBufferWithBytes:_objData.indices.data() length:indicesLen options:MTLResourceOptionCPUCacheModeDefault];
        
//        _vertices = [context.device newBufferWithBytes:cubeVertices length:sizeof(cubeVertices) options:MTLResourceOptionCPUCacheModeDefault];
//        _indices = [context.device  newBufferWithBytes:indices length:sizeof(indices) options:MTLResourceOptionCPUCacheModeDefault];
    }
    return self;
}
- (void)resize:(CGSize)size
{
    
}
- (void) render
{
    _frameNum++;
    id<MTLCommandBuffer> cb = _context.commandBuffer;
    id<MTLRenderCommandEncoder> encoder = [cb renderCommandEncoderWithDescriptor:_renderPassDesc];
    [encoder setRenderPipelineState:_renderState];
    [encoder setDepthStencilState:_dsState];
    
    [encoder setVertexBuffer:_vertices offset:0 atIndex:0];
    
    matrix_float4x4 model = matrix_identity_float4x4;//matrix4x4_rotation(_frameNum * (M_PI / 180.), 0., 0., 1.);
    
    matrix_float4x4 view = matrix_look_at_right_hand(sin(_frameNum* 0.01)  ,0 ,  cos(_frameNum*0.01) , 0.,0.,0., 0.,1.,0.);//matrix4x4_translation(0., 0., -3.); //按照右手坐标系，要远离z=0的平面
    
    matrix_float4x4 projection = matrix_perspective_right_hand(60.0f * (M_PI / 180.0f), (float)9./(float)16., 0.1, 5000.0);
    
    model = matrix_multiply(view, model);
    model = matrix_multiply(projection, model);
    
    [encoder setVertexBytes:&model length:sizeof(model) atIndex:1];
    
    [encoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle indexCount:_objData.indices.size() indexType:MTLIndexTypeUInt32 indexBuffer:_indices indexBufferOffset:0];
 
    [encoder endEncoding];
    
//    [cb commit];
}

- (id<MTLTexture>)targetTexture
{
    return _renderPassDesc.colorAttachments[0].texture;
}

@end
