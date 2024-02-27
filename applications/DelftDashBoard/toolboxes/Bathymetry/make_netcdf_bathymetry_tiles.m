function make_netcdf_bathymetry_tiles(fname1,dr,dataname,rawdataformat,nx,ny,ncopt,varargin)
% make_netcdf_bathymetry_tiles(fname1,dr,dataname,rawdataformat,nx,ny,varargin)
%
% Generates bathymetry tiles in Delft Dashboard format
%
% fname1        = filename of raw data input file (cell array in case of multiple files)
% dr            = outputfolder
% dataname      = output name of nc files
% rawdataformat = input format (nc, geotiff, arcinfo etc.)
% nx            = tile size in x direction (e.g. 300) (HAS TO BE AN EVEN NUMBER !!!)
% ny            = tile size in y direction (e.g. 300) (HAS TO BE AN EVEN NUMBER !!!)
% ncopt         = netcdf file options
% 
% optional inputs:
% zrange (default [-1e9 1e9]) : Depths outside this range will be set to NaN
% izoom1 (default 1)          : First zoom level to be created
% positiveup (default 1)      : Set to 0 if raw data is positive down

% Default inputs
zrange=[-1e9 1e9];    % Depths outside this range will be set to NaN
izoom1=1;             % First zoom level to be created
positiveup=1;         % Set to 0 if raw data is positive down
iquiet=0;
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'zrange'}
                zrange=varargin{ii+1};
            case{'izoom1'}
                izoom1=varargin{ii+1};
            case{'positiveup'}
                positiveup=varargin{ii+1};
            case{'quiet'}
                iquiet=1;
        end
    end
end

wb = waitbox('Reading data file ...');

pbyp=0;
multiple_files=0;

switch lower(rawdataformat)
    case{'arcinfogrid'}
        [ncols,nrows,x00,y00,cellsz,noval]=readArcInfo(fname1,'info');
        if ncols*nrows>225000000
            %        if ncols*nrows>1
            % Too large, read piece by piece...
            pbyp=1;
            dx=cellsz;
            dy=cellsz;
            tile_arc_info_ascii(fname1,'TMP_BATHY',nx,noval);
        else
            [x,y,z]=readArcInfo(fname1);
            x00=x(1);
            y00=y(1);
            dx=x(2)-x(1);
            dy=y(2)-y(1);
            ncols=length(x);
            nrows=length(y);
        end
    case{'arcbinarygrid'}
        [x,y,z,m] = arc_info_binary([fileparts(fname1) filesep]);
        dx=m.X(2)-m.X(1);
        dy=m.Y(2)-m.Y(1);
        if dy>0
            x00=m.X(1);
            y00=m.Y(end);
            z=flipud(z);
            %            y=fliplr(y);
        else
            x00=m.X(1);
            y00=m.Y(end);
            dy=abs(dy);
            z=flipud(z);
        end
        ncols=m.nColumns;
        nrows=m.nRows;
    case{'matfile'}
        s=load(fname1);
        z=s.z;
        x00=s.x(1);
        y00=s.y(1);
        nrows=length(s.y);
        dx=s.x(2)-s.x(1);
        dy=s.y(2)-s.y(1);
        ncols=length(s.x);
    case{'netcdf'}
        %        x=nc_varget(fname1,'x');
        %        y=nc_varget(fname1,'y');
        %        z=nc_varget(fname1,'z');
        x=nc_varget(fname1,'lon');
        y=nc_varget(fname1,'lat');
