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
    out.pos = {0.};
    out.pos.xy = vertices[vId].pos;
    
    out.color = vertices[vId].color;
    return out;
}

fragment float4 fmain(RasterData in [[stage_in]])
{
    return {1.,0.,0.,1.};//in.color;
}



