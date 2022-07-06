//
//  triangle.metal
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/6/28.
//

#include <metal_stdlib>
#include "SharedTypes.h"
using namespace metal;
struct RasterData
{
    float4 pos [[position]];
    float4 color;
    float2 coord;
};

vertex RasterData vmain(uint vId [[vertex_id]], constant VertexData* vertices [[buffer(0)]])
{
    RasterData out;
    out.pos = vector_float4(0.,0.,0.,1.);
    out.pos.xy = vertices[vId].pos;
    
    out.color = vertices[vId].color;
    return out;
}

fragment float4 fmain(RasterData in [[stage_in]])
{
    return in.color;
}

/*=======================================*/
vertex RasterData vmain1(uint vId [[vertex_id]],
                         constant VertexData* vertices [[buffer(0)]],
                         constant float* scale [[buffer(1)]],
                         constant matrix_float4x4* mat [[buffer(2)]])
{
    RasterData out;
    out.color = vertices[vId].color;
    float2 pos = vertices[vId].pos;
    out.coord = pos * 0.5 + 0.5;
    pos *= *scale;
    out.pos.xy =  pos;
    out.pos.z = 0.;
    out.pos.w = 1.;
    
    
//    out.pos.y = out.pos.y * 72./ 128.;
    out.pos = (*mat) * out.pos;
    
    return out;
}

fragment float4 fmain1(RasterData in [[stage_in]], texture2d<float> texture [[texture(0)]])
{
    constexpr sampler s(mag_filter::linear, min_filter::linear);
    const float4 color = texture.sample(s, in.coord);
    float4 ret = {1.,1.,1.,1.};
    ret.x = color.r;
    ret.y = color.g;
    ret.z = color.b;
    ret.w = color.a;
    return ret;
}



