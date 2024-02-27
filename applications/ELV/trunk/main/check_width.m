%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 17214 $
%$Date: 2021-04-29 00:05:01 +0800 (Thu, 29 Apr 2021) $
%$Author: chavarri $
%$Id: check_width.m 17214 2021-04-28 16:05:01Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/check_width.m $
%
%check_input is a function that checks that the input is enough and makes sense
%
%input_out=check_input(input,path_file_input,fid_log)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -input = variable containing the input [struct] e.g. input
%
%HISTORY:
%170720
%   -V & Pepijn. Created for the first time.

function input_out=check_width(input,fid_log)

% Adjust input for the correct flowtype
switch input.mdv.flowtype
    case 6
        if isfield(input.grd,'crt')==0 %constant cross section?
            input.grd.crt=0; %not a constant cross section
        end
        
        if numel(input.grd.B)==1
            warningprint(fid_log,'You are selecting a constant width, it is beter switch to flowtype 1');
            input.mdv.flowtype = 1;
        end
        
        % Check for a main channel or also flood plaines
        if size(input.grd.B,1)==1
            if input.grd.crt==1 %constant rectangular cross section
                warningprint(fid_log,'We will use the variable width solver for rectangular channels');
                warningprint(fid_log,'The hydraulic radius is approximated as the flow depth');
                B = [input.grd.B,input.grd.B(end)]; 
                input.grd.dBdx = (B(2:end)-B(1:end-1))/(input.grd.dx); 
         
            else
                warningprint(fid_log,'We will use only the main channel, flood plane width is set to zero');
                input.grd.B = [input.grd.B; zeros(size(input.grd.B)); zeros(size(input.grd.B))];
                input.grd.Bparam = repmat([999666999; 0; 999666999; 0],1,size(input.grd.B,2));
            end
        elseif size(input.grd.B,1)==2
            warningprint(fid_log,'We will assume that there is only one flood plain');
            input.grd.B = [input.grd.B(1,:); input.grd.B(2,:); zeros(size(input.grd.B(1,:)))];
        elseif size(input.grd.B,1)==3
            % correct input
        else
            error('wrong input in width');
        end
      
        if input.grd.crt==1
        else
            if size(input.grd.Bparam,1)==2
                    input.grd.Bparam = [input.grd.Bparam; 999666999*ones(size(input.grd.Bparam(1,:))),zeros(size(input.grd.Bparam(1,:)))];   
            elseif size(input.grd.Bparam,1)==4
            else
                error('wrong input');
            end
        end
        
        % Interpolation part
        if size(input.grd.B,2)==1
            warningprint(fid_log,'Only one cross-section is specified, it is used everywhere');
            input.grd.B = repmat(input.grd.B,1,input.mdv.nx);
        elseif size(input.grd.B,2)<input.mdv.nx
            warningprint(fid_log,'Not enough cross-sections are specified, looking for an x-vector to apply interpolation');
            input.grd.B=interp1(input.grd.Bx,input.grd.B,repmat((1:input.mdv.nx)',3,1)); 
        elseif size(input.grd.B,2)>input.mdv.nx
            error('wrong specification of the width');
        end

        if input.grd.crt==1
        else
            if size(input.grd.Bparam,2)==1
                warningprint(fid_log,'Only one set of cross-section parameters is specified, it is used everywhere');
                input.grd.Bparam= repmat(input.grd.Bparam,1,input.mdv.nx);
            elseif size(input.grd.B,2)<input.mdv.nx
                warningprint(fid_log,'Not enough cross-sections parameters are specified, looking for an x-vector to apply interpolation');
                if isfield(input.grd,'Bxparam')
                elseif isfield(input.grd,'Bx')
                   input.grd.Bxparam = input.grd.Bx;
                else
                    error('Not enough input is specified');
                end           
                input.grd.Bparam = [interp1(input.grd.Bxparam,input.grd.Bparam(1,:),1:input.mdv.nx); interp1(input.grd.Bxparam,input.grd.Bparam(2,:),1:input.mdv.nx); interp1(input.grd.Bxparam,input.grd.Bparam(3,:),1:input.mdv.nx); ];       
            elseif size(input.grd.B,2)>input.mdv.nx
                error('wrong specification of the width');
            end
        end   
    otherwise %flow type not 6
        if size(input.grd.B,2)==1
            input.grd.B=repmat(input.grd.B,1,input.mdv.nx);
        else
            if size(input.grd.B,2)~=input.mdv.nx
                error('We do not like such a shity input, please revise');
            end
        end
end

%% interpolate if needed
% if isfield(input.grd,'B_edg')==0
%     if isfield(input.mdv,'interp_edg')==1 && input.mdv.interp_edg==1
        input.grd.B_edg=interp1(input.mdv.xcen',input.grd.B',input.mdv.xedg')'; %interpolate always, it is just initialization
%     end
% end

%%
%% FOR FLOWTYPE 6, with variable width; check input
%% MDV and GRD
%%

switch input.mdv.flowtype
    case {1,5}
		if input.ini.initype~=1
			input.ini.u=NaN;
			input.ini.h=NaN;
		end
    case {2,3,4}
        if isfield(input.ini,'u')==0 || isfield(input.ini,'h')==0
            warningprint(fid_log,'For quasi-steady or unsteady flow type you must specify inital u and h')
        end
    case 6  
        if input.ini.initype~=1
			input.ini.u=NaN;
			input.ini.h=NaN;
        end       
end


%% OUTPUT 

input_out=input;