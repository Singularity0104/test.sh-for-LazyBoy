# test.sh for LazyBoy

> Gitee: https://gitee.com/singularity0104/test.sh-for-LazyBoy.git
>
> Github: https://github.com/Singularity0104/test.sh-for-LazyBoy.git


### 你终于点进来了！

+ 如果碰巧你也在做TJU的并行计算的作业，是不是感觉命令行真是tmd难使，每次提交任务都烦的一批，还要重复实验，心态爆炸……
+ 那么这个脚本你值得拥有！

### 版本更新
+ 1.0
+ 1.1：修复部分问题。
+ 1.2：增加对cpp文件支持；配置文件中args可以设置多个空格隔开的参数。
+ 1.2.1：调整部分输出信息。
+ 1.3：增加删除任务脚本，供紧急时使用，具体参阅下方“卡死了怎么办！”；增加Running进度显示，显示转动效果，方便观察任务进度；调整部分输出信息；公开GitHub网址。
+ 1.3.1：重要更新！修复多参数无法识别的问题。
+ 1.4：修改config中参数名称，减少误导，并取消stride这个没啥用的参数，让你用起来更顺手；不过请注意！1.4版本的config不兼容旧版本脚本程序！如果你用着之前的顺手，忽略这次更新；此外调整字体颜色，输出信息更醒目。
+ 1.4.1对后台运行脚本做了详细说明，请查看“如果你想在后台运行脚本”。
+ 1.5：config更新，增加对mpi的支持，不兼容旧版本。
+ 敬请期待……

### 使用这个脚本只需要这样几步……

+ 下载文件，包括如下：

  ```
  |-config
  |-submit-template.pbs
  |-test.sh
  |-deltask.sh
  ```

  + 文件的具体功能在此统一介绍（**请不要更改文件名**）
    + config：配置文件
    + submit-template.pbs：pbs文件模板
    + test.sh：自动提交脚本
    + deltask.sh：任务删除脚本

+ 写好你的多线程C文件，请**严格按照实验中的示例进行编写**，即**最后一个参数**为线程数。

+ 请将C文件与刚才的几个文件放在**实验服务器**的同一目录下，当然你也可以编写多个C文件，只要把它们都放在这个目录下。

+ 如果同时写了C和CPP文件，请不要将它们起成同一个名字！

+ 更改配置文件（请**不要随意更改变量名或增加空格**）

  + 版本>=1.5示例

  	```
  	# compiler choices
  	# [0]: icc -pthread
  	# [1]: mpiicpc
  	compiler:1
  	min_thread_num:1
  	max_thread_num:16
  	args:100 100
  	repeat:10
  	```

  	+ compiler：编译器选择
  	+ min_thread_num：实验的最小线程数
  	+ max_thread_num：实验的最大线程数
  	+ args：参数（**可以写入多个参数，如果有多个，请用空格隔开。如果使用icc编译，最后一个线程数参数不要写进去！！！**）
  	+ repeats：重复实验次数

  

  + 版本1.4示例

  	```
  	min_thread_num:1
  	max_thread_num:16
  	args:100 100
  	repeat:10
  	```

  	+ min_thread_num：实验的最小线程数
  	+ max_thread_num：实验的最大线程数
  	+ args：除了线程数的其他参数（**可以写入多个参数，如果有多个，请用空格隔开。重复！最后一个线程数参数不要写进去**）
  	+ repeats：重复实验次数

  

  + 版本<1.4示例
	
  	```
  	start_thread_num:1
  	end_thread_num:4
  	stride:1
  	args:100
  	repeat:2
  	```
	
  	+ start_thread_num：实验的最小线程数
  	+ end_thread_num：实验的最大线程数
  	+ stride：线程步长
  	+ args：除了线程数的其他参数（**可以写入多个参数，如果有多个，请用空格隔开。重复！最后一个线程数参数不要写进去**）
  	+ repeats：重复实验次数

+ 检查pbs模板是否符合你的实验，只要你使用实验示例的规范，就不会出大问题。

+ 启动脚本

  ```shell
  chmod +x test.sh
  ./test.sh
  ```

+ 如果你想在后台运行脚本

  + 执行如下命令

    ```shell
    chmod +x ./test.sh
    nohup ./test.sh &
    ```

  + 会把控制台输出到nohup.out，可能比较乱。。。

  + 现在你就可以关闭中断或者断开ssh干别的去

  + 打开新终端可以通过如下命令查看后台执行的test.sh进程信息

    ```shell
    ps -ef | grep "test.sh"
    ```

### 慢慢等实验结果……

+ 启动脚本后，脚本会建立这样几个文件或目录

  ```
  |-bin/
  |-pbs/
  |-runlog/
  |-timelog/
  |-outdata.txt
  |-node.txt
  ```

  + 文件夹内会存放这些好东西：
    + bin文件夹内存放编译好的程序。
    + pbs文件夹内会存放所有提交任务的pbs文件，所有不重复的任务都会单独保存一份pbs文件。
    + runlog文件夹内存放你的程序输出。
    + timelog文件夹内存放系统记录时间的文件。
    + outdata.txt存放提取的时间信息，也就是实验结果。
    + node.txt存放任务id信息，用于程序发生意外是运行删除任务脚本。

+ 之后脚本将自动生成pbs文件，提交任务，线程从最小线程数开始到最大线程数，按照给定的步长，生成pbs文件，提交任务，等待结果。

+ 任务结束前不要改动运行文件夹内的任何文件。

+ 任务结束后将会输出outdata.txt，里面记录了每次任务的时间信息。

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

### 卡死了怎么办！

+ 脚本卡死或者中途退出可能有这样几个原因

  + 你提交的代码编译无法通过。
  + 你提交的任务规模过大，时间严重超时。
  + 你手残摁了ctrl+c。
  + 我写的脚本有bug。
  + ……

+ 如何解决

  + 无论出现什么情况，请及时联系我。

  + 如果你提交了很多任务，但是由于中途退出，现在等待队列里仍有大量任务未完成，可以执行deltask.sh脚本，具体操作如下：

    ```shell
    chmod +x deltask.sh
    ./deltask.sh
    ```

    

### 联系我

+ Q1395602105

+ lijinghan@tju.edu.cn
