%% ========================================================================
%  File: CalPPD.m
%  Name: I Yun Su
%  Date: 2021.06.04
%  Note:
%       Calculate the PPD from all detected points.
%% ========================================================================
clear all;clc
%% Set Param
FLPoint = [121.2 22.08];
GuessPoint = [121.19 22.065];
desireDepth = '50';



%% Set Path
path_output = '/home/iyunsu/gbm/Example_121.2_22.08/GbmSearchPoints/37500';
path_detected = '/home/iyunsu/gbm/Example_121.2_22.08/FRLocation/37500_Corr';

cd(path_output)
detectedPointsFolder = dir(['*_',desireDepth,'m']);

%% Get Detected Points
cd(path_detected)
detectedPointsFile = dir(['PD',desireDepth,'results.mat']);
load(detectedPointsFile.name)

%% Get Size of jpg 
cd(path_output)
cd (detectedPointsFolder(1).name)
% jpgSize = (im2double(rgb2gray(imread(['PD',desireDepth,'mGray.png']))));
% [jpgX, jpgY, jpgZ] = size(jpgSize)    
sumPPD = zeros(1468,1468);
iDivisor = zeros(1468, 1468);
cd ../
%% For Loop 
for i = 1:length(detectedPointsFolder)
    %% Get lat amd lon from folder name
    cd (detectedPointsFolder(i).name)
    
    %% load gray jpg
    jpg = flipud(im2double(rgb2gray(imread(['PD',desireDepth,'mGray.png']))));  
    jpg = 1-jpg;
    
    %% delete the jpg data out of frame
    [xFrame, yFrame] = find(round(jpg,4) == 0.8510);
    jpg = jpg(min(xFrame)+1:max(xFrame)-1,min(yFrame)+1:max(yFrame)-1);
    
    %% Average the data
    
    sumPPD = sumPPD + jpg;
    isNotZero = find(jpg~=0);
    iDivisor(isNotZero) = iDivisor(isNotZero) +1;
    
    cd ../
end

%%
PPD = sumPPD./iDivisor;
xPoints = [GuessPoint(1)-0.045: 0.09/(length(PPD)-1):GuessPoint(1)+0.045];
yPoints = [GuessPoint(2)-0.045: 0.09/(length(PPD)-1):GuessPoint(2)+0.045]';

r = pcolor(xPoints,yPoints,PPD);
r.LineStyle = 'none';
hold on
dp = plot(xdetected,ydetected,'b^','MarkerSize',10)
frp = plot(FLPoint(1),FLPoint(2),'s','MarkerEdgeColor','w','MarkerFaceColor','k','MarkerSize',15,'LineWidth',2)
gp = plot(GuessPoint(1),GuessPoint(2),'o','MarkerEdgeColor','w','MarkerFaceColor','r','MarkerSize',15,'LineWidth',3)

c = colorbar
colormap(jet)
caxis([0 1])
legend([frp,gp,dp],{'Flight Recorder','Guess Point','Received signal points'})

c.Label.String = 'Predictive Probability of Detection'
c.Label.Rotation = 90
xlabel('Longitude (˚E)');
ylabel('Latitude (˚N)');
title({['Predictive Probability of Detection Results'],['Received Depth = ',desireDepth,' m']})

%% Save plot
cd(path_output)
saveas(gcf, ['PPDresults',desireDepth,'m.jpg'])
save(['PPDresults',desireDepth,'m.mat'], 'PPD','xPoints','yPoints')

%% Save var per 10me
xPointsPer10m = [min(xPoints):0.0001:max(xPoints)];
yPointsPer10m = [min(yPoints):0.0001:max(yPoints)];

[lonGrid, latGrid] = meshgrid(xPointsPer10m,yPointsPer10m);
[gridCol, gridRow] = size(lonGrid);
PPDper10mLine = interp2(xPoints,yPoints,PPD,reshape(lonGrid,[1,gridCol*gridRow]),reshape(latGrid,[1,gridCol*gridRow]));
PPDper10m = reshape(PPDper10mLine,[gridCol, gridRow])
save(['PPDresults',desireDepth,'mPer10m.mat'],'PPDper10m','lonGrid','latGrid');

%% % CHECK PLOT
% figure()
% tt = pcolor(lonGrid, latGrid, PPDper10m)
% tt.LineStyle = 'none'