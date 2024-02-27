function cosmos_extractWW3spectra(fname1,isp2,fnames)

rhow=1025;
g=9.81;
ff=pi/180;

%% Read Spec
fid=fopen(fname1,'r');

f=fgetl(fid);
v=strread(f,'%s','whitespace','\\''');

spec.name=v{1};
spec.model=v{3};

n=strread(v{2});

spec.nFreq=n(1);
spec.nDir=n(2);
spec.nPoints=n(3);

freq=textscan(fid,'%f',spec.nFreq);
spec.freqs=freq{1};

dr=textscan(fid,'%f',spec.nDir);
spec.dirs=dr{1};

nbin=spec.nFreq*spec.nDir;

f=fgetl(fid);

k=0;
while 1
    k=k+1;
    f=fgetl(fid);
    if ~ischar(f)
        break
    end
    spec.times(k)=datenum(f,'yyyymmdd HHMMSS');
    spec.time(k).time=datenum(f,'yyyymmdd HHMMSS');
    for i=1:spec.nPoints
        f=fgetl(fid);
        v=strread(f,'%s','whitespace','\\''');
        pars=strread(v{2});
        spec.time(k).point(i).name=v{1};
        spec.time(k).point(i).lat=pars(1);
        spec.time(k).point(i).lon=pars(2);
        if spec.time(k).point(i).lon>180
            spec.time(k).point(i).lon=spec.time(k).point(i).lon-360;
        end
        spec.time(k).point(i).Depth=pars(3);
        spec.time(k).point(i).windSpeed=pars(4);
        spec.time(k).point(i).windDir=pars(5);
%         if spec.time(k).point(i).windDir<0
%             spec.time(k).point(i).windDir+360;
%         end
        spec.time(k).point(i).curSpeed=pars(6);
        spec.time(k).point(i).curDir=pars(7);
        if spec.time(k).point(i).curDir<0
            spec.time(k).point(i).curDir+360;
        end
        data=textscan(fid,'%f',nbin);
        spec.time(k).point(i).energy=data{1};
        spec.time(k).point(i).energy=spec.time(k).point(i).energy*rhow*g*ff;
        f=fgetl(fid);
    end        
end

fclose(fid);


spec.dirs=spec.dirs*180/pi+180;


imin=0;
for j=2:spec.nDir
    if spec.dirs(j)>spec.dirs(j-1)
        imin=1;
    end
    if imin
        spec.dirs(j)=spec.dirs(j)-360;
    end
end

for istat=1:length(fnames)
    spc=spec;
%    for k=1:length(isp2)
        spc.nPoints=1;
        for it=1:length(spec.time)
            spc.time(it).point=spec.time(it).point(isp2(istat));
            e=spc.time(it).point.energy;
            e=reshape(e,[spec.nFreq spec.nDir]);
            spc.time(it).point.energy=e;
        end
%    end
    save(fnames{istat},'-struct','spc');
end

% %% Write sp2 files
% for istat=1:length(fnames)
%     
%     fname2=fnames{istat};
%     ip=isp2(istat);
%     
%     fi2=fopen(fname2,'wt');
%     
%     fprintf(fi2,'%s\n','SWAN   1                                Swan standard spectral file, version');
%     fprintf(fi2,'%s\n','$   Data produced by SWAN version 40.51AB             ');
%     fprintf(fi2,'%s\n','$   Project:                 ;  run number:     ');
%     fprintf(fi2,'%s\n','TIME                                    time-dependent data');
%     fprintf(fi2,'%s\n','     1                                  time coding option');
%     fprintf(fi2,'%s\n','LONLAT                                  locations in spherical coordinates');
%     fprintf(fi2,'%i\n',1);
%     fprintf(fi2,'%15.6f %15.6f\n',spec.time(1).point(ip).lon,spec.time(1).point(ip).lat);
%     fprintf(fi2,'%s\n','AFREQ                                   absolute frequencies in Hz');
%     fprintf(fi2,'%6i\n',spec.nFreq);
%     for j=1:spec.nFreq
%         fprintf(fi2,'%15.4f\n',spec.freqs(j));
%     end
%     fprintf(fi2,'%s\n','NDIR                                   spectral nautical directions in degr');
%     fprintf(fi2,'%i\n',spec.nDir);
%     for j=1:spec.nDir
%         fprintf(fi2,'%15.4f\n',spec.dirs(j));
%     end
%     fprintf(fi2,'%s\n','QUANT');
%     fprintf(fi2,'%s\n','     1                                  number of quantities in table');
%     fprintf(fi2,'%s\n','EnDens                                  energy densities in J/m2/Hz/degr');
%     fprintf(fi2,'%s\n','J/m2/Hz/degr                            unit');
%     fprintf(fi2,'%s\n','   -0.9900E+02                          exception value');
%     
%     j=ip;
%     
%     for it=1:length(spec.time);
% 
%         fprintf(fi2,'%s\n',datestr(spec.time(it).time,'yyyymmdd.HHMMSS'));        
%         
%         rhow=1025;
%         g=9.81;
%         f=pi/180;
%         
%         spec.time(it).point(j).energy=spec.time(it).point(j).energy*rhow*g*f;
%         
%         emax=max(max(spec.time(it).point(j).energy));
%         spec.time(it).point(j).factor=emax/990099;
%         spec.time(it).point(j).energy=round(spec.time(it).point(j).energy/spec.time(it).point(j).factor);
%         
%         spec.time(it).point(j).energy=reshape(spec.time(it).point(j).energy,[spec.nFreq spec.nDir]);
%         spec.time(it).point(j).energy=transpose(spec.time(it).point(j).energy);
%         spec.time(it).point(j).energy=reshape(spec.time(it).point(j).energy,[1 spec.nFreq*spec.nDir]);
%         
%         if spec.time(it).point(j).factor>0
%             fprintf(fi2,'%s\n','FACTOR');
%             fprintf(fi2,'%18.8e\n',spec.time(it).point(j).factor);
%             fmt=repmat([repmat('  %7i',1,spec.nDir) '\n'],1,spec.nFreq);
%             fprintf(fi2,fmt,spec.time(it).point(j).energy);
%         else
%             fprintf(fi2,'%s\n','NODATA');
%         end
%         
%     end
%     
%     fclose(fi2);
% 
% end
