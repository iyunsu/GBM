%% ========================================================================
%  File: GbmBottomSource.m
%  Name: I Yun Su
%  Date: 2021.04.10
%  Note:
%  Source depth is at the bottom.
%  Receiver depth is setted as SetParam.zr
%
%% ========================================================================
clear all;clc

%% Set Path ---------------------------------------------------------------
path_output = '/home/iyunsu/gbm/Example_121.6_23.12/FRLocation/37500_5kmds20dz50/';
path_func = '/home/iyunsu/gbm/SimFunction/';
addpath (path_func);

%% Load Data --------------------------------------------------------------
cd (path_func);
load taidb500.mat
load sediment.mat

%% Set Param --------------------------------------------------------------

Source = [121.82 23.75];
slat = Source(2);
slon = Source(1);
SetParam.fre = 37500;             % Source Frequency (Hz)
SetParam.bandwidth = 1000;      % Source Frequency bandwidth
azNumber = 16;
SL = 160;
 

isdep = 'flase';
SetParam.rdr = 50;          % Reciever distance spacing (TL.out)
SetParam.cdr = 50;
SetParam.rmax = 5000;
SetParam.m = 7;                  % month

SetParam.zr = [5 10 50 100 150 200];                 % Receiver Depth (m)
SetParam.ds = 10;
SetParam.dz = 25;  

% SetParam.d1 = min(SetParam.zr);                % Receiver Depth for dts.in
% SetParam.d2 = max(SetParam.zr);                % Receiver Depth for dts.in

zrNumber = length(SetParam.zr);

               % depth spacing for calculating
SetParam.bathdr = 100;            % substrate spacing
SetParam.the1 = -89.5;
SetParam.the2 = 89.5;
SetParam.thei = 1;

SetParam.cz1 = min(SetParam.zr);
SetParam.cz2 = max(SetParam.zr);
SetParam.cdz = 1;


%% Calcualte Param --------------------------------------------------------

cd (path_output)

% The corrdinate of the rmax/rdr
[coordLat, coordLon] = GenMultiAzCoord(slat,slon,azNumber,SetParam.rmax,SetParam.rdr);

