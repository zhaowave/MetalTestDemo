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
    _metalLayer.delegate = self;
    _dsplk = [CADisplayLink displayLinkWithTarget:self selector:@selector(render)];
    _dsplk.preferredFramesPerSecond = 60;
    _dsplk.paused = NO;
    [_dsplk addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
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

- (void)setPaused:(BOOL)paused
{
    _paused = paused;
    _dsplk.paused = paused;
}

#pragma mark - Resizing

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self resizeDrawable:self.window.screen.nativeScale];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self resizeDrawable:self.window.screen.nativeScale];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self resizeDrawable:self.window.screen.nativeScale];
}

- (void)setContentScaleFactor:(CGFloat)contentScaleFactor
{
    [super setContentScaleFactor:contentScaleFactor];
    [self resizeDrawable:self.window.screen.nativeScale];
}

- (void)render
{
    [_delegate renderToMTLLayer:_metalLayer];
}

#pragma mark CALayerDelegate

- (void)displayLayer:(CALayer *)layer
{
    [self render];
}

/* If defined, called by the default implementation of -drawInContext: */

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    [self render];
}


@end
