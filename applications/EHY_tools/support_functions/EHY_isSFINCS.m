function TF = EHY_isSFINCS(fname)
%% TF = EHY_isSFINCS(fname)
% Returns logical (TRUE or FALSE) if the provided file (fname) is a SFINCS-file
% This is needed as SFINCS-files are handled as Delft3D FM-files, but
% sometimes it is useful to know if this is really the case
TF = false;

[~,~,ext] = fileparts(fname);

if strcmp(ext,'.nc')
    infonc = ncinfo(fname);
    if ~isempty(infonc.Attributes)
        ind = strmatch('title',{infonc.Attributes.Name},'exact');
        if ~isempty(ind) && ~isempty(findstr('sfincs',lower(infonc.Attributes(ind).Value)))
            TF = true;
        end
    end
end