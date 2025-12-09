clear params;
%% 基质参数
v_stress = 2118.9;  % 压力波（纵波）速
v_shear = 1254.7;   % 剪切波（横波）速
density = 2020;     % 基质密度
K = 4.829e9;        % 体积模量
E = 7.82e9;         % 弹性模量
nu = 0.23;          % 泊松比
lam = 2.71e9;       % 拉梅常数
MU = 3.18e9;        % 剪切模量

C = zeros(6,6);                 % 初始化基质弹性矩阵
backProperty = 2;               % 基质背景性质
if backProperty == 1
    % 横观各向同性介质的弹性常数设置 (单位: Pa)
    C(1,1) = 47.31e9;             % C11
    C(3,3) = 33.89e9;             % C33
    C(1,2) = 7.83e9;              % C12
    C(1,3) = 5.29e9;              % C13
    C(4,4) = 17.15e9;             % C44
    C(2,2) = C(1,1);              % C22 = C11 (横观各向同性)
    C(2,3) = C(1,3);              % C23 = C13 (横观各向同性)
    C(6,6) = 0.5 * (C(1,1) - C(1,2)); % C66 = (C11-C12)/2 (横观各向同性)
    C(5,5) = C(4,4);              % C55 = C44 (横观各向同性)
    C(2,1) = C(1,2);              % C21 = C12 (对称性)
    C(3,1) = C(1,3);              % C31 = C13 (对称性)
    C(3,2) = C(2,3);              % C32 = C23 (对称性)

elseif backProperty == 2
    % 各向同性介质的弹性常数设置 (单位: Pa)
    C_iso = zeros(3,3);
    C_iso(1,1) = K + 4*MU / 3.0;  % λ + 2μ (Pa)
    C_iso(1,2) = K - 2*MU / 3.0;  % λ   (Pa)
    % C_iso(1,1) = 6.292e9;
    % C_iso(1,2) = 3.692e9;        % for zizhen（如有特殊要求可放开）
    C(1,1) = C_iso(1,1);          % C11 (Pa)
    C(1,2) = C_iso(1,2);          % C12 (Pa)
    C(1,3) = C(1,2);              % C13 = C12 (Pa)
    C(2,1) = C(1,3);              % C21 = C13 (Pa)
    C(2,2) = C(1,1);              % C22 = C11 (Pa)
    C(2,3) = C(2,1);              % C23 = C21 (Pa)
    C(3,1) = C(1,3);              % C31 = C13 (Pa)
    C(3,2) = C(2,1);              % C32 = C21 (Pa)
    C(3,3) = C(2,2);              % C33 = C22 (Pa)
    C(6,6) = 0.5 * (C(1,1) - C(1,2)); % C66 = (C11-C12)/2 = μ (Pa)
    C(5,5) = C(6,6);              % C55 = C66 (Pa)
    C(4,4) = C(6,6);              % C44 = C66 (Pa) 
end
c_1 = sqrt(C(1,1) * C(3,3));
B = zeros(1,5);
B(3) = sqrt(C(6,6) / C(4,4));
B(4) = sqrt((c_1-C(1,3))*(c_1+C(1,3)+2*C(4,4)) / (C(3,3)*C(4,4)));
B(5) = sqrt((c_1+C(1,3))*(c_1-C(1,3)-2*C(4,4)) / (C(3,3)*C(4,4)));
B(1) = 0.5 * (B(4) + B(5));
B(2) = 0.5 * (B(4) - B(5));


%% 实验参数
P = linspace(3e5, 6e7, 200);    % 单轴应力数组
n = 20;                         % 裂隙数量
point_n = 21;                   % 裂隙上二维截点的数量
sita = linspace(0, pi, 31);     % 波速的角度数组
dimention = 3;                  % 模型维度


%% 创建matlab结构体
params.v_stress = v_stress;
params.v_shear = v_shear;
params.density = density;
params.K = K;
params.E = E;
params.nu = nu;
params.lam = lam;
params.MU = MU;
params.C = C;
params.backProperty = backProperty;
params.c_1 = c_1;
params.B = B;

params.P = P;
params.n = n;
params.point_n = point_n;
params.sita = sita;
params.dimention = dimention;


%% 保存为json配置文件
jsonStr = jsonencode(params, 'PrettyPrint', true);
jsonFile = fullfile(pwd, 'parameters.json');
fid = fopen(jsonFile, 'w'); % 当前脚本所在路径
if fid == -1
    error('无法打开文件进行写入');
end
fprintf(fid, '%s', jsonStr);
fclose(fid);
fprintf('参数已保存在%s\n', jsonFile);

