function cosmos_extractDataDelft3DWaveSpectra3(hm,m)

model=hm.models(m);

cycledir=model.cycledirsp2;
outdir=model.cyclediroutput;

if ~isdir([cycledir 'sp2'])
    mkdir([cycledir 'sp2']); %% sp2 Folder at line 24 cannot be created straight away from that line, dont know how to do it
end

%% Read and store the spectra
for i=1:model.nrStations
    for j=1:model.stations(i).nrDatasets
        if strcmpi(model.stations(i).datasets(j).parameter,'sp2')
            try
                stName=model.stations(i).name;
                sp2list=dir([outdir filesep model.stations(i).datasets(j).sp2id '.*.sp2']);
                for it=1:length(sp2list)
                    spc=readSWANSpec([outdir filesep sp2list(it).name]);
                    if it==1
                        spec=spc;
                    end
                    spec.times(it)=spc.time(1).time;
                    spec.time(it).points.energy=spc.time(1).points.energy*spc.time(1).points.factor;
% 
%                     [SP2Data.time(it).Separation,SP2Data.time(it).spec,SP2Data.time(it).Bulk]=...
%                         getWaveSeparationFromSP2(([outdir sp2list(it).name]));
%                     SP2Data.Station=stName;
                end
                fname=[cycledir 'sp2.' stName '.mat'];
                save(fname,'-struct','spec');
            catch
                WriteErrorLogFile(hm,['Something went wrong reading SP2 data - ' hm.models(m).name]);
            end
        end
    end
end
