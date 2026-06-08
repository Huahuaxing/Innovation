% =============================================
% Stress-Vsv 拟合脚本 (基于经验公式)
% 公式: V(P) = A + K*P - B*exp(-P*D)
% =============================================

clear; clc;

%% 读取参数（读取 properties.json 并提取P）
cd(fileparts(mfilename("fullpath")))
jsonText = fileread('properties.json');
prop = jsondecode(jsonText);
P = prop.P(:) / 1e6; % 转换为MPa，列向量


%% 读取要拟合的波速数据（vp_polygonal.csv 和 vp_ellipse.csv）
nonellipse_vsv = readmatrix('../../degree_90_horizontal_incident/vsv_polygonal.csv');
ellipse_vsv = readmatrix('../../degree_90_horizontal_incident/vsv_ellipse.csv');


%% 拟合主程序
cycle = 6;
params_nonellipse = zeros(cycle, 4);
resnorm_nonellipse = zeros(cycle, 1);
params_ellipse = zeros(cycle, 4);
resnorm_ellipse = zeros(cycle, 1);

model_func = @(params, P) params(1) + params(2)*P - params(3)*exp(-P*params(4));

initialParams = [1000, 1e-14, 384, 0.04];
lb = [0, 1e-14, 0, 0]; ub = [1e4, 1e-14, 1000, 10];
opts = optimset('Display', 'off', ...
                'MaxIter', 10000, ...
                'MaxFunEvals', 10000, ...
                'TolFun', 1e-8, ...
                'TolX', 1e-8);

% 非椭圆数据拟合
for i = 1:cycle
    vp = nonellipse_vsv(:, i);
    try
        [params, resnorm] = lsqcurvefit(@(params, P) model_func(params, P), initialParams, P, vp, lb, ub, opts);
        params_nonellipse(i, :) = params;
        resnorm_nonellipse(i) = resnorm;
    catch
        params_nonellipse(i, :) = initialParams;
        resnorm_nonellipse(i) = inf;
    end
end

% 椭圆数据拟合
for i = 1:cycle
    vp = ellipse_vsv(:, i);
    try
        [params, resnorm] = lsqcurvefit(@(params, P) model_func(params, P), initialParams, P, vp, lb, ub, opts);
        params_ellipse(i, :) = params;
        resnorm_ellipse(i) = resnorm;
    catch
        params_ellipse(i, :) = initialParams;
        resnorm_ellipse(i) = inf;
    end
end

%% 输出拟合参数数组到终端
fprintf('\n========== 拟合参数数组 ==========\n');
fprintf('非椭圆参数（按数组索引顺序）:\n');
A_nonellipse_arr = params_nonellipse(:,1)';
K_nonellipse_arr = params_nonellipse(:,2)';
B_nonellipse_arr = params_nonellipse(:,3)';
D_nonellipse_arr = params_nonellipse(:,4)';
fprintf('A_nonellipse = %s;\n', mat2str(A_nonellipse_arr, 6));
fprintf('K_nonellipse = %s;\n', mat2str(K_nonellipse_arr, 6));
fprintf('B_nonellipse = %s;\n', mat2str(B_nonellipse_arr, 6));
fprintf('D_nonellipse = %s;\n', mat2str(D_nonellipse_arr, 6));

fprintf('\n椭圆参数（按数组索引顺序）:\n');
A_ellipse_arr = params_ellipse(:,1)';
K_ellipse_arr = params_ellipse(:,2)';
B_ellipse_arr = params_ellipse(:,3)';
D_ellipse_arr = params_ellipse(:,4)';
fprintf('A_ellipse = %s;\n', mat2str(A_ellipse_arr, 6));
fprintf('K_ellipse = %s;\n', mat2str(K_ellipse_arr, 6));
fprintf('B_ellipse = %s;\n', mat2str(B_ellipse_arr, 6));
fprintf('D_ellipse = %s;\n', mat2str(D_ellipse_arr, 6));

