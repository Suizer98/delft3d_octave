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
%$Id: dv_cross_section.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/dv_cross_section.m $
%
%dv_cross_section compute the coefficient resulting from the derivative of the cross section:
%  dAf/dx = a1*(dh/dx) + a2(h)
%The computation is performed in different parts for the main channel and flood planes seperately.
%
%[a1, a2, I_a1, I_a2, II_a1, II_a2, III_a1, III_a2] = dv_cross_section(input,x,hh,variable)
%
%INPUT:
%   -x = should be a node identifier
%   -h = vector with h(1,x) the location at x!
%
%OUTPUT:
%   -
%
%HISTORY:
%170404
%   -V. Added the header because Liselot does not follow the protocol :D
%

function [a1, a2, I_a1, I_a2, II_a1, II_a2, III_a1, III_a2] = dv_cross_section(input,x,hh,variable)


%% Check wheter we are dealing with a compound channel or a rectangular one;
% and whether the cross section is constant in space

% Check whether we have a constant or spatially varying cross-section;
% Define new x-coordinate dependent on the change of cross-section or not;
if numel(input.grd.B(1,:))==1
    xb = 1;
else
    xb = x;
end

% Initialize parameters
h_l = input.grd.Bparam(1,xb);
h_r = input.grd.Bparam(3,xb);
B_l = input.grd.Bparam(2,xb);
B_r = input.grd.Bparam(4,xb);

Bfl = input.grd.B(2,xb);
Bfr = input.grd.B(3,xb);

if numel(hh)==1
    h = hh;
else
    h = hh(1,x);
end
    
switch variable
    case 'Af'
        %% Contribution to parameters for each of the subparts
        % main channel
        Ia1_a1 = input.grd.B(1,xb);
        Ia1_a2 = dv_cross_aux(input,x,'B_main');

        if strcmp(input.grd.crt,'rectangular')==1;
            Ib1_a1 = 0;
            Ib1_a2 = 0;
            Ib2_a1 = 0;
            Ib2_a2 = 0;
            Ic1_a1 = 0;
            Ic1_a2 = 0;
            Ic2_a1 = 0;
            Ic2_a2 = 0;
            II_a1 = 0;
            II_a2 = 0;
            III_a1 = 0;
            III_a2 = 0;
        else
            % left indent 
            Ib1_a1 = 0.5*(1 - (h-h_l)./abs(h-h_l))*min(h,h_l)*B_l/h_l;
            Ib1_a2 = dv_cross_aux(input,x,'h_l') * 0.5*((1 - (h-h_l)./abs(h-h_l))*min(h,h_l)*B_l/h_l - min(h,h_l)^2/2*(B_l/h_l^2)) + ...
                0.5*dv_cross_aux(input,x,'B_l') * min(h,h_l)^2/(h_l);

            Ib2_a1 = 0.5*B_l*(1 + (h-h_l)/abs(h-h_l));
            Ib2_a2 = dv_cross_aux(input,x,'B_l')*0.5*(h- h_l+abs(h-h_l)) + ...
                dv_cross_aux(input,x,'h_l')*-0.5*B_l*(1+(h-h_l)/abs(h-h_l));

            %right indent
            Ic1_a1 = 0.5*(1 - (h-h_r)./abs(h-h_r))*min(h,h_r)*B_r/h_r;
            Ic1_a2 = dv_cross_aux(input,x,'h_r') * 0.5*((1 - (h-h_r)./abs(h-h_r))*min(h,h_r)*B_r/h_r - min(h,h_r)^2/2*(B_r/h_r^2)) + ...
                0.5*dv_cross_aux(input,x,'B_r') * min(h,h_r)^2/(h_r);

            Ic2_a1 = 0.5*B_r*(1 + (h-h_r)/abs(h-h_r));
            Ic2_a2 = dv_cross_aux(input,x,'B_r')*0.5*(h- h_r+abs(h-h_r)) + ...
                dv_cross_aux(input,x,'h_r')*-0.5*B_r*(1+(h-h_r)/abs(h-h_r));
       

            % check if wet:
            if h>h_l
                %left flood plain
                II_a1 = 0.5*Bfl*(1 + (h-h_l)/abs(h-h_l));
                II_a2 = dv_cross_aux(input,x,'Bfl')*0.5*(h- h_l+abs(h-h_l)) + ...
                    dv_cross_aux(input,x,'h_l')*-0.5*Bfl*(1+(h-h_l)/abs(h-h_l));
            else
                II_a1 = 0;
                II_a2 = 0;
            end

            if h>h_r
                %right flood plain
                III_a1 = 0.5*Bfr*(1 + (h-h_r)/abs(h-h_r));
                III_a2 = dv_cross_aux(input,x,'Bfr')*0.5*(h- h_r+abs(h-h_r)) + ...
                    dv_cross_aux(input,x,'h_r')*-0.5*Bfr*(1+(h-h_r)/abs(h-h_r));
            else
                III_a1 = 0;
                III_a2 = 0;
            end
        end

    case 'P'
        %% Contribution to parameters for each of the subparts
        % main channel
        Ia1_a1 = 0; 
        Ia1_a2 = dv_cross_aux(input,x,'B_main');

        % left indent 
        Ib1_a1 = sqrt(B_l^2+h_l^2)/(2*h_l)*(1- (h-h_l)./abs(h-h_l));
        Ib1_a2 = dv_cross_aux(input,x,'h_l') * (-sqrt(B_l^2+h_l^2)/(2*h_l)*(1- (h-h_l)./abs(h-h_l)) - min(h,h_l)/h_l*sqrt(B_l^2+h_l^2) + min(h,h_l)/sqrt(B_l^2+h_l^2)) + ...
            dv_cross_aux(input,x,'B_l') * (min(h,h_l)/(h_l*sqrt(B_l^2+h_l^2))*B_l);

        Ib2_a1 = 0;
        Ib2_a2 = 0;
        
        %right indent
        Ic1_a1 = sqrt(B_r^2+h_r^2)/(2*h_r)*(1- (h-h_r)./abs(h-h_r));
        Ic1_a2 = dv_cross_aux(input,x,'h_r') * (-sqrt(B_r^2+h_r^2)/(2*h_r)*(1- (h-h_r)./abs(h-h_r)) - min(h,h_r)/h_r*sqrt(B_r^2+h_r^2) + min(h,h_r)/sqrt(B_r^2+h_r^2)) + ...
            dv_cross_aux(input,x,'B_r') * (min(h,h_r)/(h_r*sqrt(B_r^2+h_r^2))*B_r);

        Ic2_a1 = 0;
        Ic2_a2 = 0;

        %left flood plain
        II_a1 = 0; % resolve later
        II_a2 = 0; 

        %right flood plain
        III_a1 = 0;
        III_a2 = 0;
end
        
        

%% Summation to obtain the total coefficients
%dAf/dx = a1 dh/dx + a2
I_a1 =Ia1_a1 + Ib1_a1 + Ib2_a1 + Ic1_a1 + Ic2_a1;
I_a2 =Ia1_a2 + Ib1_a2 + Ib2_a2 + Ic1_a2 + Ic2_a2;

a1 = I_a1 + II_a1 + III_a1;
a2 = I_a2 + II_a2 + III_a2;


end