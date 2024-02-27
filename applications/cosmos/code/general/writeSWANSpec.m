function writeSWANSpec(fname,spec,varargin)

cs.type='geographic';

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'cs'}
                cs=varargin{ii+1};
        end
    end
end

i1=1;
i2=length(spec.x);

fi2=fopen(fname,'wt');

% Write to merged sp2-file
fprintf(fi2,'%s\n','SWAN   1                                Swan standard spectral file, version');
fprintf(fi2,'%s\n','$   Data produced by SWAN version 40.51AB             ');
fprintf(fi2,'%s\n','$   Project:                 ;  run number:     ');
fprintf(fi2,'%s\n','TIME                                    time-dependent data');
fprintf(fi2,'%s\n','     1                                  time coding option');
switch lower(cs.type(1:3))
    case{'pro','car'}
    fprintf(fi2,'%s\n','LOCATIONS');
    otherwise
    fprintf(fi2,'%s\n','LONLAT                                  locations in spherical coordinates');
end
fprintf(fi2,'%i\n',i2-i1+1);
for j=i1:i2
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

for it=1:length(spec.time)
    fprintf(fi2,'%s\n',datestr(spec.time(it).time,'yyyymmdd.HHMMSS'));
    for j=i1:i2
        if spec.time(it).points(j).factor>0
            fprintf(fi2,'%s\n','FACTOR');
            fprintf(fi2,'%18.8e\n',spec.time(it).points(j).factor);
            fmt=repmat([repmat('  %7i',1,spec.nDir) '\n'],1,spec.nFreq);
            fprintf(fi2,fmt,spec.time(it).points(j).energy');
        else
            fprintf(fi2,'%s\n','NODATA');
        end
    end
end
fclose(fi2);