%         z=nc_varget(fname1,'elevation');
        %         x=nc_varget(fname1,'COLUMNS');
        %         y=nc_varget(fname1,'LINES');
        %         z=nc_varget(fname1,'DEPTH');
        x00=x(1);
        y00=y(1);
        nrows=length(y);
        dx=x(2)-x(1);
        dy=y(2)-y(1);
        ncols=length(x);
        
        if ncols*nrows>400000000
            %        if ncols*nrows>225000000
            % Too large, read piece by piece...
            pbyp=1;
        else
            z=nc_varget(fname1,'elevation');
        end
        
        
    case{'xyz'}
        s=load(fname1);
        x0=s(:,1);
        y0=s(:,2);
        z0=s(:,3);
    case{'adcircgrid'}
        wb_h = waitbar(0,'Reading the adcirc data');
        [xadc,yadc,zadc,n1,n2,n3]=import_adcirc_fort14(fname1,wb_h,[0,1/6]);
        xx=x0:dx:max(xadc)+dx;
        yy=y0:dy:max(yadc)+dy;
        [x,y]=meshgrid(xx,yy);
        z=interp_tri2grid(xadc,yadc,zadc,n1,n2,n3,x,y,wb_h,[1/6+1/12,2/3]);
        close(wb_h);
        x00=x0;
        y00=y0;
        ncols=length(xx);
        nrows=length(yy);
    case{'xyzregular'}
        [x,y,z]=xyz2regulargrid(fname1);
        x00=x(1,1);
        y00=y(1,1);
        dx=x(2)-x(1);
        dy=y(2)-y(1);
        ncols=length(x);
        nrows=length(y);
    case{'geotiff'}
        if ~iscell(fname1)
            % just one file
            [z,x,y,I] = geoimread(fname1,'info');
            maxx=max(x);
            maxy=max(y);
            z=flipud(z);
            z(z<-15000)=NaN; % Get rid of no data values
            x00=min(x);
            y00=min(y);
            dx=abs(x(2)-x(1));
            dy=abs(y(2)-y(1));
            ncols=length(x);
            nrows=length(y);
            if ncols*nrows>400000000
                %        if ncols*nrows>225000000
                % Too large, read piece by piece...
                pbyp=1;
            else
                [z,xdum,ydum,I] = ddb_geoimread(fname1);
                z=flipud(z);
                z(z<-15000)=NaN;
            end
        else
            multiple_files=1;
            xmin= 1e9;
            xmax=-1e9;
            ymin= 1e9;
            ymax=-1e9;
            for ii=1:length(fname1)
                filename=fname1{ii};
                [A,x,y,I]=geoimread(filename,'info'); %faster because elevation data of every tile is not read in
                xx=[x(1) x(end) x(end) x(1) x(1)];
                yy=[y(end) y(end) y(1) y(1) y(end)];
                dx=(x(end)-x(1))/(length(x)-1);
                dy=-(y(end)-y(1))/(length(y)-1);
                xmin=min(xmin,x(1));
                xmax=max(xmax,x(end));
                ymin=min(ymin,y(end));
                ymax=max(ymax,y(1));
            end
            x00=xmin;
            y00=ymin;
            ncols=round((xmax-xmin)/dx+1);
            nrows=round((ymax-ymin)/dy+1);
        end
end

close(wb);

% Determine required number of zoom levels
zm=1:50;
nnx=ncols./(nx.*2.^(zm-1));
nny=nrows./(ny.*2.^(zm-1));
iix=find(nnx>1,1,'last');
if isempty(iix)
    iix=1;
end
iiy=find(nny>1,1,'last');
if isempty(iiy)
    iiy=1;
end
nrzoom=max(iix,iiy);

%
% else
%     % Read in one go!
%     switch lower(rawdatatype)
%         case{'arcinfogrid'}
%             [x,y,z]=readArcInfo(fname1);
%     end
% end
if ~positiveup
    z=z*-1;
end

imaketiles=1;
imakemeta=1;

x0(1)=x00;
y0(1)=y00;
dxk(1)=dx;
dyk(1)=dy;
nnxk(1)=ceil(ncols/nx);
nnyk(1)=ceil(nrows/ny);
nxk(1)=nx;
nyk(1)=ny;

for k=2:nrzoom
    x0(k)=x00;
    y0(k)=y00;
    dxk(k)=dxk(1)*2^(k-1);
    dyk(k)=dyk(1)*2^(k-1);
    nnxk(k)=ceil(nnxk(k-1)/2);
    nnyk(k)=ceil(nnyk(k-1)/2);
    nxk(k)=nx;
    nyk(k)=ny;
end

