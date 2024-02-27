function openBoundaries=find_boundary_sections_on_structured_grid_v02(openBoundaries,z,zz,zmax,maxlength,varargin)
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

autolength=0;
dpuopt='mean';
dpsopt='max';
gridrotation=0;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'dpuopt'}
                dpuopt=lower(varargin{ii+1});
            case{'dpsopt'}
                dpsopt=lower(varargin{ii+1});
            case{'autolength'}
                autolength=varargin{ii+1};
            case{'gridrotation'}
                gridrotation=lower(varargin{ii+1});
        end
    end
end

if autolength
    stdautolength=0.1;
else
    stdautolength=1e9;
end

if strcmpi(dpsopt,'dp')
    dpuopt='mor';
end

% Depths are dps values (depth(1,1)=NaN!)

mmax=size(z,1);
nmax=size(z,2);

% Names for boundaries
gridrotation=mod(gridrotation,360);
if gridrotation<=22.5 || gridrotation>337.5
    bndnames={'South','North','West','East'};
elseif  gridrotation>22.5  && gridrotation<=67.5
    bndnames={'SouthEast','NorthWest','SouthWest','NorthEast'};
elseif  gridrotation>67.5  && gridrotation<=112.5
    bndnames={'East','West','South','North'};
elseif  gridrotation>112.5 && gridrotation<=157.5
    bndnames={'NorthEast','SouthWest','SouthEast','NorthWest'};
elseif  gridrotation>157.5 && gridrotation<=202.5
    bndnames={'North','South','East','West'};
elseif  gridrotation>202.5 && gridrotation<=247.5
    bndnames={'NorthWest','SouthEast','NorthEast','SouthWest'};
elseif  gridrotation>247.5 && gridrotation<=292.5
    bndnames={'West','East','North','South'};
elseif  gridrotation>292.5 && gridrotation<=337.5
    bndnames={'SouthWest','NorthEast','NorthWest','SouthEast'};
end
        
% First find possible open boundaries where depth at velocity points exceeds zmax

% South
ioksouth=zeros(1,mmax);
dpbsouth=ioksouth;
dpbsouth(dpbsouth==0)=NaN;
for m=2:mmax
    switch dpuopt
        case{'mean'}
            dp=0.5*(z(m,1)+z(m-1,1));
        case{'min'}
            dp=max(z(m,1),z(m-1,1));
        case{'upw','mean_dps','mor'}
            dp=zz(m,2);
    end
    dpbsouth(m)=dp;
    if ~isnan(dp) && dp<zmax
        ioksouth(m)=1;
    end
end
% North
ioknorth=zeros(1,mmax);
dpbnorth=ioknorth;
dpbnorth(dpbnorth==0)=NaN;
for m=2:mmax
    switch dpuopt
        case{'mean'}
            dp=0.5*(z(m,nmax)+z(m-1,nmax));
        case{'min'}
            dp=max(z(m,nmax),z(m-1,nmax));
        case{'upw','mean_dps','mor'}
            dp=zz(m,nmax);
    end
    dpbnorth(m)=dp;
    if ~isnan(dp) && dp<zmax
        ioknorth(m)=1;
    end
end
% East
iokeast=zeros(1,nmax);
dpbeast=iokeast;
dpbeast(dpbeast==0)=NaN;
for n=2:nmax
    switch dpuopt
        case{'mean'}
            dp=0.5*(z(1,n)+z(1,n-1));
        case{'min'}
            dp=max(z(1,n),z(1,n-1));
        case{'upw','mean_dps','mor'}
            dp=zz(2,n);
    end
    dpbeast(n)=dp;
    if ~isnan(dp) && dp<zmax
        iokeast(n)=1;
    end
end
% West
iokwest=zeros(1,nmax);
dpbwest=iokwest;
dpbwest(dpbwest==0)=NaN;
for n=2:nmax
    switch dpuopt
        case{'mean'}
            dp=0.5*(z(mmax,n)+z(mmax,n-1));
        case{'min'}
            dp=max(z(mmax,n),z(mmax,n-1));
        case{'upw','mean_dps','mor'}
            dp=zz(mmax,n);
    end
    dpbwest(n)=dp;
    if ~isnan(dp) && dp<zmax
        iokwest(n)=1;
    end
