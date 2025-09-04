%% ------------------------- 定义基质弹性参数 -------------------------
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

%% ---------- 读取文件中波速数据 ----------
v11_polygonal = fullfile('E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\velocity\\isotropic_matrix\\n_20\\degree_90\\vp_polygonal.csv');
v11_polygonal_data = readmatrix(v11_polygonal);   % 形状 (200,6)

v33_polygonal = fullfile('E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\velocity\\isotropic_matrix\\n_20\\degree_0\\vp_polygonal.csv');
v33_polygonal_data = readmatrix(v33_polygonal);

v31_polygonal = fullfile('E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\velocity\\isotropic_matrix\\n_20\\degree_0\\vsv_polygonal.csv');
v31_polygonal_data = readmatrix(v31_polygonal);

v12_polygonal = fullfile('E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\velocity\\isotropic_matrix\\n_20\\degree_90\\vsh_polygonal.csv');
v12_polygonal_data = readmatrix(v12_polygonal);

vp_de_45_polygonal = fullfile('E:\\OneDrive\\Project\\Innovation\\05_ProcessedData\\velocity\\isotropic_matrix\\n_20\\degree_45\\vp_polygonal.csv');
vp_de_45_polygonal_data = readmatrix(vp_de_45_polygonal);

% 给原数据的列调换一下位置，按照titles的顺序分布
indices = [1, 5, 4, 3, 2, 6];
titles = {'20AR1', '16AR1+4AR2', '12AR1+8AR2', '8AR1+12AR2', '4AR1+16AR2', '20AR2'};
% 绘制文件中读取的六组波速曲线
figure('Units','centimeters','Position',[2 2 40 18]);
for group = 1:6
    subplot(2, 3, group);
    plot(P, v33_polygonal_data(:, indices(group)), 'r-', 'LineWidth',1.6);
    xlabel('Uniaxial Stress Pa');
    ylabel('v_p  (m/s)');
    title(titles{group});
    grid on; legend; box on;
end

%% ------------------------- 利用已有的波速，求出有效弹性矩阵，进而求出主应变E11，E22，E33 -------------------------
c0_11 = v11_polygonal_data .^ 2 * rho;
c0_33 = v33_polygonal_data .^ 2 * rho;
c0_44 = v31_polygonal_data .^ 2 * rho;
c0_66 = v12_polygonal_data .^ 2 * rho;
c0_13 = -c0_44 + sqrt((c0_11+c0_44-2*rho*vp_de_45_polygonal_data.*2) .* (c0_33+c0_44-2*rho*vp_de_45_polygonal_data.*2));
c0_12 = c0_11 - 2 * c0_66;

C0 = zeros(200, 6, 6, 6);
C0(:,1,1,:) = c0_11;
C0(:,2,2,:) = c0_11;
C0(:,3,3,:) = c0_33;
C0(:,4,4,:) = c0_44;
C0(:,5,5,:) = c0_44;
C0(:,6,6,:) = c0_66;
C0(:,1,2,:) = c0_12;  C0(:,2,1,:) = c0_12;
C0(:,1,3,:) = c0_13;  C0(:,3,1,:) = c0_13;
C0(:,2,3,:) = c0_13;  C0(:,3,2,:) = c0_13;

E0 = zeros(200, 3, 6);
for i = 1:200
    for j = 1:6
        S0 = inv(squeeze(C0(i,:,:,j)));  % 将刚度矩阵转换为柔度矩阵
        E0(i,1,j) = S0(1,3) * P(i);      % E11
        E0(i,2,j) = S0(2,3) * P(i);      % E22
        E0(i,3,j) = S0(3,3) * P(i);      % E33
    end
end

%% ------------------------- 反演三阶弹性常数c111,c112 -------------------------
% 取两个阶段，分别是6-30MPa(序号20-100)，36-60MPa(序号120-200)
x1 = zeros(2, 6);
x2 = zeros(2, 6);
resnorm1 = zeros(1, 6);
resnorm2 = zeros(1, 6);
lb = [-1e14, -1e14];
ub = [1e14, 1e14];
opts = optimoptions('lsqcurvefit', ...
                    'Display','off', ...    % 显示优化过程
                    'TolFun',1e-10, ...     % 设置误差阈值
                    'TolX',1e-8, ...       % 设置参数变化阈值
                    'MaxIter',1e4, ...
                    'MaxFunctionEvaluations', 1e4);         % 设置最大迭代次数
