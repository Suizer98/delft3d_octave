function txt = kngr_graph2text(graph, type)
% type 1 concerns inward relations
% type 2 concerns outward relations

switch type
    case 1 % type 1 concerns inward relations
        txt=[];
        ids_previous   = find(graph(:,1)==graph(1,1));
        level_previous = 1;
        [type, graph, txt] = kngr_getNextLayers(type, graph, txt, ids_previous, level_previous);
    case 2% type 2 concerns outward relations
        txt=[];
        ids_previous = find(graph(:,2)==graph(1,2));
        level_previous = 1;
        [type, graph, txt] = kngr_getNextLayers(type, graph, txt, ids_previous, level_previous);
end