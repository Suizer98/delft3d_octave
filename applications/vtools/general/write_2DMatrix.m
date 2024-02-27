%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17699 $
%$Date: 2022-02-01 16:11:11 +0800 (Tue, 01 Feb 2022) $
%$Author: chavarri $
%$Id: write_2DMatrix.m 17699 2022-02-01 08:11:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/write_2DMatrix.m $
%
function write_2DMatrix(file_name,matrix,varargin)

%% SIZE

nx=size(matrix,2);
ny=size(matrix,1);

%% PARSE
parin=inputParser;

num_str_def=repmat('%0.15E ',1,nx);
addOptional(parin,'num_str',num_str_def);
addOptional(parin,'check_existing',1)

parse(parin,varargin{:});

num_str=parin.Results.num_str;
check_existing=parin.Results.check_existing;
% if isspace(num_str(end))==0
%     num_str=[num_str,' '];
% end

%% CALC

    %check if the file already exists
if exist(file_name,'file') && check_existing
    error('You are trying to overwrite a file!')
end

fileID_out=fopen(file_name,'w');
write_str_x=strcat(num_str,'\n'); %string to write in x

for ky=1:ny
    fprintf(fileID_out,write_str_x,matrix(ky,:));
end

fclose(fileID_out);

end %function
