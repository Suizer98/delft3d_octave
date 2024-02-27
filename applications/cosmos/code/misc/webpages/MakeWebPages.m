function MakeWebPages

dr='E:\work\OperationalModelSystem\SoCalCoastalHazards\website\';
dr='C:\xampp\htdocs\SoCalCoastalHazards\';

mainurl='http://members.upc.nl/m.ormondt/';
mainurl='http://localhost/SoCalCoastalHazards/';

mainurl='../';

MakeWebPage('index.dat',dr,'');
MakeWebPage('hydromodels.dat',dr,mainurl);
MakeWebPage('weathermodels.dat',dr,mainurl);
MakeWebPage('wavemodels.dat',dr,mainurl);
MakeWebPage('links.dat',dr,mainurl);
MakeWebPage('scenarios.dat',dr,mainurl);
MakeWebPage('faq.dat',dr,mainurl);
MakeWebPage('contact.dat',dr,mainurl);
MakeWebPage('news.dat',dr,mainurl);
MakeWebPage('newsarchive.dat',dr,mainurl);
MakeWebPage('notavailable.dat',dr,'');

function MakeWebPage(fname,dr,mainurl)

txt=ReadTextFile(fname);

hm.mainURL=mainurl;

hm.BannerFile='img/santabarbaraheader.gif';
% hm.BannerFile='img/OMSBanner.jpg';

hm.navpags=    {'home', 'news','forecasts','scenarios','models','links','faq','contact'};
hm.navpagslink={'index.html','news/news.html','scenarios/results.html?s=forecasts','scenarios/scenarios.html','models/hydromodels.html','links/links.html','faq/faq.html','contact/contact.html'};

nbut=0;
nentry=0;
nlinks=0;
nfaqs=0;
ncontacts=0;
nscenarios=0;

hm.LeftButtons1=[];
hm.LeftButtons2=[];

for i=1:length(txt)

    switch lower(txt{i}),
        case {'webpage'},
            hm.name=txt{i+1};
        case {'pagedir'}
            hm.pageDir=txt{i+1};
        case {'pagetype'}
            hm.pageType=txt{i+1};
        case {'filename'}
            hm.FileName=txt{i+1};
        case {'activeheader'}
            hm.ActiveHeader=txt{i+1};
        case {'leftcolumn1'}
            but='LeftButtons1';
        case {'leftcolumn2'}
            but='LeftButtons2';
        case {'button'}
            nbut=nbut+1;
            hm.(but)(nbut).name=txt{i+1};
        case {'buttonurl'}
            hm.(but)(nbut).URL=txt{i+1};
        case {'entry'}
            nentry=nentry+1;
            npar=0;
        case {'title'}
            hm.entry(nentry).title=txt{i+1};
        case {'image'}
            hm.entry(nentry).Image=txt{i+1};
        case {'date'}
            hm.entry(nentry).Date=txt{i+1};
        case {'paragraph'}
            npar=npar+1;
            hm.entry(nentry).paragraph{npar}=txt{i+1};
        case {'link'}
            nlinks=nlinks+1;
            hm.Links(nlinks).name=txt{i+1};
        case {'linkurl'}
            hm.Links(nlinks).URL=txt{i+1};
        case {'question'}
            nfaqs=nfaqs+1;
            hm.Faqs(nfaqs).Question=txt{i+1};
        case {'answer'}
            hm.Faqs(nfaqs).Answer=txt{i+1};
        case {'contactname'}
            ncontacts=ncontacts+1;
        case {'contactdetails'}
            hm.contacts(ncontacts).Details=txt{i+1};
        case {'scenario'}
            nscenarios=nscenarios+1;
            hm.scenarios(nscenarios).name=txt{i+1};
        case {'scenarioabbr'}
            hm.scenarios(nscenarios).shortName=txt{i+1};
    end
end

