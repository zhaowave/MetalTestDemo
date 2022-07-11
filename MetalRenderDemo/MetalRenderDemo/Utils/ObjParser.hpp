//
//  ObjParser.hpp
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/7/11.
//

#ifndef ObjParser_hpp
#define ObjParser_hpp

#include <stdio.h>
#include <string>


class ObjParser
{
public:
    class ObjData
    {
    public:
        ObjData() = default;
        ObjData(size_t vLen, size_t iLen)
        {
            vertices = new float[vLen * 3];
            indices = new int[iLen * 3];
        }
        ~ObjData()
        {
            free(vertices);
            free(indices);
        }
        float* vertices{nullptr};
        int* indices{nullptr};
    };
    
    static ObjData ParseObj(const std::string& file);
};

#endif /* ObjParser_hpp */
