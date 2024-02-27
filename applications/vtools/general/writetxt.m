%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17184 $
%$Date: 2021-04-14 20:53:36 +0800 (Wed, 14 Apr 2021) $
%$Author: chavarri $
%$Id: writetxt.m 17184 2021-04-14 12:53:36Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/writetxt.m $
%
function writetxt(file_name,data,varargin)

%% PARSE

parin=inputParser;

inp.check_existing.default=true;
addOptional(parin,'check_existing',inp.check_existing.default)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%% CALC

%check if the file already exists
if check_existing && exist(file_name,'file')>0
    error('You are trying to overwrite a file!')
end

fileID_out=fopen(file_name,'w');
for kl=1:numel(data)
%     fprintf(fileID_out,'%s \n',data{kl,1});
    fprintf(fileID_out,'%s\r\n',data{kl,1});
end

messageOut(NaN,sprintf('file written %s',file_name));
fclose(fileID_out);
