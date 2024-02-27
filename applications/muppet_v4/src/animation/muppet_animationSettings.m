function muppet_animationSettings(varargin)

if isempty(varargin)
    
    % New window
    handles=getHandles;
    
    if handles.nrdatasets>0
        
        if isempty(handles.animationsettings.starttime)
            
            % Try to determine start and stop times
            tmin=1e9;
            tmax=-1e9;
            dt=1;
            for id=1:handles.nrdatasets
                if isfield(handles.datasets(id).dataset,'times')
                    if ~isempty(handles.datasets(id).dataset.times)
                        tmin=min(tmin,handles.datasets(id).dataset.times(1));
                        tmax=max(tmax,handles.datasets(id).dataset.times(end));
                        dt1=0;
                        if length(handles.datasets(id).dataset.times)>1
                            dt1=86400*(handles.datasets(id).dataset.times(2)-handles.datasets(id).dataset.times(1));
                        end
                        dt=max(dt1,dt);
                    end
                end
            end
            if tmin<1e8 && tmax>-1e8
                handles.animationsettings.starttime=tmin;
                handles.animationsettings.stoptime=tmax;
                handles.animationsettings.timestep=dt;
            else
                handles.animationsettings.starttime=datenum(2000,1,1);
                handles.animationsettings.stoptime=datenum(2000,2,1);
                handles.animationsettings.timestep=3600;
            end
        end
        
        [handles.animationsettings,ok]=gui_newWindow(handles.animationsettings,'xmldir',handles.xmlguidir, ...
            'xmlfile','animationsettings.xml','iconfile',[handles.settingsdir 'icons' filesep 'deltares.gif']);

        % Check if avi settings have been set
        if strcmpi(handles.animationsettings.format,'avi')
            if isempty(handles.animationsettings.avioptions)
%                 aviops=avi('options');
%                 handles.animationsettings.avioptions=aviops;
            end
        end
        
        handles.animationsettings.set=1;
        
        setHandles(handles);
        
    end
    
else
    
    for ii=1:length(varargin)
        if ischar(varargin{ii})
            switch lower(varargin{ii})
                case{'avioptions'}
                    editAviOptions;
                case{'loadsettings'}
                    loadSettings;
                case{'savesettings'}
                    saveSettings;
            end
        end
    end
end

%%
function editAviOptions
h=gui_getUserData;
aviops=avi('options');
h.avioptions=aviops;
gui_setUserData(h);

%%
function saveSettings

h=gui_getUserData;

% Check if avi settings have been set
if strcmpi(h.format,'avi')
    if isempty(h.avioptions)
        aviops=avi('options');
        h.avioptions=aviops;
        gui_setUserData(h);
    end
end

[filename pathname]=uiputfile('*.ani');

if pathname~=0
    fid = fopen([pathname filename],'w');
    datestring=datestr(datenum(clock),31);
    usrstring='- Unknown user';
    usr=getenv('username');
    if size(usr,1)>0
        usrstring=[' - File created by ' usr];
    end
    txt=['# Animation Settings' usrstring ' - ' datestring];
    fprintf(fid,'%s \n',txt);
    txt='';
    fprintf(fid,'%s \n',txt);
    txt=['FileName       ' h.avifilename];
    fprintf(fid,'%s \n',txt);
    txt=['StartTime      ' datestr(h.starttime,'yyyymmdd HHMMSS')];
    fprintf(fid,'%s \n',txt);
    txt=['StopTime       ' datestr(h.stoptime,'yyyymmdd HHMMSS')];
    fprintf(fid,'%s \n',txt);
    txt=['TimeStep       ' num2str(h.timestep)];
    fprintf(fid,'%s \n',txt);
    txt=['FrameRate      ' num2str(h.framerate)];
    fprintf(fid,'%s \n',txt);
    txt=['Quality        ' num2str(h.quality)];
    fprintf(fid,'%s \n',txt);
    txt=['Format         ' h.format];
    fprintf(fid,'%s \n',txt);
    %     txt=['NBits          ' num2str(h.selectbits)];
    %     fprintf(fid,'%s \n',txt);
    if h.keepfigures
        txt=['KeepFigures    yes'];
        fprintf(fid,'%s \n',txt);
        txt=['FigurePrefix   ' h.prefix];
        fprintf(fid,'%s \n',txt);
    else
        txt=['KeepFigures    no'];
        fprintf(fid,'%s \n',txt);
    end
    if h.makekmz
        txt=['MakeKMZ        yes'];
        fprintf(fid,'%s \n',txt);
    else
        txt=['MakeKMZ        no'];
        fprintf(fid,'%s \n',txt);
    end
    if h.flightpath
        txt=['FlightPath     yes'];
        fprintf(fid,'%s \n',txt);
        txt=['FlightPathXML  ' h.flightpathxml];
        fprintf(fid,'%s \n',txt);
    else
        txt=['FlightPath     no'];
        fprintf(fid,'%s \n',txt);
    end
    txt=[''];
    fprintf(fid,'%s \n',txt);
    txt=['# Do not change the following codec settings!'];
    fprintf(fid,'%s \n',txt);
    txt=[''];
    fprintf(fid,'%s \n',txt);
    txt=['fccHandler     ' num2str(h.avioptions.fccHandler)];
    fprintf(fid,'%s \n',txt);
    txt=['KeyFrames      ' num2str(h.avioptions.KeyFrames)];
    fprintf(fid,'%s \n',txt);
    txt=['Quality        ' num2str(h.avioptions.Quality)];
    fprintf(fid,'%s \n',txt);
    txt=['BytesPerSec    ' num2str(h.avioptions.BytesPerSec)];
    fprintf(fid,'%s \n',txt);
    txt=['Parameters     ' num2str(h.avioptions.Parameters)];
    fprintf(fid,'%s \n',txt);
    
    fclose(fid);
    
end

%%
function loadSettings
[filename pathname]=uigetfile('*.ani');
if pathname~=0
    h=muppet_readAnimationSettings([pathname filename]);
else
    return
end
gui_setUserData(h);
