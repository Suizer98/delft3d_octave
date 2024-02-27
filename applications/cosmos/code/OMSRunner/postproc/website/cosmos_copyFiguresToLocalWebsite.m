function cosmos_copyFiguresToLocalWebsite(hm,m)

model=hm.models(m);
cycledir=model.cycledirfigures;

dr=model.dir;
cont=model.continent;
dir1=[cycledir '*.*'];
dir2=[hm.webDir 'scenarios' filesep  hm.scenario filesep  cont  filesep  model.name filesep 'figures'];

try
    makedir([hm.webDir 'scenarios' filesep],hm.scenario,cont,model.name,'figures');
    delete([dir2 filesep '*.html']);
    delete([dir2 filesep '*.kmz']);
    delete([dir2 filesep '*.png']);
    [status,message,messageid]=copyfile(dir1,dir2,'f');
catch
    disp(['Something went wrong with copying to local website - ' hm.models(m).name]);
end

if model.forecastplot.plot
    try
        dir3=[cycledir 'forecast' filesep '*.*'];
        makedir([hm.webDir 'zandmotor' filesep 'forecast' filesep],'results');
        makedir([hm.webDir 'zandmotor' filesep 'forecast' filesep],'results',hm.models(m).forecastplot.name);
        dir4=[hm.webDir 'zandmotor' filesep 'forecast' filesep 'results' filesep hm.models(m).forecastplot.name];
        delete([dir4 filesep '*.xml']);
        delete([dir4 filesep '*.png']);
        [status,message,messageid]=copyfile(dir3,dir4,'f');
    catch
        disp(['Something went wrong with copying forecast plots to local website - ' hm.models(m).name]);
    end
end

% Model overlays for each website
for iw=1:length(model.webSite)
    if ~isempty(model.webSite(iw).overlayFile)
        try
            f1=[dr 'data' filesep model.webSite(iw).overlayFile];
            [status,message,messageid]=copyfile(f1,dir2,'f');
        end
    end
end
