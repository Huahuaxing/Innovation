% 通过comsol数据，绘制出裂隙形态变化图，先绘制1-1模型第一个裂隙
cd(fileparts(mfilename("fullpath")))

dataPathEllipse = 'D:\Projects\02_Innovation\05_Data\SoftCrack\ellipse_data';
dataPathEllipseAligned= 'D:\Projects\02_Innovation\05_Data\SoftCrack\ellipse_data_aligned';
dataPathNonellipse = 'D:\Projects\02_Innovation\05_Data\SoftCrack\polygonal_data';

%% Ellipse
aa = zeros(40, 200, 43);
for tab = 1:40  % 四十个表格
    file_path = fullfile(dataPathEllipse, sprintf('20-cracks-distance-1-1-AR1'), sprintf('20-cracks-distance-%d~40-1-AR1.txt', tab));
    rawData = readmatrix(file_path, 'NumHeaderLines', 5);  % 跳过前5行
    aa(tab, :, :) = rawData;
end

point_n = floor((size(aa, 3)-1)/2);
pointy_start_idx = size(aa, 3) - point_n + 1;   % Matlab索引从1开始

figure("Position", [0 0 2000 800]);
% 使用2x5布局，更紧凑且易于查看
for i=1:10
    subplot(2, 5, i)
    hold on;
    % 使用squeeze确保数据是一维向量
    x1 = squeeze(aa(1, i*20, 2:pointy_start_idx-1));
    y1 = squeeze(aa(1, i*20, pointy_start_idx:end));
    x2 = squeeze(aa(2, i*20, 2:pointy_start_idx-1));
    y2 = squeeze(aa(2, i*20, pointy_start_idx:end));
    plot(x1, y1, 'b-', 'LineWidth', 1.5)
    plot(x2, y2, 'r-', 'LineWidth', 1.5)
    title(sprintf('Step %d', i*20))
    xlabel('X')
    ylabel('Y')
    grid on;
    axis tight;  % 自动适应数据范围，避免图形过扁
    hold off;
end
% 调整子图间距
sgtitle('裂隙形态变化图', 'FontSize', 14, 'FontWeight', 'bold')

