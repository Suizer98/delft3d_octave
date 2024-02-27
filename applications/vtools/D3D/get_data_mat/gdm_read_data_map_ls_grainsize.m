%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 12:18:42 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: gdm_read_data_map_ls_grainsize.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_data_map_ls_grainsize.m $
%
%

function data=gdm_read_data_map_ls_grainsize(fpath_map,simdef,varargin)
        
fpath_sed=simdef.file.sed;
if simdef.D3D.structure==4
    fpath_sed=strrep(fpath_sed,[filesep,'0',filesep],filesep); %the path is relative to the mdu in the <source> directory
end
dchar=D3D_read_sed(fpath_sed);
varargin={varargin{:},'dchar',dchar};

data=gdm_read_data_map_ls(fpath_map,'mesh2d_lyrfrac',varargin{:});

Fa=data.val;
switch varname
    case 'd10'
        val=grain_size_dX_mat(Fa,dchar,10);
    case 'd50'
        val=grain_size_dX_mat(Fa,dchar,50);
    case 'd90'
        val=grain_size_dX_mat(Fa,dchar,90);
    case 'dm'
        val=sum(Fa.*permute(dchar,[1,3,4,2]),4); %arithmetic mean grain size
end
data.val=val;

end %function