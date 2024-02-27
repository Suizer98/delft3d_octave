function dataset=muppet_addDatasetInteractiveText(opt,dataset)

switch lower(opt)
  case{'read'}
    % Do as much as possible here and not in import function
    dataset.type='interactivetext';
    dataset.filename='Interactive Text';
  case{'import'}
end
