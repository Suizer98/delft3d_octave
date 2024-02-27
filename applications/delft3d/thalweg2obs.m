function varargout = thalweg2obs(varargin)
%THALWEG2OBS helper for vs_trih2thalweg
%Creates equally spaced kml-line and observation points needed for
%vs_trih2thalweg
%Input: grd = D3D grid filename
%       kml = kml filename containing thalweg
%       dn = spacing for new kml (default = 100 m)
%       epsg = 28992; % default Rijksdriehoek
%       st_no  = 0; % can be used to start count stations at higher number (for combining tracks in 1 obsfile)
%       continuoustrack = 0; % to get obs points in consecutive grid cells
%       (time consuming)
% Output: number of obs
%See also: KML2Coordinates, arbcross, vs_trih2thalweg

OPT.grd    = '';
OPT.kml    = '';
OPT.dn     = 100;
OPT.epsg   = 28992; % default Rijksdriehoek
OPT.st_no  = 0; % can be used to start count stations at higher number (for combining tracks in 1 obsfile)
OPT.continuoustrack = 0; % 

if nargin==0
   varargout = {OPT};
   return
end

OPT = setproperty(OPT,varargin);
OPT.kmlout = [filename(OPT.kml) '_' num2str(OPT.dn) 'm.kml'];
OPT.obs    = ['thalweg_' filename(OPT.kml) '.obs'];

% read input
grd = wlgrid('read',OPT.grd);
[T.lat,T.lon] = KML2Coordinates(OPT.kml);

% convert to same coordinate system
[T.x,T.y] = convertCoordinates(T.lon,T.lat,'CS1.code',4326,'CS2.code',OPT.epsg);

% determine total track length
T.cumlength(1)=0;
for t=1:length(T.y)-1
    T.length(t) = sqrt((T.x(t+1)-T.x(t)).^2+(T.y(t+1)-T.y(t)).^2);
    T.cumlength(t+1)=T.cumlength(t)+T.length(t);
end
T.totlength=sum(T.length);

% create newly spaced track (with dn m interval)
xl=0:OPT.dn:T.totlength;
T.newx(1)=T.x(1);
T.newy(1)=T.y(1);
for t=2:length(xl)
    sect=find(T.cumlength<=xl(t));
    sect=sect(end);
    T.newx(t)=T.x(sect)+((T.x(sect+1)-T.x(sect))/T.length(sect))*(xl(t)-T.cumlength(sect));
    T.newy(t)=T.y(sect)+((T.y(sect+1)-T.y(sect))/T.length(sect))*(xl(t)-T.cumlength(sect));
end
[T.newlon,T.newlat] = convertCoordinates(T.newx,T.newy,'CS1.code',OPT.epsg,'CS2.code',4326);
KMLline(T.newlat,T.newlon,'fileName',OPT.kmlout,'lineColor',[1 0 0],'lineWidth',1)

% figure;
% hold on
% plot(grd.X,grd.Y,'k')
% plot(grd.X',grd.Y','k')
% axis equal
% plot(T.x,T.y,'r-o','linewidth',2)
% plot(int.x,int.y,'g-x','linewidth',2)

if OPT.continuoustrack 
    [int.x,int.y] = arbcross(grd.X,grd.Y,T.x,T.y); %int is a matrix with intersections with grid and points in KML file
    q=1;
    for i=1:length(int.x)
        % use only intersections
        pp=find(int.x(i)==T.x);
        qq=find(int.y(i)==T.x);
        if isempty(pp) && isempty(qq) && ~isnan(int.x(i))
            T.intx(q) = int.x(i);
            T.inty(q) = int.y(i);

            clear xx vv pp
            for j=1:size(grd.X,1)
                for k=1:size(grd.X,2)
                    xx(j,k)=((grd.X(j,k)-T.intx(q)).^2+(grd.Y(j,k)-T.inty(q)).^2);
                end
            end
            vv=min(min(xx));
            [m(q),n(q)]=find(xx==vv);
            q=q+1;
        end
    end
else
    for ii = 1:length(T.newx)
        dist = ((grd.X-T.newx(ii)).^2+(grd.Y-T.newy(ii)).^2).^0.5;
        if min(min(dist))<=0.5*OPT.dn
            [m(ii),n(ii)] = find(dist==min(min(dist)));
            m(ii) = m(ii)+1;
            n(ii) = n(ii)+1;
        end
    end
end
        
mn=unique([m' n'],'rows','stable');

%% write obs file
fid=fopen(OPT.obs,'w');

for l=1:length(mn)
    fprintf(fid,'%-20s%6s%7s\n',['thalweg' num2str(l+OPT.st_no)],num2str(mn(l,1)),num2str(mn(l,2)));
end
fclose(fid);

varargout{1} = length(mn);