for group = 1:6
    % 设置初始值
    x10 = [1.5e12, 1.5e12];
    x20 = [1e11, 1e11];

    % 6-30MPa阶段
    % fun1 = @(x, E0) v33(C0(20,3,3,group), E0(:,1,group), E0(:,2,group), E0(:,3,group), x(1), x(2), rho);    % 使用波速直接拟合
    fun2 = @(x, E) c33(C0(20,3,3,group), E(:,1,group), E(:,2,group), E(:,3,group), x(1), x(2));    % 使用刚度矩阵拟合
    % 36-60MPa阶段
    % fun3 = @(x, E0) v33(C0(120,3,3,group), E0(:,1,group), E0(:,2,group), E0(:,3,group), x(1), x(2), rho);    % 使用波速直接拟合
    fun4 = @(x, E) c33(C0(120,3,3,group), E(:,1,group), E(:,2,group), E(:,3,group), x(1), x(2));    % 使用刚度矩阵拟合
    for i = 1:10
        [x1(:, group), resnorm1(group)] = lsqcurvefit(fun2, x10, E0(20:100,:,:), C0(20:100,3,3,group), lb, ub, opts);
        x10 = x1(:, group);
    end

    for i = 1:10
        [x2(:, group), resnorm2(group)] = lsqcurvefit(fun4, x20, E0(120:200,:,:), C0(120:200,3,3,group), lb, ub, opts);
        x20 = x2(:, group);
    end
end

%% ------------------------- 绘制反演结果 -------------------------
figure('Units','centimeters','Position',[2 2 40 18]);
for group = 1:6
    vp1 = v33(C0(20,3,3,indices(group)), E0(20:100,1,indices(group)), E0(20:100,2,indices(group)), E0(20:100,3,indices(group)), x1(1, indices(group)), x1(2, indices(group)), rho);
    vp2 = v33(C0(120,3,3,indices(group)), E0(120:200,1,indices(group)), E0(120:200,2,indices(group)), E0(120:200,3,indices(group)), x2(1, indices(group)), x2(2, indices(group)), rho);

    subplot(2, 3, group);
    plot(P(20:100), v33_polygonal_data(20:100, indices(group)), 'r-', 'LineWidth',1.6);
    hold on;
    plot(P(120:200), v33_polygonal_data(120:200, indices(group)), 'r-', 'LineWidth',1.6);
    hold on;
    h1 = plot(P(20:100), vp1, 'b-', 'LineWidth',1.6);
    hold on;
    h2 = plot(P(120:200), vp2, 'g-', 'LineWidth',1.6);
    legend([h1, h2], {sprintf('c111 = %.2e, c112 = %.2e', x1(1, indices(group)), x1(2, indices(group))), sprintf('c111 = %.2e, c112 = %.2e', x2(1, indices(group)), x2(2, indices(group)))}, 'Location', 'best');
    xlabel('Uniaxial Stress Pa');
    ylabel('v_33  (m/s)');
    title(titles{group});
    grid on; legend; box on;
end

figure('Units','centimeters','Position',[2 2 40 18]);
for group = 1:6
    c33_1 = c33(C0(20,3,3,indices(group)), E0(20:100,1,indices(group)), E0(20:100,2,indices(group)), E0(20:100,3,indices(group)), x1(1, indices(group)), x1(2, indices(group)));
    c33_2 = c33(C0(120,3,3,indices(group)), E0(120:200,1,indices(group)), E0(120:200,2,indices(group)), E0(120:200,3,indices(group)), x2(1, indices(group)), x2(2, indices(group)));
    subplot(2, 3, group);
    plot(P(20:100), C0(20:100,3,3,indices(group)), 'r-', 'LineWidth',1.6);
    hold on;
    h3 = plot(P(20:100), c33_1, 'b-', 'LineWidth',1.6);
    hold on;
    plot(P(120:200), C0(120:200,3,3,indices(group)), 'r-', 'LineWidth',1.6);
    hold on;
    h4 = plot(P(120:200), c33_2, 'g-', 'LineWidth',1.6);
    legend([h3, h4], {sprintf('c111 = %.2e, c112 = %.2e', x1(1, indices(group)), x1(2, indices(group))), sprintf('c111 = %.2e, c112 = %.2e', x2(1, indices(group)), x2(2, indices(group)))}, 'Location', 'best');
    xlabel('Uniaxial Stress Pa');
    ylabel('C_33  (Pa)');
    title(titles{group});
    grid on; legend; box on;
end



%% ---------- 相关函数 ----------
function v33 = v33(c0_33, E11, E22, E33, c111, c112, rho)
    v33 = sqrt((c0_33 + c111*E33 + c112*(E11+E22)) / rho);
end

function c33 = c33(c0_33, E11, E22, E33, c111, c112)
    c33 = c0_33 + c111*E33 + c112*(E11+E22);
end
    









