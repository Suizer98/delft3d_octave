%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17201 $
%$Date: 2021-04-17 01:15:25 +0800 (Sat, 17 Apr 2021) $
%$Author: chavarri $
%$Id: D3D_read_input_m.m 17201 2021-04-16 17:15:25Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_read_input_m.m $
%
function [def,simdef,in_read]=D3D_read_input_m(path_input)

in_read.dummy=NaN;
simdef.dummy=NaN;
simdef.dummy=NaN;
def.dummy=NaN;

fid=fopen(path_input,'r');

while ~feof(fid)
    line=fgetl(fid);
    line=strtrim(line);
    if isempty(line)
        continue
    end
    if strcmp(line(1),'%')
        continue
    end
    tok1=regexp(line,'=','split');
    var_name=tok1{1,1};
    tok2=regexp(var_name,'\.','split');
    field_1=tok2{1,1};

    var_val_1=tok1{1,2};
    var_val_2=regexp(var_val_1,'%','split');
    var_val_2=var_val_2{1,1};
    var_val_3=strrep(var_val_2,';','');

    var_val_char=strrep(var_val_3,'''',''); %attention with transpose!
    var_val_num=str2double(var_val_char);

    %simdef
    switch field_1
        case 'simdef'
            simdef=add_value_1(simdef,tok2,var_val_char,var_val_num);
        case 'def'
            def=add_value_1(def,tok2,var_val_char,var_val_num);
        case 'in_read'
            in_read=add_value_1(in_read,tok2,var_val_char,var_val_num);
    end
    fprintf('%s \n',line)
end

end %function

%%
%% FUNCTIONS
%%

function out=add_value(var_val_char,var_val_num)

if isnan(var_val_num)
    if strcmp(var_val_char(1),'{')
        str1=strrep(var_val_char,'{','');
        str1=strrep(str1,'}','');
        tok1=regexp(str1,',','split'); %attention with cell array with ';' it is lost before
        nfield=numel(tok1);
        out=cell(1,nfield);
        for kc=1:nfield
            out{1,kc}=tok1{1,kc};
        end
    elseif strcmp(var_val_char,'NaN')
        out=NaN;
    else
        out=var_val_char;
    end
else
    out=var_val_num;
end

end

%%

function stru=add_value_1(stru,tok2,var_val_char,var_val_num)

nfield=numel(tok2);
switch nfield
     case 2
        stru.(tok2{1,2})=add_value(var_val_char,var_val_num);
     case 3
        stru.(tok2{1,2}).(tok2{1,3})=add_value(var_val_char,var_val_num);
end

end