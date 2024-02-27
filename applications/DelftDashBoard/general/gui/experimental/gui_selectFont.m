function font=gui_selectFont(varargin)

global figureiconfile

iconfile=[];

if ~isempty(figureiconfile)
    iconfile=figureiconfile;
end

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'selectfont'}
                font=gui_getUserData;
                h=findobj(gcf,'tag','sampletext');
                set(h,'FontName',font.name);
                set(h,'FontSize',font.size);
                set(h,'FontWeight',font.weight);
                set(h,'FontAngle',font.angle);
                clr=colorlist('getrgb','color',font.color);
                set(h,'ForegroundColor',clr);
                return
            case{'iconfile'}
                iconfile=varargin{ii+1};
        end
    end
end

% Default values
font.name                = 'Arial';
font.size                = 10;
font.angle               = 'normal'; % Normal of italic
font.weight              = 'normal'; % Normal of bold
font.color               = 'black';
font.horizontalalignment = 'left';
font.verticalalignment   = 'top';
horizontalalignment=1;
verticalalignment=1;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'font'}
                font=varargin{ii+1};
            case{'horizontalalignment'}
                horizontalalignment=varargin{ii+1};
            case{'verticalalignment'}
                verticalalignment=varargin{ii+1};
        end
    end
end

font0=font;

fonts=listfonts;

%% Define elements

% Font
n=1;
xml.element(n).element.style='listbox';
xml.element(n).element.position='20 305 260 175';
xml.element(n).element.variable='name';
xml.element(n).element.type='string';
xml.element(n).element.text='Font';
xml.element(n).element.textposition='above-center';
for ii=1:length(fonts)
    xml.element(n).element.listtext(ii).listtext=fonts{ii};
end
xml.element(n).element.callback='gui_selectFont';
xml.element(n).element.option1='selectfont';

n=n+1;
xml.element(n).element.style='panel';
xml.element(n).element.position='20 155 260 140';
xml.element(n).element.text='Sample';

n=n+1;
xml.element(n).element.style='text';
xml.element(n).element.position='30 165 240 110';
xml.element(n).element.text='The quick brown fox jumped over the lazy dog 1234567890';
xml.element(n).element.verticalalignment='top';
xml.element(n).element.tag='sampletext';

% Size
n=n+1;
xml.element(n).element.style='popupmenu';
xml.element(n).element.position='50 125 60 20';
xml.element(n).element.variable='size';
xml.element(n).element.type='integer';
xml.element(n).element.text='Size';
xml.element(n).element.textposition='left';
for ii=1:30
    xml.element(n).element.listtext(ii).listtext=num2str(ii+3);
    xml.element(n).element.listvalue(ii).listvalue=num2str(ii+3);
end
xml.element(n).element.callback='gui_selectFont';
xml.element(n).element.option1='selectfont';

% Color
n=n+1;
xml.element(n).element.style='selectcolor';
xml.element(n).element.position='160 125 100 20';
xml.element(n).element.variable='color';
xml.element(n).element.text='Color';
xml.element(n).element.textposition='left';
xml.element(n).element.callback='gui_selectFont';
xml.element(n).element.option1='selectfont';

% Weight
n=n+1;
xml.element(n).element.style='popupmenu';
xml.element(n).element.position='50 100 60 20';
xml.element(n).element.variable='weight';
xml.element(n).element.text='Weight';
xml.element(n).element.textposition='left';
xml.element(n).element.type='string';
xml.element(n).element.listtext(1).listtext='normal';
xml.element(n).element.listtext(2).listtext='bold';
xml.element(n).element.listtext(3).listtext='light';
xml.element(n).element.listtext(4).listtext='demi';
xml.element(n).element.callback='gui_selectFont';
xml.element(n).element.option1='selectfont';

% Angle
n=n+1;
xml.element(n).element.style='popupmenu';
xml.element(n).element.position='160 100 100 20';
xml.element(n).element.variable='angle';
xml.element(n).element.text='Angle';
xml.element(n).element.textposition='left';
xml.element(n).element.type='string';
xml.element(n).element.listtext(1).listtext='normal';
xml.element(n).element.listtext(2).listtext='italic';
xml.element(n).element.listtext(3).listtext='oblique';
xml.element(n).element.callback='gui_selectFont';
xml.element(n).element.option1='selectfont';

if horizontalalignment
    n=n+1;
    xml.element(n).element.style='popupmenu';
    xml.element(n).element.position='50 50 100 20';
    xml.element(n).element.variable='horizontalalignment';
    xml.element(n).element.text='Horizontal Alignment';
    xml.element(n).element.textposition='above-left';
    xml.element(n).element.type='string';
    xml.element(n).element.listtext(1).listtext='center';
    xml.element(n).element.listtext(2).listtext='left';
    xml.element(n).element.listtext(3).listtext='right';
    xml.element(n).element.callback='gui_selectFont';
    xml.element(n).element.option1='selectfont';
end

if verticalalignment
    n=n+1;
    xml.element(n).element.style='popupmenu';
    xml.element(n).element.position='160 50 100 20';
    xml.element(n).element.variable='verticalalignment';
    xml.element(n).element.text='Vertical Alignment';
    xml.element(n).element.textposition='above-left';
    xml.element(n).element.type='string';
    xml.element(n).element.listtext(1).listtext='top';
    xml.element(n).element.listtext(2).listtext='cap';
    xml.element(n).element.listtext(3).listtext='middle';
    xml.element(n).element.listtext(4).listtext='baseline';
    xml.element(n).element.list.texts(5).text='bottom';
    xml.element(n).element.callback='gui_selectFont';
    xml.element(n).element.option1='selectfont';
end

% Cancel
n=n+1;
xml.element(n).element.style='pushcancel';
xml.element(n).element.position='170 20 50 20';

% OK
n=n+1;
xml.element(n).element.style='pushok';
xml.element(n).element.position='230 20 50 20';

xml=gui_fillXMLvalues(xml);

[font,ok]=gui_newWindow(font,'element',xml.element,'height',500,'width',300,'title','Select Font','modal',1, ...
    'createcallback',@gui_selectFont,'createinput','selectfont','iconfile',iconfile);

if ~ok
    font=font0;
end

