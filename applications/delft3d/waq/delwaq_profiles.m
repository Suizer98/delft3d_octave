%DELWAQ_PROFILES Read Delwaq map files and gives back profile data
%
%   STRUCTOUT = DELWAQ_PROFILES(MAPFILE,LGAFILE,SUBSNAME,X,Y,T,dT)
%   DELWAQ_PROFILES Read MAPFILE and LGAFILE and gives back SUBSNAME in the
%   segment corresponding to X and Y for time in T.
%   dT is the interval time in seconds that is allow in order to do the
%   matching with the time model.

%   See also: DELWAQ, DELWAQ_XY2SEGNR, DELWAQ_RES, DELWAQ_TIME, DELWAQ_STAT, 
%             DELWAQ_INTERSECT

%   Copyright 2013 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2013-Mar-06 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------
function structOut = delwaq_profiles(mapFile,lgaFile,SubstanceNames,xloc,yloc,tloc,dt)

% Number of times
nt = length(tloc);

% Read times in map file
disp('Getting time: delwaq_datenum')
S.datenum = delwaq_datenum(mapFile);
[itloc, itfile]  = time_near(tloc,S.datenum,dt,'middle');
S.itime = nan(nt,1);
S.itime(itloc) = itfile;

% Find the segments corresponding to xloc and yloc
disp('Getting segment: delwaq_xy2segnr')
S.iseg   =  delwaq_xy2segnr(lgaFile,xloc,yloc);

%Open map files and lga file
S.struct = delwaq('open',mapFile);
S.grid   = delwaq('open',lgaFile);

% Matching SubsName
[S.Subs, ksub] = match_names(S.struct.SubsName,SubstanceNames);

% Read LocalDepth if any
if any(strcmpi(S.struct.SubsName, 'LocalDepth'))
   idepth = find(strcmpi(S.struct.SubsName, 'LocalDepth'));
   rdepth =1;
else
   rdepth =0;
end


for i = 1:nt
    
    disp(['delwaq_profiles progress:' num2str(i) '/' num2str(nt)])
    
    if ismember(i,itloc) && ~isnan(S.iseg(i))
        
        iseg  = S.iseg(i)+(0:(S.grid.NoSeg/S.grid.NoSegPerLayer)-1)*(S.grid.NoSegPerLayer);
        itime = S.itime(i);
        
        if rdepth
           isub = [ksub idepth];
           [time, data] = delwaq('read',S.struct,isub,iseg,itime);
           depth = data(end,:)';
           data = data(1:end-1,:)';
       else
           isub = ksub;
           [time, data] = delwaq('read',S.struct,isub,iseg,itime);
           data = data';
           depth = nan(size(data));
        end
        
    else
        depth = [];
        data  = [];
        time  = tloc(i);
    end
    
    structOut(i).x = xloc(i);
    structOut(i).y = yloc(i);
    structOut(i).datenum = time;
    structOut(i).depth = -depth;
    structOut(i).name =  SubstanceNames;
    structOut(i).value = data';
end

%--------------------------------------------------------------------------
% Match names
%--------------------------------------------------------------------------
function [names, iname1, iname2] = match_names(name1,name2)

iname1 = [];
iname2 = [];
names  = [];

if ischar(name2)
   name2 = cellstr(name2);
elseif isnumeric(name2);
    if length(name2)==1 && name2==0
       name2 = 1:length(name1);
    end
    name2 = name1(name2);
end

k = 0;
for i = 1:length(name2)
    isub1 = find(strcmpi(name1,name2{i}));
    if ~isempty(isub1)
       k = k+1;
       iname1(k) = isub1; %#ok<*AGROW>
       iname2(k) = i;
       names{k} = name2{i};
    end
end