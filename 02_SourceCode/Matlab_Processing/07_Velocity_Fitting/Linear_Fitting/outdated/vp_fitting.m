% =============================================
% Stress-Vp 拟合脚本 (基于一次函数公式)
% 公式: V(P) = a * P + b
% =============================================
clear;
%% 数据初始化
cd(fileparts(mfilename("fullpath")));
prop = jsondecode(fileread("../../../../../06_ProcessedData/parameters.json"));
P = prop.P;   % 应力数组

groupNum = 6;

% 加载椭圆模型波速数据，(200,6)，只加载中间线性上升段波速数据用于拟合
vpEllipse = readmatrix('../../../../../06_ProcessedData/03_velocity/n_20_degree_0/vp/vp_ellipse.csv');
vpEllipseFitting = vpEllipse(16:50, :);
% 加载椭圆对齐模型波速数据
vpEllipseAligned = readmatrix('../../../../../06_ProcessedData/03_velocity/n_20_degree_0/vp/vp_ellipseAligned.csv');
vpEllipseAlignedFitting = vpEllipseAligned(16:50, :);
% 加载非椭圆模型波速数据
vpNonellipse = readmatrix('../../../../../06_ProcessedData/03_velocity/n_20_degree_0/vp/vp_nonellipse.csv');
vpNonellipseFitting = vpNonellipse(16:50, :);


%% 拟合主程序
opts = optimset('Display', 'off', ...
                'MaxIter', 10000, ...
                'MaxFunEvals', 10000, ...
                'TolFun', 1e-8, ...
                'TolX', 1e-8);
initialParams = [1 2000];
lb = [0, 0]; ub = [10, 1e4];

paramsEllipse = zeros(groupNum, length(initialParams));
resnormEllipse = zeros(groupNum, 1);
paramsEllipseAligned = zeros(groupNum, length(initialParams));
resnormEllipseAligned = zeros(groupNum, 1);
paramsNonellipse = zeros(groupNum, length(initialParams));
resnormNonellipse = zeros(groupNum, 1);

% Ellipse数据拟合
for g = 1:groupNum
    vp = vpEllipseFitting(:, g);
    [params, resnorm] = lsqcurvefit(@model_func, initialParams, P(16:50), vp, [], [], opts);
    paramsEllipse(g, :) = params;
    resnormEllipse(g) = resnorm;
end
% EllipseAligned数据拟合
for g = 1:groupNum
    vp = vpEllipseAlignedFitting(:, g);
    [params, resnorm] = lsqcurvefit(@model_func, initialParams, P(16:50), vp, [], [], opts);
    paramsEllipseAligned(g, :) = params;
    resnormEllipseAligned(g) = resnorm;
end
% Nonellipse
for g = 1:groupNum
    vp = vpNonellipseFitting(:, g);
    [params, resnorm] = lsqcurvefit(@model_func, initialParams, P(16:50), vp, [], [], opts);
    paramsNonellipse(g, :) = params;
    resnormNonellipse(g) = resnorm;
end

%% 打印拟合结果
fprintf('\n========== 拟合结果 ==========\n');

fprintf('Ellipse参数:\n');
aEllipse = paramsEllipse(:,1)';
bEllipse = paramsEllipse(:,2)';
fprintf('aEllipse = %s\n', mat2str(aEllipse, 4));
fprintf('bEllipse = %s\n', mat2str(bEllipse, 4));

fprintf('\nEllipseAligned参数:\n');
aEllipseAligned = paramsEllipseAligned(:,1)';
bEllipseAligned = paramsEllipseAligned(:,2)';
fprintf('aEllipseAligned = %s\n', mat2str(aEllipseAligned, 4));
fprintf('bEllipseAligned = %s\n', mat2str(bEllipseAligned, 4));

fprintf('\nNonellipse参数:\n');
aNonellipse = paramsNonellipse(:,1)';
bNonellipse = paramsNonellipse(:,2)';
fprintf('aNonellipse = %s\n', mat2str(aNonellipse, 4));
fprintf('bNonellipse = %s\n', mat2str(bNonellipse, 4));

fprintf('====================================\n\n');


%% 绘图区
% 波速图
modelParams = {'20AR1', '16AR1+4AR2', '12AR1+8AR2', '8AR1+12AR2', '4AR1+16AR2', '20AR2'};
subTitleList = {'(a)', '(b)', '(c)', '(d)', '(e)', '(f)'};
figure('Position', [100 100 2000 1000]);
sgtitle('Fitting Result', 'FontSize', 14, 'FontWeight','bold');
for g = 1:groupNum
    subplot(2,3,g);
    title(subTitleList{g});
    ellipse_data = vpEllipse(:, g);
    ellipse_fit = model_func(paramsEllipse(g,:), P);
    ellipseAligned_data = vpEllipseAligned(:, g);
    ellipseAligned_fit = model_func(paramsEllipseAligned(g,:), P);
    nonellipse_data = vpNonellipse(:, g);
    nonellipse_fit = model_func(paramsNonellipse(g,:), P);
    scatter(P(1:3:end)/1e6, ellipse_data(1:3:end), 18, 'b', 'filled', 'o','DisplayName','Ellipse model');hold on;
    scatter(P(1:3:end)/1e6, ellipseAligned_data(1:3:end), 18, 'g', 'filled', 'o','DisplayName','EllipseAligned model');
    scatter(P(1:3:end)/1e6, nonellipse_data(1:3:end), 18, 'r', 'filled', 's','DisplayName','Nonellipse model');
    plot(P/1e6, ellipse_fit, 'b-', 'LineWidth', 1.5, 'DisplayName','Fitting line for ellipse model');
    plot(P/1e6, ellipseAligned_fit, 'g-', 'LineWidth', 1.5, 'DisplayName','Fitting line for aligned ellipse model');
    plot(P/1e6, nonellipse_fit, 'r-', 'LineWidth', 1.5, 'DisplayName','Fitting line for nonellipse model');
    xlabel('Uniaxial Stress (MPa)', 'FontSize', 11);
    ylabel('V_p (m/s)', 'FontSize', 11);
    legend('show','FontSize',8,'Location','southeast');
    text(0.5, 0.07, modelParams{g}, ...
        'Units','normalized', ...          % 使用子图归一化坐标
        'FontSize', 10, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'top', ...
        'BackgroundColor', [1 1 1 0.8], ...
        'EdgeColor', 'k', 'LineWidth', 0.5, ...
        'Margin', 2);
end

% 斜率变化图
indexArray = 1:groupNum;
figure('Position', [0, 0, 500, 500]);
plot(paramsEllipse(indexArray, 1));


%% 函数区
function y = model_func(params, x)
    a = params(1);
    b = params(2);
    y = a .*x + b;
end