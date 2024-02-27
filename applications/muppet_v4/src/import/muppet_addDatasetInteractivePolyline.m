function dataset=muppet_addDatasetInteractivePolyline(opt,dataset)

switch lower(opt)
  case{'read'}
    % Do as much as possible here and not in import function
    dataset.type='interactivepolyline';
    dataset.filename='NA';
  case{'import'}
end
