dataPathNonellipse= 'D:\Projects\02_Innovation\05_Data\SoftCrack\polygonal_data';
params = jsondecode(fileread('D:\Projects\02_Innovation\parameters.json'));
n = params.n;                   % 裂隙数量
point_n = params.point_n;       % 二维截点数量
P = params.P;                   % 单轴应力数组

%% 加载comsol 和非椭圆裂隙位置相同的椭圆 数据
% aperture_random = zeros(5, 1, 200);
% radius_random = zeros(5, 20, 200);
radius_record = zeros(5, 20, 200, 6);
aperture_record = zeros(5, 20, 200, 6);

% 加载1-1到1-5数据
for sub = 1:5  % 五个子模型
    aa = zeros(2*n, size(P,1), 2*point_n+1);
    aperture = zeros(n, size(aa, 2), point_n);
    percular = zeros(n, size(aa, 2), point_n);     % 一个由01构成的数组，1标记已完全闭合，0代表还是张开状态，形状与aperture完全一致
    radius = zeros(n, size(P,1));
    pointy_start_idx = point_n + 2;                % Matlab索引从1开始

    for tab = 1:size(aa, 1)  % 四十个表格
        file_path = fullfile(dataPathNonellipse, sprintf('20-cracks-distance-1-%d-20AR1', sub), sprintf('20-cracks-distance-%d~40-%d-AR1.txt', tab, 1));
        rawData = readmatrix(file_path, 'NumHeaderLines', 5);  % 跳过前5行
        aa(tab, :, :) = rawData;
    end
    
    for crack = 1:n
        aperture(crack, :, :) = squeeze(aa(2*crack-1, :, pointy_start_idx:end)) - squeeze(aa(2*crack, :, pointy_start_idx:end));
    end

    aperture(aperture < 1e-7) = 0;        % 将aperture数组中所有小于1e-7的值设置为0

    for crack = 1:n
        for stress = 1:size(P,1)
            for point = 1:point_n
                if aperture(crack, stress, point) <= 1e-7
                    percular(crack, stress, point) = 1;
                end
            end
            % 检查裂隙闭合点并累积长度
            for point = 1:(point_n-1)
                if percular(crack, stress, point) * percular(crack, stress, point+1) == 1
                    ds = aa(2*crack-1, 1, point+2) - aa(2*crack-1, 1, point+1);               % 这个变量记录已完全闭合的一小段长度，在下面进行累加
                    radius(crack, stress) = radius(crack, stress) + ds;
                end
            end
        end 
    end

    radius = (0.036 - radius) / 2;      % 0.036-已闭合长度得到张开长度，再除2得半长轴
    radius(radius < 5e-5) = 0;

    aperture_a = mean(aperture, 3);     % 20*200，计算每个裂隙独自的平均开度
    aperture_aa = mean(aperture_a, 1);  % 1*200，每个模型所有裂隙的平均开度

    radius_record(sub, :, :, 1) = radius;
    aperture_record(sub, :, :, 1) = aperture_a;
    % aperture_random(sub, 1, :) = aperture_aa;
    % radius_random(sub, :, :) = radius;
    % aperture_record(sub, :, :, 1) = (pi * 0.036 / 2) * (aperture_a / 2); % 裂隙等效面积
end

