clear all;close all;

MainDir='d:\OperationalModelSystem\SoCalCoastalHazards\';
scen0='forecasts';
scen1='december2007';
mkdir([MainDir 'scenarios\'],scen1);
sdir0=[MainDir 'scenarios\' scen0 '\'];
sdir1=[MainDir 'scenarios\' scen1 '\'];

mkdir(sdir1,'joblist');
mkdir(sdir1,'meteo');
mkdir(sdir1,'observations');
mkdir(sdir1,'models');

dr=dir([sdir0 'observations']);
for i=1:length(dr)
    switch dr(i).name
        case{'.','..'}
        otherwise
            if isdir([sdir0 'observations\' dr(i).name])
                mkdir([sdir1 'observations'],dr(i).name);
                dr2=dir([sdir0 'observations\' dr(i).name]);
                for j=1:length(dr2)
                    switch dr2(j).name
                        case{'.','..'}
                        otherwise
                            if isdir([sdir0 'observations\' dr(i).name '\' dr2(j).name])
                                mkdir([sdir1 'observations\' dr(i).name],dr2(j).name);
                                copyfile([sdir0 'observations\' dr(i).name '\' dr2(j).name '\*.dat'],[sdir1 'observations\' dr(i).name '\' dr2(j).name]);
                            end
                    end
                end
            end

    end
end

dr=dir([sdir0 'models']);
for i=1:length(dr)
    switch dr(i).name
        case{'.','..'}
        otherwise
            if isdir([sdir0 'models\' dr(i).name])
                mkdir([sdir1 'models'],dr(i).name);
                dr2=dir([sdir0 'models\' dr(i).name]);
                for j=1:length(dr2)
                    switch dr2(j).name
                        case{'.','..'}
                        otherwise
                            if isdir([sdir0 'models\' dr(i).name '\' dr2(j).name])
                                mkdir([sdir1 'models\' dr(i).name],dr2(j).name);
                                copyfile([sdir0 'models\' dr(i).name '\' dr2(j).name '\*.dat'],[sdir1 'models\' dr(i).name '\' dr2(j).name]);
                                sd2=[sdir1 'models\' dr(i).name '\' dr2(j).name '\'];
                                mkdir(sd2,'archive');
                                mkdir(sd2,'input');
                                mkdir(sd2,'lastrun');
                                mkdir(sd2,'nesting');
                                mkdir(sd2,'restart');
                                try
                                    copyfile([sdir0 'models\' dr(i).name '\' dr2(j).name '\input\*'],[sd2 'input']);
                                    copyfile([sdir0 'models\' dr(i).name '\' dr2(j).name '\nesting\*'],[sd2 'nesting']);
                                end
                            end
                    end
                end
            end

    end
end


