#include "load.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// int main()
// {
//     struct Model *pModel = NULL;
//     int           rc     = loadModel("cube.obj", &pModel);
//     if (rc != 0)
//     {
//         fprintf(stderr, "failed to load model\n");
//         return (-1);
//     }
//
//     printModel(pModel);
//
//     unloadModel(pModel);
//
//     return (0);
// }
//

void printModel(struct Model *pModel)
{
    for (uint32_t idx = 0; idx < pModel->nVertices; ++idx)
    {
        printf("Vertex %d: [%f %f %f]\n", idx, (pModel->pVertices + idx)->x, (pModel->pVertices + idx)->y, (pModel->pVertices + idx)->z);
    }
    for (uint32_t idx = 0; idx < pModel->nNormals; ++idx)
    {
        printf("Normal %d: [%f %f %f]\n", idx, (pModel->pNormals + idx)->x, (pModel->pNormals + idx)->y, (pModel->pNormals + idx)->z);
    }
    for (uint32_t idx = 0; idx < pModel->nTexels; ++idx)
    {
        printf("Texel %d: [%f %f]\n", idx, (pModel->pTexels + idx)->u, (pModel->pTexels + idx)->v);
    }
    printf("nFaces: %u\n", pModel->nFaces);
    for (uint32_t idx = 0U; idx < pModel->nFaces; ++idx)
    {
        struct Face *pFace = pModel->pFaces + idx;
        for (uint32_t jdx = 0U; jdx < 3; ++jdx)
        {
            printf("Face[%u][%u] - [%u %u %u]\n", idx, jdx, pFace->vIndices[jdx], pFace->tIndices[jdx], pFace->nIndices[jdx]);
        }
    }

    printf("nGroups: %u\n", pModel->nGroups);
    struct Group *pGroup = pModel->pGroups;
    while (NULL != pGroup)
    {
        printf("Group: %s\n", pGroup->name);

        for (uint32_t fdx = 0U; fdx < pGroup->nFaces; ++fdx)
        {
            struct Face *pFace = pModel->pFaces + pGroup->piFaces[fdx];
            for (uint32_t jdx = 0U; jdx < 3; ++jdx)
            {
                printf("Face[%u][%u] - [%u %u %u]\n", fdx, jdx, pFace->vIndices[jdx], pFace->tIndices[jdx], pFace->nIndices[jdx]);
            }
        }
        pGroup = pGroup->next;
    }
}

/**
 * @brief Find group with matching name
 *
 * @param pModel [in] - Pointer to model
 * @param name   [in] - name of model
 *
 * @returns pointer to group else NULL
 */
struct Group *findGroup(struct Model *pModel, char *name)
{
    struct Group *pGroup = pModel->pGroups;

    while (NULL != pGroup)
    {
        if (0 == strcmp(pGroup->name, name))
        {
            break;
        }
        pGroup = pGroup->next;
    }
    return pGroup;
}

struct Group *addGroup(struct Model *pModel, char *name)
{
    struct Group *pGroup = findGroup(pModel, name);
    if (NULL == pGroup)
    {
        pGroup            = (struct Group *)malloc(sizeof(Group));
        pGroup->name      = strdup(name);
        pGroup->nFaces    = 0U;
        pGroup->piFaces   = NULL;
        pGroup->iMaterial = -1;
        pGroup->next      = pModel->pGroups;
        pModel->pGroups   = pGroup;
        ++pModel->nGroups;
    }

    return pGroup;
}

