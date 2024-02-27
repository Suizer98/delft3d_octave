function muppet_makeAnimation(handles,ifig)

%persistent AVIOptions

animationsettings=handles.animationsettings;

% Make temporary datasets structure
datasets=handles.datasets;

% aviops=animationsettings.avioptions;

%AVIOptions.C24=animationsettings.avioptions;

if animationsettings.makekmz
    % Change plot positions etc. for KMZ option
    handles.figures(ifig).figure.width=handles.figures(ifig).figure.subplots(1).subplot.position(3);
    handles.figures(ifig).figure.height=handles.figures(ifig).figure.subplots(1).subplot.position(4);
    handles.figures(ifig).figure.backgroundcolor='none';
    handles.figures(ifig).figure.frame='none';
    handles.figures(ifig).figure.subplots(1).subplot.backgroundcolor='none';
    handles.figures(ifig).figure.subplots(1).subplot.position(1)=0;
    handles.figures(ifig).figure.subplots(1).subplot.position(2)=0;
    handles.figures(ifig).figure.subplots(1).subplot.drawbox=0;
    handles.figures(ifig).figure.subplots(1).subplot.colorbar.position=[-100 -100 0.5000 8];

    % Projection
    cstype=handles.figures(ifig).figure.subplots(1).subplot.coordinatesystem.type;
    if strcmpi(cstype,'geographic')
        % Assume WGS 84
        handles.figures(ifig).figure.subplots(1).subplot.projection='equirectangular';
    end

end

flist=dir('curvecpos*');
if ~isempty(flist)
    delete('curvecpos*');
end

%% Prepare first temporary figure
handles.figures(ifig).figure.units='centimeters';
handles.figures(ifig).figure.cm2pix=1;
handles.figures(ifig).figure.fontreduction=1;

switch lower(animationsettings.format)
    case{'mp4'}
        if length(animationsettings.avifilename)>4
            if ~strcmpi(animationsettings.avifilename(end-3:end),'.mp4')
                animationsettings.avifilename=[animationsettings.avifilename '.mp4'];
            end
        end
    case{'avi'}
        if length(animationsettings.avifilename)>4
            if ~strcmpi(animationsettings.avifilename(end-3:end),'.avi')
                animationsettings.avifilename=[animationsettings.avifilename '.avi'];
            end
        end
    case{'gif'}
        if length(animationsettings.avifilename)>4
            if ~strcmpi(animationsettings.avifilename(end-3:end),'.gif')
                animationsettings.avifilename=[animationsettings.avifilename '.gif'];
            end
        end
end

if exist(animationsettings.avifilename,'file')
    delete(animationsettings.avifilename);
end

% Determine frame size
fig=figure('visible','off');
set(fig,'PaperUnits',handles.figures(ifig).figure.units);

set(fig,'PaperSize', [handles.figures(ifig).figure.width handles.figures(ifig).figure.height]);
set(fig,'PaperPosition',[0 0 handles.figures(ifig).figure.width handles.figures(ifig).figure.height]);

set(fig,'Renderer',handles.figures(ifig).figure.renderer);
set(fig, 'InvertHardcopy', 'off');

if strcmpi(handles.figures(ifig).figure.orientation(1),'l')
    set(fig,'PaperOrientation','landscape');
end

exportfig (fig,'tmpavi.png','Format','png','FontSize',[1],'color','cmyk','Resolution',handles.figures(ifig).figure.resolution, ...
    'Renderer',handles.figures(ifig).figure.renderer);
close(fig);
a = imread('tmpavi.png');
sz=size(a);
sz(1)=4*floor(sz(1)/4);
sz(2)=4*floor(sz(2)/4);
a=a(1:sz(1),1:sz(2),:);

if exist('tmpavi.png','file')
    delete('tmpavi.png');
end

% Open animation file
if ~isempty(animationsettings.avifilename)
    % No movie is made when filename is empty
    switch lower(animationsettings.format)
        case{'mp4'}
            avihandle=VideoWriter(animationsettings.avifilename,'MPEG-4');
            avihandle.FrameRate=animationsettings.framerate;
            avihandle.Quality=animationsettings.quality;
            open(avihandle);
        case{'avi'}
            
%             for itry=1:10
%                 avihandle = avi('initialize');
%                 itry
%                 pause(0.1);
%                 if avihandle.CPointer>0
%                     break
%                 end
%             end
%             avihandle = avi('open', avihandle,animationsettings.avifilename);
%             avihandle = avi('addvideo', avihandle, animationsettings.framerate, a);

            avihandle=VideoWriter(animationsettings.avifilename,'Motion JPEG AVI');
            avihandle.FrameRate=animationsettings.framerate;
            avihandle.Quality=animationsettings.quality;
            open(avihandle);
    
    end
end
        
wb = awaitbar(0,'Generating AVI...');

