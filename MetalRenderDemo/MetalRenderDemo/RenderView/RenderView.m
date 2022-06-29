//
//  RenderView.m
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/6/29.
//

#import "RenderView.h"


@implementation RenderView
{
    CADisplayLink* _dsplk;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)dealloc
{
    [_dsplk invalidate];
}

+ (Class)layerClass
{
    return [CAMetalLayer class];
}



- (void)commonInit
{
    _metalLayer = (CAMetalLayer*)self.layer;
    
    _dsplk = [CADisplayLink displayLinkWithTarget:self selector:@selector(render)];
    _dsplk.preferredFramesPerSecond = 60;
    _dsplk.paused = NO;
}

- (void)resizeDrawable:(CGFloat)factor
{
    CGSize size = self.bounds.size;
    size.width = size.width * factor;
    size.height = size.height * factor;
    if (size.width <= 0 || size.height <= 0) {
        return;
    }
    
    [_metalLayer setDrawableSize:size];
    [_delegate resize:size];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self resizeDrawable:self.window.screen.nativeScale];
}

- (void)render
{
    [_delegate renderToMTLLayer:_metalLayer];
}


@end
