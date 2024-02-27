function filetype = det_filetype (filename)

error ('Functionalty of this function is covered by EHY_getModelType. Use that function instead');

% det_filetype : determines, based on name/extension, whether a file is a delft3d or simona file (or DFLOWFM)

filetype = 'none';

[~,name,extension] = fileparts(filename);
filename = lower([name extension]);

%
% input trih or SDS; output bct or timeser
%

if ~isempty(strfind(filename,'sds'   )) || ~isempty(strfind(filename,'timeser')) || ...
   ~isempty(strfind(filename,'points'))
    filetype = 'SIMONA';
end

if ~isempty(strfind(filename,'trih-'  )) || ~isempty(strfind(extension,'bct'    )) || ...
   ~isempty(strfind(extension,'bcc'   )) || ~isempty(strfind(extension,'obs'    )) || ...
   ~isempty(strfind(extension,'bnd'   ))
    filetype = 'Delft3D';
end

if ~isempty(strfind(extension,'mdf'  ))
    filetype = 'mdf';
end

if ~isempty(strfind(extension,'mdu'  ))
    filetype = 'mdu';
end

if ~isempty(strfind(extension,'ext'  ))
    filetype = 'ext';
end

if ~isempty(strfind(filename,'siminp'))
    filetype = 'siminp';
end

if ~isempty(strfind(extension,'grd')) || ~isempty(strfind(extension,'rgf')) || ~isempty(strfind(name,'rgf'))
     filetype = 'grd';
end

if ~isempty(strfind(filename,'net.nc')) || ~isempty(strfind(filename,'map.nc'))
    filetype = 'DFLOWFM';
end

[~,~,ext] = fileparts(filename);
if ~isempty(strfind(ext,'pli'))
    filetype = 'pli';
end

if ~isempty(strfind(extension,'.tim'))
    filetype = 'DFLOWFM';
end

if ~isempty(strfind(extension,'.xyn'))
    filetype = 'DFLOWFM';
end

if ~isempty(strfind(filename,'_his.nc'))
    filetype = 'DFLOWFM';
end

