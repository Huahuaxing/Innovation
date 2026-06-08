% 为论文优化图像
% 全英文
% 线宽（1.8）
% fontsize：
% 坐标轴标签（14）
% 坐标轴刻度（14）
% 子图标题（14）
% 图例（14）

%% 数据初始化
clear;
cd(fileparts(mfilename("fullpath")))

params = jsondecode(fileread('../../../06_ProcessedData/parameters.json'));
P = params.P(:) / 1e6;  % MPa

%% 数据读取
ellipseData = load('..\..\..\06_ProcessedData\01_aperture_radius_record\Ellipse_Record.mat');
nonellipseData = load('..\..\..\06_ProcessedData\01_aperture_radius_record\Nonellipse_Record.mat');

apertureEllipse = squeeze(mean(mean(ellipseData.aperture_record,2),1));
radiusEllipse   = squeeze(mean(mean(ellipseData.radius_record,2),1));

apertureNonEllipse = squeeze(mean(mean(nonellipseData.aperture_record,2),1));
radiusNonEllipse   = squeeze(mean(mean(nonellipseData.radius_record,2),1));

%% 归一化
maxApertureEllipse    = max(apertureEllipse, [], 1);
maxApertureNonEllipse = max(apertureNonEllipse, [], 1);

apertureEllipseNorm    = apertureEllipse ./ maxApertureEllipse;
apertureNonEllipseNorm = apertureNonEllipse ./ maxApertureNonEllipse;

%% 图像保存路径
saveBaseDir = '..\..\..\07_Research\01_Aperture_Radius\Figure\01_threshold_algorithm';
saveDirNotContain = fullfile(saveBaseDir, 'not_contain_ellipseAligned');

if ~exist(saveDirNotContain, 'dir')
    mkdir(saveDirNotContain);
end

%% 全局绘图参数
FONT_NAME = 'Times New Roman';

FONT_SIZE_LABEL  = 14;
FONT_SIZE_AXIS   = 14;
FONT_SIZE_TITLE  = 14;
FONT_SIZE_LEGEND = 14;

LINE_WIDTH = 1.8;
MARKER_SIZE = 5;

% marker间隔
markerIndex = 1:10:length(P);

%% 模型名称
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
%% 1. Stress-Aperture
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig1 = figure('Color',[1 1 1], 'Position',[100 100 900 1200]);

tiledlayout(3,2,'TileSpacing','compact','Padding','compact');

ax = gobjects(1,6);

for i = 1:6

    ax(i) = nexttile;

    p1 = plot(P, apertureEllipse(:,i), '-sk', 'LineWidth', LINE_WIDTH, 'MarkerIndices', markerIndex, 'MarkerSize', MARKER_SIZE, 'MarkerFaceColor', 'w');
    hold on
    p2 = plot(P, apertureNonEllipse(:,i), '-^k', 'LineWidth', LINE_WIDTH, 'MarkerIndices', markerIndex, 'MarkerSize', MARKER_SIZE, 'MarkerFaceColor', 'w');

    title(subTitleList{i}, 'FontSize', FONT_SIZE_TITLE, 'FontWeight','normal', 'FontName', FONT_NAME);

    xlabel('Stress (MPa)', 'FontSize', FONT_SIZE_LABEL, 'FontName', FONT_NAME);

    ylabel('Aperture (m)', 'FontSize', FONT_SIZE_LABEL, 'FontName', FONT_NAME);

    text(0.95,0.95,modelParams{i}, ...
        'Units','normalized', ...
        'FontSize',12, ...
        'FontWeight','bold', ...
        'FontName',FONT_NAME, ...
        'HorizontalAlignment','right', ...
        'VerticalAlignment','top');

    set(gca, 'FontName', FONT_NAME, 'FontSize', FONT_SIZE_AXIS, 'LineWidth',1);

    box on
end

linkaxes(ax,'xy');

lgd1 = legend([p1,p2], {'Ellipse model','Nonelliptical model'}, ...
    'Orientation','horizontal', ...
    'FontSize', FONT_SIZE_LEGEND, ...
    'FontName', FONT_NAME);

lgd1.Layout.Tile = 'north';

