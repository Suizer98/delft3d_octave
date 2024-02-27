function C = intersect_lines(A,B)
% intersect line segments A and B, where A and B may be vectors, and
%   compute weight factors for interpolation
%
% C = intersect_lines(A,B)
%
% Similar to DFLOW-FM's CROSSinbox
%
% input: A.x1, A.y1: (vector of) coordinates of startpoint of line segment A
%        A.x2, A.y1: (vector of) coordinates of endpoint   of line segment A
%        B.x1, B.y1: (vector of) coordinates of startpoint of line segment B
%        B.x2, B.y1: (vector of) coordinates of endpoint   of line segment B
%
% output: C.x, C.y: coordinates of intersection point(s)
%         C.n:      number of intersections
%         C.idxA:   indices of linesegments A that are intersected by linesegments B
%         C.idxB:   indices of linesegments B that are intersected by linesegments A
%         C.alpha:  weight factor: relative distance from startpoint of line segment A to intersection point (in [0,1])
%                   A.x1(idxB) + C.beta .* ( A.x2(C.idxB)-A.x1(C.idxB)) = C.x
%                   A.y1(idxB) + C.beta .* ( A.y2(C.idxB)-A.y1(C.idxB)) = C.y
%         C.beta:   weight factor: relative distance from startpoint of line segment B to intersection point  (in [0,1])
%                   B.x1(idxB) + C.beta .* ( B.x2(C.idxB)-B.x1(C.idxB)) = C.x
%                   B.y1(idxB) + C.beta .* ( B.y2(C.idxB)-B.y1(C.idxB)) = C.y

% get vector lenghts
NA = length(A.x1);
NB = length(B.x1);

% get the bounding boxes
A.xmin = min(A.x1,A.x2);
A.xmax = max(A.x1,A.x2);
A.ymin = min(A.y1,A.y2);
A.ymax = max(A.y1,A.y2);

B.xmin = min(B.x1,B.x2);
B.xmax = max(B.x1,B.x2);
B.ymin = min(B.y1,B.y2);
B.ymax = max(B.y1,B.y2);

% patch([A.xmin; A.xmin; A.xmax; A.xmax], [A.ymax; A.ymin; A.ymin; A.ymax], 0, 'FaceColor', 'None')
% patch([B.xmin; B.xmin; B.xmax; B.xmax], [B.ymax; B.ymin; B.ymin; B.ymax], 0, 'FaceColor', 'None')

% find canditate combinations for intersection
[i,j] = find(   ...
    repmat(reshape(A.xmin,NA,1),1,NB) <= repmat(reshape(B.xmax,1,NB),NA,1) &    ...
    repmat(reshape(A.xmax,NA,1),1,NB) >= repmat(reshape(B.xmin,1,NB),NA,1) &    ...
    repmat(reshape(A.ymin,NA,1),1,NB) <= repmat(reshape(B.ymax,1,NB),NA,1) &    ...
repmat(reshape(A.ymax,NA,1),1,NB) >= repmat(reshape(B.ymin,1,NB),NA,1));

shape = find(size(A.x1)==1 & size(B.x1==1));
if shape ~= [1 2] 
    switch ( shape )
        case 1
            i = reshape(i,1,[]);
            j = reshape(j,1,[]);
        case 2
            i = reshape(i,[],1);
            j = reshape(j,[],1);
    end
end
det   = ( (A.x2(i)-A.x1(i)).*(B.y2(j)-B.y1(j)) - (A.y2(i)-A.y1(i)).*(B.x2(j)-B.x1(j)) );
alpha = ( (B.x1(j)-A.x1(i)).*(B.y2(j)-B.y1(j)) - (B.y1(j)-A.y1(i)).*(B.x2(j)-B.x1(j)) ) ./ det;
beta  = ( (B.x1(j)-A.x1(i)).*(A.y2(i)-A.y1(i)) - (B.y1(j)-A.y1(i)).*(A.x2(i)-A.x1(i)) ) ./ det;

idx = find(alpha>=0 & alpha<=1 & beta>=0 & beta<=1);

C.n    = length(idx);
C.idxA = i(idx);
C.idxB = j(idx);
C.x  = A.x1(C.idxA) + alpha(idx).*(A.x2(C.idxA)-A.x1(C.idxA));
C.y  = A.y1(C.idxA) + alpha(idx).*(A.y2(C.idxA)-A.y1(C.idxA));
C.alpha = alpha(idx);
C.beta  = beta(idx);
% 
% hold on
% plot([A.x1(C.idxA); A.x2(C.idxA)], [A.y1(C.idxA); A.y2(C.idxA)], 'r', [B.x1(C.idxB); B.x2(C.idxB)], [B.y1(C.idxB); B.y2(C.idxB)], 'b', 'LineWidth',2);
% hold on
% plot(C.x, C.y, 'o');
% hold off