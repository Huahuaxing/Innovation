%% 数据初始化
clear;
cd(fileparts(mfilename("fullpath")))
params = jsondecode(fileread('../../../../06_ProcessedData/parameters.json'));
P = params.P(:) / 1e6;  % 转换为MPa，列向量

% 图像保存路径设置
saveBaseDir = 'D:\Projects\02_Innovation\07_Research\01_Aperture_Radius\Figure\01_threshold_algorithm';
saveDirContain    = fullfile(saveBaseDir, 'contain_ellipseAligned');
saveDirNotContain = fullfile(saveBaseDir, 'not_contain_ellipseAligned');
if ~exist(saveDirContain, 'dir');    mkdir(saveDirContain);    end
if ~exist(saveDirNotContain, 'dir'); mkdir(saveDirNotContain); end

% 读取数据
ellipseData = load('D:\Projects\02_Innovation\06_ProcessedData\01_aperture_radius_record\Ellipse_Record.mat');
ellipseAlignedData = load('D:\Projects\02_Innovation\06_ProcessedData\01_aperture_radius_record\EllipseAligned_Record.mat');
nonellipseData = load('D:\Projects\02_Innovation\06_ProcessedData\01_aperture_radius_record\Nonellipse_Record.mat');

apertureEllipse = squeeze(mean(mean(ellipseData.aperture_record,2),1));      % (200,6)
radiusEllipse = squeeze(mean(mean(ellipseData.radius_record,2),1));          % (200,6)
apertureEllipseAligned = squeeze(mean(mean(ellipseAlignedData.aperture_record,2),1));
radiusEllipseAligned = squeeze(mean(mean(ellipseAlignedData.radius_record,2),1));
apertureNonEllipse = squeeze(mean(mean(nonellipseData.aperture_record,2),1));
radiusNonEllipse = squeeze(mean(mean(nonellipseData.radius_record,2),1));

maxApertureEllipse         = max(apertureEllipse,        [], 1);  % 1×6
maxApertureEllipseAligned  = max(apertureEllipseAligned, [], 1);
maxApertureNonEllipse      = max(apertureNonEllipse,     [], 1);
apertureEllipseNorm        = apertureEllipse        ./ maxApertureEllipse;
apertureEllipseAlignedNorm = apertureEllipseAligned ./ maxApertureEllipseAligned;
apertureNonEllipseNorm     = apertureNonEllipse     ./ maxApertureNonEllipse;

