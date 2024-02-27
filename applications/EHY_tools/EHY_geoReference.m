function EHY_geoReference(figureFile,xlsFile,worldFile)
%% EHY_geoReference(figureFile,xlsFile,worldFile)
%
% This functions creates a world file based on a provided  figure 
% and corresponding Excel file that contains the translation from
% [Xpixel,Ypixel] to [longitude,latitude]
%
% Function can be used interactively; the .xlsx and world file will 
% be saved with the same file name as the path of figure, but with
% a different extension.
%
% Example1: EHY_geoReference
% Example2: EHY_geoReference('D:\figure1.png')
% Example3: EHY_geoReference('D:\figure1.png','D:\figure1.xlsx')
% Example4: EHY_geoReference('D:\figure1.png','D:\figure1.xlsx','D:\figure1.pgw')
%
% created by Julien Groenenboom, January 2019
% Largely based on script of R. Morelissen and G. de Boer
%
%% get and set paths

% figureFile
if ~exist('figureFile','var')
    disp('Open the figure that you would like to georeference');
    [filename, pathname] =uigetfile('*.*','Open the figure that you would like to georeference');
    figureFile=[pathname filename];
end

% xlsFile
if ~exist('xlsFile','var')
    [pathstr, name] = fileparts(figureFile);
    xlsFile=[pathstr filesep name '.xlsx'];
    if exist(xlsFile)
        [YesNoID,~]=  listdlg('PromptString',{'The corresponding .xlsx-file already exists. Use this file to geo reference the image?',...
            xlsFile},'SelectionMode','single','ListString',{'Yes','No, create new .xlsx-file'},'ListSize',[800 50]);
        if isempty(YesNoID)
            disp('Stopped by user.')
            return
        elseif YesNoID==2
            [filename, pathname] =uiputfile(xlsFile,'Save .xlsx-file as ... ');
            xlsFile=[pathname filename];
        end
    end
end

% worldFile
if ~exist('worldFile','var')
    [pathstr, name, ext] = fileparts(figureFile);
    worldFile=[pathstr filesep name ext(1:2) ext(4) 'w'];
    worldFileExt=[ext(2) ext(4) 'w'];
        if exist(worldFile)
        [YesNoID,~]=  listdlg('PromptString',{['The corresponding ' worldFileExt '-file already exists. Overwrite the file below?'],...
            worldFile},'SelectionMode','single','ListString',{'Yes','No, but save as...'},'ListSize',[800 50]);
        if isempty(YesNoID)
            disp('Stopped by user.')
            return
        elseif YesNoID==2
            [filename, pathname] =uiputfile(worldFile,['Save .' worldFileExt '-file as ... ']);
            worldFile=[pathname filename];
        end
    end
end

%% Read or create xlsx file 
if ~exist(xlsFile)
    % plot figure
    I=imread(figureFile);
    figure
    if size(I,3)==1
        colormap('gray');
    end
    imagesc(I)
    axis image
    
    hold on
    
    but=1;
    xp=[];
    yp=[];
    xr=[];
    yr=[];
    
    % Obtain Ground Control Points (GCP)
    while but==1 && length(xp)<3
        jj=menu({['Zoom into position and click Ok when ready to indicate point ',num2str(length(xp)+1)],...
            'When ready (at least 3 points), also click Ok, and then <left mouse> button.'},...
            'Ok');
        uiresume(jj);
        
        title({['Clicking Ground Control Point ',num2str(length(xp)+1),':'],...
            'Click <left mouse> button or <ESC> to Quit.'})
        
        [gx,gy,but]=ginput(1);
        if but==1
            xp=[xp gx];
            yp=[yp gy];
            plot(xp(end), yp(end),'r*')
            text(xp(end), yp(end),num2str(length(xp)))
        else
            disp('Stopped by user')
            return
        end
        axis([1 size(I,2) 1 size(I,1)])
    end
    title('Done clicking Ground Control Points')
    
    % write xlsx file
    xls={'Point','X_pixel','Y_pixel','longitude','Latitude'};
    for ii=1:3
        xls{ii+1,1}=ii;
        xls{ii+1,2}=xp(ii);
        xls{ii+1,3}=yp(ii);
    end
    xlswrite(xlsFile,xls);
    disp(['Created file:' char(10) xlsFile])
    disp('Open this file and fill in the corresponding [longitude,latitude]-values.')
    disp('Then, run the EHY_geoReference function again to use this .xlsx-file:')
    disp(['EHY_geoReference(''' figureFile ''');'])
    return
else
    % read xls file
    disp(['Using existing corresponding .xlsx-file:' char(10) xlsFile])
    [~,~,xls]=xlsread(xlsFile);
end

if any(any(isnan(cell2mat(xls(2:end,4:5)))))
    error(['Please fill in the corresponding [longitude,latitude]-values in the .xlsx-file:' char(10) xlsFile])
end
% Calculate georeferencing
xp=cell2mat(xls(2:end,2))';
yp=cell2mat(xls(2:end,3))';
xr=cell2mat(xls(2:end,4))';
yr=cell2mat(xls(2:end,5))';

% Try varying these 4 parameters.
% scale = 1.2;        scale factor
% angle = 40*pi/180;  rotation angle
% tx    = 0;          x translation
% ty    = 0;          y translation
%
% sc    = scale*cos(angle);
% ss    = scale*sin(angle);
%
% T = [ sc -ss;
%       ss  sc;
%       tx  ty];
%[u v] = [ x y 1] T.

A  = [xp' yp' repmat(1,length(xr),1)];
B  = [xr' yr'];
T  = A\B;

tx = T(3,1);
ty = T(3,2);

% Save world file
fid=fopen(worldFile,'w');
fprintf(fid,'%30.16f\n',T(1,1));
fprintf(fid,'%30.16f\n',T(1,2));
fprintf(fid,'%30.16f\n',T(2,1));
fprintf(fid,'%30.16f\n',T(2,2));
fprintf(fid,'%30.16f\n',tx);
fprintf(fid,'%30.16f\n',ty);
fclose(fid);

disp(['Created file:' char(10) worldFile])

disp('Result will now be plotted to screen (please check carefully)')
figure
hold on
EHY_geoShow(figureFile);
scatter(xr, yr,'r*')
text(xr,yr,{'1','2','3'})
end
