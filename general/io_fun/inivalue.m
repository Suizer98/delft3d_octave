function varargout=inivalue(fileName,varargin)
%INIVALUE   load key, section or entire contents of *.ini keyword file
%
%    keyValue      = inivalue(fileName, sectionName, keyName)
%    sectionValues = inivalue(fileName, sectionName)
%    fileValues    = inivalue(fileName)
%
% reads values of one keyName, one sectionName or entire file from fileName.
% 
% Example: a sample *.ini file (sample.ini) may have entries:
%
%    +------------
%    |  [XYZ]
%    |  abc = 123
%    |  [ZZZ]
%    |  abc = 890
%    +-------------
%
%    inivalue('sample.ini','XYZ','abc') -> '123' 
%    inivalue('sample.ini','ZZZ','abc') -> '890' 
%
%    inivalue('sample.ini','ZZZ')       ->  ans.abc=123
%    inivalue('sample.ini','ZZZ')       ->  ans.abc=890
%
%    inivalue('sample.ini')             ->  ans.XYZ.abc=123
%                                           ans.ZZZ.abc=890
%
% * if sectionName or the keyName is not found, it returns []
% * if the keyName is empty, the entire section is returned as struct.
% * if the sectionName is empty, the entire file is returned as struct.
% * if the sectionName is NaN, the entire file is returned as struct.
%      and no sectionName is assumed to be present at all in the file
%
% Note that a *.url file is has the *.ini file format.
% Optionally a struct with field 'commentchar' can be passed to skip comment lines.
%
%See also: textread, setproperty, xml_read, xml_load, inifile

% Based on code fragments from: http://www.mathworks.com/matlabcentral/fileexchange/5182-ini-file-reading-utility
% Created By: Irtaza Barlas
% Created On: June 9, 2004
% Created For: IAS Inc.

OPT.commentchar = '';

fid = 0;
jv = -1;

sectionName = [];
keyName     = [];

if nargin > 1; 
    if isstruct(varargin{1})
       OPT = setproperty(OPT,varargin{1});
    else
      sectionName = varargin{1};
    end
end

if nargin > 2; 
    if isstruct(varargin{2})
       OPT = setproperty(OPT,varargin{2});
    else
      keyName = varargin{2};
    end
end

if nargin > 3; 
    if isstruct(varargin{3})
       OPT = setproperty(OPT,varargin{3});
    else
       error('');
    end
end

if exist(fileName) ~= 2 
    error(['file finding file: ', fileName]);
end;

fid = fopen(fileName);
if fid<=0
    error(['file opening file: ', fileName]);
    floce(fid)
end;
   
if ~isnan(sectionName)
sectionString = ['[' sectionName ']'];
else
sectionString = ['['  ']'];
end
sectionFound  = 0;
rec           = fgetl_no_comment_line(fid,OPT.commentchar);

while sectionFound~=1

    if isempty(rec)
        rec = fgetl_no_comment_line(fid,OPT.commentchar);
        continue;
    elseif rec==-1
        break;
    end;

    if isempty(sectionName)| isnan(sectionName) | strcmp(strtrim(rec), sectionString) > 0 % allow leading spaces

        if isempty(sectionName)
            i0=find(rec=='[');
            i1=find(rec==']');
            section = rec(i0+1:i1-1);
            rec          = fgetl_no_comment_line(fid,OPT.commentchar);
        elseif isnan(sectionName)
            section = '';
        else
            section = sectionName;
            rec          = fgetl_no_comment_line(fid,OPT.commentchar);
        end
        
        %% look for the key

        sectionFound = 1;
        keyFound     = 0;

        while keyFound==0

            if isempty(rec)==1
                rec = fgetl_no_comment_line(fid,OPT.commentchar);
                continue;
            end;
            if rec==-1 % EOF
                break;
            end;
            if isempty(strtrim(rec)) == 0 
                rec = strtrim(sscanf(rec, '%c')); % keep all whitespaces except leading and trailing
                if rec(1)=='[' % next section                   
                    break;
                end;

                %% look for the value

                eq_idx=find(rec=='=');
                if ~isempty(eq_idx) %~=1 & eq_idx(1)>1 
                    key=strtrim(rec(1:eq_idx(1)-1));
                    if isempty(keyName) | strcmp(key, keyName)>0 
                        [rs, cs]=size(rec);
                        if eq_idx(1)>=cs
                            keyValue = '';
                        else
                            keyValue=strtrim(rec(eq_idx(1)+1:end));
                        end;
                        if strcmp(key, keyName)>0 
                            keyFound = 1;
                            out      = keyValue;
                            break;
                        else
                            if isempty(sectionName)
                                out.(mkvar(section)).(mkvar(key)) = keyValue; % in case section name has spaces etc. use mkvar()
                            else
                                out.(mkvar(key)) = keyValue;
                            end
                        end

                    end;
                end;               
            end;

            rec = fgetl_no_comment_line(fid,OPT.commentchar);
            if rec==-1
                break
            end

            rec = strtrim(sscanf(rec, '%c')); % keep all whitespaces except leading and trailing

            if ~isempty(rec)
                if rec(1)=='[' % next section                   

                    if isempty(sectionName)
                        i0=find(rec=='[');
                        i1=find(rec==']');
                        section = rec(i0+1:i1-1);
                    else
                        section = sectionName;
                    end
                    
                    jv = jv+1;
                    section = [section num2str(jv)];

                    rec = fgetl_no_comment_line(fid,OPT.commentchar);

                end
            else
                break
            end

        end; % keyFound
        break;
    end; % sectionString
    rec = fgetl_no_comment_line(fid,OPT.commentchar);
end; % sectionFound
fclose(fid);
varargout = {out};