f=[dr hm.pageDir '\' hm.FileName];
fid=fopen(f,'wt');

WriteWebsiteInfo(fid);
WriteWebsiteHead(fid,hm.name,hm.mainURL);
WriteWebsiteHeader(fid,hm,hm.ActiveHeader,0,hm.BannerFile);

buttons1=[];
buttons2=[];
if ~isempty(hm.LeftButtons1)
    for i=1:length(hm.LeftButtons1)
        buttons1(i).link=[hm.mainURL hm.LeftButtons1(i).URL];
        buttons1(i).text=hm.LeftButtons1(i).name;
    end
end
if ~isempty(hm.LeftButtons2)
    for i=1:length(hm.LeftButtons2)
        buttons1(i).link=[hm.mainURL hm.LeftButtons2(i).URL];
        buttons1(i).text=hm.LeftButtons2(i).name;
    end
end
if ~isempty(buttons1) || ~isempty(buttons2)
    WriteWebsiteLeftColumn(fid,buttons1,buttons2);
end

fprintf(fid,'%s\n','            <div id="main">');
fprintf(fid,'%s\n','');

switch lower(hm.pageType)

    case{'home'}
        fprintf(fid,'%s\n','                <img src="img/CliffLV1cvPLSLG.jpg"/>');
        fprintf(fid,'%s\n','');
        for i=1:length(hm.entry)
            fprintf(fid,'%s\n',['                <h3>' hm.entry(i).title '</h3>']);
            for j=1:length(hm.entry(i).paragraph)
                fprintf(fid,'%s\n',['                <p>' hm.entry(i).paragraph{j} '</p>']);
            end
            fprintf(fid,'%s\n','');
        end
    
    case{'models'}
        for i=1:length(hm.entry)
            fprintf(fid,'%s\n','                <div class="entry">');
            fprintf(fid,'%s\n',['                    <h2>' hm.entry(i).title '</h2>']);
            fprintf(fid,'%s\n','                    <p class="date">.</p>');
            fprintf(fid,'%s\n','                    <div class="photo_text">');
            fprintf(fid,'%s\n',['                        <p class="photo"><img src="' hm.mainURL hm.entry(i).Image '"/></p>']);
            for j=1:length(hm.entry(i).paragraph)
                fprintf(fid,'%s\n',['                        <p>' hm.entry(i).paragraph{j} '</p>']);
            end
            fprintf(fid,'%s\n','                    </div> <!-- end .photo_text -->');
            fprintf(fid,'%s\n','                </div> <!-- end .entry -->');
            fprintf(fid,'%s\n','');
        end

    case{'news'}
        for i=1:length(hm.entry)
            fprintf(fid,'%s\n','                <div class="entry">');
            fprintf(fid,'%s\n',['                    <h3>' hm.entry(i).title '</h3>']);
            fprintf(fid,'%s\n',['                    <p class="date">' hm.entry(i).Date '</p>']);
            fprintf(fid,'%s\n','                    <div class="photo_text">');
            fprintf(fid,'%s\n',['                        <p class="photo"><img src="' hm.mainURL hm.entry(i).Image '"/></p>']);
            for j=1:length(hm.entry(i).paragraph)
                fprintf(fid,'%s\n',['                        <p>' hm.entry(i).paragraph{j} '</p>']);
            end
            fprintf(fid,'%s\n','                    </div> <!-- end .photo_text -->');
            fprintf(fid,'%s\n','                </div> <!-- end .entry -->');
            fprintf(fid,'%s\n','');
        end

    case{'links'}
        fprintf(fid,'%s\n','                <h2>Links</h2>');
        fprintf(fid,'%s\n','                <p></p>');
        for i=1:length(hm.Links)
            fprintf(fid,'%s\n',['                <p><a href="' hm.Links(i).URL '">' hm.Links(i).name '</a></p>']);
        end
        fprintf(fid,'%s\n','');

    case{'faq'}
        fprintf(fid,'%s\n','                <h2>Frequently asked questions</h2>');
        for i=1:length(hm.Faqs)
            fprintf(fid,'%s\n','                <p></p>');
            fprintf(fid,'%s\n',['                <p><i>' hm.Faqs(i).Question '</i></p>']);
            fprintf(fid,'%s\n',['                <p><i>' hm.Faqs(i).Answer '</i></p>']);
        end
        fprintf(fid,'%s\n','');

    case{'contact'}
        fprintf(fid,'%s\n','                <h2>Contact</h2>');
        fprintf(fid,'%s\n','                <p></p>');
        for i=1:length(hm.contacts)
            fprintf(fid,'%s\n',['                <p>' hm.contacts(i).Details '</p>']);
        end
        fprintf(fid,'%s\n','');

    case{'notavailable'}
        fprintf(fid,'%s\n','                <p>Sorry, this page is not available.</p>');
        fprintf(fid,'%s\n','');

    case{'scenarios'}
        fprintf(fid,'%s\n','                <h2>Scenarios</h2>');
        fprintf(fid,'%s\n','                <p></p>');
        for i=1:length(hm.scenarios)
            fprintf(fid,'%s\n',['                <p><a href="results.html?s=' hm.scenarios(i).shortName '">' hm.scenarios(i).name '</a></p>']);
        end
        fprintf(fid,'%s\n','');
        
end

fprintf(fid,'%s\n','            </div> <!-- end #main -->');
fprintf(fid,'%s\n','');

if strcmpi(hm.pageType,'home')
    WriteWebsiteFooter(fid,1);
else
    WriteWebsiteFooter(fid,0);
end

fclose(fid);



