%DELWAQ_DMO Reads dmo file from delwaq
%
%   [name segments] = DELWAQ_DMO(dmoFile) Read the observation file
%   <obsFile>  and gives back x,y, layer and the id.
%
%   NOTE: <obsFile> has to be a delwaq *.obs format
%
%
%   See also:

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Jul-12 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------
function S = delwaq_dmo(type,dmoFile,S)

if nargin ==2
    S = [];
end

switch type
    case 'read'
        fid = fopen(dmoFile);
        
        n = cell2mat(textscan(fid, '%f'));
        
        for i = 1:n
            disp(['Reading area: ' num2str(i) '/' num2str(n)])
            localname = textscan(fid, '%s',1);
            localname = localname{1};
            localname = char(localname{1});
            S.name{i} = localname(2:end-1); %#ok<*AGROW>
            ns = cell2mat(textscan(fid, '%f',1));
            S.segments{i} = cell2mat(textscan(fid, '%f',ns));
        end
        
        fclose(fid);
    case 'write'
        
        fid = fopen(dmoFile,'w+');
        
        n = length(S.name);
        fprintf(fid,'%s\n',num2str(n));
        for i = 1:n
            fprintf(fid,'%s\t %s\n',['''' S.name{i} ''''], num2str(length(S.segments{i})));
            fprintf(fid,'%0.0f\n',S.segments{i});
        end
        
        fclose(fid);
        
end
