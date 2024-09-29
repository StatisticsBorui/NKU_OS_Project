# Lab0.5

## 1、使用GDB验证启动流程

使用gdb调试QEMU模拟的RISC-V计算机加电开始运行到执行应用程序的第一条指令（即跳转到0x80200000）这个阶段的执行过程，说明RISC-V硬件加电后的几条指令在哪里？完成了哪些功能？

    make
    make debug  make gdb
    x/10i $pc

    输出：
    0x1000:	auipc	t0,0x0
    0x1004:	addi	a1,t0,32
    0x1008:	csrr	a0,mhartid
    0x100c:	ld	t0,24(t0)
    0x1010:	jr	t0
    0x1014:	unimp
    0x1016:	unimp
    0x1018:	unimp
    0x101a:	.insn	2, 0x8000
    0x101c:	unimp

    说明：接入gdb，复位地址在0x1000，在0x1010跳转



    break *0x1010
    c
    info r t0

    输出：
    break *0x1010
    Continuing.
    t0             0x80000000       2147483648

    说明：执行到0x1010后，下一步将跳转到0x80000000

<!---->

    x/10i 0x80000000

    输出：
    0x80000000:	csrr	a6,mhartid
    0x80000004:	bgtz	a6,0x80000108
    0x80000008:	auipc	t0,0x0
    0x8000000c:	addi	t0,t0,1032
    0x80000010:	auipc	t1,0x0
    0x80000014:	addi	t1,t1,-16
    0x80000018:	sd	t1,0(t0)
    0x8000001c:	auipc	t0,0x0
    0x80000020:	addi	t0,t0,1020
    0x80000024:	ld	t0,0(t0)

    说明：0x80000000 处的10条汇编指令

<!---->

    break *0x80200000
    continue

    输出：
    Breakpoint 1, kern_entry () at kern/init/entry.S:7
    7	    la sp, bootstacktop

    说明：kern/init/entry.S, line 7入口点，分配内存栈，跳转到kern_init

<!---->

    (gdb) x/10i $pc

    输出：
       0x80200000 <kern_entry>:     auipc   sp,0x3
       0x80200004 <kern_entry+4>:   mv      sp,sp
       0x80200008 <kern_entry+8>:   j       0x8020000a <kern_init>
       0x8020000a <kern_init>:      auipc   a0,0x3
       0x8020000e <kern_init+4>:    addi    a0,a0,-2
       0x80200012 <kern_init+8>:    auipc   a2,0x3
       0x80200016 <kern_init+12>:   addi    a2,a2,-10
       0x8020001a <kern_init+16>:   addi    sp,sp,-16
       0x8020001c <kern_init+18>:   li      a1,0
       0x8020001e <kern_init+20>:   sub     a2,a2,a0

    说明：真正入口点在0x8020000a

**功能：**

从复位地址开始，启动Bootloader加载操作系统内核，之后跳转到入口点kern\_entry，真正的入口点在kern\_init，之后完成了格式化输出cprintf()后进入死循环。

