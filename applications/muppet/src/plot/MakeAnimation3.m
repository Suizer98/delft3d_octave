function MakeAnimation2(handles,ifig)

AnimationSettings=handles.AnimationSettings;
NrAvailableDatasets=handles.NrAvailableDatasets;
NrCombinedDatasets=handles.NrCombinedDatasets;
Data=handles.DataProperties;
CombinedDatasetProperties=handles.CombinedDatasetProperties;

AviOps.fccHandler=AnimationSettings.fccHandler;
AviOps.KeyFrames=AnimationSettings.KeyFrames;
AviOps.Quality=AnimationSettings.Quality;
AviOps.BytesPerSec=AnimationSettings.BytesPerSec;
AviOps.Parameters=AnimationSettings.Parameters;

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

AvailableTimes=0;

if handles.Figure(ifig).NrAnnotations>0
    NrSub=handles.Figure(ifig).NrSubplots-1;
else
    NrSub=handles.Figure(ifig).NrSubplots;
end

for j=1:NrSub
    for k=1:handles.Figure(ifig).Axis(j).Nr
        m=FindDatasetNr(handles.Figure(ifig).Axis(j).Plot(k).Name,Data);
        if Data(m).TC=='t'
            AvailableTimes=Data(m).AvailableTimes;
            AvailableMorphTimes=Data(m).AvailableMorphTimes;
            handles.Figure(ifig).Axis(j).dataset(k).availableTimes=Data(m).AvailableTimes;
        else
            handles.Figure(ifig).Axis(j).dataset(k).availableTimes=[];
        end
    end
end

handles.Figure(ifig).Units='centimeters';
handles.Figure(ifig).cm2pix=1;
handles.Figure(ifig).FontRed=1;

if exist(AnimationSettings.FileName,'file')
    delete(AnimationSettings.FileName);
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

if ~strcmpi(AnimationSettings.FileName(end-2:end),'gif')

%     AviHandle = writeavi('initialize');
%     AviHandle = writeavi('open', AviHandle,AnimationSettings.FileName);
%     AviHandle = writeavi('addvideo', AviHandle, AnimationSettings.FrameRate, sz(1),sz(2), 24, AviOps);

%    AviHandle = avifile(AnimationSettings.FileName,'FPS',AnimationSettings.FrameRate,'Compression','MSVC');
    AviHandle = avifile(AnimationSettings.FileName,'FPS',AnimationSettings.FrameRate,'Compression','WMV3');
    
end

wb = awaitbar(0,'Generating AVI...');

n2=1;

nf=0;

%% KMZ stuff

if AnimationSettings.makeKMZ

    if handles.Figure(ifig).Axis(1).PlotColorBar;
        makeColorBar(handles,'colorbar.png',[handles.Figure.Axis(1).CMin handles.Figure.Axis(1).CStep handles.Figure.Axis(1).CMax],handles.Figure(1).Axis(1).Plot(1).ColorMap,handles.Figure(1).Axis(1).ColorBarLabel);
    end
    
    csname=handles.Figure(ifig).Axis(1).coordinateSystem.name;
    cstype=handles.Figure(ifig).Axis(1).coordinateSystem.type;
    if strcmpi(csname,'unknown')
    else
        if ~isfield(handles,'EPSG')
%            wb3 = waitbox('Reading coordinate conversion libraries ...');
            curdir=[handles.MuppetPath 'settings' filesep 'SuperTrans'];
            handles.EPSG=load([curdir filesep 'data' filesep 'EPSG.mat']);
%            close(wb);
        end
        [xl1,yl1]=convertCoordinates(handles.Figure(ifig).Axis(1).XMin,handles.Figure(ifig).Axis(1).YMin,handles.EPSG,'CS1.name',csname,'CS1.type',cstype,'CS2.name','WGS 84','CS2.type','geo');
        [xl2,yl2]=convertCoordinates(handles.Figure(ifig).Axis(1).XMax,handles.Figure(ifig).Axis(1).YMax,handles.EPSG,'CS1.name',csname,'CS1.type',cstype,'CS2.name','WGS 84','CS2.type','geo');
    end

    fid=fopen([AnimationSettings.FileName(1:end-4) '.kml'],'wt');

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

end

timeStep=AnimationSettings.timeStep/86400;

nrFrames=round((AnimationSettings.stopTime-AnimationSettings.startTime)/timeStep);

