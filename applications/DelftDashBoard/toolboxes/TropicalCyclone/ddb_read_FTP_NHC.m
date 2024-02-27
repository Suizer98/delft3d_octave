function [succes] = ddb_read_FTP_NHC(fname)
    % This function reads the FTP site of NOAA and search for best tracks
    % Files are saved locally
    
    try
        % First get a list of files
        ftpobj      = ftp('ftp.nhc.noaa.gov');
        filesFTP    = dir(ftpobj, 'atcf/btk');

        % Second, check which files needs to be downloaded?
        % Download all, unless...
        iddownload = ones(length(filesFTP),1);
        filesdownloaded = dir([fname 'atcf/btk/']); 
        for ii = 1:length(filesFTP)
            for jj = 1:length(filesdownloaded)
                same = strcmp(filesdownloaded(jj).name, filesFTP(ii).name);
                if same == 1
                    iddownload(ii) = 0;
                end
            end
        end

        % Thirdly, download the files
        for ii = 1:length(filesFTP)
            if iddownload(ii) == 1
                mget(ftpobj,['atcf/btk/' filesFTP(ii).name],fname);
            end
        end
        succes = 1;
    catch
        succes = 0;
    end
end

