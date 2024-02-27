function bndind = ddb_makeDDModelBoundaries(x1, y1, x2, y2, runid1, runid2)
%DDB_MAKEDDMODELBOUNDARIES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   bndind = ddb_makeDDModelBoundaries(x1, y1, x2, y2, runid1, runid2)
%
%   Input:
%   x1     =
%   y1     =
%   x2     =
%   y2     =
%   runid1 =
%   runid2 =
%
%   Output:
%   bndind =
%
%   Example
%   ddb_makeDDModelBoundaries
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
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
% Find DD boundaries

bndind=[];

% disp('bottom');
bndind=findBoundaries(x1,y1,x2,y2,bndind,runid1,runid2,'bottom');
% disp('top');
bndind=findBoundaries(x1,y1,x2,y2,bndind,runid1,runid2,'top');
% disp('left');
bndind=findBoundaries(x1,y1,x2,y2,bndind,runid1,runid2,'left');
% disp('right');
bndind=findBoundaries(x1,y1,x2,y2,bndind,runid1,runid2,'right');


%%
function bndind=findBoundaries(x1,y1,x2,y2,bndind,runid1,runid2,opt)

nddb=length(bndind);
nddb0=0;
nddb1=0;

switch opt
    case{'bottom'}
        j2=1;
        ifd=1;
    case{'top'}
        j2=size(x2,2);
        ifd=0;
    case{'left'}
        x2=x2';
        y2=y2';
        j2=1;
        ifd=1;
    case{'right'}
        x2=x2';
        y2=y2';
        j2=size(x2,2);
        ifd=0;
end

iac2=zeros(size(x2));
iac2(isfinite(x2))=1;

i2=1;
while i2<=size(x2,1)
    ifound=0;
    if iac2(i2,j2)
        x2a=x2(i2,j2);
        y2a=y2(i2,j2);
        dx=GetDX(x2,y2,i2,j2);
        dx=0.1*dx;
        [ma,na]=findcornerpoint(x2a,y2a,x1,y1,dx);
        if ~isempty(ma)
            % Matching Point found
            % Find next matching point
            i2a=i2;
            ii=i2;
            while ii<=size(x2,1)-1
                ii=ii+1;
                if iac2(ii,j2)
                    x2b=x2(ii,j2);
                    y2b=y2(ii,j2);
                    dx=GetDX(x2,y2,ii,j2);
                    dx=0.1*dx;
                    [mb,nb]=findcornerpoint(x2b,y2b,x1,y1,dx);
                    if ~isempty(mb)
                        % Check to see if grid points overall grid are on
                        % the same regel
                        if na==nb || ma==mb
                            % Check for inactive points overall grid
                            isn=max(max(isnan(x1(ma:mb,na:nb))));
                            if ~isn
                                % Boundary Section Found
                                nddb0=nddb0+1;
                                m1a(nddb0)=ma;
                                m1b(nddb0)=mb;
                                n1a(nddb0)=na;
                                n1b(nddb0)=nb;
                                m2a(nddb0)=i2a;
                                m2b(nddb0)=ii;
                                n2a(nddb0)=j2;
                                n2b(nddb0)=j2;
                                ifound=1;
                                break
                            end
                        end
                    end
                else
                    break
                end
            end
        end
    end
    if ifound
        i2=ii;
    else
        i2=i2+1;
    end
end

%% Paste different sections together

% Determine refinement factors
for k=1:nddb0
    refm(k)=m2b(k)-m2a(k);
end

