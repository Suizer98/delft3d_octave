function Out = delwaq_res(cmd,varargin)
%DELWAQ_RES Read/write Delwaq restar files.
%
%   Struct = DELWAQ_RES('read','FileName',NSubstance,T0)
%   reads the all substance and all segments at specified time step
%   from the Delwaq *.RES binary file.
%   <NSubstance> is the total number of substances in the file. If the name
%   of the file containing the substances ('substances.nam') is provided,
%   then delwaq_res will read the file and find the number of sustances.
%   <T0> (OPTIONAL) is the time reference 
%
%   Struct = DELWAQ_RES('write','FileName',Data,Time)
%   writes the data to a Delwaq RES file. The size of
%   Data is matrix [NSubstance x NSegment]
%   <Time> (OPTIONAL) is the time in seconds after <T0>
%   if <Time> is not available then Time=0
%
%   Struct = DELWAQ_RES('write','FileName',Struct)
%   writes the data to a Delwaq RES file. 
%   Struct is the output of Struct = DELWAQ_RES('read','...)

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Jul-12 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------

switch cmd
    case 'read'
        Out = delwaq_res_read(varargin{:});
    case 'write'
        Out = delwaq_res_write(varargin{:});
    otherwise
        error(['Unknown command: ' cmd])
end

function S = delwaq_res_read(FileName,NSubstance, T0)

S = initial_S;
S.FileName = FileName;
fid = fopen(FileName,'r');
if fid<0
    return
end
if ischar(NSubstance) && exist(NSubstance,'file')
   Subs = read_subsName(NSubstance);
   NSubstance = length(Subs);
else
    for i = 1:NSubstance
        Subs{i} = ['Sub' num2str(i, '%03.0f')];  %#ok<AGROW>
    end
end

fseek(fid,0,1);
S.NBytesBlock = ftell(fid);
S.NumSegm = ((S.NBytesBlock-4)/4)/NSubstance;
S.SubsName = Subs;
S.NumSubs = NSubstance;
fseek(fid,0,-1);
S.Time = fread(fid,[1 1],'uint32');

if nargin == 3
   S.T0 = T0;
   S.Date = S.T0 + (S.Time/(24*60*60));
end
S.data = fread(fid,[S.NumSubs S.NumSegm],'real*4');
fclose(fid);
S.Check = 'OK';

function S = delwaq_res_write(varargin)

if nargin == 2 && isstruct(varargin{2})
   S = varargin{2};
   S.FileName = varargin{1};
else
   S = initial_S;
   S.FileName = varargin{1};
   S.data = varargin{2};
   if nargin==3 && ~isempty(varargin{3})
      S.Time = varargin{3};
   else
      S.Time = 0;
   end      
   [S.NumSubs, S.NumSegm] =  size(S.data);
   S.NBytesBlock = (S.NumSubs * S.NumSegm*4) + 4;
end
   
fid = fopen(S.FileName,'w+');
if fid<0
    return
end
fseek(fid,0,-1);
fwrite(fid,S.Time,'uint32');
fwrite(fid,S.data,'real*4');
fclose(fid);
S.Check = 'OK';

function Subs = read_subsName(FileName)

inpData = importdata(FileName,' ', 1000);   

on1 = 0;
for iline = 1:size(inpData,1)
    if on1
       local = inpData{iline,:};
       index = find(ismember(local,''''));
       Subs{k} = local(index(1)+1:index(2)-1); %#ok<AGROW>
       k = k+1;
    else
        k1 = strfind(inpData{iline,:}, 'Index');
        if ~isempty(k1)
            on1 = 1;
            k = 1;
        end
    end
end

function S =  initial_S
S.Check = 'NotOK';
S.FileType = 'DelwaqRES';
S.FileName = [];
S.FormatType = 'binary';
S.T0 = [];
S.NBytesBlock = [];
S.NumSegm = [];
S.NumSubs = [];
S.SubsName = [];
S.Time = [];
S.NTimes = 1;
S.Date = [];
S.dataRow = 'NumSubs';
S.dataColumn = 'NumSegm';
S.data = [];