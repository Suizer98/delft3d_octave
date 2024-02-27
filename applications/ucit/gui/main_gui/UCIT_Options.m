function varargout = UCIT_Options(varargin)
%UCIT_OPTIONS   this routine opens an option windows allowing to change user settings
%
% This routine opens an option windows allowing to change user settings. Values are retrieved
% from and stored in mctoolbox.ini belonging to the user.
%              
% input:       
%    function has no input
%
% output:       
%    function has no output 
%
%   see also ucit 

% --------------------------------------------------------------------
% Copyright (C) 2004-2008 Delft University of Technology
% Version:  $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $ (Version 1.0, January 2006)
%     Mark van Koningsveld
%
%     m.vankoningsveld@tudelft.nl	
%
%     Hydraulic Engineering Section
%     Faculty of Civil Engineering and Geosciences
%     Stevinweg 1
%     2628CN Delft
%     The Netherlands
%
% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Lesser General Public
% License as published by the Free Software Foundation; either
% version 2.1 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
% USA
% -------------------------------------------------------------------- 

% $Id: UCIT_Options.m 4099 2011-02-24 12:57:05Z sonnevi $
% $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $
% $Author: sonnevi $
% $Revision: 4099 $

if nargin == 0  % LAUNCH GUI
    WorkDir = getINIValue('UCIT.ini','WorkDir');  
    if isempty(WorkDir)
        setINIValue('UCIT.ini','WorkDir','d:\');
    end 
    
    Versterking = getINIValue('UCIT.ini','Versterking');  
    if isempty(Versterking)
        setINIValue('UCIT.ini','Versterking','0');
    end 
    
    xVersterking = getINIValue('UCIT.ini','xVersterking');  
    if isempty(xVersterking)
        setINIValue('UCIT.ini','xVersterking','-71');
    end 

    Consolideren = getINIValue('UCIT.ini','Consolideren');  
    if isempty(Consolideren)
        setINIValue('UCIT.ini','Consolideren','0');
    end 
    
    xConsolidatie = getINIValue('UCIT.ini','xConsolidatie');  
    if isempty(xConsolidatie)
        setINIValue('UCIT.ini','xConsolidatie','30');
    end 

    xMarge = getINIValue('UCIT.ini','xMarge');  
    if isempty(xMarge)
        setINIValue('UCIT.ini','xMarge','300');
    end 

    VisualDune = getINIValue('UCIT.ini','VisualDune');  
    if isempty(VisualDune)
        setINIValue('UCIT.ini','VisualDune','0');
    end 
 
    FrameOutput = getINIValue('UCIT.ini','FrameOutput');  
    if isempty(FrameOutput)
        setINIValue('UCIT.ini','FrameOutput','1');
    end 
 
    Suppleren = getINIValue('UCIT.ini','Suppleren');  
    if isempty(Suppleren)
        setINIValue('UCIT.ini','Suppleren','0');
    end 
 
    Begin = getINIValue('UCIT.ini','Begin');  
    if isempty(Begin)
        setINIValue('UCIT.ini','Begin','200');
    end 
 
    Lengte = getINIValue('UCIT.ini','Lengte');  
    if isempty(Lengte)
        setINIValue('UCIT.ini','Lengte','200');
    end 
 
    Hoogte = getINIValue('UCIT.ini','Hoogte');  
    if isempty(Hoogte)
        setINIValue('UCIT.ini','Hoogte','1');
    end 

    DeterministicMode = getINIValue('UCIT.ini','DeterministicMode');  
    if isempty(DeterministicMode)
        setINIValue('UCIT.ini','DeterministicMode','0');
    end 

	fig = openfig(mfilename,'reuse');

	% Use system color scheme for figure:
    set(fig,'Units','Normalized','Position', [0.25 0.4 0.44 0.495]);
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

    set(findobj(fig,'tag','Edit_WorkDir'),'string',WorkDir)
    set(findobj(fig,'tag','Landwaarts_Checkbox'),'value',str2num(Versterking))
    set(findobj(fig,'tag','Landwaarts_Xc'),'string',xVersterking)
    set(findobj(fig,'tag','Zeewaarts_Checkbox'),'value',str2num(Consolideren))
    set(findobj(fig,'tag','Zeewaarts_Xc'),'string',xConsolidatie)
    set(findobj(fig,'tag','Zeewaarts_XMarge'),'string',xMarge)
    set(findobj(fig,'tag','Visual_Dune'),'value',str2num(VisualDune))
    set(findobj(fig,'tag','FrameOutput'),'value',str2num(FrameOutput))
    set(findobj(fig,'tag','Suppleren_Checkbox'),'value',str2num(Suppleren))
    set(findobj(fig,'tag','Zeewaarts_Begin'),'string',Begin)
    set(findobj(fig,'tag','Zeewaarts_Lengte'),'string',Lengte)
    set(findobj(fig,'tag','Zeewaarts_Hoogte'),'string',Hoogte)    
    set(findobj(fig,'tag','DeterministicMode'),'string',DeterministicMode)

    % Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

    uiwait(fig);
    
    if ~ishandle(fig)
        return
    else
        % retrieve the latest copy of the 'handles' struct, and return the answer.
        handles = guidata(fig);
     
        
        % Also, we need to delete the window.
        delete(fig);
    end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch
		disp(lasterr);
	end

end

%------------------------------------------------
function varargout = Click_Cancel_Callback(h, eventdata, handles, varargin)
% handles.Dummy=1;
% guidata(h,handles);
% uiresume(handles.UCIT_Options);
guiH=findobj('tag','UCIT_Options');
delete(guiH)

% --------------------------------------------------------------------------------------
function varargout = Click_OK_Callback (h, eventdata, handles, varargin)
guiH=findobj('tag','UCIT_Options');

%---------------------

if ~isempty(get(findobj(guiH,'tag','Edit_WorkDir'),'string'))
    setINIValue('UCIT.ini','WorkDir',get(findobj(guiH,'tag','Edit_WorkDir'),'string'));
end 

if ~isempty(get(findobj(guiH,'tag','Landwaarts_Checkbox'),'value'))
    setINIValue('UCIT.ini','Versterking',num2str(get(findobj(guiH,'tag','Landwaarts_Checkbox'),'value')));
else
    setINIValue('UCIT.ini','Versterking','0');
end 

if ~isempty(get(findobj(guiH,'tag','Landwaarts_Xc'),'string'))
    setINIValue('UCIT.ini','xVersterking',get(findobj(guiH,'tag','Landwaarts_Xc'),'string'));
end 

%---------------------

if ~isempty(get(findobj(guiH,'tag','Zeewaarts_Checkbox'),'value'))
    setINIValue('UCIT.ini','Consolideren',num2str(get(findobj(guiH,'tag','Zeewaarts_Checkbox'),'value')));
else
    setINIValue('UCIT.ini','Consolideren','0');
end 

if ~isempty(get(findobj(guiH,'tag','Zeewaarts_Xc'),'string'))
    setINIValue('UCIT.ini','xConsolidatie',get(findobj(guiH,'tag','Zeewaarts_Xc'),'string'));
end 

if ~isempty(get(findobj(guiH,'tag','Zeewaarts_XMarge'),'string'))
    setINIValue('UCIT.ini','xMarge',get(findobj(guiH,'tag','Zeewaarts_XMarge'),'string'));
end 

%---------------------

if ~isempty(get(findobj(guiH,'tag','Visual_Dune'),'value'))
    setINIValue('UCIT.ini','VisualDune',num2str(get(findobj(guiH,'tag','Visual_Dune'),'value')));
else
    setINIValue('UCIT.ini','VisualDune','0');
end 

%---------------------

if ~isempty(get(findobj(guiH,'tag','FrameOutput'),'value'))
    setINIValue('UCIT.ini','FrameOutput',num2str(get(findobj(guiH,'tag','FrameOutput'),'value')));
else
    setINIValue('UCIT.ini','FrameOutput','0');
end 

%---------------------

if ~isempty(get(findobj(guiH,'tag','Suppleren_Checkbox'),'value'))
    setINIValue('UCIT.ini','Suppleren',num2str(get(findobj(guiH,'tag','Suppleren_Checkbox'),'value')));
else
    setINIValue('UCIT.ini','Suppleren','0');
end 

if ~isempty(get(findobj(guiH,'tag','Zeewaarts_Begin'),'string'))
    setINIValue('UCIT.ini','Begin',num2str(get(findobj(guiH,'tag','Zeewaarts_Begin'),'string')));
else
    setINIValue('UCIT.ini','Begin','0');
end 

if ~isempty(get(findobj(guiH,'tag','Zeewaarts_Lengte'),'string'))
    setINIValue('UCIT.ini','Lengte',num2str(get(findobj(guiH,'tag','Zeewaarts_Lengte'),'string')));
else
    setINIValue('UCIT.ini','Lengte','0');
end 

if ~isempty(get(findobj(guiH,'tag','Zeewaarts_Hoogte'),'string'))
    setINIValue('UCIT.ini','Hoogte',num2str(get(findobj(guiH,'tag','Zeewaarts_Hoogte'),'string')));
else
    setINIValue('UCIT.ini','Hoogte','0');
end 

if ~isempty(get(findobj(guiH,'tag','DeterministicMode'),'string'))
    setINIValue('UCIT.ini','DeterministicMode',num2str(get(findobj(guiH,'tag','DeterministicMode'),'string')));
else
    setINIValue('UCIT.ini','DeterministicMode','0');
end 

% handles.Dummy=1;
% guidata(h,handles);
% uiresume%(handles.UCIT_Options);
delete(guiH)

% --------------------------------------------------------------------------------------    
function varargout = WorkDir_Browse_Callback(h, eventdata, handles, varargin)
guiH=findobj('tag','UCIT_Options');

if ~isempty(get(findobj(guiH,'tag','Edit_WorkDir'),'string'))
    [name,pat]=uigetfile([get(findobj(guiH,'tag','Edit_WorkDir'),'string') '*.*'],'Select workingdirectory');
else
    [name,pat]=uigetfile(['*.*'],'Select workingdirectory');
end

set(findobj(guiH,'tag','Edit_WorkDir'),'string',pat)


% --------------------------------------------------------------------------------------
function varargout = Zeewaarts_Checkbox_Callback(h, eventdata, handles, varargin)

guiH=findobj('tag','UCIT_Options');
if get(findobj(guiH,'tag','Landwaarts_Checkbox'),'value')==1|get(findobj(guiH,'tag','Suppleren_Checkbox'),'value')==1
    set(findobj(guiH,'tag','Zeewaarts_Checkbox'),'value',1)
    set(findobj(guiH,'tag','Landwaarts_Checkbox'),'value',0)
    set(findobj(guiH,'tag','Suppleren_Checkbox'),'value',0)
end


% --------------------------------------------------------------------------------------
function varargout = Landwaarts_Checkbox_Callback(h, eventdata, handles, varargin)

guiH=findobj('tag','UCIT_Options');
if get(findobj(guiH,'tag','Zeewaarts_Checkbox'),'value')==1|get(findobj(guiH,'tag','Suppleren_Checkbox'),'value')==1
    set(findobj(guiH,'tag','Zeewaarts_Checkbox'),'value',0)
    set(findobj(guiH,'tag','Landwaarts_Checkbox'),'value',1)
    set(findobj(guiH,'tag','Suppleren_Checkbox'),'value',0)
end

% --------------------------------------------------------------------------------------
function varargout = Suppleren_Checkbox_Callback(h, eventdata, handles, varargin)

guiH=findobj('tag','UCIT_Options');
if get(findobj(guiH,'tag','Landwaarts_Checkbox'),'value')==1|get(findobj(guiH,'tag','Suppleren_Checkbox'),'value')==1
    set(findobj(guiH,'tag','Zeewaarts_Checkbox'),'value',0)
    set(findobj(guiH,'tag','Landwaarts_Checkbox'),'value',0)
    set(findobj(guiH,'tag','Suppleren_Checkbox'),'value',1)
end


% ---------------------------------------------------------------------------------
function varargout = Visual_Dune_Callback(h, eventdata, handles, varargin)


% ---------------------------------------------------------------------------------
function varargout = FramePlot_Callback(h, eventdata, handles, varargin)
