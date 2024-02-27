%QUIVERBUG   Test script to show how to plot a correct quiver legend with v6 option.
%
%See also: quiver

scale       = 1;
xleg        = 0;
yleg        = -.5;
uleg        = 1;

[x,y]       = meshgrid(0:1:10,0:1:10);
u           = 1.*rand(size(x));
v           = 1.*rand(size(x));

subplot(2,2,1)
H.q = quiver('v6',x,y,scale.*u,scale.*v,0);
hold on
H.q = quiver('v6',x,y,scale.*v,scale.*u,0);
H.q = quiver('v6',[xleg],[yleg],[uleg.*scale],[0.*scale],0);
title({[version,': quiver({\color[rgb]{1 0 0}''v6''},...). '],'correct head of the legend','Used deprecated ''v6'' option.'})
axis  equal
axis ([-1 11 -1 11])
axis off

subplot(2,2,2)
H.q(1) = quiver(x,y,scale.*u,scale.*v,0);
hold on
H.q(2) = quiver(x,y,scale.*v,scale.*u,0);
H.q(3) = quiver([xleg],[yleg],[uleg.*scale],[0.*scale],0);
title({[version,': quiver(...). '],'{\color[rgb]{1 0 0}ERRONOUS} head of the legend arrow','Not used ''v6'' option.'})
axis  equal
axis ([-1 11 -1 11])
axis off

subplot(2,2,4)
H.q(1) = quiver(x,y,scale.*u,scale.*v,0);
hold on
H.q(2) = quiver(x,y,scale.*v,scale.*u,0);
H.q(3) = quiver([xleg],[yleg],[uleg.*scale],[0.*scale],0, 'MaxHeadSize', 1);
title({[version,': quiver(...). '],'{\color[rgb]{0 1 0}CORRECTED} head of the legend arrow','specified with MaxHeadSize','Not used ''v6'' option.'})
axis  equal
axis ([-1 11 -1 11])
axis off

for i=[1 2 4]
   subplot(2,2,i)
   text (xleg + uleg,...
         yleg,[' ',num2str(uleg),' [m/s]'],'horizontalalignment','left')

end

fname = [mfilename('fullpath'),'_',version('-release')];
print(gcf,fname,'-dpng');
