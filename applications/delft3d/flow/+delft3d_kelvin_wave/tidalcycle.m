function tidalcycle(x,y, F, C, T, ETA0, VEL0);
%delft3d_kelvin_wave.TIDALCYCLE  quick-n-dirty visual assessment of delft3d_kelvin_wave_* 
%
%See also: delft3d_kelvin_wave

OPT.writetoavi = 0;        % 1 = movie, 0 = no movie
OPT.velscale   = 20000;
OPT.plottype   = 'figure'; % 'subplot'
OPT.plotabs    = 1;
OPT.export     = 0;
OPT.pause      = 1;

OPT.xlim = [-50e3 0 ];
OPT.ylim = [0 100e3 ];
OPT.zlim = [-2 2];
OPT.zscale = 2e-5;

if strcmp(OPT.plottype,'figure')
   figETA = figure('name','ETA');
   figVEL = figure('name','VEL');
   figNEU = figure('name','NEU');
else
   figMOV = figure('name','MOVIE');
end

if OPT.writetoavi
mov             = avifile(  'neumann'    ,...
                            'Quality'    ,100      ,...
                            'compression','Cinepak',...
                            'fps'        ,2        )
end;

polygon.x = [OPT.xlim(1) OPT.xlim(2) OPT.xlim(2) OPT.xlim(1)];
polygon.y = [OPT.ylim(1) OPT.ylim(1) OPT.ylim(2) OPT.ylim(2)];
boolmask  = inpolygon(x,y,polygon.x,polygon.y);
mask      = ones(size(x));  
mask(~boolmask) = nan;

for time=T.t
  
    ETA.complex  = ETA0.complex* exp(1i*C.w.*time);
    VEL.complex  = ETA .complex.* (C.g*ETA0.k./(1i*C.w+ETA0.kappa));
    NEU.complex  = ETA .complex.* (-ETA0.k);
    
    if strcmp(OPT.plottype,'figure')
       set(0,'currentfigure',figETA);
    else
       subplot(3,1,1)
    end

       hold off;
       S(1) = surf        (x.*mask,y.*mask,real(ETA.complex).*mask);
       hold on;
       if OPT.plotabs
       M(1) = surf        (x.*mask,y.*mask, abs(ETA.complex).*mask);
       M(2) = surf        (x.*mask,y.*mask,-abs(ETA.complex).*mask);
       end
       %Q(:,1) = quiver3   (x.*mask,...
       %                    y.*mask,...
       %                    x.*0,...
       %                    OPT.velscale.*real(VEL.complex).*mask.*0,...
       %                    OPT.velscale.*real(VEL.complex).*mask   ,...
       %                    OPT.velscale.*real(VEL.complex).*mask.*0,0);
                       
       set         (gca,'xlim',[min(x(:)) max(x(:))]);
       set         (gca,'ylim',[min(y(:)) max(y(:))]);
       set         (gca,'zlim',[-1.0 1.0]);
       
       
       SURFPROP.EdgeAlpha = 1      ; %[ flat | interp ] -or- {an Alpha}.
       SURFPROP.EdgeColor = 'interp'; %[ none | flat | interp ] -or- {a ColorSpec}.
       SURFPROP.FaceAlpha = 1      ; %[ flat | interp | texturemap ] -or- {an Alpha}.
       SURFPROP.FaceColor = 'interp'; %[ none | {flat} | interp | texturemap ] -or- a ColorSpec.
       
       set(S(1),SURFPROP)
       
       daaspect = get(gca,'dataaspectratio');
       %daaspect(1) = daaspect(2);
       %daaspect(3) = OPT.zscale;
       %set         (gca,'dataaspectratio',daaspect);
       set         (gca,'dataaspectratio',[1 1 OPT.zscale]);
       shading     interp;
       xlabel      ('X');
       ylabel      ('Y');
       zlabel      ('Water level');
       title       (['Water level t=',num2str(time),' [s]']);
       set(gca,'xlim',OPT.xlim);
       set(gca,'ylim',OPT.ylim);
       
       set(gcf,'position',[0 50 500 650])
       
       
       if OPT.export
       exportfig(gcf,[num2str(time,'%0.6i'),''],'format','png',...
                'color' ,'cmyk',...
                'width' ,2,...
                'height',3)
       end

    if strcmp(OPT.plottype,'figure')
       set(0,'currentfigure',figVEL);
    else
       subplot(3,1,2)
    end
    
       hold off;
       S(1) = surf        (x.*mask,y.*mask,real(VEL.complex).*mask);
       hold on;
       if OPT.plotabs
       M(1) = mesh        (x.*mask,y.*mask, abs(VEL.complex).*mask);
       M(2) = mesh        (x.*mask,y.*mask,-abs(VEL.complex).*mask);
       end
       Q(:,1) = quiver3   (x.*mask,...
                           y.*mask,...
                           x.*0,...
                           OPT.velscale.*real(VEL.complex).*mask.*0,...
                           OPT.velscale.*real(VEL.complex).*mask   ,...
                           OPT.velscale.*real(VEL.complex).*mask.*0,0);
                       
       set         (gca,'xlim',[min(x(:)) max(x(:))]);
       set         (gca,'ylim',[min(y(:)) max(y(:))]);	
       set         (gca,'zlim',[-1 1]);
       
       daaspect = get(gca,'dataaspectratio');
       %daaspect(1) = daaspect(2);
       %daaspect(3) = OPT.zscale;
       %set         (gca,'dataaspectratio',daaspect);
       set         (gca,'dataaspectratio',[1 1 OPT.zscale]);
       shading     interp;
       xlabel      ('X');
       ylabel      ('Y');
       zlabel      ('Velocity');
       title       (['Velocity t=',num2str(time),' [s]']);
       set(gca,'xlim',OPT.xlim);
       set(gca,'ylim',OPT.ylim);
    
       set(gcf,'position',[500 50 500 650])

    if strcmp(OPT.plottype,'figure')
       set(0,'currentfigure',figNEU);
    else
       subplot(3,1,3)
    end
    
       hold off;
       S(1) = surf        (x.*mask,y.*mask,real(NEU.complex).*mask);
       hold on;
       if OPT.plotabs
       M(1) = mesh        (x.*mask,y.*mask, abs(NEU.complex).*mask);
       M(2) = mesh        (x.*mask,y.*mask,-abs(NEU.complex).*mask);
       end
       Q(:,1) = quiver3   (x.*mask,...
                           y.*mask,...
                           x.*0,...
                           OPT.velscale.*real(VEL.complex).*mask.*0,...
                           OPT.velscale.*real(VEL.complex).*mask   ,...
                           OPT.velscale.*real(VEL.complex).*mask.*0,0);
                       
       set         (gca,'xlim',[min(x(:)) max(x(:))]);
       set         (gca,'ylim',[min(y(:)) max(y(:))]);
       set         (gca,'zlim',[-1 1].*1e-5);
       
       set         (gca,'dataaspectratio',[1 1 .2e-9]);
       shading     interp;
       xlabel      ('X');
       ylabel      ('Y');
       zlabel      ('Neumann');
       title       (['Neumann t=',num2str(time),' [s]']);
       set(gca,'xlim',OPT.xlim);
       set(gca,'ylim',OPT.ylim);
    
       set(gcf,'position',[1000 50 500 650])

  if OPT.writetoavi
     F          = getframe(figfilmpje);
     mov        = addframe(mov,F);
  end;
  
  disp          ([num2str(time),' [h]']);

  if OPT.pause
     pausedisp
  end
  
end;

if OPT.writetoavi
   mov = close(mov);
end;
