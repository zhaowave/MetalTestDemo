//
//  RenderView.h
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/6/29.
//

#import <UIKit/UIKit.h>
@import MetalKit;
NS_ASSUME_NONNULL_BEGIN

@protocol RenderViewDelegate <NSObject>

- (void)resize:(CGSize)size;
- (void)renderToMTLLayer:(nonnull CAMetalLayer*)layer;

@end

@interface RenderView : UIView

@property (nonatomic, nonnull, readonly) CAMetalLayer *metalLayer;
@property(nonatomic, weak) id<RenderViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
