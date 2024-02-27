function [dataOut stdOut]=smoothByAveraging(dataIn,tOut,varargin)
%SMOOTHBYAVERAGING Smooths time signal by averaging groups of data.
%
%The function divides the time domain in blocks centered around the 
%times in tOut. It bins the data in dataIn into these blocks and
%averages the data. 
%
%Syntax:
%   [dataOut sigma]=smoothByAveraging(dataIn,tOut,<keyword>,<value>,...)
%
%Input:
% dataIn        = [mxn double] matrix with in column 1 the time (as datenum) and column
%                 2 to n the data to be averaged. Column 1 must be
%                 ascending. 
% tOut          = [mx1 double] matrix with times (as datenum) on which output will be
%                 generated. 
%
%Output:
% dataOut       = [mxn double] matrix with in column 1 output time and
%                 other columns the averaged data. 
% stdOut         = standard deviation of mean for the set of data that have been averaged for 1 time step. 
%
%Optional keywords:
% min_samples   = [integer] mininum number of samples to be averaged for each output
%                 time. If the number of available samples is lower then
%                 this the output will be NaN (default=1). 

%--------------------------------------------------------------------------------------
%   Copyright (C) 2013 Arcadis
%       Ivo Pasmans
%
%       ivo.pasmans@arcadis.nl
%
%       Arcadis Zwolle
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of OpenEarthTools.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 04 Nov 2010
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: smoothByAveraging.m 8438 2013-04-12 09:58:43Z ivo.pasmans.x $
% $Date: 2013-04-12 17:58:43 +0800 (Fri, 12 Apr 2013) $
% $Author: ivo.pasmans.x $
% $Revision: 8438 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/signal_fun/smoothByAveraging.m $
% $Keywords: $
%
%--------------------------------------------------------------------------------------------

%% Preprocessing

%set default values keywords
OPT.min_samples=1;
OPT=setproperty(OPT,varargin); 

%Turn tOut into column vector
if size(tOut,1)<size(tOut,2)
    tOut=tOut';
end

%% Averaging

%Initiate output
dataOut=nan(length(tOut),size(dataIn,2)); 
stdOut=nan(length(tOut),size(dataIn,2));

%Calculate boundary between different output times
if length(tOut)>1
  %boundaries based on output times specified in tOut
  tBoundary=tOut(1:end-1)+0.5*diff(tOut);     
  tBoundary=[tBoundary;dataIn(end,1)];
  dataOut(:,1)=tOut;
else
  %output time is equal to average input times
  tBoundary=dataIn(end,1); 
  dataOut(1,1)=nanmean(dataIn(:,1));
  stdOut(1,1)=nanstd(dataIn(:,1))./sqrt( sum(~isnan(dataIn(:,1))) ); 
end


%Average per output time
for k=1:length(tBoundary)
    
    if numel(dataIn)==0
        break;
    else
        iBlock=find( dataIn(:,1)<=tBoundary(k) ); 
    end
    
    %Too few samples to be averaged
    if length(iBlock)<OPT.min_samples
        dataIn=local_removeData(dataIn,max(iBlock)+1); 
        continue;
    end 
    
    %Average samples in block
    dataOut(k,2:end)=nanmean(dataIn(iBlock,2:end),1); 
	stdOut(k,2:end)=nanstd(dataIn(iBlock,2:end),1)./sqrt( sum(~isnan(dataIn(iBlock,2:end)),1) );
    dataIn=local_removeData(dataIn,max(iBlock)+1); 
end

end %end function smoothByAverging

function out=local_removeData(in,iStart)
%LOCAL_REMOVEDATA Removes rows before row iStart

if isempty(iStart)
    out=in; 
elseif iStart>size(in,1)
    out=[];
else
    out=in(iStart:end,:); 
end %end if isempty(iStart) 
    
end %end function local_removeData