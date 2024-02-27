%DELWAQ_DIFF Read Delwaq ADA file a write a Delwaq HIS file.
%
%   STRUCTOUT = DELWAQ_ADA2HIS(FILENAME,,FILE2SAVE,SEGEMENTNR,SEGMENTNAMES)
%   Reads FILENAME and creates the His file FILE2SAVE, SEGEMENTNR and
%   SEGMENTNAMES.
%   If FILE2SAVE is empty FILE2SAVE = FILENAME.HIS
%
%   STRUCTOUT = DELWAQ_ADA2HIS(...,SUBSTANCENAMES)
%   Create the HIS file only for substances specified in SUBSTANCENAMES
%
%   See also: DELWAQ, DELWAQ_XY2SEGNR, DELWAQ_RES, DELWAQ_TIME, DELWAQ_STAT, 
%             DELWAQ_INTERSECT

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Jul-12 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------
function structOut = delwaq_ada2his(FileName,File2Save,SegmentNr,SegmentNames,SubstanceNames)

if nargin<5
   SubstanceNames = 0;
end

if isempty(File2Save)
   [path1, name1] = fileparts(FileName);
   File2Save = [path1 '\' name1 '.his'];
end

inot = isnan(SegmentNr);
SegmentNr = SegmentNr(~inot);
SegmentNames = {SegmentNames{~inot}}; %#ok<CCAT1>


% Opening Files
Nfs = vs_use(FileName,'quiet');
 
% Header
Header = vs_get(Nfs,'DELWAQ_PARAMS','TITLE','quiet');

% Setting time reference
T0 =  datenum(Header(end,4:23),'yyyy.mm.dd HH:MM:SS');
refTime =  [T0 1];

% Getting time
nfsTime = vs_get(Nfs,'DELWAQ_RESULTS','TIME','quiet');
nfsTime = [nfsTime{:}]/86400;
time    = T0+nfsTime;

SubsName = cellstr(vs_get(Nfs,'DELWAQ_PARAMS','SUBST_NAMES','quiet'));

% Matching SubsName
[SubstanceNames isub] = match_names(SubsName,SubstanceNames);
if isempty(isub)
   disp('There is any match in the substance name');
   return 
end

for i = 1:length(isub)
    subNfs{i} = ['SUBST_' num2str(isub(i), '%03.0f')];
end



nsub = length(isub);
nseg = length(SegmentNr);
data = nan(nsub,nseg,length(nfsTime));

% Read data
for isub = 1:nsub
    data1= vs_get(Nfs,'DELWAQ_RESULTS',{0},subNfs{isub},{SegmentNr},'quiet');
    data(isub,:,:) = [data1{:}];    
end

% Writing a File
structOut = delwaq('write',File2Save,Header,SubstanceNames,SegmentNames,refTime,time,data);


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
