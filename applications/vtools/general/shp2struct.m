%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18457 $
%$Date: 2022-10-17 20:32:45 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: shp2struct.m 18457 2022-10-17 12:32:45Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/shp2struct.m $
%
%I do not know who made this function first but I guess Bert Jaggers. I have
%adapted it a bit. 
%
%convert a shape file to a struct. 

function [outputvar] = shp2struct(fpath,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'read_val',false);
addOptional(parin,'xy_only',false);

parse(parin,varargin{:});

read_val=parin.Results.read_val;
xy_only=parin.Results.xy_only;

%% CALC

if exist(fpath,'file')~=2
    error('file does not exist: %s',fpath)
end
SHP=qpfopen(fpath);
Q=qpread(SHP);
objstr = {Q.Name};
outputvar.xy=qpread(SHP,objstr{1},'griddata');
if read_val
    for i=2:length(objstr)
      outputvar.val{i-1}=qpread(SHP,objstr{i},'data');
    end
end

if xy_only
    aux=polcell2nan(outputvar.xy.XY);
    outputvar=aux(:,1:2);
end

end %function