% fileload
% loads a file into a matrix

function data = fileload(image_path)

if isstruct(image_path)
    image_path = fullfile(image_path.path,image_path.name);
end

data=imread(image_path);
if numel(size(data))==3
    data=double(0.2990 * data(:,:,1) + ...
                0.5870 * data(:,:,2) + ...
                0.1140 * data(:,:,3));
else
    data=double(data);
end