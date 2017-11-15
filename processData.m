clc; close all; clear;

addpath(genpath('ComponentAnalysis'),'data')  

load('G1data.mat');
% load('G2data.mat');
% load('V1data.mat');
% load('V2data.mat');
% load('facedata.mat');

V.FrameRate = 50; %For G1,G2,V1,V2data.mat
% V.FrameRate = 30; %For facedata.mat
V.NumberOfFrames = size(y,2);

y_interp = cubicSplineInterp(V, y, 1000);

y_stable = removeUnstable(y_interp);

y_filtered = temporalFiltering(y_stable);

%% Component Analysis Part
% Perform PCA
tic
y_pca = PCA(y_filtered,5);
time_pca = toc;

% Perform Fast ICA
tic
y_fica = fastica(y_filtered, 'lastEig', 10, 'numOfIC', 5);
time_fica = toc;

% Perform max-kurtosis ICA
tic
y_mkica = mkICA(y_filtered,5);
time_mkica = toc;

% Perform Jade
tic
[~,y_jade] = jade(y_filtered,5);
time_jade = toc;

% Perform Shibbs
tic
y_shibbs = shibbs(y_filtered',5);
time_shibbs = toc;

% Perform fast RADICAL (VERY SLOW!!!)
% [y_radical, ~] = fast_RADICAL(y_filtered);

%% Plot components
for i = 1:5
    subplot(2,3,1)
        plot(y_pca(i,:))
        title(['PCA ' num2str(time_pca) ' sec'])
        
    subplot(2,3,2)
        plot(y_fica(i,:))
        title(['Fast ICA ' num2str(time_fica) ' sec'])

    subplot(2,3,3)
        plot(real(y_mkica(i,:)))
        title(['Max-Kurtosis ICA ' num2str(time_mkica) ' sec'])

    subplot(2,3,4)
        plot(y_jade(i,:))
        title(['Jade ' num2str(time_jade) ' sec'])

    subplot(2,3,5)
        plot(y_shibbs(i,:))
        title(['Shibss ' num2str(time_shibbs) ' sec'])

    ginput(1);
end

%% TODO
%Intuitive selection of component
[signal_y, signal_number_y] = signalSelection(y_filtered, y_pca);

%Plot components
for i = 1:size(signal_y, 2)
    figure(i); plot(signal_y(:,i));
end

T = size(y_filtered,2);

pks = findpeaks(signal_y(:,1));
[pks, locs] = findpeaks(signal_y(:,1),'MinPeakHeight',max(pks)/40,'MinPeakDistance',frameRate/(150/60)*T/numFr);
pulse = 60*V.frameRate*T/V.numFr./diff(locs)'
averagePulse = mean(pulse)