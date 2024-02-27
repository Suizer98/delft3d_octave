function SaveSessionFileDatasets(handles,fid)

for i=1:handles.NrAvailableDatasets

    if handles.DataProperties(i).CombinedDataset==0

        txt=['Dataset   "' handles.DataProperties(i).Name '"'];
        fprintf(fid,'%s \n',txt);

        txt=['   FileType    "' handles.DataProperties(i).FileType '"'];
        fprintf(fid,'%s \n',txt);
        
        if ~strcmpi(handles.DataProperties(i).FileType,'freetext') && ~strcmpi(handles.DataProperties(i).FileType,'freehanddrawing')
            PathName=handles.DataProperties(i).PathName;
            if strcmp(handles.CurrentPath,handles.DataProperties(i).PathName)
                PathName='';
            end
            txt=['   File        "' PathName handles.DataProperties(i).FileName '"'];
            fprintf(fid,'%s \n',txt);
        end
        
        switch lower(handles.DataProperties(i).FileType),

            case {'tekalmap'}
                if handles.DataProperties(i).ColumnX~=1
                    txt=['   ColumnX     ' num2str(handles.DataProperties(i).ColumnX)];
                    fprintf(fid,'%s \n',txt);
                end
                if handles.DataProperties(i).ColumnY~=2
                    txt=['   ColumnY     ' num2str(handles.DataProperties(i).ColumnY)];
                    fprintf(fid,'%s \n',txt);
                end
                txt=['   Column      ' num2str(handles.DataProperties(i).Column)];
                fprintf(fid,'%s \n',txt);
                txt=['   Block       ' num2str(handles.DataProperties(i).Block)];
                fprintf(fid,'%s \n',txt);

                if handles.DataProperties(i).M1>0
                    if handles.DataProperties(i).M1==handles.DataProperties(i).M2
                        txt=['   M           ' num2str(handles.DataProperties(i).M1)];
                    else
                        if handles.DataProperties(i).MStep==1
                            txt=['   M           ' num2str(handles.DataProperties(i).M1),' ',num2str(handles.DataProperties(i).M2)];
                        else
                            txt=['   M           ' num2str(handles.DataProperties(i).M1),' ',num2str(handles.DataProperties(i).MStep),' ',num2str(handles.DataProperties(i).M2)];
                        end
                    end
                    fprintf(fid,'%s \n',txt);
                end

                if handles.DataProperties(i).N1>0
                    if handles.DataProperties(i).N1==handles.DataProperties(i).N2
                        txt=['   N           ' num2str(handles.DataProperties(i).N1)];
                    else
                        if handles.DataProperties(i).NStep==1
                            txt=['   N           ' num2str(handles.DataProperties(i).N1),' ',num2str(handles.DataProperties(i).N2)];
                        else
                            txt=['   N           ' num2str(handles.DataProperties(i).N1),' ',num2str(handles.DataProperties(i).NStep),' ',num2str(handles.DataProperties(i).N2)];
                        end
                    end
                    fprintf(fid,'%s \n',txt);
                end

                if handles.DataProperties(i).M1>0
                    if handles.DataProperties(i).M1==handles.DataProperties(i).M2
                        txt=['   XCoordinate "' handles.DataProperties(i).XCoordinate '"'];
                        fprintf(fid,'%s \n',txt);
                    end
                end

                if handles.DataProperties(i).N1>0
                    if handles.DataProperties(i).N1==handles.DataProperties(i).N2
                        txt=['   XCoordinate "' handles.DataProperties(i).XCoordinate '"'];
                        fprintf(fid,'%s \n',txt);
                    end
                end
                
