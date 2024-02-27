function ConvertWW3spc(fname1,fname2,coordsys,coordsystype)
% ConvertWW3spc(fname1,fname2,coordsys,coordsystype)

%% Read Spec
fid=fopen(fname1,'r');

f=fgetl(fid);
v=strread(f,'%s','whitespace','\\''');

spec.name=v{1};
%spec.model=v{3};

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
        if spec.time(k).point(i).windDir<0
            spec.time(k).point(i).windDir+360;
        end
        spec.time(k).point(i).curSpeed=pars(6);
        spec.time(k).point(i).curDir=pars(7);
        if spec.time(k).point(i).curDir<0
            spec.time(k).point(i).curDir+360;
        end
        data=textscan(fid,'%f',nbin);
        spec.time(k).point(i).energy=data{1};
        f=fgetl(fid);
    end        
end

fclose(fid);

%% Convert coordinates
convc=0;
if ~strcmpi(coordsys,'wgs 84')
    convc=1;
    for it=1:length(spec.time);
        for ip=1:spec.nPoints
            [spec.time(it).point(ip).lon,spec.time(it).point(ip).lat]=convertCoordinates(spec.time(it).point(ip).lon,spec.time(it).point(ip).lat,'persistent','CS1.name','WGS 84','CS1.type','geographic','CS2.name',coordsys,'CS2.type',coordsystype);
        end
    end
end

% spec.dirs=flipud(spec.dirs);
% spec.freqs=flipud(spec.freqs);

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

%% Write sp2

fi2=fopen(fname2,'wt');

fprintf(fi2,'%s\n','SWAN   1                                Swan standard spectral file, version');
fprintf(fi2,'%s\n','$   Data produced by SWAN version 40.51AB             ');
fprintf(fi2,'%s\n','$   Project:                 ;  run number:     ');
fprintf(fi2,'%s\n','TIME                                    time-dependent data');
fprintf(fi2,'%s\n','     1                                  time coding option');
if convc
    switch lower(coordsystype)
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
    fprintf(fi2,'%15.6f %15.6f\n',spec.time(1).point(j).lon,spec.time(1).point(j).lat);
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

for it=1:length(spec.time);
    fprintf(fi2,'%s\n',datestr(spec.time(it).time,'yyyymmdd.HHMMSS'));
    for j=1:spec.nPoints

        rhow=1025;
        g=9.81;
        f=pi/180;
        
        spec.time(it).point(j).energy=spec.time(it).point(j).energy*rhow*g*f;

        emax=max(max(spec.time(it).point(j).energy));
        spec.time(it).point(j).factor=emax/990099;
        spec.time(it).point(j).energy=round(spec.time(it).point(j).energy/spec.time(it).point(j).factor);
               
        spec.time(it).point(j).energy=reshape(spec.time(it).point(j).energy,[spec.nFreq spec.nDir]);
        spec.time(it).point(j).energy=transpose(spec.time(it).point(j).energy);
%         spec.time(it).point(j).energy=flipud(spec.time(it).point(j).energy);
%         spec.time(it).point(j).energy=fliplr(spec.time(it).point(j).energy);
        spec.time(it).point(j).energy=reshape(spec.time(it).point(j).energy,[1 spec.nFreq*spec.nDir]);

        if spec.time(it).point(j).factor>0
            fprintf(fi2,'%s\n','FACTOR');
            fprintf(fi2,'%18.8e\n',spec.time(it).point(j).factor);
            fmt=repmat([repmat('  %7i',1,spec.nDir) '\n'],1,spec.nFreq);
            fprintf(fi2,fmt,spec.time(it).point(j).energy);
        else
            fprintf(fi2,'%s\n','NODATA');
        end
    end

end
fclose(fi2);













% %% Write spec
% 
% fid=fopen(fname2,'wt');
% 
% str1=['''' spec.name ''''];
% str2=sprintf('%6.0f',spec.nFreq);
% str3=sprintf('%6.0f',spec.nDir);
% str4=sprintf('%6.0f',spec.nPoints);
% str5=['''' spec.model ''' '];
% 
% str=[str1 ' ' str2 str3 str4 ' ' str5];
% fprintf(fid,'%s\n',str);
% 
% nlines=floor(spec.nFreq/8);
% nlast=spec.nFreq-nlines*8;
% fmt=repmat([repmat(' %9.2E',1,8) '\n'],1,nlines);
% if nlast>0
%     fmt=[fmt repmat(' %9.2E',1,nlast) '\n'];
% end
% fprintf(fid,fmt,spec.freqs);
% 
% nlines=floor(spec.nDir/7);
% nlast=spec.nDir-nlines*7;
% fmt=repmat([repmat('  %9.2E',1,7) '\n'],1,nlines);
% if nlast>0
%     fmt=[fmt repmat('  %9.2E',1,nlast) '\n'];
% end
% fprintf(fid,fmt,spec.dirs);
% 
% nt=length(spec.time);
% 
% for it=1:nt
%     fprintf(fid,'%s\n',datestr(spec.time(it).time,'yyyymmdd HHMMSS'));
% 
%     for ip=1:spec.nPoints
%         str=['''' spec.time(it).point(ip).name '''' num2str(spec.time(it).point(ip).lat,'%10.2f') num2str(spec.time(it).point(ip).lon,'%10.2f') num2str(spec.time(it).point(ip).Depth,'%10.1f')];
%         fprintf(fid,'%s%s%s%7.2f%8.2f%10.1f%7.2f%6.1f%7.2f%6.1f\n','''',spec.time(it).point(ip).name,'''',spec.time(it).point(ip).lat,spec.time(it).point(ip).lon,spec.time(it).point(ip).Depth,spec.time(it).point(ip).windSpeed,spec.time(it).point(ip).windDir,spec.time(it).point(ip).curSpeed,spec.time(it).point(ip).curDir);
% 
%         nlines=floor(nbin/7);
%         nlast=nbin-nlines*7;
%         fmt=repmat([repmat('  %9.2E',1,7) '\n'],1,nlines);
%         if nlast>0
%             fmt=[fmt repmat('  %9.2E',1,nlast) '\n'];
%         end
%         fprintf(fid,fmt,spec.time(it).point(ip).energy);
% 
%     end
% 
% end
% 
% 
% fclose(fid);
% 
% 
% 
