function cosmos_imagePlot(fname,data,varargin)

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'xlim'}
                xlim=varargin{i+1};
            case{'ylim'}
                ylim=varargin{i+1};
        end
    end
end

szx=8;
szy=szx*(ylim(2)-ylim(1))/(xlim(2)-xlim(1));

pps=[szx szy];

h=figure('Visible','off');

set(h,'Units','centimeters');
set(h,'Position',[0 0 pps]);
set(h,'PaperUnits','centimeters');
set(h,'PaperSize',pps);
set(h,'PaperPosition',[0 0 pps]);
set(h,'PaperPositionMode','manual');

ax=axes;
set(ax,'Units','centimeters');

% Assuming x and y are on cell corners and z is in cell centres!
image(data.x,data.y,data.c);

% Random purplish color
bgc=[0.8 0.1 0.8];

set(ax,'XLim',xlim,'YLim',ylim);
set(ax,'Box','off');
set(ax,'XTick',[],'YTick',[]);
set(ax,'Position',[-0.00 -0.00 szx+0.00 szy+0.00]);
set(h,'Color',bgc);
set(ax,'Color',bgc);
set(h,'InvertHardCopy', 'off');

print('-dpng','-r200','-painters',fname);
uniquebgcolor=[204 25 204]; % <- select a color that does not exist in your image!!!
im = imread(fname,'BackgroundColor',bgc);
mask = bsxfun(@eq,im,reshape(uniquebgcolor,1,1,3));
imwrite(im,fname,'png','Alpha',1-double(all(mask,3)));

close(h);

