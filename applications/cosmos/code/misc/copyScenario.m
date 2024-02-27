clear all;close all;
hm=cosmos_readConfigFile;

Continents{1}='northamerica';
Continents{2}='centralamerica';
Continents{3}='southamerica';
Continents{4}='asia';
Continents{5}='europe';
Continents{6}='africa';
Continents{7}='australia';
Continents{8}='world';

scenori='forecasts';
scennew='socal_dec2010';

MakeDir([hm.runDir 'scenarios'],scennew);
scendir=[hm.runDir 'scenarios\' scennew '\'];

oridir=[hm.runDir 'scenarios\' scenori '\'];

MakeDir(scendir,'observations');
copyfile([oridir 'observations'],[scendir 'observations']);

MakeDir(scendir,'joblist');



% MakeDir(scendir,'meteo','gfs1p0');
MakeDir(scendir,'meteo','gfs1p0');
% MakeDir(scendir,'meteo','nam');
% MakeDir(scendir,'meteo','hirlam');
% MakeDir(scendir,'meteo','wrf');

for i=1:8
    MakeDir(scendir,'models',Continents{i});
end

for i=1:8
    cnt=Continents{i};
    switch lower(cnt)
        case{'world','europe','northamerica'}
    lst=dir([oridir 'models\' cnt]);
    for j=1:length(lst)
        switch lst(j).name
            case{'.','..'}
            otherwise
                model=lst(j).name;
                MakeDir([scendir 'models\' cnt],model);
                MakeDir([scendir 'models\' cnt '\' model],'input');
                MakeDir([scendir 'models\' cnt '\' model],'archive');
                MakeDir([scendir 'models\' cnt '\' model],'restart');
                MakeDir([scendir 'models\' cnt '\' model],'lastrun');
                MakeDir([scendir 'models\' cnt '\' model],'nesting');
                MakeDir([scendir 'models\' cnt '\' model],'data');
                copyfile([oridir 'models\' cnt '\' model '\' model '.xml'],[scendir 'models\' cnt '\' model]);
                copyfile([oridir 'models\' cnt '\' model '\input\*'],[scendir 'models\' cnt '\' model '\input']);
                try
                copyfile([oridir 'models\' cnt '\' model '\data\*'],[scendir 'models\' cnt '\' model '\data']);
                end
                [success,message,messageid] = copyfile([oridir 'models\' cnt '\' model '\nesting\*'],[scendir 'models\' cnt '\' model '\nesting']);
        end
    end
        otherwise
    end
end
