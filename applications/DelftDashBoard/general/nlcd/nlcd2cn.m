function cn=nlcd2cn(A,soiltype)

cn=zeros(size(A));
cn(cn==0)=NaN;

switch lower(soiltype)
    case{'a'}
        nr=1;
    case{'b'}
        nr=2;
    case{'c'}
        nr=3;
    case{'d'}
        nr=4;
end

% Convert NLCD land cover values to Manning's n
tbl( 1,:)=[11  100 100 100 100];
tbl( 2,:)=[12  NaN NaN NaN NaN];
tbl( 3,:)=[21   52  68  78  84];
tbl( 4,:)=[22   81  88  90  93];
tbl( 5,:)=[23   84  89  93  94];
tbl( 6,:)=[24   88  92  93  94];
tbl( 7,:)=[31   70  81  88  92];
tbl( 8,:)=[41  NaN NaN NaN NaN];
tbl( 9,:)=[42  NaN NaN NaN NaN];
tbl(10,:)=[43  NaN NaN NaN NaN];
tbl(11,:)=[51  NaN  42  52  62];
tbl(12,:)=[52  NaN  42  52  62];
tbl(13,:)=[71  NaN  63  75  85];
tbl(14,:)=[72  NaN  63  75  85];
tbl(15,:)=[73   74  74  74  74];
tbl(16,:)=[74   79  79  79  79];
tbl(17,:)=[81   40  61  73  79];
tbl(18,:)=[82   62  74  82  86];
tbl(19,:)=[90   86  86  86  86];
tbl(20,:)=[95   80  80  80  80];

for it=1:size(tbl,1)
    idfind = A == tbl(it,1);
    cn(idfind) = tbl(it,nr); 
end

cn(isnan(cn))=80; % Set cn to 80 where no data available
