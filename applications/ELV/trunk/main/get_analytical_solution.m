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
%$Id: get_analytical_solution.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/get_analytical_solution.m $
%
%get_analytical_solution does this and that
%
%get_analytical_solution(folder_run)
%
%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%
function get_analytical_solution(folder_run)
% First created by L at 24082016
% 170126
%   L: nested in ELV

% try
%     version='2';
%     fprintf(fid_log,'get_analytical_solution version: %s\n',version);
% catch
% end


% Load boundary conditions and input data;
load(fullfile(folder_run,'Q.mat'));
load(fullfile(folder_run,'Qbk0.mat'));
load(fullfile(folder_run,'input.mat'));

Qbk = Qbk(1:end-1,:);
Q = Q(1:end-1);

% Rename 
cf = input.frc.Cf;
g = 9.81;
Dk = input.sed.dk;
Dg = max(Dk);
Ds = min(Dk);
Dref = 0.001;
B = input.grd.B;
R = 1.65;

Qbk0mean = mean(Qbk);
pg = Qbk0mean(1)/(Qbk0mean(1)+Qbk0mean(2));
AL = Qbk0mean(1)+Qbk0mean(2);

if input.tra.cr == 2 %EH
    w = 1;
    r = 0; 
    tau_ref = cf/0.05;
elseif input.tra.cr == 5 % GL
    w = input.tra.param(2);
    r = input.tra.param(1);
    tau_ref = input.tra.param(3);
end

% Compute dominant discharge
Qwdom = (mean(Q.^((2*w+3)/3))).^(3/(2*w+3));

% Compute slope and gravel fraction
G = cf^(w+3/2)/(tau_ref^w*(R*g)^(w+1));
mu = (Dg/Ds)^r*(1-pg)+(Dg/Ds)^w*pg;
S = cf*B^(2*w/(2*w+3))/(g*Qwdom)*(Ds^w*mu*AL/G/((Dg/Dref)^r))^(3/(2*w+3));
F = 1/mu*(Dg/Ds)^w*pg;
Hdom = Qwdom/(B^((2*w+2)/(2*w+3)))*(G/Ds^w/mu*(Dg/Dref)^r/AL)^(1/(2*w+3));


%% Save updated variable in new input file;
% Make a copy of the old one
copyfile(fullfile(folder_run,'input.mat'),fullfile(folder_run,'input_analytical.mat'))

% Adjust variables
input.ini.slopeb = S;
input.ini.etab0 = -Hdom;
input.ini.Fak = F;
input.ini.fsk = F;

% Overwrite input.mat
cd(folder_run);
clearvars -except input
save('input.mat');
end