function SetTextBox(FigureProperties,SubplotProperties)

txt=SubplotProperties.Text;

nr=SubplotProperties.NrTextLines;

switch lower(SubplotProperties.HorAl),
    case {'left'},
        x=0.2;
    case {'right'},
        x=SubplotProperties.Position(3);
    case {'center'},
        x=SubplotProperties.Position(3)/2;
end

dy=SubplotProperties.FontSize/20;

switch lower(SubplotProperties.VerAl),
    case {'top'},
        y1=SubplotProperties.Position(4)-dy;
    case {'bottom'},
        y1=0.2+(nr-1)*dy;
    case {'middle'},
        y1=SubplotProperties.Position(4)/2+(nr/2-0.5)*dy;       
    case {'baseline'},
        y1=SubplotProperties.Position(4)/2+(nr/2-0.5)*dy;       
end

for i=1:nr
    y=y1-(i-1)*dy;
    tx(i)=text(x,y,txt{i});
    set(tx(i),'HorizontalAlignment',SubplotProperties.HorAl);
    set(tx(i),'VerticalAlignment','baseline');
    set(tx(i),'FontName',SubplotProperties.Font);
    set(tx(i),'FontWeight',SubplotProperties.FontWeight);
    set(tx(i),'FontAngle',SubplotProperties.FontAngle);
    set(tx(i),'FontSize',SubplotProperties.FontSize);
    set(tx(i),'Color',SubplotProperties.FontColor);
    set(tx(i),'Clipping','off');
    hold on;
end

tick(gca,'x','none');
tick(gca,'y','none');

set(gca,'Xlim',[0 SubplotProperties.Position(3)]);
set(gca,'Ylim',[0 SubplotProperties.Position(4)]);

set(gca,'Units',FigureProperties.Units);
set(gca,'Position',SubplotProperties.Position*FigureProperties.cm2pix);

if SubplotProperties.DrawBox
    box on;
    axis on;
else
    box off;
    axis off;
end
