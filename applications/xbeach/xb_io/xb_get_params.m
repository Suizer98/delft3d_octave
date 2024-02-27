function [params params_array] = xb_get_params(fpath)
%XB_GET_PARAMS  Reads XBeach parameter types and defaults from XBeach source code
%
%   Function to read XBeach params types and defaults from XBeach source
%   code (params.F90). Useful to link to latest trunk update.
%
%   Syntax:
%   [params params_array] = xb_get_params(xbdir)
%
%   Input:
%   xbdir           = Directory in which XBeach source code can be found.
%                     If not given, an attempt is made to use a default
%                     path.
%
%   Output:
%   params          = structure array with listing of every parameter in
%                     XBeach, including type, name, units, comment,
%                     parameter type, default, minimum recommended and
%                     maximum recommended values data.
%   params_array    = array-version of params
%
%   Example
%   [params params_array] = xb_get_params(xbdir)
%
%   See also xb_read_params, xb_write_params

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Robert McCall
%
%       robert.mccall@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 25 Nov 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_get_params.m 13911 2017-11-09 09:06:26Z nederhof $
% $Date: 2017-11-09 17:06:26 +0800 (Thu, 09 Nov 2017) $
% $Author: nederhof $
% $Revision: 13911 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_io/xb_get_params.m $
% $Keywords: $

%% read params.f90
if ~exist('fpath','var')
    fpath = abspath(fullfile(fileparts(which(mfilename)), '..', '..', '..', '..', 'fortran', 'XBeach'));
else
    if ~exist(fpath, 'dir') || isempty(fpath)
        fpath = abspath(fullfile(fileparts(which(mfilename)), '..', '..', '..', '..', 'fortran', 'XBeach'));
    end
end

paramfile='params.F90';
Typename='parameters';

paramsfname=fullfile(fpath, paramfile);

params = {};
params_array = struct( ...
    'type', {}, ...
    'name', {}, ...
    'noinstances', {}, ...
    'units', {}, ...
    'comment', {}, ...
    'advanced', {}, ...
    'deprecated', {}, ...
    'partype', {}, ...
    'default', {}, ...
    'minval', {}, ...
    'maxval', {}, ...
    'required', {}, ...
    'allowed', {}, ...
    'condition', {}, ...
    'affects', {}           );

