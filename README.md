# uperf

#### 介绍  
YC调度，为天玑1100和天玑1200进行专属优化  
感谢@yc9559 [Uperf-Github](https://github.com/yc9559/uperf)  

 **相关修改**  
加回fast模式  
fast模式：降低CPU高负载时的GPU频率，强制提高内存频率，提供极限CPU性能。  
performance模式：降低CPU频率，阻止GPU调频至最高以压制GPU功耗，强制提高内存频率，提供高GPU性能。  
balance模式：降低CPU和GPU频率至高能效频率，根据负载提高内存频率，同时提供较高CPU和GPU性能。  
powersave模式：保证基本使用的同时尽可能降低CPU和GPU性能以省电  
service.sh  
开机两分钟后关闭负载均衡，防止反复切换核心。  
每分钟调整一次CPU分配：  
后台应用锁定双小核，压制后台应用耗电；  
将游戏绑定至大核和超大核，减少卡顿（需要游戏进程的cpuset为game或者gamelite，已知部分设备失效）；  