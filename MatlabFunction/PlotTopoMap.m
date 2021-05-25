%% ========================= PlotTopoMap.m ================================
%% 2020.04.20
%% ========================================================================
%% init -------------------------------------------------------------------
clear all;clc
%% Set Point --------------------------------------------------------------
FLPoint = [121.82 23.75]; %[Lon Lat]
GuessPoint = [121.79 23.77]; %[Lon Lat]

%% load data --------------------------------------------------------------
load /home/iyunsu/gbm/SimFunction/taidb500.mat

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
%%
contourf(X,Y,ZZ,[0:-250:-6000],'LineColor',[0.4 0.4 0.4])
%% Plot
% surf(X,Y,ZZ,'LineStyle','none');view(2);
axis equal;
colormap(flipud(myColormap'))
% Plot Coast line
hold on;
contour(X,Y,Z,[0 1],'LineWidth',3,'LineColor','k')
xlim([GuessPoint(1)-0.35 GuessPoint(1)+0.35])
ylim([GuessPoint(2)-0.3 GuessPoint(2)+0.3])
xlabel('Longitude (°E)')
ylabel('Latitude (°N)')
caxis([-5000 0])
c = colorbar
c.Label.String = 'Depth (m)';
hold on;
contour(X,Y,ZZ,[-400:-400:-6000],'LineColor',[0.3 0.3 0.3])
hold on;
% plot(FLPoint(1),FLPoint(2),'w*','MarkerSize',20,'LineWidth',10)
% plot(FLPoint(1),FLPoint(2),'ks','MarkerSize',13,'LineWidth',2)
plot(FLPoint(1),FLPoint(2),'s','MarkerEdgeColor','w','MarkerFaceColor','k','MarkerSize',15,'LineWidth',2)
text(FLPoint(1)+0.01,FLPoint(2)-0.01,'Flight Recorder','BackgroundColor','w','HorizontalAlignment','left','FontSize',25)
hold on;
plot(GuessPoint(1),GuessPoint(2),'o','MarkerEdgeColor','w','MarkerFaceColor','r','MarkerSize',15,'LineWidth',3)
% plot(GuessPoint(1),GuessPoint(2),'k*','MarkerSize',13,'LineWidth',2)
text(GuessPoint(1)-0.01,GuessPoint(2)+0.01,'Guess Point','BackgroundColor','w','HorizontalAlignment','right','FontSize',25)
text(121.57,24,'Hualien Port','HorizontalAlignment','right','FontSize',25)
