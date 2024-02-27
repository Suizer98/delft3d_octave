function DataProperties=UpdateDatasets(DataProperties,DateTime,iblock,j)

%DataProperties(j).DateTime=DateTime;
%DataProperties(j).DateTime=0;
DataProperties(j).Block=iblock;

switch lower(DataProperties(j).FileType),
    case {'tekaltime'}
        DataProperties=ImportTekalTime(DataProperties,j);
    case {'annotation'}
        DataProperties=ImportAnnotation(DataProperties,j);
    case {'tekalxy'}
        DataProperties=ImportTekalXY(DataProperties,j);
    case {'tekalmap'}
        DataProperties=ImportTekalMap(DataProperties,j);
    case {'tekalvector'}
        DataProperties=ImportTekalVector(DataProperties,j);
    case {'delft3d','delwaq'}
        DataProperties=ImportD3D(DataProperties,j);
    case {'trim'}
        DataProperties=ImportD3DTrim(DataProperties,j);
    case {'wavm'}
        DataProperties=ImportWavm(DataProperties,j);
    case {'trih'}
        DataProperties=ImportTrih(DataProperties,j);
    case {'grid','d3dgrid','grd'}
        DataProperties=ImportD3DGrid(DataProperties,j);
    case {'d3ddepth'}
        DataProperties=ImportD3DDepth(DataProperties,j);
    case {'polyline','polygon','landboundary'}
        DataProperties=ImportLandboundary(DataProperties,j);
    case {'samples'}
        DataProperties=ImportSamples(DataProperties,j);
    case {'image'}
        DataProperties=ImportImage(DataProperties,j);
    case {'kubint'}
        DataProperties=ImportKubint(DataProperties,j);
    case {'lint'}
        DataProperties=ImportLint(DataProperties,j);
    case {'rose'}
        DataProperties=ImportRose(DataProperties,j);
    case {'curvedvectors'}
        DataProperties=ImportCurvedVectors(DataProperties,j);
    case {'xbeach'}
        DataProperties=ImportXBeach(DataProperties,j);
    case {'unibestcl'}
        DataProperties=ImportUnibestCL(DataProperties,j);
    case {'d3dmeteo'}
        DataProperties=ImportD3DMeteo(DataProperties,j);
    case {'simonasds'}
        DataProperties=ImportSimonaSDS(DataProperties,j);
    case {'mat'}
        DataProperties=ImportMAT(DataProperties,j);
end
