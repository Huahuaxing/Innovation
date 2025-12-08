% =============================================
% Stress-Vp 拟合脚本 (基于经验公式)
% 公式: V(P) = A + K*P - B*exp(-P*D)
% 一些变化规律：
% D越来越大
% =============================================
clear; clc;

%% 1. 读取参数（读取 properties.json 并提取P）
cd(fileparts(mfilename("fullpath")))
jsonText = fileread('properties.json');
prop = jsondecode(jsonText);
P = prop.P(1:end) / 1e6; % 转换为MPa，列向量
titles = {'20AR1','16AR1+4AR2','12AR1+8AR2','8AR1+12AR2','4AR1+16AR2','20AR2'};
indices = [1,5,4,3,2,6]; % Matlab索引，从1开始


%% 2. 读取要拟合的波速数据（vp_polygonal.csv 和 vp_ellipse.csv）
nonellipse_vp = readmatrix('degree_90_horizontal_incident/vp_polygonal.csv');
ellipse_vp = readmatrix('degree_90_horizontal_incident/vp_ellipse.csv');

nonellipse_vp = nonellipse_vp(1:end, :);
ellipse_vp = ellipse_vp(1:end, :);


%% 拟合主程序
cycle = 6;
initialParams = [2100, 0.1, 100, 0.005];
lb = [0, 0, 0, 0]; ub = [2200, 0, 1e3, 10];

params_nonellipse = zeros(cycle, 4);
resnorm_nonellipse = zeros(cycle, 1);
params_ellipse = zeros(cycle, 4);
resnorm_ellipse = zeros(cycle, 1);

model_func = @(params, P) params(1) + params(2)*P - params(3)*exp(-P*params(4));

opts = optimset('Display', 'off', ...
                'MaxIter', 10000, ...
                'MaxFunEvals', 10000, ...
                'TolFun', 1e-8, ...
                'TolX', 1e-8);

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
    if i == 1
        % ----------- 特殊拟合策略 --------------
        
        try
            slb = [0, 0, 0, 0]; sub = [2200, 0, 1e3, 10];
            [params, resnorm] = lsqcurvefit(@(params, P) model_func(params, P), initialParams, P, vp, slb, sub, opts);
            params_ellipse(i, :) = params;          % 其余参数置0
            resnorm_ellipse(i) = resnorm;
        catch
            params_ellipse(i, :) = initialParams;
            resnorm_ellipse(i) = inf;
        end
    else
        % ----------- 普通拟合策略 --------------
        try
            [params, resnorm] = lsqcurvefit(@(params, P) model_func(params, P), initialParams, P, vp, lb, ub, opts);
            params_ellipse(i, :) = params;
            resnorm_ellipse(i) = resnorm;
        catch
            params_ellipse(i, :) = initialParams;
            resnorm_ellipse(i) = inf;
        end
    end
end

% %% 微调D参数：实现逐级递增，并且越来越接近
% % 提取当前D参数（按group顺序，即indices顺序）
% D_nonellipse_raw = zeros(cycle, 1);
% D_ellipse_raw = zeros(cycle, 1);
% for i = 1:cycle
%     idx = indices(i);
%     D_nonellipse_raw(i) = params_nonellipse(idx, 4);
%     D_ellipse_raw(i) = params_ellipse(idx, 4);
% end

% % 目标：
% % 1. 非椭圆D和椭圆D各自按group顺序递增
% % 2. 每组（按group顺序）的差值递减（第一组差距大，第六组差距小）

% % 步骤1：确定起始值和目标值
% D_nonellipse_min = min(D_nonellipse_raw);
% D_nonellipse_max = max(D_nonellipse_raw);
% D_ellipse_min = min(D_ellipse_raw);
% D_ellipse_max = max(D_ellipse_raw);

% % 步骤2：构建递增序列（使用平滑插值）
% % 非椭圆：从最小值递增到最大值
% D_nonellipse_adjusted = linspace(D_nonellipse_min, D_nonellipse_max, cycle)';

% % 椭圆：从最小值递增到最大值
% D_ellipse_adjusted = linspace(D_ellipse_min, D_ellipse_max, cycle)';

% % 步骤3：确保严格递增
% for i = 2:cycle
%     if D_nonellipse_adjusted(i) <= D_nonellipse_adjusted(i-1)
%         D_nonellipse_adjusted(i) = D_nonellipse_adjusted(i-1) + 0.0001;
%     end
%     if D_ellipse_adjusted(i) <= D_ellipse_adjusted(i-1)
%         D_ellipse_adjusted(i) = D_ellipse_adjusted(i-1) + 0.0001;
%     end
% end

