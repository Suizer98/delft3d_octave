%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18082 $
%$Date: 2022-05-27 22:38:11 +0800 (Fri, 27 May 2022) $
%$Author: chavarri $
%$Id: D3D_table_d3d4_to_FM.m 18082 2022-05-27 14:38:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_table_d3d4_to_FM.m $
%

function stru_out=D3D_table_d3d4_to_FM(stru_in)

ntab=stru_in.NTables;

for ktab=1:ntab
    
    if numel(stru_in.Table(ktab).Location)>5 && strcmp(stru_in.Table(ktab).Location(end-4:end-2),'_00')
        stru_in.Table(ktab).Location=stru_in.Table(ktab).Location(1:end-5);
        warning('It seems the <Location> in the table has trailing for FM bc ''_0001''. I am removing it.')
    end
    stru_out(ktab).name=stru_in.Table(ktab).Location;
    stru_out(ktab).function=stru_in.Table(ktab).Contents;
    stru_out(ktab).time_interpolation=stru_in.Table(ktab).Interpolation;
    stru_out(ktab).quantity={stru_in.Table(ktab).Parameter.Name};
    stru_out(ktab).unit={stru_in.Table(ktab).Parameter.Unit};
    stru_out(ktab).val=stru_in.Table(ktab).Data;

end