%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16592 $
%$Date: 2020-09-17 01:32:43 +0800 (Thu, 17 Sep 2020) $
%$Author: chavarri $
%$Id: get_cross_section.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/get_cross_section.m $
%
%get_cross_section does this and that
%
%[T,I,II,III] = get_cross_section(input,x,h,variable)
%
%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%170404
%   -V. Added the header because Liselot does not follow the protocol :D
%

function [T,I,II,III] = get_cross_section(input,x,h,variable)
% OUTPUT: 
% P: wetted perimeter
% R: hydraulic radius
% Af: cross-sectional area for flow
% As: cross-sectional area for storage 
%  
% 1st column: total value
% 2nd column: main channel 
% 3rd column: first floodplain (left)
% 4rd column: second floodplain (right)
%

%% Replace by default values somehow
if nargin <2 %|| isnan(x)==1
    xb = 1;
elseif isnan(x)==1
    xb = 1:numel(h);
else
    xb = x;
end


%% Check whether h is a vector or a single value
%{
if numel(hh)==1
    h = hh;
else
    h = hh(1,x);
end
%}

%% Check wheter we are dealing with a compound channel or a rectangular one;
% and whether the cross section is constant in space
% Check whether we have a constant or spatially varying cross-section;
% Define new x-coordinate dependent on the change of cross-section or not;

if strcmp(input.grd.crt,'rectangular')==1;
    switch variable
        case 'P'
            T = input.grd.B(1,xb);    
        case 'Af'
            T = input.grd.B(1,xb).*h;
    end
    I = NaN;
    II = NaN;
    III = NaN;
else
    % Initialize parameters
    %h_l = input.grd.Bparam(1,xb);
    %h_r = input.grd.Bparam(3,xb);
    %B_l = input.grd.Bparam(2,xb);
    %B_r = input.grd.Bparam(4,xb);

    %Bm = input.grd.B(1,xb);
    %Bfl = input.grd.B(2,xb);
    %Bfr = input.grd.B(3,xb);

    h_ll = min(h,input.grd.Bparam(1,xb)); %becomes relevant when left flood plain is not in use
    B_ll = input.grd.Bparam(2,xb).*(h_ll./input.grd.Bparam(1,xb)); %idem
    h_rr = min(h,input.grd.Bparam(3,xb)); %becomes relevant when right flood plain is not in use
    B_rr = input.grd.Bparam(4,xb).*(h_rr./input.grd.Bparam(3,xb)); %idem

    switch variable
        case 'P'
            % Compute wetted perimeter
            Ia = input.grd.B(1,xb);
            Ib1 = sqrt(B_ll.^2+h_ll.^2);
            Ib2 = 0;
            Ic1 = sqrt(B_rr.^2+h_rr.^2);
            Ic2 = 0;
            I = Ia+Ib1+Ib2+Ic1+Ic2;
            II = (h>input.grd.Bparam(1,xb)).*(input.grd.B(2,xb)+max(h-input.grd.Bparam(1,xb),0));
            III = (h>input.grd.Bparam(3,xb)).*(input.grd.B(3,xb)+max(h-input.grd.Bparam(3,xb),0));

            T = I+II+III;

        case 'Af'
            % Compute cross sectional area (flow)
            Ia = input.grd.B(1,xb).*h;
            Ib1 = 0.5*B_ll.*h_ll;
            Ib2 = max(input.grd.Bparam(1,xb)-h,0).*B_ll;
            Ic1 = 0.5*B_rr.*h_rr;
            Ic2 = max(input.grd.Bparam(3,xb)-h,0).*+B_rr;
            I = Ia+Ib1+Ib2+Ic1+Ic2;
            II = max(h-input.grd.Bparam(1,xb),0).*input.grd.B(2,xb);
            III = max(h-input.grd.Bparam(3,xb),0).*input.grd.B(3,xb);

            T = I+II+III;

            %{
            % Compute cross sectional area (storage)
            Is = input.grd.B.type(1,xb).*(Ia + Ib1 + Ib2 + Ic1 + Ic2);  %main channel
            IIs = input.grd.B.type(2,xb).*II;
            IIIs = input.grd.B.type(3,xb).*III;
            T = T-Is-IIs-IIIs;
            I = I-Is;
            II = II-IIs;
            III = III-IIIs;
            %}
    end
end


end

