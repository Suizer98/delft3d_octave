function cosmos_extractDataDelft3DWaveSpectra(hm,m)

model=hm.models(m);
dr=model.dir;
outdir=[dr 'lastrun' filesep 'output' filesep];
archdir = model.archiveDir;
mkdir([archdir hm.cycStr filesep 'sp2']); %% sp2 Folder at line 24 cannot be created straight away from that line, dont know how to do it
%% Read and store the spectra
for i=1:model.nrTimeSeriesDatasets    
    if strcmpi(model.timeSeriesDatasets(i).parameter,'sp2')
        try
            stName=model.timeSeriesDatasets(i).station;        
            sp2list=dir([outdir '/' model.timeSeriesDatasets(i).sp2id '.*.sp2']);            
            for j=1:length(sp2list)
                [SP2Data.time(j).Separation,SP2Data.time(j).spec,SP2Data.time(j).Bulk]=...
                    getWaveSeparationFromSP2(([outdir sp2list(j).name]));
                SP2Data.Station=stName;
            end
            fname=[archdir hm.cycStr filesep 'sp2' filesep 'sp2.' stName '.mat'];
            save(fname,'SP2Data');
        catch
            WriteErrorLogFile(hm,['Something went wrong reading SP2 data - ' hm.models(m).name]);
        end
    end 
end
