function s = ddb_readDelft3D_keyWordFile(fname,varargin)
%DDB_READDELFT3D_KEYWORDFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   s = ddb_readDelft3D_keyWordFile(fname)
%
%   Input:
%   fname =
%
%   Output:
%   s     =
%
%   Example
%   ddb_readDelft3D_keyWordFile
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_readDelft3D_keyWordFile.m 12731 2016-05-12 15:46:58Z nederhof $
% $Date: 2016-05-12 23:46:58 +0800 (Thu, 12 May 2016) $
% $Author: nederhof $
% $Revision: 12731 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/fileio/ddb_readDelft3D_keyWordFile.m $
% $Keywords: $

%% Reads Delft3D keyword file into structure

lowercase=1;
firstcharacterafterdata=' ';
allowspaces=0;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'lowercase'}
                lowercase=varargin{ii+1};
            case{'firstcharacterafterdata'}
                firstcharacterafterdata=varargin{ii+1};
            case{'allowspaces'}
                allowspaces=varargin{ii+1};
        end
    end
end

s=[];
fid=fopen(fname,'r');
while 1
    str=fgetl(fid);
    if str==-1
        break
    end
    str=deblank2(str);
    if ~isempty(str)
        if strcmpi(str(1),'#')
            % Comment line
        else
            if str(1)=='[' && str(end)==']';
                % New field
                if lowercase
                    fld=lower(str(2:end-1));
                else
                    fld=str(2:end-1);
                end
                fld=fld(fld~=' ');
                if isfield(s,fld)
                    % Field already exist
                    ifld=ifld+1;
                else
                    ifld=1;
                end
            else
                isf=find(str=='=');
                if isempty(isf)
                    break
                end
                keyword=str(1:isf-1);
                keyword=strrep(keyword,' ','');
                if lowercase
                    keyword=lower(keyword);
                end
                v=str(isf+1:end);
                v=deblank2(v);
                if isempty(v)
                    val=[];
                else
                    if strcmpi(keyword,'waveforces')
                        shite1=1
                    end
                    if allowspaces
                        val=[];
                        val{1}=v;
                    else
                        val = strread(v,'%s','delimiter',' ');
                    end
                    if strcmpi(val{1}(1),'#')
                        % Check if there is only one #
                        ii=find(v=='#');
                        if length(ii)==1
                            % Only comments in this line
                            val='';
                        else
                            val = strread(v,'%s','delimiter','#');
                            val=val{2};
                        end
                    else
                        if allowspaces
                            ish=length(v)+1;
                        else
                            ish=find(v==firstcharacterafterdata, 1);
                        end
                        if isempty(ish)
                            % No comments at end of line
                            val=deblank(v);
                        else
                            val=deblank(v(1:ish-1));
                        end
                        %                    val=val{1};
                    end
                    ispace=find(val==' ', 1);
                    if ~isnan(str2double(val))
                        % It's a number
                        val=str2double(val);
                    elseif ~isempty(ispace)
                        % It's multiple numbers or multiple words
                        if ~isnan(str2num(val))
                            val=str2num(val);
                        end
                    else
                        % It's a string
                        % Check if it's a boolean
                        switch lower(val)
                            case{'true'}
                                val=true;
                            case{'false'}
                                val=false;
                        end
                    end
                end
                inormal=1;
                if ~isempty(s)
                    if isfield(s,fld)
                        if ifld<=length(s.(fld))
                            if isfield(s.(fld)(ifld),keyword)
                                if ~isempty(s.(fld)(ifld).(keyword))
                                    % Field already exists
                                    if ~iscell(s.(fld)(ifld).(keyword))
                                        % Make this a cell array
                                        vvv=s.(fld)(ifld).(keyword);
                                        s.(fld)(ifld).(keyword)=[];
                                        s.(fld)(ifld).(keyword){1}=vvv;
                                        s.(fld)(ifld).(keyword){2}=val;
                                    else
                                        nnn=length(s.(fld)(ifld).(keyword));
                                        s.(fld)(ifld).(keyword){nnn+1}=val;
                                    end
                                    inormal=0;
                                end
                            end
                        end
                    end
                end
                if inormal
                    try
                    s.(fld)(ifld).(keyword)=val;
                    catch
                        shite=1
                    end
                end
            end
        end
        
    end
end
fclose(fid);

