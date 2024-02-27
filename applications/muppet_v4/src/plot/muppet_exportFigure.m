function frame=muppet_exportFigure(handles,ifig,mode)

frame=[];

fig=handles.figures(ifig).figure;
fff=[];
try
    if strcmp(mode,'guiexport')
        wb = waitbox('Exporting figure...');
    elseif strcmp(mode,'print')
        wb = waitbox('Printing figure...');
    end
    
%     mode='xhtml';
    
    muppet_makeFigure(handles,ifig,mode);

    switch lower(mode)
        case{'print'}
            ii=printdlg('-setup',gcf);
        case{'export','guiexport'}
            fid=fopen(fig.outputfile,'w');
            if fid~=-1
                fclose(fid);
            end
            if fid==-1
                txt=strvcat(['The file ' fig.outputfile ' cannot be opened'],'Remove write protection');
                mp_giveWarning('WarningText',txt);
            else
                % Export figure
                if strcmpi(fig.orientation,'l')
                    set(gcf,'PaperOrientation','landscape');
                end

                aafac=1;
                if fig.antialiasing
                    aafac=2;
                end
                print (gcf,['-d' fig.format],['-r' num2str(fig.resolution*aafac)],['-' lower(fig.renderer)],fig.outputfile);
                if fig.antialiasing
                    aa_mvo(fig.outputfile,fig.outputfile);
                end
                
                %% Test for kml files
                if strcmpi(fig.backgroundcolor,'none')
                    a=imread(fig.outputfile);
                    itransp=real(sum(a,3)~=612);
                    imwrite(a,fig.outputfile,'alpha',itransp);
                end


            
            end
        case{'xhtml'}
            
            figure2xhtml('test/example1',gcf) 
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
    muppet_writeErrorLog(err);
end
if exist('wb') && ishandle(wb)
    close(wb);
end
if ishandle(999)
    close(999);
end
if ishandle(fff)
    close(fff);
end
