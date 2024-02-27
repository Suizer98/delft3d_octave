function AnimationSettings=ReadAnimationSettings(fname)

AnimationSettings.FrameRate=5;
AnimationSettings.FirstStep=1;
AnimationSettings.Increment=1;
AnimationSettings.LastStep=1;
AnimationSettings.KeepFigures=0;
AnimationSettings.makeKMZ=0;
AnimationSettings.FileName='anim.avi';
AnimationSettings.Prefix='anim';
AnimationSettings.NBits=24;

AnimationSettings.fccHandler=1684633187;
AnimationSettings.KeyFrames=0;
AnimationSettings.Quality=10000;
AnimationSettings.BytesPerSec=300;
AnimationSettings.Parameters=[99 111 108 114];

txt=ReadTextFile(fname);

for i=1:length(txt)
    
    switch lower(txt{i}),

        case {'filename'},
            AnimationSettings.FileName=txt{i+1};

        case {'keepfigures'},
            if strcmpi(txt{i+1},'yes')
                AnimationSettings.KeepFigures=1;
            else
                AnimationSettings.KeepFigures=1;
            end
            
        case {'makekmz'},
            if strcmpi(txt{i+1},'yes')
                AnimationSettings.makeKMZ=1;
            else
                AnimationSettings.makeKMZ=1;
            end
            
        case {'figureprefix'},
            AnimationSettings.Prefix=txt{i+1};
            
        case {'firststep'},
            AnimationSettings.FirstStep=str2num(txt{i+1});

        case {'laststep'},
            AnimationSettings.LastStep=str2num(txt{i+1});

        case {'nbits'},
            AnimationSettings.NBits=str2num(txt{i+1});
            
        case {'increment'},
            AnimationSettings.Increment=str2num(txt{i+1});

        case {'framerate'},
            AnimationSettings.FrameRate=str2num(txt{i+1});
            
        case {'fcchandler'},
            AnimationSettings.fccHandler=str2num(txt{i+1});
            
        case {'keyframes'},
            AnimationSettings.KeyFrames=str2num(txt{i+1});
            
        case {'quality'},
            AnimationSettings.Quality=str2num(txt{i+1});
            
        case {'bytespersec'},
            AnimationSettings.BytesPerSec=str2num(txt{i+1});
            
        case {'parameter'},
            ii=0;
            for k=i+1:length(txt)
                ii=ii+1;
                AnimationSettings.Parameter(ii)=str2num(txt{k});
            end            
    end

end

