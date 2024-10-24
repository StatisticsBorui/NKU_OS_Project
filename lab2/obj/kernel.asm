
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
ffffffffc020004a:	319010ef          	jal	ra,ffffffffc0201b62 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	b2650513          	addi	a0,a0,-1242 # ffffffffc0201b78 <etext+0x4>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	426010ef          	jal	ra,ffffffffc020148c <pmm_init>

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
ffffffffc02000a6:	5e6010ef          	jal	ra,ffffffffc020168c <vprintfmt>
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
ffffffffc02000dc:	5b0010ef          	jal	ra,ffffffffc020168c <vprintfmt>
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
ffffffffc020013c:	00002517          	auipc	a0,0x2
ffffffffc0200140:	a5c50513          	addi	a0,a0,-1444 # ffffffffc0201b98 <etext+0x24>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00002517          	auipc	a0,0x2
ffffffffc0200156:	a6650513          	addi	a0,a0,-1434 # ffffffffc0201bb8 <etext+0x44>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00002597          	auipc	a1,0x2
ffffffffc0200162:	a1658593          	addi	a1,a1,-1514 # ffffffffc0201b74 <etext>
ffffffffc0200166:	00002517          	auipc	a0,0x2
ffffffffc020016a:	a7250513          	addi	a0,a0,-1422 # ffffffffc0201bd8 <etext+0x64>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <free_area>
ffffffffc020017a:	00002517          	auipc	a0,0x2
ffffffffc020017e:	a7e50513          	addi	a0,a0,-1410 # ffffffffc0201bf8 <etext+0x84>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	2ea58593          	addi	a1,a1,746 # ffffffffc0206470 <end>
ffffffffc020018e:	00002517          	auipc	a0,0x2
ffffffffc0200192:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0201c18 <etext+0xa4>
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
ffffffffc02001bc:	00002517          	auipc	a0,0x2
ffffffffc02001c0:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0201c38 <etext+0xc4>
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
ffffffffc02001ca:	00002617          	auipc	a2,0x2
ffffffffc02001ce:	a9e60613          	addi	a2,a2,-1378 # ffffffffc0201c68 <etext+0xf4>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00002517          	auipc	a0,0x2
ffffffffc02001da:	aaa50513          	addi	a0,a0,-1366 # ffffffffc0201c80 <etext+0x10c>
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
ffffffffc02001e6:	00002617          	auipc	a2,0x2
ffffffffc02001ea:	ab260613          	addi	a2,a2,-1358 # ffffffffc0201c98 <etext+0x124>
ffffffffc02001ee:	00002597          	auipc	a1,0x2
ffffffffc02001f2:	aca58593          	addi	a1,a1,-1334 # ffffffffc0201cb8 <etext+0x144>
ffffffffc02001f6:	00002517          	auipc	a0,0x2
ffffffffc02001fa:	aca50513          	addi	a0,a0,-1334 # ffffffffc0201cc0 <etext+0x14c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00002617          	auipc	a2,0x2
ffffffffc0200208:	acc60613          	addi	a2,a2,-1332 # ffffffffc0201cd0 <etext+0x15c>
ffffffffc020020c:	00002597          	auipc	a1,0x2
ffffffffc0200210:	aec58593          	addi	a1,a1,-1300 # ffffffffc0201cf8 <etext+0x184>
ffffffffc0200214:	00002517          	auipc	a0,0x2
ffffffffc0200218:	aac50513          	addi	a0,a0,-1364 # ffffffffc0201cc0 <etext+0x14c>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00002617          	auipc	a2,0x2
ffffffffc0200224:	ae860613          	addi	a2,a2,-1304 # ffffffffc0201d08 <etext+0x194>
ffffffffc0200228:	00002597          	auipc	a1,0x2
ffffffffc020022c:	b0058593          	addi	a1,a1,-1280 # ffffffffc0201d28 <etext+0x1b4>
ffffffffc0200230:	00002517          	auipc	a0,0x2
ffffffffc0200234:	a9050513          	addi	a0,a0,-1392 # ffffffffc0201cc0 <etext+0x14c>
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
ffffffffc020026a:	00002517          	auipc	a0,0x2
ffffffffc020026e:	ace50513          	addi	a0,a0,-1330 # ffffffffc0201d38 <etext+0x1c4>
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
ffffffffc020028c:	00002517          	auipc	a0,0x2
ffffffffc0200290:	ad450513          	addi	a0,a0,-1324 # ffffffffc0201d60 <etext+0x1ec>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00002c17          	auipc	s8,0x2
ffffffffc02002a6:	b2ec0c13          	addi	s8,s8,-1234 # ffffffffc0201dd0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00002917          	auipc	s2,0x2
ffffffffc02002ae:	ade90913          	addi	s2,s2,-1314 # ffffffffc0201d88 <etext+0x214>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00002497          	auipc	s1,0x2
ffffffffc02002b6:	ade48493          	addi	s1,s1,-1314 # ffffffffc0201d90 <etext+0x21c>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00002b17          	auipc	s6,0x2
ffffffffc02002c0:	adcb0b13          	addi	s6,s6,-1316 # ffffffffc0201d98 <etext+0x224>
        argv[argc ++] = buf;
ffffffffc02002c4:	00002a17          	auipc	s4,0x2
ffffffffc02002c8:	9f4a0a13          	addi	s4,s4,-1548 # ffffffffc0201cb8 <etext+0x144>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	73e010ef          	jal	ra,ffffffffc0201a0e <readline>
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
ffffffffc02002e6:	00002d17          	auipc	s10,0x2
ffffffffc02002ea:	aead0d13          	addi	s10,s10,-1302 # ffffffffc0201dd0 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	03b010ef          	jal	ra,ffffffffc0201b2e <strcmp>
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
ffffffffc0200308:	027010ef          	jal	ra,ffffffffc0201b2e <strcmp>
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
ffffffffc0200346:	007010ef          	jal	ra,ffffffffc0201b4c <strchr>
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
ffffffffc0200384:	7c8010ef          	jal	ra,ffffffffc0201b4c <strchr>
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
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	a1a50513          	addi	a0,a0,-1510 # ffffffffc0201db8 <etext+0x244>
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
ffffffffc02003da:	00002517          	auipc	a0,0x2
ffffffffc02003de:	a3e50513          	addi	a0,a0,-1474 # ffffffffc0201e18 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00002517          	auipc	a0,0x2
ffffffffc02003f4:	87050513          	addi	a0,a0,-1936 # ffffffffc0201c60 <etext+0xec>
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
ffffffffc0200420:	6bc010ef          	jal	ra,ffffffffc0201adc <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b523          	sd	zero,10(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0201e38 <commands+0x68>
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
ffffffffc0200446:	6960106f          	j	ffffffffc0201adc <sbi_set_timer>

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
ffffffffc0200450:	6720106f          	j	ffffffffc0201ac2 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	6a20106f          	j	ffffffffc0201af6 <sbi_console_getchar>

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
ffffffffc020047e:	00002517          	auipc	a0,0x2
ffffffffc0200482:	9da50513          	addi	a0,a0,-1574 # ffffffffc0201e58 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	9e250513          	addi	a0,a0,-1566 # ffffffffc0201e70 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	9ec50513          	addi	a0,a0,-1556 # ffffffffc0201e88 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	9f650513          	addi	a0,a0,-1546 # ffffffffc0201ea0 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	a0050513          	addi	a0,a0,-1536 # ffffffffc0201eb8 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0201ed0 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	a1450513          	addi	a0,a0,-1516 # ffffffffc0201ee8 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0201f00 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	a2850513          	addi	a0,a0,-1496 # ffffffffc0201f18 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	a3250513          	addi	a0,a0,-1486 # ffffffffc0201f30 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0201f48 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	a4650513          	addi	a0,a0,-1466 # ffffffffc0201f60 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	a5050513          	addi	a0,a0,-1456 # ffffffffc0201f78 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0201f90 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	a6450513          	addi	a0,a0,-1436 # ffffffffc0201fa8 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	a6e50513          	addi	a0,a0,-1426 # ffffffffc0201fc0 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	a7850513          	addi	a0,a0,-1416 # ffffffffc0201fd8 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	a8250513          	addi	a0,a0,-1406 # ffffffffc0201ff0 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0202008 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	a9650513          	addi	a0,a0,-1386 # ffffffffc0202020 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	aa050513          	addi	a0,a0,-1376 # ffffffffc0202038 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	aaa50513          	addi	a0,a0,-1366 # ffffffffc0202050 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	ab450513          	addi	a0,a0,-1356 # ffffffffc0202068 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	abe50513          	addi	a0,a0,-1346 # ffffffffc0202080 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	ac850513          	addi	a0,a0,-1336 # ffffffffc0202098 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	ad250513          	addi	a0,a0,-1326 # ffffffffc02020b0 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	adc50513          	addi	a0,a0,-1316 # ffffffffc02020c8 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	ae650513          	addi	a0,a0,-1306 # ffffffffc02020e0 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	af050513          	addi	a0,a0,-1296 # ffffffffc02020f8 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	afa50513          	addi	a0,a0,-1286 # ffffffffc0202110 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	b0450513          	addi	a0,a0,-1276 # ffffffffc0202128 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	b0a50513          	addi	a0,a0,-1270 # ffffffffc0202140 <commands+0x370>
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
ffffffffc020064a:	00002517          	auipc	a0,0x2
ffffffffc020064e:	b0e50513          	addi	a0,a0,-1266 # ffffffffc0202158 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00002517          	auipc	a0,0x2
ffffffffc0200666:	b0e50513          	addi	a0,a0,-1266 # ffffffffc0202170 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	b1650513          	addi	a0,a0,-1258 # ffffffffc0202188 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	b1e50513          	addi	a0,a0,-1250 # ffffffffc02021a0 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	b2250513          	addi	a0,a0,-1246 # ffffffffc02021b8 <commands+0x3e8>
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
ffffffffc02006b0:	00002717          	auipc	a4,0x2
ffffffffc02006b4:	be870713          	addi	a4,a4,-1048 # ffffffffc0202298 <commands+0x4c8>
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
ffffffffc02006c2:	00002517          	auipc	a0,0x2
ffffffffc02006c6:	b6e50513          	addi	a0,a0,-1170 # ffffffffc0202230 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	b4450513          	addi	a0,a0,-1212 # ffffffffc0202210 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	afa50513          	addi	a0,a0,-1286 # ffffffffc02021d0 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	b7050513          	addi	a0,a0,-1168 # ffffffffc0202250 <commands+0x480>
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
ffffffffc0200710:	00002517          	auipc	a0,0x2
ffffffffc0200714:	b6850513          	addi	a0,a0,-1176 # ffffffffc0202278 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00002517          	auipc	a0,0x2
ffffffffc020071e:	ad650513          	addi	a0,a0,-1322 # ffffffffc02021f0 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00002517          	auipc	a0,0x2
ffffffffc0200730:	b3c50513          	addi	a0,a0,-1220 # ffffffffc0202268 <commands+0x498>
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

ffffffffc020081e <buddy_system_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
buddy_system_check(void) {
ffffffffc020081e:	715d                	addi	sp,sp,-80
ffffffffc0200820:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200822:	00005417          	auipc	s0,0x5
ffffffffc0200826:	7ee40413          	addi	s0,s0,2030 # ffffffffc0206010 <free_area>
ffffffffc020082a:	641c                	ld	a5,8(s0)
ffffffffc020082c:	e486                	sd	ra,72(sp)
ffffffffc020082e:	fc26                	sd	s1,56(sp)
ffffffffc0200830:	f84a                	sd	s2,48(sp)
ffffffffc0200832:	f44e                	sd	s3,40(sp)
ffffffffc0200834:	f052                	sd	s4,32(sp)
ffffffffc0200836:	ec56                	sd	s5,24(sp)
ffffffffc0200838:	e85a                	sd	s6,16(sp)
ffffffffc020083a:	e45e                	sd	s7,8(sp)
ffffffffc020083c:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020083e:	30878763          	beq	a5,s0,ffffffffc0200b4c <buddy_system_check+0x32e>
    int count = 0, total = 0;
ffffffffc0200842:	4481                	li	s1,0
ffffffffc0200844:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200846:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020084a:	8b09                	andi	a4,a4,2
ffffffffc020084c:	30070463          	beqz	a4,ffffffffc0200b54 <buddy_system_check+0x336>
        count ++, total += p->property;
ffffffffc0200850:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200854:	679c                	ld	a5,8(a5)
ffffffffc0200856:	2905                	addiw	s2,s2,1
ffffffffc0200858:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020085a:	fe8796e3          	bne	a5,s0,ffffffffc0200846 <buddy_system_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc020085e:	89a6                	mv	s3,s1
ffffffffc0200860:	3f3000ef          	jal	ra,ffffffffc0201452 <nr_free_pages>
ffffffffc0200864:	4d351863          	bne	a0,s3,ffffffffc0200d34 <buddy_system_check+0x516>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200868:	4505                	li	a0,1
ffffffffc020086a:	36b000ef          	jal	ra,ffffffffc02013d4 <alloc_pages>
ffffffffc020086e:	8a2a                	mv	s4,a0
ffffffffc0200870:	4a050263          	beqz	a0,ffffffffc0200d14 <buddy_system_check+0x4f6>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200874:	4505                	li	a0,1
ffffffffc0200876:	35f000ef          	jal	ra,ffffffffc02013d4 <alloc_pages>
ffffffffc020087a:	89aa                	mv	s3,a0
ffffffffc020087c:	46050c63          	beqz	a0,ffffffffc0200cf4 <buddy_system_check+0x4d6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200880:	4505                	li	a0,1
ffffffffc0200882:	353000ef          	jal	ra,ffffffffc02013d4 <alloc_pages>
ffffffffc0200886:	8aaa                	mv	s5,a0
ffffffffc0200888:	42050663          	beqz	a0,ffffffffc0200cb4 <buddy_system_check+0x496>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020088c:	2f3a0463          	beq	s4,s3,ffffffffc0200b74 <buddy_system_check+0x356>
ffffffffc0200890:	2eaa0263          	beq	s4,a0,ffffffffc0200b74 <buddy_system_check+0x356>
ffffffffc0200894:	2ea98063          	beq	s3,a0,ffffffffc0200b74 <buddy_system_check+0x356>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200898:	000a2783          	lw	a5,0(s4)
ffffffffc020089c:	2e079c63          	bnez	a5,ffffffffc0200b94 <buddy_system_check+0x376>
ffffffffc02008a0:	0009a783          	lw	a5,0(s3)
ffffffffc02008a4:	2e079863          	bnez	a5,ffffffffc0200b94 <buddy_system_check+0x376>
ffffffffc02008a8:	411c                	lw	a5,0(a0)
ffffffffc02008aa:	2e079563          	bnez	a5,ffffffffc0200b94 <buddy_system_check+0x376>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008ae:	00006797          	auipc	a5,0x6
ffffffffc02008b2:	b927b783          	ld	a5,-1134(a5) # ffffffffc0206440 <pages>
ffffffffc02008b6:	40fa0733          	sub	a4,s4,a5
ffffffffc02008ba:	8711                	srai	a4,a4,0x4
ffffffffc02008bc:	00002597          	auipc	a1,0x2
ffffffffc02008c0:	13c5b583          	ld	a1,316(a1) # ffffffffc02029f8 <error_string+0x38>
ffffffffc02008c4:	02b70733          	mul	a4,a4,a1
ffffffffc02008c8:	00002617          	auipc	a2,0x2
ffffffffc02008cc:	13863603          	ld	a2,312(a2) # ffffffffc0202a00 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02008d0:	00006697          	auipc	a3,0x6
ffffffffc02008d4:	b686b683          	ld	a3,-1176(a3) # ffffffffc0206438 <npage>
ffffffffc02008d8:	06b2                	slli	a3,a3,0xc
ffffffffc02008da:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc02008dc:	0732                	slli	a4,a4,0xc
ffffffffc02008de:	3ad77b63          	bgeu	a4,a3,ffffffffc0200c94 <buddy_system_check+0x476>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008e2:	40f98733          	sub	a4,s3,a5
ffffffffc02008e6:	8711                	srai	a4,a4,0x4
ffffffffc02008e8:	02b70733          	mul	a4,a4,a1
ffffffffc02008ec:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02008ee:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02008f0:	56d77263          	bgeu	a4,a3,ffffffffc0200e54 <buddy_system_check+0x636>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008f4:	40f507b3          	sub	a5,a0,a5
ffffffffc02008f8:	8791                	srai	a5,a5,0x4
ffffffffc02008fa:	02b787b3          	mul	a5,a5,a1
ffffffffc02008fe:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200900:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200902:	32d7f963          	bgeu	a5,a3,ffffffffc0200c34 <buddy_system_check+0x416>
    assert(alloc_page() == NULL);
ffffffffc0200906:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200908:	00043c03          	ld	s8,0(s0)
ffffffffc020090c:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200910:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200914:	e400                	sd	s0,8(s0)
ffffffffc0200916:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200918:	00005797          	auipc	a5,0x5
ffffffffc020091c:	7007a423          	sw	zero,1800(a5) # ffffffffc0206020 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200920:	2b5000ef          	jal	ra,ffffffffc02013d4 <alloc_pages>
ffffffffc0200924:	2e051863          	bnez	a0,ffffffffc0200c14 <buddy_system_check+0x3f6>
    free_page(p0);
ffffffffc0200928:	4585                	li	a1,1
ffffffffc020092a:	8552                	mv	a0,s4
ffffffffc020092c:	2e7000ef          	jal	ra,ffffffffc0201412 <free_pages>
    free_page(p1);
ffffffffc0200930:	4585                	li	a1,1
ffffffffc0200932:	854e                	mv	a0,s3
ffffffffc0200934:	2df000ef          	jal	ra,ffffffffc0201412 <free_pages>
    free_page(p2);
ffffffffc0200938:	4585                	li	a1,1
ffffffffc020093a:	8556                	mv	a0,s5
ffffffffc020093c:	2d7000ef          	jal	ra,ffffffffc0201412 <free_pages>
    assert(nr_free == 3);
ffffffffc0200940:	4818                	lw	a4,16(s0)
ffffffffc0200942:	478d                	li	a5,3
ffffffffc0200944:	2af71863          	bne	a4,a5,ffffffffc0200bf4 <buddy_system_check+0x3d6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200948:	4505                	li	a0,1
ffffffffc020094a:	28b000ef          	jal	ra,ffffffffc02013d4 <alloc_pages>
ffffffffc020094e:	89aa                	mv	s3,a0
ffffffffc0200950:	28050263          	beqz	a0,ffffffffc0200bd4 <buddy_system_check+0x3b6>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200954:	4505                	li	a0,1
ffffffffc0200956:	27f000ef          	jal	ra,ffffffffc02013d4 <alloc_pages>
ffffffffc020095a:	8aaa                	mv	s5,a0
ffffffffc020095c:	30050c63          	beqz	a0,ffffffffc0200c74 <buddy_system_check+0x456>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200960:	4505                	li	a0,1
ffffffffc0200962:	273000ef          	jal	ra,ffffffffc02013d4 <alloc_pages>
ffffffffc0200966:	8a2a                	mv	s4,a0
ffffffffc0200968:	2e050663          	beqz	a0,ffffffffc0200c54 <buddy_system_check+0x436>
    assert(alloc_page() == NULL);
ffffffffc020096c:	4505                	li	a0,1
ffffffffc020096e:	267000ef          	jal	ra,ffffffffc02013d4 <alloc_pages>
ffffffffc0200972:	24051163          	bnez	a0,ffffffffc0200bb4 <buddy_system_check+0x396>
    free_page(p0);
ffffffffc0200976:	4585                	li	a1,1
ffffffffc0200978:	854e                	mv	a0,s3
ffffffffc020097a:	299000ef          	jal	ra,ffffffffc0201412 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc020097e:	641c                	ld	a5,8(s0)
ffffffffc0200980:	34878a63          	beq	a5,s0,ffffffffc0200cd4 <buddy_system_check+0x4b6>
    assert((p = alloc_page()) == p0);
ffffffffc0200984:	4505                	li	a0,1
ffffffffc0200986:	24f000ef          	jal	ra,ffffffffc02013d4 <alloc_pages>
ffffffffc020098a:	4aa99563          	bne	s3,a0,ffffffffc0200e34 <buddy_system_check+0x616>
    assert(alloc_page() == NULL);
ffffffffc020098e:	4505                	li	a0,1
ffffffffc0200990:	245000ef          	jal	ra,ffffffffc02013d4 <alloc_pages>
ffffffffc0200994:	48051063          	bnez	a0,ffffffffc0200e14 <buddy_system_check+0x5f6>
    assert(nr_free == 0);
ffffffffc0200998:	481c                	lw	a5,16(s0)
ffffffffc020099a:	44079d63          	bnez	a5,ffffffffc0200df4 <buddy_system_check+0x5d6>
    free_page(p);
ffffffffc020099e:	854e                	mv	a0,s3
ffffffffc02009a0:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02009a2:	01843023          	sd	s8,0(s0)
ffffffffc02009a6:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc02009aa:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc02009ae:	265000ef          	jal	ra,ffffffffc0201412 <free_pages>
    free_page(p1);
ffffffffc02009b2:	8556                	mv	a0,s5
ffffffffc02009b4:	4585                	li	a1,1
ffffffffc02009b6:	25d000ef          	jal	ra,ffffffffc0201412 <free_pages>
    free_page(p2);
ffffffffc02009ba:	4585                	li	a1,1
ffffffffc02009bc:	8552                	mv	a0,s4
ffffffffc02009be:	255000ef          	jal	ra,ffffffffc0201412 <free_pages>
    
    basic_check();


    struct Page *p0 = alloc_pages(7), *p1 = alloc_pages(13), *p2 = alloc_pages(5);
ffffffffc02009c2:	451d                	li	a0,7
ffffffffc02009c4:	211000ef          	jal	ra,ffffffffc02013d4 <alloc_pages>
ffffffffc02009c8:	8aaa                	mv	s5,a0
ffffffffc02009ca:	4535                	li	a0,13
ffffffffc02009cc:	209000ef          	jal	ra,ffffffffc02013d4 <alloc_pages>
ffffffffc02009d0:	8a2a                	mv	s4,a0
ffffffffc02009d2:	4515                	li	a0,5
ffffffffc02009d4:	201000ef          	jal	ra,ffffffffc02013d4 <alloc_pages>
ffffffffc02009d8:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02009da:	3e0a8d63          	beqz	s5,ffffffffc0200dd4 <buddy_system_check+0x5b6>
ffffffffc02009de:	008ab783          	ld	a5,8(s5)
ffffffffc02009e2:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc02009e4:	8b85                	andi	a5,a5,1
ffffffffc02009e6:	3c079763          	bnez	a5,ffffffffc0200db4 <buddy_system_check+0x596>
    assert(p1 != NULL);
ffffffffc02009ea:	3a0a0563          	beqz	s4,ffffffffc0200d94 <buddy_system_check+0x576>
ffffffffc02009ee:	008a3783          	ld	a5,8(s4)
ffffffffc02009f2:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p1));
ffffffffc02009f4:	8b85                	andi	a5,a5,1
ffffffffc02009f6:	36079f63          	bnez	a5,ffffffffc0200d74 <buddy_system_check+0x556>
    assert(p2 != NULL);
