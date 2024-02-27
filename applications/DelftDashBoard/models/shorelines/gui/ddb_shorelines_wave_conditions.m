function ddb_shorelines_wave_conditions(varargin)

%%
ddb_zoomOff;

if isempty(varargin)
    % New tab selected
    ddb_refreshScreen;
    % Make shoreline visible
    ddb_plotshorelines('update','active',1,'visible',1);
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch lower(opt)
        case{'selectwaveoption'}
            select_wave_option;
        case{'selectwavetransoption'}
            select_wavetrans_option;
        case{'loadwaveclimfile'}
            load_waveclimfile;
        case{'loadwvcfile'}
            load_wvcfile;
        case('loadwavefile')
            load_wavefile;
    end
    
end

%%
function select_wave_option

handles=getHandles;
opt=handles.model.shorelines.wave_opt;
switch lower(opt)
    case{'mean_and_spreading'}
        handles.model.shorelines.domain.Waveclimfile='';
        handles.model.shorelines.domain.WVCfile='';
    case('wave_climate')
        handles.model.shorelines.domain.WVCfile='';
    case('wave_time_series')
        handles.model.shorelines.domain.Waveclimfile='';
end
    %ddb_giveWarning('text',['Thank you for selecting wave option ' opt]);
setHandles(handles);

%%
function select_wavetrans_option

handles=getHandles;
opt=handles.model.shorelines.wavetrans_opt;
%ddb_giveWarning('text',['Thank you for selecting wave option ' opt]);
setHandles(handles);

%%
function load_waveclimfile

handles=getHandles;
[HTDp]=load(handles.model.shorelines.domain.Waveclimfile);
Hs=HTDp(:,1);
Tp=HTDp(:,2);
phiw0=HTDp(:,3);
perc=HTDp(:,4);
handles.model.shorelines.wave_conditions.Hsclim=Hs;
handles.model.shorelines.wave_conditions.Tpclim=Tp;
handles.model.shorelines.wave_conditions.phiw0clim=phiw0;
handles.model.shorelines.wave_conditions.perc=perc;
%% Make plot to check wave climate is ok
pcum=cumsum(perc);
figure;
subplot(311);plot(phiw0,Hs,'.');ylabel('Hs (m)');
subplot(312);plot(phiw0,Tp,'.');ylabel('Tp (s)');
subplot(313);plot(phiw0,perc,'.');xlabel('dir(deg. N)');ylabel('percentage')


setHandles(handles);

%%
function load_wvcfile

handles=getHandles;
[tHTD]=load(handles.model.shorelines.domain.WVCfile);
try
    time=datenum(num2str(tHTD(:,1)),'yyyymmddhhMM');
catch
    time=datenum(num2str(tHTD(:,1)),'yyyymmdd');
end
handles.model.shorelines.time_ts=time;
Hs=tHTD(:,2);
Tp=tHTD(:,3);
phiw0=tHTD(:,4);
handles.model.shorelines.wave_conditions.Hs_ts=Hs;
handles.model.shorelines.wave_conditions.Tp_ts=Tp;
handles.model.shorelines.wave_conditions.phiw0_ts=phiw0;
%% Make plot to check wave time series is ok
figure;
subplot(311);plot(time,Hs);datetick;ylabel('Hs (m)')
subplot(312);plot(time,Tp);datetick;ylabel('Tp (s)')
subplot(313);plot(time,phiw0);datetick;ylabel('dir(deg. N)')

setHandles(handles);

%%
function load_wavefile

handles=getHandles;
wave_table=load(handles.model.shorelines.domain.wavefile);
handles.model.shorelines.domain.wave_table=wave_table;
%% Make plot to check wave table is ok?
wave_table.zb(wave_table.zb==-999)=nan;
figure;
scatter(wave_table.xg,wave_table.yg,20,wave_table.zb);
shading flat;
colorbar;
axis equal;
setHandles(handles);

