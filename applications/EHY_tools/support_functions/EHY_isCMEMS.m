function TF = EHY_isCMEMS(fname)
%% TF = EHY_isCMEMS(fname)
% Returns logical (TRUE or FALSE) if the provided file (fname) is a CMEMS-file
% This is needed as CMEMS-files are handled as Delft3D FM-files, but
% sometimes it is useful to know if this is really the case
TF = false;

[~,~,ext] = fileparts(fname);

if strcmp(ext,'.nc')
    infonc = ncinfo(fname);
    if ~isempty(infonc.Attributes)
        ind = strmatch('institution',{infonc.Attributes.Name},'exact');
        if ~isempty(ind) && strcmpi('MERCATOR OCEAN',infonc.Attributes(ind).Value)
            TF = true;
        end
    end
end
