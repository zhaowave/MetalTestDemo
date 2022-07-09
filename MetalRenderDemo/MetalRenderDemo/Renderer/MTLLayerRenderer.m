//
//  MTLLayerRenderer.m
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/6/30.
//

#import "MTLLayerRenderer.h"
#import "SharedTypes.h"
#import "AAPLMathUtilities.h"
//#import <vector_types.h>
#import <UIKit/UIKit.h>

@implementation MTLLayerRenderer
{
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQ;
    
    id<MTLRenderPipelineState> _state;
    id<MTLDepthStencilState> _dsState;
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
        _renderPassdesc.depthAttachment.texture = [self createDepthStencilTextureWithWidth:1170 height:2532];
        
        //shader
        {
            id<MTLLibrary> lib = [_device newDefaultLibrary];
            
            id<MTLFunction> vs = [lib newFunctionWithName:@"vmain1"];
            id<MTLFunction> fs = [lib newFunctionWithName:@"fmain1"];
            
            
            static const VertexCube data[] = {
                {{-0.5f, -0.5f, -0.5f},  {0.0f, 0.0f}},
                {{ 0.5f, -0.5f, -0.5f},  {1.0f, 0.0f}},
                {{ 0.5f,  0.5f, -0.5f},  {1.0f, 1.0f}},
                {{0.5f,  0.5f, -0.5f},  {1.0f, 1.0f}},
                {{-0.5f,  0.5f, -0.5f},  {0.0f, 1.0f}},
                {{-0.5f, -0.5f, -0.5f},  {0.0f, 0.0f}},

                {{-0.5f, -0.5f,  0.5f},  {0.0f, 0.0f}},
                {{0.5f, -0.5f,  0.5f},  {1.0f, 0.0f}},
                {{0.5f,  0.5f,  0.5f},  {1.0f, 1.0f}},
                {{0.5f,  0.5f,  0.5f},  {1.0f, 1.0f}},
                {{-0.5f,  0.5f,  0.5f},  {0.0f, 1.0f}},
                {{-0.5f, -0.5f,  0.5f},  {0.0f, 0.0f}},

                {{-0.5f,  0.5f,  0.5f},  {1.0f, 0.0f}},
                {{ -0.5f,  0.5f, -0.5f},  {1.0f, 1.0f}},
                {{ -0.5f, -0.5f, -0.5f},  {0.0f, 1.0f}},
                {{ -0.5f, -0.5f, -0.5f}, { 0.0f, 1.0f}},
                {{ -0.5f, -0.5f,  0.5f},  {0.0f, 0.0f}},
                {{ -0.5f,  0.5f,  0.5f}, { 1.0f, 0.0f}},

                {{ 0.5f,  0.5f,  0.5f},  {1.0f, 0.0f}},
                {{0.5f,  0.5f, -0.5f},  {1.0f, 1.0f}},
                {{ 0.5f, -0.5f, -0.5f},  {0.0f, 1.0f}},
                {{ 0.5f, -0.5f, -0.5f},  {0.0f, 1.0f}},
                {{0.5f, -0.5f,  0.5f},  {0.0f, 0.0f}},
                {{ 0.5f,  0.5f,  0.5f},  {1.0f, 0.0f}},

                {{-0.5f, -0.5f, -0.5f},  {0.0f, 1.0f}},
                {{ 0.5f, -0.5f, -0.5f},  {1.0f, 1.0f}},
                {{ 0.5f, -0.5f,  0.5f},  {1.0f, 0.0f}},
                {{ 0.5f, -0.5f,  0.5f},  {1.0f, 0.0f}},
                {{ -0.5f, -0.5f,  0.5f},  {0.0f, 0.0f}},
                {{ -0.5f, -0.5f, -0.5f},  {0.0f, 1.0f}},

                {{-0.5f,  0.5f, -0.5f},  {0.0f, 1.0f}},
                {{0.5f,  0.5f, -0.5f},  {1.0f, 1.0f}},
                {{ 0.5f,  0.5f,  0.5f},  {1.0f, 0.0f}},
                {{ 0.5f,  0.5f,  0.5f},  {1.0f, 0.0f}},
                {{-0.5f,  0.5f,  0.5f},  {0.0f, 0.0f}},
                {{-0.5f,  0.5f, -0.5f},  {0.0f, 1.0f}}
            };
            
            
            
            
            
            _vertices = [_device newBufferWithBytes:data length:sizeof(data) options:MTLResourceStorageModeShared];
            _vertices.label = @"vertices";
            
            //pipeline state
            MTLRenderPipelineDescriptor *pipelineDesc = [MTLRenderPipelineDescriptor new];
            pipelineDesc.vertexFunction = vs;
            pipelineDesc.fragmentFunction = fs;
            pipelineDesc.colorAttachments[0].pixelFormat = format;
            pipelineDesc.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
            
            NSError *error;
            _state = [_device newRenderPipelineStateWithDescriptor:pipelineDesc error:&error];
            
            MTLDepthStencilDescriptor* dsDesc = [MTLDepthStencilDescriptor new];
            dsDesc.depthCompareFunction = MTLCompareFunctionLess;
            dsDesc.depthWriteEnabled = YES;
            _dsState = [_device newDepthStencilStateWithDescriptor:dsDesc];
            
        }
        
    }
    return self;
}

