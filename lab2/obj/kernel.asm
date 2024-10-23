
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	43660613          	addi	a2,a2,1078 # ffffffffc0206470 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	70c010ef          	jal	ra,ffffffffc0201756 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	71650513          	addi	a0,a0,1814 # ffffffffc0201768 <etext>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	01a010ef          	jal	ra,ffffffffc0201080 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	1da010ef          	jal	ra,ffffffffc0201280 <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	1a4010ef          	jal	ra,ffffffffc0201280 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013c:	00001517          	auipc	a0,0x1
ffffffffc0200140:	64c50513          	addi	a0,a0,1612 # ffffffffc0201788 <etext+0x20>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00001517          	auipc	a0,0x1
ffffffffc0200156:	65650513          	addi	a0,a0,1622 # ffffffffc02017a8 <etext+0x40>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00001597          	auipc	a1,0x1
ffffffffc0200162:	60a58593          	addi	a1,a1,1546 # ffffffffc0201768 <etext>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	66250513          	addi	a0,a0,1634 # ffffffffc02017c8 <etext+0x60>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <free_area>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	66e50513          	addi	a0,a0,1646 # ffffffffc02017e8 <etext+0x80>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	2ea58593          	addi	a1,a1,746 # ffffffffc0206470 <end>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	67a50513          	addi	a0,a0,1658 # ffffffffc0201808 <etext+0xa0>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	6d558593          	addi	a1,a1,1749 # ffffffffc020686f <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00001517          	auipc	a0,0x1
ffffffffc02001c0:	66c50513          	addi	a0,a0,1644 # ffffffffc0201828 <etext+0xc0>
}
ffffffffc02001c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ca:	00001617          	auipc	a2,0x1
ffffffffc02001ce:	68e60613          	addi	a2,a2,1678 # ffffffffc0201858 <etext+0xf0>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	69a50513          	addi	a0,a0,1690 # ffffffffc0201870 <etext+0x108>
void print_stackframe(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e6:	00001617          	auipc	a2,0x1
ffffffffc02001ea:	6a260613          	addi	a2,a2,1698 # ffffffffc0201888 <etext+0x120>
ffffffffc02001ee:	00001597          	auipc	a1,0x1
ffffffffc02001f2:	6ba58593          	addi	a1,a1,1722 # ffffffffc02018a8 <etext+0x140>
ffffffffc02001f6:	00001517          	auipc	a0,0x1
ffffffffc02001fa:	6ba50513          	addi	a0,a0,1722 # ffffffffc02018b0 <etext+0x148>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00001617          	auipc	a2,0x1
ffffffffc0200208:	6bc60613          	addi	a2,a2,1724 # ffffffffc02018c0 <etext+0x158>
ffffffffc020020c:	00001597          	auipc	a1,0x1
ffffffffc0200210:	6dc58593          	addi	a1,a1,1756 # ffffffffc02018e8 <etext+0x180>
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	69c50513          	addi	a0,a0,1692 # ffffffffc02018b0 <etext+0x148>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00001617          	auipc	a2,0x1
ffffffffc0200224:	6d860613          	addi	a2,a2,1752 # ffffffffc02018f8 <etext+0x190>
ffffffffc0200228:	00001597          	auipc	a1,0x1
ffffffffc020022c:	6f058593          	addi	a1,a1,1776 # ffffffffc0201918 <etext+0x1b0>
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	68050513          	addi	a0,a0,1664 # ffffffffc02018b0 <etext+0x148>
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    return 0;
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
    return 0;
}
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026a:	00001517          	auipc	a0,0x1
ffffffffc020026e:	6be50513          	addi	a0,a0,1726 # ffffffffc0201928 <etext+0x1c0>
kmonitor(struct trapframe *tf) {
ffffffffc0200272:	ed86                	sd	ra,216(sp)
ffffffffc0200274:	e9a2                	sd	s0,208(sp)
ffffffffc0200276:	e5a6                	sd	s1,200(sp)
ffffffffc0200278:	e1ca                	sd	s2,192(sp)
ffffffffc020027a:	fd4e                	sd	s3,184(sp)
ffffffffc020027c:	f952                	sd	s4,176(sp)
ffffffffc020027e:	f556                	sd	s5,168(sp)
ffffffffc0200280:	f15a                	sd	s6,160(sp)
ffffffffc0200282:	e962                	sd	s8,144(sp)
ffffffffc0200284:	e566                	sd	s9,136(sp)
ffffffffc0200286:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	6c450513          	addi	a0,a0,1732 # ffffffffc0201950 <etext+0x1e8>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00001c17          	auipc	s8,0x1
ffffffffc02002a6:	71ec0c13          	addi	s8,s8,1822 # ffffffffc02019c0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00001917          	auipc	s2,0x1
ffffffffc02002ae:	6ce90913          	addi	s2,s2,1742 # ffffffffc0201978 <etext+0x210>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00001497          	auipc	s1,0x1
ffffffffc02002b6:	6ce48493          	addi	s1,s1,1742 # ffffffffc0201980 <etext+0x218>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00001b17          	auipc	s6,0x1
ffffffffc02002c0:	6ccb0b13          	addi	s6,s6,1740 # ffffffffc0201988 <etext+0x220>
        argv[argc ++] = buf;
ffffffffc02002c4:	00001a17          	auipc	s4,0x1
ffffffffc02002c8:	5e4a0a13          	addi	s4,s4,1508 # ffffffffc02018a8 <etext+0x140>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	332010ef          	jal	ra,ffffffffc0201602 <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002dc:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00001d17          	auipc	s10,0x1
ffffffffc02002ea:	6dad0d13          	addi	s10,s10,1754 # ffffffffc02019c0 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	42e010ef          	jal	ra,ffffffffc0201722 <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	41a010ef          	jal	ra,ffffffffc0201722 <strcmp>
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
}
ffffffffc0200328:	60ee                	ld	ra,216(sp)
ffffffffc020032a:	644e                	ld	s0,208(sp)
ffffffffc020032c:	64ae                	ld	s1,200(sp)
ffffffffc020032e:	690e                	ld	s2,192(sp)
ffffffffc0200330:	79ea                	ld	s3,184(sp)
ffffffffc0200332:	7a4a                	ld	s4,176(sp)
ffffffffc0200334:	7aaa                	ld	s5,168(sp)
ffffffffc0200336:	7b0a                	ld	s6,160(sp)
ffffffffc0200338:	6bea                	ld	s7,152(sp)
ffffffffc020033a:	6c4a                	ld	s8,144(sp)
ffffffffc020033c:	6caa                	ld	s9,136(sp)
ffffffffc020033e:	6d0a                	ld	s10,128(sp)
ffffffffc0200340:	612d                	addi	sp,sp,224
ffffffffc0200342:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	8526                	mv	a0,s1
ffffffffc0200346:	3fa010ef          	jal	ra,ffffffffc0201740 <strchr>
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200374:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020037e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
ffffffffc0200384:	3bc010ef          	jal	ra,ffffffffc0201740 <strchr>
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	60a50513          	addi	a0,a0,1546 # ffffffffc02019a8 <etext+0x240>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	07c30313          	addi	t1,t1,124 # ffffffffc0206428 <is_panic>
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00001517          	auipc	a0,0x1
ffffffffc02003de:	62e50513          	addi	a0,a0,1582 # ffffffffc0201a08 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00001517          	auipc	a0,0x1
ffffffffc02003f4:	46050513          	addi	a0,a0,1120 # ffffffffc0201850 <etext+0xe8>
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
    while (1) {
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	2b0010ef          	jal	ra,ffffffffc02016d0 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b523          	sd	zero,10(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	5fa50513          	addi	a0,a0,1530 # ffffffffc0201a28 <commands+0x68>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	28a0106f          	j	ffffffffc02016d0 <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	2660106f          	j	ffffffffc02016b6 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	2960106f          	j	ffffffffc02016ea <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	2e478793          	addi	a5,a5,740 # ffffffffc020074c <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00001517          	auipc	a0,0x1
ffffffffc0200482:	5ca50513          	addi	a0,a0,1482 # ffffffffc0201a48 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	5d250513          	addi	a0,a0,1490 # ffffffffc0201a60 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	5dc50513          	addi	a0,a0,1500 # ffffffffc0201a78 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	5e650513          	addi	a0,a0,1510 # ffffffffc0201a90 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	5f050513          	addi	a0,a0,1520 # ffffffffc0201aa8 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	5fa50513          	addi	a0,a0,1530 # ffffffffc0201ac0 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	60450513          	addi	a0,a0,1540 # ffffffffc0201ad8 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	60e50513          	addi	a0,a0,1550 # ffffffffc0201af0 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	61850513          	addi	a0,a0,1560 # ffffffffc0201b08 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	62250513          	addi	a0,a0,1570 # ffffffffc0201b20 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	62c50513          	addi	a0,a0,1580 # ffffffffc0201b38 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	63650513          	addi	a0,a0,1590 # ffffffffc0201b50 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	64050513          	addi	a0,a0,1600 # ffffffffc0201b68 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	64a50513          	addi	a0,a0,1610 # ffffffffc0201b80 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	65450513          	addi	a0,a0,1620 # ffffffffc0201b98 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	65e50513          	addi	a0,a0,1630 # ffffffffc0201bb0 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	66850513          	addi	a0,a0,1640 # ffffffffc0201bc8 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	67250513          	addi	a0,a0,1650 # ffffffffc0201be0 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	67c50513          	addi	a0,a0,1660 # ffffffffc0201bf8 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	68650513          	addi	a0,a0,1670 # ffffffffc0201c10 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	69050513          	addi	a0,a0,1680 # ffffffffc0201c28 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	69a50513          	addi	a0,a0,1690 # ffffffffc0201c40 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	6a450513          	addi	a0,a0,1700 # ffffffffc0201c58 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	6ae50513          	addi	a0,a0,1710 # ffffffffc0201c70 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	6b850513          	addi	a0,a0,1720 # ffffffffc0201c88 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	6c250513          	addi	a0,a0,1730 # ffffffffc0201ca0 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	6cc50513          	addi	a0,a0,1740 # ffffffffc0201cb8 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	6d650513          	addi	a0,a0,1750 # ffffffffc0201cd0 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	6e050513          	addi	a0,a0,1760 # ffffffffc0201ce8 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	6ea50513          	addi	a0,a0,1770 # ffffffffc0201d00 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	6f450513          	addi	a0,a0,1780 # ffffffffc0201d18 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	6fa50513          	addi	a0,a0,1786 # ffffffffc0201d30 <commands+0x370>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00001517          	auipc	a0,0x1
ffffffffc020064e:	6fe50513          	addi	a0,a0,1790 # ffffffffc0201d48 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00001517          	auipc	a0,0x1
ffffffffc0200666:	6fe50513          	addi	a0,a0,1790 # ffffffffc0201d60 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	70650513          	addi	a0,a0,1798 # ffffffffc0201d78 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	70e50513          	addi	a0,a0,1806 # ffffffffc0201d90 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	71250513          	addi	a0,a0,1810 # ffffffffc0201da8 <commands+0x3e8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76c63          	bltu	a4,a5,ffffffffc0200724 <interrupt_handler+0x82>
ffffffffc02006b0:	00001717          	auipc	a4,0x1
ffffffffc02006b4:	7d870713          	addi	a4,a4,2008 # ffffffffc0201e88 <commands+0x4c8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00001517          	auipc	a0,0x1
ffffffffc02006c6:	75e50513          	addi	a0,a0,1886 # ffffffffc0201e20 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	73450513          	addi	a0,a0,1844 # ffffffffc0201e00 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	6ea50513          	addi	a0,a0,1770 # ffffffffc0201dc0 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	76050513          	addi	a0,a0,1888 # ffffffffc0201e40 <commands+0x480>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006f2:	00006697          	auipc	a3,0x6
ffffffffc02006f6:	d3e68693          	addi	a3,a3,-706 # ffffffffc0206430 <ticks>
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cf19                	beqz	a4,ffffffffc0200726 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200710:	00001517          	auipc	a0,0x1
ffffffffc0200714:	75850513          	addi	a0,a0,1880 # ffffffffc0201e68 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	6c650513          	addi	a0,a0,1734 # ffffffffc0201de0 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00001517          	auipc	a0,0x1
ffffffffc0200730:	72c50513          	addi	a0,a0,1836 # ffffffffc0201e58 <commands+0x498>
}
ffffffffc0200734:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200738 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200738:	11853783          	ld	a5,280(a0)
ffffffffc020073c:	0007c763          	bltz	a5,ffffffffc020074a <trap+0x12>
    switch (tf->cause) {
ffffffffc0200740:	472d                	li	a4,11
ffffffffc0200742:	00f76363          	bltu	a4,a5,ffffffffc0200748 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200746:	8082                	ret
            print_trapframe(tf);
ffffffffc0200748:	bded                	j	ffffffffc0200642 <print_trapframe>
        interrupt_handler(tf);
ffffffffc020074a:	bfa1                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc020074c <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc020074c:	14011073          	csrw	sscratch,sp
ffffffffc0200750:	712d                	addi	sp,sp,-288
ffffffffc0200752:	e002                	sd	zero,0(sp)
ffffffffc0200754:	e406                	sd	ra,8(sp)
ffffffffc0200756:	ec0e                	sd	gp,24(sp)
ffffffffc0200758:	f012                	sd	tp,32(sp)
ffffffffc020075a:	f416                	sd	t0,40(sp)
ffffffffc020075c:	f81a                	sd	t1,48(sp)
ffffffffc020075e:	fc1e                	sd	t2,56(sp)
ffffffffc0200760:	e0a2                	sd	s0,64(sp)
ffffffffc0200762:	e4a6                	sd	s1,72(sp)
ffffffffc0200764:	e8aa                	sd	a0,80(sp)
ffffffffc0200766:	ecae                	sd	a1,88(sp)
ffffffffc0200768:	f0b2                	sd	a2,96(sp)
ffffffffc020076a:	f4b6                	sd	a3,104(sp)
ffffffffc020076c:	f8ba                	sd	a4,112(sp)
ffffffffc020076e:	fcbe                	sd	a5,120(sp)
ffffffffc0200770:	e142                	sd	a6,128(sp)
ffffffffc0200772:	e546                	sd	a7,136(sp)
ffffffffc0200774:	e94a                	sd	s2,144(sp)
ffffffffc0200776:	ed4e                	sd	s3,152(sp)
ffffffffc0200778:	f152                	sd	s4,160(sp)
ffffffffc020077a:	f556                	sd	s5,168(sp)
ffffffffc020077c:	f95a                	sd	s6,176(sp)
ffffffffc020077e:	fd5e                	sd	s7,184(sp)
ffffffffc0200780:	e1e2                	sd	s8,192(sp)
ffffffffc0200782:	e5e6                	sd	s9,200(sp)
ffffffffc0200784:	e9ea                	sd	s10,208(sp)
ffffffffc0200786:	edee                	sd	s11,216(sp)
ffffffffc0200788:	f1f2                	sd	t3,224(sp)
ffffffffc020078a:	f5f6                	sd	t4,232(sp)
ffffffffc020078c:	f9fa                	sd	t5,240(sp)
ffffffffc020078e:	fdfe                	sd	t6,248(sp)
ffffffffc0200790:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200794:	100024f3          	csrr	s1,sstatus
ffffffffc0200798:	14102973          	csrr	s2,sepc
ffffffffc020079c:	143029f3          	csrr	s3,stval
ffffffffc02007a0:	14202a73          	csrr	s4,scause
ffffffffc02007a4:	e822                	sd	s0,16(sp)
ffffffffc02007a6:	e226                	sd	s1,256(sp)
ffffffffc02007a8:	e64a                	sd	s2,264(sp)
ffffffffc02007aa:	ea4e                	sd	s3,272(sp)
ffffffffc02007ac:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007ae:	850a                	mv	a0,sp
    jal trap
ffffffffc02007b0:	f89ff0ef          	jal	ra,ffffffffc0200738 <trap>

ffffffffc02007b4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007b4:	6492                	ld	s1,256(sp)
ffffffffc02007b6:	6932                	ld	s2,264(sp)
ffffffffc02007b8:	10049073          	csrw	sstatus,s1
ffffffffc02007bc:	14191073          	csrw	sepc,s2
ffffffffc02007c0:	60a2                	ld	ra,8(sp)
ffffffffc02007c2:	61e2                	ld	gp,24(sp)
ffffffffc02007c4:	7202                	ld	tp,32(sp)
ffffffffc02007c6:	72a2                	ld	t0,40(sp)
ffffffffc02007c8:	7342                	ld	t1,48(sp)
ffffffffc02007ca:	73e2                	ld	t2,56(sp)
ffffffffc02007cc:	6406                	ld	s0,64(sp)
ffffffffc02007ce:	64a6                	ld	s1,72(sp)
ffffffffc02007d0:	6546                	ld	a0,80(sp)
ffffffffc02007d2:	65e6                	ld	a1,88(sp)
ffffffffc02007d4:	7606                	ld	a2,96(sp)
ffffffffc02007d6:	76a6                	ld	a3,104(sp)
ffffffffc02007d8:	7746                	ld	a4,112(sp)
ffffffffc02007da:	77e6                	ld	a5,120(sp)
ffffffffc02007dc:	680a                	ld	a6,128(sp)
ffffffffc02007de:	68aa                	ld	a7,136(sp)
ffffffffc02007e0:	694a                	ld	s2,144(sp)
ffffffffc02007e2:	69ea                	ld	s3,152(sp)
ffffffffc02007e4:	7a0a                	ld	s4,160(sp)
ffffffffc02007e6:	7aaa                	ld	s5,168(sp)
ffffffffc02007e8:	7b4a                	ld	s6,176(sp)
ffffffffc02007ea:	7bea                	ld	s7,184(sp)
ffffffffc02007ec:	6c0e                	ld	s8,192(sp)
ffffffffc02007ee:	6cae                	ld	s9,200(sp)
ffffffffc02007f0:	6d4e                	ld	s10,208(sp)
ffffffffc02007f2:	6dee                	ld	s11,216(sp)
ffffffffc02007f4:	7e0e                	ld	t3,224(sp)
ffffffffc02007f6:	7eae                	ld	t4,232(sp)
ffffffffc02007f8:	7f4e                	ld	t5,240(sp)
ffffffffc02007fa:	7fee                	ld	t6,248(sp)
ffffffffc02007fc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02007fe:	10200073          	sret

ffffffffc0200802 <buddy_system_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200802:	00006797          	auipc	a5,0x6
ffffffffc0200806:	80e78793          	addi	a5,a5,-2034 # ffffffffc0206010 <free_area>
ffffffffc020080a:	e79c                	sd	a5,8(a5)
ffffffffc020080c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
buddy_system_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020080e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200812:	8082                	ret

ffffffffc0200814 <buddy_system_nr_free_pages>:
}

static size_t
buddy_system_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200814:	00006517          	auipc	a0,0x6
ffffffffc0200818:	80c56503          	lwu	a0,-2036(a0) # ffffffffc0206020 <free_area+0x10>
ffffffffc020081c:	8082                	ret

ffffffffc020081e <buddy_system_free_pages>:
buddy_system_free_pages(struct Page *base, size_t n) {
ffffffffc020081e:	1141                	addi	sp,sp,-16
ffffffffc0200820:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200822:	16058f63          	beqz	a1,ffffffffc02009a0 <buddy_system_free_pages+0x182>
    while(p -> property == 0) {
ffffffffc0200826:	491c                	lw	a5,16(a0)
ffffffffc0200828:	862a                	mv	a2,a0
ffffffffc020082a:	86be                	mv	a3,a5
ffffffffc020082c:	eb91                	bnez	a5,ffffffffc0200840 <buddy_system_free_pages+0x22>
ffffffffc020082e:	fe062683          	lw	a3,-32(a2)
        flag++;
ffffffffc0200832:	2785                	addiw	a5,a5,1
        p--;
ffffffffc0200834:	fd060613          	addi	a2,a2,-48
    while(p -> property == 0) {
ffffffffc0200838:	dafd                	beqz	a3,ffffffffc020082e <buddy_system_free_pages+0x10>
    assert(flag + n <= size);
ffffffffc020083a:	1782                	slli	a5,a5,0x20
ffffffffc020083c:	9381                	srli	a5,a5,0x20
ffffffffc020083e:	95be                	add	a1,a1,a5
ffffffffc0200840:	02069793          	slli	a5,a3,0x20
ffffffffc0200844:	9381                	srli	a5,a5,0x20
ffffffffc0200846:	16b7ed63          	bltu	a5,a1,ffffffffc02009c0 <buddy_system_free_pages+0x1a2>
    for (; p != base + size; p ++) {
ffffffffc020084a:	00179593          	slli	a1,a5,0x1
ffffffffc020084e:	95be                	add	a1,a1,a5
ffffffffc0200850:	0592                	slli	a1,a1,0x4
ffffffffc0200852:	95aa                	add	a1,a1,a0
ffffffffc0200854:	87b2                	mv	a5,a2
ffffffffc0200856:	02b60263          	beq	a2,a1,ffffffffc020087a <buddy_system_free_pages+0x5c>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020085a:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020085c:	8b05                	andi	a4,a4,1
ffffffffc020085e:	12071163          	bnez	a4,ffffffffc0200980 <buddy_system_free_pages+0x162>
ffffffffc0200862:	6798                	ld	a4,8(a5)
ffffffffc0200864:	8b09                	andi	a4,a4,2
ffffffffc0200866:	10071d63          	bnez	a4,ffffffffc0200980 <buddy_system_free_pages+0x162>
        p->flags = 0;
ffffffffc020086a:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020086e:	0007a023          	sw	zero,0(a5)
    for (; p != base + size; p ++) {
ffffffffc0200872:	03078793          	addi	a5,a5,48
ffffffffc0200876:	feb792e3          	bne	a5,a1,ffffffffc020085a <buddy_system_free_pages+0x3c>
    b->property = size;
ffffffffc020087a:	ca14                	sw	a3,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020087c:	4789                	li	a5,2
ffffffffc020087e:	00860713          	addi	a4,a2,8
ffffffffc0200882:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += size;
ffffffffc0200886:	00005597          	auipc	a1,0x5
ffffffffc020088a:	78a58593          	addi	a1,a1,1930 # ffffffffc0206010 <free_area>
ffffffffc020088e:	4998                	lw	a4,16(a1)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
ffffffffc0200890:	659c                	ld	a5,8(a1)
        list_add(&free_list, &(b->page_link));
ffffffffc0200892:	01860513          	addi	a0,a2,24
    nr_free += size;
ffffffffc0200896:	9f35                	addw	a4,a4,a3
ffffffffc0200898:	c998                	sw	a4,16(a1)
    if (list_empty(&free_list)) {
ffffffffc020089a:	0cb78e63          	beq	a5,a1,ffffffffc0200976 <buddy_system_free_pages+0x158>
            p = le2page(le, page_link);
ffffffffc020089e:	fe878713          	addi	a4,a5,-24
ffffffffc02008a2:	0005b883          	ld	a7,0(a1)
    if (list_empty(&free_list)) {
ffffffffc02008a6:	4801                	li	a6,0
            if (b < p) {
ffffffffc02008a8:	00e66a63          	bltu	a2,a4,ffffffffc02008bc <buddy_system_free_pages+0x9e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02008ac:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02008ae:	02b70f63          	beq	a4,a1,ffffffffc02008ec <buddy_system_free_pages+0xce>
    for (; p != base + size; p ++) {
ffffffffc02008b2:	87ba                	mv	a5,a4
            p = le2page(le, page_link);
ffffffffc02008b4:	fe878713          	addi	a4,a5,-24
            if (b < p) {
ffffffffc02008b8:	fee67ae3          	bgeu	a2,a4,ffffffffc02008ac <buddy_system_free_pages+0x8e>
ffffffffc02008bc:	00080463          	beqz	a6,ffffffffc02008c4 <buddy_system_free_pages+0xa6>
ffffffffc02008c0:	0115b023          	sd	a7,0(a1)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02008c4:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02008c6:	e388                	sd	a0,0(a5)
ffffffffc02008c8:	e708                	sd	a0,8(a4)
    elm->next = next;
ffffffffc02008ca:	f21c                	sd	a5,32(a2)
    elm->prev = prev;
ffffffffc02008cc:	ee18                	sd	a4,24(a2)
ffffffffc02008ce:	560c                	lw	a1,40(a2)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02008d0:	5875                	li	a6,-3
        if (((b -> location / b -> property) & 1 )
ffffffffc02008d2:	4a18                	lw	a4,16(a2)
ffffffffc02008d4:	02e5d7bb          	divuw	a5,a1,a4
ffffffffc02008d8:	8b85                	andi	a5,a5,1
ffffffffc02008da:	c39d                	beqz	a5,ffffffffc0200900 <buddy_system_free_pages+0xe2>
         && le2page(b -> page_link.prev,page_link) -> location == b -> location - size
ffffffffc02008dc:	6e1c                	ld	a5,24(a2)
ffffffffc02008de:	9d95                	subw	a1,a1,a3
ffffffffc02008e0:	4b9c                	lw	a5,16(a5)
ffffffffc02008e2:	04b78e63          	beq	a5,a1,ffffffffc020093e <buddy_system_free_pages+0x120>
}
ffffffffc02008e6:	60a2                	ld	ra,8(sp)
ffffffffc02008e8:	0141                	addi	sp,sp,16
ffffffffc02008ea:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02008ec:	e788                	sd	a0,8(a5)
    elm->next = next;
ffffffffc02008ee:	f20c                	sd	a1,32(a2)
    return listelm->next;
ffffffffc02008f0:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02008f2:	ee1c                	sd	a5,24(a2)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02008f4:	06b70f63          	beq	a4,a1,ffffffffc0200972 <buddy_system_free_pages+0x154>
    prev->next = next->prev = elm;
ffffffffc02008f8:	88aa                	mv	a7,a0
ffffffffc02008fa:	4805                	li	a6,1
    for (; p != base + size; p ++) {
ffffffffc02008fc:	87ba                	mv	a5,a4
ffffffffc02008fe:	bf5d                	j	ffffffffc02008b4 <buddy_system_free_pages+0x96>
         && le2page(b -> page_link.next,page_link) -> location == b -> location + size
ffffffffc0200900:	7208                	ld	a0,32(a2)
ffffffffc0200902:	00d587bb          	addw	a5,a1,a3
ffffffffc0200906:	4908                	lw	a0,16(a0)
ffffffffc0200908:	fcf51fe3          	bne	a0,a5,ffffffffc02008e6 <buddy_system_free_pages+0xc8>
         && (b+size) -> property == size) {
ffffffffc020090c:	02069513          	slli	a0,a3,0x20
ffffffffc0200910:	9101                	srli	a0,a0,0x20
ffffffffc0200912:	00151793          	slli	a5,a0,0x1
ffffffffc0200916:	97aa                	add	a5,a5,a0
ffffffffc0200918:	0792                	slli	a5,a5,0x4
ffffffffc020091a:	97b2                	add	a5,a5,a2
ffffffffc020091c:	4b88                	lw	a0,16(a5)
ffffffffc020091e:	fcd514e3          	bne	a0,a3,ffffffffc02008e6 <buddy_system_free_pages+0xc8>
            b -> property *= 2;
ffffffffc0200922:	0017171b          	slliw	a4,a4,0x1
ffffffffc0200926:	ca18                	sw	a4,16(a2)
ffffffffc0200928:	00878713          	addi	a4,a5,8
ffffffffc020092c:	6107302f          	amoand.d	zero,a6,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200930:	6f98                	ld	a4,24(a5)
ffffffffc0200932:	739c                	ld	a5,32(a5)
            size *= 2;
ffffffffc0200934:	0016969b          	slliw	a3,a3,0x1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200938:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020093a:	e398                	sd	a4,0(a5)
ffffffffc020093c:	bf59                	j	ffffffffc02008d2 <buddy_system_free_pages+0xb4>
         && (b-size) -> property == size) {
ffffffffc020093e:	02069713          	slli	a4,a3,0x20
ffffffffc0200942:	9301                	srli	a4,a4,0x20
ffffffffc0200944:	00171793          	slli	a5,a4,0x1
ffffffffc0200948:	97ba                	add	a5,a5,a4
ffffffffc020094a:	0792                	slli	a5,a5,0x4
ffffffffc020094c:	40f607b3          	sub	a5,a2,a5
ffffffffc0200950:	4b98                	lw	a4,16(a5)
ffffffffc0200952:	f8e69ae3          	bne	a3,a4,ffffffffc02008e6 <buddy_system_free_pages+0xc8>
            p -> property *= 2;
ffffffffc0200956:	0016969b          	slliw	a3,a3,0x1
ffffffffc020095a:	cb94                	sw	a3,16(a5)
ffffffffc020095c:	00860713          	addi	a4,a2,8
ffffffffc0200960:	6107302f          	amoand.d	zero,a6,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200964:	6e08                	ld	a0,24(a2)
ffffffffc0200966:	7218                	ld	a4,32(a2)
    prev->next = next;
ffffffffc0200968:	578c                	lw	a1,40(a5)
            size *= 2;
ffffffffc020096a:	863e                	mv	a2,a5
ffffffffc020096c:	e518                	sd	a4,8(a0)
    next->prev = prev;
ffffffffc020096e:	e308                	sd	a0,0(a4)
ffffffffc0200970:	b78d                	j	ffffffffc02008d2 <buddy_system_free_pages+0xb4>
ffffffffc0200972:	e188                	sd	a0,0(a1)
ffffffffc0200974:	bfa9                	j	ffffffffc02008ce <buddy_system_free_pages+0xb0>
    prev->next = next->prev = elm;
ffffffffc0200976:	e388                	sd	a0,0(a5)
ffffffffc0200978:	e788                	sd	a0,8(a5)
    elm->next = next;
ffffffffc020097a:	f21c                	sd	a5,32(a2)
    elm->prev = prev;
ffffffffc020097c:	ee1c                	sd	a5,24(a2)
}
ffffffffc020097e:	bf81                	j	ffffffffc02008ce <buddy_system_free_pages+0xb0>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200980:	00001697          	auipc	a3,0x1
ffffffffc0200984:	59068693          	addi	a3,a3,1424 # ffffffffc0201f10 <commands+0x550>
ffffffffc0200988:	00001617          	auipc	a2,0x1
ffffffffc020098c:	53860613          	addi	a2,a2,1336 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200990:	06c00593          	li	a1,108
ffffffffc0200994:	00001517          	auipc	a0,0x1
ffffffffc0200998:	54450513          	addi	a0,a0,1348 # ffffffffc0201ed8 <commands+0x518>
ffffffffc020099c:	a11ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc02009a0:	00001697          	auipc	a3,0x1
ffffffffc02009a4:	51868693          	addi	a3,a3,1304 # ffffffffc0201eb8 <commands+0x4f8>
ffffffffc02009a8:	00001617          	auipc	a2,0x1
ffffffffc02009ac:	51860613          	addi	a2,a2,1304 # ffffffffc0201ec0 <commands+0x500>
ffffffffc02009b0:	06100593          	li	a1,97
ffffffffc02009b4:	00001517          	auipc	a0,0x1
ffffffffc02009b8:	52450513          	addi	a0,a0,1316 # ffffffffc0201ed8 <commands+0x518>
ffffffffc02009bc:	9f1ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(flag + n <= size);
ffffffffc02009c0:	00001697          	auipc	a3,0x1
ffffffffc02009c4:	53868693          	addi	a3,a3,1336 # ffffffffc0201ef8 <commands+0x538>
ffffffffc02009c8:	00001617          	auipc	a2,0x1
ffffffffc02009cc:	4f860613          	addi	a2,a2,1272 # ffffffffc0201ec0 <commands+0x500>
ffffffffc02009d0:	06900593          	li	a1,105
ffffffffc02009d4:	00001517          	auipc	a0,0x1
ffffffffc02009d8:	50450513          	addi	a0,a0,1284 # ffffffffc0201ed8 <commands+0x518>
ffffffffc02009dc:	9d1ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02009e0 <buddy_system_alloc_pages>:
    assert(n > 0);
ffffffffc02009e0:	c945                	beqz	a0,ffffffffc0200a90 <buddy_system_alloc_pages+0xb0>
    if (n > nr_free) {
ffffffffc02009e2:	00005e17          	auipc	t3,0x5
ffffffffc02009e6:	62ee0e13          	addi	t3,t3,1582 # ffffffffc0206010 <free_area>
ffffffffc02009ea:	010e2f03          	lw	t5,16(t3)
ffffffffc02009ee:	832a                	mv	t1,a0
ffffffffc02009f0:	020f1793          	slli	a5,t5,0x20
ffffffffc02009f4:	9381                	srli	a5,a5,0x20
ffffffffc02009f6:	00a7ee63          	bltu	a5,a0,ffffffffc0200a12 <buddy_system_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02009fa:	8772                	mv	a4,t3
ffffffffc02009fc:	a801                	j	ffffffffc0200a0c <buddy_system_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02009fe:	ff872803          	lw	a6,-8(a4)
ffffffffc0200a02:	02081793          	slli	a5,a6,0x20
ffffffffc0200a06:	9381                	srli	a5,a5,0x20
ffffffffc0200a08:	0067f763          	bgeu	a5,t1,ffffffffc0200a16 <buddy_system_alloc_pages+0x36>
    return listelm->next;
ffffffffc0200a0c:	6718                	ld	a4,8(a4)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200a0e:	ffc718e3          	bne	a4,t3,ffffffffc02009fe <buddy_system_alloc_pages+0x1e>
        return NULL;
ffffffffc0200a12:	4501                	li	a0,0
}
ffffffffc0200a14:	8082                	ret
        while(page -> property / 2 >= n){
ffffffffc0200a16:	0018589b          	srliw	a7,a6,0x1
ffffffffc0200a1a:	6710                	ld	a2,8(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200a1c:	630c                	ld	a1,0(a4)
        struct Page *p = le2page(le, page_link);
ffffffffc0200a1e:	fe870513          	addi	a0,a4,-24
        while(page -> property / 2 >= n){
ffffffffc0200a22:	86c6                	mv	a3,a7
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200a24:	4e89                	li	t4,2
ffffffffc0200a26:	0468ea63          	bltu	a7,t1,ffffffffc0200a7a <buddy_system_alloc_pages+0x9a>
            p = page + page -> property / 2;
ffffffffc0200a2a:	00189793          	slli	a5,a7,0x1
ffffffffc0200a2e:	97c6                	add	a5,a5,a7
    prev->next = next;
ffffffffc0200a30:	e590                	sd	a2,8(a1)
ffffffffc0200a32:	0792                	slli	a5,a5,0x4
ffffffffc0200a34:	97aa                	add	a5,a5,a0
    next->prev = prev;
ffffffffc0200a36:	e20c                	sd	a1,0(a2)
            p -> property = page -> property / 2;
ffffffffc0200a38:	cb94                	sw	a3,16(a5)
ffffffffc0200a3a:	00878693          	addi	a3,a5,8
ffffffffc0200a3e:	41d6b02f          	amoor.d	zero,t4,(a3)
            page -> property /= 2;
ffffffffc0200a42:	ff872683          	lw	a3,-8(a4)
ffffffffc0200a46:	8832                	mv	a6,a2
            list_add_before(next, &(p -> page_link));
ffffffffc0200a48:	01878613          	addi	a2,a5,24
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200a4c:	00083583          	ld	a1,0(a6)
    prev->next = next->prev = elm;
ffffffffc0200a50:	00c83023          	sd	a2,0(a6)
    elm->next = next;
ffffffffc0200a54:	0307b023          	sd	a6,32(a5)
            page -> property /= 2;
ffffffffc0200a58:	0016d81b          	srliw	a6,a3,0x1
ffffffffc0200a5c:	ff072c23          	sw	a6,-8(a4)
    prev->next = next->prev = elm;
ffffffffc0200a60:	ef98                	sd	a4,24(a5)
ffffffffc0200a62:	e598                	sd	a4,8(a1)
        while(page -> property / 2 >= n){
ffffffffc0200a64:	0026d89b          	srliw	a7,a3,0x2
    elm->next = next;
ffffffffc0200a68:	e710                	sd	a2,8(a4)
    elm->prev = prev;
ffffffffc0200a6a:	e30c                	sd	a1,0(a4)
            page -> property /= 2;
ffffffffc0200a6c:	0016d81b          	srliw	a6,a3,0x1
        while(page -> property / 2 >= n){
ffffffffc0200a70:	86c6                	mv	a3,a7
ffffffffc0200a72:	fa68fce3          	bgeu	a7,t1,ffffffffc0200a2a <buddy_system_alloc_pages+0x4a>
        nr_free -= page -> property;
ffffffffc0200a76:	010e2f03          	lw	t5,16(t3)
    prev->next = next;
ffffffffc0200a7a:	e590                	sd	a2,8(a1)
    next->prev = prev;
ffffffffc0200a7c:	e20c                	sd	a1,0(a2)
ffffffffc0200a7e:	410f083b          	subw	a6,t5,a6
ffffffffc0200a82:	010e2823          	sw	a6,16(t3)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200a86:	57f5                	li	a5,-3
ffffffffc0200a88:	1741                	addi	a4,a4,-16
ffffffffc0200a8a:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc0200a8e:	8082                	ret
buddy_system_alloc_pages(size_t n) {
ffffffffc0200a90:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200a92:	00001697          	auipc	a3,0x1
ffffffffc0200a96:	42668693          	addi	a3,a3,1062 # ffffffffc0201eb8 <commands+0x4f8>
ffffffffc0200a9a:	00001617          	auipc	a2,0x1
ffffffffc0200a9e:	42660613          	addi	a2,a2,1062 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200aa2:	03e00593          	li	a1,62
ffffffffc0200aa6:	00001517          	auipc	a0,0x1
ffffffffc0200aaa:	43250513          	addi	a0,a0,1074 # ffffffffc0201ed8 <commands+0x518>
buddy_system_alloc_pages(size_t n) {
ffffffffc0200aae:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200ab0:	8fdff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200ab4 <buddy_system_init_memmap>:
buddy_system_init_memmap(struct Page *base, size_t n) {
ffffffffc0200ab4:	1141                	addi	sp,sp,-16
ffffffffc0200ab6:	e406                	sd	ra,8(sp)
ffffffffc0200ab8:	4785                	li	a5,1
    assert(n > 0);
ffffffffc0200aba:	c1dd                	beqz	a1,ffffffffc0200b60 <buddy_system_init_memmap+0xac>
        size <<= 1;
ffffffffc0200abc:	0017971b          	slliw	a4,a5,0x1
    while (size <= n) {
ffffffffc0200ac0:	02071693          	slli	a3,a4,0x20
ffffffffc0200ac4:	9281                	srli	a3,a3,0x20
ffffffffc0200ac6:	0007861b          	sext.w	a2,a5
        size <<= 1;
ffffffffc0200aca:	0007079b          	sext.w	a5,a4
    while (size <= n) {
ffffffffc0200ace:	fed5f7e3          	bgeu	a1,a3,ffffffffc0200abc <buddy_system_init_memmap+0x8>
    size >>= 1;
ffffffffc0200ad2:	02161793          	slli	a5,a2,0x21
    for (; p != base + size; p ++) {
ffffffffc0200ad6:	0217d713          	srli	a4,a5,0x21
ffffffffc0200ada:	0207d613          	srli	a2,a5,0x20
ffffffffc0200ade:	963a                	add	a2,a2,a4
ffffffffc0200ae0:	0612                	slli	a2,a2,0x4
ffffffffc0200ae2:	962a                	add	a2,a2,a0
    size >>= 1;
ffffffffc0200ae4:	85ba                	mv	a1,a4
    for (; p != base + size; p ++) {
ffffffffc0200ae6:	02c50363          	beq	a0,a2,ffffffffc0200b0c <buddy_system_init_memmap+0x58>
ffffffffc0200aea:	87aa                	mv	a5,a0
    unsigned index = 0;
ffffffffc0200aec:	4681                	li	a3,0
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200aee:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200af0:	8b05                	andi	a4,a4,1
ffffffffc0200af2:	cb21                	beqz	a4,ffffffffc0200b42 <buddy_system_init_memmap+0x8e>
        p -> location = index;
ffffffffc0200af4:	d794                	sw	a3,40(a5)
        p->flags = p->property = 0;
ffffffffc0200af6:	0007a823          	sw	zero,16(a5)
ffffffffc0200afa:	0007b423          	sd	zero,8(a5)
ffffffffc0200afe:	0007a023          	sw	zero,0(a5)
    for (; p != base + size; p ++) {
ffffffffc0200b02:	03078793          	addi	a5,a5,48
        index++;
ffffffffc0200b06:	2685                	addiw	a3,a3,1
    for (; p != base + size; p ++) {
ffffffffc0200b08:	fec793e3          	bne	a5,a2,ffffffffc0200aee <buddy_system_init_memmap+0x3a>
    base -> property = size;
ffffffffc0200b0c:	c90c                	sw	a1,16(a0)
    base -> location = 0;
ffffffffc0200b0e:	02052423          	sw	zero,40(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200b12:	4789                	li	a5,2
ffffffffc0200b14:	00850713          	addi	a4,a0,8
ffffffffc0200b18:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += size;
ffffffffc0200b1c:	00005697          	auipc	a3,0x5
ffffffffc0200b20:	4f468693          	addi	a3,a3,1268 # ffffffffc0206010 <free_area>
ffffffffc0200b24:	4a9c                	lw	a5,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0200b26:	6698                	ld	a4,8(a3)
    nr_free += size;
ffffffffc0200b28:	9fad                	addw	a5,a5,a1
ffffffffc0200b2a:	ca9c                	sw	a5,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0200b2c:	04d71963          	bne	a4,a3,ffffffffc0200b7e <buddy_system_init_memmap+0xca>
}
ffffffffc0200b30:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0200b32:	01850793          	addi	a5,a0,24
    prev->next = next->prev = elm;
ffffffffc0200b36:	e31c                	sd	a5,0(a4)
ffffffffc0200b38:	e71c                	sd	a5,8(a4)
    elm->next = next;
ffffffffc0200b3a:	f118                	sd	a4,32(a0)
    elm->prev = prev;
ffffffffc0200b3c:	ed18                	sd	a4,24(a0)
}
ffffffffc0200b3e:	0141                	addi	sp,sp,16
ffffffffc0200b40:	8082                	ret
        assert(PageReserved(p));
ffffffffc0200b42:	00001697          	auipc	a3,0x1
ffffffffc0200b46:	3f668693          	addi	a3,a3,1014 # ffffffffc0201f38 <commands+0x578>
ffffffffc0200b4a:	00001617          	auipc	a2,0x1
ffffffffc0200b4e:	37660613          	addi	a2,a2,886 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200b52:	45f5                	li	a1,29
ffffffffc0200b54:	00001517          	auipc	a0,0x1
ffffffffc0200b58:	38450513          	addi	a0,a0,900 # ffffffffc0201ed8 <commands+0x518>
ffffffffc0200b5c:	851ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200b60:	00001697          	auipc	a3,0x1
ffffffffc0200b64:	35868693          	addi	a3,a3,856 # ffffffffc0201eb8 <commands+0x4f8>
ffffffffc0200b68:	00001617          	auipc	a2,0x1
ffffffffc0200b6c:	35860613          	addi	a2,a2,856 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200b70:	45d1                	li	a1,20
ffffffffc0200b72:	00001517          	auipc	a0,0x1
ffffffffc0200b76:	36650513          	addi	a0,a0,870 # ffffffffc0201ed8 <commands+0x518>
ffffffffc0200b7a:	833ff0ef          	jal	ra,ffffffffc02003ac <__panic>
        assert(0);
ffffffffc0200b7e:	00001697          	auipc	a3,0x1
ffffffffc0200b82:	3ca68693          	addi	a3,a3,970 # ffffffffc0201f48 <commands+0x588>
ffffffffc0200b86:	00001617          	auipc	a2,0x1
ffffffffc0200b8a:	33a60613          	addi	a2,a2,826 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200b8e:	02b00593          	li	a1,43
ffffffffc0200b92:	00001517          	auipc	a0,0x1
ffffffffc0200b96:	34650513          	addi	a0,a0,838 # ffffffffc0201ed8 <commands+0x518>
ffffffffc0200b9a:	813ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200b9e <buddy_system_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
buddy_system_check(void) {
ffffffffc0200b9e:	7139                	addi	sp,sp,-64
ffffffffc0200ba0:	f426                	sd	s1,40(sp)
    return listelm->next;
ffffffffc0200ba2:	00005497          	auipc	s1,0x5
ffffffffc0200ba6:	46e48493          	addi	s1,s1,1134 # ffffffffc0206010 <free_area>
ffffffffc0200baa:	649c                	ld	a5,8(s1)
ffffffffc0200bac:	fc06                	sd	ra,56(sp)
ffffffffc0200bae:	f822                	sd	s0,48(sp)
ffffffffc0200bb0:	f04a                	sd	s2,32(sp)
ffffffffc0200bb2:	ec4e                	sd	s3,24(sp)
ffffffffc0200bb4:	e852                	sd	s4,16(sp)
ffffffffc0200bb6:	e456                	sd	s5,8(sp)
ffffffffc0200bb8:	e05a                	sd	s6,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bba:	18978563          	beq	a5,s1,ffffffffc0200d44 <buddy_system_check+0x1a6>
    int count = 0, total = 0;
ffffffffc0200bbe:	4681                	li	a3,0
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200bc0:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200bc4:	8b09                	andi	a4,a4,2
ffffffffc0200bc6:	18070163          	beqz	a4,ffffffffc0200d48 <buddy_system_check+0x1aa>
        count ++, total += p->property;
ffffffffc0200bca:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200bce:	679c                	ld	a5,8(a5)
ffffffffc0200bd0:	9eb9                	addw	a3,a3,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bd2:	fe9797e3          	bne	a5,s1,ffffffffc0200bc0 <buddy_system_check+0x22>
    }
    assert(total == nr_free_pages());
ffffffffc0200bd6:	8436                	mv	s0,a3
ffffffffc0200bd8:	46e000ef          	jal	ra,ffffffffc0201046 <nr_free_pages>
ffffffffc0200bdc:	3c851663          	bne	a0,s0,ffffffffc0200fa8 <buddy_system_check+0x40a>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200be0:	4505                	li	a0,1
ffffffffc0200be2:	3e6000ef          	jal	ra,ffffffffc0200fc8 <alloc_pages>
ffffffffc0200be6:	89aa                	mv	s3,a0
ffffffffc0200be8:	3a050063          	beqz	a0,ffffffffc0200f88 <buddy_system_check+0x3ea>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200bec:	4505                	li	a0,1
ffffffffc0200bee:	3da000ef          	jal	ra,ffffffffc0200fc8 <alloc_pages>
ffffffffc0200bf2:	842a                	mv	s0,a0
ffffffffc0200bf4:	36050a63          	beqz	a0,ffffffffc0200f68 <buddy_system_check+0x3ca>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200bf8:	4505                	li	a0,1
ffffffffc0200bfa:	3ce000ef          	jal	ra,ffffffffc0200fc8 <alloc_pages>
ffffffffc0200bfe:	892a                	mv	s2,a0
ffffffffc0200c00:	22050463          	beqz	a0,ffffffffc0200e28 <buddy_system_check+0x28a>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c04:	16898263          	beq	s3,s0,ffffffffc0200d68 <buddy_system_check+0x1ca>
ffffffffc0200c08:	16a98063          	beq	s3,a0,ffffffffc0200d68 <buddy_system_check+0x1ca>
ffffffffc0200c0c:	14a40e63          	beq	s0,a0,ffffffffc0200d68 <buddy_system_check+0x1ca>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c10:	0009a783          	lw	a5,0(s3)
ffffffffc0200c14:	16079a63          	bnez	a5,ffffffffc0200d88 <buddy_system_check+0x1ea>
ffffffffc0200c18:	401c                	lw	a5,0(s0)
ffffffffc0200c1a:	16079763          	bnez	a5,ffffffffc0200d88 <buddy_system_check+0x1ea>
ffffffffc0200c1e:	411c                	lw	a5,0(a0)
ffffffffc0200c20:	16079463          	bnez	a5,ffffffffc0200d88 <buddy_system_check+0x1ea>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c24:	00006797          	auipc	a5,0x6
ffffffffc0200c28:	81c7b783          	ld	a5,-2020(a5) # ffffffffc0206440 <pages>
ffffffffc0200c2c:	40f98733          	sub	a4,s3,a5
ffffffffc0200c30:	8711                	srai	a4,a4,0x4
ffffffffc0200c32:	00002597          	auipc	a1,0x2
ffffffffc0200c36:	8ae5b583          	ld	a1,-1874(a1) # ffffffffc02024e0 <error_string+0x38>
ffffffffc0200c3a:	02b70733          	mul	a4,a4,a1
ffffffffc0200c3e:	00002617          	auipc	a2,0x2
ffffffffc0200c42:	8aa63603          	ld	a2,-1878(a2) # ffffffffc02024e8 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c46:	00005697          	auipc	a3,0x5
ffffffffc0200c4a:	7f26b683          	ld	a3,2034(a3) # ffffffffc0206438 <npage>
ffffffffc0200c4e:	06b2                	slli	a3,a3,0xc
ffffffffc0200c50:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c52:	0732                	slli	a4,a4,0xc
ffffffffc0200c54:	1ed77a63          	bgeu	a4,a3,ffffffffc0200e48 <buddy_system_check+0x2aa>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c58:	40f40733          	sub	a4,s0,a5
ffffffffc0200c5c:	8711                	srai	a4,a4,0x4
ffffffffc0200c5e:	02b70733          	mul	a4,a4,a1
ffffffffc0200c62:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c64:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200c66:	1ad77163          	bgeu	a4,a3,ffffffffc0200e08 <buddy_system_check+0x26a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c6a:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c6e:	8791                	srai	a5,a5,0x4
ffffffffc0200c70:	02b787b3          	mul	a5,a5,a1
ffffffffc0200c74:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c76:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c78:	22d7f863          	bgeu	a5,a3,ffffffffc0200ea8 <buddy_system_check+0x30a>
    assert(alloc_page() == NULL);
ffffffffc0200c7c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c7e:	0004bb03          	ld	s6,0(s1)
ffffffffc0200c82:	0084ba83          	ld	s5,8(s1)
    unsigned int nr_free_store = nr_free;
ffffffffc0200c86:	0104aa03          	lw	s4,16(s1)
    elm->prev = elm->next = elm;
ffffffffc0200c8a:	e484                	sd	s1,8(s1)
ffffffffc0200c8c:	e084                	sd	s1,0(s1)
    nr_free = 0;
ffffffffc0200c8e:	00005797          	auipc	a5,0x5
ffffffffc0200c92:	3807a923          	sw	zero,914(a5) # ffffffffc0206020 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200c96:	332000ef          	jal	ra,ffffffffc0200fc8 <alloc_pages>
ffffffffc0200c9a:	1e051763          	bnez	a0,ffffffffc0200e88 <buddy_system_check+0x2ea>
    free_page(p0);
ffffffffc0200c9e:	4585                	li	a1,1
ffffffffc0200ca0:	854e                	mv	a0,s3
ffffffffc0200ca2:	364000ef          	jal	ra,ffffffffc0201006 <free_pages>
    free_page(p1);
ffffffffc0200ca6:	4585                	li	a1,1
ffffffffc0200ca8:	8522                	mv	a0,s0
ffffffffc0200caa:	35c000ef          	jal	ra,ffffffffc0201006 <free_pages>
    free_page(p2);
ffffffffc0200cae:	4585                	li	a1,1
ffffffffc0200cb0:	854a                	mv	a0,s2
ffffffffc0200cb2:	354000ef          	jal	ra,ffffffffc0201006 <free_pages>
    assert(nr_free == 3);
ffffffffc0200cb6:	4898                	lw	a4,16(s1)
ffffffffc0200cb8:	478d                	li	a5,3
ffffffffc0200cba:	1af71763          	bne	a4,a5,ffffffffc0200e68 <buddy_system_check+0x2ca>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cbe:	4505                	li	a0,1
ffffffffc0200cc0:	308000ef          	jal	ra,ffffffffc0200fc8 <alloc_pages>
ffffffffc0200cc4:	842a                	mv	s0,a0
ffffffffc0200cc6:	28050163          	beqz	a0,ffffffffc0200f48 <buddy_system_check+0x3aa>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200cca:	4505                	li	a0,1
ffffffffc0200ccc:	2fc000ef          	jal	ra,ffffffffc0200fc8 <alloc_pages>
ffffffffc0200cd0:	89aa                	mv	s3,a0
ffffffffc0200cd2:	24050b63          	beqz	a0,ffffffffc0200f28 <buddy_system_check+0x38a>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200cd6:	4505                	li	a0,1
ffffffffc0200cd8:	2f0000ef          	jal	ra,ffffffffc0200fc8 <alloc_pages>
ffffffffc0200cdc:	892a                	mv	s2,a0
ffffffffc0200cde:	22050563          	beqz	a0,ffffffffc0200f08 <buddy_system_check+0x36a>
    assert(alloc_page() == NULL);
ffffffffc0200ce2:	4505                	li	a0,1
ffffffffc0200ce4:	2e4000ef          	jal	ra,ffffffffc0200fc8 <alloc_pages>
ffffffffc0200ce8:	20051063          	bnez	a0,ffffffffc0200ee8 <buddy_system_check+0x34a>
    free_page(p0);
ffffffffc0200cec:	4585                	li	a1,1
ffffffffc0200cee:	8522                	mv	a0,s0
ffffffffc0200cf0:	316000ef          	jal	ra,ffffffffc0201006 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200cf4:	649c                	ld	a5,8(s1)
ffffffffc0200cf6:	1c978963          	beq	a5,s1,ffffffffc0200ec8 <buddy_system_check+0x32a>
    assert((p = alloc_page()) == p0);
ffffffffc0200cfa:	4505                	li	a0,1
ffffffffc0200cfc:	2cc000ef          	jal	ra,ffffffffc0200fc8 <alloc_pages>
ffffffffc0200d00:	0ea41463          	bne	s0,a0,ffffffffc0200de8 <buddy_system_check+0x24a>
    assert(alloc_page() == NULL);
ffffffffc0200d04:	4505                	li	a0,1
ffffffffc0200d06:	2c2000ef          	jal	ra,ffffffffc0200fc8 <alloc_pages>
ffffffffc0200d0a:	ed5d                	bnez	a0,ffffffffc0200dc8 <buddy_system_check+0x22a>
    assert(nr_free == 0);
ffffffffc0200d0c:	489c                	lw	a5,16(s1)
ffffffffc0200d0e:	efc9                	bnez	a5,ffffffffc0200da8 <buddy_system_check+0x20a>
    free_page(p);
ffffffffc0200d10:	8522                	mv	a0,s0
ffffffffc0200d12:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200d14:	0164b023          	sd	s6,0(s1)
ffffffffc0200d18:	0154b423          	sd	s5,8(s1)
    nr_free = nr_free_store;
ffffffffc0200d1c:	0144a823          	sw	s4,16(s1)
    free_page(p);
ffffffffc0200d20:	2e6000ef          	jal	ra,ffffffffc0201006 <free_pages>
    free_page(p1);
ffffffffc0200d24:	854e                	mv	a0,s3
ffffffffc0200d26:	4585                	li	a1,1
ffffffffc0200d28:	2de000ef          	jal	ra,ffffffffc0201006 <free_pages>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
    assert(total == 0);*/
}
ffffffffc0200d2c:	7442                	ld	s0,48(sp)
ffffffffc0200d2e:	70e2                	ld	ra,56(sp)
ffffffffc0200d30:	74a2                	ld	s1,40(sp)
ffffffffc0200d32:	69e2                	ld	s3,24(sp)
ffffffffc0200d34:	6a42                	ld	s4,16(sp)
ffffffffc0200d36:	6aa2                	ld	s5,8(sp)
ffffffffc0200d38:	6b02                	ld	s6,0(sp)
    free_page(p2);
ffffffffc0200d3a:	854a                	mv	a0,s2
}
ffffffffc0200d3c:	7902                	ld	s2,32(sp)
    free_page(p2);
ffffffffc0200d3e:	4585                	li	a1,1
}
ffffffffc0200d40:	6121                	addi	sp,sp,64
    free_page(p2);
ffffffffc0200d42:	a4d1                	j	ffffffffc0201006 <free_pages>
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d44:	4401                	li	s0,0
ffffffffc0200d46:	bd49                	j	ffffffffc0200bd8 <buddy_system_check+0x3a>
        assert(PageProperty(p));
ffffffffc0200d48:	00001697          	auipc	a3,0x1
ffffffffc0200d4c:	20868693          	addi	a3,a3,520 # ffffffffc0201f50 <commands+0x590>
ffffffffc0200d50:	00001617          	auipc	a2,0x1
ffffffffc0200d54:	17060613          	addi	a2,a2,368 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200d58:	0e000593          	li	a1,224
ffffffffc0200d5c:	00001517          	auipc	a0,0x1
ffffffffc0200d60:	17c50513          	addi	a0,a0,380 # ffffffffc0201ed8 <commands+0x518>
ffffffffc0200d64:	e48ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200d68:	00001697          	auipc	a3,0x1
ffffffffc0200d6c:	27868693          	addi	a3,a3,632 # ffffffffc0201fe0 <commands+0x620>
ffffffffc0200d70:	00001617          	auipc	a2,0x1
ffffffffc0200d74:	15060613          	addi	a2,a2,336 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200d78:	0ab00593          	li	a1,171
ffffffffc0200d7c:	00001517          	auipc	a0,0x1
ffffffffc0200d80:	15c50513          	addi	a0,a0,348 # ffffffffc0201ed8 <commands+0x518>
ffffffffc0200d84:	e28ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200d88:	00001697          	auipc	a3,0x1
ffffffffc0200d8c:	28068693          	addi	a3,a3,640 # ffffffffc0202008 <commands+0x648>
ffffffffc0200d90:	00001617          	auipc	a2,0x1
ffffffffc0200d94:	13060613          	addi	a2,a2,304 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200d98:	0ac00593          	li	a1,172
ffffffffc0200d9c:	00001517          	auipc	a0,0x1
ffffffffc0200da0:	13c50513          	addi	a0,a0,316 # ffffffffc0201ed8 <commands+0x518>
ffffffffc0200da4:	e08ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200da8:	00001697          	auipc	a3,0x1
ffffffffc0200dac:	36068693          	addi	a3,a3,864 # ffffffffc0202108 <commands+0x748>
ffffffffc0200db0:	00001617          	auipc	a2,0x1
ffffffffc0200db4:	11060613          	addi	a2,a2,272 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200db8:	0cf00593          	li	a1,207
ffffffffc0200dbc:	00001517          	auipc	a0,0x1
ffffffffc0200dc0:	11c50513          	addi	a0,a0,284 # ffffffffc0201ed8 <commands+0x518>
ffffffffc0200dc4:	de8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200dc8:	00001697          	auipc	a3,0x1
ffffffffc0200dcc:	2e068693          	addi	a3,a3,736 # ffffffffc02020a8 <commands+0x6e8>
ffffffffc0200dd0:	00001617          	auipc	a2,0x1
ffffffffc0200dd4:	0f060613          	addi	a2,a2,240 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200dd8:	0cd00593          	li	a1,205
ffffffffc0200ddc:	00001517          	auipc	a0,0x1
ffffffffc0200de0:	0fc50513          	addi	a0,a0,252 # ffffffffc0201ed8 <commands+0x518>
ffffffffc0200de4:	dc8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200de8:	00001697          	auipc	a3,0x1
ffffffffc0200dec:	30068693          	addi	a3,a3,768 # ffffffffc02020e8 <commands+0x728>
ffffffffc0200df0:	00001617          	auipc	a2,0x1
ffffffffc0200df4:	0d060613          	addi	a2,a2,208 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200df8:	0cc00593          	li	a1,204
ffffffffc0200dfc:	00001517          	auipc	a0,0x1
ffffffffc0200e00:	0dc50513          	addi	a0,a0,220 # ffffffffc0201ed8 <commands+0x518>
ffffffffc0200e04:	da8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200e08:	00001697          	auipc	a3,0x1
ffffffffc0200e0c:	26068693          	addi	a3,a3,608 # ffffffffc0202068 <commands+0x6a8>
ffffffffc0200e10:	00001617          	auipc	a2,0x1
ffffffffc0200e14:	0b060613          	addi	a2,a2,176 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200e18:	0af00593          	li	a1,175
ffffffffc0200e1c:	00001517          	auipc	a0,0x1
ffffffffc0200e20:	0bc50513          	addi	a0,a0,188 # ffffffffc0201ed8 <commands+0x518>
ffffffffc0200e24:	d88ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200e28:	00001697          	auipc	a3,0x1
ffffffffc0200e2c:	19868693          	addi	a3,a3,408 # ffffffffc0201fc0 <commands+0x600>
ffffffffc0200e30:	00001617          	auipc	a2,0x1
ffffffffc0200e34:	09060613          	addi	a2,a2,144 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200e38:	0a900593          	li	a1,169
ffffffffc0200e3c:	00001517          	auipc	a0,0x1
ffffffffc0200e40:	09c50513          	addi	a0,a0,156 # ffffffffc0201ed8 <commands+0x518>
ffffffffc0200e44:	d68ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e48:	00001697          	auipc	a3,0x1
ffffffffc0200e4c:	20068693          	addi	a3,a3,512 # ffffffffc0202048 <commands+0x688>
ffffffffc0200e50:	00001617          	auipc	a2,0x1
ffffffffc0200e54:	07060613          	addi	a2,a2,112 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200e58:	0ae00593          	li	a1,174
ffffffffc0200e5c:	00001517          	auipc	a0,0x1
ffffffffc0200e60:	07c50513          	addi	a0,a0,124 # ffffffffc0201ed8 <commands+0x518>
ffffffffc0200e64:	d48ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 3);
ffffffffc0200e68:	00001697          	auipc	a3,0x1
ffffffffc0200e6c:	25868693          	addi	a3,a3,600 # ffffffffc02020c0 <commands+0x700>
ffffffffc0200e70:	00001617          	auipc	a2,0x1
ffffffffc0200e74:	05060613          	addi	a2,a2,80 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200e78:	0bf00593          	li	a1,191
ffffffffc0200e7c:	00001517          	auipc	a0,0x1
ffffffffc0200e80:	05c50513          	addi	a0,a0,92 # ffffffffc0201ed8 <commands+0x518>
ffffffffc0200e84:	d28ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e88:	00001697          	auipc	a3,0x1
ffffffffc0200e8c:	22068693          	addi	a3,a3,544 # ffffffffc02020a8 <commands+0x6e8>
ffffffffc0200e90:	00001617          	auipc	a2,0x1
ffffffffc0200e94:	03060613          	addi	a2,a2,48 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200e98:	0b900593          	li	a1,185
ffffffffc0200e9c:	00001517          	auipc	a0,0x1
ffffffffc0200ea0:	03c50513          	addi	a0,a0,60 # ffffffffc0201ed8 <commands+0x518>
ffffffffc0200ea4:	d08ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ea8:	00001697          	auipc	a3,0x1
ffffffffc0200eac:	1e068693          	addi	a3,a3,480 # ffffffffc0202088 <commands+0x6c8>
ffffffffc0200eb0:	00001617          	auipc	a2,0x1
ffffffffc0200eb4:	01060613          	addi	a2,a2,16 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200eb8:	0b000593          	li	a1,176
ffffffffc0200ebc:	00001517          	auipc	a0,0x1
ffffffffc0200ec0:	01c50513          	addi	a0,a0,28 # ffffffffc0201ed8 <commands+0x518>
ffffffffc0200ec4:	ce8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200ec8:	00001697          	auipc	a3,0x1
ffffffffc0200ecc:	20868693          	addi	a3,a3,520 # ffffffffc02020d0 <commands+0x710>
ffffffffc0200ed0:	00001617          	auipc	a2,0x1
ffffffffc0200ed4:	ff060613          	addi	a2,a2,-16 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200ed8:	0c900593          	li	a1,201
ffffffffc0200edc:	00001517          	auipc	a0,0x1
ffffffffc0200ee0:	ffc50513          	addi	a0,a0,-4 # ffffffffc0201ed8 <commands+0x518>
ffffffffc0200ee4:	cc8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ee8:	00001697          	auipc	a3,0x1
ffffffffc0200eec:	1c068693          	addi	a3,a3,448 # ffffffffc02020a8 <commands+0x6e8>
ffffffffc0200ef0:	00001617          	auipc	a2,0x1
ffffffffc0200ef4:	fd060613          	addi	a2,a2,-48 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200ef8:	0c600593          	li	a1,198
ffffffffc0200efc:	00001517          	auipc	a0,0x1
ffffffffc0200f00:	fdc50513          	addi	a0,a0,-36 # ffffffffc0201ed8 <commands+0x518>
ffffffffc0200f04:	ca8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f08:	00001697          	auipc	a3,0x1
ffffffffc0200f0c:	0b868693          	addi	a3,a3,184 # ffffffffc0201fc0 <commands+0x600>
ffffffffc0200f10:	00001617          	auipc	a2,0x1
ffffffffc0200f14:	fb060613          	addi	a2,a2,-80 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200f18:	0c300593          	li	a1,195
ffffffffc0200f1c:	00001517          	auipc	a0,0x1
ffffffffc0200f20:	fbc50513          	addi	a0,a0,-68 # ffffffffc0201ed8 <commands+0x518>
ffffffffc0200f24:	c88ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f28:	00001697          	auipc	a3,0x1
ffffffffc0200f2c:	07868693          	addi	a3,a3,120 # ffffffffc0201fa0 <commands+0x5e0>
ffffffffc0200f30:	00001617          	auipc	a2,0x1
ffffffffc0200f34:	f9060613          	addi	a2,a2,-112 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200f38:	0c200593          	li	a1,194
ffffffffc0200f3c:	00001517          	auipc	a0,0x1
ffffffffc0200f40:	f9c50513          	addi	a0,a0,-100 # ffffffffc0201ed8 <commands+0x518>
ffffffffc0200f44:	c68ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f48:	00001697          	auipc	a3,0x1
ffffffffc0200f4c:	03868693          	addi	a3,a3,56 # ffffffffc0201f80 <commands+0x5c0>
ffffffffc0200f50:	00001617          	auipc	a2,0x1
ffffffffc0200f54:	f7060613          	addi	a2,a2,-144 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200f58:	0c100593          	li	a1,193
ffffffffc0200f5c:	00001517          	auipc	a0,0x1
ffffffffc0200f60:	f7c50513          	addi	a0,a0,-132 # ffffffffc0201ed8 <commands+0x518>
ffffffffc0200f64:	c48ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f68:	00001697          	auipc	a3,0x1
ffffffffc0200f6c:	03868693          	addi	a3,a3,56 # ffffffffc0201fa0 <commands+0x5e0>
ffffffffc0200f70:	00001617          	auipc	a2,0x1
ffffffffc0200f74:	f5060613          	addi	a2,a2,-176 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200f78:	0a800593          	li	a1,168
ffffffffc0200f7c:	00001517          	auipc	a0,0x1
ffffffffc0200f80:	f5c50513          	addi	a0,a0,-164 # ffffffffc0201ed8 <commands+0x518>
ffffffffc0200f84:	c28ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f88:	00001697          	auipc	a3,0x1
ffffffffc0200f8c:	ff868693          	addi	a3,a3,-8 # ffffffffc0201f80 <commands+0x5c0>
ffffffffc0200f90:	00001617          	auipc	a2,0x1
ffffffffc0200f94:	f3060613          	addi	a2,a2,-208 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200f98:	0a700593          	li	a1,167
ffffffffc0200f9c:	00001517          	auipc	a0,0x1
ffffffffc0200fa0:	f3c50513          	addi	a0,a0,-196 # ffffffffc0201ed8 <commands+0x518>
ffffffffc0200fa4:	c08ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == nr_free_pages());
ffffffffc0200fa8:	00001697          	auipc	a3,0x1
ffffffffc0200fac:	fb868693          	addi	a3,a3,-72 # ffffffffc0201f60 <commands+0x5a0>
ffffffffc0200fb0:	00001617          	auipc	a2,0x1
ffffffffc0200fb4:	f1060613          	addi	a2,a2,-240 # ffffffffc0201ec0 <commands+0x500>
ffffffffc0200fb8:	0e300593          	li	a1,227
ffffffffc0200fbc:	00001517          	auipc	a0,0x1
ffffffffc0200fc0:	f1c50513          	addi	a0,a0,-228 # ffffffffc0201ed8 <commands+0x518>
ffffffffc0200fc4:	be8ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200fc8 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200fc8:	100027f3          	csrr	a5,sstatus
ffffffffc0200fcc:	8b89                	andi	a5,a5,2
ffffffffc0200fce:	e799                	bnez	a5,ffffffffc0200fdc <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200fd0:	00005797          	auipc	a5,0x5
ffffffffc0200fd4:	4787b783          	ld	a5,1144(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0200fd8:	6f9c                	ld	a5,24(a5)
ffffffffc0200fda:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0200fdc:	1141                	addi	sp,sp,-16
ffffffffc0200fde:	e406                	sd	ra,8(sp)
ffffffffc0200fe0:	e022                	sd	s0,0(sp)
ffffffffc0200fe2:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200fe4:	c7aff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200fe8:	00005797          	auipc	a5,0x5
ffffffffc0200fec:	4607b783          	ld	a5,1120(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0200ff0:	6f9c                	ld	a5,24(a5)
ffffffffc0200ff2:	8522                	mv	a0,s0
ffffffffc0200ff4:	9782                	jalr	a5
ffffffffc0200ff6:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200ff8:	c60ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200ffc:	60a2                	ld	ra,8(sp)
ffffffffc0200ffe:	8522                	mv	a0,s0
ffffffffc0201000:	6402                	ld	s0,0(sp)
ffffffffc0201002:	0141                	addi	sp,sp,16
ffffffffc0201004:	8082                	ret

ffffffffc0201006 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201006:	100027f3          	csrr	a5,sstatus
ffffffffc020100a:	8b89                	andi	a5,a5,2
ffffffffc020100c:	e799                	bnez	a5,ffffffffc020101a <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc020100e:	00005797          	auipc	a5,0x5
ffffffffc0201012:	43a7b783          	ld	a5,1082(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201016:	739c                	ld	a5,32(a5)
ffffffffc0201018:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc020101a:	1101                	addi	sp,sp,-32
ffffffffc020101c:	ec06                	sd	ra,24(sp)
ffffffffc020101e:	e822                	sd	s0,16(sp)
ffffffffc0201020:	e426                	sd	s1,8(sp)
ffffffffc0201022:	842a                	mv	s0,a0
ffffffffc0201024:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201026:	c38ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020102a:	00005797          	auipc	a5,0x5
ffffffffc020102e:	41e7b783          	ld	a5,1054(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201032:	739c                	ld	a5,32(a5)
ffffffffc0201034:	85a6                	mv	a1,s1
ffffffffc0201036:	8522                	mv	a0,s0
ffffffffc0201038:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020103a:	6442                	ld	s0,16(sp)
ffffffffc020103c:	60e2                	ld	ra,24(sp)
ffffffffc020103e:	64a2                	ld	s1,8(sp)
ffffffffc0201040:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201042:	c16ff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc0201046 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201046:	100027f3          	csrr	a5,sstatus
ffffffffc020104a:	8b89                	andi	a5,a5,2
ffffffffc020104c:	e799                	bnez	a5,ffffffffc020105a <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc020104e:	00005797          	auipc	a5,0x5
ffffffffc0201052:	3fa7b783          	ld	a5,1018(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201056:	779c                	ld	a5,40(a5)
ffffffffc0201058:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc020105a:	1141                	addi	sp,sp,-16
ffffffffc020105c:	e406                	sd	ra,8(sp)
ffffffffc020105e:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201060:	bfeff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201064:	00005797          	auipc	a5,0x5
ffffffffc0201068:	3e47b783          	ld	a5,996(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc020106c:	779c                	ld	a5,40(a5)
ffffffffc020106e:	9782                	jalr	a5
ffffffffc0201070:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201072:	be6ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201076:	60a2                	ld	ra,8(sp)
ffffffffc0201078:	8522                	mv	a0,s0
ffffffffc020107a:	6402                	ld	s0,0(sp)
ffffffffc020107c:	0141                	addi	sp,sp,16
ffffffffc020107e:	8082                	ret

ffffffffc0201080 <pmm_init>:
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0201080:	00001797          	auipc	a5,0x1
ffffffffc0201084:	0b878793          	addi	a5,a5,184 # ffffffffc0202138 <buddy_system_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201088:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc020108a:	1101                	addi	sp,sp,-32
ffffffffc020108c:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020108e:	00001517          	auipc	a0,0x1
ffffffffc0201092:	0e250513          	addi	a0,a0,226 # ffffffffc0202170 <buddy_system_pmm_manager+0x38>
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0201096:	00005497          	auipc	s1,0x5
ffffffffc020109a:	3b248493          	addi	s1,s1,946 # ffffffffc0206448 <pmm_manager>
void pmm_init(void) {
ffffffffc020109e:	ec06                	sd	ra,24(sp)
ffffffffc02010a0:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc02010a2:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02010a4:	80eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc02010a8:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02010aa:	00005417          	auipc	s0,0x5
ffffffffc02010ae:	3b640413          	addi	s0,s0,950 # ffffffffc0206460 <va_pa_offset>
    pmm_manager->init();
ffffffffc02010b2:	679c                	ld	a5,8(a5)
ffffffffc02010b4:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02010b6:	57f5                	li	a5,-3
ffffffffc02010b8:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02010ba:	00001517          	auipc	a0,0x1
ffffffffc02010be:	0ce50513          	addi	a0,a0,206 # ffffffffc0202188 <buddy_system_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02010c2:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc02010c4:	feffe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02010c8:	46c5                	li	a3,17
ffffffffc02010ca:	06ee                	slli	a3,a3,0x1b
ffffffffc02010cc:	40100613          	li	a2,1025
ffffffffc02010d0:	16fd                	addi	a3,a3,-1
ffffffffc02010d2:	07e005b7          	lui	a1,0x7e00
ffffffffc02010d6:	0656                	slli	a2,a2,0x15
ffffffffc02010d8:	00001517          	auipc	a0,0x1
ffffffffc02010dc:	0c850513          	addi	a0,a0,200 # ffffffffc02021a0 <buddy_system_pmm_manager+0x68>
ffffffffc02010e0:	fd3fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02010e4:	777d                	lui	a4,0xfffff
ffffffffc02010e6:	00006797          	auipc	a5,0x6
ffffffffc02010ea:	38978793          	addi	a5,a5,905 # ffffffffc020746f <end+0xfff>
ffffffffc02010ee:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02010f0:	00005517          	auipc	a0,0x5
ffffffffc02010f4:	34850513          	addi	a0,a0,840 # ffffffffc0206438 <npage>
ffffffffc02010f8:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02010fc:	00005597          	auipc	a1,0x5
ffffffffc0201100:	34458593          	addi	a1,a1,836 # ffffffffc0206440 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201104:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201106:	e19c                	sd	a5,0(a1)
ffffffffc0201108:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020110a:	4701                	li	a4,0
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020110c:	4885                	li	a7,1
ffffffffc020110e:	fff80837          	lui	a6,0xfff80
ffffffffc0201112:	a011                	j	ffffffffc0201116 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0201114:	619c                	ld	a5,0(a1)
ffffffffc0201116:	97b6                	add	a5,a5,a3
ffffffffc0201118:	07a1                	addi	a5,a5,8
ffffffffc020111a:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020111e:	611c                	ld	a5,0(a0)
ffffffffc0201120:	0705                	addi	a4,a4,1
ffffffffc0201122:	03068693          	addi	a3,a3,48
ffffffffc0201126:	01078633          	add	a2,a5,a6
ffffffffc020112a:	fec765e3          	bltu	a4,a2,ffffffffc0201114 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020112e:	6190                	ld	a2,0(a1)
ffffffffc0201130:	00179713          	slli	a4,a5,0x1
ffffffffc0201134:	973e                	add	a4,a4,a5
ffffffffc0201136:	fe8006b7          	lui	a3,0xfe800
ffffffffc020113a:	0712                	slli	a4,a4,0x4
ffffffffc020113c:	96b2                	add	a3,a3,a2
ffffffffc020113e:	96ba                	add	a3,a3,a4
ffffffffc0201140:	c0200737          	lui	a4,0xc0200
ffffffffc0201144:	08e6ef63          	bltu	a3,a4,ffffffffc02011e2 <pmm_init+0x162>
ffffffffc0201148:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc020114a:	45c5                	li	a1,17
ffffffffc020114c:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020114e:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201150:	04b6e863          	bltu	a3,a1,ffffffffc02011a0 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201154:	609c                	ld	a5,0(s1)
ffffffffc0201156:	7b9c                	ld	a5,48(a5)
ffffffffc0201158:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020115a:	00001517          	auipc	a0,0x1
ffffffffc020115e:	0de50513          	addi	a0,a0,222 # ffffffffc0202238 <buddy_system_pmm_manager+0x100>
ffffffffc0201162:	f51fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201166:	00004597          	auipc	a1,0x4
ffffffffc020116a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc020116e:	00005797          	auipc	a5,0x5
ffffffffc0201172:	2eb7b523          	sd	a1,746(a5) # ffffffffc0206458 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201176:	c02007b7          	lui	a5,0xc0200
ffffffffc020117a:	08f5e063          	bltu	a1,a5,ffffffffc02011fa <pmm_init+0x17a>
ffffffffc020117e:	6010                	ld	a2,0(s0)
}
ffffffffc0201180:	6442                	ld	s0,16(sp)
ffffffffc0201182:	60e2                	ld	ra,24(sp)
ffffffffc0201184:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0201186:	40c58633          	sub	a2,a1,a2
ffffffffc020118a:	00005797          	auipc	a5,0x5
ffffffffc020118e:	2cc7b323          	sd	a2,710(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201192:	00001517          	auipc	a0,0x1
ffffffffc0201196:	0c650513          	addi	a0,a0,198 # ffffffffc0202258 <buddy_system_pmm_manager+0x120>
}
ffffffffc020119a:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020119c:	f17fe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02011a0:	6705                	lui	a4,0x1
ffffffffc02011a2:	177d                	addi	a4,a4,-1
ffffffffc02011a4:	96ba                	add	a3,a3,a4
ffffffffc02011a6:	777d                	lui	a4,0xfffff
ffffffffc02011a8:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02011aa:	00c6d513          	srli	a0,a3,0xc
ffffffffc02011ae:	00f57e63          	bgeu	a0,a5,ffffffffc02011ca <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc02011b2:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02011b4:	982a                	add	a6,a6,a0
ffffffffc02011b6:	00181513          	slli	a0,a6,0x1
ffffffffc02011ba:	9542                	add	a0,a0,a6
ffffffffc02011bc:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02011be:	8d95                	sub	a1,a1,a3
ffffffffc02011c0:	0512                	slli	a0,a0,0x4
    pmm_manager->init_memmap(base, n);
ffffffffc02011c2:	81b1                	srli	a1,a1,0xc
ffffffffc02011c4:	9532                	add	a0,a0,a2
ffffffffc02011c6:	9782                	jalr	a5
}
ffffffffc02011c8:	b771                	j	ffffffffc0201154 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc02011ca:	00001617          	auipc	a2,0x1
ffffffffc02011ce:	03e60613          	addi	a2,a2,62 # ffffffffc0202208 <buddy_system_pmm_manager+0xd0>
ffffffffc02011d2:	06b00593          	li	a1,107
ffffffffc02011d6:	00001517          	auipc	a0,0x1
ffffffffc02011da:	05250513          	addi	a0,a0,82 # ffffffffc0202228 <buddy_system_pmm_manager+0xf0>
ffffffffc02011de:	9ceff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02011e2:	00001617          	auipc	a2,0x1
ffffffffc02011e6:	fee60613          	addi	a2,a2,-18 # ffffffffc02021d0 <buddy_system_pmm_manager+0x98>
ffffffffc02011ea:	06f00593          	li	a1,111
ffffffffc02011ee:	00001517          	auipc	a0,0x1
ffffffffc02011f2:	00a50513          	addi	a0,a0,10 # ffffffffc02021f8 <buddy_system_pmm_manager+0xc0>
ffffffffc02011f6:	9b6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02011fa:	86ae                	mv	a3,a1
ffffffffc02011fc:	00001617          	auipc	a2,0x1
ffffffffc0201200:	fd460613          	addi	a2,a2,-44 # ffffffffc02021d0 <buddy_system_pmm_manager+0x98>
ffffffffc0201204:	08a00593          	li	a1,138
ffffffffc0201208:	00001517          	auipc	a0,0x1
ffffffffc020120c:	ff050513          	addi	a0,a0,-16 # ffffffffc02021f8 <buddy_system_pmm_manager+0xc0>
ffffffffc0201210:	99cff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201214 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201214:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201218:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020121a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020121e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201220:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201224:	f022                	sd	s0,32(sp)
ffffffffc0201226:	ec26                	sd	s1,24(sp)
ffffffffc0201228:	e84a                	sd	s2,16(sp)
ffffffffc020122a:	f406                	sd	ra,40(sp)
ffffffffc020122c:	e44e                	sd	s3,8(sp)
ffffffffc020122e:	84aa                	mv	s1,a0
ffffffffc0201230:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201232:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201236:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201238:	03067e63          	bgeu	a2,a6,ffffffffc0201274 <printnum+0x60>
ffffffffc020123c:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020123e:	00805763          	blez	s0,ffffffffc020124c <printnum+0x38>
ffffffffc0201242:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201244:	85ca                	mv	a1,s2
ffffffffc0201246:	854e                	mv	a0,s3
ffffffffc0201248:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020124a:	fc65                	bnez	s0,ffffffffc0201242 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020124c:	1a02                	slli	s4,s4,0x20
ffffffffc020124e:	00001797          	auipc	a5,0x1
ffffffffc0201252:	04a78793          	addi	a5,a5,74 # ffffffffc0202298 <buddy_system_pmm_manager+0x160>
ffffffffc0201256:	020a5a13          	srli	s4,s4,0x20
ffffffffc020125a:	9a3e                	add	s4,s4,a5
}
ffffffffc020125c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020125e:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201262:	70a2                	ld	ra,40(sp)
ffffffffc0201264:	69a2                	ld	s3,8(sp)
ffffffffc0201266:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201268:	85ca                	mv	a1,s2
ffffffffc020126a:	87a6                	mv	a5,s1
}
ffffffffc020126c:	6942                	ld	s2,16(sp)
ffffffffc020126e:	64e2                	ld	s1,24(sp)
ffffffffc0201270:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201272:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201274:	03065633          	divu	a2,a2,a6
ffffffffc0201278:	8722                	mv	a4,s0
ffffffffc020127a:	f9bff0ef          	jal	ra,ffffffffc0201214 <printnum>
ffffffffc020127e:	b7f9                	j	ffffffffc020124c <printnum+0x38>

ffffffffc0201280 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201280:	7119                	addi	sp,sp,-128
ffffffffc0201282:	f4a6                	sd	s1,104(sp)
ffffffffc0201284:	f0ca                	sd	s2,96(sp)
ffffffffc0201286:	ecce                	sd	s3,88(sp)
ffffffffc0201288:	e8d2                	sd	s4,80(sp)
ffffffffc020128a:	e4d6                	sd	s5,72(sp)
ffffffffc020128c:	e0da                	sd	s6,64(sp)
ffffffffc020128e:	fc5e                	sd	s7,56(sp)
ffffffffc0201290:	f06a                	sd	s10,32(sp)
ffffffffc0201292:	fc86                	sd	ra,120(sp)
ffffffffc0201294:	f8a2                	sd	s0,112(sp)
ffffffffc0201296:	f862                	sd	s8,48(sp)
ffffffffc0201298:	f466                	sd	s9,40(sp)
ffffffffc020129a:	ec6e                	sd	s11,24(sp)
ffffffffc020129c:	892a                	mv	s2,a0
ffffffffc020129e:	84ae                	mv	s1,a1
ffffffffc02012a0:	8d32                	mv	s10,a2
ffffffffc02012a2:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02012a4:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02012a8:	5b7d                	li	s6,-1
ffffffffc02012aa:	00001a97          	auipc	s5,0x1
ffffffffc02012ae:	022a8a93          	addi	s5,s5,34 # ffffffffc02022cc <buddy_system_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02012b2:	00001b97          	auipc	s7,0x1
ffffffffc02012b6:	1f6b8b93          	addi	s7,s7,502 # ffffffffc02024a8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02012ba:	000d4503          	lbu	a0,0(s10)
ffffffffc02012be:	001d0413          	addi	s0,s10,1
ffffffffc02012c2:	01350a63          	beq	a0,s3,ffffffffc02012d6 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02012c6:	c121                	beqz	a0,ffffffffc0201306 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02012c8:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02012ca:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02012cc:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02012ce:	fff44503          	lbu	a0,-1(s0)
ffffffffc02012d2:	ff351ae3          	bne	a0,s3,ffffffffc02012c6 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012d6:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02012da:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02012de:	4c81                	li	s9,0
ffffffffc02012e0:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02012e2:	5c7d                	li	s8,-1
ffffffffc02012e4:	5dfd                	li	s11,-1
ffffffffc02012e6:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02012ea:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012ec:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02012f0:	0ff5f593          	zext.b	a1,a1
ffffffffc02012f4:	00140d13          	addi	s10,s0,1
ffffffffc02012f8:	04b56263          	bltu	a0,a1,ffffffffc020133c <vprintfmt+0xbc>
ffffffffc02012fc:	058a                	slli	a1,a1,0x2
ffffffffc02012fe:	95d6                	add	a1,a1,s5
ffffffffc0201300:	4194                	lw	a3,0(a1)
ffffffffc0201302:	96d6                	add	a3,a3,s5
ffffffffc0201304:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201306:	70e6                	ld	ra,120(sp)
ffffffffc0201308:	7446                	ld	s0,112(sp)
ffffffffc020130a:	74a6                	ld	s1,104(sp)
ffffffffc020130c:	7906                	ld	s2,96(sp)
ffffffffc020130e:	69e6                	ld	s3,88(sp)
ffffffffc0201310:	6a46                	ld	s4,80(sp)
ffffffffc0201312:	6aa6                	ld	s5,72(sp)
ffffffffc0201314:	6b06                	ld	s6,64(sp)
ffffffffc0201316:	7be2                	ld	s7,56(sp)
ffffffffc0201318:	7c42                	ld	s8,48(sp)
ffffffffc020131a:	7ca2                	ld	s9,40(sp)
ffffffffc020131c:	7d02                	ld	s10,32(sp)
ffffffffc020131e:	6de2                	ld	s11,24(sp)
ffffffffc0201320:	6109                	addi	sp,sp,128
ffffffffc0201322:	8082                	ret
            padc = '0';
ffffffffc0201324:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201326:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020132a:	846a                	mv	s0,s10
ffffffffc020132c:	00140d13          	addi	s10,s0,1
ffffffffc0201330:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201334:	0ff5f593          	zext.b	a1,a1
ffffffffc0201338:	fcb572e3          	bgeu	a0,a1,ffffffffc02012fc <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020133c:	85a6                	mv	a1,s1
ffffffffc020133e:	02500513          	li	a0,37
ffffffffc0201342:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201344:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201348:	8d22                	mv	s10,s0
ffffffffc020134a:	f73788e3          	beq	a5,s3,ffffffffc02012ba <vprintfmt+0x3a>
ffffffffc020134e:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201352:	1d7d                	addi	s10,s10,-1
ffffffffc0201354:	ff379de3          	bne	a5,s3,ffffffffc020134e <vprintfmt+0xce>
ffffffffc0201358:	b78d                	j	ffffffffc02012ba <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020135a:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020135e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201362:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201364:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201368:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020136c:	02d86463          	bltu	a6,a3,ffffffffc0201394 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201370:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201374:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201378:	0186873b          	addw	a4,a3,s8
ffffffffc020137c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201380:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201382:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201386:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201388:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020138c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201390:	fed870e3          	bgeu	a6,a3,ffffffffc0201370 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201394:	f40ddce3          	bgez	s11,ffffffffc02012ec <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201398:	8de2                	mv	s11,s8
ffffffffc020139a:	5c7d                	li	s8,-1
ffffffffc020139c:	bf81                	j	ffffffffc02012ec <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020139e:	fffdc693          	not	a3,s11
ffffffffc02013a2:	96fd                	srai	a3,a3,0x3f
ffffffffc02013a4:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013a8:	00144603          	lbu	a2,1(s0)
ffffffffc02013ac:	2d81                	sext.w	s11,s11
ffffffffc02013ae:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02013b0:	bf35                	j	ffffffffc02012ec <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02013b2:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013b6:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02013ba:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013bc:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02013be:	bfd9                	j	ffffffffc0201394 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02013c0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02013c2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02013c6:	01174463          	blt	a4,a7,ffffffffc02013ce <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02013ca:	1a088e63          	beqz	a7,ffffffffc0201586 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02013ce:	000a3603          	ld	a2,0(s4)
ffffffffc02013d2:	46c1                	li	a3,16
ffffffffc02013d4:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02013d6:	2781                	sext.w	a5,a5
ffffffffc02013d8:	876e                	mv	a4,s11
ffffffffc02013da:	85a6                	mv	a1,s1
ffffffffc02013dc:	854a                	mv	a0,s2
ffffffffc02013de:	e37ff0ef          	jal	ra,ffffffffc0201214 <printnum>
            break;
ffffffffc02013e2:	bde1                	j	ffffffffc02012ba <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02013e4:	000a2503          	lw	a0,0(s4)
ffffffffc02013e8:	85a6                	mv	a1,s1
ffffffffc02013ea:	0a21                	addi	s4,s4,8
ffffffffc02013ec:	9902                	jalr	s2
            break;
ffffffffc02013ee:	b5f1                	j	ffffffffc02012ba <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02013f0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02013f2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02013f6:	01174463          	blt	a4,a7,ffffffffc02013fe <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02013fa:	18088163          	beqz	a7,ffffffffc020157c <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02013fe:	000a3603          	ld	a2,0(s4)
ffffffffc0201402:	46a9                	li	a3,10
ffffffffc0201404:	8a2e                	mv	s4,a1
ffffffffc0201406:	bfc1                	j	ffffffffc02013d6 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201408:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020140c:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020140e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201410:	bdf1                	j	ffffffffc02012ec <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201412:	85a6                	mv	a1,s1
ffffffffc0201414:	02500513          	li	a0,37
ffffffffc0201418:	9902                	jalr	s2
            break;
ffffffffc020141a:	b545                	j	ffffffffc02012ba <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020141c:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201420:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201422:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201424:	b5e1                	j	ffffffffc02012ec <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201426:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201428:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020142c:	01174463          	blt	a4,a7,ffffffffc0201434 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201430:	14088163          	beqz	a7,ffffffffc0201572 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201434:	000a3603          	ld	a2,0(s4)
ffffffffc0201438:	46a1                	li	a3,8
ffffffffc020143a:	8a2e                	mv	s4,a1
ffffffffc020143c:	bf69                	j	ffffffffc02013d6 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc020143e:	03000513          	li	a0,48
ffffffffc0201442:	85a6                	mv	a1,s1
ffffffffc0201444:	e03e                	sd	a5,0(sp)
ffffffffc0201446:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201448:	85a6                	mv	a1,s1
ffffffffc020144a:	07800513          	li	a0,120
ffffffffc020144e:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201450:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201452:	6782                	ld	a5,0(sp)
ffffffffc0201454:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201456:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020145a:	bfb5                	j	ffffffffc02013d6 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020145c:	000a3403          	ld	s0,0(s4)
ffffffffc0201460:	008a0713          	addi	a4,s4,8
ffffffffc0201464:	e03a                	sd	a4,0(sp)
ffffffffc0201466:	14040263          	beqz	s0,ffffffffc02015aa <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020146a:	0fb05763          	blez	s11,ffffffffc0201558 <vprintfmt+0x2d8>
ffffffffc020146e:	02d00693          	li	a3,45
ffffffffc0201472:	0cd79163          	bne	a5,a3,ffffffffc0201534 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201476:	00044783          	lbu	a5,0(s0)
ffffffffc020147a:	0007851b          	sext.w	a0,a5
ffffffffc020147e:	cf85                	beqz	a5,ffffffffc02014b6 <vprintfmt+0x236>
ffffffffc0201480:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201484:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201488:	000c4563          	bltz	s8,ffffffffc0201492 <vprintfmt+0x212>
ffffffffc020148c:	3c7d                	addiw	s8,s8,-1
ffffffffc020148e:	036c0263          	beq	s8,s6,ffffffffc02014b2 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201492:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201494:	0e0c8e63          	beqz	s9,ffffffffc0201590 <vprintfmt+0x310>
ffffffffc0201498:	3781                	addiw	a5,a5,-32
ffffffffc020149a:	0ef47b63          	bgeu	s0,a5,ffffffffc0201590 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020149e:	03f00513          	li	a0,63
ffffffffc02014a2:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014a4:	000a4783          	lbu	a5,0(s4)
ffffffffc02014a8:	3dfd                	addiw	s11,s11,-1
ffffffffc02014aa:	0a05                	addi	s4,s4,1
ffffffffc02014ac:	0007851b          	sext.w	a0,a5
ffffffffc02014b0:	ffe1                	bnez	a5,ffffffffc0201488 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02014b2:	01b05963          	blez	s11,ffffffffc02014c4 <vprintfmt+0x244>
ffffffffc02014b6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02014b8:	85a6                	mv	a1,s1
ffffffffc02014ba:	02000513          	li	a0,32
ffffffffc02014be:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02014c0:	fe0d9be3          	bnez	s11,ffffffffc02014b6 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02014c4:	6a02                	ld	s4,0(sp)
ffffffffc02014c6:	bbd5                	j	ffffffffc02012ba <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02014c8:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02014ca:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02014ce:	01174463          	blt	a4,a7,ffffffffc02014d6 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02014d2:	08088d63          	beqz	a7,ffffffffc020156c <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02014d6:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02014da:	0a044d63          	bltz	s0,ffffffffc0201594 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02014de:	8622                	mv	a2,s0
ffffffffc02014e0:	8a66                	mv	s4,s9
ffffffffc02014e2:	46a9                	li	a3,10
ffffffffc02014e4:	bdcd                	j	ffffffffc02013d6 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02014e6:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02014ea:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02014ec:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02014ee:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02014f2:	8fb5                	xor	a5,a5,a3
ffffffffc02014f4:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02014f8:	02d74163          	blt	a4,a3,ffffffffc020151a <vprintfmt+0x29a>
ffffffffc02014fc:	00369793          	slli	a5,a3,0x3
ffffffffc0201500:	97de                	add	a5,a5,s7
ffffffffc0201502:	639c                	ld	a5,0(a5)
ffffffffc0201504:	cb99                	beqz	a5,ffffffffc020151a <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201506:	86be                	mv	a3,a5
ffffffffc0201508:	00001617          	auipc	a2,0x1
ffffffffc020150c:	dc060613          	addi	a2,a2,-576 # ffffffffc02022c8 <buddy_system_pmm_manager+0x190>
ffffffffc0201510:	85a6                	mv	a1,s1
ffffffffc0201512:	854a                	mv	a0,s2
ffffffffc0201514:	0ce000ef          	jal	ra,ffffffffc02015e2 <printfmt>
ffffffffc0201518:	b34d                	j	ffffffffc02012ba <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020151a:	00001617          	auipc	a2,0x1
ffffffffc020151e:	d9e60613          	addi	a2,a2,-610 # ffffffffc02022b8 <buddy_system_pmm_manager+0x180>
ffffffffc0201522:	85a6                	mv	a1,s1
ffffffffc0201524:	854a                	mv	a0,s2
ffffffffc0201526:	0bc000ef          	jal	ra,ffffffffc02015e2 <printfmt>
ffffffffc020152a:	bb41                	j	ffffffffc02012ba <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020152c:	00001417          	auipc	s0,0x1
ffffffffc0201530:	d8440413          	addi	s0,s0,-636 # ffffffffc02022b0 <buddy_system_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201534:	85e2                	mv	a1,s8
ffffffffc0201536:	8522                	mv	a0,s0
ffffffffc0201538:	e43e                	sd	a5,8(sp)
ffffffffc020153a:	1cc000ef          	jal	ra,ffffffffc0201706 <strnlen>
ffffffffc020153e:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201542:	01b05b63          	blez	s11,ffffffffc0201558 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201546:	67a2                	ld	a5,8(sp)
ffffffffc0201548:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020154c:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020154e:	85a6                	mv	a1,s1
ffffffffc0201550:	8552                	mv	a0,s4
ffffffffc0201552:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201554:	fe0d9ce3          	bnez	s11,ffffffffc020154c <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201558:	00044783          	lbu	a5,0(s0)
ffffffffc020155c:	00140a13          	addi	s4,s0,1
ffffffffc0201560:	0007851b          	sext.w	a0,a5
ffffffffc0201564:	d3a5                	beqz	a5,ffffffffc02014c4 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201566:	05e00413          	li	s0,94
ffffffffc020156a:	bf39                	j	ffffffffc0201488 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020156c:	000a2403          	lw	s0,0(s4)
ffffffffc0201570:	b7ad                	j	ffffffffc02014da <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201572:	000a6603          	lwu	a2,0(s4)
ffffffffc0201576:	46a1                	li	a3,8
ffffffffc0201578:	8a2e                	mv	s4,a1
ffffffffc020157a:	bdb1                	j	ffffffffc02013d6 <vprintfmt+0x156>
ffffffffc020157c:	000a6603          	lwu	a2,0(s4)
ffffffffc0201580:	46a9                	li	a3,10
ffffffffc0201582:	8a2e                	mv	s4,a1
ffffffffc0201584:	bd89                	j	ffffffffc02013d6 <vprintfmt+0x156>
ffffffffc0201586:	000a6603          	lwu	a2,0(s4)
ffffffffc020158a:	46c1                	li	a3,16
ffffffffc020158c:	8a2e                	mv	s4,a1
ffffffffc020158e:	b5a1                	j	ffffffffc02013d6 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201590:	9902                	jalr	s2
ffffffffc0201592:	bf09                	j	ffffffffc02014a4 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201594:	85a6                	mv	a1,s1
ffffffffc0201596:	02d00513          	li	a0,45
ffffffffc020159a:	e03e                	sd	a5,0(sp)
ffffffffc020159c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020159e:	6782                	ld	a5,0(sp)
ffffffffc02015a0:	8a66                	mv	s4,s9
ffffffffc02015a2:	40800633          	neg	a2,s0
ffffffffc02015a6:	46a9                	li	a3,10
ffffffffc02015a8:	b53d                	j	ffffffffc02013d6 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02015aa:	03b05163          	blez	s11,ffffffffc02015cc <vprintfmt+0x34c>
ffffffffc02015ae:	02d00693          	li	a3,45
ffffffffc02015b2:	f6d79de3          	bne	a5,a3,ffffffffc020152c <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02015b6:	00001417          	auipc	s0,0x1
ffffffffc02015ba:	cfa40413          	addi	s0,s0,-774 # ffffffffc02022b0 <buddy_system_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02015be:	02800793          	li	a5,40
ffffffffc02015c2:	02800513          	li	a0,40
ffffffffc02015c6:	00140a13          	addi	s4,s0,1
ffffffffc02015ca:	bd6d                	j	ffffffffc0201484 <vprintfmt+0x204>
ffffffffc02015cc:	00001a17          	auipc	s4,0x1
ffffffffc02015d0:	ce5a0a13          	addi	s4,s4,-795 # ffffffffc02022b1 <buddy_system_pmm_manager+0x179>
ffffffffc02015d4:	02800513          	li	a0,40
ffffffffc02015d8:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02015dc:	05e00413          	li	s0,94
ffffffffc02015e0:	b565                	j	ffffffffc0201488 <vprintfmt+0x208>

ffffffffc02015e2 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02015e2:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02015e4:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02015e8:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02015ea:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02015ec:	ec06                	sd	ra,24(sp)
ffffffffc02015ee:	f83a                	sd	a4,48(sp)
ffffffffc02015f0:	fc3e                	sd	a5,56(sp)
ffffffffc02015f2:	e0c2                	sd	a6,64(sp)
ffffffffc02015f4:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02015f6:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02015f8:	c89ff0ef          	jal	ra,ffffffffc0201280 <vprintfmt>
}
ffffffffc02015fc:	60e2                	ld	ra,24(sp)
ffffffffc02015fe:	6161                	addi	sp,sp,80
ffffffffc0201600:	8082                	ret

ffffffffc0201602 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201602:	715d                	addi	sp,sp,-80
ffffffffc0201604:	e486                	sd	ra,72(sp)
ffffffffc0201606:	e0a6                	sd	s1,64(sp)
ffffffffc0201608:	fc4a                	sd	s2,56(sp)
ffffffffc020160a:	f84e                	sd	s3,48(sp)
ffffffffc020160c:	f452                	sd	s4,40(sp)
ffffffffc020160e:	f056                	sd	s5,32(sp)
ffffffffc0201610:	ec5a                	sd	s6,24(sp)
ffffffffc0201612:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201614:	c901                	beqz	a0,ffffffffc0201624 <readline+0x22>
ffffffffc0201616:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201618:	00001517          	auipc	a0,0x1
ffffffffc020161c:	cb050513          	addi	a0,a0,-848 # ffffffffc02022c8 <buddy_system_pmm_manager+0x190>
ffffffffc0201620:	a93fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201624:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201626:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201628:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020162a:	4aa9                	li	s5,10
ffffffffc020162c:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020162e:	00005b97          	auipc	s7,0x5
ffffffffc0201632:	9fab8b93          	addi	s7,s7,-1542 # ffffffffc0206028 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201636:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020163a:	af1fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020163e:	00054a63          	bltz	a0,ffffffffc0201652 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201642:	00a95a63          	bge	s2,a0,ffffffffc0201656 <readline+0x54>
ffffffffc0201646:	029a5263          	bge	s4,s1,ffffffffc020166a <readline+0x68>
        c = getchar();
ffffffffc020164a:	ae1fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020164e:	fe055ae3          	bgez	a0,ffffffffc0201642 <readline+0x40>
            return NULL;
ffffffffc0201652:	4501                	li	a0,0
ffffffffc0201654:	a091                	j	ffffffffc0201698 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201656:	03351463          	bne	a0,s3,ffffffffc020167e <readline+0x7c>
ffffffffc020165a:	e8a9                	bnez	s1,ffffffffc02016ac <readline+0xaa>
        c = getchar();
ffffffffc020165c:	acffe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201660:	fe0549e3          	bltz	a0,ffffffffc0201652 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201664:	fea959e3          	bge	s2,a0,ffffffffc0201656 <readline+0x54>
ffffffffc0201668:	4481                	li	s1,0
            cputchar(c);
ffffffffc020166a:	e42a                	sd	a0,8(sp)
ffffffffc020166c:	a7dfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc0201670:	6522                	ld	a0,8(sp)
ffffffffc0201672:	009b87b3          	add	a5,s7,s1
ffffffffc0201676:	2485                	addiw	s1,s1,1
ffffffffc0201678:	00a78023          	sb	a0,0(a5)
ffffffffc020167c:	bf7d                	j	ffffffffc020163a <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020167e:	01550463          	beq	a0,s5,ffffffffc0201686 <readline+0x84>
ffffffffc0201682:	fb651ce3          	bne	a0,s6,ffffffffc020163a <readline+0x38>
            cputchar(c);
ffffffffc0201686:	a63fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc020168a:	00005517          	auipc	a0,0x5
ffffffffc020168e:	99e50513          	addi	a0,a0,-1634 # ffffffffc0206028 <buf>
ffffffffc0201692:	94aa                	add	s1,s1,a0
ffffffffc0201694:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201698:	60a6                	ld	ra,72(sp)
ffffffffc020169a:	6486                	ld	s1,64(sp)
ffffffffc020169c:	7962                	ld	s2,56(sp)
ffffffffc020169e:	79c2                	ld	s3,48(sp)
ffffffffc02016a0:	7a22                	ld	s4,40(sp)
ffffffffc02016a2:	7a82                	ld	s5,32(sp)
ffffffffc02016a4:	6b62                	ld	s6,24(sp)
ffffffffc02016a6:	6bc2                	ld	s7,16(sp)
ffffffffc02016a8:	6161                	addi	sp,sp,80
ffffffffc02016aa:	8082                	ret
            cputchar(c);
ffffffffc02016ac:	4521                	li	a0,8
ffffffffc02016ae:	a3bfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc02016b2:	34fd                	addiw	s1,s1,-1
ffffffffc02016b4:	b759                	j	ffffffffc020163a <readline+0x38>

ffffffffc02016b6 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02016b6:	4781                	li	a5,0
ffffffffc02016b8:	00005717          	auipc	a4,0x5
ffffffffc02016bc:	95073703          	ld	a4,-1712(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc02016c0:	88ba                	mv	a7,a4
ffffffffc02016c2:	852a                	mv	a0,a0
ffffffffc02016c4:	85be                	mv	a1,a5
ffffffffc02016c6:	863e                	mv	a2,a5
ffffffffc02016c8:	00000073          	ecall
ffffffffc02016cc:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02016ce:	8082                	ret

ffffffffc02016d0 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc02016d0:	4781                	li	a5,0
ffffffffc02016d2:	00005717          	auipc	a4,0x5
ffffffffc02016d6:	d9673703          	ld	a4,-618(a4) # ffffffffc0206468 <SBI_SET_TIMER>
ffffffffc02016da:	88ba                	mv	a7,a4
ffffffffc02016dc:	852a                	mv	a0,a0
ffffffffc02016de:	85be                	mv	a1,a5
ffffffffc02016e0:	863e                	mv	a2,a5
ffffffffc02016e2:	00000073          	ecall
ffffffffc02016e6:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc02016e8:	8082                	ret

ffffffffc02016ea <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc02016ea:	4501                	li	a0,0
ffffffffc02016ec:	00005797          	auipc	a5,0x5
ffffffffc02016f0:	9147b783          	ld	a5,-1772(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc02016f4:	88be                	mv	a7,a5
ffffffffc02016f6:	852a                	mv	a0,a0
ffffffffc02016f8:	85aa                	mv	a1,a0
ffffffffc02016fa:	862a                	mv	a2,a0
ffffffffc02016fc:	00000073          	ecall
ffffffffc0201700:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201702:	2501                	sext.w	a0,a0
ffffffffc0201704:	8082                	ret

ffffffffc0201706 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201706:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201708:	e589                	bnez	a1,ffffffffc0201712 <strnlen+0xc>
ffffffffc020170a:	a811                	j	ffffffffc020171e <strnlen+0x18>
        cnt ++;
ffffffffc020170c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020170e:	00f58863          	beq	a1,a5,ffffffffc020171e <strnlen+0x18>
ffffffffc0201712:	00f50733          	add	a4,a0,a5
ffffffffc0201716:	00074703          	lbu	a4,0(a4)
ffffffffc020171a:	fb6d                	bnez	a4,ffffffffc020170c <strnlen+0x6>
ffffffffc020171c:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020171e:	852e                	mv	a0,a1
ffffffffc0201720:	8082                	ret

ffffffffc0201722 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201722:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201726:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020172a:	cb89                	beqz	a5,ffffffffc020173c <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc020172c:	0505                	addi	a0,a0,1
ffffffffc020172e:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201730:	fee789e3          	beq	a5,a4,ffffffffc0201722 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201734:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201738:	9d19                	subw	a0,a0,a4
ffffffffc020173a:	8082                	ret
ffffffffc020173c:	4501                	li	a0,0
ffffffffc020173e:	bfed                	j	ffffffffc0201738 <strcmp+0x16>

ffffffffc0201740 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201740:	00054783          	lbu	a5,0(a0)
ffffffffc0201744:	c799                	beqz	a5,ffffffffc0201752 <strchr+0x12>
        if (*s == c) {
ffffffffc0201746:	00f58763          	beq	a1,a5,ffffffffc0201754 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020174a:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc020174e:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201750:	fbfd                	bnez	a5,ffffffffc0201746 <strchr+0x6>
    }
    return NULL;
ffffffffc0201752:	4501                	li	a0,0
}
ffffffffc0201754:	8082                	ret

ffffffffc0201756 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201756:	ca01                	beqz	a2,ffffffffc0201766 <memset+0x10>
ffffffffc0201758:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020175a:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020175c:	0785                	addi	a5,a5,1
ffffffffc020175e:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201762:	fec79de3          	bne	a5,a2,ffffffffc020175c <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201766:	8082                	ret
