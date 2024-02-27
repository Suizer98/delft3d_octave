function string_mn = nesthd_convertmn2string(m,n)

% convertmn2string: converts set of m,n coordinates to a (stationname) string

string = '(M,N) = (????,????)';
for i_pnt = 1: length(m)
    string_mn{i_pnt} = string;
    string_mn{i_pnt}(10:13) = sprintf('%4i',m(i_pnt));
    string_mn{i_pnt}(15:18) = sprintf('%4i',n(i_pnt));
end
