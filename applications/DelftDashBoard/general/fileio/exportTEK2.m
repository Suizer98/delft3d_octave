function exportTEK2(data,filename)
%EXPORTTEK  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   exportTEK(data, times, fname, blname, comments)
%
%   Input:
%   data     =
%   times    =
%   fname    =
%   blname   =
%   comments =
%
%
%
%
%   Example
%   exportTEK
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
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: exportTEK2.m 8290 2013-03-07 11:13:26Z ormondt $
% $Date: 2013-03-07 19:13:26 +0800 (Thu, 07 Mar 2013) $
% $Author: ormondt $
% $Revision: 8290 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/fileio/exportTEK2.m $
% $Keywords: $


% Count number of time series
n=0;
for ipar=1:length(data.parameters)
    if sum(data.parameters(ipar).parameter.size(2:end))==0
        % Time series
        n=n+1;
        acpar(n)=ipar;
    end    
end

time=data.parameters(acpar(1)).parameter.time;
blockdata=zeros(length(time),n);
for ii=1:n
    ipar=acpar(ii);
    if size(data.parameters(ipar).parameter.val,1)==1
        data.parameters(ipar).parameter.val=data.parameters(ipar).parameter.val';
        blockdata(:,ipar)=data.parameters(ipar).parameter.val;
    end
end

blockdata(isnan(blockdata))=-999;

fid=fopen(filename,'w');

fprintf(fid,'%s\n','* column 1 : Date');
fprintf(fid,'%s\n','* column 2 : Time');
for ii=1:n
    ipar=acpar(ii);
    fprintf(fid,'%s\n',['* column ' num2str(ii+2) ' : ' data.parameters(ipar).parameter.name]);
end

fprintf(fid,'%s\n',data.stationname);
n=size(data,2);
fprintf(fid,'%i %i\n',length(time),2+length(data.parameters));
fclose(fid);

timestr=datestr(time,'yyyymmdd HHMMSS');
datastr=num2str(blockdata,'%14.4e');
spc=repmat(' ',length(time),1);
str=[timestr spc datastr];
dlmwrite(filename,str,'delimiter','','-append');
