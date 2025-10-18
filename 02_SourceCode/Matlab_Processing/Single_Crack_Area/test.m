% 参数
b = 1e-4/2;
c0 = 0.036/2;
nu = 0.15;
mu0 = 2.59e9;
kn = 1e12; % 裂隙法向刚度 (Pa/m)，可从COMSOL接触对导出近似值

P = 0:-0.02:-1.00;
P = P * 100e6;

A = zeros(size(P));
for i = 1:length(P)
    A(i) = integral(@(x) max(w0(x,b,c0) - abs(P(i))/kn, 0), -c0, c0);
end

figure('Position',[100,100,600,400]);
plot(P/1e6, A*1e6, 'b-', 'LineWidth', 2);
xlabel('Stress P (MPa)');
ylabel('Area (mm^2)');
title('Crack effective open area under compressive stress');
grid on;

function y = w0(x,b,c0)
    % 初始裂隙形状：椭圆开度分布
    y = 2*b*(1 - (x/c0).^2).^0.5;
    y(abs(x)>c0) = 0;
end
