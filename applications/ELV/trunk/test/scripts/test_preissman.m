
%% PREAMBLE

clear
clc

%% INPUT

nt=10;
% load('d:\victorchavarri\SURFdrive\projects\00_codes\ELV\branch_V\test\scripts\input_test_preissman.mat') %nx=100
load('d:\victorchavarri\SURFdrive\projects\00_codes\ELV\branch_V\test\scripts\input_test_preissman_2.mat') %nx=1000

%% CHECK IMPLEMENTATION

[U1,H1] = preissmann_1(u,h,etab,Cf,Hdown,qwup,input);
[U2,H2] = preissmann_2(u,h,etab,Cf,Hdown,qwup,input);

tol=1e-10;
if max(abs(U1-U2))>tol || max(abs(H1-H2))>tol; warning('messing up'); else; fprintf('goed! you have not messed up V! \n'); end

%% CHECK TIME

tic;
for kt=1:nt
    preissmann_1(u,h,etab,Cf,Hdown,qwup,input);
end
t1=toc;

tic;
for kt=1:nt
    preissmann_2(u,h,etab,Cf,Hdown,qwup,input);
end
t2=toc;

fprintf('%f s (old), %f s (new), %f %% improvement \n',t1,t2,-(t2-t1)/t1*100)