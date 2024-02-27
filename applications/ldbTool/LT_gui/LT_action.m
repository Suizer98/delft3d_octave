function LT_action(subRoutine,optionalValue)
%LT_ACTION ldbTool GUI function to perform selected action on ldb
%
% See also: LDBTOOL

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Code
[but,fig]=gcbo;
data=LT_getData;
data=data(5);

if isempty(data)
    errordlg('Landboundary is empty!','LdbTool');
    return
end

[dataIn, dataOut]=LT_getSelectedCells(data); % get segements inside and outside selection

switch subRoutine
    case 'glue'
        switch get(findobj(fig,'tag','LT_whichGluePopupmenu'),'value');
            case 1
                outLdb=ultraGlueLDB(optionalValue,dataIn);
            case 2
                outLdb=ultraGlueLDB(optionalValue,dataIn,'s');
        end
    case 'ipGlue'
        outLdb=ipGlueLDB(dataIn);
    case 'closeSegments'
        outLdb=closeLdbSegments(dataIn);
    case 'expand'
        outLdb=blowUpLDB(optionalValue, dataIn);
    case 'thin'
        outLdb=thinOutLDB(optionalValue, dataIn);
    case 'inCreaseReso'
        outLdb=addEquidistantPointsBetweenSupportingLDBPoints(optionalValue,dataIn);
    case 'removeDouble'
        outLdb=removeDoubleSegmentsLDB(dataIn);
    case 'removeSingle'
        outLdb=removeSinglePointsLDB(dataIn);
end

if ~isempty(dataOut) % thus a selection was made
    outLdb.ldbCell=[outLdb.ldbCell; dataOut.ldbCell];
    outLdb.ldbBegin=[outLdb.ldbBegin;dataOut.ldbBegin];
    outLdb.ldbEnd=[outLdb.ldbEnd;dataOut.ldbEnd];
    LT_removeSelection; % remove selection
end

ldb=rebuildLdb(outLdb.ldbCell);

LT_updateData(ldb,outLdb.ldbCell,outLdb.ldbBegin,outLdb.ldbEnd);