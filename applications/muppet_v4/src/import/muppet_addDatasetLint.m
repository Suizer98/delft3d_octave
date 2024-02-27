function dataset=muppet_addDatasetLint(opt,dataset)

switch lower(opt)
    case{'read'}
        % Do as much as possible here and not in import function
        dataset.adjustname=0;
        [pathstr,name,ext]=fileparts(dataset.filename);
        dataset.name='integrated transports';
    case{'import'}
        
        fi=tekal('open',dataset.filename,'loaddata');
        [x,y]=landboundary('read',dataset.polygonfile);
        
        dataset.x(1)=min(min(x));
        dataset.x(2)=max(max(x));
        dataset.y(1)=min(min(y));
        dataset.y(2)=max(max(y));
        
        dataset.z=fi.Field.Data(:,2);
        
        dataset.type='lint';
        
        dataset.tc='c';
                
        %     dataset.dimensions.coordinatesystem.name='WGS 84';
        %     dataset.dimensions.coordinatesystem.type='geographic';
end
