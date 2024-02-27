function UCIT_selectTransect(varargin)
%UCIT_SELECTTRANSECT this function enables the user to select a transect
%in the user window
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = UCIT_selectTransect(varargin)
%
%   Input:
%   gets input from GUI
%
%   Output:
%   no output
%
%   Example
%
%   See also 

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%   Mark van Koningsveld       
%   Ben de Sonneville
%
%       M.vankoningsveld@tudelft.nl
%       Ben.deSonneville@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% UCIT_resetUCITDir;                                % reset Current Directory To UCIT directory (just to be on the safe side)

[check]    = UCIT_focusOn_Window('mapWindow');      % make mapWindow the current figure
if check == 0
    return
end

rayH       = UCIT_findAllObjectsOnToken('_');       % find all transects
selection  = UCIT_selectObject(rayH);               % select a transect by mouse click
[parts]    = UCIT_parseStringOnToken(selection,'_');% parse the tag of the selected object

% assign parts to proper variables
DataType   = parts{1};
Area       = parts{2};
TransectID = parts{3};
SoundingID = parts{4};

% Put the raynumber and coastvak in the GUI
if nargin==0                                     %From the UCIT GUI
     UCIT_setValues2Popup(1,DataType,Area,TransectID,SoundingID);
else
    switch varargin{1}                           %From batch windows, more cases possible
        case 'startDuinafslag'
            guiH=findobj('tag','UCIT_batchDuinafslagInput');
            set(findobj(guiH,'tag','UCIT_batchInputStartArea'),'string',Area);
            set(findobj(guiH,'tag','UCIT_batchInputStartRay' ),'string',transectID);
        case 'endDuinafslag'
            guiH=findobj('tag','UCIT_batchDuinafslagInput');
            set(findobj(guiH,'tag','UCIT_batchInputEndArea'  ),'string',Area);
            set(findobj(guiH,'tag','UCIT_batchInputEndRay'   ),'string',transectID);
    end
end