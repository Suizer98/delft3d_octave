function PutInCentre(f)

%PUTINCENTRE Put box in centre

set(f,'Units','pixels');

ScreenSize=get(0,'ScreenSize');
PosOri=get(f,'Position');

ScreenPixelsPerInch=get(0,'ScreenPixelsPerInch');

if ScreenPixelsPerInch~=96
    hh=get(f,'Children');
    ii=findobj(f,'FontSize',8);
    set(ii,'FontSize',round(8*(96/ScreenPixelsPerInch)));
end

if ScreenPixelsPerInch~=96
    hh=get(f,'Children');
    ii=findall(f,'FontSize',10);
    set(ii,'FontSize',round(10*(96/ScreenPixelsPerInch)));
end

Pos(1)=ScreenSize(3)/2-PosOri(3)/2;
Pos(2)=ScreenSize(4)/2-PosOri(4)/2;
Pos(3)=PosOri(3);
Pos(4)=PosOri(4);

set(f,'Position',Pos);
