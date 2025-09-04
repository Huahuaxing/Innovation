%% ------------------------- 曹老师数据 -------------------------
P  = linspace(3, 600, 200) * 1e5;       % 3e5-6e7 Pa
P = P(:);                               % 变成列向量
% ------------------------- 基质弹性参数 -------------------------
v_stress= 2118.9;       % 纵波波速 (m/s)
v_shear = 1254.7;       % 横波波速 (m/s)
rho     = 2020;         % 密度 (kg/m³)
K       = 4.829e9;      % 体积模量 (Pa)
E       = 7.820e9;      % 杨氏模量 (Pa)
nu      = 0.23;         % 泊松比
lam     = 2.71e9;       % Lamé 第一参数 (Pa)
mu      = 3.180e9;      % 剪切模量 (Pa)
% lam = E*nu/((1+nu)*(1-2*nu));        % 若需用公式计算

%% ---------- 1. 读取文件中波速数据 ----------

% 读取数据
vp_ellipse = fullfile('vp_ellipse.csv');
vp_polygonal = fullfile('vp_polygonal.csv');
vp_ellipse_data = readmatrix(vp_ellipse);   % 形状 (100,6)
vp_polygonal_data = readmatrix(vp_polygonal);

vp_ellipse_data = vp_ellipse_data(100:end, :);      % 只拟合后100个数据
vp_polygonal_data = vp_polygonal_data(100:end, :);

% Min-Max 归一化（按列）
min_vals_ellipse = min(vp_ellipse_data, [], 1);  % 每列的最小值（行向量）
max_vals_ellipse = max(vp_ellipse_data, [], 1);  % 每列的最大值（行向量）
vp_ellipse_norm = (vp_ellipse_data - min_vals_ellipse) ./ (max_vals_ellipse - min_vals_ellipse);

min_vals_poly = min(vp_polygonal_data, [], 1);
max_vals_poly = max(vp_polygonal_data, [], 1);
vp_polygonal_norm = (vp_polygonal_data - min_vals_poly) ./ (max_vals_poly - min_vals_poly);

P_data   = P(100:end);

YData_ellipse = vp_ellipse_norm;
YData_polygonal = vp_polygonal_norm;

% 给原数据的列调换一下位置，按照titles的顺序分布
indices = [1, 5, 4, 3, 2, 6];
titles = {'20AR1', '16AR1+4AR2', '12AR1+8AR2', '8AR1+12AR2', '4AR1+16AR2', '20AR2'};
% 绘制文件中读取的六组波速曲线
figure('Units','centimeters','Position',[2 2 40 18]);
for group = 1:6
    subplot(2, 3, group);
    plot(P_data, vp_ellipse_data(:, indices(group)), 'r-', 'LineWidth',1.6);
    hold on;
    plot(P_data, vp_polygonal_data(:, indices(group)), 'b-', 'LineWidth',1.6);
    legend('Ellipse', 'Polygonal');
    xlabel('Uniaxial Stress  MPa');
    ylabel('v_p  (m/s)');
    title(titles{group});
    grid on; legend; box on;
end

%% ---------- 2. 定义拟合模型 ----------
% 参数 ABCs = [A B C]，单位 GPa，在模型函数里再 ×1e9 变成 Pa
fun_ellipse = @(x, P_data) y_model_norm(x, P_data, lam, mu, rho, 0);
fun_polygonal = @(x, P_data) y_model_norm(x, P_data, lam, mu, rho, 0);

%% ---------- 3. 设定拟合器相关参数 ----------
lb = [-1e6 -1e6 -1e6];     % 下界 (GPa)
ub = [ 1e6  1e6  1e6];     % 上界 (GPa)
opts = optimoptions('lsqcurvefit', ...
                    'Display','off', ...    % 显示优化过程
                    'TolFun',1e-10, ...     % 设置误差阈值
                    'TolX',1e-8, ...       % 设置参数变化阈值
                    'MaxIter',1e4);         % 设置最大迭代次数

