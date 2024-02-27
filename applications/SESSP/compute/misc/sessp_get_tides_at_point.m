function wl=sessp_get_tides_at_point(tim,x,y,tidefile)

% handles=getHandles;
% ii=handles.toolbox.tidedatabase.activeModel;
% name=handles.tideModels.model(ii).name;
% if strcmpi(url(1:4),'http')
%     tidefile=[url '/' name '.nc'];
% else
%     tidefile=[url filesep name '.nc'];
% end

[lon,lat, gt, depth, conList] =  readTideModel(tidefile,'type','h','x',x','y',y','constituent','all');

% t0=handles.toolbox.tidestations.startTime;
% t1=handles.toolbox.tidestations.stopTime;
% dt=handles.toolbox.tidestations.timeStep/1440;
% 
% % t0=datenum(2017,3,1);
% % t1=datenum(2017,4,1);
% % t0=floor(now);
% % t1=t0+31;
% % dt=30/1440;
% 
% tim=t0:dt:t1;

wl=zeros(length(tim),length(x));

for ip=1:length(x)
    gt0.amp=gt.amp(ip,:);
    gt0.phi=gt.phi(ip,:);
    wl0=makeTidePrediction(tim,conList,gt0.amp,gt0.phi,y(ip));
    wl(:,ip)=wl0';
end
