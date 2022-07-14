//
//  ObjParser.cpp
//  MetalRenderDemo
//
//  Created by zhaowei on 2022/7/11.
//

#include "ObjParser.hpp"


ObjParser::ObjData ObjParser::ParseObj(const std::string& fileName)
{
    FILE* file = fopen(fileName.c_str(), "r");
    
//# OBJ file format with ext .obj
//# vertex count = 2503
//# face count = 4968
//    v -3.4101800e-003 1.3031957e-001 2.1754370e-002
//    v -8.1719160e-002 1.5250145e-001 2.9656090e-002
//    f 1069 1647 1578
//    f 1058 909 939
//    f 421 1176 238
//    f 1055 1101 1042
    char buf[100] = {0};
    fgets(buf, 100, file);
    size_t len = strlen(buf);
    buf[len-1] = '\0';
    if (strcmp(buf, "# OBJ file format with ext .obj") == 0)
    {
        printf("file %s is a obj file\n",fileName.c_str());
    }
    memset(buf, 0, 100);
    
    int vLen = 0;
    int iLen = 0;
    fscanf(file, "# vertex count = %d\n",&vLen);
    fscanf(file, "# face count = %d\n",&iLen);
    ObjData obj = ObjData(vLen*4,iLen*3);
    for (int i = 0; i < vLen; ++i)
    {
        fscanf(file, "v %f %f %f\n",&obj.vertices[i*4], &obj.vertices[i*4 + 1], &obj.vertices[i*4 + 2]);
        obj.vertices[i*4 + 3] = 1.;
    }
    for (int i = 0; i < iLen; ++i)
    {
        fscanf(file, "f %d %d %d\n",&obj.indices[i*3], &obj.indices[i*3 + 1], &obj.indices[i*3 + 2]);
//        printf("%d %d %d\n",obj.indices[i*3], obj.indices[i*3 + 1],obj.indices[i*3 + 2]);
    }
    fclose(file);
    return obj;
}
