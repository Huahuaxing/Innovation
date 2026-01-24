%% 数据读取
ellipseData = load('D:\Projects\02_Innovation\06_ProcessedData\01_aperture_radius_record\Ellipse_Record.mat');
ellipseAlignedData = load('D:\Projects\02_Innovation\06_ProcessedData\01_aperture_radius_record\EllipseAligned_Record.mat');
nonellipseData = load('D:\Projects\02_Innovation\06_ProcessedData\01_aperture_radius_record\Nonellipse_Record.mat');

params = jsondecode(fileread('parameters.json'));
C = params.C;
n = params.n;
dimention = params.dimention;
density = params.density;
sita = params.sita;

%% 有效弹性矩阵C_eff计算
% 椭圆模型
r_r = ellipseData.radius_record;
a_r = ellipseData.aperture_record;
C_eff_ellipse = Func_C_eff(C, n, r_r, a_r, dimention, density, sita);
save('D:\Projects\02_Innovation\06_ProcessedData\02_C_eff\ellipse_C_eff.mat', 'C_eff_ellipse');

% 对齐椭圆模型
r_r_aligned = ellipseAlignedData.radius_record;
a_r_aligned = ellipseAlignedData.aperture_record;
C_eff_ellipseAligned = Func_C_eff(C, n, r_r_aligned, a_r_aligned, dimention, density, sita);
save('D:\Projects\02_Innovation\06_ProcessedData\02_C_eff\ellipseAligned_C_eff.mat', 'C_eff_ellipseAligned');

% 非椭圆模型
r_r_non = nonellipseData.radius_record;
a_r_non = nonellipseData.aperture_record;
C_eff_nonellipse = Func_C_eff(C, n, r_r_non, a_r_non, dimention, density, sita);
save('D:\Projects\02_Innovation\06_ProcessedData\02_C_eff\nonellipse_C_eff.mat', 'C_eff_nonellipse');