% 通过comsol数据，绘制出裂隙形态变化图，先绘制1-1模型第一个裂隙
%% 数据初始化
clear;
cd(fileparts(mfilename("fullpath")))

jsonPath = "../../../../06_ProcessedData";
jsonFile = fullfile(jsonPath, "parameters.json");
params = jsondecode(fileread(jsonFile));
P = params.P;

dataPathEllipse = 'D:\Projects\02_Innovation\05_Data\SoftCrack\ellipse_data';
dataPathEllipseAligned= 'D:\Projects\02_Innovation\05_Data\SoftCrack\ellipse_data_aligned';
dataPathNonellipse = 'D:\Projects\02_Innovation\05_Data\SoftCrack\polygonal_data';

aaEllipse = zeros(40, 200, 43);
for tab = 1:40  % 四十个表格
    file_path = fullfile(dataPathEllipse, sprintf('20-cracks-distance-1-1-AR1'), sprintf('20-cracks-distance-%d~40-1-AR1.txt', tab));
    rawData = readmatrix(file_path, 'NumHeaderLines', 5);  % 跳过前5行
    aaEllipse(tab, :, :) = rawData;
end

aaEllipseAligned = zeros(40, 200, 43);
for tab = 1:40  % 四十个表格
    file_path = fullfile(dataPathEllipseAligned, sprintf('20-cracks-distance-1-1-AR1'), sprintf('20-cracks-distance-%d~40-1-AR1.txt', tab));
    rawData = readmatrix(file_path, 'NumHeaderLines', 5);  % 跳过前5行
    aaEllipseAligned(tab, :, :) = rawData;
end

aaNonellipse = zeros(40, 200, 43);
for tab = 1:40  % 四十个表格
    file_path = fullfile(dataPathNonellipse, sprintf('20-cracks-distance-1-1-20AR1'), sprintf('20-cracks-distance-%d~40-1-AR1.txt', tab));
    rawData = readmatrix(file_path, 'NumHeaderLines', 5);  % 跳过前5行
    aaNonellipse(tab, :, :) = rawData;
end

point_n = floor((size(aaEllipse, 3)-1)/2);
pointy_start_idx = size(aaEllipse, 3) - point_n + 1;   % Matlab索引从1开始
%% 绘图区 
figure("Position",[0 0 1500 1200]);
sgtitle("Single Crack Shape Changes", "FontSize", 18, "FontWeight","bold");
row = 8;
column = 3;
for k = 1:8

    % --- 列 1：椭圆 ---
    subplot(row,column,(k-1)*3 + 1);
    xdataA = squeeze(aaEllipse(1,k*20,2:pointy_start_idx-1));
    ydataA = squeeze(aaEllipse(1,k*20,pointy_start_idx:end));
    xdataB = squeeze(aaEllipse(2,k*20,2:pointy_start_idx-1));
    ydataB = squeeze(aaEllipse(2,k*20,pointy_start_idx:end));
    plot(xdataA, ydataA, 'b-', 'LineWidth', 1.5);hold on;
    plot(xdataB, ydataB, 'b-', 'LineWidth', 1.5);
    % ylim([min(ydataB), max(ydataA)]);
    % ylim([0.1680, 0.1700]);
    title(sprintf('[Ellipse] Stress %.2f MPa', P(k*20)/1e6));
    xlabel('X'); ylabel('Y'); grid on;

    % --- 列 2：对齐椭圆 ---
    subplot(row,column,(k-1)*3 + 2);
    xdataA = squeeze(aaEllipseAligned(1,k*20,2:pointy_start_idx-1));
    ydataA = squeeze(aaEllipseAligned(1,k*20,pointy_start_idx:end));
    xdataB = squeeze(aaEllipseAligned(2,k*20,2:pointy_start_idx-1));
    ydataB = squeeze(aaEllipseAligned(2,k*20,pointy_start_idx:end));
    plot(xdataA, ydataA, 'g-', 'LineWidth', 1.5);hold on;
    plot(xdataB, ydataB, 'g-', 'LineWidth', 1.5);
    % ylim([min(ydata), max(ydata)]);
    title(sprintf('[Aligned] Stress %.2f MPa', P(k*20)/1e6));
    xlabel('X'); ylabel('Y'); grid on;

    % --- 列 3：非椭圆 ---
    subplot(row,column,(k-1)*3 + 3);
    xdataA = squeeze(aaNonellipse(1,k*20,2:pointy_start_idx-1));
    ydataA = squeeze(aaNonellipse(1,k*20,pointy_start_idx:end));
    xdataB = squeeze(aaNonellipse(2,k*20,2:pointy_start_idx-1));
    ydataB = squeeze(aaNonellipse(2,k*20,pointy_start_idx:end));
    ydataB = min(ydataA, ydataB);
    plot(xdataA, ydataA, 'r-', 'LineWidth', 1.5);hold on;
    plot(xdataB, ydataB, 'r-', 'LineWidth', 1.5);
    % ylim([min(ydata), max(ydata)]);
    title(sprintf('[Nonellipse] Stress %.2f MPa', P(k*20)/1e6));
    xlabel('X'); ylabel('Y'); grid on;
end

