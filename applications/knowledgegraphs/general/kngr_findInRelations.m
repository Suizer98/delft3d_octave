function [idIn, idOut, idOntology, edgeHandles] = findInRelations(id_focus)

%% initialise globals
global session
idOntology = nan;
[idfrom,idto]=find(session.edges);

%% find all in relations
idIn = idfrom(find(idto == id_focus));
if ~isempty(idIn)
    idOut  = ones(size(idIn))*id_focus;
    clear edgeHandles
    for i = 1:size(idIn,1)
        idOntology(i,1) = session.edges(idIn(i),idOut(i));
        edgeHandles(i,1)= session.edgeHandles(idIn(i),idOut(i));
    end
else
    idIn = nan;
    idOut = id_focus;
    edgeHandles = nan;
end