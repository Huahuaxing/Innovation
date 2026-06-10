% =============================================
% Stress-Vsv 仅拟合A脚本 (K、B、D指定)
% 公式: V(P) = A + K*P - B*exp(-P*D)
% =============================================
clear; clc;
cd(fileparts(mfilename("fullpath")))
jsonText = fileread('properties.json');
prop = jsondecode(jsonText);
P = prop.P(:) / 1e6; % 转换为MPa

% ========== 手动输入每组的K、B、D ==========
K_nonellipse = [1e-14 1e-14 1e-14 1e-14 1e-14 1e-14];
B_nonellipse = [429.117 393.609 395.841 408.311 418.579 384.458];
D_nonellipse = [0.0490947 0.089818 0.0762845 0.0649845 0.0626347 0.113366];
K_ellipse = [1e-14 1e-14 1e-14 1e-14 1e-14 1e-14];
B_ellipse = [461.247 417.344 428.604 443.942 453.472 392.331];
D_ellipse = [0.0242592 0.0688024 0.0478691 0.0354174 0.0340777 0.108033];

cycle = 6;
nonellipse_vsv = readmatrix('degree_90_horizontal_incident/vsv_polygonal.csv');
ellipse_vsv = readmatrix('degree_90_horizontal_incident/vsv_ellipse.csv');

params_nonellipse = zeros(cycle, 1); % 只拟合A
resnorm_nonellipse = zeros(cycle, 1);
params_ellipse = zeros(cycle, 1);
resnorm_ellipse = zeros(cycle, 1);

model_func = @(A, K, B, D, P) A + K*P - B*exp(-P*D);
opts = optimset('Display', 'off', ...
                'MaxIter', 10000, ...
                'MaxFunEvals', 10000, ...
                'TolFun', 1e-8, ...
                'TolX', 1e-8);

for i = 1:cycle
    vsv = nonellipse_vsv(:, i);
    K = K_nonellipse(i); B = B_nonellipse(i); D = D_nonellipse(i);
    fit_func = @(A, P) model_func(A, K, B, D, P);
    initialA = 1200; lba = 500; uba = 1600;
    try
        [A_fit, resnorm] = lsqcurvefit(fit_func, initialA, P, vsv, lba, uba, opts);
        params_nonellipse(i) = A_fit;
        resnorm_nonellipse(i) = resnorm;
    catch
        params_nonellipse(i) = initialA;
        resnorm_nonellipse(i) = inf;
    end
end

for i = 1:cycle
    vsv = ellipse_vsv(:, i);
    K = K_ellipse(i); B = B_ellipse(i); D = D_ellipse(i);
    fit_func = @(A, P) model_func(A, K, B, D, P);
    initialA = 1200; lba = 500; uba = 1600;
    try
        [A_fit, resnorm] = lsqcurvefit(fit_func, initialA, P, vsv, lba, uba, opts);
        params_ellipse(i) = A_fit;
        resnorm_ellipse(i) = resnorm;
    catch
        params_ellipse(i) = initialA;
        resnorm_ellipse(i) = inf;
    end
end

%% Plot 1: Fitting Results Display
titles = {'20AR1','16AR1+4AR2','12AR1+8AR2','8AR1+12AR2','4AR1+16AR2','20AR2'};
indices = [1,5,4,3,2,6]; % Matlab索引，从1开始
figure('Position', [100 100 1200 700]);
for group = 1:cycle
    subplot(2,3,group);
    idx = indices(group);
    % Non-ellipse
    A = params_nonellipse(idx); K = K_nonellipse(idx); B = B_nonellipse(idx); D = D_nonellipse(idx);
    nonellipse_data = nonellipse_vsv(:, idx);
    nonellipse_fit = A + K*P - B*exp(-P*D);
    % Ellipse
    A2 = params_ellipse(idx); K2 = K_ellipse(idx); B2 = B_ellipse(idx); D2 = D_ellipse(idx);
    ellipse_data = ellipse_vsv(:, idx);
    ellipse_fit = A2 + K2*P - B2*exp(-P*D2);
    hold on;
    scatter(P(1:3:end), nonellipse_data(1:3:end), 18, 'r', 'filled', 'o','DisplayName','Non-ellipse Data');
    plot(P, nonellipse_fit, 'r-', 'LineWidth', 1.5, 'DisplayName','Non-ellipse Fitting');
    scatter(P(1:3:end), ellipse_data(1:3:end), 18, 'b', 'filled', 's','DisplayName','Ellipse Data');
    plot(P, ellipse_fit, 'b-', 'LineWidth', 1.5, 'DisplayName','Ellipse Fitting');
    legend('show','FontSize',8,'Location','southeast');
    % parameter annotation
    nonellipse_txt = sprintf('Non-ellipse:\nA=%.2f\nK=%.4g\nB=%.2f\nD=%.5g', A, K, B, D);
    ellipse_txt    = sprintf('Ellipse:\nA=%.2f\nK=%.4g\nB=%.2f\nD=%.5g', A2, K2, B2, D2);
    text('String',nonellipse_txt,'Units','normalized','Position',[0.02, 0.98], ...
        'VerticalAlignment','top','FontSize',7,'BackgroundColor',[1 0.8 0.8],'Margin',2,'EdgeColor','k','Color','k');
    text('String',ellipse_txt,'Units','normalized','Position',[0.98, 0.98], ...
        'VerticalAlignment','top','HorizontalAlignment','right','FontSize',7, ...
        'BackgroundColor',[0.8 0.9 1],'Margin',2,'EdgeColor','k','Color','k');
    xlabel('Uniaxial Stress (MPa)'); ylabel('v_{sv} (m/s)');
    title(titles{group});
    grid on;
