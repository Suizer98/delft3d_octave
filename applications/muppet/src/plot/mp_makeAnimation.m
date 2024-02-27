function mp_makeAnimation(handles,ifig)

AnimationSettings=handles.AnimationSettings;

% Make temporary Data structure
Data=handles.DataProperties;

CombinedDatasetProperties=handles.CombinedDatasetProperties;

% AviOps.fccHandler=AnimationSettings.fccHandler;
% AviOps.KeyFrames=AnimationSettings.KeyFrames;
% AviOps.Quality=AnimationSettings.Quality;
% AviOps.BytesPerSec=AnimationSettings.BytesPerSec;
% AviOps.Parameters=AnimationSettings.Parameters;
AviOps=AnimationSettings.aviOptions;

if AnimationSettings.makeKMZ
    handles.Figure(ifig).PaperSize(1)=handles.Figure(ifig).Axis(1).Position(3);
    handles.Figure(ifig).PaperSize(2)=handles.Figure(ifig).Axis(1).Position(4);
    handles.Figure(ifig).BackgroundColor='none';
    handles.Figure(ifig).Axis(1).BackgroundColor='none';
    handles.Figure(ifig).Axis(1).Position(1)=0;
    handles.Figure(ifig).Axis(1).Position(2)=0;
    handles.Figure(ifig).Axis(1).DrawBox=0;
    handles.Figure(ifig).Axis(1).ColorBarPosition=[-100 -100 0.5000 8];
end

flist=dir('curvecpos*');
if ~isempty(flist)
    delete('curvecpos*');
end

%% Prepare first temporary figure
handles.Figure(ifig).Units='centimeters';
handles.Figure(ifig).cm2pix=1;
handles.Figure(ifig).FontRed=1;

if exist(AnimationSettings.aviFileName,'file')
    delete(AnimationSettings.aviFileName);
end

% Determine frame size
fig=figure('visible','off');
set(fig,'PaperUnits',handles.Figure(ifig).Units);
set(fig,'PaperSize', [21 29.7]);
set(fig,'PaperPosition',[1.3 1.2 handles.Figure(ifig).PaperSize(1) handles.Figure(ifig).PaperSize(2)]);
set(fig,'Renderer',handles.Figure(ifig).Renderer);
set(fig, 'InvertHardcopy', 'off');

if strcmpi(handles.Figure(ifig).Orientation,'l')
    set(fig,'PaperOrientation','landscape');
end

exportfig (fig,'tmpavi.png','Format','png','FontSize',[1],'color','cmyk','Resolution',handles.Figure(ifig).Resolution, ...
    'Renderer',handles.Figure(ifig).Renderer);
close(fig);
a = imread('tmpavi.png');
sz=size(a);
sz(1)=4*floor(sz(1)/4);
sz(2)=4*floor(sz(2)/4);

if exist('tmpavi.png','file')
    delete('tmpavi.png');
end
clear a

if ~isempty(AnimationSettings.aviFileName)
    if ~strcmpi(AnimationSettings.aviFileName(end-2:end),'gif')
        AviHandle = writeavi('initialize');
        AviHandle = writeavi('open', AviHandle,AnimationSettings.aviFileName);
        AviHandle = writeavi('addvideo', AviHandle, AnimationSettings.frameRate, sz(1),sz(2), 24, AviOps);
    end
end 

wb = awaitbar(0,'Generating AVI...');

