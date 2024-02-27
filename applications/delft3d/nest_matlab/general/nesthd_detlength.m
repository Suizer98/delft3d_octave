function [dist] = nesthd_detlength(x_from,y_from,x_to,y_to,varargin)

%   nesthd_detlength, computes lengths from "from" to "to"
%   from might be a vector
%
%   Optional <keyword>,<value> pair
%            'Spherical' which is either false (default) or true

OPT.Spherical = false;
OPT           = setproperty(OPT,varargin);

if ~OPT.Spherical

    %% Cartesian coordinates
    dist = sqrt((x_from - x_to).^2 + (y_from - y_to).^2 );
else

    %% Spherical coordinates, use native matlab functions
    x_to (2:length(x_from)) = x_to(1);
    y_to (2:length(x_from)) = y_to(1);

    pnt_1 = [y_from ; x_from];
    pnt_2 = [y_to   ; x_to];

    dist  = geo.deg2km(geo.distance(pnt_1',pnt_2'))*1000.;

 %   no_pnt        = length(x_from);
 %   for i_pnt = 1: no_pnt
 %       dist(i_pnt) = deg2km(distance(x_from(i_pnt),y_from(i_pnt),x_to,y_to))/1000.;
 %   end
end

