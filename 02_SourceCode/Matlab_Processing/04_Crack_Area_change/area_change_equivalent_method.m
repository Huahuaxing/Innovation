% 方法一：计算出每组平均半长轴和半短轴，利用椭圆面积公式计算出裂隙的等效面积变化
% 不符合comsol模拟实际
%% 数据初始化
clear;
cd(fileparts(mfilename("fullpath")))
basePath = "../../../../06_ProcessedData/01_aperture_radius_record";
jsonPath = "../../../../06_ProcessedData";
jsonFile = fullfile(jsonPath, "parameters.json");
params = jsondecode(fileread(jsonFile));
P = params.P;

% Ellipse
dataPathEllipse = fullfile(basePath, 'Ellipse_Record.mat');
ellipseRecord = load(dataPathEllipse);
equivalentAperture_Ellipse = squeeze(mean(mean(ellipseRecord.aperture_record ./ 2, 2), 1));
equivalentRadius_Ellipse = squeeze(mean(mean(ellipseRecord.radius_record, 2), 1));
areaArray_Ellipse = equivalentAperture_Ellipse .* equivalentRadius_Ellipse .* pi;

% EllipseAligned
dataPathEllipseAligned = fullfile(basePath, 'EllipseAligned_Record.mat');
ellipseAlignedRecord = load(dataPathEllipseAligned);
equivalentAperture_EllipseAligned = squeeze(mean(mean(ellipseAlignedRecord.aperture_record ./ 2, 2), 1));
equivalentRadius_EllipseAligned = squeeze(mean(mean(ellipseAlignedRecord.radius_record, 2), 1));
areaArray_EllipseAligned = equivalentAperture_EllipseAligned .* equivalentRadius_EllipseAligned .* pi;

% Nonellipse
dataPathNonellipse = fullfile(basePath, 'Nonellipse_Record.mat');
nonellipseRecord = load(dataPathNonellipse);
equivalentAperture_Nonellipse = squeeze(mean(mean(nonellipseRecord.aperture_record ./ 2, 2), 1));
equivalentRadius_Nonellipse = squeeze(mean(mean(nonellipseRecord.radius_record, 2), 1));
areaArray_Nonellipse = equivalentAperture_Nonellipse .* equivalentRadius_Nonellipse .* pi;

%% 绘图
figure('Color',[1 1 1], 'Position', [0 0 2000 1000]);
sgtitle('Uniaxial Stress-Area', 'FontSize', 14, 'FontWeight','bold');
ax = gobjects(1, 6);
modelParams = {'20AR1', '16AR1+4AR2', '12AR1+8AR2', '8AR1+12AR2', '4AR1+16AR2', '20AR2'};
subTitleList = {'(a)', '(b)', '(c)', '(d)', '(e)', '(f)'};
for groupNum=1:6
    ax(groupNum) = subplot(2, 3, groupNum);
    plot(P, areaArray_Ellipse(:, groupNum), "-b", "LineWidth", 1.5);hold on;
    plot(P, areaArray_EllipseAligned(:, groupNum), "-g", "LineWidth", 1.5);
    plot(P, areaArray_Nonellipse(:, groupNum), "-r", "LineWidth", 1.5);
    title(subTitleList{groupNum}, 'FontSize', 12, 'FontWeight','normal');
    xlabel('Uniaxial Stress (MPa)', 'FontSize', 11);
    ylabel('Area (m^2)', 'FontSize', 11);
    if groupNum == 1
        legend({'Ellipse model', 'EllipseAligned model', 'Nonelliptical model'}, 'FontSize', 9);
    end
    text(0.5, 0.98, modelParams{groupNum}, ...
        'Units','normalized', ...
        'FontSize', 10, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'top', ...
        'BackgroundColor', [1 1 1 0.8], ...
        'EdgeColor', 'k', 'LineWidth', 0.5, ...
        'Margin', 2);
    set(gca, 'FontName', 'SimHei', 'FontSize', 11);
end
linkaxes (ax, "xy");