try
    % If anything fails, at least close waitbar and animation
    
    hh=[];
    
    nf=0;
    
    % Determine timestep and number of frames
    timeStep=AnimationSettings.timeStep/86400;
    
    nrFrames=round((AnimationSettings.stopTime-AnimationSettings.startTime)/timeStep);
    
    for iblock=1:nrFrames
        
        % Update time
        t=AnimationSettings.startTime+(iblock-1)*timeStep;
        
        %% Update datasets
        
        % First all regular datasets
        for id=1:length(Data)
            if ~Data(id).CombinedDataset
                % Check to see if this a time-varying dataset
                if Data(id).TC=='t'
                    % First see if available times exactly match current
                    % time
                    iTime=find(abs(Data(id).AvailableTimes-t)<1/864000, 1, 'first');
                    if ~isempty(iTime)
                        % Exact time found
                        Data(id).DateTime=Data(id).AvailableTimes(iTime);
                        Data=UpdateDatasets(Data,0,iTime,id);
                    else
                        % Averaging between surrounding times
                        iTime1=find(Data(id).AvailableTimes-1e-4<t,1,'last');
                        Data1=UpdateDatasets(Data,0,iTime1,id);
                        iTime2=find(Data(id).AvailableTimes+1e-4>=t,1,'first');
                        Data2=UpdateDatasets(Data,0,iTime2,id);
                        t1=Data(id).AvailableTimes(iTime1);
                        t2=Data(id).AvailableTimes(iTime2);
                        dt=t2-t1;
                        tFrac2=(t-t1)/dt;
                        tFrac1=1-tFrac2;
                        switch lower(Data(id).Type)
                            case{'2dvector'}
                                Data(id).u  = tFrac1*Data1(id).u  + tFrac2*Data2(id).u;
                                Data(id).v  = tFrac1*Data1(id).v  + tFrac2*Data2(id).v;
                            case{'2dscalar'}
                                Data(id).z  = tFrac1*Data1(id).z  + tFrac2*Data2(id).z;
                                Data(id).zz = tFrac1*Data1(id).zz + tFrac2*Data2(id).zz;
                        end
                    end
                end
            end
        end
        
        % And now the combined datasets
        for id=1:length(Data)
            if Data(id).CombinedDataset
                % Check to see if this a time-varying dataset
                if Data(id).TC=='t'
                    % Find combined dataset number
                    for j=1:handles.NrCombinedDatasets
                        if strcmpi(Data(id).Name,handles.CombinedDatasetProperties(j).Name)
                            ic=j;
                            break;
                        end
                    end
                    Data=mp_combineDataset(Data,CombinedDatasetProperties,id,ic);
                end
            end
        end
        
        %% Update time bars
        for j=1:handles.Figure(ifig).NrSubplots
            for k=1:handles.Figure(ifig).Axis(j).Nr
                if isfield(handles.Figure(ifig).Axis(j).Plot(k),'TimeBar')
                    if handles.Figure(ifig).Axis(j).Plot(k).TimeBar(1)>0
                        AvailableDate=str2double(datestr(t,'yyyymmdd'));
                        AvailableTime=str2double(datestr(t,'HHMMSS'));
                        handles.Figure(ifig).Axis(j).Plot(k).TimeBar=[AvailableDate AvailableTime];
                    end
                end
            end
        end
        handles.DataProperties=Data;
        
        %% Make the figure
        
        % Figure name and format
        str=num2str(iblock+10000);
        figname=[AnimationSettings.prefix str(2:end) '.png'];
        handles.Figure(ifig).FileName=figname;
        handles.Figure(ifig).Format='png';
        
        % And export the figure
        ExportFigure(handles,ifig,'export');
        
        %% Add figure to animation
        
        % No avi file is made if avi filename is empty
        if  ~isempty(AnimationSettings.aviFileName)
            a = imread(figname,'png');
            if ~strcmpi(AnimationSettings.aviFileName(end-2:end),'gif')
                aaa=uint8(a(1:sz(1),1:sz(2),:));
                AviHandle = writeavi('addframe', AviHandle, aaa, iblock);
                clear aaa
            else
                nf = nf+1;
                if nf==1
                    [im,map] = rgb2ind(a,256,'nodither');
                    itransp=find(sum(map,2)==3);
                end
                im(:,:,1,nf) = rgb2ind(a,map,'nodither');
            end
            clear a
        end
        
        %% Delete figure file
        if AnimationSettings.keepFigures==0 && ~AnimationSettings.makeKMZ
            delete(figname);
        end
        
        %% Update waitbar
        str=['Generating AVI - frame ' num2str(iblock) ' of ' ...
            num2str(nrFrames) ' ...'];
        [hh,abort2]=awaitbar(iblock/nrFrames,wb,str);
        
        if abort2 % Abort the process by clicking abort button
            break;
        end;
        if isempty(hh); % Break the process when closing the figure
            break;
        end;
        
    end
    
    % Close waitbar
    if ~isempty(hh)
        close(wb);
    end
    
    % Close avi file
    if ~isempty(AnimationSettings.aviFileName)
        if ~strcmpi(AnimationSettings.aviFileName(end-2:end),'gif')
            AviHandle=writeavi('close', AviHandle);
        else
            % Try to make animated gif (not very succesful so far)
            %    imwrite(im,map,'test.gif','DelayTime',1/AnimationSettings.FrameRate,'LoopCount',inf) %g443800
            imwrite(im,map,'test.gif','DelayTime',1/AnimationSettings.frameRate,'LoopCount',inf,'TransparentColor',itransp-1,'DisposalMethod','restoreBG');
        end
    end
    
    % Delete curvec temporary files
    delete('curvecpos.*.dat');
    
    %% KMZ file
    if AnimationSettings.makeKMZ
        % File names
        for iblock=1:nrFrames
            str=num2str(iblock+10000);
            fignames{iblock}=[AnimationSettings.prefix str(2:end) '.png'];
            tms(iblock)=AnimationSettings.startTime+(iblock-1)*timeStep;
        end
        dt=timeStep;
        % Make colorbar
        if handles.Figure(ifig).Axis(1).PlotColorBar;
            makeColorBar(handles,'colorbar.png',[handles.Figure.Axis(1).CMin handles.Figure.Axis(1).CStep handles.Figure.Axis(1).CMax],handles.Figure(1).Axis(1).Plot(1).ColorMap,handles.Figure(1).Axis(1).ColorBarLabel);
        end
        % Bounding box
        csname=handles.Figure(ifig).Axis(1).coordinateSystem.name;
        cstype=handles.Figure(ifig).Axis(1).coordinateSystem.type;
        if strcmpi(csname,'unknown')
        else
            if ~isfield(handles,'EPSG')
                curdir=[handles.MuppetPath 'settings' filesep 'SuperTrans'];
                handles.EPSG=load([curdir filesep 'data' filesep 'EPSG.mat']);
            end
            [xl1,yl1]=convertCoordinates(handles.Figure(ifig).Axis(1).XMin,handles.Figure(ifig).Axis(1).YMin,handles.EPSG,'CS1.name',csname,'CS1.type',cstype,'CS2.name','WGS 84','CS2.type','geo');
            [xl2,yl2]=convertCoordinates(handles.Figure(ifig).Axis(1).XMax,handles.Figure(ifig).Axis(1).YMax,handles.EPSG,'CS1.name',csname,'CS1.type',cstype,'CS2.name','WGS 84','CS2.type','geo');
        end
        fname=[handles.AnimationSettings.aviFileName(1:end-4) '.kml'];
        makeKMZ(fname,xl1,xl2,yl1,yl2,fignames,tms,dt,'colorbar.png');
        delete('colorbar.png');
        % Delete existing figures
        if handles.AnimationSettings.keepFigures==0
            for ii=1:nf
                delete(fignames{ii});
            end
        end
    end
    
