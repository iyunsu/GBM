%% ========================================================================
%  File: Gbm2DplotCorr.m
%  Name: I Yun Su
%  Date: 2021.05.25
%  Note:
%  
%% ========================================================================
clear all;clc;
%%
TLname = dir('TL*m.jpg');
PDname = dir('PD*m.jpg');

%%
load TLraPDra.mat

for i =1:length(TLname)
    split = regexp(TLname(i).name, 'm', 'split');
    TLdepth = str2num(split{1}(3:end));
    eval(['TL',num2str(TLdepth),'m1km = TL',num2str(TLdepth),'mraAz(:,1:5:end-15)']);
    eval(['PD',num2str(TLdepth),'m1km = PD',num2str(TLdepth),'mAz(:,1:5:end-15)']);
end

%%
load TLraPDra.mat

eval(['TL',num2str(TLdepth),'mraAz(1:16,1:length(TL',num2str(TLdepth),'m1km)) = TL',num2str(TLdepth),'m1km'])
eval(['PD',num2str(TLdepth),'mAz(1:16,1:length(TL',num2str(TLdepth),'m1km)) = PD',num2str(TLdepth),'m1km'])
%%
save TLraPDra.mat PD*mAz TL*mraAz
