function [DataProperties,iword,noset]=ReadDataProperties(txt)

% READ DATASETS FROM SESSION FILE

nowords=size(txt,2);

i=1;

end_datasets = false;
noset=0;
 
DataProperties(1).Name='';
 
while end_datasets==0
 
    end_dataset = false;
 
    while and(end_dataset==0,end_datasets==0)
 
        switch lower(txt{i}),
            case {'dataset'},
                noset=noset+1;
                DataProperties(noset).Name=txt{i+1};
                DataProperties(noset).ColumnX=1;
                DataProperties(noset).ColumnY=2;
                DataProperties(noset).ColumnZ=3;
                DataProperties(noset).ColumnU=3;
                DataProperties(noset).ColumnV=4;
                DataProperties(noset).Column=3;
                DataProperties(noset).FileType='unknown';
                DataProperties(noset).Type='unknown';
                DataProperties(noset).PathName='';
                DataProperties(noset).Parameter='unknown';
                DataProperties(noset).Location='unknown';
                DataProperties(noset).Station='';
                DataProperties(noset).Date=0;
                DataProperties(noset).Time=0;
                DataProperties(noset).DateTime=0;
                DataProperties(noset).Block=0;
                DataProperties(noset).M=0;
                DataProperties(noset).N=0;
                DataProperties(noset).M1=0;
                DataProperties(noset).N1=0;
                DataProperties(noset).M2=0;
                DataProperties(noset).N2=0;
                DataProperties(noset).MStep=1;
                DataProperties(noset).NStep=1;
                DataProperties(noset).K1=0;
                DataProperties(noset).K2=0;
                DataProperties(noset).T1=0;
                DataProperties(noset).T2=0;
                DataProperties(noset).TStep=1;
                DataProperties(noset).Layer=1;
                DataProperties(noset).Constituent='unknown';
                DataProperties(noset).Component='magnitude';
                DataProperties(noset).XCoordinate='pathdistance';
                DataProperties(noset).Multiply=1.0;
                DataProperties(noset).MultiplyX=1.0;
                DataProperties(noset).MultiplyY=1.0;
                DataProperties(noset).AddX=0.0;
                DataProperties(noset).AddY=0.0;
                DataProperties(noset).Add=0.0;
                DataProperties(noset).TimeZone=0.0;
                DataProperties(noset).PolFile='unknown';
                DataProperties(noset).GeoReferenceFile='';
                DataProperties(noset).CombinedDataset=0;
                DataProperties(noset).SubField='none';
                DataProperties(noset).GrdFile='';
                DataProperties(noset).LGAFile='';
                DataProperties(noset).XYFile='';
                DataProperties(noset).DefFile='';
                DataProperties(noset).XBeachUFile='';
                DataProperties(noset).XBeachVFile='';
                DataProperties(noset).String='';
                DataProperties(noset).Position=[0 0];
                DataProperties(noset).Rotation=0;
                DataProperties(noset).Curvature=0;
                DataProperties(noset).RefDate=floor(now);
                DataProperties(noset).PressureType='mBar';
                DataProperties(noset).coordinateSystemName='unknown';
                DataProperties(noset).coordinateSystemType='projected';
 
            case {'filetype'},
                DataProperties(noset).FileType=txt{i+1};
            case {'type'},
                DataProperties(noset).Type=txt{i+1};
            case {'file'},
                DataProperties(noset).FileName=txt{i+1};
                DataProperties(noset).PathName=fileparts(txt{i+1});
                DataProperties(noset).PathName='';
                if ~isempty(DataProperties(noset).PathName)
                    if ~strcmpi(DataProperties(noset).PathName(end),'\')
                        DataProperties(noset).PathName=[DataProperties(noset).PathName '\'];
                    end
                end
            case {'lgafile'},
                DataProperties(noset).LGAFile=txt{i+1};
            case {'grdfile'},
                DataProperties(noset).GrdFile=txt{i+1};
            case {'deffile'},
                DataProperties(noset).DefFile=txt{i+1};
            case {'xyfile'},
                DataProperties(noset).XYFile=txt{i+1};
            case {'xbeachufile'},
                DataProperties(noset).File=txt{i+1};
            case {'xbeachvfile'},
                DataProperties(noset).XBeachVFile=txt{i+1};
            case {'column'},
                DataProperties(noset).Column=str2num(txt{i+1});
            case {'columnx'},
                DataProperties(noset).ColumnX=str2num(txt{i+1});
            case {'columny'},
                DataProperties(noset).ColumnY=str2num(txt{i+1});
            case {'columnz'},
                DataProperties(noset).ColumnZ=str2num(txt{i+1});
            case {'columnu'},
                DataProperties(noset).ColumnU=str2num(txt{i+1});
            case {'columnv'},
                DataProperties(noset).ColumnV=str2num(txt{i+1});
            case {'parameter'},
                DataProperties(noset).Parameter=txt{i+1};
            case {'subfield'},
                DataProperties(noset).SubField=txt{i+1};
            case {'location'},
                DataProperties(noset).Location=txt{i+1};
            case {'station'},
                DataProperties(noset).Station=txt{i+1};
            case {'date'},
                DataProperties(noset).Date=str2num(txt{i+1});
            case {'time'},
                DataProperties(noset).Date=str2num(txt{i+1});
                DataProperties(noset).Time=str2num(txt{i+2});
                DataProperties(noset).DateTime=MatTime(DataProperties(noset).Date,DataProperties(noset).Time);
                DataProperties(noset).Block=0;
            case {'refdate'},
                DataProperties(noset).RefDate=str2num(txt{i+1});
                DataProperties(noset).RefDate=MatTime(DataProperties(noset).RefDate,0);
            case {'block'},
                DataProperties(noset).Block=str2num(txt{i+1});
            case {'m'},
                if size(str2num(txt{i+2}),1)==0
                    DataProperties(noset).M1=str2num(txt{i+1});
                    DataProperties(noset).M2=str2num(txt{i+1});
                elseif size(str2num(txt{i+3}),1)==0
                    DataProperties(noset).M1=str2num(txt{i+1});
                    DataProperties(noset).M2=str2num(txt{i+2});
                elseif size(str2num(txt{i+4}),1)==0
                    DataProperties(noset).M1=str2num(txt{i+1});
                    DataProperties(noset).MStep=str2num(txt{i+2});
                    DataProperties(noset).M2=str2num(txt{i+3});
                end
            case {'n'},
                if size(str2num(txt{i+2}),1)==0
                    DataProperties(noset).N1=str2num(txt{i+1});
                    DataProperties(noset).N2=str2num(txt{i+1});
                elseif size(str2num(txt{i+3}),1)==0
                    DataProperties(noset).N1=str2num(txt{i+1});
                    DataProperties(noset).N2=str2num(txt{i+2});
                elseif size(str2num(txt{i+4}),1)==0
                    DataProperties(noset).N1=str2num(txt{i+1});
                    DataProperties(noset).NStep=str2num(txt{i+2});
                    DataProperties(noset).N2=str2num(txt{i+3});
                end
            case {'t'},
                if size(str2num(txt{i+2}),1)==0
                    DataProperties(noset).T1=str2num(txt{i+1});
                    DataProperties(noset).T2=str2num(txt{i+1});
                elseif size(str2num(txt{i+3}),1)==0
                    DataProperties(noset).T1=str2num(txt{i+1});
                    DataProperties(noset).T2=str2num(txt{i+2});
                elseif size(str2num(txt{i+4}),1)==0
                    DataProperties(noset).T1=str2num(txt{i+1});
                    DataProperties(noset).TStep=str2num(txt{i+2});
                    DataProperties(noset).T2=str2num(txt{i+3});
                end
            case {'multiply'},
                DataProperties(noset).Multiply=str2num(txt{i+1});
            case {'add'},
                DataProperties(noset).Add=str2num(txt{i+1});
            case {'xcoordinate'},
                DataProperties(noset).XCoordinate=txt{i+1};
            case {'multiplyx'},
                DataProperties(noset).MultiplyX=str2num(txt{i+1});
            case {'addx'},
                DataProperties(noset).AddX=str2num(txt{i+1});
            case {'timezone'},
                DataProperties(noset).TimeZone=str2num(txt{i+1});
            case {'layer','k'},
                DataProperties(noset).K1=str2num(txt{i+1});
                DataProperties(noset).K2=str2num(txt{i+2});
            case {'elevation'},
                DataProperties(noset).Elevation=str2num(txt{i+1});
            case {'constituent'},
                DataProperties(noset).Constituent=txt{i+1};
            case {'component'},
                DataProperties(noset).Component=txt{i+1};
            case {'polygonfile','polylinefile'},
                DataProperties(noset).PolygonFile=txt{i+1};
            case {'trianabfile'},
                DataProperties(noset).TrianaBFile=txt{i+1};
            case {'georeferencefile'},
                DataProperties(noset).GeoReferenceFile=txt{i+1};
            case {'string'},
                DataProperties(noset).String=txt{i+1};
                DataProperties(noset).Type='FreeText';
            case {'position'},
                DataProperties(noset).Position(1)=str2num(txt{i+1});
                DataProperties(noset).Position(2)=str2num(txt{i+2});
            case {'rotation'},
                DataProperties(noset).Rotation=str2num(txt{i+1});
            case {'curvature'},
                DataProperties(noset).Curvature=str2num(txt{i+1});
            case {'coordinates'},
                DataProperties(noset).Type='FreeHandDrawing';
                kk=0;
                while ~strcmpi(txt{i+3},'enddataset')
                    kk=kk+1;
                    DataProperties(noset).x(kk)=str2num(txt{i+1});
                    DataProperties(noset).y(kk)=str2num(txt{i+2});
                    i=i+3;
                end
                kk=kk+1;
                DataProperties(noset).x(kk)=str2num(txt{i+1});
                DataProperties(noset).y(kk)=str2num(txt{i+2});
            case {'pressuretype'},
                DataProperties(noset).PressureType=txt{i+1};
            case {'coordinatesystemname'}
                DataProperties(noset).coordinateSystem.name=txt{i+1};
            case {'coordinatesystemtype'}
                DataProperties(noset).coordinateSystem.type=txt{i+1};
        end
 
        end_dataset=strcmpi(txt{i},'enddataset');
        
        stopstr={'combineddataset','figure'};
        
        end_datasets=max(strcmpi(txt{i},stopstr));
 
        i=i+1;
 
    end
 
end

iword=i-1;

