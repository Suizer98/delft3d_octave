%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17435 $
%$Date: 2021-07-28 19:51:10 +0800 (Wed, 28 Jul 2021) $
%$Author: chavarri $
%$Id: modify_rtctimeseries.m 17435 2021-07-28 11:51:10Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/rmm_setup/modify_rtctimeseries.m $
%

function modify_rtctimeseries(path_xml,start_time,stop_time,bcn,loclabels)

xml_in=read_ascii(path_xml);
nl=numel(xml_in);

%% CHANGE ALL START AND END TIMES

%we rely on the first <startDate and <endDate to be the one everywhere
%we expect that the time series which are not the ones we modify only have
%to enters with the start and end time

    %% start time
notfound_1=true;
kl=0;
while notfound_1
    kl=kl+1;
    search4_1='<startDate date="(\d+)-(\d+)-(\d+)" time="(\d+):(\d+):(\d+)"';
    tok_start_original=regexp(xml_in{kl,1},search4_1,'tokens');
    if ~isempty(tok_start_original) 
        notfound_1=false;
    end
end

for kl=1:nl
    [idx_s,idx_e]=regexp(xml_in{kl,1},sprintf('date="%s-%s-%s" time="%s:%s:%s"',tok_start_original{1,1}{1,1},tok_start_original{1,1}{1,2},tok_start_original{1,1}{1,3},tok_start_original{1,1}{1,4},tok_start_original{1,1}{1,5},tok_start_original{1,1}{1,6}));
    if ~isempty(idx_s)
        xml_in{kl,1}(idx_s:idx_e)=sprintf('date="%04d-%02d-%02d" time="%02d:%02d:%02d"',year(start_time),month(start_time),day(start_time),hour(start_time),minute(start_time),second(start_time));
    end
end

    %% end time
notfound_1=true;
kl=0;
while notfound_1
    kl=kl+1;
    search4_1='<endDate date="(\d+)-(\d+)-(\d+)" time="(\d+):(\d+):(\d+)"';
    tok_start_original=regexp(xml_in{kl,1},search4_1,'tokens');
    if ~isempty(tok_start_original) 
        notfound_1=false;
    end
end

for kl=1:nl
    [idx_s,idx_e]=regexp(xml_in{kl,1},sprintf('date="%s-%s-%s" time="%s:%s:%s"',tok_start_original{1,1}{1,1},tok_start_original{1,1}{1,2},tok_start_original{1,1}{1,3},tok_start_original{1,1}{1,4},tok_start_original{1,1}{1,5},tok_start_original{1,1}{1,6}));
    if ~isempty(idx_s)
        xml_in{kl,1}(idx_s:idx_e)=sprintf('date="%04d-%02d-%02d" time="%02d:%02d:%02d"',year(stop_time),month(stop_time),day(stop_time),hour(stop_time),minute(stop_time),second(stop_time));
    end
end

%% MODIFY TIME SERIES

nseries=numel(loclabels); %number of time series to be changed
block_line=NaN(nseries,1);
for kseries=1:nseries
    name_rtc=loclabels(kseries).s3;
%     name_block=name_rtc; %modify if the name of the block with the time series is different than the name of the rtc control group
    name_block=loclabels(kseries).s3_block;
    idx_bcn=find(strcmp({bcn.tsc.Locatiecode},loclabels(kseries).data));
    if isempty(idx_bcn)
        error('There is no label match between model and input data')
    end
    search4block=true;
    kl=1;
    while search4block
        tok=regexp(xml_in{kl,1},sprintf('(]%s/%s<)',name_rtc,name_block),'tokens');
        if ~isempty(tok) %loop down from found string
           search4block=false;
        else
            kl=kl+1;
        end
        
        %prevent infinite
        search4='</TimeSeries';
        tok2=regexp(xml_in{kl,1},search4,'tokens');
        if ~isempty(tok2)
            error('I cannot find the block')
        end
        
        %save order
        block_line(kseries,1)=kl;
    end %search4block
        
    %% start time
    notfound=true;
    kl2=kl+1;
    while notfound
        search4='<startDate';
        tok2=regexp(xml_in{kl2,1},search4,'tokens');
        if ~isempty(tok2)
            xml_in{kl2,1}=sprintf('      <startDate date="%04d-%02d-%02d" time="%02d:%02d:%02d" />',year(bcn.tsc(idx_bcn).daty(1)),month(bcn.tsc(idx_bcn).daty(1)),day(bcn.tsc(idx_bcn).daty(1)),hour(bcn.tsc(idx_bcn).daty(1)),minute(bcn.tsc(idx_bcn).daty(1)),second(bcn.tsc(idx_bcn).daty(1)));
            notfound=false;
        else
            kl2=kl2+1;
        end

        %prevent infinite
        tokt=regexp(xml_in{kl2,1},'(</series>)','tokens');
        if ~isempty(tokt)
            error('I could not find %s',search4)
        end
    end %while

    %% end time
    notfound=true;
    kl2=kl+1;
    while notfound
        search4='<endDate';
        tok2=regexp(xml_in{kl2,1},search4,'tokens');
        if ~isempty(tok2)
            xml_in{kl2,1}=sprintf('      <endDate date="%04d-%02d-%02d" time="%02d:%02d:%02d" />',year(bcn.tsc(idx_bcn).daty(end)),month(bcn.tsc(idx_bcn).daty(end)),day(bcn.tsc(idx_bcn).daty(end)),hour(bcn.tsc(idx_bcn).daty(end)),minute(bcn.tsc(idx_bcn).daty(end)),second(bcn.tsc(idx_bcn).daty(end)));
            notfound=false;
        else
            kl2=kl2+1;
        end

        %prevent infinite
        tokt=regexp(xml_in{kl2,1},'(</series>)','tokens');
        if ~isempty(tokt)
            error('I could not find %s',search4)
        end
    end %while

    %% delete existing time series

    notfound=true;
    kl2=kl+1;
    while notfound
        search4='<event';
        tok2=regexp(xml_in{kl2,1},search4,'tokens');
        if ~isempty(tok2)
            xml_in(kl2)=[];
        else
            kl2=kl2+1;
        end

        %prevent infinite
        tokt=regexp(xml_in{kl2,1},'(</series>)','tokens');
        if ~isempty(tokt)
            notfound=false;
        end
    end %while
    
