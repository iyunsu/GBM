%% ========================================================================
%  File: GenSearchPoints.m
%  Name: I Yun Su
%  Date: 2021.04.10
%  Note:
%
%% ========================================================================
clear all;clc
%% Set Param
FLPoint = [121.2 22.08];
GuessPoints = [121.19 22.065]; %[lon lat]

wayPointLon = [GuessPoints(1)-0.025:0.005:GuessPoints(1)+0.025];
wayPointLat = [GuessPoints(2)-0.025:0.005:GuessPoints(2)+0.025];
[x, y] = meshgrid(wayPointLon,wayPointLat)
%% Load data

load TLraPDra.mat
lonData = dir('*lon*');
latData = dir('*lat*')
lon = load(lonData.name);
lat = load(latData.name);

%% Get zr Depth
zrDepthName = dir('TL*m.jpg');

for i=1:length(zrDepthName)
    split = regexp(zrDepthName(i).name, 'm', 'split');
    zrDepth = str2num(split{1}(3:end));
    %% Plot PD
    % surf
    % p = surf([lon; lon(1,:)],[lat;lat(1,:)],[PD5mAz;PD5mAz(1,:)],'LineStyle','none','FaceColor','interp')
    % p.FaceColor = 'interp';
    % p.Annotation.LegendInformation.IconDisplayStyle = 'off';
    % view(2);axis equal
    %pcolor
    eval(['PD = PD',num2str(zrDepth),'mAz']) 
    f1 = figure(1)
    ax1 = axes;
    p = pcolor([lon; lon(1,:)],[lat;lat(1,:)],[PD;PD(1,:)]);
    p.Annotation.LegendInformation.IconDisplayStyle = 'off';
    p.EdgeColor = 'none';
    p.FaceColor = 'interp';
    axis equal
    colormap
    RBmap = [0.7:0.01:1;ones(1,31)*0.7;1:-0.01:0.7]';
    colormap(RBmap)
    c = colorbar;
    caxis([0 1])
    % FR location
    hold on
    plot(FLPoint(1),FLPoint(2),'s','MarkerEdgeColor',[0.5 0.5 0.5],'MarkerSize',10,'LineWidth',2)
    % guess point
    plot(GuessPoints(1),GuessPoints(2),'o','MarkerEdgeColor','r','MarkerSize',10,'LineWidth',2)
    % way point
    plot(x,y,'k.','MarkerSize',10,'DisplayName','Search points')
    % legend
    legend('Flight recorder','Guess point','Search points')
    
    % axis label & limits
    xlim([min(wayPointLon)-0.02 max(wayPointLon)+0.02 ])
    ylim([min(wayPointLat)-0.02 max(wayPointLat)+0.02 ])
    caxis([0 1])
    c.Label.String = 'Predictive Probability of Detection'
    c.Label.Rotation = 90
    xlabel('Longitude (˚E)');
    ylabel('Latitude (˚N)');
    
    saveas(gcf,['PD',num2str(zrDepth),'mPoints.jpg'])
    
    %% Get PD value
    
    f2 = figure(2)
    p = pcolor([lon; lon(1,:)],[lat;lat(1,:)],[PD;PD(1,:)]);
    p.Annotation.LegendInformation.IconDisplayStyle = 'off';
    p.EdgeColor = 'none';
    p.FaceColor = 'interp';
    axis equal
    colormap(flipud(gray))
    caxis([0 1])
    xticks([])
    yticks([])
    set (gca,'position',[0,0,1,1] );
    set(gcf,'position',[93.3333  200.3333  331.3334  246.6667])
    saveas(f2,['PD',num2str(zrDepth),'mGray.jpg'])
    
    %% Load jpd data
    jpg = flipud(im2double(rgb2gray(imread(['PD',num2str(zrDepth),'mGray.jpg']))));
    jpg = 1-jpg;
    jpgCorr = jpg(9:end-8,7:end-1);
    
    minX = min(min(lon));
    maxX = max(max(lon));
    minY = min(min(lat));
    maxY = max(max(lat));
    jpgX = [minX:(maxX-minX)/(length(jpgCorr(1,:))-1):maxX]';
    jpgY = minY:(maxY-minY)/(length(jpgCorr(:,1))-1):maxY;
    
    % Get Search Points PPD data
    [sizeC sizeR] = size(x);
    PDinterpResults = interp2(jpgX,jpgY,jpgCorr,reshape(x,[1,sizeC*sizeR]),reshape(y,[1,sizeC*sizeR]))
    PDover50points = find(PDinterpResults>0.5)
   
    xline = reshape(x,[1,sizeC*sizeR]);
    yline = reshape(y,[1,sizeC*sizeR]);
%     plot(xline(ans),yline(ans),'*')
    xdetected = xline(PDover50points);
    ydetected = yline(PDover50points);
    
    save(['PD',num2str(zrDepth),'results.mat'] ,'xdetected' ,'ydetected')
    %%try
%     f3 = figure()
%     j = pcolor(jpgX,jpgY,jpgCorr)
%     j.Annotation.LegendInformation.IconDisplayStyle = 'off';
%     j.EdgeColor = 'none';
%     j.FaceColor = 'interp';
%     colormap(flipud(gray))
%     axis equal
    hold( ax1,'on');
    plot(ax1,xdetected,ydetected,'r^','MarkerSize',10,'DisplayName','Received signal points')
    saveas(f1,['PD',num2str(zrDepth),'mReceivedPoints.jpg'])
   
end
%% Check Data
% j = pcolor(jpgCorr)
% j.Annotation.LegendInformation.IconDisplayStyle = 'off';
% j.EdgeColor = 'none';
% j.FaceColor = 'interp';
% colormap(flipud(gray))
% axis equal
