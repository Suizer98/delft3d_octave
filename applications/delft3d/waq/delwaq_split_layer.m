function structOut = delwaq_split_layer(FileName,LayerNr,lgaOrNlayer,SubstanceNames)
%DELWAQ_SPLIT_LAYER Read and split in layers a Delwaq MAP file.
%
%   STRUCTOUT = DELWAQ_SPLIT_LAYER(FILENAME,LAYERNR,LGAFILE)
%   Reads FILENAME, split the map file into layers  using the
%   information in the LGAFILE and creates a new map file named as:
%   FILENAME_LAYERNR.MAP 
%   
%   STRUCTOUT = DELWAQ_SPLIT_LAYER(FILENAME,LAYERNR,NRLAYERS)
%   Reads FILENAME, split the map file into layers  using the
%   information in the NRLAYERS and creates a new map file named as:
%   FILENAME_LAYERNR.MAP 
%
%   STRUCTOUT = DELWAQ_SPLIT_LAYER(FILENAME,...,SUBSTANCENAMES)
%   Reads FILENAME, split the map file into layers but only choosing the 
%   substances specified in SUBSTANCENAMES.
%
%   See also: DELWAQ, DELWAQ_SPLIT_SUBS, DELWAQ_TIME, DELWAQ_STAT, 
%             DELWAQ_INTERSECT, DELWAQ_DATENUM

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2012-Mar-06 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------

% Opening Files
struct1 = delwaq('open',FileName);

if isnumeric(lgaOrNlayer)
   nlayer = lgaOrNlayer;
   szLaker = struct1.NumSegm/nlayer;
   for il = 1:nlayer
       ilayer{il} = ((szLaker*(il-1))+1):(szLaker*il);
   end        

elseif exist(lgaOrNlayer,'file')
    S = delwaq('open',lgaOrNlayer);
    nlayer = size(S.Index,3);
    for il = 1:nlayer
        layer =  unique(S.Index(:,:,il));
        layer(layer<=0) = [];
        ilayer{il} = layer;
    end        
end

if nargin<4
   SubstanceNames = 0;
end

[path1 name1 ext1] = fileparts(FileName);

% Matching SubsName
[SubstanceNames SubstanceNr] = match_names(struct1.SubsName,SubstanceNames);

if isempty(SubstanceNr)
   disp('There is any match in the substance name');
   return 
end

% Header
Header = struct1.Header;

% Setting time reference
T0 = struct1.T0;
refTime =  [T0 1];

nslay = length(LayerNr);

% Read data
for it = 1:struct1.NTimes
    [time alldata] = delwaq('read',struct1,SubstanceNr,0,it);
    disp(['delwaq_split_layers progress:' num2str(it) '/' num2str(struct1.NTimes)])

    for ilay = 1:nslay
        klay = ilayer{LayerNr(ilay)};
        data = alldata(:,klay);
        
        % Writing a File
        if it==1
            fileName = [name1 '_' num2str(LayerNr(ilay),'%02.0f') ext1];
            File2Save = fullfile(path1,fileName);
            structOut{ilay} = delwaq('write',File2Save,Header,SubstanceNames,refTime,time,data);
        else
            structOut{ilay} = delwaq('write',structOut{ilay},time,data);
        end
    end
        
end


%--------------------------------------------------------------------------
% Match names
%--------------------------------------------------------------------------
function [names iname1 iname2] = match_names(name1,name2)

iname1 = [];
iname2 = [];
names  = [];
name1 = lower(name1);
name2 = lower(name2);

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
    isub1 = find(strcmp(name1,name2{i}));
    if ~isempty(isub1)
       k = k+1;
       iname1(k) = isub1; %#ok<*AGROW>
       iname2(k) = i;
       names{k} = name2{i};
    end
end
