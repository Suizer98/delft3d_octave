function dataset=muppet_addDatasetTideStations(opt,dataset)

switch lower(opt)

    case{'read'}
        
        % Do as much as possible here and not in import function
        dataset.adjustname=0;
        [pathstr,name,ext]=fileparts(dataset.filename);    
        dataset.name=name;
        dataset.adjustname=1;

        s=load(dataset.filename);
        
        % Locations
        dataset.parameters(1).parameter.name='locations';
        dataset.parameters(1).parameter.data=s;
        dataset.parameters(1).parameter.size=[0 length(s.station) 0 0 0];
        for istat=1:length(s.station)
            dataset.parameters(1).parameter.stations{istat}=squeeze(s.station(istat).name);
        end        
        dataset.parameters(1).parameter.active=1;
        
        % Component sets
        dataset.parameters(2).parameter.name='component set';
        dataset.parameters(2).parameter.data=s;
        dataset.parameters(2).parameter.size=[0 length(s.station) 0 0 0];
        for istat=1:length(s.station)
            dataset.parameters(2).parameter.stations{istat}=squeeze(s.station(istat).name);
        end
        dataset.parameters(2).parameter.active=1;

        % Samples
        dataset.parameters(3).parameter.name='samples';
        dataset.parameters(3).parameter.data=s;
        dataset.parameters(3).parameter.size=[0 length(s.station) 0 0 0];
        for istat=1:length(s.station)
            dataset.parameters(3).parameter.stations{istat}=squeeze(s.station(istat).name);
        end                
%        dataset.tidalcomponent=s.station(1).component{1};
        dataset.tidalcomponentlist=s.station(1).component;
        dataset.parameters(3).parameter.active=1;
        
    case{'import'}

        s=dataset.data;                
        
        switch dataset.parameter
            case{'locations'}
                
                if ~isempty(dataset.station)
                    istat=strmatch(dataset.station,dataset.stations,'exact');
                    dataset.x=squeeze(s.station(istat).x);
                    dataset.y=squeeze(s.station(istat).y);
                    dataset.text{1}=s.station(istat).name;
                    dataset.rotation=0;
                    dataset.curvature=0;
                else
                    for istat=1:length(s.station)
                        dataset.x(istat)=squeeze(s.station(istat).x);
                        dataset.y(istat)=squeeze(s.station(istat).y);
                        dataset.text{istat}=s.station(istat).name;
                        dataset.rotation(istat)=0;
                        dataset.curvature(istat)=0;
                    end
                end
                
                dataset.type = 'textannotation';
                dataset.tc='c';
        
            case{'component set'}

                istat=strmatch(dataset.station,dataset.stations,'exact');
                
                switch dataset.tidalcomponentset
                    case{'all'}
                        dataset.x=1:length(s.station(istat).component);
                        if strcmpi(dataset.tidalparameter,'amplitude')
                            dataset.y=s.station(istat).amplitude;
                        else
                            dataset.y=s.station(istat).phase;
                        end
                        dataset.xticklabel=s.station(istat).component;
                    otherwise
                        
                        switch dataset.tidalcomponentset
                            case{'8 main components'}
                                % Main components
                                cmps={'M2','S2','K2','N2','K1','O1','P1','Q1'};
                            case{'13 main components'}
                                % Main components
                                cmps={'M2','S2','K2','N2','K1','O1','P1','Q1','MF','MM','M4','MS4','MN4'};
                        end
                                
                        for ic=1:length(cmps)
                            dataset.x(ic)=ic;
                            icmp=strmatch(lower(cmps{ic}),lower(s.station(istat).component),'exact');
                            if ~isempty(icmp)
                                if strcmpi(dataset.tidalparameter,'amplitude')
                                    dataset.y(ic)=s.station(istat).amplitude(icmp);
                                else
                                    dataset.y(ic)=s.station(istat).phase(icmp);
                                end
                            else
                                dataset.y(ic)=NaN;
                            end
                        end
                        
                        dataset.xticklabel=cmps;
                        
                end
                
                dataset.type='histogram';
                dataset.tc='c';
                                
            case{'samples'}
                n=0;
                for istat=1:length(s.station)
                    
                    icmp=strmatch(lower(dataset.tidalcomponent),lower(s.station(istat).component),'exact');
                    if ~isempty(icmp)
                        n=n+1;
                        dataset.x(n)=s.station(istat).x;
                        dataset.y(n)=s.station(istat).y;
                        if strcmpi(dataset.tidalparameter,'amplitude')
                            dataset.z(n)=s.station(istat).amplitude(icmp);
                        else
                            dataset.z(n)=s.station(istat).phase(icmp);
                        end
                    end
                end
                
                dataset.type='scalar1dxy';
                dataset.tc='c';

        end

end
