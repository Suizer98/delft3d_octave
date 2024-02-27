function RH = relative_humidity(method,T2,Td)
%RELATIVE_HUMIDITY  rel. huimidity in % as as f(air temp., dew point temp.)
%
%   RH = relative_humidity(method,T2,Td) 
%
% calculates the relative humidity RH [%] as a function of
% the air temperature T [Celsius] (at 2 m) and the
% dew point temperature Td [Celsius], using the chosen
% coefficient sets + chosen formulations.
% Use method = 'wmo_water' for the coefficients for
% water substrate, or method='wmo_ice' for ice subtrate or ...
% T and Td can either be in degrees Celsius or in Kelvin
% (any T > 100 is transformed to Celsius), RH is in percent (%).
%
% Example: reproduce Fig 1 from (Lawrence, 2005, BAMS).
%
%    T2    = 0:10:30;colors = {'b--','m-.','g:','r-'};
%    Td    = -60:40;
%    for i = 1:length(T2);
%       RH{i} = relative_humidity('wmo_water',T2(i),Td); % vectorized
%    end
%    
%    subplot(2,1,1)
%    for i = 1:length(T2);
%       plot(RH{i}, Td, colors{i},'Displayname',['T2 = ',num2str(T2(i)),' [\circC]']);hold on
%    end
%    axis([0 100 -60 40]);grid on;legend('location','SouthEast');ylabel('T_D [\circC]');xlabel('RH [%]')
%    title('WMO equation for water')
%    
%    subplot(2,1,2)
%    for i = 1:length(T2);
%       plot(Td, RH{i},colors{i},'Displayname',['T2 = ',num2str(T2(i)),' [\circC]']);hold on
%    end
%    axis([-60 40 0 100]);grid on;legend('location','NorthWest');xlabel('T_D [\circC]');ylabel('RH [%]')
%    print2screensize('relative_humidity_wmo_water')
%
%See also: <a href="http://www.wmo.int/pages/prog/www/IMOP/CIMO-Guide.html">WMO no-8 Guide</a>, <a href="http://www.knmi.nl/samenw/hawa/pdf/Handbook_H01_H06.pdf">KNMI handbook</a>, <a href="http://dx.doi.org/10.1175%2F1520-0450%281981%29020%3C1527%3ANEFCVP%3E2.0.CO%3B2">Buck (1981)</a>, <a href="http://dx.doi.org/10.1175/BAMS-86-2-225">Lawrence (2005)</a>,

% http://www.wmo.int/pages/prog/www/IMOP/CIMO-Guide.html
% http://www.knmi.nl/samenw/hawa/pdf/Handbook_H01_H06.pdf        
% http://dx.doi.org/10.1175%2F1520-0450%281981%29020%3C1527%3ANEFCVP%3E2.0.CO%3B2
% http://dx.doi.org/10.1175/BAMS-86-2-225                                 

if T2(1) > 100;T2 = T2-273.15;end % to degrees_Celsius
if Td(1) > 100;Td = Td-273.15;end % to degrees_Celsius

if     strcmpi(method,'wmo_water'       ); A = 6.112  ; B = 17.62   ; C = 243.12;
elseif strcmpi(method,'knmi_water_synop')|...
       strcmpi(method,'knmi_water_metar')|...
       strcmpi(method,'knmi_water_siam' ); A = 6.11   ; B = 17.504  ; C = 241.20;
elseif strcmpi(method,'knmi_water_insa' ); A = 6.11213; B = 21.50403; C = 241.30;
elseif strcmpi(method,'knmi_water_kis'  ); A = 6.107  ; B = 17.27   ; C = 237.30;
elseif strcmpi(method,'wmo_ice'         ); A = 6.112  ; B = 22.46   ; C = 272.62;
elseif strcmpi(method,'knmi_ice_kis'    ); A = 6.107  ; B = 21.87   ; C = 265.50;
end

   RH = 100 .* (A .* exp(B .* Td ./ (C + Td))) ./ ...
               (A .* exp(B .* T2 ./ (C + T2)));