if imaketiles
    
    for k=izoom1:nrzoom
        
        if ~exist([dr 'zl' num2str(k,'%0.2i')],'dir')
            mkdir([dr 'zl' num2str(k,'%0.2i')]);
        end
        
        dx=dxk(k);
        dy=dyk(k);
        nnx=nnxk(k);
        nny=nnyk(k);
        
        if k==1
            
            if ~iquiet
            wb = awaitbar(0,'Generating tiles ...');
            end

            if multiple_files
                nfiles=length(fname1);
            else
                nfiles=1;
            end
            
            for ifile=1:nfiles

                if multiple_files
                    % This is where we read in the separate files
                    disp(['Processing file ' num2str(ifile) ' of ' num2str(nfiles) ' ...']);
                    [z,x,y,I] = ddb_geoimread(fname1{ifile});
                    xminf=min(x);
                    yminf=min(y);
                    xmaxf=max(x);
                    ymaxf=max(y);
                    z=flipud(z);
                    z(z<-15000)=NaN;
                    z(z<-9998)=NaN;
                else
                    xminf=x0(k);
                    yminf=x0(k);
                    xmaxf=maxx;
                    ymaxf=maxy;                    
                end                
                
                tilen=0;
                
                iii1=floor((xminf-x0(k))/(nx*dx));
                iii1=max(iii1,1);
                iii1=min(iii1,nnx);
                iii2=ceil((xmaxf-x0(k))/(nx*dx))+1;                
                iii2=max(iii2,1);
                iii2=min(iii2,nnx);

                jjj1=floor((yminf-y0(k))/(ny*dy));
                jjj1=max(jjj1,1);
                jjj1=min(jjj1,nny);
                jjj2=ceil((ymaxf-y0(k))/(ny*dy))+1;                
                jjj2=max(jjj2,1);
                jjj2=min(jjj2,nny);
                
%                for i=1:nnx
%                    for j=1:nny
                for i=iii1:iii2
                    for j=jjj1:jjj2
                        
                        tilen=tilen+1;

                        xmin = x0(k)+(i-1)*nx*dx;
                        ymin = y0(k)+(j-1)*ny*dy;
                        xmax = xmin+(nx-1)*dx;
                        ymax = ymin+(ny-1)*dy;
                        
                        xx=xmin:dx:xmax;
                        yy=ymin:dy:ymax;
                        
                        if multiple_files
                            
                            i1=round((xmin-xminf)/dx)+1;
                            i2=round((xmax-xminf)/dx)+1;
                            j1=round((ymin-yminf)/dy)+1;
                            j2=round((ymax-yminf)/dy)+1;
                            if (i1<1 && i2<1) || (i1>length(x) && i2>length(x)) || (j1<1 && j2<1) || (j1>length(y) && j2>length(y))
                                % tile outside file extent
                                continue
                            end
                            
                            jj1=1;
                            jj2=j2-j1+1;
                            ii1=1;
                            ii2=i2-i1+1;
                            
                            if i1<1 && i2>=1
                                ii1=-i1+2;
                                ii2=nx;
                                i1=1;
                            end
                            if i1<=length(x) && i2>length(x)
                                ii1=1;
                                ii2=nx-(i2-length(x));
                                i2=length(x);
                            end

                            if j1<1 && j2>=1
                                jj1=-j1+2;
                                jj2=ny;
                                j1=1;
                            end
                            if j1<=length(y) && j2>length(y)
                                jj1=1;
                                jj2=ny-(j2-length(y));
                                j2=length(y);
                            end
                            
                        else
                            i1=(i-1)*nx+1;
                            i2=i*nx;
                            i2=min(i2,ncols);
                            j1=(j-1)*ny+1;
                            j2=j*ny;
                            j2=min(j2,nrows);
                            
                            jj1=1;
                            jj2=j2-j1+1;
                            ii1=1;
                            ii2=i2-i1+1;

                        end
                        
                        abort2=0;
                        hh=1;
                        if ~iquiet
                            str=['Generating tiles - tile ' num2str(tilen) ' of ' ...
                                num2str(nnx*nny) ' ...'];
                            [hh,abort2]=awaitbar(tilen/(nnx*nny),wb,str);
                        else
                            disp(['Generating tiles - tile ' num2str(tilen) ' of ' ...
                                num2str(nnx*nny) ' ...']);
                        end
                        
                        if abort2 % Abort the process by clicking abort button
                            break;
                        end
                        if isempty(hh) % Break the process when closing the figure
                            break;
                        end
                        
