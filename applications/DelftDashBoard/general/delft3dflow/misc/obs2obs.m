function nobs = obs2obs(grd1, obs1, grd2, obs2)
%OBS2OBS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   nobs = obs2obs(grd1, obs1, grd2, obs2)
%
%   Input:
%   grd1 =
%   obs1 =
%   grd2 =
%   obs2 =
%
%   Output:
%   nobs =
%
%   Example
%   obs2obs
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

% $Id: obs2obs.m 5562 2011-12-02 12:20:46Z boer_we $
% $Date: 2011-12-02 20:20:46 +0800 (Fri, 02 Dec 2011) $
% $Author: boer_we $
% $Revision: 5562 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/misc/obs2obs.m $
% $Keywords: $

%%
[x0,y0,enc1]=ddb_wlgrid('read',grd1);
x1=zeros(size(x0,1)+1,size(x0,2)+1);
y1=zeros(size(x1));
xc1=zeros(size(x1));
yc1=zeros(size(x1));
x1(1:end-1,1:end-1)=x0;
y1(1:end-1,1:end-1)=y0;
x1(x1==0)=NaN;
y1(y1==0)=NaN;

x0=0.25*(x1(1:end-2,1:end-2)+x1(2:end-1,1:end-2)+x1(2:end-1,2:end-1)+x1(1:end-2,2:end-1));
y0=0.25*(y1(1:end-2,1:end-2)+y1(2:end-1,1:end-2)+y1(2:end-1,2:end-1)+y1(1:end-2,2:end-1));
xc1(2:end-1,2:end-1)=x0;
yc1(2:end-1,2:end-1)=y0;

[x0,y0,enc2]=ddb_wlgrid('read',grd2);
x2=zeros(size(x0,1)+1,size(x0,2)+1);
y2=zeros(size(x2));
xc2=zeros(size(x2));
yc2=zeros(size(x2));
x2(1:end-1,1:end-1)=x0;
y2(1:end-1,1:end-1)=y0;
x2(x2==0)=NaN;
y2(y2==0)=NaN;

x0=0.25*(x2(1:end-2,1:end-2)+x2(2:end-1,1:end-2)+x2(2:end-1,2:end-1)+x2(1:end-2,2:end-1));
y0=0.25*(y2(1:end-2,1:end-2)+y2(2:end-1,1:end-2)+y2(2:end-1,2:end-1)+y2(1:end-2,2:end-1));
xc2(2:end-1,2:end-1)=x0;
yc2(2:end-1,2:end-1)=y0;

fid=fopen(obs1);
counter=0;
while ~feof(fid)
    regel=fgetl(fid);
    counter=counter+1;
    obsNames{counter}=deblank2(regel(1:20));
    mnc=str2num(regel(21:end));
    obsM(counter)=mnc(1);
    obsN(counter)=mnc(2);
end
fclose(fid);

for i=1:length(obsM)
    obsx(i)=xc1(obsM(i),obsN(i));
    obsy(i)=yc1(obsM(i),obsN(i));
end

% fid=fopen(ann,'w');
% for ii=1:length(obsM)
%     if isfinite(obsx(ii))
%         fprintf(fid,'%17.8e  %17.8e  "%s"\n',obsx(ii),obsy(ii),obsNames{ii});
%     end
% end
% fclose(fid);

nobs=0;

fid=fopen(obs2,'w');
for i=1:length(obsM)
    dist=sqrt( (xc2-obsx(i)).^2 + (yc2-obsy(i)).^2 );
    [sorted, sortID]=sort(dist(:));
    candidates=sortID(1);
    [tm,tn]=ind2sub(size(dist),candidates);
    if tm>1 && tm>1
        xpol(1)=x2(tm-1,tn-1);ypol(1)=y2(tm-1,tn-1);
        xpol(2)=x2(tm,tn-1);  ypol(2)=y2(tm,tn-1);
        xpol(3)=x2(tm,tn);    ypol(3)=y2(tm,tn);
        xpol(4)=x2(tm-1,tn);  ypol(4)=y2(tm-1,tn);
        xpol(5)=xpol(1);      ypol(5)=ypol(1);
        ip=inpolygon(obsx(i),obsy(i),xpol,ypol);
        if ip>0
            if strcmpi(obsNames{i},['(' num2str(obsM(i)) ',' num2str(obsN(i)) ')'])
                obsNames{i} = ['(' num2str(tm) ',' num2str(tn) ')'];
            end
            nobs=nobs+1;
            fprintf(fid,'%s  %6i %6i\n',[obsNames{i} repmat(' ',1,20-length(obsNames{i}))],tm,tn);
        else
            warning=['Observation point ' obsNames{i} ' not found!'];
        end
    else
        warning=['Observation point ' obsNames{i} ' not found!'];
    end
end
fclose(fid);

if nobs==0
    delete(obs2)
end

