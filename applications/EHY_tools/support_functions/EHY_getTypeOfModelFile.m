function [typeOfModelFile, typeOfModelFileDetail] = EHY_getTypeOfModelFile(fileInp)
%% [typeOfModelFile, typeOfModelFileDetail] = EHY_getTypeOfModelFile(fileInp)
%
% This function returns the typeOfModelFile based on a filename
% typeOfModelFile can be:
% grid
% network
% mdFile
% outputfile
%
% Example1: 	typeOfModelFile = EHY_getTypeOfModelFile('D:\model.mdu')
%                   returns:	typeOfModelFile = 'mdFile'
% Example2: 	typeOfModelFile = EHY_getTypeOfModelFile('D:\sea_net.nc')
%                   returns:    typeOfModelFile = 'network'
% Example3: 	[typeOfModelFile, typeOfModelFileDetail] = EHY_getTypeOfModelFile('D:\trih-r01.dat')
%                   returns:    typeOfModelFile       = 'outputfile'
%                               typeOfModelFileDetail = 'trih'
%
% support function of the EHY_tools
% Julien Groenenboom - E: Julien.Groenenboom@deltares.nl

%% typeOfModelFile
[pathstr, name, ext] = fileparts(lower(fileInp));
typeOfModelFile='';

% grid
if isempty(typeOfModelFile)
    if ismember(ext,{'.grd','.lga','.cco'})
        typeOfModelFile = 'grid';
    end
end

% network
if isempty(typeOfModelFile)
    if ~isempty(strfind([name ext],'_net.nc')) || ~isempty(strfind([name ext],'_waqgeom.nc')) || ~isempty(strfind([name ext],'_netgeom.nc'))
        typeOfModelFile = 'network';
    end
end

% mdFile
if isempty(typeOfModelFile)
    if ismember(ext,{'.mdu','.mdf'}) || (~isempty(strfind([name ext],'siminp')) && isempty(ext)) % Avoid nc file with "siminp" in name being recognised as mdFile
        typeOfModelFile = 'mdFile';
    end
end

% outputfile
if isempty(typeOfModelFile)
    if ~isempty(strfind([name ext],'_his.nc'))  || ~isempty(strfind([name ext],'_map.nc')) || ...
            ~isempty(strfind([name ext],'trih-'))  || ~isempty(strfind([name ext],'trim-')) || ...
            ~isempty(strfind([name],'sds')) || ~isempty(strfind([name ext],'_fou.nc')) || ...
            strcmp(ext,'.map') || strcmp(ext,'.his') || strcmp(ext,'.sgf')
        typeOfModelFile = 'outputfile';
    end
end

% nc_griddata (e.g. CMEMS or HiRLAM)
if isempty(typeOfModelFile) && strcmp(ext,'.nc') && ...
        ( nc_isvar(fileInp,'x') || nc_isvar(fileInp,'X') || nc_isvar(fileInp,'longitude') )
    typeOfModelFile = 'nc_griddata';
end

%% typeOfModelFileDetail
if nargout==2
    typeOfModelFileDetail='';
    [~,~,ext]                       = fileparts(fileInp);
    if length(ext) > 1                            ;  typeOfModelFileDetail = ext(2:end); end
    if ~isempty(strfind(lower(fileInp),'siminp' ));  typeOfModelFileDetail = 'siminp'; end
    if ~isempty(strfind(lower(fileInp),'sds'    ));  typeOfModelFileDetail = 'sds'   ; end
    if ~isempty(strfind(lower(fileInp),'_his.nc'));  typeOfModelFileDetail = 'his_nc'; end
    if ~isempty(strfind(lower(fileInp),'_map.nc'));  typeOfModelFileDetail = 'map_nc'; end
    if ~isempty(strfind(lower(fileInp),'_fou.nc'));  typeOfModelFileDetail = 'fou_nc'; end
    if ~isempty(strfind(lower(fileInp),'_net.nc'));  typeOfModelFileDetail = 'net_nc'; end
    if ~isempty(strfind(lower(fileInp),'trih'   ));  typeOfModelFileDetail = 'trih'  ; end
    if ~isempty(strfind(lower(fileInp),'trim'   ));  typeOfModelFileDetail = 'trim'  ; end
    if ~isempty(strfind(lower(fileInp),'rgf'))    ;  typeOfModelFileDetail = 'grd'   ; end
end

