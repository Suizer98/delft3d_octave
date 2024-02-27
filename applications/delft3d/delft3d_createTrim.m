function nfsOut = delft3d_createTrim(trimIn,trimOut,time,varargin)
%DELFT3D_CREATETRIM  Compiles a new trim file from the 
%data in the input time file where it is possible to use different times as
%different groupNames. 
%
%   This file copies the data in trimIn at time timeOut to a new NEFIS file.
%   This new NEFIS file contains only data a one moment, namely the time
%   given in time. By passing keywords in the form <groupName>,<timeGroup>
%   it is possible to copy data in trimIn from other moments than time to
%   the output NEFIS file. This makes it suitable for creating trim-ini
%   files (see example). 
%
%   Syntax:
%   delft3d_createTrim(trimIn,trimOut,timeOut,<groupName>,<timeGroup>)
%
%   Input:
%   trimIn  	=	[string] filepath to input trim file
%   trimOut 	=	[string] filepath to the new trim file to be created. 
%             		If no path it present it is assumed trimOut is located in the
%             		same directory as trimIn. If trimOut is empty the file will
%             		be called <trimIn>-ini
%   timeOut    	=	[datenum] Time of the entry in the output file
%   <groupName> = 	[string] groupname to be copied. Groupnames are the same 
%                 	as groupnames for vs_let. Alternatively one can also
%                 	input {groupName,elementName1,elementName2,...}. In this
%                 	case only the elements with the name
%                 	elementName1,elementName2, etc. will be copied
%   <groupTime> = 	[datenum] the time in trimIn for which the data in the
%                 	group <groupName> has to be copied to trimOut. If
%                 	<groupTime> is empty the last time step will be used.
%
%
%   Example
%   Let trim-mysim.def and trim-mysim.dat be trim files of a Delft3d
%   simulation running from 2010-01-01 to 2010-01-30. Then the following
%   command will create trim-mysim-ini.def and trim-mysim-ini.dat
%   containing the hydrodynamic data of the first time step of trim-mysim
%   and bottom composition of the last time step of trim-mysim.
%   trim-mysim-ini can be used to restart the simulation at 2010-01-01
%   delft3d_createTrim('c:\mysim\trim-mysim.def',[],datenum('2010-01-01'),..
%   'map-sed-series',datenum('2010-01-31')); 
%
%   See also vs_copy, vs_ini, vs_put

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 ARCADIS
%       Ivo Pasmans
%
%       ivo.pasmans@arcadis.nl	
%
%       Arcadis, Zwolle, The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 nov 2012
% Created with Matlab version: 2009b

% $Id: delft3d_createTrim.m 9180 2013-09-04 16:36:46Z ivo.pasmans.x $
% $Date: 2013-09-05 00:36:46 +0800 (Thu, 05 Sep 2013) $
% $Author: ivo.pasmans.x $
% $Revision: 9180 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/delft3d_createTrim.m $
% $Keywords: $

%% Open input NEFIS-file

[trimInPath trimInName trimInExt]=fileparts(trimIn); 

%Check if file is trim file
if ~ismember(trimInExt,{'.def','.dat'}) || isempty(regexpi(trimInName,'trim-.*','once')); 
    error('File %s is not a proper trim file',trimIn); 
end %end if trim

%Check if file exists
if exist(trimIn,'file')
    nfsIn=vs_use(trimIn,'quiet'); 
else
    error('Cannot find input trim file %s',trimIn); 
end %end if exist

%% Time info

%convert time if necessary
if ~isnumeric(time)
    time=datenum(time); 
end %end if 

%Read times in trimIn
tIn=vs_time(nfsIn); t=tIn.datenum;

%% Create output NEFIS-file

%Set empty trimOut
if isempty(trimOut)
    trimOutPath=trimInPath;
    trimOutName=[trimInName,'-ini']; 
else
    [trimOutPath trimOutName trimOutExt]=fileparts(trimOut);
end %end if isempty(trimOut)

%Set empty trimOutPath
if isempty(trimOutPath)
    trimOutPath=trimInPath;
end %end iftrimOutPath

%Create filePath output file
trimOut=fullfile(trimOutPath,trimOutName); 

%Remove trimOut if present
if exist(trimOut,'file')
    delete(trimOut)
end %end if exist

%Create trimOut
nfsOut=vs_ini([trimOut,'.dat'],[trimOut,'.def']); 

%% Read <groupName>,<groupTime>-pairs
if ~isempty(varargin)
    
    %Replace empty times with end time
    for k=2:2:length(varargin)
        if isempty(varargin{k})
            varargin{k}=t(end);
        end %end if
    end %end for k        
    
    %Check length varargin
    if mod(length(varargin),2)~=0
        error('Use <groupName>,<groupTime> pairs in input.');
    end %end if length(varargin)
    
    %Create list with groupNames that has to be used at the times at which
    %data from these groups has to be taken. 
    groupNames=[];
    groupNames=varargin(1:2:end-1); 
    groupTimes=local_timeIndex(t,varargin(2:2:end));
    
    %Find element names
    elementNames=cell(1,length(groupNames)); 
    for l=1:length(groupNames)
       if ~iscell(groupNames{l})
           elementNames{l}=[];
       else
           elementNames{l}=groupNames{l}(2:end);
           groupNames{l}=groupNames{l}{1}; 
       end %end if length
    end %end for l
    
else
    
    groupNames={};
    elementNames={};
    groupTimes=[];
    
end %end varargin

%% Copy data at time time

%Set empty time
if isempty(time)
   time=t(1); 
end %end if empty(time)

%Find index closest to time time
iT=local_timeIndex(t,time); 

%Get groupNames
groupDef={nfsIn.GrpDat(:).Name}; 

%Copy data group by group
for k=1:length(groupDef)
    
    %Check if data from the output time or another time have to be copied
    iGroup=find( strcmpi(groupDef{k},groupNames),1); 
    
   
    if isempty(iGroup) 
        %Data have to be copied from default time
        iMax=nfsIn.GrpDat(k).SizeDim;
        vs_copy(nfsIn,nfsOut,'*',[],groupDef{k},{min(iT,iMax)}); 
    else
        %Data have to be copied from other time
        if isempty(elementNames{iGroup})
            %All elements have to be copied
            vs_copy(nfsIn,nfsOut,'*',[],groupNames{iGroup},{groupTimes(iGroup)}); 
        else
            %Only a limited list has to be copied
            vs_copy(nfsIn,nfsOut,'*',[],groupNames{iGroup},{groupTimes(iGroup)},elementNames{iGroup}); 
        end %end if isempty
    end %end if
        
end %end for k

%% Set new output time

nfsOut=vs_use(trimOut,'quiet'); 

%Calculate new itmapc
itmapc=round((time-tIn.datenum0)*24*60*60/tIn.dt_simulation);

%Write new itmapc 
vs_put(nfsOut,'map-info-series',{[1]},'ITMAPC',{[1]},itmapc); 

end %end delft3d_createTrim

function index=local_timeIndex(timeseries,time)
%Finds the index of time in timeseries

if ~iscell(time)
    time={time};
end %end if cell

index=nan(1,length(time)); 
for k=1:length(time)
  %Convert string to datenum is necessary
  if ~isnumeric(time{k})
      time{k}=datenum(time{k});
  end 

  if time{k}<timeseries(1) || time{k}>timeseries(end)
      warning('warning: given time lies outside the range of the timeseries. First/last step are used.');
  end %end if warning
  
  dTime=abs(timeseries-time{k});
  index(k)=find(dTime==min(dTime(:)),1); 
end %end for k

end %end local_timeIndex
