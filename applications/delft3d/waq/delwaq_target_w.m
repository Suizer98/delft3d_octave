function structOut = delwaq_target(File1,File2,SubstanceName,Type,Tinter,geoMean)
%DELWAQ_TARGET Read Delwaq files and write a Difference file.
%
%   STRUCTOUT = DELWAQ_TARGET(FILE1,FILE2,FILE2SAVE,SUBSTANCENAME,SUBSTANCENAME,TYPE)
%   Reads FILE1 and FILE2, find the matchig fields:
%   substances/segments/stations in both files and write the statistics to
%   plot a target diagram
%
%   STRUCTOUT = DELWAQ_TARGET(...,SUBSTANCESNAME,...) specifies substances to
%   be used. SUBSTANCESNAME = 0 for all substances.      
%
%   STRUCTOUT = DELWAQ_TARGET(...,TYPE) specifies alternate methods.  
%   The default is 'none'.  Available methods are:
%  
%       'none'    - Difference: File1-File2
%       'log'     - stat of natural logarithm: log(File1)-log(File2)
%       'log10'   - Difference of base 10 logarithm: log10(File1)-log10(File2)
%       'log_a'   - stat of natural logarithm: log(File1)-log(File2)
%       'log10_a' - Difference of base 10 logarithm: log10(File1)-log10(File2)
%       'fwf'  - For Salinity: Fresh water fraccion

% 
%   See also: DELWAQ, DELWAQ_CONC, DELWAQ_RES, DELWAQ_TIME, DELWAQ_STAT, 
%             DELWAQ_INTERSECT

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Jul-12 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------

if nargin<4
    Type = 'none';
end
if nargin<6
    geoMean = 0;
end

if nargin<5
    Tinter = 0;
end
if nargin<3
   error('The name of the substance is not provided');
elseif nargin>=3 && iscell(SubstanceName) && length(SubstanceName)>1
   SubstanceName = SubstanceName{1};
   warning('Too many substances, only the first substance will be used') %#ok<*WNTAG>
end
SegmentsNames = 0;

S = delwaq_intersect(File1,File2);

% Matching SubsName and SegmentsNames
S = delwaq_match(S,SubstanceName,SegmentsNames);


if isempty(S.Subs)
   disp('There is any match in the substance name');
   return 
end

if isempty(S.Segm)
   disp('There is any match in the substance name');
   return 
end


% Opening Files
struct1 = delwaq('open',File1);
struct2 = delwaq('open',File2);
k = 0;

switch S.extId
    case 'map'
    disp('Not yet implemented for map files')

   case 'his'
       
    for iseg = 1:S.nSegm
        disp(['delwaq_target progress: ' num2str(iseg) '/' num2str(S.nSegm)])

        [time1, data1] = delwaq('read',struct1,S.iSubs{1}(1),S.iSegm{1}(iseg),0);
        [time2, data2] = delwaq('read',struct2,S.iSubs{2}(1),S.iSegm{2}(iseg),0);
        
        % Transform values according to Type
        [time1, data1] = transform_values(time1, data1, Type);
        [time2, data2] = transform_values(time2, data2, Type);
                 
        if Tinter~=0
           [it1 it2]  = time_near(time1,time2,Tinter);
           time1 = time1(it1);
           time2 = time1;
           data1 = data1(it1);
           data2 = data2(it2);
        end
            
        % Target diagram information
        if length(time1)>2
           k = k+1;
           structOut(k).subsName = S.Subs{1}; %#ok<*AGROW>
           structOut(k).obs_name = S.Segm{iseg};            
           TS = GoFStats(time1, data1, time2, data2, 'geomean',geoMean); 
           TS.obs_name =  S.Segm{iseg};
           tnames = fieldnames(TS);
           for j = 1:length(tnames)
               structOut(k).(tnames{j}) = TS.(tnames{j});
           end
        end 
    end
    
end

if ~exist('structOut','var')
   structOut = [];
end

function [dtime dvalues] = transform_values(dtime, dvalues,Type)


switch Type
    case 'log'        
        dvalues(dvalues<=0) = nan;
        dvalues   = log(dvalues);
    case 'log10'        
        dvalues(dvalues<=0) = nan;
        dvalues   = log10(dvalues);
    case 'loga'        
        dvalues(dvalues<=0) = nan;
        dvalues   = log(dvalues+1);
    case 'log10a'        
        dvalues(dvalues<=0) = nan;
        dvalues   = log10(dvalues+1);
    case 'log10b'        
        dvalues(dvalues<=0) = nan;
        dvalues   = log10(dvalues);
    case 'fwf'        
        S0 = 36;
        dvalues(dvalues<=0) = nan;
        dvalues = log10((S0-dvalues)./S0);
end

inot1 = isnan(dvalues);
dtime(inot1) = [];
dvalues(inot1) = [];
           
