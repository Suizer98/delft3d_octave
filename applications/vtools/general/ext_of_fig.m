%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18353 $
%$Date: 2022-09-08 19:39:21 +0800 (Thu, 08 Sep 2022) $
%$Author: chavarri $
%$Id: ext_of_fig.m 18353 2022-09-08 11:39:21Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/ext_of_fig.m $
%
%

function fext=ext_of_fig(fig_print)

%We use this function for creating a movie. 
%If we have several types of figure, the movie
%will be with '.png' or '.jpg'.
if numel(fig_print)>1
    if any(fig_print==1)
        fig_print=1;
    elseif any(fig_print==4)
        fig_print=4;
    end
end

switch fig_print
    case 0
        fext=''; %just to pass this function
    case 1
        fext='.png';
    case 2
        fext='.fig';
    case 3
        fext='.eps';
    case 4
        fext='.jpg';
    otherwise
        error('add')
end

end %function