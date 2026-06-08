# 根据裂隙中心坐标，使用论文公式，生成多边形裂隙坐标

import os

# 裂隙几何形态公式（修复幂运算）
def U0(b0, c0, x):
    a = 2 * b0
    # Python中幂运算用**，而非^（^是按位异或）
    b = (1 - (x / c0)**2)**1.5
    return a * b

def generate_crack_coords(b0, c0, center_x, center_y):
    """
    输入裂隙中心坐标，生成多边形裂隙的坐标数组
    :param b0: 裂隙几何参数
    :param c0: 裂隙几何参数
    :param center_x: 裂隙中心x坐标
    :param center_y: 裂隙中心y坐标
    :return: 多边形裂隙坐标列表，格式[(x1,y1), (x2,y2), ...]
    """
    # 生成x轴方向的采样点（从-c0到c0，取20个点，可调整数量）
    x_samples = [ -c0 + i * (2*c0)/20 for i in range(21) ]
    rows = 40
    cols = 2
    crack_coords = [[0 for _ in range(cols)] for _ in range(rows)]
    
    # 计算每个x对应的y值，生成坐标（基于中心偏移）
    for i, x in enumerate(x_samples):
        y1 = U0(b0, c0, x) / 2
        y2 = -y1
        if i == 0:
            crack_coords[i][0] = x + center_x
            crack_coords[i][1] = y1 + center_y

            crack_coords[20][0] = x + center_x
            crack_coords[20][1] = y2 + center_y
        else:
            crack_coords[i][0] = x + center_x
            crack_coords[i][1] = y1 + center_y

            crack_coords[40-i][0] = x + center_x
            crack_coords[40-i][1] = y2 + center_y
    return crack_coords

def io(crack_coords):
    """
    将生成的坐标列表以txt形式保存到本地
    """
    script_path = os.path.abspath(__file__)
    script_dir = os.path.dirname(script_path)
    file_path = os.path.join(script_dir, "crack_coords.txt")

    with open(file_path, "w", encoding='utf-8') as f:
        for (x, y) in crack_coords:
            line = f"{x:.6f}, {y:.6f}\n"
            f.write(line)


def main():
    # 设定裂隙参数
    b0 = 1e-4
    c0 = 0.018
    # 设定裂隙中心坐标
    center_x = 0.088+0.018
    center_y = 0.123
    
    # 生成多边形裂隙坐标
    crack_coords = generate_crack_coords(b0, c0, center_x, center_y)

    # 保存本地
    io(crack_coords)

if __name__ == "__main__":

    main()