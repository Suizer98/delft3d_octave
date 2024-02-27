function ddb_dnami_drawpolygon()
%
% ------------------------------------------------------------------------------------
%
% Function:     .m
%%
% Copyright (c) WL|Delft Hydraulics 2004 - 2006 FOR INTERNAL USE ONLY
%
% ------------------------------------------------------------------------------------
%
% Syntax:       output = function(input)
%
% With:
%               variable description
%
% Output:       Output description
%
global Mw        lat_epi     lon_epi    fdtop      totflength  fwidth   disloc     foption
global iarea     filearea    xareaGeo   yareaGeo   overviewpic fltpatch mrkrpatch flinepatch
global nseg      faultX      faultY     faultTotL  xvrt        yvrt

% Set the current object to be the figure2
fig2 = (findobj('tag','Figure2'));
if (~isempty(fig2))
   figure(fig2);
   image(xareaGeo,yareaGeo,overviewpic)
   set(gca,'YDir','normal')
   set(gca,'XDir','normal')
else
   msgbox('Load Area first','error')
   return
end

%Draw polygon (from Argus IBM)
uo = []; vo = []; button = []; flinepatch = [];

[uo,vo,lfrt] = ginput(1);
button = lfrt;
hold on; flinepatch = plot(uo,vo,'+m','LineWidth',2);
icount = 1;

while lfrt == 1 & icount < 6
    [u,v,lfrt] = ginput(1);
    uo=[uo;u]; vo=[vo;v]; button=[button;lfrt];
%     try
%       impixelinfo()
%     end
    if (lfrt ~= 27)
       hp = plot(uo,vo,'r','LineWidth',3);
       flinepatch=[flinepatch;hp];
       icount = icount + 1;
    end
end

% Bail out at ESCAPE = ascii character 27
if lfrt == 27
    delete(flinepatch)
    if exist('bp')
        set(bp,'linestyle','-')
    end
    return
end

% when right mouse is clicked extra coordinate point is included
[icount, idum] = size(uo);
nseg = min(icount,6) - 2;
faultX(1:nseg+1) = uo(1:nseg+1);
faultY(1:nseg+1) = vo(1:nseg+1);

hold off

try
end

ddb_dnami_compFline();
ddb_dnami_setValues();
