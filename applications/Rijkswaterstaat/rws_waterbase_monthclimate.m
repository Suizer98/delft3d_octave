function rws_waterbase_monthclimate(datadirectory)
%RWS_WATERBASE_MONTHCLIMATE  routine to convert and plot RWS watrbase.nl (Donar) data to monthly averages
%
%   rws_waterbase_monthclimate(datadirectory)
%
% See also: RWS_WATERBASE_READ

%% Copyright
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Bas van Maren, 4 aug 2009
%
%       @
%
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   -------------------------------------------------------------------- 

%datadirectory  = 'D:\Projects\Z4573_Eems-Dollard\data\donar\txt_donar_data\';
eval(['cd ' datadirectory]);
fileno=dir('id*.*')

for h=1:size(fileno)                         % Number of files in directory
D          = rws_waterbase_read(fileno(h).name)
locationno = char(D.data.location)
tt=size((locationno),1)  ;                   % Number of locations
for i = 1: tt
    t      = D.data(i).datenum;              % time         
    v      = D.data(i).waarde;               % value
    months = str2num(datestr(t,'mm'));        
    C_m=[];                                 
    STD_m=[];
    % find all values per month, compute average and standard deviation,
    % and write to matrix
    for m=1:12;
        f          = find(months==m);
        data_m     = v(f);
        c_m        = nanmean(data_m);
        std_m      = nanstd(data_m);
        C_m(m,1)   = c_m;
        STD_m(m,1) = std_m;
    end
    % add last month value as first month value
    C_m=[C_m(end,:); C_m];
    STD_m=[STD_m(end,:); STD_m];
    % plot
    figure
    set   (gcf,'PaperUnits','centimeters','PaperOrientation','portrait','papertype','A4','paperposition',[1 1 9 9])
    set   (gcf,'renderer','zbuffer')
    errorbar([0:12],C_m,[C_m-STD_m],[C_m+STD_m]);
    set   (gca,'yscale','log','xlim',[0 12])
    xlabel('months');
    ylabel(D.data(i).waarnemingssoort);
    title ([D.data(i).location])
    basename=[D.data(i).location, '-' , D.data(i).waarnemingssoort(1:12),'-monthly_averages']
    % export graphics and dump output in mat file
    print (basename,'-dpng','-r200')   
    print (basename,'-deps')   
    save  ([basename])
end 
end
