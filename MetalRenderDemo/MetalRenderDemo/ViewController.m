//
//  ViewController.m
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/6/27.
//

#import "ViewController.h"
#import "MTLRenderer.h"
#import "RenderView/RenderView.h"
#import "MTLLayerRenderer.h"

@interface ViewController ()<MTKViewDelegate, RenderViewDelegate>

@end

const BOOL usingMtlLayer = YES;
#define FullScreenFrame [UIScreen mainScreen].bounds

@implementation ViewController
{
    MTKView *_view;
    MTLRenderer* _renderer;
    MTLLayerRenderer* _layerRenderer;
}

- (void)loadView
{
    if (usingMtlLayer)
    {
        [self loadRenderView];
    }
    else
    {
        [self loadMTKView];
    }
}

- (void)loadMTKView
{
    self.view = [[MTKView alloc] initWithFrame:FullScreenFrame];
}

- (void)loadRenderView
{
    self.view = [[RenderView alloc] initWithFrame:FullScreenFrame];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (usingMtlLayer)
    {
        [self basicRenderViewRenderer];
    }
    else
    {
        [self basicMTKViewRenderer];
    }
    
}

- (void)basicRenderViewRenderer
{
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    RenderView* view = (RenderView*)self.view;
    view.metalLayer.device = device;
    view.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
    view.delegate = self;
    
    _layerRenderer = [[MTLLayerRenderer alloc] initWithMTLDevice:device andPixelFormat:view.metalLayer.pixelFormat];
    
}

- (void)basicMTKViewRenderer
{
    _view = (MTKView*)self.view;
    _view.device = MTLCreateSystemDefaultDevice();
    _view.delegate = self;
    self.view.backgroundColor = [UIColor blueColor];
    _view.backgroundColor  = [UIColor redColor];
    _renderer = [[MTLRenderer alloc] initWithMTKView:_view];
    [_renderer mtkView:_view resize:_view.drawableSize];
}

- (void)resize:(CGSize)size
{
    if (_layerRenderer)
    {
        [_layerRenderer resize:size];
    }
}
- (void)renderToMTLLayer:(nonnull CAMetalLayer*)layer
{
    if (_layerRenderer)
    {
        [_layerRenderer renderToMetalLayer:layer];
    }
}


#pragma mark MTKViewDelegate
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    NSLog(@"mtlView drawableSizeWillChange...");
    [_renderer mtkView:view resize:size];
}


- (void)drawInMTKView:(nonnull MTKView *)view {
//    NSLog(@"drawInMTKView...");
    [_renderer render:view];
}


@end
