//
//  MTLLayerRenderer.m
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/6/30.
//

#import "MTLLayerRenderer.h"
#import "SharedTypes.h"
#import <UIKit/UIKit.h>

@implementation MTLLayerRenderer
{
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQ;
    
    id<MTLRenderPipelineState> _state;
    id<MTLBuffer> _vertices;
    id<MTLTexture> _texture;
    
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
        [self loadTexture];
        //shader
        {
            id<MTLLibrary> lib = [_device newDefaultLibrary];
            
            id<MTLFunction> vs = [lib newFunctionWithName:@"vmain1"];
            id<MTLFunction> fs = [lib newFunctionWithName:@"fmain1"];
            
            
            static const VertexData data[] = {
                {{-1.,-1.}, {1.,0.,0.,1.}},
                {{1., -1.}, {0.,1.,0.,1.}},
                {{-1,  1.}, {0.,0.,1.,1.}},
                
                {{-1.,1.}, {1.,0.,0.,1.}},
                {{1.,-1.}, {0.,1.,0.,1.}},
                {{1, 1  }, {0.,0.,1.,1.}},
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

- (void)loadTexture
{
    UIImage* image = [UIImage imageNamed:@"00-apple.png"];
    if (image != nil)
    {
        MTLTextureDescriptor* desc = [[MTLTextureDescriptor alloc] init];
        desc.width = image.size.width;
        desc.height = image.size.height;
        desc.pixelFormat = MTLPixelFormatRGBA8Unorm_sRGB;
        
        _texture = [_device newTextureWithDescriptor:desc];
        MTLRegion region = {{0,0,0}, {image.size.width,image.size.height,1}};
        
        Byte* data = [self loadImage:image];
        if (data)
        {
            [_texture replaceRegion:region mipmapLevel:0 withBytes:data bytesPerRow:image.size.width * 4];
            free(data);
            data = NULL;
        }
        
    }
   
    
}

- (Byte *)loadImage:(UIImage *)image {
    // 1.获取图片的CGImageRef
    CGImageRef spriteImage = image.CGImage;
    
    // 2.读取图片的大小
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
   
    //3.计算图片大小.rgba共4个byte
    Byte * spriteData = (Byte *) calloc(width * height * 4, sizeof(Byte));
    
    //4.创建画布
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    //5.在CGContextRef上绘图
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    //6.图片翻转过来
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextTranslateCTM(spriteContext, rect.origin.x, rect.origin.y);
    CGContextTranslateCTM(spriteContext, 0, rect.size.height);
    CGContextScaleCTM(spriteContext, 1.0, -1.0);
    CGContextTranslateCTM(spriteContext, -rect.origin.x, -rect.origin.y);
    CGContextDrawImage(spriteContext, rect, spriteImage);
    
    //7.释放spriteContext
    CGContextRelease(spriteContext);
    
    return spriteData;
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
        [encoder setFragmentTexture:_texture atIndex:0];
        
        float scale = 1.;//0.5 + (1.0 + 0.5 * sin(_frameNum * 0.1));;
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
