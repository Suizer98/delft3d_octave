function [st,id,long,lati]=makeobs(xlim,ylim)

stations=nc_varget('d:\delftdashboard\data\toolboxes\TideStations\xtide.nc','stations');
idcodes=nc_varget('d:\delftdashboard\data\toolboxes\TideStations\xtide.nc','idcodes');
lon=nc_varget('d:\delftdashboard\data\toolboxes\TideStations\xtide.nc','lon');
lat=nc_varget('d:\delftdashboard\data\toolboxes\TideStations\xtide.nc','lat');

ns=0;
for i=1:length(lon)
    if lon(i)>=xlim(1) && lon(i)<=xlim(2) &&  lat(i)>=ylim(1) && lat(i)<=ylim(2)
        ns=ns+1;
        stat=stations(:,i);
        stat=stat';
        stat=deblank(stat);
        st{ns}=stat;
        ids=idcodes(:,i);
        ids=ids';
        ids=deblank(ids);
        id{ns}=ids;
        long(ns)=lon(i);
        lati(ns)=lat(i);
    end
end
