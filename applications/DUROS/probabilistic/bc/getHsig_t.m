function Hsig_t = getHsig_t(WL_t, a, b, c, d, e)
%GETHSIG_T   routine to compute mean wave height or wave period based on water level
%
%   Routine computes mean wave height based on a relation between
%   Hsig_t and WL_t: Hsig_t = a+b*WL_t-c*(d-WL_t)^e
%
%   syntax:
%   Hsig_t = getHsig_t(WL_t, a, b, c, d, e)
%
%   input:
%       WL_t      = Water level [m] ('Rekenpeil')
%       a,b,c,d,e = coefficients in the relation
%
%   example:
%
%
%   See also
%
% -------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics 2004-2008 FOR INTERNAL USE ONLY
% Version:      Version 1.1, January 2008 (Version 1.0, December 2007)
% By:           <C.(Kees) den Heijer (email: C.denHeijer@tudelft.nl)>                                                            
% -------------------------------------------------------------

%%
% if nargin == 1 %|| isemtpy(Relation) % no Relation given: use relation between muHsig_t and WL_t as used in Van de Graaff (1984)
%WL_t(WL_t<3) = 3;
Hsig_t = a + b*WL_t; % WL_t > NAP + d [m]
Hsig_t(WL_t < d) = Hsig_t(WL_t < d) - (c*((d-WL_t(WL_t < d)).^e)); % between NAP + 3m and NAP + d [m]
%     mu(WL_t < 3) = NaN; %#ok<NASGU> % relation only holds for water levels above NAP + 3m
% else
%     mu = zeros(size(WL_t,1), size(WL_t,2));
%     mu(WL_t <= Relation(2,1)) =  Relation(1,1)*WL_t(WL_t <= Relation(2,1)).^2 + Relation(1,2)*WL_t(WL_t <= Relation(2,1)) + Relation(1,3);
%     mu(WL_t > Relation(2,1)) = Relation(2,2)*WL_t(WL_t > Relation(2,1)) + Relation(2,3); %#ok<NASGU>
% end