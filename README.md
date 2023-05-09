# MLP
*Author：WoodsNing,ZhaojunNi*     
*Data：20230508*
## pe_unit——module:
- 两个数据输入连入乘法
- rounder_en 该输入数据计算完后需不需要rounder
- keep：保持数据regadd和reg_out，在input数据打八拍时候使用；
- data_out:输出数据，有rounder才输出，其余情况输出入为0；
- rounder_num：输出rounder第几组数1-8；
- rounder_valid：输出数据是否有效


## FSM——module:
0. 初始等待状态
    - 初始化输出reg和adder的reg数组
    - 等待下一个状态需要输入控制信号loaddata
1. 初始数据输入状态：
   - 读入两个weight数据
   - 输出weightload_valid
2. loaddata状态：
    - 读八拍input
    - 第4状态
3. 第一层普通计算：
    - 计算mac
    - 存入addreg
    - 加载两个weight
    - 需要重复8遍
    - 转到loaddata
4. 第一层需要rounder的计算
    - 计算mac
    - rounder
    - 重复八遍
    - 将rounder结果存入regout
    - 转到其他层普通状态
    - 清除该层的addreg
5. 其他层普通计算
    - 将regout连接入到input位置
    - 输入两个weight
    - 计算mac
    - 计数这是第几层计算
    - 结果输出到adder
    - 重复15*8个周期
    - 去7
6. 其他层rounder计算
    - 将regout连接入到input位置
    - 输入两个weight
    - 计算mac
    - rounder
    - 清零addreg
    - 结果输出到adder
    - 重复8个周期
    - 返回到5/7
7. 输出数据
    - 将regout串行输出
  