%                         disp(['Processing ' num2str((i-1)*nny+j) ' of ' num2str(nnx*nny) ' ...']);
                        
                        zz=nan(ny,nx);
                        
                        if pbyp
                            % Read data piece by piece
                            switch lower(rawdataformat)
                                case{'arcinfogrid'}
                                    tempdir='TMP_BATHY';
                                    fname=[tempdir filesep 'TMP_' num2str(i,'%0.6i') '_' num2str(j,'%0.6i')  '.mat'];
                                    if exist(fname,'file')
                                        zz=load(fname);
                                        zz=zz.m2;
                                    end
                                    %                                [x,y,zz]=readArcInfo(fname1,'x',xx,'y',yy);
                                case{'geotiff'}
                                    [zz,xdum,ydum,I] = ddb_geoimread(fname1,[xmin xmax],[ymin ymax]);
                                    zz=flipud(zz);
                                    zz(zz<-15000)=NaN;
                                    zz(zz>15000)=NaN;
                                    
                                    if ~positiveup
                                        z=z*-1;
                                    end
                                    sztile=size(zz);
                                    if sztile(1)~=300 || sztile(2)~=300
                                        zz1=zeros(ny,nx);
                                        zz1(zz1==0)=NaN;
                                        zz1(1:size(zz,1),1:size(zz,2))=zz;
                                        zz=single(zz1);
                                    end
                                case{'netcdf'}
                                    zz=nc_varget(fname1,'elevation',[j1-1 i1-1],[ny nx]);
%                                     [zz,xdum,ydum,I] = ddb_geoimread(fname1,[xmin xmax],[ymin ymax]);
%                                     zz=flipud(zz);
%                                     zz(zz<-15000)=NaN;
%                                     zz(zz>15000)=NaN;
%                                     
%                                     if ~OPT.positiveup
%                                         z=z*-1;
%                                     end
%                                     sztile=size(zz);
%                                     if sztile(1)~=300 || sztile(2)~=300
%                                         zz1=zeros(ny,nx);
%                                         zz1(zz1==0)=NaN;
%                                         zz1(1:size(zz,1),1:size(zz,2))=zz;
%                                         zz=single(zz1);
%                                     end
                            end
                            %                        zz(1:(j2-j1+1),1:(i2-i1+1))=single(z);
                        else
                            zsingle=full(z(j1:j2,i1:i2));
%                            zz(1:(j2-j1+1),1:(i2-i1+1))=single(zsingle);
                            zz(jj1:jj2,ii1:ii2)=single(zsingle);
                        end
                        
                        if zrange(1)>-15000 || zrange(2)<15000
                            zz(zz<zrange(1))=NaN;
                            zz(zz>zrange(2))=NaN;
                        end
                        % Only save files that contain at least some valid
                        % values
%                         try
                            if ~isnan(nanmax(nanmax(zz)))
                                
                                if multiple_files
                                    % Check if the file was already partially filled
                                    % using previous file(s)
                                    fname=[dr 'zl' num2str(k,'%0.2i') filesep dataname '.zl01.' num2str(i,'%0.5i') '.' num2str(j,'%0.5i') '.nc'];
                                    if exist(fname,'file')
                                        zz0=nc_varget(fname,'depth');
                                        zz0=double(zz0);
                                        zz0(zz0==-999)=NaN;
                                        zz(isnan(zz))=zz0(isnan(zz));
                                    end
                                end
                                
                                zz=single(zz);
                                zz=zz';
                                fname=[dr 'zl' num2str(k,'%0.2i') filesep dataname '.zl01.' num2str(i,'%0.5i') '.' num2str(j,'%0.5i') '.nc'];
                                
                                ncopt.fillValue=-999;
                                
                                nc_grid_createNCfile2(fname,xx,yy,zz,ncopt);
                            end
