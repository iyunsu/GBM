%% ========================================================================
%  File: CalPPD.m
%  Name: I Yun Su
%  Date: 2021.06.04
%  Note:
%       Calculate the PPD from all detected points.
%% ========================================================================
clear all;clc
%% Set Path
path_output = '/home/iyunsu/gbm/Example_121.2_22.08/GbmSearchPoints/37500';
cd(path_output)
detectedPoints = dir('*_5m')

for i = 1:length(detectedPoints)
    %% Get lat amd lon from folder name
    cd (detectedPoints(i).name)
    
    
    %% load gray jpg
    
    %% Average the data
    
    
    
    cd ..
end

%% Output


