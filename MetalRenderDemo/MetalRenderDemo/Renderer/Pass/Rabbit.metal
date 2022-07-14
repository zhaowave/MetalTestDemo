//
//  Rabbit.metal
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/7/11.
//

#include <metal_stdlib>
#include "../SharedTypes.h"
using namespace metal;



vertex float4 rabbit_vs(uint vId [[vertex_id]], constant float4* vertices [[buffer(0)]], constant matrix_float4x4& mvp [[buffer(1)]])
{
    float4 pos = float4(vertices[vId]);
    return mvp * pos;
}

fragment float4 rabbit_fs()
{
    return float4(0.5,0.5,0.5,1.);
}


