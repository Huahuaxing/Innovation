% =============================================
% Stress-Vsv 拟合脚本 (基于经验公式)
% 公式: V(P) = A + K*P - B*exp(-P*D)
% 一些变化规律：
% D越来越大
% =============================================

clear; clc;

%% 1. 读取参数（读取 properties.json 并提取P）
cd(fileparts(mfilename("fullpath")))
jsonText = fileread('properties.json');
prop = jsondecode(jsonText);
P = prop.P(:) / 1e6; % 转换为MPa，列向量


%% 2. 读取要拟合的波速数据（vsv_polygonal.csv 和 vsv_ellipse.csv）
nonellipse_vsv = readmatrix('degree_90_horizontal_incident/vsv_polygonal.csv');
ellipse_vsv = readmatrix('degree_90_horizontal_incident/vsv_ellipse.csv');


%% 拟合主程序
cycle = 6;
% ====== 用户指定D参数 ======
D_nonellipse = [0.0507618 0.0902899 0.0809832 0.0680728 0.0655491 0.115931];
D_ellipse = [0.0246667 0.0714797 0.05026 0.03634 0.0349643 0.113368];

initialParams = [1200, 1e-14, 100];
lb = [1000, 1e-14, 0]; ub = [2000, 1e-14, 1e3];

params_nonellipse = zeros(cycle, 3);
resnorm_nonellipse = zeros(cycle, 1);
params_ellipse = zeros(cycle, 3);
resnorm_ellipse = zeros(cycle, 1);

model_func = @(params, D, P) params(1) + params(2)*P - params(3)*exp(-P*D);

opts = optimset('Display', 'off', ...
                'MaxIter', 10000, ...
                'MaxFunEvals', 10000, ...
                'TolFun', 1e-8, ...
                'TolX', 1e-8);
% 3. 非椭圆数据拟合
for i = 1:cycle
    vsv = nonellipse_vsv(:, i);
    D_fix = D_nonellipse(i);
    try
        fit_func = @(params, P) model_func(params, D_fix, P);
        [params, resnorm] = lsqcurvefit(fit_func, initialParams, P, vsv, lb, ub, opts);
        params_nonellipse(i, :) = params;
        resnorm_nonellipse(i) = resnorm;
    catch
        params_nonellipse(i, :) = initialParams;
        resnorm_nonellipse(i) = inf;
    end
end
% 4. 椭圆数据拟合
for i = 1:cycle
    vsv = ellipse_vsv(:, i);
    D_fix = D_ellipse(i);
    try
        fit_func = @(params, P) model_func(params, D_fix, P);
        [params, resnorm] = lsqcurvefit(fit_func, initialParams, P, vsv, lb, ub, opts);
        params_ellipse(i, :) = params;
        resnorm_ellipse(i) = resnorm;
    catch
        params_ellipse(i, :) = initialParams;
        resnorm_ellipse(i) = inf;
    end
end

%% 绘图1:拟合结果展示
titles = {'20AR1','16AR1+4AR2','12AR1+8AR2','8AR1+12AR2','4AR1+16AR2','20AR2'};
indices = [1,5,4,3,2,6]; % Matlab索引，从1开始
figure('Position', [100 100 1200 700]);
for group = 1:cycle
    subplot(2,3,group);
    idx = indices(group);
    nonellipse_data = nonellipse_vsv(:, idx);
    nonellipse_fit = model_func(params_nonellipse(idx,:), D_nonellipse(idx), P);
    ellipse_data = ellipse_vsv(:, idx);
    ellipse_fit = model_func(params_ellipse(idx,:), D_ellipse(idx), P);
    hold on;
    scatter(P(1:3:end), nonellipse_data(1:3:end), 18, 'r', 'filled', 'o','DisplayName','非椭圆数据');
    plot(P, nonellipse_fit, 'r-', 'LineWidth', 1.5, 'DisplayName','非椭圆拟合');
    scatter(P(1:3:end), ellipse_data(1:3:end), 18, 'b', 'filled', 's','DisplayName','椭圆数据');
    plot(P, ellipse_fit, 'b-', 'LineWidth', 1.5, 'DisplayName','椭圆拟合');
    legend('show','FontSize',8,'Location','southeast');
    % 非椭圆参数文本
    nonellipse_txt = sprintf('非椭圆:\nA=%g\nK=%g\nB=%g\nD=%g', params_nonellipse(idx,1:3), D_nonellipse(idx));
    % 椭圆参数文本
    ellipse_txt = sprintf('椭圆:\nA=%g\nK=%g\nB=%g\nD=%g', params_ellipse(idx,1:3), D_ellipse(idx));
    % 非椭圆参数文本（淡红色背景）
    text('String',nonellipse_txt,'Units','normalized','Position',[0.02, 0.98], ...
        'VerticalAlignment','top','FontSize',7, ...
        'BackgroundColor',[1 0.8 0.8],'Margin',2, ...
        'EdgeColor','k','Color','k');

    % 椭圆参数文本
    text('String',ellipse_txt,'Units','normalized','Position',[0.98, 0.98], ...
        'VerticalAlignment','top','HorizontalAlignment','right','FontSize',7, ...
        'BackgroundColor',[0.8 0.9 1],'Margin',2, ...
        'EdgeColor','k','Color','k');
    xlabel('Uniaxial Stress (MPa)'); ylabel('v_{sv} (m/s)');
    title(titles{group});
    grid on;
