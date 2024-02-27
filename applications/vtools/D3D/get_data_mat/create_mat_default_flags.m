%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18185 $
%$Date: 2022-06-21 19:23:15 +0800 (Tue, 21 Jun 2022) $
%$Author: chavarri $
%$Id: create_mat_default_flags.m 18185 2022-06-21 11:23:15Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_default_flags.m $
%
%

function in_plot=create_mat_default_flags(in_plot)

%% defaults common to all

if isfield(in_plot,'lan')==0
    in_plot.lan='nl';
end

if isfield(in_plot,'tag_serie')==0
    in_plot.tag_serie='01';
end

%% get the items which are not structure

fn=fieldnames(in_plot);
nf=numel(fn);
idx_def=NaN(nf,1);
for kf=1:nf
    if isstruct(in_plot.(fn{kf}))==0
        idx_def(kf)=kf;
    end
end
idx_def=idx_def(~isnan(idx_def));
ndef=numel(find(idx_def));

%% copy flags

for kf=1:nf
    if isstruct(in_plot.(fn{kf}))
        for kdef=1:ndef
            in_plot.(fn{kf}).(fn{idx_def(kdef)})=in_plot.(fn{idx_def(kdef)});
        end
    end
end

end %function