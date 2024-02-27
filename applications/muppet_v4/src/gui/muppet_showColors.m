function muppet_showColors(varargin)

if isempty(varargin)
    
    % New window
    handles=getHandles;
    
    s.colornames=colorlist('getlist');
    s.colornumber=1;
    rgb=colorlist('getrgb','color',s.colornames{1});
    s.r=round(rgb(1)*255);
    s.g=round(rgb(2)*255);
    s.b=round(rgb(3)*255);
    
    [s,ok]=gui_newWindow(s,'xmldir',handles.xmlguidir,'xmlfile','showcolors.xml', ...
                         'createcallback',@muppet_showColors,'createinput','selectcolor', ...
                         'iconfile',[handles.settingsdir 'icons' filesep 'deltares.gif']);
        
else
    
    for ii=1:length(varargin)
        if ischar(varargin{ii})
            switch lower(varargin{ii})
                case{'selectcolor'}
                    s=gui_getUserData;
                    name=s.colornames{s.colornumber};
                    rgb=colorlist('getrgb','color',name);
                    h=findobj('Tag','coloredpushbutton');
                    set(h,'BackgroundColor',rgb);
                    s.r=round(rgb(1)*255);
                    s.g=round(rgb(2)*255);
                    s.b=round(rgb(3)*255);
                    gui_setUserData(s);
            end
        end
    end
end
