function PostFTP(hm,m)

model=hm.models(m);

locdir=[hm.webDir model.webSite filesep 'scenarios' filesep hm.scenario filesep ...
        model.continent filesep model.name filesep 'figures'];

try

    cont=hm.models(m).continent;
    disp('Connecting to FTP site ...');
    f=ftp('members.upc.nl','m.ormondt','8AMGU55S');

    disp(['cd ' model.webSite filesep 'scenarios' hm.scenario filesep cont]);
    
    cd(f,[model.webSite filesep 'scenarios' filesep hm.scenario filesep cont]);

    try % to delete existing directory
        disp('Entering current directory ...');
        cd(f,hm.models(m).name);
        cd(f,'figures');
        disp('Deleting files in current directory ...');
        try
            delete(f,'*');
        end
        disp('Going up one directory ...');
        cd(f,'..');
        disp('Deleting current directory ...');
        [success,message,messageid]=rmdir(f,'figures','s');
    end
    
    try % to upload figures
        disp('Uploading data ...');
        mput(f,locdir);
        disp('Data uploaded ...');
    end

    cd(f,'..');
    cd(f,'..');

    try % to delete models.xml
        disp('Deleting models.xml ...');
        delete(f,'models.xml');
    end

    try % to upload models.xml
        disp('Uploading models.xml ...');
        mput(f,[hm.webDir model.webSite filesep 'scenarios' filesep hm.scenario ...
                filesep 'models.xml']);
        disp('models.xml uploaded ...');
    end
    
    close(f);

catch
    disp('Something went wrong with uploading to FTP site!');
end


% % Post data to FTP for Dano
% 
% if strcmpi(hm.models(m).name,'kuststrook')
% 
%     locdir=[hm.archiveDir filesep model.continent filesep model.name
%     filesep 'archive' filesep 'appended' filesep 'timeseries'];
% 
%     try
% 
%         disp('Connecting to FTP site ...');
%         f=ftp('ftp.wldelft.nl','ormondt','ibQLw54');
%  
%         try % to delete existing directory
%             disp('Entering current directory ...');
%             cd(f,'timeseries');
%             disp('Deleting files in current directory ...');
%             try
%                 delete(f,'*');
%             end
%             disp('Going up one directory ...');
%             cd(f,'..');
%             disp('Deleting current directory ...');
%             rmdir(f,'timeseries');
%         end
% 
%         try % to upload figures
%             disp('Uploading data kuststrook...');
%             mput(f,locdir);
%             disp('Data uploaded ...');
%         end
% 
%         close(f);
% 
%     catch
%         disp('Something went wrong with uploading to FTP site!');
%     end
% 
% 
% end
% 
% if strcmpi(hm.models(m).name,'delflandxbeach')
% 
%     locdir=[hm.archiveDir filesep model.continent filesep model.name
%     filesep 'lastrun' filesep 'input'];
% 
%     try
% 
%         disp('Connecting to FTP site ...');
%         f=ftp('ftp.wldelft.nl','ormondt','ibQLw54');
%  
%         try % to delete existing directory
%             disp('Entering current directory ...');
%             cd(f,'delflandxbeach');
%             cd(f,'input');
%             disp('Deleting files in current directory ...');
%             try
%                 delete(f,'*');
%             end
%             disp('Going up one directory ...');
%             cd(f,'..');
%             disp('Deleting current directory ...');
%             rmdir(f,'input');
%         catch
%             disp('Something went wrong with uploading to FTP site!')
%         end
% 
%         try % to upload figures
%             disp('Uploading data delfland xbeach...');
%             mput(f,locdir);
%             disp('Data uploaded ...');
%         end
% 
%         close(f);
% 
%     catch
%         disp('Something went wrong with uploading to FTP site!');
%     end
% 
% 
% end
