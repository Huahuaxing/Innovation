% 裂隙参数
b = 1e-4/2;         % 最大开度 (m)
c0 = 0.036/2;       % 初始半长 (m)
nu = 0.15;          % 泊松比
mu0 = 2.59e9;       % 剪切模量 (Pa)

% 压力P（负号表示压应力，与python一致，单位：Pa）
P = 0:-0.02:-1.00;         % 生成 0, -0.02, ..., -1.00
P = P * 100e6;             % 转为 Pa

% 计算面积的函数
A = zeros(size(P));
for i = 1:length(P)
    c = c_of_P(P(i), b, c0, nu, mu0);
    % 积分上下限为 -c 到 c
    A(i) = integral(@(x) integrand(x, c, b, c0), -c, c);
end

A = 2 * A;  % 乘以2表示上下面积之和

% 绘图
figure('Position', [100, 100, 600, 400]);
plot(P/1e6, A*1e6, 'b-', 'LineWidth', 2);  % P 单位换成MPa，A换成 mm²/m
xlabel('Stress P (MPa)');
ylabel('Area (mm^2)');
title('Non-elliptical crack area under stress');
grid on;

% ----------- 子函数部分（可单独放文件） ----------

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