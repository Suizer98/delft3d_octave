function Tout = time_interp(T,type)
% TIME_INTERP  Round towards minus infinity.
%
%   TIME_INTERP(T,'hour') rounds the elements of T to the nearest
%   hour.
%   TIME_INTERP(T,'minute') rounds the elements of T to the nearest
%   minute.
%   TIME_INTERP(T,'second') rounds the elements of T to the nearest
%   second.
%   The default is 'hour'
%
%   See also TIME_FLOOR, TIME_CEIL.

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Sep-25 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com

if nargin<2
    type = 'hour';
end

switch type
    case 'hour'
          t = 24;          
    case 'minute'
          t = 24*60;
    case 'second'
          t = 24*60*60;
end

% floor
Tout = T -((.5/t)-rem(T,.5/t));
Tout = Tout - rem(Tout,1/t);

