%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17340 $
%$Date: 2021-06-10 21:24:14 +0800 (Thu, 10 Jun 2021) $
%$Author: chavarri $
%$Id: D3D_bct_2.m 17340 2021-06-10 13:24:14Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_bct_2.m $
%
%general and direct writing
%
%INPUT:
%   -simdef.bct.fname
%   -simdef.bct.ref_time
%   -simdef.bct.sec(k).param
%   -simdef.bct.sec(k).tim
%   -simdef.bct.sec(k).val

function D3D_bct_2(simdef,varargin)

bct=simdef.bct;

fname=bct.fname;
[~,fil,ext]=fileparts(fname);
fname_loc=fullfile(pwd,sprintf('%s%s',fil,ext));

fid=fopen(fname_loc,'w');

nbct=numel(bct.sec);

for kbct=1:nbct
    fprintf(fid,'table-name           ''Boundary Section : %d''                                     \n',kbct); 
    fprintf(fid,'contents             ''Uniform             ''                                     \n'); 
    fprintf(fid,'location             ''%s         ''                                     \n',bct.sec(kbct).location); 
    fprintf(fid,'time-function        ''non-equidistant''                                          \n'); 
    fprintf(fid,'reference-time       %s                                                     \n',datestr(bct.ref_time,'yyyymmdd')); 
    fprintf(fid,'time-unit            ''seconds''                                                  \n'); 
    fprintf(fid,'interpolation        ''linear''                                                   \n'); 
    fprintf(fid,'parameter            ''time                ''                     unit ''[min]''  \n'); 
    switch bct.sec(kbct).param
        case 'Q'
            fprintf(fid,'parameter            ''total discharge (t)  end A''               unit ''[m3/s]'' \n'); 
            fprintf(fid,'parameter            ''total discharge (t)  end B''               unit ''[m3/s]'' \n'); 
        case 'H'
            fprintf(fid,'parameter            ''water elevation (z)  end A''              unit ''[m]'' \n');
            fprintf(fid,'parameter            ''water elevation (z)  end B''              unit ''[m]'' \n');
    end
    nl=numel(bct.sec(kbct).tim);
    fprintf(fid,'records-in-table     %d \r\n',nl);
    %serie
    for kl=1:nl
        switch bct.sec(kbct).param
            case 'Q'
                fprintf(fid,'%10.9e  %10.9e    9.9999900e+002 \r\n',seconds(bct.sec(kbct).tim(kl)-bct.ref_time),bct.sec(kbct).val(kl));
            case 'H'
                fprintf(fid,'%10.9e  %10.9e    %10.9e \r\n',seconds(bct.sec(kbct).tim(kl)-bct.ref_time),bct.sec(kbct).val(kl),bct.sec(kbct).val(kl));
        end %switch
    end %kl    
end %kbct

fclose(fid);
status=copyfile(fname_loc,fname);
delete(fname_loc);
if status
    messageOut(NaN,sprintf('File written: %s',fname));
else
    messageOut(NaN,'File created locally here:');
    fprintf('%s \n',fname_loc);
    fprintf('but could not be copied here: \n');
    fprintf('%s \n',fname);
end

end %function