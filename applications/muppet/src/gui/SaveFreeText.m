function SaveFreeText(handles,fname);

szmax=0;
k=0;
for i=1:handles.NrAvailableDatasets
    if strcmp(lower(handles.DataProperties(i).Type),'freetext')
        k=k+1;
        str{k}=handles.DataProperties(i).String;
        pos{k}=handles.DataProperties(i).Position;
        rot(k)=handles.DataProperties(i).Rotation;
        cur(k)=handles.DataProperties(i).Curvature;
        szmax=max(szmax,length(str{k}));
    end
end

szmax=max(szmax,7);

if k>0
    spc=' ';
    fid=fopen(fname,'wt');
    spaces=repmat(spc,szmax,1);
    fprintf(fid,'%s %s %s\n','# String',spaces,'PositionX    PositionY   Rotation  Curvature');
    for i=1:k
        spaces=repmat(spc,3+szmax-length(str{i}),1);
        fprintf(fid,'"%s" %s %12.2f %12.2f %10.0f %10.0f\n',str{i},spaces,pos{i}(1),pos{i}(2),rot(i),cur(i));
    end
    fclose(fid);
end