%                 if handles.DataProperties(i).N1>0
%                     txt=['   N           ' num2str(handles.DataProperties(i).N1),' ',num2str(handles.DataProperties(i).N2)];
%                     fprintf(fid,'%s \n',txt);
%                 end

                if handles.DataProperties(i).MultiplyX~=1.0
                    txt=['   MultiplyX   ' num2str(handles.DataProperties(i).MultiplyX)];
                    fprintf(fid,'%s \n',txt);
                end
                if handles.DataProperties(i).AddX~=0.0
                    txt=['   AddX        ' num2str(handles.DataProperties(i).AddX)];
                    fprintf(fid,'%s \n',txt);
                end
                
            case {'tekalvector'}
                if handles.DataProperties(i).ColumnX~=1
                    txt=['   ColumnX     ' num2str(handles.DataProperties(i).ColumnX)];
                    fprintf(fid,'%s \n',txt);
                end
                if handles.DataProperties(i).ColumnY~=2
                    txt=['   ColumnY     ' num2str(handles.DataProperties(i).ColumnY)];
                    fprintf(fid,'%s \n',txt);
                end
                if handles.DataProperties(i).ColumnU~=3
                    txt=['   ColumnU     ' num2str(handles.DataProperties(i).ColumnU)];
                    fprintf(fid,'%s \n',txt);
                end
                if handles.DataProperties(i).ColumnV~=4
                    txt=['   ColumnV     ' num2str(handles.DataProperties(i).ColumnV)];
                    fprintf(fid,'%s \n',txt);
                end
                txt=['   Block       ' num2str(handles.DataProperties(i).Block)];
                fprintf(fid,'%s \n',txt);

                if handles.DataProperties(i).M1>0
                    if handles.DataProperties(i).M1==handles.DataProperties(i).M2
                        txt=['   M           ' num2str(handles.DataProperties(i).M1)];
                    else
                        if handles.DataProperties(i).MStep==1
                            txt=['   M           ' num2str(handles.DataProperties(i).M1),' ',num2str(handles.DataProperties(i).M2)];
                        else
                            txt=['   M           ' num2str(handles.DataProperties(i).M1),' ',num2str(handles.DataProperties(i).MStep),' ',num2str(handles.DataProperties(i).M2)];
                        end
                    end
                    fprintf(fid,'%s \n',txt);
                end

                if handles.DataProperties(i).N1>0
                    if handles.DataProperties(i).N1==handles.DataProperties(i).N2
                        txt=['   N           ' num2str(handles.DataProperties(i).N1)];
                    else
                        if handles.DataProperties(i).NStep==1
                            txt=['   N           ' num2str(handles.DataProperties(i).N1),' ',num2str(handles.DataProperties(i).N2)];
                        else
                            txt=['   N           ' num2str(handles.DataProperties(i).N1),' ',num2str(handles.DataProperties(i).NStep),' ',num2str(handles.DataProperties(i).N2)];
                        end
                    end
                    fprintf(fid,'%s \n',txt);
                end

                if handles.DataProperties(i).M1>0
                    if handles.DataProperties(i).M1==handles.DataProperties(i).M2
                        txt=['   XCoordinate "' handles.DataProperties(i).XCoordinate '"'];
                        fprintf(fid,'%s \n',txt);
                    end
                end

                if handles.DataProperties(i).N1>0
                    if handles.DataProperties(i).N1==handles.DataProperties(i).N2
                        txt=['   XCoordinate "' handles.DataProperties(i).XCoordinate '"'];
                        fprintf(fid,'%s \n',txt);
                    end
                end
                
            case {'samples'}
                txt=['   Column      ' num2str(handles.DataProperties(i).Column)];
                fprintf(fid,'%s \n',txt);

            case {'tekalxy'}
                txt=['   Column      ' num2str(handles.DataProperties(i).Column)];
                fprintf(fid,'%s \n',txt);
                if handles.DataProperties(i).ColumnX>1
                    txt=['   ColumnX     ' num2str(handles.DataProperties(i).ColumnX)];
                    fprintf(fid,'%s \n',txt);
                end
                txt=['   Block       ' num2str(handles.DataProperties(i).Block)];
                fprintf(fid,'%s \n',txt);
                if handles.DataProperties(i).MultiplyX~=1.0
                    txt=['   MultiplyX   ' num2str(handles.DataProperties(i).ColumnX)];
                    fprintf(fid,'%s \n',txt);
                end

            case {'bar'}
                txt=['   Column      ' num2str(handles.DataProperties(i).Column)];
                fprintf(fid,'%s \n',txt);

            case {'trianaa'}
                txt=['   Column      ' num2str(handles.DataProperties(i).Column)];
                fprintf(fid,'%s \n',txt);
                txt=['   Component   "' handles.DataProperties(i).Component '"'];
                fprintf(fid,'%s \n',txt);
                txt=['   TrianaBFile "' handles.DataProperties(i).TrianaBFile '"'];
                fprintf(fid,'%s \n',txt);

            case {'trianab'}
                txt=['   Column      ' num2str(handles.DataProperties(i).Column)];
                fprintf(fid,'%s \n',txt);
                txt=['   Location    "' handles.DataProperties(i).Location '"'];
                fprintf(fid,'%s \n',txt);

            case {'tekaltime'}
                txt=['   Column      ' num2str(handles.DataProperties(i).Column)];
                fprintf(fid,'%s \n',txt);
                txt=['   Block       ' num2str(handles.DataProperties(i).Block)];
                fprintf(fid,'%s \n',txt);

            case {'tekaltimestack'}
                txt=['   Block       ' num2str(handles.DataProperties(i).Block)];
                fprintf(fid,'%s \n',txt);

            case {'d3dboundaryconditions'}
                txt=['   Location    "' handles.DataProperties(i).Location   '"'];
                fprintf(fid,'%s \n',txt);
                txt=['   Parameter   "' handles.DataProperties(i).Parameter  '"'];
                fprintf(fid,'%s \n',txt);
                
            case {'curvedvectors'}
                txt=['   Block       ' num2str(handles.DataProperties(i).Block)];
                fprintf(fid,'%s \n',txt);
                datestring=[datestr(handles.DataProperties(i).DateTime,'yyyymmdd') ' ' datestr(handles.DataProperties(i).DateTime,'HHMMSS')];
                txt=['   Time        ' datestring];
                fprintf(fid,'%s \n',txt);

            case {'delft3d','delwaq','simonasds'}

               
                if isfield(handles.DataProperties(i),'LGAFile')
                    if size(handles.DataProperties(i).LGAFile,2)>0
                        txt=['   LGAFile     "' handles.DataProperties(i).LGAFile '"'];
                        fprintf(fid,'%s \n',txt);
                    end
                end

                txt=['   Parameter   "' handles.DataProperties(i).Parameter '"'];
                fprintf(fid,'%s \n',txt);
                
                if strcmpi(handles.DataProperties(i).SubField,'none')==0
                    txt=['   SubField    "' handles.DataProperties(i).SubField '"'];
                    fprintf(fid,'%s \n',txt);
                end
                
                if strcmp(handles.DataProperties(i).Component,'magnitude')==0
                    txt=['   Component   "' handles.DataProperties(i).Component '"'];
                    fprintf(fid,'%s \n',txt);
                end

                if size(handles.DataProperties(i).Station,2)>0
                    txt=['   Station     "' handles.DataProperties(i).Station '"'];
                    fprintf(fid,'%s \n',txt);
                end

                if handles.DataProperties(i).DateTime>0
                    datestring=[datestr(handles.DataProperties(i).DateTime,'yyyymmdd') ' ' datestr(handles.DataProperties(i).DateTime,'HHMMSS')];
                    txt=['   Time        ' datestring];
                    fprintf(fid,'%s \n',txt);
                end

                if handles.DataProperties(i).K1>0
                    txt=['   K           ' num2str(handles.DataProperties(i).K1),' ',num2str(handles.DataProperties(i).K2)];
                    fprintf(fid,'%s \n',txt);
                end                

