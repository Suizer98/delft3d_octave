function kngr_deleteFcn_DelftConStruct

global ontology session;

try
    session.vertices(:,3:end)=[];
    session = rmfield(session,'edgeHandles');
    session = rmfield(session,'edgeLabels');

    save([fileparts(which('DelftConStruct')) filesep 'lastsession.mat'],'session')
end
clear global ontology session