%%
for ii =1:azNumber
    % Set Path
    cd(path_output);
    folderName = ['AZ' num2str(ii)]
    mkdir(folderName)
    cd (folderName)
    % Get Depth
    SetParam.depth = -interp2(X,Y,Z,coordLon(ii,:),coordLat(ii,:)); % depth from source to receiver (per rdr)
    
    % Source Depth
    SetParam.zs = fix(SetParam.depth(1))-1;
    
    % Get Sediment data
    for i = 1:1:length(coordLon(1,:))
        [~,n_lon(i)]=(min(abs(sed_lon-coordLon(ii,i))));
        [~,n_lat(i)]=(min(abs(sed_lat-coordLat(ii,i))));
        sed_s(i) = sed_index(n_lat(i),n_lon(i));
        switch sed_s(i)
            case 1
                SetParam.Mz(i) = -4;
            case 2
                SetParam.Mz(i) = -3;
            case 3
                SetParam.Mz(i) = -2;
            case 4
                SetParam.Mz(i) = 0.92;
            case 5
                SetParam.Mz(i) = 5.4;
            case 6,1
                SetParam.Mz(i) = 9.5;
        end
    end
    
    % Get SSP
    ssp_head = [0:2:10 15:5:100 110:10:200 220:20:300 350 400:100:1500 1600:200:6600]';
    SSP = [ssp_head];
    
    for i = 1:length(coordLon(1,:))
        ssp=Extract(coordLon(ii,i),coordLat(ii,i),SetParam.m);        % The number is the month (Extraxt is the function)
        SSP(1:length(ssp),i+1)=ssp(:,4);
        T = interp1(ssp(:,1),ssp(:,2),SetParam.depth(i),'linear','extrap');
        Vw = interp1(ssp(:,1),ssp(:,4),SetParam.depth(i),'linear','extrap');
        
        % run GA.m
        [SetParam.cb(i),SetParam.thob(i),SetParam.alphab(i)]=GA_iys(SetParam.Mz(i), SetParam.depth(i), T, Vw);
    end
    
    SetParam.zmax = SSP(length(ssp),1)+1000;            % max depth culafor calting the TL (Larger than SSP depth)
    %% Generate .in file
    
    copyfile([path_func 'Gbm.exe'],[path_output folderName])
    copyfile([path_func 'gbm.sh'],[path_output folderName])
    GenInFile(SetParam,SSP,'false',pwd)
    system(['sh gbm.sh']);
    delete TRACE.OUT SSP_INPUT.IN PQ.OUT KNOTS.OUT Gbm.exe gbm.sh GA.out CHECK.SSP BATHY.OUT
    
    %% Get TL data at each zr
    TL = load('TL.GRID');
    TLreshape = reshape(TL(:,5),[max(SetParam.zr)-min(SetParam.zr)+1 SetParam.rmax/SetParam.cdr]);
    zSquare = ones(SetParam.rmax/SetParam.cdr+1,length(SetParam.zr)).*(SetParam.zr-SetParam.zs).^2;
    sSquare = ones(SetParam.rmax/SetParam.cdr+1,length(SetParam.zr)).*([0:SetParam.rdr:SetParam.rmax]').^2;
    distanceFromSource2Receiver = sqrt(zSquare'+sSquare');
    switch SetParam.fre
        case 8800
            absorptionCoeff = 6.5/1000*0.9144;
            NL = 68;
        case 37500
            absorptionCoeff = 10/1000*0.9144;
            NL = 60;
    end
    
    % PD setup
    
    
    for izr = 1:zrNumber
        temp = TLreshape(SetParam.zr(izr)-min(SetParam.zr)+1,:)
        TLName = ['TL',num2str(SetParam.zr(izr)),'m'];
        if distanceFromSource2Receiver(izr,1) >1000
            TL0 = 30+10*log10(distanceFromSource2Receiver(izr,1));
        elseif distanceFromSource2Receiver(izr,1) <= 1000
            TL0 = 20*log10(distanceFromSource2Receiver(izr,1));
        end
        eval([TLName,'=','[TL0 temp]',';']);
        absroption = absorptionCoeff*distanceFromSource2Receiver(izr,:)
        
        TLaName = ['TL',num2str(SetParam.zr(izr)),'m_a'];
        eval(['TL_a =', TLName, '+absroption']);
        eval([TLaName,'=TL_a']);
        
        %% Range Average
        
        alpha = SetParam.bandwidth/SetParam.fre;
        rForTLGRID = 0:SetParam.cdr:SetParam.rmax;
        windowWidth = round(rForTLGRID.*alpha/SetParam.cdr/2,0); % Window width from 500 to 4500
        StartRangeIndex = min(find(windowWidth==1));
        if isempty(StartRangeIndex) ==0
            EndRangeIndex = length(rForTLGRID)-windowWidth(end);
        
            pressureTL = sqrt(10.^(TL_a./10));
            TLra = nan(1,length(rForTLGRID));
            for iw =StartRangeIndex:EndRangeIndex
                meanP = mean(pressureTL(iw-windowWidth(iw):iw+windowWidth(iw)));
                TLra(iw) = 20*log10(meanP);
            end
            
            TLraName = ['TL',num2str(SetParam.zr(izr)),'m_ra'];
            TLra(1:StartRangeIndex-1) = TL_a((1:StartRangeIndex-1));
            eval([TLraName,'=','TLra']);
        else
            TLraName = ['TL',num2str(SetParam.zr(izr)),'m_ra'];
            TLra = TL_a;
            eval([TLraName,'=',TLaName]);
        end
        %         plot(TL_a);hold on;plot(TLra)
        %         colormap(jet)
        
        %% PD
        SE = SL - TLra - NL;
        x = -50:0.1:50;
        pd = makedist('Normal','mu',0,'sigma',10);
        y = cdf(pd,x)
        PD = interp1(x,y,SE,'linear','extrap')
        eval(['PD',num2str(SetParam.zr(izr)),'m=','PD'])
        eval(['PD',num2str(SetParam.zr(izr)),'mAz(', num2str(ii),',:)=PD',num2str(SetParam.zr(izr)),'m(1,:)'])
        eval(['TL',num2str(SetParam.zr(izr)),'mraAz(', num2str(ii),',:)=TL',num2str(SetParam.zr(izr)),'m_ra(1,:)'])
        
    end
    save TLandPD.mat TL*m TL*m_a TL*m_ra PD*m
    
    cd ../
    
end
save TLraPDra.mat PD*mAz TL*mraAz

%% TL Plot
load('TLraPDra.mat')
lat = load('23.75_121.82_16dir_lat.txt')
lon = load('23.75_121.82_16dir_lon.txt')
for iplot = 1:length(SetParam.zr)
    eval(['TLdata = TL',num2str(SetParam.zr(iplot)),'mraAz']);
    f1 = figure(1);
    surf([lon;lon(1,:)],[lat; lat(1,:)],[TLdata; TLdata(1,:)],'LineStyle','none','FaceColor','interp')
    colormap(flipud(jet))
    view(2);axis equal
    c = colorbar
    caxis([50 120])
    c.Label.String = 'Transmission Loss (dB re 1μPa)'
    c.Label.Rotation = 90
    xlabel = ('Longitude (˚E)');
    ylabel = ('Latitude (˚N)');
    title({['Tansmission Loss at (',num2str(Source(2)),'˚N, ',num2str(Source(1)),'˚E)'], ['Depth = ',num2str(SetParam.zr(iplot)),'m']})
    saveas(f1,['TL',num2str(SetParam.zr(iplot)),'m.jpg'])
    %% PD Plot
    eval(['PDdata = PD',num2str(SetParam.zr(iplot)),'mAz']);
    f2 = figure(2)
    surf([lon;lon(1,:)],[lat; lat(1,:)],[PDdata; PDdata(1,:)],'LineStyle','none','FaceColor','interp')
    colormap(jet)
    view(2);axis equal
    c = colorbar
    caxis([0 1])
    c.Label.String = 'Predictive Probability of Detection'
    c.Label.Rotation = 90
    xlabel = ('Longitude (˚E)');
    ylabel = ('Latitude (˚N)');
    title({['Predictive Probability of Detection at (',num2str(Source(2)),'˚N, ',num2str(Source(1)),'˚E)'], ['Depth = ',num2str(SetParam.zr(iplot)),'m']})
    saveas(f2,['PD',num2str(SetParam.zr(iplot)),'m.jpg'])
end
%%
% distance()