function bathy2nc(station,begindate,enddate)
% rawdir = ['..' filesep 'raw' filesep station];
rawdir = ['\\131.180.118.191\maxradermacher\cBathyProducts\cBathyDepths\zandmotor\Kalman'];
files = dir([rawdir filesep '*.cbathy.mat']);
% dates = char(files(:).name);
% dates = str2num(dates(:,1:10))/(24*3600)+datenum(1970,1,1);
% dind = find(dates >= begindate & dates <= enddate);
% files = files(dind);

for f = 1:20%length(files)
    if f == 1
        load([rawdir filesep files(f).name]);
        fn = fieldnames(bathy);
        bathy.runningAverage.Hs = 0.5;
    else
        btemp = load([rawdir filesep files(f).name]);
        for n = 1:length(fn)
            eval(['bathy(' num2str(f) ').' fn{n} ' = btemp.bathy.' fn{n} ';']);
        end
        eval(['bathy(' num2str(f) ').runningAverage.Hs = 0.5;']);
    end
end

if strcmpi(lower(station),'zandmotor')
    load([rawdir filesep 'zm_shoreline.mat']);
end

create_cbathy_ncfile(bathy,xs);
end