clear variables;close all;

ascfile='srtm_68_24.asc';
ncfile='srtm_68_24.nc';

OPT.EPSGcode                     = 4326;
OPT.EPSGname                     = 'WGS 84';
OPT.EPSGtype                     = 'geographic 2d';
OPT.VertCoordName                = 'MSL';
OPT.VertCoordLevel               = 0.0;
OPT.Conventions                  = 'CF-1.4';
OPT.CF_featureType               = 'grid';
OPT.title                        = 'SRTM DATA VERSION 4.1';
OPT.institution                  = 'CIAT';
OPT.source                       = 'http://srtm.csi.cgiar.org';
OPT.history                      = 'created by Maarten van Ormondt (12-Feb-2011)';
OPT.references                   = 'Jarvis A., H.I. Reuter, A.  Nelson, E. Guevara, 2008, Hole-filled  seamless SRTM data V4, International  Centre for Tropical  Agriculture (CIAT), available from http://srtm.csi.cgiar.org.';
OPT.comment                      = 'General Bathymetric Chart of the Oceans';
OPT.email                        = 'Maarten.vanOrmondt@deltares.nl';
OPT.version                      = '1.0';
OPT.terms_for_use                = 'We kindly ask  any users to  cite this data  in any published  material produced using this data,  and if possible  link web pages  to the CIAT-CSI  SRTM website (http://srtm.csi.cgiar.org).';
OPT.disclaimer                   = 'These data are made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';
OPT.nc_library                   = 'matlab';
OPT.coordsystype='geo';
OPT.tp='short';

dr='P:\1201423-santa-cruz-harbor\SRTMv4.1_ascii\5_5x5_ascii\';
flist=dir([dr '*.zip']);
for i=253:length(flist)
    tic
%for i=1:2
    f=flist(i).name(1:end-4);
    disp([f ' - ' num2str(i) ' of ' num2str(length(flist))]);
%    tic
%    disp('copying file');
    copyfile([dr flist(i).name],'.\');
%    toc
%    tic
%    disp('unzipping file');
    unzip(flist(i).name);
%    toc
    ascfile=[f '.asc'];
    ncfile=[f '.nc'];
%    tic
%    disp('make nc file');
    asc2nc(ascfile,ncfile,OPT);
%    toc
%    tic
%    disp('move nc file');
%    zip([f '.nc.zip'],ncfile);
    movefile(ncfile,[dr ncfile]);
%    toc
    delete(flist(i).name);
    delete('*.prj');
    delete('*.asc');
    delete('*.nc');
    delete('readme.txt');
    toc
end


