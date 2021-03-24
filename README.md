# test.sh for LazyBoy

### 你终于点进来了！

+ 如果碰巧你也在做TJU的并行计算的作业，是不是感觉命令行真是tmd难使，每次提交任务都烦的一批，还要重复实验，心态爆炸……
+ 那么这个脚本你值得拥有！

### 版本更新
+ 1.0
+ 1.1：修复部分问题
+ 1.2：增加对cpp文件支持，配置文件中args可以设置多个空格隔开的参数
+ 敬请期待……

### 使用这个脚本只需要这样几步……

+ 下载文件，包括如下：

  ```
  |-config
  |-submit-template.pbs
  |-test.sh
  ```

  + 文件的具体功能在此统一介绍（请**不要更改文件名**）
    + config：配置文件
    + submit-template.pbs：pbs文件模板
    + test.sh：自动提交脚本

+ 写好你的多线程C文件，请**严格按照实验中的示例进行编写**，即第一个参数为数据规模，第二个参数为线程数。

+ 请将C文件与刚才的三个文件放在**实验服务器**的同一目录下，当然你也可以编写多个C文件，只要把它们都放在这个目录下。

+ 更改配置文件（请**不要随意更改变量名或增加空格**）

  + start_thread_num：实验的最小线程数
  + end_thread_num：实验的最大线程数
  + stride：线程步长
  + args：除了线程数的其他参数，如果有多个，请用空格隔开
  + repeats：重复实验次数

+ 检查pbs模板是否符合你的实验，只要你使用实验示例的规范，就不会出大问题。

+ 启动脚本

  ```
  chmod +x test.sh
  ./test.sh
  ```

### 慢慢等实验结果……

+ 启动脚本后，脚本会建立这样几个目录

  ```
  |-bin\
  |-pbs\
  |-runlog\
  |-timelog\
  ```

  + 文件夹内会存放这些好东西：
    + bin文件夹内存放编译好的程序。
    + pbs文件夹内会存放所有提交任务的pbs文件，所有不重复的任务都会单独保存一份pbs文件。
    + runlog文件夹内存放你的程序输出。
    + timelog文件夹内存放系统记录时间的文件

+ 之后脚本将自动生成pbs文件，提交任务，线程从最小线程数开始到最大线程数，按照给定的步长，生成pbs文件，提交任务，等待结果。

+ 任务结束前不要改动运行文件夹内的任何文件。

+ 任务结束后将会输出output.txt，里面记录了每次任务的时间信息。

  示例如下：

  ```
  test_exp01_integral-1-1  //表示test_exp01_integral的1线程第1次实验
  real    0m0.012s
  test_exp01_integral-1-2
  real    0m0.005s
  test_exp01_integral-2-1
  real    0m0.007s
  test_exp01_integral-2-2
  real    0m0.007s
  test_exp01_integral-3-1
  real    0m0.009s
  test_exp01_integral-3-2
  real    0m0.009s
  test_exp01_integral-4-1
  real    0m0.009s
  test_exp01_integral-4-2  //表示test_exp01_integral的4线程第2次实验
  real    0m0.009s
  ```

+ 任务结束后，文件夹内的内容都会保留，如有需要自行提取，下一次运行脚本会自动删除，包括output.txt。

### 我不保证不会卡死！

+ 鉴于时间紧迫，测试做的比较少，估计……肯定……有bug……
+ 但是！！！由于服务器提交作业然后返回确实很慢！所以不要以为它不动就是真的卡死了……它可能只是在默默执行……
+ 不！要！中！途！kill！它！
+ 希望你能喜欢这个小工具！也欢迎你提出改进建议！

### 联系我

+ Q1395602105

+ lijinghan@tju.edu.cn