function [blok, I] = blok_select(blok, varargin)
% Select Dia blocks with specified parameter-value pairs.
% 
% CALL:
%  blok = blok_select(blok, varargin)
% 
% INPUT:
%  blok: structarray with dia blokken
%  varargin: parameter-value pairs, e.g. 'sRkstyp', 'TE'
% 
% OUTPUT:
%  blok: selected blokken
%  I: index of selected blokken
% 
% EXAMPLE:
%  blok = repmat(emptyblok,2,1);
%  blok(1).W3H.sParcod = 'Hm0';
%  blok(2).W3H.sParcod = 'WATHTE';
%  [blok, I] = blok_select(blok, 'sParcod', 'WATHTE');
%  find(I)

I = true(length(blok),1);
for i=1:2:length(varargin)
    prop = varargin{i};
    value = varargin{i+1};
    
    admin = getAdministrationBlok(blok, prop);
    
    if isnumeric(value)
        values = cat(1,admin.(prop));
        I = I & ismember(values, value);
    else
        values = {admin.(prop)};
        I = I & ismember(values(:), value);
    end
end

blok = blok(I);

%__________________________________________________________________________
function admin = getAdministrationBlok(blok, prop)
% getAdministrationBlok -

if isfield(emptyW3H, prop)
    admin = 'W3H';
elseif isfield(emptyRKS, prop)
    admin = 'RKS';    
end

admin = cat(1,blok.(admin));

assertm(length(blok) == length(admin), 'Blok lengte niet gelijk aan administratieblok lengte');