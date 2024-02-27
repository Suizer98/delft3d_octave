function h=muppet_readAnimationSettings(fname)

h.framerate=20;
h.quality=75;
h.starttime=1;
h.timestep=1;
h.stoptime=1;
h.keepfigures=0;
h.makekmz=0;
h.avifilename='anim.avi';
h.prefix='anim';
h.selectbits=24;
h.format='avi';

h.avioptions.fccHandler=1684633187;
h.avioptions.KeyFrames=0;
h.avioptions.Quality=10000;
h.avioptions.BytesPerSec=300;
h.avioptions.Parameters=[99 111 108 114];

txt=ReadTextFile(fname);

for i=1:length(txt)
    
    switch lower(txt{i})

        case {'filename'}
            h.avifilename=txt{i+1};

        case {'keepfigures'}
            if strcmpi(txt{i+1}(1),'y')
                h.keepfigures=1;
            else
                h.keepfigures=0;
            end
            
        case {'makekmz'}
            if strcmpi(txt{i+1}(1),'y')
                h.makekmz=1;
            else
                h.makekmz=0;
            end

        case {'flightpath'}
            if strcmpi(txt{i+1}(1),'y')
                h.flightpath=1;
            else
                h.flightpath=0;
            end

        case {'flightpathxml'}
            h.flightpathxml=txt{i+1};
            
        case {'figureprefix'}
            h.prefix=txt{i+1};
            
        case {'starttime'}
            h.starttime=datenum([txt{i+1} ' ' txt{i+2}],'yyyymmdd HHMMSS');

        case {'stoptime'}
            h.stoptime=datenum([txt{i+1} ' ' txt{i+2}],'yyyymmdd HHMMSS');

        case {'nbits'}
            h.selectbits=str2num(txt{i+1});
            
        case {'timestep'}
            h.timestep=str2num(txt{i+1});

        case {'framerate'}
            h.framerate=str2num(txt{i+1});
            
        case {'quality'}
            h.quality=str2num(txt{i+1});

        case {'format'}
            h.format=txt{i+1};

        case {'fcchandler'}
            h.avioptions.fccHandler=str2num(txt{i+1});
            
        case {'keyframes'}
            h.avioptions.KeyFrames=str2num(txt{i+1});
            
%         case {'quality'}
%             h.avioptions.Quality=str2num(txt{i+1});
            
        case {'bytespersec'}
            h.avioptions.BytesPerSec=str2num(txt{i+1});
            
        case {'parameter'}
            ii=0;
            for k=i+1:length(txt)
                ii=ii+1;
                h.avioptions.Parameter(ii)=str2num(txt{k});
            end            
    end

end

