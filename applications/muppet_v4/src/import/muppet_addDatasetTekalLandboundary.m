function dataset=muppet_addDatasetTekalLandboundary(opt,dataset)

switch lower(opt)
  case{'read'}
    % Do as much as possible here and not in import function
    dataset.adjustname=0;
    [pathstr,name,ext]=fileparts(dataset.filename);
    dataset.name=name;
  case{'import'}
    [x,y]=landboundary('read',dataset.filename);
    dataset.x=x;
    dataset.y=y;
    dataset.type = 'location1dxy';
    dataset.tc='c';
%     dataset.dimensions.coordinatesystem.name='WGS 84';
%     dataset.dimensions.coordinatesystem.type='geographic';    
end
