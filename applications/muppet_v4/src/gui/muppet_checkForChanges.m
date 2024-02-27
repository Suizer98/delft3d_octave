function changed=muppet_checkForChanges

changed=0;

fig=getappdata(gcf,'figure');
if fig.changed
    changed=1;
end