%                 if strcmpi(handles.DataProperties(i).Type,'timestack')
%                     txt=['   K           ' num2str(handles.DataProperties(i).K1),' ',num2str(handles.DataProperties(i).K2)];
%                     fprintf(fid,'%s \n',txt);
%                 end                
                
                if handles.DataProperties(i).M1>0
                    if handles.DataProperties(i).M1==handles.DataProperties(i).M2
                        txt=['   M           ' num2str(handles.DataProperties(i).M1)];
                    else
                        if handles.DataProperties(i).MStep==1
                            txt=['   M           ' num2str(handles.DataProperties(i).M1),' ',num2str(handles.DataProperties(i).M2)];
                        else
                            txt=['   M           ' num2str(handles.DataProperties(i).M1),' ',num2str(handles.DataProperties(i).MStep),' ',num2str(handles.DataProperties(i).M2)];
                        end
                    end
                    fprintf(fid,'%s \n',txt);
                end

                if handles.DataProperties(i).N1>0
                    if handles.DataProperties(i).N1==handles.DataProperties(i).N2
                        txt=['   N           ' num2str(handles.DataProperties(i).N1)];
                    else
                        if handles.DataProperties(i).NStep==1
                            txt=['   N           ' num2str(handles.DataProperties(i).N1),' ',num2str(handles.DataProperties(i).N2)];
                        else
                            txt=['   N           ' num2str(handles.DataProperties(i).N1),' ',num2str(handles.DataProperties(i).NStep),' ',num2str(handles.DataProperties(i).N2)];
                        end
                    end
                    fprintf(fid,'%s \n',txt);
                end

                if handles.DataProperties(i).M1>0
                    if handles.DataProperties(i).M1==handles.DataProperties(i).M2
                        txt=['   XCoordinate "' handles.DataProperties(i).XCoordinate '"'];
                        fprintf(fid,'%s \n',txt);
                    end
                end

                if handles.DataProperties(i).N1>0
                    if handles.DataProperties(i).N1==handles.DataProperties(i).N2
                        txt=['   XCoordinate "' handles.DataProperties(i).XCoordinate '"'];
                        fprintf(fid,'%s \n',txt);
                    end
                end
                
                if handles.DataProperties(i).T1>0
                    if handles.DataProperties(i).T1==handles.DataProperties(i).T2
                        txt=['   T           ' num2str(handles.DataProperties(i).T1)];
                    else
                        if handles.DataProperties(i).TStep==1
                            txt=['   T           ' num2str(handles.DataProperties(i).T1),' ',num2str(handles.DataProperties(i).T2)];
                        else
                            txt=['   T           ' num2str(handles.DataProperties(i).T1),' ',num2str(handles.DataProperties(i).TStep),' ',num2str(handles.DataProperties(i).T2)];
                        end
                    end
                    fprintf(fid,'%s \n',txt);
                end
                
            case {'unibest','durosta'}

                txt=['   Parameter   "' handles.DataProperties(i).Parameter '"'];
                fprintf(fid,'%s \n',txt);
                
                if handles.DataProperties(i).M1>0
                    if handles.DataProperties(i).M1==handles.DataProperties(i).M2
                        txt=['   M           ' num2str(handles.DataProperties(i).M1)];
                    else
                        if handles.DataProperties(i).MStep==1
                            txt=['   M           ' num2str(handles.DataProperties(i).M1),' ',num2str(handles.DataProperties(i).M2)];
                        else
                            txt=['   M           ' num2str(handles.DataProperties(i).M1),' ',num2str(handles.DataProperties(i).MStep),' ',num2str(handles.DataProperties(i).M2)];
                        end
                    end
                    fprintf(fid,'%s \n',txt);
                end

                if handles.DataProperties(i).T1>0 || handles.DataProperties(i).DateTime>100000
                    if handles.DataProperties(i).DateTime>100000
                        datestring=[datestr(handles.DataProperties(i).DateTime,'yyyymmdd') ' ' datestr(handles.DataProperties(i).DateTime,'HHMMSS')];
                        txt=['   Time        ' datestring];
                        fprintf(fid,'%s \n',txt);
                    else
                        if handles.DataProperties(i).T1==handles.DataProperties(i).T2
                            txt=['   T           ' num2str(handles.DataProperties(i).T1)];
                        else
                            if handles.DataProperties(i).TStep==1
                                txt=['   T           ' num2str(handles.DataProperties(i).T1),' ',num2str(handles.DataProperties(i).T2)];
                            else
                                txt=['   T           ' num2str(handles.DataProperties(i).T1),' ',num2str(handles.DataProperties(i).TStep),' ',num2str(handles.DataProperties(i).T2)];
                            end
                        end
                        fprintf(fid,'%s \n',txt);
                    end
                end

            case {'xbeach'}
                
                txt=['   Parameter   "' handles.DataProperties(i).Parameter '"'];
                fprintf(fid,'%s \n',txt);

