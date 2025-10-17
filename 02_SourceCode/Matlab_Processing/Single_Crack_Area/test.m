aa = load('D:\Projects\02_Innovation\06_Results\03_Single_Crack_Area\Table41.txt');

format long g

x = aa(:,1);
y = aa(:,2);

figure;
plot(x, y, '-o', 'LineWidth', 1.2, 'MarkerSize', 4);
grid on;
xlabel('列 1');
ylabel('列 2');
title('Table42: 列1 vs 列2');

% 保存图像到指定目录（示例）
outdir = 'D:\Projects\02_Innovation\06_Results\03_Single_Crack_Area\figures';
if ~exist(outdir, 'dir'), mkdir(outdir); end

% 文件名（可改）
fname_png = fullfile(outdir, 'Table41.png');
fname_pdf = fullfile(outdir, 'Table41.pdf');
fname_fig = fullfile(outdir, 'Table41.fig');

% 方法A：高质量导出（MATLAB R2020a 及以后推荐）
exportgraphics(gcf, fname_png, 'Resolution', 300);

% 方法B：经典的 print，指定分辨率
% print(gcf, '-dpng', fname_png, '-r300');

% 方法C：保存为 MATLAB 可恢复的 .fig
% savefig(gcf, fname_fig);

% 方法D：简单保存（格式由扩展名决定）
% saveas(gcf, fname_pdf);
% ...existing code...