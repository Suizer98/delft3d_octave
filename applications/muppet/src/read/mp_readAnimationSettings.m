function h=mp_readAnimationSettings(fname)

h.frameRate=5;
h.startTime=1;
h.timeStep=1;
h.stopTime=1;
h.keepFigures=0;
h.makeKMZ=0;
h.aviFileName='anim.avi';
h.prefix='anim';
h.selectBits=24;

h.aviOptions.fccHandler=1684633187;
h.aviOptions.KeyFrames=0;
h.aviOptions.Quality=10000;
h.aviOptions.BytesPerSec=300;
h.aviOptions.Parameters=[99 111 108 114];

txt=ReadTextFile(fname);

for i=1:length(txt)
    
    switch lower(txt{i}),

        case {'filename'},
            h.aviFileName=txt{i+1};

        case {'keepfigures'},
            if strcmpi(txt{i+1}(1),'y')
                h.keepFigures=1;
            else
                h.keepFigures=0;
            end
            
        case {'makekmz'},
            if strcmpi(txt{i+1}(1),'y')
                h.makeKMZ=1;
            else
                h.makeKMZ=0;
            end
            
        case {'figureprefix'},
            h.prefix=txt{i+1};
            
        case {'starttime'},
            h.startTime=datenum([txt{i+1} ' ' txt{i+2}],'yyyymmdd HHMMSS');

        case {'stoptime'},
            h.stopTime=datenum([txt{i+1} ' ' txt{i+2}],'yyyymmdd HHMMSS');

        case {'nbits'},
            h.selectBits=str2num(txt{i+1});
            
        case {'timestep'},
            h.timeStep=str2num(txt{i+1});

        case {'framerate'},
            h.frameRate=str2num(txt{i+1});
            
        case {'fcchandler'},
            h.aviOptions.fccHandler=str2num(txt{i+1});
            
        case {'keyframes'},
            h.aviOptions.KeyFrames=str2num(txt{i+1});
            
        case {'quality'},
            h.aviOptions.Quality=str2num(txt{i+1});
            
        case {'bytespersec'},
            h.aviOptions.BytesPerSec=str2num(txt{i+1});
            
        case {'parameter'},
            ii=0;
            for k=i+1:length(txt)
                ii=ii+1;
                h.aviOptions.Parameter(ii)=str2num(txt{k});
            end            
    end

end

