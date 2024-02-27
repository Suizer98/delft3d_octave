%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_read_dimensions.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_read_dimensions.m $
%
%get data from 1 time step in D3D, output name as in D3D

function out=D3D_read_dimensions(simdef)

%% RENAME in

file=simdef.file;
flg=simdef.flg;

%% results structure

NFStruct=vs_use(file.map,'quiet');

%% domain size
ITMAPC=vs_let(NFStruct,'map-info-series','ITMAPC','quiet'); %results time vector
out.nTt=numel(ITMAPC);
    %x
MMAX=vs_let(NFStruct,'map-const','MMAX','quiet'); 
out.MMAX=MMAX; 
    %y
NMAX=vs_let(NFStruct,'map-const','NMAX','quiet');
out.NMAX=NMAX; 
    %k
KMAX=vs_let(NFStruct,'map-const','KMAX','quiet');
out.KMAX=KMAX; 

if isfield(file,'sed')
dchar=D3D_read_sed(file.sed); %characteristic grain size per fraction (ATTENTION! bug in 'delft3d_io_sed.m' function)
% if ~isempty(dlimits)
%     warning('check below, difference between sed dia and percentages')
%     dchar=sqrt(dlimits(1,:).*dlimits(2,:));
    nf=numel(dchar); %number of sediment fractions
% else
%     nf=1;
% end
out.nf=nf;
end

    %number of substrate layers
if isempty(vs_find(NFStruct,'LYRFRAC')) %if it does not exists, there is one layer
    nl=1;
else 
    LYRFRAC=vs_let(NFStruct,'map-sed-series',{1},'LYRFRAC','quiet'); %fractions at layers [-] (t,y,x,l,f)
    nl=size(LYRFRAC,4); 
end
out.nl=nl;

