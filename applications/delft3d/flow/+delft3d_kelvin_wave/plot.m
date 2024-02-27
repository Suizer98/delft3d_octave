function S = plot(x,y, ETA0, VEL0,C);
%DELFT3D_KELVIN_WAVE.PLOT   quick-n-dirty visual assessment of delft3d_kelvin_wave_* 
%
%See also: delft3d_kelvin_wave

OPT.velscale   = 20000;
OPT.plottype   = 'figure'; % 'subplot'
OPT.plotabs    = 0;
OPT.argscaling = 180/pi;

OPT.xlim = [-50e3     0]; % [    0 75e3 ];
OPT.ylim = [    0 100e3]; % [    0 200e3];
OPT.zlim = [-2 2];
OPT.zscale = 2e-5;


polygon.x = [OPT.xlim(1) OPT.xlim(2) OPT.xlim(2) OPT.xlim(1)];
polygon.y = [OPT.ylim(1) OPT.ylim(1) OPT.ylim(2) OPT.ylim(2)];
boolmask  = inpolygon(x,y,polygon.x,polygon.y);
mask      = ones(size(x));  
mask(~boolmask) = nan;


    if strcmp(OPT.plottype,'figure')
       figure('name','figETA_abs');
    else
       subplot(3,3,1)
    end
    
       T.t = (0:2:12).*3600;
       for i = 1:length(T.t);
       S = my_plot(x.*mask,y.*mask,ETA0.abs.*mask,'|\eta|');
       hold on
       S3 = my_plot(x.*mask,y.*mask,-ETA0.abs.*mask,'|\eta|');
       S2 = my_plot(x.*mask,y.*mask,-real(ETA0.complex.*exp(1i*C.w.*T.t(i))).*mask,'|\eta|');
       title([num2str(T.t(i)./3600),' hr'])
       end

%%

    if strcmp(OPT.plottype,'figure')
       figure('name','figETA_arg');
    else
       subplot(3,3,2)
    end
    
       S = my_plot(x.*mask,y.*mask,ETA0.arg.*OPT.argscaling.*mask,'arg(\eta)',180/pi);
       set         (gca,'zlim',[-pi pi].*OPT.argscaling);
    
%%
    if strcmp(OPT.plottype,'figure')
       figure('name','figVEL_abs');
    else
       subplot(3,3,3)
    end
    
       S = my_plot(x.*mask,y.*mask,VEL0.abs.*mask,'|v|');

%%

    if strcmp(OPT.plottype,'figure')
       figure('name','figVEL_arg');

    else
       subplot(3,3,4)
    end
    
       S = my_plot(x.*mask,y.*mask,VEL0.arg.*OPT.argscaling.*mask,'arg(v)',180/pi) 
       set         (gca,'zlim',[-pi pi].*OPT.argscaling);

%% -------------------------------------------------

function S = my_plot(X,Y,Z,titlestring,varargin)


dataaspectratio_z = nan;
if nargin == 5
   dataaspectratio_z = varargin{1};
end   

       %hold off;
       S(1) = surf        (X,Y,Z);
       %hold on;
                       
       set         (gca,'xlim',[min(X(:)) max(X(:))]);
       set         (gca,'ylim',[min(Y(:)) max(Y(:))]);
       set         (gca,'zlim',[-1.5 1.5]);
       
       
       SURFPROP.EdgeAlpha = 1      ; %[ flat | interp ] -or- {an Alpha}.
       SURFPROP.EdgeColor = [0 0 0]; %[ none | flat | interp ] -or- {a ColorSpec}.
       SURFPROP.FaceAlpha = 1      ; %[ flat | interp | texturemap ] -or- {an Alpha}.
       SURFPROP.FaceColor = 'none' ; %[ none | {flat} | interp | texturemap ] -or- a ColorSpec.
       
       set(S(1),SURFPROP)
       
       daaspect = get(gca,'dataaspectratio');
       daaspect(1) = daaspect(2);
       if ~isnan(dataaspectratio_z)
          daaspect(3) = dataaspectratio_z;
       end
       set         (gca,'dataaspectratio',daaspect);
       shading     interp;
       xlabel      ('X');
       ylabel      ('Y');
       zlabel      (titlestring);
       title       (titlestring);
    

%% -------------------------------------------------
