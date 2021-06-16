%% ========================================================================
%  File: PlotResults.m
%  Name: I Yun Su
%  Date: 2021.06.16
%  Note: Test plot for
%
%
%% ========================================================================
clear all;clc
%% Set Path
path_func = '/home/iyunsu/gbm/SimFunction/'
path_output = '/home/iyunsu/gbm/Example_121.2_22.08/GbmSearchPointsV2/37500';
%% Set Param 
FLPoint = [121.2 22.08];
GuessPoint = [121.19 22.065];
zrDepth = '100';
%% Load topo data & PPD results
cd(path_output)
PPDfileName = ['PPDresults',zrDepth,'mPer10m.mat']
load(PPDfileName)
minX = min(min(lonGrid));
maxX = max(max(lonGrid));
minY = min(min(latGrid));
maxY = max(max(latGrid));

cd(path_func)
load taidb500.mat
% Remove the unused data
iXmin = find(abs(X(1,:)-minX) == min(abs(X(1,:)-minX)));
iXmax = find(abs(X(1,:)-maxX) == min(abs(X(1,:)-maxX)));
iYmax = find(abs(Y(:,1)-minY) == min(abs(Y(:,1)-minY)));
iYmin = find(abs(Y(:,1)-maxY) == min(abs(Y(:,1)-maxY)));
X = X(iYmin:iYmax,iXmin:iXmax);
Y = Y(iYmin:iYmax,iXmin:iXmax);
Z = Z(iYmin:iYmax,iXmin:iXmax);

%% Average Filter (PPD per 200m)
windoeSize = 20;
averageWindow = fspecial('average',[windoeSize,windoeSize]);
PPDper10mAfter200mAve = imfilter(PPDper10m,averageWindow);
PPDper200m = PPDper10mAfter200mAve(1:windoeSize:end,1:windoeSize:end);
latGrid200m = latGrid(1:windoeSize:end,1:windoeSize:end);
lonGrid200m = lonGrid(1:windoeSize:end,1:windoeSize:end);

%% CHECK
figure()
% p = pcolor(lonGrid200m,latGrid200m,PPDper200m);
% p.LineStyle = 'none';
% p.FaceColor = 'interp';
% axis equal
% hold on
%% Plot topoMap ----------------------------------------------------------
%% remove data depth>0
ZZ = Z;
ZZ(Z>0)=nan;

%% Set colorbar

color0 = [244/256 238/256 225/256]
color1 = [180/256 229/256 193/256];
color2 = [133/256 206/256 184/256];
color3 = [81/256 173/256 162/256];
% color4 = [29/256 100/256 96/256];
color4 = [54/256 127/256 150/256];
color5 = [37/256 69/256 138/256];
n = 63;
myColormap = []
for i = 1:3
    myColormapTemp = [color0(i):(color1(i)-color0(i))/n:color1(i) color1(i):(color2(i)-color1(i))/n:color2(i) color2(i):(color3(i)-color2(i))/n:color3(i) color3(i):(color4(i)-color3(i))/n:color4(i) color4(i):(color5(i)-color4(i))/n:color5(i)]
    myColormap = [myColormap; myColormapTemp]
end
%% Topomap
[C,h] = contourf(X,Y,ZZ,[0:-10:-6000],'LineColor',[0.4 0.4 0.4],'ShowText','on')
clabel(C,h,'FontSize',20,'Color',[0.4 0.4 0.4],'FontName','Courier','LabelSpacing',500)
axis equal;
colormap(flipud(myColormap'))

% Plot Coast line
hold on;
contour(X,Y,Z,[0 1],'LineWidth',3,'LineColor','k')
xlabel('Longitude (°E)')
ylabel('Latitude (°N)')
c = colorbar
c.Label.String = 'Depth (m)';
% hold on;
% contour(X,Y,ZZ,[-10:-10:-6000],'LineColor',[0.3 0.3 0.3],'ShowText','on')


%% Find MAXk 200m and Plot
k=1
maxkVal = maxk(reshape(PPDper200m,[1 length(PPDper200m)^2]),k)
for i = 1:k
    [maxX(i) maxY(i)] = find(PPDper200m == maxkVal(i));
    pR = plot(lonGrid200m(maxX(i),maxY(i)),latGrid200m(maxX(i),maxY(i)),'p','MarkerEdgeColor','w','MarkerFaceColor','r','MarkerSize',20,'LineWidth',2)
%     text(lonGrid200m(maxX(i),maxY(i))+0.001,latGrid200m(maxX(i),maxY(i))+0.001,'Guess Point','BackgroundColor','w','HorizontalAlignment','left','FontSize',25)

    hold on
end
% Plot Hot Zone
hold on
t = linspace(0, 2*pi);
r = 0.005;
x = r*cos(t)+lonGrid200m(maxX(i),maxY(i));
y = r*sin(t)+latGrid200m(maxX(i),maxY(i));
pP = patch(x, y, [0.8500 0.3250 0.0980],'FaceAlpha',0.3,'EdgeColor',[0.8500 0.3250 0.0980])

% Plot line from FR recorder to highest PPD points
distance(22.08,121.2,latGrid200m(maxX,maxY),lonGrid200m(maxX,maxY))
plot([FLPoint(1) lonGrid200m(maxX(i),maxY(i))],[FLPoint(2) latGrid200m(maxX(i),maxY(i))],'k--')
kmDist = 100*distance(FLPoint(2),FLPoint(1),latGrid200m(maxX(i),maxY(i)),lonGrid200m(maxX(i),maxY(i)))
text(mean([FLPoint(1) lonGrid200m(maxX(i),maxY(i))])+0.001,mean([FLPoint(2) latGrid200m(maxX(i),maxY(i))]),[num2str(round(kmDist,2)),' km'],'HorizontalAlignment','left','FontSize',25)
hold on;

% Plot FR recorder
pF = plot(FLPoint(1),FLPoint(2),'s','MarkerEdgeColor','w','MarkerFaceColor','k','MarkerSize',12,'LineWidth',2)
text(FLPoint(1)+0.001,FLPoint(2)+0.001,'Flight Recorder','BackgroundColor','w','HorizontalAlignment','left','FontSize',25)
hold on;
pG = plot(GuessPoint(1),GuessPoint(2),'o','MarkerEdgeColor','w','MarkerFaceColor','r','MarkerSize',10,'LineWidth',3)
text(GuessPoint(1)+0.001,GuessPoint(2)+0.001,'Guess Point','BackgroundColor','w','HorizontalAlignment','left','FontSize',25)

% plot setting

xlim([121.18 121.22])
ylim([22.06 22.09])

legend([h pP],'Topographic map (m)','Hot Zone (r=0.5km)')
title({['Detection Results'],['Depth = ',zrDepth,'m']})
cd(path_output)
saveas(gcf,['hotZone',zrDepth,'m.jpg'])