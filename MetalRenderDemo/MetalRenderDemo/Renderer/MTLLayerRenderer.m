//
//  MTLLayerRenderer.m
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/6/30.
//

#import "MTLLayerRenderer.h"
#import "SharedTypes.h"

@implementation MTLLayerRenderer
{
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQ;
    
    id<MTLRenderPipelineState> _state;
    id<MTLBuffer> _vertices;
    
    MTLRenderPassDescriptor* _renderPassdesc;
    
    vector_int2 _viewport;
    NSInteger _frameNum;
    
}

- (instancetype)initWithMTLDevice:(nonnull id<MTLDevice>)dvc andPixelFormat:(MTLPixelFormat)format
{
    if (self = [super init]) {
        _frameNum = 0;
        _device = dvc;
        _commandQ = [_device newCommandQueue];
        _renderPassdesc = [MTLRenderPassDescriptor new];
        _renderPassdesc.colorAttachments[0].loadAction = MTLLoadActionClear;
        _renderPassdesc.colorAttachments[0].storeAction = MTLStoreActionStore;
        _renderPassdesc.colorAttachments[0].clearColor = MTLClearColorMake(1., 1., 0., 1.);
        
        //shader
        {
            id<MTLLibrary> lib = [_device newDefaultLibrary];
            
            id<MTLFunction> vs = [lib newFunctionWithName:@"vmain1"];
            id<MTLFunction> fs = [lib newFunctionWithName:@"fmain1"];
            
            
            static const VertexData data[] = {
                {{-0.5,-0.5}, {1.,0.,0.,1.}},
                {{0.5, -0.5}, {0.,1.,0.,1.}},
                {{0.5,  0.5}, {0.,0.,1.,1.}},
                
                {{-0.5,-0.5}, {1.,0.,0.,1.}},
                {{0.5,  0.5}, {0.,1.,0.,1.}},
                {{-0.5, 0.5}, {0.,0.,1.,1.}},
            };
            _vertices = [_device newBufferWithBytes:data length:sizeof(data) options:MTLResourceStorageModeShared];
            _vertices.label = @"vertices";
            
            //pipeline state
            MTLRenderPipelineDescriptor *pipelineDesc = [MTLRenderPipelineDescriptor new];
            pipelineDesc.vertexFunction = vs;
            pipelineDesc.fragmentFunction = fs;
            pipelineDesc.colorAttachments[0].pixelFormat = format;
            
            NSError *error;
            _state = [_device newRenderPipelineStateWithDescriptor:pipelineDesc error:&error];
            
        }
        
    }
    return self;
}

- (void)renderToMetalLayer:(nonnull CAMetalLayer*)layer
{
    _frameNum++;
    id<MTLCommandBuffer> cb = [_commandQ commandBuffer];
    
    id<CAMetalDrawable> drawable = [layer nextDrawable];
    
    _renderPassdesc.colorAttachments[0].texture = drawable.texture;
    
    id<MTLRenderCommandEncoder> encoder = [cb renderCommandEncoderWithDescriptor:_renderPassdesc];
    if (encoder)
    {
        [encoder setRenderPipelineState:_state];
        [encoder setVertexBuffer:_vertices offset:0 atIndex:0];
        
        float scale = 0.5 + (1.0 + 0.5 * sin(_frameNum * 0.1));;
        [encoder setVertexBytes:&scale length:sizeof(scale) atIndex:1];
        
        [encoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
        [encoder endEncoding];
        [cb presentDrawable:drawable];
    }
    
    [cb commit];
}

- (void)resize:(CGSize)size
{
    _viewport.x = size.width;
    _viewport.y = size.height;
}


@end
