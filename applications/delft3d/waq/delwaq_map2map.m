%DELWAQ_MAP2MAP Interpolate one mapfile/lga to another mapfile/lga
%
%   STRUCTOUT = DELWAQ_MAP2MAP(FILE1,LGAFILE1, FILE2,LGAFILE2,SUBSTANCENAMES,TYPE)
%   Reads FILE1/LGAFILE1 and interpolate the data in FILE1 to the new grid LGAFILE2
%   the interpolated data is saved as FILE2.
%
%   STRUCTOUT = DELWAQ_MAP2MAP(...,SUBSTANCESNAME,...) specifies substances to
%   be used. SUBSTANCESNAME = 0 for all substances.
%
%   STRUCTOUT = DELWAQ_DIFF(...,TYPE) specifies alternate methods.
%   The default is 'linear'.  Available methods are:
% %
%      'nearest'  - nearest neighbor interpolation
%       'linear'  - bilinear interpolation
%       'spline'  - spline interpolation
%       'cubic'   - bicubic interpolation as long as the data is
%                   uniformly spaced, otherwise the same as 'spline'
%
%   See also: DELWAQ, DELWAQ_CONC, DELWAQ_RES, DELWAQ_TIME, DELWAQ_STAT,
%             DELWAQ_INTERSECT

%   Copyright 2015 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2015-Feb-18 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------
function delwaq_map2map(File1,lgaFile1,File2,lgaFile2,subs,Type)

% Opening Files
struct1 = delwaq('open',File1);
gridStruct1 = delwaq_xysegment(lgaFile1);
gridStruct2 = delwaq_xysegment(lgaFile2);

% Header
Header = struct1.Header;

% Setting time reference
T0 = struct1.T0;
refTime =  [T0 1];

% [0] if all substances 
if nargin<5
    subs = 0;
end

% Type of interpolation 
if nargin<6
    Type = 'nearest';
end

% Check if a vertical interpolation is nedeed
z1 = size(gridStruct1.Index,3);
z2 = size(gridStruct2.Index,3);
if z1~=z2
    interpLayers = 1;
else
    interpLayers = 0;
end

% Find substance
if subs==0
    substances = 1:length(struct1.SubsName);
else
    substances = find(strcmpi(struct1.SubsName,subs));
end

% Dimensions for grid1 and grid1 (x,y,z)
NoSegPerLayer = gridStruct1.NoSegPerLayer;
x1 = gridStruct1.cen.x;
y1 = gridStruct1.cen.y;

x2 = gridStruct2.cen.x;
y2 = gridStruct2.cen.y;

%%
for it = 1:struct1.NTimes
    
    disp([it struct1.NTimes])
    data = nan(length(substances),gridStruct2.NoSeg);
    
    for isub = 1:length(substances)
        [time, local1] = delwaq('read',struct1,substances(isub),0,it);
        local1 = reshape(local1,NoSegPerLayer,[]);
        localdata = [];
       
       % Interpolation to more layers
       if interpLayers           
            ns1 = NoSegPerLayer;
            nl1  = size(gridStruct1.Index,3);
            nl2 = size(gridStruct2.Index,3);
            [l1,s1] = meshgrid(1:nl1,1:ns1);
            [l2,s2] = meshgrid(linspace(1,nl1,nl2),1:ns1);            
            local1 = naninterp(s1,l1,local1,s2,l2,'linear');
        end
        
        for i=1:size(local1,2) 
            layer = local1(:,i);
            local2  = naninterp(x1,y1,layer,x2,y2,Type);
            localdata = [localdata(:)', local2(:)'];
        end
        data(isub,:) = localdata;
    end
    
    % save new map file
    if it == 1
        structOut = delwaq('write',File2,Header,{struct1.SubsName{substances}},refTime,time,data);
    else
        structOut = delwaq('write',structOut,time,data);
    end
    
    
end

