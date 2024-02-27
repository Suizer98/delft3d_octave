function [Z] = gridFcn(x,y,z,X,Y)
   F = TriScatteredInterp(x,y,z);
   Z= F(X,Y);
end