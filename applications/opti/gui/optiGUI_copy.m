function optiGUI_copy;

[but,fig]=gcbo;

this=get(fig,'userdata');

oldPat=pwd;
cd('Y:\app\MatlabR13\toolbox\matlab\uitools\');%because in wl-tools is also a clipboard function, which we won't use.
info=get(findobj(fig,'tag','condBox'),'string');
info(:,end+1)=char(13);
[dum,weights]=strread(info','%s %s','delimiter',':');
clipboard('copy',str2num(char(weights))');
cd(oldPat);
