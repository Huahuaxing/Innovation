% 根据论文的裂隙形态函数，绘制开度图和直径图
%%数据初始化
cd(fileparts(mfilename("fullpath")));
jsonPath = "../../../../06_ProcessedData/parameters.json";
params = jsondecode(fileread(jsonPath));
E = params.E;
MU = params.MU;
nu = params.nu;
P = params.P;

b0 = 2e-4/2;        % 半开度,AR1
c0 = 0.036/2;       % 半长轴
x = linspace(-c0, c0, 37);

%% 计算闭合应力
sigmaNonellipse = sigma_close_p(b0, c0, E, nu);
fprintf('该裂隙的闭合应力是：%.2f MPa', sigmaNonellipse/1e6);

%% 计算开度
c = c_of_P(-P, b0, c0, nu, MU);


%% 绘图区
% 开度图
figure;
plot(P, c);





%% 函数区
function c = c_of_P(P, b0, c0, nu, MU)
    % 计算应力P下的裂隙半长轴c
    % 公式： c = c0 * (1 - beta * P)^(-1/2)
    % 其中 beta = 2(1 - nu) c0 / (3 MU b0)
    beta = 2 * (1 - nu) * c0 / (3 * MU * b0);
    c = c0 .* (1 - beta .* P) .^ (-0.5);
end

function sigma = sigma_close_p(b0, c0, E, nu)
    % 计算非椭圆裂隙闭合应力P
    alpha0 = b0 / c0;
    sigma = 3 * alpha0 * E / (4 * (1 - nu^2));
end