ffffffffc02009fa:	54050d63          	beqz	a0,ffffffffc0200f54 <buddy_system_check+0x736>
ffffffffc02009fe:	651c                	ld	a5,8(a0)
ffffffffc0200a00:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p2));
ffffffffc0200a02:	8b85                	andi	a5,a5,1
ffffffffc0200a04:	52079863          	bnez	a5,ffffffffc0200f34 <buddy_system_check+0x716>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200a08:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200a0a:	00043b83          	ld	s7,0(s0)
ffffffffc0200a0e:	00843b03          	ld	s6,8(s0)
ffffffffc0200a12:	e000                	sd	s0,0(s0)
ffffffffc0200a14:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200a16:	1bf000ef          	jal	ra,ffffffffc02013d4 <alloc_pages>
ffffffffc0200a1a:	4e051d63          	bnez	a0,ffffffffc0200f14 <buddy_system_check+0x6f6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0,2);
ffffffffc0200a1e:	8556                	mv	a0,s5
ffffffffc0200a20:	4589                	li	a1,2
    unsigned int nr_free_store = nr_free;
ffffffffc0200a22:	01042a83          	lw	s5,16(s0)
    nr_free = 0;
ffffffffc0200a26:	00005797          	auipc	a5,0x5
ffffffffc0200a2a:	5e07ad23          	sw	zero,1530(a5) # ffffffffc0206020 <free_area+0x10>
    free_pages(p0,2);
ffffffffc0200a2e:	1e5000ef          	jal	ra,ffffffffc0201412 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200a32:	641c                	ld	a5,8(s0)
ffffffffc0200a34:	4c878063          	beq	a5,s0,ffffffffc0200ef4 <buddy_system_check+0x6d6>
    free_pages(p1,5);
ffffffffc0200a38:	8552                	mv	a0,s4
ffffffffc0200a3a:	4595                	li	a1,5
ffffffffc0200a3c:	1d7000ef          	jal	ra,ffffffffc0201412 <free_pages>


    assert(alloc_pages(18) == NULL);
ffffffffc0200a40:	4549                	li	a0,18
ffffffffc0200a42:	193000ef          	jal	ra,ffffffffc02013d4 <alloc_pages>
ffffffffc0200a46:	48051763          	bnez	a0,ffffffffc0200ed4 <buddy_system_check+0x6b6>
    assert(!list_empty(&free_list));
ffffffffc0200a4a:	641c                	ld	a5,8(s0)
ffffffffc0200a4c:	46878463          	beq	a5,s0,ffffffffc0200eb4 <buddy_system_check+0x696>
    free_pages(p2,1);
ffffffffc0200a50:	854e                	mv	a0,s3
ffffffffc0200a52:	4585                	li	a1,1
ffffffffc0200a54:	1bf000ef          	jal	ra,ffffffffc0201412 <free_pages>
    
    p0 = alloc_pages(18);
ffffffffc0200a58:	4549                	li	a0,18
ffffffffc0200a5a:	17b000ef          	jal	ra,ffffffffc02013d4 <alloc_pages>
    assert(p0 != NULL);
ffffffffc0200a5e:	42050b63          	beqz	a0,ffffffffc0200e94 <buddy_system_check+0x676>
    assert(nr_free == 0);
ffffffffc0200a62:	481c                	lw	a5,16(s0)
ffffffffc0200a64:	40079863          	bnez	a5,ffffffffc0200e74 <buddy_system_check+0x656>

    free_pages(p0 + 3, 3);
ffffffffc0200a68:	458d                	li	a1,3
ffffffffc0200a6a:	09050513          	addi	a0,a0,144
ffffffffc0200a6e:	1a5000ef          	jal	ra,ffffffffc0201412 <free_pages>
    assert(nr_free == 32);
ffffffffc0200a72:	4818                	lw	a4,16(s0)
ffffffffc0200a74:	02000793          	li	a5,32
ffffffffc0200a78:	2cf71e63          	bne	a4,a5,ffffffffc0200d54 <buddy_system_check+0x536>


    p0 = alloc_pages(14);
ffffffffc0200a7c:	4539                	li	a0,14
ffffffffc0200a7e:	157000ef          	jal	ra,ffffffffc02013d4 <alloc_pages>
ffffffffc0200a82:	8c2a                	mv	s8,a0
    p1 = alloc_page();
ffffffffc0200a84:	4505                	li	a0,1
ffffffffc0200a86:	14f000ef          	jal	ra,ffffffffc02013d4 <alloc_pages>
ffffffffc0200a8a:	89aa                	mv	s3,a0
    p2 = alloc_pages(6);
ffffffffc0200a8c:	4519                	li	a0,6
ffffffffc0200a8e:	147000ef          	jal	ra,ffffffffc02013d4 <alloc_pages>
    assert(nr_free == 7);
ffffffffc0200a92:	4818                	lw	a4,16(s0)
ffffffffc0200a94:	479d                	li	a5,7
    p2 = alloc_pages(6);
ffffffffc0200a96:	8a2a                	mv	s4,a0
    assert(nr_free == 7);
ffffffffc0200a98:	58f71e63          	bne	a4,a5,ffffffffc0201034 <buddy_system_check+0x816>

    free_page(p1 - 1);
ffffffffc0200a9c:	4585                	li	a1,1
ffffffffc0200a9e:	fd098513          	addi	a0,s3,-48
ffffffffc0200aa2:	171000ef          	jal	ra,ffffffffc0201412 <free_pages>
ffffffffc0200aa6:	008c3783          	ld	a5,8(s8)
ffffffffc0200aaa:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0));
ffffffffc0200aac:	8b85                	andi	a5,a5,1
ffffffffc0200aae:	56078363          	beqz	a5,ffffffffc0201014 <buddy_system_check+0x7f6>
    assert(nr_free == 23);
ffffffffc0200ab2:	4818                	lw	a4,16(s0)
ffffffffc0200ab4:	47dd                	li	a5,23
ffffffffc0200ab6:	52f71f63          	bne	a4,a5,ffffffffc0200ff4 <buddy_system_check+0x7d6>
    free_page(p2);
ffffffffc0200aba:	4585                	li	a1,1
ffffffffc0200abc:	8552                	mv	a0,s4
ffffffffc0200abe:	155000ef          	jal	ra,ffffffffc0201412 <free_pages>
    assert(nr_free == 31);
ffffffffc0200ac2:	4818                	lw	a4,16(s0)
ffffffffc0200ac4:	47fd                	li	a5,31
ffffffffc0200ac6:	50f71763          	bne	a4,a5,ffffffffc0200fd4 <buddy_system_check+0x7b6>
    free_page(p1);
ffffffffc0200aca:	4585                	li	a1,1
ffffffffc0200acc:	854e                	mv	a0,s3
ffffffffc0200ace:	145000ef          	jal	ra,ffffffffc0201412 <free_pages>
    assert(nr_free == 32);
ffffffffc0200ad2:	4818                	lw	a4,16(s0)
ffffffffc0200ad4:	02000793          	li	a5,32
ffffffffc0200ad8:	4cf71e63          	bne	a4,a5,ffffffffc0200fb4 <buddy_system_check+0x796>

    p0 = alloc_pages(7);
