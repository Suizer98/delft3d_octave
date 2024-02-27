function [xRD,yRD] = jarkus_rsp2xy(varargin)
%jarkus_rsp2xy   transform RijksStrandPalen coordinates to RD coordinates
%    
% depending on inputs arguments, function will be:
%    nargin = 3: [xRD,yRD] = jarkus_rsp2xy(cross_shore,areacode,alongshore);
%    nargin = 4: [xRD,yRD] = jarkus_rsp2xy(x0,y0,alpha,xRSP); 
%
%   [xRD,yRD] = jarkus_rsp2xy(cross_shore,areacode,alongshore)
%   
%    cross_shore: cross shore coordinate (distance from RSP line 
%    	          (rijksstrandpalen lijn), positive in seaward direction) 
%    areacode:    area code of transect Dutch: 'Kustvak'. 
%    alongshore:  Alongshore distance of transect in DECAMETRES, consistent
%                 common practice (transect number). The beach pole of 
%                 Egmond is beachpole 38, beacuse it is 38km from Den 
%                 Helder. It's alongshore number is 3800. Must be either a 
%                 single value or an array of size cross_shore. 
%
%   [xRD,yRD] = jarkus_rsp2xy(x0,y0,alpha,xRSP)
%       
%        x0/y0:   zero point coordinates of transect; can be either single
%                 values, or arrays of the same length as xRSP.
%        alpha:   orientation of the transect (direction of positive xRSP).
%                 Can be either single values, or array of the same length
%                 as xRSP. 
%
%  !  Beware of certain old transects where alpha is based on a 
%  !  400 degree system in stead of 'normal' 360 degrees
%
% See also: convertCoordinates, jarkus_raaien

% TO DO: rename to rws_raai2xy
% TO DO implement next to exact also closest

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Thijs Damsma
%
%       Thijs.Damsma@deltares.nl
%
%       Deltares
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

% $Id: jarkus_rsp2xy.m 2139 2010-01-12 14:15:53Z boer_g $
% $Date: 2010-01-12 22:15:53 +0800 (Tue, 12 Jan 2010) $
% $Author: boer_g $
% $Revision: 2139 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/RijksStrandPalen/jarkus_rsp2xy.m $
% $Keywords: $

OPT.log    = 0;
OPT.method = 'nearest'; % 'exact','nearest','linear'
OPT.rmax   = 600;

%% get data from database
if nargin == 3;
    
    %% assign varargin

       cross_shore = varargin{1};
       areacode    = varargin{2};
       alongshore  = varargin{3};
    
    %% load raai data
    
       D = jarkus_raaien;

    %% find raaien that match specified request
    %  set rest to nan
    
       alpha = nan(size(alongshore));
       x0    = nan(size(alongshore));
       y0    = nan(size(alongshore));
       for ii = 1:numel(alongshore)
          ind = find(D.kustvak  ==     areacode(ii)&...
                     D.metrering==10*alongshore(ii));
          if ~isempty(ind)
             alpha(ii) = D.angle(ind);
             x0   (ii) = D.x    (ind);
             y0   (ii) = D.y    (ind);
          else
          
             if strcmpi(OPT.method,'exact')
                dprintf(OPT.log,'could not convert item %0.4d section %0.2d, transect number %06.2f \n', ii, areacode(ii), alongshore(ii))
             elseif strcmpi(OPT.method,'nearest')
                ind     =     find(D.kustvak  ==     areacode(ii));
               [r,ind2] =  min(abs(D.metrering(ind)-10*alongshore(ii)));
                if r < OPT.rmax
                dprintf(OPT.log,'could not convert item %0.4d section %0.2d, transect number %06.2f exactly, used nearest\n', ii, areacode(ii), alongshore(ii))
                alpha(ii) = D.angle(ind(ind2));
                x0   (ii) = D.x    (ind(ind2));
                y0   (ii) = D.y    (ind(ind2));
                else
                dprintf(OPT.log,'could not convert item %0.4d section %0.2d, transect number %06.2f, distance %f > %f \n', ii, areacode(ii), alongshore(ii),r,OPT.rmax);
                end
             elseif strcmpi(OPT.method,'linear')
             end
             
          end
       end
    
else
    %assign varargin
    x0          = varargin{1}; 
    y0          = varargin{2};
    alpha       = varargin{3};
    cross_shore = varargin{4};
end

%% convert coordinates

xRD = x0 + cross_shore.*sind(alpha);
yRD = y0 + cross_shore.*cosd(alpha);

%% EOF