%% Plot 1: Fitting Results Display
titles = {'20AR1','16AR1+4AR2','12AR1+8AR2','8AR1+12AR2','4AR1+16AR2','20AR2'};
indices = [1,5,4,3,2,6]; % Matlab索引，从1开始
figure('Position', [100 100 1200 700]);
for group = 1:cycle
    subplot(2,3,group);
    idx = indices(group);
    nonellipse_data = nonellipse_vsv(:, idx);
    nonellipse_fit = model_func(params_nonellipse(idx,:), P);
    ellipse_data = ellipse_vsv(:, idx);
    ellipse_fit = model_func(params_ellipse(idx,:), P);
    hold on;
    scatter(P(1:3:end), nonellipse_data(1:3:end), 18, 'r', 'filled', 'o','DisplayName','Non-ellipse Data');
    plot(P, nonellipse_fit, 'r-', 'LineWidth', 1.5, 'DisplayName','Non-ellipse Fitting');
    scatter(P(1:3:end), ellipse_data(1:3:end), 18, 'b', 'filled', 's','DisplayName','Ellipse Data');
    plot(P, ellipse_fit, 'b-', 'LineWidth', 1.5, 'DisplayName','Ellipse Fitting');
    legend('show','FontSize',8,'Location','southeast');
    % parameter annotation
    nonellipse_txt = sprintf('Non-ellipse:\nA=%.2f\nK=%.4g\nB=%.2f\nD=%.5g', params_nonellipse(idx,1), params_nonellipse(idx,2), params_nonellipse(idx,3), params_nonellipse(idx,4));
    ellipse_txt    = sprintf('Ellipse:\nA=%.2f\nK=%.4g\nB=%.2f\nD=%.5g', params_ellipse(idx,1), params_ellipse(idx,2), params_ellipse(idx,3), params_ellipse(idx,4));
    text('String',nonellipse_txt,'Units','normalized','Position',[0.02, 0.98], ...
        'VerticalAlignment','top','FontSize',7,'BackgroundColor',[1 0.8 0.8],'Margin',2,'EdgeColor','k','Color','k');
    text('String',ellipse_txt,'Units','normalized','Position',[0.98, 0.98], ...
        'VerticalAlignment','top','HorizontalAlignment','right','FontSize',7, ...
        'BackgroundColor',[0.8 0.9 1],'Margin',2,'EdgeColor','k','Color','k');
    xlabel('Uniaxial Stress (MPa)'); ylabel('v_s_v (m/s)');
    title(titles{group});
    grid on;
end
sgtitle('Vsv Fitting Results');

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
plot(params_nonellipse(indices,4),'co','MarkerSize',8,'MarkerFaceColor','c'); hold on;
plot(params_ellipse(indices,4),'ro','MarkerSize',8,'MarkerFaceColor','r');
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
    y_fit = model_func(params_nonellipse(idx,:), P);
    SS_res = sum((y - y_fit).^2);
    SS_tot = sum((y - mean(y)).^2);
    if SS_tot > 0
        nonellipse_r2(i) = 1 - SS_res/SS_tot;
    else
        nonellipse_r2(i) = 0;
    end
    y2 = ellipse_vsv(:, idx);
    y2_fit = model_func(params_ellipse(idx,:), P);
    SS_res2 = sum((y2 - y2_fit).^2);
    SS_tot2 = sum((y2 - mean(y2)).^2);
    if SS_tot2 > 0
        ellipse_r2(i) = 1 - SS_res2/SS_tot2;
    else
        ellipse_r2(i) = 0;
    end
end

