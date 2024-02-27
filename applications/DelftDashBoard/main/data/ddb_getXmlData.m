function localdata = ddb_getXmlData(localdir,url,xmlfile)
%DDB_GETXMLDATA  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = ddb_getXmlData(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   ddb_getXmlData
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Wiebe de Boer
%
%       Wiebe.deBoer@deltares.nl
%
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 05 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_getXmlData.m 16798 2020-11-11 18:17:34Z ormondt $
% $Date: 2020-11-12 02:17:34 +0800 (Thu, 12 Nov 2020) $
% $Author: ormondt $
% $Revision: 16798 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/data/ddb_getXmlData.m $
% $Keywords: $

%% Check local xml-file else download from server
file = [localdir filesep xmlfile];
localdata  = [];
serverdata = [];

if exist(file,'file')
    % Local file exists
    localdata=xml2struct(file,'structuretype','supershort');
    try
        % Copy file on server to local folder
        ddb_urlwrite(url,[localdir filesep 'temp.xml']);
        % Read file from server
        serverdata=xml2struct([localdir filesep 'temp.xml'],'structuretype','supershort');
        % And delete file that was copied from server
        delete([localdir filesep 'temp.xml']); %cleanup
    catch
        % Data cannot be updated
        disp(['Could not retrieve ' xmlfile ' from server, no data update!']);
    end 
else
    % Local file does not exist, so copy file from server (this should happen the first time DelftDashboard is started)
    try
        % Make folder
        if ~isdir(localdir)
           mkdir(localdir); 
        end
        % Copy file from server
        ddb_urlwrite(url,file);
        % Read file
        localdata=xml2struct(file,'structuretype','supershort');
        % All data files need to be updated
        fld = fieldnames(localdata);
        for ii=1:length(fld)
            if strcmpi(fld{ii},'file')
                for jj=1:length(localdata.(fld{ii}))
                    localdata.(fld{ii})(jj).update = 1;
                end
            end
        end
    catch
        error(['Could not retrieve ' xmlfile ' from server']);
        return
    end
end

iupdate=0;

if isempty(localdata) && ~isempty(serverdata)

    % New data file was loaded
    localdata=serverdata;
    fld = fieldnames(localdata);
    for ii=1:length(fld)
        for jlocal=1:length(localdata.(fld{ii}))
            localdata.(fld{ii})(jlocal).update=0;
        end
    end

elseif ~isempty(localdata) && isempty(serverdata)

    % Could not load data from server, so use local data
    fld = fieldnames(localdata);
    for ii=1:length(fld)
        for jlocal=1:length(localdata.(fld{ii}))
            localdata.(fld{ii})(jlocal).update=0;
        end
    end

else
    
    % Both local data and server data exist, so try to merge the two by
    % updating local data

    % First set file update to zero for each field
    fld = fieldnames(localdata);
    for ii=1:length(fld)
        for jlocal=1:length(localdata.(fld{ii}))
            localdata.(fld{ii})(jlocal).update=0;
        end
    end
    
    % Loop through server data

    fld = fieldnames(serverdata);
    
    for ii=1:length(fld)
        
        if ~isfield(localdata,fld{ii})
            % Field does not yet exist in local data, so create empty field
            localdata.(fld{ii})=serverdata.(fld{ii});
            for jlocal=1:length(localdata.(fld{ii}))
                localdata.(fld{ii})(jlocal).update=1;
            end
            iupdate=1;
        end

        % There are three options:
        % 1) entry is in local data and in server data
        % 2) entry is in server data and not in local data
        % 3) entry is in local data and not in server data (no need to do anything)

        % Make an array of local data names
        localdatanames={''};
        for jlocal=1:length(localdata.(fld{ii}))
            localdatanames{jlocal}=localdata.(fld{ii})(jlocal).name;
        end

        % Look for option 1
        for jserver=1:length(serverdata.(fld{ii}))
            name=serverdata.(fld{ii})(jserver).name;
            isame=strmatch(lower(name),lower(localdatanames),'exact');
            for k=1:length(isame)
                jlocal=isame(k);
                % Now check if server data has higher number
                % Find versions
                serverversion=0;
                if isfield(serverdata.(fld{ii})(jserver),'version')
                    if ~isempty(serverdata.(fld{ii})(jserver).version)
                        serverversion=str2double(serverdata.(fld{ii})(jserver).version);
                    end
                end
                localversion=0;
                if isfield(localdata.(fld{ii})(jlocal),'version')
                    if ~isempty(localdata.(fld{ii})(jlocal).version)
                        localversion=str2double(localdata.(fld{ii})(jlocal).version);
                    end
                end
                if serverversion>localversion
                    % Update local data
                    % A newer version was found somewhere, so ask user if he wants to
                    % update
                    Qupdate = questdlg(['There is an update for ' fld{ii} ' ' name ' in ' xmlfile ', would you like to delete the old cache and update?'], ...
                        'Update?', ...
                        'Yes', 'No', 'Yes');
                    switch Qupdate
                        case{'Yes'}
                            iupdate=1;
                            % Copy fields from server data to local data
                            fld2=fieldnames(serverdata.(fld{ii})(jserver));
                            for kk=1:length(fld2)
                                localdata.(fld{ii})(jlocal).(fld2{kk})=serverdata.(fld{ii})(jserver).(fld2{kk});
                            end
                            localdata.(fld{ii})(jlocal).update = 1;
                            if isdir([localdir filesep name])
                                rmdir([localdir filesep name],'s');
                            end
                        case{'No'}
                    end
                end
                
                serverurl='    ';
                if isfield(serverdata.(fld{ii})(jserver),'URL')
                    if ~isempty(serverdata.(fld{ii})(jserver).URL)
                        serverurl=serverdata.(fld{ii})(jserver).URL;
                    end
                end
                localurl='    ';
                if isfield(localdata.(fld{ii})(jlocal),'URL')
                    if ~isempty(localdata.(fld{ii})(jlocal).URL)
                        localurl=localdata.(fld{ii})(jlocal).URL;
                    end
                end

                % When urls both start with http, but the urls are
                % different
                if strcmpi(serverurl(1:4),'http') && strcmpi(localurl(1:4),'http')
                    if ~strcmpi(serverurl,localurl)
                        iupdate=1;
                        % Copy fields from server data to local data
                        fld2=fieldnames(serverdata.(fld{ii})(jserver));
                        for kk=1:length(fld2)
                            localdata.(fld{ii})(jlocal).(fld2{kk})=serverdata.(fld{ii})(jserver).(fld2{kk});
                        end
                        localdata.(fld{ii})(jlocal).update = 1;
                    end
                end
                
                
            end
        end                    
                
        % Now look for option 2
        for jserver=1:length(serverdata.(fld{ii}))
            name=serverdata.(fld{ii})(jserver).name;
            isame=strmatch(lower(name),lower(localdatanames),'exact');
            if isempty(isame)
                % New data found on server
                iupdate=1;
                jlocal=length(localdata.(fld{ii}))+1;
                fld2=fieldnames(serverdata.(fld{ii})(jserver));
                for kk=1:length(fld2)
                    localdata.(fld{ii})(jlocal).(fld2{kk})=serverdata.(fld{ii})(jserver).(fld2{kk});
                end
                localdata.(fld{ii})(jlocal).update = 1;
            end
        end
        
    end
end

if iupdate
    % Write new local data file
    % First remove update fields
    tempdata=localdata;
    % First set file update to zero for each field
    fld = fieldnames(tempdata);
    for ii=1:length(fld)
        for jlocal=1:length(tempdata.(fld{ii}))
            if isfield(tempdata.(fld{ii})(jlocal),'update')
                tempdata.(fld{ii})=rmfield(tempdata.(fld{ii}),'update');
            end
        end
    end
    struct2xml(file,tempdata,'structuretype','supershort');
end