%% ---------- 4. 对六组模型分别进行拟合 ----------
% 拟合椭圆数据
ABC_ellipse = zeros(3, 6);
fprintf('椭圆建模方式三阶弹性常数拟合结果：\n')
figure('Units','centimeters','Position',[2 2 40 18]);
sgtitle('Ellipse');
for group = 1:6
    ABCs0 = [1 1 1];           % 初始猜测 (GPa)
    for i = 1:10
        [ABCs_opt, resnorm, residual, exitflag, output] = lsqcurvefit(fun_ellipse, ABCs0, P_data, YData_ellipse(:, indices(group)), lb, ub, opts);
        ABCs0 = ABCs_opt;
    end
    fprintf('第%d组拟合结果：A=%.2f GPa  B=%.2f GPa  C=%.2f GPa\n', group, ABCs_opt(1), ABCs_opt(2), ABCs_opt(3));
    ABC_ellipse(:, group) = ABCs_opt;

    subplot(2, 3, group);
    plot(P_data, vp_ellipse_norm(:, indices(group)), 'ko', 'MarkerFaceColor','w', ...
         'DisplayName',sprintf('Measured v_p (Group %d)', group));
    hold on;

    plot(P_data, fun_ellipse(ABCs_opt, P_data), 'r-', 'LineWidth',1.6,...
         'DisplayName',sprintf('Fitted v_p (Group %d)', group));

    xlabel('Uniaxial Stress  Pa');
    ylabel('v_p norm');
    title(sprintf('A=%.2f  B=%.2f  C=%.2f  (GPa)', ABCs_opt(1), ABCs_opt(2), ABCs_opt(3)));
    grid on; legend; box on;
end


% 拟合多边形数据
fprintf('多边形建模方式三阶弹性常数拟合结果：\n')
ABC_polygonal = zeros(3, 6);
figure('Units','centimeters','Position',[2 2 40 18]);
sgtitle('Polygonal');
for group = 1:6
    ABCs0 = [-1 -1 -1];           % 初始猜测 (GPa)
    for i = 1:10
        [ABCs_opt, resnorm, residual, exitflag, output] = lsqcurvefit(fun_polygonal, ABCs0, P_data, YData_polygonal(:, indices(group)), lb, ub, opts);
        ABCs0 = ABCs_opt;
    end
    ABC_polygonal(:, group) = ABCs_opt;
    fprintf('第%d组拟合结果：A=%.2f GPa  B=%.2f GPa  C=%.2f GPa\n', group, ABCs_opt(1), ABCs_opt(2), ABCs_opt(3));

    subplot(2, 3, group);
    plot(P_data, vp_polygonal_norm(:, indices(group)), 'ko', 'MarkerFaceColor','w', ...
         'DisplayName',sprintf('Measured v_p (Group %d)', group));
    hold on;

    plot(P_data, fun_polygonal(ABCs_opt, P_data), 'r-', 'LineWidth',1.6,...
         'DisplayName',sprintf('Fitted v_p (Group %d)', group));

    xlabel('Uniaxial Stress  Pa');
    ylabel('v_p norm');
    title(sprintf('A=%.2f  B=%.2f  C=%.2f  (GPa)', ABCs_opt(1), ABCs_opt(2), ABCs_opt(3)));
    grid on; legend; box on;
end

%% ---------- 5. 绘制测量波速曲线和拟合波速曲线 ----------
figure('Units','centimeters','Position',[2 2 40 18]);
sgtitle('vp ellipse');
for group = 1:6
    subplot(2, 3, group);
    plot(P_data, vp_ellipse_data(:, indices(group)) - mean(vp_ellipse_data(:, indices(group)), 1), 'ko', 'MarkerFaceColor','w', ...
         'DisplayName',sprintf('Measured v_p (Group %d)', group));
    hold on;
    plot(P_data, vp_uniaxial(P_data, ABC_ellipse(1, group), ABC_ellipse(2, group), ABC_ellipse(3, group), lam, mu, rho, 0) - mean(vp_uniaxial(P_data, ABC_ellipse(1, group), ABC_ellipse(2, group), ABC_ellipse(3, group), lam, mu, rho, 0), 1), 'r-', 'LineWidth',1.6,...
         'DisplayName',sprintf('Fitted v_p (Group %d)', group));
end

figure('Units','centimeters','Position',[2 2 40 18]);
sgtitle('vp polygonal');
for group = 1:6
    subplot(2, 3, group);
    plot(P_data, vp_polygonal_data(:, indices(group)) - mean(vp_polygonal_data(:, indices(group)), 1), 'ko', 'MarkerFaceColor','w', ...
         'DisplayName',sprintf('Measured v_p (Group %d)', group));
    hold on;
    plot(P_data, vp_uniaxial(P_data, ABC_polygonal(1, group), ABC_polygonal(2, group), ABC_polygonal(3, group), lam, mu, rho, 0) - mean(vp_uniaxial(P_data, ABC_polygonal(1, group), ABC_polygonal(2, group), ABC_polygonal(3, group), lam, mu, rho, 0), 1), 'r-', 'LineWidth',1.6,...
         'DisplayName',sprintf('Fitted v_p (Group %d)', group));
end

%% ----------------------- 局部函数区 -----------------------

function y = A11(P, A, B, C, lam, mu)
    term1 = lam + 2*mu;
    term2 = (3*lam + 6*mu + 2*C + 6*B + 2*A) .* P .* (lam + 2*mu) ./ (mu .* (3*lam + 2*mu));
    term3 = (2*B + 2*C - lam - 2*mu) .* P .* lam ./ (2*mu .* (3*lam + 2*mu));
    y = term1 + term2 - term3;
