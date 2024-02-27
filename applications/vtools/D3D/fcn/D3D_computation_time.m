%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: D3D_computation_time.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_computation_time.m $
%
%Check computational time
%
%INPUT:
%   -simdef: structure, path to dia file, path to simulation folder
%
%OUTPUT:
%   -sim_efficiency = simulation time / (clock time * # processes)
%
%E.G.:

function [tim_dur,t0,tf,processes,tim_sim,sim_efficiency]=D3D_computation_time(simdef,varargin)

[fpath_dia,structure]=D3D_simdef_2_dia(simdef);

fid=fopen(fpath_dia,'r');
kl=0;
while ~feof(fid)
    
    fline=fgetl(fid);
    kl=kl+1;
    switch structure
        case 1
            % ***           date,time  : 2022-07-27, 16:41:07
            
            tok=regexp(fline,'***           date,time  : (\d{4})-(\d{2})-(\d{2}), (\d{2}):(\d{2}):(\d{2})','tokens');
            if ~isempty(tok)
                %t0
                tok_num=str2double(tok{1,1});
                t0=datetime(tok_num(1),tok_num(2),tok_num(3),tok_num(4),tok_num(5),tok_num(6));
                %tf
                [kl_g,fline]=search_text_ascii(fpath_dia,'***             date, time :',kl); %attention, different number of spaces than t0
                if numel(kl_g)>1
                    messageOut(NaN,sprintf('Simulation run more than once: %s',fpath_dia));
                    kl_g=kl_g(end);
                end
                if isempty(kl_g) || isnan(kl_g)
                    error('I could not find the end time')
                end
                tok=regexp(fline,'***             date, time : (\d{4})-(\d{2})-(\d{2}), (\d{2}):(\d{2}):(\d{2})','tokens');
%                 tok_num=str2double(tok{1,1}); %I don't know why this worked before but not now 
                tok_num=str2double(tok{1,1}{1,1});
                tf=datetime(tok_num(1),tok_num(2),tok_num(3),tok_num(4),tok_num(5),tok_num(6));
                %duration
                tim_dur=tf-t0;
                %simulated time
                tim_sim=NaN;
                %processes
                processes=NaN; %check where it is
            end
        case 2
            % ** INFO   : Computation started  at: 11:28:10, 04-09-2022
            % ** INFO   : Computation finished at: 08:13:17, 05-09-2022
            % ** INFO   : 
            % ** INFO   : simulation period      (h)  :            48.0000000000
            % ** INFO   : total time in timeloop (h)  :            20.7510759225
            % ** INFO   : MPI    : yes.         #processes   : 8, my_rank: 0
            % ** INFO   : OpenMP : unavailable.

            
            tok=regexp(fline,'** INFO   : Computation started  at: (\d{2}):(\d{2}):(\d{2}), (\d{2})-(\d{2})-(\d{4})','tokens');
            if ~isempty(tok)
                %t0
                tok_num=str2double(tok{1,1});
                t0=datetime(tok_num(6),tok_num(5),tok_num(4),tok_num(1),tok_num(2),tok_num(3));
                %tf
                fline=fgetl(fid);
                tok=regexp(fline,'** INFO   : Computation finished at: (\d{2}):(\d{2}):(\d{2}), (\d{2})-(\d{2})-(\d{4})','tokens');
                tok_num=str2double(tok{1,1});
                tf=datetime(tok_num(6),tok_num(5),tok_num(4),tok_num(1),tok_num(2),tok_num(3));
                %duration
                tim_dur=tf-t0;
                %simulation period
                for kloop=1:2
                    fline=fgetl(fid);
                end
                tok=regexp(fline,'** INFO   : simulation period      \(h\)  :\s*(\d*).(\d*)','tokens');
                tim_sim=hours(str2double(tok{1,1}{1,1})+str2double(tok{1,1}{1,2})/10);
                %processes
                for kloop=1:2
                    fline=fgetl(fid);
                end
                tok=regexp(fline,'#processes   : (\d*)','tokens');
                processes=str2double(tok{1,1}{1,1});
                break
            end
%             kl=search_text_ascii(simdef.file.dia,'** INFO   : Computation finished at:',1);
    end

end %while

sim_efficiency=tim_sim/(tim_dur*processes);

fclose(fid);

end %function