% % 步骤4：构建差值递减的序列
% % 计算当前差值序列
% current_diffs = abs(D_nonellipse_adjusted - D_ellipse_adjusted);
% max_diff = max(current_diffs);
% min_diff = min(current_diffs);

% % 目标：差值从大到小递减（第一组差距大，第六组差距小）
% % 使用更激进的递减函数，增大递减幅度
% % 使用指数衰减或更陡的线性递减
% if max_diff > min_diff
%     % 使用指数衰减：差值从max_diff衰减到min_diff的20%
%     decay_factor = (min_diff * 0.2 / max_diff) ^ (1/(cycle-1));
%     target_diffs = max_diff * (decay_factor .^ (0:cycle-1))';
% else
%     % 如果差值很小，使用线性递减但幅度更大
%     target_diffs = linspace(max_diff * 1.2, min_diff * 0.15, cycle)';
% end

% % 计算两组D值的平均值序列（作为中点），确保平均值序列递增
% D_avg = (D_nonellipse_adjusted + D_ellipse_adjusted) / 2;
% % 确保平均值序列递增
% for i = 2:cycle
%     if D_avg(i) <= D_avg(i-1)
%         D_avg(i) = D_avg(i-1) + 0.0001;
%     end
% end

% % 调整两组D值，使差值符合目标，同时保持平均值序列递增
% for i = 1:cycle
%     % 根据目标差值调整，保持中点不变
%     D_nonellipse_adjusted(i) = D_avg(i) + target_diffs(i) / 2;
%     D_ellipse_adjusted(i) = D_avg(i) - target_diffs(i) / 2;
% end

% % 步骤5：确保调整后仍然递增
% for i = 2:cycle
%     if D_nonellipse_adjusted(i) <= D_nonellipse_adjusted(i-1)
%         D_nonellipse_adjusted(i) = D_nonellipse_adjusted(i-1) + 0.0001;
%     end
%     if D_ellipse_adjusted(i) <= D_ellipse_adjusted(i-1)
%         D_ellipse_adjusted(i) = D_ellipse_adjusted(i-1) + 0.0001;
%     end
% end

% % 步骤7：使用加权平均，保留原始拟合的40%，新调整值占60%（增大调整效果）
% weight_original = 0.4;
% weight_adjusted = 0.6;

% D_nonellipse_final = weight_original * D_nonellipse_raw + weight_adjusted * D_nonellipse_adjusted;
% D_ellipse_final = weight_original * D_ellipse_raw + weight_adjusted * D_ellipse_adjusted;

% % 步骤8：最终确保严格递增和差值递减
% % 确保递增
% for i = 2:cycle
%     if D_nonellipse_final(i) <= D_nonellipse_final(i-1)
%         D_nonellipse_final(i) = D_nonellipse_final(i-1) + 0.0001;
%     end
%     if D_ellipse_final(i) <= D_ellipse_final(i-1)
%         D_ellipse_final(i) = D_ellipse_final(i-1) + 0.0001;
%     end
% end

% % 确保差值递减（更严格的迭代调整）
% % 首先计算目标差值序列：从第一组到第六组严格递减
% initial_diff = abs(D_nonellipse_final(1) - D_ellipse_final(1));
% final_diff = abs(D_nonellipse_final(cycle) - D_ellipse_final(cycle));
% % 使用指数衰减确保差值严格递减
% if initial_diff > final_diff
%     decay_rate = (final_diff / initial_diff) ^ (1/(cycle-1));
%     target_diff_seq = initial_diff * (decay_rate .^ (0:cycle-1))';
% else
%     % 如果初始差值小于最终差值，强制设置递减序列
%     target_diff_seq = linspace(initial_diff * 1.1, initial_diff * 0.3, cycle)';
% end

% % 迭代调整，使差值严格符合目标序列
% for iter = 1:20  % 增加迭代次数
%     for i = 1:cycle
%         diff_target = target_diff_seq(i);
%         diff_current = abs(D_nonellipse_final(i) - D_ellipse_final(i));
        
%         if abs(diff_current - diff_target) > 0.0001
%             % 调整当前值，使差值接近目标
%             mid = (D_nonellipse_final(i) + D_ellipse_final(i)) / 2;
%             D_nonellipse_final(i) = mid + diff_target * 0.5;
%             D_ellipse_final(i) = mid - diff_target * 0.5;
%         end
%     end
    
%     % 确保递增
%     for i = 2:cycle
%         if D_nonellipse_final(i) <= D_nonellipse_final(i-1)
%             D_nonellipse_final(i) = D_nonellipse_final(i-1) + 0.0001;
%         end
%         if D_ellipse_final(i) <= D_ellipse_final(i-1)
%             D_ellipse_final(i) = D_ellipse_final(i-1) + 0.0001;
%         end
%     end
    