try
    % If anything fails, at least close waitbar and animation
    
    hh=[];
    
    nf=0;
    
    % Determine timestep and number of frames
    timestep=animationsettings.timestep/86400;
    
    % Flight path
    if animationsettings.flightpath
        if isempty(animationsettings.flightpathxml)
            muppet_giveWarning('text','Flight path selected, but no flight path xml file specified!');
            animationsettings.flightpath=0;
        else
            flightpath=xml2struct(animationsettings.flightpathxml);
            times=animationsettings.starttime:timestep:animationsettings.stoptime;
            for j=1:handles.figures(ifig).figure.nrsubplots
                dataaspectratio=handles.figures(ifig).figure.subplots(j).subplot.dataaspectratio;
                [cameraposition(j).position,cameratarget(j).target]=flightpathspline(flightpath,times,dataaspectratio);
            end
        end
    end
    
    nrframes=max(round((animationsettings.stoptime-animationsettings.starttime)/timestep)+1,1);
    
    for iblock=1:nrframes
       
        % Update time
        t=animationsettings.starttime+(iblock-1)*timestep;
        
        %% Update datasets
        
        % First all regular datasets
        for id=1:length(datasets)
            if ~datasets(id).dataset.combineddataset
                % Check to see if this a time-varying dataset
                if datasets(id).dataset.tc=='t'
                    % First see if available times exactly match current
                    % time
                    itime=find(abs(datasets(id).dataset.times-t)<1/864000, 1, 'first');
                     if ~isempty(itime)
                         % Exact time found
                         datasets(id).dataset.timestep=itime;
                         datasets(id).dataset.time=datasets(id).dataset.times(itime);
                         datasets(id).dataset=feval(datasets(id).dataset.callback,'import',datasets(id).dataset);
                     else
                        % Averaging between surrounding times
                        itime1=find(datasets(id).dataset.availabletimes-1e-4<t,1,'last');
                        if isempty(itime1)
                            % t bigger than any of the available times
                            if datasets(id).dataset.availabletimes(end)<t
                                itime1=length(datasets(id).dataset.availabletimes);
                            else
                                itime1=1;
                            end
                        end
                        itime2=find(datasets(id).dataset.availabletimes+1e-4>=t,1,'first');
                        if isempty(itime2)
                            % t smaller than any of the available times
                            % t bigger than any of the available times
                            if datasets(id).dataset.availabletimes(end)<t
                                itime2=length(datasets(id).dataset.availabletimes);
                            else
                                itime2=1;
                            end
                        end
                        
                        t1=datasets(id).dataset.availabletimes(itime1);
                        t2=datasets(id).dataset.availabletimes(itime2);

                        if itime1==itime2
                            datasets(id).dataset.timestep=itime1;
                            datasets(id).dataset.time=datasets(id).dataset.times(itime1);
                            datasets(id).dataset=feval(datasets(id).dataset.callback,'import',datasets(id).dataset);
                        else
                            
                            data1=datasets(id).dataset;
                            data1.time=t1;
                            data1.timestep=itime1;
                            data1=feval(data1.callback,'import',data1);
                            
                            data2=datasets(id).dataset;
                            data2.time=t2;
                            data2.timestep=itime2;
                            data2=feval(data2.callback,'import',data2);
                            
                            dt=t2-t1;
                            tfrac2=(t-t1)/dt;
                            tfrac1=1-tfrac2;
                            datasets(id).dataset.time = t;
                            switch lower(datasets(id).dataset.type)
                                case{'vector2d2dxy'}
                                    datasets(id).dataset.u  = tfrac1*data1.u  + tfrac2*data2.u;
                                    datasets(id).dataset.v  = tfrac1*data1.v  + tfrac2*data2.v;
                                case{'scalar2dxy'}
                                    datasets(id).dataset.z  = tfrac1*data1.z  + tfrac2*data2.z;
                                    datasets(id).dataset.zz = tfrac1*data1.zz + tfrac2*data2.zz;
                                case{'scalar2duxy'}
                                    datasets(id).dataset.z  = tfrac1*data1.z  + tfrac2*data2.z;
                            end
                        end
                        
                     end
                end
            end
        end
        
        % And now the combined datasets
        for id=1:length(datasets)
            if datasets(id).dataset.combineddataset
                % Check to see if this a time-varying dataset
                if datasets(id).dataset.tc=='t'
                    datasets=muppet_combineDataset(datasets,id);
                end
            end
        end
        
        %% Update time bars
        for j=1:handles.figures(ifig).figure.nrsubplots
            for k=1:handles.figures(ifig).figure.subplots(j).subplot.nrdatasets
                handles.figures(ifig).figure.subplots(j).subplot.datasets(k).dataset.timebar.time=t;
                handles.figures(ifig).figure.subplots(j).subplot.datasets(k).dataset.timemarker.time=t;
            end
        end
        handles.datasets=datasets;
        
        %% Camera
        if animationsettings.flightpath
            for j=1:handles.figures(ifig).figure.nrsubplots
                handles.figures(ifig).figure.subplots(j).subplot.viewmode3d=1;
                handles.figures(ifig).figure.subplots(j).subplot.cameraposition=cameraposition(j).position(iblock,:);
                handles.figures(ifig).figure.subplots(j).subplot.cameratarget=cameratarget(j).target(iblock,:);
            end
        end
        
        %% Make the figure
        
        % Figure name and format
        str=num2str(iblock+10000);
        figname=[animationsettings.prefix str(2:end) '.png'];
        handles.figures(ifig).figure.filename=figname;
        handles.figures(ifig).figure.outputfile=figname;
        handles.figures(ifig).figure.format='png';
        
        % And export the figure
        muppet_exportFigure(handles,ifig,'export');
        
        %% Add figure to animation
        
        % No avi file is made if avi filename is empty
        if  ~isempty(animationsettings.avifilename)
            a = imread(figname,'png');
            switch lower(animationsettings.format)
                case{'mp4'}
                    a=a(1:sz(1),1:sz(2),:);
