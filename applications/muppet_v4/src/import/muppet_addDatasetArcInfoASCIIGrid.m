function varargout=muppet_addDatasetArcInfoASCIIGrid(varargin)

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'read'}
                % Read file data
                dataset=varargin{ii+1};
                parameter=[];
                if length(varargin)==3
                    parameter=varargin{ii+1};
                end
                dataset=read(dataset,parameter);
                varargout{1}=dataset;                
            case{'import'}
                % Import data
                dataset=varargin{ii+1};
                dataset=import(dataset);
                varargout{1}=dataset;
            case{'gettimes'}
                varargout{1}=[];
        end
    end
end

%%
function dataset=read(dataset,varargin)

try
    [ncols,nrows,xll,yll,cellsz]=readArcInfo(dataset.filename,'info');
catch
    disp([dataset.filename ' does not appear to be a valid ArcInfo ASCII Grid file!']);    
end

par=[];
par=muppet_setDefaultParameterProperties(par);
[pathstr,name,ext]=fileparts(dataset.filename);
par.name=name;
par.size=[0 0 nrows ncols 0];
dataset.parameters(1).parameter=par;

%%
function dataset=import(dataset)

[x,y,z]=readArcInfo(dataset.filename);
[x,y]=meshgrid(x,y);

dataset.rawquantity='scalar';

imagefile=0;

if ~isempty(dataset.imagefile) && ~isempty(dataset.georeferencefile)
    
    imagefile=1;    

    % Now load image
    
    frm=dataset.imagefile(end-2:end);
    switch lower(frm)
        case{'jpg','epg','bmp'}
            col=imread(dataset.imagefile);
        case{'png'}
            [col,map,alpha]=imread(dataset.imagefile,'BackgroundColor','none');
        case{'gif'}
            col=imread(dataset.imagefile,1);
    end
    
    sz=size(col);
            
    txt=load(dataset.georeferencefile);
    dx=txt(1);
    roty=txt(2);
    rotx=txt(3);
    dy=txt(4);
    x0=txt(5);
    y0=txt(6);
    
    if rotx~=0 || roty~=0
        xc=dx*x0+rotx*y0+x0;
        yc=roty*x0+dy*y0+y0;
    else
        % New: MvO
        xc=x0:dx:x0+(sz(2)-1)*dx;
        yc=y0:dy:y0+(sz(1)-1)*dy;
    end
    
end

if dataset.interpolatedemonimage
    % interpolate image on dem
    [xc,yc]=meshgrid(xc,yc);    
    parameter.x=xc;
    parameter.y=yc;
    parameter.val=interp2(x,y,z,xc,yc);
    dataset.rgb=double(col)/255;
    dataset.size=[0 0 size(xc,1) size(xc,2) 0];        
else
    % interpolate dem on image
    parameter.x=x;
    parameter.y=y;
    parameter.val=z;
    if imagefile
        dataset.rgb(:,:,1) = interp2(xc,yc,double(squeeze(col(:,:,1))),x,y);
        dataset.rgb(:,:,2) = interp2(xc,yc,double(squeeze(col(:,:,2))),x,y);
        dataset.rgb(:,:,3) = interp2(xc,yc,double(squeeze(col(:,:,3))),x,y);
        dataset.rgb=dataset.rgb/255;
    end
end

% parameter.val=max(parameter.val,-5);
% parameter.val=min(parameter.val,5);

[timestep,istation,m,n,k]=muppet_findDataIndices(dataset);

% Get values (and store in same structure format as qpread)
d.X=muppet_extractmatrix(parameter,'x',dataset.size,timestep,istation,m,n,k);
d.Y=muppet_extractmatrix(parameter,'y',dataset.size,timestep,istation,m,n,k);
d.Time=muppet_extractmatrix(parameter,'time',dataset.size,timestep,istation,m,n,k);
d.Val=muppet_extractmatrix(parameter,'val',dataset.size,timestep,istation,m,n,k);

% From here on, everything should be the same for each type of datafile
dataset=muppet_finishImportingDataset(dataset,d,timestep,istation,m,n,k);
