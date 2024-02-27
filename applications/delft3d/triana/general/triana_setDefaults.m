function s = triana_setDefaults(s)


k.model.epsg = 4326; % WGS84 is assumed
k.model.epsgTxT = strrep(strrep(strtok(epsg_wkt(s.model.epsg),','),'PROJCS["',''),'"','');
k.model.timeZone=0;
% s.ana.timeStart = datenum(timeStart,'yyyymmdd')
% s.ana.timeEnd = datenum(timeEnd,'yyyymmdd')
k.ana.fourier = 1; % 1: fourier analysis on residual is performed for each station, 0: fourier analysis is not performed on residual
k.plot.txtHorFraq = 110; %fraction of (s.plot.Xmax - s.plot.Xmin) used to horizontally locate the computed and observed amplitude and phase texts
k.plot.txtVerFraq = 110; %fraction of (s.plot.Ymax - s.plot.Ymin) used to vertically locate the computed and observed amplitude and phase texts
k.plot.FontSize = 3; %fraction of (s.plot.Ymax - s.plot.Ymin) used to vertically locate the computed and observed amplitude and phase texts
k.meas.useIHO = 1;
k.meas.file = which('iho.nc');
if strcmpi(k.meas.file,'')
    if exist('p:\delta\svn.oss.deltares.nl\openearthtools\matlab\applications\DelftDashBoard\toolboxes\TideStations\data\iho.nc','file')
        k.meas.file = 'p:\delta\svn.oss.deltares.nl\openearthtools\matlab\applications\DelftDashBoard\toolboxes\TideStations\data\iho.nc';
    elseif isfield(s.meas,'data')
        disp('Warning: cannot find the Dashboard IHO database, function will only use specified measurements in MEAS')
    else
        error('Cannot find the Dashboard IHO database, please check and include in s.meas.file')
    end
end
k.outputDir=pwd;
k.description = 'triana';

% set defaults
fields = fieldnames(k);
for ff = 1:length(fields)
    if ~isfield(s,fields{ff})
        s.(fields{ff}) = k.(fields{ff});
        if ~isstruct(k.(fields{ff}))
            if isnumeric(s.(fields{ff}));
                dummy = num2str(s.(fields{ff}));
            else
                dummy = s.(fields{ff});
            end
            disp(['Default set for s.',fields{ff},': ',dummy])
        else
            fields2 = fieldnames(k.(fields{ff}));
            for ff2 = 1:length(fields2)
                if isnumeric(s.(fields{ff}).(fields2{ff2}));
                    dummy = num2str(s.(fields{ff}).(fields2{ff2}));
                else
                    dummy = s.(fields{ff}).(fields2{ff2});
                end
                disp(['Default set for s.',fields{ff},'.',fields2{ff2},': ',dummy])
            end
        end
    elseif isstruct(k.(fields{ff}))
        fields2 = fieldnames(k.(fields{ff}));
        for ff2 = 1:length(fields2)
            if ~isfield(s.(fields{ff}),fields2{ff2})
                s.(fields{ff}).(fields2{ff2}) = k.(fields{ff}).(fields2{ff2});
                if isnumeric(s.(fields{ff}).(fields2{ff2}));
                    dummy = num2str(s.(fields{ff}).(fields2{ff2}));
                else
                    dummy = s.(fields{ff}).(fields2{ff2});
                end
                disp(['Default set for s.',fields{ff},'.',fields2{ff2},': ',dummy])
            end
        end
    end
end