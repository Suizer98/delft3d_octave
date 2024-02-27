%DELWAQ_POL Reads pol file from delwaq
%
%   [name segments] = DELWAQ_POL(dmoFile) Read the polygon file
%
%
%   See also:

%   Copyright 2016 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2016-Feb-16 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------
function S = delwaq_pol(type,polFile,S)

if nargin ==2
    S = [];
end

switch type
    case 'read'
        fid = fopen(polFile);
        sline = fgetl(fid);
        while any(ismember(sline,'*'))
            sline = fgetl(fid);
        end
        localname = sline;
        k = 0;
        while ischar(localname)
            k = k+1;
            numcell = textscan(fid, '%f',2);
            ns = numcell{1}(1)*numcell{1}(2);
            local = cell2mat(textscan(fid, '%f',ns));
            S(k).name = strtrim(localname);
            S(k).x = local(1:2:end);      
            S(k).y = local(2:2:end);       
            fgetl(fid);
            localname = fgetl(fid);
        end
%         
%         n = cell2mat(textscan(fid, '%f'));
%         for i = 1:n
%             disp(['Reading area: ' num2str(i) '/' num2str(n)])
%             localname = textscan(fid, '%s',1);
%             localname = localname{1};
%             localname = char(localname{1});
%             S.name{i} = localname(2:end-1); %#ok<*AGROW>
%             ns = cell2mat(textscan(fid, '%f',1));
%             S.segments{i} = cell2mat(textscan(fid, '%f',ns));
%         end
%         
        fclose(fid);
    case 'write'
        
        %         fid = fopen(polFile,'w+');
        %
        %         n = length(S.name);
        %         fprintf(fid,'%s\n',num2str(n));
        %         for i = 1:n
        %             fprintf(fid,'%s\t %s\n',['''' S.name{i} ''''], num2str(length(S.segments{i})));
        %             fprintf(fid,'%0.0f\n',S.segments{i});
        %         end
        %
        %         fclose(fid);
        
end
