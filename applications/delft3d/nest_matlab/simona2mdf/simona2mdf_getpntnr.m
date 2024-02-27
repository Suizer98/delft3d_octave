function pnt = simona2mdf_area(list,nr)

% simona2mdf_getpntnr : gets the point (squence) number out of a list of points/curves

pnt = [];

for ipnt = 1: length(list)
    if list(ipnt).SEQNR == nr
        pnt = ipnt;
        break;
    end
end
