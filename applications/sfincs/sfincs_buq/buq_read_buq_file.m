function buq=buq_read_buq_file(buqfile)

% fldnames=fieldnames(buq);
% for j=1:length(fldnames)
%     name=fldnames{j};
%     if strcmpi(name(1),'m') || strcmpi(name(1),'n') || strcmpi(name(1),'l')
%         buq.(name)=buq.(name)(msk>0);
%     end
% end
% 
% buq = buq_find_neighbors(buq);

fid=fopen(buqfile,'r');

% Number of blocks
np=fread(fid,1,'integer*4');

% Nr levels
nlev=fread(fid,1,'integer*1');

% Grid stuff
buq.x0=fread(fid,1,'real*4');
buq.y0=fread(fid,1,'real*4');
buq.dx=fread(fid,1,'real*4');
buq.dy=fread(fid,1,'real*4');
buq.rotation=fread(fid,1,'real*4');

% Levels
buq.level=fread(fid,np,'integer*1');

% N
buq.n=fread(fid,np,'integer*4');

% M
buq.m=fread(fid,np,'integer*4');

% NU
buq.nu=fread(fid,np,'integer*1');
buq.nu1=fread(fid,np,'integer*4');
buq.nu2=fread(fid,np,'integer*4');
% MU
buq.mu=fread(fid,np,'integer*1');
buq.mu1=fread(fid,np,'integer*4');
buq.mu2=fread(fid,np,'integer*4');
% ND
buq.nd=fread(fid,np,'integer*1');
buq.nd1=fread(fid,np,'integer*4');
buq.nd2=fread(fid,np,'integer*4');
% MD
buq.md=fread(fid,np,'integer*1');
buq.md1=fread(fid,np,'integer*4');
buq.md2=fread(fid,np,'integer*4');

fclose(fid);

buq.level=buq.level+1;
nlev=nlev+1;
buq.nmax=0;
buq.mmax=0;

for nm = 1:np
      n    = buq.n(nm);
      m    = buq.m(nm);
      iref = buq.level(nm);
      buq.nmax = max(buq.nmax, floor( (1.0*(n - 1) + 0.01) / (2^(iref - 1))) + 2);
      buq.mmax = max(buq.mmax, floor( (1.0*(m - 1) + 0.01) / (2^(iref - 1))) + 2);
end

buq.first_point_per_level = 0;
buq.last_point_per_level = 0;
buq.nm_indices = 0;
% First count
%
ireflast = 0;
%
for ip = 1: np
    %
    iref = buq.level(ip);
    n    = buq.n(ip);
    m    = buq.m(ip);
    nmx  = buq.nmax*2^(iref - 1);
    nm   = (m - 1)*nmx + n;
    %
    buq.nm_indices(ip) = nm;
    %
    if iref>ireflast
        %
        % Found new level
        %
        buq.first_point_per_level(iref) = ip;
        ireflast = iref;
        %
    end
    %
    buq.last_point_per_level(iref) = ip;
    %
end
disp('done')