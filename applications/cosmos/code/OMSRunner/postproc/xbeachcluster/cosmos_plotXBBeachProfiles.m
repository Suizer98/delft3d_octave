function cosmos_plotXBBeachProfiles(hm,m)

model=hm.models(m);

np=hm.models(m).nrProfiles;

for ip=1:np
    
    profile=model.profile(ip).name;
    
    archivedir=[model.cycledirnetcdf profile filesep];
    figuredir=[model.cycledirfigures filesep];
    xmldir=[model.cycledirhazards profile filesep];
    
    % Check if simulation has run
    if exist([archivedir profile '_proc.mat'],'file')
        
        plot_profilecalcs(figuredir,archivedir,xmldir,profile);
        
        %% Write html code
        fi2=fopen([model.cycledirfigures profile '.html'],'wt');
        fprintf(fi2,'%s\n','<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">');
        fprintf(fi2,'%s\n','<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">');
        fprintf(fi2,'%s\n','<head>');
        fprintf(fi2,'%s\n','</head>');
        fprintf(fi2,'%s\n','<body>');
        fprintf(fi2,'%s\n',['<img src="' profile '.png">']);
        fprintf(fi2,'%s\n','</body>');
        fprintf(fi2,'%s\n','</html>');
        fclose(fi2);
                
    end
    
end
