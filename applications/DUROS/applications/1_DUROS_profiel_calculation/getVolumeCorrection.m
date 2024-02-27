function [Volume, Volumechange, CorrectionApplied, DuneCorrected, x, z, z2] = getVolumeCorrection(x, z, z2, WL)
%GETVOLUMECORRECTION corrects found profiles for landward transport

%% initiate variables
CorrectionApplied = false;
DuneCorrected = false;
Volumechange = 0;

%% Determin crossings between two profiles
[xcr zcr, x, z, x, z2]= findCrossings(x,z,x,z2,'keeporiginalgrid');

%% get initial profile volumes
[volumes CumVolume] = getCumVolume(x,z,z2);
oldVolume = CumVolume(1);

%% find Correction boundaries
%{
most seaward point where landward transport occurs can be used as seaward 
boundary. The most landward erosional part should not be checked, whereas 
landward transport is not possible (either there is no sedimentation 
landward, or the part lies above the water leven. This is made sure in the 
beginning of the calculation). Consequently the sedimentation profile
par directly seaward to this point should also not be checked. The landward 
boundary is therefore located at the third crossing between the two 
profiles counted seaward. If the landward boundary lies seaward of the 
seaward boundary, a correction is not needed.
%}

% seaward boundary
SeawardBoundary = find(CumVolume<0, 1, 'last' );
SeawardBoundary(SeawardBoundary==length(CumVolume)) = [];

% landward boundary
if length(xcr)>=2
    if find(x==xcr(2),1) < length(volumes) && volumes(x==xcr(2)) < 0
        % Most landward part starts with accretion. This is the most seaward solution (without any
        % erosion above the waterline)
        LandWardBoundary = find(x==xcr(2),1,'first');
    else
        LandWardBoundary = find(volumes(find(x==xcr(2)):end)<0,1,'first') + find(x==xcr(2));
    end
    if isempty(LandWardBoundary)
        LandWardBoundary = length(x);
    end
else
    LandWardBoundary = length(x);
end

if isempty(SeawardBoundary) || LandWardBoundary >= SeawardBoundary
    Volume = oldVolume;
    return
end

%% plot intermediate results
if dbstate
    dbplotgetVolumeCorrection('init');
end

if SeawardBoundary < length(z)
    DuneCorrected = any(z(SeawardBoundary+1:end)>WL);
end

%% Walk through profile and correct
for ii = fliplr(LandWardBoundary:SeawardBoundary)
    % starting at most seaward location of landward transport and going
    % landward
    CurrentCellLWtransport = CumVolume(ii) < 0;
    SeasideNeighbouringCellLWtransport = CumVolume(ii+1) <= 0;
    SedNeededLandWards = x(ii)>min(xcr);
    CurrentCellAboveWL = z(ii)>WL;
    if CurrentCellLWtransport && SedNeededLandWards && CurrentCellAboveWL
        DuneCorrected = true;
    end
    if CurrentCellLWtransport && ~SeasideNeighbouringCellLWtransport && SedNeededLandWards
        x_old=x;
        VolumeStaysInCell = abs(volumes(ii)) - abs(CumVolume(ii));
        SeaPartVolume = 0.5*diff([z2(ii+1) z(ii+1)])*diff(x(ii:ii+1));
        SeawardVolumeFactor = SeaPartVolume / abs(volumes(ii));
        UsedVolumeFactor = VolumeStaysInCell / abs(volumes(ii));
        MajorPartofCellRequired = UsedVolumeFactor > SeawardVolumeFactor;
        if MajorPartofCellRequired
            x_new = x(ii) + (2 * (abs(volumes(ii)) - VolumeStaysInCell)) / diff([z2(ii) z(ii)]);
            z_new = interp1(x(ii:ii+1), z2(ii:ii+1), x_new);
            x = [x(1:ii); x_new; x(ii+1:end)];
            z2 = [z2(1:ii-1); z(ii); z_new; z2(ii+1:end)];
        else
            x_new = x(ii+1) - (2 * VolumeStaysInCell) / diff([z2(ii+1) z(ii+1)]);
            z_new = interp1(x(ii:ii+1), z(ii:ii+1), x_new);
            x = [x(1:ii); x_new; x(ii+1:end)];
            z2 = [z2(1:ii-1); z(ii); z_new; z2(ii+1:end)];
        end
        z = interp1(x_old, z, x);
    elseif CurrentCellLWtransport && SedNeededLandWards
        z2(ii) = z(ii);
    end
    [volumes CumVolume] = getCumVolume(x,z,z2);
    % plot added point / last iteration step
    if dbstate
        dbplotgetVolumeCorrection('update')
    end
end
Volume = CumVolume(1);
Volumechange = Volume - oldVolume;

if Volumechange ~= 0;
    CorrectionApplied = true;
end
if dbstate
    dbplotgetVolumeCorrection('finish');
end