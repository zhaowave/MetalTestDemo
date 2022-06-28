//
//  MTLRenderer.m
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/6/27.
//

#import "MTLRenderer.h"
#import "SharedTypes.h"


@implementation MTLRenderer
{
    id<MTLDevice> _device;
    //commandqueue
    id<MTLCommandQueue> _commandQ;
    //pipeline
    id<MTLRenderPipelineState> _state;
    MTKView* _view;
    vector_uint2 _viewport;
}

- (instancetype)initWithMTKView:(nonnull MTKView *)view
{
    if (self = [super init]) {
        _device = view.device;
        _view = view;
        [self createMTLObj];
    }
    return self;
}

- (void) createMTLObj
{
    _commandQ = [_device newCommandQueue];
    
    id<MTLLibrary> library = [_device newDefaultLibrary];
    
    id<MTLFunction> vFunc = [library newFunctionWithName:@"vmain"];
    id<MTLFunction> fFunc = [library newFunctionWithName:@"fmain"];
    
    MTLRenderPipelineDescriptor* pipelineDesc = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineDesc.label = @"pipelineDesc";
    pipelineDesc.fragmentFunction = fFunc;
    pipelineDesc.vertexFunction = vFunc;
    pipelineDesc.colorAttachments[0].pixelFormat = _view.colorPixelFormat;
    
    NSError *error;
    _state = [_device newRenderPipelineStateWithDescriptor:pipelineDesc error:&error];
}

- (void)mtkView:(nonnull MTKView *)view resize:(CGSize)size{
    _viewport.x = size.width;
    _viewport.y = size.height;
}

- (void)render:(nonnull MTKView *)view
{
    static const VertexData vertexData[] = {
        {{-0.5,-0.5}, {1.,0.,0.,1.}},
        {{-0.5, 0.5}, {0.,1.,0.,1.}},
        {{0.,   0.5}, {0.,0.,1.,1.}}
    };
    
    id<MTLCommandBuffer> cb = [_commandQ commandBuffer];
    cb.label = @"cb";
    
    MTLRenderPassDescriptor* renderPassDesc = view.currentRenderPassDescriptor;
    if (renderPassDesc != nil) {
        id<MTLRenderCommandEncoder> encoder = [cb renderCommandEncoderWithDescriptor:renderPassDesc];
        [encoder setLabel:@"encoder"];
        [encoder setViewport:(MTLViewport){0.0, 0.0, _viewport.x, _viewport.y, 0.0, 1.0 }];
        [encoder setRenderPipelineState:_state];
        [encoder setVertexBytes:vertexData length:sizeof(vertexData) atIndex:0];
        [encoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
        [encoder endEncoding];
        
        [cb presentDrawable:view.currentDrawable];
    }
    [cb commit];
    
}


@end
