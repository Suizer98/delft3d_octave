function [LTRdata]=readLTR(LTRfilename)
%read LTR : Reads a UNIBEST LTR-file
%   
%   Syntax:
%     function  [LTRdata]=readLTR(LTRfilename)
%   
%   Input:
%     LTRfilename         String with filename of LTR-file
%   
%   Output:
%     LTRdata
%             .angle      
%             .       
%             .   
%   
%   Example:
%     [LTRdata]=readLTR('test.LTR')
%   
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
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
% Created: 14 Apr 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: readLTR.m 14962 2018-12-13 15:29:34Z huism_b $
% $Date: 2018-12-13 16:29:34 +0100 (Thu, 13 Dec 2018) $
% $Author: huism_b $
% $Revision: 14962 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/readLTR.m $
% $Keywords: $


%% CREATE DEFAULT OUTPUT STRUCTURE
[pathnm,filenm,extnm]=fileparts(LTRfilename);
LTRdata = struct;
LTRdata.filenm = [filenm,extnm];
LTRdata.pathnm = pathnm;
LTRdata.no = 0;
LTRdata.angle = [];
LTRdata.h0 = [];
LTRdata.pro_file = {};
LTRdata.cfs_file = {};
LTRdata.cfe_file = {};
LTRdata.sco_file = {};
LTRdata.ray_file = {};


%% READ DATA
fid=fopen(LTRfilename);

%Read comment line
lin=fgetl(fid);

% Read number of locations
lin=fgetl(fid);
nloc=strread(lin,'%d');
if isempty(nloc)
    fprintf(['Warning empty LTR file! (',LTRdata.filenm,')\n']);
    return
end

%Read comment line
lin=fgetl(fid);

%Read data
for ii=1:nloc
    lin = fgetl(fid);
    try
        % read a line with LTR data
        [f1, f2, s1, s2, s3, s4, s5 ]=strread(lin,'%f%f%s%s%s%s%s');
        
        LTRdata.no           = nloc;
        LTRdata.angle(ii)    = f1;
        LTRdata.h0(ii)       = f2;
        LTRdata.pro_file{ii} = regexprep(s1{1},'''','');
        LTRdata.cfs_file{ii} = regexprep(s2{1},'''','');
        LTRdata.cfe_file{ii} = regexprep(s3{1},'''','');
        LTRdata.sco_file{ii} = regexprep(s4{1},'''','');
        LTRdata.ray_file{ii} = regexprep(s5{1},'''','');
    catch    
        fprintf(['Warning line could not be read in LTR file! (',LTRdata.filenm,', line no. ',num2str(ii),')\n']);
    end
end
fclose(fid);

