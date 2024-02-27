function muppet_saveSessionFileFigures(handles,fid,ifig,ilayout)

fig=handles.figures(ifig).figure;

txt=['Figure "' fig.name '"'];
fprintf(fid,'%s \n',txt);

txt='';
fprintf(fid,'%s \n',txt);

k=muppet_findIndex(handles.figureoption,'figureoption','name','papersize');
muppet_writeOption(handles.figureoption(k).figureoption,fig,fid,3,11);
k=muppet_findIndex(handles.figureoption,'figureoption','name','backgroundcolor');
muppet_writeOption(handles.figureoption(k).figureoption,fig,fid,3,11);

if ~strcmpi(fig.frame,'none')
    if fig.useframe
        k=muppet_findIndex(handles.figureoption,'figureoption','name','frame');
        muppet_writeOption(handles.figureoption(k).figureoption,fig,fid,3,11);
        k=muppet_findIndex(handles.figureoption,'figureoption','name','orientation');
        muppet_writeOption(handles.figureoption(k).figureoption,fig,fid,3,11);
        % Frame texts
        if ~ilayout
            kfr=strmatch(lower(fig.frame),lower(handles.frames.names),'exact');
            for ii=1:length(handles.frames.frame(kfr).frame.text)
                k=muppet_findIndex(handles.figureoption,'figureoption','name',['frametext' num2str(ii)]);
                muppet_writeOption(handles.figureoption(k).figureoption,fig,fid,3,11);
            end
        end
    end
end

txt='';
fprintf(fid,'%s \n',txt);

for isub=1:fig.nrsubplots
    muppet_saveSessionFileSubplots(handles,fid,ifig,isub,ilayout);
end

if ilayout==0
    str=fig.outputfile;
else
    str=['figure1.' fig.format];
end
txt=['   OutputFile   "' str '"'];
fprintf(fid,'%s \n',txt);

k=muppet_findIndex(handles.figureoption,'figureoption','name','format');
muppet_writeOption(handles.figureoption(k).figureoption,fig,fid,3,13);
k=muppet_findIndex(handles.figureoption,'figureoption','name','resolution');
muppet_writeOption(handles.figureoption(k).figureoption,fig,fid,3,13);
if fig.antialiasing
    k=muppet_findIndex(handles.figureoption,'figureoption','name','antialiasing');
    muppet_writeOption(handles.figureoption(k).figureoption,fig,fid,3,13);
end
k=muppet_findIndex(handles.figureoption,'figureoption','name','renderer');
muppet_writeOption(handles.figureoption(k).figureoption,fig,fid,3,13);

txt='';
fprintf(fid,'%s \n',txt);
txt='EndFigure';
fprintf(fid,'%s \n',txt);