ffffffffc0200adc:	451d                	li	a0,7
ffffffffc0200ade:	0f7000ef          	jal	ra,ffffffffc02013d4 <alloc_pages>
ffffffffc0200ae2:	8c2a                	mv	s8,a0
    p1 = alloc_pages(13);
ffffffffc0200ae4:	4535                	li	a0,13
ffffffffc0200ae6:	0ef000ef          	jal	ra,ffffffffc02013d4 <alloc_pages>
ffffffffc0200aea:	8a2a                	mv	s4,a0
    p2 = alloc_pages(5);
ffffffffc0200aec:	4515                	li	a0,5
ffffffffc0200aee:	0e7000ef          	jal	ra,ffffffffc02013d4 <alloc_pages>
ffffffffc0200af2:	89aa                	mv	s3,a0

    nr_free = nr_free_store;
    free_list = free_list_store;

    free_page(p0);
ffffffffc0200af4:	4585                	li	a1,1
ffffffffc0200af6:	8562                	mv	a0,s8
    nr_free = nr_free_store;
ffffffffc0200af8:	01542823          	sw	s5,16(s0)
    free_list = free_list_store;
ffffffffc0200afc:	01743023          	sd	s7,0(s0)
ffffffffc0200b00:	01643423          	sd	s6,8(s0)
    free_page(p0);
ffffffffc0200b04:	10f000ef          	jal	ra,ffffffffc0201412 <free_pages>
    free_page(p1);
ffffffffc0200b08:	4585                	li	a1,1
ffffffffc0200b0a:	8552                	mv	a0,s4
ffffffffc0200b0c:	107000ef          	jal	ra,ffffffffc0201412 <free_pages>
    free_page(p2);
ffffffffc0200b10:	4585                	li	a1,1
ffffffffc0200b12:	854e                	mv	a0,s3
ffffffffc0200b14:	0ff000ef          	jal	ra,ffffffffc0201412 <free_pages>
    return listelm->next;
ffffffffc0200b18:	641c                	ld	a5,8(s0)
    

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b1a:	00878963          	beq	a5,s0,ffffffffc0200b2c <buddy_system_check+0x30e>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200b1e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b22:	679c                	ld	a5,8(a5)
ffffffffc0200b24:	397d                	addiw	s2,s2,-1
ffffffffc0200b26:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b28:	fe879be3          	bne	a5,s0,ffffffffc0200b1e <buddy_system_check+0x300>
    }
    assert(count == 0);
ffffffffc0200b2c:	46091463          	bnez	s2,ffffffffc0200f94 <buddy_system_check+0x776>
    assert(total == 0);
ffffffffc0200b30:	44049263          	bnez	s1,ffffffffc0200f74 <buddy_system_check+0x756>

}
ffffffffc0200b34:	60a6                	ld	ra,72(sp)
ffffffffc0200b36:	6406                	ld	s0,64(sp)
ffffffffc0200b38:	74e2                	ld	s1,56(sp)
ffffffffc0200b3a:	7942                	ld	s2,48(sp)
ffffffffc0200b3c:	79a2                	ld	s3,40(sp)
ffffffffc0200b3e:	7a02                	ld	s4,32(sp)
ffffffffc0200b40:	6ae2                	ld	s5,24(sp)
ffffffffc0200b42:	6b42                	ld	s6,16(sp)
ffffffffc0200b44:	6ba2                	ld	s7,8(sp)
ffffffffc0200b46:	6c02                	ld	s8,0(sp)
ffffffffc0200b48:	6161                	addi	sp,sp,80
ffffffffc0200b4a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b4c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200b4e:	4481                	li	s1,0
ffffffffc0200b50:	4901                	li	s2,0
ffffffffc0200b52:	b339                	j	ffffffffc0200860 <buddy_system_check+0x42>
        assert(PageProperty(p));
