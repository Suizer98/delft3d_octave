function ddb_saveDisFile2(discharges,fname,itDate)
%DDB_SAVEDISFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_saveDisFile(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%
%
%
%   Example
%   ddb_saveDisFile
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_saveDisFile2.m 7299 2012-09-26 16:04:59Z ormondt $
% $Date: 2012-09-27 00:04:59 +0800 (Thu, 27 Sep 2012) $
% $Author: ormondt $
% $Revision: 7299 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/fileio/ddb_saveDisFile2.m $
% $Keywords: $

%%

nr=length(discharges);

Info.Check='OK';
Info.FileName=fname;

Info.NTables=nr;

for n=1:nr
    
    switch lower(discharges(n).type)
        case{'normal'}
            tp='regular';
        case{'walking'}
            tp='walking';
        case{'momentum'}
            tp='momentum';
        case{'in-out'}
            tp='inoutlet';
    end
    Info.Table(n).Name=['Discharge : ' num2str(n)];
    Info.Table(n).Contents=tp;
    Info.Table(n).Location=discharges(n).name;
    Info.Table(n).TimeFunction='non-equidistant';
    itd=str2double(datestr(itDate,'yyyymmdd'));
    Info.Table(n).ReferenceTime=itd;
    Info.Table(n).TimeUnit='minutes';
    Info.Table(n).Interpolation=discharges(n).interpolation;
    Info.Table(n).Parameter(1).Name='time';
    Info.Table(n).Parameter(1).Unit='[min]';
    t=discharges(n).timeSeriesT;
    t=(t-itDate)*1440;
    Info.Table(n).Data(:,1)=t;
    Info.Table(n).Parameter(2).Name='flux/discharge rate';
    Info.Table(n).Parameter(2).Unit='[m3/s]';
    Info.Table(n).Data(:,2)=discharges(n).timeSeriesQ;
    
    k=2;
    
    if isfield(discharges(n),'salinity')
        k=k+1;
        Info.Table(n).Parameter(k).Name='Salinity';
        Info.Table(n).Parameter(k).Unit='[ppt]';
        Info.Table(n).Data(:,k)=discharges(n).salinity.timeSeries;
    end
    if isfield(discharges(n),'temperature')
        k=k+1;
        Info.Table(n).Parameter(k).Name='Temperature';
        Info.Table(n).Parameter(k).Unit='[C]';
        Info.Table(n).Data(:,k)=discharges(n).temperature.timeSeries;
    end
    if isfield(discharges(n),'sediment')
        for i=1:nrSediments
            k=k+1;
            Info.Table(n).Parameter(k).Name=sediment(i).name;
            Info.Table(n).Parameter(k).Unit='[kg/m3]';
            Info.Table(n).Data(:,k)=discharges(n).sediment(i).timeSeries;
        end
    end
    if isfield(discharges(n),'tracer')
        for i=1:nrTracers
            k=k+1;
            Info.Table(n).Parameter(k).Name=tracer(i).name;
            Info.Table(n).Parameter(k).Unit='[kg/m3]';
            Info.Table(n).Data(:,k)=discharges(n).tracer(i).timeSeries;
        end
    end
    if strcmpi(discharges(n).type,'momentum')
        k=k+1;
        Info.Table(n).Parameter(k).Name='flow magnitude';
        Info.Table(n).Parameter(k).Unit='[m/s]';
        Info.Table(n).Data(:,k)=discharges(n).timeSeriesM;
        k=k+1;
        Info.Table(n).Parameter(k).Name='flow direction';
        Info.Table(n).Parameter(k).Unit='[deg]';
        Info.Table(n).Data(:,k)=discharges(n).timeSeriesM;
    end
    
    npar=length(Info.Table(n).Parameter);
    for i=1:npar
        quant=deblank(Info.Table(n).Parameter(i).Name);
        quant=[quant repmat(' ',1,20-length(quant))];
        Info.Table(n).Parameter(i).Name=quant;
    end
    
end
ddb_bct_io('write',fname,Info);


