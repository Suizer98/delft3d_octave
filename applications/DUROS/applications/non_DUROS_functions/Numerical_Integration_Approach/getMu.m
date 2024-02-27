function mu = getMu(WL_t, Relation)
%GETMU   routine to compute mean wave height or wave period based on water level
%
%   Routine computes mean wave height based on the relation between
%   muHsig_t and WL_t as used in Van de Graaff (1984) or using a
%   combination of a polynomal of degree 2 and degree 1 (above a specified
%   value of WL_t). Routine is also applicable to compute the mean wave
%   period; this is only possible by using a combination of a polynomal of
%   degree 2 and degree 1 (above a specified value of WL_t)
%
%   syntax:
%   mu = getMu(WL_t, Relation)
%
%   input:
%       WL_t      = Water level [m] ('Rekenpeil')
%       Relation  = (optional) 2*3 matrix giving the relation between WL_t and mu (either muHsig_t or muTp_t);
%           The first row should contain the three coefficients of a polynomal of degree 2;
%           for values of WL_t larger than Relation(2,1), a linear relation
%           given by Relation(2,2:3) will be used.
%           If no relation is given, the relation between muHsig_t and WL_t
%           as used in Van de Graaff (1984) will be applied.
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

if nargin == 1 %|| isemtpy(Relation) % no Relation given: use relation between muHsig_t and WL_t as used in Van de Graaff (1984)
    mu = 4.82 + .6*WL_t; % WL_t > NAP + 7m
    mu(WL_t < 7) = mu(WL_t < 7) - (.0063*((7-WL_t(WL_t < 7)).^3.13)); % between NAP + 3m and NAP + 7m
%     mu(WL_t < 3) = NaN; %#ok<NASGU> % relation only holds for water levels above NAP + 3m
else
    mu = zeros(size(WL_t,1), size(WL_t,2));
    mu(WL_t <= Relation(2,1)) =  Relation(1,1)*WL_t(WL_t <= Relation(2,1)).^2 + Relation(1,2)*WL_t(WL_t <= Relation(2,1)) + Relation(1,3);
    mu(WL_t > Relation(2,1)) = Relation(2,2)*WL_t(WL_t > Relation(2,1)) + Relation(2,3); %#ok<NASGU>
end