function [segnr,x,y] = delwaq_xy2segnr(varargin)
%DELWAQ_XY2SEGNR Read Delwaq LGA files and gives back corresponding segment
%   number for x and y coordenates
%
%   SEGNR = DELWAQ_XY2SEGNR(LGAFILE,X,Y,TYPE)
%
%   SEGNR = DELWAQ_XY2SEGNR(...,TYPE)
%   TYPE = 'LL' for lat lon coordenates
%   If TYPE is not provided then TYPE = 'XY'
%
%   See also: DELWAQ, DELWAQ_CONC, DELWAQ_RES, DELWAQ_TIME, DELWAQ_STAT, 
%             DELWAQ_INTERSECT

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Jul-12 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------

if nargin<4
    if   isstruct(varargin{1}), gridStruct = varargin{1}; 
    elseif ischar(varargin{1}), gridStruct = delwaq('open',varargin{1});
    end
    
    x = varargin{2};
    y = varargin{3};
    type = 'XY';
else
    if   isstruct(varargin{1}), gridStruct = varargin{1}; 
    elseif ischar(varargin{1}), gridStruct = delwaq('open',varargin{1});
    end
    
    x = varargin{2};
    y = varargin{3};
    type = varargin{4};
end

x = x(:);
y = y(:);

if strcmpi(type,'LL'),   [x, y] =  convertCoordinates(x,y,'CS1.code',4326,'CS2.code',28992); end

[Xcen Ycen] = corner2center(gridStruct.X,gridStruct.Y);

temp = gridStruct.Index(2:end,2:end,1);
the_source = [Xcen(:),Ycen(:), temp(:)];
clear temp
the_source(isnan(the_source(:,1)) | isnan(the_source(:,2)) | the_source(:,3)<=0,:) = [];
segnr  = naninterp(the_source(:,1),the_source(:,2),the_source(:,3),x,y,'nearest');

inot = (segnr<=0);
segnr(inot) = nan;

