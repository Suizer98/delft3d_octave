function OPT = uncompress(fileName, varargin)
%UNCOMPRESS  Uncompresses a zip, rar or whatever compressed file using 7zip
%
%   Syntax:
%       OPT = uncompress(fileName, varargin)
%
%   Input:
%       fileName    = file to uncompress
%       $varargin   = keyword/value pairs for additional options where the 
%       following <keyword,value> pairs have been implemented (values 
%       indicated are the current default settings):
%
%       'outpath'   , []        : if nothing specified the original
%                                 filelocation is used
%       'quiet'     , false     : do not surpress output
%
%   Output:
%       OPT.status  : 0 if succesful, non-zero when function fails
%          .result  : contains output message of 3rd party function 7z.exe
%
%   Example:
%       uncompress('file','c:\temp\fik.rar')
%           uncompresses the contents of .rar file to c:\temp
%
%       OPT = uncompress('c:\test.rar','quiet',true,'outpath',pwd)
%           silent uncompress of the .rar file to the working directory
%
%   See also unzip system('7z')

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Van Oord
%       Aad van Es
%
%       aes@vanoord.com
%
%       Watermanweg 64
%       POBox 8574
%       3009 AN Rotterdam
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

% This tools is part of VOTools which is the internal clone of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 24 Dec 2009
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: uncompress.m 12381 2015-11-26 09:24:01Z cclaessens.x $
% $Date: 2015-11-26 17:24:01 +0800 (Thu, 26 Nov 2015) $
% $Author: cclaessens.x $
% $Revision: 12381 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/uncompress.m $
% $Keywords: $

%% settings
% defaults
OPT.outpath     = [];       % output path
OPT.quiet       = false;    % do not surpress output
OPT.gui         = false;    % do not show 7zip gui
OPT.password    = '';       % if not empty, use to specify a password to extract the archive
OPT.args        = '-y';
% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin{:});

%%
% define outpath
[OPT.fileDir, OPT.fileName, OPT.fileExt] = fileparts(fileName);
if isempty(OPT.outpath)
    OPT.outpath = OPT.fileDir;
    if isempty(OPT.outpath)
       OPT.outpath = '.'; % unpacking to '' does not work in arglist <dosstring> below, so choose pwd '.'
    end
end

if ~OPT.quiet
    fprintf('unpacking %s ...',fileName);
end
tic

if isempty(OPT.password)
    password = '';
else
    password = sprintf(' -p"%s" ',OPT.password);
end

if isdeployed
%Thus the 7za.exe and 7zG.exe must reside on the location of the deployed product ! Add these exe's to the package.    
    if exist('getcurrentdir.m','file')
        basepath = getcurrentdir();          % Path to the installation folder of the exe  
    else
        basepath = ''; 
    end 
else
    basepath = fullfile(fileparts(mfilename('fullpath')),'private','7z');
end

if OPT.gui
    path7zip      = fullfile(basepath,'7z922','7zG.exe');
else
    path7zip      = fullfile(basepath,'7za.exe');
end

dosstring     = sprintf('"%s" %s%s e "%s" -o"%s"',path7zip,password,OPT.args,fullfile(fileName),OPT.outpath);

[OPT.status, OPT.info] = system(dosstring);

% get extracted files from string
tokens = regexp(OPT.info,'\nExtracting *([^\n])+','tokens');
OPT.extractedFiles = [tokens{:}]';

if ~OPT.quiet
    fprintf(1,' took %2.1f sec to %s\n', toc, OPT.outpath);
end