%% ======================== GenMultiAzCoord.m ========================
%  Comparing the three gbm.e
%                                                       I Yun Su 2021.04.10
%% ========================================================================
function [coordLat, coordLon] = GenMultiAzCoord(slat,slon,azNumber,rmax,rdr)

%% Set Param -------------------------------------------------------------
theta = 360/azNumber;
path_output = pwd;
%% Main -------------------------------------------------------------------
for i = 1:azNumber
    az = theta*i;
    [coordLat(i,:), coordLon(i,:)]=track1(slat,slon,az,km2deg(rmax/1000),...
        [],[],ceil(rmax/rdr)+1);
end

cd (path_output)
latName = [num2str(slat) '_' num2str(slon) '_' num2str(azNumber) 'dir_lat.txt'];
lonName = [num2str(slat) '_' num2str(slon) '_' num2str(azNumber) 'dir_lon.txt'];
writematrix(coordLat,latName);
writematrix(coordLon,lonName);
end
