% 通过comsol导出的位移数据，绘制出裂隙形态变化图，选择1-1模型的第一个裂隙
% 三个裂隙的位置坐标：()()()
%% 数据初始化
clear;
cd(fileparts(mfilename("fullpath")))
jsonPath = "../../../../06_ProcessedData";
jsonFile = fullfile(jsonPath, "parameters.json");
params = jsondecode(fileread(jsonFile));
P = params.P;

dataPathEllipse = '..\..\..\..\05_Data\SoftCrack\ellipse_data\distance';
dataPathEllipseAligned= '..\..\..\..\05_Data\SoftCrack\ellipse_data_aligned\distance';
dataPathNonellipse = '..\..\..\..\05_Data\SoftCrack\polygonal_data\distance';

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
pointy_start_idx = point_n + 2;   % Matlab索引从1开始

xEllipse = aaEllipse(1, 1, 2) + 0.018;
yEllipse = aaEllipse(1, 1, pointy_start_idx);

xEllipseAligned = aaEllipseAligned(1, 1, 2) + 0.018;
yEllipseAligned = aaEllipseAligned(1, 1, pointy_start_idx);

xNonellipse = aaNonellipse(1, 1, 2) + 0.018;
yNonellipse = aaNonellipse(1, 1, pointy_start_idx);



%% 绘图区 
figure("Position",[0 0 1500 1200]);
sgtitle("Single Crack Shape Changes", "FontSize", 18, "FontWeight","bold");
row = 10;
column = 3;
stressIndex = 1:20:200;
ax = gobjects(row, column);
for r = 1:row
    % --- 列 1：椭圆 ---
    subplot(row,column,(r-1)*3 + 1);
    xdataA = squeeze(aaEllipse(1,stressIndex(r),2:pointy_start_idx-1));
    ydataA = squeeze(aaEllipse(1,stressIndex(r),pointy_start_idx:end));
    xdataB = squeeze(aaEllipse(2,stressIndex(r),2:pointy_start_idx-1));
    ydataB = squeeze(aaEllipse(2,stressIndex(r),pointy_start_idx:end));
    plot(xdataA, ydataA, 'b-', 'LineWidth', 1.5);hold on;
    plot(xdataB, ydataB, 'b-', 'LineWidth', 1.5);
    if r == 1
        title(sprintf('[Ellipse model (%.3f %.3f)] Stress %.2f MPa', xEllipse, yEllipse, P(stressIndex(r))/1e6));
    else
        title(sprintf('[Ellipse model] Stress %.2f MPa', P(stressIndex(r))/1e6));
    end
    xlabel('X'); ylabel('Y'); grid on;

    % --- 列 2：对齐椭圆 ---
    subplot(row,column,(r-1)*3 + 2);
    xdataA = squeeze(aaEllipseAligned(1,stressIndex(r),2:pointy_start_idx-1));
    ydataA = squeeze(aaEllipseAligned(1,stressIndex(r),pointy_start_idx:end));
    xdataB = squeeze(aaEllipseAligned(2,stressIndex(r),2:pointy_start_idx-1));
    ydataB = squeeze(aaEllipseAligned(2,stressIndex(r),pointy_start_idx:end));
    plot(xdataA, ydataA, 'g-', 'LineWidth', 1.5);hold on;
    plot(xdataB, ydataB, 'g-', 'LineWidth', 1.5);
    if r == 1
        title(sprintf('[EllipseAligned model (%.3f %.3f)] Stress %.2f MPa', xEllipseAligned, yEllipseAligned, P(stressIndex(r))/1e6));
    else
        title(sprintf('[EllipseAligned model] Stress %.2f MPa', P(stressIndex(r))/1e6));
    end
    xlabel('X'); ylabel('Y'); grid on;

    % --- 列 3：非椭圆 ---
    subplot(row,column,(r-1)*3 + 3);
    xdataA = squeeze(aaNonellipse(1,stressIndex(r),2:pointy_start_idx-1));
    ydataA = squeeze(aaNonellipse(1,stressIndex(r),pointy_start_idx:end));
    xdataB = squeeze(aaNonellipse(2,stressIndex(r),2:pointy_start_idx-1));
    ydataB = squeeze(aaNonellipse(2,stressIndex(r),pointy_start_idx:end));
    ydataB = min(ydataA, ydataB);
    plot(xdataA, ydataA, 'r-', 'LineWidth', 1.5);hold on;
    plot(xdataB, ydataB, 'r-', 'LineWidth', 1.5);
    if r == 1
        title(sprintf('[Nonellipse model (%.3f %.3f)] Stress %.2f MPa', xNonellipse, yNonellipse, P(stressIndex(r))/1e6));
    else
        title(sprintf('[Nonellipse model] Stress %.2f MPa', P(stressIndex(r))/1e6));
    end
    xlabel('X'); ylabel('Y'); grid on;
end

