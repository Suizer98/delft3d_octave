function varargout = opendap_folder_contents_test

%OPENDAP_FOLDER_CONTENTS_TEST   test for opendap_folder_contents on OET opendap servers
%
%See also: opendap_folder_contents

%% HYRAX @ opendap.deltares.nl 

MTestCategory.DataAccess;

warning('opendap_folder_contents is deprecated, use opendap_catalog instead')

   disp(repmat('#',[1 72]))
   disp('HYRAX @ opendap.deltares.nl ')
   disp(repmat('#',[1 72]))
   
   url      = 'http://opendap.deltares.nl:8080/opendap/rijkswaterstaat/vaklodingen/contents.html';
   contents = opendap_folder_contents(url);
   char   (contents);
   nc_dump(contents{1})
   
   url      = 'http://opendap.deltares.nl:8080/opendap/rijkswaterstaat/vaklodingen';
   contents = opendap_folder_contents(url);
   char   (contents);
   nc_dump(contents{1})
   %% THREDDS @ opendap.deltares.nl 
   
   
   disp(repmat('#',[1 72]))
   disp('THREDDS @ opendap.deltares.nl ')
   disp(repmat('#',[1 72]))
   
   url      = 'http://opendap.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.html';
   contents = opendap_folder_contents(url);
   char   (contents);
   nc_dump(contents{1})
   
   url      = 'http://opendap.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/vaklodingen';
   contents = opendap_folder_contents(url);
   char   (contents);
   nc_dump(contents{1})
   %% THREDDS @ dtvirt5.deltares.nl 
   
   
   disp(repmat('#',[1 72]))
   disp('THREDDS @ dtvirt5.deltares.nl')
   disp(repmat('#',[1 72]))
   
   url      = 'http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.html';
   contents = opendap_folder_contents(url);
   char   (contents);
   nc_dump(contents{1})
   
   url      = 'http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/vaklodingen';
   contents = opendap_folder_contents(url);
   char   (contents);
   nc_dump(contents{1})

   disp(repmat('#',[1 72]))
   
   if nargout==1
      varargout = {contents};
   end

%% EOF