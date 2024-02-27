%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17867 $
%$Date: 2022-03-29 14:02:08 +0800 (Tue, 29 Mar 2022) $
%$Author: chavarri $
%$Id: D3D_morini_files.m 17867 2022-03-29 06:02:08Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_morini_files.m $
%
%writes initial composition files. For a given matrix 'frac_xy' containing x
%and y coordinates of 'np' points, it writes the files corresponding to
%'nl' layers and 'nf' fractions given in 'frac'. The first layer (i.e.,
%frac(:,1,:) is the active layer. Similarly for the thickness. 
%
%INPUT:
%   -simdef.mor.frac = volume fraction content [-]; [np,nl,nf]
%   -simdef.mor.thk = layer thickness [-]; [np,nl]

function D3D_morini_files(simdef,varargin)

if isfield(simdef,'D3D')
    fdir_out=fullfile(simdef.D3D.dire_sim,simdef.mor.folder_out);
else
    fdir_out=simdef.mor.folder_out;
end
mkdir_check(fdir_out);

frac=simdef.mor.frac;
frac_xy=simdef.mor.frac_xy;
thk=simdef.mor.thk;


nf=size(frac,3);
nl=size(frac,2);

%% round

% check_Fak(frac);

prec=10;
frac_rn=round(frac,prec);
% frac_rn(:,:,end)=1-sum(frac_rn(:,:,1:end-1),3);
frac_rn(:,:,1)=1-sum(frac_rn(:,:,2:end),3);
frac_rn(frac_rn<1*10^(-prec))=0;

check_Fak(frac_rn);

%% write
for kl=1:nl
    file_name=fullfile(fdir_out,sprintf('lyr%02d_thk.xyz',kl));
    outmat=[frac_xy(:,1),frac_xy(:,2),thk(:,kl)];
    write_2DMatrix(file_name,outmat,varargin{:})
    for kf=1:nf
        file_name=fullfile(fdir_out,sprintf('lyr%02d_frac%02d.xyz',kl,kf));
        outmat=[frac_xy(:,1),frac_xy(:,2),frac_rn(:,kl,kf)];
        write_2DMatrix(file_name,outmat,varargin{:})
        messageOut(NaN,sprintf('file written layer %4.2f %% fraction %4.2f %%: %s',kl/nl*100,kf/nf*100,file_name));
    end
end

end

%%
%% FUNCTIONS
%%

function check_Fak(fractions_var_mod)

tol=1e-9;
if ~isempty(find(fractions_var_mod>1+tol, 1)) || ~isempty(find(fractions_var_mod<-tol, 1))
     warning('ups')
end

tol_sum=1e-9;
sum_frac=sum(fractions_var_mod,3);
idx_1=find(sum_frac>1+tol_sum,1);
idx_0=find(sum_frac<1-tol_sum,1);
if ~isempty(idx_1)
    warning('Warning: volume fraction content = %0.15e',sum_frac(idx_1))
end
if ~isempty(idx_0)
    warning('Warning: volume fraction content = %0.15e',sum_frac(idx_0))
end

end
