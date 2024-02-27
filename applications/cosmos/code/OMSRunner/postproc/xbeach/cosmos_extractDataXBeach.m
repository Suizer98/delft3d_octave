function cosmos_extractDataXBeach(hm,m)

model=hm.models(m);

outdir=model.cyclediroutput;

XBdims=getdimensions(outdir);

x=XBdims.x;
y=XBdims.y;

x=x(:,2:end-1);
y=y(:,2:end-1);

%% Maps

pars = struct( ...
    'zb', {{'zb'}}, ...
    'hs', {{'H_mean'}}, ...
    'tp', {{'T'}}, ...
    'wl', {{'zs'}}, ...
    'vel', {{'uu_mean','vv_mean'}} ...
);

fpars = fields(pars);
for i = 1:length(fpars)
    par = char(fpars(i));
    
    parfiles = pars.(par);
    parfilesexist = zeros(size(parfiles));
    for j = 1:length(parfiles)
        fname = [outdir parfiles{j} '.dat'];
        parfilesexist(j) = exist(fname, 'file');
    end
    
    if all(parfilesexist)
        s = struct('Parameter', par, 'Time', [], 'X', x, 'Y', y, 'Val', [], 'U', [], 'V', []);
        
        for j = 1:length(parfiles)
            parfile = parfiles{j};
            fname = [outdir parfile '.dat'];
            
            [Var info]=readvar(fname,XBdims,'2D');

            if length(parfile)>5 && strcmpi(parfile(end-4:end), '_mean')
                t=XBdims.tsmean;
                t=t-3600;
            else
                t=XBdims.tsglobal;
            end

            nt=length(t);

            switch length(parfiles)
                case 1
                    for k=1:nt
                        s.Time(k)=model.tFlowStart+t(k)./86400;
                        s.Val(k,:,:)=squeeze(Var(:,2:end-1,k));
                    end
                    s.Val(nt+1,:,:)=s.Val(nt,:,:);
                    s.Val(s.Val<0.1)=NaN;
    
                case 2
                    for k=1:nt
                        s.Time(k)=model.tFlowStart+t(k)./86400;
                        switch j
                            case 1
                                s.U(k,:,:)=squeeze(Var(:,2:end-1,k));
                            case 2
                                s.V(k,:,:)=squeeze(Var(:,2:end-1,k));
                        end
                    end
                        switch j
                            case 1
                    s.U(nt+1,:,:)=s.U(nt,:,:);
                            case 2
                    s.V(nt+1,:,:)=s.V(nt,:,:);
                    end
            end
        end
        
        s.Time(end+1)=s.Time(end)+1/24;
        
        fname=[model.cycledirmaps par '.mat'];
        switch length(parfiles)
            case 1
                save(fname,'-struct','s','Parameter','Time','X','Y','Val');
            case 2
                save(fname,'-struct','s','Parameter','Time','X','Y','U', 'V');
        end
    end
end

%% Time Series

archdir=[model.appendeddirtimeseries];

points={'p1','p2'};
npoints=2;

for i=1:npoints

    fname = [outdir 'point' num2str(i,'%0.3i') '.dat'];
    
    if exist(fname, 'file')
        Var=readpoint(fname,XBdims,6);

        t=Var(:,1);

        % water levels
        s.Val=Var(:,2);
        s.Time=model.tFlowStart+model.morFac*t./86400;
        s.Parameter='wl';

        fname=[archdir 'wl_' points{i} '.mat'];
        save(fname,'-struct','s','Parameter','Time','Val');

        % water levels
        s.Val=sqrt(2)*Var(:,3);
        s.Time=model.tFlowStart+model.morFac*t./86400;
        s.Parameter='hs';

        fname=[archdir 'hs_' points{i} '.mat'];
        save(fname,'-struct','s','Parameter','Time','Val');
    end
    
end
