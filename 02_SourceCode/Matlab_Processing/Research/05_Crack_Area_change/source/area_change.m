% 计算出等效半长轴和半短轴，计算出裂隙的等效面积变化
cd(fileparts(mfilename("fullpath")))
basePath = "D:\Projects\02_Innovation\06_ProcessedData\radius_aperture_record\data";
jsonPath = "../../..";
jsonFile = fullfile(jsonPath, "properties.json");
prop = jsondecode(fileread(jsonFile));
P = prop.P(:);

%% Ellipse
dataPathEllipse = fullfile(basePath, 'Ellipse_Record.mat');
ellipseRecord = load(dataPathEllipse);
equivalentAperture_Ellipse = squeeze(mean(mean(ellipseRecord.aperture_record, 2), 1));
equivalentRadius_Ellipse = squeeze(mean(mean(ellipseRecord.radius_record, 2), 1));
areaArray_Ellipse = equivalentAperture_Ellipse .* equivalentRadius_Ellipse .* pi;

%% EllipseAligned
dataPathEllipseAligned = fullfile(basePath, 'EllipseAligned_Record.mat');
ellipseAlignedRecord = load(dataPathEllipseAligned);
equivalentAperture_EllipseAligned = squeeze(mean(mean(ellipseAlignedRecord.aperture_record, 2), 1));
equivalentRadius_EllipseAligned = squeeze(mean(mean(ellipseAlignedRecord.radius_record, 2), 1));
areaArray_EllipseAligned = equivalentAperture_EllipseAligned .* equivalentRadius_EllipseAligned .* pi;

%% Nonellipse
dataPathNonellipse = fullfile(basePath, 'Nonellipse_Record.mat');
nonellipseRecord = load(dataPathNonellipse);
equivalentAperture_Nonellipse = squeeze(mean(mean(nonellipseRecord.aperture_record, 2), 1));
equivalentRadius_Nonellipse = squeeze(mean(mean(nonellipseRecord.radius_record, 2), 1));
areaArray_Nonellipse = equivalentAperture_Nonellipse .* equivalentRadius_Nonellipse .* pi;

%% 绘图
ax = gobjects(1, 6);
figure("Position", [0 0 1500 900])
for group=1:6
    ax(group) = subplot(2, 3, group);
    hold on;
    plot(P, areaArray_Ellipse(:, group), "-g", "LineWidth", 1.5, "DisplayName", "Ellipse");
    plot(P, areaArray_EllipseAligned(:, group), "-b", "LineWidth", 1.5, "DisplayName", "EllipseAligned");
    plot(P, areaArray_Nonellipse(:, group), "-r", "LineWidth", 1.5, "DisplayName", "Nonellipse");
    grid on;
    axis tight;
    legend("Location", "best");
    hold off;
end
linkaxes (ax, "xy");
