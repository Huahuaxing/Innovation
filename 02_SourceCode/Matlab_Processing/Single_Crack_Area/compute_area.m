% 裂隙参数
b = 1e-4/2;         % 最大开度 (m)
c0 = 0.036/2;       % 初始半长 (m)
nu = 0.15;          % 泊松比
E = 5.59e9          % 杨氏模量 (Pa)
mu0 = 2.59e9;       % 剪切模量 (Pa)

% 压力P（负号表示压应力，与python一致，单位：Pa）
P = 0:-0.02:-1.00;         % 生成 0, -0.02, ..., -1.00
P = P * 100e6;             % 转为 Pa



% 绘图1：裂隙图像
x = -c0:0.001:c0;
U0 = U0_of_x(x, b, c0);
figure('Position', [100, 100, 600, 800]);

subplot(2, 1, 1)
plot(x, U0, 'b-', 'LineWidth', 2);
hold on;
plot(x, -U0, 'b-', 'LineWidth', 2)
xlabel('x');
ylabel('y');
title('crack shape');
grid on;

% 绘图2：裂隙随力的变化
A = zeros(size(P));
for i = 1:length(P)
    c = c_of_P(P(i), b, c0, nu, mu0);
    A(i) = integral(@(x) integrand(x, c, b, c0), -c, c);
end

subplot(2, 1, 2)
plot(P/1e6, A*1e6, 'b-', 'LineWidth', 2);
xlabel('Stress P (MPa)');
ylabel('Area (mm^2)');
title('Non-elliptical crack area under stress');
grid on;

% 绘图3：裂隙随应力变化的图像
c1 = c_of_P(P(1:10:end), b, c0, nu, mu0);

figure('Position', [100, 100, 600, 800]);
for i = 1:length(c1)
    U1 = integrand(x, c1(i), b, c0);
    subplot(10, 1, i);
    plot(x, U1, 'b-');
    hold on;
    plot(x, -U1, 'b-');
    xlabel('x');
    ylabel('y');
    title('crack shape');
end
grid on;

% ---------------- 子函数部分（可单独放文件） ---------------
function U = U0_of_x(x, b, c0)
    U = b * (1 - (x/c0).^2).^1.5;
end

function c = c_of_P(P, b, c0, nu, mu0)
    % 计算应力P下的裂隙半长
    beta = 2*(1-nu)*c0 / (3*mu0*b);
    c = c0 * (1 - beta * P).^(-0.5);
end

function y = integrand(x, c, b, c0)
    % 被积函数 U(x,P)
    y = 2*b*(c/c0)^3 * (1 - (x/c).^2).^1.5 .* (abs(x) <= c);
    y(~(abs(x) <= c)) = 0;  % 超过c以外的都为0
end

function sigma_close = sigma_close_p(b, c0, E)
    alpha0 = b/c0;
    sigma_close = 3*alpha0*E / (4*(1-nu^2));
end

function sigma_close = sigma_close_e(b, c0, E)
    alpha0 = b/c0;
    sigma_close = alpha0*E / (4*(1-nu^2));
end
