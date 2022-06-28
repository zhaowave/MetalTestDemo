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

- (void)viewDidLoad {
    [super viewDidLoad];
    _view = (MTKView*)self.view;
    _view.device = MTLCreateSystemDefaultDevice();
    _view.delegate = self;
    _renderer = [[MTLRenderer alloc] initWithMTKView:_view];
    [_renderer mtkView:_view resize:_view.drawableSize];
    // Do any additional setup after loading the view.
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