%                         catch
%                             shite=1
%                         end
                        
                    end
                end
            end
            
            % Close waitbar
            if ~iquiet
            if ~isempty(hh)
                close(wb);
            end
            end
            
        else
            
            % Create tiles for higher zoom level
            
            wb = awaitbar(0,'Generating tiles ...');
            
            tilen=0;
            
            for i=1:nnx
                for j=1:nny
                    
                    tic
                    
                    tilen=tilen+1;
                    
                    str=['Generating level ' num2str(k) ' of ' num2str(nrzoom) ' - tile ' num2str(tilen) ' of ' ...
                        num2str(nnx*nny) ' ...'];
                    [hh,abort2]=awaitbar(tilen/(nnx*nny),wb,str);
                    
                    if abort2 % Abort the process by clicking abort button
                        break;
                    end;
                    if isempty(hh); % Break the process when closing the figure
                        break;
                    end;
                    
                    disp(['Processing ' num2str((i-1)*nny+j) ' of ' num2str(nnx*nny) ' ...']);
                                                            
                    iind=[i*2-1 i*2];
                    jind=[j*2-1 j*2];
                    
                    iex=zeros(2,2);
                    
                    % First check if surrouning files exist
                    for ii=1:2
                        for jj=1:2
                            fname=[dr 'zl' num2str(k-1,'%0.2i') filesep dataname '.zl' num2str(k-1,'%0.2i') '.' num2str(iind(ii),'%0.5i') '.' num2str(jind(jj),'%0.5i') '.nc'];
                            if exist(fname,'file')
                                iex(ii,jj)=1;
                            end
                        end
                    end
                    
                    if max(max(iex))>0
                        
                        % Now get the surrounding files and merge them

                        zz=zeros(2*ny,2*nx);
                        zz(zz==0)=NaN;
                        
%                        tic
                        for ii=1:2
                            for jj=1:2
                                fname=[dr 'zl' num2str(k-1,'%0.2i') filesep dataname '.zl' num2str(k-1,'%0.2i') '.' num2str(iind(ii),'%0.5i') '.' num2str(jind(jj),'%0.5i') '.nc'];
                                if iex(ii,jj)
                                    ncid = netcdf.open (fname,'NOWRITE');
                                    varid = netcdf.inqVarID(ncid,'depth');
                                    z = netcdf.getVar(ncid,varid);
                                    z=double(z);
                                    z=z';
                                    netcdf.close(ncid);
                                else
                                    z=zeros(ny,nx);
                                    z(z==0)=NaN;
                                end
                                zz((jj-1)*ny+1:jj*ny,(ii-1)*nx+1:ii*nx)=z;
                            end
                        end
%                        toc
                        
%                        tic
                        zzz=zeros(4,ny,nx);
                        zzz(1,:,:)=zz(1:2:end-1,1:2:end-1);
                        zzz(2,:,:)=zz(2:2:end  ,1:2:end-1);
                        zzz(3,:,:)=zz(2:2:end  ,2:2:end  );
                        zzz(4,:,:)=zz(1:2:end-1,2:2:end  );
                        
                        z=squeeze(nanmean(zzz,1));
                        
%                         zz=zz(ny:3*ny,nx:3*nx);
%                         z=derefine3(zz);
                        z=z';
%                        toc
                        
%                        tic
                        if ~isempty(find(~isnan(z), 1))
                            
                            z=single(z);
                            
                            xmin = x0(k)+(i-1)*nx*dx;
                            ymin = y0(k)+(j-1)*ny*dy;
                            xmax = xmin+(nx-1)*dx;
                            ymax = ymin+(ny-1)*dy;
                            
                            xx=xmin:dx:xmax;
                            yy=ymin:dy:ymax;
                            
                            fname=[dr 'zl' num2str(k,'%0.2i') filesep dataname '.zl' num2str(k,'%0.2i') '.' num2str(i,'%0.5i') '.' num2str(j,'%0.5i') '.nc'];
                            
                            ncopt.fillValue=-999;
                            
                            nc_grid_createNCfile2(fname,xx,yy,z,ncopt);
                            
                        end