%% 绘图1 （contain ellipseAligned）
% P-Aperture 多模型对比图
modelParams = {'20AR1', '16AR1+4AR2', '12AR1+8AR2', '8AR1+12AR2', '4AR1+16AR2', '20AR2'};
subTitleList = {'(a)', '(b)', '(c)', '(d)', '(e)', '(f)'};
figure('Color',[1 1 1], 'Position', [0 0 2000 1000]);
sgtitle('Uniaxial Stress-Aperture', 'FontSize', 14, 'FontWeight','bold');
ax = gobjects(1, 6);
for i = 1:6
    ax(i) = subplot(2, 3, i);
    plot(P, apertureEllipse(:, i), '-b', 'LineWidth', 1.5); hold on;
    plot(P, apertureEllipseAligned(:, i), '-g', 'LineWidth', 1.5);
    plot(P, apertureNonEllipse(:, i), '-r', 'LineWidth', 1.5);
    title(subTitleList{i}, 'FontSize', 12, 'FontWeight','normal');
    xlabel('Uniaxial Stress (MPa)', 'FontSize', 11);
    ylabel('Aperture (m)', 'FontSize', 11);
    if i == 1
        legend({'Ellipse model', 'EllipseAligned model', 'Nonelliptical model'}, 'FontSize', 9);
    end
    text(0.5, 0.98, modelParams{i}, ...
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
linkaxes(ax, 'xy'); 

% 保存：包含 ellipseAligned 的 P-Aperture 图像
saveas(gcf, fullfile(saveDirContain, 'Uniaxial Stress-Aperture.fig'));
saveas(gcf, fullfile(saveDirContain, 'Uniaxial Stress-Aperture.png'));

% P-Diameter 多模型对比图
figure('Color',[1 1 1], 'Position', [0 0 2000 1000]);
sgtitle('Uniaxial Stress-Diameter', 'FontSize', 14, 'FontWeight','bold');
ax = gobjects(1, 6);
for i = 1:6
    ax(i) = subplot(2, 3, i);
    plot(P, radiusEllipse(:, i)*2, '-b', 'LineWidth', 1.5); hold on;
    plot(P, radiusEllipseAligned(:, i)*2, '-g', 'LineWidth', 1.5);
    plot(P, radiusNonEllipse(:, i)*2, '-r', 'LineWidth', 1.5);
    title(subTitleList{i}, 'FontSize', 12, 'FontWeight','normal');
    xlabel('Uniaxial Stress (MPa)', 'FontSize', 11);
    ylabel('Diameter (m)', 'FontSize', 11);
    if i == 1
        legend({'Ellipse model', 'EllipseAligned model', 'Nonelliptical model'}, 'FontSize', 9);
    end
    text(0.5, 0.98, modelParams{i}, ...
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
linkaxes(ax, 'xy');

% 保存：包含 ellipseAligned 的 P-Radius 图像
saveas(gcf, fullfile(saveDirContain, 'Uniaxial Stress-Diameter.fig'));
saveas(gcf, fullfile(saveDirContain, 'Uniaxial Stress-Diameter.png'));

% Normalized P-Aperture
figure('Color',[1 1 1], 'Position', [0 0 2000 1000]);
sgtitle('Uniaxial Stress-Normalized Aperture', ...
        'FontSize', 14, 'FontWeight','bold');
ax = gobjects(1, 6);
for i = 1:6
    ax(i) = subplot(2, 3, i);
    plot(P, apertureEllipseNorm(:, i),        '-b', 'LineWidth', 1.5); hold on;
    plot(P, apertureEllipseAlignedNorm(:, i), '-g', 'LineWidth', 1.5);
    plot(P, apertureNonEllipseNorm(:, i),     '-r', 'LineWidth', 1.5);
    title(subTitleList{i}, 'FontSize', 12, 'FontWeight','normal');
    xlabel('Uniaxial Stress (MPa)', 'FontSize', 11);
    ylabel('Normalized Aperture', 'FontSize', 11);
    if i == 1
        legend({'Ellipse model', 'EllipseAligned model', 'Nonelliptical model'}, ...
               'FontSize', 9, 'Location','northeast');
    end
    text(0.5, 0.98, modelParams{i}, ...
        'Units','normalized', ...
        'FontSize', 10, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'top', ...
        'BackgroundColor', [1 1 1 0.8], ...
        'EdgeColor', 'k', 'LineWidth', 0.5, ...
        'Margin', 2);
    % grid on;
    set(gca, 'FontName', 'SimHei', 'FontSize', 11);
end
linkaxes(ax, 'xy');

% 保存：包含 ellipseAligned 的 Normalized P-Aperture 图像
saveas(gcf, fullfile(saveDirContain, 'Uniaxial Stress-Normalized Aperture.fig'));
saveas(gcf, fullfile(saveDirContain, 'Uniaxial Stress-Normalized Aperture.png'));

%% 绘图2 （not contain ellipseAligned）
% P-Aperture 双模型对比图
figure('Color',[1 1 1], 'Position', [0 0 2000 1000]);
sgtitle('Uniaxial Stress-Aperture', 'FontSize', 14, 'FontWeight','bold');
ax = gobjects(1, 6);
for i = 1:6
    ax(i) = subplot(2, 3, i);
    plot(P, apertureEllipse(:, i), '-b', 'LineWidth', 1.5); hold on;
    plot(P, apertureNonEllipse(:, i), '-r', 'LineWidth', 1.5);
    title(subTitleList{i}, 'FontSize', 12, 'FontWeight','normal');
    xlabel('Uniaxial Stress (MPa)', 'FontSize', 11);
    ylabel('Aperture (m)', 'FontSize', 11);
    if i == 1
        legend({'Ellipse model', 'Nonelliptical model'}, 'FontSize', 9);
    end
    text(0.5, 0.98, modelParams{i}, ...
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
linkaxes(ax, 'xy'); 

% 保存：不包含 ellipseAligned 的 P-Aperture 图像
saveas(gcf, fullfile(saveDirNotContain, 'Uniaxial Stress-Aperture.fig'));
saveas(gcf, fullfile(saveDirNotContain, 'Uniaxial Stress-Aperture.png'));

% P-Diameter 双模型对比图
figure('Color',[1 1 1], 'Position', [0 0 2000 1000]);
sgtitle('Uniaxial Stress-Diameter', 'FontSize', 14, 'FontWeight','bold');
ax = gobjects(1, 6);
for i = 1:6
    ax(i) = subplot(2, 3, i);
    plot(P, radiusEllipse(:, i)*2, '-b', 'LineWidth', 1.5); hold on;
    plot(P, radiusNonEllipse(:, i)*2, '-r', 'LineWidth', 1.5);
    title(subTitleList{i}, 'FontSize', 12, 'FontWeight','normal');
    xlabel('Uniaxial Stress (MPa)', 'FontSize', 11);
    ylabel('Diameter (m)', 'FontSize', 11);
    if i == 1
        legend({'Ellipse model', 'Nonelliptical model'}, 'FontSize', 9);
    end
    text(0.5, 0.98, modelParams{i}, ...
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
linkaxes(ax, 'xy');

% 保存：不包含 ellipseAligned 的 P-Diameter 图像
saveas(gcf, fullfile(saveDirNotContain, 'Uniaxial Stress-Diameter.fig'));
saveas(gcf, fullfile(saveDirNotContain, 'Uniaxial Stress-Diameter.png'));

% normalized P-Aperture
figure('Color',[1 1 1], 'Position', [0 0 2000 1000]);
sgtitle('Uniaxial Stress-Normalized Aperture', ...
        'FontSize', 14, 'FontWeight','bold');
ax = gobjects(1, 6);
for i = 1:6
    ax(i) = subplot(2, 3, i);
    plot(P, apertureEllipseNorm(:, i),    '-b', 'LineWidth', 1.5); hold on;
    plot(P, apertureNonEllipseNorm(:, i), '-r', 'LineWidth', 1.5);
    title(subTitleList{i}, 'FontSize', 12, 'FontWeight','normal');
    xlabel('Uniaxial Stress (MPa)', 'FontSize', 11);
    ylabel('Normalized Aperture', 'FontSize', 11);
    if i == 1
        legend({'Ellipse model', 'Nonelliptical model'}, ...
               'FontSize', 9, 'Location','northeast');
    end
    text(0.5, 0.98, modelParams{i}, ...
        'Units','normalized', ...
        'FontSize', 10, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'top', ...
        'BackgroundColor', [1 1 1 0.8], ...
        'EdgeColor', 'k', 'LineWidth', 0.5, ...
        'Margin', 2);
    % grid on;
    set(gca, 'FontName', 'SimHei', 'FontSize', 11);
end
linkaxes(ax, 'xy');

% 保存：不包含 ellipseAligned 的 Normalized P-Aperture 图像
saveas(gcf, fullfile(saveDirNotContain, 'Uniaxial Stress-Normalized Aperture.fig'));
saveas(gcf, fullfile(saveDirNotContain, 'Uniaxial Stress-Normalized Aperture.png'));