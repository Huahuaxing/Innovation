% =============================================
% Stress-Vp 拟合脚本 (基于经验公式)
% 公式: V(P) = A + K*P - B*exp(-P*D)
% =============================================

clear; clc;

%% 1. 读取参数（读取 properties.json 并提取P）
cd(fileparts(mfilename("fullpath")))
jsonText = fileread('properties.json');
prop = jsondecode(jsonText);
P = prop.P(:) / 1e6; % 转换为MPa，列向量

%% 2. 读取数据（vp_polygonal.csv 和 vp_ellipse.csv）
nonellipse_vp = readmatrix('degree_90_horizontal_incident/vp_polygonal.csv');
ellipse_vp = readmatrix('degree_90_horizontal_incident/vp_ellipse.csv');

cycle = 6;
initialParams = [2071, 0.9, 66, 0.1];
lb = [0, 0, 0, 0]; ub = [1e6, 1e3, 1e6, 1e3];

params_nonellipse = zeros(cycle, 4);
resnorm_nonellipse = zeros(cycle, 1);
params_ellipse = zeros(cycle, 4);
resnorm_ellipse = zeros(cycle, 1);

model_func = @(params, P) params(1) + params(2)*P - params(3)*exp(-P*params(4));

opts = optimset('Display','off');

% 3. 非椭圆数据拟合
for i = 1:cycle
    vp = nonellipse_vp(:, i);
    try
        [params, resnorm] = lsqcurvefit(@(params, P) model_func(params, P), initialParams, P, vp, lb, ub, opts);
        params_nonellipse(i, :) = params;
        resnorm_nonellipse(i) = resnorm;
    catch
        params_nonellipse(i, :) = initialParams;
        resnorm_nonellipse(i) = inf;
    end
end

% 4. 椭圆数据拟合
for i = 1:cycle
    vp = ellipse_vp(:, i);
    try
        [params, resnorm] = lsqcurvefit(@(params, P) model_func(params, P), initialParams, P, vp, lb, ub, opts);
        params_ellipse(i, :) = params;
        resnorm_ellipse(i) = resnorm;
    catch
        params_ellipse(i, :) = initialParams;
        resnorm_ellipse(i) = inf;
    end
end

%% 绘图设置
titles = {'20AR1','16AR1+4AR2','12AR1+8AR2','8AR1+12AR2','4AR1+16AR2','20AR2'};
indices = [1,5,4,3,2,6]; % Matlab索引，从1开始
figure('Position', [100 100 1200 700]);
for group = 1:cycle
    subplot(2,3,group);
    idx = indices(group);
    nonellipse_data = nonellipse_vp(:, idx);
    nonellipse_fit = model_func(params_nonellipse(idx,:), P);
    ellipse_data = ellipse_vp(:, idx);
    ellipse_fit = model_func(params_ellipse(idx,:), P);
    hold on;
    scatter(P(1:3:end), nonellipse_data(1:3:end), 18, 'r', 'filled', 'o','DisplayName','非椭圆数据');
    plot(P, nonellipse_fit, 'r-', 'LineWidth', 1.5, 'DisplayName','非椭圆拟合');
    scatter(P(1:3:end), ellipse_data(1:3:end), 18, 'b', 'filled', 's','DisplayName','椭圆数据');
    plot(P, ellipse_fit, 'b-', 'LineWidth', 1.5, 'DisplayName','椭圆拟合');
    legend('show','FontSize',8,'Location','southeast');
    % 非椭圆参数文本
    nonellipse_txt = sprintf('非椭圆:\nA=%.2f\nK=%.2f\nB=%.2f\nD=%.2f', params_nonellipse(idx,1:4));
    % 椭圆参数文本
    ellipse_txt = sprintf('椭圆:\nA=%.2f\nK=%.2f\nB=%.2f\nD=%.2f', params_ellipse(idx,1:4));
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
    xlabel('Uniaxial Stress (MPa)'); ylabel('v_p (m/s)');
    title(titles{group});
    grid on;
