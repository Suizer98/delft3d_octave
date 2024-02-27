clear variables;close all;

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

outdir='F:\delftdashboard\data\bathymetry\';
dataname='srtm41';
nrzoom=8;
x00=-180;
y00=-90;
dx0=3/3600;
dy0=dx0;
npx=432000;
npy=216000;
nx=300;
ny=300;

dr='P:\1201423-santa-cruz-harbor\SRTMv4.1_ascii\5_5x5_ascii\';
flist=dir([dr '*.nc']);
%for i=1:length(flist)
for i=1:length(flist)
    ncfiles{i}=[dr flist(i).name];
end

ddb_makeBathyTiles(outdir,dataname,ncfiles,nrzoom,x00,y00,dx0,dy0,npx,npy,nx,ny,OPT)

