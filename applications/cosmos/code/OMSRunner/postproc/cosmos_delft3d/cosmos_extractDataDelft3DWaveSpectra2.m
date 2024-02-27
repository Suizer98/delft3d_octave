function cosmos_extractDataDelft3DWaveSpectra2(hm,m)

model=hm.models(m);
dr=model.dir;
outdir=[dr 'lastrun' filesep 'output' filesep];
archdir = model.archiveDir;
mkdir([archdir hm.cycStr filesep 'sp2']); %% sp2 Folder at line 24 cannot be created straight away from that line, dont know how to do it
%% Read and store the spectra
for i=1:model.nrStations
    for j=1:model.stations(i).nrDatasets
        if strcmpi(model.stations(i).datasets(j).parameter,'sp2')
            try
                stName=model.stations(i).name;
                sp2list=dir([outdir '/' model.stations(i).datasets(j).sp2id '.*.sp2']);
                for it=1:length(sp2list)
                    [SP2Data.time(it).Separation,SP2Data.time(it).spec,SP2Data.time(it).Bulk]=...
                        getWaveSeparationFromSP2(([outdir sp2list(it).name]));
                    SP2Data.Station=stName;
                end
                fname=[archdir hm.cycStr filesep 'sp2' filesep 'sp2.' stName '.mat'];
                save(fname,'SP2Data');
            catch
                WriteErrorLogFile(hm,['Something went wrong reading SP2 data - ' hm.models(m).name]);
            end
        end
    end
end
