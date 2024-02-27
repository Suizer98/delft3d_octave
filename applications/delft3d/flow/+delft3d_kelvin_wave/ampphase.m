function ampphase(x,y, ETA0, VEL0);
%DELFT3D_KELVIN_WAVE.AMPPHASE  .
%
%See also: delft3d_kelvin_wave

[amp.c amp.h] = contour(x,y,ETA0.abs,'b');
[amp.t      ] = clabel (amp.c,amp.h);

hold on

[pha.c pha.h] = contour(x,y,-rad2deg(ETA0.arg),'k');
[pha.t      ] = clabel (pha.c,pha.h);

axis equal
