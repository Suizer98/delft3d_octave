function remove_figure_frame(varargin)
% Remove the frame around a figure, usefull for e.g. splash screens...
%
% Uses undocumented Matlab functionality (Java code) and is therefore
% always called within a "try --> catch --> end" statement. If nothing
% happens to your figure, your Matlab version is (no longer) supported.
%
% Syntax:
%      remove_figure_frame(figure_handle);     % Frameless exisiting figure
%      remove_figure_frame;                    % New figure without a frame
%
%

if isempty(varargin)
    hFig = gcf;
else
    hFig = varargin{1};
end

set(hFig,'menubar','none');
drawnow;

if isempty(hFig)
    error('Cannot retrieve the figure handle');
end

% Check for the desktop handle
if isequal(hFig,0)
    %jframe = com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame; return;
    error('Only figure windows can be undecorated, not the Matlab desktop');
end

% Check whether the figure is invisible
if strcmpi(get(hFig,'Visible'),'off')
    error('Cannot undecorate a non-visible figure');
end

% Check whether the figure is docked
if strcmpi(get(hFig,'WindowStyle'),'docked')
    error('Cannot undecorate a docked figure');
end

% Retrieve the figure window (JFrame) handle
jWindow = [];
maxTries = 10;
oldWarn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
while maxTries > 0
    try
        % Get the figure's underlying Java frame
        jf = get(handle(hFig),'JavaFrame');

        % Get the Java frame's root frame handle
        %jframe = jf.getFigurePanelContainer.getComponent(0).getRootPane.getParent;
        try  % Old releases
            jWindow = jf.fFigureClient.getWindow;  % equivalent to above...
        catch
            try  % HG2
                jWindow = jf.fHG2Client.getWindow;  % equivalent to above...
            catch  % HG1
                jWindow = jf.fHG1Client.getWindow;  % equivalent to above...
            end
        end
        if ~isempty(jWindow)
            break;
        else
            maxTries = maxTries - 1;
            drawnow; pause(0.1);
        end
    catch
        maxTries = maxTries - 1;
        drawnow; pause(0.1);
    end
end
warning(oldWarn);
if isempty(jWindow)
    error('Cannot retrieve the figure''s underlying Java Frame');
end

try

setappdata(hFig,'undecorate_jWindow',jWindow);

% Get the content pane's handle
mjc = jWindow.getContentPane;  %=getRootPane;
mjr = jWindow.getRootPane;

% Create a new pure-Java undecorated JFrame
figTitle = jWindow.getTitle;
jFrame_ = javaObjectEDT(javax.swing.JFrame(figTitle));
jFrame_.setUndecorated(true);

% Move the JFrame's on-screen location just on top of the original
jFrame_.setLocation(mjc.getLocationOnScreen);

% Set the JFrame's size to the Matlab figure's content size
%jFrame_.setSize(mjc.getSize);  % slightly incorrect (content-pane's offset)
jFrame_.setSize(mjc.getWidth+mjr.getX, mjc.getHeight+mjr.getY);
setappdata(hFig,'undecorate_contentJPanel',mjc);

% Reparent (move) the contents from the Matlab JFrame to the new undecorated JFrame
jFrame_.setContentPane(mjc);

% Hide the taskbar component (Java 7 i.e. R2013b or newer only)
try jFrame_.setType(javaMethod('valueOf','java.awt.Window$Type','UTILITY')); catch, end

% Make the new JFrame visible
jFrame_.setVisible(true);

% Hide the Matlab figure by moving it off-screen
pos = get(hFig,'Position');
setappdata(hFig,'undecorate_originalPos',pos);
set(hFig,'Position',pos-[9000,9000,0,0]);
drawnow;

% Enlarge the content pane to fill the jFrame
mjc.setSize(jFrame_.getSize);

% Set the focus callback to enable focusing by clicking in the taskbar
hjWindow = handle(jWindow, 'CallbackProperties');
set(hjWindow, 'FocusGainedCallback', @(h,e)jFrame_.requestFocus);

% Dispose the JFrame when the Matlab figure closes
set(hjWindow, 'WindowClosedCallback', @(h,e)jFrame_.dispose);

% Store the JFrame reference for possible later use by redecorateFig
setappdata(hFig,'undecorate_jFrame',jFrame_);

catch
    disp('This function appears to no longer/not work for this Matlab version')
end

end % of the function