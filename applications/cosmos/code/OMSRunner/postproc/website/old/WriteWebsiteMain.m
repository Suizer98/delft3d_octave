function WriteWebsiteLeftColumn(fid,entries,ilevel)

fprintf(fid,'%s\n','        <div id="main">');

n=length(entries);
for i=1:n
    WriteWebsiteEntry(fid,entries(i),ilevel);
end

fprintf(fid,'%s\n','        </div> <!-- end #main -->');
fprintf(fid,'%s\n','');