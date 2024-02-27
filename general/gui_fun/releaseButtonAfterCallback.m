function varargout = releaseButtonAfterCallback(hObject,eventdata,fHandle,varargin)
	% useful when assigning callbacks to top level menu items
    [varargout{1:nargout}] = fHandle(hObject,eventdata,varargin{:});
    import java.awt.Robot;
    import java.awt.event.*;
    mouse = Robot;

    mouse.mousePress(InputEvent.BUTTON3_MASK);
    mouse.mouseRelease(InputEvent.BUTTON3_MASK);
end