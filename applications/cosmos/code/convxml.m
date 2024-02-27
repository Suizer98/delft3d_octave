clear variables;close all;

dr='F:\OperationalModelSystem\SoCalCoastalHazards\scenarios\';
sc='forecasts';
cnts={'europe','world'};
cnts={'northamerica'};

for ic=1:length(cnts)
    mdls=dir([dr sc filesep 'models' filesep cnts{ic} filesep]);
    for k=1:length(mdls)
        switch mdls(k).name
            case{'.','..'}
            otherwise
                if isdir([dr sc filesep 'models' filesep cnts{ic} filesep mdls(k).name])
                    mdl=mdls(k).name;
                    %                    copyfile([dr sc filesep 'models' filesep cnts{ic} filesep mdls(k).name filesep mdls(k).name '.xml'],[dr sc filesep 'models' filesep cnts{ic} filesep mdls(k).name filesep mdls(k).name '.xml.ori'])
                    
                    fnamein=[dr sc filesep 'models' filesep cnts{ic} filesep mdls(k).name filesep mdls(k).name '.xml.ori'];
                    fnameout=[dr sc filesep 'models' filesep cnts{ic} filesep mdls(k).name filesep mdls(k).name '.xml'];
                    
                    s0=xml_load(fnamein);
                    s1=s0;
                    try
                        if isfield(s1,'stations')
                            
                            s1=rmfield(s1,'stations');
                            
                            np=0;
                            for i=1:length(s0.stations)
                                for ip=1:length(s0.stations(i).station.parameters)
                                    par=s0.stations(i).station.parameters(ip).parameter;
                                    np=np+1;
                                    %                                s1.timeseriesdatasets(np).dataset.name=[par.name '.' s0.stations(i).station.name];
                                    s1.timeseriesdatasets(np).dataset.parameter=par.name;
                                    s1.timeseriesdatasets(np).dataset.station=s0.stations(i).station.name;
                                    if isfield(s0.stations(i).station,'locationm')
                                        s1.timeseriesdatasets(np).dataset.locationm=s0.stations(i).station.locationm;
                                        s1.timeseriesdatasets(np).dataset.locationn=s0.stations(i).station.locationn;
                                    else
                                        s1.timeseriesdatasets(np).dataset.locationx=s0.stations(i).station.locationx;
                                        s1.timeseriesdatasets(np).dataset.locationy=s0.stations(i).station.locationy;
                                    end
                                    if isfield(par,'toopendap')
                                        s1.timeseriesdatasets(np).dataset.toopendap=par.toopendap;
                                    end
                                end
                            end
                            
                            np=0;
                            
                            for i=1:length(s0.stations)
                                s1.stations(i).station.name=s0.stations(i).station.name;
                                s1.stations(i).station.longname=s0.stations(i).station.longname;
                                s1.stations(i).station.locationx=s0.stations(i).station.locationx;
                                s1.stations(i).station.locationy=s0.stations(i).station.locationy;
                                s1.stations(i).station.type=s0.stations(i).station.type;
                                np=length(s0.stations(i).station.parameters);
                                for ip=1:np
                                    s1.stations(i).station.plots(ip).plot.type='timeseries';
                                    par=s0.stations(i).station.parameters(ip).parameter;
                                    n=0;
                                    n=n+1;
                                    %        s1.stations(i).station.plots(ip).plot.datasets(n).dataset.name=[par.name '.' s0.stations(i).station.name];
                                    s1.stations(i).station.plots(ip).plot.datasets(n).dataset.parameter=par.name;
                                    s1.stations(i).station.plots(ip).plot.datasets(n).dataset.type='computed';
                                    if isfield(s0.stations(i).station.parameters(ip).parameter,'plotobs')
                                        if strcmpi(s0.stations(i).station.parameters(ip).parameter.plotobs,'1')
                                            n=n+1;
                                            %                s1.stations(i).station.plots(ip).plot.datasets(n).dataset.name=[par.name '.' s0.stations(i).station.name];
                                            s1.stations(i).station.plots(ip).plot.datasets(n).dataset.parameter=par.name;
                                            s1.stations(i).station.plots(ip).plot.datasets(n).dataset.type='observed';
                                            s1.stations(i).station.plots(ip).plot.datasets(n).dataset.source=s0.stations(i).station.parameters(ip).parameter.obssrc;
                                            s1.stations(i).station.plots(ip).plot.datasets(n).dataset.id=s0.stations(i).station.parameters(ip).parameter.obsid;
                                        end
                                    end
                                    if isfield(s0.stations(i).station.parameters(ip).parameter,'plotprd')
                                        if strcmpi(s0.stations(i).station.parameters(ip).parameter.plotprd,'1')
                                            n=n+1;
                                            %                s1.stations(i).station.plots(ip).plot.datasets(n).dataset.name=[par.name '.' s0.stations(i).station.name];
                                            s1.stations(i).station.plots(ip).plot.datasets(n).dataset.parameter=par.name;
                                            s1.stations(i).station.plots(ip).plot.datasets(n).dataset.type='predicted';
                                            s1.stations(i).station.plots(ip).plot.datasets(n).dataset.source=s0.stations(i).station.parameters(ip).parameter.prdsrc;
                                            try
                                                s1.stations(i).station.plots(ip).plot.datasets(n).dataset.id=s0.stations(i).station.parameters(ip).parameter.prdid;
                                            catch
                                                shite=1
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    xml_save(fnameout,s1,'off');
                    catch
                        shite=4
                    end
                end
        end
    end
end
