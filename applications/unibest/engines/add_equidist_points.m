function [outLDB ori_ldb_inds]=add_equidist_points(dx,ldb,varargin)
%=Overview=================================================================
%
% add_equidist_points - cuts up ldb's in sections of dx length (only works
%                       for refinement, does not coarsen the ldb)
%
%      outLDB = add_equidist_points(<dx>,<ldb>,<dx option>)
%      [outLDB, ori_ldb_inds] = add_equidist_points(<dx>,<ldb>,<dx option>)
%
% input variables:
%
%   <dx>             - Optional: Value to cut up the ldb
%   <ldb>            - Optional: <ldb> as [Nx2] matrix or ldb structure
%   <dx option>      - Optional: Defines the way the ldb is cut up, use
%                                'exact' to cut up in exact dx sections
%                                while the remainder (smaller than dx) is
%                                added as well (this is the default
%                                option, a visual description is given
%                                below). Use 'equi' to add equidistant
%                                sections in between ldb points of at most
%                                dx length. Can only be used if dx and ldb
%                                are defined a-priori (so not through UI's)
%
%                                Original ldb:
%                                
%                                X--------------------------------------X
%                                :                                      :
%                       dist. =  0                                     100
%
%                                dx = 40
%
%                                <dx option> = 'exact' (default):
%
%                                X---------------x---------------x------X
%                                :               :               :      :
%                       dist. =  0               40              80    100
%
%                                <dx option> = 'equi':
%
%                                X------------x------------x------------X
%                                :            :            :            :
%                       dist. =  0           33.3         66.7         100
%
%=Syntax===================================================================
%
% ldb_out=add_equidist_points            
%            2 dialog prompts are triggered (for ldb & dx)
%
% ldb_out=add_equidist_points(dx)
%            1 dialog prompt is triggered (for the ldb)
%
% ldb_out=add_equidist_points(dx,ldb_in)
%            scripting only (no dialogs are triggered)
%
% ldb_out=add_equidist_points(dx,ldb_in,'equi')
%            scripting only (no dialogs are triggered)
%
% [ldb_out,ori_ldb_inds]=add_equidist_points(dx,ldb_in,'equi')
%            scripting only (no dialogs are triggered)
%
%=Elaborated overview of default 'exact' functionality=====================
%
% X = original ldb points
% x = new points in between ldb points (X's) using dx
%
%(1)(start)            (2)                                    (3)
% :                     :                                      :
% X_____________________X______________________________________X
%                                                               \        
%                                                                \       
%                                                                 \      
%                                                                  \     
%                                                                   \    
%                                                                    \   
%                                                                     \  
%                                                                      \ 
%         RETURNS:                                                      \
%                                                                        X
%                                                                        :
%(1)(start)            (2)                                    (3)       (4)
% :          1a         :          2a         2b         2c    :        end                                        
% X__________x__________X__________x__________x__________x_____X
%                                   <-- dx -->              ^   \
%                                                           :    \
%                                                           :     \ dx
%                                                           :      \
%                                                           :       \
%                                                           :        x
%                                                           :         \
% !Note that 'remainder' parts may be smaller than dx! <....:.........>\
%      (when using default 'exact' <dx option>)                         \
%                                                                        X
%                                                                        :
%                                                                       (4)
%                                                                       end
%
%==========================================================================
% see also: landboundary ldbTool tekal disassembleLdb rebuildLdb

%
% Small additions 2014 by Freek Scheel:
%
%  - Added UI functionality
%  - Added endpoints check
%  - added help
%  - added <dx option> equi for better Unibest use (updated writeMDA)
%
% freek.scheel@deltares.nl
%

%
% Small additions 2021 by Freek Scheel:
%
%  - Completely re-written with pre-allocation, may be orders of magnitude
%  faster, particularly for large vectors (>100.000 points)

%% Some initial handling:
%

outLDB=[];

if nargin<2 
    if isempty(which('landboundary.m'))
        wlsettings;
    end
    ldb=landboundary('read');
    if isempty(ldb)
        disp('No ldb chosen, aborting...');
        return
    end
end

if nargin==0
    dx_t = inputdlg('Specify a value for dx','dx?',1,{'1'});
    if isempty(dx_t)
        disp('No dx chosen, aborting...');
        return
    end
    dx = str2num(char(dx_t));
    if isempty(dx)
        error('Please specify a numeric number for dx');
    end
end

if nargin > 2
    if nargin == 3
        dx_opt = [];
        switch varargin{1}
            case 'exact'
                dx_opt = 'exact';
            case 'equi'
                dx_opt = 'equi';
        end
        if isempty(dx_opt)
            error(['specified <dx option> ''' varargin{1} ''' is unknown, use ''exact'' or ''equi''']);
        end
    else
        error('Too many input arguments');
    end
else
    dx_opt = 'exact';
end

if isempty(ldb)
    error('Empty ldb');
    return
end

if isnumeric(dx)
    if max(size(dx))>1
        error('Please specify one positive numeric value for dx')
    else
        if dx <= 0
            error('Please specify a positive numeric value for dx')
        end
    end
else
    error('Please specify a positive numeric value for dx')
end

try
    if ~isstruct(ldb)
        if (size(ldb,1) == 2) & (size(ldb,2) ~= 2)
            ldb = ldb';
        elseif (size(ldb,1) ~= 2) & (size(ldb,2) ~= 2)
            error('transferred to error below the catch...');
        end
        [ldbCell, ldbBegin, ldbEnd, ldbIn]=disassembleLdb(ldb);
    else
        ldbCell=ldb.ldbCell;
        ldbBegin=ldb.ldbBegin;
        ldbEnd=ldb.ldbEnd;
    end
catch
    error('Unknown ldb format, please check this');
end

%% Actual ldb scripting:
%

ori_ldb_inds = NaN(size(cell2mat(ldbCell),1),1); cur_ori_ind = 1; cur_ori_tel = 0;
for cc=1:length(ldbCell)
    cur_ori_ind = cur_ori_ind+1;
    in=ldbCell{cc};
    out=NaN(sum(ceil(diff(pathdistance(in(:,1),in(:,2))) ./ dx))+1,2);
    tel = 1;
    for ii=1:size(in,1)-1
        cur_ori_tel = cur_ori_tel+1;
        %Determine distance between two points 
        dist=sqrt((in(ii+1,1)-in(ii,1)).^2 + (in(ii+1,2)-in(ii,2)).^2);
        if dist == 0
            continue
        elseif dist <= dx
            ox=in(ii,1);
            oy=in(ii,2);
            out(tel:tel+length(ox)-1,:)=[ox oy];
            ori_ldb_inds(cur_ori_tel) = cur_ori_ind; cur_ori_ind = cur_ori_ind+1;
            tel = tel+1;
            if ii==(size(in,1)-1)
                ox=in(ii+1,1);
                oy=in(ii+1,2);
                out(tel,:)=[ox oy];
                tel = tel+1;
                cur_ori_tel = cur_ori_tel+1;
                ori_ldb_inds(cur_ori_tel) = cur_ori_ind;
            end
        elseif dist~=0
            if strcmp(dx_opt,'exact')
                ox=interp1([0 dist],in(ii:ii+1,1),0:dx:dist)';
                oy=interp1([0 dist],in(ii:ii+1,2),0:dx:dist)';
            elseif strcmp(dx_opt,'equi')
                dx_cur = dist/(ceil(dist/dx));

                ox=interp1([0 dist],in(ii:ii+1,1),0:dx_cur:dist)';
                oy=interp1([0 dist],in(ii:ii+1,2),0:dx_cur:dist)';
            else
                error(['Unknown dx_opt option: ''' dx_opt '''']);
            end
            
            if (in(ii+1,1) == ox(end,1)) & (in(ii+1,2) == oy(end,1)) && ii~=(size(in,1)-1)
                out(tel:tel+length(ox)-2,:)=[ox(1:end-1,1) oy(1:end-1,1)];
                ori_ldb_inds(cur_ori_tel) = cur_ori_ind; cur_ori_ind = cur_ori_ind+length(ox)-1;
                tel = tel+length(ox)-1;
            else
                out(tel:tel+length(ox)-1,:)=[ox oy];
                ori_ldb_inds(cur_ori_tel) = cur_ori_ind; cur_ori_ind = cur_ori_ind+length(ox);
                tel = tel+length(ox);
                if ii==(size(in,1)-1)
                    if ((in(ii+1,1) == ox(end,1)) && (in(ii+1,2) == oy(end,1))) == 0
                        out(tel,:)=[in(ii+1,1) in(ii+1,2)];
                    end
                    cur_ori_tel = cur_ori_tel+1;
                    ori_ldb_inds(cur_ori_tel) = cur_ori_ind-1;
                end
            end
            
        end
        
        
        
%         if ii>1
%             if (out(tel-1,1) == ox(1,1)) & (out(tel-1,2) == oy(1,1))
%                 out(tel:tel+length(ox)-2,:)=[ox(2:end,1) oy(2:end,1)];
%                 ori_ldb_inds = [ori_ldb_inds; cur_ori_ind+length(ox)-1];
%             else
%                 out(tel:tel+length(ox)-1,:)=[ox oy];
%                 cur_ori_ind  = cur_ori_ind + 1;
%                 ori_ldb_inds = [ori_ldb_inds(1:end-1); cur_ori_ind; cur_ori_ind+length(ox)-1];
%             end
%         else
%             DONE out(tel:tel+length(ox)-1,:)=[ox oy];
%             ori_ldb_inds = [ori_ldb_inds; cur_ori_ind; cur_ori_ind+length(ox)-1];
%         end
%         cur_ori_ind  = ori_ldb_inds(end);
    end
    outCell{cc}=out;
end

%% Output:
%

if ~isstruct(ldb)
    outLDB=rebuildLdb(outCell);
%     plot(outLDB(:,1),outLDB(:,2),'k.-');
%     hold on;
%     plot(ldb(:,1),ldb(:,2),'rx');
%     plot(outLDB(ori_ldb_inds,1),outLDB(ori_ldb_inds,2),'bo');
else
    outLDB.ldbCell=outCell;
    outLDB.ldbBegin=ldbBegin;
    outLDB.ldbEnd=ldbEnd;
end