int loadModel(char *filename, struct Model **ppModel)
{
    char     buff[128];
    FILE    *pFile     = NULL;
    uint32_t nVertices = 0;
    uint32_t nNormals  = 0;
    uint32_t nTexels   = 0;
    uint32_t nFaces    = 0; // face => triangle

    uint32_t         vIdx        = 0;
    uint32_t         nIdx        = 0;
    uint32_t         tIdx        = 0;
    uint32_t         gIdx        = 0;
    uint32_t         fgIdx       = 0;
    uint32_t         fIdx        = 0; // face => triangle index
    struct Position *pVertNormal = NULL;
    struct Texel    *pTex        = NULL;
    struct Group    *pGroup      = NULL;
    struct Model    *pModel      = NULL;

    pFile = fopen(filename, "r");
    if (NULL == pFile)
    {
        fprintf(stderr, "Failed to open model \"%s\"\n", filename);
        return (-1);
    }
    pModel = (struct Model *)malloc(sizeof(struct Model));

    pGroup = addGroup(pModel, "default"); // add a default group

    /* Calculate nVertices, nNormals */
    while (EOF != fscanf(pFile, "%s", buff))
    {
        switch (buff[0])
        {
            case 'o':
            {
                fgets(buff, sizeof(buff), pFile);
                sscanf(buff, "%s", buff);
                break;
            }
            case 'm':
            {
                fscanf(pFile, "%s", buff);
                processMaterialFile(buff, pModel);
                break;
            }
            case 'g':
            {
                /* read group name and add it to model */
                fscanf(pFile, "%s", buff);
                pGroup = addGroup(pModel, buff);
                break;
            }
            case 'f':
            {
                int v, n, t;
                fscanf(pFile, "%s", buff);
                if (strstr(buff, "//"))
                {
                    /* format: v//n - No text coordinates */
                    fscanf(pFile, "%d//%d", &v, &n);
                    fscanf(pFile, "%d//%d", &v, &n);
                    ++nFaces;
                    ++pGroup->nFaces;
                    while (fscanf(pFile, "%d//%d", &v, &n) > 0)
                    {
                        ++nFaces;
                        ++pGroup->nFaces;
                    }
                }
                else if (3 == sscanf(buff, "%d/%d/%d", &v, &t, &n))
                {
                    fscanf(pFile, "%d/%d/%d", &v, &t, &n);
                    fscanf(pFile, "%d/%d/%d", &v, &t, &n);
                    ++nFaces;
                    ++pGroup->nFaces;
                    while (fscanf(pFile, "%d/%d/%d", &v, &t, &n) > 0)
                    {
                        ++nFaces;
                        ++pGroup->nFaces;
                    }
                }
                break;
            }
            case 'v':
            {
                switch (buff[1])
                {
                    case '\0':
                    {
                        ++nVertices;
                        break;
                    }
                    case 'n':
                    {
                        ++nNormals;
                        break;
                    }
                    case 't':
                    {
                        ++nTexels;
                        break;
                    }
                }
                fgets(buff, sizeof(buff), pFile);
                break;
            }
            case '#':
            {
                // comment
            }
            default:
            {
                // read and dump content
                fgets(buff, sizeof(buff), pFile);
                break;
            }
        }
    }
    (void)fseek(pFile, 0L, SEEK_SET);
    pModel->pVertices = (struct Position *)malloc(sizeof(struct Position) * nVertices);
    pModel->pNormals  = (struct Position *)malloc(sizeof(struct Position) * nNormals);
    pModel->pTexels   = (struct Texel *)malloc(sizeof(struct Texel) * nTexels);
    pModel->pFaces    = (struct Face *)malloc(sizeof(struct Face) * nFaces);
    pModel->nVertices = nVertices;
    pModel->nNormals  = nNormals;
    pModel->nTexels   = nTexels;
    pModel->nFaces    = nFaces;

    /* Load vertices data */
    while (EOF != fscanf(pFile, "%s", buff))
    {
        switch (buff[0])
        {
            case 'm':
            {
                fgets(buff, sizeof(buff), pFile);
                sscanf(buff, "%s", buff);
                break;
            }
            case 'g':
            {
                fgets(buff, sizeof(buff), pFile);
                sscanf(buff, "%s", buff);
                pGroup          = findGroup(pModel, buff);
                pGroup->piFaces = (uint32_t *)malloc(sizeof(uint32_t) * pGroup->nFaces);
                fgIdx           = 0U;
                break;
            }
            case 'u':
            {
                fgets(buff, sizeof(buff), pFile);
                sscanf(buff, "%s", buff);
                pGroup->iMaterial = findMaterial(pModel, buff);
                break;
            }
            case 'f':
            {
                int v = 0;
                int t = 0;
                int n = 0;
                fscanf(pFile, "%s", buff); // not reading entire line, only reading first word
                struct Face *pFace = pModel->pFaces + fIdx;
                if (strstr(buff, "//"))
                {
                    /* format: v//n - No text coordinates */
                    sscanf(buff, "%d//%d", &v, &n);
                    pFace->vIndices[0] = v - 1;
                    pFace->nIndices[0] = n - 1;
                    fscanf(pFile, "%d//%d", &v, &n);
                    pFace->vIndices[1] = v - 1;
                    pFace->nIndices[1] = n - 1;
                    fscanf(pFile, "%d//%d", &v, &n);
                    pFace->vIndices[2]     = v - 1;
                    pFace->nIndices[2]     = n - 1;
                    pGroup->piFaces[fgIdx] = fIdx;
                    ++fgIdx;
                    ++fIdx;

                    /* This block will be executed for polygon */
                    while (0 < fscanf(pFile, "%d//%d", &v, &n))
                    {
                        struct Face *newFace   = pModel->pFaces + fIdx;
                        newFace->vIndices[0]   = pFace->vIndices[0];
                        newFace->nIndices[0]   = pFace->nIndices[0];
                        newFace->vIndices[1]   = pFace->vIndices[2];
                        newFace->nIndices[1]   = pFace->nIndices[2];
                        newFace->vIndices[2]   = v - 1;
                        newFace->nIndices[2]   = n - 1;
                        pGroup->piFaces[fgIdx] = fIdx;
                        ++fgIdx;
                        ++fIdx;
                    }
                }
                else if (3 == sscanf(buff, "%d/%d/%d", &v, &t, &n))
                {
                    pFace->vIndices[0] = v - 1;
                    pFace->tIndices[0] = t - 1;
                    pFace->nIndices[0] = n - 1;
                    fscanf(pFile, "%d/%d/%d", &v, &t, &n);
                    pFace->vIndices[1] = v - 1;
                    pFace->tIndices[1] = t - 1;
                    pFace->nIndices[1] = n - 1;
                    fscanf(pFile, "%d/%d/%d", &v, &t, &n);
                    pFace->vIndices[2]     = v - 1;
                    pFace->tIndices[2]     = t - 1;
                    pFace->nIndices[2]     = n - 1;
                    pGroup->piFaces[fgIdx] = fIdx;
                    ++fgIdx;
                    ++fIdx;

                    /* This block will be executed for polygon */
                    while (0 < fscanf(pFile, "%d/%d/%d", &v, &t, &n))
                    {
                        struct Face *newFace   = pModel->pFaces + fIdx;
                        newFace->vIndices[0]   = pFace->vIndices[0];
                        newFace->tIndices[0]   = pFace->tIndices[0];
                        newFace->nIndices[0]   = pFace->nIndices[0];
                        newFace->vIndices[1]   = pFace->vIndices[2];
                        newFace->tIndices[1]   = pFace->tIndices[2];
                        newFace->nIndices[1]   = pFace->nIndices[2];
                        newFace->vIndices[2]   = v - 1;
                        newFace->nIndices[2]   = n - 1;
                        newFace->tIndices[2]   = t - 1;
                        pGroup->piFaces[fgIdx] = fIdx;
                        ++fgIdx;
                        ++fIdx;
                    }
                }
                /* TODO: add support for more index format
                 * 1. %d/%d
                 * 2. %d
                 * 3. %d/%d/%d
                 */
                break;
            }
            case 'v':
            {
                switch (buff[1])
                {
                    case '\0':
                    {
                        pVertNormal = pModel->pVertices + vIdx;
                        fgets(buff, sizeof(buff), pFile);
                        sscanf(buff, "%f %f %f", &pVertNormal->x, &pVertNormal->y, &pVertNormal->z);
                        ++vIdx;
                        break;
                    }
                    case 'n':
                    {
                        pVertNormal = pModel->pNormals + nIdx;
                        fgets(buff, sizeof(buff), pFile);
                        sscanf(buff, "%f %f %f", &pVertNormal->x, &pVertNormal->y, &pVertNormal->z);
                        ++nIdx;
                        break;
                    }
                    case 't':
                    {
                        pTex = pModel->pTexels + tIdx;
                        fgets(buff, sizeof(buff), pFile);
                        sscanf(buff, "%f %f", &pTex->u, &pTex->v);
                        ++tIdx;
                        break;
                    }
                }
                break;
            }
            case '#':
            {
                // comment
            }
            default:
            {
                // read and dump content
                fgets(buff, sizeof(buff), pFile);
                break;
            }
        }
    }
    *ppModel = pModel;
    fclose(pFile);
    return (0);
}

