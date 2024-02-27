function [U1, V1] = rotatevector(u0,v0,a);
%ROTATEVECTOR   Rotatation in rad of a vector
%
%  [U1 V1] = rotatevector (u0,v0,angle) % angle in degrees radians
%
%  Rotates vector (u0,v0) to vector (u1,v1) over angle 
%  (angle defined positive anti-clockwise) in a constant
%  cartesian system. u0,v0 should have the same size. angle can 
%  either be a scalar or have the same size as (u0,v0). Likewise
%  (u0,v0) can be a scalar and angle can be an array.
%
%  This function can also be used to reproject the same vector (u0,v0)
%  defined on one cartesian grid0 to another cartesian grid1 which is rotated
%  with respect to grid1. In this case the vector itself does not change
%  in global coordinates but the grid definition rotates. Here use -angle.
%
%         V0
%         ^
%         |      U1
%  V1     |     /   
%     \   |   / \ a = angle (positive anti-clockwise)
%       \ | /    |
% --------+-------->---------> U0
%        /|\
%      /  |  \
%    /    |    \
%
%  N.B. angle given in radians,  for degrees: angle*pi/180 or rotatevector
%
%         ____        ____
%  Method:Unew =  M * uold;
%  _  _       _                         _     _  _
% | U2 |  =  | cos(angle)   - sin(angle) |   | u1 |;
% |    |     |                           | * |    |
% |_V2_|  =  |_sin(angle)   + cos(angle)_|   |_v1_|; 
%
% example: rotate a wind-vane over 90 degrees from E to N (data changes)
%
%   [u1,v1]=rotatevector(1,0,pi/2)  %  = [0, 1]
%
% example: describe the a stagnant wind vane pointing E in a 90 degrees
% rotated coordinate system (data does not change, onlt it's description)
%
%   [u1,v1]=rotatevector(1,0,-pi/2) %  = [0,-1]
%

% See also: cart2pol, pol2cart, rotatevectord

%13-9-2004

%method = 1;

% $Id: rotatevector.m 14334 2018-05-15 15:16:33Z bartgrasmeijer.x $
% $Date: 2018-05-15 23:16:33 +0800 (Tue, 15 May 2018) $
% $Author: bartgrasmeijer.x $
% $Revision: 14334 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_fun/rotatevector.m $
% $Keywords: $


%if method==1
   U1 = cos(a) .* u0 - sin(a) .* v0;
   V1 = sin(a) .* u0 + cos(a) .* v0;

%elseif method==2

   % slower
   %tic
   %[TH0,R0] = cart2pol(u0,v0);
   % TH1     = + a + TH0 ;
   %[U1 ,V1] = pol2cart(TH1,R0)
   %toc

%elseif method==2

   %% Method below is almost 2 times as slow
   %% - - - - - - - - - - - - - - - - - - - 
   %tic
   %M   = [cos(a),  - sin(a) 
   %       sin(a),  + cos(a)]
   %       
   %UV1 = M*[u0(:) v0(:)];
   %U1  = UV1(1,:)
   %V1  = UV1(2,:)
   %toc

%end
%% EOF