%                 txt=['   XYFile      "' handles.DataProperties(i).XYFile '"'];
%                 fprintf(fid,'%s \n',txt);
% 
                if handles.DataProperties(i).DateTime>0
                    datestring=[datestr(handles.DataProperties(i).DateTime,'yyyymmdd') ' ' datestr(handles.DataProperties(i).DateTime,'HHMMSS')];
                    txt=['   Time        ' datestring];
                    fprintf(fid,'%s \n',txt);
                end

%                 if handles.DataProperties(i).K1>0
%                     txt=['   K           ' num2str(handles.DataProperties(i).K1),' ',num2str(handles.DataProperties(i).K2)];
%                     fprintf(fid,'%s \n',txt);
%                 end                
% 
                if handles.DataProperties(i).M1>0
                    if handles.DataProperties(i).M1==handles.DataProperties(i).M2
                        txt=['   M           ' num2str(handles.DataProperties(i).M1)];
                    else
                        if handles.DataProperties(i).MStep==1
                            txt=['   M           ' num2str(handles.DataProperties(i).M1),' ',num2str(handles.DataProperties(i).M2)];
                        else
                            txt=['   M           ' num2str(handles.DataProperties(i).M1),' ',num2str(handles.DataProperties(i).MStep),' ',num2str(handles.DataProperties(i).M2)];
                        end
                    end
                    fprintf(fid,'%s \n',txt);
                end

                if handles.DataProperties(i).N1>0
                    if handles.DataProperties(i).N1==handles.DataProperties(i).N2
                        txt=['   N           ' num2str(handles.DataProperties(i).N1)];
                    else
                        if handles.DataProperties(i).NStep==1
                            txt=['   N           ' num2str(handles.DataProperties(i).N1),' ',num2str(handles.DataProperties(i).N2)];
                        else
                            txt=['   N           ' num2str(handles.DataProperties(i).N1),' ',num2str(handles.DataProperties(i).NStep),' ',num2str(handles.DataProperties(i).N2)];
                        end
                    end
                    fprintf(fid,'%s \n',txt);
                end

                if handles.DataProperties(i).M1>0
                    if handles.DataProperties(i).M1==handles.DataProperties(i).M2
                        txt=['   XCoordinate "' handles.DataProperties(i).XCoordinate '"'];
                        fprintf(fid,'%s \n',txt);
                    end
                end

                if handles.DataProperties(i).N1>0
                    if handles.DataProperties(i).N1==handles.DataProperties(i).N2
                        txt=['   XCoordinate "' handles.DataProperties(i).XCoordinate '"'];
                        fprintf(fid,'%s \n',txt);
                    end
                end
                
                
            case {'kubint'}
                txt=['   PolygonFile "' handles.DataProperties(i).PolygonFile '"'];
                fprintf(fid,'%s \n',txt);
                txt=['   Parameter   "' handles.DataProperties(i).Parameter '"'];
                fprintf(fid,'%s \n',txt);

            case {'lint'}
                txt=['   PolygonFile "' handles.DataProperties(i).PolygonFile '"'];
                fprintf(fid,'%s \n',txt);

            case {'d3ddepth'}
                txt=['   GrdFile     "' handles.DataProperties(i).GrdFile '"'];
                fprintf(fid,'%s \n',txt);

            case {'d3dmonitoring'}
                txt=['   Type        "' handles.DataProperties(i).Type '"'];
                fprintf(fid,'%s \n',txt);

            case {'image'}
                if size(handles.DataProperties(i).GeoReferenceFile,2)>0
                    txt=['   GeoReferenceFile "' handles.DataProperties(i).GeoReferenceFile '"'];
                    fprintf(fid,'%s \n',txt);
                end

            case {'ucitxyz'}

                if handles.DataProperties(i).M1>0
                    if handles.DataProperties(i).M1==handles.DataProperties(i).M2
                        txt=['   M           ' num2str(handles.DataProperties(i).M1)];
                    else
                        if handles.DataProperties(i).MStep==1
                            txt=['   M           ' num2str(handles.DataProperties(i).M1),' ',num2str(handles.DataProperties(i).M2)];
                        else
                            txt=['   M           ' num2str(handles.DataProperties(i).M1),' ',num2str(handles.DataProperties(i).MStep),' ',num2str(handles.DataProperties(i).M2)];
                        end
                    end
                    fprintf(fid,'%s \n',txt);
                end

                if handles.DataProperties(i).N1>0
                    if handles.DataProperties(i).N1==handles.DataProperties(i).N2
                        txt=['   N           ' num2str(handles.DataProperties(i).N1)];
                    else
                        if handles.DataProperties(i).NStep==1
                            txt=['   N           ' num2str(handles.DataProperties(i).N1),' ',num2str(handles.DataProperties(i).N2)];
                        else
                            txt=['   N           ' num2str(handles.DataProperties(i).N1),' ',num2str(handles.DataProperties(i).NStep),' ',num2str(handles.DataProperties(i).N2)];
                        end
                    end
                    fprintf(fid,'%s \n',txt);
                end

                if handles.DataProperties(i).MultiplyX~=1.0
                    txt=['   MultiplyX   ' num2str(handles.DataProperties(i).MultiplyX)];
                    fprintf(fid,'%s \n',txt);
                end
                if handles.DataProperties(i).AddX~=0.0
                    txt=['   AddX        ' num2str(handles.DataProperties(i).AddX)];
                    fprintf(fid,'%s \n',txt);
                end
                
            case {'unibestcl'}
                txt=['   Parameter   "' handles.DataProperties(i).Parameter '"'];
                fprintf(fid,'%s \n',txt);
                txt=['   Location    "' handles.DataProperties(i).Location '"'];
                fprintf(fid,'%s \n',txt);
                if handles.DataProperties(i).Date>0
                    txt=['   Date        ' num2str(handles.DataProperties(i).Date)];
                    fprintf(fid,'%s \n',txt);
                end
                
            case{'freetext'}
                txt=['   String       "' handles.DataProperties(i).String '"'];
                fprintf(fid,'%s \n',txt);
                txt=['   Position     ' num2str(handles.DataProperties(i).Position)];
                fprintf(fid,'%s \n',txt);
                txt=['   Rotation     ' num2str(handles.DataProperties(i).Rotation)];
                fprintf(fid,'%s \n',txt);
                txt=['   Curvature    ' num2str(handles.DataProperties(i).Curvature)];
                fprintf(fid,'%s \n',txt);

            case{'freehanddrawing'}
                for kk=1:length(handles.DataProperties(i).x)
                    strx=sprintf('%12.2f',handles.DataProperties(i).x(kk));
                    stry=sprintf('%12.2f',handles.DataProperties(i).y(kk));
                    txt=['   Coordinates ' strx stry];
                    fprintf(fid,'%s \n',txt);
                end
        
            case{'hirlam'}
                txt=['   Parameter   "' handles.DataProperties(i).Parameter '"'];
                fprintf(fid,'%s \n',txt);

            case{'d3dmeteo'}
                txt=['   Parameter   "' handles.DataProperties(i).Parameter '"'];
                fprintf(fid,'%s \n',txt);
                if strcmpi(handles.DataProperties(i).Parameter(1),'p')
                    txt=['   PressureType "' handles.DataProperties(i).PressureType '"'];
                    fprintf(fid,'%s \n',txt);
                end
                str=datestr(handles.DataProperties(i).RefDate,'yyyymmdd');
                txt=['   RefDate     ' str];
                fprintf(fid,'%s \n',txt);
                str=datestr(handles.DataProperties(i).DateTime,'yyyymmdd HHMMSS');
                txt=['   Time        ' str];
                fprintf(fid,'%s \n',txt);

        end

        if handles.DataProperties(i).TimeZone~=0
            txt=['   TimeZone    ' num2str(handles.DataProperties(i).TimeZone)];
            fprintf(fid,'%s \n',txt);
        end
        
        if isfield(handles.DataProperties(i),'coordinateSystem')
            if isfield(handles.DataProperties(i).coordinateSystem,'name')
                if ~isempty(handles.DataProperties(i).coordinateSystem.name)
                    if ~strcmpi(handles.DataProperties(i).coordinateSystem.name,'unknown')
                        txt=['   CoordinateSystemName    "' handles.DataProperties(i).coordinateSystem.name '"'];
                        fprintf(fid,'%s \n',txt);
                        txt=['   CoordinateSystemType    "' handles.DataProperties(i).coordinateSystem.type '"'];
                        fprintf(fid,'%s \n',txt);
                    end
                end
            end
        end
        
        txt='EndDataset';
        fprintf(fid,'%s \n',txt);

        txt='';
        fprintf(fid,'%s \n',txt);

    end

