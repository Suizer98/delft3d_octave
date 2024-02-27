function manning=nlcd2manning(A)
% Convert NLCD land cover values to Manning's n

manning = NaN(size(A));
idfind = A == 11;         manning(idfind) = 0.023;
idfind = A == 21;         manning(idfind) = 0.070;
idfind = A == 22;         manning(idfind) = 0.100;
idfind = A == 23;         manning(idfind) = 0.120;
idfind = A == 24;         manning(idfind) = 0.140;
idfind = A == 31;         manning(idfind) = 0.070;
idfind = A == 41;         manning(idfind) = 0.120;
idfind = A == 42;         manning(idfind) = 0.150;
idfind = A == 43;         manning(idfind) = 0.120;
idfind = A == 52;         manning(idfind) = 0.050;
idfind = A == 71;         manning(idfind) = 0.034;
idfind = A == 81;         manning(idfind) = 0.030;
idfind = A == 82;         manning(idfind) = 0.035;
idfind = A == 90;         manning(idfind) = 0.100;
idfind = A == 95;         manning(idfind) = 0.035;
idfind = isnan(manning);  manning(idfind) = 0.023;
