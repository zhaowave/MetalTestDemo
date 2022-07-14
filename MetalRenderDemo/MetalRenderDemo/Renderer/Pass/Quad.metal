//
//  Quad.metal
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/7/13.
//

#include <metal_stdlib>
using namespace metal;

struct QuadOut
{
    float4 pos [[position]];
    float2 textureCoordinate;
};

vertex QuadOut quad_vs(uint vertexId [[vertex_id]], constant float2* vertices [[buffer(0)]])
{
    QuadOut out;
    out.pos = float4(0.,0.,0.,1.);
    out.pos.xy = vertices[vertexId];
    out.textureCoordinate = out.pos.xy * 0.5 + 0.5;
    return out;
}
 
fragment float4 quad_fs(QuadOut in [[stage_in]], texture2d<float> texture [[texture(0)]])
{
    constexpr sampler s(mag_filter::linear, min_filter::linear);
    float4 color = texture.sample(s, in.textureCoordinate);
    return color;
}

