%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: SRE_read_grainp.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/SRE_read_grainp.m $
%

function [dk_lims,fractions,underlayer_levels]=SRE_read_grainp(path_grainp)
%% DEBUG

% clear
% clc
% path_grainp="c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\191016_rt_fm1D\data\gsd\RIJNMORF.SBK\25\GRAINP.TXT" ;

%% INPUT

nloc=1000; %preallocate with large number

%% READ

grainp=read_ascii(path_grainp);

%% GET

nl=numel(grainp);

%% get number of layers
search_nunlay=1;
while search_nunlay
    for kl=1:nl
        if contains(grainp{kl,1},'NUNLAY')
            nunlay_raw=regexp(grainp{kl,1},'\d+','match');
            nunlay=cellfun(@str2double,nunlay_raw);
            search_nunlay=0;
        end
    end %kl
end

%% get grain size
search_grain_size=1;
while search_grain_size
    for kl=1:nl
        if contains(grainp{kl,1},'$FRACT')
            dk_lims_raw=regexp(grainp{kl,1},'\d+.\d+','match');
            dk_lims=cellfun(@str2double,dk_lims_raw(:));
            search_grain_size=0;
        end
    end %kl
end

nf=numel(dk_lims)-1; %number of characteristic grain sizes

%% get composition

branch_num=NaN(nloc,1);
chainage=NaN(nloc,1);
frac=NaN(nloc,nunlay,nf);
kloc=1;
for kl=1:nl
    if contains(grainp{kl,1},'$GSINIT')
        %% branch number
        gsinit_br_raw=regexp(grainp{kl,1},'BRANCH\s+\d+','match');
        gsinit_br_num_raw=regexp(gsinit_br_raw,'\d+','match');
        gsinit_br_num=cellfun(@str2double,gsinit_br_num_raw(:));
        
        branch_num(kloc,1)=gsinit_br_num;
        %% chainage
        gsinit_chainage_raw=regexp(grainp{kl,1},'AT\s+\d+.\d+','match');
        gsinit_chainage_num_raw=regexp(gsinit_chainage_raw,'\d+.\d+','match');
        gsinit_chainage_num=cellfun(@str2double,gsinit_chainage_num_raw(:)); 
        
        chainage(kloc,1)=gsinit_chainage_num;
        %% fractions
        for klay=1:nunlay
            kl2=kl+klay;
            laynum_raw=regexp(grainp{kl2,1},'\d+.\d+','match');
            laynum=cellfun(@str2double,laynum_raw(:)); 
            
            frac(kloc,klay,:)=laynum';
        end %klay2
        
        %% update
        if kloc==nloc
            branch_num=cat(1,branch_num,NaN(nloc,1));
            chainage=cat(1,chainage,NaN(nloc,1));
            frac=cat(1,frac,NaN(nloc,nunlay,nf));
        end
        kloc=kloc+1;
    end
    
    %display
    fprintf('file %4.2f %% \n',kl/nl*100)
end
    
%clean
branch_num=branch_num(1:kloc-1,:);
chainage=chainage(1:kloc-1,:);
frac=frac(1:kloc-1,:,:);
    
%out
fractions.branch=branch_num;
fractions.chainage=chainage;
fractions.var=frac;

%% get lowest layer position
    
branch_num_elev=NaN(nloc,1);
chainage_elev=NaN(nloc,1);
elev=NaN(nloc,1);
kloc=1;
for kl=1:nl
    tok=regexp(grainp{kl,1},'\$GSLEVUNLA Branch\s+(\d+)\s+AT\s+(\d+)\s+(-?\d+.\d+)','tokens');
    if ~isempty(tok)
        branch_num_elev(kloc,1)=str2double(tok{1,1}{1,1});
        chainage_elev(kloc,1)=str2double(tok{1,1}{1,2});
        elev(kloc,1)=str2double(tok{1,1}{1,3});
        
        %update
        if kloc==nloc
            branch_num_elev=cat(1,branch_num_elev,NaN(nloc,1));
            chainage_elev=cat(1,chainage_elev,NaN(nloc,1));
            elev=cat(1,elev,NaN(nloc,nunlay,nf));
        end
        kloc=kloc+1;
    end    
    %display
    fprintf('file %4.2f %% \n',kl/nl*100)
end
    
%clean
branch_num_elev=branch_num_elev(1:kloc-1,:);
chainage_elev=chainage_elev(1:kloc-1,:);
elev=elev(1:kloc-1,:,:);

underlayer_levels.branch=branch_num_elev;
underlayer_levels.chainage=chainage_elev;
underlayer_levels.var=elev;




    
    
    