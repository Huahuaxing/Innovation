from typing import Literal
import numpy as np
from utils.crack_shape_paper import sigma_close_e, sigma_close_p

class Crack:
    '''裂隙类'''
    def __init__(self, b0, c0, E, nu, crackType: 'Literal["elliptic", "nonelliptic"]') -> None:
        '''
        基质属性：
        b0:半最大开度, c0:半长, E:杨氏模量, nu:泊松比
        裂隙类型：
            - "elliptic"：椭圆形
            - "nonelliptic"：非椭圆形
        '''
        self.b0 = b0
        self.c0 = c0
        self.E = E
        self.nu = nu
        self.crackType = crackType

    def sigma_close(self) -> float:
        """
        计算闭合应力（σ_close），根据裂隙类型选择不同的方法。

        Returns:
            float: 闭合应力

        Raises:
            ValueError: 当 crackType 不是 'elliptic' 或 'nonelliptic' 时抛出
        """
        if self.crackType == "elliptic":
            return sigma_close_e(self.b0, self.c0, self.E, self.nu)
        elif self.crackType == "nonelliptic":
            return sigma_close_p(self.b0, self.c0, self.E, self.nu)
        else:
            raise ValueError(f"不支持的裂隙类型 crackType：{self.crackType}，请使用 'elliptic' 或 'nonelliptic'")
