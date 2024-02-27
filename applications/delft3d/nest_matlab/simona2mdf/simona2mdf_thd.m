function mdf = simona2mdf_thd(S,mdf,name_mdf,varargin)

% simona2mdf_thd : gets thin dams out of the parsed siminp tree

THD.DATA   =  [];

OPT.nesthd_path = getenv_np('nesthd_path');
OPT = setproperty(OPT,varargin{1:end});

%
% Thin dams in u direction
%

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'DRYPOINTS' 'CLOSEU'});

if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.DRYPOINTS.CLOSEU.MNN')
   line = siminp_struc.ParsedTree.MESH.DRYPOINTS.CLOSEU.MNN;
   for i_line = 1: length(line)
      THD.DATA(end+1).mn(1)     = line(i_line).MNNLINE(1);
      THD.DATA(end  ).mn(2)     = line(i_line).MNNLINE(2);
      THD.DATA(end  ).mn(3)     = line(i_line).MNNLINE(1);
      THD.DATA(end  ).mn(4)     = line(i_line).MNNLINE(3);
      THD.DATA(end  ).direction = 'U';
   end
end

%
% Same story v-direction
%

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'DRYPOINTS' 'CLOSEV'});

if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.DRYPOINTS.CLOSEV.NMM')
   line = siminp_struc.ParsedTree.MESH.DRYPOINTS.CLOSEV.NMM;
   for i_line = 1: length(line)
      THD.DATA(end+1).mn(1)     = line(i_line).NMMLINE(2);
      THD.DATA(end  ).mn(2)     = line(i_line).NMMLINE(1);
      THD.DATA(end  ).mn(3)     = line(i_line).NMMLINE(3);
      THD.DATA(end  ).mn(4)     = line(i_line).NMMLINE(1);
      THD.DATA(end  ).direction = 'V';
   end
end

%
% Write to the output file
%

if ~isempty(THD.DATA)
    file = [name_mdf '.thd'];
    delft3d_io_thd('write',file,THD);
    mdf.filtd = simona2mdf_rmpath(file);
end
