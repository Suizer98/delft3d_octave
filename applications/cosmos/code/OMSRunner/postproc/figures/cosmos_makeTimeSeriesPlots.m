function cosmos_makeTimeSeriesPlots(hm,m)

model=hm.models(m);
appendeddir=model.appendeddirtimeseries;
figdir=model.cycledirfigures;

try
    
    if model.nrStations>0
        
        nn=model.nrStations;
        
        if strcmpi(hm.scenarioType,'forecast')
            tstart=model.tOutputStart-5;
        else
            tstart=model.tOutputStart;
        end
        tstop=model.tStop;
                
        for i=1:nn

            clear pars
            
            station=model.stations(i).name;

            % Time shift
            timeShift=model.stations(i).timeShift/24;
            
            ifg=0;
            
            for iplt=1:model.stations(i).nrPlots

                ymin=1e9;
                ymax=-1e9;
                
                nd=0;

                tms=[];
                
                for ip=1:model.stations(i).plots(iplt).nrDatasets
                    
                    par=model.stations(i).plots(iplt).datasets(ip).parameter;
                    
                    switch lower(model.stations(i).plots(iplt).datasets(ip).type)
                        case{'computed'}
                            fname=[appendeddir par '.' station '.mat'];
                            if exist(fname,'file')
                                nd=nd+1;
                                tms(nd).color='k';
                                tms(nd).name='computed';
                            end
                        case{'observed'}
                            src=model.stations(i).plots(iplt).datasets(ip).source;
                            id=model.stations(i).plots(iplt).datasets(ip).id;
                            fname=[hm.scenarioDir 'observations' filesep src filesep id filesep par '.' id '.mat'];
                            if exist(fname,'file')
                                nd=nd+1;
                                tms(nd).color='b';
                                tms(nd).name='observed';
                            end
                        case{'predicted'}
                            src=model.stations(i).plots(iplt).datasets(ip).source;
                            id=model.stations(i).plots(iplt).datasets(ip).id;
                            fname=[hm.scenarioDir 'observations' filesep src filesep id filesep par '.' id '.mat'];
                            if exist(fname,'file')
                                nd=nd+1;
                                tms(nd).color='r';
                                tms(nd).name='predicted';
                            end
                    end
                    
                    if exist(fname,'file')
                        data=load(fname);
                        it1=find(data.Time<tstart,1,'last');
                        if isempty(it1)
                            it1=1;
                        end
                        tms(nd).x=data.Time(it1:end)+timeShift;
                        tms(nd).y=data.Val(it1:end);
                        ymin=min(ymin,min(tms(nd).y));
                        ymax=max(ymax,max(tms(nd).y));
                    end
                    
                end
                
                
                
                %                     Parameter=model.stations(i).parameters(ip);
                %                     stationfile=model.stations(i).name;
                %                     typ=Parameter.name;
                %
                % Title and labels
                partit=getParameterInfo(hm,par,'plot','timeseries','title');
                ylab=getParameterInfo(hm,par,'plot','timeseries','ylabel');
                yltp=getParameterInfo(hm,par,'plot','timeseries','ylimtype');
                
                
                % Check if there is any data in structure tms
                if ~isempty(tms)

                    % X Axis properties

                    tlim=[tstart tstop]+timeShift;

                    if tstop-tstart>8
                        xticks=floor(tstart+timeShift):1:ceil(tstop+timeShift);
                    else
                        xticks=floor(tstart+timeShift):0.5:ceil(tstop+timeShift);
                    end
                    
                    % Y Axis properties
                    switch yltp
                        case{'sym'}
                            yminabs=abs(ymin);
                            ymaxabs=abs(ymax);
                            yabs=ceil(max(yminabs,ymaxabs));
                            ymin=-yabs;
                            ymax=yabs;
                        case{'fit'}
                            ymin=floor(ymin);
                            ymax=ceil(ymax);
                        case{'positive'}
                            ymin=0;
                            ymax=ceil(ymax);
                        case{'angle'}
                            ymin=0;
                            ymax=360;
                    end
                    ydif=ymax-ymin;
                    if ydif<1
                        ytck=0.05;
                        ydec=2;
                    elseif ydif<2
                        ytck=0.1;
                        ydec=1;
                    elseif ydif<4
                        ytck=0.2;
                        ydec=1;
                    elseif ydif<10
                        ytck=0.5;
                        ydec=1;
                    elseif ydif<20
                        ytck=1;
                        ydec=1;
                    elseif ydif<40
                        ytck=2;
                        ydec=1;
                    elseif ydif<100
                        ytck=5;
                        ydec=1;
                    else
                        ytck=30;
                        ydec=1;
                    end
                    ymax=max(ymax,ymin+0.1);
                    if strcmp(yltp,'angle')
                        ytck=45;
                        ydec=0;
                    end
                    ylim=[ymin ymax];
                    yticks=ymin:ytck:ymax;
                    
                    % Title
                    ttl=[partit ' - ' model.stations(i).longName];
                    
                    % And export the figure
                    figname=[figdir par '.' station '.png'];
                    cosmos_timeSeriesPlot(figname,tms,'ylabel',ylab,'title',ttl,'xlim',tlim,'ylim',ylim,'xticks',xticks,'yticks',yticks, ...
                        'timelabel',model.stations(i).timeZoneString);
                    
                    % Cell array for html code
                    ifg=ifg+1;
                    fign{ifg}=[par '.' station '.png'];
                    
                end
            end
            
            %% Write html code
            fi2=fopen([figdir station '.html'],'wt');
            fprintf(fi2,'%s\n','<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">');
            fprintf(fi2,'%s\n','<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">');
            fprintf(fi2,'%s\n','<head>');
            fprintf(fi2,'%s\n','</head>');
            fprintf(fi2,'%s\n','<body>');
            for iplt=1:ifg
                str=['<img src="' fign{iplt} '">'];
                fprintf(fi2,'%s\n',str);
            end
            fprintf(fi2,'%s\n','</body>');
            fprintf(fi2,'%s\n','</html>');
            fclose(fi2);
        
        end
    end
    
catch
    WriteErrorLogFile(hm,['Something went wrong with generating timeseries figure - ' par ' - ' model.name]);
end
