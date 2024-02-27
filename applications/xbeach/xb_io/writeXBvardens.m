function [succes] = writeXBvardens(outputname,frequency,direction,variance_density)
% Simple function that create vardens for XBeach
try
    
    % Create textfile
    fid=fopen(outputname ,'wt');
    
    % Write frequency
    fprintf(fid, '%s \n', num2str(length(frequency)));
    for ii = 1:length(frequency)
        fprintf(fid,  '%.5f \n', frequency(ii));
    end
    
    % Write directions
    fprintf(fid, '%s \n', num2str(length(direction)));
    for ii = 1:length(direction)
        fprintf(fid, '%.5f \n', direction(ii));
    end
    
    % Write variance density
    for ii = 1:size(variance_density,2)
        for jj = 1:size(variance_density,1)
            fprintf(fid, '%.10f ', variance_density(jj,ii));
        end
        fprintf(fid, '%s \n', ' ');
    end
    fclose('all');

    succes = 1;
catch
    succes = 0;
end
    
end