end

% Add dummy points
ioksouth=[ioksouth 0];
ioknorth=[ioknorth 0];
iokeast=[iokeast 0];
iokwest=[iokwest 0];
dpbsouth=[dpbsouth NaN];
dpbnorth=[dpbnorth NaN];
dpbeast=[dpbeast NaN];
dpbwest=[dpbwest NaN];

nb=0;

% Now let's find the sections

% South
[mstart,mend]=find_sections(ioksouth,dpbsouth,maxlength,stdautolength);
nd=0;
for ib=1:length(mstart)
    nb=nb+1;
    nd=nd+1;
    openBoundaries(nb).M1=mstart(ib);
    openBoundaries(nb).M2=mend(ib);
    openBoundaries(nb).N1=1;
    openBoundaries(nb).N2=1;
    openBoundaries(nb).name=[bndnames{1} num2str(nd,'%0.2i')];
end

% North
[mstart,mend]=find_sections(ioknorth,dpbnorth,maxlength,stdautolength);
nd=0;
for ib=1:length(mstart)
    nb=nb+1;
    nd=nd+1;
    openBoundaries(nb).M1=mstart(ib);
    openBoundaries(nb).M2=mend(ib);
    openBoundaries(nb).N1=nmax+1;
    openBoundaries(nb).N2=nmax+1;
    openBoundaries(nb).name=[bndnames{2} num2str(nd,'%0.2i')];
end

% East
[mstart,mend]=find_sections(iokeast,dpbeast,maxlength,stdautolength);
nd=0;
for ib=1:length(mstart)
    nb=nb+1;
    nd=nd+1;
    openBoundaries(nb).M1=1;
    openBoundaries(nb).M2=1;
    openBoundaries(nb).N1=mstart(ib);
    openBoundaries(nb).N2=mend(ib);
    openBoundaries(nb).name=[bndnames{3} num2str(nd,'%0.2i')];
end

% West
[mstart,mend]=find_sections(iokwest,dpbwest,maxlength,stdautolength);
nd=0;
for ib=1:length(mstart)
    nb=nb+1;
    nd=nd+1;
    openBoundaries(nb).M1=mmax+1;
    openBoundaries(nb).M2=mmax+1;
    openBoundaries(nb).N1=mstart(ib);
    openBoundaries(nb).N2=mend(ib);
    openBoundaries(nb).name=[bndnames{4} num2str(nd,'%0.2i')];
end

function [m1,m2]=find_sections(iok,dp,maxlength,stdautolength)

m1=[];
m2=[];

mmax=length(iok)-1;
nb=0;
m=2;
while m<=mmax
    %
    % New boundary section
    %
    mstart=0;
    mend=0;
    %
    while m<=mmax
        %
        % First find first wet point
        %
        if iok(m) && iok(m+1) % This point is okay and the next one as well (we don't want boundary sections of one grid cell)
            nb=nb+1;
            mstart=m;
            break
        else
            % Go to next point
            m=m+1;
        end
    end
    %
    if mstart>0
        %
        % Find end point of boundary section
        %
        while m<=mmax
            %
            m=m+1; % This ensures that all boundary sections are at least 2 grid cells long
            %
            % Compute standard deviation of depth in this section plus one cell
            %
            alldepths=dp(mstart:m+1); % Vector of all depths along this boundary section
            alldepths=alldepths(~isnan(alldepths));
            stdreldepths=std(alldepths/mean(alldepths)); % Relative depths
            %
            if stdreldepths>stdautolength || m-mstart+1==maxlength || ~iok(m+1) % Check that standard deviation of relative depths does not exceed threshold
                %
                % End of boundary section due to:
                %
                % - strong bathymetry variation,
                % - max length reach, or
                % - next cell is dry
                %
                % However, if the next cell is okay, and cell after that
                % is not, we want to include the next cell as well (otherwise we'd end up with a section of only one grid cell)
                %
                if iok(m+1) && ~iok(m+2)
                    mend=m+1;
                    m=m+1;
                else
                    mend=m;
                end
                %
                m=m+1;
                %
                % End point of section found, so leave while loop
                %
                break
                %
            end            
        end
        %
        m1(nb)=mstart;
        m2(nb)=mend;
        %
    end
end
