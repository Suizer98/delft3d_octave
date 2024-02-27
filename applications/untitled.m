grd = 'D:/Sea4cast/Delft3d_Controller/temp/tmpexz_rjbw/h06-cut_o.grd';
dry = 'D:/Sea4cast/Delft3d_Controller/temp/tmpexz_rjbw/o01a.dry';
out = 'D:/test/g5.geojson'
thd = 'D:/Sea4cast/Delft3d_Controller/temp/tmpexz_rjbw/o01a.thd';
%grd2geojson(grd,out)
%dry2geojson(dry,grd,out);
thd2geojson(thd,grd,out);