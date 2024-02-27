% this is a very simple routine that imports InfoStruct session files and converts them
% to DelftConstruct sessionfiles.

% clear all;close all
path = 'D:\WL Projecten\WL Software\InfoStruct\Data2\';
name = 'zeegras';

clear global session
global session
addpath('F:\McTools\mc_toolbox\mc_general\mc_stringroutines\');

cntr=0;
fid = fopen([path name '.vtx']);
while ~feof(fid);
    line = fgetl(fid);
    if length(line)~=0
        cntr=cntr+1;
        result = parseStringOnToken(line,',');
        session.vertices{cntr,1} = result{1};
        session.vertices{cntr,2} = [str2num(result{3})/50 str2num(result{4})/50];
    end
end

edges = load([path name '.edg']);
session.edges = sparse(edges)


cla;plotGraph(gcf)
