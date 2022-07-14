//
//  triangle.metal
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/6/28.
//

#include <metal_stdlib>
#include "../SharedTypes.h"
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
                         constant VertexCube* vertices [[buffer(0)]],
                         constant float* scale [[buffer(1)]],
                         constant matrix_float4x4* mat [[buffer(2)]])
{
    RasterData out;
    out.coord = vertices[vId].texCoord.xy;

    out.pos = float4(vertices[vId].pos, 1.);

    out.pos = (*mat) * out.pos;
    
    out.color = float4(1.,1.,1.,1.);
//    out.color.xyz = vertices[vId].pos;
    return out;
}

fragment float4 fmain1(RasterData in [[stage_in]], texture2d<float> texture [[texture(0)]])
{
    constexpr sampler s(mag_filter::linear, min_filter::linear);
    const float4 color = texture.sample(s, in.coord);
    return color;
}



