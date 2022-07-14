//
//  Cube.metal
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/7/14.
//

#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;

vertex float4 cube_vs(uint vId [[vertex_id]],
                         constant float4* vertices [[buffer(0)]],
                         constant matrix_float4x4& mvp [[buffer(1)]])
{
    return mvp * vertices[vId];
}

fragment float4 cube_fs()
{
    return float4(1.,0.,0.,1.);
}

