clear variables;close all;
ff='USCoastNOAA';
dr='F:\delftdashboard\data\toolboxes\navigationcharts\USCoastNOAA\';
n=0;
a=dir(dr);
for i=1:length(a)
    if a(i).isdir
        if ~strcmpi(a(i).name,'.') && ~strcmpi(a(i).name,'..')
            fname=a(i).name;
            disp([num2str(i) ' - ' fname]);
            inpdir=[dr fname filesep];
            if exist([inpdir fname '.mat'],'file')
                n=n+1;
                s=load([inpdir fname '.mat']);
                Box(n).Name=fname;
                Box(n).X=s.Box.X;
                Box(n).Y=s.Box.Y;
                if ~isempty(s.Layers.M_NPUB)
                    infotxt=s.Layers.M_NPUB.TXTDSC;
                    fid=fopen([inpdir infotxt],'r');
                    cdummy=fgetl(fid);
                    cdummy=fgetl(fid);
                    while isempty(deblank(cdummy))
                        cdummy=fgetl(fid);
                    end
                    desc=deblank(cdummy);
                    fclose(fid);
                else
                    desc=fname;
                end
                disp(desc);
                
                Box(n).Description=desc;
            else
                disp([inpdir fname '.mat does not exist!']);
            end
        end
    end
end
save([dr ff '.mat'],'Box');
