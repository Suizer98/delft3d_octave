function [type, graph, txt, ids_previous, level_previous] = getNextLayers(type, graph, txt, ids_previous, level_previous)

%% initialise globals
global session ontology;

%% add next layers of text to txt for ...
switch type
    case 1 % ... outward relations, and ...
        for i = 1:size(ids_previous,1)
            graph(ids_previous(i),5) = level_previous;
        end

        for i = 1:size(ids_previous,1)
            if graph(ids_previous(i),5) == 1
                if  i == 1
                    txt = ['In this graph "' session.vertices{graph(ids_previous(i),1)} '"' ' is someTHING' char(13)];
                    coupletxt = [kngr_getIndent(level_previous) 'THAT'];
                    txt = [txt '(' num2str(graph(ids_previous(i),5)) ')' coupletxt ontology(graph(ids_previous(i),3)).txtout '"' session.vertices{graph(ids_previous(i),2)} '"' char(13)];
                else
                    coupletxt = [kngr_getIndent(level_previous) 'AND THAT'];
                    txt = [txt '(' num2str(graph(ids_previous(i),5)) ')' coupletxt ontology(graph(ids_previous(i),3)).txtout '"' session.vertices{graph(ids_previous(i),2)} '"' char(13)];
                end
            else
                if  i == 1
                    coupletxt = [kngr_getIndent(level_previous) 'THAT'];
                    txt = [txt '(' num2str(graph(ids_previous(i),5)) ')' coupletxt ontology(graph(ids_previous(i),3)).txtout '"' session.vertices{graph(ids_previous(i),2)} '"' char(13)];
                else
                    coupletxt = [kngr_getIndent(level_previous) 'AND THAT'];
                    txt = [txt '(' num2str(graph(ids_previous(i),5)) ')' coupletxt ontology(graph(ids_previous(i),3)).txtout '"' session.vertices{graph(ids_previous(i),2)} '"' char(13)];
                end
            end
            ids_nextprevious    = find(graph(:,1)==graph(ids_previous(i),2) & graph(:,5)== 0);
            level_nextprevious = level_previous + 1;
            if ~isempty(ids_nextprevious)
                [type, graph, txt] = kngr_getNextLayers(type, graph, txt, ids_nextprevious, level_nextprevious);
            end
        end

    case 2 % ... inward relations.

        for i = 1:size(ids_previous,1)
            graph(ids_previous(i),5) = level_previous;
        end

        for i = 1:size(ids_previous,1)
            if graph(ids_previous(i),5) == 1
                if  i == 1
                    txt = ['In this graph "' session.vertices{graph(ids_previous(i),2)} '"'  ' is someTHING' char(13)];
                    coupletxt = [kngr_getIndent(level_previous) 'THAT'];
                    txt = [txt '(' num2str(graph(ids_previous(i),5)) ')' coupletxt ontology(graph(ids_previous(i),3)).txtin '"' session.vertices{graph(ids_previous(i),1)} '"' char(13)];
                else
                    coupletxt = [kngr_getIndent(level_previous) 'AND THAT'];
                    txt = [txt '(' num2str(graph(ids_previous(i),5)) ')' coupletxt ontology(graph(ids_previous(i),3)).txtin '"' session.vertices{graph(ids_previous(i),1)} '"' char(13)];
                end
            else
                if  i == 1
                    coupletxt = [kngr_getIndent(level_previous) 'THAT'];
                    txt = [txt '(' num2str(graph(ids_previous(i),5)) ')' coupletxt ontology(graph(ids_previous(i),3)).txtin '"' session.vertices{graph(ids_previous(i),1)} '"' char(13)];
                else
                    coupletxt = [kngr_getIndent(level_previous) 'AND THAT'];
                    txt = [txt '(' num2str(graph(ids_previous(i),5)) ')' coupletxt ontology(graph(ids_previous(i),3)).txtin '"' session.vertices{graph(ids_previous(i),1)} '"' char(13)];
                end
            end

            ids_nextprevious   = find(graph(:,2)==graph(ids_previous(i),1) & graph(:,5)== 0);
            level_nextprevious = level_previous + 1;
            if ~isempty(ids_nextprevious)
                [type, graph, txt] = kngr_getNextLayers(type, graph, txt, ids_nextprevious, level_nextprevious);
            end
        end
end