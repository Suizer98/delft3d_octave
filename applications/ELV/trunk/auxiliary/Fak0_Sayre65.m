
function [Fak_pt_13,Fak_p_13,Cf_m,Q_m,B_m,s_m,dk_m,dk_13,Fak_pt_2,Fak_p_2,dk_2]=Fak0_Sayre65(input)

%% 
%% RENAME
%%

dx=input.grd.dx;

%% CONVERSION

ft2m=0.3048; %feet to meter
lb2kg=0.453592; %pount to kilogram
% gcuft2c=1/1000/0.3048^3/2650; %gram/ft^3 to concentration

%% 
%% CALC
%%

%% HYDRAULIC DATA

time_hm_i=[1960,11,4 ,11,30,00;...
           1960,11,6 ,17,00,00;...
           1960,11,9 ,17,00,00;...
           1960,11,12,16,15,00;...
           1960,11,16,15,30,00 ...
        ];

Cf_12=[8.7;9.0;10.5;9.6;9.9];
Q=[263;249;251;255;260]*ft2m^3;
B=[47.4;54;56;57;53.4]*ft2m;
s=[0.839;0.844;0.810;0.826;0.860]*1e-3;

time_hm=datetime(time_hm_i);
time_d2=diff(time_hm)/2;
time_int=[time_d2(1);time_d2(1:end-1)+time_d2(2:end);time_d2(end)];

%means
Cf_12_m=sum(time_int.*Cf_12)./sum(time_int);
Cf_m=1/Cf_12_m^2;
Q_m=sum(time_int.*Q)./sum(time_int);
B_m=sum(time_int.*B)./sum(time_int);
s_m=sum(time_int.*s)./sum(time_int);

%% GSD
d_ref=0.001;

%bed
d_lim=[0.088;0.125;0.175;0.250;0.350;0.500;0.700;1.000;1.651;3.327;9.424]./1000;
F=[0;2;6;29;68;91;96;97;98;99;100]./100;

F_d=diff(F);
dk=d_ref*2.^((log2(d_lim(1:end-1)/d_ref)+log2(d_lim(2:end)/d_ref))/2);
dk_m=d_ref*2.^(sum(log2(dk/d_ref).*F_d));

%tracer
d_lim_t=[0.175;0.250;0.350;0.500]./1000;
F_t=[0;9;81;100]./100;

F_d_t=diff(F_t);
dk_t=d_ref*2.^((log2(d_lim_t(1:end-1)/d_ref)+log2(d_lim_t(2:end)/d_ref))/2);
dk_m_t=d_ref*2.^(sum(log2(dk_t/d_ref).*F_d_t));

%% INITIAL VOLUME CONSIDERING dx (mixed-size)

Lx=dx; %length over which the tracer is extended [m]
W=40*lb2kg; %weight of tracer [kg]
La=1.45*ft2m; %active layer thickness [m]
rho_s=2650; %sediment density [kg/m^3]
p=0.4; %porosity [-]

Fak_t_T=W/B_m/La/Lx/rho_s/(1-p); %total volume fraction content of tracer sediment in the active layer considering length of 'nourishment'

Fak_tp=F_d_t.*Fak_t_T; %volume fraction content per size fraction of tracer sediment [-] (partial, not all grain sizes)
Fak_t_10=[0;0;Fak_tp;0;0;0;0;0]; %volume fraction content per size fraction of tracer sediment [-] (considering all grain sizes)

%substitute parent material for tracer sediment without considering separate grain sizes (i.e., 10 grain sizes)
Fak_pwt_10=F_d-Fak_t_10; %parent with tracer

%parent+tracer, tracer in positions 4,6,8
dk_13=[dk(1:2);dk(3);dk(3);dk(4);dk(4);dk(5);dk(5);dk(6:end)];
Fak_pt_13=[Fak_pwt_10(1:2);Fak_pwt_10(3);Fak_t_10(3);Fak_pwt_10(4);Fak_t_10(4);Fak_pwt_10(5);Fak_t_10(5);Fak_pwt_10(6:end)];

%parent without tracer but considering it
Fak_p_13=[F_d(1:2);F_d(3);0;F_d(4);0;F_d(5);0;F_d(6:end)];

%check correct volume fraction content
if abs(sum(Fak_pt_13)-1)>1e-12; error('1'); end  %should be 1
if abs(sum(Fak_p_13 )-1)>1e-12; error('2'); end %should be 1
% if abs(d_ref*2.^(sum(log2(dk_13/d_ref).*Fak_pt_13))- dk_m)>1e-12; error('3'); end

%% INITIAL VOLUME CONSIDERING dx (unisize)

%parent+tracer, tracer in position 2
dk_2=[dk_m;dk_m];
Fak_pt_2=[1-Fak_t_T;Fak_t_T];

%parent without tracer but considering it
Fak_p_2=[1;0];