end

for i=1:handles.NrCombinedDatasets

    txt=['CombinedDataset  "' handles.CombinedDatasetProperties(i).Name '"'];
    fprintf(fid,'%s \n',txt);
    txt=['   Operation     ' handles.CombinedDatasetProperties(i).Operation];
    fprintf(fid,'%s \n',txt);
    if handles.CombinedDatasetProperties(i).UnifOpt==1
        txt=['   UniformValue  ' num2str(handles.CombinedDatasetProperties(i).UniformValue)];
        fprintf(fid,'%s \n',txt);
        str=handles.CombinedDatasetProperties(i).DatasetA.Name;
        txt=['   DatasetA      "' str '"'];
        fprintf(fid,'%s \n',txt);
        txt=['   MultiplyA     ' num2str(handles.CombinedDatasetProperties(i).DatasetA.Multiply)];
        fprintf(fid,'%s \n',txt);
    else
        str=handles.CombinedDatasetProperties(i).DatasetA.Name;
        txt=['   DatasetA      "' str '"'];
        fprintf(fid,'%s \n',txt);
        txt=['   MultiplyA     ' num2str(handles.CombinedDatasetProperties(i).DatasetA.Multiply)];
        fprintf(fid,'%s \n',txt);
        str=handles.CombinedDatasetProperties(i).DatasetB.Name;
        txt=['   DatasetB      "' str '"'];
        fprintf(fid,'%s \n',txt);
        txt=['   MultiplyB     ' num2str(handles.CombinedDatasetProperties(i).DatasetB.Multiply)];
        fprintf(fid,'%s \n',txt);
    end
    txt=['EndCombinedDataset'];
    fprintf(fid,'%s \n',txt);
    txt='';
    fprintf(fid,'%s \n',txt);
end
