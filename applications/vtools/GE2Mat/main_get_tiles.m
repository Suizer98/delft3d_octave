%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16973 $
%$Date: 2020-12-17 18:20:54 +0800 (Thu, 17 Dec 2020) $
%$Author: chavarri $
%$Id: main_get_tiles.m 16973 2020-12-17 10:20:54Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/GE2Mat/main_get_tiles.m $
%
%download or load (for saving) maptiles 

%% PREAMBLE

% clear
% clc

%% INPUT

%token
% mytoken='XXXXXXXXXXXXXXXXXXX';
load("c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\00_codes\GE2Mat\mytoken.mat")

% xlima=  [5.20     7.50]*1e4;
% ylima=  [4.40     4.60]*1e5;
% coordinate_input=28992; %Amersfoort

% xlima=  [05+28/60+37/3600, 05+29/60+40/3600];
% ylima=  [51+53/60+04/3600, 51+53/60+26/3600];
% xlima=  [05+26/60+08/3600, 05+27/60+07/3600];
% ylima=  [51+52/60+44/3600, 51+53/60+07/3600];
% xlima=  [05+24/60+38/3600, 05+25/60+27/3600];
% ylima=  [51+51/60+14/3600, 51+51/60+33/3600];
xlima=  [04+11/60+45/3600, 06+35/60+32/3600];
ylima=  [51+28/60+52/3600, 52+42/60+24/3600];
coordinate_input=4326; %google earth

tzl = 10; %zoom

save_tiles=1;
% coordinate_output=4326;
coordinate_output=28992;
path_save='C:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\191016_rt_fm1D\data\tiles\tiles_3';

%map type
%1=satellite;
%2=openstreetmat; 
%3=google earth (satellite); 
%4=google earth (maps); 
%5=google earth (hybrid); 
%6=google earth (terrain); 
map_type=3;  

path_tiles='C:\Users\chavarri\checkouts\riv\earth_tiles\'; 

%% PATHS

addpath(path_tiles)

%% CONVERT COORDINATES

[xRD,yRD] = ndgrid(xlima,ylima);
[lon_deg,lat_deg,logs]=convertCoordinates(xRD,yRD,'CS1.code',coordinate_input,'CS2.code',4326);
[xtile,ytile] = deg2osm(tzl,lat_deg,lon_deg);

%%

txl_v=min(floor(xtile(:))):max(floor(xtile(:)));
tyl_v=min(floor(ytile(:))):max(floor(ytile(:)));
nx=numel(txl_v);
ny=numel(tyl_v);
tiles=cell(nx,ny,3);
for kx=1:nx
    txl=txl_v(kx);
    for ky = 1:ny
        tyl=tyl_v(ky);
        
        switch map_type
            case 1 %MapBox
                ti = 1/512;
            case {2,3} %openstreetmap
                ti=1/255;
%             case 3
        end
        
        tz = tzl; %*ones(1/ti+1);
        [tx, ty] = ndgrid([txl:ti:txl+1],[tyl:ti:tyl+1]);
        [lat_deg,lon_deg] = osm2deg(tzl,tx,ty);
        
        switch map_type
            case 1
                baseserver = 'api.mapbox.com/styles/v1/mapbox/satellite-v9/tiles/256';
                baseformat = 'jpeg';
                basetoken = sprintf('@2x?access_token=%s',mytoken);
                source = sprintf([baseserver,'/%i/%i'],tzl,txl);
                sourcecache = sprintf(['%s/%s/%i.',baseformat],path_tiles,source,tyl);
                httptilename = sprintf(['https://%s/%i%s'],source,tyl,basetoken);
            case 2
                %check possible ones here: https://wiki.openstreetmap.org/wiki/Tile_servers
%                 baseserver = 'a.tile.openstreetmap.org'; 
                baseserver = 'a.tile.openstreetmap.de'; 
                baseformat = 'png';
                source = sprintf([baseserver,'/%i/%i'],tzl,txl);
                sourcecache = sprintf(['%s/%s/%i.',baseformat],path_tiles,source,tyl);
                httptilename = sprintf(['http://%s/%i.',baseformat],source,tyl);
            case {3,4,5,6}
                switch map_type
                    case 3
                        str_type='s';
                    case 4
                        str_type='m';
                    case 5
                        str_type='y';
                    case 6
                        str_type='t';
                end
                baseserver = sprintf('mt1.google.com/vt/lyrs=%s',str_type); 
                baseformat = 'jpg';
                source = sprintf([baseserver,'&x=%d&y=%d&z=%d'],txl,tyl,tzl); %http://mt1.google.com/vt/lyrs=m&x=1325&y=3143&z=13
                sourcecache = sprintf('%s/%s/%i/%i/%i.%s',path_tiles,baseserver,tzl,txl,tyl,baseformat);
                httptilename = sprintf('http://%s',source);
        end

%         if exist(sourcecache)==2
        if exist(sourcecache,'file')==2
            [A,map]=imread(sourcecache);  
        else
            disp([ 'Downloading tile: ' ,httptilename])
            [A,map]=imread(httptilename);
            sourcecachedir = fileparts(sourcecache);
%             if exist(sourcecachedir) ~= 7
            if exist(sourcecachedir,'dir') ~= 7
                mkdir(sourcecachedir);
            end
            
            switch map_type
                case {1,3,4,5,6}
                    imwrite(A,sprintf('%s',sourcecache));
                case 2
                    imwrite(A,map,sprintf('%s',sourcecache));
            end
        end
        
        switch map_type
            case {1,3,4,5,6}
                
            case 2
                A = ind2rgb(A,map);                
        end
            
        %satellite and openstreetmap
        Im = permute(A,[2 1 3]); 

        [xRD,yRD,logs]=convertCoordinates(lon_deg,lat_deg,'CS1.code',4326,'CS2.code',coordinate_output);
        tiles{kx,ky,1}=xRD;
        tiles{kx,ky,2}=yRD;
        tiles{kx,ky,3}=Im;
        
        %display
        fprintf('tile x %4.2f %% tile y %4.2f %% \n',kx/nx*100,ky/ny*100)
    end
end


%% PLOT

[nx,ny,~]=size(tiles);
figure
hold on
for kx=1:nx
    for ky=1:ny
         surf(tiles{kx,ky,1},tiles{kx,ky,2},zeros(size(tiles{kx,ky,2})),tiles{kx,ky,3},'EdgeColor','none')
    end
end
axis equal

%% SAVE

if save_tiles
    path_full_save=fullfile(path_save);
    if exist(path_full_save,'file')
        error('you are trying to overwrite a tiles variable')
    else
        save(path_full_save,'tiles')
    end
end

