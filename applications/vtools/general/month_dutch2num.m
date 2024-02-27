%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18269 $
%$Date: 2022-08-01 12:31:19 +0800 (Mon, 01 Aug 2022) $
%$Author: chavarri $
%$Id: month_dutch2num.m 18269 2022-08-01 04:31:19Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/month_dutch2num.m $
%
%Convert month names to number

function month_num=month_dutch2num(month_dutch)

switch lower(month_dutch)
    case {'januari','jan'}
        month_num=1;
    case {'februari','feb'}
        month_num=2;
    case 'maart'
        month_num=3;
    case 'april'
        month_num=4;
    case 'mei'
        month_num=5;
    case 'juni'
        month_num=6;
    case 'juli'
        month_num=7;
    case 'augustus'
        month_num=8;
    case 'september'
        month_num=9;
    case 'oktober'
        month_num=10;
    case 'november'
        month_num=11;
    case 'december'
        month_num=12;
    otherwise
        error('unknown month name')
end

end %function