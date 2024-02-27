function varargout = KMLcolorbar(varargin)
%KMLCOLORBAR   make KML colorbar
%
%   kmlstring = KMLcolorbar(<keyword,value>) returns kml formatted string
%               KMLcolorbar(<keyword,value>) saves to kml file
%   [kmlstring,pngnames] = KMLcolorbar(...) also returns names of png files for overlay
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLcolorbar()
%
% keyword 'colorbarlocation' specifies where to put colorbars. The first
% colorbar in the list is shown by default, the other can be ticked. Useful
% when multiple parameters with different colormaps are shown together in GE.
% Default: {'W'}, options: {'N','NNE','ENE','E','ESE','SSE','S','SSW','WSW','W','WNW','NNW'}
%
% TODO: CBcLim should crop the colorbar range when is it different from
% cLim (if that is defined)
%
%See also: GOOGLEPLOT

% http://code.google.com/intl/nl/apis/kml/documentation/kmlreference.html#screenoverlay

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Gerben de Boer
%
%       g.j.deboer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

% $Id: KMLcolorbar.m 12766 2016-06-07 14:17:44Z gerben.deboer.x $
% $Date: 2016-06-07 22:17:44 +0800 (Tue, 07 Jun 2016) $
% $Author: gerben.deboer.x $
% $Revision: 12766 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLcolorbar.m $
% $Keywords: $

% TO DO: split png name (absolute) and png href (relative)

%% Options

OPT.CBfileName           = '';
OPT.CBkmlName            = 'colorbar';
OPT.CBcolorMap           = [];             % can be entered as a name (eg: 'jet'), or as a funtion
OPT.CBcolorSteps         = [];             % 
OPT.CBcLim               = [];             %
OPT.CBbgcolor            = [255 253 2];    % background color to be made transparent
OPT.CBfontrgb            = [0 0 0];        % black
OPT.CBcolorbarlocation   = {'W'};          %{'N','E','S','W'}; %{'N','NNE','ENE','E','ESE','SSE','S','SSW','WSW','W','WNW','NNW'};
OPT.CBcolorTitle         = '';             % The title of the colorbar as it appears in the bar
OPT.CBcolorTick          = [];             % Ticks on colorbar. If isempty, nothing is changed, see help colorberlegend
OPT.CBcolorTickLabel     = '';             % Is isempty, nothing is changed
OPT.CBtitlergb           = [0 0 0];        % black
OPT.CBframergb           = [255 253 2]/255;% white
OPT.CBalpha              = 0.8;            % transparency
OPT.CBtemplateHor        = 'KML_colorbar_template_horizontal.png';
OPT.CBtemplateVer        = 'KML_colorbar_template_vertical.png';
OPT.CBfontsize           = 7;

OPT.CBtipmargin          = [];
OPT.CBalignmargin        = [];
OPT.CBthickness          = [];

OPT.CBorientation        = [];
OPT.CBverticalalignment  = [];
OPT.CBhorizonalalignment = [];

OPT.CBopen               = 0; % KML_header 
OPT.CBvisible            = 1; % KML_header
OPT.CBdescription        = ''; % KML_header
OPT.CBinterpreter        = 'tex';

if nargin==0
    varargout = {OPT};
    return
end

if nargin == 1 % don't set properties if an OPT struct was already given
    OPT = varargin{1};
    if isempty(OPT.CBfileName  ), OPT.CBfileName   = OPT.fileName  ; end
    if isempty(OPT.CBkmlName   ), OPT.CBkmlName    = OPT.kmlName   ; end
    if isempty(OPT.CBcolorTitle), OPT.CBcolorTitle = OPT.CBkmlName   ; end
    if isempty(OPT.CBcolorMap  ), OPT.CBcolorMap   = OPT.colorMap  ; end
    if isempty(OPT.CBcolorSteps), OPT.CBcolorSteps = OPT.colorSteps; end
    if isempty(OPT.CBcLim      ), OPT.CBcLim       = OPT.cLim      ; end
else
    [OPT, Set, Default] = setproperty(OPT, varargin);
end

colorbarFig = figure('Visible','Off');

%% get filename, gui for filename, if not set yet