for iblock=1:nrFrames

    t=AnimationSettings.startTime+(iblock-1)*timeStep;

    % If combined datasets are present, update all dataset (yes, it's slow)

    UpdateAll=0;
    for j=1:NrSub
        for k=1:handles.Figure(ifig).Axis(j).Nr
            m=FindDatasetNr(handles.Figure(ifig).Axis(j).Plot(k).Name,Data);
            if Data(m).CombinedDataset==1
                UpdateAll=1;
            end
            if handles.Figure(ifig).Axis(j).Plot(k).TimeBar(1)>0
                %                 if isempty(AvailableMorphTimes)
                AvailableDate=str2double(datestr(t,'yyyymmdd'));
                AvailableTime=str2double(datestr(t,'HHMMSS'));
                %                 else
                %                     AvailableDate=str2double(datestr(AvailableMorphTimes(iblock),'yyyymmdd'));
                %                     AvailableTime=str2double(datestr(AvailableMorphTimes(iblock),'HHMMSS'));
                %                 end
                handles.Figure(ifig).Axis(j).Plot(k).TimeBar=[AvailableDate AvailableTime];
                %                 disp(datestr(AvailableTimes(iblock),'yyyymmdd HHMMSS'))
                %                 disp(handles.Figure(ifig).Axis(j).Plot(k).TimeBar);
            end
            %             if strcmpi(handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine,'plotcurvedarrows') || strcmpi(handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine,'plotcoloredcurvedarrows')
            %                 if handles.Figure(ifig).Axis(j).Plot(k).DDtCurVec>0
            %                     dt=86400*(AvailableTimes(2)-AvailableTimes(1));
            %                     n2=round(dt/handles.Figure(ifig).Axis(j).Plot(k).DDtCurVec);
            %                 else
            %                     n2=1;
            %                 end
            %                 if AnimationSettings.LastStep==AnimationSettings.FirstStep
            %                     n2=handles.Figure(ifig).Axis(j).Plot(k).NoFramesStationaryCurVec;
            %                 end
            %                 n2=max(n2,1);
            %             end
        end
    end

    Data2=Data;

    tFrac2=zeros(length(Data),1);
    tFrac1=tFrac2+1;
    
    if ~UpdateAll
        % Update datasets
        for j=1:NrSub
            for k=1:handles.Figure(ifig).Axis(j).Nr
 
                m=FindDatasetNr(handles.Figure(ifig).Axis(j).Plot(k).Name,Data);

                tFrac1(m)=1;
                tFrac2(m)=0;

                if Data(m).TC=='t'
                    % First see if available times exactly match current
                    % time
                    iTime=find(handles.Figure(ifig).Axis(j).dataset(k).availableTimes==t, 1);
                    if ~isempty(iTime)
                        Data(m).DateTime=Data(m).AvailableTimes(iTime);
                        Data=UpdateDatasets(Data,0,iTime,m);
                    else
                        iTime1=find(handles.Figure(ifig).Axis(j).dataset(k).availableTimes<t,1,'last');
                        Data=UpdateDatasets(Data,0,iTime1,m);
                        iTime2=find(handles.Figure(ifig).Axis(j).dataset(k).availableTimes>=t,1,'first');
                        Data2=UpdateDatasets(Data2,0,iTime2,m);

                        t1=handles.Figure(ifig).Axis(j).dataset(k).availableTimes(iTime1);
                        t2=handles.Figure(ifig).Axis(j).dataset(k).availableTimes(iTime2);
                        dt=t2-t1;
                        tFrac2(m)=(t-t1)/dt;
                        tFrac1(m)=1-tFrac2(m);

                        %                     if n2>1
                        %                         if iblock<AnimationSettings.LastStep
                        %                             Data2=UpdateDatasets(Data2,0,iblock+1,m);
                        %                         end
                        %                     end
                    end
                end
            end
        end
    else
        % Update all datasets
        nrd=NrAvailableDatasets; % All datasets
        nrc=NrCombinedDatasets;  % Combined datasets
        nrn=nrd-nrc; % 'Normal' datasets
        for m=1:nrn
            if Data(m).TC=='t'
                Data=UpdateDatasets(Data,0,iblock,m);
                if n2>1
                    if iblock<AnimationSettings.LastStep
                        Data2=UpdateDatasets(Data2,0,iblock+1,m);
                    end
                end
            end
        end
        for m=1:nrc
            ic=nrn+m;
            Data=Combine(Data,CombinedDatasetProperties,ic,m);
            if n2>1
                if iblock<AnimationSettings.LastStep
                    Data2=Combine(Data2,CombinedDatasetProperties,ic,m);
                end
            end
        end
    end

    %    for ii=1:n2
    %        iwb=iwb+1;

    % Export figure
    str=num2str(iblock+10000);
    figname=[AnimationSettings.Prefix str(2:end) '.png'];

    handles.Figure(ifig).FileName=figname;
    handles.Figure(ifig).Format='png';

    Data3=Data;

%    ttb=AvailableTimes(iblock);


    %        if n2>1
    for k=1:length(Data3)

        if tFrac1(k)<1

            f1=tFrac1(k);
            f2=tFrac2(k);

            if Data(k).TC=='t'
                if strcmpi(Data(k).Type,'2dvector')
                    Data3(k).u=f1*Data(k).u+f2*Data2(k).u;
                    Data3(k).v=f1*Data(k).v+f2*Data2(k).v;
                end
                if strcmpi(Data(k).Type,'2dscalar')
                    Data3(k).z=f1*Data(k).z+f2*Data2(k).z;
                    Data3(k).zz=f1*Data(k).z+f2*Data2(k).zz;
                end
            end
        end
    end

    for j=1:NrSub
        for k=1:handles.Figure(ifig).Axis(j).Nr
            if handles.Figure(ifig).Axis(j).Plot(k).TimeBar(1)>0
                AvailableDate=str2double(datestr(t,'yyyymmdd'));
                AvailableTime=str2double(datestr(t,'HHMMSS'));
                handles.Figure(ifig).Axis(j).Plot(k).TimeBar=[AvailableDate AvailableTime];
            end
        end
    end
    %end

    handles.DataProperties=Data3;

    ExportFigure(handles,ifig,'export');

    a = imread(figname,'png');

    if ~strcmpi(AnimationSettings.FileName(end-2:end),'gif')
        aaa=uint8(a(1:sz(1),1:sz(2),:));
        AviHandle = addframe(AviHandle,aaa); 
%        AviHandle = writeavi('addframe', AviHandle, aaa, iblock);
    else
        nf = nf+1;
        if nf==1
            [im,map] = rgb2ind(a,256,'nodither');
            itransp=find(sum(map,2)==3);
        end
        im(:,:,1,nf) = rgb2ind(a,map,'nodither');
    end

    clear a aa

    if AnimationSettings.makeKMZ

        fprintf(fid,'%s\n','    <GroundOverlay>');
        fprintf(fid,'%s\n','      <name>figure1.png</name>');

        fprintf(fid,'%s\n','      <TimeSpan>');
        dt=AvailableTimes(2)-AvailableTimes(1);

        fprintf(fid,'%s\n',['        <begin>' datestr(ttb,'yyyy-mm-ddTHH:MM:SSZ') '</begin>']);
        fprintf(fid,'%s\n',['        <end>' datestr(ttb+dt+0.0001,'yyyy-mm-ddTHH:MM:SSZ') '</end>']);
        fprintf(fid,'%s\n','      </TimeSpan>');

        fprintf(fid,'%s\n','      <Icon>');
        fprintf(fid,'%s\n',['        <href>' figname '</href>']);
        fprintf(fid,'%s\n','      </Icon>');
        fprintf(fid,'%s\n','      <LatLonBox>');
        fprintf(fid,'%s\n',['        <north>' num2str(yl2) '</north>']);
        fprintf(fid,'%s\n',['        <south>' num2str(yl1) '</south>']);
        fprintf(fid,'%s\n',['        <east>' num2str(xl2) '</east>']);
        fprintf(fid,'%s\n',['        <west>' num2str(xl1) '</west>']);
        fprintf(fid,'%s\n','      </LatLonBox>');
        fprintf(fid,'%s\n','    </GroundOverlay>');

        fgname{iblock}=figname;

    end


    if AnimationSettings.KeepFigures==0 && ~AnimationSettings.makeKMZ
        delete(figname);
    end

    str=['Generating AVI - frame ' num2str(iblock) ' of ' ...
        num2str(nrFrames) ' ...'];
    [hh,abort2]=awaitbar(iblock/(nrFrames),wb,str);

    if abort2 % Abort the process by clicking abort button
        break;
    end;
    if isempty(hh); % Break the process when closing the figure
        break;
    end;

    %    end

    if abort2 % Abort the process by clicking abort button
        break;
    end;
    if isempty(hh); % Break the process when closing the figure
        break;
    end;

end

if ~isempty(hh)
    close(wb);
end

if ~strcmpi(AnimationSettings.FileName(end-2:end),'gif')
    AviHandle = close(AviHandle);
%    AviHandle = writeavi('close', AviHandle);
else
    %    imwrite(im,map,'test.gif','DelayTime',1/AnimationSettings.FrameRate,'LoopCount',inf) %g443800
    imwrite(im,map,'test.gif','DelayTime',1/AnimationSettings.FrameRate,'LoopCount',inf,'TransparentColor',itransp-1,'DisposalMethod','restoreBG');
end

delete('curvecpos.*.dat');

if AnimationSettings.makeKMZ

    %% Further kml stuff

    fprintf(fid,'%s\n','  </Folder>');
    fprintf(fid,'%s\n','</Document>');
    fprintf(fid,'%s\n','</kml>');
    fclose(fid);

    zipfilename=[AnimationSettings.FileName(1:end-4) '.zip'];

    nf=length(fgname);
    fgname{nf+1}=[AnimationSettings.FileName(1:end-4) '.kml'];
    if handles.Figure(ifig).Axis(1).PlotColorBar;
        fgname{nf+2}='colorbar.png';
    end
    zip(zipfilename,fgname);

    kmzname=[AnimationSettings.FileName(1:end-4) '.kmz'];

    movefile(zipfilename,kmzname);
    delete([AnimationSettings.FileName(1:end-4) '.kml']);
    if exist('colorbar.png','file')
        delete('colorbar.png');
    end

    if AnimationSettings.KeepFigures==0
        for i=1:nf
            delete(fgname{i});
        end
    end

end
        