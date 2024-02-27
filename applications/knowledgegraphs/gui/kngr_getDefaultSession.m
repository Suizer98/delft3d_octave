function kngr_getDefaultSession

global session %#ok<NUSED>

try % default session should be the last used session file
    load([fileparts(which('knowledgegraphs')) filesep 'lastsession.mat']);
catch % or a very basic default session
    kngr_addRelation('Felix'   ,'name'   ,3) % ali
    kngr_addRelation('name'    ,'cat'    ,4) % par
    kngr_addRelation('cat'     ,'animal' ,2) % sub
end