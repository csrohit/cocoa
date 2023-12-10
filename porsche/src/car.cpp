
#include "car.h"
#include "glm.h"
#include <cstdlib>

GLMmodel *pCar = nullptr;

void initializeCar()
{
    pCar = glmReadOBJ("porsche.obj");
    if (nullptr == pCar)
    {
    }
    glmUnitize(pCar);
    glmFacetNormals(pCar);
    glmVertexNormals(pCar, 90.0f);
}

void updateCar()
{
}

void displayCar()
{
    glmDraw(pCar, GLM_SMOOTH);
}

void freeCar()
{
    if (nullptr != pCar)
    {
        free(pCar);
        pCar = nullptr;
    }
}
