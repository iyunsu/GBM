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
desireDepth = '5';
sumPPD = zeros(1192,1192);
iDivisor = zeros(1192,1192);

%% Set Path
path_output = '/home/iyunsu/gbm/Example_121.2_22.08/GbmSearchPoints/37500';
path_detected = '/home/iyunsu/gbm/Example_121.2_22.08/FRLocation/37500_Corr';

cd(path_output)
detectedPointsFolder = dir(['*_',desireDepth,'m']);

%% Get Detected Points
cd(path_detected)
detectedPointsFile = dir(['PD',desireDepth,'results.mat']);
load(detectedPointsFile.name)

%% For Loop - all points
cd(path_output)

for i = 1:length(detectedPointsFolder)
    %% Get lat amd lon from folder name
    cd (detectedPointsFolder(i).name)
    
    %% load gray jpg
    jpg = flipud(im2double(rgb2gray(imread('PD5mGray.jpg'))));
    jpg = jpg(4:end,1:end-3);
    jpg = 1-jpg;
    
    %% Average the data
    
    sumPPD = sumPPD + jpg;
    isNotZero = find(jpg~=0);
    iDivisor(isNotZero) = iDivisor(isNotZero) +1;
    
    cd ..
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
