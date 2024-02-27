function frame=ExportFigure(handles,ifig,mode)

frame=[];

try
    if strcmp(mode,'guiexport')
        wb = waitbox('Exporting figure...');
    elseif strcmp(mode,'print')
        wb = waitbox('Printing figure...');
    end
    %
    MakeFigure(handles,ifig,mode);
    %
    switch lower(mode)
        case{'print'}
            ii=printdlg('-setup',gcf);
        case{'export','guiexport'}
            fid=fopen(handles.Figure(ifig).FileName,'w');
            if fid~=-1
                fclose(fid);
            end
            if fid==-1
                txt=strvcat(['The file ' handles.Figure(ifig).FileName ' cannot be opened'],'Remove write protection');
                mp_giveWarning('WarningText',txt);
            else
                % Export figure
                if strcmpi(handles.Figure(ifig).Orientation,'l')
                    set(gcf,'PaperOrientation','landscape');
                end
%                gcf2=myaa(4,'standard','figure');
%myaa; 
                print (gcf,['-d' handles.Figure(ifig).Format],['-r' num2str(handles.Figure(ifig).Resolution)], ...
                    ['-' lower(handles.Figure(ifig).Renderer)], ...
                    handles.Figure(ifig).FileName);

                %% Test for kml files
                if strcmpi(handles.Figure(ifig).BackgroundColor,'none')
                    a=imread(handles.Figure(ifig).FileName);
                    itransp=real(sum(a,3)~=612);
%                    itransp=real(sum(a,3)~=765);
%                 imwrite(a,handles.Figure(ifig).FileName,'transparency',squeeze(double(a(1,1,:))/255));
                    imwrite(a,handles.Figure(ifig).FileName,'alpha',itransp);
                end

%             [xl1,yl1]=convertCoordinates(handles.Figure(ifig).Axis(1).XMin,handles.Figure(ifig).Axis(1).YMin,'CS1.name','Amersfoort / RD New','CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
%             [xl2,yl2]=convertCoordinates(handles.Figure(ifig).Axis(1).XMax,handles.Figure(ifig).Axis(1).YMax,'CS1.name','Amersfoort / RD New','CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
% 
%            fid=fopen([handles.Figure(ifig).FileName '.kml'],'wt');
%            fprintf(fid,'%s\n','<kml xmlns="http://www.opengis.net/kml/2.2">');
%            fprintf(fid,'%s\n','<Document>');
%            fprintf(fid,'%s\n','  <ScreenOverlay id="colorbar">');
%            fprintf(fid,'%s\n','    <Icon>');
%            fprintf(fid,'%s\n','      <href>hs.colorbar.png</href>');
%            fprintf(fid,'%s\n','    </Icon>');
%            fprintf(fid,'%s\n','    <overlayXY x="1" y="1" xunits="pixels" yunits="pixels"/>');
%            fprintf(fid,'%s\n','    <screenXY x="10" y="10" xunits="pixels" yunits="pixels"/>');
%            fprintf(fid,'%s\n','    <rotation>0</rotation>');
%            fprintf(fid,'%s\n','    <size x="0" y="0" xunits="pixels" yunits="pixels"/>');
%            fprintf(fid,'%s\n','  </ScreenOverlay>');
%            fprintf(fid,'%s\n','  <Folder>');
%            fprintf(fid,'%s\n','    <GroundOverlay>');
%            fprintf(fid,'%s\n','      <name>figure1.png</name>');
%            fprintf(fid,'%s\n','      <Icon>');
%            fprintf(fid,'%s\n',['        <href>' handles.Figure(ifig).FileName '</href>']);
%            fprintf(fid,'%s\n','      </Icon>');
%            fprintf(fid,'%s\n','      <LatLonBox>');
%            fprintf(fid,'%s\n',['        <north>' num2str(yl2) '</north>']);
%            fprintf(fid,'%s\n',['        <south>' num2str(yl1) '</south>']);
%            fprintf(fid,'%s\n',['        <east>' num2str(xl2) '</east>']);
%            fprintf(fid,'%s\n',['        <west>' num2str(xl1) '</west>']);
%            fprintf(fid,'%s\n','      </LatLonBox>');
%            fprintf(fid,'%s\n','    </GroundOverlay>');
%            fprintf(fid,'%s\n','  </Folder>');
%            fprintf(fid,'%s\n','</Document>');
%            fprintf(fid,'%s\n','</kml>');
%            fclose(fid);
            
%               makeColorBar(handles,'colorbar.png',[handles.Figure(1).Axis(1).CMin handles.Figure(1).Axis(1).CStep handles.Figure(1).Axis(1).CMax],handles.Figure(1).Axis(1).Plot(1).ColorMap,handles.Figure(1).Axis(1).ColorBarLabel);

            
            end
%         case{'frame'}
%             frame = getframe;
    end
catch
    h=findobj('Tag','waitbox');
    close(h);
    err=lasterror;
    str{1}=['An error occured in function: '  err.stack(1).name];
    str{2}=['Error: '  err.message];
    str{3}=['File: ' err.stack(1).file];
    str{4}=['Line: ' num2str(err.stack(1).line)];
    str{5}=['See muppet.err for more information'];
    strv=strvcat(str{1},str{2},str{3},str{4},str{5});
    if strcmp(mode,'guiexport')
        uiwait(errordlg(strv,'Error','modal'));
    end
%    disp(err)
    WriteErrorLog(err);
end
if exist('wb') && ishandle(wb)
    close(wb);
end
if ishandle(999)
    close(999);
end