saveas(fig1, fullfile(saveDirNotContain, 'Stress-Aperture.fig'));
saveas(fig1, fullfile(saveDirNotContain, 'Stress-Aperture.png'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Stress-Diameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig2 = figure('Color',[1 1 1], 'Position',[100 100 900 1200]);

tiledlayout(3,2,'TileSpacing','compact','Padding','compact');

ax = gobjects(1,6);

for i = 1:6

    ax(i) = nexttile;

    p1 = plot(P, radiusEllipse(:,i)*2, '-sk', 'LineWidth', LINE_WIDTH, 'MarkerIndices', markerIndex, 'MarkerSize', MARKER_SIZE, 'MarkerFaceColor', 'w');
    hold on
    p2 = plot(P, radiusNonEllipse(:,i)*2, '-^k', 'LineWidth', LINE_WIDTH, 'MarkerIndices', markerIndex, 'MarkerSize', MARKER_SIZE, 'MarkerFaceColor', 'w');

    title(subTitleList{i}, 'FontSize', FONT_SIZE_TITLE, 'FontWeight','normal', 'FontName', FONT_NAME);

    xlabel('Stress (MPa)', 'FontSize', FONT_SIZE_LABEL, 'FontName', FONT_NAME);

    ylabel('Diameter (m)', 'FontSize', FONT_SIZE_LABEL, 'FontName', FONT_NAME);

    text(0.95,0.95,modelParams{i}, ...
        'Units','normalized', ...
        'FontSize',12, ...
        'FontWeight','bold', ...
        'FontName',FONT_NAME, ...
        'HorizontalAlignment','right', ...
        'VerticalAlignment','top');

    set(gca, 'FontName', FONT_NAME, 'FontSize', FONT_SIZE_AXIS, 'LineWidth',1);

    box on
end

linkaxes(ax,'xy');

lgd2 = legend([p1,p2], {'Ellipse model','Nonelliptical model'}, ...
    'Orientation','horizontal', ...
    'FontSize', FONT_SIZE_LEGEND, ...
    'FontName', FONT_NAME);

lgd2.Layout.Tile = 'north';

saveas(fig2, fullfile(saveDirNotContain, 'Stress-Diameter.fig'));
saveas(fig2, fullfile(saveDirNotContain, 'Stress-Diameter.png'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. Stress-Normalized Aperture
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig3 = figure('Color',[1 1 1], 'Position',[100 100 900 1200]);

tiledlayout(3,2,'TileSpacing','compact','Padding','compact');

ax = gobjects(1,6);

for i = 1:6

    ax(i) = nexttile;

    p1 = plot(P, apertureEllipseNorm(:,i), '-sk', 'LineWidth', LINE_WIDTH, 'MarkerIndices', markerIndex, 'MarkerSize', MARKER_SIZE, 'MarkerFaceColor', 'w');
    hold on
    p2 = plot(P, apertureNonEllipseNorm(:,i), '-^k', 'LineWidth', LINE_WIDTH, 'MarkerIndices', markerIndex, 'MarkerSize', MARKER_SIZE, 'MarkerFaceColor', 'w');

    title(subTitleList{i}, 'FontSize', FONT_SIZE_TITLE, 'FontWeight','normal', 'FontName', FONT_NAME);

    xlabel('Stress (MPa)', 'FontSize', FONT_SIZE_LABEL, 'FontName', FONT_NAME);

    ylabel('Normalized Aperture', 'FontSize', FONT_SIZE_LABEL, 'FontName', FONT_NAME);

    text(0.95,0.95,modelParams{i}, ...
        'Units','normalized', ...
        'FontSize',12, ...
        'FontWeight','bold', ...
        'FontName',FONT_NAME, ...
        'HorizontalAlignment','right', ...
        'VerticalAlignment','top');

    set(gca, 'FontName', FONT_NAME, 'FontSize', FONT_SIZE_AXIS, 'LineWidth',1);

    box on
end

linkaxes(ax,'xy');

lgd3 = legend([p1,p2], {'Ellipse model','Nonelliptical model'}, ...
    'Orientation','horizontal', ...
    'FontSize', FONT_SIZE_LEGEND, ...
    'FontName', FONT_NAME);

lgd3.Layout.Tile = 'north';

saveas(fig3, fullfile(saveDirNotContain, 'Stress-Normalized Aperture.fig'));
saveas(fig3, fullfile(saveDirNotContain, 'Stress-Normalized Aperture.png'));