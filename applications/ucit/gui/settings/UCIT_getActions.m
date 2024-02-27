function [datatypes] = UCIT_getActions;
%UCIT_GETDATATYPES  gets urls of selected datatypes in UCIT
%
%      [datatypes] = UCIT_getActions()
%
%   returns a cellstr with the relevant actions of
%   each of the four UCIT datatypes (transects, grids, lines, points)
%
%   Input: none
%
%
%   Output: structure with datatypes
%
%
%   Example: [datatypes] = UCIT_getActions
%
%
%   See also: UCIT_getDatatypes

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Ben de Sonneville
%
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

% TO DO: save as datatypes.transect(i).names instead of datatypes.transect.names{i}
% add data type

tmp=UCIT_getDatatypes;
%  NOTE: Keep this file consistent with UCIT_getDatatypes!
%  here we choose identical functions for all data, please modify this manually if needed

for i=1:length(tmp.transect.datatype)
datatypes.transect.commonactions{i}     =  {'UCIT_selectTransect','UCIT_plotTransect','UCIT_exportTransects2GoogleEarth', 'UCIT_plotMultipleYears','UCIT_analyseTransectVolume','UCIT_calculateMKL','UCIT_calculateTKL'};
datatypes.transect.specificactions{i}   =  {};
end

%% Grid data
%  names are a unique tag, datatype governs the actions

for i=1:length(tmp.grid.datatype)
datatypes.grid.commonactions{i}     =  {'UCIT_plotDataInPolygon', 'UCIT_plotDataInGoogleEarth', 'UCIT_plotDifferenceMap','UCIT_getCrossSection','UCIT_sandBalanceInPolygon', 'UCIT_IsohypseInPolygon'};
datatypes.grid.specificactions{i}   =  {};
end