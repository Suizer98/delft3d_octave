function optiGUI_save

[but,fig]=gcbo;

this=get(fig,'userdata');
[namS,patS]=uiputfile('*.mat','Save opti structure to');
save([patS filesep namS],'this');