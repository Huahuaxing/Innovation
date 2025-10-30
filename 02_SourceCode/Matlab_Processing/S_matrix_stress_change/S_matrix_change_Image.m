% =============================================
% 弹性矩阵随应力变化分析脚本
% =============================================

clear; clc;

%% 1. 读取P参数（读取 properties.json 并提取P）
cd(fileparts(mfilename("fullpath")))
jsonText = fileread('../properties.json');
prop = jsondecode(jsonText);
P = prop.P(:) / 1e6; % 转换为MPa，列向量
cycle = 6;

%% 2. 加载Ceff数据文件
% cd(fileparts(mfilename("fullpath")))
matfile = 'D:\Projects\02_Innovation\05_ProcessedData\C_eff\C_eff_polygonal.mat';   % <-- 此处填写你的mat文件名
data = load(matfile);               % 加载mat文件中的所有变量
C_eff = data.C_eff;                 % 200，5，6，6，6

%% 3. 求出逆矩阵
S_eff = zeros(200, 5, 6, 6, 6);   % 预分配，和C_eff同形
for i = 1:200
    for j = 1:5
        for k = 1:6
            % 取出6×6矩阵
            C66 = squeeze(C_eff(i, j, :, :, k));
            % 求逆（保证C66为6x6）
            S_eff(i, j, :, :, k) = inv(C66);
        end
    end
end

disp(squeeze(C_eff(1,1,:,:,1)))
disp(squeeze(C_eff(100,1,:,:,1)))

n = size(C_eff,1);         % 样本点数量
S11 = zeros(n,cycle);
S12 = zeros(n,cycle);
S13 = zeros(n,cycle);
S33 = zeros(n,cycle);
S44 = zeros(n,cycle);

for i = 1:n
    for j = 1:cycle
        S = squeeze(S_eff(i,1,:,:,j));
        S11(i,j) = S(1,1);
        S12(i,j) = S(1,2);
        S13(i,j) = S(1,3);
        S33(i,j) = S(3,3);
        S44(i,j) = S(4,4);
    end
end

%% 4.绘图
titles = {'20AR1','16AR1+4AR2','12AR1+8AR2','8AR1+12AR2','4AR1+16AR2','20AR2'};
indices = [1,5,4,3,2,6];
S_cell = {S11, S12, S13, S33, S44};
names = {'S_{11}','S_{12}','S_{13}','S_{33}','S_{44}'};
colors = {'r-','g-','b-','m-','k-'};
figure('Position', [100 100 1200 700]);
for group = 1:cycle
    subplot(2, 3, group)
    hold on;
    for i = 1:5
        plot(P, S_cell{i}(:,indices(group)), colors{i}, 'LineWidth', 1.5);
    end
    xlabel('P (MPa)');
    ylabel('柔度值');
    legend(names, 'Location','best','FontSize',11);
    set(gca,'FontSize',13);
    title(titles{group});
    grid on;
end
sgtitle('TI岩体五个独立柔度分量随应力变化趋势');
