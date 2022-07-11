//
//  SharedStruct.h
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/6/28.
//

#ifndef SharedTypes_h
#define SharedTypes_h
#include <simd/simd.h>

typedef struct
{
    vector_float2 pos;
    vector_float4 color;
}VertexData;

typedef struct
{
    vector_float3 pos;
    vector_float2 texCoord;
}VertexCube;

typedef struct
{
    vector_float3 pos;
}VertexInfo;



#endif /* SharedStruct_h */
