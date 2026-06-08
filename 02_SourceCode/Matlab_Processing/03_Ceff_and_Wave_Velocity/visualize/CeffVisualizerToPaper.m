% C_eff矩阵为横向各向同性矩阵
% 五个独立分量：
% C11、C12、C13、C33、C44
%
% 三行两列六幅子图
% 每幅子图对应六组模型中的一组
% 每幅子图中包含五条曲线，分别表示五个独立刚度分量

clear;
clc;

%% ===================== 绘图设置 =====================
modelParams = { ...
    '20AR1', ...
    '16AR1+4AR2', ...
    '12AR1+8AR2', ...
    '8AR1+12AR2', ...
    '4AR1+16AR2', ...
    '20AR2'};

subTitleList = {'(a)', '(b)', '(c)', '(d)', '(e)', '(f)'};

FONT_NAME         = 'Times New Roman';
FONT_SIZE_TITLE   = 14;
FONT_SIZE_LABEL   = 12;
FONT_SIZE_AXIS    = 11;
FONT_SIZE_LEGEND  = 10;
FONT_SIZE_TEXT    = 11;

LINE_WIDTH = 1.5;

%% ===================== 保存路径 =====================
saveBaseDir = '.\07_Research\02_C_eff_and_Velocity\Figure\n20_degree_0';
saveDir = fullfile(saveBaseDir, 'not_contain_aligned');

if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end

%% ===================== 数据读取 =====================
params = jsondecode( ...
    fileread('.\06_ProcessedData\parameters.json'));

P = params.P / 1e6;     % MPa

% 数据维度:
% 200 × 5 × 6 × 6 × 6
C_eff_Ellipse = load( ...
    ".\06_ProcessedData\02_C_eff\ellipse_C_eff.mat");

C_eff_Nonellipse = load( ...
    ".\06_ProcessedData\02_C_eff\Nonellipse_C_eff.mat");

C_eff_Ellipse = C_eff_Ellipse.C_eff_ellipse;
C_eff_Nonellipse = C_eff_Nonellipse.C_eff_nonellipse;

% 对第二维求平均
% 结果维度:
% 200 × 6 × 6 × 6
C_eff_Ellipse_mean = squeeze(mean(C_eff_Ellipse, 2)) / 1e9;
C_eff_Nonellipse_mean = squeeze(mean(C_eff_Nonellipse, 2)) / 1e9;

%% ===================== 提取五个独立分量 =====================
% 顺序:
% 1 → C11
% 2 → C12
% 3 → C13
% 4 → C33
% 5 → C44

% ellipse
C11_E = squeeze(C_eff_Ellipse_mean(:,1,1,:));
C12_E = squeeze(C_eff_Ellipse_mean(:,1,2,:));
C13_E = squeeze(C_eff_Ellipse_mean(:,1,3,:));
C33_E = squeeze(C_eff_Ellipse_mean(:,3,3,:));
C44_E = squeeze(C_eff_Ellipse_mean(:,4,4,:));

% nonellipse
C11_N = squeeze(C_eff_Nonellipse_mean(:,1,1,:));
C12_N = squeeze(C_eff_Nonellipse_mean(:,1,2,:));
C13_N = squeeze(C_eff_Nonellipse_mean(:,1,3,:));
C33_N = squeeze(C_eff_Nonellipse_mean(:,3,3,:));
C44_N = squeeze(C_eff_Nonellipse_mean(:,4,4,:));


%% 非椭圆裂隙模型绘图

fig1 = figure( ...
    'Color',[1 1 1], ...
    'Position',[100 100 900 1200]);

tiledlayout(3,2, ...
    'TileSpacing','compact', ...
    'Padding','compact');

ax1 = gobjects(1,6);

componentNames = { ...
    'C_{11}', ...
    'C_{12}', ...
    'C_{13}', ...
    'C_{33}', ...
    'C_{44}'};

