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
%$Id: dv_cross_aux.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/dv_cross_aux.m $
%
%dv_cross_aux does this and that
%
%diff = dv_cross_aux(input, x, term)
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

function diff = dv_cross_aux(input, x, term)

switch term
    case 'B_main'
        var = input.grd.B(1,:);
    case 'B_l'
        var = input.grd.Bparam(2,:);
    case 'B_r'
        var = input.grd.Bparam(4,:);
    case 'Bfl'
        var = input.grd.B(2,:);
    case 'Bfr'
        var = input.grd.B(3,:);
    case 'h_l'
        var = input.grd.Bparam(1,:);
    case 'h_r'
        var = input.grd.Bparam(3,:);
end

%Add dummy cells;
%var = [var(1)-(var(2)-var(1)), var, var(end)+(var(end)-var(end-1))];

% Compute derivative
%try %centered
if x==1
    diff= (var(x+1)-var(x))/(input.grd.dx);
elseif x==numel(var)
    diff= (var(x)-var(x-1))/(input.grd.dx);
else
    diff= (var(x+1)-var(x-1))/(2*input.grd.dx);
end
%catch 
%    try %upstream 
%        diff= (var(x+1)-var(x))/(input.grd.dx);
%    catch
%        try %downstream
%            diff= (var(x)-var(x-1))/(input.grd.dx);
%        catch
%            %it should be a fixed with case
%            error('check dimensions of width');
%        end
%    end
%end      
end