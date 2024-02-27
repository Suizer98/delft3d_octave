function [DIFdata]=ITHK_readDIF(DIFfilename)
%read DIF : Reads a UNIBEST dif-file which contains input data for the 
%computation of diffraction and sheltering effect on a wave climate behind 
%a structure
%   
%   Syntax:
%     function [DIFdata]=ITHK_readDIF(DIFfilename)
%   
%   Input:
%     DIFfilename    (optional) String with filename of dif-file
%   
%   Output:
%     DIFdata        struct with contents of dif-file
%                      .Lray       : Filename of local SCO-file (to be made)
%                      .Oray       : Filename of global SCO-file (existing)
%                      .X          : x-coord of local sco [m]
%                      .Y          : y-coord of local sco [m]
%                      .groyneX    : x-coord of diffraction point [m] (e.g. at tip of groyne)
%                      .groyneY    : y-coord of diffraction point [m] (e.g. at tip of groyne)
%                      .groynehoek : Groyne angle(w.r.t. North) 
%                      .coastangle : Coast angle (normal w.r.t. North)
%   
%   Example:
%     [DIFdata]=ITHK_readDIF('test.dif')
%   
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: ITHK_readDIF.m 6382 2012-06-12 16:00:17Z boer_we $
% $Date: 2012-06-13 00:00:17 +0800 (Wed, 13 Jun 2012) $
% $Author: boer_we $
% $Revision: 6382 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/operations/OLD/ITHK_readDIF.m $
% $Keywords: $

%% Read input
if nargin==0
    [DIFfilename DIFpath] = uigetfile( ...
        {  '*.dif','diffraction-files (*.dif)'; ...
           '*.txt','txt-files (*.txt)'; ...
           '*.*',  'All Files (*.*)'}, ...
           'Pick a file','MultiSelect', 'off');
end

if ~isstr(DIFfilename) || ~strcmpi(DIFfilename(end-3:end),'.dif')
    fprintf('Error : file not suitable!\n')
    return
elseif nargin>0
    [DIFpath,DIFfilename1,DIFfilename2]=fileparts(DIFfilename);
    DIFfilename=[DIFfilename1,DIFfilename2];
    if ~isempty(DIFpath)
        DIFpath=[DIFpath,filesep];
    end
end

%% Read data
[DIFdata1 DIFdata2 DIFdata3 DIFdata4 DIFdata5 DIFdata6 DIFdata7 DIFdata8] = textread([DIFpath,DIFfilename],'%s%s%f%f%f%f%f%f','headerlines',1);
for ii=1:size(DIFdata1,1)
    if strfind(lower(DIFdata2{ii}),'.sco')
        DIFdata1{ii} = DIFdata1{ii}(1:end-4);
        DIFdata2{ii} = DIFdata2{ii}(1:end-4);
    end
    DIFdata(ii).Lray=DIFdata1{ii};           % Name Local ray
    DIFdata(ii).Oray=DIFdata2{ii};           % Name offshore ray
    DIFdata(ii).X=DIFdata3(ii);              % X Location DIFdataal ray
    DIFdata(ii).Y=DIFdata4(ii);              % Y Location DIFdataal ray
    DIFdata(ii).groyneX=DIFdata5(ii);        % X Location groyne diffraction point
    DIFdata(ii).groyneY=DIFdata6(ii);        % Y Location groyne diffraction point
    DIFdata(ii).groynehoek=DIFdata7(ii);     % Angle of groyne with the coast relative to North
    DIFdata(ii).coastangle=DIFdata8(ii);	 % Angle of coast relative to North
end