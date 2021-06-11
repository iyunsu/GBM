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
desireDepth = '5';
cd(path_input)
load(['PPDresults',desireDepth,'mPer10m.mat'])
%% Average Filter
windoeSize = 10;
averageWindow = fspecial('average',[windoeSize,windoeSize]);
PPDper10mAfter100mAve = imfilter(PPDper10m,averageWindow);
PPDper100m = PPDper10mAfter100mAve(1:windoeSize:end,1:windoeSize:end);
latGrid100m = latGrid(1:windoeSize:end,1:windoeSize:end);
lonGrid100m = lonGrid(1:windoeSize:end,1:windoeSize:end);
%% Find PPD value over 0.75
threshold = 0.8;
detectedIndex = find(PPDper100m >threshold);
searchPointsLatV2 = latGrid100m(detectedIndex);
searchPointsLonV2 = lonGrid100m(detectedIndex);

%%
ii = pcolor(lonGrid100m,latGrid100m,PPDper100m);ii.LineStyle = 'none';
hold on
plot(searchPointsLonV2,searchPointsLatV2,'*')