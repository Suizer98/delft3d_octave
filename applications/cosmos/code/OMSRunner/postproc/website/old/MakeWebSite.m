clear all;close all;

navpags={'home','news','forecasts','projects','models','links','faq','aboutus','contact'};
navpagslink={'index','news','forecasts','projects','models','links','faq','aboutus','contact'};
navpaglevels=[0 1 1 1 1 1 1 1 1];

%for i=1:length(navpags)
for i=1:1

    ilevel=navpaglevels(1);
    entries(1).title='Tides';
    entries(1).date='May 3, 2008';
    entries(1).img='tide.gif';
    entries(1).text{1}='Tides are the rising and falling of Earth''s ocean surface caused by the tidal forces of the Moon and the Sun acting on the oceans. Tidal phenomena can occur in any object that is subjected to a gravitational field that varies in time and space, such as the Earth''s land masses.';
    entries(1).text{2}='Tides noticeably affect the depth of marine and estuarine water bodies and produce oscillating currents known as tidal streams, making prediction of tides very important for coastal navigation (see Tides and navigation). The strip of seashore that is submerged at high water and exposed at low water, the intertidal zone or foreshore, is an important ecological product of ocean tides. <a href="http://en.wikipedia.org/wiki/Tide">Read more.</a>';

    entries(2).title='Currents';
    entries(2).date='May 3, 2008';
    entries(2).img='current.gif';
    entries(2).text{1}='The regular rise and fall of sea level which in turn results in a tide, is generally accompanied by horizontal movement of the water called tidal current.';
    
    entries(3).title='Waves';
    entries(3).date='May 3, 2008';
    entries(3).img='wave.gif';
    entries(3).text{1}='A wave is a disturbance that propagates through space and time, usually with transference of energy. While a mechanical wave exists in a medium (which on deformation is capable of producing elastic restoring forces), waves of electromagnetic radiation (and probably gravitational radiation) can travel through vacuum, that is, without a medium. Waves travel and transfer energy from one point to another, often with little or no permanent displacement of the particles of the medium (that is, with little or no associated mass transport); instead there are oscillations around almost fixed positions. <a href="http://en.wikipedia.org/wiki/Waves">Read more.</a>';
    
    fid=fopen([navpagslink{i} '.html'],'wt');
    WriteWebsiteInfo(fid,navpags{i});
    WriteWebsiteHead(fid,navpags{i},ilevel);
    WriteWebsiteBody(fid,navpags{i},ilevel);
    WriteWebsiteLeftColumn(fid);
    WriteWebsiteMain(fid,entries,ilevel);
    WriteWebsiteRightColumn(fid,ilevel);
    WriteWebsiteFooter(fid);
    fclose(fid);

end
