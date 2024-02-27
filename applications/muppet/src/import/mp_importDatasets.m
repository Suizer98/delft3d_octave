function DataProperties=mp_importDatasets(DataProperties,noset)

for j=1:noset
    switch lower(DataProperties(j).FileType),
        case {'delft3d','delwaq'}
            DataProperties=ImportD3D(DataProperties,j);
        case {'tekaltime'}
            DataProperties=ImportTekalTime(DataProperties,j);
        case {'tekaltimestack'}
            DataProperties=ImportTekalTimeStack(DataProperties,j);
        case {'annotation'}
            DataProperties=ImportAnnotation(DataProperties,j);
        case {'d3dmonitoring'}
            DataProperties=ImportD3DMonitoring(DataProperties,j);
        case {'tekalxy'}
            DataProperties=ImportTekalXY(DataProperties,j);
        case {'tekalmap'}
            DataProperties=ImportTekalMap(DataProperties,j);
        case {'tekalvector'}
            DataProperties=ImportTekalVector(DataProperties,j);
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
        case {'bar'}
            DataProperties=ImportBar(DataProperties,j);
        case {'trianaa'}
            DataProperties=ImportTrianaA(DataProperties,j);
        case {'trianab'}
            DataProperties=ImportTrianaB(DataProperties,j);
        case {'xbeach'}
            DataProperties=ImportXBeach(DataProperties,j);
        case {'ucitxyz'}
            DataProperties=ImportUCITxyz(DataProperties,j);
        case {'unibest','durosta'}
            DataProperties=ImportUnibest(DataProperties,j);
        case {'d3dboundaryconditions'}
            DataProperties=ImportD3DBoundaryConditions(DataProperties,j);
        case {'unibestcl'}
            DataProperties=ImportUnibestCL(DataProperties,j);
        case {'hirlam'}
            DataProperties=ImportHIRLAM(DataProperties,j);
        case {'d3dmeteo'}
            DataProperties=ImportD3DMeteo(DataProperties,j);
        case {'simonasds'}
            DataProperties=ImportSimonaSDS(DataProperties,j);
        case {'mat'}
            DataProperties=ImportMAT(DataProperties,j);
        case {'tekalhistogram'}
            DataProperties=mp_importTekalHistogram(DataProperties,j);
    end
    if strcmpi(DataProperties(j).Type,'timeseries')
        DataProperties(j).x=DataProperties(j).x+DataProperties(j).TimeZone/24;
    end
end
