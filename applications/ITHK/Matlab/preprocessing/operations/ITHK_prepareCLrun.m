function ITHK_prepareCLrun

global S

fprintf('ITHK preprocessing : Preparing phasing of UNIBEST in time\n');

%% write a Unibest CL-run specification file
CLRfileName      = [S.settings.outputdir S.userinput.name,'.CLR'];
time             = [S.settings.CLRdata.from(1)+S.userinput.phases S.settings.CLRdata.from(1)+S.userinput.duration];
phaseunit        = 'year';
timesteps        = 20; % computational timesteps (number / phase) (single value)
output_step      = 20; % output per number of computational timesteps (single value, every n-th timestep)
MDAfile          = S.settings.CLRdata.mdaname;

% WARNING: For now assumes GKL, BCO, OBW & BCI to be constant throughout simulation
for ii=1:length(S.userinput.phases)
    GKLfiles{ii} = S.settings.CLRdata.GKL{1};
    BCOfiles{ii} = S.settings.CLRdata.BCO{1};
    GROfiles{ii} = strtok(S.userinput.phase(ii).GROfile,'.');
    SOSfiles{ii} = strtok(S.userinput.phase(ii).SOSfile,'.');
    REVfiles{ii} = strtok(S.userinput.phase(ii).REVfile,'.');
    OBWfiles{ii} = S.settings.CLRdata.OBW{1};
    BCIfiles{ii} = S.settings.CLRdata.BCI{1};
end
CL_filenames     = {MDAfile,GKLfiles,BCOfiles,GROfiles,SOSfiles,REVfiles,OBWfiles,BCIfiles};
ITHK_io_writeCLR(CLRfileName, time, phaseunit, timesteps, output_step, CL_filenames);

%% write a batch file
batchfileName='computeClrIT.bat';

fid = fopen([S.settings.outputdir batchfileName],'wt');
fprintf(fid,'%s %s\n','call clrun',[S.userinput.name,'.CLR']);
fclose(fid);

%% Save filenames to be transfered to output dir
for ii=1:length(S.userinput.phases)
    GKLfiles{ii} = S.settings.CLRdata.GKL{1};
    BCOfiles{ii} = S.settings.CLRdata.BCO{1};
    GROfiles{ii} = S.userinput.phase(ii).GROfile;
    SOSfiles{ii} = S.userinput.phase(ii).SOSfile;
    REVfiles{ii} = S.userinput.phase(ii).REVfile;
    OBWfiles{ii} = S.settings.CLRdata.OBW{1};
    BCIfiles{ii} = S.settings.CLRdata.BCI{1};
end
CL_fullfilenames = {GKLfiles,BCOfiles,GROfiles,SOSfiles,REVfiles,OBWfiles,BCIfiles};
for ii=1:length(CL_fullfilenames)
    S.PP.output.CL_fullfilenames{ii} = unique(CL_fullfilenames{ii});
end