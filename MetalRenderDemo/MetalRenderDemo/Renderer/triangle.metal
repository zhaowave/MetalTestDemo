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
                         constant float* scale [[buffer(1)]])
{
    RasterData out;
    out.color = vertices[vId].color;
    float2 pos = vertices[vId].pos;
    pos *= *scale;
    out.pos.xy =  pos;
    out.pos.z = 0.;
    out.pos.w = 1.;
    return out;
}

fragment float4 fmain1(RasterData in [[stage_in]])
{
    return in.color;
}



