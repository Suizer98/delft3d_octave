function nbnd = bnd2bnd(grd1, bnd1, grd2, bnd2)
%BND2BND  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   nbnd = bnd2bnd(grd1, bnd1, grd2, bnd2)
%
%   Input:
%   grd1 =
%   bnd1 =
%   grd2 =
%   bnd2 =
%
%   Output:
%   nbnd =
%
%   Example
%   bnd2bnd
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

% $Id: bnd2bnd.m 5562 2011-12-02 12:20:46Z boer_we $
% $Date: 2011-12-02 20:20:46 +0800 (Fri, 02 Dec 2011) $
% $Author: boer_we $
% $Revision: 5562 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/misc/bnd2bnd.m $
% $Keywords: $

%%
[x0,y0,enc1]=ddb_wlgrid('read',grd1);
x1=zeros(size(x0,1)+1,size(x0,2)+1);
y1=zeros(size(x1));
x1(1:end-1,1:end-1)=x0;
y1(1:end-1,1:end-1)=y0;
x1(x1==0)=NaN;
y1(y1==0)=NaN;

[x0,y0,enc2]=ddb_wlgrid('read',grd2);
x2=zeros(size(x0,1)+1,size(x0,2)+1);
y2=zeros(size(x2));
x2(1:end-1,1:end-1)=x0;
y2(1:end-1,1:end-1)=y0;
x2(x2==0)=NaN;
y2(y2==0)=NaN;

fid=fopen(bnd1);
counter=0;
while ~feof(fid)
    regel=fgetl(fid);
    counter=counter+1;
    bndNames{counter}=deblank2(regel(1:24));
    mnc=str2num(regel(25:48));
    Mstart0(counter)=mnc(1);
    Nstart0(counter)=mnc(2);
    Mend0(counter)=mnc(3);
    Nend0(counter)=mnc(4);
    otherNames{counter}=deblank2(regel(49:end));
end
fclose(fid);

nc=0;
for i=1:length(Mstart0)
    
    bndM1(i)=0;
    
    Mstart=Mstart0(i);
    Nstart=Nstart0(i);
    Mend=Mend0(i);
    Nend=Nend0(i);
    
    if Nend==Nstart
        if isfinite(x1(Nstart)) & x1(Nstart)~=0
            n1=Nstart;
            n2=Nend;
        else
            n1=Nstart-1;
            n2=Nend-1;
        end
        if Mend>Mstart
            m1=Mstart-1;
            m2=Mend;
        else
            m1=Mstart;
            m2=Mend-1;
        end
    else
        if isfinite(x1(Mstart)) & x1(Mstart)~=0
            m1=Mstart;
            m2=Mend;
        else
            m1=Mstart-1;
            m2=Mend-1;
        end
        if Nend>Nstart
            n1=Nstart-1;
            n2=Nend;
        else
            n1=Nstart;
            n2=Nend-1;
        end
    end
    
    xbnd1=x1(m1,n1);
    xbnd2=x1(m2,n2);
    ybnd1=y1(m1,n1);
    ybnd2=y1(m2,n2);
    
    dist=sqrt( (x2-xbnd1).^2 + (y2-ybnd1).^2 );
    [sorted, sortID]=sort(dist(:));
    candidates=sortID(1);
    [tm0,tn0]=ind2sub(size(dist),candidates);
    if sorted(1)<=0.5*sqrt((xbnd2-xbnd1)^2 + (ybnd2-ybnd1)^2);
        tm1=tm0;
        tn1=tn0;
    else
        tm1=0;
        tn1=0;
    end
    
    dist=sqrt( (x2-xbnd2).^2 + (y2-ybnd2).^2 );
    [sorted, sortID]=sort(dist(:));
    candidates=sortID(1);
    [tm0,tn0]=ind2sub(size(dist),candidates);
    if sorted(1)<=0.5*sqrt((xbnd2-xbnd1)^2 + (ybnd2-ybnd1)^2);
        tm2=tm0;
        tn2=tn0;
    else
        tm2=0;
        tn2=0;
    end
    
    if tm1==tm2 & tm1>0
        nc=nc+1;
        if isfinite(x2(tm1+1)) & x2(tm1+1)~=0
            bndM1(nc)=tm1;
            bndM2(nc)=tm2;
        else
            bndM1(nc)=tm1+1;
            bndM2(nc)=tm2+1;
        end
        if tn2>tn1
            bndN1(nc)=tn1+1;
            bndN2(nc)=tn2;
        else
            bndN1(nc)=tn1;
            bndN2(nc)=tn2+1;
        end
    elseif tn1==tn2 & tn1>0
        nc=nc+1;
        if isfinite(x2(tn1+1)) & x2(tn1+1)~=0
            bndN1(nc)=tn1;
            bndN2(nc)=tn2;
        else
            bndN1(nc)=tn1+1;
            bndN2(nc)=tn2+1;
        end
        if tm2>tm1
            bndM1(nc)=tm1+1;
            bndM2(nc)=tm2;
        else
            bndM1(nc)=tm1;
            bndM2(nc)=tm2+1;
        end
    else
        Warning=['Boundary section ' deblank(bndNames{i}) ' not found!']
        bndM1(max(nc,1))=0;
    end
end

nbnd=0;
fid = fopen(bnd2,'wt');
for i=1:nc
    if bndM1(i)>0
        nbnd=nbnd+1;
        fprintf(fid,'%s  %5i %5i %5i %5i %s\n',[bndNames{i} repmat(' ',1,20-length(bndNames{i}))],bndM1(i),bndN1(i),bndM2(i),bndN2(i),otherNames{i});
    end
end
fclose(fid);
if nbnd==0
    delete(bnd2)
end

