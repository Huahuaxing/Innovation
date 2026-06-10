% 绘图配置：全英文，线宽（2.0）
% fontsize：
% 坐标轴标签（14）
% 坐标轴刻度（14）
% 子图标题（14）
% 图例（14）

%% 数据初始化
clear;
cd(fileparts(mfilename("fullpath")));

params = jsondecode(fileread('../../../06_ProcessedData/parameters.json'));
P = params.P / 1e6;

groupNum = 6;
subModelNum = 5;
PNum = length(P);
CrackNum = 20;

%% 加载椭圆面积数据
areaEllipseOriginal = zeros(groupNum, subModelNum, PNum, CrackNum);

ARListEllipse = {"AR1", "AR2", "AR1+AR2", "AR1+AR2", "AR1+AR2", "AR1+AR2"};

for g = 1:groupNum
    for s = 1:subModelNum

        folderName = sprintf('20-cracks-porosity-%d-%d-%s', g, s, ARListEllipse{g});
        fileName = sprintf('20-cracks-porosity-%d-%s.txt', s, ARListEllipse{g});

        Path = fullfile('../../../05_Data/SoftCrack/ellipse_data/area/', folderName, fileName);

        raw = readmatrix(Path, "NumHeaderLines", 5);

        raw = raw(:,2:end);

        areaEllipseOriginal(g,s,:,:) = raw;
    end
end

areaEllipseOriginal(areaEllipseOriginal < 0) = 0;

%% 加载非椭圆面积数据
areaNonellipseOriginal = zeros(groupNum, subModelNum, PNum, CrackNum);

ARList = {"20AR1", "16AR1+4AR2", "12AR1+8AR2", "8AR1+12AR2", "4AR1+16AR2", "20AR2"};

for g = 1:groupNum
    for s = 1:subModelNum

        folderName = sprintf('20-cracks-porosity-%d-%d-%s', g, s, ARList{g});
        fileName = sprintf('20-cracks-porosity-%d-%s.txt', s, ARList{g});

        Path = fullfile('../../../05_Data/SoftCrack/polygonal_data/area/', folderName, fileName);

        raw = readmatrix(Path, "NumHeaderLines", 5);

        raw = raw(:,2:end);

        areaNonellipseOriginal(g,s,:,:) = raw;
    end
end

areaNonellipseOriginal(areaNonellipseOriginal < 0) = 0;

%% 求平均
areaEllipse = squeeze(mean(mean(areaEllipseOriginal,4),2));
areaNonellipse = squeeze(mean(mean(areaNonellipseOriginal,4),2));

%% 归一化
areaEllipseMax = max(areaEllipse, [], 2);
areaNonellipseMax = max(areaNonellipse, [], 2);

areaEllipseNormalized = areaEllipse ./ areaEllipseMax;
areaNonellipseNormalized = areaNonellipse ./ areaNonellipseMax;

%% 图像保存路径
saveDir = '..\..\..\07_Research\03_Crack_Area_Research\Figure';
if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end

%% 绘图参数
FONT_NAME = 'Times New Roman';

FONT_SIZE_LABEL = 14;
FONT_SIZE_AXIS = 14;
FONT_SIZE_TITLE = 14;
FONT_SIZE_LEGEND = 14;

LINE_WIDTH = 1.8;
MARKER_SIZE = 5;

markerIndex = 1:10:length(P);

ellipseOrder = [1,3,4,5,6,2];

modelParams = {
    '20AR1', ...
    '16AR1+4AR2', ...
    '12AR1+8AR2', ...
    '8AR1+12AR2', ...
    '4AR1+16AR2', ...
    '20AR2'
};

