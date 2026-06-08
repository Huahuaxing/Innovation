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

params = jsondecode(fileread('../../../../06_ProcessedData/parameters.json'));
P = params.P(:) / 1e6;  % MPa

%% 数据读取
root_dir = 'E:\OneDrive\01_Project\02.1_Innovation';

vpEllipse = readmatrix(fullfile(root_dir, '06_ProcessedData\03_velocity\n_20_degree_0\vp\vp_ellipse.csv'));
vpNonellipse = readmatrix(fullfile(root_dir, '06_ProcessedData\03_velocity\n_20_degree_0\vp\vp_nonellipse.csv'));

vsvEllipse = readmatrix(fullfile(root_dir, '06_ProcessedData\03_velocity\n_20_degree_0\vsv\vsv_ellipse.csv'));
vsvNonellipse = readmatrix(fullfile(root_dir, '06_ProcessedData\03_velocity\n_20_degree_0\vsv\vsv_nonellipse.csv'));

%% 图像保存路径
saveBaseDir = '..\..\..\..\07_Research\02_C_eff_and_Velocity\Figure\n20_degree_0';
saveDirNotContain = fullfile(saveBaseDir, 'not_contain_aligned');

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
%% 1. Stress - Vp Velocity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig1 = figure('Color',[1 1 1], 'Position',[100 100 900 1200]);

tiledlayout(3,2,'TileSpacing','compact','Padding','compact');

ax = gobjects(1,6);

for i = 1:6

    ax(i) = nexttile;

    p1 = plot(P, vpEllipse(:,i), '-sk', 'LineWidth', LINE_WIDTH, 'MarkerIndices', markerIndex, 'MarkerSize', MARKER_SIZE, 'MarkerFaceColor', 'w');
    hold on
    p2 = plot(P, vpNonellipse(:,i), '-^k', 'LineWidth', LINE_WIDTH, 'MarkerIndices', markerIndex, 'MarkerSize', MARKER_SIZE, 'MarkerFaceColor', 'w');

    title(subTitleList{i}, 'FontSize', FONT_SIZE_TITLE, 'FontWeight','normal', 'FontName', FONT_NAME);

    xlabel('Stress (MPa)', 'FontSize', FONT_SIZE_LABEL, 'FontName', FONT_NAME);

    ylabel('V_P (m/s)', 'FontSize', FONT_SIZE_LABEL, 'FontName', FONT_NAME);

    % ====================== 已修改：移到右下角 ======================
    text(0.95,0.05,modelParams{i}, ...
        'Units','normalized', ...
        'FontSize',12, ...
        'FontWeight','bold', ...
        'FontName',FONT_NAME, ...
        'HorizontalAlignment','right', ...
        'VerticalAlignment','bottom');
    % ===============================================================

    set(gca, 'FontName', FONT_NAME, 'FontSize', FONT_SIZE_AXIS, 'LineWidth',1);

    box on
end

linkaxes(ax,'xy');

lgd1 = legend([p1,p2], {'Ellipse model','Nonelliptical model'}, ...
    'Orientation','horizontal', ...
    'FontSize', FONT_SIZE_LEGEND, ...
    'FontName', FONT_NAME);

lgd1.Layout.Tile = 'north';

saveas(fig1, fullfile(saveDirNotContain, 'Stress-Vp.fig'));
saveas(fig1, fullfile(saveDirNotContain, 'Stress-Vp.png'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Stress - Vsv Velocity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig2 = figure('Color',[1 1 1], 'Position',[100 100 900 1200]);

tiledlayout(3,2,'TileSpacing','compact','Padding','compact');

ax = gobjects(1,6);

for i = 1:6

    ax(i) = nexttile;

    p1 = plot(P, vsvEllipse(:,i), '-sk', 'LineWidth', LINE_WIDTH, 'MarkerIndices', markerIndex, 'MarkerSize', MARKER_SIZE, 'MarkerFaceColor', 'w');
    hold on
    p2 = plot(P, vsvNonellipse(:,i), '-^k', 'LineWidth', LINE_WIDTH, 'MarkerIndices', markerIndex, 'MarkerSize', MARKER_SIZE, 'MarkerFaceColor', 'w');

    title(subTitleList{i}, 'FontSize', FONT_SIZE_TITLE, 'FontWeight','normal', 'FontName', FONT_NAME);

    xlabel('Stress (MPa)', 'FontSize', FONT_SIZE_LABEL, 'FontName', FONT_NAME);

    ylabel('V_{SV} (m/s)', 'FontSize', FONT_SIZE_LABEL, 'FontName', FONT_NAME);

    % ====================== 已修改：移到右下角 ======================
    text(0.95,0.05,modelParams{i}, ...
        'Units','normalized', ...
        'FontSize',12, ...
        'FontWeight','bold', ...
        'FontName',FONT_NAME, ...
        'HorizontalAlignment','right', ...
        'VerticalAlignment','bottom');
    % ===============================================================

    set(gca, 'FontName', FONT_NAME, 'FontSize', FONT_SIZE_AXIS, 'LineWidth',1);

    box on
end

linkaxes(ax,'xy');

lgd2 = legend([p1,p2], {'Ellipse model','Nonelliptical model'}, ...
    'Orientation','horizontal', ...
    'FontSize', FONT_SIZE_LEGEND, ...
    'FontName', FONT_NAME);

lgd2.Layout.Tile = 'north';

saveas(fig2, fullfile(saveDirNotContain, 'Stress-Vsv.fig'));
saveas(fig2, fullfile(saveDirNotContain, 'Stress-Vsv.png'));