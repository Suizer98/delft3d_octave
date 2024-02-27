function txt = getDESettingsTxt(fid)

DESettings = defaultDESettings;
DESfieldnames = fieldnames(DESettings);

txt = ['% Dunerosion settings for this calculation where:' char(13)];
txt = [txt '%' char(13)];
for itypes = 1:length(DESfieldnames)
    txt = [txt '% ' DESfieldnames{itypes} char(13)];
    DESsubfieldnames = fieldnames(DESettings.(DESfieldnames{itypes}));
    for ifields = 1:length(DESsubfieldnames)
        txt = [txt '%    ' DESsubfieldnames{ifields} ' = ' num2str(DuneErosionSettings(DESsubfieldnames{ifields})) char(13)];
    end
    txt = [txt '%' char(13)];
end

if nargin == 1
    fprintf(fid,'%s\n',txt);
end
