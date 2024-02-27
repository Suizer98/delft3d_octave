function tile_arc_info_ascii(datafile,tempdir,np,noval)

if ~exist(tempdir,'dir')
    mkdir(tempdir);
end

[ncols,nrows,x0,y0,cellsz]=readArcInfo(datafile,'info');

ncoltiles=ceil(ncols/np);
nrowtiles=ceil(nrows/np);

nrowend=nrows-(nrowtiles-1)*np;

% ncoltot=ncoltiles*np;
% nrowtot=nrowtiles*np;

m0=zeros(np,ncoltiles*np);
m0(m0==0)=NaN;


fid=fopen(datafile,'r');

% Read header lines
for ii=1:6
    f=fgetl(fid);
end

for irowr=1:nrowtiles
        
    disp(['Converting row ' num2str(irowr) ' of ' num2str(nrowtiles) ' ...']);
    
    m=m0;
    irow=nrowtiles-irowr+1;
    
    if irowr==1 && nrowend>0
        % Remainder of data at top op file
        for kk=1:nrowend
            s=sscanf(fgetl(fid),'%f',ncols);
            ii=nrowend-kk+1;
            m(ii,1:ncols)=s;
        end
    else
        for kk=1:np
            s=sscanf(fgetl(fid),'%f',ncols);
            ii=np-kk+1;
            m(ii,1:ncols)=s;
        end        
    end
    
    m(m==noval)=NaN;
    
    for icol=1:ncoltiles
        m2=m(:,(icol-1)*np+1:(icol-1)*np+np);
        if ~isempty(find(~isnan(m2)))
            fname=[tempdir filesep 'TMP_' num2str(icol,'%0.6i') '_' num2str(irow,'%0.6i')  '.mat'];        
            save(fname,'m2');
        end
    end
end
%S = fscanf(fid,fmt);
% a=textscan(fid, '%[^\n]', 300, 'HeaderLines', 6);
%a=textscan(fid, '%[^\n]', 10, 'HeaderLines', 10000);

fclose(fid);

