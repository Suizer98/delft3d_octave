function pos = kngr_getPosition(lowerLeft, partofscreen_Hor, partofscreen_Vrt,scnsize,bdwidth,topbdwidth)
if nargin == 3
    set(0,'Units','pixels')
    scnsize = get(0,'ScreenSize');
    bdwidth = 4;
    topbdwidth = 48;
elseif nargin == 4
    bdwidth = 4;
    topbdwidth = 48;
elseif nargin ==5
    topbdwidth = 48;
end

pos  = [bdwidth,... 
    lowerLeft*scnsize(4) + bdwidth,...
    scnsize(3)/(1/partofscreen_Hor) - 2*bdwidth,...
    scnsize(4)/(1/partofscreen_Vrt) - (topbdwidth + bdwidth)];