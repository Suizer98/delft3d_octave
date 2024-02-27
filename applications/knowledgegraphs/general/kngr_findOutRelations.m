function [idIn, idOut, idOntology, edgeHandles] = kngr_findOutRelations(id_focus)

%% initialize globals
global session
idOntology = nan;
[idfrom, idto]=find(session.edges);

%% find all out relations
idOut = idto(find(idfrom == id_focus));
if ~isempty(idOut)
    idIn  = ones(size(idOut))*id_focus;
    clear edgeHandles
    for i = 1:size(idOut,1)
        idOntology(i,1) = session.edges(idIn(i),idOut(i));
        edgeHandles(i,1)= session.edgeHandles(id_focus,idOut(i));
    end
else
    idIn = id_focus;
    idOut = nan;
    edgeHandles = nan;
end