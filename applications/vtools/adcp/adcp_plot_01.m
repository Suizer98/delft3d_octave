%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17514 $
%$Date: 2021-10-04 15:15:38 +0800 (Mon, 04 Oct 2021) $
%$Author: chavarri $
%$Id: adcp_plot_01.m 17514 2021-10-04 07:15:38Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/adcp/adcp_plot_01.m $
%

function [fname_original,fname_print]=adcp_plot_01(fdir_mat,fdir_fig,varargin)

%% parse

OPT.plot=1;
OPT=setproperty(OPT,varargin{:});

%% dire

[dire1,~,dire3]=dirwalk(fdir_mat);
nd=numel(dire3);

fname_print=cell(size(dire3));
fname_original=fname_print;

%start from beginning
order_anl=1:1:nd;

%% loop

for kd=order_anl
    fname=dire3{kd,1};
    if ~isempty(fname)
        nf=numel(fname);
        fname_print{kd,1}=cell(size(fname));
        fname_original{kd,1}=cell(size(fname));
        for kf=1:nf
            fnameext=dire3{kd,1}{kf,1};
            ffolder=dire1{kd,1};
            ffullname=fullfile(ffolder,fnameext);
            [~,fnameonly,fext]=fileparts(ffullname);

            ffolder_out_fig=strrep(ffolder,fdir_mat,fdir_fig);
            mkdir_check(ffolder_out_fig)
            
            
            if strcmp(fext,'.mat')
                load(ffullname);
                data_block_processed=adcp_get_data_block(data_block);

                %%
                fname_print{kd,1}{kf,1}=fullfile(ffolder_out_fig,sprintf('%s_vmag',fnameonly));
                fname_original{kd,1}{kf,1}=ffullname;

                if OPT.plot
                    in_p.fname=fname_print{kd,1}{kf,1};
                    in_p.fig_print=[1,4]; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
                    in_p.fig_visible=0;
                    in_p.fig_size=[0,0,14,8];
                    in_p.data_block_processed=data_block_processed;
                    in_p.val='vmag';
                    in_p.lan='es';

                    fig_adcp_1_v(in_p)
                end
            end
            
        end %kf
    end %isempty(fname)
end %kd