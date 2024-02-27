function tc=read_spiderweb_file_delft3d(fname)

info = asciiwind('open',fname);
nt=length(info.Data);
wndspd=asciiwind('read',info,'wind_speed',1:nt);
wnddir=asciiwind('read',info,'wind_from_direction',1:nt);
pdrop =asciiwind('read',info,'p_drop',1:nt);
wndspd=wndspd(:,2:end,1:end-1);
wnddir=wnddir(:,2:end,1:end-1);
pdrop=pdrop(:,2:end,1:end-1);
% 
% n1=size(wndspd,2);
% n2=size(wndspd,3);
tc.spw_radius=info.Header.spw_radius;
for it=1:nt
    tc.track(it).time=info.Data(it).time;
    tc.track(it).x=info.Data(it).x_spw_eye;
    tc.track(it).y=info.Data(it).y_spw_eye;
    tc.track(it).wind_speed=squeeze(wndspd(it,:,:))';
    tc.track(it).wind_from_direction=squeeze(wnddir(it,:,:))';
    tc.track(it).pressure_drop=squeeze(pdrop(it,:,:))';
end
