function ConvertSWANNestSpec(dr,fout,varargin)

convc=0;
if nargin>2
    convc=1;
    hm=varargin{1};
    m1=varargin{2};
    m2=varargin{3};
end

lst=dir([dr '*.sp2']);

n=length(lst);

fi2=fopen(fout,'wt');

for i=1:n
    
    fname=lst(i).name;
    fid=fopen([dr fname],'r');
        
    f=fgetl(fid);
    f=fgetl(fid);
    f=fgetl(fid);
    f=fgetl(fid);
    f=fgetl(fid);
    f=fgetl(fid);

    f=fgetl(fid);

    spec.nPoints=str2double(f(1:12));

    for j=1:spec.nPoints
        f=fgetl(fid);
        [spec.x(j) spec.y(j)]=strread(f);
    end
    
    if convc
        if ~strcmpi(hm.models(m1).coordinateSystem,hm.models(m2).coordinateSystem) || ~strcmpi(hm.models(m1).coordinateSystemType,hm.models(m2).coordinateSystemType)
            % Convert coordinates
            [spec.x,spec.y]=convertCoordinates(spec.x,spec.y,'persistent','CS1.name',hm.models(m1).coordinateSystem,'CS1.type',hm.models(m1).coordinateSystemType,'CS2.name',hm.models(m2).coordinateSystem,'CS2.type',hm.models(m2).coordinateSystemType);
        end
    end

    f=fgetl(fid);

    f=fgetl(fid);
    spec.nFreq=str2double(f(1:12));
    
    for j=1:spec.nFreq
        f=fgetl(fid);
        spec.freqs(j)=strread(f);
    end

    f=fgetl(fid);

    f=fgetl(fid);
    spec.nDir=str2double(f(1:12));
    
    for j=1:spec.nDir
        f=fgetl(fid);
        spec.dirs(j)=strread(f);
    end
    
    f=fgetl(fid);
    f=fgetl(fid);
    f=fgetl(fid);
    f=fgetl(fid);
    f=fgetl(fid);

    f=fgetl(fid);
    f=f(1:15);
    
    it=1;
    
    spec.time(it).time=datenum(f,'yyyymmdd.HHMMSS');
    
    nbin=spec.nDir*spec.nFreq;

    for j=1:spec.nPoints  
        f=fgetl(fid);
        deblank(f);
        if strcmpi(deblank(f),'factor')
            f=fgetl(fid);
            spec.time(it).points(j).factor=strread(f);
            data=textscan(fid,'%f',nbin);
            data=data{1};
            data=reshape(data,spec.nDir,spec.nFreq);
            data=data';
            spec.time(it).points(j).energy=data;
            f=fgetl(fid);
        else
            spec.time(it).points(j).factor=0;
            spec.time(it).points(j).energy=0;
        end            
    end

    if i==1
        fprintf(fi2,'%s\n','SWAN   1                                Swan standard spectral file, version');
        fprintf(fi2,'%s\n','$   Data produced by SWAN version 40.51AB             ');
        fprintf(fi2,'%s\n','$   Project:                 ;  run number:     ');
        fprintf(fi2,'%s\n','TIME                                    time-dependent data');
        fprintf(fi2,'%s\n','     1                                  time coding option');
        if convc
            switch lower(hm.models(m2).coordinateSystemType)
                case{'proj','projection','projected','cart','cartesian','xy'}
                    fprintf(fi2,'%s\n','LOCATIONS');
                otherwise
                    fprintf(fi2,'%s\n','LONLAT                                  locations in spherical coordinates');
            end
        else
            fprintf(fi2,'%s\n','LONLAT                                  locations in spherical coordinates');
        end
        fprintf(fi2,'%i\n',spec.nPoints);
        for j=1:spec.nPoints
            fprintf(fi2,'%15.6f %15.6f\n',spec.x(j),spec.y(j));
        end
        fprintf(fi2,'%s\n','AFREQ                                   absolute frequencies in Hz');
        fprintf(fi2,'%6i\n',spec.nFreq);
        for j=1:spec.nFreq
            fprintf(fi2,'%15.4f\n',spec.freqs(j));
        end
        fprintf(fi2,'%s\n','NDIR                                   spectral nautical directions in degr');
        fprintf(fi2,'%i\n',spec.nDir);
        for j=1:spec.nDir
            fprintf(fi2,'%15.4f\n',spec.dirs(j));
        end
        fprintf(fi2,'%s\n','QUANT');
        fprintf(fi2,'%s\n','     1                                  number of quantities in table');
        fprintf(fi2,'%s\n','EnDens                                  energy densities in J/m2/Hz/degr');
        fprintf(fi2,'%s\n','J/m2/Hz/degr                            unit');
        fprintf(fi2,'%s\n','   -0.9900E+02                          exception value');
    end
    
    fprintf(fi2,'%s\n',datestr(spec.time(it).time,'yyyymmdd.HHMMSS'));
    for j=1:spec.nPoints
        if spec.time(it).points(j).factor>0
            fprintf(fi2,'%s\n','FACTOR');
            fprintf(fi2,'%18.8e\n',spec.time(it).points(j).factor);
            fmt=repmat([repmat('  %7i',1,spec.nDir) '\n'],1,spec.nFreq);
            fprintf(fi2,fmt,spec.time(it).points(j).energy');
        else
            fprintf(fi2,'%s\n','NODATA');
        end
    end
    fclose(fid);
end
fclose(fi2);