subTitleList = {'(a)','(b)','(c)','(d)','(e)','(f)'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Stress-Area
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig1 = figure('Color',[1 1 1], 'Position',[100 100 900 1200]);

tiledlayout(3,2,'TileSpacing','compact','Padding','compact');

ax = gobjects(1,groupNum);

for g = 1:groupNum

    ax(g) = nexttile;

    p1 = plot(P, areaEllipse(ellipseOrder(g),:), '-sk', 'LineWidth', LINE_WIDTH, 'MarkerIndices', markerIndex, 'MarkerSize', MARKER_SIZE, 'MarkerFaceColor', 'w');
    hold on
    p2 = plot(P, areaNonellipse(g,:), '-^k', 'LineWidth', LINE_WIDTH, 'MarkerIndices', markerIndex, 'MarkerSize', MARKER_SIZE, 'MarkerFaceColor', 'w');

    title(subTitleList{g}, 'FontSize', FONT_SIZE_TITLE, 'FontWeight','normal', 'FontName', FONT_NAME);

    xlabel('Stress (MPa)', 'FontSize', FONT_SIZE_LABEL, 'FontName', FONT_NAME);

    ylabel('Area (m^2)', 'FontSize', FONT_SIZE_LABEL, 'FontName', FONT_NAME);

    text(0.95,0.95,modelParams{g}, ...
        'Units','normalized', ...
        'FontSize',12, ...
        'FontWeight','bold', ...
        'FontName',FONT_NAME, ...
        'HorizontalAlignment','right', ...
        'VerticalAlignment','top', ...
        'BackgroundColor',[1 1 1 0.8], ...
        'EdgeColor','k', ...
        'LineWidth',0.5, ...
        'Margin',3);

    set(gca, 'FontName', FONT_NAME, 'FontSize', FONT_SIZE_AXIS);

    box on
end

linkaxes(ax,'xy');

lgd1 = legend([p1,p2], {'Ellipse model','Nonelliptical model'}, ...
    'FontSize', FONT_SIZE_LEGEND, ...
    'FontName', FONT_NAME, ...
    'Orientation','horizontal');

lgd1.Layout.Tile = 'north';

saveas(fig1, fullfile(saveDir, 'Area-Stress.fig'));
saveas(fig1, fullfile(saveDir, 'Area-Stress.png'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Stress-Normalized Area
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig2 = figure('Color',[1 1 1], 'Position',[100 100 900 1200]);

tiledlayout(3,2,'TileSpacing','compact','Padding','compact');

ax = gobjects(1,groupNum);

for g = 1:groupNum

    ax(g) = nexttile;

    p1 = plot(P, areaEllipseNormalized(ellipseOrder(g),:), '-sk', 'LineWidth', LINE_WIDTH, 'MarkerIndices', markerIndex, 'MarkerSize', MARKER_SIZE, 'MarkerFaceColor', 'w');
    hold on
    p2 = plot(P, areaNonellipseNormalized(g,:), '-^k', 'LineWidth', LINE_WIDTH, 'MarkerIndices', markerIndex, 'MarkerSize', MARKER_SIZE, 'MarkerFaceColor', 'w');

    title(subTitleList{g}, 'FontSize', FONT_SIZE_TITLE, 'FontWeight','normal', 'FontName', FONT_NAME);

    xlabel('Stress (MPa)', 'FontSize', FONT_SIZE_LABEL, 'FontName', FONT_NAME);

    ylabel('Normalized Area', 'FontSize', FONT_SIZE_LABEL, 'FontName', FONT_NAME);

    text(0.95,0.95,modelParams{g}, ...
        'Units','normalized', ...
        'FontSize',12, ...
        'FontWeight','bold', ...
        'FontName',FONT_NAME, ...
        'HorizontalAlignment','right', ...
        'VerticalAlignment','top', ...
        'BackgroundColor',[1 1 1 0.8], ...
        'EdgeColor','k', ...
        'LineWidth',0.5, ...
        'Margin',3);

    set(gca, 'FontName', FONT_NAME, 'FontSize', FONT_SIZE_AXIS);

    box on
end

linkaxes(ax,'xy');

lgd2 = legend([p1,p2], {'Ellipse model','Nonelliptical model'}, ...
    'FontSize', FONT_SIZE_LEGEND, ...
    'FontName', FONT_NAME, ...
    'Orientation','horizontal');

lgd2.Layout.Tile = 'north';

saveas(fig2, fullfile(saveDir, 'Norm_Area-Stress.fig'));
saveas(fig2, fullfile(saveDir, 'Norm_Area-Stress.png'));