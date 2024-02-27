dr=dir('F:\OperationalModelSystem\SoCalCoastalHazards\scenarios\arkstorm\models\northamerica\*x');

for i=1:length(dr)
    if isdir(['F:\OperationalModelSystem\SoCalCoastalHazards\scenarios\arkstorm\models\northamerica\' dr(i).name])
        switch dr(i).name
            case{'.','..'}
            otherwise
                f1=['F:\OperationalModelSystem\SoCalCoastalHazards\scenarios\arkstorm\models\northamerica\' dr(i).name '\nesting'];
                f2=['F:\OperationalModelSystem\SoCalCoastalHazards\scenarios\jan2010_slr14\models\northamerica\' dr(i).name '\nesting\'];
                copyfile(f1,f2);
        end
    end
end

