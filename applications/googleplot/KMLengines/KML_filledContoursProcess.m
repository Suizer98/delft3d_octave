function [latC,lonC,zC,contour] = KML_filledContoursProcess(OPT,E,C)
%KML_FILLEDCONTOURSPROCESS   subsidiary of KMLcontourf
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = KML_filledContoursProcess(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   KML_filledContoursProcess
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Thijs
%
%       <EMAIL>	
%
%       <ADDRESS>
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 21 Apr 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: KML_filledContoursProcess.m 4894 2011-07-21 20:47:45Z boer_g $
% $Date: 2011-07-22 04:47:45 +0800 (Fri, 22 Jul 2011) $
% $Author: boer_g $
% $Revision: 4894 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLengines/KML_filledContoursProcess.m $
% $Keywords: $

%% pre allocate, find dimensions

max_size = 1;
jj = 1;ii = 0;
while jj<size(C,2)
    ii = ii+1;
    max_size = max(max_size,C(2,jj));
    jj = jj+C(2,jj)+1;
end
contour.n      = ii;
latC           = nan(max_size,contour.n);
lonC           = nan(max_size,contour.n);
zC             = nan(max_size,contour.n);
contour.level  = nan(1,contour.n);
contour.begin  = nan(3,contour.n);
contour.end    = nan(3,contour.n);
contour.closed = false(1,contour.n);
jj = 1;ii = 0;

%% Assign data from C to contours
while jj<size(C,2)
    ii = ii+1;
    contour.level(1,ii) = C(1,jj);
    latC(1:C(2,jj),ii)   = C(1,jj+1:jj+C(2,jj));
    lonC(1:C(2,jj),ii)   = C(2,jj+1:jj+C(2,jj));
    contour.begin(:,ii) = [C(1,jj+1)      ,C(2,jj+1)      ,C(1,jj)];
    contour.end(:,ii)   = [C(1,jj+C(2,jj)),C(2,jj+C(2,jj)),C(1,jj)];
    jj = jj+C(2,jj)+1;
end

zC(1:max_size,1:contour.n) = repmat(contour.level(1:contour.n),max_size,1);
zC(isnan(latC))            = nan;
contour.closed             = all(contour.begin==contour.end,1);
contour.open               = find(~contour.closed);
contour.toBeDeleted        = false(1,size(latC,2));
contour.usedAsUpperBnd     = false(1,size(latC,2));
contour.usedAsLowerBnd     = false(1,size(latC,2));

%% find crossings of edge and contours
Ecrossings = nan(size(E,1),2,numel(OPT.levels)+1);
for ii = 1:numel(OPT.levels)
    crossings = find(xor(E(1:end-1,3)<OPT.levels(ii),E(2:end,3)<OPT.levels(ii))&...
        E(1:end-1,4)==E(2:end,4));
    weighting = abs([E(crossings+1,3) E(crossings,3)] - OPT.levels(ii))./...
        repmat(abs(E(crossings,3) - E(crossings+1,3)),1,2);
    Ecrossings(crossings,1,ii) = sum([E(crossings,1) E(crossings+1,1)].*weighting,2);
    Ecrossings(crossings,2,ii) = sum([E(crossings,2) E(crossings+1,2)].*weighting,2);
end


%% Add all crossings from edge and contour as extra coordinates to the edge 
F = nan(size(E,1)+sum(sum(~isnan(squeeze(Ecrossings(:,1,:))))),7);
kk=0;
for ii = 1:size(E,1)
    kk = kk+1;
    F(kk,1:5)= E(ii,:);
    if any(~isnan(squeeze(Ecrossings(ii,1,:))))
        jj = find(~isnan(squeeze(Ecrossings(ii,1,:))))';
        if E(ii,3) > E(ii+1,3)
            jj = fliplr(jj);
        end
        for ll = jj
            kk = kk+1;
            F(kk,1) = Ecrossings(ii,1,ll);%assign x
            F(kk,2) = Ecrossings(ii,2,ll);% assign y
            F(kk,3) = OPT.levels(ll);% assign z
            F(kk,4) = E(ii,4);
            F(kk,5) = E(ii,5);
            %  find the crossed contour
            iContour = abs(contour.begin(1,contour.open)-F(kk,1))<OPT.verySmall&...
                abs(contour.begin(2,contour.open)-F(kk,2))<OPT.verySmall;
            % if no matching coordinates are found at the contour
            % begin, then also look at the ends
            if ~any(iContour)
                iContour = abs(contour.end(1,contour.open)-F(kk,1))<OPT.verySmall&...
                    abs(contour.end(2,contour.open)-F(kk,2))<OPT.verySmall;
                F(kk,7) = 0;
            else
                F(kk,7) = 1;
            end
            if sum(iContour == 1)~=1
                 error %#ok<LTARG> % thies means something went wrong, debugging needed...
            end
            F(kk,6) = contour.open(iContour);
        end
    end
end
E = F;
clear F
if OPT.debug
    tricontour3(tri,lon,lat,z,OPT.levels)
    hold on
    for ii=1:E(end,4)
        jj = find(E(:,4)==ii&isnan(E(:,6)));
        plot3(E(jj,2),E(jj,1),E(jj,3),'r.');
    end
    for ii=1:E(end,4)
        jj = find(E(:,4)==ii&~isnan(E(:,6)));
        plot3(E(jj,2),E(jj,1),E(jj,3),'k*');
        h = text(E(jj,2),E(jj,1),reshape(sprintf('%5d',E(jj,6)),5,[])');
        set(h,'color','r','FontSize',6,'VerticalAlignment','top')
    end
    h = text(E(:,2),E(:,1),reshape(sprintf('%5d',1:size(E,1)),5,[])');
    set(h,'color','b','FontSize',6,'VerticalAlignment','bottom')
    view([0 90])
end

% The edge variable E now looks like this:
% E = 1 | 2 | 3 | 4       | 5              | 6                 | 7            | 8 
%     x | y | z | loop_nr | outer_boundary | cross contour ind | begin or end | section is used

%% 
E(:,8) = 0;
iNewContour = contour.n;
for ii =1:E(end,4)
    iE = E(:,4)==ii;
    E(find(iE==1,1,'last'),8) = 2;
    
    % for mod looping
    nn      = find( E(:,4)==ii,1,'first');
    kk      = find( E(:,4)==ii,1, 'last');
    
    while any(E(iE,8)<2) % there are non used sections in E2
        iE0 = find(E(iE,8)<2,1,'first')-1+nn; % start somewhere
        iNewContour = iNewContour+1;
        if iNewContour>contour.n
            latC            = [latC nan(size(latC,1),20)]; %#ok<AGROW>
            lonC            = [lonC nan(size(latC,1),20)]; %#ok<AGROW>
            zC              = [zC   nan(size(latC,1),20)]; %#ok<AGROW>
            contour.level  = [contour.level nan(1,20)];
            contour.n      = contour.n+20;
        end
      
        contour.level(iNewContour) = max([max(OPT.levels(OPT.levels<E(iE0,3))) OPT.levels(1)]);
        
        jNewContour = 0;
        
        iE1 = iE0;
        
        if E((mod(iE1+1-nn,kk-nn)+nn),8)<2;
            walk = 1;
        else
            walk = -1;
        end
       
        while jNewContour == 0 || iE1 ~= iE0
            edgeAddedAsLast = true;
            % add edge coordinates
            while jNewContour == 0 || (iE1 ~= iE0 && isnan(E(iE1,6)))
                E(iE1,8) = 2;
                jNewContour = jNewContour +1;
                if jNewContour>size(latC,1)
                    latC            = [latC; nan(5,size(zC,2))]; %#ok<AGROW>
                    lonC            = [lonC; nan(5,size(zC,2))]; %#ok<AGROW>
                    zC              = [zC  ; nan(5,size(zC,2))]; %#ok<AGROW>
                end
                latC(jNewContour,iNewContour) = E(iE1,1);
                lonC(jNewContour,iNewContour) = E(iE1,2);
                zC  (jNewContour,iNewContour) = E(iE1,3);
                
                iE1 = mod(iE1+walk-nn,kk-nn)+nn;
            end

            % add contour coordinates
            if jNewContour == 0 || iE1 ~= iE0
                edgeAddedAsLast = false;
                E(iE1,8) = E(iE1,8)+1;
                iContour = E(iE1,6);
                % indices of the coordinate to be added
                addContourCoordinates = find(~isnan(latC(:,iContour)));
                if ~E(iE1,7); 
                    addContourCoordinates = flipud(addContourCoordinates); 
                end

                % adjust indices
                jNewContour = jNewContour+1:jNewContour+numel(addContourCoordinates);

                % mark that contour as 'to be deleted'
                contour.toBeDeleted(iContour) = true;

                if jNewContour(end)>size(latC,1)
                    latC            = [latC; nan(length(jNewContour),size(zC,2))]; %#ok<AGROW>
                    lonC            = [lonC; nan(length(jNewContour),size(zC,2))]; %#ok<AGROW>
                    zC              = [zC  ; nan(length(jNewContour),size(zC,2))]; %#ok<AGROW>
                end

                % add the contour
                latC(jNewContour,iNewContour) = latC(addContourCoordinates,iContour);
                lonC(jNewContour,iNewContour) = lonC(addContourCoordinates,iContour);
                zC  (jNewContour,iNewContour) =             contour.level(iContour);           

                jNewContour = jNewContour(end);
                
                % find where to continue
                iE1 = find(E(:,6) ==  E(iE1,6) & E(:,7)+ E(iE1,7)==1,1);
                E(iE1,8) = E(iE1,8)+1;
                
                if iE1 ~= iE0
                    iE1 = mod(iE1+walk-nn,kk-nn)+nn;
                end
            end
        end
        if edgeAddedAsLast
            jNewContour = jNewContour +1;
            if jNewContour>size(latC,1)
                latC            = [latC; nan(1,size(zC,2))]; %#ok<AGROW>
                lonC            = [lonC; nan(1,size(zC,2))]; %#ok<AGROW>
                zC              = [zC  ; nan(1,size(zC,2))]; %#ok<AGROW>
            end
            latC(jNewContour,iNewContour) = E(iE1,1);
            lonC(jNewContour,iNewContour) = E(iE1,2);
            zC  (jNewContour,iNewContour) = E(iE1,3);
        end
    end
end

%% Delete all duplicate data, and the data from contoursToBeDeleted
contour.toBeDeleted(all(isnan(latC)))=true;
latC(:,contour.toBeDeleted) = [];
lonC(:,contour.toBeDeleted) = [];
zC  (:,contour.toBeDeleted) = [];

%% trim superfluous nan values from the coordinate arrays
zC  (all(isnan(lonC),2),:) = [];
latC(all(isnan(lonC),2),:) = [];
lonC(all(isnan(lonC),2),:) = [];

contour.level(contour.toBeDeleted) = [];
contour.n = size(latC,2);

