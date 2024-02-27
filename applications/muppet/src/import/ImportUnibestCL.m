function DataProperties=ImportUnibestCL(DataProperties,i)

Data=unibest_clp_read_prn([DataProperties(i).PathName DataProperties(i).FileName]);

nt=length(Data.CEL);

if DataProperties(i).Date==0
    % TimeSeries
    pos=DataProperties(i).Location;
    ipos=str2num(pos(5:end));
    if lower(pos(1:3))=='cel'
        for j=1:nt
            tim=Data.CEL(j).year;
            y=floor(tim);
            DataProperties(i).x(j)=datenum(num2str(y),'yyyy')+(tim-y)*365;
            par=DataProperties(i).Parameter;
            switch lower(par),
                case {'xcoast'}
                    DataProperties(i).y(j)=Data.CEL(j).Xcoast(ipos);
                case {'ycoast'}
                    DataProperties(i).y(j)=Data.CEL(j).Ycoast(ipos);
                case {'y'}
                    DataProperties(i).y(j)=Data.CEL(j).N(ipos);
                case {'y-y0'}
                    DataProperties(i).y(j)=Data.CEL(j).N_N0(ipos);
                case {'source'}
                    DataProperties(i).y(j)=Data.CEL(j).source(ipos);
                case {'alfa'}
                    DataProperties(i).y(j)=Data.CEL(j).alfa(ipos);
                case {'s'}
                    DataProperties(i).y(j)=Data.CEL(j).S(ipos);
            end
        end
    else
        for j=1:nt
            tim=Data.RAY(j).year;
            y=floor(tim);
            DataProperties(i).x(j)=datenum(num2str(y),'yyyy')+(tim-y)*365;
            par=DataProperties(i).Parameter;
            switch lower(par),
                case {'xcoast'}
                    DataProperties(i).y(j)=Data.RAY(j).Xcoast(ipos);
                case {'ycoast'}
                    DataProperties(i).y(j)=Data.RAY(j).Ycoast(ipos);
                case {'n'}
                    DataProperties(i).y(j)=Data.RAY(j).N(ipos);
                case {'transport'}
                    DataProperties(i).y(j)=Data.RAY(j).transport(ipos);
                case {'vol'}
                    DataProperties(i).y(j)=Data.RAY(j).vol.passed(ipos);
                case {'alfa'}
                    DataProperties(i).y(j)=Data.RAY(j).alfa(ipos);
                case {'s'}
                    DataProperties(i).y(j)=Data.RAY(j).S(ipos);
            end
        end
    end
    DataProperties(i).Type='TimeSeries';
    DataProperties(i).TC='c';
else
    tim=DataProperties(i).Date;
    pos=DataProperties(i).Location;
    if lower(pos(4:6))=='cel'
        for j=1:nt
            times(j)=Data.CEL(j).year;
        end
        itim0=find(times==tim);
        itim=itim0(1);
        if DataProperties(i).Block>0
            itim=DataProperties(i).Block;
        end
        xdist=pathdistance(Data.CEL(1).Xcoast,Data.CEL(1).Ycoast);
        switch lower(DataProperties(i).Parameter),
            case {'coast line'}
                DataProperties(i).x=Data.CEL(itim).Xcoast;
                DataProperties(i).y=Data.CEL(itim).Ycoast;
                DataProperties(i).Type='Polyline';
            case {'xcoast'}
                DataProperties(i).x=xdist;
                DataProperties(i).y=Data.CEL(itim).Xcoast;
                DataProperties(i).Type='XYSeries';
            case {'ycoast'}
                DataProperties(i).x=xdist;
                DataProperties(i).y=Data.CEL(itim).Ycoast;
                DataProperties(i).Type='XYSeries';
            case {'y'}
                DataProperties(i).x=xdist;
                DataProperties(i).y=Data.CEL(itim).N;
                DataProperties(i).Type='XYSeries';
            case {'y-y0'}
                DataProperties(i).x=xdist;
                DataProperties(i).y=Data.CEL(itim).N_N0;
                DataProperties(i).Type='XYSeries';
            case {'source'}
                DataProperties(i).x=xdist;
                DataProperties(i).y=Data.CEL(itim).source;
                DataProperties(i).Type='XYSeries';
            case {'alfa'}
                DataProperties(i).x=xdist;
                DataProperties(i).y=Data.CEL(itim).alfa;
                DataProperties(i).Type='XYSeries';
            case {'s'}
                DataProperties(i).x=xdist;
                DataProperties(i).y=Data.CEL(itim).S;
                DataProperties(i).Type='XYSeries';
        end
    else
        for j=1:nt
            times(j)=Data.RAY(j).year;
        end
        itim=find(times==tim);
        if DataProperties(i).Block>0
            itim=DataProperties(i).Block;
        end
        xdist=pathdistance(Data.RAY(1).Xcoast,Data.RAY(1).Ycoast);
        switch lower(DataProperties(i).Parameter),
            case {'coast line'}
                DataProperties(i).x=Data.RAY(itim).Xcoast;
                DataProperties(i).y=Data.RAY(itim).Ycoast;
                DataProperties(i).Type='Polyline';
            case {'xcoast'}
                DataProperties(i).x=xdist;
                DataProperties(i).y=Data.RAY(itim).Xcoast;
                DataProperties(i).Type='XYSeries';
            case {'ycoast'}
                DataProperties(i).x=xdist;
                DataProperties(i).y=Data.RAY(itim).Ycoast;
                DataProperties(i).Type='XYSeries';
            case {'n'}
                DataProperties(i).x=xdist;
                DataProperties(i).y=Data.RAY(itim).N;
                DataProperties(i).Type='XYSeries';
            case {'transport'}
                DataProperties(i).x=xdist;
                DataProperties(i).y=Data.RAY(itim).transport;
                DataProperties(i).Type='XYSeries';
            case {'vol'}
                DataProperties(i).x=xdist;
                DataProperties(i).y=Data.RAY(itim).vol.passed;
                DataProperties(i).Type='XYSeries';
            case {'alfa'}
                DataProperties(i).x=xdist;
                DataProperties(i).y=Data.RAY(itim).alfa;
                DataProperties(i).Type='XYSeries';
            case {'s'}
                DataProperties(i).x=xdist;
                DataProperties(i).y=Data.RAY(itim).S;
                DataProperties(i).Type='XYSeries';
        end
    end
    DataProperties(i).TC='t';
    mt=zeros(size(times));
    DataProperties(i).AvailableTimes=datenum(times,mt,mt,mt,mt,mt);
end

DataProperties(i).z=0;

clear Data

