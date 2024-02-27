%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18293 $
%$Date: 2022-08-11 00:25:55 +0800 (Thu, 11 Aug 2022) $
%$Author: chavarri $
%$Id: gdm_read_data_map_ls_simdef.m 18293 2022-08-10 16:25:55Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_data_map_ls_simdef.m $
%
%

function data=gdm_read_data_map_ls_simdef(fdir_mat,simdef,varname,sim_idx,varargin)
            
fpath_map=gdm_fpathmap(simdef,sim_idx);
ismor=D3D_is(fpath_map);

switch varname
    case {'d10','d50','d90','dm'}
        data=gdm_read_data_map_ls_grainsize(fdir_mat,fpath_map,simdef,varargin);
    case {'h'}
        switch simdef.D3D.structure
            case 1
                data_bl=gdm_read_data_map_ls(fdir_mat,fpath_map,'DPS',varargin{:});
                data_wl=gdm_read_data_map_ls(fdir_mat,fpath_map,'wl',varargin{:});

                data=data_bl;
                data.val=data_wl.val-data_bl.val;
            case {2,4}
                data=gdm_read_data_map_ls(fdir_mat,fpath_map,'wd',varargin{:});
        end
        
    case {'umag'}
        switch simdef.D3D.structure
            case 1
                data=gdm_read_data_map_ls(fdir_mat,fpath_map,'U1',varargin{:});
                data.val=data.vel_mag;
            case {2,4}
                data=gdm_read_data_map_ls(fdir_mat,fpath_map,'mesh2d_ucmag',varargin{:});
%                 data=gdm_read_data_map_ls(fdir_mat,fpath_map,'uv',varargin{:});
%                 data.val=data.vel_mag;
        end
    case {'bl'}
        switch simdef.D3D.structure
            case 1
                data=gdm_read_data_map_ls(fdir_mat,fpath_map,'DPS',varargin{:});
            case {2,4}
                if ismor
                    data=gdm_read_data_map_ls(fdir_mat,fpath_map,'mesh2d_mor_bl',varargin{:});
                else
                    data=gdm_read_data_map_ls(fdir_mat,fpath_map,'bl',varargin{:});
                end
        end
    case {'sb'}
        switch simdef.D3D.structure
            case 1
                data=gdm_read_data_map_ls(fdir_mat,fpath_map,'SBUU',varargin{:}); %<sbuu> already reads both
%                 data_v=gdm_read_data_map_ls(fdir_mat,fpath_map,'SBVV',varargin{:});
%                 data=data_u;
%                 data.val=hypot(data_u.val,data_v.val);
                data.val=data.vel_mag;
            case {2,4}
                error('check')
                data_x=gdm_read_data_map_ls(fdir_mat,fpath_map,'sxtot',varargin{:});
                data_y=gdm_read_data_map_ls(fdir_mat,fpath_map,'sytot',varargin{:});
        end
    otherwise
        data=gdm_read_data_map_ls(fdir_mat,fpath_map,varname,varargin{:});
end



end %function