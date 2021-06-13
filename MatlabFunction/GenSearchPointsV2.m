%% ========================================================================
%  File: GenSearchPointsV2.m
%  Name: I Yun Su
%  Date: 2021.06.10
%  Note:
%       Calculate the PPD with Average filter
%       Generate the Search Point from first detection results.
%% ========================================================================
clear all;clc
%% Set Path
path_input = '/home/iyunsu/gbm/Example_121.2_22.08/GbmSearchPoints/37500';
path_output = '/home/iyunsu/gbm/Example_121.2_22.08/GbmSearchPointsV2/37500';
zrDepth = '5';
cd(path_input)
load(['PPDresults',zrDepth,'mPer10m.mat'])
%% Average Filter
windoeSize = 20;
averageWindow = fspecial('average',[windoeSize,windoeSize]);
PPDper10mAfter200mAve = imfilter(PPDper10m,averageWindow);
PPDper200m = PPDper10mAfter200mAve(1:windoeSize:end,1:windoeSize:end);
latGrid200m = latGrid(1:windoeSize:end,1:windoeSize:end);
lonGrid200m = lonGrid(1:windoeSize:end,1:windoeSize:end);
%% Find PPD value over 0.75
threshold = 0.75;
detectedIndex = find(PPDper200m >threshold);
searchPointsLatV2 = latGrid200m(detectedIndex);
searchPointsLonV2 = lonGrid200m(detectedIndex);

%% Save Search Points 
save(['2ndPD',num2str(zrDepth),'mDetectedOver',num2str(threshold),'.mat'],'searchPointsLatV2','searchPointsLonV2')
%%   CHECK
ii = pcolor(lonGrid200m,latGrid200m,PPDper200m);ii.LineStyle = 'none';
hold on
plot(searchPointsLonV2,searchPointsLatV2,'*')