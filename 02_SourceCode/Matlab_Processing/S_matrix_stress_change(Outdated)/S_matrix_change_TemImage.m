% =============================================
% 弹性矩阵随应力变化分析脚本
% =============================================

clear; clc;

% 1. 加载mat数据文件
% cd(fileparts(mfilename("fullpath")))
matfile = 'D:\Projects\02_Innovation\05_ProcessedData\C_eff\C_eff_polygonal.mat';   % <-- 此处填写你的mat文件名

data = load(matfile);               % 加载mat文件中的所有变量
C_eff = data.C_eff;                 % 200，5，6，6，6

S = zeros(200, 5, 6, 6, 6);   % 预分配，和C_eff同形

for i = 1:200
    for j = 1:5
        for k = 1:6
            % 取出6×6矩阵
            C66 = squeeze(C_eff(i, j, :, :, k));
            % 求逆（保证C66为6x6）
            S(i, j, :, :, k) = inv(C66);
        end
    end
end


%% 选择方向与索引
j_idx = 1;   % 方向索引
k_idx = 1;   % 第五维索引

% 提取指定方向的200个6x6矩阵
S_select = squeeze(S(:, j_idx, :, :, k_idx));   % 尺寸: 200×6×6

% 将每个矩阵展开为1×36行向量
S_reshaped = reshape(S_select, [200, 36]);      % 尺寸: 200×36

%% 绘制热图
figure('Color','w','Position',[100 100 1200 700]);   % 正确
imagesc(S_reshaped);
colormap("turbo");
colorbar;
xlabel('C_{ij} 组件 (展开为1~36)');
ylabel('预应力序号 (1~200)');

% 美化刻度
set(gca,'FontSize',12,'LineWidth',1.2);

hold on;
for idx = 1:36
    xline(idx+0.5, '-k', 'LineWidth', 0.5);
end
hold off;

% ---- 每6个加主刻度 ----
xticks = 1:5:36;
xticklabels = cell(1, length(xticks));    % 直接预分配好cell数组
for idx = 1:length(xticks)
    xticklabels{idx} = sprintf('%d', xticks(idx));
end
set(gca, 'XTick', xticks);
set(gca, 'XTickLabel', xticklabels);