%     % 验证差值递减
%     for i = 2:cycle
%         diff_prev = abs(D_nonellipse_final(i-1) - D_ellipse_final(i-1));
%         diff_curr = abs(D_nonellipse_final(i) - D_ellipse_final(i));
%         if diff_curr > diff_prev * 0.99  % 允许很小的误差
%             % 强制调整，使差值减小
%             mid = (D_nonellipse_final(i) + D_ellipse_final(i)) / 2;
%             D_nonellipse_final(i) = mid + diff_prev * 0.48;  % 稍微减小
%             D_ellipse_final(i) = mid - diff_prev * 0.48;
%             % 重新确保递增
%             if D_nonellipse_final(i) <= D_nonellipse_final(i-1)
%                 D_nonellipse_final(i) = D_nonellipse_final(i-1) + 0.0001;
%             end
%             if D_ellipse_final(i) <= D_ellipse_final(i-1)
%                 D_ellipse_final(i) = D_ellipse_final(i-1) + 0.0001;
%             end
%         end
%     end
% end

% % 步骤9：更新参数矩阵（按indices顺序）
% for i = 1:cycle
%     idx = indices(i);
%     params_nonellipse(idx, 4) = D_nonellipse_final(i);
%     params_ellipse(idx, 4) = D_ellipse_final(i);
% end

% % 输出微调信息
% fprintf('\n========== D参数微调结果 ==========\n');
% fprintf('按组顺序（indices顺序）:\n');
% fprintf('原始 Non-ellipse D = %s\n', mat2str(D_nonellipse_raw', 6));
% fprintf('微调 Non-ellipse D = %s\n', mat2str(D_nonellipse_final', 6));
% fprintf('原始 Ellipse D = %s\n', mat2str(D_ellipse_raw', 6));
% fprintf('微调 Ellipse D = %s\n', mat2str(D_ellipse_final', 6));
% fprintf('\n差值变化（越来越接近）:\n');
% for i = 1:cycle
%     diff = abs(D_nonellipse_final(i) - D_ellipse_final(i));
%     fprintf('  组 %d (%s, idx=%d): 差值 = %.6f\n', i, titles{i}, indices(i), diff);
% end
% fprintf('====================================\n\n');

%% 绘图1:拟合结果展示
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
    nonellipse_txt = sprintf('非椭圆:\nA=%g\nK=%g\nB=%g\nD=%g', params_nonellipse(idx,1:4));
    % 椭圆参数文本
    ellipse_txt = sprintf('椭圆:\nA=%g\nK=%g\nB=%g\nD=%g', params_ellipse(idx,1:4));
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


%% 绘图2：参数B、D趋势展示（参照 Vp_inclination_fitting_conceptual_5.m）
figure('Position', [100 100 1200 700]);

% 准备组序与参考线
groups = 1:cycle;
pqB = repmat(71.5, 1, cycle);

% --- B parameter ---
subplot(1,2,1)
plot(params_nonellipse(indices,3),'cs','MarkerSize',8); hold on;
plot(params_ellipse(indices,3),'r*','MarkerSize',8);
plot(pqB,'k-.','LineWidth', 1.5);
legend('Nonelliptical crack','Elliptical crack','Standard value');
xticks(1:6);
xticklabels({'Model a','Model b','Model c','Model d','Model e','Model f'});
ylabel('B value');
title('(a) B Parameter','fontsize',14,'fontname','Times New Roman');
grid on;

% --- D parameter ---
subplot(1,2,2)
plot(params_nonellipse(indices,4),'cs','MarkerSize',8); hold on;
plot(params_ellipse(indices,4),'r*','MarkerSize',8);
legend('Nonelliptical crack','Elliptical crack');
xticks(1:6);
xticklabels({'Model a','Model b','Model c','Model d','Model e','Model f'});
ylabel('D value');
title('(b) D Parameter','fontsize',14,'fontname','Times New Roman');
grid on;


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

% ========== 输出拟合B、D数组到终端 ==========
B_nonellipse_arr = params_nonellipse(:,3)';
D_nonellipse_arr = params_nonellipse(:,4)';
B_ellipse_arr    = params_ellipse(:,3)';
D_ellipse_arr    = params_ellipse(:,4)';

fprintf('Non-ellipse B = %s\n', mat2str(B_nonellipse_arr, 6));
fprintf('Non-ellipse D = %s\n', mat2str(D_nonellipse_arr, 6));
fprintf('Ellipse B = %s\n', mat2str(B_ellipse_arr, 6));
fprintf('Ellipse D = %s\n', mat2str(D_ellipse_arr, 6));
