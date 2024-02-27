%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: SRE_read_deftop.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/SRE_read_deftop.m $
%

function [branch_name,branch_number]=SRE_read_deftop(path_deftop)

% %% DEBUG
% 
% clear
% clc
% path_deftop="c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\191016_rt_fm1D\data\gsd\RIJNMORF.SBK\25\DEFTOP.1";

%% INPUT

nloc=100; %preallocate with large number

%% READ

deftop=read_ascii(path_deftop);

%% get branch number and name

nl=numel(deftop);

branch_number=NaN(nloc,1);
branch_name=cell(nloc,1);

kloc=1;
for kl=1:nl
%     BRCH id '001' nm 'Bovenryn&Rhein' bn '001' en '002' al 86440 brch
    tok=regexp(deftop{kl,1},'BRCH id ''(\d+)''\s+nm\s+''(\w+&?\w+)','tokens');
% %% debug
% % clc
% % [tok,mat]=regexp(deftop{kl,1},'BRCH id ''(\d+)''\s+nm\s+''(\w+&?\w+)','tokens','match')
% %%
    if ~isempty(tok)
        branch_number(kloc,1)=str2double(tok{1,1}{1,1});
        branch_name{kloc,1}=tok{1,1}{1,2};
        
        %update
        if kloc==nloc
            branch_number=cat(1,branch_number,NaN(nloc,1));
            branch_name=cat(1,branch_name,cell(nloc,1));
        end
        kloc=kloc+1;
    end
    
end %kl

%clean
branch_number=branch_number(1:kloc-1,:);
branch_name=branch_name(1:kloc-1,:);