% 2-1到2-5数据
for sub = 1:5  % 五个子模型
    aa = zeros(2*n, size(P,1), 2*point_n+1);
    aperture = zeros(n, size(aa, 2), point_n);
    percular = zeros(n, size(aa, 2), point_n);
    radius = zeros(n, size(P,1));
    pointy_start_idx = point_n + 2;   % Matlab索引从1开始

    for tab = 1:size(aa, 1)  % 四十个表格
        file_path = fullfile(dataPathNonellipse, ...
            sprintf('20-cracks-distance-2-%d-20AR2', sub), ...
            sprintf('20-cracks-distance-%d~40-%d-20AR2.txt', tab, sub));
        rawData = readmatrix(file_path, 'NumHeaderLines', 5);  % 跳过前5行
        aa(tab, :, :) = rawData;
    end
    
    for crack = 1:n
        aperture(crack, :, :) = squeeze(aa(2*crack-1, :, pointy_start_idx:end)) ...
                              - squeeze(aa(2*crack,   :, pointy_start_idx:end));
    end

    aperture(aperture < 1e-7) = 0;

    for crack = 1:n
        for stress = 1:size(P,1)
            for point = 1:point_n
                if aperture(crack, stress, point) <= 1e-7
                    percular(crack, stress, point) = 1;
                end
            end
            for point = 1:(point_n-1)
                if percular(crack, stress, point) * percular(crack, stress, point+1) == 1
                    ds = aa(2*crack-1, 1, point+2) - aa(2*crack-1, 1, point+1);
                    radius(crack, stress) = radius(crack, stress) + ds;
                end
            end
        end
    end

    radius = (0.036 - radius) / 2;
    radius(radius < 5e-5) = 0;

    aperture_a = mean(aperture, 3);
    aperture_aa = mean(aperture_a, 1);

    radius_record(sub, :, :, 6) = radius;
    aperture_record(sub, :, :, 6) = aperture_a;
    % aperture_random(sub, 1, :) = aperture_aa;
    % radius_random(sub, :, :) = radius;
end

ARList = {'4AR1+16AR2', '8AR1+12AR2', '12AR1+8AR2', '16AR1+4AR2'};
% 3-1到6-5数据
for arIdx = 1:numel(ARList)
    groupLabel = arIdx + 2;  % 原始数据文件夹标号3~6
    storeIdx = 6 - arIdx;    % 保持与原先相同的记录顺序（5,4,3,2）

    for sub = 1:5
        aa = zeros(2*n, size(P,1), 2*point_n+1);
        aperture = zeros(n, size(aa, 2), point_n);
        percular = zeros(n, size(aa, 2), point_n);
        radius = zeros(n, size(P,1));
        pointy_start_idx = point_n + 2;   % Matlab索引从1开始

        for tab = 1:size(aa, 1)
            file_path = sprintf('%s/20-cracks-distance-%d-%d-%s/20-cracks-distance-%d~40-%d-%s.txt', ...
                dataPathNonellipse, groupLabel, sub, ARList{arIdx}, tab, sub, ARList{arIdx});
            rawData = readmatrix(file_path, 'NumHeaderLines', 5);
            aa(tab, :, :) = rawData;
        end

        for crack = 1:n
            aperture(crack, :, :) = squeeze(aa(2*crack-1, :, pointy_start_idx:end)) ...
                                  - squeeze(aa(2*crack,   :, pointy_start_idx:end));
        end

        aperture(aperture < 1e-7) = 0;

        for crack = 1:n
            for stress = 1:size(P,1)
                for point = 1:point_n
                    if aperture(crack, stress, point) <= 1e-7
                        percular(crack, stress, point) = 1;
                    end
                end
                for point = 1:(point_n-1)
                    if percular(crack, stress, point) * percular(crack, stress, point+1) == 1
                        ds = aa(2*crack-1, 1, point+2) - aa(2*crack-1, 1, point+1);
                        radius(crack, stress) = radius(crack, stress) + ds;
                    end
                end
            end 
        end

        radius = (0.036 - radius) / 2;
        radius(radius < 5e-5) = 0;

        aperture_a = mean(aperture, 3);
        aperture_aa = mean(aperture_a, 1);
        
        radius_record(sub, :, :, storeIdx)   = radius;
        aperture_record(sub, :, :, storeIdx) = aperture_a;
        % aperture_random(sub, 1, :) = aperture_aa;
        % radius_random(sub, :, :) = radius;
    end
end

save('D:\Projects\02_Innovation\06_ProcessedData\01_aperture_radius_record\Nonellipse_Record.mat', 'aperture_record', 'radius_record');
        


