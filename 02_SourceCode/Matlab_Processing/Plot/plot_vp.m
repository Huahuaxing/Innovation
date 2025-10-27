%% ------------------------- 定义基质弹性参数 -------------------------
P  = linspace(3, 600, 200) * 1e5;       % 3e5-6e7 Pa
P = P(:);                               % 变成列向量


%% ---------- 读取文件中波速数据 ----------

% 读取数据
vp_ellipse = fullfile('D:\\Projects\\02_Innovation\\05_ProcessedData\\velocity\\n_20_deg_0\\vp_ellipse.csv');
vp_polygonal = fullfile('D:\\Projects\\02_Innovation\\05_ProcessedData\\velocity\\n_20_deg_0\\vp_polygonal.csv');
vp_ellipse_data = readmatrix(vp_ellipse);
vp_polygonal_data = readmatrix(vp_polygonal);

% 给原数据的列调换一下位置，按照titles的顺序分布
indices = [1, 5, 4, 3, 2, 6];
titles = {'20AR1', '16AR1+4AR2', '12AR1+8AR2', '8AR1+12AR2', '4AR1+16AR2', '20AR2'};
% 绘制文件中读取的六组波速曲线
figure('Units','centimeters','Position',[2 2 40 18]);
for group = 1:6
    subplot(2, 3, group);
    plot(P, vp_ellipse_data(:, indices(group)), 'b-', 'LineWidth',1.6);
    hold on;
    plot(P, vp_polygonal_data(:, indices(group)), 'r-', 'LineWidth',1.6);
    legend('Ellipse', 'Polygonal');
    xlabel('Uniaxial Stress Pa');
    ylabel('v_p  (m/s)');
    title(titles{group});
    grid on; legend; box on;
end

savefig('D:\Projects\02_Innovation\05_ProcessedData\velocity\n_20_deg_0\\vp.fig');