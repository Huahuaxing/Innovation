%% 绘图设置
modelParams = {'20AR1', '16AR1+4AR2', '12AR1+8AR2', '8AR1+12AR2', '4AR1+16AR2', '20AR2'};
subTitleList = {'(a)', '(b)', '(c)', '(d)', '(e)', '(f)'};

% 图像保存路径设置
saveBaseDir = 'D:\Projects\02_Innovation\02_SourceCode\Matlab_Processing\Research\03_Calculate_Ceff_and_Wave_Velocity\results\Velocity\n20_degree_0';
saveDir    = fullfile(saveBaseDir, 'contain_aligned');
saveDirNot = fullfile(saveBaseDir, 'not_contain_aligned');
if ~exist("saveDir", 'dir');    mkdir(saveDir); end
if ~exist("saveDirNot", 'dir');    mkdir(saveDirNot); end

%% 数据读取
params = jsondecode(fileread('parameters.json'));
P = params.P / 1e6;
vpEllipse = readmatrix('D:\Projects\02_Innovation\06_ProcessedData\03_velocity\n_20_degree_0\vp_ellipse.csv');
vpEllipseAligned = readmatrix('D:\Projects\02_Innovation\06_ProcessedData\03_velocity\n_20_degree_0\vp_ellipseAligned.csv');
vpNonellipse = readmatrix('D:\Projects\02_Innovation\06_ProcessedData\03_velocity\n_20_degree_0\vp_nonellipse.csv');

%% 绘图区
% contain aligned
figure('Position', [100 100 2000 1000]);
sgtitle('Uniaxial Stress-P Velocity', 'FontSize', 14, 'FontWeight','bold');
ax = gobjects(1, 6);
for group=1:6
    ax(group) = subplot(2, 3, group);
    title(subTitleList{group}, 'FontSize', 12, 'FontWeight','normal');
    hold on;
    plot(P, vpEllipse(:, group), 'b-', 'LineWidth', 1.5);
    plot(P, vpEllipseAligned(:, group), 'g-', 'LineWidth', 1.5);
    plot(P, vpNonellipse(:, group), 'r-', 'LineWidth', 1.5);
    xlabel('Uniaxial Stress (MPa)', 'FontSize', 11);
    ylabel('V_p (m/s)', 'FontSize', 11);
    if group == 1
        legend({'Ellipse model', 'EllipseAligned model', 'Nonelliptical model'}, 'FontSize', 9, 'Location', 'southeast');
    end
    text(0.5, 0.07, modelParams{group}, ...
        'Units','normalized', ...          % 使用子图归一化坐标
        'FontSize', 10, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'top', ...
        'BackgroundColor', [1 1 1 0.8], ...
        'EdgeColor', 'k', 'LineWidth', 0.5, ...
        'Margin', 2);
    set(gca, 'FontName', 'SimHei', 'FontSize', 11);
end
linkaxes(ax, 'xy'); 

saveas(gcf, fullfile(saveDir, 'Uniaxial Stress-P Velocity.fig'));
saveas(gcf, fullfile(saveDir, 'Uniaxial Stress-P Velocity.png'));

% not contain algned
figure('Position', [100 100 2000 1000]);
sgtitle('Uniaxial Stress-P Velocity', 'FontSize', 14, 'FontWeight','bold');
ax = gobjects(1, 6);
for group=1:6
    ax(group) = subplot(2, 3, group);
    title(subTitleList{group}, 'FontSize', 12, 'FontWeight','normal');
    hold on;
    plot(P, vpEllipse(:, group), 'b-', 'LineWidth', 1.5);
    plot(P, vpNonellipse(:, group), 'r-', 'LineWidth', 1.5);
    xlabel('Uniaxial Stress (MPa)', 'FontSize', 11);
    ylabel('V_p (m/s)', 'FontSize', 11);
    if group == 1
        legend({'Ellipse model', 'Nonelliptical model'}, 'FontSize', 9, 'Location', 'southeast');
    end
    text(0.5, 0.07, modelParams{group}, ...
        'Units','normalized', ...          % 使用子图归一化坐标
        'FontSize', 10, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'top', ...
        'BackgroundColor', [1 1 1 0.8], ...
        'EdgeColor', 'k', 'LineWidth', 0.5, ...
        'Margin', 2);
    set(gca, 'FontName', 'SimHei', 'FontSize', 11);
end
linkaxes(ax, 'xy'); 

saveas(gcf, fullfile(saveDirNot, 'Uniaxial Stress-P Velocity.fig'));
saveas(gcf, fullfile(saveDirNot, 'Uniaxial Stress-P Velocity.png'));