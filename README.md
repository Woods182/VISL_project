# MLP
## FSM——module:
1. 初始等待状态
    - 初始化输出reg和adder的reg数组
    - 等待下一个状态需要输入控制信号loaddata
2. 初始数据输入状态：
   - 读入两个weight数据
   - 输出weightload_valid
3. loaddata状态：
    - 读八拍input
    - 第4状态
4. 第一层普通计算：
    - 计算mac
    - 存入addreg
    - 加载两个weight
    - 需要重复8遍
    - 转到loaddata
5. 第一层需要rounder的计算
    - 计算mac
    - rounder
    - 重复八遍
    - 将rounder结果存入regout
    - 转到其他层普通状态
    - 清除该层的addreg
6. 其他层普通计算
    - 将regout连接入到input位置
    - 输入两个weight
    - 计算mac
    - 计数这是第几层计算
    - 结果输出到adder
    - 重复15*8个周期
    - 去7
7. 其他层rounder计算
    - 将regout连接入到input位置
    - 输入两个weight
    - 计算mac
    - rounder
    - 清零addreg
    - 结果输出到adder
    - 重复8个周期
    - 返回到5/7
8. 输出数据
    - 将regout串行输出
  