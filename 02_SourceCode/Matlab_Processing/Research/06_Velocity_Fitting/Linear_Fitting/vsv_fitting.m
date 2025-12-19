% =============================================
% Stress-vsv 拟合脚本 (基于一次函数公式)
% 公式: V(P) = a * P + b
% =============================================
clear;
%% 数据初始化
cd(fileparts(mfilename("fullpath")));
prop = jsondecode(fileread("../../../../../06_ProcessedData/parameters.json"));
P = prop.P;   % 应力数组

groupNum = 6;

% 加载椭圆模型波速数据，(200,6)
vsvEllipse = readmatrix('../../../../../06_ProcessedData/03_velocity/n_20_degree_0/vsv/vsv_Ellipse.csv');
indexArray = [[30,100]; [22,88]; [26,79]; [35,70]; [16,55]; [16,52]];
slopeEllipse = zeros(1, groupNum);
interceptEllipse = zeros(1, groupNum);
indexInterval = cell(1, groupNum);
PInterval = cell(1, groupNum);
for g = 1:groupNum
    idx = indexArray(g, 1):indexArray(g, 2);
    indexInterval{g} = idx; 
    PInterval{g} = P(idx);

    p = polyfit(P(idx), vsvEllipse(idx, g), 1);
    slopeEllipse(g) = p(1);
    interceptEllipse(g) = p(2);
end
% 椭圆对齐模型数据
vsvEllipseAligned = readmatrix('../../../../../06_ProcessedData/03_velocity/n_20_degree_0/vsv/vsv_EllipseAligned.csv');
indexArray = [[35,120]; [16,110]; [19,95]; [20,70]; [16,55]; [16,40]];
slopeEllipseAligned = zeros(1, groupNum);
interceptEllipseAligned = zeros(1, groupNum);
indexInterval = cell(1, groupNum);
PInterval = cell(1, groupNum);
for g = 1:groupNum
    idx = indexArray(g, 1):indexArray(g, 2);
    indexInterval{g} = idx; 
    PInterval{g} = P(idx);

    p = polyfit(P(idx), vsvEllipseAligned(idx, g), 1);
    slopeEllipseAligned(g) = p(1);
    interceptEllipseAligned(g) = p(2);
end
% 非椭圆模型数据
vsvNonellipse = readmatrix('../../../../../06_ProcessedData/03_velocity/n_20_degree_0/vsv/vsv_nonellipse.csv');
dvdpNonellipse = zeros(200, 6);
for g=1:groupNum
    dvdpNonellipse(:, g) = gradient(vsvNonellipse(:,g), P);
end
[~, idx_max] = max(dvdpNonellipse);
win = 20;
slopeNonellipse = zeros(1, groupNum);
interceptNonellipse = zeros(1, groupNum);
for g = 1:groupNum
    idx = (idx_max(g)-win):(idx_max(g)+win);
    idx = idx(idx>=1 & idx<=length(P));

    p = polyfit(P(idx), vsvNonellipse(idx, g), 1);
    slopeNonellipse(g) = p(1);
    interceptNonellipse(g) = p(2);
end


%% 打印拟合结果
fprintf('\n========== 拟合结果 ==========\n');

fprintf('Ellipse参数:\n');
fprintf('每组选取的应力区间：\n')
fprintf('slope = %s\n', mat2str(slopeEllipse, 4));
fprintf('intercept = %s\n', mat2str(interceptEllipse, 5));

fprintf('EllipseAligned参数:\n');
fprintf('每组选取的应力区间：')
for g=1:groupNum
    fprintf('[%g, %g]', PInterval{g}(1)/1e6, PInterval{g}(end)/1e6);
end
fprintf('\nslope = %s\n', mat2str(slopeEllipseAligned, 4));
fprintf('intercept = %s\n', mat2str(interceptEllipseAligned, 5));

fprintf('Nonellipse参数:\n');
fprintf('每组选取的应力区间：\n')
fprintf('slope = %s\n', mat2str(slopeNonellipse, 4));
fprintf('intercept = %s\n', mat2str(interceptNonellipse, 5));


fprintf('====================================\n\n');


%% 绘图区
% 波速图
modelParams = {'20AR1', '16AR1+4AR2', '12AR1+8AR2', '8AR1+12AR2', '4AR1+16AR2', '20AR2'};
subTitleList = {'(a)', '(b)', '(c)', '(d)', '(e)', '(f)'};
figure('Position', [0 0 2000 1000]);
sgtitle('Fitting Result', 'FontSize', 14, 'FontWeight','bold');
ax = gobjects(1, 6);
for g = 1:groupNum
    ax(g) = subplot(2,3,g);
    title(subTitleList{g});
    ellipse_fit = slopeEllipse(g) * P(1:120) + interceptEllipse(g);
    ellipseAligned_fit = slopeEllipseAligned(g) * P(1:120) + interceptEllipseAligned(g);
    Nonellipse_fit = slopeNonellipse(g) * P(1:120) + interceptNonellipse(g);
    hold on;
    scatter(P(1:3:end)/1e6, vsvEllipse(1:3:end,g), 18, 'b', 'filled', 'o','DisplayName','Ellipse model');
    scatter(P(1:3:end)/1e6, vsvEllipseAligned(1:3:end,g), 18, 'g', 'filled', 'o','DisplayName','EllipseAligned model');
    scatter(P(1:3:end)/1e6, vsvNonellipse(1:3:end,g), 18, 'r', 'filled', 'o','DisplayName','Nonellipse model');
    plot(P(1:120)/1e6, ellipse_fit, 'b-', 'LineWidth', 1.2, 'DisplayName','Fitting line for ellipse model');
    plot(P(1:120)/1e6, ellipseAligned_fit, 'g-', 'LineWidth', 1.2, 'DisplayName','Fitting line for ellipseAligned model');
    plot(P(1:120)/1e6, Nonellipse_fit, 'r-', 'LineWidth', 1.2, 'DisplayName','Fitting line for Nonellipse model');
    xlabel('Uniaxial Stress (MPa)', 'FontSize', 11);
    ylabel('V_p (m/s)', 'FontSize', 11);
    ylim([1170, 1400]);
    if g == 1
        legend('show','FontSize',8,'Location','southeast');
    end
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
figure('Position', [0, 0, 500, 500]);
plot(slopeEllipse, 'b-', 'DisplayName', 'Ellipse model');hold on;
plot(slopeEllipseAligned, 'g-', 'DisplayName', 'EllipseAligned model');
plot(slopeNonellipse, 'r-', 'DisplayName', 'Nonellipse model');
legend('show');