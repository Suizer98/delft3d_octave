function windData = ddb_getNOAAWindData(stationId, startDate, numOfDays, outputFile)
%DDB_GETNOAAWINDDATA  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   windData = ddb_getNOAAWindData(stationId, startDate, numOfDays, outputFile)
%
%   Input:
%   stationId  =
%   startDate  =
%   numOfDays  =
%   outputFile =
%
%   Output:
%   windData   =
%
%   Example
%   ddb_getNOAAWindData
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
% download data:
% step 1: find selected stationId and time period
% step 2: create string ['@' stationId]
% step 3: create url link with above string as stationID

[fPat,fName,fExt]=fileparts(outputFile);
if isempty(fExt)
    fExt='.txt.';
end
if isempty(fPat)
    fPat=pwd;
end
name=[fPat filesep fName fExt];
windData=[];

hW = waitbar(0,'Please wait...');

for ii=1:numOfDays
    currentDate=startDate+ii-1;
    data=ddb_getTableFromWeb(['http://data.nssl.noaa.gov/dataselect/nssl_result.php?datatype=sf&sdate=' datestr(currentDate,29) '&hour=00&hour2=23&outputtype=list&param_val=SPED;DRCT;PMSL&area=@' stationId],2);
    if ~isempty(data)&size(data,1)~=1
        speed=str2num(char(data(2:end,3)));
        dirs=str2num(char(data(2:end,4)));
        pres=str2num(char(data(2:end,5)));
        speed(speed==-9999.00)=nan;
        dirs(dirs==-9999.00)=nan;
        pres(pres==-9999.00)=nan;
        dates=char(data{2:end,2});
        yy=1900+str2num(dates(:,1:2));
        yy(yy<1950)=yy(yy<1950)+100;
        mm=str2num(dates(:,3:4));
        dd=str2num(dates(:,5:6));
        HH=str2num(dates(:,8:9));
        MM=str2num(dates(:,10:11));
        SS=zeros(size(MM));
        datNums=datenum(yy,mm,dd,HH,MM,SS);
        windData=[windData; datNums speed dirs pres];
        dates=strrep(cellstr(D3DTimeString(datNums,30)),'T','   ');
        dates=str2num(strvcat(dates{:}));
        fid=fopen(name,'a');
        fprintf(fid,'%8.8i   %6.6i   %4.1f   %3.1f   %6.2f\n',[dates(:,1), dates(:,2), [speed dirs pres]]');
        fclose(fid);
    end
    waitbar(ii/numOfDays,hW);
end

close(hW);