%% 保存结果到txt文件
reportName = "vsv_fit_results_" + string(datetime('now'),'yyyyMMdd_HHmmss') + ".txt";
fid = fopen(reportName,'w','n','UTF-8');
fprintf(fid,'%s\n', repmat('=',1,80));
fprintf(fid,'应力-波速拟合结果报告\n');
fprintf(fid,'生成时间: %s\n', string(datetime('now'),'yyyy-MM-dd HH:mm:ss'));
% 插入公式说明
fprintf(fid,'残差平方和(SSR)公式: SSR = ∑(y_i - 预测值_i)^2\n');
fprintf(fid,'判定系数(R²)公式: R² = 1 - SSR/SST, 其中 SST = ∑(y_i - mean(y))^2\n');
fprintf(fid,'其中 y_i 为观测值，预测值_i 为拟合值。\n');
fprintf(fid,'说明: 残差平方和(SSR)衡量拟合误差大小，越小说明拟合越好；判定系数(R²)反映拟合优度，越接近1表示拟合效果越佳。\n');
fprintf(fid,'拟合公式: V(P) = A + K*P - B*exp(-P*D)\n');
fprintf(fid,'%s\n\n', repmat('=',1,80));

fprintf(fid,'非椭圆数据拟合结果\n--------------------------------------------------\n');
for i = 1:cycle
    idx = indices(i);
    fprintf(fid,'组 %d (%s) - 数据索引: %d\n', i, titles{i}, idx);
    fprintf(fid,'  拟合参数:\n');
    fprintf(fid,'    A = %g\n', params_nonellipse(idx,1));
    fprintf(fid,'    K = %g\n', params_nonellipse(idx,2));
    fprintf(fid,'    B = %g\n', params_nonellipse(idx,3));
    fprintf(fid,'    D = %g\n', params_nonellipse(idx,4));
    fprintf(fid,'  残差平方和 = %g\n', resnorm_nonellipse(idx));
    fprintf(fid,'  R² = %g\n\n', nonellipse_r2(i));
end
fprintf(fid,'椭圆数据拟合结果\n--------------------------------------------------\n');
for i = 1:cycle
    idx = indices(i);
    fprintf(fid,'组 %d (%s) - 数据索引: %d\n', i, titles{i}, idx);
    fprintf(fid,'  拟合参数:\n');
    fprintf(fid,'    A = %g\n', params_ellipse(idx,1));
    fprintf(fid,'    K = %g\n', params_ellipse(idx,2));
    fprintf(fid,'    B = %g\n', params_ellipse(idx,3));
    fprintf(fid,'    D = %g\n', params_ellipse(idx,4));
    fprintf(fid,'  残差平方和 = %g\n', resnorm_ellipse(idx));
    fprintf(fid,'  R² = %g\n\n', ellipse_r2(i));
end
fprintf(fid,'非椭圆与椭圆数据对比分析\n--------------------------------------------------\n');
for i = 1:cycle
    fprintf(fid,'组 %d (%s):\n', i, titles{i});
    fprintf(fid,'  非椭圆 R² = %g\n', nonellipse_r2(i));
    fprintf(fid,'  椭圆 R² = %g\n', ellipse_r2(i));
    fprintf(fid,'  R²差异 = %g\n', abs(nonellipse_r2(i)-ellipse_r2(i)));
    if nonellipse_r2(i) > ellipse_r2(i)
        fprintf(fid,'  非椭圆拟合效果更好\n\n');
    elseif ellipse_r2(i) > nonellipse_r2(i)
        fprintf(fid,'  椭圆拟合效果更好\n\n');
    else
        fprintf(fid,'  两种数据拟合效果相当\n\n');
    end
end
fprintf(fid,'统计摘要\n--------------------------------------------------\n');
fprintf(fid,'非椭圆数据平均R²: %g\n', mean(nonellipse_r2));
fprintf(fid,'椭圆数据平均R²: %g\n', mean(ellipse_r2));
fprintf(fid,'非椭圆数据R²标准差: %g\n', std(nonellipse_r2));
fprintf(fid,'椭圆数据R²标准差: %g\n', std(ellipse_r2));
fprintf(fid,'非椭圆数据平均残差平方和: %g\n', mean(resnorm_nonellipse));
fprintf(fid,'椭圆数据平均残差平方和: %g\n', mean(resnorm_ellipse));
fprintf(fid,'\n%s\n报告结束\n', repmat('=',1,80));
fclose(fid);
disp(["拟合结果已保存到文件: " reportName]);
