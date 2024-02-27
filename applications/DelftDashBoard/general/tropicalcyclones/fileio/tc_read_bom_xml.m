function tc=tc_read_bom_xml(fname)

xml=xml2struct(fname);
d=xml.data.data.disturbance.disturbance;
nt=length(d.fix);
tc.name=xml.data.data.disturbance.disturbance.cycloneName;

% Initialize
for it=1:nt
    tc.time(it)=-999; 
    tc.x(it)=-999; 
    tc.y(it)=-999; 
    tc.vmax(it)=-999; 
    tc.rmax(it)=-999; 
    tc.pc(it)=-999; 
    tc.r35ne(it)=-999;
    tc.r35se(it)=-999;
    tc.r35sw(it)=-999;
    tc.r35nw(it)=-999;
    tc.r50ne(it)=-999;
    tc.r50se(it)=-999;
    tc.r50sw(it)=-999;
    tc.r50nw(it)=-999;
    tc.r65ne(it)=-999;
    tc.r65se(it)=-999;
    tc.r65sw(it)=-999;
    tc.r65nw(it)=-999;
    tc.r100ne(it)=-999;
    tc.r100se(it)=-999;
    tc.r100sw(it)=-999;
    tc.r100nw(it)=-999;
end


for it=1:nt
    tstr=d.fix(it).fix.validTime;
    
    tc.time(it)=datenum(tstr,'yyyy-mm-ddTHH:MM:SSZ');
    tc.y(it)=-str2double(d.fix(it).fix.latitude);
    tc.x(it)=str2double(d.fix(it).fix.longitude);
    data=d.fix(it).fix.cycloneData.cycloneData;
    tc.pc(it)=str2double(data.minimumPressure.minimumPressure.pressure);
    tc.vmax(it)=str2double(data.maximumWind.maximumWind.speed);
    if isfield(data.maximumWind.maximumWind,'radius')
        tc.rmax(it)=str2double(data.maximumWind.maximumWind.radius);
    end

    if isfield(data,'windContours')
        tc.r35ne(it)=str2double(data.windContours.windContours.windSpeed(1).windSpeed.radius(1).radius);
        tc.r35se(it)=str2double(data.windContours.windContours.windSpeed(1).windSpeed.radius(2).radius);
        tc.r35sw(it)=str2double(data.windContours.windContours.windSpeed(1).windSpeed.radius(3).radius);
        tc.r35nw(it)=str2double(data.windContours.windContours.windSpeed(1).windSpeed.radius(4).radius);
        if length(data.windContours.windContours.windSpeed)>1
            tc.r50ne(it)=str2double(data.windContours.windContours.windSpeed(2).windSpeed.radius(1).radius);
            tc.r50se(it)=str2double(data.windContours.windContours.windSpeed(2).windSpeed.radius(2).radius);
            tc.r50sw(it)=str2double(data.windContours.windContours.windSpeed(2).windSpeed.radius(3).radius);
            tc.r50nw(it)=str2double(data.windContours.windContours.windSpeed(2).windSpeed.radius(4).radius);
        end
        if length(data.windContours.windContours.windSpeed)>2
            tc.r65ne(it)=str2double(data.windContours.windContours.windSpeed(3).windSpeed.radius(1).radius);
            tc.r65se(it)=str2double(data.windContours.windContours.windSpeed(3).windSpeed.radius(2).radius);
            tc.r65sw(it)=str2double(data.windContours.windContours.windSpeed(3).windSpeed.radius(3).radius);
            tc.r65nw(it)=str2double(data.windContours.windContours.windSpeed(3).windSpeed.radius(4).radius);
        end
    end

end
