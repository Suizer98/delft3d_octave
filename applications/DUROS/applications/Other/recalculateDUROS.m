function [resultnewcalc messages] = recalculateDUROS(figname,varargin)
% Recalculates a getDuneErosion result from a figure.



if ~exist(figname,'file')
    return
end
[pt nm ext] = fileparts(figname);
if ~strcmp(ext,'.fig')
    return
end

h = open(figname);
ax = findobj(h,'Type','axes');
ax(strcmp(get(ax,'Tag'),'legend'))=[];

result = get(ax,'UserData');

xInitial = cat(1,...
    result(1).xLand,...
    result(1).xActive,...
    result(1).xSea);
zInitial = cat(1,...
    result(1).zLand,...
    result(1).zActive,...
    result(1).zSea);
Hs = result(1).info.input.Hsig_t;
Tp = result(1).info.input.Tp_t;
D50 = result(1).info.input.D50;
WL = result(1).info.input.WL_t;

if nargin>1
    DuneErosionSettings(varargin{:});
end

[resultnewcalc, messages] = getDuneErosion(xInitial, zInitial, D50, WL, Hs, Tp);

plotDuneErosion(resultnewcalc,figure)