for g = 1:6
    
    ax1(g) = nexttile;
    hold on;

    % ===================== Nonellipse =====================
    p1 = plot(P, C11_N(:,g), '-k', 'LineWidth',LINE_WIDTH);
    p2 = plot(P, C12_N(:,g), '--k', 'LineWidth',LINE_WIDTH);
    p3 = plot(P, C13_N(:,g), '-.k', 'LineWidth',LINE_WIDTH);
    p4 = plot(P, C33_N(:,g), ':k', 'LineWidth',LINE_WIDTH);
    p5 = plot(P, C44_N(:,g), '-ok', ...
        'LineWidth',LINE_WIDTH, ...
        'MarkerIndices',1:20:length(P), ...
        'MarkerFaceColor','w');

    title(subTitleList{g}, ...
        'FontSize',FONT_SIZE_TITLE, ...
        'FontWeight','normal', ...
        'FontName',FONT_NAME);

    xlabel('Stress (MPa)', ...
        'FontSize',FONT_SIZE_LABEL);

    ylabel('Stiffness (GPa)', ...
        'FontSize',FONT_SIZE_LABEL);

    text(0.95,0.95,modelParams{g}, ...
        'Units','normalized', ...
        'FontSize',FONT_SIZE_TEXT, ...
        'FontWeight','bold', ...
        'HorizontalAlignment','right');

    set(gca,'FontName',FONT_NAME,'FontSize',FONT_SIZE_AXIS,'LineWidth',1);
    box on;

end

lgd1 = legend([p1,p2,p3,p4,p5], componentNames, ...
    'Orientation','horizontal', ...
    'FontSize',FONT_SIZE_LEGEND);

lgd1.Layout.Tile = 'north';

linkaxes(ax1,'x');

exportgraphics(fig1, fullfile(saveDir,'Ceff_Nonellipse.png'), 'Resolution',600);


%% 椭圆裂隙模型绘图

fig2 = figure( ...
    'Color',[1 1 1], ...
    'Position',[100 100 900 1200]);

tiledlayout(3,2, ...
    'TileSpacing','compact', ...
    'Padding','compact');

ax2 = gobjects(1,6);

for g = 1:6
    
    ax2(g) = nexttile;
    hold on;

    % ===================== Ellipse =====================
    p1 = plot(P, C11_E(:,g), '-k', 'LineWidth',LINE_WIDTH);
    p2 = plot(P, C12_E(:,g), '--k', 'LineWidth',LINE_WIDTH);
    p3 = plot(P, C13_E(:,g), '-.k', 'LineWidth',LINE_WIDTH);
    p4 = plot(P, C33_E(:,g), ':k', 'LineWidth',LINE_WIDTH);
    p5 = plot(P, C44_E(:,g), '-ok', ...
        'LineWidth',LINE_WIDTH, ...
        'MarkerIndices',1:20:length(P), ...
        'MarkerFaceColor','w');

    title(subTitleList{g}, ...
        'FontSize',FONT_SIZE_TITLE, ...
        'FontWeight','normal', ...
        'FontName',FONT_NAME);

    xlabel('Stress (MPa)', ...
        'FontSize',FONT_SIZE_LABEL);

    ylabel('Stiffness (GPa)', ...
        'FontSize',FONT_SIZE_LABEL);

    text(0.95,0.95,modelParams{g}, ...
        'Units','normalized', ...
        'FontSize',FONT_SIZE_TEXT, ...
        'FontWeight','bold', ...
        'HorizontalAlignment','right');

    set(gca,'FontName',FONT_NAME,'FontSize',FONT_SIZE_AXIS,'LineWidth',1);
    box on;

end

lgd2 = legend([p1,p2,p3,p4,p5], componentNames, ...
    'Orientation','horizontal', ...
    'FontSize',FONT_SIZE_LEGEND);

lgd2.Layout.Tile = 'north';

linkaxes(ax2,'x');

exportgraphics(fig2, ...
    fullfile(saveDir,'Ceff_Ellipse.png'), ...
    'Resolution',600);