end
sgtitle('Vsv Fitting Results');

%% Plot 2: Trends of Four Parameters (A, K, B, D)
figure('Name','Parameter Trends','Position',[100 100 1500 900]);
% --- A parameter ---
subplot(2,2,1)
plot(params_nonellipse(indices),'co','MarkerSize',8,'MarkerFaceColor','c'); hold on;
plot(params_ellipse(indices),'ro','MarkerSize',8,'MarkerFaceColor','r');
legend('Nonelliptical crack','Elliptical crack');
xticks(1:6);
xticklabels({'Model a','Model b','Model c','Model d','Model e','Model f'});
ylabel('A value');
title('(a) A Parameter','fontsize',14,'fontname','Times New Roman');
grid on;
% --- K parameter ---
subplot(2,2,2)
plot(K_nonellipse(indices),'co','MarkerSize',8,'MarkerFaceColor','c'); hold on;
plot(K_ellipse(indices),'ro','MarkerSize',8,'MarkerFaceColor','r');
legend('Nonelliptical crack','Elliptical crack');
xticks(1:6);
ylabel('K value');
xticklabels({'Model a','Model b','Model c','Model d','Model e','Model f'});
title('(b) K Parameter','fontsize',14,'fontname','Times New Roman');
grid on;
% --- B parameter ---
subplot(2,2,3)
plot(B_nonellipse(indices),'co','MarkerSize',8,'MarkerFaceColor','c'); hold on;
plot(B_ellipse(indices),'ro','MarkerSize',8,'MarkerFaceColor','r');
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
    K = K_nonellipse(idx); B = B_nonellipse(idx); D = D_nonellipse(idx); A = params_nonellipse(idx);
    y_fit = A + K*P - B*exp(-P*D);
    SS_res = sum((y - y_fit).^2);
    SS_tot = sum((y - mean(y)).^2);
    if SS_tot > 0
        nonellipse_r2(i) = 1 - SS_res/SS_tot;
    else
        nonellipse_r2(i) = 0;
    end
    y2 = ellipse_vsv(:, idx);
    K2 = K_ellipse(idx); B2 = B_ellipse(idx); D2 = D_ellipse(idx); A2 = params_ellipse(idx);
    y2_fit = A2 + K2*P - B2*exp(-P*D2);
    SS_res2 = sum((y2 - y2_fit).^2);
    SS_tot2 = sum((y2 - mean(y2)).^2);
    if SS_tot2 > 0
        ellipse_r2(i) = 1 - SS_res2/SS_tot2;
    else
        ellipse_r2(i) = 0;
    end
end

%% ========== 文件输出 ==========
reportName = "vsv_fit_results_KBDfixAfit_" + string(datetime('now'),'yyyyMMdd_HHmmss') + ".txt";
fid = fopen(reportName,'w','n','UTF-8');
fprintf(fid,'%s\n', repmat('=',1,80));
fprintf(fid,'应力-波速拟合结果报告 (指定K/B/D,仅A拟合)\n');
fprintf(fid,'生成时间: %s\n', string(datetime('now'),'yyyy-MM-dd HH:mm:ss'));
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
    fprintf(fid,'    A = %g\n', params_nonellipse(idx));
    fprintf(fid,'    K = %g\n', K_nonellipse(idx));
    fprintf(fid,'    B = %g\n', B_nonellipse(idx));
    fprintf(fid,'    D = %g\n', D_nonellipse(idx));
    fprintf(fid,'  残差平方和 = %g\n', resnorm_nonellipse(idx));
    fprintf(fid,'  R² = %g\n\n', nonellipse_r2(i));
end

fprintf(fid,'椭圆数据拟合结果\n--------------------------------------------------\n');
for i = 1:cycle
    idx = indices(i);
    fprintf(fid,'组 %d (%s) - 数据索引: %d\n', i, titles{i}, idx);
    fprintf(fid,'  拟合参数:\n');
    fprintf(fid,'    A = %g\n', params_ellipse(idx));
    fprintf(fid,'    K = %g\n', K_ellipse(idx));
    fprintf(fid,'    B = %g\n', B_ellipse(idx));
    fprintf(fid,'    D = %g\n', D_ellipse(idx));
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
disp(["参数结果已保存到文件: " reportName]);

% ========== 输出拟合A数组到终端 ==========
A_nonellipse_arr = params_nonellipse(:,1)';
A_ellipse_arr    = params_ellipse(:,1)';
fprintf('A_nonellipse = %s;\n', mat2str(A_nonellipse_arr, 6));
fprintf('A_ellipse = %s;\n', mat2str(A_ellipse_arr, 6));
