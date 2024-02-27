clear

%%
nx=100;
thetak=linspace(0,0.06,nx);

a_q=5.7;
b_q=1.5;

a_E=0.0199;
b_E=1.5;

a_vpk=11.5;
b_vpk=0.7;

theta_c=0.047;
xik=1;

nf=1;

%% direct

f1=thetak-xik.*theta_c;
f2=sqrt(thetak)-sqrt(xik.*theta_c);

no_trans_idx=thetak-xik.*theta_c<0; %indexes of fractions below threshold ; boolean [nx,nf]
qbk_st=a_q.*(thetak-xik.*theta_c).^b_q; %MPM relation
qbk_st(no_trans_idx)=0; %the transport capacity of those fractions below threshold is 0

no_E_idx=thetak-xik.*theta_c<0; %indexes of fractions below threshold ; boolean [nx,nf]
Ek_st=a_E.*(thetak-xik.*theta_c).^b_E;
Ek_st(no_E_idx)=0; %the transport capacity of those fractions below threshold is 0

no_vpk_idx=sqrt(thetak)-b_vpk.*xik.*sqrt(theta_c)<0; %indexes of fractions below threshold ; boolean [nx,nf]
vpk_st=a_vpk.*(sqrt(thetak)-b_vpk.*xik.*sqrt(theta_c));
vpk_st(no_vpk_idx)=0; %the transport capacity of those fractions below threshold is 0

Dk_st=Ek_st.*vpk_st./qbk_st; 

Dk_st_2=a_E.*(thetak-xik.*theta_c).^b_E.*a_vpk.*(sqrt(thetak)-b_vpk.*xik.*sqrt(theta_c))./(a_q.*(thetak-xik.*theta_c).^b_q);
Dk_st_2(no_vpk_idx)=0;

%% scaled

qbk_sc=qbk_st/max(qbk_st);
Ek_sc=Ek_st/max(Ek_st);
vpk_sc=vpk_st/max(vpk_st);
Dk_sc=Dk_st/max(Dk_st);
Dk_2_sc=Dk_st_2/max(Dk_st_2);

%% PLOT

%% normal
figure
plot(thetak,[qbk_st',Ek_st',vpk_st',Dk_st'])
legend('qb','E','v','D')

%% scaled
figure
plot(thetak,[qbk_sc',Ek_sc',vpk_sc',Dk_sc',Dk_2_sc'])
legend('qb','E','v','D','D2')

%% 

figure
plot(thetak,[f1',f2'])
legend('reg','sqrt')