%                    F=im2frame(a,jet(256));
%                    F = im2frame(a);
%                    writeVideo(avihandle,F);
                    writeVideo(avihandle,a);
%                    imgs(:,:,:,iblock)=a;
                case{'avi'}
%                     aaa=uint8(a(1:sz(1),1:sz(2),:));
%                     avihandle = avi('addframe', avihandle, aaa, iblock);
%                     clear aaa
                    a=a(1:sz(1),1:sz(2),:);
                    writeVideo(avihandle,a);
                case{'gif'}
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
        if animationsettings.keepfigures==0 && ~animationsettings.makekmz
            delete(figname);
        end
        
        %% Update waitbar
        str=['Generating AVI - frame ' num2str(iblock) ' of ' ...
            num2str(nrframes) ' ...'];
        [hh,abort2]=awaitbar(iblock/nrframes,wb,str);
        
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

    % Close animation
    closeanimation(avihandle,animationsettings.format);    

    % Delete curvec temporary files
    delete('curvecpos.*.dat');
    
    %% KMZ file
    if animationsettings.makekmz
        
        plt=handles.figures(ifig).figure.subplots(1).subplot;
        
        % File names
        for iblock=1:nrframes
            str=num2str(iblock+10000);
            fignames{iblock}=[animationsettings.prefix str(2:end) '.png'];
            tms(iblock)=animationsettings.starttime+(iblock-1)*timestep;
        end
        dt=timestep;
        % Make colorbar
        colorbarfile='';
        if plt.plotcolorbar;
            colorbarfile='colorbar.png';
            if plt.colorbar.decimals>=0
                dec=plt.colorbar.decimals;
            else
                dec=0;
            end
            cosmos_makeColorBar(colorbarfile,'contours',plt.cmin:plt.cstep:plt.cmax,'colormap',plt.colormap,'label',plt.colorbar.label,'decimals',dec);
        end
        % Bounding box
        csname=plt.coordinatesystem.name;
        cstype=plt.coordinatesystem.type;
        if strcmpi(csname,'unknown')
        else
            if ~isfield(handles,'epsg')
%                handles.epsg=load([handles.settingsdir 'SuperTrans' filesep 'data' filesep 'EPSG.mat']);
                handles.epsg=load('EPSG.mat');
            end
            plt=muppet_updateLimits(plt,'setprojectionlimits');
            [xl1,yl1]=convertCoordinates(plt.xminproj,plt.yminproj,handles.epsg,'CS1.name',csname,'CS1.type',cstype,'CS2.name','WGS 84','CS2.type','geo');
            [xl2,yl2]=convertCoordinates(plt.xmaxproj,plt.ymaxproj,handles.epsg,'CS1.name',csname,'CS1.type',cstype,'CS2.name','WGS 84','CS2.type','geo');
        end
        fname=[handles.animationsettings.avifilename(1:end-4) '.kml'];
        makeKMZ(fname,xl1,xl2,yl1,yl2,fignames,tms,dt,colorbarfile);
        delete('colorbar.png');
        % Delete existing figures
        if handles.animationsettings.keepfigures==0
            for ii=1:nrframes
                delete(fignames{ii});
            end
        end
    end
    
catch
    closeanimation(avihandle,animationsettings.format);
    if ishandle(wb)
        close(wb);
    end
    muppet_giveWarning('text','Something went wrong while generating avi file');
end
%%
function makeKMZ(fname,xl1,xl2,yl1,yl2,fignames,tms,dt,colorbarfile)

fid=fopen(fname,'wt');
fprintf(fid,'%s\n','<kml xmlns="http://www.opengis.net/kml/2.2">');
fprintf(fid,'%s\n','<Document>');
if ~isempty(colorbarfile)
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
    fprintf(fid,'%s\n',['        <href>' fignames{iblock} '</href>']);
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
    fignames{nf+2}=colorbarfile;
end
zip(zipfilename,fignames);

kmzname=[fname(1:end-4) '.kmz'];

movefile(zipfilename,kmzname);
delete(fname);
if exist(colorbarfile,'file')
    delete(colorbarfile);
end

%%
function closeanimation(h,fmt)

try
    switch lower(fmt)
        case{'mp4'}
            close(h);
        case{'avi'}
%             h=avi('close', h);
%             flag=avi('finalize',h) ;
            close(h);
        case{'gif'}
            % Try to make animated gif (not very succesful so far)
            imwrite(im,map,'test.gif','DelayTime',1/animationsettings.framerate,'LoopCount',inf,'TransparentColor',itransp-1,'DisposalMethod','restoreBG');
    end
end
