%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18269 $
%$Date: 2022-08-01 12:31:19 +0800 (Mon, 01 Aug 2022) $
%$Author: chavarri $
%$Id: D3D_version.m 18269 2022-08-01 04:31:19Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_version.m $
%
%OUTPUT:


function [tgen,version,tim_ver,source]=D3D_version(simdef,varargin)

[fpath_dia,structure]=D3D_simdef_2_dia(simdef);

fid=fopen(fpath_dia,'r');
while ~feof(fid)
    
    fline=fgetl(fid);
    
    switch structure
        case 1
            % *** Deltares, FLOW2D3D Version 6.04.01.141160M, May 17 2022, 10:52:54
            % ***           built from : https://svn.oss.deltares.nl/repos/delft3d/branches/research/Deltares/20210729_changes_implementation_exner
            
            bol_g=contains(fline,'*** Deltares, FLOW2D3D Version');
            if ~bol_g
                continue
            end
            tok=regexp(fline,',','split');
            str_tim=cat(2,tok{1,3},tok{1,4});
            tim_ver=datetime(str_tim,'InputFormat','MMM d yyyy HH:mm:ss');
            version=strrep(tok{1,2},' FLOW2D3D Version ','');
            
%             ***           built from : https://svn.oss.deltares.nl/repos/delft3d/branches/research/Deltares/20210729_changes_implementation_exner
            fline=fgetl(fid);
            source=strrep(fline,'***           built from : ','');
            
            fline=fgetl(fid);
            fline=fgetl(fid);
            fline=fgetl(fid);
            
%             ***           date,time  : 2022-07-27, 16:41:07
            tok=regexp(fline,'***           date,time  : (\d{4})-(\d{2})-(\d{2}), (\d{2}):(\d{2}):(\d{2})','tokens');
            %t0
            tok_num=str2double(tok{1,1});
            tgen=datetime(tok_num(1),tok_num(2),tok_num(3),tok_num(4),tok_num(5),tok_num(6));
            
        case 2
            % # Generated on 10:34:36, 01-04-2022
            % # Deltares, D-Flow FM Version 1.2.136.140489, Dec 13 2021, 09:36:38
            % # Source:https://svn.oss.deltares.nl/repos/delft3d/branches/releases/140261/
            
            tok=regexp(fline,'# Generated on (\d{2}):(\d{2}):(\d{2}), (\d{2})-(\d{2})-(\d{4})','tokens');
            if ~isempty(tok)
                tok_num=str2double(tok{1,1});
                tgen=datetime(tok_num(6),tok_num(5),tok_num(4),tok_num(1),tok_num(2),tok_num(3));
                
                fline=fgetl(fid);
                tok=regexp(fline,',','split');
                version=strrep(tok{1,2},' D-Flow FM Version ','');
                str_tim=strcat(tok{1,3},tok{1,4});
                tim_ver=datetime(str_tim,'InputFormat','MMM d yyyy HH:mm:ss');
                
                fline=fgetl(fid);
                source=strrep(fline,'# Source:','');
                break
            end
    end

end %while

fclose(fid);

end %function

%%
% tok_tim=regexp(str_tim,'(\w{3}) (\d{2}) (\d{4}) (\d{2}):(\d{2}):(\d{2})','tokens');
%             month_num=month(datetime(tok_tim{1,1}{1,1},'InputFormat','MMM'));
%             tok_num=str2double(tok_tim{1,1});
%             tgen=datetime(tok_num(3),month_num,tok_num(2),tok_num(4),tok_num(5),tok_num(6));