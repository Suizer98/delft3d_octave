function muppet4(varargin)

handles.muppetversion='4.05';

warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
warning('off','MATLAB:contours:DeprecatedErrorOutputArgument');

% Initialize
handles.currentpath=pwd;
handles=muppet_getDirectories(handles);

if isempty(varargin)
    % Splash screen
    handles.splashscreen = SplashScreen( 'Splashscreen',[handles.settingsdir 'icons' filesep 'muppets.jpg']);
    handles.splashscreen.addText( 10, 30, 'Muppet', 'FontSize', 30, 'Color', [0 0 0.6] ); 
    handles.splashscreen.addText( 10, 55, ['v ' handles.muppetversion], 'FontSize', 20, 'Color',[1 1 1]);
end

handles=muppet_initialize(handles);

setHandles(handles);

if ~isempty(varargin)
    mupfile=varargin{1};
    curdir=pwd;
    pth=fileparts(mupfile);
    if ~isempty(pth)
        cd(pth);
    end
    [handles,ok]=muppet_newSession(handles,mupfile);
    for isub=1:length(handles.figures(1).figure.subplots)
        handles.figures(1).figure.subplots(isub).subplot=muppet_updateLimits(handles.figures(1).figure.subplots(isub).subplot,'computescale');
    end
    
    if nargin==1
        muppet_exportFigure(handles,1,'export');
    else
        handles.animationsettings=muppet_readAnimationSettings(varargin{2});
        muppet_makeAnimation(handles,1);
    end
    
    cd(curdir);
else
   muppet_initializegui;
   muppet_gui;
end
