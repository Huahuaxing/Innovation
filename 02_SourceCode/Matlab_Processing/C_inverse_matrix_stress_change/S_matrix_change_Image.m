% =============================================
% 弹性矩阵随应力变化分析脚本
% =============================================

clear; clc;

%% 1. 读取P参数（读取 properties.json 并提取P）
cd(fileparts(mfilename("fullpath")))
jsonText = fileread('../properties.json');
prop = jsondecode(jsonText);
P = prop.P(:) / 1e6; % 转换为MPa，列向量

%% 2. 加载Ceff数据文件
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

n = size(C_eff,1);         % 样本点数量
S11 = zeros(n,1); S12 = zeros(n,1); S13 = zeros(n,1); S33 = zeros(n,1); S44 = zeros(n,1);

for i = 1:n
    S = squeeze(C_eff(i,1,:,:,1));   % 取出第i组6×6
    S11(i) = S(1,1);
    S12(i) = S(1,2);
    S13(i) = S(1,3);
    S33(i) = S(3,3);
    S44(i) = S(4,4);
end


S_cell = {S11, S12, S13, S33, S44};
names = {'S_{11}','S_{12}','S_{13}','S_{33}','S_{44}'};
colors = {'r-o','g-o','b-o','m-o','k-o'};

figure('Position', [100 100 1200 700]);
for i = 1:5
    subplot(2,3,i);
    plot(P, S_cell{i}, colors{i}, 'LineWidth', 1.2); grid on
    title(names{i});
    xlabel('P (MPa)');
    ylabel('柔度值');
    set(gca,'FontSize',11);
end
sgtitle('TI岩体五个独立柔度分量随应力变化趋势');
