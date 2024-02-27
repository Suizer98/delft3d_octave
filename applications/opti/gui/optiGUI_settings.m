function optiGUI_settings

[but,fig]=gcbo;

this=get(fig,'userdata');

sets=this.optiSettings;

defAns={num2str(sets.maxIter),sets.method,sets.transectInterpMethod,num2str(sets.scaleTol)};
prompt={'Number of iterations','Opti method','Transect interpolation method','Scale tolerance'};
newSets=inputdlg(prompt,'Opti settings',1,defAns);
if isempty(newSets)
    return
end
this.optiSettings.maxIter=str2num(newSets{1});
this.optiSettings.method=newSets{2};
this.optiSettings.transectInterpMethod=newSets{3};
this.optiSettings.scaleTol=str2num(newSets{4});
set(fig,'userdata',this);