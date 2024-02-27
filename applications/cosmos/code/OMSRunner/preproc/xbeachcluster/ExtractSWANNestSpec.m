function [ok,times,fnames]=ExtractSWANNestSpec(dr,outdir,runid,starttime,stoptime,varargin)

convc=0;
if nargin>3
    convc=1;
    hm=varargin{1};
    m1=varargin{2};
    m2=varargin{3};
end

lst=dir([dr runid '*.sp2']);

n=length(lst);

if strcmpi(hm.models(m2).type,'xbeachcluster')
    nrprofiles=hm.models(m2).nrProfiles;
else
    nrprofiles=1;
end

ok=zeros(nrprofiles,1)+1;

nt=0;

for i=1:n
    
    disp(['Processing sp2 file ' num2str(i) ' of ' num2str(n)]);
    
    fname=lst(i).name;
    
    spec=readSWANSpec([dr fname]);
    
    fname=strrep(fname,' ','');
    
    if convc
        if ~strcmpi(hm.models(m1).coordinateSystem,hm.models(m2).coordinateSystem) || ~strcmpi(hm.models(m1).coordinateSystemType,hm.models(m2).coordinateSystemType)
            % Convert coordinates
            [spec.x,spec.y]=convertCoordinates(spec.x,spec.y,'persistent','CS1.name',hm.models(m1).coordinateSystem,'CS1.type',hm.models(m1).coordinateSystemType,'CS2.name',hm.models(m2).coordinateSystem,'CS2.type',hm.models(m2).coordinateSystemType);
        end
    end
    
    it=1;    
    
    if spec.time(it).time>=starttime && spec.time(it).time<=stoptime
        
        nt=nt+1;
        
        % Writing
        
        for jj=1:nrprofiles
            
            irun=1;
            
            if strcmpi(hm.models(m2).type,'xbeachcluster')
                irun=hm.models(m2).profile(jj).run;
                flname=[outdir hm.models(m2).profile(jj).name filesep fname];
            else
                % Regular xbeach model
                flname=[outdir fname];
            end
            
            if irun
                
                times(nt,jj)=spec.time(it).time;
                fnames{nt,jj}=fname;
                                
                fi2=fopen(flname,'wt');
                
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
                fprintf(fi2,'%i\n',1);
                fprintf(fi2,'%15.6f %15.6f\n',spec.x(jj),spec.y(jj));
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
                
                fprintf(fi2,'%s\n',datestr(spec.time(it).time,'yyyymmdd.HHMMSS'));
                
                if spec.time(it).points(jj).factor>0
                    fprintf(fi2,'%s\n','FACTOR');
                    fprintf(fi2,'%18.8e\n',spec.time(it).points(jj).factor);
                    fmt=repmat([repmat('  %7i',1,spec.nDir) '\n'],1,spec.nFreq);
                    fprintf(fi2,fmt,spec.time(it).points(jj).energy');
                else
                    fprintf(fi2,'%s\n','NODATA');
                    ok(jj)=0;
                end
                
                fclose(fi2);
            else
                ok(jj)=0;
            end
        end
    end
end