if nddb0>0
    nddb1=1;
    m1anew(nddb1)=m1a(1);
    m2anew(nddb1)=m2a(1);
    m1bnew(nddb1)=m1b(1);
    m2bnew(nddb1)=m2b(1);
    n1anew(nddb1)=n1a(1);
    n2anew(nddb1)=n2a(1);
    n1bnew(nddb1)=n1b(1);
    n2bnew(nddb1)=n2b(1);
    for k=1:nddb0-1
        if refm(k)==refm(k+1) && m1a(k+1)==m1b(k)
            m1bnew(nddb1)=m1b(k+1);
            m2bnew(nddb1)=m2b(k+1);
            n1bnew(nddb1)=n1b(k+1);
            n2bnew(nddb1)=n2b(k+1);
        else
            nddb1=nddb1+1;
            m1anew(nddb1)=m1a(k+1);
            m2anew(nddb1)=m2a(k+1);
            m1bnew(nddb1)=m1b(k+1);
            m2bnew(nddb1)=m2b(k+1);
            n1anew(nddb1)=n1a(k+1);
            n2anew(nddb1)=n2a(k+1);
            n1bnew(nddb1)=n1b(k+1);
            n2bnew(nddb1)=n2b(k+1);
        end
    end
end

%% Make DD structure
for k=1:nddb1
    switch opt
        case{'bottom'}
            bndind(nddb+k).runid1=runid1;
            bndind(nddb+k).runid2=runid2;
            bndind(nddb+k).m1a=m1anew(k);
            bndind(nddb+k).m1b=m1bnew(k);
            bndind(nddb+k).n1a=n1anew(k);
            bndind(nddb+k).n1b=n1bnew(k);
            bndind(nddb+k).m2a=m2anew(k);
            bndind(nddb+k).m2b=m2bnew(k);
            bndind(nddb+k).n2a=n2anew(k);
            bndind(nddb+k).n2b=n2bnew(k);
        case{'left'}
            bndind(nddb+k).runid1=runid1;
            bndind(nddb+k).runid2=runid2;
            bndind(nddb+k).m1a=m1anew(k);
            bndind(nddb+k).m1b=m1bnew(k);
            bndind(nddb+k).n1a=n1anew(k);
            bndind(nddb+k).n1b=n1bnew(k);
            bndind(nddb+k).m2a=n2anew(k);
            bndind(nddb+k).m2b=n2bnew(k);
            bndind(nddb+k).n2a=m2anew(k);
            bndind(nddb+k).n2b=m2bnew(k);
        case{'top'}
            bndind(nddb+k).runid1=runid2;
            bndind(nddb+k).runid2=runid1;
            bndind(nddb+k).m1a=m2anew(k);
            bndind(nddb+k).m1b=m2bnew(k);
            bndind(nddb+k).n1a=n2anew(k);
            bndind(nddb+k).n1b=n2bnew(k);
            bndind(nddb+k).m2a=m1anew(k);
            bndind(nddb+k).m2b=m1bnew(k);
            bndind(nddb+k).n2a=n1anew(k);
            bndind(nddb+k).n2b=n1bnew(k);
        case{'right'}
            bndind(nddb+k).runid1=runid2;
            bndind(nddb+k).runid2=runid1;
            bndind(nddb+k).m1a=n2anew(k);
            bndind(nddb+k).m1b=n2bnew(k);
            bndind(nddb+k).n1a=m2anew(k);
            bndind(nddb+k).n1b=m2bnew(k);
            bndind(nddb+k).m2a=m1anew(k);
            bndind(nddb+k).m2b=m1bnew(k);
            bndind(nddb+k).n2a=n1anew(k);
            bndind(nddb+k).n2b=n1bnew(k);
    end
end

%%
function dx=GetDX(x,y,i,j)

mmax=size(x,1);
nmax=size(x,2);

i1=max(i-1,1);
i2=min(i+1,mmax);

j1=max(j-1,1);
j2=min(j+1,nmax);

dist(1)=sqrt((x(i,j)-x(i1,j)).^2 + (y(i,j)-y(i1,j)).^2);
dist(2)=sqrt((x(i,j)-x(i2,j)).^2 + (y(i,j)-y(i2,j)).^2);
dist(3)=sqrt((x(i,j)-x(i,j1)).^2 + (y(i,j)-y(i,j1)).^2);
dist(4)=sqrt((x(i,j)-x(i,j2)).^2 + (y(i,j)-y(i,j2)).^2);

t=0;
nt=0;
for k=1:4
    if ~isnan(dist(k)) && dist(k)>0
        nt=nt+1;
        t=t+dist(k);
    end
end
nt=max(nt,1);
dx=t/nt;


