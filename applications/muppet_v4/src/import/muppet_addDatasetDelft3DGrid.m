function dataset=muppet_addDatasetDelft3DGrid(opt,dataset)

switch lower(opt)

    case{'read'}
    
        % Do as much as possible here and not in import function
        dataset.adjustname=0;
        [pathstr,name,ext]=fileparts(dataset.filename);
        dataset.name=name;
    
    case{'import'}
        
        grd=wlgrid('read',dataset.filename);
        dataset.x     = grd.X;
        dataset.y     = grd.Y;       
        dataset.tc='c';
        dataset.type = 'location2dxy';
                
end
