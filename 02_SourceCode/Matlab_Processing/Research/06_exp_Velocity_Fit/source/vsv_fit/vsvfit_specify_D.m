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
custom_D_nonellipse = [0.044529 0.0900357 0.0796718 0.064292 0.0603519 0.115455];
custom_D_ellipse    = [0.012397 0.0787424 0.0478881 0.0256835 0.0306735 0.1136709];

% ====== 只拟合 A, K, B ======
initialParams = [1200, 5e-12, 100];
lb = [0, 1e-12, 0];
ub = [1e4, 1e-12, 1e4];

params_nonellipse = zeros(cycle, 3);
resnorm_nonellipse = zeros(cycle, 1);
params_ellipse = zeros(cycle, 3);
resnorm_ellipse = zeros(cycle, 1);

% ====== 只有 A,K,B 三个参数；D 固定 ======
model_func = @(params, D, P) params(1) + params(2)*P - params(3)*exp(-P*D);

opts = optimset('Display', 'off', ...
                'MaxIter', 10000, ...
                'MaxFunEvals', 10000, ...
                'TolFun', 1e-8, ...
                'TolX', 1e-8);

% 3. 非椭圆数据拟合
for i = 1:cycle
    vsv = nonellipse_vsv(:, i);
    D_fix = custom_D_nonellipse(i);

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
    D_fix = custom_D_ellipse(i);

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
    nonellipse_fit = model_func(params_nonellipse(idx,:), custom_D_nonellipse(idx), P);

    ellipse_data = ellipse_vsv(:, idx);
    ellipse_fit = model_func(params_ellipse(idx,:), custom_D_ellipse(idx), P);

    hold on;
    scatter(P(1:3:end), nonellipse_data(1:3:end), 18, 'r', 'filled', 'o','DisplayName','非椭圆数据');
    plot(P, nonellipse_fit, 'r-', 'LineWidth', 1.5, 'DisplayName','非椭圆拟合');

    scatter(P(1:3:end), ellipse_data(1:3:end), 18, 'b', 'filled', 's','DisplayName','椭圆数据');
    plot(P, ellipse_fit, 'b-', 'LineWidth', 1.5, 'DisplayName','椭圆拟合');

    legend('show','FontSize',8,'Location','southeast');

    nonellipse_txt = sprintf('非椭圆:\nA=%g\nK=%g\nB=%g\nD=%g', params_nonellipse(idx,1:3), custom_D_nonellipse(idx));
    ellipse_txt    = sprintf('椭圆:\nA=%g\nK=%g\nB=%g\nD=%g', params_ellipse(idx,1:3), custom_D_ellipse(idx));

    text('String',nonellipse_txt,'Units','normalized','Position',[0.02, 0.98], ...
        'VerticalAlignment','top','FontSize',7, ...
        'BackgroundColor',[1 0.8 0.8],'Margin',2, ...
        'EdgeColor','k','Color','k');

    text('String',ellipse_txt,'Units','normalized','Position',[0.98, 0.98], ...
        'VerticalAlignment','top','HorizontalAlignment','right','FontSize',7, ...
        'BackgroundColor',[0.8 0.9 1],'Margin',2, ...
        'EdgeColor','k','Color','k');

    xlabel('Uniaxial Stress (MPa)');
    ylabel('v_{sv} (m/s)');
    title(titles{group});
    grid on;
end
sgtitle('非椭圆与椭圆数据 Stress-Vsv 拟合结果对比');


%% Plot 2: Four Parameter Trends
figure('Name', 'Parameter Trends', 'Position', [200, 200, 1200, 800]);
groups = 1:cycle;
subplot(2,2,1);
plot(groups, params_nonellipse(indices,1), 'o-r', 'MarkerFaceColor','r', 'DisplayName','Non-ellipse A'); hold on;
plot(groups, params_ellipse(indices,1), 'o-b', 'MarkerFaceColor','b', 'DisplayName','Ellipse A');
xlabel('Group Index'); ylabel('A'); title('Trend of A'); legend; grid on;

subplot(2,2,2);
plot(groups, params_nonellipse(indices,2), 'o-r', 'MarkerFaceColor','r', 'DisplayName','Non-ellipse K'); hold on;
plot(groups, params_ellipse(indices,2), 'o-b', 'MarkerFaceColor','b', 'DisplayName','Ellipse K');
xlabel('Group Index'); ylabel('K'); title('Trend of K'); legend; grid on;

subplot(2,2,3);
plot(groups, params_nonellipse(indices,3), 'o-r', 'MarkerFaceColor','r', 'DisplayName','Non-ellipse B'); hold on;
plot(groups, params_ellipse(indices,3), 'o-b', 'MarkerFaceColor','b', 'DisplayName','Ellipse B');
xlabel('Group Index'); ylabel('B'); title('Trend of B'); legend; grid on;

subplot(2,2,4);
plot(groups, custom_D_nonellipse(indices), 'o-r', 'MarkerFaceColor','r', 'DisplayName','Non-ellipse D'); hold on;
plot(groups, custom_D_ellipse(indices), 'o-b', 'MarkerFaceColor','b', 'DisplayName','Ellipse D');
xlabel('Group Index'); ylabel('D'); title('Trend of D'); legend; grid on;
sgtitle('Trends of Fitted Parameters (A, K, B, D)');

% ========== Print A, B and R^2 arrays to terminal ==========
A_nonellipse_arr = params_nonellipse(:,1)';
K_nonellipse_arr = params_nonellipse(:,2)';
B_nonellipse_arr = params_nonellipse(:,3)';
A_ellipse_arr    = params_ellipse(:,1)';
K_ellipse_arr    = params_ellipse(:,2)';
B_ellipse_arr    = params_ellipse(:,3)';

fprintf('A_nonellipse = %s;\n', mat2str(A_nonellipse_arr, 6));
fprintf('K_nonellipse = %s;\n', mat2str(K_nonellipse_arr, 6));
fprintf('B_nonellipse = %s;\n', mat2str(B_nonellipse_arr, 6));

fprintf('A_ellipse = %s;\n', mat2str(A_ellipse_arr, 6));
fprintf('K_ellipse = %s;\n', mat2str(K_ellipse_arr, 6));
fprintf('B_ellipse = %s;\n', mat2str(B_ellipse_arr, 6));

