% 该脚本按照论文中的裂隙形态公式，通过定积分，计算出理论裂隙面积变化曲线
%%数据初始化
cd(fileparts(mfilename("fullpath")));
jsonPath = "../../../../06_ProcessedData/parameters.json";
params = jsondecode(fileread(jsonPath));
E = params.E;
MU = params.MU;
nu = params.nu;
P = params.P;

b0 = 2e-4/2;        % 半开度
c0 = 0.036/2;       % 半长轴
x = linspace(-c0, c0, 37);

%% -----------------用定积分面积求解---------------------
A = zeros(size(P));
for i = 1:length(P)
    c = c_of_P(-P(i), b0, c0, nu, MU);
    % MATLAB自带quadgk或integral用于数值积分
    integrand = @(x_val) U_of_x_P(x_val, c, b0, c0);
    A(i) = integral(integrand, -c, c);
end

%% -----------绘图（类比matplotlib部分）------------
figure('Units','pixels', 'Position',[100 100 800 600])
subplot(1,2,2)
scatter(P/1e6, A*1e6);
xlabel('Stress P (MPa)');
ylabel('Area (mm^2)');
title('Area vs Stress');
grid on;

% 左侧多个小图
P_subset = P(1:20:end);  % 每隔5个取一个
A3 = A(1:5:end);
for i = 1:length(P_subset)
    ci = c_of_P(-P_subset(i), b0, c0, nu, MU);
    U1 = U_of_x_P(x, ci, b0, c0);
    subplot(length(P_subset),2,2*i-1)
    plot(x, U1/2, 'b-', x, -U1/2, 'b-');
    ylim([-6e-5, 6e-5]);
    title(sprintf('P=%.2f MPa   A=%.3f mm^2', P_subset(i)/1e6, A3(i)*1e6));
    grid on;
    if i < length(P_subset)
        set(gca, 'XTickLabel', []);
    else
        xlabel('x');
    end
end

%% 函数区
function c = c_of_P(P, b0, c0, nu, MU)
    % 计算应力P下的裂隙开度c
    % 公式： c = c0 * (1 - beta * P)^(-1/2)
    % 其中 beta = 2(1 - nu) c0 / (3 MU b0)
    beta = 2 * (1 - nu) * c0 / (3 * MU * b0);
    c = c0 .* (1 - beta .* P) .^ (-0.5);
end

function y = U_of_x_P(x, c, b0, c0)
    % 应力P作用下的裂隙形态函数
    % 公式： U(x) = 2 b0 (c / c0)^3 (1 - (x / c)^2)^(3/2)  当 |x| <= c
    %        U(x) = 0                                  当 |x| >  c
    y = zeros(size(x));
    mask = abs(x) <= c;
    if any(mask)
        z = 1.0 - (x(mask) / c).^2;
        z = max(z, 0.0);
        y(mask) = 2.0 * b0 * (c / c0).^3 .* z.^1.5;
    end
end