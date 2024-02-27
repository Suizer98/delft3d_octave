function Hsig_t = getHsfromTable(WL_t, Pexc)

data = load('D:\My Documents\PhD project\Prob2B\ParametricStudy\conditionele kans Hs\Hoek van Holland.dat');


column = min(find(data(1,:)>WL_t));

row = min(find(data(2:end,column)>1-Pexc));

datared = data([1 row-1:row+1], column-1:column);

for i = 2:size(datared,1)
    P(i-1,1) = interp1(datared(1,:), datared(i,:), WL_t); %#ok<AGROW>
end

Hsig_t = interp1(P, data(row-1:row+1,1), 1-Pexc);
% Hsig_told = data(row,1);