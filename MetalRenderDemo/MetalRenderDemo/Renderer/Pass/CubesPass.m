//
//  Cubes.m
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/7/13.
//

#import "CubesPass.h"
#import "AAPLMathUtilities.h"

@implementation CubesPass
{
    RenderContex* _context;
    id<MTLRenderPipelineState> _state;
    id<MTLDepthStencilState> _dsState;
    id<MTLBuffer> _vertices;
    id<MTLTexture> _texture;
    
    MTLRenderPassDescriptor* _renderPassdesc;
    
    vector_int2 _viewport;
    NSInteger _frameNum;
}

- (instancetype)initWithContext:(RenderContex*)context
{
    if (self = [super init]) {
        _frameNum = 0;
        _context = context;
        [[Renderer shared] setContext:_context];
        _renderPassdesc = [[Renderer shared] newRenderPassDescriptorWithTextureAndDepthAttachment:_context.size.width height:_context.size.height];
        [self loadTexture];

        _vertices = [_context.device newBufferWithBytes:data length:sizeof(data) options:MTLResourceStorageModeShared];
        _vertices.label = @"vertices";

        _state = [[Renderer shared] newStateWithShader:@"vmain1" andFsh:@"fmain1"];
        _dsState = [[Renderer shared] newDepthSetncilState];

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
    _frameNum++;
    id<MTLCommandBuffer> cb = _context.commandBuffer;
    
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
        

        
        matrix_float4x4 model = matrix_identity_float4x4;//matrix4x4_rotation(_frameNum * (M_PI / 180.), 0., 0., 1.);
        
        matrix_float4x4 view = matrix_look_at_right_hand(sin(_frameNum* 0.01) * 4 ,0 , cos(_frameNum*0.01) * 4, 0.,0.,0., 0.,1.,0.);//matrix4x4_translation(0., 0., -3.); //按照右手坐标系，要远离z=0的平面
        
        matrix_float4x4 projection = matrix_perspective_right_hand(60.0f * (M_PI / 180.0f), (float)_viewport.x/(float)_viewport.y, 0.1, 5000.0);
        
        [encoder setDepthStencilState:_dsState];
        [encoder setRenderPipelineState:_state];
        
        [encoder setVertexBuffer:_vertices offset:0 atIndex:0];
        [encoder setFragmentTexture:_texture atIndex:0];
        
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
    }
}


- (void)renderToTexture:(id<MTLTexture>)texture
{
    _renderPassdesc.colorAttachments[0].texture = texture;
    [self render];
}

- (void)loadTexture
{
    UIImage* image = [UIImage imageNamed:@"00-apple.png"];
    if (image != nil)
    {
        MTLTextureDescriptor* desc = [[MTLTextureDescriptor alloc] init];
        desc.width = image.size.width;
        desc.height = image.size.height;
        desc.pixelFormat = MTLPixelFormatRGBA8Unorm;
        
        _texture = [_context.device newTextureWithDescriptor:desc];
        MTLRegion region = {{0,0,0}, {(NSUInteger)image.size.width,(NSUInteger)image.size.height,1}};
        
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

- (id<MTLTexture>)targetTexture
{
    return _renderPassdesc.colorAttachments[0].texture;
}

@end