end %kseries

%% WRITE 

%before adding new time series
writetxt(path_xml,xml_in,'check_existing',0)

%% NEW TIME SERIES

%it cannot be inside the loop, as it become too expensive

%order the series as they appear in the file
[~,o2]=sort(block_line);

xml_in=read_ascii(path_xml);
nl=numel(xml_in);

fID=fopen(path_xml,'w');

klw0=1;
nseries=numel(loclabels); %number of time series to be changed
for kseries_bc=1:nseries
    kseries=o2(kseries_bc);
    name_rtc=loclabels(kseries).s3;
    %     name_block=name_rtc; %modify if the name of the block with the time series is different than the name of the rtc control group
    name_block=loclabels(kseries).s3_block;
    idx_bcn=find(strcmp({bcn.tsc.Locatiecode},loclabels(kseries).data));
    if strcmp(name_block,'hartel breed over')
        a=1;
    end
    search4block=true;
    kl=1;
    while search4block
        tok=regexp(xml_in{kl,1},sprintf('(]%s/%s<)',name_rtc,name_block),'tokens');
        if ~isempty(tok) %loop down from found string
           search4block=false;
        else
            kl=kl+1;
        end
        
        %prevent infinite
        search4='</TimeSeries';
        tok2=regexp(xml_in{kl,1},search4,'tokens');
        if ~isempty(tok2)
            error('I cannot find the block')
        end
        
    end %search4block
    
    %search for line to add event
    notfound=true;
    kl2=kl+1;
    while notfound
        search4='</header';
        tok2=regexp(xml_in{kl2,1},search4,'tokens');
        if ~isempty(tok2)
            notfound=false;
        else
            kl2=kl2+1;
        end

        %prevent infinite
        tokt=regexp(xml_in{kl2,1},'(</series>)','tokens');
        if ~isempty(tokt)
            notfound=false;
        end
    end %while
    
    %write until kl2
    for klw=klw0:kl2
       fprintf(fID,'%s\r\n',xml_in{klw,1});
    end
    klw0=kl2+1;
    
    nts=numel(bcn.tsc(idx_bcn).daty);
    for kts=1:nts
%     for kts=1:5 %for debugging purposes
        auxt=bcn.tsc(idx_bcn).daty(kts);
        switch bcn.tsc(idx_bcn).Parametereenheid
            case 'cm'
                unit_f=1/100;
            case 'm'
                unit_f=1;
            otherwise
                error('unknown unit (parametereenheid) in %s',bcn.tsc(idx_bcn).Locatiecode)
        end
        auxv=bcn.tsc(idx_bcn).val(kts)*unit_f; %cm to m
        switch loclabels(kseries).s3_function
            case 2
                auxv=auxv+loclabels(kseries).s3_param; 
        end
        fprintf(fID,'      <event date="%04d-%02d-%02d" time="%02d:%02d:%02d" value="%f" />\r\n',year(auxt),month(auxt),day(auxt),hour(auxt),minute(auxt),second(auxt),auxv);
    end
    
    fprintf('Done writing serie %d/%d \n',kseries_bc,nseries)
end

%write info after last serie
for klw=klw0:nl
   fprintf(fID,'%s\r\n',xml_in{klw,1});
end

fclose(fID);

end %function