% paper_radius_change.m
% 切换到脚本所在路径
cd(fileparts(mfilename('fullpath')));

%------------------参数与属性---------------------
b0 = 1e-4/2;
c0 = 0.036/2;
E = 5.96e9;
nu = 0.15;
% 你可根据实际调整应力范围，维持和 paper_area_change.m 一致
P = -linspace(0,1,51)*100e6;  % 单位：Pa，负号表示压应力

%------------------主计算---------------------
radius = zeros(size(P));  % 存储每个应力下的半长轴
for i = 1:length(P)
    radius(i) = c_of_P(P(i), b0, c0, nu, mu0);
end

%------------------可视化---------------------
figure;
plot(P/1e6, radius*1e3, 'LineWidth',2); % 单位统一：x轴 MPa，y轴 mm
xlabel('Stress P (MPa)');
ylabel('Crack Half-length c (mm)');
title('Crack Half-length vs Stress');
grid on;

%------------------公式函数定义---------------------
function c = c_of_P(P, b0, c0, nu, mu0)
    % 计算应力P下的裂隙开度c
    beta = 2 * (1 - nu) * c0 / (3 * mu0 * b0);
    c = c0 .* (1 - beta * P).^(-0.5);
end