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
#include <vector>


class ObjParser
{
public:
    class ObjData
    {
    public:
        ObjData() = default;
        ObjData(size_t vLen, size_t iLen)
        {
            vertices.resize(vLen);
            indices.resize(iLen);
        }
        ~ObjData()
        {
        }
        std::vector<float> vertices;
        std::vector<int> indices;
    };
    
    static ObjData ParseObj(const std::string& file);
};

#endif /* ObjParser_hpp */