catch
    AviHandle=writeavi('close', AviHandle);
    close(wb);
    mp_giveWarning('text','Something went wrong while generating avi file');
end
%%
function makeKMZ(fname,xl1,xl2,yl1,yl2,fignames,tms,dt,colorbarfile)

fid=fopen(fname,'wt');
fprintf(fid,'%s\n','<kml xmlns="http://www.opengis.net/kml/2.2">');
fprintf(fid,'%s\n','<Document>');
if handles.Figure(ifig).Axis(1).PlotColorBar;
    fprintf(fid,'%s\n','  <ScreenOverlay id="colorbar">');
    fprintf(fid,'%s\n','    <Icon>');
    fprintf(fid,'%s\n','      <href>colorbar.png</href>');
    fprintf(fid,'%s\n','    </Icon>');
    fprintf(fid,'%s\n','    <overlayXY x="1" y="1" xunits="pixels" yunits="pixels"/>');
    fprintf(fid,'%s\n','    <screenXY x="10" y="10" xunits="pixels" yunits="pixels"/>');
    fprintf(fid,'%s\n','    <rotation>0</rotation>');
    fprintf(fid,'%s\n','    <size x="0" y="0" xunits="pixels" yunits="pixels"/>');
    fprintf(fid,'%s\n','  </ScreenOverlay>');
end
fprintf(fid,'%s\n','  <Folder>');
for iblock=1:length(tms)
    fprintf(fid,'%s\n', '    <GroundOverlay>');
    fprintf(fid,'%s\n',['      <name>' fignames{iblock} '</name>']);
    fprintf(fid,'%s\n', '      <TimeSpan>');
    fprintf(fid,'%s\n',['        <begin>' datestr(tms(iblock),'yyyy-mm-ddTHH:MM:SSZ') '</begin>']);
    fprintf(fid,'%s\n',['        <end>' datestr(tms(iblock)+dt+0.0001,'yyyy-mm-ddTHH:MM:SSZ') '</end>']);
    fprintf(fid,'%s\n', '      </TimeSpan>');
    
    fprintf(fid,'%s\n', '      <Icon>');
    fprintf(fid,'%s\n',['        <href>' handles.kmz.figname '</href>']);
    fprintf(fid,'%s\n', '      </Icon>');
    fprintf(fid,'%s\n', '      <LatLonBox>');
    fprintf(fid,'%s\n',['        <north>' num2str(yl2) '</north>']);
    fprintf(fid,'%s\n',['        <south>' num2str(yl1) '</south>']);
    fprintf(fid,'%s\n',['        <east>' num2str(xl2) '</east>']);
    fprintf(fid,'%s\n',['        <west>' num2str(xl1) '</west>']);
    fprintf(fid,'%s\n', '      </LatLonBox>');
    fprintf(fid,'%s\n', '    </GroundOverlay>');
end
fprintf(fid,'%s\n','  </Folder>');
fprintf(fid,'%s\n','</Document>');
fprintf(fid,'%s\n','</kml>');
fclose(fid);

zipfilename=[fname(1:end-4) '.zip'];

nf=length(fignames);
fignames{nf+1}=fname;
if ~isempty(colorbarfile)
    fignames{nf+2}='colorbar.png';
end
zip(zipfilename,fignames);

kmzname=[fname(1:end-4) '.kmz'];

movefile(zipfilename,kmzname);
delete(fname);
if exist(colorbarfile,'file')
    delete(colorbarfile);
end
