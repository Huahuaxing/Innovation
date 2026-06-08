% =============================================
% Stress-Vsv 拟合脚本 (基于一次函数公式)
% 公式: V(P) = a * P + b
% 格式：3行2列 | 黑白配色 | 仅保留 椭圆+非椭圆
% =============================================
clear;

%% 数据初始化
cd(fileparts(mfilename("fullpath")));

prop = jsondecode(fileread("../../../../06_ProcessedData/parameters.json"));
P = prop.P;

groupNum = 6;

% marker间隔
markerIndex = 1:15:length(P);

%% ===================== 椭圆模型 =====================
vsvEllipse = readmatrix('../../../../06_ProcessedData/03_velocity/n_20_degree_0/vsv/vsv_ellipse.csv');

dvdpEllipse = zeros(200, 6);

for g = 1:groupNum
    dvdpEllipse(:, g) = gradient(vsvEllipse(:,g), P);
end

[~, idx_max] = max(dvdpEllipse);

win = 40;

slopeEllipse = zeros(1, groupNum);
interceptEllipse = zeros(1, groupNum);

for g = 1:groupNum

    idx = (idx_max(g)-win):(idx_max(g)+win);
    idx = idx(idx>=1 & idx<=length(P));

    p = polyfit(P(idx), vsvEllipse(idx, g), 1);

    slopeEllipse(g) = p(1);
    interceptEllipse(g) = p(2);

end

%% ===================== 非椭圆模型 =====================
vsvNonellipse = readmatrix('../../../../06_ProcessedData/03_velocity/n_20_degree_0/vsv/vsv_nonellipse.csv');

dvdpNonellipse = zeros(200, 6);

for g = 1:groupNum
    dvdpNonellipse(:, g) = gradient(vsvNonellipse(:,g), P);
end

[~, idx_max] = max(dvdpNonellipse);

win = 40;

slopeNonellipse = zeros(1, groupNum);
interceptNonellipse = zeros(1, groupNum);

for g = 1:groupNum

    idx = (idx_max(g)-win):(idx_max(g)+win);
    idx = idx(idx>=1 & idx<=length(P));

    p = polyfit(P(idx), vsvNonellipse(idx, g), 1);

    slopeNonellipse(g) = p(1);
    interceptNonellipse(g) = p(2);

end

%% ===================== 打印拟合结果 =====================
fprintf('\n========== 拟合结果 ==========\n');

fprintf('Ellipse参数:\n');
fprintf('slope = %s\n', mat2str(slopeEllipse, 4));
fprintf('intercept = %s\n', mat2str(interceptEllipse, 5));

fprintf('Nonellipse参数:\n');
fprintf('slope = %s\n', mat2str(slopeNonellipse, 4));
fprintf('intercept = %s\n', mat2str(interceptNonellipse, 5));

fprintf('====================================\n\n');

%% ===================== 绘图区 =====================
modelParams = {'20AR1', '16AR1+4AR2', '12AR1+8AR2', '8AR1+12AR2', '4AR1+16AR2', '20AR2'};
subTitleList = {'(a)','(b)','(c)','(d)','(e)','(f)'};

%% 全局绘图参数
FONT_NAME = 'Times New Roman';

FONT_SIZE_LABEL = 14;
FONT_SIZE_AXIS = 14;
FONT_SIZE_TITLE = 14;
FONT_SIZE_LEGEND = 14;

LINE_WIDTH = 1.8;
MARKER_SIZE = 5;

%% ===================== 原始波速 + 拟合图 =====================
fig1 = figure('Color',[1 1 1], 'Position',[100 100 900 1200]);

tiledlayout(3,2,'TileSpacing','compact','Padding','compact');

ax = gobjects(1,6);

