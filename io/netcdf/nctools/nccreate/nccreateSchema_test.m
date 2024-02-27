function testresult = nccreateSchema_test()
% NCCREATESCHEMA_TEST  One line description goes here
%
% More detailed description of the test goes here.
%
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Van Oord
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 30 Mar 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: nccreateSchema_test.m 8557 2013-05-01 14:48:38Z tda.x $
% $Date: 2013-05-01 22:48:38 +0800 (Wed, 01 May 2013) $
% $Author: tda.x $
% $Revision: 8557 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/nccreate/nccreateSchema_test.m $
% $Keywords: $

MTestCategory.Unit;

testfile = fullfile(tempdir,'test.nc');
Format = {'netcdf4','netcdf4_classic','classic'};
testresult = false(size(Format));

for ii = 1:length(Format) 
    
    % make a nc schema
    dimstruct        = nccreateDimstruct('Name','x','Length',10);
    dimstruct(end+1) = nccreateDimstruct('Name','y','Length',10);
    dimstruct(end+1) = nccreateDimstruct('Name','t','Unlimited',true);
    varstruct        = nccreateVarstruct('Name','x','Dimensions',{'x'},'scale_factor',1,'ChunkSize',10,'Attributes',{'asdasd',1,'asd',2});
    varstruct(end+1) = nccreateVarstruct('Name','y','Dimensions',{'y'},'Attributes',{'asd',2},'ChunkSize',10);
    varstruct(end+1) = nccreateVarstruct('Name','t','Dimensions',{'t'},'Datatype','single','ChunkSize',1);
    varstruct(end+1) = nccreateVarstruct('Name','z','Dimensions',{'x','y','t'},'DeflateLevel',1,'ChunkSize',[10 10 1]);
    
    schema = nccreateSchema(dimstruct,varstruct,...
        'Filename',testfile,...
        'Attributes',{'Filetype','Testfile'},'Format',Format{ii});
  
    if exist(testfile,'file')
        delete(testfile);
    end
    
    % write the schema
    ncwriteschema(testfile,schema)
    
    % write some data 
    data = sin(1:10)';
    ncwrite(testfile,'x',data)
    assert(isequal(data,ncread(testfile,'x')));
    
    % read schema from created file
    schema2 = ncinfo(testfile);
    
    % test if both are equal
    testresult(ii) = isequal(schema,schema2);
end
    
testresult = all(testresult);