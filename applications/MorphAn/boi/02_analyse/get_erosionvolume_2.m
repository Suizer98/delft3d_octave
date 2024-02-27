function dVero = compute_Vero(x,zi,ze,maxWL) 
    dz = max(ze, maxWL)-zi;
    dA = [diff(x);0].*dz;
    dVero = sum(dA(dA<0)) * -1; %m3/m
end