%                        toc
                    end
                    
                    
                    
%                     iind=[i*2-2 i*2-1 i*2 i*2+1];
%                     jind=[j*2-2 j*2-1 j*2 j*2+1];
%                     
%                     iex=zeros(4,4);
%                     
%                     % First check if surrouning files exist
%                     for ii=1:4
%                         for jj=1:4
%                             fname=[dr 'zl' num2str(k-1,'%0.2i') filesep dataname '.zl' num2str(k-1,'%0.2i') '.' num2str(iind(ii),'%0.5i') '.' num2str(jind(jj),'%0.5i') '.nc'];
%                             if exist(fname,'file')
%                                 iex(ii,jj)=1;
%                             end
%                         end
%                     end
%                     
%                     if max(max(iex))>0
%                         
%                         % Now get the surrounding files and merge them
% 
%                         zz=zeros(4*ny,4*nx);
%                         zz(zz==0)=NaN;
%                         
%                         for ii=1:4
%                             for jj=1:4
%                                 fname=[dr 'zl' num2str(k-1,'%0.2i') filesep dataname '.zl' num2str(k-1,'%0.2i') '.' num2str(iind(ii),'%0.5i') '.' num2str(jind(jj),'%0.5i') '.nc'];
%                                 if iex(ii,jj)
%                                     ncid = netcdf.open (fname,'NOWRITE');
%                                     varid = netcdf.inqVarID(ncid,'depth');
%                                     z = netcdf.getVar(ncid,varid);
%                                     z=double(z);
%                                     z=z';
%                                     netcdf.close(ncid);
%                                 else
%                                     z=zeros(ny,nx);
%                                     z(z==0)=NaN;
%                                 end
%                                 zz((jj-1)*ny+1:jj*ny,(ii-1)*nx+1:ii*nx)=z;
%                             end
%                         end
%                         
%                         zz=zz(ny:3*ny,nx:3*nx);
%                         z=derefine3(zz);
%                         z=z';
%                         
%                         if ~isempty(find(~isnan(z), 1))
%                             z=single(z);
%                             
%                             xmin = x0(k)+(i-1)*nx*dx;
%                             ymin = y0(k)+(j-1)*ny*dy;
%                             xmax = xmin+(nx-1)*dx;
%                             ymax = ymin+(ny-1)*dy;
%                             
%                             xx=xmin:dx:xmax;
%                             yy=ymin:dy:ymax;
%                             
%                             fname=[dr 'zl' num2str(k,'%0.2i') filesep dataname '.zl' num2str(k,'%0.2i') '.' num2str(i,'%0.5i') '.' num2str(j,'%0.5i') '.nc'];
%                             
%                             OPT.fillValue=-999;
%                             
%                             nc_grid_createNCfile2(fname,xx,yy,z,OPT);
%                             
%                         end
%                     end

                toc
                end                
            end
            
            % close waitbar
            if ~isempty(hh)
                close(wb);
            end
            
        end
    end
end

% Check which files are available and make meta file
if imakemeta
    
    for k=1:nrzoom
        nnx=nnxk(k);
        nny=nnyk(k);
        nav=0;
        
        flist2=dir([dr 'zl' num2str(k,'%0.2i') filesep '*.nc']);
        iin=[];
        jin=[];
        for jjj=1:length(flist2)
            iin(jjj)=str2double(flist2(jjj).name(end-13:end-9));
            jin(jjj)=str2double(flist2(jjj).name(end-7:end-3));
        end
        
        for i=1:nnx
            for j=1:nny
                iava=find(iin==i & jin==j);
                if ~isempty(iava)
                    nav=nav+1;
                    iavailable{k}(nav)=i;
                    javailable{k}(nav)=j;
                end
            end
        end
    end
    fnamemeta=[dr dataname '.nc'];
    nc_createNCmetafile(fnamemeta,x0,y0,dxk,dyk,nnxk,nnyk,nxk,nyk,iavailable,javailable,ncopt);
end

