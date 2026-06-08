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

%% 裂隙密度计算 ε = n * a² / A
n = 20;        % 裂隙数量
A = 0.04;      % 代表面积
epsilonEllipse = n * radiusEllipse.^2 / A;
epsilonNonEllipse = n * radiusNonEllipse.^2 / A;

%% 图像保存路径
saveDir = '..\..\..\07_Research\06_Crack_Density';

if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end

%% 全局绘图参数（完全和你统一）
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
%% 4. Stress - Fracture Density  裂隙密度图（完全按你风格绘制）
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig4 = figure('Color',[1 1 1], 'Position',[100 100 900 1200]);

tiledlayout(3,2,'TileSpacing','compact','Padding','compact');

ax = gobjects(1,6);

for i = 1:6

    ax(i) = nexttile;

    p1 = plot(P, epsilonEllipse(:,i), '-sk', 'LineWidth', LINE_WIDTH, 'MarkerIndices', markerIndex, 'MarkerSize', MARKER_SIZE, 'MarkerFaceColor', 'w');
    hold on
    p2 = plot(P, epsilonNonEllipse(:,i), '-^k', 'LineWidth', LINE_WIDTH, 'MarkerIndices', markerIndex, 'MarkerSize', MARKER_SIZE, 'MarkerFaceColor', 'w');

    title(subTitleList{i}, 'FontSize', FONT_SIZE_TITLE, 'FontWeight','normal', 'FontName', FONT_NAME);

    xlabel('Stress (MPa)', 'FontSize', FONT_SIZE_LABEL, 'FontName', FONT_NAME);

    ylabel('Crack Density', 'FontSize', FONT_SIZE_LABEL, 'FontName', FONT_NAME);

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

lgd4 = legend([p1,p2], {'Ellipse model','Nonelliptical model'}, ...
    'Orientation','horizontal', ...
    'FontSize', FONT_SIZE_LEGEND, ...
    'FontName', FONT_NAME);

lgd4.Layout.Tile = 'north';

saveas(fig4, fullfile(saveDir, 'Stress-Fracture_Density.fig'));
saveas(fig4, fullfile(saveDir, 'Stress-Fracture_Density.png'));

% 高清导出论文用图
exportgraphics(fig4, fullfile(saveDir, 'Stress-Fracture_Density_HighRes.png'),'Resolution',600);