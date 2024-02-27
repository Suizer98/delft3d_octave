function handles=muppet_backwardCompatibility(handles)

% Backward compatibility
for ifig=1:handles.nrfigures
    
    % Orientation
    
    for isub=1:handles.figures(ifig).figure.nrsubplots
        
        plt=handles.figures(ifig).figure.subplots(isub).subplot;
        
        % Plot type
        switch lower(plt.type)
            case{'2d'}
                plt.type='map';
        end
        
        switch lower(plt.type)
            case{'annotation'}
                for id=1:plt.nrdatasets
                    if ~isfield(plt.datasets(id).dataset,'plotroutine')
                        name=textscan(plt.datasets(id).dataset.name,'%s');
                        name=name{1}{1};
                        switch lower(name)
                            case{'line'}
                                plt.datasets(id).dataset.plotroutine='Single Line';
                            case{'arrow'}
                                plt.datasets(id).dataset.plotroutine='Arrow';
                            case{'doublearrow'}
                                plt.datasets(id).dataset.plotroutine='Double Arrow';
                            case{'rectangle'}
                                plt.datasets(id).dataset.plotroutine='Rectangle';
                            case{'ellipse'}
                                plt.datasets(id).dataset.plotroutine='Ellipse';
                            case{'textbox'}
                                plt.datasets(id).dataset.plotroutine='Text Box';
                        end                        
                    end
                end
            otherwise                
                % Renaming of plot routines
                for id=1:plt.nrdatasets
                    switch lower(plt.datasets(id).dataset.plotroutine)
                        case{'plotcontourmap'}
                            plt.datasets(id).dataset.plotroutine='Contour Map';
                        case{'plotcontourmaplines'}
                            plt.datasets(id).dataset.plotroutine='Contour Map and Lines';
                        case{'plotcontourlines'}
                            plt.datasets(id).dataset.plotroutine='Contour Lines';
                        case{'plotshadesmap'}
                            plt.datasets(id).dataset.plotroutine='Shades Map';
                        case{'plotpatches'}
                            plt.datasets(id).dataset.plotroutine='Patches';
                        case{'plot3dsurface'}
                            plt.datasets(id).dataset.plotroutine='3D Surface';
                        case{'plot3dsurfacelines'}
                            plt.datasets(id).dataset.plotroutine='3D Surface and Lines';
                        case{'plotgrid'}
                            plt.datasets(id).dataset.plotroutine='Grid';
                        case{'plotannotation'}
                            plt.datasets(id).dataset.plotroutine='Annotation';
                        case{'plotsamples'}
                            plt.datasets(id).dataset.plotroutine='Samples';
                        case{'plotpolyline','plotpolygon'}
                            plt.datasets(id).dataset.plotroutine='Polyline';
                        case{'plotpolygon3d'}
                            plt.datasets(id).dataset.plotroutine='Polyline 3D';
                        case{'plotkub','plotkubint'}
                            plt.datasets(id).dataset.plotroutine='Kubint';
                        case{'plotlint'}
                            plt.datasets(id).dataset.plotroutine='Lint';
                        case{'plotimage'}
                            plt.datasets(id).dataset.plotroutine='Image';
                        case{'plotcrosssections'}
                            plt.datasets(id).dataset.plotroutine='Cross Sections';
                        case{'plotrose'}
                            plt.datasets(id).dataset.plotroutine='Rose';
                        case{'plotvectors'}
                            plt.datasets(id).dataset.plotroutine='Vectors';
                        case{'plotcurvedarrows'}
                            plt.datasets(id).dataset.plotroutine='Curved Arrows';
                        case{'plotcoloredcurvedarrows'}
                            plt.datasets(id).dataset.plotroutine='Colored Curved Arrows';
                        case{'plotline'}
                            plt.datasets(id).dataset.plotroutine='Line';
                        case{'plotspline'}
                            plt.datasets(id).dataset.plotroutine='Spline';
                        case{'plothistogram'}
                            plt.datasets(id).dataset.plotroutine='Histogram';
                        case{'plotstackedarea'}
                            plt.datasets(id).dataset.plotroutine='Stacked Area';
                    end
                end
        end

        % Scale bar (now with respect to lower left corner of subplot)
        if plt.plotscalebar
             if numel(plt.plotscalebar)==3
                 plt.scalebar.position(1)=plt.plotscalebar(1)-plt.position(1);
                 plt.scalebar.position(2)=plt.plotscalebar(2)-plt.position(2);                 
                 plt.scalebar.position(3)=plt.plotscalebar(3);                 
                 plt.plotscalebar=1;
             end
        end
        
        % North arrow (now with respect to lower left corner of subplot)
        if plt.plotnortharrow
             if numel(plt.plotnortharrow)==4
                 plt.northarrow.position(1)=plt.plotnortharrow(1)-plt.position(1);
                 plt.northarrow.position(2)=plt.plotnortharrow(2)-plt.position(2);                 
                 plt.northarrow.position(3)=plt.plotnortharrow(3);                 
                 plt.northarrow.position(4)=plt.plotnortharrow(4);                 
                 plt.plotnortharrow=1;
             end
        end
        
        handles.figures(ifig).figure.subplots(isub).subplot=plt;

    end
end

