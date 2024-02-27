function gt31 = process_drifterlog(mid,mdir)
oetsettings;
% read GT31 data
% read file names
% ad reniers july 25th 2012

% cd('D:\GPS_DATA')
d= dir([mdir filesep mid filesep '*.TXT']);


% initialize arrays
nn = length(d);
gt31 = cell(nn,1);
% for jn = 1:nn
%     gt31{jn}.time =[];
%     gt31{jn}.lat =[];
%     gt31{jn}.lon =[];
%     gt31(jn).height =[];
% end

%  d= dir('*.TXT');
%  nd = length(d);
for jd = 1:nn
    %[string,time,lat,orient1,lon,orient2,dum1,dum2,dum3,height] = textread(d(jd).name,'%s%s%f%s%f%s%s%s%s%f%*[^\n]','delimiter',',');
    [hour,minute,second,lat,lon,height,velocity] = read_drifterlog([mdir filesep mid filesep d(jd).name]);
    % sensor name
    % make structured array for each sensor
    year = str2double(d(jd).name(25:28));
    month= str2num(d(jd).name(29:30));
    day  = str2num(d(jd).name(31:32));
    %         tim1 = cell2mat(time);
    %         hour = str2num(tim1(:,1:2));
    idh = find((hour(2:end)-hour(1:end-1))<0); % find start of new days
    nh = length(idh);
    for jh = 1:nh
        hour(idh(jh)+1:end) = hour(idh(jh)+1:end)+24;
    end
    %         minutes  = str2num(tim1(:,3:4));
    %         sec  = str2num(tim1(:,5:end));
    yd = datenum(year,month,day,hour,minute,second);
    % get decimal degrees
    deg = floor(lat/100);
    dmin= (lat-deg*100)/60;
    latd = deg+dmin;
    deg = floor(lon/100);
    dmin= (lon-deg*100)/60;
    lond = deg+dmin;
    % get name
    unit = str2num(d(jd).name(2:3));
    % Convert to RD coordinates
    [x,y] = convertCoordinates(lond,latd,'CS1.code','4326','CS2.code','28992');
    
    % output data
    gt31_t.name = unit;
    gt31_t.time = yd;
    gt31_t.epoch = mat2ep(yd);
    gt31_t.lat =  latd;
    gt31_t.lon =  lond;
    gt31_t.x = x;
    gt31_t.y = y;
    gt31_t.height = height;
    gt31_t.velocity = velocity/1.94384449; % Convert from nautical miles / hour to meters / second
    gt31{jd} = gt31_t;
end

gt31 = split_gt31(gt31,mdir,mid,d);

end

function gt31 = split_gt31(gt31,mdir,mid,d)
[~,~,txt] = xlsread([mdir filesep mid filesep mid '.xlsx']);

fn = fieldnames(gt31{1});
for i = 1:length(gt31)
    gt31_t = gt31{i};
    did = str2num(d(i).name(2:3));
    xlinds = ~isnan([txt{:,1}]);
    txt = txt(xlinds,:);
    xlinds = [];
    for k = 1:size(txt,2)
        if sum(isnan([txt{:,k}])) ~= size(txt,1)
            xlinds = [xlinds;k];
        end
    end
    txt = txt(:,xlinds);
    for k = 1:(size(txt,2)-1)/2
        xlrid = find([txt{:,1}] == did);
        tstart = datenum(2014,str2num(mid(end-1:end)),str2num(mid(end-4:end-3))) + txt{xlrid,k*2};
        tend = datenum(2014,str2num(mid(end-1:end)),str2num(mid(end-4:end-3))) + txt{xlrid,k*2+1};
        if strcmpi(datestr(tend,'HH:MM'),'23:59')
            tend = datenum(2100,1,1,0,0,0);
        end
        if length(tend) > 1 || length(tstart) > 1
            tind = [];
        else
            tind = gt31_t.time >= tstart & gt31_t.time <= tend;
        end
        flen = length(gt31_t.lon);
        for j = 1:length(fn)
            aflen = eval(['length(gt31_t.' fn{j} ');']);
            if aflen == flen
                eval(['gt31_t2(' num2str(k) ').' fn{j} '=gt31_t.' fn{j} '(tind);']);
            else
                eval(['gt31_t2(' num2str(k) ').' fn{j} '=gt31_t.' fn{j} ';']);
            end
        end
    end
    gt31{i} = gt31_t2;
end
end

function epochTime = mat2ep(mattime)
ep = datenum( 1970, 1, 1, 0, 0, 0 );
epochTime = round((mattime - ep) * (24*3600));
end