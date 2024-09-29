# Lab1

## 1、理解内核启动中的程序入口操作

阅读 kern/init/entry.S内容代码，结合操作系统内核启动流程，说明指令 la sp, bootstacktop 完成了什么操作，目的是什么？ tail kern\_init 完成了什么操作，目的是什么？

1.  RISC-V硬件加电后，寄存器的内容是未定义，因此需要通过某种方式设置堆栈指针寄存器的值，指令 **la sp, bootstacktop**就是将bootstacktop的内存地址加载到堆栈指针寄存器sp。
2.  **tail kern\_init**尾调用是用来跳转到kern\_init函数的，不保留当前的返回地址，在内核初始化阶段可以节省栈空间\*\*。\*\*

## 2、完善中断处理 （需要编程）

编程完善trap.c中的中断处理函数trap，在对时钟中断进行处理的部分填写kern/trap/trap.c函数中处理时钟中断的部分，使操作系统每遇到100次时钟中断后，调用print\_ticks子程序，向屏幕上打印一行文字”100 ticks”，在打印完10行后调用sbi.h中的shut\_down()函数关机。说明实现过程和定时器中断中断处理的流程。实现要求的部分代码后，运行整个系统，大约每1秒会输出一次”100 ticks”，输出10行。

    case IRQ_S_TIMER:
                /*(1)设置下次时钟中断- clock_set_next_event()
                 *(2)计数器（ticks）加一
                 *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
                * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
                */
                clock_set_next_event(); //(1)
                num++;  //(2)
                if (num >= TICK_NUM){ 
                    print_ticks();
                    num = 0;
                    print_num++;
                }   //(3)
                if (print_num == 10){
                    sbi_shutdown();
                }   //(4)

                break;

## 3、Challenge1：描述与理解中断流程

描述ucore中处理中断异常的流程（从异常的产生开始），其中mov a0，sp的目的是什么？SAVE\_ALL中寄存器保存在栈中的位置是什么确定的？对于任何中断，\_\_alltraps 中都需要保存所有寄存器吗？请说明理由。

1.  产生异常——向CPU发送中断请求——通过\_alltraps找到中断入口点——CPU保留当前任务上下文，调用SAVE\_ALL——处理异常——恢复现场，调用RESTORE\_ALL
2.  \*\***mov a0,sp的作用**：\*\*sp栈指针赋值给a0寄存器，在中断处理或函数调用的上下文中，保存栈指针的值，后续恢复执行时的栈状态。
3.  SAVE\_ALL中寄存器保存的位置是sp的当前值向下偏移，依次存储，寄存器所对应栈位置通过特定的偏移量来访问。
4.  对于任何中断，\_\_alltraps 中都需要保存所有寄存器，在异常处理程序执行过程中出现了任何问题，还需要通过 \_\_alltraps 恢复到之前的状态。

# 4、Challenge2：理解上下文切换机制

在trapentry.S中汇编代码 csrw sscratch, sp；csrrw s0, sscratch, x0实现了什么操作，目的是什么？save all里面保存了stval scause这些csr，而在restore all里面却不还原它们？那这样store的意义何在呢？

1.  \*\*csrw sscratch, sp：\*\*把当前的栈指针 sp 值写入 sscratch 寄存器，sscratch可以保存一些关键的上下文信息，以便在中断处理过程后恢复执行环境。
2.  \*\*csrrw s0, sscratch, x0：\*\*读取 sscratch CSR寄存器的当前值，然后，将 x0 寄存器的值写入到 sscratch  CSR寄存器中，最后，将 sscrath CSR寄存器在被写入之前的值写入到 s0 寄存器中。主要是为了保存CSR寄存器的当前值并在之后恢复它。
3.  scause存储了导致当前异常或中断发生的具体原因，stval 存储导致当前异常或中断发生的特定值，然而，它们的值只在处理过程中有用，异常处理完成后它们的值就不再需要了，因此不需要恢复。
4.

