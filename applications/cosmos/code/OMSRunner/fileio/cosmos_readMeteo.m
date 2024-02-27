function hm=cosmos_readMeteo(hm)

dirname=[hm.dataDir 'meteo' filesep];

noset=0;

fname=[dirname 'meteo.dat'];
txt=ReadTextFile(fname);

% Read Meteo

hm.meteo=[];

for i=1:length(txt)

    switch lower(txt{i}),
        case {'meteo'},
            noset=noset+1;
            hm.meteo(noset).longName=txt{i+1};
            hm.meteo(noset).xLim=[];
            hm.meteo(noset).yLim=[];
        case {'type'},
            hm.meteo(noset).type=txt{i+1};
        case {'location'},
            hm.meteo(noset).Location=txt{i+1};
        case {'name'},
            hm.meteo(noset).name=txt{i+1};
        case {'timestep'},
            hm.meteo(noset).timeStep=str2double(txt{i+1});
        case {'cycleinterval'},
            hm.meteo(noset).cycleInterval=str2double(txt{i+1});
        case {'delay'},
            hm.meteo(noset).Delay=str2double(txt{i+1});
        case {'xlim'},
            hm.meteo(noset).xLim(1)=str2double(txt{i+1});
            hm.meteo(noset).xLim(2)=str2double(txt{i+2});
        case {'ylim'},
            hm.meteo(noset).yLim(1)=str2double(txt{i+1});
            hm.meteo(noset).yLim(2)=str2double(txt{i+2});
        case {'source'},
            hm.meteo(noset).source=txt{i+1};
    end

end

hm.nrMeteoDatasets=noset;

for i=1:hm.nrMeteoDatasets
    hm.meteoNames{i}=hm.meteo(i).name;
    hm.meteo(i).tLastAnalyzed=rounddown(now-hm.meteo(i).Delay/24,hm.meteo(i).cycleInterval/24);
end
