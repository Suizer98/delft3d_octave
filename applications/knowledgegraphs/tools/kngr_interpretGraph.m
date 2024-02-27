function kngr_interpretGraph
% INTERPRETGRAPH
%
% Syntax:
% interpretGraph
%
% Input:
%
% Output:
%
% See also: findInRelations, findOutRelations, getOntology
 
%--------------------------------------------------------------------------------
% Copyright(c) Deltares 2004 - 2007  FOR INTERNAL USE ONLY
% Version:  Version 1.0, December 2007 (Version 1.0, June 2008)
% By:      <Mark van Koningsveld (email:mark.vankoningsveld@deltares.nl)>
%--------------------------------------------------------------------------------
 
%% initialise globals 
global session ontology;
ontology = kngr_getOntology;
maxiter  = 10;

%% find and interpret all out relations
id_focus = find(ismember(vertcat(session.vertices{:,3}),gco));
if ~isempty(id_focus)
    outgraph = [];
    [idIn, idOut, idOntology, edgeHandles] = kngr_findOutRelations(id_focus);
    outgraph = [outgraph;[idIn, idOut, idOntology, edgeHandles,ones(size(idIn))]];
end
if isempty(find(isnan(outgraph)))
    iter  = 0;
    while (~isempty(find(outgraph(:,5)==1))&&iter<maxiter)
        iter = iter + 1;
        id_next = find(outgraph(:,5)==1,1);
        outgraph(id_next,5)=0;
        if isempty(find(isnan(outgraph(id_next,:))))
            [idIn, idOut, idOntology, edgeHandles] = kngr_findOutRelations(outgraph(id_next,2));
            for i = 1: size(idIn,1)
                if ~isnan(edgeHandles(i))&&~ismember(edgeHandles(i),outgraph(outgraph(:,4)~=0,4))
                    outgraph = [outgraph;[idIn(i), idOut(i), idOntology(i), edgeHandles(i), 1]];
                end
            end
        end
    end
    %% cleanup outgraph
    ids = ones(size(outgraph,1),1);
    for i = 1:size(outgraph,1)
        id = find(outgraph(:,2)==outgraph(i,1) & outgraph(:,1)==outgraph(i,2));
        if ~isempty(id)&&ids(i)==1
            ids(id)=0;
        end
    end
    outgraph=outgraph(ids==1,:);    %     set(outgraph(outgraph(:,3)~=0,3),'linewidth',4);
else
    clear outgraph
end

%% find and interpret all in relations
id_focus = find(ismember(vertcat(session.vertices{:,3}),gco));
if ~isempty(id_focus)
    ingraph = [];
    [idIn, idOut, idOntology, edgeHandles] = kngr_findInRelations(id_focus);
    ingraph = [ingraph;[idIn, idOut, idOntology, edgeHandles,ones(size(idIn))]];
end
if isempty(find(isnan(ingraph)))
    iter  = 0;
    while (~isempty(find(ingraph(:,5)==1))&&iter<maxiter)
        iter = iter + 1;
        id_next = find(ingraph(:,5)==1,1);
        ingraph(id_next,5)=0;
        if isempty(find(isnan(ingraph(id_next,:))))
            [idIn, idOut, idOntology, edgeHandles] = kngr_findInRelations(ingraph(id_next,1));
            for i = 1: size(idIn,1)
                if ~isnan(edgeHandles(i))&&~ismember(edgeHandles(i),ingraph(ingraph(:,4)~=0,4))
                    ingraph = [ingraph;[idIn(i), idOut(i), idOntology(i), edgeHandles(i), 1]];
                end
            end
        end
    end
    %% cleanup ingraph
    ids = ones(size(ingraph,1),1);
    for i = 1:size(ingraph,1)
        id = find(ingraph(:,2)==ingraph(i,1) & ingraph(:,1)==ingraph(i,2));
        if ~isempty(id)&&ids(i)==1
            ids(id)=0;
        end
    end
    ingraph=ingraph(ids==1,:);    %     set(ingraph(ingraph(:,3)~=0,3),'linewidth',4);
else
    clear ingraph
end

%% put info in gui
if exist('outgraph','var')
    set(findobj('Tag','txtout'), 'string', kngr_graph2text(outgraph,1));
else
    set(findobj('Tag','txtout'), 'string', '');
end
if exist('ingraph','var')
    set(findobj('Tag','txtin'), 'string', kngr_graph2text(ingraph,2));
else
    set(findobj('Tag','txtin'), 'string', '');
end
set(findobj('Tag','txtDic'), 'string', '');