end

function y = A12(~, varargin) %#ok<*INUSD>
    y = 0;          % 全 0
end

function y = A33(P, A, B, C, lam, mu)
    term1 = lam + 2*mu;
    term2 = (2*B + 2*C - lam - 2*mu) .* P .* (lam + 2*mu) ./ (mu .* (3*lam + 2*mu));
    term3 = (3*lam + 6*mu + 2*C + 6*B + 2*A) .* P .* lam ./ (2*mu .* (3*lam + 2*mu));
    y =  term1 + term2 - term3;
end

function y = A55(P, A, B, lam, mu)
    term1 = mu;
    term2 = (mu + B + A/2) .* P .* (lam + 2*mu) ./ (mu .* (3*lam + 2*mu));
    term3 = (mu + B + A/2) .* P .* lam ./ (2*mu .* (3*lam + 2*mu));
    y = term1 + term2 - term3;
end

function y = A44(P, A, B, lam, mu)
    y = A55(P, A, B, lam, mu);      % 各向同性：A44 = A55
end

function y = A13(P, B, C, lam, mu)
    term1 = lam;
    term2 = (lam + 2*C + 2*B) .* P .* (lam + 2*mu) ./ (mu .* (3*lam + 2*mu));
    term3 = (2*B + 2*C + lam) .* P .* lam ./ (2*mu .* (3*lam + 2*mu));
    y = term1 + term2 - term3;
end

function y = A15(P, varargin) %#ok<*ARGUNT>
    y = zeros(size(P));             % 全 0
end

function y = A35(P, varargin)
    y = zeros(size(P));             % 全 0
end

%% ---------- 声弹性波速（各向同性—围压） ----------
function vp = vp_confined(P, A, B, C, lam, mu, rho)
    a33 = A33(P, A, B, C, lam, mu);
    vp  = sqrt(a33 ./ rho);
end

function vsv = vsv_confined(P, A, B, lam, mu, rho)
    a55 = A55(P, A, B, lam, mu);
    vsv = sqrt(a55 ./ rho);
end

function vsh = vsh_confined(P, A, B, lam, mu, rho)
    a44 = A44(P, A, B, lam, mu);
    vsh = sqrt(a44 ./ rho);
end

%% ---------- 完整 K 表达式 ----------
function K = K_expr(P, A, B, C, lam, mu, theta_deg)
    theta = deg2rad(theta_deg);
    a11 = A11(P, A, B, C, lam, mu);
    a55 = A55(P, A, B, lam, mu);
    a12 = 0;                              % A12 恒为 0
    a44 = A44(P, A, B, lam, mu);

    K = (4 .* a11.^2 .* sin(theta).^4 ...
        - 8 .* a11 .* a55 .* sin(theta).^4 ...
        - 4 .* a12.^2 .* sin(theta).^4 ...
        - 8 .* a12 .* a55 .* sin(theta).^4 ...
        + 4 .* a11.^2 .* sin(theta).^2 ...
        + 8 .* a11 .* a44 .* sin(theta).^2 ...
        + 4 .* a12.^2 .* sin(theta).^2 ...
        + 8 .* a12 .* a44 .* sin(theta).^2 ...
        + (a11 - a44).^2);
end

%% ---------- 波速（对称平面内） ----------
function vp = vp_uniaxial(P, A, B, C, lam, mu, rho, theta_deg)
    if nargin < 8, theta_deg = 0; end
    a11 = A11(P, A, B, C, lam, mu);
    a55 = A55(P, A, B, lam, mu);
    K   = K_expr(P, A, B, C, lam, mu, theta_deg);
    vp  = sqrt((a11 + a55 + sqrt(K)) ./ rho);
end

function vsv = vsv_uniaxial(P, A, B, C, lam, mu, rho, theta_deg)
    if nargin < 8, theta_deg = 0; end
    a11 = A11(P, A, B, C, lam, mu);
    a55 = A55(P, A, B, lam, mu);
    K   = K_expr(P, A, B, C, lam, mu, theta_deg);
    vsv = sqrt((a11 + a55 - sqrt(K)) ./ rho);
end

function vsh = vsh_uniaxial(P, A, B, lam, mu, rho)
    a44 = A44(P, A, B, lam, mu);
    vsh = sqrt(a44 ./ rho);
end

function y_model = y_model_norm(x, P, lam, mu, rho, theta_deg)
    if nargin < 7, theta_deg = 0; end
    % 模型预测值
    ymodel = vp_uniaxial(P, x(1)*1e9, x(2)*1e9, x(3)*1e9, lam, mu, rho, theta_deg);

    % 归一化
    ymodel_norm = (ymodel - min(ymodel)) / (max(ymodel) - min(ymodel));
    y_model = ymodel_norm;
end