ffffffffc0200b54:	00001697          	auipc	a3,0x1
ffffffffc0200b58:	77468693          	addi	a3,a3,1908 # ffffffffc02022c8 <commands+0x4f8>
ffffffffc0200b5c:	00001617          	auipc	a2,0x1
ffffffffc0200b60:	77c60613          	addi	a2,a2,1916 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200b64:	0e400593          	li	a1,228
ffffffffc0200b68:	00001517          	auipc	a0,0x1
ffffffffc0200b6c:	78850513          	addi	a0,a0,1928 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200b70:	83dff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b74:	00002697          	auipc	a3,0x2
ffffffffc0200b78:	81c68693          	addi	a3,a3,-2020 # ffffffffc0202390 <commands+0x5c0>
ffffffffc0200b7c:	00001617          	auipc	a2,0x1
ffffffffc0200b80:	75c60613          	addi	a2,a2,1884 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200b84:	0b000593          	li	a1,176
ffffffffc0200b88:	00001517          	auipc	a0,0x1
ffffffffc0200b8c:	76850513          	addi	a0,a0,1896 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200b90:	81dff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b94:	00002697          	auipc	a3,0x2
ffffffffc0200b98:	82468693          	addi	a3,a3,-2012 # ffffffffc02023b8 <commands+0x5e8>
ffffffffc0200b9c:	00001617          	auipc	a2,0x1
ffffffffc0200ba0:	73c60613          	addi	a2,a2,1852 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200ba4:	0b100593          	li	a1,177
ffffffffc0200ba8:	00001517          	auipc	a0,0x1
ffffffffc0200bac:	74850513          	addi	a0,a0,1864 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200bb0:	ffcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200bb4:	00002697          	auipc	a3,0x2
ffffffffc0200bb8:	8a468693          	addi	a3,a3,-1884 # ffffffffc0202458 <commands+0x688>
ffffffffc0200bbc:	00001617          	auipc	a2,0x1
ffffffffc0200bc0:	71c60613          	addi	a2,a2,1820 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200bc4:	0ca00593          	li	a1,202
ffffffffc0200bc8:	00001517          	auipc	a0,0x1
ffffffffc0200bcc:	72850513          	addi	a0,a0,1832 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200bd0:	fdcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bd4:	00001697          	auipc	a3,0x1
ffffffffc0200bd8:	75c68693          	addi	a3,a3,1884 # ffffffffc0202330 <commands+0x560>
ffffffffc0200bdc:	00001617          	auipc	a2,0x1
ffffffffc0200be0:	6fc60613          	addi	a2,a2,1788 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200be4:	0c500593          	li	a1,197
ffffffffc0200be8:	00001517          	auipc	a0,0x1
ffffffffc0200bec:	70850513          	addi	a0,a0,1800 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200bf0:	fbcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 3);
ffffffffc0200bf4:	00002697          	auipc	a3,0x2
ffffffffc0200bf8:	87c68693          	addi	a3,a3,-1924 # ffffffffc0202470 <commands+0x6a0>
ffffffffc0200bfc:	00001617          	auipc	a2,0x1
ffffffffc0200c00:	6dc60613          	addi	a2,a2,1756 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200c04:	0c300593          	li	a1,195
ffffffffc0200c08:	00001517          	auipc	a0,0x1
ffffffffc0200c0c:	6e850513          	addi	a0,a0,1768 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200c10:	f9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200c14:	00002697          	auipc	a3,0x2
ffffffffc0200c18:	84468693          	addi	a3,a3,-1980 # ffffffffc0202458 <commands+0x688>
ffffffffc0200c1c:	00001617          	auipc	a2,0x1
ffffffffc0200c20:	6bc60613          	addi	a2,a2,1724 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200c24:	0be00593          	li	a1,190
ffffffffc0200c28:	00001517          	auipc	a0,0x1
ffffffffc0200c2c:	6c850513          	addi	a0,a0,1736 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200c30:	f7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c34:	00002697          	auipc	a3,0x2
ffffffffc0200c38:	80468693          	addi	a3,a3,-2044 # ffffffffc0202438 <commands+0x668>
ffffffffc0200c3c:	00001617          	auipc	a2,0x1
ffffffffc0200c40:	69c60613          	addi	a2,a2,1692 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200c44:	0b500593          	li	a1,181
ffffffffc0200c48:	00001517          	auipc	a0,0x1
ffffffffc0200c4c:	6a850513          	addi	a0,a0,1704 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200c50:	f5cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c54:	00001697          	auipc	a3,0x1
ffffffffc0200c58:	71c68693          	addi	a3,a3,1820 # ffffffffc0202370 <commands+0x5a0>
ffffffffc0200c5c:	00001617          	auipc	a2,0x1
ffffffffc0200c60:	67c60613          	addi	a2,a2,1660 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200c64:	0c700593          	li	a1,199
ffffffffc0200c68:	00001517          	auipc	a0,0x1
ffffffffc0200c6c:	68850513          	addi	a0,a0,1672 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200c70:	f3cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c74:	00001697          	auipc	a3,0x1
ffffffffc0200c78:	6dc68693          	addi	a3,a3,1756 # ffffffffc0202350 <commands+0x580>
ffffffffc0200c7c:	00001617          	auipc	a2,0x1
ffffffffc0200c80:	65c60613          	addi	a2,a2,1628 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200c84:	0c600593          	li	a1,198
ffffffffc0200c88:	00001517          	auipc	a0,0x1
ffffffffc0200c8c:	66850513          	addi	a0,a0,1640 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200c90:	f1cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c94:	00001697          	auipc	a3,0x1
ffffffffc0200c98:	76468693          	addi	a3,a3,1892 # ffffffffc02023f8 <commands+0x628>
ffffffffc0200c9c:	00001617          	auipc	a2,0x1
ffffffffc0200ca0:	63c60613          	addi	a2,a2,1596 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200ca4:	0b300593          	li	a1,179
ffffffffc0200ca8:	00001517          	auipc	a0,0x1
ffffffffc0200cac:	64850513          	addi	a0,a0,1608 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200cb0:	efcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200cb4:	00001697          	auipc	a3,0x1
ffffffffc0200cb8:	6bc68693          	addi	a3,a3,1724 # ffffffffc0202370 <commands+0x5a0>
ffffffffc0200cbc:	00001617          	auipc	a2,0x1
ffffffffc0200cc0:	61c60613          	addi	a2,a2,1564 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200cc4:	0ae00593          	li	a1,174
ffffffffc0200cc8:	00001517          	auipc	a0,0x1
ffffffffc0200ccc:	62850513          	addi	a0,a0,1576 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200cd0:	edcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200cd4:	00001697          	auipc	a3,0x1
ffffffffc0200cd8:	7ac68693          	addi	a3,a3,1964 # ffffffffc0202480 <commands+0x6b0>
ffffffffc0200cdc:	00001617          	auipc	a2,0x1
ffffffffc0200ce0:	5fc60613          	addi	a2,a2,1532 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200ce4:	0cd00593          	li	a1,205
ffffffffc0200ce8:	00001517          	auipc	a0,0x1
ffffffffc0200cec:	60850513          	addi	a0,a0,1544 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200cf0:	ebcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200cf4:	00001697          	auipc	a3,0x1
ffffffffc0200cf8:	65c68693          	addi	a3,a3,1628 # ffffffffc0202350 <commands+0x580>
ffffffffc0200cfc:	00001617          	auipc	a2,0x1
ffffffffc0200d00:	5dc60613          	addi	a2,a2,1500 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200d04:	0ad00593          	li	a1,173
ffffffffc0200d08:	00001517          	auipc	a0,0x1
ffffffffc0200d0c:	5e850513          	addi	a0,a0,1512 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200d10:	e9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d14:	00001697          	auipc	a3,0x1
ffffffffc0200d18:	61c68693          	addi	a3,a3,1564 # ffffffffc0202330 <commands+0x560>
ffffffffc0200d1c:	00001617          	auipc	a2,0x1
ffffffffc0200d20:	5bc60613          	addi	a2,a2,1468 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200d24:	0ac00593          	li	a1,172
ffffffffc0200d28:	00001517          	auipc	a0,0x1
ffffffffc0200d2c:	5c850513          	addi	a0,a0,1480 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200d30:	e7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == nr_free_pages());
ffffffffc0200d34:	00001697          	auipc	a3,0x1
ffffffffc0200d38:	5dc68693          	addi	a3,a3,1500 # ffffffffc0202310 <commands+0x540>
ffffffffc0200d3c:	00001617          	auipc	a2,0x1
ffffffffc0200d40:	59c60613          	addi	a2,a2,1436 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200d44:	0e700593          	li	a1,231
ffffffffc0200d48:	00001517          	auipc	a0,0x1
ffffffffc0200d4c:	5a850513          	addi	a0,a0,1448 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200d50:	e5cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 32);
ffffffffc0200d54:	00002697          	auipc	a3,0x2
ffffffffc0200d58:	80468693          	addi	a3,a3,-2044 # ffffffffc0202558 <commands+0x788>
ffffffffc0200d5c:	00001617          	auipc	a2,0x1
ffffffffc0200d60:	57c60613          	addi	a2,a2,1404 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200d64:	10a00593          	li	a1,266
ffffffffc0200d68:	00001517          	auipc	a0,0x1
ffffffffc0200d6c:	58850513          	addi	a0,a0,1416 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200d70:	e3cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p1));
ffffffffc0200d74:	00001697          	auipc	a3,0x1
ffffffffc0200d78:	78c68693          	addi	a3,a3,1932 # ffffffffc0202500 <commands+0x730>
ffffffffc0200d7c:	00001617          	auipc	a2,0x1
ffffffffc0200d80:	55c60613          	addi	a2,a2,1372 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200d84:	0f000593          	li	a1,240
ffffffffc0200d88:	00001517          	auipc	a0,0x1
ffffffffc0200d8c:	56850513          	addi	a0,a0,1384 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200d90:	e1cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p1 != NULL);
ffffffffc0200d94:	00001697          	auipc	a3,0x1
ffffffffc0200d98:	75c68693          	addi	a3,a3,1884 # ffffffffc02024f0 <commands+0x720>
ffffffffc0200d9c:	00001617          	auipc	a2,0x1
ffffffffc0200da0:	53c60613          	addi	a2,a2,1340 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200da4:	0ef00593          	li	a1,239
ffffffffc0200da8:	00001517          	auipc	a0,0x1
ffffffffc0200dac:	54850513          	addi	a0,a0,1352 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200db0:	dfcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p0));
ffffffffc0200db4:	00001697          	auipc	a3,0x1
ffffffffc0200db8:	72468693          	addi	a3,a3,1828 # ffffffffc02024d8 <commands+0x708>
ffffffffc0200dbc:	00001617          	auipc	a2,0x1
ffffffffc0200dc0:	51c60613          	addi	a2,a2,1308 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200dc4:	0ee00593          	li	a1,238
ffffffffc0200dc8:	00001517          	auipc	a0,0x1
ffffffffc0200dcc:	52850513          	addi	a0,a0,1320 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200dd0:	ddcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200dd4:	00001697          	auipc	a3,0x1
ffffffffc0200dd8:	6f468693          	addi	a3,a3,1780 # ffffffffc02024c8 <commands+0x6f8>
ffffffffc0200ddc:	00001617          	auipc	a2,0x1
ffffffffc0200de0:	4fc60613          	addi	a2,a2,1276 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200de4:	0ed00593          	li	a1,237
ffffffffc0200de8:	00001517          	auipc	a0,0x1
ffffffffc0200dec:	50850513          	addi	a0,a0,1288 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200df0:	dbcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200df4:	00001697          	auipc	a3,0x1
ffffffffc0200df8:	6c468693          	addi	a3,a3,1732 # ffffffffc02024b8 <commands+0x6e8>
ffffffffc0200dfc:	00001617          	auipc	a2,0x1
ffffffffc0200e00:	4dc60613          	addi	a2,a2,1244 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200e04:	0d300593          	li	a1,211
ffffffffc0200e08:	00001517          	auipc	a0,0x1
ffffffffc0200e0c:	4e850513          	addi	a0,a0,1256 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200e10:	d9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e14:	00001697          	auipc	a3,0x1
ffffffffc0200e18:	64468693          	addi	a3,a3,1604 # ffffffffc0202458 <commands+0x688>
ffffffffc0200e1c:	00001617          	auipc	a2,0x1
ffffffffc0200e20:	4bc60613          	addi	a2,a2,1212 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200e24:	0d100593          	li	a1,209
ffffffffc0200e28:	00001517          	auipc	a0,0x1
ffffffffc0200e2c:	4c850513          	addi	a0,a0,1224 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200e30:	d7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200e34:	00001697          	auipc	a3,0x1
ffffffffc0200e38:	66468693          	addi	a3,a3,1636 # ffffffffc0202498 <commands+0x6c8>
ffffffffc0200e3c:	00001617          	auipc	a2,0x1
ffffffffc0200e40:	49c60613          	addi	a2,a2,1180 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200e44:	0d000593          	li	a1,208
ffffffffc0200e48:	00001517          	auipc	a0,0x1
ffffffffc0200e4c:	4a850513          	addi	a0,a0,1192 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200e50:	d5cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200e54:	00001697          	auipc	a3,0x1
ffffffffc0200e58:	5c468693          	addi	a3,a3,1476 # ffffffffc0202418 <commands+0x648>
ffffffffc0200e5c:	00001617          	auipc	a2,0x1
ffffffffc0200e60:	47c60613          	addi	a2,a2,1148 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200e64:	0b400593          	li	a1,180
ffffffffc0200e68:	00001517          	auipc	a0,0x1
ffffffffc0200e6c:	48850513          	addi	a0,a0,1160 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200e70:	d3cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200e74:	00001697          	auipc	a3,0x1
ffffffffc0200e78:	64468693          	addi	a3,a3,1604 # ffffffffc02024b8 <commands+0x6e8>
ffffffffc0200e7c:	00001617          	auipc	a2,0x1
ffffffffc0200e80:	45c60613          	addi	a2,a2,1116 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200e84:	10700593          	li	a1,263
ffffffffc0200e88:	00001517          	auipc	a0,0x1
ffffffffc0200e8c:	46850513          	addi	a0,a0,1128 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200e90:	d1cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200e94:	00001697          	auipc	a3,0x1
ffffffffc0200e98:	63468693          	addi	a3,a3,1588 # ffffffffc02024c8 <commands+0x6f8>
ffffffffc0200e9c:	00001617          	auipc	a2,0x1
ffffffffc0200ea0:	43c60613          	addi	a2,a2,1084 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200ea4:	10600593          	li	a1,262
ffffffffc0200ea8:	00001517          	auipc	a0,0x1
ffffffffc0200eac:	44850513          	addi	a0,a0,1096 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200eb0:	cfcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200eb4:	00001697          	auipc	a3,0x1
ffffffffc0200eb8:	5cc68693          	addi	a3,a3,1484 # ffffffffc0202480 <commands+0x6b0>
ffffffffc0200ebc:	00001617          	auipc	a2,0x1
ffffffffc0200ec0:	41c60613          	addi	a2,a2,1052 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200ec4:	10200593          	li	a1,258
ffffffffc0200ec8:	00001517          	auipc	a0,0x1
ffffffffc0200ecc:	42850513          	addi	a0,a0,1064 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200ed0:	cdcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(18) == NULL);
ffffffffc0200ed4:	00001697          	auipc	a3,0x1
ffffffffc0200ed8:	66c68693          	addi	a3,a3,1644 # ffffffffc0202540 <commands+0x770>
ffffffffc0200edc:	00001617          	auipc	a2,0x1
ffffffffc0200ee0:	3fc60613          	addi	a2,a2,1020 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200ee4:	10100593          	li	a1,257
ffffffffc0200ee8:	00001517          	auipc	a0,0x1
ffffffffc0200eec:	40850513          	addi	a0,a0,1032 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200ef0:	cbcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200ef4:	00001697          	auipc	a3,0x1
ffffffffc0200ef8:	58c68693          	addi	a3,a3,1420 # ffffffffc0202480 <commands+0x6b0>
ffffffffc0200efc:	00001617          	auipc	a2,0x1
ffffffffc0200f00:	3dc60613          	addi	a2,a2,988 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200f04:	0fd00593          	li	a1,253
ffffffffc0200f08:	00001517          	auipc	a0,0x1
ffffffffc0200f0c:	3e850513          	addi	a0,a0,1000 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200f10:	c9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f14:	00001697          	auipc	a3,0x1
ffffffffc0200f18:	54468693          	addi	a3,a3,1348 # ffffffffc0202458 <commands+0x688>
ffffffffc0200f1c:	00001617          	auipc	a2,0x1
ffffffffc0200f20:	3bc60613          	addi	a2,a2,956 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200f24:	0f700593          	li	a1,247
ffffffffc0200f28:	00001517          	auipc	a0,0x1
ffffffffc0200f2c:	3c850513          	addi	a0,a0,968 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200f30:	c7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p2));
ffffffffc0200f34:	00001697          	auipc	a3,0x1
ffffffffc0200f38:	5f468693          	addi	a3,a3,1524 # ffffffffc0202528 <commands+0x758>
ffffffffc0200f3c:	00001617          	auipc	a2,0x1
ffffffffc0200f40:	39c60613          	addi	a2,a2,924 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200f44:	0f200593          	li	a1,242
ffffffffc0200f48:	00001517          	auipc	a0,0x1
ffffffffc0200f4c:	3a850513          	addi	a0,a0,936 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200f50:	c5cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p2 != NULL);
ffffffffc0200f54:	00001697          	auipc	a3,0x1
ffffffffc0200f58:	5c468693          	addi	a3,a3,1476 # ffffffffc0202518 <commands+0x748>
ffffffffc0200f5c:	00001617          	auipc	a2,0x1
ffffffffc0200f60:	37c60613          	addi	a2,a2,892 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200f64:	0f100593          	li	a1,241
ffffffffc0200f68:	00001517          	auipc	a0,0x1
ffffffffc0200f6c:	38850513          	addi	a0,a0,904 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200f70:	c3cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == 0);
ffffffffc0200f74:	00001697          	auipc	a3,0x1
ffffffffc0200f78:	64c68693          	addi	a3,a3,1612 # ffffffffc02025c0 <commands+0x7f0>
ffffffffc0200f7c:	00001617          	auipc	a2,0x1
ffffffffc0200f80:	35c60613          	addi	a2,a2,860 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200f84:	12c00593          	li	a1,300
ffffffffc0200f88:	00001517          	auipc	a0,0x1
ffffffffc0200f8c:	36850513          	addi	a0,a0,872 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200f90:	c1cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(count == 0);
ffffffffc0200f94:	00001697          	auipc	a3,0x1
ffffffffc0200f98:	61c68693          	addi	a3,a3,1564 # ffffffffc02025b0 <commands+0x7e0>
ffffffffc0200f9c:	00001617          	auipc	a2,0x1
ffffffffc0200fa0:	33c60613          	addi	a2,a2,828 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200fa4:	12b00593          	li	a1,299
ffffffffc0200fa8:	00001517          	auipc	a0,0x1
ffffffffc0200fac:	34850513          	addi	a0,a0,840 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200fb0:	bfcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 32);
ffffffffc0200fb4:	00001697          	auipc	a3,0x1
ffffffffc0200fb8:	5a468693          	addi	a3,a3,1444 # ffffffffc0202558 <commands+0x788>
ffffffffc0200fbc:	00001617          	auipc	a2,0x1
ffffffffc0200fc0:	31c60613          	addi	a2,a2,796 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200fc4:	11800593          	li	a1,280
ffffffffc0200fc8:	00001517          	auipc	a0,0x1
ffffffffc0200fcc:	32850513          	addi	a0,a0,808 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200fd0:	bdcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 31);
ffffffffc0200fd4:	00001697          	auipc	a3,0x1
ffffffffc0200fd8:	5cc68693          	addi	a3,a3,1484 # ffffffffc02025a0 <commands+0x7d0>
ffffffffc0200fdc:	00001617          	auipc	a2,0x1
ffffffffc0200fe0:	2fc60613          	addi	a2,a2,764 # ffffffffc02022d8 <commands+0x508>
ffffffffc0200fe4:	11600593          	li	a1,278
ffffffffc0200fe8:	00001517          	auipc	a0,0x1
ffffffffc0200fec:	30850513          	addi	a0,a0,776 # ffffffffc02022f0 <commands+0x520>
ffffffffc0200ff0:	bbcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 23);
ffffffffc0200ff4:	00001697          	auipc	a3,0x1
ffffffffc0200ff8:	59c68693          	addi	a3,a3,1436 # ffffffffc0202590 <commands+0x7c0>
ffffffffc0200ffc:	00001617          	auipc	a2,0x1
ffffffffc0201000:	2dc60613          	addi	a2,a2,732 # ffffffffc02022d8 <commands+0x508>
ffffffffc0201004:	11400593          	li	a1,276
ffffffffc0201008:	00001517          	auipc	a0,0x1
ffffffffc020100c:	2e850513          	addi	a0,a0,744 # ffffffffc02022f0 <commands+0x520>
ffffffffc0201010:	b9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0));
ffffffffc0201014:	00001697          	auipc	a3,0x1
ffffffffc0201018:	56468693          	addi	a3,a3,1380 # ffffffffc0202578 <commands+0x7a8>
ffffffffc020101c:	00001617          	auipc	a2,0x1
ffffffffc0201020:	2bc60613          	addi	a2,a2,700 # ffffffffc02022d8 <commands+0x508>
ffffffffc0201024:	11300593          	li	a1,275
ffffffffc0201028:	00001517          	auipc	a0,0x1
ffffffffc020102c:	2c850513          	addi	a0,a0,712 # ffffffffc02022f0 <commands+0x520>
ffffffffc0201030:	b7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 7);
ffffffffc0201034:	00001697          	auipc	a3,0x1
ffffffffc0201038:	53468693          	addi	a3,a3,1332 # ffffffffc0202568 <commands+0x798>
ffffffffc020103c:	00001617          	auipc	a2,0x1
ffffffffc0201040:	29c60613          	addi	a2,a2,668 # ffffffffc02022d8 <commands+0x508>
ffffffffc0201044:	11000593          	li	a1,272
ffffffffc0201048:	00001517          	auipc	a0,0x1
ffffffffc020104c:	2a850513          	addi	a0,a0,680 # ffffffffc02022f0 <commands+0x520>
ffffffffc0201050:	b5cff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201054 <buddy_system_free_pages>:
buddy_system_free_pages(struct Page *base, size_t n) {
ffffffffc0201054:	1141                	addi	sp,sp,-16
ffffffffc0201056:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201058:	16058f63          	beqz	a1,ffffffffc02011d6 <buddy_system_free_pages+0x182>
    while(p -> property == 0) {
ffffffffc020105c:	491c                	lw	a5,16(a0)
ffffffffc020105e:	86be                	mv	a3,a5
ffffffffc0201060:	eb91                	bnez	a5,ffffffffc0201074 <buddy_system_free_pages+0x20>
ffffffffc0201062:	fe052683          	lw	a3,-32(a0)
        flag++;
ffffffffc0201066:	2785                	addiw	a5,a5,1
        p--;
ffffffffc0201068:	fd050513          	addi	a0,a0,-48
    while(p -> property == 0) {
ffffffffc020106c:	dafd                	beqz	a3,ffffffffc0201062 <buddy_system_free_pages+0xe>
    assert(flag + n <= size);
ffffffffc020106e:	1782                	slli	a5,a5,0x20
ffffffffc0201070:	9381                	srli	a5,a5,0x20
ffffffffc0201072:	95be                	add	a1,a1,a5
ffffffffc0201074:	02069793          	slli	a5,a3,0x20
ffffffffc0201078:	9381                	srli	a5,a5,0x20
ffffffffc020107a:	16b7ee63          	bltu	a5,a1,ffffffffc02011f6 <buddy_system_free_pages+0x1a2>
    for (; p != b + size; p ++) {
ffffffffc020107e:	00179613          	slli	a2,a5,0x1
ffffffffc0201082:	963e                	add	a2,a2,a5
ffffffffc0201084:	0612                	slli	a2,a2,0x4
ffffffffc0201086:	962a                	add	a2,a2,a0
ffffffffc0201088:	87aa                	mv	a5,a0
ffffffffc020108a:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020108c:	8b05                	andi	a4,a4,1
ffffffffc020108e:	12071463          	bnez	a4,ffffffffc02011b6 <buddy_system_free_pages+0x162>
ffffffffc0201092:	6798                	ld	a4,8(a5)
ffffffffc0201094:	8b09                	andi	a4,a4,2
ffffffffc0201096:	12071063          	bnez	a4,ffffffffc02011b6 <buddy_system_free_pages+0x162>
        p->flags = 0;
ffffffffc020109a:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020109e:	0007a023          	sw	zero,0(a5)
    for (; p != b + size; p ++) {
ffffffffc02010a2:	03078793          	addi	a5,a5,48
ffffffffc02010a6:	fec792e3          	bne	a5,a2,ffffffffc020108a <buddy_system_free_pages+0x36>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02010aa:	4789                	li	a5,2
ffffffffc02010ac:	00850713          	addi	a4,a0,8
ffffffffc02010b0:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += size;
ffffffffc02010b4:	00005597          	auipc	a1,0x5
ffffffffc02010b8:	f5c58593          	addi	a1,a1,-164 # ffffffffc0206010 <free_area>
ffffffffc02010bc:	4998                	lw	a4,16(a1)
    return list->next == list;
ffffffffc02010be:	659c                	ld	a5,8(a1)
ffffffffc02010c0:	9f35                	addw	a4,a4,a3
ffffffffc02010c2:	c998                	sw	a4,16(a1)
    if (list_empty(&free_list)) {
ffffffffc02010c4:	00b79763          	bne	a5,a1,ffffffffc02010d2 <buddy_system_free_pages+0x7e>
ffffffffc02010c8:	a8c9                	j	ffffffffc020119a <buddy_system_free_pages+0x146>
    return listelm->next;
ffffffffc02010ca:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02010cc:	0cb70e63          	beq	a4,a1,ffffffffc02011a8 <buddy_system_free_pages+0x154>
ffffffffc02010d0:	87ba                	mv	a5,a4
            p = le2page(le, page_link);
ffffffffc02010d2:	fe878713          	addi	a4,a5,-24
            if (b < p) {
ffffffffc02010d6:	fee57ae3          	bgeu	a0,a4,ffffffffc02010ca <buddy_system_free_pages+0x76>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02010da:	6398                	ld	a4,0(a5)
                list_add_before(le, &(b->page_link));
ffffffffc02010dc:	01850613          	addi	a2,a0,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02010e0:	e390                	sd	a2,0(a5)
ffffffffc02010e2:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02010e4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02010e6:	ed18                	sd	a4,24(a0)
ffffffffc02010e8:	5510                	lw	a2,40(a0)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02010ea:	58f5                	li	a7,-3
        if (((b -> location / b -> property) & 1 )
ffffffffc02010ec:	4918                	lw	a4,16(a0)
ffffffffc02010ee:	02e657bb          	divuw	a5,a2,a4
ffffffffc02010f2:	8b85                	andi	a5,a5,1
ffffffffc02010f4:	cb99                	beqz	a5,ffffffffc020110a <buddy_system_free_pages+0xb6>
         && b -> page_link.prev != &free_list
ffffffffc02010f6:	6d1c                	ld	a5,24(a0)
ffffffffc02010f8:	00b78663          	beq	a5,a1,ffffffffc0201104 <buddy_system_free_pages+0xb0>
         && (le2page(b -> page_link.prev,page_link) -> location == b -> location - size)
ffffffffc02010fc:	4b9c                	lw	a5,16(a5)
ffffffffc02010fe:	9e15                	subw	a2,a2,a3
ffffffffc0201100:	04c78e63          	beq	a5,a2,ffffffffc020115c <buddy_system_free_pages+0x108>
}
ffffffffc0201104:	60a2                	ld	ra,8(sp)
ffffffffc0201106:	0141                	addi	sp,sp,16
ffffffffc0201108:	8082                	ret
         && b -> page_link.next != &free_list
ffffffffc020110a:	711c                	ld	a5,32(a0)
ffffffffc020110c:	feb78ce3          	beq	a5,a1,ffffffffc0201104 <buddy_system_free_pages+0xb0>
         && (le2page(b -> page_link.next,page_link) -> location == b -> location + size)
ffffffffc0201110:	0107a803          	lw	a6,16(a5)
ffffffffc0201114:	00d607bb          	addw	a5,a2,a3
ffffffffc0201118:	fef816e3          	bne	a6,a5,ffffffffc0201104 <buddy_system_free_pages+0xb0>
         && ((b+size) -> property == size)) {
ffffffffc020111c:	02069813          	slli	a6,a3,0x20
ffffffffc0201120:	02085813          	srli	a6,a6,0x20
ffffffffc0201124:	00181793          	slli	a5,a6,0x1
ffffffffc0201128:	97c2                	add	a5,a5,a6
ffffffffc020112a:	0792                	slli	a5,a5,0x4
ffffffffc020112c:	97aa                	add	a5,a5,a0
ffffffffc020112e:	0107a803          	lw	a6,16(a5)
ffffffffc0201132:	fcd819e3          	bne	a6,a3,ffffffffc0201104 <buddy_system_free_pages+0xb0>
            b -> property *= 2;
ffffffffc0201136:	0017171b          	slliw	a4,a4,0x1
ffffffffc020113a:	c918                	sw	a4,16(a0)
ffffffffc020113c:	00878713          	addi	a4,a5,8
ffffffffc0201140:	6117302f          	amoand.d	zero,a7,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201144:	0187b803          	ld	a6,24(a5)
ffffffffc0201148:	7398                	ld	a4,32(a5)
            p -> property = 0;
ffffffffc020114a:	0007a823          	sw	zero,16(a5)
            size *= 2;
ffffffffc020114e:	0016969b          	slliw	a3,a3,0x1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201152:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0201156:	01073023          	sd	a6,0(a4)
ffffffffc020115a:	bf49                	j	ffffffffc02010ec <buddy_system_free_pages+0x98>
         && (b-size) -> property == size) {
ffffffffc020115c:	02069713          	slli	a4,a3,0x20
ffffffffc0201160:	9301                	srli	a4,a4,0x20
ffffffffc0201162:	00171793          	slli	a5,a4,0x1
ffffffffc0201166:	97ba                	add	a5,a5,a4
ffffffffc0201168:	0792                	slli	a5,a5,0x4
ffffffffc020116a:	40f507b3          	sub	a5,a0,a5
ffffffffc020116e:	4b98                	lw	a4,16(a5)
ffffffffc0201170:	f8e69ae3          	bne	a3,a4,ffffffffc0201104 <buddy_system_free_pages+0xb0>
            p -> property *= 2;
ffffffffc0201174:	0016969b          	slliw	a3,a3,0x1
ffffffffc0201178:	cb94                	sw	a3,16(a5)
ffffffffc020117a:	00850713          	addi	a4,a0,8
ffffffffc020117e:	6117302f          	amoand.d	zero,a7,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201182:	01853803          	ld	a6,24(a0)
ffffffffc0201186:	7118                	ld	a4,32(a0)
            b -> property = 0;
ffffffffc0201188:	00052823          	sw	zero,16(a0)
    prev->next = next;
ffffffffc020118c:	5790                	lw	a2,40(a5)
ffffffffc020118e:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0201192:	01073023          	sd	a6,0(a4)
            size *= 2;
ffffffffc0201196:	853e                	mv	a0,a5
ffffffffc0201198:	bf91                	j	ffffffffc02010ec <buddy_system_free_pages+0x98>
        list_add(&free_list, &(b->page_link));
ffffffffc020119a:	01850793          	addi	a5,a0,24
    prev->next = next->prev = elm;
ffffffffc020119e:	e19c                	sd	a5,0(a1)
ffffffffc02011a0:	e59c                	sd	a5,8(a1)
    elm->next = next;
ffffffffc02011a2:	f10c                	sd	a1,32(a0)
    elm->prev = prev;
ffffffffc02011a4:	ed0c                	sd	a1,24(a0)
}
ffffffffc02011a6:	b789                	j	ffffffffc02010e8 <buddy_system_free_pages+0x94>
                list_add(le, &(b->page_link));
ffffffffc02011a8:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02011ac:	e798                	sd	a4,8(a5)
ffffffffc02011ae:	e198                	sd	a4,0(a1)
    elm->next = next;
ffffffffc02011b0:	f10c                	sd	a1,32(a0)
    elm->prev = prev;
ffffffffc02011b2:	ed1c                	sd	a5,24(a0)
}
ffffffffc02011b4:	bf15                	j	ffffffffc02010e8 <buddy_system_free_pages+0x94>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02011b6:	00001697          	auipc	a3,0x1
ffffffffc02011ba:	43a68693          	addi	a3,a3,1082 # ffffffffc02025f0 <commands+0x820>
ffffffffc02011be:	00001617          	auipc	a2,0x1
ffffffffc02011c2:	11a60613          	addi	a2,a2,282 # ffffffffc02022d8 <commands+0x508>
ffffffffc02011c6:	06c00593          	li	a1,108
ffffffffc02011ca:	00001517          	auipc	a0,0x1
ffffffffc02011ce:	12650513          	addi	a0,a0,294 # ffffffffc02022f0 <commands+0x520>
ffffffffc02011d2:	9daff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc02011d6:	00001697          	auipc	a3,0x1
ffffffffc02011da:	3fa68693          	addi	a3,a3,1018 # ffffffffc02025d0 <commands+0x800>
ffffffffc02011de:	00001617          	auipc	a2,0x1
ffffffffc02011e2:	0fa60613          	addi	a2,a2,250 # ffffffffc02022d8 <commands+0x508>
ffffffffc02011e6:	06100593          	li	a1,97
ffffffffc02011ea:	00001517          	auipc	a0,0x1
ffffffffc02011ee:	10650513          	addi	a0,a0,262 # ffffffffc02022f0 <commands+0x520>
ffffffffc02011f2:	9baff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(flag + n <= size);
ffffffffc02011f6:	00001697          	auipc	a3,0x1
ffffffffc02011fa:	3e268693          	addi	a3,a3,994 # ffffffffc02025d8 <commands+0x808>
ffffffffc02011fe:	00001617          	auipc	a2,0x1
ffffffffc0201202:	0da60613          	addi	a2,a2,218 # ffffffffc02022d8 <commands+0x508>
ffffffffc0201206:	06900593          	li	a1,105
ffffffffc020120a:	00001517          	auipc	a0,0x1
ffffffffc020120e:	0e650513          	addi	a0,a0,230 # ffffffffc02022f0 <commands+0x520>
ffffffffc0201212:	99aff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201216 <buddy_system_alloc_pages>:
    assert(n > 0);
ffffffffc0201216:	c945                	beqz	a0,ffffffffc02012c6 <buddy_system_alloc_pages+0xb0>
    if (n > nr_free) {
ffffffffc0201218:	00005e17          	auipc	t3,0x5
ffffffffc020121c:	df8e0e13          	addi	t3,t3,-520 # ffffffffc0206010 <free_area>
ffffffffc0201220:	010e2f03          	lw	t5,16(t3)
ffffffffc0201224:	832a                	mv	t1,a0
ffffffffc0201226:	020f1793          	slli	a5,t5,0x20
ffffffffc020122a:	9381                	srli	a5,a5,0x20
ffffffffc020122c:	00a7ee63          	bltu	a5,a0,ffffffffc0201248 <buddy_system_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201230:	8772                	mv	a4,t3
ffffffffc0201232:	a801                	j	ffffffffc0201242 <buddy_system_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201234:	ff872803          	lw	a6,-8(a4)
ffffffffc0201238:	02081793          	slli	a5,a6,0x20
ffffffffc020123c:	9381                	srli	a5,a5,0x20
ffffffffc020123e:	0067f763          	bgeu	a5,t1,ffffffffc020124c <buddy_system_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201242:	6718                	ld	a4,8(a4)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201244:	ffc718e3          	bne	a4,t3,ffffffffc0201234 <buddy_system_alloc_pages+0x1e>
        return NULL;
ffffffffc0201248:	4501                	li	a0,0
}
ffffffffc020124a:	8082                	ret
        while(page -> property / 2 >= n){
ffffffffc020124c:	0018589b          	srliw	a7,a6,0x1
ffffffffc0201250:	6710                	ld	a2,8(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201252:	630c                	ld	a1,0(a4)
        struct Page *p = le2page(le, page_link);
ffffffffc0201254:	fe870513          	addi	a0,a4,-24
        while(page -> property / 2 >= n){
ffffffffc0201258:	86c6                	mv	a3,a7
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020125a:	4e89                	li	t4,2
ffffffffc020125c:	0468ea63          	bltu	a7,t1,ffffffffc02012b0 <buddy_system_alloc_pages+0x9a>
            p = page + page -> property / 2;
ffffffffc0201260:	00189793          	slli	a5,a7,0x1
ffffffffc0201264:	97c6                	add	a5,a5,a7
    prev->next = next;
ffffffffc0201266:	e590                	sd	a2,8(a1)
ffffffffc0201268:	0792                	slli	a5,a5,0x4
ffffffffc020126a:	97aa                	add	a5,a5,a0
    next->prev = prev;
ffffffffc020126c:	e20c                	sd	a1,0(a2)
            p -> property = page -> property / 2;
ffffffffc020126e:	cb94                	sw	a3,16(a5)
ffffffffc0201270:	00878693          	addi	a3,a5,8
ffffffffc0201274:	41d6b02f          	amoor.d	zero,t4,(a3)
            page -> property /= 2;
ffffffffc0201278:	ff872683          	lw	a3,-8(a4)
ffffffffc020127c:	8832                	mv	a6,a2
            list_add_before(next, &(p -> page_link));
ffffffffc020127e:	01878613          	addi	a2,a5,24
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201282:	00083583          	ld	a1,0(a6)
    prev->next = next->prev = elm;
ffffffffc0201286:	00c83023          	sd	a2,0(a6)
    elm->next = next;
ffffffffc020128a:	0307b023          	sd	a6,32(a5)
            page -> property /= 2;
ffffffffc020128e:	0016d81b          	srliw	a6,a3,0x1
ffffffffc0201292:	ff072c23          	sw	a6,-8(a4)
    prev->next = next->prev = elm;
ffffffffc0201296:	ef98                	sd	a4,24(a5)
ffffffffc0201298:	e598                	sd	a4,8(a1)
        while(page -> property / 2 >= n){
ffffffffc020129a:	0026d89b          	srliw	a7,a3,0x2
    elm->next = next;
ffffffffc020129e:	e710                	sd	a2,8(a4)
    elm->prev = prev;
ffffffffc02012a0:	e30c                	sd	a1,0(a4)
            page -> property /= 2;
ffffffffc02012a2:	0016d81b          	srliw	a6,a3,0x1
        while(page -> property / 2 >= n){
ffffffffc02012a6:	86c6                	mv	a3,a7
ffffffffc02012a8:	fa68fce3          	bgeu	a7,t1,ffffffffc0201260 <buddy_system_alloc_pages+0x4a>
        nr_free -= page -> property;
ffffffffc02012ac:	010e2f03          	lw	t5,16(t3)
    prev->next = next;
ffffffffc02012b0:	e590                	sd	a2,8(a1)
    next->prev = prev;
ffffffffc02012b2:	e20c                	sd	a1,0(a2)
ffffffffc02012b4:	410f083b          	subw	a6,t5,a6
ffffffffc02012b8:	010e2823          	sw	a6,16(t3)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02012bc:	57f5                	li	a5,-3
ffffffffc02012be:	1741                	addi	a4,a4,-16
ffffffffc02012c0:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc02012c4:	8082                	ret
buddy_system_alloc_pages(size_t n) {
ffffffffc02012c6:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02012c8:	00001697          	auipc	a3,0x1
ffffffffc02012cc:	30868693          	addi	a3,a3,776 # ffffffffc02025d0 <commands+0x800>
ffffffffc02012d0:	00001617          	auipc	a2,0x1
ffffffffc02012d4:	00860613          	addi	a2,a2,8 # ffffffffc02022d8 <commands+0x508>
ffffffffc02012d8:	03e00593          	li	a1,62
ffffffffc02012dc:	00001517          	auipc	a0,0x1
ffffffffc02012e0:	01450513          	addi	a0,a0,20 # ffffffffc02022f0 <commands+0x520>
buddy_system_alloc_pages(size_t n) {
ffffffffc02012e4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02012e6:	8c6ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02012ea <buddy_system_init_memmap>:
buddy_system_init_memmap(struct Page *base, size_t n) {
ffffffffc02012ea:	1141                	addi	sp,sp,-16
ffffffffc02012ec:	e406                	sd	ra,8(sp)
ffffffffc02012ee:	4785                	li	a5,1
    assert(n > 0);
ffffffffc02012f0:	c1dd                	beqz	a1,ffffffffc0201396 <buddy_system_init_memmap+0xac>
        size <<= 1;
ffffffffc02012f2:	0017971b          	slliw	a4,a5,0x1
    while (size <= n) {
ffffffffc02012f6:	02071693          	slli	a3,a4,0x20
ffffffffc02012fa:	9281                	srli	a3,a3,0x20
ffffffffc02012fc:	0007861b          	sext.w	a2,a5
        size <<= 1;
ffffffffc0201300:	0007079b          	sext.w	a5,a4
    while (size <= n) {
ffffffffc0201304:	fed5f7e3          	bgeu	a1,a3,ffffffffc02012f2 <buddy_system_init_memmap+0x8>
    size >>= 1;
ffffffffc0201308:	02161793          	slli	a5,a2,0x21
    for (; p != base + size; p ++) {
ffffffffc020130c:	0217d713          	srli	a4,a5,0x21
ffffffffc0201310:	0207d613          	srli	a2,a5,0x20
ffffffffc0201314:	963a                	add	a2,a2,a4
ffffffffc0201316:	0612                	slli	a2,a2,0x4
ffffffffc0201318:	962a                	add	a2,a2,a0
    size >>= 1;
ffffffffc020131a:	85ba                	mv	a1,a4
    for (; p != base + size; p ++) {
ffffffffc020131c:	02c50363          	beq	a0,a2,ffffffffc0201342 <buddy_system_init_memmap+0x58>
ffffffffc0201320:	87aa                	mv	a5,a0
    unsigned index = 0;
ffffffffc0201322:	4681                	li	a3,0
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201324:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0201326:	8b05                	andi	a4,a4,1
ffffffffc0201328:	cb21                	beqz	a4,ffffffffc0201378 <buddy_system_init_memmap+0x8e>
        p -> location = index;
ffffffffc020132a:	d794                	sw	a3,40(a5)
        p->flags = p->property = 0;
ffffffffc020132c:	0007a823          	sw	zero,16(a5)
ffffffffc0201330:	0007b423          	sd	zero,8(a5)
ffffffffc0201334:	0007a023          	sw	zero,0(a5)
    for (; p != base + size; p ++) {
ffffffffc0201338:	03078793          	addi	a5,a5,48
        index++;
ffffffffc020133c:	2685                	addiw	a3,a3,1
    for (; p != base + size; p ++) {
ffffffffc020133e:	fec793e3          	bne	a5,a2,ffffffffc0201324 <buddy_system_init_memmap+0x3a>
    base -> property = size;
ffffffffc0201342:	c90c                	sw	a1,16(a0)
    base -> location = 0;
ffffffffc0201344:	02052423          	sw	zero,40(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201348:	4789                	li	a5,2
ffffffffc020134a:	00850713          	addi	a4,a0,8
ffffffffc020134e:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += size;
ffffffffc0201352:	00005697          	auipc	a3,0x5
ffffffffc0201356:	cbe68693          	addi	a3,a3,-834 # ffffffffc0206010 <free_area>
ffffffffc020135a:	4a9c                	lw	a5,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020135c:	6698                	ld	a4,8(a3)
    nr_free += size;
ffffffffc020135e:	9fad                	addw	a5,a5,a1
ffffffffc0201360:	ca9c                	sw	a5,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201362:	04d71963          	bne	a4,a3,ffffffffc02013b4 <buddy_system_init_memmap+0xca>
}
ffffffffc0201366:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201368:	01850793          	addi	a5,a0,24
    prev->next = next->prev = elm;
ffffffffc020136c:	e31c                	sd	a5,0(a4)
ffffffffc020136e:	e71c                	sd	a5,8(a4)
    elm->next = next;
ffffffffc0201370:	f118                	sd	a4,32(a0)
    elm->prev = prev;
ffffffffc0201372:	ed18                	sd	a4,24(a0)
}
ffffffffc0201374:	0141                	addi	sp,sp,16
ffffffffc0201376:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201378:	00001697          	auipc	a3,0x1
ffffffffc020137c:	2a068693          	addi	a3,a3,672 # ffffffffc0202618 <commands+0x848>
ffffffffc0201380:	00001617          	auipc	a2,0x1
ffffffffc0201384:	f5860613          	addi	a2,a2,-168 # ffffffffc02022d8 <commands+0x508>
ffffffffc0201388:	45f5                	li	a1,29
ffffffffc020138a:	00001517          	auipc	a0,0x1
ffffffffc020138e:	f6650513          	addi	a0,a0,-154 # ffffffffc02022f0 <commands+0x520>
ffffffffc0201392:	81aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0201396:	00001697          	auipc	a3,0x1
ffffffffc020139a:	23a68693          	addi	a3,a3,570 # ffffffffc02025d0 <commands+0x800>
ffffffffc020139e:	00001617          	auipc	a2,0x1
ffffffffc02013a2:	f3a60613          	addi	a2,a2,-198 # ffffffffc02022d8 <commands+0x508>
ffffffffc02013a6:	45d1                	li	a1,20
ffffffffc02013a8:	00001517          	auipc	a0,0x1
ffffffffc02013ac:	f4850513          	addi	a0,a0,-184 # ffffffffc02022f0 <commands+0x520>
ffffffffc02013b0:	ffdfe0ef          	jal	ra,ffffffffc02003ac <__panic>
        assert(0);
ffffffffc02013b4:	00001697          	auipc	a3,0x1
ffffffffc02013b8:	27468693          	addi	a3,a3,628 # ffffffffc0202628 <commands+0x858>
ffffffffc02013bc:	00001617          	auipc	a2,0x1
ffffffffc02013c0:	f1c60613          	addi	a2,a2,-228 # ffffffffc02022d8 <commands+0x508>
ffffffffc02013c4:	02b00593          	li	a1,43
ffffffffc02013c8:	00001517          	auipc	a0,0x1
ffffffffc02013cc:	f2850513          	addi	a0,a0,-216 # ffffffffc02022f0 <commands+0x520>
ffffffffc02013d0:	fddfe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02013d4 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02013d4:	100027f3          	csrr	a5,sstatus
ffffffffc02013d8:	8b89                	andi	a5,a5,2
ffffffffc02013da:	e799                	bnez	a5,ffffffffc02013e8 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02013dc:	00005797          	auipc	a5,0x5
ffffffffc02013e0:	06c7b783          	ld	a5,108(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc02013e4:	6f9c                	ld	a5,24(a5)
ffffffffc02013e6:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc02013e8:	1141                	addi	sp,sp,-16
ffffffffc02013ea:	e406                	sd	ra,8(sp)
ffffffffc02013ec:	e022                	sd	s0,0(sp)
ffffffffc02013ee:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02013f0:	86eff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02013f4:	00005797          	auipc	a5,0x5
ffffffffc02013f8:	0547b783          	ld	a5,84(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc02013fc:	6f9c                	ld	a5,24(a5)
ffffffffc02013fe:	8522                	mv	a0,s0
ffffffffc0201400:	9782                	jalr	a5
ffffffffc0201402:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0201404:	854ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201408:	60a2                	ld	ra,8(sp)
ffffffffc020140a:	8522                	mv	a0,s0
ffffffffc020140c:	6402                	ld	s0,0(sp)
ffffffffc020140e:	0141                	addi	sp,sp,16
ffffffffc0201410:	8082                	ret

ffffffffc0201412 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201412:	100027f3          	csrr	a5,sstatus
ffffffffc0201416:	8b89                	andi	a5,a5,2
ffffffffc0201418:	e799                	bnez	a5,ffffffffc0201426 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc020141a:	00005797          	auipc	a5,0x5
ffffffffc020141e:	02e7b783          	ld	a5,46(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201422:	739c                	ld	a5,32(a5)
ffffffffc0201424:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201426:	1101                	addi	sp,sp,-32
ffffffffc0201428:	ec06                	sd	ra,24(sp)
ffffffffc020142a:	e822                	sd	s0,16(sp)
ffffffffc020142c:	e426                	sd	s1,8(sp)
ffffffffc020142e:	842a                	mv	s0,a0
ffffffffc0201430:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201432:	82cff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201436:	00005797          	auipc	a5,0x5
ffffffffc020143a:	0127b783          	ld	a5,18(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc020143e:	739c                	ld	a5,32(a5)
ffffffffc0201440:	85a6                	mv	a1,s1
ffffffffc0201442:	8522                	mv	a0,s0
ffffffffc0201444:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201446:	6442                	ld	s0,16(sp)
ffffffffc0201448:	60e2                	ld	ra,24(sp)
ffffffffc020144a:	64a2                	ld	s1,8(sp)
ffffffffc020144c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020144e:	80aff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc0201452 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201452:	100027f3          	csrr	a5,sstatus
ffffffffc0201456:	8b89                	andi	a5,a5,2
ffffffffc0201458:	e799                	bnez	a5,ffffffffc0201466 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc020145a:	00005797          	auipc	a5,0x5
ffffffffc020145e:	fee7b783          	ld	a5,-18(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201462:	779c                	ld	a5,40(a5)
ffffffffc0201464:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201466:	1141                	addi	sp,sp,-16
ffffffffc0201468:	e406                	sd	ra,8(sp)
ffffffffc020146a:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020146c:	ff3fe0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201470:	00005797          	auipc	a5,0x5
ffffffffc0201474:	fd87b783          	ld	a5,-40(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201478:	779c                	ld	a5,40(a5)
ffffffffc020147a:	9782                	jalr	a5
ffffffffc020147c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020147e:	fdbfe0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201482:	60a2                	ld	ra,8(sp)
ffffffffc0201484:	8522                	mv	a0,s0
ffffffffc0201486:	6402                	ld	s0,0(sp)
ffffffffc0201488:	0141                	addi	sp,sp,16
ffffffffc020148a:	8082                	ret

ffffffffc020148c <pmm_init>:
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc020148c:	00001797          	auipc	a5,0x1
ffffffffc0201490:	1c478793          	addi	a5,a5,452 # ffffffffc0202650 <buddy_system_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201494:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201496:	1101                	addi	sp,sp,-32
ffffffffc0201498:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020149a:	00001517          	auipc	a0,0x1
ffffffffc020149e:	1ee50513          	addi	a0,a0,494 # ffffffffc0202688 <buddy_system_pmm_manager+0x38>
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc02014a2:	00005497          	auipc	s1,0x5
ffffffffc02014a6:	fa648493          	addi	s1,s1,-90 # ffffffffc0206448 <pmm_manager>
void pmm_init(void) {
ffffffffc02014aa:	ec06                	sd	ra,24(sp)
ffffffffc02014ac:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc02014ae:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02014b0:	c03fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc02014b4:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02014b6:	00005417          	auipc	s0,0x5
ffffffffc02014ba:	faa40413          	addi	s0,s0,-86 # ffffffffc0206460 <va_pa_offset>
    pmm_manager->init();
ffffffffc02014be:	679c                	ld	a5,8(a5)
ffffffffc02014c0:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02014c2:	57f5                	li	a5,-3
ffffffffc02014c4:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02014c6:	00001517          	auipc	a0,0x1
ffffffffc02014ca:	1da50513          	addi	a0,a0,474 # ffffffffc02026a0 <buddy_system_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02014ce:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc02014d0:	be3fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02014d4:	46c5                	li	a3,17
ffffffffc02014d6:	06ee                	slli	a3,a3,0x1b
ffffffffc02014d8:	40100613          	li	a2,1025
ffffffffc02014dc:	16fd                	addi	a3,a3,-1
ffffffffc02014de:	07e005b7          	lui	a1,0x7e00
ffffffffc02014e2:	0656                	slli	a2,a2,0x15
ffffffffc02014e4:	00001517          	auipc	a0,0x1
ffffffffc02014e8:	1d450513          	addi	a0,a0,468 # ffffffffc02026b8 <buddy_system_pmm_manager+0x68>
ffffffffc02014ec:	bc7fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02014f0:	777d                	lui	a4,0xfffff
ffffffffc02014f2:	00006797          	auipc	a5,0x6
ffffffffc02014f6:	f7d78793          	addi	a5,a5,-131 # ffffffffc020746f <end+0xfff>
ffffffffc02014fa:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02014fc:	00005517          	auipc	a0,0x5
ffffffffc0201500:	f3c50513          	addi	a0,a0,-196 # ffffffffc0206438 <npage>
ffffffffc0201504:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201508:	00005597          	auipc	a1,0x5
ffffffffc020150c:	f3858593          	addi	a1,a1,-200 # ffffffffc0206440 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201510:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201512:	e19c                	sd	a5,0(a1)
ffffffffc0201514:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201516:	4701                	li	a4,0
ffffffffc0201518:	4885                	li	a7,1
ffffffffc020151a:	fff80837          	lui	a6,0xfff80
ffffffffc020151e:	a011                	j	ffffffffc0201522 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0201520:	619c                	ld	a5,0(a1)
ffffffffc0201522:	97b6                	add	a5,a5,a3
ffffffffc0201524:	07a1                	addi	a5,a5,8
ffffffffc0201526:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020152a:	611c                	ld	a5,0(a0)
ffffffffc020152c:	0705                	addi	a4,a4,1
ffffffffc020152e:	03068693          	addi	a3,a3,48
ffffffffc0201532:	01078633          	add	a2,a5,a6
ffffffffc0201536:	fec765e3          	bltu	a4,a2,ffffffffc0201520 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020153a:	6190                	ld	a2,0(a1)
ffffffffc020153c:	00179713          	slli	a4,a5,0x1
ffffffffc0201540:	973e                	add	a4,a4,a5
ffffffffc0201542:	fe8006b7          	lui	a3,0xfe800
ffffffffc0201546:	0712                	slli	a4,a4,0x4
ffffffffc0201548:	96b2                	add	a3,a3,a2
ffffffffc020154a:	96ba                	add	a3,a3,a4
ffffffffc020154c:	c0200737          	lui	a4,0xc0200
ffffffffc0201550:	08e6ef63          	bltu	a3,a4,ffffffffc02015ee <pmm_init+0x162>
ffffffffc0201554:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0201556:	45c5                	li	a1,17
ffffffffc0201558:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020155a:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc020155c:	04b6e863          	bltu	a3,a1,ffffffffc02015ac <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201560:	609c                	ld	a5,0(s1)
ffffffffc0201562:	7b9c                	ld	a5,48(a5)
ffffffffc0201564:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201566:	00001517          	auipc	a0,0x1
ffffffffc020156a:	1ea50513          	addi	a0,a0,490 # ffffffffc0202750 <buddy_system_pmm_manager+0x100>
ffffffffc020156e:	b45fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201572:	00004597          	auipc	a1,0x4
ffffffffc0201576:	a8e58593          	addi	a1,a1,-1394 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc020157a:	00005797          	auipc	a5,0x5
ffffffffc020157e:	ecb7bf23          	sd	a1,-290(a5) # ffffffffc0206458 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201582:	c02007b7          	lui	a5,0xc0200
ffffffffc0201586:	08f5e063          	bltu	a1,a5,ffffffffc0201606 <pmm_init+0x17a>
ffffffffc020158a:	6010                	ld	a2,0(s0)
}
ffffffffc020158c:	6442                	ld	s0,16(sp)
ffffffffc020158e:	60e2                	ld	ra,24(sp)
ffffffffc0201590:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0201592:	40c58633          	sub	a2,a1,a2
ffffffffc0201596:	00005797          	auipc	a5,0x5
ffffffffc020159a:	eac7bd23          	sd	a2,-326(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020159e:	00001517          	auipc	a0,0x1
ffffffffc02015a2:	1d250513          	addi	a0,a0,466 # ffffffffc0202770 <buddy_system_pmm_manager+0x120>
}
ffffffffc02015a6:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02015a8:	b0bfe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02015ac:	6705                	lui	a4,0x1
ffffffffc02015ae:	177d                	addi	a4,a4,-1
ffffffffc02015b0:	96ba                	add	a3,a3,a4
ffffffffc02015b2:	777d                	lui	a4,0xfffff
ffffffffc02015b4:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02015b6:	00c6d513          	srli	a0,a3,0xc
ffffffffc02015ba:	00f57e63          	bgeu	a0,a5,ffffffffc02015d6 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc02015be:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02015c0:	982a                	add	a6,a6,a0
ffffffffc02015c2:	00181513          	slli	a0,a6,0x1
ffffffffc02015c6:	9542                	add	a0,a0,a6
ffffffffc02015c8:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02015ca:	8d95                	sub	a1,a1,a3
ffffffffc02015cc:	0512                	slli	a0,a0,0x4
    pmm_manager->init_memmap(base, n);
ffffffffc02015ce:	81b1                	srli	a1,a1,0xc
ffffffffc02015d0:	9532                	add	a0,a0,a2
ffffffffc02015d2:	9782                	jalr	a5
}
ffffffffc02015d4:	b771                	j	ffffffffc0201560 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc02015d6:	00001617          	auipc	a2,0x1
ffffffffc02015da:	14a60613          	addi	a2,a2,330 # ffffffffc0202720 <buddy_system_pmm_manager+0xd0>
ffffffffc02015de:	06b00593          	li	a1,107
ffffffffc02015e2:	00001517          	auipc	a0,0x1
ffffffffc02015e6:	15e50513          	addi	a0,a0,350 # ffffffffc0202740 <buddy_system_pmm_manager+0xf0>
ffffffffc02015ea:	dc3fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02015ee:	00001617          	auipc	a2,0x1
ffffffffc02015f2:	0fa60613          	addi	a2,a2,250 # ffffffffc02026e8 <buddy_system_pmm_manager+0x98>
ffffffffc02015f6:	06f00593          	li	a1,111
ffffffffc02015fa:	00001517          	auipc	a0,0x1
ffffffffc02015fe:	11650513          	addi	a0,a0,278 # ffffffffc0202710 <buddy_system_pmm_manager+0xc0>
ffffffffc0201602:	dabfe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201606:	86ae                	mv	a3,a1
ffffffffc0201608:	00001617          	auipc	a2,0x1
ffffffffc020160c:	0e060613          	addi	a2,a2,224 # ffffffffc02026e8 <buddy_system_pmm_manager+0x98>
ffffffffc0201610:	08a00593          	li	a1,138
ffffffffc0201614:	00001517          	auipc	a0,0x1
ffffffffc0201618:	0fc50513          	addi	a0,a0,252 # ffffffffc0202710 <buddy_system_pmm_manager+0xc0>
ffffffffc020161c:	d91fe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201620 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201620:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201624:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201626:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020162a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020162c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201630:	f022                	sd	s0,32(sp)
ffffffffc0201632:	ec26                	sd	s1,24(sp)
ffffffffc0201634:	e84a                	sd	s2,16(sp)
ffffffffc0201636:	f406                	sd	ra,40(sp)
ffffffffc0201638:	e44e                	sd	s3,8(sp)
ffffffffc020163a:	84aa                	mv	s1,a0
ffffffffc020163c:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020163e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201642:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201644:	03067e63          	bgeu	a2,a6,ffffffffc0201680 <printnum+0x60>
ffffffffc0201648:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020164a:	00805763          	blez	s0,ffffffffc0201658 <printnum+0x38>
ffffffffc020164e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201650:	85ca                	mv	a1,s2
ffffffffc0201652:	854e                	mv	a0,s3
ffffffffc0201654:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201656:	fc65                	bnez	s0,ffffffffc020164e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201658:	1a02                	slli	s4,s4,0x20
ffffffffc020165a:	00001797          	auipc	a5,0x1
ffffffffc020165e:	15678793          	addi	a5,a5,342 # ffffffffc02027b0 <buddy_system_pmm_manager+0x160>
ffffffffc0201662:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201666:	9a3e                	add	s4,s4,a5
}
ffffffffc0201668:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020166a:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020166e:	70a2                	ld	ra,40(sp)
ffffffffc0201670:	69a2                	ld	s3,8(sp)
ffffffffc0201672:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201674:	85ca                	mv	a1,s2
ffffffffc0201676:	87a6                	mv	a5,s1
}
ffffffffc0201678:	6942                	ld	s2,16(sp)
ffffffffc020167a:	64e2                	ld	s1,24(sp)
ffffffffc020167c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020167e:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201680:	03065633          	divu	a2,a2,a6
ffffffffc0201684:	8722                	mv	a4,s0
ffffffffc0201686:	f9bff0ef          	jal	ra,ffffffffc0201620 <printnum>
ffffffffc020168a:	b7f9                	j	ffffffffc0201658 <printnum+0x38>

ffffffffc020168c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020168c:	7119                	addi	sp,sp,-128
ffffffffc020168e:	f4a6                	sd	s1,104(sp)
ffffffffc0201690:	f0ca                	sd	s2,96(sp)
ffffffffc0201692:	ecce                	sd	s3,88(sp)
ffffffffc0201694:	e8d2                	sd	s4,80(sp)
ffffffffc0201696:	e4d6                	sd	s5,72(sp)
ffffffffc0201698:	e0da                	sd	s6,64(sp)
ffffffffc020169a:	fc5e                	sd	s7,56(sp)
ffffffffc020169c:	f06a                	sd	s10,32(sp)
ffffffffc020169e:	fc86                	sd	ra,120(sp)
ffffffffc02016a0:	f8a2                	sd	s0,112(sp)
ffffffffc02016a2:	f862                	sd	s8,48(sp)
ffffffffc02016a4:	f466                	sd	s9,40(sp)
ffffffffc02016a6:	ec6e                	sd	s11,24(sp)
ffffffffc02016a8:	892a                	mv	s2,a0
ffffffffc02016aa:	84ae                	mv	s1,a1
ffffffffc02016ac:	8d32                	mv	s10,a2
ffffffffc02016ae:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02016b0:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02016b4:	5b7d                	li	s6,-1
ffffffffc02016b6:	00001a97          	auipc	s5,0x1
ffffffffc02016ba:	12ea8a93          	addi	s5,s5,302 # ffffffffc02027e4 <buddy_system_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02016be:	00001b97          	auipc	s7,0x1
ffffffffc02016c2:	302b8b93          	addi	s7,s7,770 # ffffffffc02029c0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02016c6:	000d4503          	lbu	a0,0(s10)
ffffffffc02016ca:	001d0413          	addi	s0,s10,1
ffffffffc02016ce:	01350a63          	beq	a0,s3,ffffffffc02016e2 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02016d2:	c121                	beqz	a0,ffffffffc0201712 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02016d4:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02016d6:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02016d8:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02016da:	fff44503          	lbu	a0,-1(s0)
ffffffffc02016de:	ff351ae3          	bne	a0,s3,ffffffffc02016d2 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016e2:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02016e6:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02016ea:	4c81                	li	s9,0
ffffffffc02016ec:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02016ee:	5c7d                	li	s8,-1
ffffffffc02016f0:	5dfd                	li	s11,-1
ffffffffc02016f2:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02016f6:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016f8:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02016fc:	0ff5f593          	zext.b	a1,a1
ffffffffc0201700:	00140d13          	addi	s10,s0,1
ffffffffc0201704:	04b56263          	bltu	a0,a1,ffffffffc0201748 <vprintfmt+0xbc>
ffffffffc0201708:	058a                	slli	a1,a1,0x2
ffffffffc020170a:	95d6                	add	a1,a1,s5
ffffffffc020170c:	4194                	lw	a3,0(a1)
ffffffffc020170e:	96d6                	add	a3,a3,s5
ffffffffc0201710:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201712:	70e6                	ld	ra,120(sp)
ffffffffc0201714:	7446                	ld	s0,112(sp)
ffffffffc0201716:	74a6                	ld	s1,104(sp)
ffffffffc0201718:	7906                	ld	s2,96(sp)
ffffffffc020171a:	69e6                	ld	s3,88(sp)
ffffffffc020171c:	6a46                	ld	s4,80(sp)
ffffffffc020171e:	6aa6                	ld	s5,72(sp)
ffffffffc0201720:	6b06                	ld	s6,64(sp)
ffffffffc0201722:	7be2                	ld	s7,56(sp)
ffffffffc0201724:	7c42                	ld	s8,48(sp)
ffffffffc0201726:	7ca2                	ld	s9,40(sp)
ffffffffc0201728:	7d02                	ld	s10,32(sp)
ffffffffc020172a:	6de2                	ld	s11,24(sp)
ffffffffc020172c:	6109                	addi	sp,sp,128
ffffffffc020172e:	8082                	ret
            padc = '0';
ffffffffc0201730:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201732:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201736:	846a                	mv	s0,s10
ffffffffc0201738:	00140d13          	addi	s10,s0,1
ffffffffc020173c:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201740:	0ff5f593          	zext.b	a1,a1
ffffffffc0201744:	fcb572e3          	bgeu	a0,a1,ffffffffc0201708 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201748:	85a6                	mv	a1,s1
ffffffffc020174a:	02500513          	li	a0,37
ffffffffc020174e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201750:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201754:	8d22                	mv	s10,s0
ffffffffc0201756:	f73788e3          	beq	a5,s3,ffffffffc02016c6 <vprintfmt+0x3a>
ffffffffc020175a:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020175e:	1d7d                	addi	s10,s10,-1
ffffffffc0201760:	ff379de3          	bne	a5,s3,ffffffffc020175a <vprintfmt+0xce>
ffffffffc0201764:	b78d                	j	ffffffffc02016c6 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201766:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020176a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020176e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201770:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201774:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201778:	02d86463          	bltu	a6,a3,ffffffffc02017a0 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020177c:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201780:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201784:	0186873b          	addw	a4,a3,s8
ffffffffc0201788:	0017171b          	slliw	a4,a4,0x1
ffffffffc020178c:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020178e:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201792:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201794:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201798:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020179c:	fed870e3          	bgeu	a6,a3,ffffffffc020177c <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02017a0:	f40ddce3          	bgez	s11,ffffffffc02016f8 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02017a4:	8de2                	mv	s11,s8
ffffffffc02017a6:	5c7d                	li	s8,-1
ffffffffc02017a8:	bf81                	j	ffffffffc02016f8 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02017aa:	fffdc693          	not	a3,s11
ffffffffc02017ae:	96fd                	srai	a3,a3,0x3f
ffffffffc02017b0:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017b4:	00144603          	lbu	a2,1(s0)
ffffffffc02017b8:	2d81                	sext.w	s11,s11
ffffffffc02017ba:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02017bc:	bf35                	j	ffffffffc02016f8 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02017be:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017c2:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02017c6:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017c8:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02017ca:	bfd9                	j	ffffffffc02017a0 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02017cc:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02017ce:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02017d2:	01174463          	blt	a4,a7,ffffffffc02017da <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02017d6:	1a088e63          	beqz	a7,ffffffffc0201992 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02017da:	000a3603          	ld	a2,0(s4)
ffffffffc02017de:	46c1                	li	a3,16
ffffffffc02017e0:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02017e2:	2781                	sext.w	a5,a5
ffffffffc02017e4:	876e                	mv	a4,s11
ffffffffc02017e6:	85a6                	mv	a1,s1
ffffffffc02017e8:	854a                	mv	a0,s2
ffffffffc02017ea:	e37ff0ef          	jal	ra,ffffffffc0201620 <printnum>
            break;
ffffffffc02017ee:	bde1                	j	ffffffffc02016c6 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02017f0:	000a2503          	lw	a0,0(s4)
ffffffffc02017f4:	85a6                	mv	a1,s1
ffffffffc02017f6:	0a21                	addi	s4,s4,8
ffffffffc02017f8:	9902                	jalr	s2
            break;
ffffffffc02017fa:	b5f1                	j	ffffffffc02016c6 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02017fc:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02017fe:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201802:	01174463          	blt	a4,a7,ffffffffc020180a <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201806:	18088163          	beqz	a7,ffffffffc0201988 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020180a:	000a3603          	ld	a2,0(s4)
ffffffffc020180e:	46a9                	li	a3,10
ffffffffc0201810:	8a2e                	mv	s4,a1
ffffffffc0201812:	bfc1                	j	ffffffffc02017e2 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201814:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201818:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020181a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020181c:	bdf1                	j	ffffffffc02016f8 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020181e:	85a6                	mv	a1,s1
ffffffffc0201820:	02500513          	li	a0,37
ffffffffc0201824:	9902                	jalr	s2
            break;
ffffffffc0201826:	b545                	j	ffffffffc02016c6 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201828:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020182c:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020182e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201830:	b5e1                	j	ffffffffc02016f8 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201832:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201834:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201838:	01174463          	blt	a4,a7,ffffffffc0201840 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020183c:	14088163          	beqz	a7,ffffffffc020197e <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201840:	000a3603          	ld	a2,0(s4)
ffffffffc0201844:	46a1                	li	a3,8
ffffffffc0201846:	8a2e                	mv	s4,a1
ffffffffc0201848:	bf69                	j	ffffffffc02017e2 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc020184a:	03000513          	li	a0,48
ffffffffc020184e:	85a6                	mv	a1,s1
ffffffffc0201850:	e03e                	sd	a5,0(sp)
ffffffffc0201852:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201854:	85a6                	mv	a1,s1
ffffffffc0201856:	07800513          	li	a0,120
ffffffffc020185a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020185c:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020185e:	6782                	ld	a5,0(sp)
ffffffffc0201860:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201862:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201866:	bfb5                	j	ffffffffc02017e2 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201868:	000a3403          	ld	s0,0(s4)
ffffffffc020186c:	008a0713          	addi	a4,s4,8
ffffffffc0201870:	e03a                	sd	a4,0(sp)
ffffffffc0201872:	14040263          	beqz	s0,ffffffffc02019b6 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201876:	0fb05763          	blez	s11,ffffffffc0201964 <vprintfmt+0x2d8>
ffffffffc020187a:	02d00693          	li	a3,45
ffffffffc020187e:	0cd79163          	bne	a5,a3,ffffffffc0201940 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201882:	00044783          	lbu	a5,0(s0)
ffffffffc0201886:	0007851b          	sext.w	a0,a5
ffffffffc020188a:	cf85                	beqz	a5,ffffffffc02018c2 <vprintfmt+0x236>
ffffffffc020188c:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201890:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201894:	000c4563          	bltz	s8,ffffffffc020189e <vprintfmt+0x212>
ffffffffc0201898:	3c7d                	addiw	s8,s8,-1
ffffffffc020189a:	036c0263          	beq	s8,s6,ffffffffc02018be <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020189e:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02018a0:	0e0c8e63          	beqz	s9,ffffffffc020199c <vprintfmt+0x310>
ffffffffc02018a4:	3781                	addiw	a5,a5,-32
ffffffffc02018a6:	0ef47b63          	bgeu	s0,a5,ffffffffc020199c <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02018aa:	03f00513          	li	a0,63
ffffffffc02018ae:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018b0:	000a4783          	lbu	a5,0(s4)
ffffffffc02018b4:	3dfd                	addiw	s11,s11,-1
ffffffffc02018b6:	0a05                	addi	s4,s4,1
ffffffffc02018b8:	0007851b          	sext.w	a0,a5
ffffffffc02018bc:	ffe1                	bnez	a5,ffffffffc0201894 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02018be:	01b05963          	blez	s11,ffffffffc02018d0 <vprintfmt+0x244>
ffffffffc02018c2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02018c4:	85a6                	mv	a1,s1
ffffffffc02018c6:	02000513          	li	a0,32
ffffffffc02018ca:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02018cc:	fe0d9be3          	bnez	s11,ffffffffc02018c2 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02018d0:	6a02                	ld	s4,0(sp)
ffffffffc02018d2:	bbd5                	j	ffffffffc02016c6 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02018d4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02018d6:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02018da:	01174463          	blt	a4,a7,ffffffffc02018e2 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02018de:	08088d63          	beqz	a7,ffffffffc0201978 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02018e2:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02018e6:	0a044d63          	bltz	s0,ffffffffc02019a0 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02018ea:	8622                	mv	a2,s0
ffffffffc02018ec:	8a66                	mv	s4,s9
ffffffffc02018ee:	46a9                	li	a3,10
ffffffffc02018f0:	bdcd                	j	ffffffffc02017e2 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02018f2:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02018f6:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02018f8:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02018fa:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02018fe:	8fb5                	xor	a5,a5,a3
ffffffffc0201900:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201904:	02d74163          	blt	a4,a3,ffffffffc0201926 <vprintfmt+0x29a>
ffffffffc0201908:	00369793          	slli	a5,a3,0x3
ffffffffc020190c:	97de                	add	a5,a5,s7
ffffffffc020190e:	639c                	ld	a5,0(a5)
ffffffffc0201910:	cb99                	beqz	a5,ffffffffc0201926 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201912:	86be                	mv	a3,a5
ffffffffc0201914:	00001617          	auipc	a2,0x1
ffffffffc0201918:	ecc60613          	addi	a2,a2,-308 # ffffffffc02027e0 <buddy_system_pmm_manager+0x190>
ffffffffc020191c:	85a6                	mv	a1,s1
ffffffffc020191e:	854a                	mv	a0,s2
ffffffffc0201920:	0ce000ef          	jal	ra,ffffffffc02019ee <printfmt>
ffffffffc0201924:	b34d                	j	ffffffffc02016c6 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201926:	00001617          	auipc	a2,0x1
ffffffffc020192a:	eaa60613          	addi	a2,a2,-342 # ffffffffc02027d0 <buddy_system_pmm_manager+0x180>
ffffffffc020192e:	85a6                	mv	a1,s1
ffffffffc0201930:	854a                	mv	a0,s2
ffffffffc0201932:	0bc000ef          	jal	ra,ffffffffc02019ee <printfmt>
ffffffffc0201936:	bb41                	j	ffffffffc02016c6 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201938:	00001417          	auipc	s0,0x1
ffffffffc020193c:	e9040413          	addi	s0,s0,-368 # ffffffffc02027c8 <buddy_system_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201940:	85e2                	mv	a1,s8
ffffffffc0201942:	8522                	mv	a0,s0
ffffffffc0201944:	e43e                	sd	a5,8(sp)
ffffffffc0201946:	1cc000ef          	jal	ra,ffffffffc0201b12 <strnlen>
ffffffffc020194a:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020194e:	01b05b63          	blez	s11,ffffffffc0201964 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201952:	67a2                	ld	a5,8(sp)
ffffffffc0201954:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201958:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020195a:	85a6                	mv	a1,s1
ffffffffc020195c:	8552                	mv	a0,s4
ffffffffc020195e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201960:	fe0d9ce3          	bnez	s11,ffffffffc0201958 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201964:	00044783          	lbu	a5,0(s0)
ffffffffc0201968:	00140a13          	addi	s4,s0,1
ffffffffc020196c:	0007851b          	sext.w	a0,a5
ffffffffc0201970:	d3a5                	beqz	a5,ffffffffc02018d0 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201972:	05e00413          	li	s0,94
ffffffffc0201976:	bf39                	j	ffffffffc0201894 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201978:	000a2403          	lw	s0,0(s4)
ffffffffc020197c:	b7ad                	j	ffffffffc02018e6 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020197e:	000a6603          	lwu	a2,0(s4)
ffffffffc0201982:	46a1                	li	a3,8
ffffffffc0201984:	8a2e                	mv	s4,a1
ffffffffc0201986:	bdb1                	j	ffffffffc02017e2 <vprintfmt+0x156>
ffffffffc0201988:	000a6603          	lwu	a2,0(s4)
ffffffffc020198c:	46a9                	li	a3,10
ffffffffc020198e:	8a2e                	mv	s4,a1
ffffffffc0201990:	bd89                	j	ffffffffc02017e2 <vprintfmt+0x156>
ffffffffc0201992:	000a6603          	lwu	a2,0(s4)
ffffffffc0201996:	46c1                	li	a3,16
ffffffffc0201998:	8a2e                	mv	s4,a1
ffffffffc020199a:	b5a1                	j	ffffffffc02017e2 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020199c:	9902                	jalr	s2
ffffffffc020199e:	bf09                	j	ffffffffc02018b0 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02019a0:	85a6                	mv	a1,s1
ffffffffc02019a2:	02d00513          	li	a0,45
ffffffffc02019a6:	e03e                	sd	a5,0(sp)
ffffffffc02019a8:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02019aa:	6782                	ld	a5,0(sp)
ffffffffc02019ac:	8a66                	mv	s4,s9
ffffffffc02019ae:	40800633          	neg	a2,s0
ffffffffc02019b2:	46a9                	li	a3,10
ffffffffc02019b4:	b53d                	j	ffffffffc02017e2 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02019b6:	03b05163          	blez	s11,ffffffffc02019d8 <vprintfmt+0x34c>
ffffffffc02019ba:	02d00693          	li	a3,45
ffffffffc02019be:	f6d79de3          	bne	a5,a3,ffffffffc0201938 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02019c2:	00001417          	auipc	s0,0x1
ffffffffc02019c6:	e0640413          	addi	s0,s0,-506 # ffffffffc02027c8 <buddy_system_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02019ca:	02800793          	li	a5,40
ffffffffc02019ce:	02800513          	li	a0,40
ffffffffc02019d2:	00140a13          	addi	s4,s0,1
ffffffffc02019d6:	bd6d                	j	ffffffffc0201890 <vprintfmt+0x204>
ffffffffc02019d8:	00001a17          	auipc	s4,0x1
ffffffffc02019dc:	df1a0a13          	addi	s4,s4,-527 # ffffffffc02027c9 <buddy_system_pmm_manager+0x179>
ffffffffc02019e0:	02800513          	li	a0,40
ffffffffc02019e4:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02019e8:	05e00413          	li	s0,94
ffffffffc02019ec:	b565                	j	ffffffffc0201894 <vprintfmt+0x208>

ffffffffc02019ee <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02019ee:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02019f0:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02019f4:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02019f6:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02019f8:	ec06                	sd	ra,24(sp)
ffffffffc02019fa:	f83a                	sd	a4,48(sp)
ffffffffc02019fc:	fc3e                	sd	a5,56(sp)
ffffffffc02019fe:	e0c2                	sd	a6,64(sp)
ffffffffc0201a00:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201a02:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201a04:	c89ff0ef          	jal	ra,ffffffffc020168c <vprintfmt>
}
ffffffffc0201a08:	60e2                	ld	ra,24(sp)
ffffffffc0201a0a:	6161                	addi	sp,sp,80
ffffffffc0201a0c:	8082                	ret

ffffffffc0201a0e <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201a0e:	715d                	addi	sp,sp,-80
ffffffffc0201a10:	e486                	sd	ra,72(sp)
ffffffffc0201a12:	e0a6                	sd	s1,64(sp)
ffffffffc0201a14:	fc4a                	sd	s2,56(sp)
ffffffffc0201a16:	f84e                	sd	s3,48(sp)
ffffffffc0201a18:	f452                	sd	s4,40(sp)
ffffffffc0201a1a:	f056                	sd	s5,32(sp)
ffffffffc0201a1c:	ec5a                	sd	s6,24(sp)
ffffffffc0201a1e:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201a20:	c901                	beqz	a0,ffffffffc0201a30 <readline+0x22>
ffffffffc0201a22:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201a24:	00001517          	auipc	a0,0x1
ffffffffc0201a28:	dbc50513          	addi	a0,a0,-580 # ffffffffc02027e0 <buddy_system_pmm_manager+0x190>
ffffffffc0201a2c:	e86fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201a30:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a32:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201a34:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201a36:	4aa9                	li	s5,10
ffffffffc0201a38:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201a3a:	00004b97          	auipc	s7,0x4
ffffffffc0201a3e:	5eeb8b93          	addi	s7,s7,1518 # ffffffffc0206028 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a42:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201a46:	ee4fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201a4a:	00054a63          	bltz	a0,ffffffffc0201a5e <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a4e:	00a95a63          	bge	s2,a0,ffffffffc0201a62 <readline+0x54>
ffffffffc0201a52:	029a5263          	bge	s4,s1,ffffffffc0201a76 <readline+0x68>
        c = getchar();
ffffffffc0201a56:	ed4fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201a5a:	fe055ae3          	bgez	a0,ffffffffc0201a4e <readline+0x40>
            return NULL;
ffffffffc0201a5e:	4501                	li	a0,0
ffffffffc0201a60:	a091                	j	ffffffffc0201aa4 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201a62:	03351463          	bne	a0,s3,ffffffffc0201a8a <readline+0x7c>
ffffffffc0201a66:	e8a9                	bnez	s1,ffffffffc0201ab8 <readline+0xaa>
        c = getchar();
ffffffffc0201a68:	ec2fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201a6c:	fe0549e3          	bltz	a0,ffffffffc0201a5e <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a70:	fea959e3          	bge	s2,a0,ffffffffc0201a62 <readline+0x54>
ffffffffc0201a74:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201a76:	e42a                	sd	a0,8(sp)
ffffffffc0201a78:	e70fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc0201a7c:	6522                	ld	a0,8(sp)
ffffffffc0201a7e:	009b87b3          	add	a5,s7,s1
ffffffffc0201a82:	2485                	addiw	s1,s1,1
ffffffffc0201a84:	00a78023          	sb	a0,0(a5)
ffffffffc0201a88:	bf7d                	j	ffffffffc0201a46 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201a8a:	01550463          	beq	a0,s5,ffffffffc0201a92 <readline+0x84>
ffffffffc0201a8e:	fb651ce3          	bne	a0,s6,ffffffffc0201a46 <readline+0x38>
            cputchar(c);
ffffffffc0201a92:	e56fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc0201a96:	00004517          	auipc	a0,0x4
ffffffffc0201a9a:	59250513          	addi	a0,a0,1426 # ffffffffc0206028 <buf>
ffffffffc0201a9e:	94aa                	add	s1,s1,a0
ffffffffc0201aa0:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201aa4:	60a6                	ld	ra,72(sp)
ffffffffc0201aa6:	6486                	ld	s1,64(sp)
ffffffffc0201aa8:	7962                	ld	s2,56(sp)
ffffffffc0201aaa:	79c2                	ld	s3,48(sp)
ffffffffc0201aac:	7a22                	ld	s4,40(sp)
ffffffffc0201aae:	7a82                	ld	s5,32(sp)
ffffffffc0201ab0:	6b62                	ld	s6,24(sp)
ffffffffc0201ab2:	6bc2                	ld	s7,16(sp)
ffffffffc0201ab4:	6161                	addi	sp,sp,80
ffffffffc0201ab6:	8082                	ret
            cputchar(c);
ffffffffc0201ab8:	4521                	li	a0,8
ffffffffc0201aba:	e2efe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201abe:	34fd                	addiw	s1,s1,-1
ffffffffc0201ac0:	b759                	j	ffffffffc0201a46 <readline+0x38>

ffffffffc0201ac2 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201ac2:	4781                	li	a5,0
ffffffffc0201ac4:	00004717          	auipc	a4,0x4
ffffffffc0201ac8:	54473703          	ld	a4,1348(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201acc:	88ba                	mv	a7,a4
ffffffffc0201ace:	852a                	mv	a0,a0
ffffffffc0201ad0:	85be                	mv	a1,a5
ffffffffc0201ad2:	863e                	mv	a2,a5
ffffffffc0201ad4:	00000073          	ecall
ffffffffc0201ad8:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201ada:	8082                	ret

ffffffffc0201adc <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201adc:	4781                	li	a5,0
ffffffffc0201ade:	00005717          	auipc	a4,0x5
ffffffffc0201ae2:	98a73703          	ld	a4,-1654(a4) # ffffffffc0206468 <SBI_SET_TIMER>
ffffffffc0201ae6:	88ba                	mv	a7,a4
ffffffffc0201ae8:	852a                	mv	a0,a0
ffffffffc0201aea:	85be                	mv	a1,a5
ffffffffc0201aec:	863e                	mv	a2,a5
ffffffffc0201aee:	00000073          	ecall
ffffffffc0201af2:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201af4:	8082                	ret

ffffffffc0201af6 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201af6:	4501                	li	a0,0
ffffffffc0201af8:	00004797          	auipc	a5,0x4
ffffffffc0201afc:	5087b783          	ld	a5,1288(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201b00:	88be                	mv	a7,a5
ffffffffc0201b02:	852a                	mv	a0,a0
ffffffffc0201b04:	85aa                	mv	a1,a0
ffffffffc0201b06:	862a                	mv	a2,a0
ffffffffc0201b08:	00000073          	ecall
ffffffffc0201b0c:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201b0e:	2501                	sext.w	a0,a0
ffffffffc0201b10:	8082                	ret

ffffffffc0201b12 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201b12:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201b14:	e589                	bnez	a1,ffffffffc0201b1e <strnlen+0xc>
ffffffffc0201b16:	a811                	j	ffffffffc0201b2a <strnlen+0x18>
        cnt ++;
ffffffffc0201b18:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201b1a:	00f58863          	beq	a1,a5,ffffffffc0201b2a <strnlen+0x18>
ffffffffc0201b1e:	00f50733          	add	a4,a0,a5
ffffffffc0201b22:	00074703          	lbu	a4,0(a4)
ffffffffc0201b26:	fb6d                	bnez	a4,ffffffffc0201b18 <strnlen+0x6>
ffffffffc0201b28:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201b2a:	852e                	mv	a0,a1
ffffffffc0201b2c:	8082                	ret

ffffffffc0201b2e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201b2e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201b32:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201b36:	cb89                	beqz	a5,ffffffffc0201b48 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201b38:	0505                	addi	a0,a0,1
ffffffffc0201b3a:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201b3c:	fee789e3          	beq	a5,a4,ffffffffc0201b2e <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201b40:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201b44:	9d19                	subw	a0,a0,a4
ffffffffc0201b46:	8082                	ret
ffffffffc0201b48:	4501                	li	a0,0
ffffffffc0201b4a:	bfed                	j	ffffffffc0201b44 <strcmp+0x16>

ffffffffc0201b4c <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201b4c:	00054783          	lbu	a5,0(a0)
ffffffffc0201b50:	c799                	beqz	a5,ffffffffc0201b5e <strchr+0x12>
        if (*s == c) {
ffffffffc0201b52:	00f58763          	beq	a1,a5,ffffffffc0201b60 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201b56:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201b5a:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201b5c:	fbfd                	bnez	a5,ffffffffc0201b52 <strchr+0x6>
    }
    return NULL;
ffffffffc0201b5e:	4501                	li	a0,0
}
ffffffffc0201b60:	8082                	ret

ffffffffc0201b62 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201b62:	ca01                	beqz	a2,ffffffffc0201b72 <memset+0x10>
ffffffffc0201b64:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201b66:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201b68:	0785                	addi	a5,a5,1
ffffffffc0201b6a:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201b6e:	fec79de3          	bne	a5,a2,ffffffffc0201b68 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201b72:	8082                	ret
