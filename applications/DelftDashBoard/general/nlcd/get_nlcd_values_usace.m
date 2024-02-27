function s=get_nlcd_values(filename,x,y,cs,varargin)

get_nlcd=0;
get_manning=0;
get_cn=0;
soiltype='B';

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch varargin{ii}
            case{'nlcd'}
                get_nlcd=1;
            case{'manning'}
                get_manning=1;
            case{'cn'}
                get_cn=1;
            case{'soiltype'}
                soiltype=varargin{ii+1};
        end
    end
end

% Convert x and y coordinates to Albers Equal Area
[x1,y1]=convertCoordinates(x,y,'persistent','CS1.name',cs.name,'CS1.type',cs.type,'CS2.code',2278);

xmin=min(min(x1));
xmax=max(max(x1));
ymin=min(min(y1));
ymax=max(max(y1));

% Add a little buffer
dx=xmax-xmin;
dy=ymax-ymin;
xmin=xmin-0.1*dx;
xmax=xmax+0.1*dx;
ymin=ymin-0.1*dy;
ymax=ymax+0.1*dy;

% Read NLCD values 
[nlcd,xa,ya,I] = geoimread(filename,[xmin xmax],[ymin ymax]);

xa=xa+5; % cell centres
ya=ya+5; % cell centres

if get_nlcd
    s.nlcd=interp2(xa,ya,nlcd,x1,y1,'nearest'); % Interpolate to grid
end
if get_manning
    manning=nlcd2manning_usace(nlcd);                  % Convert NLCD to Manning
    s.manning=interp2(xa,ya,manning,x1,y1);       % Interpolate to grid
end
if get_cn
    cn=nlcd2cn(nlcd,soiltype);               % Convert to CN numbers
    s.cn=interp2(xa,ya,cn,x1,y1);       % Interpolate to grid
end