void unloadModel(struct Model *pModel)
{
    struct Group *pGroup = pModel->pGroups;
    while (NULL != pGroup)
    {
        if (NULL != pGroup->name)
        {
            free(pGroup->name);
        }
        if (NULL != pGroup->piFaces)
        {
            free(pGroup->piFaces);
        }
        pModel->pGroups = pGroup->next;
        free(pGroup);
        pGroup = pModel->pGroups;
    }

    if (NULL != pModel->pFaces)
    {
        free(pModel->pFaces);
    }

    if (NULL != pModel->pVertices)
    {
        free(pModel->pVertices);
    }
    if (NULL != pModel->pNormals)
    {
        free(pModel->pNormals);
    }
    if (NULL != pModel->pTexels)
    {
        free(pModel->pTexels);
    }

    deleteMaterials(pModel->pMaterials, pModel->nMaterials);
    free(pModel);
}

int processMaterialFile(char *filename, struct Model *pModel)
{
    char             buff[128];
    int32_t          nMaterials = 0;
    struct Material *pMaterial  = NULL;
    struct Material *pMaterials = NULL;
    int32_t          idx        = 0U;
    FILE            *pFile      = NULL;

    pFile = fopen(filename, "r");
    if (NULL == pFile)
    {
        fprintf(stderr, "Failed to read material file \"%s\"\n", filename);
        return (-1);
    }

    while (EOF != fscanf(pFile, "%s", buff))
    {
        switch (buff[0])
        {
            case 'n': /* newmtl */
                fgets(buff, sizeof(buff), pFile);
                ++nMaterials;
                sscanf(buff, "%s %s", buff, buff);
                break;
            case '#':
            {
                // comment
                // line is read and content is discarded
            }
            default:
                /* eat up rest of line */
                fgets(buff, sizeof(buff), pFile);
                break;
        }
    }
    pModel->nMaterials = nMaterials;
    pMaterials         = (struct Material *)malloc(sizeof(struct Material) * nMaterials);

    /* reset to beginning of file */
    (void)fseek(pFile, 0L, SEEK_SET);

    /* set the default material */
    for (idx = 0; idx < nMaterials; idx++)
    {
        pMaterial               = pMaterials + idx;
        pMaterial->name         = NULL;
        pMaterial->shininess    = 65.0f;
        pMaterial->rDiffuse[0]  = 0.8f;
        pMaterial->rDiffuse[1]  = 0.8f;
        pMaterial->rDiffuse[2]  = 0.8f;
        pMaterial->rDiffuse[3]  = 1.0f;
        pMaterial->rAmbient[0]  = 0.2f;
        pMaterial->rAmbient[1]  = 0.2f;
        pMaterial->rAmbient[2]  = 0.2f;
        pMaterial->rAmbient[3]  = 1.0f;
        pMaterial->rSpecular[0] = 0.0f;
        pMaterial->rSpecular[1] = 0.0f;
        pMaterial->rSpecular[2] = 0.0f;
        pMaterial->rSpecular[3] = 1.0f;
        pMaterial->emmission[0] = 0.0f;
        pMaterial->emmission[1] = 0.0f;
        pMaterial->emmission[2] = 0.0f;
        pMaterial->emmission[3] = 1.0f;
    }
    idx = -1;

    while (EOF != fscanf(pFile, "%s", buff))
    {
        switch (buff[0])
        {
            case 'n': /* newmtl */
                ++idx;
                pMaterial = pMaterials + idx;
                fgets(buff, sizeof(buff), pFile);
                sscanf(buff, "%s %s", buff, buff);
                pMaterial->name = strdup(buff);
                break;
            case 'N':
            {
                if ('s' == buff[1])
                {
                    // shininess - focus of secular hightlight
                    fgets(buff, sizeof(buff), pFile);
                    sscanf(buff, "%f", &pMaterial->shininess);
                    pMaterial->shininess /= 1000.0f;
                    pMaterial->shininess *= 128.0f;
                }
                else if ('i' == buff[1])
                {
                    // optical density - refrative index
                    fgets(buff, sizeof(buff), pFile);
                    sscanf(buff, "%f", &pMaterial->opeticalDensity);
                }
                else
                {
                    fprintf(stderr, "Unknown command: \"%s\"\n", buff);
                }

                break;
            }
            case 'K':
            {
                switch (buff[1])
                {
                    case 'a':
                    {
                        fgets(buff, sizeof(buff), pFile);
                        sscanf(buff, "%f %f %f", pMaterial->rAmbient, pMaterial->rAmbient + 1, pMaterial->rAmbient + 2);
                        break;
                    }
                    case 's':
                    {
                        fgets(buff, sizeof(buff), pFile);
                        sscanf(buff, "%f %f %f", pMaterial->rSpecular, pMaterial->rSpecular + 1, pMaterial->rSpecular + 2);
                        break;
                    }
                    case 'd':
                    {
                        fgets(buff, sizeof(buff), pFile);
                        sscanf(buff, "%f %f %f", pMaterial->rDiffuse, pMaterial->rDiffuse + 1, pMaterial->rDiffuse + 2);
                        break;
                    }
                    case 'e':
                    {
                        fgets(buff, sizeof(buff), pFile);
                        sscanf(buff, "%f %f %f", pMaterial->emmission, pMaterial->emmission + 1, pMaterial->emmission + 2);
                        break;
                    }
                    default:
                    {
                        fprintf(stdout, "Unknown command \"%s\"\n", buff);
                        break;
                    }
                }
                break;
            }
            case 'd': // dissolve factor
            {
                fgets(buff, sizeof(buff), pFile);
                sscanf(buff, "%f", &pMaterial->dissolveFactor);
                break;
            }
            case 'i':
            {
                fgets(buff, sizeof(buff), pFile);
                sscanf(buff, "%u", &pMaterial->illuminationModel);
                break;
            }
            case '#':
            {
                // comment
                // line is read and content is discarded
            }
            default:
                /* eat up rest of line */
                fgets(buff, sizeof(buff), pFile);
                break;
        }
    }
    pModel->pMaterials = pMaterials;
    fclose(pFile);
    return (0);
}
void printMaterial(struct Material *pMaterial)
{
    fprintf(stdout, "Name: %s\n", pMaterial->name);
    fprintf(stdout, "Shininess: %f\n", pMaterial->shininess);
    fprintf(stdout, "Refractive Index: %f\n", pMaterial->opeticalDensity);
    fprintf(stdout, "Dissolve factor: %f\n", pMaterial->dissolveFactor);
    fprintf(stdout, "Texture file: %s\n", pMaterial->texturePath);
    fprintf(stdout, "Illumination model: %u\n", pMaterial->illuminationModel);
    fprintf(stdout, "Ambient: [%.2f %.2f %.2f %.2f]\n", pMaterial->rAmbient[0], pMaterial->rAmbient[1], pMaterial->rAmbient[2],
            pMaterial->rAmbient[3]);
    fprintf(stdout, "Diffuse: [%.2f %.2f %.2f %.2f]\n", pMaterial->rDiffuse[0], pMaterial->rDiffuse[1], pMaterial->rDiffuse[2],
            pMaterial->rDiffuse[3]);
    fprintf(stdout, "Specular: [%.2f %.2f %.2f %.2f]\n", pMaterial->rSpecular[0], pMaterial->rSpecular[1], pMaterial->rSpecular[2],
            pMaterial->rSpecular[3]);
    fprintf(stdout, "Emission: [%.2f %.2f %.2f %.2f]\n", pMaterial->emmission[0], pMaterial->emmission[1], pMaterial->emmission[2],
            pMaterial->emmission[3]);
    fprintf(stdout, "\n");
}

static int findMaterial(struct Model *pModel, char *name)
{
    if (NULL != pModel->pMaterials)
    {
        struct Material *pMaterial = NULL;
        for (uint32_t idx = 0U; idx < pModel->nMaterials; ++idx)
        {
            pMaterial = pModel->pMaterials + idx;
            if (0 == strcmp(pMaterial->name, name))
            {
                return idx;
            }
        }
        fprintf(stderr, "Materials not loaded\n");
    }
    fprintf(stderr, "failed to find material \"%s\"\n", name);
    return (-1);
}

void deleteMaterials(struct Material *pMaterials, int nMaterials)
{
    if (NULL == pMaterials)
    {
        return;
    }
    struct Material *pMaterial;
    for (int32_t idx = 0U; idx < nMaterials; ++idx)
    {
        pMaterial = pMaterials + idx;
        if (NULL != pMaterial->name)
        {
            free(pMaterial->name);
        }
        if (NULL != pMaterial->texturePath)
        {
            free(pMaterial->texturePath);
        }
    }
    free(pMaterials);
    pMaterials = NULL;
}

//----
