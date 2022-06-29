//
//  ViewController.m
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/6/27.
//

#import "ViewController.h"
#import "MTLRenderer.h"

@interface ViewController ()<MTKViewDelegate>

@end

@implementation ViewController
{
    MTKView *_view;
    MTLRenderer* _renderer;
}

- (void)loadView
{
    [self loadMTKView];
}

- (void)loadMTKView
{
    self.view = [[MTKView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

- (void)loadRenderView
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self basicMTKViewRenderer];
}

- (void)basicRenderViewRenderer
{
    
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


- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    NSLog(@"mtlView drawableSizeWillChange...");
    [_renderer mtkView:view resize:size];
}


- (void)drawInMTKView:(nonnull MTKView *)view {
//    NSLog(@"drawInMTKView...");
    [_renderer render:view];
}


@end
