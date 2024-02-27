function mdf = simona2mdf_weirs(S,mdf,name_mdf, varargin)

% simona2mdf_weirs: gets grid related quantities out of the parsed siminp tree

OPT.nesthd_path = getenv_np('nesthd_path');
OPT = setproperty(OPT,varargin{1:end});

weirs_d3d = [];

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'DEPTH_CONTROL'});

%
% positive upward or downward
%

sign = 1.0;

if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.DEPTH_CONTROL.ORIENTATION')
    upward = strfind(siminp_struc.ParsedTree.DEPTH_CONTROL.ORIENTATION,'upwards');
    if ~isempty(upward)
        sign = -1.0;
    end
end

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'WEIRS'});

%
% Get grid related information
%

if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.WEIRS')
    weirs_waq = siminp_struc.ParsedTree.MESH.WEIRS.W;
    nr_weir   = 0;
    for i_weir = 1: length(weirs_waq)
        if weirs_waq(i_weir).U_TYPE ~= 0
            nr_weir = nr_weir + 1;
            weirs_d3d.DATA(nr_weir).direction =  'U';
            weirs_d3d.DATA(nr_weir).mn(1)     =  weirs_waq(i_weir).M;
            weirs_d3d.DATA(nr_weir).mn(2)     =  weirs_waq(i_weir).N;
            weirs_d3d.DATA(nr_weir).mn(3)     =  weirs_waq(i_weir).M;
            weirs_d3d.DATA(nr_weir).mn(4)     =  weirs_waq(i_weir).N;
            weirs_d3d.DATA(nr_weir).cal       =  1.0;
            weirs_d3d.DATA(nr_weir).height    =  sign*weirs_waq(i_weir).U_OVERFLOW_H;
        end
        if weirs_waq(i_weir).V_TYPE ~= 0
            nr_weir = nr_weir + 1;
            weirs_d3d.DATA(nr_weir).direction =  'V';
            weirs_d3d.DATA(nr_weir).mn(1)     =  weirs_waq(i_weir).M;
            weirs_d3d.DATA(nr_weir).mn(2)     =  weirs_waq(i_weir).N;
            weirs_d3d.DATA(nr_weir).mn(3)     =  weirs_waq(i_weir).M;
            weirs_d3d.DATA(nr_weir).mn(4)     =  weirs_waq(i_weir).N;
            weirs_d3d.DATA(nr_weir).cal       =  1.0;
            weirs_d3d.DATA(nr_weir).height    =  sign*weirs_waq(i_weir).V_OVERFLOW_H;
        end
    end
    mdf.fil2dw = [name_mdf '.2dw'];
    delft3d_io_2dw('write',mdf.fil2dw,weirs_d3d);
    mdf.fil2dw = simona2mdf_rmpath(mdf.fil2dw);
end

