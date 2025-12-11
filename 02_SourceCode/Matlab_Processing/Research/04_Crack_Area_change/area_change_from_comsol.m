%% 数据初始化
clear;
cd(fileparts(mfilename("fullpath")));
params = jsondecode(fileread('../../../../06_ProcessedData/parameters.json'));
P = params.P;       % 200 个应力点

groupNum = 6;       % 共有 1-1 ~ 6-5
subModelNum  = 5;
PNum = length(P);
CrackNum = 20;      % 剔除第一列后剩 20 列

% 加载面积数据
areaEllipseArray = zeros(groupNum, subModelNum, PNum, CrackNum);    % (6,5,200,20)
% 1-1到1-5
for g = 1:groupNum
    for s = 1:subModelNum
        folderName = sprintf('20-cracks-porosity-%d-%d-%s', g, s, ARList{g});
        fileName   = sprintf('20-cracks-porosity-%d-%s.txt', s, ARList{g});
        Path = fullfile('../../../../05_Data/SoftCrack/ellipse_data/area/', folderName, fileName);
        raw = readmatrix(Path, "NumHeaderLines", 5);
        raw = raw(:, 2:end);                    % 第一列为应力，故去除
        areaEllipseArray(g, s, :, :) = raw;
    end
end
% 3-1到6-5
% 2-1到2-5

ARList = {"AR1", "AR2", "AR1+AR2", "AR1+AR2", "AR1+AR2", "AR1+AR2"};

areaEllipse = squeeze(mean(mean(areaEllipseArray, 4), 2));  % (6, 200)先对20个裂隙求平均，再对五个子模型求平均

%% === 绘图示例：第 1 组 ===
ellipseOrder = [1, 3, 4, 5, 6, 2];  % 调整绘图顺序
modelParams = {'20AR1', '16AR1+4AR2', '12AR1+8AR2', '8AR1+12AR2', '4AR1+16AR2', '20AR2'};
subTitleList = {'(a)', '(b)', '(c)', '(d)', '(e)', '(f)'};
figure('Color',[1 1 1], 'Position', [0 0 2000 1000]);
sgtitle('Uniaxial Stress-Area', 'FontSize', 14, 'FontWeight','bold');
ax = gobjects(1, groupNum);
for g = 1:groupNum
    ax(g) = subplot(2, 3, g);
    plot(P, squeeze(areaEllipse(ellipseOrder(g), :)));hold on;
    title(subTitleList{ellipseOrder(g)}, 'FontSize', 12, 'FontWeight','normal');
    xlabel('Uniaxial Stress (MPa)', 'FontSize', 11);
    ylabel('Aperture (m)', 'FontSize', 11);
end
linkaxes(ax, "xy");
