function ITHK_cleanup(sens)

global S

%% Move files to directory
for ii=1:length(S.PP(sens).output.CL_fullfilenames)
    for jj = 1:length(S.PP(sens).output.CL_fullfilenames{ii})
        movefile([S.settings.outputdir S.PP(sens).output.CL_fullfilenames{ii}{jj}],[S.settings.outputdir 'output\' S.userinput.name '\'])
        % movefile(['input_' S.name '.mat'],['output\' S.name '\']);
        % Ray files nog toevoegen
    end
end
if isfield(S.UB,'input')
    if isfield(S.UB.input(sens),'groyne')
        for ss=1:length(S.UB.input(sens).groyne)
            for ii=1:length(S.UB.input(sens).groyne(ss).rayfiles)
                movefile([S.settings.outputdir S.UB.input(sens).groyne(ss).rayfiles{ii}],[S.settings.outputdir 'output\' S.userinput.name '\'])
            end
        end
    end
end
if exist([S.settings.outputdir '1HOTSPOTSIT_cont.sos'],'file')  
    movefile([S.settings.outputdir '1HOTSPOTSIT_cont.sos'],[S.settings.outputdir 'output\' S.userinput.name '\']);
end
movefile([S.settings.outputdir 'BASIS.MDA'],[S.settings.outputdir 'output\' S.userinput.name '\']);
movefile([S.settings.outputdir 'BASIS_ORIG.MDA'],[S.settings.outputdir 'output\' S.userinput.name '\']);
movefile([S.settings.outputdir 'BASIS_ORIG_OLD.MDA'],[S.settings.outputdir 'output\' S.userinput.name '\']);
movefile([S.settings.outputdir S.userinput.name '.CLR'],[S.settings.outputdir 'output\' S.userinput.name '\']);
movefile([S.settings.outputdir S.userinput.name '.PRN'],[S.settings.outputdir 'output\' S.userinput.name '\']);
movefile([S.settings.outputdir 'computeClrIT.bat'],[S.settings.outputdir 'output\' S.userinput.name '\']);
delete([S.settings.outputdir 'BRIJN90A.GRO']);
delete([S.settings.outputdir '1HOTSPOTS1IT.SOS']);
delete([S.settings.outputdir 'HOLLANDCOAST.REV']);
