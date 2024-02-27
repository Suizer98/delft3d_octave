function sfincs_write_indices_for_dem_providegrid(xg,yg,outfile,demx,demy)

% Grid is given in function
% xg is xgrid of coarse
% yg is ygrid of coarse

% size of dem
ntopo=size(demy,2); 
mtopo=size(demx,2);

% Get indices. Do this in blocks as the mex file can't handle large arrays
blocksize = 501;
nn1=ceil(ntopo/blocksize);
mm1=ceil(mtopo/blocksize);
indices=zeros(ntopo,mtopo);
for in=1:nn1
    for im=1:mm1
        i1=(in-1)*blocksize+1;
        j1=(im-1)*blocksize+1;
        i2=i1+blocksize-1;
        j2=j1+blocksize-1;
        i2=min(i2,ntopo);
        j2=min(j2,mtopo);
        ind=mx_find_grid_indices(demx(j1:j2),demy(i1:i2),xg,yg);
        ind=double(ind);
        indices(i1:i2,j1:j2)=ind;
    end
end

% Now write output file
%indices=reshape(indices,[1 ntopo*mtopo]);

fid=fopen(outfile,'w');
fwrite(fid,ntopo,'integer*4');
fwrite(fid,mtopo,'integer*4');
fwrite(fid,indices,'integer*4');
fclose(fid);
