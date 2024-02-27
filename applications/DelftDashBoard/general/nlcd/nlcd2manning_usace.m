function manning=nlcd2manning_usace(A)
% Convert NLCD land cover values to Manning's n

manning = NaN(size(A));
idfind = A == 0;         manning(idfind) = 0.030;
idfind = A == 1;         manning(idfind) = 0.020;
idfind = A == 10;        manning(idfind) = 0.080;
idfind = A == 2;         manning(idfind) = 0.030;
idfind = A == 21;        manning(idfind) = 10.00;
idfind = A == 3;         manning(idfind) = 0.180;
idfind = A == 4;         manning(idfind) = 0.160;
idfind = A == 5;         manning(idfind) = 0.060;
idfind = A == 6;         manning(idfind) = 0.040;
idfind = A == 7;         manning(idfind) = 0.250;
idfind = A == 8;         manning(idfind) = 0.220;
idfind = A == 9;         manning(idfind) = 0.170;
idfind = isnan(manning); manning(idfind) = 0.023;
