%% ============================================
%  Stress-Vp 拟合脚本 (基于经验公式)
%  公式: V(P) = A + K*P - B*exp(-P*D)
%% ============================================
clear; clc; close all;

prop = jsondecode(fileread('properties.json'));

cd(fileparts(mfilename('fullpath')))
nonellipse_vp_path = fullfile(".\degree_0\vp_polygonal.csv");
nonellipse_de0_vp = readmatrix(nonellipse_vp_path);

cycle = 6;
%% 定义拟合函数
model_fun = @(params, P) params(1) + params(2)*P - params(3)*exp(-P*params(4));
% params = [A, K, B, D]

%% 初始猜测参数
params0 = [1200, 0, 0, 0];  % 可根据数据范围调整初值

%% 执行非线性最小二乘拟合
params_fit_all = cell(1,6);   % 存拟合后的参数
resnorm_all = zeros(1,6);     % 存拟合损失
residual_all = cell(1,6);     % 存残差

options = optimoptions('lsqcurvefit', 'Display', 'iter', 'MaxFunctionEvaluations', 1e4);

for i = 1:cycle
    vp = nonellipse_de0_vp(:,i);
    [params_fit, resnorm, residual] = lsqcurvefit(model_fun, params0, prop.P, vp, [], [], options);
    params_fit_all{i} = params_fit;
    resnorm_all(i) = resnorm;
    residual_all{i} = residual;
end

%% 绘图
% 给原数据的列调换一下位置，按照titles的顺序分布
indices = [1, 5, 4, 3, 2, 6];
titles = {'20AR1', '16AR1+4AR2', '12AR1+8AR2', '8AR1+12AR2', '4AR1+16AR2', '20AR2'};
figure('Units','centimeters','Position',[2 2 40 18]);
for group = 1:cycle
    vp_fit = model_fun(params_fit_all{group}, prop.P);

    subplot(2, 3, group);
    plot(prop.P, nonellipse_de0_vp(:,indices(group)), 'r-', 'LineWidth',1.6);
    hold on;
    h1 = plot(prop.P, vp_fit, 'b-', 'LineWidth', 1.6);
    legend(h1, sprintf('A = %.4f, K = %.4f, B = %.4f, D = %.4f', params_fit_all{group}(1), params_fit_all{group}(2), params_fit_all{group}(3), params_fit_all{group}(4)), 'Location', 'best');
    xlabel('Uniaxial Stress Pa');
    ylabel('v_p  (m/s)');
    title(titles{group});
    grid on; legend; box on;
end

%% 计算拟合优度
% R2 = 1 - sum(residual.^2) / sum((nonellipse_vp - mean(nonellipse_vp)).^2);
% fprintf('拟合优度 R² = %.4f\n', R2);