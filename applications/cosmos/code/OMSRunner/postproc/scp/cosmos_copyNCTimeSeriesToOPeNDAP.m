function cosmos_copyNCTimeSeriesToOPeNDAP(hm,m)

exeDir=[hm.dataDir filesep 'exe' filesep];    

model=hm.models(m);
archdir = model.appendeddirtimeseries;

for istat=1:model.nrStations
    
    stName=model.stations(istat).name;
    
    for i=1:model.stations(istat).nrDatasets
        
        if model.stations(istat).datasets(i).toOPeNDAP
            
            par=model.stations(istat).datasets(i).parameter;
            
            ncfile=[archdir stName '.' par '.' num2str(year(hm.cycle)) '.nc'];
            
            if exist(ncfile,'file')
                try
                    fid=fopen('scp.txt','wt');
                    fprintf(fid,'%s\n','option batch on');
                    fprintf(fid,'%s\n','option confirm off');
                    fprintf(fid,'%s\n','open ormondt:Lido2000@opendap.deltares.nl -timeout=15 -hostkey="ssh-rsa 2048 40:80:49:83:e3:e8:06:7c:49:ba:67:18:20:2e:bf:69"');
                    fprintf(fid,'%s\n',['cd /p/opendap/data/deltares/cosmos']);
                    fprintf(fid,'%s\n',['mkdir ' hm.scenario]);
                    fprintf(fid,'%s\n',['mkdir ' hm.scenario '/' model.name]);
                    fprintf(fid,'%s\n',['cd ' hm.scenario '/' model.name]);
                    
                    % Upload scenario xml
                    fprintf(fid,'%s\n',['put ' ncfile]);  
                    fprintf(fid,'%s\n','close');
                    fprintf(fid,'%s\n','exit');
                    fclose(fid);
                    system([exeDir 'winscp.exe /console /script=scp.txt']);
                    delete('scp.txt');
                catch
                    disp('Could not copy to OPeNDAP server!');
                end
            end
        end
    end
    
end
