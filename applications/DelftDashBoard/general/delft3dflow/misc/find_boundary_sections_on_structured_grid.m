function openBoundaries=find_boundary_sections_on_structured_grid(openBoundaries,depth,zmax,d,varargin)
%FINDBOUNDARYSECTIONSONSTRUCTEDGRID  finds open boundaries  on a grid 
%
%   
%
%   Syntax:
%   [handles err] = findBoundarySectionsOnStructuredGrid(handles, id, varargin)
%
%   Input:
%   handles  =
%   id       =
%   varargin =
%
%   Output:
%   handles  =
%   err      =
%
%   Example
%   ddb_generateBoundaryConditionsDelft3DFLOW
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
namingoption=1;
dpsopt='max';
autolength=0;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'dpsopt'}
                dpsopt=lower(varargin{ii+1});
            case{'namingoption'}
                namingoption=varargin{ii+1};
            case{'autolength'}
                autolength=varargin{ii+1};
        end
    end
end

if autolength
    stdautolength=0.1;
else
    stdautolength=1e9;
end

mmax=size(depth,1);
nmax=size(depth,2);

% Boundary locations

% North and South
switch namingoption
    case 1
        dir={'North','South'};
    case 2
        dir={'Upper','Lower'};
end

switch dpsopt
    case{'dp'}
        n=[nmax 2];
    otherwise
        n=[nmax 1];
end
n2=[nmax+1 1];
nb=0;
            
for j=1:2
    
    nd=0;
    mstart=0;
    mend=0;
    m=2;
    while m<=mmax
        % New boundary section
        while m<=mmax
            % Find start point of boundary section
            switch dpsopt
                case{'dp'}
                        if ~isnan(depth(m,n(j))) && ...
                                depth(m,n(j))<zmax
                            mstart=m;
                            break
                        else
                            m=m+1;
                        end
                otherwise
                    if ~isnan(depth(m,n(j))) && ~isnan(depth(m-1,n(j))) && ...
                            depth(m,n(j))<zmax
                        mstart=m;
                        break
                    else
                        m=m+1;
                    end
            end
        end
        mend=0;
%         figure(20)
%         plot(depth(:,n(j)),'o-')
        while m<=mstart+d-1 && m<=mmax
            % Find end point of boundary section
            switch dpsopt
                case{'dp'}
                    if ~isnan(depth(m,n(j))) && ...
                            depth(m,n(j))<zmax
                        alldepths=depth(mstart:m,n(j));
                        reldepths=alldepths/mean(alldepths);
                        if std(reldepths)>stdautolength
                            break
                        end
                        mend=m;
                        m=m+1;
                    else
                        break
                    end
                otherwise
                    if ~isnan(depth(m,n(j))) && ~isnan(depth(m-1,n(j))) && ...
                            depth(m,n(j))<zmax
                        mend=m;
                        m=m+1;
                    else
                        break
                    end
            end
        end
        if mstart>0 && mend>0
            % Start and end point found, this is a real boundary
            % section
            nb=nb+1;
            nd=nd+1;
            openBoundaries(nb).M1=mstart;
            openBoundaries(nb).M2=mend;
            openBoundaries(nb).N1=n2(j);
            openBoundaries(nb).N2=n2(j);            
            openBoundaries(nb).name=[dir{j} num2str(nd)];
        end
%        if m==mmax
        if m>mmax
            break
        end
    end    
end

% West and East
switch namingoption
    case 1
        dir={'West','East'};
    case 2
        dir={'Left','Right'};
end

switch dpsopt
    case{'dp'}
        m=[2 mmax];
    otherwise
        m=[1 mmax];
end
m2=[1 mmax+1];

for j=1:2
    
    nd=0;
    nstart=0;
    nend=0;
    n=2;
    while n<=nmax
        while n<=nmax
            % Find start point
            switch dpsopt
                case{'dp'}
                    if ~isnan(depth(m(j),n)) && ...
                            depth(m(j),n)<zmax
                        nstart=n;
                        break
                    else
                        n=n+1;
                    end
                otherwise
                    if ~isnan(depth(m(j),n)) && ...
                            depth(m(j),n)<zmax
                        nstart=n;
                        break
                    else
                        n=n+1;
                    end                    
            end
        end
        nend=0;
        while n<=nstart+d-1 && n<=nmax
            % Find end point
            switch dpsopt
                case{'dp'}
                    if ~isnan(depth(m(j),n)) && ...
                            depth(m(j),n)<zmax
                        alldepths=depth(m(j),nstart:n);
                        reldepths=alldepths/mean(alldepths);
                        if std(reldepths)>stdautolength
                            break
                        end
                        nend=n;
                        n=n+1;
                    else
                        break
                    end
                otherwise
                    if ~isnan(depth(m(j),n)) && ~isnan(depth(m(j),n-1)) && ...
                            depth(m(j),n)<zmax
                        nend=n;
                        n=n+1;
                    else
                        break
                    end
            end
        end
        %                n=n+1;
        if nstart>0 && nend>0
            nb=nb+1;
            nd=nd+1;
            openBoundaries(nb).M1=m2(j);
            openBoundaries(nb).M2=m2(j);
            openBoundaries(nb).N1=nstart;
            openBoundaries(nb).N2=nend;            
            openBoundaries(nb).name=[dir{j} num2str(nd)];
        end
%         if nend==0
%             n=n+1;
%         end
%        if n==nmax
        if n>nmax
            break
        end
    end
end
