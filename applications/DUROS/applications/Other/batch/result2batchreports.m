function result2batchreports(workdir, outputfilename, d, result)

if ~(...
        ~isempty(find(isnan(vertcat(result(1).info.messages{:,1}))))|...
        any(strcmp(result(1).info.messages(:,2),'Iteration boundaries are non-consistent'))|...
        ~isempty(find(vertcat(result(1).info.messages{:,1})==2))|...
        ~isempty(find(vertcat(result(1).info.messages{:,1})==100))...
        )
    messages = writemessage('get');
    messages = unique(vertcat(messages(:,2)));
    if ~isempty(messages)
        msgtxt = messages{1};
        for j = 2:size(messages,1)
            msgtxt = [msgtxt ' -> ' messages{j}];
        end
    else
        msgtxt = [];
    end

    fid=fopen([workdir filesep outputfilename],'a');
    fprintf(fid,'%s\n', ...
        ['Results for: ' d.year ' ' d.areacode ' ' d.transectID ' - '  msgtxt]);
    fclose(fid);
else
    fid=fopen([workdir filesep outputfilename],'a');
    fprintf(fid,'%s\n', ...
        ['No results for: ' d.year ' ' d.areacode ' ' d.transectID]);
    fclose(fid);
end