if exist(paramsfname, 'file')
    
    fid=fopen(paramsfname);

    parread=0;
    parcount=0;

    nowifcondition={};
    storeifcondition={};
    iflevel=0;
    parametertype='unknown';

    while ~feof(fid)
        try
        if parread==0
            % does this line say type parameters?
            line=strtrim(fgetl(fid));
            t1=findstr('type',strtrim(line));
            t2=findstr(Typename,line);
            if (~isempty(t1) && t1==1 && ~isempty(t2))
                parread = 1;
            end
        elseif parread==1
            line=strtrim(fgetl(fid));
            t0 = findstr('!',line);  if length(t0)>1; t0=t0(1); end;  % we need this later to determine if this is likely continuation of comment
            line=strtrim(line);
            % is this the end of type parameters?
            t11=findstr('end',line);
            t12=findstr('type',line);
            t13=findstr(Typename,line);
            if (~isempty(t11) && t1==1 && ~isempty(t12) && ~isempty(t13))
                parread=2;
            end
            t3c=0;
            t3=findstr('::',line); if length(t3)>1; t3=t3(1); end; if~isempty(t3);t3c=t3;end;
            t4=findstr('=',line);  if length(t4)>1; t4=t4(t4>t3c);t4=t4(1); end;
            t5=findstr('!',line);  if length(t5)>1; t5=t5(1); end;
            t5a=findstr('[Section]',line);  if length(t5a)>1; t5a=t5a(1); end;
            t6=findstr('[',line);  if length(t6)>1; t6=t6(t6>t3c);t6=t6(1); end;
            t7=findstr(']',line);  if length(t7)>1; t7=t7(t7>t3c);t7=t7(1); end;
            t8=findstr('(advanced)',line);
            t9=findstr('(deprecated)',line);
            if (~isempty(t3) && ~isempty(t4) && ~isempty(t5))
                parcount=parcount+1;
                params_array(parcount).type = strtrim(line(1:t3-1));
                params_array(parcount).name = strtrim(line(t3+2:t4-1));
                params_array(parcount).noinstances = 0;
                if isempty(t6)
                    params_array(parcount).units = 'unknown';
                    if ~isempty(t8)
                        params_array(parcount).comment = strtrim(line(t8+10:end));
                        params_array(parcount).advanced = 1;
                        params_array(parcount).deprecated = 0;
                    else
                        if ~isempty(t9)
                            params_array(parcount).comment = strtrim(line(t9+12:end));
                            params_array(parcount).advanced = 0;
                            params_array(parcount).deprecated = 0;
                        else
                            params_array(parcount).comment = strtrim(line(t5+1:end));
                            params_array(parcount).advanced = 0;
                            params_array(parcount).deprecated = 0;
                        end
                    end
                    params_array(parcount).partype = strtrim(parametertype);
                else
                    params_array(parcount).units = strtrim(line(t6+1:t7-1));
                    if ~isempty(t8)
                        params_array(parcount).comment = strtrim(line(t8+10:end));
                        params_array(parcount).advanced = 1;
                        params_array(parcount).deprecated = 0;
                    else
                        if ~isempty(t9)
                            params_array(parcount).comment = strtrim(line(t9+12:end));
                            params_array(parcount).advanced = 0;
                            params_array(parcount).deprecated = 1;
                        else
                            params_array(parcount).comment = strtrim(line(t7+1:end));
                            params_array(parcount).advanced = 0;
                            params_array(parcount).deprecated = 0;
                        end
                    end
                    params_array(parcount).partype = strtrim(parametertype);
                end
            elseif t5==1 & ~isempty(t5a) % Last line of comment is probably parameter type decription
                parametertype=strtrim(line(t5a+9:end));
            elseif t5==1 & t0>50  % probably continuation of comment of the last read variable
                commentcont = strtrim(line(2:end));
                params_array(parcount).comment = [params_array(parcount).comment commentcont];
            end

        elseif parread==2   % finding default, min and max
            line='';
            cont=true;
            while cont
                line=[line strtrim(fgetl(fid))];
                % only fortran readable text is included
                t200=findstr('!',line);
                if ~isempty(t200)
                    line=line(1:t200-1);
                end
                % continue on next lines if we have "&"
                t201=findstr('&',line);
                if ~isempty(t201)
                    line=line(1:t201-1);
                    cont=true;
                else
                    cont=false;
                end
            end
            % remove all whitespaces
            line(line==' ')=[];
            % three tests to see if this is a readkey statement
            t21=findstr('=',line);
            t22=findstr('readkey_',line);
            t23=findstr('params.txt',line);
            % test to see if this has information about allowed names for
            % variables
            tvn=findstr('allowednames',line);
            tvl=findstr('/',line);
            %test to see if this is a conditional statement
            tif=findstr('if(',line(1:min(3,end)));
            telseif=findstr('elseif(',line(1:min(7,end)));
            tthen=findstr(')then',line(max(1,end-4):end));
            telse=findstr('else',line(1:min(4,end)));
            tendif=findstr('endif',line(1:min(5,end)));
            if (~isempty(t21) && ~isempty(t22) && ~isempty(t23))
                % Okay, it's readkey, but what type?
                t22r=findstr('readkey_dbl(',line);
                t22i=findstr('readkey_int(',line);
                t22s=findstr('readkey_str(',line);
                t22n=findstr('readkey_name(',line);
                t22rv=findstr('readkey_dblvec(',line);
                t22req=findstr('required=',line);
                % Reset values
                tempdef=[];
                tempmin=[];
                tempmax=[];
                temprequired=[];
                tempallowed=[];
                tempcondition=[];
                for icond=1:iflevel
                    if icond==1
                        tempcondition=[nowifcondition{icond}];
                    else
                        tempcondition=[tempcondition ' & ' nowifcondition{icond}];
                    end
                end
                % find other keys
                t24=findstr('par%',line);
                t25=findstr(',',line);
                t26=findstr(')',line);


                if (~isempty(t22r) || ~isempty(t22i))  % readkey_dbl & readkey_int
                    tempname = strtrim(line(t24+4:t21-1));
                    tempdef  = line(t25(2)+1:t25(3)-1);
                    tempdef = parsestringtonumber(tempdef);
                    tempmin  = parsestringtonumber(line(t25(3)+1:t25(4)-1));
                    if length(t25)>4
                        tempmax  = parsestringtonumber(line(t25(4)+1:min(t25(5),t26(end))-1));
                    else
                        tempmax  = parsestringtonumber(line(t25(4)+1:t26(end)-1));
                    end
                elseif ~isempty(t22s)  % readkey_str
                    tempname = strtrim(line(t24+4:t21-1));
                    tempdef  = line(t25(2)+1:t25(3)-1);
                    tempdef(tempdef=='''')=[];
                    tempdef = regexprep(tempdef,'par%','par.');
                    tempallowed = allowed;
                elseif ~isempty(t22n)   % readkey_name
                    tempname = strtrim(line(t24+4:t21-1));
                    tempdef = [];
                    % do something with names
                elseif ~isempty(t22rv)
                    tempname = strtrim(line(t24+4:t21-1));
                    tempdef  = parsestringtonumber(line(t25(4)+1:t25(5)-1));
                    tempmin  = parsestringtonumber(line(t25(5)+1:t25(6)-1));
                    if length(t25)>6
                        tempmax  = parsestringtonumber(line(t25(6)+1:min(t25(7),t26(end))-1));
                    else
                        tempmax  = parsestringtonumber(line(t25(6)+1:t26(end)-1));
                    end
                end
                if ~isempty(t22req)
                    if strcmp(line(t22req+9),'(') 
                        temprequired = line(t22req+9:t26(1));
                    else
                        temprequired = line(t22req+9:t26(1)-1);
                    end
                    if strcmpi(strtrim(temprequired),'.true.');
                        temprequired=true;
                    elseif strcmpi(strtrim(temprequired),'.false.');
                        temprequired=false;
                    else
                        temprequired = convertfort2mat(temprequired);
                    end
                else
                    temprequired = false;
                end
                for ivar=1:length(params_array)
                    if strcmpi(strtrim(params_array(ivar).name),tempname)
                        params_array(ivar).noinstances=params_array(ivar).noinstances+1;
                        params_array(ivar).default{params_array(ivar).noinstances}=tempdef;
                        params_array(ivar).minval{params_array(ivar).noinstances}=tempmin;
                        params_array(ivar).maxval{params_array(ivar).noinstances}=tempmax;
                        params_array(ivar).required{params_array(ivar).noinstances}=temprequired;
                        params_array(ivar).allowed{params_array(ivar).noinstances}=tempallowed;
                        params_array(ivar).condition{params_array(ivar).noinstances}=tempcondition;
                        break
                    end
                end
            elseif (~isempty(tvn) && length(tvl)==2 && ~isempty(t21) && isempty(t22))
                % we have an allowednames = (/'var',etc./) line
                allowed={};
                templine = line(tvl(1)+1:tvl(2)-1);
                tvc=findstr(templine,',');
                if ~isempty(tvc)
                    nallowed = length(tvc)+1;
                    for ial=1:nallowed
                        switch ial
                            case 1
                                temp=strtrim(templine(1:tvc(ial)-1));
                            case nallowed
                                temp=strtrim(templine(tvc(ial-1)+1:end));
                            otherwise
                                temp=strtrim(templine(tvc(ial-1)+1:tvc(ial)-1));
                        end
                        temp(temp=='''')=[];
                        allowed{ial}=temp;
                    end
                else
                    allowed = {strtrim(line(tvl(1)+1:tvl(2)-1))};
                end
            % Conditional statements   
            elseif ~isempty(tif) && ~isempty(tthen)
                iflevel=iflevel+1;
                nowifcondition{iflevel} = ['(' line(4:end-5) ')'];  % we already know if and then are in correct positions
                nowifcondition{iflevel} = convertfort2mat(nowifcondition{iflevel});
                storeifcondition{iflevel} = nowifcondition{iflevel};
            elseif ~isempty(telseif) && ~isempty(tthen)
                nowifcondition{iflevel} = line(8:end-5);
                nowifcondition{iflevel} = convertfort2mat(nowifcondition{iflevel});
                storeifcondition{iflevel}=[storeifcondition{iflevel} ' & ' nowifcondition{iflevel}];
            elseif ~isempty(telse)
                nowifcondition{iflevel} = ['~(' storeifcondition{iflevel} ')'];
            elseif ~isempty(tendif)
                nowifcondition(iflevel)=[];
                storeifcondition(iflevel)=[];
                iflevel=iflevel-1;
            end
        end
        catch
        end
    end
    % make list of elements that affect current element
    affectedby=cell(length(params_array),1);
    for ii=1:length(params_array)
        affectedby{ii}='';
        for j=1:length(params_array(ii).condition)
            if isstr(params_array(ii).condition{j})
                affectedby{ii}=[affectedby{ii} ' ' params_array(ii).condition{j}];
            end
        end
        for j=1:length(params_array(ii).required)
            if isstr(params_array(ii).required{j})
                affectedby{ii}=[affectedby{ii} ' ' params_array(ii).required{j}];
            end
        end
        for j=1:length(params_array(ii).default)
            if isstr(params_array(ii).default{j})
                affectedby{ii}=[affectedby{ii} ' ' params_array(ii).default{j}];
            end
        end
        for j=1:length(params_array(ii).minval)
            if isstr(params_array(ii).minval{j})
                affectedby{ii}=[affectedby{ii} ' ' params_array(ii).minval{j}];
            end
        end
        for j=1:length(params_array(ii).maxval)
            if isstr(params_array(ii).maxval{j})
                affectedby{ii}=[affectedby{ii} ' ' params_array(ii).maxval{j}];
            end
        end
    end

    % find elements that listen to changes of current element
    for i=1:length(params_array)
        params_array(i).affects={};
        for ii=1:length(params_array)
            if regexp(affectedby{ii},[ '(^|\W)' params_array(i).name '(\W|$)'])
                params_array(i).affects{end+1}=params_array(ii).name;
            end
        end
    end

    for i=1:length(params_array)
        try
        names = fieldnames(params_array(i));
        for ii=1:length(names)
            if ~strcmp(names{ii},'name')
                eval(['params.' params_array(i).name '.' names{ii} '= params_array(i).' names{ii} ';']);
            end
        end
        catch
        end
    end

    fclose(fid);

    % store data
    matfile = fullfile(fileparts(which(mfilename)), 'params.mat');
    if ~exist(matfile, 'file'); save(matfile, '-mat', 'params', 'params_array'); end;

end

    function lineout = convertfort2mat(linein)
        lineout = linein;
        lineout = regexprep(lineout,'trim','');
        lineout = regexprep(lineout,'\.and\.',' & ');
        lineout = regexprep(lineout,'\.not\.',' ~ ');
        lineout = regexprep(lineout,'\.or\.',' | ');
        lineout = regexprep(lineout,'\.gt\.',' > ');
        lineout = regexprep(lineout,'\.ge\.',' >= ');
        lineout = regexprep(lineout,'\.lt\.',' < ');
        lineout = regexprep(lineout,'\.le\.',' <= ');
        lineout = regexprep(lineout,'par%','par.'); 
    end

    function lineout = parsestringtonumber(linein)
        lineout=linein;
        if ~isempty(findstr(lineout,'par%'))
            lineout=strtrim(lineout);
            lineout = regexprep(lineout,'par%','par.');
        else
            lineout=str2num(lineout);
        end
    end
        

end
