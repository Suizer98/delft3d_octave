%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18149 $
%$Date: 2022-06-13 12:50:33 +0800 (Mon, 13 Jun 2022) $
%$Author: chavarri $
%$Id: D3D_which_v_2_label.m 18149 2022-06-13 04:50:33Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_which_v_2_label.m $
%
    
function [lab,str_var,str_un,str_diff]=D3D_which_v_2_label(which_v,un,lan,varargin)

%%

parin=inputParser;

addOptional(parin,'Lref','+NAP');

parse(parin,varargin{:});

Lref=parin.Results.Lref;

%%
switch which_v
    case 1
        [lab,str_var,str_un,str_diff]=labels4all('etab',un,lan,'Lref',Lref); 
    case 2
        [lab,str_var,str_un,str_diff]=labels4all('h',un,lan); 
    case 10
        [lab,str_var,str_un,str_diff]=labels4all('umag',un,lan); 
    case 12
        [lab,str_var,str_un,str_diff]=labels4all('etaw',un,lan,'Lref',Lref); 
    case 17
        [lab,str_var,str_un,str_diff]=labels4all('detab',un,lan); 
    case 43
        [lab,str_var,str_un,str_diff]=labels4all('vicouv',un,lan); 
    otherwise
        error('ups')
end