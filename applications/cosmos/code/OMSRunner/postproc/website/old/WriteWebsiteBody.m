function WriteWebsiteBody(fid,navpag,ilevel)

bcksl=repmat('../',1,ilevel);

fprintf(fid,'%s\n','<body>');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','<div id="wrap">');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','	<div id="screen">');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','         <div id="header">');
fprintf(fid,'%s\n',['           <img src="' bcksl 'img/victoria.gif"/>']);
fprintf(fid,'%s\n','            <p id="navbuttons">');

navpags={'home','news','forecasts','projects','models','links','faq','aboutus','contact'};
navpagstxt={'home','news','forecasts','projects','models','links','faq','about us','contact'};
navpagslink={'index','news','forecasts','projects','models','links','faq','aboutus','contact'};


for i=1:length(navpags)
    if i<length(navpags)
        bullet='&#8226;';
    else
        bullet='';
    end
    if strcmpi(navpag,navpags{i})
       fprintf(fid,'%s\n',['            ' navpagstxt{i} bullet]);
    else
       fprintf(fid,'%s\n',['			<a href="' bcksl navpagslink{i} '/' navpagslink{i} '.html"           class="navlink" >' navpagstxt{i} ' </a>' bullet]);
    end
end    
fprintf(fid,'%s\n','			<p></p>');
fprintf(fid,'%s\n','		</div> <!-- end #header -->');
fprintf(fid,'%s\n','');

