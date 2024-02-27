function tc=tc_read_jmv30(fname)

fid=fopen(fname,'r');

% Read header
str=fgetl(fid); % dummy
str=fgetl(fid); % dummy
str=fgetl(fid);
if isempty(str) % Empty line, try another line
    str=fgetl(fid);
end
f=strread(str,'%s','delimiter',' ');
t0=datenum(f{1}(1:10),'yyyymmddHH');
tc.name=f{3};
tc.advisorynumber=str2double(f{4});
it=0;
while 1
    str=fgetl(fid);
    f=strread(str,'%s','delimiter',' ');
    if ~strcmpi(f{1}(1),'T')
        break
    end
    it=it+1;
    tc.time(it)=t0+str2double(f{1}(2:end))/24;
    latstr=f{2};
    if strcmpi(latstr(end),'N')
        tc.y(it)=0.10*str2double(latstr(1:end-1));
    else
        tc.y(it)=-0.10*str2double(latstr(1:end-1));
    end
    lonstr=f{3};
    if strcmpi(lonstr(end),'E')
        tc.x(it)=0.10*str2double(lonstr(1:end-1));
    else
        tc.x(it)=-0.10*str2double(lonstr(1:end-1));
    end
    tc.vmax(it)=str2double(f{4}); 
    tc.r35ne(it)=NaN;
    tc.r35se(it)=NaN;
    tc.r35sw(it)=NaN;
    tc.r35nw(it)=NaN;
    tc.r50ne(it)=NaN;
    tc.r50se(it)=NaN;
    tc.r50sw(it)=NaN;
    tc.r50nw(it)=NaN;
    tc.r65ne(it)=NaN;
    tc.r65se(it)=NaN;
    tc.r65sw(it)=NaN;
    tc.r65nw(it)=NaN;
    tc.r100ne(it)=NaN;
    tc.r100se(it)=NaN;
    tc.r100sw(it)=NaN;
    tc.r100nw(it)=NaN;
    for n=5:length(f)
        switch lower(f{n})
            case{'r034'}
                tc.r35ne(it)=str2double(f{n+1});
                tc.r35se(it)=str2double(f{n+4});
                tc.r35sw(it)=str2double(f{n+7});
                tc.r35nw(it)=str2double(f{n+10});
            case{'r050'}
                tc.r50ne(it)=str2double(f{n+1});
                tc.r50se(it)=str2double(f{n+4});
                tc.r50sw(it)=str2double(f{n+7});
                tc.r50nw(it)=str2double(f{n+10});
            case{'r064'}
                tc.r65ne(it)=str2double(f{n+1});
                tc.r65se(it)=str2double(f{n+4});
                tc.r65sw(it)=str2double(f{n+7});
                tc.r65nw(it)=str2double(f{n+10});
            case{'r100'}
                tc.r100ne(it)=str2double(f{n+1});
                tc.r100se(it)=str2double(f{n+4});
                tc.r100sw(it)=str2double(f{n+7});
                tc.r100nw(it)=str2double(f{n+10});
        end
    end
end

fclose(fid);

tc.first_forecast_time=tc.time(1);

% Now read what came before
% First find position
fid=fopen(fname,'r');
n=0;
while 1
    n=n+1;
    str=fgetl(fid);
    f=strread(str,'%s','delimiter',' ');
    if ~isempty(f)
        f=f{end};
        f=deblank2(f);
        if strcmpi(f(end-1:end),'//')
            istart=n+1;
        end
        if strcmpi(f,'NNNN')
            istop=n-2;
            break
        end
    end
end
fclose(fid);

fid=fopen(fname,'r');
for ii=1:istart-1
    str=fgetl(fid);
end

it=0;
f=[];

for ii=istart:istop
    
    str=fgetl(fid);
    
