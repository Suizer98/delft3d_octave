function WriteModels(hm,varargin)

i1=[];
i2=[];

if nargin==1
    i1=1;
    i2=hm.nrModels;
else
    for i=1:hm.nrModels
        if strcmpi(hm.models(i).name,varargin{1})
            i1=i;
            i2=i;
        end
    end
end

if ~isempty(i1)

    for i=i1:i2

        dirname=[hm.modelDirectory 'models\' hm.models(i).continent '\' hm.models(i).name];
        system(['md ' dirname]);

        fname=[dirname '\' hm.models(i).name '.dat'];

        fid=fopen(fname,'wt');

        fprintf(fid,'%s\n',['Model "' hm.models(i).name '"']);
        fprintf(fid,'%s\n',['   Type        "' hm.models(i).type '"']);
        fprintf(fid,'%s\n',['   Name        ' hm.models(i).name]);
        fprintf(fid,'%s\n',['   Runid       ' hm.models(i).runid]);
        fprintf(fid,'%s\n',['   Location    ' num2str(hm.models(i).Location(1)) ' ' num2str(hm.models(i).Location(2))]);
        fprintf(fid,'%s\n',['   Continent   "' hm.models(i).continent '"']);
        fprintf(fid,'%s\n',['   Size        ' num2str(hm.models(i).size)]);
        fprintf(fid,'%s\n',['   XLim        ' num2str(hm.models(i).xLim(1)) ' ' num2str(hm.models(i).xLim(2))]);
        fprintf(fid,'%s\n',['   YLim        ' num2str(hm.models(i).yLim(1)) ' ' num2str(hm.models(i).yLim(2))]);
        fprintf(fid,'%s\n',['   Priority    ' num2str(hm.models(i).priority)]);
        if hm.models(i).nested
            fprintf(fid,'%s\n',['   Nested      "' hm.models(i).nestModel '"']);
        end
        if hm.models(i).waveNested
            fprintf(fid,'%s\n',['   WaveNested  "' hm.models(i).waveNestModel '"']);
        end
        fprintf(fid,'%s\n',['   SpinUpTime  ' num2str(hm.models(i).spinUp)]);
        fprintf(fid,'%s\n',['   RunTime     ' num2str(hm.models(i).runTime)]);
        fprintf(fid,'%s\n',['   TimeStep    ' num2str(hm.models(i).timeStep)]);
        fprintf(fid,'%s\n',['   MapTimeStep ' num2str(hm.models(i).mapTimeStep)]);
        fprintf(fid,'%s\n',['   HisTimeStep ' num2str(hm.models(i).hisTimeStep)]);
        fprintf(fid,'%s\n',['   ComTimeStep ' num2str(hm.models(i).comTimeStep)]);
        if hm.models(i).useMeteo
            fprintf(fid,'%s\n',['   UseMeteo    yes']);
        else
            fprintf(fid,'%s\n',['   UseMeteo    no']);
        end
        for j=1:hm.models(i).nrStations
            fprintf(fid,'%s\n',['   Station "' hm.models(i).stations(j).name2 '"']);
            fprintf(fid,'%s\n',['      StName          "' hm.models(i).stations(j).name1 '"']);
            fprintf(fid,'%s\n',['      StLocation      ' num2str(hm.models(i).stations(j).Location(1)) ' ' num2str(hm.models(i).stations(j).Location(2))]);
            if ~isempty(hm.models(i).stations(j).mN)
                fprintf(fid,'%s\n',['      StMN            ' num2str(hm.models(i).stations(j).mN(1)) ' ' num2str(hm.models(i).stations(j).mN(2))]);
            end
            for k=1:hm.models(i).stations(j).nrParameters
                fprintf(fid,'%s\n',['      Parameter ' hm.models(i).stations(j).parameters(k).name]);                
                if hm.models(i).stations(j).parameters(k).plotCmp
                    str='yes';
                else
                    str='no';
                end
                fprintf(fid,'%s\n',['         PlotCmp     ' str]);
                %
                if hm.models(i).stations(j).parameters(k).plotObs
                    str='yes';
                else
                    str='no';
                end
                fprintf(fid,'%s\n',['         PlotObs     ' str]);
                if ~strcmpi(hm.models(i).stations(j).parameters(k).obsCode,'none')
                    fprintf(fid,'%s\n',['         ObsCode     ' hm.models(i).stations(j).parameters(k).obsCode]);
                end
                %
                if hm.models(i).stations(j).parameters(k).plotPrd
                    str='yes';
                else
                    str='no';
                end
                fprintf(fid,'%s\n',['         PlotPrd     ' str]);
                if ~strcmpi(hm.models(i).stations(j).parameters(k).prdCode,'none')
                    fprintf(fid,'%s\n',['         PrdCode     ' hm.models(i).stations(j).parameters(k).prdCode]);
                end
                fprintf(fid,'%s\n','      EndParameter');
            end
            fprintf(fid,'%s\n',['   EndStation']);
        end
        for j=1:hm.models(i).nrAreas
            fprintf(fid,'%s\n',['   Area    "' hm.models(i).Areas(j).name '"']);
            fprintf(fid,'%s\n',['      AreaName   "' hm.models(i).Areas(j).name '"']);
            fprintf(fid,'%s\n',['      AreaXLim   ' num2str(hm.models(i).Areas(j).xLim(1)) ' ' num2str(hm.models(i).Areas(j).xLim(2))]);
            fprintf(fid,'%s\n',['      AreaYLim   ' num2str(hm.models(i).Areas(j).yLim(1)) ' ' num2str(hm.models(i).Areas(j).yLim(2))]);
            if hm.models(i).Areas(j).plotWL
                str='yes';
            else
                str='no';
            end
            fprintf(fid,'%s\n',['      AreaPlotWL ' str]);
            if hm.models(i).Areas(j).plotVel
                str='yes';
            else
                str='no';
            end
            fprintf(fid,'%s\n',['      AreaPlotVel ' str]);
            if hm.models(i).Areas(j).plotVelMag
                str='yes';
            else
                str='no';
            end
            fprintf(fid,'%s\n',['      AreaPlotVelMag ' str]);
            if hm.models(i).Areas(j).plotHs
                str='yes';
            else
                str='no';
            end
            fprintf(fid,'%s\n',['      AreaPlotHs ' str]);
            if hm.models(i).Areas(j).plotTp
                str='yes';
            else
                str='no';
            end
            fprintf(fid,'%s\n',['      AreaPlotTp ' str]);
            fprintf(fid,'%s\n',['   EndArea']);
        end
        fprintf(fid,'%s\n',['EndModel']);
        fclose(fid);
        %fprintf(fid,'%s\n','');
    end

end
