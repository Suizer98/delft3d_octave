function [ result ] = mpa_fillresultfromcsharp( morphAnResult )
%MPA_FILLRESULTFROMCSHARP Summary of this function goes here
%   Detailed explanation goes here

xInitial = double(morphAnResult.Input.InputProfile.XCoordinates)';
zInitial = double(morphAnResult.Input.InputProfile.ZCoordinates)';

%% Step 1
result = fillresultwithprofile(createEmptyDUROSResult,...
    morphAnResult.OutputDurosPreProfile,...
    morphAnResult.OutputDurosProfile,...
    xInitial,zInitial);

result.VTVinfo.Xr = morphAnResult.OutputPointRDuros.X;
result.VTVinfo.Zr = morphAnResult.OutputPointRDuros.Z;
result.VTVinfo.Xp = morphAnResult.OutputPointPDuros.X;
result.VTVinfo.Zp = morphAnResult.OutputPointPDuros.Z;
result.Volumes.Volume = morphAnResult.OutputTotalErosionVolume;%????
result.info.ID = 'MorphAn DUROS+';
result.info.iter = morphAnResult.OutputDurosNrIterations;
result.info.precision = morphAnResult.OutputDurosCalculationPrecision;
result.info.x0 = result.VTVinfo.Xp;

result.info.input = struct(...
    'D50', morphAnResult.Input.D50,...
    'WL_t', morphAnResult.Input.MaximumStormSurgeLevel,...
    'Hsig_t', morphAnResult.Input.SignificantWaveHeight,...
    'Tp_t', morphAnResult.Input.PeakPeriod,...
    'Bend', []); % morphAnInput.G0

%% Step 2 (Erosion above storm surge level)
result(end+1) = fillresultwithprofile(createEmptyDUROSResult,...
    morphAnResult.OutputAVolumePreProfile,...
    morphAnResult.OutputAVolumeProfile,...
    xInitial,zInitial);
result(end).VTVinfo.AVolume = morphAnResult.OutputErosionVolumeAboveStormSurgeLevel;
result(end).Volumes.Erosion = morphAnResult.OutputErosionVolumeAboveStormSurgeLevel;
result(end).Volumes.Accretion = 0;
result(end).Volumes.Volume = morphAnResult.OutputErosionVolumeAboveStormSurgeLevel;
result(end).info.ID = 'DUROS-plus Erosion above SSL';
result(end).info.resultinboundaries = true;

%% Step 3 (Erosion due to coastal bend)
if ~isempty(morphAnResult.OutputBendErosionProfile)
    result(end+1) = fillresultwithprofile(createEmptyDUROSResult,...
        morphAnResult.OutputBendErosionPreProfile,...
        morphAnResult.OutputBendErosionProfile,...
        xInitial,zInitial);

    result(end).VTVinfo.Xr = morphAnResult.OutputPointRBendErosion.X;
    result(end).VTVinfo.Zr = morphAnResult.OutputPointRBendErosion.Z;
    result(end).VTVinfo.Xp = morphAnResult.OutputPointPBendErosion.X;
    result(end).VTVinfo.Zp = morphAnResult.OutputPointPBendErosion.Z;
    result(end).VTVinfo.G = morphAnResult.OutputBendErosionVolume;
end

%% Step 4 (Additional erosion)
if ~isempty(morphAnResult.OutputAdditionalErosionProfile)
    result(end+1) = fillresultwithprofile(createEmptyDUROSResult,...
        morphAnResult.OutputAdditionalErosionPreProfile,...
        morphAnResult.OutputAdditionalErosionProfile,...
        xInitial,zInitial);
    
    result(end).VTVinfo.Xr = morphAnResult.OutputPointR.X;
    result(end).VTVinfo.Zr = morphAnResult.OutputPointR.Z;
    result(end).VTVinfo.Xp = morphAnResult.OutputPointP.X;
    result(end).VTVinfo.Zp = morphAnResult.OutputPointP.Z;
    result(end).VTVinfo.TVolume = morphAnResult.OutputAdditionalErosionVolume;
    result(end).Volumes.Erosion = morphAnResult.OutputAdditionalErosionVolume;
    result(end).Volumes.Volume = morphAnResult.OutputAdditionalErosionVolume;
    result(end).info.ID = 'Additional Erosion';
end

%% Step 5 (Boundary profile) - Not present in MorphAn calculation (needs seperate routine)
% result(end+1) = fillresultwithprofile(createEmptyDUROSResult,...
%     morphAnResult.OutputBoundaryPreProfile,...
%     morphAnResult.OutputBoundaryProfile,...
%     xInitial,zInitial);
% 
% result(end).Volumes.Volume = morphAnResult.OutputBoundaryProfileVolume;
% result(end).info.ID = 'Boundary Profile';

end

function result = fillresultwithprofile(result,morphAnPreProfile,morpAnProfile,xInitial,zInitial)
profile = crossshoreprofile2matlabprofile(morpAnProfile);
preProfile = crossshoreprofile2matlabprofile(morphAnPreProfile);

result.xActive = unique([profile(:,1);preProfile(:,1)]);
result.z2Active = interp1(profile(:,1),profile(:,2),result.xActive );
result.zActive = interp1(preProfile(:,1),preProfile(:,2),result.xActive );

result.xLand = xInitial(xInitial < min(result.xActive));
result.zLand = zInitial(xInitial < min(result.xActive));
result.xSea = xInitial(xInitial > max(result.xActive));
result.zSea = zInitial(xInitial > max(result.xActive));
end

function profile = crossshoreprofile2matlabprofile(morphAnProfile)
profile = [double(morphAnProfile.XCoordinates)',double(morphAnProfile.ZCoordinates)'];
end
