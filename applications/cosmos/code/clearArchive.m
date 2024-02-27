dr='F:\OperationalModelSystem\SoCalCoastalHazards\scenarios\forecasts\models\world\nww3\archive\';

flist=dir([dr '20*']);
for i=1:length(flist)
    try
        delete([dr flist(i).name filesep 'maps' filesep '*.mat']);
    end    
end
