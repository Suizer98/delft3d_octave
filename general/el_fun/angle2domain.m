function out = angle2domain(in,rangemin, rangemax,varargin);
%ANGLE2DOMAIN   truncates ngle to domain
%
% out = angle2domain(in,rangemin, rangemax)
%
% Adds an integer number of range = rangemax-rangemin
% to input, untill all output values are within the
% range [rangein, rangeout];
%
% Works for all circle units, E.g.:
% [0 -180 0] =         angle2domain([0 180 360],-180,180)
% [0 -180 0] = rad2deg(angle2domain([0 pi 2*pi],-pi ,pi ))
%
% angle2domain(in,rangemin,rangemax)
% angle2domain(in,rangemin,rangemax,1)
%    sets all input elements with value equal to
%    rangemin or rangemax get rangeMAX (default).
% angle2domain(in,rangemin,rangemax,0)
%    sets all input elements with value equal to
%    rangemin or rangemax get rangeMIN.
%
% See also: DEG2RAD, RAD2DEG, UNWRAP, DOMAIN2ANGLE

% © G.J. de Boer
% Delft University of Technology Nov 2004

if nargin==4
   shift = varargin{1};
else
   shift = 1; % rangeMAX (default)
end   

range = rangemax - rangemin;
out   = rangemin + mod(in-shift-rangemin,range)+shift;


% FUTURE IS THAT POSSIBLE ? make sure there not a full range gaP BETWEEN ADJECENT POINTS
% If either 
% rangemin =-Inf or 
% rangemax = Inf, all input values are
% concatenated to one monotone increasing 
% vector with rangemax and rangemin
% respectively 
