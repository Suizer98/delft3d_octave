function cosmos_makeSpecList(outdir,outfile,times,files)
%function MakeSpecList(inpdir,tstart,dt,runid,outdir,outfile,trefxbeach,runtime,morfac)

% MakeSpecList(inpdir,tstart,dt,runid,imodel,outdir,fout,trefxbeach,morfac)
%
% inpdir : flow-wave run directory with sp2 files (incl. last backslash)
% tstart : start time of flow model (e.g. datenum(2008,5,10))
% dt     : interval of wave computations (minutes)
% runid  : runid of wave simulation
% outdir : XBeach run directory (incl. last backslash)
% outfile :  filename spectra list (e.g. speclist.txt)
% trefxbeach : reference time xbeach (e.g. datenum(2008,5,10))
% morfac : MORFAC


dt=86400*(times(2,1)-times(1,1));

fid=fopen([outdir outfile],'wt');
fprintf(fid,'%s\n','FILELIST');
for it=1:size(times,1)
    fname=files{it,1};
    fprintf(fid,'%8.1f %8.1f %s\n',dt,1.0,fname);
end
fclose(fid);


% files=dir([inpdir runid '*.sp2' ]);
% 
% nfiles=length(files);
% 
% if (nfiles>0);
% 
%    for i=1:nfiles
%        k=str2double(files(i).name(10:12));
%        t(i)=tstart+k*dt/1440;
%    end
% 
%    t=t-trefxbeach;
% 
%    it0=find(t>=0,1,'first');
%    it1=find(t<runtime/1440,1,'last');
%    
%    if length(t) > it1; it1 = it1 + 1; end;
% 
%    fid=fopen([outdir outfile],'wt');
%    fprintf(fid,'%s\n','FILELIST');
%    for i=it0:it1
%        fname=strrep(files(i).name,' ','');
%        fprintf(fid,'%8.1f %8.1f %s\n',dt*60,1.0,fname);
%    end
%    fclose(fid);
% end;
