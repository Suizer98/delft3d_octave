function dataset=muppet_addDatasetSamples(opt,dataset)

switch lower(opt)

    case{'read'}
        
        % Do as much as possible here and not in import function
        dataset.adjustname=0;
        [pathstr,name,ext]=fileparts(dataset.filename);    
        dataset.name=name;

    case{'import'}
        
        s=load(dataset.filename);
        dataset.x=squeeze(s(:,1));
        dataset.y=squeeze(s(:,2));
        dataset.z=squeeze(s(:,3));
                        
        dataset.type = 'scalar1dxyz';
        dataset.tc='c';

end
