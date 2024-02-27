clear variables;close all;

dr='F:\OperationalModelSystem\SoCalCoastalHazards\scenarios\';
sc='forecasts';
cnts={'europe','world'};
cnts={'world'};
cnts={'northamerica'};

for ic=1:length(cnts)
    mdls=dir([dr sc filesep 'models' filesep cnts{ic} filesep]);
    for k=1:length(mdls)
        switch mdls(k).name
            case{'.','..'}
            otherwise
                if isdir([dr sc filesep 'models' filesep cnts{ic} filesep mdls(k).name])
                    mdl=mdls(k).name;
                    
                    copyfile([dr sc filesep 'models' filesep cnts{ic} filesep mdls(k).name filesep mdls(k).name '.xml'],[dr sc filesep 'models' filesep cnts{ic} filesep mdls(k).name filesep mdls(k).name '.xml.ori'])
                    
                    fnamein =[dr sc filesep 'models' filesep cnts{ic} filesep mdls(k).name filesep mdls(k).name '.xml.ori'];
                    fnameout=[dr sc filesep 'models' filesep cnts{ic} filesep mdls(k).name filesep mdls(k).name '.xml'];
                    
                    s0=xml_load(fnamein);
                    s1=s0;
                    
                    if isfield(s1,'timeseriesdatasets')

                        for istat=1:length(s1.stations)
                            stationnames{istat}=s1.stations(istat).station.name;
                        end
                        iset=zeros(length(s1.stations),1);
                        
                        for itms=1:length(s1.timeseriesdatasets)
                            data=s1.timeseriesdatasets(itms).dataset;
                            istat=strmatch(data.station,stationnames,'exact');
                            if ~iset(istat)
                                s1.stations(istat).station=[];
                                s1.stations(istat).station.name=s0.stations(istat).station.name;
                                s1.stations(istat).station.longname=s0.stations(istat).station.longname;
                                s1.stations(istat).station.type=s0.stations(istat).station.type;
                                s1.stations(istat).station.locationx=s0.stations(istat).station.locationx;
                                s1.stations(istat).station.locationy=s0.stations(istat).station.locationy;
                                if isfield(data,'locationm')
                                    s1.stations(istat).station.locationm=data.locationm;
                                    s1.stations(istat).station.locationn=data.locationn;
                                end
                            end
                            if isfield(s1.stations(istat).station,'datasets')
                                nd=length(s1.stations(istat).station.datasets);
                                nd=nd+1;
                            else
                                nd=1;
                            end
                            s1.stations(istat).station.datasets(nd).dataset.parameter=data.parameter;
                            s1.stations(istat).station.plots=s0.stations(istat).station.plots;
                            iset(istat)=1;
                        end
                        
                        s1=rmfield(s1,'timeseriesdatasets');
                        xml_save(fnameout,s1,'off');
                    end
                end
        end
    end
end
