//
//  Rabbit.metal
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/7/11.
//

#include <metal_stdlib>
#include "../SharedTypes.h"
using namespace metal;

struct RastData {
    vector_float4 pos [[position]];
};

vertex RastData vertexShader(uint vId [[vertex_id]], constant VertexInfo* vertices [[buffer(0)]])
{
    RastData out ;
    out.pos = vector_float4(0.,0.,0.,1.);;
    out.pos.xyz = vertices[vId].pos;
    return out;
}

fragment vector_float4 fragmentShader()
{
    vector_float4 out(1.,1.,1.,1.);
    
    return out;
}