if isempty(OPT.CBfileName) && nargout==0 % if nargout==1, kml is a return argument, and not written to kml file
    [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as',[mfilename,'.kml']);
    OPT.CBfileName = fullfile(filePath,fileName);
end

%% set kmlName if it is not set yet

if isempty(OPT.CBkmlName)
    [ignore OPT.CBkmlName] = fileparts(OPT.CBfileName);
end

%% handle error when only one color is supplied

if isempty(OPT.CBcLim)
    error('cLim not supplied')
end
if OPT.CBcLim(1)==OPT.CBcLim(2)
    OPT.CBcLim = OPT.CBcLim + 10.*[-eps eps];
end

%% make colorbar pngs as separate files

[PATHSTR,NAME] = fileparts(OPT.CBfileName);
% % allow for '.' in middle of file name
% if ~isempty(EXT)
%    NAME  =[NAME,'.',EXT];
% end

if ischar(OPT.CBcolorbarlocation)
    OPT.CBcolorbarlocation = {OPT.CBcolorbarlocation};
end
OPT2     = OPT; % copy before overwriting margins & thickness
pngNames = {};
for ii = 1:length(OPT.CBcolorbarlocation)
    switch OPT.CBcolorbarlocation{ii}
        case {'NNW','N','NNE','SSE','S','SSW'}
            OPT.CBorientation        = 'horizontal';
            OPT2.CBtipmargin          = 0.05; % prevent overlap between S and E colorbars
            OPT2.CBalignmargin        = 0.08;
            OPT2.CBthickness          = 0.026;%0.013;
            switch OPT.CBcolorbarlocation{ii}
                case {'NNW','N','NNE'}
                    OPT.CBverticalalignment  = 'top';
                    OPT.CBfileName           = [fullfile(PATHSTR,NAME),'_hor_top'];
                case {'SSE','S','SSW'}
                    OPT.CBverticalalignment  = 'bottom';
                    OPT.CBfileName           = [fullfile(PATHSTR,NAME),'_hor_bot'];
            end
        case {'ENE','E','ESE','WSW','W','WNW'} % OPT.CBcolorbarlocation ] 'W'
            OPT.CBorientation        = 'vertical';
            OPT2.CBtipmargin          = 0.15; % prevent overlap with time ruler, google logo and N-rose
            OPT2.CBalignmargin        = 0.10;
            OPT2.CBthickness          = 0.02;%0.01;
            switch OPT.CBcolorbarlocation{ii}
                case {'ENE','E','ESE'}
                    OPT.CBhorizonalalignment = 'right';
                    OPT.CBfileName           = [fullfile(PATHSTR,NAME),'_ver_rgt'];
                case {'WSW','W','WNW'}
                    OPT.CBhorizonalalignment = 'left';
                    OPT.CBfileName           = [fullfile(PATHSTR,NAME),'_ver_lft'];
            end
        otherwise
            error('unknown OPT.CBcolorbarlocation location, ''%s''', OPT.CBcolorbarlocation{ii});
    end
    
    if isempty(OPT.CBtipmargin         ); OPT.CBtipmargin         = OPT2.CBtipmargin         ;end
    if isempty(OPT.CBalignmargin       ); OPT.CBalignmargin       = OPT2.CBalignmargin       ;end
    if isempty(OPT.CBthickness         ); OPT.CBthickness         = OPT2.CBthickness         ;end
    pngNames{end+1} = KML_colorbar(OPT);
end

OPT.CBfileName          =  fullfile(PATHSTR,NAME);

%% make associated kml code

colorbarstring = sprintf([...
    '<Folder>\n'...
    ' <name>%s</name>\n'...
    ' <open>0</open>\n'],...
    OPT.CBkmlName);
    
for ii = 1:length(OPT.CBcolorbarlocation)
    switch OPT.CBcolorbarlocation{ii}
        case 'NNW'
            overlayXY = [0 1];
            screenXY  = [0 1];
            pngName     = '_hor_top';
        case 'N'
            overlayXY = [0.5 1];
            screenXY  = [0.5 1];
            pngName     = '_hor_top';
        case 'NNE'
            overlayXY = [1 1];
            screenXY  = [1 1];
            pngName     = '_hor_top';
        case 'SSE'
            overlayXY = [1 0];
            screenXY  = [1 0];
            pngName     = '_hor_bot';
        case 'S'
            overlayXY = [0.5 0];
            screenXY  = [0.5 0];
            pngName     = '_hor_bot';
        case 'SSW'
            overlayXY = [0 0];
            screenXY  = [0 0];
            pngName     = '_hor_bot';
        case 'ENE'
            overlayXY = [1 1];
            screenXY  = [1 1];
            pngName     = '_ver_rgt';
        case 'E'
            overlayXY = [1 0.5];
            screenXY  = [1 0.5];
            pngName     = '_ver_rgt';
        case 'ESE'
            overlayXY = [1 0];
            screenXY  = [1 0];
            pngName     = '_ver_rgt';
        case 'WSW'
            overlayXY = [0 0];
            screenXY  = [0 0];
            pngName     = '_ver_lft';
        case 'W'
            overlayXY = [0 0.5];
            screenXY  = [0 0.5];
            pngName     = '_ver_lft';
        case 'WNW'
            overlayXY = [0 1];
            screenXY  = [0 1];
            pngName     = '_ver_lft';
    end
    
    bool = (ii == 1) & OPT.CBvisible;
    colorbarstring = [colorbarstring sprintf([...
        '  <Folder>\n'...
        '  <name>%s</name>\n'...
        '  <visibility>%d</visibility>\n'...
        '  <ScreenOverlay>\n'...
        '  <name>colorbar</name>\n'...
        '  <visibility>%d</visibility>\n'...
        '  <Icon><href>%s.png</href></Icon>\n'...
        '   <overlayXY x="%f" y="%f" xunits="fraction" yunits="fraction"/>\n'...
        '   <screenXY  x="%f" y="%f" xunits="fraction" yunits="fraction"/>\n'...
        '  </ScreenOverlay>\n'...
        '  </Folder>\n'],...
        OPT.CBcolorbarlocation{ii},...
        bool,bool,...
        [NAME,pngName],...
        overlayXY,screenXY)];
end
        
   colorbarstring = [colorbarstring sprintf([...
    '</Folder>'],...
    OPT.CBkmlName)];

%% save

    if ~isempty(OPT.CBfileName)
       fname = [OPT.CBfileName,'.kml'];
       OPT.CBfid    = fopen(fname,'w');
       output = [KML_header(OPT) colorbarstring KML_footer];
       fprintf(OPT.CBfid,'%s',output);
       fclose (OPT.CBfid);
       %pngNames{end+1} = fname;
    end

%% finish

   if nargout==1
       varargout = {colorbarstring};
   elseif nargout==2
       varargout = {colorbarstring,pngNames};
   end
   
   close(colorbarFig)

%% EOF