%    f=strread(str,'%s','delimiter',' ');
    f{1}=str(1:10);
    f{2}=str(12:20);
    f{3}=str(21:end);


    tim=datenum(f{1}(3:end),'yymmddHH');

    if it>0
        if abs(tim-tc0.time(it))<1/86400
            % Time was already given, skip this record
            continue
        end
    end
    
    it=it+1;
    
    tc0.time(it)=datenum(f{1}(3:end),'yymmddHH');
    
    idir=find(f{2}=='N');
    if isempty(idir)
        idir=find(f{2}=='S');
    end        
    latstr=f{2}(1:idir);
    if strcmpi(latstr(end),'N')
        tc0.y(it)=0.10*str2double(latstr(1:end-1));
    else
        tc0.y(it)=-0.10*str2double(latstr(1:end-1));
    end
        
    lonstr=f{2}(idir+1:end);
    if strcmpi(lonstr(end),'E')
        tc0.x(it)=0.10*str2double(lonstr(1:end-1));
    else
        tc0.x(it)=-0.10*str2double(lonstr(1:end-1));
    end
    
    yr=2000+str2double(f{1}(3:4));
    mn=str2double(f{1}(5:6));
    dy=str2double(f{1}(7:8));
    hr=str2double(f{1}(9:10));
    tc0.time(it)=datenum(yr,mn,dy,hr,0,0);
    
    tc0.vmax(it)=str2double(f{3}); 
    tc0.r35ne(it)=NaN;
    tc0.r35se(it)=NaN;
    tc0.r35sw(it)=NaN;
    tc0.r35nw(it)=NaN;
    tc0.r50ne(it)=NaN;
    tc0.r50se(it)=NaN;
    tc0.r50sw(it)=NaN;
    tc0.r50nw(it)=NaN;
    tc0.r65ne(it)=NaN;
    tc0.r65se(it)=NaN;
    tc0.r65sw(it)=NaN;
    tc0.r65nw(it)=NaN;
    tc0.r100ne(it)=NaN;
    tc0.r100se(it)=NaN;
    tc0.r100sw(it)=NaN;
    tc0.r100nw(it)=NaN;
end

if abs(tc0.time(end)-tc.time(1))<1/86400
    % Times of forecast and hindcast overlap
    tc0.time=tc0.time(1:end-1);
    tc0.x=tc0.x(1:end-1);
    tc0.y=tc0.y(1:end-1);
    tc0.vmax=tc0.vmax(1:end-1);
    tc0.r35ne=tc0.r35ne(1:end-1);
    tc0.r35se=tc0.r35se(1:end-1);
    tc0.r35sw=tc0.r35sw(1:end-1);
    tc0.r35nw=tc0.r35nw(1:end-1);
    tc0.r50ne=tc0.r50ne(1:end-1);
    tc0.r50se=tc0.r50se(1:end-1);
    tc0.r50sw=tc0.r50sw(1:end-1);
    tc0.r50nw=tc0.r50nw(1:end-1);
    tc0.r65ne=tc0.r65ne(1:end-1);
    tc0.r65se=tc0.r65se(1:end-1);
    tc0.r65sw=tc0.r65sw(1:end-1);
    tc0.r65nw=tc0.r65nw(1:end-1);
    tc0.r100ne=tc0.r100ne(1:end-1);
    tc0.r100se=tc0.r100se(1:end-1);
    tc0.r100sw=tc0.r100sw(1:end-1);
    tc0.r100nw=tc0.r100nw(1:end-1);
end

% Merge
tc.time=[tc0.time tc.time];
tc.x=[tc0.x tc.x];
tc.y=[tc0.y tc.y];
tc.vmax=[tc0.vmax tc.vmax]; 
tc.r35ne=[tc0.r35ne tc.r35ne]; 
tc.r35se=[tc0.r35se tc.r35se]; 
tc.r35sw=[tc0.r35sw tc.r35sw]; 
tc.r35nw=[tc0.r35nw tc.r35nw]; 
tc.r50ne=[tc0.r50ne tc.r50ne]; 
tc.r50se=[tc0.r50se tc.r50se]; 
tc.r50sw=[tc0.r50sw tc.r50sw]; 
tc.r50nw=[tc0.r50nw tc.r50nw]; 
tc.r65ne=[tc0.r65ne tc.r65ne]; 
tc.r65se=[tc0.r65se tc.r65se]; 
tc.r65sw=[tc0.r65sw tc.r65sw]; 
tc.r65nw=[tc0.r65nw tc.r65nw]; 
tc.r100ne=[tc0.r100ne tc.r100ne]; 
tc.r100se=[tc0.r100se tc.r100se]; 
tc.r100sw=[tc0.r100sw tc.r100sw]; 
tc.r100nw=[tc0.r100nw tc.r100nw]; 

fclose(fid);


tc.r35ne(isnan(tc.r35ne))=-999;
tc.r35se(isnan(tc.r35se))=-999;
tc.r35sw(isnan(tc.r35sw))=-999;
tc.r35nw(isnan(tc.r35nw))=-999;
tc.r50ne(isnan(tc.r50ne))=-999;
tc.r50se(isnan(tc.r50se))=-999;
tc.r50sw(isnan(tc.r50sw))=-999;
tc.r50nw(isnan(tc.r50nw))=-999;
tc.r65ne(isnan(tc.r65ne))=-999;
tc.r65se(isnan(tc.r65se))=-999;
tc.r65sw(isnan(tc.r65sw))=-999;
tc.r65nw(isnan(tc.r65nw))=-999;
tc.r100ne(isnan(tc.r100ne))=-999;
tc.r100se(isnan(tc.r100se))=-999;
tc.r100sw(isnan(tc.r100sw))=-999;
tc.r100nw(isnan(tc.r100nw))=-999;
