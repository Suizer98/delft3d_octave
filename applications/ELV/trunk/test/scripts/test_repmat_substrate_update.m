
clear all
clc

%% INPUT 

%% test

ni=10;

%% CHECK IMPLEMENTATION

%% input

% save('d:\victorchavarri\SURFdrive\projects\00_codes\ELV\branch_V\test\scripts\input_test_repmat_substrate_update.mat','Mak','msk','Ls','La_old','La','etab_old','etab','qbk','input');
load('input_test_repmat_substrate_update.mat')

%% call

[msk_new_1,Ls_new_1,fIk_1,detaLa_1]=substrate_update_1(Mak,msk,Ls,La_old,La,etab_old,etab,qbk,input);
[msk_new_2,Ls_new_2,fIk_2,detaLa_2]=substrate_update_2(Mak,msk,Ls,La_old,La,etab_old,etab,qbk,input);

%% check

if abs(max(max(msk_new_1-msk_new_2)))>1e-16; error('...'); end
if abs(max(max(Ls_new_1-Ls_new_2)))>1e-16; error('...'); end
if abs(max(max(fIk_1-fIk_2)))>1e-16; error('...'); end
if abs(max(max(detaLa_1-detaLa_2)))>1e-16; error('...'); end

%% TEST TIME

%% call

tic_1=tic;
for ki=1:ni
    [msk_new_1,Ls_new_1,fIk_1,detaLa_1]=substrate_update_1(Mak,msk,Ls,La_old,La,etab_old,etab,qbk,input);
end
t1=toc(tic_1);

tic_2=tic;
for ki=1:ni
    [msk_new_2,Ls_new_2,fIk_2,detaLa_2]=substrate_update_2(Mak,msk,Ls,La_old,La,etab_old,etab,qbk,input);
end
t2=toc(tic_2);

%% disp

fprintf('without repmat we gain %4.1f %% time \n',-(t2-t1)/t1*100)