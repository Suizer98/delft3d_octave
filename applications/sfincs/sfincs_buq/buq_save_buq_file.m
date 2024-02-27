function buq_save_buq_file(buq, msk, buqfile)

fldnames=fieldnames(buq);
for j=1:length(fldnames)
    name=fldnames{j};
    if strcmpi(name(1),'m') || strcmpi(name(1),'n') || strcmpi(name(1),'l')
        buq.(name)=buq.(name)(msk>0);
    end
end

buq = buq_find_neighbors(buq);

fid=fopen(buqfile,'w');

% Number of blocks
fwrite(fid,length(buq.level),'integer*4');

% Nr levels
fwrite(fid,max(buq.level),'integer*1');

% Grid stuff
fwrite(fid,buq.x0,'real*4');
fwrite(fid,buq.y0,'real*4');
fwrite(fid,buq.dx,'real*4'); % size of coarsest blocks
fwrite(fid,buq.dy,'real*4'); % size of coarsest blocks
fwrite(fid,buq.rotation,'real*4');

% Levels
fwrite(fid,buq.level,'integer*1');

% N
fwrite(fid,buq.n,'integer*4');

% M
fwrite(fid,buq.m,'integer*4');

% NU
fwrite(fid,buq.nu, 'integer*1');
fwrite(fid,buq.nu1,'integer*4');
fwrite(fid,buq.nu2,'integer*4');
% MU
fwrite(fid,buq.mu, 'integer*1');
fwrite(fid,buq.mu1,'integer*4');
fwrite(fid,buq.mu2,'integer*4');
% ND
fwrite(fid,buq.nd, 'integer*1');
fwrite(fid,buq.nd1,'integer*4');
fwrite(fid,buq.nd2,'integer*4');
% MD
fwrite(fid,buq.md, 'integer*1');
fwrite(fid,buq.md1,'integer*4');
fwrite(fid,buq.md2,'integer*4');

fclose(fid);