- (id<MTLTexture>)createDepthStencilTextureWithWidth:  (size_t)width
                                          height: (size_t)height {
    
    MTLTextureDescriptor *texDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat: MTLPixelFormatDepth32Float width: width height: height mipmapped: false];
    texDescriptor.usage = MTLTextureUsageRenderTarget;
    texDescriptor.storageMode = MTLStorageModePrivate;
    
    id<MTLTexture> texture = [_device newTextureWithDescriptor: texDescriptor];
    
    return texture;
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
//    drawable.texture.pixelFormat;
    id<MTLRenderCommandEncoder> encoder = [cb renderCommandEncoderWithDescriptor:_renderPassdesc];
    if (encoder)
    {
        
        /*  右手坐标系
                                    y
                                    |
                                    |
                                    |_______x   
                                    /
                                   /
                                  /
                                 z
         左手坐标系
                                     y   z
                                     |  /
                                     | /
                                     |/_______x
         
         
         */
        
        static const vector_float3 cubePositions[] = {
            { 0.0f,  0.0f,  0.0f},
            { 2.0f,  5.0f, -15.0f},
            {-1.5f, -2.2f, -2.5f},
            {-3.8f, -2.0f, -12.3f},
            { 2.4f, -0.4f, -3.5f},
            {-1.7f,  3.0f, -7.5f},
            { 1.3f, -2.0f, -2.5f},
            { 1.5f,  2.0f, -2.5f},
            { -0.5f,  0.2f, -1.5f},
            {-1.f,   1.0f, -1.5f}
            };
        
        matrix_float4x4 model = matrix_identity_float4x4;//matrix4x4_rotation(_frameNum * (M_PI / 180.), 0., 0., 1.);
        
        matrix_float4x4 view = matrix_look_at_right_hand(sin(_frameNum* 0.01) * 4 ,0 , cos(_frameNum*0.01) * 4, 0.,0.,0., 0.,1.,0.);//matrix4x4_translation(0., 0., -3.); //按照右手坐标系，要远离z=0的平面
//        model.columns[1].y = 720./1280.;
        
        matrix_float4x4 projection = matrix_perspective_right_hand(60.0f * (M_PI / 180.0f), drawable.texture.width/(CGFloat)drawable.texture.height, 0.1, 5000.0);
        
        [encoder setDepthStencilState:_dsState];
        [encoder setRenderPipelineState:_state];
        
        [encoder setVertexBuffer:_vertices offset:0 atIndex:0];
        [encoder setFragmentTexture:_texture atIndex:0];
//        [encoder setdepth];
        
        float scale = 1.;//0.5 + (1.0 + 0.5 * sin(_frameNum * 0.1));;
        [encoder setVertexBytes:&scale length:sizeof(scale) atIndex:1];
        
        for (int i = 0; i < 10; ++i)
        {
            model = matrix4x4_translation(cubePositions[i]);
            model = matrix_multiply(model, matrix4x4_rotation(i * 0.2, 1., 1., 1.));
            model = matrix_multiply(view, model);
            model = matrix_multiply(projection, model);
            [encoder setVertexBytes:&model length:sizeof(model) atIndex:2];
            [encoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:36];
        }
        

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
