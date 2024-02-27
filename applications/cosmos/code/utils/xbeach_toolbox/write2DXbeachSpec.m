function write2DXbeachSpec(SS,name,sdur,tstep)

%write2DXbeachSpec(SS,name,sdur,tstep) Writes 2D spectral input files for 
% Xbeach from the spectral structure SS named specin_NAME_date.dat.
%
%   Input:
%     SS = struct('t',datenum(s),'f',freqs,'d',dirs,...
%          'S',2D_variance_densities)
%        size(SS.s) = [length(SS.f) length(SS.d) length(SS.t)]
%     name = 'text'; used in file name written (ex: 'VE')
%     sdur = duration of each wave spectrum condition in seconds (ex: 3600)
%     tstep = required time step in boundary condition file in seconds 
%            (ex:1.0)
%   Output:
%     for length(SS.t)==1 : specin_NAME_datestr(SS.t,'yyyymmddHH').dat
%     for length(SS.t)>1  : specin_NAME_datestr(SS.t,'yyyymmddHH').dat for
%                           each time
%                         : Filelist.txt with the names of each indiv file
%                         for use with the 'bcfile' command for
%                         time-varying spectra (Xbeach manual p.45).
%   !!!ASSUMPTIONS!!!:
%     1 - Frequencies are absolute frequencies.
%     2 - Spectral data values are variance densities (m^2/Hz/degr).
%
%   write2DXbeachSpec(SS,name,sdur,tstep);
%
% Modified from DMT Write2DSwanSpec code
% JLE 5/2/09

% Loop through for each time and write individual spectral file.
for ii=1:length(SS.t)
    
    % initialize file
    fid = fopen(['specin_',name,'_',datestr(SS.t(ii),'yyyymmddHH'),'.dat'],'w');
    
    % frequencies
    fprintf(fid,'%6.0f\n',length(SS.f));
    for jj=1:length(SS.f)
       fprintf(fid,'%10.4f\n',SS.f(jj));
    end

    % directions
    fprintf(fid,'%6.0f\n',length(SS.d));
    for jj=1:length(SS.d)
       fprintf(fid,'%10.4f\n',SS.d(jj));
    end

    % spectral data
    tmp = SS.s(:,:,ii);
    So = tmp;
    for mm=1:size(So,1)
       fprintf(fid,' %9.4f',So(mm,:)); 
       fprintf(fid,'\n');
    end
    fclose(fid);

end

%now write filelist.txt with all of the filenames.
% initialize file
fid = fopen('filelist.txt','w');
fprintf(fid,'%8s\n','FILELIST');
% Loop through for each time and write individual spectral file name
for ii=1:length(SS.t)
    tmp = ['  ',num2str(sdur),'.0      ',num2str(tstep),'.0 ','specin_',name,'_',datestr(SS.t(ii),'yyyymmddHH'),'.dat'];
    fprintf(fid,'%s\n',tmp);
end
fclose(fid);