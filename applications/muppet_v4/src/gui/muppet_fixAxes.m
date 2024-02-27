function muppet_fixAxes(varargin)

muppet_setPlotEdit(0);
plotedit off;

handles=getHandles;

fig=getappdata(gcf,'figure');
ifig=fig.number;

% Check for new subplots
if fig.nrsubplots>handles.figures(ifig).figure.nrsubplots
    for ii=handles.figures(ifig).figure.nrsubplots+1:fig.nrsubplots
        handles.figures(ifig).figure.subplots(ii).subplot=fig.subplots(ii).subplot;
    end
    handles.figures(ifig).figure.nrsubplots=fig.nrsubplots;
    handles=muppet_updateSubplotNames(handles);
end

for isub=1:fig.nrsubplots
    
    switch fig.subplots(isub).subplot.type
        
        case{'annotation'}
            
            % Annotations
            if fig.annotationschanged
                handles.figures(ifig).figure.subplots(isub).subplot=fig.subplots(isub).subplot;
                handles.figures(ifig).figure.nrannotations=fig.subplots(isub).subplot.nrdatasets;
                fig.annotationschanged=0;
            end
            
        otherwise
            
            % Check for change in position
            if fig.subplots(isub).subplot.positionchanged
                handles.figures(ifig).figure.subplots(isub).subplot.position=fig.subplots(isub).subplot.position;
                fig.subplots(isub).subplot.positionchanged=0;
            end
            
            % Check for change in limits
            if fig.subplots(isub).subplot.limitschanged
                switch fig.subplots(isub).subplot.type
                    
                    case{'2d','map','xy'}
                        handles.figures(ifig).figure.subplots(isub).subplot.xmin=fig.subplots(isub).subplot.xmin;
                        handles.figures(ifig).figure.subplots(isub).subplot.xmax=fig.subplots(isub).subplot.xmax;
                        handles.figures(ifig).figure.subplots(isub).subplot.ymin=fig.subplots(isub).subplot.ymin;
                        handles.figures(ifig).figure.subplots(isub).subplot.ymax=fig.subplots(isub).subplot.ymax;
                        handles.figures(ifig).figure.subplots(isub).subplot.scale=fig.subplots(isub).subplot.scale;

                    case{'3d'}
                        hax=findobj('Tag','axis','UserData',[ifig,isub]);
                        handles.figures(ifig).figure.subplots(isub).subplot.cameratarget=get(hax,'CameraTarget');
                        handles.figures(ifig).figure.subplots(isub).subplot.cameraposition=get(hax,'CameraPosition');
                        handles.figures(ifig).figure.subplots(isub).subplot.cameraviewangle=get(hax,'CameraViewAngle');
                        dasp=handles.figures(ifig).figure.subplots(isub).subplot.dataaspectratio;
                        pos=handles.figures(ifig).figure.subplots(isub).subplot.cameraposition;
                        tar=handles.figures(ifig).figure.subplots(isub).subplot.cameratarget;
                        ang=cameraview('target',tar,'position',pos,'dataaspectratio',dasp);
                        handles.figures(ifig).figure.subplots(isub).subplot.cameraangle=ang(1:2);
                        handles.figures(ifig).figure.subplots(isub).subplot.cameradistance=ang(3);
                        
                    case{'timeseries','timestack'}
                        t0=datevec(fig.subplots(isub).subplot.xmin);
                        t1=datevec(fig.subplots(isub).subplot.xmax);
                        handles.figures(ifig).figure.subplots(isub).subplot.yearmin=t0(1);
                        handles.figures(ifig).figure.subplots(isub).subplot.monthmin=t0(2);
                        handles.figures(ifig).figure.subplots(isub).subplot.daymin=t0(3);
                        handles.figures(ifig).figure.subplots(isub).subplot.hourmin=t0(4);
                        handles.figures(ifig).figure.subplots(isub).subplot.minutemin=t0(5);
                        handles.figures(ifig).figure.subplots(isub).subplot.secondmin=t0(6);
                        handles.figures(ifig).figure.subplots(isub).subplot.yearmax=t1(1);
                        handles.figures(ifig).figure.subplots(isub).subplot.monthmax=t1(2);
                        handles.figures(ifig).figure.subplots(isub).subplot.daymax=t1(3);
                        handles.figures(ifig).figure.subplots(isub).subplot.hourmax=t1(4);
                        handles.figures(ifig).figure.subplots(isub).subplot.minutemax=t1(5);
                        handles.figures(ifig).figure.subplots(isub).subplot.secondmax=t1(6);
                        handles.figures(ifig).figure.subplots(isub).subplot.ymin=fig.subplots(isub).subplot.ymin;
                        handles.figures(ifig).figure.subplots(isub).subplot.ymax=fig.subplots(isub).subplot.ymax;
                end
                fig.subplots(isub).subplot.limitschanged=0;
            end
            
            % Color Bar
            if fig.subplots(isub).subplot.colorbar.changed
                handles.figures(ifig).figure.subplots(isub).subplot.colorbar.position=fig.subplots(isub).subplot.colorbar.position;
                fig.subplots(isub).subplot.colorbar.changed=0;
            end
            
            % Legend
            if fig.subplots(isub).subplot.legend.changed
                handles.figures(ifig).figure.subplots(isub).subplot.legend.position=fig.subplots(isub).subplot.legend.position;
                handles.figures(ifig).figure.subplots(isub).subplot.legend.customposition=fig.subplots(isub).subplot.legend.customposition;
                fig.subplots(isub).subplot.legend.changed=0;
            end
            
            % Vector Legend
            if fig.subplots(isub).subplot.vectorlegend.changed
                handles.figures(ifig).figure.subplots(isub).subplot.vectorlegend.position=fig.subplots(isub).subplot.vectorlegend.position;
                fig.subplots(isub).subplot.vectorlegend.changed=0;
            end
            
            % North Arrow
            if fig.subplots(isub).subplot.northarrow.changed
                handles.figures(ifig).figure.subplots(isub).subplot.northarrow.position=fig.subplots(isub).subplot.northarrow.position;
                fig.subplots(isub).subplot.northarrow.changed=0;
            end
            
            % Scale Bar
            if fig.subplots(isub).subplot.scalebar.changed
                handles.figures(ifig).figure.subplots(isub).subplot.scalebar.position=fig.subplots(isub).subplot.scalebar.position;
                handles.figures(ifig).figure.subplots(isub).subplot.scalebar.text=fig.subplots(isub).subplot.scalebar.text;
                fig.subplots(isub).subplot.scalebar.changed=0;
            end
                        
            % And now the dataset (check for changes in colorbar)
            for id=1:fig.subplots(isub).subplot.nrdatasets
                if fig.subplots(isub).subplot.datasets(id).dataset.plotcolorbar
                    if fig.subplots(isub).subplot.datasets(id).dataset.colorbar.changed
                        handles.figures(ifig).figure.subplots(isub).subplot.datasets(id).dataset.colorbar.position=fig.subplots(isub).subplot.datasets(id).dataset.colorbar.position;
                        fig.subplots(isub).subplot.datasets(id).dataset.colorbar.changed=0;
                    end
                end
            end
            
            if fig.subplots(isub).subplot.annotationsadded
                
                % Annotations added?
                nd0=handles.figures(ifig).figure.subplots(isub).subplot.nrdatasets;
                nd1=fig.subplots(isub).subplot.nrdatasets;
                
                if nd1>nd0
                    
                    for ii=1:nd1-nd0
                        
                        nd2=nd0+ii;

                        switch fig.subplots(isub).subplot.datasets(nd2).dataset.type
                            case{'interactivepolyline'}
                                % Count number of existing interactive
                                % polylines
                                npol=0;
                                for n=1:nd2-1
                                    if strcmpi(fig.subplots(isub).subplot.datasets(n).dataset.type,'interactivepolyline')
                                        npol=npol+1;
                                    end
                                end
                                nm=['polyline ' num2str(npol+1)];
                                fig.subplots(isub).subplot.datasets(nd2).dataset.name=nm;
                                handles.figures(ifig).figure.subplots(isub).subplot.datasets(nd2).dataset=fig.subplots(isub).subplot.datasets(nd2).dataset;
                            case{'interactivetext'}
                                handles.figures(ifig).figure.subplots(isub).subplot.datasets(nd2).dataset=fig.subplots(isub).subplot.datasets(nd2).dataset;
                        end                                                               
                    end
                end
                
                handles.figures(ifig).figure.subplots(isub).subplot.nrdatasets=nd1;
                handles=muppet_updateDatasetInSubplotNames(handles);
                
                fig.subplots(isub).subplot.annotationsadded=0;
                
            end
            
            if fig.subplots(isub).subplot.annotationschanged
                for ii=1:length(fig.subplots(isub).subplot.datasets)
                    switch fig.subplots(isub).subplot.datasets(ii).dataset.type
                        case{'interactivepolyline'}
                            handles.figures(ifig).figure.subplots(isub).subplot.datasets(ii).dataset.x=fig.subplots(isub).subplot.datasets(ii).dataset.x;
                            handles.figures(ifig).figure.subplots(isub).subplot.datasets(ii).dataset.y=fig.subplots(isub).subplot.datasets(ii).dataset.y;
                        case{'interactivetext'}
                            handles.figures(ifig).figure.subplots(isub).subplot.datasets(ii).dataset.x=fig.subplots(isub).subplot.datasets(ii).dataset.x;
                            handles.figures(ifig).figure.subplots(isub).subplot.datasets(ii).dataset.y=fig.subplots(isub).subplot.datasets(ii).dataset.y;
                            handles.figures(ifig).figure.subplots(isub).subplot.datasets(ii).dataset.rotation=fig.subplots(isub).subplot.datasets(ii).dataset.rotation;
                            handles.figures(ifig).figure.subplots(isub).subplot.datasets(ii).dataset.curvature=fig.subplots(isub).subplot.datasets(ii).dataset.curvature;
                    end
                end
                fig.subplots(isub).subplot.annotationschanged=0;
            end
    end
    
end

handles.figures(ifig).figure.frametext=fig.frametext;
fig.changed=0;
setappdata(gcf,'figure',fig);

setHandles(handles);

muppet_updateGUI;

