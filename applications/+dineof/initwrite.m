function initwrite(T,initfile)
%initwrite  saves file with DINEOF setings
%
%    dineof.initwrite(T, initfile) 
%
% saves struct T with dineof settings to DINEOF initfile.
%
%See also: DINEOF

OPT.comments = 0;

%% load 

   [T0,E0] = dineof.init();
   
   fields = fieldnames(T0);
   
   T = mergestructs('overwrite',T0,T); % add non-existing fields

%% save

   fid = fopen(initfile,'w');
   
   if fid <0
       error(['Cannot write to "',initfile,'"'])
   end
   
   fprintf(fid,'! Created with $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/+dineof/initwrite.m $ $Id: initwrite.m 9067 2013-08-16 15:31:02Z boer_g $ \n');
   
   for ifld=1:length(fields)

     fld = fields{ifld};

     if ischar(T.(fld));
        fmt = '%s';
     else
        fmt = '%d';
     end
     
     if     (strcmp(fld,'clouds')           & isempty(T.(fld))), continue
     elseif (strcmp(fld,'number_cv_points') & isempty(T.(fld))), continue
     elseif strcmp(fld,'EOF_U')
       fprintf(fid,['%s = ',fmt,'\n'],pad('EOF.U',11),T.(fld));
     elseif strcmp(fld,'EOF_V')
       fprintf(fid,['%s = ',fmt,'\n'],pad('EOF.V',11),T.(fld));
     elseif strcmp(fld,'EOF_Sigma')
       fprintf(fid,['%s = ',fmt,'\n'],pad('EOF.Sigma',11),T.(fld));
     else
     
       if OPT.comments
       for j=1:length(E0.(fld))
         fprintf(fid,'! %s\n',E0.(fld){j});
       end
       end
       
       fprintf(fid,['%s = ',fmt,'\n'],pad(fld,11),T.(fld));
     
     end
       
   end
   
   fclose(fid);

   