end
sgtitle('非椭圆与椭圆数据 Stress-Vp 拟合结果对比');

%% 计算R²
nonellipse_r2 = zeros(cycle,1);
ellipse_r2 = zeros(cycle,1);
for i = 1:cycle
    idx = indices(i);
    y = nonellipse_vp(:, idx);
    y_fit = model_func(params_nonellipse(idx,:), P);
    SS_res = sum((y - y_fit).^2);
    SS_tot = sum((y - mean(y)).^2);
    if SS_tot > 0
        nonellipse_r2(i) = 1 - SS_res/SS_tot;
    else
        nonellipse_r2(i) = 0;
    end
    y2 = ellipse_vp(:, idx);
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
reportName = "fit_results_" + string(datetime('now'),'yyyyMMdd_HHmmss') + ".txt";
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
    fprintf(fid,'    A = %.6f\n', params_nonellipse(idx,1));
    fprintf(fid,'    K = %.6f\n', params_nonellipse(idx,2));
    fprintf(fid,'    B = %.6f\n', params_nonellipse(idx,3));
    fprintf(fid,'    D = %.6f\n', params_nonellipse(idx,4));
    fprintf(fid,'  残差平方和 = %.6f\n', resnorm_nonellipse(idx));
    fprintf(fid,'  R² = %.6f\n\n', nonellipse_r2(i));
end
fprintf(fid,'椭圆数据拟合结果\n--------------------------------------------------\n');
for i = 1:cycle
    idx = indices(i);
    fprintf(fid,'组 %d (%s) - 数据索引: %d\n', i, titles{i}, idx);
    fprintf(fid,'  拟合参数:\n');
    fprintf(fid,'    A = %.6f\n', params_ellipse(idx,1));
    fprintf(fid,'    K = %.6f\n', params_ellipse(idx,2));
    fprintf(fid,'    B = %.6f\n', params_ellipse(idx,3));
    fprintf(fid,'    D = %.6f\n', params_ellipse(idx,4));
    fprintf(fid,'  残差平方和 = %.6f\n', resnorm_ellipse(idx));
    fprintf(fid,'  R² = %.6f\n\n', ellipse_r2(i));
end
fprintf(fid,'非椭圆与椭圆数据对比分析\n--------------------------------------------------\n');
for i = 1:cycle
    fprintf(fid,'组 %d (%s):\n', i, titles{i});
    fprintf(fid,'  非椭圆 R² = %.6f\n', nonellipse_r2(i));
    fprintf(fid,'  椭圆 R² = %.6f\n', ellipse_r2(i));
    fprintf(fid,'  R²差异 = %.6f\n', abs(nonellipse_r2(i)-ellipse_r2(i)));
    if nonellipse_r2(i) > ellipse_r2(i)
        fprintf(fid,'  非椭圆拟合效果更好\n\n');
    elseif ellipse_r2(i) > nonellipse_r2(i)
        fprintf(fid,'  椭圆拟合效果更好\n\n');
    else
        fprintf(fid,'  两种数据拟合效果相当\n\n');
    end
end
fprintf(fid,'统计摘要\n--------------------------------------------------\n');
fprintf(fid,'非椭圆数据平均R²: %.6f\n', mean(nonellipse_r2));
fprintf(fid,'椭圆数据平均R²: %.6f\n', mean(ellipse_r2));
fprintf(fid,'非椭圆数据R²标准差: %.6f\n', std(nonellipse_r2));
fprintf(fid,'椭圆数据R²标准差: %.6f\n', std(ellipse_r2));
fprintf(fid,'非椭圆数据平均残差平方和: %.6f\n', mean(resnorm_nonellipse));
fprintf(fid,'椭圆数据平均残差平方和: %.6f\n', mean(resnorm_ellipse));
fprintf(fid,'\n%s\n报告结束\n', repmat('=',1,80));
fclose(fid);
disp(["拟合结果已保存到文件: " reportName]);
