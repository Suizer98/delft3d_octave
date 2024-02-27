function G3=mergeNets(G1,G2)
%writeNet   Merge 2 networks read by dflowfm.readNet
%
% Example 1:
%
%
disp(1);

%[~,ia,ic] = unique_rows_tolerance([[G1.node.x;G1.node.y].';[G2.node.x;G2.node.y].'],1e-7,'rows'); 
[~,ia,ic] = unique([[G1.node.x;G1.node.y].';[G2.node.x;G2.node.y].'],'rows'); 

[ic2,ia2] = sort(ic);
idx = find(diff(ic2) == 0); 

overlap_nodes = [ia2(idx),ia2(idx+1)];

G3 = G1; 
G3.node.x = [G1.node.x, G2.node.x];
G3.node.y = [G1.node.y, G2.node.y];
G3.node.x(overlap_nodes(:,2)) = NaN; 
G3.node.y(overlap_nodes(:,2)) = NaN; 
if isfield (G1.node, 'z'); 
    G3.node.z = [G1.node.z, G2.node.z];
    G3.node.z(overlap_nodes(:,2)) = NaN; 
end
G3.node.n = length(find(~isnan(G3.node.x))); 

G3.edge.NetLink = [G1.edge.NetLink, G2.edge.NetLink+G1.node.n]; 
G3.edge.NetLinkType = [G1.edge.NetLinkType, G2.edge.NetLinkType]; 

for j = 1:length(overlap_nodes); 
    G3.edge.NetLink(G3.edge.NetLink == overlap_nodes(j,2)) = overlap_nodes(j,1);
end
G3.edge.NetLink = [min(G3.edge.NetLink);max(G3.edge.NetLink)];
[~,ia,ic] = unique(G3.edge.NetLink.', 'rows'); 

G3.edge.NetLink = G3.edge.NetLink(:, ia); 
G3.edge.NetLinkType = G3.edge.NetLinkType(ia); 
G3.edge.NetLinkSize = length(G3.edge.NetLinkType);

mapping = unique(G3.edge.NetLink(:)); 
%[[1:length(mapping)].', mapping]
node_mapping=[mapping,[1:length(mapping)].'];

G3.node.x = G3.node.x(mapping); 
G3.node.y = G3.node.y(mapping); 
if isfield (G1.node, 'z'); 
    G3.node.z = G3.node.z(mapping); 
end

for k = 1:length(node_mapping); 
    G3.edge.NetLink(G3.edge.NetLink == node_mapping(k,1)) = node_mapping(k,2);
end

pause(1);
%%



