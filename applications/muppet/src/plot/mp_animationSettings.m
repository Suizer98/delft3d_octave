function mp_animationsettings(varargin)

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

%%
function editAviOptions
h=gui_getUserData;
aviops=writeavi('getoptions', h.selectBits);
h.aviOptions=aviops;
gui_setUserData(h);

%%
function saveSettings

h=gui_getUserData;

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
    txt=['FileName       ' h.aviFileName];
    fprintf(fid,'%s \n',txt);
    txt=['StartTime      ' datestr(h.startTime,'yyyymmdd HHMMSS')];
    fprintf(fid,'%s \n',txt);
    txt=['StopTime       ' datestr(h.stopTime,'yyyymmdd HHMMSS')];
    fprintf(fid,'%s \n',txt);
    txt=['TimeStep       ' num2str(h.timeStep)];
    fprintf(fid,'%s \n',txt);
    txt=['FrameRate      ' num2str(h.frameRate)];
    fprintf(fid,'%s \n',txt);    
    txt=['NBits          ' num2str(h.selectBits)];
    fprintf(fid,'%s \n',txt);
    if h.keepFigures
        txt=['KeepFigures    yes'];
        fprintf(fid,'%s \n',txt);
        txt=['FigurePrefix   ' h.prefix];
        fprintf(fid,'%s \n',txt);
    else
        txt=['KeepFigures    no'];
        fprintf(fid,'%s \n',txt);
    end
    if h.makeKMZ
        txt=['MakeKMZ        yes'];
        fprintf(fid,'%s \n',txt);
    else
        txt=['MakeKMZ        no'];
        fprintf(fid,'%s \n',txt);
    end        
    txt=[''];
    fprintf(fid,'%s \n',txt);
    txt=['# Do not change the following codec settings!'];
    fprintf(fid,'%s \n',txt);
    txt=[''];
    fprintf(fid,'%s \n',txt);
    txt=['fccHandler     ' num2str(h.aviOptions.fccHandler)];
    fprintf(fid,'%s \n',txt);
    txt=['KeyFrames      ' num2str(h.aviOptions.KeyFrames)];
    fprintf(fid,'%s \n',txt);
    txt=['Quality        ' num2str(h.aviOptions.KeyFrames)];
    fprintf(fid,'%s \n',txt);
    txt=['BytesPerSec    ' num2str(h.aviOptions.BytesPerSec)];
    fprintf(fid,'%s \n',txt);
    txt=['Parameters     ' num2str(h.aviOptions.Parameters)];
    fprintf(fid,'%s \n',txt);
    
    fclose(fid);

end

%%
function loadSettings
[filename pathname]=uigetfile('*.ani');
if pathname~=0
    h=mp_readAnimationSettings([pathname filename]);
else
    return
end
gui_setUserData(h);
elements=getappdata(gcf,'elements');
gui_setElements(elements);
