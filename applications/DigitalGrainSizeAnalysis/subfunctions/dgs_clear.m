% dgs_clear
% clear different parameters from memory

function dgs_clear(obj, event, par)

h=findobj('tag','current_image');
sample=get(h,'userdata');

switch par
    case 'image'
        [sample.data] = deal([]);
    case 'imagelist'
        sample=sample(1:0);
    case 'roi'
        [sample.roi] = deal({});
        [sample.roi_x] = deal({});
        [sample.roi_y] = deal({});
        [sample.whole_roi] = deal(0);
        [sample.num_roi] = deal(0);
        [sample.roi_line] = deal({});
    otherwise
        errordlg(['Unknown object to clear [' par ']']);
end

set(h,'userdata',sample);

warndlg(['Cleared memory [' par ']']);