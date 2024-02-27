delete('bin\*');

statspath='Y:\app\MATLAB2009b\toolbox\stats';
statspath='n:\Applications\Matlab\MATLAB2012a_64\toolbox\stats';
rmpath(statspath);
statspath='n:\Applications\Matlab\MATLAB2012a_64\toolbox\stats\classreg';
rmpath(statspath);
statspath='n:\Applications\Matlab\MATLAB2012a_64\toolbox\stats\stats';
rmpath(statspath);
statspath='n:\Applications\Matlab\MATLAB2012a_64\toolbox\stats\statsdemos';
rmpath(statspath);

statspath='c:\Program Files\MATLAB2012a_64\toolbox\stats';
rmpath(statspath);
statspath='c:\Program Files\MATLAB2012a_64\toolbox\stats\classreg';
rmpath(statspath);
statspath='c:\Program Files\MATLAB2012a_64\toolbox\stats\stats';
rmpath(statspath);
statspath='c:\Program Files\MATLAB2012a_64\toolbox\stats\statsdemos';
rmpath(statspath);

fid=fopen('complist','wt');

fprintf(fid,'%s\n','-a');

filetypes=defineFileTypes;
nf=size(filetypes,1);
for i=1:nf
    fprintf(fid,'%s\n',['AddDataset' filetypes{i,2}]);    
end

fclose(fid);

% fid=fopen('addlist','wt');
% flist=dir(['xml' filesep '*.xml']);
% for ii=1:length(flist)
%     fprintf(fid,'%s\n',['xml' filesep flist(ii).name]);        
% end
% fclose(fid);

% mcc -m -d c:\work\checkouts\OpenEarthTools\trunk\matlab\applications\muppet\bin muppet.m -B complist
mcc -m -d d:\checkouts\OpenEarthTools\trunk\matlab\applications\muppet\bin muppet.m -B complist -a xml

delete('complist');
%delete('addlist');

% delete('qptmp\*.m');
% rmpath('qptmp');
% rmdir('qptmp','s');
