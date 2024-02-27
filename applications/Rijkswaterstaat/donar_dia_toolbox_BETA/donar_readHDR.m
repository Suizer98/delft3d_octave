function [result] = donar_read_HDR(file_id)
%donar_readHDR
%
% [result] = donar_read_HDR(file_id)
%
% sEE ALSO: 

    rec = fgetl(file_id);
    if rec == -1, result = -1; return; end %Is it the end of the file?
    
    line = 1;
    while ~strcmpi(rec(1:5),'[wrd]')
        rec   = fgetl(file_id);
        
        HDRnumcol    = length(strfind(rec,';'));
        theHDRformat = '%s';
        for l=1:HDRnumcol
         theHDRformat = ['%s',theHDRformat];
        end

        if ~strcmp(rec(1),'[')
            theinfo = textscan(rec,theHDRformat,'delimiter',';');
            for ifield=2:1:length(theinfo)
             result.(theinfo{1}{1}) = [theinfo{2:end}];
            end
        end
        
        line = line+1;
    end
end