end
sgtitle('非椭圆与椭圆数据 Stress-Vsv 拟合结果对比');


%% Plot 2: Four Parameter Trends
figure('Name','Parameter Trends','Position',[100 100 1500 900]);
% --- A parameter ---
subplot(2,2,1)
plot(params_nonellipse(indices,1),'co','MarkerSize',8,'MarkerFaceColor','c'); hold on;
plot(params_ellipse(indices,1),'ro','MarkerSize',8,'MarkerFaceColor','r');
legend('Nonelliptical crack','Elliptical crack');
xticks(1:6);
xticklabels({'Model a','Model b','Model c','Model d','Model e','Model f'});
ylabel('A value');
title('(a) A Parameter','fontsize',14,'fontname','Times New Roman');
grid on;

% --- K parameter ---
subplot(2,2,2)
plot(params_nonellipse(indices,2),'co','MarkerSize',8,'MarkerFaceColor','c'); hold on;
plot(params_ellipse(indices,2),'ro','MarkerSize',8,'MarkerFaceColor','r');
legend('Nonelliptical crack','Elliptical crack');
xticks(1:6);
ylabel('K value');
xticklabels({'Model a','Model b','Model c','Model d','Model e','Model f'});
title('(b) K Parameter','fontsize',14,'fontname','Times New Roman');
grid on;

% --- B parameter ---
subplot(2,2,3)
plot(params_nonellipse(indices,3),'co','MarkerSize',8,'MarkerFaceColor','c'); hold on;
plot(params_ellipse(indices,3),'ro','MarkerSize',8,'MarkerFaceColor','r');
legend('Nonelliptical crack','Elliptical crack');
xticks(1:6);
ylabel('B value');
xticklabels({'Model a','Model b','Model c','Model d','Model e','Model f'});
title('(c) B Parameter','fontsize',14,'fontname','Times New Roman');
grid on;

% --- D parameter ---
subplot(2,2,4)
plot(D_nonellipse(indices),'co','MarkerSize',8,'MarkerFaceColor','c'); hold on;
plot(D_ellipse(indices),'ro','MarkerSize',8,'MarkerFaceColor','r');
legend('Nonelliptical crack','Elliptical crack');
xticks(1:6);
ylabel('D value');
xticklabels({'Model a','Model b','Model c','Model d','Model e','Model f'});
title('(d) D Parameter','fontsize',14,'fontname','Times New Roman');
grid on;
sgtitle('Trends of Parameters (A, K, B, D, by Group)');



%% 计算R²
nonellipse_r2 = zeros(cycle,1);
ellipse_r2 = zeros(cycle,1);
for i = 1:cycle
    idx = indices(i);
    y = nonellipse_vsv(:, idx);
    y_fit = model_func(params_nonellipse(idx,:), D_nonellipse(idx), P);
    SS_res = sum((y - y_fit).^2);
    SS_tot = sum((y - mean(y)).^2);
    if SS_tot > 0
        nonellipse_r2(i) = 1 - SS_res/SS_tot;
    else
        nonellipse_r2(i) = 0;
    end
    y2 = ellipse_vsv(:, idx);
    y2_fit = model_func(params_ellipse(idx,:), D_ellipse(idx), P);
    SS_res2 = sum((y2 - y2_fit).^2);
    SS_tot2 = sum((y2 - mean(y2)).^2);
    if SS_tot2 > 0
        ellipse_r2(i) = 1 - SS_res2/SS_tot2;
    else
        ellipse_r2(i) = 0;
    end
end

%% 输出拟合参数数组到终端
fprintf('\n========== 拟合参数数组 ==========\n');
fprintf('非椭圆参数（按数组索引顺序）:\n');
A_nonellipse_arr = params_nonellipse(:,1)';
K_nonellipse_arr = params_nonellipse(:,2)';
B_nonellipse_arr = params_nonellipse(:,3)';
fprintf('A_nonellipse = %s;\n', mat2str(A_nonellipse_arr, 6));
fprintf('K_nonellipse = %s;\n', mat2str(K_nonellipse_arr, 6));
fprintf('B_nonellipse = %s;\n', mat2str(B_nonellipse_arr, 6));

fprintf('\n椭圆参数（按数组索引顺序）:\n');
A_ellipse_arr = params_ellipse(:,1)';
K_ellipse_arr = params_ellipse(:,2)';
B_ellipse_arr = params_ellipse(:,3)';
fprintf('A_ellipse = %s;\n', mat2str(A_ellipse_arr, 6));
fprintf('K_ellipse = %s;\n', mat2str(K_ellipse_arr, 6));
fprintf('B_ellipse = %s;\n', mat2str(B_ellipse_arr, 6));

