function dataset=muppet_addDatasetImage(opt,dataset)

x=[];
y=[];

switch lower(opt)

    case{'read'}
    
        % Do as much as possible here and not in import function
        dataset.adjustname=0;
        [pathstr,name,ext]=fileparts(dataset.filename);
        dataset.name=name;
    
    case{'import'}
        
        alpha=[];
        frm=dataset.filename(end-2:end);
        switch lower(frm)
            case{'jpg','epg','bmp'}
                jpgcol=imread(dataset.filename);
            case{'png'}
                [jpgcol,map,alpha]=imread(dataset.filename,'BackgroundColor','none');
            case{'gif'}
                jpgcol=imread(dataset.filename,1);
            case{'tif'}
                [jpgcol,x,y,I]=geoimread(dataset.filename);
        end
        sz=size(jpgcol);
        step=1;
        jpgcol=jpgcol(1:step:sz(1),1:step:sz(2),:);
        col=jpgcol;
        
        if ~isempty(dataset.georeferencefile)
            
            txt=load(dataset.georeferencefile);
            dx=txt(1);
            roty=txt(2);
            rotx=txt(3);
            dy=txt(4);
            x0=txt(5);
            y0=txt(6);
            
            a=dx*step;
            d=roty;
            b=rotx;
            e=dy*step;
            c=x0;
            f=y0;
            
            if rotx~=0 || roty~=0
                x=a*x0+b*y0+c;
                y=d*x0+e*y0+f;
            else
                % New: MvO
                x=x0:dx:x0+(sz(2)-1)*dx;
                y=y0:dy:y0+(sz(1)-1)*dy;
            end
        end
        
        if ~isempty(x)        
            dataset.type = 'geoimage';
        else
            x=[];
            y=[];
            dataset.type = 'image';
        end
        
        z=zeros(size(x));
        
        dataset.x     = x;
        dataset.y     = y;
        dataset.z     = z;
        dataset.c     = col;
        dataset.alpha = alpha;
        
        dataset.tc='c';
        
end