for g = 1:groupNum

    ax(g) = nexttile;

    hold on;

    % 拟合曲线
    ellipse_fit = slopeEllipse(g) * P + interceptEllipse(g);
    nonellipse_fit = slopeNonellipse(g) * P + interceptNonellipse(g);

    % 椭圆：方形 + 黑线
    p1 = plot(P/1e6, vsvEllipse(:,g), '-sk', ...
        'LineWidth', LINE_WIDTH, ...
        'MarkerSize', MARKER_SIZE, ...
        'MarkerFaceColor', 'w', ...
        'MarkerIndices', markerIndex);

    % 非椭圆：三角形 + 黑线
    p2 = plot(P/1e6, vsvNonellipse(:,g), '-^k', ...
        'LineWidth', LINE_WIDTH, ...
        'MarkerSize', MARKER_SIZE, ...
        'MarkerFaceColor', 'w', ...
        'MarkerIndices', markerIndex);

    % 拟合线
    plot(P/1e6, ellipse_fit, 'k-', 'LineWidth', 1.0);

    plot(P/1e6, nonellipse_fit, 'k--', 'LineWidth', 1.0);

    % 标题
    title(subTitleList{g}, ...
        'FontSize', FONT_SIZE_TITLE, ...
        'FontWeight','normal', ...
        'FontName', FONT_NAME);

    % 坐标轴
    xlabel('Stress (MPa)', ...
        'FontSize', FONT_SIZE_LABEL, ...
        'FontName', FONT_NAME);

    ylabel('V_{SV} (m/s)', ...
        'FontSize', FONT_SIZE_LABEL, ...
        'FontName', FONT_NAME);

    % 模型标签
    text(0.95,0.05,modelParams{g}, ...
        'Units','normalized', ...
        'FontSize',12, ...
        'FontWeight','bold', ...
        'FontName',FONT_NAME, ...
        'HorizontalAlignment','right', ...
        'VerticalAlignment','bottom');

    % ===================== 拟合公式文字 =====================
    ellipseStr = sprintf('Elliptical: V_{SV}=%.2eP+%.1f', ...
        slopeEllipse(g), interceptEllipse(g));

    nonellipseStr = sprintf('Nonelliptical: V_{SV}=%.2eP+%.1f', ...
        slopeNonellipse(g), interceptNonellipse(g));

    text(0.05,0.90,ellipseStr, ...
        'Units','normalized', ...
        'FontSize',10, ...
        'FontName',FONT_NAME, ...
        'HorizontalAlignment','left', ...
        'VerticalAlignment','bottom', ...
        'Interpreter','tex');

    text(0.05,0.78,nonellipseStr, ...
        'Units','normalized', ...
        'FontSize',10, ...
        'FontName',FONT_NAME, ...
        'HorizontalAlignment','left', ...
        'VerticalAlignment','bottom', ...
        'Interpreter','tex');

    % 坐标轴格式
    set(gca, ...
        'FontName', FONT_NAME, ...
        'FontSize', FONT_SIZE_AXIS, ...
        'LineWidth',1);

    box on;

end

linkaxes(ax,'xy');

%% ===================== 图例 =====================
lgd1 = legend([p1,p2], ...
    {'Ellipse model','Nonelliptical model'}, ...
    'Orientation','horizontal', ...
    'FontSize', FONT_SIZE_LEGEND, ...
    'FontName', FONT_NAME);

lgd1.Layout.Tile = 'north';

%% ===================== 斜率图 =====================
fig2 = figure('Color',[1 1 1], 'Position',[100 100 600 400]);

hold on;

plot(1:6, slopeEllipse, '-sk', ...
    'LineWidth',2, ...
    'MarkerSize',8, ...
    'MarkerFaceColor','w');

plot(1:6, slopeNonellipse, '-^k', ...
    'LineWidth',2, ...
    'MarkerSize',8, ...
    'MarkerFaceColor','w');

xticks(1:6);

xticklabels(modelParams);

ylabel('dV_{SV}/dP (m·s^{-1}·Pa^{-1})', ...
    'FontSize',12, ...
    'FontName','Times New Roman');

set(gca, ...
    'FontName','Times New Roman', ...
    'FontSize',12, ...
    'LineWidth',1);

grid on;
box on;

legend({'Ellipse','Nonellipse'}, ...
    'Location','best', ...
    'FontSize',12, ...
    'FontName','Times New Roman');