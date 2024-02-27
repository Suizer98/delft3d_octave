function Tout = time_ceil(T,type)
% TIME_CEIL  Round towards plus infinity.
%
%   TIME_CEIL(T,'hour') rounds the elements of T to the nearest
%   hour.
%   TIME_CEIL(T,'minute') rounds the elements of T to the nearest
%   minute.
%   TIME_CEIL(T,'second') rounds the elements of T to the nearest
%   second.
%   The default is 'hour'
%
%   See also TIME_FLOOR, TIME_ROUND.

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Sep-25 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com

if nargin<2
    type = 'hour';
end

switch type
    case 'day'
          t = 1;          
    case 'hour'
          t = 24;          
    case 'minute'
          t = 24*60;
    case 'second'
          t = 24*60*60;
end

% ceil
Tout = T +((1/t)-rem(T,1/t));
Tout = Tout - rem(Tout,1/t);

