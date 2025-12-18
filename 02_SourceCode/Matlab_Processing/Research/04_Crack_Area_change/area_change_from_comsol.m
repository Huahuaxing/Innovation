%% 数据初始化
clear;
cd(fileparts(mfilename("fullpath")));
params = jsondecode(fileread('../../../../06_ProcessedData/parameters.json'));
P = params.P / 1e6;       % 200 个应力点

groupNum = 6;       % 共有 1-1 ~ 6-5
subModelNum  = 5;
PNum = length(P);
CrackNum = 20;      % 剔除第一列后剩 20 列

% 加载椭圆面积数据
areaEllipseOriginal = zeros(groupNum, subModelNum, PNum, CrackNum);    % (6,5,200,20)
ARListEllipse = {"AR1", "AR2", "AR1+AR2", "AR1+AR2", "AR1+AR2", "AR1+AR2"};
for g = 1:groupNum
    for s = 1:subModelNum
        folderName = sprintf('20-cracks-porosity-%d-%d-%s', g, s, ARListEllipse{g});
        fileName   = sprintf('20-cracks-porosity-%d-%s.txt', s, ARListEllipse{g});
        Path = fullfile('../../../../05_Data/SoftCrack/ellipse_data/area/', folderName, fileName);
        raw = readmatrix(Path, "NumHeaderLines", 5);
        raw = raw(:, 2:end);                    % 第一列为应力，故去除
        areaEllipseOriginal(g, s, :, :) = raw;
    end
end
areaEllipseOriginal(areaEllipseOriginal < 0) = 0;

% 加载对齐的椭圆面积数据
areaEllipseAlignedOriginal = zeros(groupNum, subModelNum, PNum, CrackNum);
ARList = {"20AR1", "16AR1+4AR2", "12AR1+8AR2", "8AR1+12AR2", "4AR1+16AR2", "20AR2"};
for g=1:groupNum
    for s=1:subModelNum
        folderName = sprintf('20-cracks-porosity-%d-%d-%s', g, s, ARList{g});
        fileName   = sprintf('20-cracks-porosity-%d-%s.txt', s, ARList{g});
        Path = fullfile('../../../../05_Data/SoftCrack/ellipse_data_aligned/area/', folderName, fileName);
        raw = readmatrix(Path, "NumHeaderLines", 5);
        raw = raw(:, 2:end);                    % 第一列为应力，故去除
        areaEllipseAlignedOriginal(g, s, :, :) = raw;
    end
end
areaEllipseAlignedOriginal(areaEllipseAlignedOriginal < 0) = 0;

% 加载非椭圆面积数据
areaNonellipseOriginal = zeros(groupNum, subModelNum, PNum, CrackNum);
ARList = {"20AR1", "16AR1+4AR2", "12AR1+8AR2", "8AR1+12AR2", "4AR1+16AR2", "20AR2"};
for g=1:groupNum
    for s=1:subModelNum
        folderName = sprintf('20-cracks-porosity-%d-%d-%s', g, s, ARList{g});
        fileName   = sprintf('20-cracks-porosity-%d-%s.txt', s, ARList{g});
        Path = fullfile('../../../../05_Data/SoftCrack/polygonal_data/area/', folderName, fileName);
        raw = readmatrix(Path, "NumHeaderLines", 5);
        raw = raw(:, 2:end);                    % 第一列为应力，故去除
        areaNonellipseOriginal(g, s, :, :) = raw;
    end
end
areaNonellipseOriginal(areaNonellipseOriginal < 0) = 0;

% 对原始数据求平均值
areaEllipse = squeeze(mean(mean(areaEllipseOriginal, 4), 2));  % (6, 200)先对20个裂隙求平均，再对五个子模型求平均
areaEllipseAligned = squeeze(mean(mean(areaEllipseAlignedOriginal, 4), 2));
areaNonellipse = squeeze(mean(mean(areaNonellipseOriginal, 4), 2));

% 归一化面积
areaEllipseMax = max(areaEllipse, [], 2);
areaEllipseAlignedMax = max(areaEllipseAligned, [], 2);
areaNonellipseMax = max(areaNonellipse, [], 2);

areaEllipseNormalized = areaEllipse ./ areaEllipseMax;
areaEllipseAlignedNormalized = areaEllipseAligned ./ areaEllipseAlignedMax;
areaNonellipseNormalized = areaNonellipse ./ areaNonellipseMax;


%% 绘图区
% 应力面积图
ellipseOrder = [1, 3, 4, 5, 6, 2];  % 调整绘图顺序
modelParams = {'20AR1', '16AR1+4AR2', '12AR1+8AR2', '8AR1+12AR2', '4AR1+16AR2', '20AR2'};
subTitleList = {'(a)', '(b)', '(c)', '(d)', '(e)', '(f)'};
figure('Color',[1 1 1], 'Position', [0 0 2000 1000]);
sgtitle('Uniaxial Stress-Area', 'FontSize', 14, 'FontWeight','bold');
ax = gobjects(1, groupNum);
for g = 1:groupNum
    ax(g) = subplot(2, 3, g);
    plot(P, areaEllipse(ellipseOrder(g), :), '-b', 'LineWidth', 1.5);hold on;
    plot(P, areaEllipseAligned(g, :), '-g', 'LineWidth', 1.5);
    plot(P, areaNonellipse(g, :), '-r', 'LineWidth', 1.5);
    title(subTitleList{g}, 'FontSize', 12, 'FontWeight','normal');
    xlabel('Uniaxial Stress (MPa)', 'FontSize', 11);
    ylabel('Area (m^2)', 'FontSize', 11);
    if g == 1
        legend({'Ellipse model', 'EllipseAligned model', 'Nonelliptical model'}, 'FontSize', 9);
    end
    text(0.5, 0.98, modelParams{g}, ...
        'Units','normalized', ...          % 使用子图归一化坐标
        'FontSize', 10, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'top', ...
        'BackgroundColor', [1 1 1 0.8], ...
        'EdgeColor', 'k', 'LineWidth', 0.5, ...
        'Margin', 2);
    % grid on;
    set(gca, 'FontName', 'SimHei', 'FontSize', 11);
end
linkaxes(ax, "xy");

% 应力-面积归一化图
figure('Color',[1 1 1], 'Position', [0 0 2000 1000]);
sgtitle('Uniaxial Stress-Normalized Area', 'FontSize', 14, 'FontWeight','bold');
ax = gobjects(1, groupNum);
for g = 1:groupNum
    ax(g) = subplot(2, 3, g);
    plot(P, areaEllipseNormalized(ellipseOrder(g), :), '-b', 'LineWidth', 1.5);hold on;
    plot(P, areaEllipseAlignedNormalized(g, :), '-g', 'LineWidth', 1.5);
    plot(P, areaNonellipseNormalized(g, :), '-r', 'LineWidth', 1.5);
    title(subTitleList{g}, 'FontSize', 12, 'FontWeight','normal');
    xlabel('Uniaxial Stress (MPa)', 'FontSize', 11);
    ylabel('Normalized Area', 'FontSize', 11);
    if g == 1
        legend({'Ellipse model', 'EllipseAligned model', 'Nonelliptical model'}, 'FontSize', 9);
    end
    text(0.5, 0.98, modelParams{g}, ...
        'Units','normalized', ...          % 使用子图归一化坐标
        'FontSize', 10, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'top', ...
        'BackgroundColor', [1 1 1 0.8], ...
        'EdgeColor', 'k', 'LineWidth', 0.5, ...
        'Margin', 2);
    % grid on;
    set(gca, 'FontName', 'SimHei', 'FontSize', 11);
end
linkaxes(ax, "xy");
