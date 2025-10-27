%% ------------------------- 定义基质弹性参数 -------------------------
P  = linspace(3, 600, 200) * 1e5;       % 3e5-6e7 Pa
P = P(:);                               % 变成列向量


%% ---------- 读取文件中波速数据 ----------

% 读取数据
vp_ellipse = fullfile('E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\velocity\\isotropic_matrix\\n_20\\degree_90\\vp_ellipse.csv');
vp_polygonal = fullfile('E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\velocity\\isotropic_matrix\\n_20\\degree_90\\vp_polygonal.csv');
vp_ellipse_data = readmatrix(vp_ellipse);   % 形状 (100,6)
vp_polygonal_data = readmatrix(vp_polygonal);

YData_ellipse = vp_ellipse_data - mean(vp_ellipse_data, 1);
YData_polygonal = vp_polygonal_data - mean(vp_polygonal_data, 1);

% 给原数据的列调换一下位置，按照titles的顺序分布
indices = [1, 5, 4, 3, 2, 6];
titles = {'20AR1', '16AR1+4AR2', '12AR1+8AR2', '8AR1+12AR2', '4AR1+16AR2', '20AR2'};
% 绘制文件中读取的六组波速曲线
figure('Units','centimeters','Position',[2 2 40 18]);
for group = 1:6
    subplot(2, 3, group);
    plot(P, vp_ellipse_data(:, indices(group)), 'r-', 'LineWidth',1.6);
    hold on;
    plot(P, vp_polygonal_data(:, indices(group)), 'b-', 'LineWidth',1.6);
    legend('Ellipse', 'Polygonal');
    xlabel('Uniaxial Stress Pa');
    ylabel('v_p  (m/s)');
    title(titles{group});
    grid on; legend; box on;
end

%% ------------------------- aperture -------------------------
record_ellipse = fileread('E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\record\\ellipse_data_aligned_radius_aperture_record.json');
record_polygonal = fileread('E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\record\\polygonal_data_radius_aperture_record.json');

record_ellipse = jsondecode(record_ellipse);            % （5, 20, 200, 6）
record_polygonal = jsondecode(record_polygonal);

aperture_ellipse = record_ellipse.aperture_record;
aperture_ellipse_aver = squeeze(mean(aperture_ellipse, 1));
aperture_ellipse_aver = squeeze(mean(aperture_ellipse_aver, 1));

aperture_polygonal = record_polygonal.aperture_record;
aperture_polygonal_aver = squeeze(mean(aperture_polygonal, 1));
aperture_polygonal_aver = squeeze(mean(aperture_polygonal_aver, 1));

figure('Units','centimeters','Position',[2 2 40 18]);
ax = zeros(6,1); % 创建数组存储轴句柄
for group = 1:6
    subplot(2, 3, group);
    plot(P, aperture_ellipse_aver(:, indices(group)), 'r-', 'LineWidth',1.6);
    hold on;
    plot(P, aperture_polygonal_aver(:, indices(group)), 'b-', 'LineWidth',1.6);
    legend('Ellipse', 'Polygonal');
    xlabel('Uniaxial Stress Pa');
    ylabel('Aperture  (m)');
    title(titles{group});
    grid on; legend; box on;
    ax(group) = gca; % 获取当前轴的句柄
end
% 链接所有子图的坐标轴
linkaxes(ax, 'xy');

%% ------------------------- radius -------------------------
radius_ellipse = record_ellipse.radius_record;
radius_ellipse_aver = squeeze(mean(radius_ellipse, 1));
radius_ellipse_aver = squeeze(mean(radius_ellipse_aver, 1));
radius_polygonal = record_polygonal.radius_record;
radius_polygonal_aver = squeeze(mean(radius_polygonal, 1));
radius_polygonal_aver = squeeze(mean(radius_polygonal_aver, 1));

figure('Units','centimeters','Position',[2 2 40 18]);
ax = zeros(6,1); % 创建数组存储轴句柄
for group = 1:6
    subplot(2, 3, group);
    plot(P, radius_ellipse_aver(:, indices(group)), 'r-', 'LineWidth',1.6);
    hold on;
    plot(P, radius_polygonal_aver(:, indices(group)), 'b-', 'LineWidth',1.6);
    legend('Ellipse', 'Polygonal');
    xlabel('Uniaxial Stress Pa');
    ylabel('Radius  (m)');
    title(titles{group});
    grid on; legend; box on;
    ax(group) = gca; % 获取当前轴的句柄
end
% 链接所有子图的坐标轴
linkaxes(ax, 'xy');










