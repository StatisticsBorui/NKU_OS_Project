
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
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
ffffffffc0200024:	c0209137          	lui	sp,0xc0209

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

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	02650513          	addi	a0,a0,38 # ffffffffc020a058 <buf>
ffffffffc020003a:	00015617          	auipc	a2,0x15
ffffffffc020003e:	58a60613          	addi	a2,a2,1418 # ffffffffc02155c4 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	0f1040ef          	jal	ra,ffffffffc020493a <memset>

    cons_init();                // init the console
ffffffffc020004e:	4a6000ef          	jal	ra,ffffffffc02004f4 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00005597          	auipc	a1,0x5
ffffffffc0200056:	93658593          	addi	a1,a1,-1738 # ffffffffc0204988 <etext>
ffffffffc020005a:	00005517          	auipc	a0,0x5
ffffffffc020005e:	94e50513          	addi	a0,a0,-1714 # ffffffffc02049a8 <etext+0x20>
ffffffffc0200062:	11e000ef          	jal	ra,ffffffffc0200180 <cprintf>

    print_kerninfo();
ffffffffc0200066:	162000ef          	jal	ra,ffffffffc02001c8 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	663010ef          	jal	ra,ffffffffc0201ecc <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	536000ef          	jal	ra,ffffffffc02005a4 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5a4000ef          	jal	ra,ffffffffc0200616 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	0f7030ef          	jal	ra,ffffffffc020396c <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	0e6040ef          	jal	ra,ffffffffc0204160 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	4e8000ef          	jal	ra,ffffffffc0200566 <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	2bf020ef          	jal	ra,ffffffffc0202b40 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	41c000ef          	jal	ra,ffffffffc02004a2 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	50e000ef          	jal	ra,ffffffffc0200598 <intr_enable>

    cpu_idle();                 // run idle process
ffffffffc020008e:	37c040ef          	jal	ra,ffffffffc020440a <cpu_idle>

ffffffffc0200092 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200092:	715d                	addi	sp,sp,-80
ffffffffc0200094:	e486                	sd	ra,72(sp)
ffffffffc0200096:	e0a6                	sd	s1,64(sp)
ffffffffc0200098:	fc4a                	sd	s2,56(sp)
ffffffffc020009a:	f84e                	sd	s3,48(sp)
ffffffffc020009c:	f452                	sd	s4,40(sp)
ffffffffc020009e:	f056                	sd	s5,32(sp)
ffffffffc02000a0:	ec5a                	sd	s6,24(sp)
ffffffffc02000a2:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02000a4:	c901                	beqz	a0,ffffffffc02000b4 <readline+0x22>
ffffffffc02000a6:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02000a8:	00005517          	auipc	a0,0x5
ffffffffc02000ac:	90850513          	addi	a0,a0,-1784 # ffffffffc02049b0 <etext+0x28>
ffffffffc02000b0:	0d0000ef          	jal	ra,ffffffffc0200180 <cprintf>
readline(const char *prompt) {
ffffffffc02000b4:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000b6:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000b8:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000ba:	4aa9                	li	s5,10
ffffffffc02000bc:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000be:	0000ab97          	auipc	s7,0xa
ffffffffc02000c2:	f9ab8b93          	addi	s7,s7,-102 # ffffffffc020a058 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000c6:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000ca:	0ee000ef          	jal	ra,ffffffffc02001b8 <getchar>
        if (c < 0) {
ffffffffc02000ce:	00054a63          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000d2:	00a95a63          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000d6:	029a5263          	bge	s4,s1,ffffffffc02000fa <readline+0x68>
        c = getchar();
ffffffffc02000da:	0de000ef          	jal	ra,ffffffffc02001b8 <getchar>
        if (c < 0) {
ffffffffc02000de:	fe055ae3          	bgez	a0,ffffffffc02000d2 <readline+0x40>
            return NULL;
ffffffffc02000e2:	4501                	li	a0,0
ffffffffc02000e4:	a091                	j	ffffffffc0200128 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02000e6:	03351463          	bne	a0,s3,ffffffffc020010e <readline+0x7c>
ffffffffc02000ea:	e8a9                	bnez	s1,ffffffffc020013c <readline+0xaa>
        c = getchar();
ffffffffc02000ec:	0cc000ef          	jal	ra,ffffffffc02001b8 <getchar>
        if (c < 0) {
ffffffffc02000f0:	fe0549e3          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000f4:	fea959e3          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000f8:	4481                	li	s1,0
            cputchar(c);
ffffffffc02000fa:	e42a                	sd	a0,8(sp)
ffffffffc02000fc:	0ba000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            buf[i ++] = c;
ffffffffc0200100:	6522                	ld	a0,8(sp)
ffffffffc0200102:	009b87b3          	add	a5,s7,s1
ffffffffc0200106:	2485                	addiw	s1,s1,1
ffffffffc0200108:	00a78023          	sb	a0,0(a5)
ffffffffc020010c:	bf7d                	j	ffffffffc02000ca <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020010e:	01550463          	beq	a0,s5,ffffffffc0200116 <readline+0x84>
ffffffffc0200112:	fb651ce3          	bne	a0,s6,ffffffffc02000ca <readline+0x38>
            cputchar(c);
ffffffffc0200116:	0a0000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            buf[i] = '\0';
ffffffffc020011a:	0000a517          	auipc	a0,0xa
ffffffffc020011e:	f3e50513          	addi	a0,a0,-194 # ffffffffc020a058 <buf>
ffffffffc0200122:	94aa                	add	s1,s1,a0
ffffffffc0200124:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200128:	60a6                	ld	ra,72(sp)
ffffffffc020012a:	6486                	ld	s1,64(sp)
ffffffffc020012c:	7962                	ld	s2,56(sp)
ffffffffc020012e:	79c2                	ld	s3,48(sp)
ffffffffc0200130:	7a22                	ld	s4,40(sp)
ffffffffc0200132:	7a82                	ld	s5,32(sp)
ffffffffc0200134:	6b62                	ld	s6,24(sp)
ffffffffc0200136:	6bc2                	ld	s7,16(sp)
ffffffffc0200138:	6161                	addi	sp,sp,80
ffffffffc020013a:	8082                	ret
            cputchar(c);
ffffffffc020013c:	4521                	li	a0,8
ffffffffc020013e:	078000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            i --;
ffffffffc0200142:	34fd                	addiw	s1,s1,-1
ffffffffc0200144:	b759                	j	ffffffffc02000ca <readline+0x38>

ffffffffc0200146 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200146:	1141                	addi	sp,sp,-16
ffffffffc0200148:	e022                	sd	s0,0(sp)
ffffffffc020014a:	e406                	sd	ra,8(sp)
ffffffffc020014c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020014e:	3a8000ef          	jal	ra,ffffffffc02004f6 <cons_putc>
    (*cnt) ++;
ffffffffc0200152:	401c                	lw	a5,0(s0)
}
ffffffffc0200154:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200156:	2785                	addiw	a5,a5,1
ffffffffc0200158:	c01c                	sw	a5,0(s0)
}
ffffffffc020015a:	6402                	ld	s0,0(sp)
ffffffffc020015c:	0141                	addi	sp,sp,16
ffffffffc020015e:	8082                	ret

ffffffffc0200160 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200160:	1101                	addi	sp,sp,-32
ffffffffc0200162:	862a                	mv	a2,a0
ffffffffc0200164:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200166:	00000517          	auipc	a0,0x0
ffffffffc020016a:	fe050513          	addi	a0,a0,-32 # ffffffffc0200146 <cputch>
ffffffffc020016e:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200170:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200172:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200174:	3c8040ef          	jal	ra,ffffffffc020453c <vprintfmt>
    return cnt;
}
ffffffffc0200178:	60e2                	ld	ra,24(sp)
ffffffffc020017a:	4532                	lw	a0,12(sp)
ffffffffc020017c:	6105                	addi	sp,sp,32
ffffffffc020017e:	8082                	ret

ffffffffc0200180 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200180:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200182:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200186:	8e2a                	mv	t3,a0
ffffffffc0200188:	f42e                	sd	a1,40(sp)
ffffffffc020018a:	f832                	sd	a2,48(sp)
ffffffffc020018c:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020018e:	00000517          	auipc	a0,0x0
ffffffffc0200192:	fb850513          	addi	a0,a0,-72 # ffffffffc0200146 <cputch>
ffffffffc0200196:	004c                	addi	a1,sp,4
ffffffffc0200198:	869a                	mv	a3,t1
ffffffffc020019a:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc020019c:	ec06                	sd	ra,24(sp)
ffffffffc020019e:	e0ba                	sd	a4,64(sp)
ffffffffc02001a0:	e4be                	sd	a5,72(sp)
ffffffffc02001a2:	e8c2                	sd	a6,80(sp)
ffffffffc02001a4:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001a6:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001a8:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001aa:	392040ef          	jal	ra,ffffffffc020453c <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001ae:	60e2                	ld	ra,24(sp)
ffffffffc02001b0:	4512                	lw	a0,4(sp)
ffffffffc02001b2:	6125                	addi	sp,sp,96
ffffffffc02001b4:	8082                	ret

ffffffffc02001b6 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001b6:	a681                	j	ffffffffc02004f6 <cons_putc>

ffffffffc02001b8 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02001b8:	1141                	addi	sp,sp,-16
ffffffffc02001ba:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001bc:	36e000ef          	jal	ra,ffffffffc020052a <cons_getc>
ffffffffc02001c0:	dd75                	beqz	a0,ffffffffc02001bc <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02001c2:	60a2                	ld	ra,8(sp)
ffffffffc02001c4:	0141                	addi	sp,sp,16
ffffffffc02001c6:	8082                	ret

ffffffffc02001c8 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001ca:	00004517          	auipc	a0,0x4
ffffffffc02001ce:	7ee50513          	addi	a0,a0,2030 # ffffffffc02049b8 <etext+0x30>
void print_kerninfo(void) {
ffffffffc02001d2:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001d4:	fadff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02001d8:	00000597          	auipc	a1,0x0
ffffffffc02001dc:	e5a58593          	addi	a1,a1,-422 # ffffffffc0200032 <kern_init>
ffffffffc02001e0:	00004517          	auipc	a0,0x4
ffffffffc02001e4:	7f850513          	addi	a0,a0,2040 # ffffffffc02049d8 <etext+0x50>
ffffffffc02001e8:	f99ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02001ec:	00004597          	auipc	a1,0x4
ffffffffc02001f0:	79c58593          	addi	a1,a1,1948 # ffffffffc0204988 <etext>
ffffffffc02001f4:	00005517          	auipc	a0,0x5
ffffffffc02001f8:	80450513          	addi	a0,a0,-2044 # ffffffffc02049f8 <etext+0x70>
ffffffffc02001fc:	f85ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200200:	0000a597          	auipc	a1,0xa
ffffffffc0200204:	e5858593          	addi	a1,a1,-424 # ffffffffc020a058 <buf>
ffffffffc0200208:	00005517          	auipc	a0,0x5
ffffffffc020020c:	81050513          	addi	a0,a0,-2032 # ffffffffc0204a18 <etext+0x90>
ffffffffc0200210:	f71ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200214:	00015597          	auipc	a1,0x15
ffffffffc0200218:	3b058593          	addi	a1,a1,944 # ffffffffc02155c4 <end>
ffffffffc020021c:	00005517          	auipc	a0,0x5
ffffffffc0200220:	81c50513          	addi	a0,a0,-2020 # ffffffffc0204a38 <etext+0xb0>
ffffffffc0200224:	f5dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200228:	00015597          	auipc	a1,0x15
ffffffffc020022c:	79b58593          	addi	a1,a1,1947 # ffffffffc02159c3 <end+0x3ff>
ffffffffc0200230:	00000797          	auipc	a5,0x0
ffffffffc0200234:	e0278793          	addi	a5,a5,-510 # ffffffffc0200032 <kern_init>
ffffffffc0200238:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020023c:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200240:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200242:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200246:	95be                	add	a1,a1,a5
ffffffffc0200248:	85a9                	srai	a1,a1,0xa
ffffffffc020024a:	00005517          	auipc	a0,0x5
ffffffffc020024e:	80e50513          	addi	a0,a0,-2034 # ffffffffc0204a58 <etext+0xd0>
}
ffffffffc0200252:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200254:	b735                	j	ffffffffc0200180 <cprintf>

ffffffffc0200256 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200256:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200258:	00005617          	auipc	a2,0x5
ffffffffc020025c:	83060613          	addi	a2,a2,-2000 # ffffffffc0204a88 <etext+0x100>
ffffffffc0200260:	04d00593          	li	a1,77
ffffffffc0200264:	00005517          	auipc	a0,0x5
ffffffffc0200268:	83c50513          	addi	a0,a0,-1988 # ffffffffc0204aa0 <etext+0x118>
void print_stackframe(void) {
ffffffffc020026c:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020026e:	1d8000ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0200272 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200272:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200274:	00005617          	auipc	a2,0x5
ffffffffc0200278:	84460613          	addi	a2,a2,-1980 # ffffffffc0204ab8 <etext+0x130>
ffffffffc020027c:	00005597          	auipc	a1,0x5
ffffffffc0200280:	85c58593          	addi	a1,a1,-1956 # ffffffffc0204ad8 <etext+0x150>
ffffffffc0200284:	00005517          	auipc	a0,0x5
ffffffffc0200288:	85c50513          	addi	a0,a0,-1956 # ffffffffc0204ae0 <etext+0x158>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020028c:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020028e:	ef3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200292:	00005617          	auipc	a2,0x5
ffffffffc0200296:	85e60613          	addi	a2,a2,-1954 # ffffffffc0204af0 <etext+0x168>
ffffffffc020029a:	00005597          	auipc	a1,0x5
ffffffffc020029e:	87e58593          	addi	a1,a1,-1922 # ffffffffc0204b18 <etext+0x190>
ffffffffc02002a2:	00005517          	auipc	a0,0x5
ffffffffc02002a6:	83e50513          	addi	a0,a0,-1986 # ffffffffc0204ae0 <etext+0x158>
ffffffffc02002aa:	ed7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02002ae:	00005617          	auipc	a2,0x5
ffffffffc02002b2:	87a60613          	addi	a2,a2,-1926 # ffffffffc0204b28 <etext+0x1a0>
ffffffffc02002b6:	00005597          	auipc	a1,0x5
ffffffffc02002ba:	89258593          	addi	a1,a1,-1902 # ffffffffc0204b48 <etext+0x1c0>
ffffffffc02002be:	00005517          	auipc	a0,0x5
ffffffffc02002c2:	82250513          	addi	a0,a0,-2014 # ffffffffc0204ae0 <etext+0x158>
ffffffffc02002c6:	ebbff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    }
    return 0;
}
ffffffffc02002ca:	60a2                	ld	ra,8(sp)
ffffffffc02002cc:	4501                	li	a0,0
ffffffffc02002ce:	0141                	addi	sp,sp,16
ffffffffc02002d0:	8082                	ret

ffffffffc02002d2 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002d2:	1141                	addi	sp,sp,-16
ffffffffc02002d4:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002d6:	ef3ff0ef          	jal	ra,ffffffffc02001c8 <print_kerninfo>
    return 0;
}
ffffffffc02002da:	60a2                	ld	ra,8(sp)
ffffffffc02002dc:	4501                	li	a0,0
ffffffffc02002de:	0141                	addi	sp,sp,16
ffffffffc02002e0:	8082                	ret

ffffffffc02002e2 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e2:	1141                	addi	sp,sp,-16
ffffffffc02002e4:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002e6:	f71ff0ef          	jal	ra,ffffffffc0200256 <print_stackframe>
    return 0;
}
ffffffffc02002ea:	60a2                	ld	ra,8(sp)
ffffffffc02002ec:	4501                	li	a0,0
ffffffffc02002ee:	0141                	addi	sp,sp,16
ffffffffc02002f0:	8082                	ret

ffffffffc02002f2 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002f2:	7115                	addi	sp,sp,-224
ffffffffc02002f4:	ed5e                	sd	s7,152(sp)
ffffffffc02002f6:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002f8:	00005517          	auipc	a0,0x5
ffffffffc02002fc:	86050513          	addi	a0,a0,-1952 # ffffffffc0204b58 <etext+0x1d0>
kmonitor(struct trapframe *tf) {
ffffffffc0200300:	ed86                	sd	ra,216(sp)
ffffffffc0200302:	e9a2                	sd	s0,208(sp)
ffffffffc0200304:	e5a6                	sd	s1,200(sp)
ffffffffc0200306:	e1ca                	sd	s2,192(sp)
ffffffffc0200308:	fd4e                	sd	s3,184(sp)
ffffffffc020030a:	f952                	sd	s4,176(sp)
ffffffffc020030c:	f556                	sd	s5,168(sp)
ffffffffc020030e:	f15a                	sd	s6,160(sp)
ffffffffc0200310:	e962                	sd	s8,144(sp)
ffffffffc0200312:	e566                	sd	s9,136(sp)
ffffffffc0200314:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200316:	e6bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020031a:	00005517          	auipc	a0,0x5
ffffffffc020031e:	86650513          	addi	a0,a0,-1946 # ffffffffc0204b80 <etext+0x1f8>
ffffffffc0200322:	e5fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    if (tf != NULL) {
ffffffffc0200326:	000b8563          	beqz	s7,ffffffffc0200330 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020032a:	855e                	mv	a0,s7
ffffffffc020032c:	4d0000ef          	jal	ra,ffffffffc02007fc <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200330:	4501                	li	a0,0
ffffffffc0200332:	4581                	li	a1,0
ffffffffc0200334:	4601                	li	a2,0
ffffffffc0200336:	48a1                	li	a7,8
ffffffffc0200338:	00000073          	ecall
ffffffffc020033c:	00005c17          	auipc	s8,0x5
ffffffffc0200340:	8b4c0c13          	addi	s8,s8,-1868 # ffffffffc0204bf0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200344:	00005917          	auipc	s2,0x5
ffffffffc0200348:	86490913          	addi	s2,s2,-1948 # ffffffffc0204ba8 <etext+0x220>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020034c:	00005497          	auipc	s1,0x5
ffffffffc0200350:	86448493          	addi	s1,s1,-1948 # ffffffffc0204bb0 <etext+0x228>
        if (argc == MAXARGS - 1) {
ffffffffc0200354:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200356:	00005b17          	auipc	s6,0x5
ffffffffc020035a:	862b0b13          	addi	s6,s6,-1950 # ffffffffc0204bb8 <etext+0x230>
        argv[argc ++] = buf;
ffffffffc020035e:	00004a17          	auipc	s4,0x4
ffffffffc0200362:	77aa0a13          	addi	s4,s4,1914 # ffffffffc0204ad8 <etext+0x150>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200366:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200368:	854a                	mv	a0,s2
ffffffffc020036a:	d29ff0ef          	jal	ra,ffffffffc0200092 <readline>
ffffffffc020036e:	842a                	mv	s0,a0
ffffffffc0200370:	dd65                	beqz	a0,ffffffffc0200368 <kmonitor+0x76>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200372:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200376:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200378:	e1bd                	bnez	a1,ffffffffc02003de <kmonitor+0xec>
    if (argc == 0) {
ffffffffc020037a:	fe0c87e3          	beqz	s9,ffffffffc0200368 <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020037e:	6582                	ld	a1,0(sp)
ffffffffc0200380:	00005d17          	auipc	s10,0x5
ffffffffc0200384:	870d0d13          	addi	s10,s10,-1936 # ffffffffc0204bf0 <commands>
        argv[argc ++] = buf;
ffffffffc0200388:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020038a:	4401                	li	s0,0
ffffffffc020038c:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020038e:	578040ef          	jal	ra,ffffffffc0204906 <strcmp>
ffffffffc0200392:	c919                	beqz	a0,ffffffffc02003a8 <kmonitor+0xb6>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200394:	2405                	addiw	s0,s0,1
ffffffffc0200396:	0b540063          	beq	s0,s5,ffffffffc0200436 <kmonitor+0x144>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020039a:	000d3503          	ld	a0,0(s10)
ffffffffc020039e:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003a0:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003a2:	564040ef          	jal	ra,ffffffffc0204906 <strcmp>
ffffffffc02003a6:	f57d                	bnez	a0,ffffffffc0200394 <kmonitor+0xa2>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003a8:	00141793          	slli	a5,s0,0x1
ffffffffc02003ac:	97a2                	add	a5,a5,s0
ffffffffc02003ae:	078e                	slli	a5,a5,0x3
ffffffffc02003b0:	97e2                	add	a5,a5,s8
ffffffffc02003b2:	6b9c                	ld	a5,16(a5)
ffffffffc02003b4:	865e                	mv	a2,s7
ffffffffc02003b6:	002c                	addi	a1,sp,8
ffffffffc02003b8:	fffc851b          	addiw	a0,s9,-1
ffffffffc02003bc:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003be:	fa0555e3          	bgez	a0,ffffffffc0200368 <kmonitor+0x76>
}
ffffffffc02003c2:	60ee                	ld	ra,216(sp)
ffffffffc02003c4:	644e                	ld	s0,208(sp)
ffffffffc02003c6:	64ae                	ld	s1,200(sp)
ffffffffc02003c8:	690e                	ld	s2,192(sp)
ffffffffc02003ca:	79ea                	ld	s3,184(sp)
ffffffffc02003cc:	7a4a                	ld	s4,176(sp)
ffffffffc02003ce:	7aaa                	ld	s5,168(sp)
ffffffffc02003d0:	7b0a                	ld	s6,160(sp)
ffffffffc02003d2:	6bea                	ld	s7,152(sp)
ffffffffc02003d4:	6c4a                	ld	s8,144(sp)
ffffffffc02003d6:	6caa                	ld	s9,136(sp)
ffffffffc02003d8:	6d0a                	ld	s10,128(sp)
ffffffffc02003da:	612d                	addi	sp,sp,224
ffffffffc02003dc:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003de:	8526                	mv	a0,s1
ffffffffc02003e0:	544040ef          	jal	ra,ffffffffc0204924 <strchr>
ffffffffc02003e4:	c901                	beqz	a0,ffffffffc02003f4 <kmonitor+0x102>
ffffffffc02003e6:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02003ea:	00040023          	sb	zero,0(s0)
ffffffffc02003ee:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003f0:	d5c9                	beqz	a1,ffffffffc020037a <kmonitor+0x88>
ffffffffc02003f2:	b7f5                	j	ffffffffc02003de <kmonitor+0xec>
        if (*buf == '\0') {
ffffffffc02003f4:	00044783          	lbu	a5,0(s0)
ffffffffc02003f8:	d3c9                	beqz	a5,ffffffffc020037a <kmonitor+0x88>
        if (argc == MAXARGS - 1) {
ffffffffc02003fa:	033c8963          	beq	s9,s3,ffffffffc020042c <kmonitor+0x13a>
        argv[argc ++] = buf;
ffffffffc02003fe:	003c9793          	slli	a5,s9,0x3
ffffffffc0200402:	0118                	addi	a4,sp,128
ffffffffc0200404:	97ba                	add	a5,a5,a4
ffffffffc0200406:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020040a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020040e:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200410:	e591                	bnez	a1,ffffffffc020041c <kmonitor+0x12a>
ffffffffc0200412:	b7b5                	j	ffffffffc020037e <kmonitor+0x8c>
ffffffffc0200414:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200418:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020041a:	d1a5                	beqz	a1,ffffffffc020037a <kmonitor+0x88>
ffffffffc020041c:	8526                	mv	a0,s1
ffffffffc020041e:	506040ef          	jal	ra,ffffffffc0204924 <strchr>
ffffffffc0200422:	d96d                	beqz	a0,ffffffffc0200414 <kmonitor+0x122>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200424:	00044583          	lbu	a1,0(s0)
ffffffffc0200428:	d9a9                	beqz	a1,ffffffffc020037a <kmonitor+0x88>
ffffffffc020042a:	bf55                	j	ffffffffc02003de <kmonitor+0xec>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020042c:	45c1                	li	a1,16
ffffffffc020042e:	855a                	mv	a0,s6
ffffffffc0200430:	d51ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200434:	b7e9                	j	ffffffffc02003fe <kmonitor+0x10c>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200436:	6582                	ld	a1,0(sp)
ffffffffc0200438:	00004517          	auipc	a0,0x4
ffffffffc020043c:	7a050513          	addi	a0,a0,1952 # ffffffffc0204bd8 <etext+0x250>
ffffffffc0200440:	d41ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
ffffffffc0200444:	b715                	j	ffffffffc0200368 <kmonitor+0x76>

ffffffffc0200446 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200446:	00015317          	auipc	t1,0x15
ffffffffc020044a:	0ea30313          	addi	t1,t1,234 # ffffffffc0215530 <is_panic>
ffffffffc020044e:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200452:	715d                	addi	sp,sp,-80
ffffffffc0200454:	ec06                	sd	ra,24(sp)
ffffffffc0200456:	e822                	sd	s0,16(sp)
ffffffffc0200458:	f436                	sd	a3,40(sp)
ffffffffc020045a:	f83a                	sd	a4,48(sp)
ffffffffc020045c:	fc3e                	sd	a5,56(sp)
ffffffffc020045e:	e0c2                	sd	a6,64(sp)
ffffffffc0200460:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200462:	020e1a63          	bnez	t3,ffffffffc0200496 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200466:	4785                	li	a5,1
ffffffffc0200468:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc020046c:	8432                	mv	s0,a2
ffffffffc020046e:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200470:	862e                	mv	a2,a1
ffffffffc0200472:	85aa                	mv	a1,a0
ffffffffc0200474:	00004517          	auipc	a0,0x4
ffffffffc0200478:	7c450513          	addi	a0,a0,1988 # ffffffffc0204c38 <commands+0x48>
    va_start(ap, fmt);
ffffffffc020047c:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020047e:	d03ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200482:	65a2                	ld	a1,8(sp)
ffffffffc0200484:	8522                	mv	a0,s0
ffffffffc0200486:	cdbff0ef          	jal	ra,ffffffffc0200160 <vcprintf>
    cprintf("\n");
ffffffffc020048a:	00005517          	auipc	a0,0x5
ffffffffc020048e:	71e50513          	addi	a0,a0,1822 # ffffffffc0205ba8 <default_pmm_manager+0x4d0>
ffffffffc0200492:	cefff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200496:	108000ef          	jal	ra,ffffffffc020059e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020049a:	4501                	li	a0,0
ffffffffc020049c:	e57ff0ef          	jal	ra,ffffffffc02002f2 <kmonitor>
    while (1) {
ffffffffc02004a0:	bfed                	j	ffffffffc020049a <__panic+0x54>

ffffffffc02004a2 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004a2:	67e1                	lui	a5,0x18
ffffffffc02004a4:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02004a8:	00015717          	auipc	a4,0x15
ffffffffc02004ac:	08f73c23          	sd	a5,152(a4) # ffffffffc0215540 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004b0:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02004b4:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004b6:	953e                	add	a0,a0,a5
ffffffffc02004b8:	4601                	li	a2,0
ffffffffc02004ba:	4881                	li	a7,0
ffffffffc02004bc:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02004c0:	02000793          	li	a5,32
ffffffffc02004c4:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02004c8:	00004517          	auipc	a0,0x4
ffffffffc02004cc:	79050513          	addi	a0,a0,1936 # ffffffffc0204c58 <commands+0x68>
    ticks = 0;
ffffffffc02004d0:	00015797          	auipc	a5,0x15
ffffffffc02004d4:	0607b423          	sd	zero,104(a5) # ffffffffc0215538 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02004d8:	b165                	j	ffffffffc0200180 <cprintf>

ffffffffc02004da <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004da:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004de:	00015797          	auipc	a5,0x15
ffffffffc02004e2:	0627b783          	ld	a5,98(a5) # ffffffffc0215540 <timebase>
ffffffffc02004e6:	953e                	add	a0,a0,a5
ffffffffc02004e8:	4581                	li	a1,0
ffffffffc02004ea:	4601                	li	a2,0
ffffffffc02004ec:	4881                	li	a7,0
ffffffffc02004ee:	00000073          	ecall
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02004f4:	8082                	ret

ffffffffc02004f6 <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02004f6:	100027f3          	csrr	a5,sstatus
ffffffffc02004fa:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02004fc:	0ff57513          	zext.b	a0,a0
ffffffffc0200500:	e799                	bnez	a5,ffffffffc020050e <cons_putc+0x18>
ffffffffc0200502:	4581                	li	a1,0
ffffffffc0200504:	4601                	li	a2,0
ffffffffc0200506:	4885                	li	a7,1
ffffffffc0200508:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020050c:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020050e:	1101                	addi	sp,sp,-32
ffffffffc0200510:	ec06                	sd	ra,24(sp)
ffffffffc0200512:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200514:	08a000ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc0200518:	6522                	ld	a0,8(sp)
ffffffffc020051a:	4581                	li	a1,0
ffffffffc020051c:	4601                	li	a2,0
ffffffffc020051e:	4885                	li	a7,1
ffffffffc0200520:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200524:	60e2                	ld	ra,24(sp)
ffffffffc0200526:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200528:	a885                	j	ffffffffc0200598 <intr_enable>

ffffffffc020052a <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020052a:	100027f3          	csrr	a5,sstatus
ffffffffc020052e:	8b89                	andi	a5,a5,2
ffffffffc0200530:	eb89                	bnez	a5,ffffffffc0200542 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200532:	4501                	li	a0,0
ffffffffc0200534:	4581                	li	a1,0
ffffffffc0200536:	4601                	li	a2,0
ffffffffc0200538:	4889                	li	a7,2
ffffffffc020053a:	00000073          	ecall
ffffffffc020053e:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200540:	8082                	ret
int cons_getc(void) {
ffffffffc0200542:	1101                	addi	sp,sp,-32
ffffffffc0200544:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200546:	058000ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc020054a:	4501                	li	a0,0
ffffffffc020054c:	4581                	li	a1,0
ffffffffc020054e:	4601                	li	a2,0
ffffffffc0200550:	4889                	li	a7,2
ffffffffc0200552:	00000073          	ecall
ffffffffc0200556:	2501                	sext.w	a0,a0
ffffffffc0200558:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020055a:	03e000ef          	jal	ra,ffffffffc0200598 <intr_enable>
}
ffffffffc020055e:	60e2                	ld	ra,24(sp)
ffffffffc0200560:	6522                	ld	a0,8(sp)
ffffffffc0200562:	6105                	addi	sp,sp,32
ffffffffc0200564:	8082                	ret

ffffffffc0200566 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200566:	8082                	ret

ffffffffc0200568 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200568:	00253513          	sltiu	a0,a0,2
ffffffffc020056c:	8082                	ret

ffffffffc020056e <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020056e:	03800513          	li	a0,56
ffffffffc0200572:	8082                	ret

ffffffffc0200574 <ide_write_secs>:
    return 0;
}

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc0200574:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200578:	0000a517          	auipc	a0,0xa
ffffffffc020057c:	ee050513          	addi	a0,a0,-288 # ffffffffc020a458 <ide>
                   size_t nsecs) {
ffffffffc0200580:	1141                	addi	sp,sp,-16
ffffffffc0200582:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200584:	953e                	add	a0,a0,a5
ffffffffc0200586:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc020058a:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020058c:	3c0040ef          	jal	ra,ffffffffc020494c <memcpy>
    return 0;
}
ffffffffc0200590:	60a2                	ld	ra,8(sp)
ffffffffc0200592:	4501                	li	a0,0
ffffffffc0200594:	0141                	addi	sp,sp,16
ffffffffc0200596:	8082                	ret

ffffffffc0200598 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200598:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020059c:	8082                	ret

ffffffffc020059e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020059e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005a2:	8082                	ret

ffffffffc02005a4 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02005a4:	8082                	ret

ffffffffc02005a6 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005a6:	10053783          	ld	a5,256(a0)
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005aa:	1141                	addi	sp,sp,-16
ffffffffc02005ac:	e022                	sd	s0,0(sp)
ffffffffc02005ae:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005b0:	1007f793          	andi	a5,a5,256
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005b4:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005b8:	842a                	mv	s0,a0
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005ba:	05500613          	li	a2,85
ffffffffc02005be:	c399                	beqz	a5,ffffffffc02005c4 <pgfault_handler+0x1e>
ffffffffc02005c0:	04b00613          	li	a2,75
ffffffffc02005c4:	11843703          	ld	a4,280(s0)
ffffffffc02005c8:	47bd                	li	a5,15
ffffffffc02005ca:	05700693          	li	a3,87
ffffffffc02005ce:	00f70463          	beq	a4,a5,ffffffffc02005d6 <pgfault_handler+0x30>
ffffffffc02005d2:	05200693          	li	a3,82
ffffffffc02005d6:	00004517          	auipc	a0,0x4
ffffffffc02005da:	6a250513          	addi	a0,a0,1698 # ffffffffc0204c78 <commands+0x88>
ffffffffc02005de:	ba3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc02005e2:	00015517          	auipc	a0,0x15
ffffffffc02005e6:	fb653503          	ld	a0,-74(a0) # ffffffffc0215598 <check_mm_struct>
ffffffffc02005ea:	c911                	beqz	a0,ffffffffc02005fe <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc02005ec:	11043603          	ld	a2,272(s0)
ffffffffc02005f0:	11842583          	lw	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc02005f4:	6402                	ld	s0,0(sp)
ffffffffc02005f6:	60a2                	ld	ra,8(sp)
ffffffffc02005f8:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc02005fa:	1470306f          	j	ffffffffc0203f40 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc02005fe:	00004617          	auipc	a2,0x4
ffffffffc0200602:	69a60613          	addi	a2,a2,1690 # ffffffffc0204c98 <commands+0xa8>
ffffffffc0200606:	06200593          	li	a1,98
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	6a650513          	addi	a0,a0,1702 # ffffffffc0204cb0 <commands+0xc0>
ffffffffc0200612:	e35ff0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0200616 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200616:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc020061a:	00000797          	auipc	a5,0x0
ffffffffc020061e:	47a78793          	addi	a5,a5,1146 # ffffffffc0200a94 <__alltraps>
ffffffffc0200622:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200626:	000407b7          	lui	a5,0x40
ffffffffc020062a:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020062e:	8082                	ret

ffffffffc0200630 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200630:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200632:	1141                	addi	sp,sp,-16
ffffffffc0200634:	e022                	sd	s0,0(sp)
ffffffffc0200636:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200638:	00004517          	auipc	a0,0x4
ffffffffc020063c:	69050513          	addi	a0,a0,1680 # ffffffffc0204cc8 <commands+0xd8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200640:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200642:	b3fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200646:	640c                	ld	a1,8(s0)
ffffffffc0200648:	00004517          	auipc	a0,0x4
ffffffffc020064c:	69850513          	addi	a0,a0,1688 # ffffffffc0204ce0 <commands+0xf0>
ffffffffc0200650:	b31ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200654:	680c                	ld	a1,16(s0)
ffffffffc0200656:	00004517          	auipc	a0,0x4
ffffffffc020065a:	6a250513          	addi	a0,a0,1698 # ffffffffc0204cf8 <commands+0x108>
ffffffffc020065e:	b23ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200662:	6c0c                	ld	a1,24(s0)
ffffffffc0200664:	00004517          	auipc	a0,0x4
ffffffffc0200668:	6ac50513          	addi	a0,a0,1708 # ffffffffc0204d10 <commands+0x120>
ffffffffc020066c:	b15ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200670:	700c                	ld	a1,32(s0)
ffffffffc0200672:	00004517          	auipc	a0,0x4
ffffffffc0200676:	6b650513          	addi	a0,a0,1718 # ffffffffc0204d28 <commands+0x138>
ffffffffc020067a:	b07ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc020067e:	740c                	ld	a1,40(s0)
ffffffffc0200680:	00004517          	auipc	a0,0x4
ffffffffc0200684:	6c050513          	addi	a0,a0,1728 # ffffffffc0204d40 <commands+0x150>
ffffffffc0200688:	af9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc020068c:	780c                	ld	a1,48(s0)
ffffffffc020068e:	00004517          	auipc	a0,0x4
ffffffffc0200692:	6ca50513          	addi	a0,a0,1738 # ffffffffc0204d58 <commands+0x168>
ffffffffc0200696:	aebff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc020069a:	7c0c                	ld	a1,56(s0)
ffffffffc020069c:	00004517          	auipc	a0,0x4
ffffffffc02006a0:	6d450513          	addi	a0,a0,1748 # ffffffffc0204d70 <commands+0x180>
ffffffffc02006a4:	addff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006a8:	602c                	ld	a1,64(s0)
ffffffffc02006aa:	00004517          	auipc	a0,0x4
ffffffffc02006ae:	6de50513          	addi	a0,a0,1758 # ffffffffc0204d88 <commands+0x198>
ffffffffc02006b2:	acfff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006b6:	642c                	ld	a1,72(s0)
ffffffffc02006b8:	00004517          	auipc	a0,0x4
ffffffffc02006bc:	6e850513          	addi	a0,a0,1768 # ffffffffc0204da0 <commands+0x1b0>
ffffffffc02006c0:	ac1ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006c4:	682c                	ld	a1,80(s0)
ffffffffc02006c6:	00004517          	auipc	a0,0x4
ffffffffc02006ca:	6f250513          	addi	a0,a0,1778 # ffffffffc0204db8 <commands+0x1c8>
ffffffffc02006ce:	ab3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02006d2:	6c2c                	ld	a1,88(s0)
ffffffffc02006d4:	00004517          	auipc	a0,0x4
ffffffffc02006d8:	6fc50513          	addi	a0,a0,1788 # ffffffffc0204dd0 <commands+0x1e0>
ffffffffc02006dc:	aa5ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc02006e0:	702c                	ld	a1,96(s0)
ffffffffc02006e2:	00004517          	auipc	a0,0x4
ffffffffc02006e6:	70650513          	addi	a0,a0,1798 # ffffffffc0204de8 <commands+0x1f8>
ffffffffc02006ea:	a97ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc02006ee:	742c                	ld	a1,104(s0)
ffffffffc02006f0:	00004517          	auipc	a0,0x4
ffffffffc02006f4:	71050513          	addi	a0,a0,1808 # ffffffffc0204e00 <commands+0x210>
ffffffffc02006f8:	a89ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc02006fc:	782c                	ld	a1,112(s0)
ffffffffc02006fe:	00004517          	auipc	a0,0x4
ffffffffc0200702:	71a50513          	addi	a0,a0,1818 # ffffffffc0204e18 <commands+0x228>
ffffffffc0200706:	a7bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020070a:	7c2c                	ld	a1,120(s0)
ffffffffc020070c:	00004517          	auipc	a0,0x4
ffffffffc0200710:	72450513          	addi	a0,a0,1828 # ffffffffc0204e30 <commands+0x240>
ffffffffc0200714:	a6dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200718:	604c                	ld	a1,128(s0)
ffffffffc020071a:	00004517          	auipc	a0,0x4
ffffffffc020071e:	72e50513          	addi	a0,a0,1838 # ffffffffc0204e48 <commands+0x258>
ffffffffc0200722:	a5fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200726:	644c                	ld	a1,136(s0)
ffffffffc0200728:	00004517          	auipc	a0,0x4
ffffffffc020072c:	73850513          	addi	a0,a0,1848 # ffffffffc0204e60 <commands+0x270>
ffffffffc0200730:	a51ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200734:	684c                	ld	a1,144(s0)
ffffffffc0200736:	00004517          	auipc	a0,0x4
ffffffffc020073a:	74250513          	addi	a0,a0,1858 # ffffffffc0204e78 <commands+0x288>
ffffffffc020073e:	a43ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200742:	6c4c                	ld	a1,152(s0)
ffffffffc0200744:	00004517          	auipc	a0,0x4
ffffffffc0200748:	74c50513          	addi	a0,a0,1868 # ffffffffc0204e90 <commands+0x2a0>
ffffffffc020074c:	a35ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200750:	704c                	ld	a1,160(s0)
ffffffffc0200752:	00004517          	auipc	a0,0x4
ffffffffc0200756:	75650513          	addi	a0,a0,1878 # ffffffffc0204ea8 <commands+0x2b8>
ffffffffc020075a:	a27ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020075e:	744c                	ld	a1,168(s0)
ffffffffc0200760:	00004517          	auipc	a0,0x4
ffffffffc0200764:	76050513          	addi	a0,a0,1888 # ffffffffc0204ec0 <commands+0x2d0>
ffffffffc0200768:	a19ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc020076c:	784c                	ld	a1,176(s0)
ffffffffc020076e:	00004517          	auipc	a0,0x4
ffffffffc0200772:	76a50513          	addi	a0,a0,1898 # ffffffffc0204ed8 <commands+0x2e8>
ffffffffc0200776:	a0bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc020077a:	7c4c                	ld	a1,184(s0)
ffffffffc020077c:	00004517          	auipc	a0,0x4
ffffffffc0200780:	77450513          	addi	a0,a0,1908 # ffffffffc0204ef0 <commands+0x300>
ffffffffc0200784:	9fdff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200788:	606c                	ld	a1,192(s0)
ffffffffc020078a:	00004517          	auipc	a0,0x4
ffffffffc020078e:	77e50513          	addi	a0,a0,1918 # ffffffffc0204f08 <commands+0x318>
ffffffffc0200792:	9efff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200796:	646c                	ld	a1,200(s0)
ffffffffc0200798:	00004517          	auipc	a0,0x4
ffffffffc020079c:	78850513          	addi	a0,a0,1928 # ffffffffc0204f20 <commands+0x330>
ffffffffc02007a0:	9e1ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007a4:	686c                	ld	a1,208(s0)
ffffffffc02007a6:	00004517          	auipc	a0,0x4
ffffffffc02007aa:	79250513          	addi	a0,a0,1938 # ffffffffc0204f38 <commands+0x348>
ffffffffc02007ae:	9d3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007b2:	6c6c                	ld	a1,216(s0)
ffffffffc02007b4:	00004517          	auipc	a0,0x4
ffffffffc02007b8:	79c50513          	addi	a0,a0,1948 # ffffffffc0204f50 <commands+0x360>
ffffffffc02007bc:	9c5ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007c0:	706c                	ld	a1,224(s0)
ffffffffc02007c2:	00004517          	auipc	a0,0x4
ffffffffc02007c6:	7a650513          	addi	a0,a0,1958 # ffffffffc0204f68 <commands+0x378>
ffffffffc02007ca:	9b7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007ce:	746c                	ld	a1,232(s0)
ffffffffc02007d0:	00004517          	auipc	a0,0x4
ffffffffc02007d4:	7b050513          	addi	a0,a0,1968 # ffffffffc0204f80 <commands+0x390>
ffffffffc02007d8:	9a9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc02007dc:	786c                	ld	a1,240(s0)
ffffffffc02007de:	00004517          	auipc	a0,0x4
ffffffffc02007e2:	7ba50513          	addi	a0,a0,1978 # ffffffffc0204f98 <commands+0x3a8>
ffffffffc02007e6:	99bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc02007ea:	7c6c                	ld	a1,248(s0)
}
ffffffffc02007ec:	6402                	ld	s0,0(sp)
ffffffffc02007ee:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc02007f0:	00004517          	auipc	a0,0x4
ffffffffc02007f4:	7c050513          	addi	a0,a0,1984 # ffffffffc0204fb0 <commands+0x3c0>
}
ffffffffc02007f8:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc02007fa:	b259                	j	ffffffffc0200180 <cprintf>

ffffffffc02007fc <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc02007fc:	1141                	addi	sp,sp,-16
ffffffffc02007fe:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200800:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200802:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200804:	00004517          	auipc	a0,0x4
ffffffffc0200808:	7c450513          	addi	a0,a0,1988 # ffffffffc0204fc8 <commands+0x3d8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020080c:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020080e:	973ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200812:	8522                	mv	a0,s0
ffffffffc0200814:	e1dff0ef          	jal	ra,ffffffffc0200630 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200818:	10043583          	ld	a1,256(s0)
ffffffffc020081c:	00004517          	auipc	a0,0x4
ffffffffc0200820:	7c450513          	addi	a0,a0,1988 # ffffffffc0204fe0 <commands+0x3f0>
ffffffffc0200824:	95dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200828:	10843583          	ld	a1,264(s0)
ffffffffc020082c:	00004517          	auipc	a0,0x4
ffffffffc0200830:	7cc50513          	addi	a0,a0,1996 # ffffffffc0204ff8 <commands+0x408>
ffffffffc0200834:	94dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200838:	11043583          	ld	a1,272(s0)
ffffffffc020083c:	00004517          	auipc	a0,0x4
ffffffffc0200840:	7d450513          	addi	a0,a0,2004 # ffffffffc0205010 <commands+0x420>
ffffffffc0200844:	93dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200848:	11843583          	ld	a1,280(s0)
}
ffffffffc020084c:	6402                	ld	s0,0(sp)
ffffffffc020084e:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200850:	00004517          	auipc	a0,0x4
ffffffffc0200854:	7d850513          	addi	a0,a0,2008 # ffffffffc0205028 <commands+0x438>
}
ffffffffc0200858:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020085a:	927ff06f          	j	ffffffffc0200180 <cprintf>

ffffffffc020085e <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc020085e:	11853783          	ld	a5,280(a0)
ffffffffc0200862:	472d                	li	a4,11
ffffffffc0200864:	0786                	slli	a5,a5,0x1
ffffffffc0200866:	8385                	srli	a5,a5,0x1
ffffffffc0200868:	06f76c63          	bltu	a4,a5,ffffffffc02008e0 <interrupt_handler+0x82>
ffffffffc020086c:	00005717          	auipc	a4,0x5
ffffffffc0200870:	88470713          	addi	a4,a4,-1916 # ffffffffc02050f0 <commands+0x500>
ffffffffc0200874:	078a                	slli	a5,a5,0x2
ffffffffc0200876:	97ba                	add	a5,a5,a4
ffffffffc0200878:	439c                	lw	a5,0(a5)
ffffffffc020087a:	97ba                	add	a5,a5,a4
ffffffffc020087c:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc020087e:	00005517          	auipc	a0,0x5
ffffffffc0200882:	82250513          	addi	a0,a0,-2014 # ffffffffc02050a0 <commands+0x4b0>
ffffffffc0200886:	8fbff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc020088a:	00004517          	auipc	a0,0x4
ffffffffc020088e:	7f650513          	addi	a0,a0,2038 # ffffffffc0205080 <commands+0x490>
ffffffffc0200892:	8efff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc0200896:	00004517          	auipc	a0,0x4
ffffffffc020089a:	7aa50513          	addi	a0,a0,1962 # ffffffffc0205040 <commands+0x450>
ffffffffc020089e:	8e3ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008a2:	00004517          	auipc	a0,0x4
ffffffffc02008a6:	7be50513          	addi	a0,a0,1982 # ffffffffc0205060 <commands+0x470>
ffffffffc02008aa:	8d7ff06f          	j	ffffffffc0200180 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008ae:	1141                	addi	sp,sp,-16
ffffffffc02008b0:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02008b2:	c29ff0ef          	jal	ra,ffffffffc02004da <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02008b6:	00015697          	auipc	a3,0x15
ffffffffc02008ba:	c8268693          	addi	a3,a3,-894 # ffffffffc0215538 <ticks>
ffffffffc02008be:	629c                	ld	a5,0(a3)
ffffffffc02008c0:	06400713          	li	a4,100
ffffffffc02008c4:	0785                	addi	a5,a5,1
ffffffffc02008c6:	02e7f733          	remu	a4,a5,a4
ffffffffc02008ca:	e29c                	sd	a5,0(a3)
ffffffffc02008cc:	cb19                	beqz	a4,ffffffffc02008e2 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008ce:	60a2                	ld	ra,8(sp)
ffffffffc02008d0:	0141                	addi	sp,sp,16
ffffffffc02008d2:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc02008d4:	00004517          	auipc	a0,0x4
ffffffffc02008d8:	7fc50513          	addi	a0,a0,2044 # ffffffffc02050d0 <commands+0x4e0>
ffffffffc02008dc:	8a5ff06f          	j	ffffffffc0200180 <cprintf>
            print_trapframe(tf);
ffffffffc02008e0:	bf31                	j	ffffffffc02007fc <print_trapframe>
}
ffffffffc02008e2:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc02008e4:	06400593          	li	a1,100
ffffffffc02008e8:	00004517          	auipc	a0,0x4
ffffffffc02008ec:	7d850513          	addi	a0,a0,2008 # ffffffffc02050c0 <commands+0x4d0>
}
ffffffffc02008f0:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc02008f2:	88fff06f          	j	ffffffffc0200180 <cprintf>

ffffffffc02008f6 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc02008f6:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc02008fa:	1101                	addi	sp,sp,-32
ffffffffc02008fc:	e822                	sd	s0,16(sp)
ffffffffc02008fe:	ec06                	sd	ra,24(sp)
ffffffffc0200900:	e426                	sd	s1,8(sp)
ffffffffc0200902:	473d                	li	a4,15
ffffffffc0200904:	842a                	mv	s0,a0
ffffffffc0200906:	14f76a63          	bltu	a4,a5,ffffffffc0200a5a <exception_handler+0x164>
ffffffffc020090a:	00005717          	auipc	a4,0x5
ffffffffc020090e:	9ce70713          	addi	a4,a4,-1586 # ffffffffc02052d8 <commands+0x6e8>
ffffffffc0200912:	078a                	slli	a5,a5,0x2
ffffffffc0200914:	97ba                	add	a5,a5,a4
ffffffffc0200916:	439c                	lw	a5,0(a5)
ffffffffc0200918:	97ba                	add	a5,a5,a4
ffffffffc020091a:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc020091c:	00005517          	auipc	a0,0x5
ffffffffc0200920:	9a450513          	addi	a0,a0,-1628 # ffffffffc02052c0 <commands+0x6d0>
ffffffffc0200924:	85dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200928:	8522                	mv	a0,s0
ffffffffc020092a:	c7dff0ef          	jal	ra,ffffffffc02005a6 <pgfault_handler>
ffffffffc020092e:	84aa                	mv	s1,a0
ffffffffc0200930:	12051b63          	bnez	a0,ffffffffc0200a66 <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200934:	60e2                	ld	ra,24(sp)
ffffffffc0200936:	6442                	ld	s0,16(sp)
ffffffffc0200938:	64a2                	ld	s1,8(sp)
ffffffffc020093a:	6105                	addi	sp,sp,32
ffffffffc020093c:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc020093e:	00004517          	auipc	a0,0x4
ffffffffc0200942:	7e250513          	addi	a0,a0,2018 # ffffffffc0205120 <commands+0x530>
}
ffffffffc0200946:	6442                	ld	s0,16(sp)
ffffffffc0200948:	60e2                	ld	ra,24(sp)
ffffffffc020094a:	64a2                	ld	s1,8(sp)
ffffffffc020094c:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc020094e:	833ff06f          	j	ffffffffc0200180 <cprintf>
ffffffffc0200952:	00004517          	auipc	a0,0x4
ffffffffc0200956:	7ee50513          	addi	a0,a0,2030 # ffffffffc0205140 <commands+0x550>
ffffffffc020095a:	b7f5                	j	ffffffffc0200946 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc020095c:	00005517          	auipc	a0,0x5
ffffffffc0200960:	80450513          	addi	a0,a0,-2044 # ffffffffc0205160 <commands+0x570>
ffffffffc0200964:	b7cd                	j	ffffffffc0200946 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200966:	00005517          	auipc	a0,0x5
ffffffffc020096a:	81250513          	addi	a0,a0,-2030 # ffffffffc0205178 <commands+0x588>
ffffffffc020096e:	bfe1                	j	ffffffffc0200946 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc0200970:	00005517          	auipc	a0,0x5
ffffffffc0200974:	81850513          	addi	a0,a0,-2024 # ffffffffc0205188 <commands+0x598>
ffffffffc0200978:	b7f9                	j	ffffffffc0200946 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc020097a:	00005517          	auipc	a0,0x5
ffffffffc020097e:	82e50513          	addi	a0,a0,-2002 # ffffffffc02051a8 <commands+0x5b8>
ffffffffc0200982:	ffeff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200986:	8522                	mv	a0,s0
ffffffffc0200988:	c1fff0ef          	jal	ra,ffffffffc02005a6 <pgfault_handler>
ffffffffc020098c:	84aa                	mv	s1,a0
ffffffffc020098e:	d15d                	beqz	a0,ffffffffc0200934 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200990:	8522                	mv	a0,s0
ffffffffc0200992:	e6bff0ef          	jal	ra,ffffffffc02007fc <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200996:	86a6                	mv	a3,s1
ffffffffc0200998:	00005617          	auipc	a2,0x5
ffffffffc020099c:	82860613          	addi	a2,a2,-2008 # ffffffffc02051c0 <commands+0x5d0>
ffffffffc02009a0:	0b300593          	li	a1,179
ffffffffc02009a4:	00004517          	auipc	a0,0x4
ffffffffc02009a8:	30c50513          	addi	a0,a0,780 # ffffffffc0204cb0 <commands+0xc0>
ffffffffc02009ac:	a9bff0ef          	jal	ra,ffffffffc0200446 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02009b0:	00005517          	auipc	a0,0x5
ffffffffc02009b4:	83050513          	addi	a0,a0,-2000 # ffffffffc02051e0 <commands+0x5f0>
ffffffffc02009b8:	b779                	j	ffffffffc0200946 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc02009ba:	00005517          	auipc	a0,0x5
ffffffffc02009be:	83e50513          	addi	a0,a0,-1986 # ffffffffc02051f8 <commands+0x608>
ffffffffc02009c2:	fbeff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009c6:	8522                	mv	a0,s0
ffffffffc02009c8:	bdfff0ef          	jal	ra,ffffffffc02005a6 <pgfault_handler>
ffffffffc02009cc:	84aa                	mv	s1,a0
ffffffffc02009ce:	d13d                	beqz	a0,ffffffffc0200934 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009d0:	8522                	mv	a0,s0
ffffffffc02009d2:	e2bff0ef          	jal	ra,ffffffffc02007fc <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009d6:	86a6                	mv	a3,s1
ffffffffc02009d8:	00004617          	auipc	a2,0x4
ffffffffc02009dc:	7e860613          	addi	a2,a2,2024 # ffffffffc02051c0 <commands+0x5d0>
ffffffffc02009e0:	0bd00593          	li	a1,189
ffffffffc02009e4:	00004517          	auipc	a0,0x4
ffffffffc02009e8:	2cc50513          	addi	a0,a0,716 # ffffffffc0204cb0 <commands+0xc0>
ffffffffc02009ec:	a5bff0ef          	jal	ra,ffffffffc0200446 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc02009f0:	00005517          	auipc	a0,0x5
ffffffffc02009f4:	82050513          	addi	a0,a0,-2016 # ffffffffc0205210 <commands+0x620>
ffffffffc02009f8:	b7b9                	j	ffffffffc0200946 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc02009fa:	00005517          	auipc	a0,0x5
ffffffffc02009fe:	83650513          	addi	a0,a0,-1994 # ffffffffc0205230 <commands+0x640>
ffffffffc0200a02:	b791                	j	ffffffffc0200946 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a04:	00005517          	auipc	a0,0x5
ffffffffc0200a08:	84c50513          	addi	a0,a0,-1972 # ffffffffc0205250 <commands+0x660>
ffffffffc0200a0c:	bf2d                	j	ffffffffc0200946 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a0e:	00005517          	auipc	a0,0x5
ffffffffc0200a12:	86250513          	addi	a0,a0,-1950 # ffffffffc0205270 <commands+0x680>
ffffffffc0200a16:	bf05                	j	ffffffffc0200946 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a18:	00005517          	auipc	a0,0x5
ffffffffc0200a1c:	87850513          	addi	a0,a0,-1928 # ffffffffc0205290 <commands+0x6a0>
ffffffffc0200a20:	b71d                	j	ffffffffc0200946 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a22:	00005517          	auipc	a0,0x5
ffffffffc0200a26:	88650513          	addi	a0,a0,-1914 # ffffffffc02052a8 <commands+0x6b8>
ffffffffc0200a2a:	f56ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a2e:	8522                	mv	a0,s0
ffffffffc0200a30:	b77ff0ef          	jal	ra,ffffffffc02005a6 <pgfault_handler>
ffffffffc0200a34:	84aa                	mv	s1,a0
ffffffffc0200a36:	ee050fe3          	beqz	a0,ffffffffc0200934 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a3a:	8522                	mv	a0,s0
ffffffffc0200a3c:	dc1ff0ef          	jal	ra,ffffffffc02007fc <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a40:	86a6                	mv	a3,s1
ffffffffc0200a42:	00004617          	auipc	a2,0x4
ffffffffc0200a46:	77e60613          	addi	a2,a2,1918 # ffffffffc02051c0 <commands+0x5d0>
ffffffffc0200a4a:	0d300593          	li	a1,211
ffffffffc0200a4e:	00004517          	auipc	a0,0x4
ffffffffc0200a52:	26250513          	addi	a0,a0,610 # ffffffffc0204cb0 <commands+0xc0>
ffffffffc0200a56:	9f1ff0ef          	jal	ra,ffffffffc0200446 <__panic>
            print_trapframe(tf);
ffffffffc0200a5a:	8522                	mv	a0,s0
}
ffffffffc0200a5c:	6442                	ld	s0,16(sp)
ffffffffc0200a5e:	60e2                	ld	ra,24(sp)
ffffffffc0200a60:	64a2                	ld	s1,8(sp)
ffffffffc0200a62:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a64:	bb61                	j	ffffffffc02007fc <print_trapframe>
                print_trapframe(tf);
ffffffffc0200a66:	8522                	mv	a0,s0
ffffffffc0200a68:	d95ff0ef          	jal	ra,ffffffffc02007fc <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a6c:	86a6                	mv	a3,s1
ffffffffc0200a6e:	00004617          	auipc	a2,0x4
ffffffffc0200a72:	75260613          	addi	a2,a2,1874 # ffffffffc02051c0 <commands+0x5d0>
ffffffffc0200a76:	0da00593          	li	a1,218
ffffffffc0200a7a:	00004517          	auipc	a0,0x4
ffffffffc0200a7e:	23650513          	addi	a0,a0,566 # ffffffffc0204cb0 <commands+0xc0>
ffffffffc0200a82:	9c5ff0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0200a86 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200a86:	11853783          	ld	a5,280(a0)
ffffffffc0200a8a:	0007c363          	bltz	a5,ffffffffc0200a90 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200a8e:	b5a5                	j	ffffffffc02008f6 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a90:	b3f9                	j	ffffffffc020085e <interrupt_handler>
	...

ffffffffc0200a94 <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a94:	14011073          	csrw	sscratch,sp
ffffffffc0200a98:	712d                	addi	sp,sp,-288
ffffffffc0200a9a:	e406                	sd	ra,8(sp)
ffffffffc0200a9c:	ec0e                	sd	gp,24(sp)
ffffffffc0200a9e:	f012                	sd	tp,32(sp)
ffffffffc0200aa0:	f416                	sd	t0,40(sp)
ffffffffc0200aa2:	f81a                	sd	t1,48(sp)
ffffffffc0200aa4:	fc1e                	sd	t2,56(sp)
ffffffffc0200aa6:	e0a2                	sd	s0,64(sp)
ffffffffc0200aa8:	e4a6                	sd	s1,72(sp)
ffffffffc0200aaa:	e8aa                	sd	a0,80(sp)
ffffffffc0200aac:	ecae                	sd	a1,88(sp)
ffffffffc0200aae:	f0b2                	sd	a2,96(sp)
ffffffffc0200ab0:	f4b6                	sd	a3,104(sp)
ffffffffc0200ab2:	f8ba                	sd	a4,112(sp)
ffffffffc0200ab4:	fcbe                	sd	a5,120(sp)
ffffffffc0200ab6:	e142                	sd	a6,128(sp)
ffffffffc0200ab8:	e546                	sd	a7,136(sp)
ffffffffc0200aba:	e94a                	sd	s2,144(sp)
ffffffffc0200abc:	ed4e                	sd	s3,152(sp)
ffffffffc0200abe:	f152                	sd	s4,160(sp)
ffffffffc0200ac0:	f556                	sd	s5,168(sp)
ffffffffc0200ac2:	f95a                	sd	s6,176(sp)
ffffffffc0200ac4:	fd5e                	sd	s7,184(sp)
ffffffffc0200ac6:	e1e2                	sd	s8,192(sp)
ffffffffc0200ac8:	e5e6                	sd	s9,200(sp)
ffffffffc0200aca:	e9ea                	sd	s10,208(sp)
ffffffffc0200acc:	edee                	sd	s11,216(sp)
ffffffffc0200ace:	f1f2                	sd	t3,224(sp)
ffffffffc0200ad0:	f5f6                	sd	t4,232(sp)
ffffffffc0200ad2:	f9fa                	sd	t5,240(sp)
ffffffffc0200ad4:	fdfe                	sd	t6,248(sp)
ffffffffc0200ad6:	14002473          	csrr	s0,sscratch
ffffffffc0200ada:	100024f3          	csrr	s1,sstatus
ffffffffc0200ade:	14102973          	csrr	s2,sepc
ffffffffc0200ae2:	143029f3          	csrr	s3,stval
ffffffffc0200ae6:	14202a73          	csrr	s4,scause
ffffffffc0200aea:	e822                	sd	s0,16(sp)
ffffffffc0200aec:	e226                	sd	s1,256(sp)
ffffffffc0200aee:	e64a                	sd	s2,264(sp)
ffffffffc0200af0:	ea4e                	sd	s3,272(sp)
ffffffffc0200af2:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200af4:	850a                	mv	a0,sp
    jal trap
ffffffffc0200af6:	f91ff0ef          	jal	ra,ffffffffc0200a86 <trap>

ffffffffc0200afa <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200afa:	6492                	ld	s1,256(sp)
ffffffffc0200afc:	6932                	ld	s2,264(sp)
ffffffffc0200afe:	10049073          	csrw	sstatus,s1
ffffffffc0200b02:	14191073          	csrw	sepc,s2
ffffffffc0200b06:	60a2                	ld	ra,8(sp)
ffffffffc0200b08:	61e2                	ld	gp,24(sp)
ffffffffc0200b0a:	7202                	ld	tp,32(sp)
ffffffffc0200b0c:	72a2                	ld	t0,40(sp)
ffffffffc0200b0e:	7342                	ld	t1,48(sp)
ffffffffc0200b10:	73e2                	ld	t2,56(sp)
ffffffffc0200b12:	6406                	ld	s0,64(sp)
ffffffffc0200b14:	64a6                	ld	s1,72(sp)
ffffffffc0200b16:	6546                	ld	a0,80(sp)
ffffffffc0200b18:	65e6                	ld	a1,88(sp)
ffffffffc0200b1a:	7606                	ld	a2,96(sp)
ffffffffc0200b1c:	76a6                	ld	a3,104(sp)
ffffffffc0200b1e:	7746                	ld	a4,112(sp)
ffffffffc0200b20:	77e6                	ld	a5,120(sp)
ffffffffc0200b22:	680a                	ld	a6,128(sp)
ffffffffc0200b24:	68aa                	ld	a7,136(sp)
ffffffffc0200b26:	694a                	ld	s2,144(sp)
ffffffffc0200b28:	69ea                	ld	s3,152(sp)
ffffffffc0200b2a:	7a0a                	ld	s4,160(sp)
ffffffffc0200b2c:	7aaa                	ld	s5,168(sp)
ffffffffc0200b2e:	7b4a                	ld	s6,176(sp)
ffffffffc0200b30:	7bea                	ld	s7,184(sp)
ffffffffc0200b32:	6c0e                	ld	s8,192(sp)
ffffffffc0200b34:	6cae                	ld	s9,200(sp)
ffffffffc0200b36:	6d4e                	ld	s10,208(sp)
ffffffffc0200b38:	6dee                	ld	s11,216(sp)
ffffffffc0200b3a:	7e0e                	ld	t3,224(sp)
ffffffffc0200b3c:	7eae                	ld	t4,232(sp)
ffffffffc0200b3e:	7f4e                	ld	t5,240(sp)
ffffffffc0200b40:	7fee                	ld	t6,248(sp)
ffffffffc0200b42:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200b44:	10200073          	sret

ffffffffc0200b48 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200b48:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200b4a:	bf45                	j	ffffffffc0200afa <__trapret>
	...

ffffffffc0200b4e <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200b4e:	00011797          	auipc	a5,0x11
ffffffffc0200b52:	90a78793          	addi	a5,a5,-1782 # ffffffffc0211458 <free_area>
ffffffffc0200b56:	e79c                	sd	a5,8(a5)
ffffffffc0200b58:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200b5a:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200b5e:	8082                	ret

ffffffffc0200b60 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200b60:	00011517          	auipc	a0,0x11
ffffffffc0200b64:	90856503          	lwu	a0,-1784(a0) # ffffffffc0211468 <free_area+0x10>
ffffffffc0200b68:	8082                	ret

ffffffffc0200b6a <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200b6a:	715d                	addi	sp,sp,-80
ffffffffc0200b6c:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b6e:	00011417          	auipc	s0,0x11
ffffffffc0200b72:	8ea40413          	addi	s0,s0,-1814 # ffffffffc0211458 <free_area>
ffffffffc0200b76:	641c                	ld	a5,8(s0)
ffffffffc0200b78:	e486                	sd	ra,72(sp)
ffffffffc0200b7a:	fc26                	sd	s1,56(sp)
ffffffffc0200b7c:	f84a                	sd	s2,48(sp)
ffffffffc0200b7e:	f44e                	sd	s3,40(sp)
ffffffffc0200b80:	f052                	sd	s4,32(sp)
ffffffffc0200b82:	ec56                	sd	s5,24(sp)
ffffffffc0200b84:	e85a                	sd	s6,16(sp)
ffffffffc0200b86:	e45e                	sd	s7,8(sp)
ffffffffc0200b88:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b8a:	2a878d63          	beq	a5,s0,ffffffffc0200e44 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0200b8e:	4481                	li	s1,0
ffffffffc0200b90:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b92:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200b96:	8b09                	andi	a4,a4,2
ffffffffc0200b98:	2a070a63          	beqz	a4,ffffffffc0200e4c <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc0200b9c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ba0:	679c                	ld	a5,8(a5)
ffffffffc0200ba2:	2905                	addiw	s2,s2,1
ffffffffc0200ba4:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ba6:	fe8796e3          	bne	a5,s0,ffffffffc0200b92 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200baa:	89a6                	mv	s3,s1
ffffffffc0200bac:	72f000ef          	jal	ra,ffffffffc0201ada <nr_free_pages>
ffffffffc0200bb0:	6f351e63          	bne	a0,s3,ffffffffc02012ac <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bb4:	4505                	li	a0,1
ffffffffc0200bb6:	653000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200bba:	8aaa                	mv	s5,a0
ffffffffc0200bbc:	42050863          	beqz	a0,ffffffffc0200fec <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200bc0:	4505                	li	a0,1
ffffffffc0200bc2:	647000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200bc6:	89aa                	mv	s3,a0
ffffffffc0200bc8:	70050263          	beqz	a0,ffffffffc02012cc <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200bcc:	4505                	li	a0,1
ffffffffc0200bce:	63b000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200bd2:	8a2a                	mv	s4,a0
ffffffffc0200bd4:	48050c63          	beqz	a0,ffffffffc020106c <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200bd8:	293a8a63          	beq	s5,s3,ffffffffc0200e6c <default_check+0x302>
ffffffffc0200bdc:	28aa8863          	beq	s5,a0,ffffffffc0200e6c <default_check+0x302>
ffffffffc0200be0:	28a98663          	beq	s3,a0,ffffffffc0200e6c <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200be4:	000aa783          	lw	a5,0(s5)
ffffffffc0200be8:	2a079263          	bnez	a5,ffffffffc0200e8c <default_check+0x322>
ffffffffc0200bec:	0009a783          	lw	a5,0(s3)
ffffffffc0200bf0:	28079e63          	bnez	a5,ffffffffc0200e8c <default_check+0x322>
ffffffffc0200bf4:	411c                	lw	a5,0(a0)
ffffffffc0200bf6:	28079b63          	bnez	a5,ffffffffc0200e8c <default_check+0x322>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200bfa:	00015797          	auipc	a5,0x15
ffffffffc0200bfe:	96e7b783          	ld	a5,-1682(a5) # ffffffffc0215568 <pages>
ffffffffc0200c02:	40fa8733          	sub	a4,s5,a5
ffffffffc0200c06:	00006617          	auipc	a2,0x6
ffffffffc0200c0a:	da263603          	ld	a2,-606(a2) # ffffffffc02069a8 <nbase>
ffffffffc0200c0e:	8719                	srai	a4,a4,0x6
ffffffffc0200c10:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c12:	00015697          	auipc	a3,0x15
ffffffffc0200c16:	94e6b683          	ld	a3,-1714(a3) # ffffffffc0215560 <npage>
ffffffffc0200c1a:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c1c:	0732                	slli	a4,a4,0xc
ffffffffc0200c1e:	28d77763          	bgeu	a4,a3,ffffffffc0200eac <default_check+0x342>
    return page - pages + nbase;
ffffffffc0200c22:	40f98733          	sub	a4,s3,a5
ffffffffc0200c26:	8719                	srai	a4,a4,0x6
ffffffffc0200c28:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c2a:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200c2c:	4cd77063          	bgeu	a4,a3,ffffffffc02010ec <default_check+0x582>
    return page - pages + nbase;
ffffffffc0200c30:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c34:	8799                	srai	a5,a5,0x6
ffffffffc0200c36:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c38:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c3a:	30d7f963          	bgeu	a5,a3,ffffffffc0200f4c <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0200c3e:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c40:	00043c03          	ld	s8,0(s0)
ffffffffc0200c44:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200c48:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200c4c:	e400                	sd	s0,8(s0)
ffffffffc0200c4e:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200c50:	00011797          	auipc	a5,0x11
ffffffffc0200c54:	8007ac23          	sw	zero,-2024(a5) # ffffffffc0211468 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200c58:	5b1000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200c5c:	2c051863          	bnez	a0,ffffffffc0200f2c <default_check+0x3c2>
    free_page(p0);
ffffffffc0200c60:	4585                	li	a1,1
ffffffffc0200c62:	8556                	mv	a0,s5
ffffffffc0200c64:	637000ef          	jal	ra,ffffffffc0201a9a <free_pages>
    free_page(p1);
ffffffffc0200c68:	4585                	li	a1,1
ffffffffc0200c6a:	854e                	mv	a0,s3
ffffffffc0200c6c:	62f000ef          	jal	ra,ffffffffc0201a9a <free_pages>
    free_page(p2);
ffffffffc0200c70:	4585                	li	a1,1
ffffffffc0200c72:	8552                	mv	a0,s4
ffffffffc0200c74:	627000ef          	jal	ra,ffffffffc0201a9a <free_pages>
    assert(nr_free == 3);
ffffffffc0200c78:	4818                	lw	a4,16(s0)
ffffffffc0200c7a:	478d                	li	a5,3
ffffffffc0200c7c:	28f71863          	bne	a4,a5,ffffffffc0200f0c <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c80:	4505                	li	a0,1
ffffffffc0200c82:	587000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200c86:	89aa                	mv	s3,a0
ffffffffc0200c88:	26050263          	beqz	a0,ffffffffc0200eec <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c8c:	4505                	li	a0,1
ffffffffc0200c8e:	57b000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200c92:	8aaa                	mv	s5,a0
ffffffffc0200c94:	3a050c63          	beqz	a0,ffffffffc020104c <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c98:	4505                	li	a0,1
ffffffffc0200c9a:	56f000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200c9e:	8a2a                	mv	s4,a0
ffffffffc0200ca0:	38050663          	beqz	a0,ffffffffc020102c <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0200ca4:	4505                	li	a0,1
ffffffffc0200ca6:	563000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200caa:	36051163          	bnez	a0,ffffffffc020100c <default_check+0x4a2>
    free_page(p0);
ffffffffc0200cae:	4585                	li	a1,1
ffffffffc0200cb0:	854e                	mv	a0,s3
ffffffffc0200cb2:	5e9000ef          	jal	ra,ffffffffc0201a9a <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200cb6:	641c                	ld	a5,8(s0)
ffffffffc0200cb8:	20878a63          	beq	a5,s0,ffffffffc0200ecc <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0200cbc:	4505                	li	a0,1
ffffffffc0200cbe:	54b000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200cc2:	30a99563          	bne	s3,a0,ffffffffc0200fcc <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0200cc6:	4505                	li	a0,1
ffffffffc0200cc8:	541000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200ccc:	2e051063          	bnez	a0,ffffffffc0200fac <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0200cd0:	481c                	lw	a5,16(s0)
ffffffffc0200cd2:	2a079d63          	bnez	a5,ffffffffc0200f8c <default_check+0x422>
    free_page(p);
ffffffffc0200cd6:	854e                	mv	a0,s3
ffffffffc0200cd8:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200cda:	01843023          	sd	s8,0(s0)
ffffffffc0200cde:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200ce2:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200ce6:	5b5000ef          	jal	ra,ffffffffc0201a9a <free_pages>
    free_page(p1);
ffffffffc0200cea:	4585                	li	a1,1
ffffffffc0200cec:	8556                	mv	a0,s5
ffffffffc0200cee:	5ad000ef          	jal	ra,ffffffffc0201a9a <free_pages>
    free_page(p2);
ffffffffc0200cf2:	4585                	li	a1,1
ffffffffc0200cf4:	8552                	mv	a0,s4
ffffffffc0200cf6:	5a5000ef          	jal	ra,ffffffffc0201a9a <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200cfa:	4515                	li	a0,5
ffffffffc0200cfc:	50d000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200d00:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200d02:	26050563          	beqz	a0,ffffffffc0200f6c <default_check+0x402>
ffffffffc0200d06:	651c                	ld	a5,8(a0)
ffffffffc0200d08:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200d0a:	8b85                	andi	a5,a5,1
ffffffffc0200d0c:	54079063          	bnez	a5,ffffffffc020124c <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200d10:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200d12:	00043b03          	ld	s6,0(s0)
ffffffffc0200d16:	00843a83          	ld	s5,8(s0)
ffffffffc0200d1a:	e000                	sd	s0,0(s0)
ffffffffc0200d1c:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200d1e:	4eb000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200d22:	50051563          	bnez	a0,ffffffffc020122c <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200d26:	08098a13          	addi	s4,s3,128
ffffffffc0200d2a:	8552                	mv	a0,s4
ffffffffc0200d2c:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200d2e:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200d32:	00010797          	auipc	a5,0x10
ffffffffc0200d36:	7207ab23          	sw	zero,1846(a5) # ffffffffc0211468 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200d3a:	561000ef          	jal	ra,ffffffffc0201a9a <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200d3e:	4511                	li	a0,4
ffffffffc0200d40:	4c9000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200d44:	4c051463          	bnez	a0,ffffffffc020120c <default_check+0x6a2>
ffffffffc0200d48:	0889b783          	ld	a5,136(s3)
ffffffffc0200d4c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200d4e:	8b85                	andi	a5,a5,1
ffffffffc0200d50:	48078e63          	beqz	a5,ffffffffc02011ec <default_check+0x682>
ffffffffc0200d54:	0909a703          	lw	a4,144(s3)
ffffffffc0200d58:	478d                	li	a5,3
ffffffffc0200d5a:	48f71963          	bne	a4,a5,ffffffffc02011ec <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200d5e:	450d                	li	a0,3
ffffffffc0200d60:	4a9000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200d64:	8c2a                	mv	s8,a0
ffffffffc0200d66:	46050363          	beqz	a0,ffffffffc02011cc <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0200d6a:	4505                	li	a0,1
ffffffffc0200d6c:	49d000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200d70:	42051e63          	bnez	a0,ffffffffc02011ac <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0200d74:	418a1c63          	bne	s4,s8,ffffffffc020118c <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200d78:	4585                	li	a1,1
ffffffffc0200d7a:	854e                	mv	a0,s3
ffffffffc0200d7c:	51f000ef          	jal	ra,ffffffffc0201a9a <free_pages>
    free_pages(p1, 3);
ffffffffc0200d80:	458d                	li	a1,3
ffffffffc0200d82:	8552                	mv	a0,s4
ffffffffc0200d84:	517000ef          	jal	ra,ffffffffc0201a9a <free_pages>
ffffffffc0200d88:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200d8c:	04098c13          	addi	s8,s3,64
ffffffffc0200d90:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200d92:	8b85                	andi	a5,a5,1
ffffffffc0200d94:	3c078c63          	beqz	a5,ffffffffc020116c <default_check+0x602>
ffffffffc0200d98:	0109a703          	lw	a4,16(s3)
ffffffffc0200d9c:	4785                	li	a5,1
ffffffffc0200d9e:	3cf71763          	bne	a4,a5,ffffffffc020116c <default_check+0x602>
ffffffffc0200da2:	008a3783          	ld	a5,8(s4)
ffffffffc0200da6:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200da8:	8b85                	andi	a5,a5,1
ffffffffc0200daa:	3a078163          	beqz	a5,ffffffffc020114c <default_check+0x5e2>
ffffffffc0200dae:	010a2703          	lw	a4,16(s4)
ffffffffc0200db2:	478d                	li	a5,3
ffffffffc0200db4:	38f71c63          	bne	a4,a5,ffffffffc020114c <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200db8:	4505                	li	a0,1
ffffffffc0200dba:	44f000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200dbe:	36a99763          	bne	s3,a0,ffffffffc020112c <default_check+0x5c2>
    free_page(p0);
ffffffffc0200dc2:	4585                	li	a1,1
ffffffffc0200dc4:	4d7000ef          	jal	ra,ffffffffc0201a9a <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200dc8:	4509                	li	a0,2
ffffffffc0200dca:	43f000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200dce:	32aa1f63          	bne	s4,a0,ffffffffc020110c <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc0200dd2:	4589                	li	a1,2
ffffffffc0200dd4:	4c7000ef          	jal	ra,ffffffffc0201a9a <free_pages>
    free_page(p2);
ffffffffc0200dd8:	4585                	li	a1,1
ffffffffc0200dda:	8562                	mv	a0,s8
ffffffffc0200ddc:	4bf000ef          	jal	ra,ffffffffc0201a9a <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200de0:	4515                	li	a0,5
ffffffffc0200de2:	427000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200de6:	89aa                	mv	s3,a0
ffffffffc0200de8:	48050263          	beqz	a0,ffffffffc020126c <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc0200dec:	4505                	li	a0,1
ffffffffc0200dee:	41b000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200df2:	2c051d63          	bnez	a0,ffffffffc02010cc <default_check+0x562>

    assert(nr_free == 0);
ffffffffc0200df6:	481c                	lw	a5,16(s0)
ffffffffc0200df8:	2a079a63          	bnez	a5,ffffffffc02010ac <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200dfc:	4595                	li	a1,5
ffffffffc0200dfe:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200e00:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0200e04:	01643023          	sd	s6,0(s0)
ffffffffc0200e08:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0200e0c:	48f000ef          	jal	ra,ffffffffc0201a9a <free_pages>
    return listelm->next;
ffffffffc0200e10:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e12:	00878963          	beq	a5,s0,ffffffffc0200e24 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200e16:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e1a:	679c                	ld	a5,8(a5)
ffffffffc0200e1c:	397d                	addiw	s2,s2,-1
ffffffffc0200e1e:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e20:	fe879be3          	bne	a5,s0,ffffffffc0200e16 <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc0200e24:	26091463          	bnez	s2,ffffffffc020108c <default_check+0x522>
    assert(total == 0);
ffffffffc0200e28:	46049263          	bnez	s1,ffffffffc020128c <default_check+0x722>
}
ffffffffc0200e2c:	60a6                	ld	ra,72(sp)
ffffffffc0200e2e:	6406                	ld	s0,64(sp)
ffffffffc0200e30:	74e2                	ld	s1,56(sp)
ffffffffc0200e32:	7942                	ld	s2,48(sp)
ffffffffc0200e34:	79a2                	ld	s3,40(sp)
ffffffffc0200e36:	7a02                	ld	s4,32(sp)
ffffffffc0200e38:	6ae2                	ld	s5,24(sp)
ffffffffc0200e3a:	6b42                	ld	s6,16(sp)
ffffffffc0200e3c:	6ba2                	ld	s7,8(sp)
ffffffffc0200e3e:	6c02                	ld	s8,0(sp)
ffffffffc0200e40:	6161                	addi	sp,sp,80
ffffffffc0200e42:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e44:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200e46:	4481                	li	s1,0
ffffffffc0200e48:	4901                	li	s2,0
ffffffffc0200e4a:	b38d                	j	ffffffffc0200bac <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0200e4c:	00004697          	auipc	a3,0x4
ffffffffc0200e50:	4cc68693          	addi	a3,a3,1228 # ffffffffc0205318 <commands+0x728>
ffffffffc0200e54:	00004617          	auipc	a2,0x4
ffffffffc0200e58:	4d460613          	addi	a2,a2,1236 # ffffffffc0205328 <commands+0x738>
ffffffffc0200e5c:	0f000593          	li	a1,240
ffffffffc0200e60:	00004517          	auipc	a0,0x4
ffffffffc0200e64:	4e050513          	addi	a0,a0,1248 # ffffffffc0205340 <commands+0x750>
ffffffffc0200e68:	ddeff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e6c:	00004697          	auipc	a3,0x4
ffffffffc0200e70:	56c68693          	addi	a3,a3,1388 # ffffffffc02053d8 <commands+0x7e8>
ffffffffc0200e74:	00004617          	auipc	a2,0x4
ffffffffc0200e78:	4b460613          	addi	a2,a2,1204 # ffffffffc0205328 <commands+0x738>
ffffffffc0200e7c:	0bd00593          	li	a1,189
ffffffffc0200e80:	00004517          	auipc	a0,0x4
ffffffffc0200e84:	4c050513          	addi	a0,a0,1216 # ffffffffc0205340 <commands+0x750>
ffffffffc0200e88:	dbeff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e8c:	00004697          	auipc	a3,0x4
ffffffffc0200e90:	57468693          	addi	a3,a3,1396 # ffffffffc0205400 <commands+0x810>
ffffffffc0200e94:	00004617          	auipc	a2,0x4
ffffffffc0200e98:	49460613          	addi	a2,a2,1172 # ffffffffc0205328 <commands+0x738>
ffffffffc0200e9c:	0be00593          	li	a1,190
ffffffffc0200ea0:	00004517          	auipc	a0,0x4
ffffffffc0200ea4:	4a050513          	addi	a0,a0,1184 # ffffffffc0205340 <commands+0x750>
ffffffffc0200ea8:	d9eff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200eac:	00004697          	auipc	a3,0x4
ffffffffc0200eb0:	59468693          	addi	a3,a3,1428 # ffffffffc0205440 <commands+0x850>
ffffffffc0200eb4:	00004617          	auipc	a2,0x4
ffffffffc0200eb8:	47460613          	addi	a2,a2,1140 # ffffffffc0205328 <commands+0x738>
ffffffffc0200ebc:	0c000593          	li	a1,192
ffffffffc0200ec0:	00004517          	auipc	a0,0x4
ffffffffc0200ec4:	48050513          	addi	a0,a0,1152 # ffffffffc0205340 <commands+0x750>
ffffffffc0200ec8:	d7eff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200ecc:	00004697          	auipc	a3,0x4
ffffffffc0200ed0:	5fc68693          	addi	a3,a3,1532 # ffffffffc02054c8 <commands+0x8d8>
ffffffffc0200ed4:	00004617          	auipc	a2,0x4
ffffffffc0200ed8:	45460613          	addi	a2,a2,1108 # ffffffffc0205328 <commands+0x738>
ffffffffc0200edc:	0d900593          	li	a1,217
ffffffffc0200ee0:	00004517          	auipc	a0,0x4
ffffffffc0200ee4:	46050513          	addi	a0,a0,1120 # ffffffffc0205340 <commands+0x750>
ffffffffc0200ee8:	d5eff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200eec:	00004697          	auipc	a3,0x4
ffffffffc0200ef0:	48c68693          	addi	a3,a3,1164 # ffffffffc0205378 <commands+0x788>
ffffffffc0200ef4:	00004617          	auipc	a2,0x4
ffffffffc0200ef8:	43460613          	addi	a2,a2,1076 # ffffffffc0205328 <commands+0x738>
ffffffffc0200efc:	0d200593          	li	a1,210
ffffffffc0200f00:	00004517          	auipc	a0,0x4
ffffffffc0200f04:	44050513          	addi	a0,a0,1088 # ffffffffc0205340 <commands+0x750>
ffffffffc0200f08:	d3eff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free == 3);
ffffffffc0200f0c:	00004697          	auipc	a3,0x4
ffffffffc0200f10:	5ac68693          	addi	a3,a3,1452 # ffffffffc02054b8 <commands+0x8c8>
ffffffffc0200f14:	00004617          	auipc	a2,0x4
ffffffffc0200f18:	41460613          	addi	a2,a2,1044 # ffffffffc0205328 <commands+0x738>
ffffffffc0200f1c:	0d000593          	li	a1,208
ffffffffc0200f20:	00004517          	auipc	a0,0x4
ffffffffc0200f24:	42050513          	addi	a0,a0,1056 # ffffffffc0205340 <commands+0x750>
ffffffffc0200f28:	d1eff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f2c:	00004697          	auipc	a3,0x4
ffffffffc0200f30:	57468693          	addi	a3,a3,1396 # ffffffffc02054a0 <commands+0x8b0>
ffffffffc0200f34:	00004617          	auipc	a2,0x4
ffffffffc0200f38:	3f460613          	addi	a2,a2,1012 # ffffffffc0205328 <commands+0x738>
ffffffffc0200f3c:	0cb00593          	li	a1,203
ffffffffc0200f40:	00004517          	auipc	a0,0x4
ffffffffc0200f44:	40050513          	addi	a0,a0,1024 # ffffffffc0205340 <commands+0x750>
ffffffffc0200f48:	cfeff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f4c:	00004697          	auipc	a3,0x4
ffffffffc0200f50:	53468693          	addi	a3,a3,1332 # ffffffffc0205480 <commands+0x890>
ffffffffc0200f54:	00004617          	auipc	a2,0x4
ffffffffc0200f58:	3d460613          	addi	a2,a2,980 # ffffffffc0205328 <commands+0x738>
ffffffffc0200f5c:	0c200593          	li	a1,194
ffffffffc0200f60:	00004517          	auipc	a0,0x4
ffffffffc0200f64:	3e050513          	addi	a0,a0,992 # ffffffffc0205340 <commands+0x750>
ffffffffc0200f68:	cdeff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(p0 != NULL);
ffffffffc0200f6c:	00004697          	auipc	a3,0x4
ffffffffc0200f70:	5a468693          	addi	a3,a3,1444 # ffffffffc0205510 <commands+0x920>
ffffffffc0200f74:	00004617          	auipc	a2,0x4
ffffffffc0200f78:	3b460613          	addi	a2,a2,948 # ffffffffc0205328 <commands+0x738>
ffffffffc0200f7c:	0f800593          	li	a1,248
ffffffffc0200f80:	00004517          	auipc	a0,0x4
ffffffffc0200f84:	3c050513          	addi	a0,a0,960 # ffffffffc0205340 <commands+0x750>
ffffffffc0200f88:	cbeff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free == 0);
ffffffffc0200f8c:	00004697          	auipc	a3,0x4
ffffffffc0200f90:	57468693          	addi	a3,a3,1396 # ffffffffc0205500 <commands+0x910>
ffffffffc0200f94:	00004617          	auipc	a2,0x4
ffffffffc0200f98:	39460613          	addi	a2,a2,916 # ffffffffc0205328 <commands+0x738>
ffffffffc0200f9c:	0df00593          	li	a1,223
ffffffffc0200fa0:	00004517          	auipc	a0,0x4
ffffffffc0200fa4:	3a050513          	addi	a0,a0,928 # ffffffffc0205340 <commands+0x750>
ffffffffc0200fa8:	c9eff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fac:	00004697          	auipc	a3,0x4
ffffffffc0200fb0:	4f468693          	addi	a3,a3,1268 # ffffffffc02054a0 <commands+0x8b0>
ffffffffc0200fb4:	00004617          	auipc	a2,0x4
ffffffffc0200fb8:	37460613          	addi	a2,a2,884 # ffffffffc0205328 <commands+0x738>
ffffffffc0200fbc:	0dd00593          	li	a1,221
ffffffffc0200fc0:	00004517          	auipc	a0,0x4
ffffffffc0200fc4:	38050513          	addi	a0,a0,896 # ffffffffc0205340 <commands+0x750>
ffffffffc0200fc8:	c7eff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200fcc:	00004697          	auipc	a3,0x4
ffffffffc0200fd0:	51468693          	addi	a3,a3,1300 # ffffffffc02054e0 <commands+0x8f0>
ffffffffc0200fd4:	00004617          	auipc	a2,0x4
ffffffffc0200fd8:	35460613          	addi	a2,a2,852 # ffffffffc0205328 <commands+0x738>
ffffffffc0200fdc:	0dc00593          	li	a1,220
ffffffffc0200fe0:	00004517          	auipc	a0,0x4
ffffffffc0200fe4:	36050513          	addi	a0,a0,864 # ffffffffc0205340 <commands+0x750>
ffffffffc0200fe8:	c5eff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200fec:	00004697          	auipc	a3,0x4
ffffffffc0200ff0:	38c68693          	addi	a3,a3,908 # ffffffffc0205378 <commands+0x788>
ffffffffc0200ff4:	00004617          	auipc	a2,0x4
ffffffffc0200ff8:	33460613          	addi	a2,a2,820 # ffffffffc0205328 <commands+0x738>
ffffffffc0200ffc:	0b900593          	li	a1,185
ffffffffc0201000:	00004517          	auipc	a0,0x4
ffffffffc0201004:	34050513          	addi	a0,a0,832 # ffffffffc0205340 <commands+0x750>
ffffffffc0201008:	c3eff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020100c:	00004697          	auipc	a3,0x4
ffffffffc0201010:	49468693          	addi	a3,a3,1172 # ffffffffc02054a0 <commands+0x8b0>
ffffffffc0201014:	00004617          	auipc	a2,0x4
ffffffffc0201018:	31460613          	addi	a2,a2,788 # ffffffffc0205328 <commands+0x738>
ffffffffc020101c:	0d600593          	li	a1,214
ffffffffc0201020:	00004517          	auipc	a0,0x4
ffffffffc0201024:	32050513          	addi	a0,a0,800 # ffffffffc0205340 <commands+0x750>
ffffffffc0201028:	c1eff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020102c:	00004697          	auipc	a3,0x4
ffffffffc0201030:	38c68693          	addi	a3,a3,908 # ffffffffc02053b8 <commands+0x7c8>
ffffffffc0201034:	00004617          	auipc	a2,0x4
ffffffffc0201038:	2f460613          	addi	a2,a2,756 # ffffffffc0205328 <commands+0x738>
ffffffffc020103c:	0d400593          	li	a1,212
ffffffffc0201040:	00004517          	auipc	a0,0x4
ffffffffc0201044:	30050513          	addi	a0,a0,768 # ffffffffc0205340 <commands+0x750>
ffffffffc0201048:	bfeff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020104c:	00004697          	auipc	a3,0x4
ffffffffc0201050:	34c68693          	addi	a3,a3,844 # ffffffffc0205398 <commands+0x7a8>
ffffffffc0201054:	00004617          	auipc	a2,0x4
ffffffffc0201058:	2d460613          	addi	a2,a2,724 # ffffffffc0205328 <commands+0x738>
ffffffffc020105c:	0d300593          	li	a1,211
ffffffffc0201060:	00004517          	auipc	a0,0x4
ffffffffc0201064:	2e050513          	addi	a0,a0,736 # ffffffffc0205340 <commands+0x750>
ffffffffc0201068:	bdeff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020106c:	00004697          	auipc	a3,0x4
ffffffffc0201070:	34c68693          	addi	a3,a3,844 # ffffffffc02053b8 <commands+0x7c8>
ffffffffc0201074:	00004617          	auipc	a2,0x4
ffffffffc0201078:	2b460613          	addi	a2,a2,692 # ffffffffc0205328 <commands+0x738>
ffffffffc020107c:	0bb00593          	li	a1,187
ffffffffc0201080:	00004517          	auipc	a0,0x4
ffffffffc0201084:	2c050513          	addi	a0,a0,704 # ffffffffc0205340 <commands+0x750>
ffffffffc0201088:	bbeff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(count == 0);
ffffffffc020108c:	00004697          	auipc	a3,0x4
ffffffffc0201090:	5d468693          	addi	a3,a3,1492 # ffffffffc0205660 <commands+0xa70>
ffffffffc0201094:	00004617          	auipc	a2,0x4
ffffffffc0201098:	29460613          	addi	a2,a2,660 # ffffffffc0205328 <commands+0x738>
ffffffffc020109c:	12500593          	li	a1,293
ffffffffc02010a0:	00004517          	auipc	a0,0x4
ffffffffc02010a4:	2a050513          	addi	a0,a0,672 # ffffffffc0205340 <commands+0x750>
ffffffffc02010a8:	b9eff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free == 0);
ffffffffc02010ac:	00004697          	auipc	a3,0x4
ffffffffc02010b0:	45468693          	addi	a3,a3,1108 # ffffffffc0205500 <commands+0x910>
ffffffffc02010b4:	00004617          	auipc	a2,0x4
ffffffffc02010b8:	27460613          	addi	a2,a2,628 # ffffffffc0205328 <commands+0x738>
ffffffffc02010bc:	11a00593          	li	a1,282
ffffffffc02010c0:	00004517          	auipc	a0,0x4
ffffffffc02010c4:	28050513          	addi	a0,a0,640 # ffffffffc0205340 <commands+0x750>
ffffffffc02010c8:	b7eff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010cc:	00004697          	auipc	a3,0x4
ffffffffc02010d0:	3d468693          	addi	a3,a3,980 # ffffffffc02054a0 <commands+0x8b0>
ffffffffc02010d4:	00004617          	auipc	a2,0x4
ffffffffc02010d8:	25460613          	addi	a2,a2,596 # ffffffffc0205328 <commands+0x738>
ffffffffc02010dc:	11800593          	li	a1,280
ffffffffc02010e0:	00004517          	auipc	a0,0x4
ffffffffc02010e4:	26050513          	addi	a0,a0,608 # ffffffffc0205340 <commands+0x750>
ffffffffc02010e8:	b5eff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02010ec:	00004697          	auipc	a3,0x4
ffffffffc02010f0:	37468693          	addi	a3,a3,884 # ffffffffc0205460 <commands+0x870>
ffffffffc02010f4:	00004617          	auipc	a2,0x4
ffffffffc02010f8:	23460613          	addi	a2,a2,564 # ffffffffc0205328 <commands+0x738>
ffffffffc02010fc:	0c100593          	li	a1,193
ffffffffc0201100:	00004517          	auipc	a0,0x4
ffffffffc0201104:	24050513          	addi	a0,a0,576 # ffffffffc0205340 <commands+0x750>
ffffffffc0201108:	b3eff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020110c:	00004697          	auipc	a3,0x4
ffffffffc0201110:	51468693          	addi	a3,a3,1300 # ffffffffc0205620 <commands+0xa30>
ffffffffc0201114:	00004617          	auipc	a2,0x4
ffffffffc0201118:	21460613          	addi	a2,a2,532 # ffffffffc0205328 <commands+0x738>
ffffffffc020111c:	11200593          	li	a1,274
ffffffffc0201120:	00004517          	auipc	a0,0x4
ffffffffc0201124:	22050513          	addi	a0,a0,544 # ffffffffc0205340 <commands+0x750>
ffffffffc0201128:	b1eff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020112c:	00004697          	auipc	a3,0x4
ffffffffc0201130:	4d468693          	addi	a3,a3,1236 # ffffffffc0205600 <commands+0xa10>
ffffffffc0201134:	00004617          	auipc	a2,0x4
ffffffffc0201138:	1f460613          	addi	a2,a2,500 # ffffffffc0205328 <commands+0x738>
ffffffffc020113c:	11000593          	li	a1,272
ffffffffc0201140:	00004517          	auipc	a0,0x4
ffffffffc0201144:	20050513          	addi	a0,a0,512 # ffffffffc0205340 <commands+0x750>
ffffffffc0201148:	afeff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020114c:	00004697          	auipc	a3,0x4
ffffffffc0201150:	48c68693          	addi	a3,a3,1164 # ffffffffc02055d8 <commands+0x9e8>
ffffffffc0201154:	00004617          	auipc	a2,0x4
ffffffffc0201158:	1d460613          	addi	a2,a2,468 # ffffffffc0205328 <commands+0x738>
ffffffffc020115c:	10e00593          	li	a1,270
ffffffffc0201160:	00004517          	auipc	a0,0x4
ffffffffc0201164:	1e050513          	addi	a0,a0,480 # ffffffffc0205340 <commands+0x750>
ffffffffc0201168:	adeff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020116c:	00004697          	auipc	a3,0x4
ffffffffc0201170:	44468693          	addi	a3,a3,1092 # ffffffffc02055b0 <commands+0x9c0>
ffffffffc0201174:	00004617          	auipc	a2,0x4
ffffffffc0201178:	1b460613          	addi	a2,a2,436 # ffffffffc0205328 <commands+0x738>
ffffffffc020117c:	10d00593          	li	a1,269
ffffffffc0201180:	00004517          	auipc	a0,0x4
ffffffffc0201184:	1c050513          	addi	a0,a0,448 # ffffffffc0205340 <commands+0x750>
ffffffffc0201188:	abeff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(p0 + 2 == p1);
ffffffffc020118c:	00004697          	auipc	a3,0x4
ffffffffc0201190:	41468693          	addi	a3,a3,1044 # ffffffffc02055a0 <commands+0x9b0>
ffffffffc0201194:	00004617          	auipc	a2,0x4
ffffffffc0201198:	19460613          	addi	a2,a2,404 # ffffffffc0205328 <commands+0x738>
ffffffffc020119c:	10800593          	li	a1,264
ffffffffc02011a0:	00004517          	auipc	a0,0x4
ffffffffc02011a4:	1a050513          	addi	a0,a0,416 # ffffffffc0205340 <commands+0x750>
ffffffffc02011a8:	a9eff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011ac:	00004697          	auipc	a3,0x4
ffffffffc02011b0:	2f468693          	addi	a3,a3,756 # ffffffffc02054a0 <commands+0x8b0>
ffffffffc02011b4:	00004617          	auipc	a2,0x4
ffffffffc02011b8:	17460613          	addi	a2,a2,372 # ffffffffc0205328 <commands+0x738>
ffffffffc02011bc:	10700593          	li	a1,263
ffffffffc02011c0:	00004517          	auipc	a0,0x4
ffffffffc02011c4:	18050513          	addi	a0,a0,384 # ffffffffc0205340 <commands+0x750>
ffffffffc02011c8:	a7eff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02011cc:	00004697          	auipc	a3,0x4
ffffffffc02011d0:	3b468693          	addi	a3,a3,948 # ffffffffc0205580 <commands+0x990>
ffffffffc02011d4:	00004617          	auipc	a2,0x4
ffffffffc02011d8:	15460613          	addi	a2,a2,340 # ffffffffc0205328 <commands+0x738>
ffffffffc02011dc:	10600593          	li	a1,262
ffffffffc02011e0:	00004517          	auipc	a0,0x4
ffffffffc02011e4:	16050513          	addi	a0,a0,352 # ffffffffc0205340 <commands+0x750>
ffffffffc02011e8:	a5eff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02011ec:	00004697          	auipc	a3,0x4
ffffffffc02011f0:	36468693          	addi	a3,a3,868 # ffffffffc0205550 <commands+0x960>
ffffffffc02011f4:	00004617          	auipc	a2,0x4
ffffffffc02011f8:	13460613          	addi	a2,a2,308 # ffffffffc0205328 <commands+0x738>
ffffffffc02011fc:	10500593          	li	a1,261
ffffffffc0201200:	00004517          	auipc	a0,0x4
ffffffffc0201204:	14050513          	addi	a0,a0,320 # ffffffffc0205340 <commands+0x750>
ffffffffc0201208:	a3eff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc020120c:	00004697          	auipc	a3,0x4
ffffffffc0201210:	32c68693          	addi	a3,a3,812 # ffffffffc0205538 <commands+0x948>
ffffffffc0201214:	00004617          	auipc	a2,0x4
ffffffffc0201218:	11460613          	addi	a2,a2,276 # ffffffffc0205328 <commands+0x738>
ffffffffc020121c:	10400593          	li	a1,260
ffffffffc0201220:	00004517          	auipc	a0,0x4
ffffffffc0201224:	12050513          	addi	a0,a0,288 # ffffffffc0205340 <commands+0x750>
ffffffffc0201228:	a1eff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020122c:	00004697          	auipc	a3,0x4
ffffffffc0201230:	27468693          	addi	a3,a3,628 # ffffffffc02054a0 <commands+0x8b0>
ffffffffc0201234:	00004617          	auipc	a2,0x4
ffffffffc0201238:	0f460613          	addi	a2,a2,244 # ffffffffc0205328 <commands+0x738>
ffffffffc020123c:	0fe00593          	li	a1,254
ffffffffc0201240:	00004517          	auipc	a0,0x4
ffffffffc0201244:	10050513          	addi	a0,a0,256 # ffffffffc0205340 <commands+0x750>
ffffffffc0201248:	9feff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(!PageProperty(p0));
ffffffffc020124c:	00004697          	auipc	a3,0x4
ffffffffc0201250:	2d468693          	addi	a3,a3,724 # ffffffffc0205520 <commands+0x930>
ffffffffc0201254:	00004617          	auipc	a2,0x4
ffffffffc0201258:	0d460613          	addi	a2,a2,212 # ffffffffc0205328 <commands+0x738>
ffffffffc020125c:	0f900593          	li	a1,249
ffffffffc0201260:	00004517          	auipc	a0,0x4
ffffffffc0201264:	0e050513          	addi	a0,a0,224 # ffffffffc0205340 <commands+0x750>
ffffffffc0201268:	9deff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020126c:	00004697          	auipc	a3,0x4
ffffffffc0201270:	3d468693          	addi	a3,a3,980 # ffffffffc0205640 <commands+0xa50>
ffffffffc0201274:	00004617          	auipc	a2,0x4
ffffffffc0201278:	0b460613          	addi	a2,a2,180 # ffffffffc0205328 <commands+0x738>
ffffffffc020127c:	11700593          	li	a1,279
ffffffffc0201280:	00004517          	auipc	a0,0x4
ffffffffc0201284:	0c050513          	addi	a0,a0,192 # ffffffffc0205340 <commands+0x750>
ffffffffc0201288:	9beff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(total == 0);
ffffffffc020128c:	00004697          	auipc	a3,0x4
ffffffffc0201290:	3e468693          	addi	a3,a3,996 # ffffffffc0205670 <commands+0xa80>
ffffffffc0201294:	00004617          	auipc	a2,0x4
ffffffffc0201298:	09460613          	addi	a2,a2,148 # ffffffffc0205328 <commands+0x738>
ffffffffc020129c:	12600593          	li	a1,294
ffffffffc02012a0:	00004517          	auipc	a0,0x4
ffffffffc02012a4:	0a050513          	addi	a0,a0,160 # ffffffffc0205340 <commands+0x750>
ffffffffc02012a8:	99eff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(total == nr_free_pages());
ffffffffc02012ac:	00004697          	auipc	a3,0x4
ffffffffc02012b0:	0ac68693          	addi	a3,a3,172 # ffffffffc0205358 <commands+0x768>
ffffffffc02012b4:	00004617          	auipc	a2,0x4
ffffffffc02012b8:	07460613          	addi	a2,a2,116 # ffffffffc0205328 <commands+0x738>
ffffffffc02012bc:	0f300593          	li	a1,243
ffffffffc02012c0:	00004517          	auipc	a0,0x4
ffffffffc02012c4:	08050513          	addi	a0,a0,128 # ffffffffc0205340 <commands+0x750>
ffffffffc02012c8:	97eff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02012cc:	00004697          	auipc	a3,0x4
ffffffffc02012d0:	0cc68693          	addi	a3,a3,204 # ffffffffc0205398 <commands+0x7a8>
ffffffffc02012d4:	00004617          	auipc	a2,0x4
ffffffffc02012d8:	05460613          	addi	a2,a2,84 # ffffffffc0205328 <commands+0x738>
ffffffffc02012dc:	0ba00593          	li	a1,186
ffffffffc02012e0:	00004517          	auipc	a0,0x4
ffffffffc02012e4:	06050513          	addi	a0,a0,96 # ffffffffc0205340 <commands+0x750>
ffffffffc02012e8:	95eff0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02012ec <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02012ec:	1141                	addi	sp,sp,-16
ffffffffc02012ee:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02012f0:	14058463          	beqz	a1,ffffffffc0201438 <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc02012f4:	00659693          	slli	a3,a1,0x6
ffffffffc02012f8:	96aa                	add	a3,a3,a0
ffffffffc02012fa:	87aa                	mv	a5,a0
ffffffffc02012fc:	02d50263          	beq	a0,a3,ffffffffc0201320 <default_free_pages+0x34>
ffffffffc0201300:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201302:	8b05                	andi	a4,a4,1
ffffffffc0201304:	10071a63          	bnez	a4,ffffffffc0201418 <default_free_pages+0x12c>
ffffffffc0201308:	6798                	ld	a4,8(a5)
ffffffffc020130a:	8b09                	andi	a4,a4,2
ffffffffc020130c:	10071663          	bnez	a4,ffffffffc0201418 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0201310:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0201314:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201318:	04078793          	addi	a5,a5,64
ffffffffc020131c:	fed792e3          	bne	a5,a3,ffffffffc0201300 <default_free_pages+0x14>
    base->property = n;
ffffffffc0201320:	2581                	sext.w	a1,a1
ffffffffc0201322:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201324:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201328:	4789                	li	a5,2
ffffffffc020132a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020132e:	00010697          	auipc	a3,0x10
ffffffffc0201332:	12a68693          	addi	a3,a3,298 # ffffffffc0211458 <free_area>
ffffffffc0201336:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201338:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020133a:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020133e:	9db9                	addw	a1,a1,a4
ffffffffc0201340:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201342:	0ad78463          	beq	a5,a3,ffffffffc02013ea <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc0201346:	fe878713          	addi	a4,a5,-24
ffffffffc020134a:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020134e:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201350:	00e56a63          	bltu	a0,a4,ffffffffc0201364 <default_free_pages+0x78>
    return listelm->next;
ffffffffc0201354:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201356:	04d70c63          	beq	a4,a3,ffffffffc02013ae <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc020135a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020135c:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201360:	fee57ae3          	bgeu	a0,a4,ffffffffc0201354 <default_free_pages+0x68>
ffffffffc0201364:	c199                	beqz	a1,ffffffffc020136a <default_free_pages+0x7e>
ffffffffc0201366:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020136a:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc020136c:	e390                	sd	a2,0(a5)
ffffffffc020136e:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201370:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201372:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0201374:	00d70d63          	beq	a4,a3,ffffffffc020138e <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc0201378:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc020137c:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0201380:	02059813          	slli	a6,a1,0x20
ffffffffc0201384:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201388:	97b2                	add	a5,a5,a2
ffffffffc020138a:	02f50c63          	beq	a0,a5,ffffffffc02013c2 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc020138e:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201390:	00d78c63          	beq	a5,a3,ffffffffc02013a8 <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc0201394:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0201396:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc020139a:	02061593          	slli	a1,a2,0x20
ffffffffc020139e:	01a5d713          	srli	a4,a1,0x1a
ffffffffc02013a2:	972a                	add	a4,a4,a0
ffffffffc02013a4:	04e68a63          	beq	a3,a4,ffffffffc02013f8 <default_free_pages+0x10c>
}
ffffffffc02013a8:	60a2                	ld	ra,8(sp)
ffffffffc02013aa:	0141                	addi	sp,sp,16
ffffffffc02013ac:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02013ae:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02013b0:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02013b2:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02013b4:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013b6:	02d70763          	beq	a4,a3,ffffffffc02013e4 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc02013ba:	8832                	mv	a6,a2
ffffffffc02013bc:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02013be:	87ba                	mv	a5,a4
ffffffffc02013c0:	bf71                	j	ffffffffc020135c <default_free_pages+0x70>
            p->property += base->property;
ffffffffc02013c2:	491c                	lw	a5,16(a0)
ffffffffc02013c4:	9dbd                	addw	a1,a1,a5
ffffffffc02013c6:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02013ca:	57f5                	li	a5,-3
ffffffffc02013cc:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02013d0:	01853803          	ld	a6,24(a0)
ffffffffc02013d4:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc02013d6:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02013d8:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc02013dc:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc02013de:	0105b023          	sd	a6,0(a1)
ffffffffc02013e2:	b77d                	j	ffffffffc0201390 <default_free_pages+0xa4>
ffffffffc02013e4:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013e6:	873e                	mv	a4,a5
ffffffffc02013e8:	bf41                	j	ffffffffc0201378 <default_free_pages+0x8c>
}
ffffffffc02013ea:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02013ec:	e390                	sd	a2,0(a5)
ffffffffc02013ee:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02013f0:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02013f2:	ed1c                	sd	a5,24(a0)
ffffffffc02013f4:	0141                	addi	sp,sp,16
ffffffffc02013f6:	8082                	ret
            base->property += p->property;
ffffffffc02013f8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02013fc:	ff078693          	addi	a3,a5,-16
ffffffffc0201400:	9e39                	addw	a2,a2,a4
ffffffffc0201402:	c910                	sw	a2,16(a0)
ffffffffc0201404:	5775                	li	a4,-3
ffffffffc0201406:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020140a:	6398                	ld	a4,0(a5)
ffffffffc020140c:	679c                	ld	a5,8(a5)
}
ffffffffc020140e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201410:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201412:	e398                	sd	a4,0(a5)
ffffffffc0201414:	0141                	addi	sp,sp,16
ffffffffc0201416:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201418:	00004697          	auipc	a3,0x4
ffffffffc020141c:	27068693          	addi	a3,a3,624 # ffffffffc0205688 <commands+0xa98>
ffffffffc0201420:	00004617          	auipc	a2,0x4
ffffffffc0201424:	f0860613          	addi	a2,a2,-248 # ffffffffc0205328 <commands+0x738>
ffffffffc0201428:	08300593          	li	a1,131
ffffffffc020142c:	00004517          	auipc	a0,0x4
ffffffffc0201430:	f1450513          	addi	a0,a0,-236 # ffffffffc0205340 <commands+0x750>
ffffffffc0201434:	812ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(n > 0);
ffffffffc0201438:	00004697          	auipc	a3,0x4
ffffffffc020143c:	24868693          	addi	a3,a3,584 # ffffffffc0205680 <commands+0xa90>
ffffffffc0201440:	00004617          	auipc	a2,0x4
ffffffffc0201444:	ee860613          	addi	a2,a2,-280 # ffffffffc0205328 <commands+0x738>
ffffffffc0201448:	08000593          	li	a1,128
ffffffffc020144c:	00004517          	auipc	a0,0x4
ffffffffc0201450:	ef450513          	addi	a0,a0,-268 # ffffffffc0205340 <commands+0x750>
ffffffffc0201454:	ff3fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201458 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201458:	c941                	beqz	a0,ffffffffc02014e8 <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc020145a:	00010597          	auipc	a1,0x10
ffffffffc020145e:	ffe58593          	addi	a1,a1,-2 # ffffffffc0211458 <free_area>
ffffffffc0201462:	0105a803          	lw	a6,16(a1)
ffffffffc0201466:	872a                	mv	a4,a0
ffffffffc0201468:	02081793          	slli	a5,a6,0x20
ffffffffc020146c:	9381                	srli	a5,a5,0x20
ffffffffc020146e:	00a7ee63          	bltu	a5,a0,ffffffffc020148a <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201472:	87ae                	mv	a5,a1
ffffffffc0201474:	a801                	j	ffffffffc0201484 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201476:	ff87a683          	lw	a3,-8(a5)
ffffffffc020147a:	02069613          	slli	a2,a3,0x20
ffffffffc020147e:	9201                	srli	a2,a2,0x20
ffffffffc0201480:	00e67763          	bgeu	a2,a4,ffffffffc020148e <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201484:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201486:	feb798e3          	bne	a5,a1,ffffffffc0201476 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020148a:	4501                	li	a0,0
}
ffffffffc020148c:	8082                	ret
    return listelm->prev;
ffffffffc020148e:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201492:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201496:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc020149a:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc020149e:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02014a2:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02014a6:	02c77863          	bgeu	a4,a2,ffffffffc02014d6 <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc02014aa:	071a                	slli	a4,a4,0x6
ffffffffc02014ac:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc02014ae:	41c686bb          	subw	a3,a3,t3
ffffffffc02014b2:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02014b4:	00870613          	addi	a2,a4,8
ffffffffc02014b8:	4689                	li	a3,2
ffffffffc02014ba:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02014be:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02014c2:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc02014c6:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc02014ca:	e290                	sd	a2,0(a3)
ffffffffc02014cc:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02014d0:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc02014d2:	01173c23          	sd	a7,24(a4)
ffffffffc02014d6:	41c8083b          	subw	a6,a6,t3
ffffffffc02014da:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02014de:	5775                	li	a4,-3
ffffffffc02014e0:	17c1                	addi	a5,a5,-16
ffffffffc02014e2:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc02014e6:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02014e8:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02014ea:	00004697          	auipc	a3,0x4
ffffffffc02014ee:	19668693          	addi	a3,a3,406 # ffffffffc0205680 <commands+0xa90>
ffffffffc02014f2:	00004617          	auipc	a2,0x4
ffffffffc02014f6:	e3660613          	addi	a2,a2,-458 # ffffffffc0205328 <commands+0x738>
ffffffffc02014fa:	06200593          	li	a1,98
ffffffffc02014fe:	00004517          	auipc	a0,0x4
ffffffffc0201502:	e4250513          	addi	a0,a0,-446 # ffffffffc0205340 <commands+0x750>
default_alloc_pages(size_t n) {
ffffffffc0201506:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201508:	f3ffe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020150c <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020150c:	1141                	addi	sp,sp,-16
ffffffffc020150e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201510:	c5f1                	beqz	a1,ffffffffc02015dc <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc0201512:	00659693          	slli	a3,a1,0x6
ffffffffc0201516:	96aa                	add	a3,a3,a0
ffffffffc0201518:	87aa                	mv	a5,a0
ffffffffc020151a:	00d50f63          	beq	a0,a3,ffffffffc0201538 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020151e:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0201520:	8b05                	andi	a4,a4,1
ffffffffc0201522:	cf49                	beqz	a4,ffffffffc02015bc <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0201524:	0007a823          	sw	zero,16(a5)
ffffffffc0201528:	0007b423          	sd	zero,8(a5)
ffffffffc020152c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201530:	04078793          	addi	a5,a5,64
ffffffffc0201534:	fed795e3          	bne	a5,a3,ffffffffc020151e <default_init_memmap+0x12>
    base->property = n;
ffffffffc0201538:	2581                	sext.w	a1,a1
ffffffffc020153a:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020153c:	4789                	li	a5,2
ffffffffc020153e:	00850713          	addi	a4,a0,8
ffffffffc0201542:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201546:	00010697          	auipc	a3,0x10
ffffffffc020154a:	f1268693          	addi	a3,a3,-238 # ffffffffc0211458 <free_area>
ffffffffc020154e:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201550:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201552:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201556:	9db9                	addw	a1,a1,a4
ffffffffc0201558:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020155a:	04d78a63          	beq	a5,a3,ffffffffc02015ae <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc020155e:	fe878713          	addi	a4,a5,-24
ffffffffc0201562:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201566:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201568:	00e56a63          	bltu	a0,a4,ffffffffc020157c <default_init_memmap+0x70>
    return listelm->next;
ffffffffc020156c:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020156e:	02d70263          	beq	a4,a3,ffffffffc0201592 <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc0201572:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201574:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201578:	fee57ae3          	bgeu	a0,a4,ffffffffc020156c <default_init_memmap+0x60>
ffffffffc020157c:	c199                	beqz	a1,ffffffffc0201582 <default_init_memmap+0x76>
ffffffffc020157e:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201582:	6398                	ld	a4,0(a5)
}
ffffffffc0201584:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201586:	e390                	sd	a2,0(a5)
ffffffffc0201588:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020158a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020158c:	ed18                	sd	a4,24(a0)
ffffffffc020158e:	0141                	addi	sp,sp,16
ffffffffc0201590:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201592:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201594:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201596:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201598:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020159a:	00d70663          	beq	a4,a3,ffffffffc02015a6 <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc020159e:	8832                	mv	a6,a2
ffffffffc02015a0:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02015a2:	87ba                	mv	a5,a4
ffffffffc02015a4:	bfc1                	j	ffffffffc0201574 <default_init_memmap+0x68>
}
ffffffffc02015a6:	60a2                	ld	ra,8(sp)
ffffffffc02015a8:	e290                	sd	a2,0(a3)
ffffffffc02015aa:	0141                	addi	sp,sp,16
ffffffffc02015ac:	8082                	ret
ffffffffc02015ae:	60a2                	ld	ra,8(sp)
ffffffffc02015b0:	e390                	sd	a2,0(a5)
ffffffffc02015b2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02015b4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02015b6:	ed1c                	sd	a5,24(a0)
ffffffffc02015b8:	0141                	addi	sp,sp,16
ffffffffc02015ba:	8082                	ret
        assert(PageReserved(p));
ffffffffc02015bc:	00004697          	auipc	a3,0x4
ffffffffc02015c0:	0f468693          	addi	a3,a3,244 # ffffffffc02056b0 <commands+0xac0>
ffffffffc02015c4:	00004617          	auipc	a2,0x4
ffffffffc02015c8:	d6460613          	addi	a2,a2,-668 # ffffffffc0205328 <commands+0x738>
ffffffffc02015cc:	04900593          	li	a1,73
ffffffffc02015d0:	00004517          	auipc	a0,0x4
ffffffffc02015d4:	d7050513          	addi	a0,a0,-656 # ffffffffc0205340 <commands+0x750>
ffffffffc02015d8:	e6ffe0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(n > 0);
ffffffffc02015dc:	00004697          	auipc	a3,0x4
ffffffffc02015e0:	0a468693          	addi	a3,a3,164 # ffffffffc0205680 <commands+0xa90>
ffffffffc02015e4:	00004617          	auipc	a2,0x4
ffffffffc02015e8:	d4460613          	addi	a2,a2,-700 # ffffffffc0205328 <commands+0x738>
ffffffffc02015ec:	04600593          	li	a1,70
ffffffffc02015f0:	00004517          	auipc	a0,0x4
ffffffffc02015f4:	d5050513          	addi	a0,a0,-688 # ffffffffc0205340 <commands+0x750>
ffffffffc02015f8:	e4ffe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02015fc <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02015fc:	c94d                	beqz	a0,ffffffffc02016ae <slob_free+0xb2>
{
ffffffffc02015fe:	1141                	addi	sp,sp,-16
ffffffffc0201600:	e022                	sd	s0,0(sp)
ffffffffc0201602:	e406                	sd	ra,8(sp)
ffffffffc0201604:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc0201606:	e9c1                	bnez	a1,ffffffffc0201696 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201608:	100027f3          	csrr	a5,sstatus
ffffffffc020160c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020160e:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201610:	ebd9                	bnez	a5,ffffffffc02016a6 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201612:	00009617          	auipc	a2,0x9
ffffffffc0201616:	a3e60613          	addi	a2,a2,-1474 # ffffffffc020a050 <slobfree>
ffffffffc020161a:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020161c:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020161e:	679c                	ld	a5,8(a5)
ffffffffc0201620:	02877a63          	bgeu	a4,s0,ffffffffc0201654 <slob_free+0x58>
ffffffffc0201624:	00f46463          	bltu	s0,a5,ffffffffc020162c <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201628:	fef76ae3          	bltu	a4,a5,ffffffffc020161c <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc020162c:	400c                	lw	a1,0(s0)
ffffffffc020162e:	00459693          	slli	a3,a1,0x4
ffffffffc0201632:	96a2                	add	a3,a3,s0
ffffffffc0201634:	02d78a63          	beq	a5,a3,ffffffffc0201668 <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0201638:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc020163a:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc020163c:	00469793          	slli	a5,a3,0x4
ffffffffc0201640:	97ba                	add	a5,a5,a4
ffffffffc0201642:	02f40e63          	beq	s0,a5,ffffffffc020167e <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201646:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0201648:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc020164a:	e129                	bnez	a0,ffffffffc020168c <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc020164c:	60a2                	ld	ra,8(sp)
ffffffffc020164e:	6402                	ld	s0,0(sp)
ffffffffc0201650:	0141                	addi	sp,sp,16
ffffffffc0201652:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201654:	fcf764e3          	bltu	a4,a5,ffffffffc020161c <slob_free+0x20>
ffffffffc0201658:	fcf472e3          	bgeu	s0,a5,ffffffffc020161c <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc020165c:	400c                	lw	a1,0(s0)
ffffffffc020165e:	00459693          	slli	a3,a1,0x4
ffffffffc0201662:	96a2                	add	a3,a3,s0
ffffffffc0201664:	fcd79ae3          	bne	a5,a3,ffffffffc0201638 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0201668:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc020166a:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc020166c:	9db5                	addw	a1,a1,a3
ffffffffc020166e:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc0201670:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201672:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201674:	00469793          	slli	a5,a3,0x4
ffffffffc0201678:	97ba                	add	a5,a5,a4
ffffffffc020167a:	fcf416e3          	bne	s0,a5,ffffffffc0201646 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc020167e:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201680:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0201682:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201684:	9ebd                	addw	a3,a3,a5
ffffffffc0201686:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0201688:	e70c                	sd	a1,8(a4)
ffffffffc020168a:	d169                	beqz	a0,ffffffffc020164c <slob_free+0x50>
}
ffffffffc020168c:	6402                	ld	s0,0(sp)
ffffffffc020168e:	60a2                	ld	ra,8(sp)
ffffffffc0201690:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0201692:	f07fe06f          	j	ffffffffc0200598 <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0201696:	25bd                	addiw	a1,a1,15
ffffffffc0201698:	8191                	srli	a1,a1,0x4
ffffffffc020169a:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020169c:	100027f3          	csrr	a5,sstatus
ffffffffc02016a0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02016a2:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016a4:	d7bd                	beqz	a5,ffffffffc0201612 <slob_free+0x16>
        intr_disable();
ffffffffc02016a6:	ef9fe0ef          	jal	ra,ffffffffc020059e <intr_disable>
        return 1;
ffffffffc02016aa:	4505                	li	a0,1
ffffffffc02016ac:	b79d                	j	ffffffffc0201612 <slob_free+0x16>
ffffffffc02016ae:	8082                	ret

ffffffffc02016b0 <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc02016b0:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02016b2:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc02016b4:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02016b8:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc02016ba:	34e000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
  if(!page)
ffffffffc02016be:	c91d                	beqz	a0,ffffffffc02016f4 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc02016c0:	00014697          	auipc	a3,0x14
ffffffffc02016c4:	ea86b683          	ld	a3,-344(a3) # ffffffffc0215568 <pages>
ffffffffc02016c8:	8d15                	sub	a0,a0,a3
ffffffffc02016ca:	8519                	srai	a0,a0,0x6
ffffffffc02016cc:	00005697          	auipc	a3,0x5
ffffffffc02016d0:	2dc6b683          	ld	a3,732(a3) # ffffffffc02069a8 <nbase>
ffffffffc02016d4:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc02016d6:	00c51793          	slli	a5,a0,0xc
ffffffffc02016da:	83b1                	srli	a5,a5,0xc
ffffffffc02016dc:	00014717          	auipc	a4,0x14
ffffffffc02016e0:	e8473703          	ld	a4,-380(a4) # ffffffffc0215560 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc02016e4:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc02016e6:	00e7fa63          	bgeu	a5,a4,ffffffffc02016fa <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc02016ea:	00014697          	auipc	a3,0x14
ffffffffc02016ee:	e8e6b683          	ld	a3,-370(a3) # ffffffffc0215578 <va_pa_offset>
ffffffffc02016f2:	9536                	add	a0,a0,a3
}
ffffffffc02016f4:	60a2                	ld	ra,8(sp)
ffffffffc02016f6:	0141                	addi	sp,sp,16
ffffffffc02016f8:	8082                	ret
ffffffffc02016fa:	86aa                	mv	a3,a0
ffffffffc02016fc:	00004617          	auipc	a2,0x4
ffffffffc0201700:	01460613          	addi	a2,a2,20 # ffffffffc0205710 <default_pmm_manager+0x38>
ffffffffc0201704:	06900593          	li	a1,105
ffffffffc0201708:	00004517          	auipc	a0,0x4
ffffffffc020170c:	03050513          	addi	a0,a0,48 # ffffffffc0205738 <default_pmm_manager+0x60>
ffffffffc0201710:	d37fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201714 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201714:	1101                	addi	sp,sp,-32
ffffffffc0201716:	ec06                	sd	ra,24(sp)
ffffffffc0201718:	e822                	sd	s0,16(sp)
ffffffffc020171a:	e426                	sd	s1,8(sp)
ffffffffc020171c:	e04a                	sd	s2,0(sp)
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc020171e:	01050713          	addi	a4,a0,16
ffffffffc0201722:	6785                	lui	a5,0x1
ffffffffc0201724:	0cf77363          	bgeu	a4,a5,ffffffffc02017ea <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201728:	00f50493          	addi	s1,a0,15
ffffffffc020172c:	8091                	srli	s1,s1,0x4
ffffffffc020172e:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201730:	10002673          	csrr	a2,sstatus
ffffffffc0201734:	8a09                	andi	a2,a2,2
ffffffffc0201736:	e25d                	bnez	a2,ffffffffc02017dc <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201738:	00009917          	auipc	s2,0x9
ffffffffc020173c:	91890913          	addi	s2,s2,-1768 # ffffffffc020a050 <slobfree>
ffffffffc0201740:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201744:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201746:	4398                	lw	a4,0(a5)
ffffffffc0201748:	08975e63          	bge	a4,s1,ffffffffc02017e4 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc020174c:	00d78b63          	beq	a5,a3,ffffffffc0201762 <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201750:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201752:	4018                	lw	a4,0(s0)
ffffffffc0201754:	02975a63          	bge	a4,s1,ffffffffc0201788 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc0201758:	00093683          	ld	a3,0(s2)
ffffffffc020175c:	87a2                	mv	a5,s0
ffffffffc020175e:	fed799e3          	bne	a5,a3,ffffffffc0201750 <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc0201762:	ee31                	bnez	a2,ffffffffc02017be <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201764:	4501                	li	a0,0
ffffffffc0201766:	f4bff0ef          	jal	ra,ffffffffc02016b0 <__slob_get_free_pages.constprop.0>
ffffffffc020176a:	842a                	mv	s0,a0
			if (!cur)
ffffffffc020176c:	cd05                	beqz	a0,ffffffffc02017a4 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc020176e:	6585                	lui	a1,0x1
ffffffffc0201770:	e8dff0ef          	jal	ra,ffffffffc02015fc <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201774:	10002673          	csrr	a2,sstatus
ffffffffc0201778:	8a09                	andi	a2,a2,2
ffffffffc020177a:	ee05                	bnez	a2,ffffffffc02017b2 <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc020177c:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201780:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201782:	4018                	lw	a4,0(s0)
ffffffffc0201784:	fc974ae3          	blt	a4,s1,ffffffffc0201758 <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0201788:	04e48763          	beq	s1,a4,ffffffffc02017d6 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc020178c:	00449693          	slli	a3,s1,0x4
ffffffffc0201790:	96a2                	add	a3,a3,s0
ffffffffc0201792:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201794:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201796:	9f05                	subw	a4,a4,s1
ffffffffc0201798:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc020179a:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc020179c:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc020179e:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc02017a2:	e20d                	bnez	a2,ffffffffc02017c4 <slob_alloc.constprop.0+0xb0>
}
ffffffffc02017a4:	60e2                	ld	ra,24(sp)
ffffffffc02017a6:	8522                	mv	a0,s0
ffffffffc02017a8:	6442                	ld	s0,16(sp)
ffffffffc02017aa:	64a2                	ld	s1,8(sp)
ffffffffc02017ac:	6902                	ld	s2,0(sp)
ffffffffc02017ae:	6105                	addi	sp,sp,32
ffffffffc02017b0:	8082                	ret
        intr_disable();
ffffffffc02017b2:	dedfe0ef          	jal	ra,ffffffffc020059e <intr_disable>
			cur = slobfree;
ffffffffc02017b6:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc02017ba:	4605                	li	a2,1
ffffffffc02017bc:	b7d1                	j	ffffffffc0201780 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc02017be:	ddbfe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc02017c2:	b74d                	j	ffffffffc0201764 <slob_alloc.constprop.0+0x50>
ffffffffc02017c4:	dd5fe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
}
ffffffffc02017c8:	60e2                	ld	ra,24(sp)
ffffffffc02017ca:	8522                	mv	a0,s0
ffffffffc02017cc:	6442                	ld	s0,16(sp)
ffffffffc02017ce:	64a2                	ld	s1,8(sp)
ffffffffc02017d0:	6902                	ld	s2,0(sp)
ffffffffc02017d2:	6105                	addi	sp,sp,32
ffffffffc02017d4:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc02017d6:	6418                	ld	a4,8(s0)
ffffffffc02017d8:	e798                	sd	a4,8(a5)
ffffffffc02017da:	b7d1                	j	ffffffffc020179e <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc02017dc:	dc3fe0ef          	jal	ra,ffffffffc020059e <intr_disable>
        return 1;
ffffffffc02017e0:	4605                	li	a2,1
ffffffffc02017e2:	bf99                	j	ffffffffc0201738 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02017e4:	843e                	mv	s0,a5
ffffffffc02017e6:	87b6                	mv	a5,a3
ffffffffc02017e8:	b745                	j	ffffffffc0201788 <slob_alloc.constprop.0+0x74>
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02017ea:	00004697          	auipc	a3,0x4
ffffffffc02017ee:	f5e68693          	addi	a3,a3,-162 # ffffffffc0205748 <default_pmm_manager+0x70>
ffffffffc02017f2:	00004617          	auipc	a2,0x4
ffffffffc02017f6:	b3660613          	addi	a2,a2,-1226 # ffffffffc0205328 <commands+0x738>
ffffffffc02017fa:	06300593          	li	a1,99
ffffffffc02017fe:	00004517          	auipc	a0,0x4
ffffffffc0201802:	f6a50513          	addi	a0,a0,-150 # ffffffffc0205768 <default_pmm_manager+0x90>
ffffffffc0201806:	c41fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020180a <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc020180a:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc020180c:	00004517          	auipc	a0,0x4
ffffffffc0201810:	f7450513          	addi	a0,a0,-140 # ffffffffc0205780 <default_pmm_manager+0xa8>
kmalloc_init(void) {
ffffffffc0201814:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201816:	96bfe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc020181a:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc020181c:	00004517          	auipc	a0,0x4
ffffffffc0201820:	f7c50513          	addi	a0,a0,-132 # ffffffffc0205798 <default_pmm_manager+0xc0>
}
ffffffffc0201824:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201826:	95bfe06f          	j	ffffffffc0200180 <cprintf>

ffffffffc020182a <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc020182a:	1101                	addi	sp,sp,-32
ffffffffc020182c:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc020182e:	6905                	lui	s2,0x1
{
ffffffffc0201830:	e822                	sd	s0,16(sp)
ffffffffc0201832:	ec06                	sd	ra,24(sp)
ffffffffc0201834:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201836:	fef90793          	addi	a5,s2,-17 # fef <kern_entry-0xffffffffc01ff011>
{
ffffffffc020183a:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc020183c:	04a7f963          	bgeu	a5,a0,ffffffffc020188e <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201840:	4561                	li	a0,24
ffffffffc0201842:	ed3ff0ef          	jal	ra,ffffffffc0201714 <slob_alloc.constprop.0>
ffffffffc0201846:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201848:	c929                	beqz	a0,ffffffffc020189a <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc020184a:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc020184e:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201850:	00f95763          	bge	s2,a5,ffffffffc020185e <kmalloc+0x34>
ffffffffc0201854:	6705                	lui	a4,0x1
ffffffffc0201856:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201858:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc020185a:	fef74ee3          	blt	a4,a5,ffffffffc0201856 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc020185e:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201860:	e51ff0ef          	jal	ra,ffffffffc02016b0 <__slob_get_free_pages.constprop.0>
ffffffffc0201864:	e488                	sd	a0,8(s1)
ffffffffc0201866:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201868:	c525                	beqz	a0,ffffffffc02018d0 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020186a:	100027f3          	csrr	a5,sstatus
ffffffffc020186e:	8b89                	andi	a5,a5,2
ffffffffc0201870:	ef8d                	bnez	a5,ffffffffc02018aa <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201872:	00014797          	auipc	a5,0x14
ffffffffc0201876:	cd678793          	addi	a5,a5,-810 # ffffffffc0215548 <bigblocks>
ffffffffc020187a:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc020187c:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc020187e:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201880:	60e2                	ld	ra,24(sp)
ffffffffc0201882:	8522                	mv	a0,s0
ffffffffc0201884:	6442                	ld	s0,16(sp)
ffffffffc0201886:	64a2                	ld	s1,8(sp)
ffffffffc0201888:	6902                	ld	s2,0(sp)
ffffffffc020188a:	6105                	addi	sp,sp,32
ffffffffc020188c:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc020188e:	0541                	addi	a0,a0,16
ffffffffc0201890:	e85ff0ef          	jal	ra,ffffffffc0201714 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201894:	01050413          	addi	s0,a0,16
ffffffffc0201898:	f565                	bnez	a0,ffffffffc0201880 <kmalloc+0x56>
ffffffffc020189a:	4401                	li	s0,0
}
ffffffffc020189c:	60e2                	ld	ra,24(sp)
ffffffffc020189e:	8522                	mv	a0,s0
ffffffffc02018a0:	6442                	ld	s0,16(sp)
ffffffffc02018a2:	64a2                	ld	s1,8(sp)
ffffffffc02018a4:	6902                	ld	s2,0(sp)
ffffffffc02018a6:	6105                	addi	sp,sp,32
ffffffffc02018a8:	8082                	ret
        intr_disable();
ffffffffc02018aa:	cf5fe0ef          	jal	ra,ffffffffc020059e <intr_disable>
		bb->next = bigblocks;
ffffffffc02018ae:	00014797          	auipc	a5,0x14
ffffffffc02018b2:	c9a78793          	addi	a5,a5,-870 # ffffffffc0215548 <bigblocks>
ffffffffc02018b6:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc02018b8:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc02018ba:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc02018bc:	cddfe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
		return bb->pages;
ffffffffc02018c0:	6480                	ld	s0,8(s1)
}
ffffffffc02018c2:	60e2                	ld	ra,24(sp)
ffffffffc02018c4:	64a2                	ld	s1,8(sp)
ffffffffc02018c6:	8522                	mv	a0,s0
ffffffffc02018c8:	6442                	ld	s0,16(sp)
ffffffffc02018ca:	6902                	ld	s2,0(sp)
ffffffffc02018cc:	6105                	addi	sp,sp,32
ffffffffc02018ce:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc02018d0:	45e1                	li	a1,24
ffffffffc02018d2:	8526                	mv	a0,s1
ffffffffc02018d4:	d29ff0ef          	jal	ra,ffffffffc02015fc <slob_free>
  return __kmalloc(size, 0);
ffffffffc02018d8:	b765                	j	ffffffffc0201880 <kmalloc+0x56>

ffffffffc02018da <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc02018da:	c169                	beqz	a0,ffffffffc020199c <kfree+0xc2>
{
ffffffffc02018dc:	1101                	addi	sp,sp,-32
ffffffffc02018de:	e822                	sd	s0,16(sp)
ffffffffc02018e0:	ec06                	sd	ra,24(sp)
ffffffffc02018e2:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc02018e4:	03451793          	slli	a5,a0,0x34
ffffffffc02018e8:	842a                	mv	s0,a0
ffffffffc02018ea:	e3d9                	bnez	a5,ffffffffc0201970 <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018ec:	100027f3          	csrr	a5,sstatus
ffffffffc02018f0:	8b89                	andi	a5,a5,2
ffffffffc02018f2:	e7d9                	bnez	a5,ffffffffc0201980 <kfree+0xa6>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02018f4:	00014797          	auipc	a5,0x14
ffffffffc02018f8:	c547b783          	ld	a5,-940(a5) # ffffffffc0215548 <bigblocks>
    return 0;
ffffffffc02018fc:	4601                	li	a2,0
ffffffffc02018fe:	cbad                	beqz	a5,ffffffffc0201970 <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201900:	00014697          	auipc	a3,0x14
ffffffffc0201904:	c4868693          	addi	a3,a3,-952 # ffffffffc0215548 <bigblocks>
ffffffffc0201908:	a021                	j	ffffffffc0201910 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020190a:	01048693          	addi	a3,s1,16
ffffffffc020190e:	c3a5                	beqz	a5,ffffffffc020196e <kfree+0x94>
			if (bb->pages == block) {
ffffffffc0201910:	6798                	ld	a4,8(a5)
ffffffffc0201912:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc0201914:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc0201916:	fe871ae3          	bne	a4,s0,ffffffffc020190a <kfree+0x30>
				*last = bb->next;
ffffffffc020191a:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc020191c:	ee2d                	bnez	a2,ffffffffc0201996 <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc020191e:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201922:	4098                	lw	a4,0(s1)
ffffffffc0201924:	08f46963          	bltu	s0,a5,ffffffffc02019b6 <kfree+0xdc>
ffffffffc0201928:	00014697          	auipc	a3,0x14
ffffffffc020192c:	c506b683          	ld	a3,-944(a3) # ffffffffc0215578 <va_pa_offset>
ffffffffc0201930:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc0201932:	8031                	srli	s0,s0,0xc
ffffffffc0201934:	00014797          	auipc	a5,0x14
ffffffffc0201938:	c2c7b783          	ld	a5,-980(a5) # ffffffffc0215560 <npage>
ffffffffc020193c:	06f47163          	bgeu	s0,a5,ffffffffc020199e <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201940:	00005517          	auipc	a0,0x5
ffffffffc0201944:	06853503          	ld	a0,104(a0) # ffffffffc02069a8 <nbase>
ffffffffc0201948:	8c09                	sub	s0,s0,a0
ffffffffc020194a:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc020194c:	00014517          	auipc	a0,0x14
ffffffffc0201950:	c1c53503          	ld	a0,-996(a0) # ffffffffc0215568 <pages>
ffffffffc0201954:	4585                	li	a1,1
ffffffffc0201956:	9522                	add	a0,a0,s0
ffffffffc0201958:	00e595bb          	sllw	a1,a1,a4
ffffffffc020195c:	13e000ef          	jal	ra,ffffffffc0201a9a <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201960:	6442                	ld	s0,16(sp)
ffffffffc0201962:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201964:	8526                	mv	a0,s1
}
ffffffffc0201966:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201968:	45e1                	li	a1,24
}
ffffffffc020196a:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc020196c:	b941                	j	ffffffffc02015fc <slob_free>
ffffffffc020196e:	e20d                	bnez	a2,ffffffffc0201990 <kfree+0xb6>
ffffffffc0201970:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201974:	6442                	ld	s0,16(sp)
ffffffffc0201976:	60e2                	ld	ra,24(sp)
ffffffffc0201978:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc020197a:	4581                	li	a1,0
}
ffffffffc020197c:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc020197e:	b9bd                	j	ffffffffc02015fc <slob_free>
        intr_disable();
ffffffffc0201980:	c1ffe0ef          	jal	ra,ffffffffc020059e <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201984:	00014797          	auipc	a5,0x14
ffffffffc0201988:	bc47b783          	ld	a5,-1084(a5) # ffffffffc0215548 <bigblocks>
        return 1;
ffffffffc020198c:	4605                	li	a2,1
ffffffffc020198e:	fbad                	bnez	a5,ffffffffc0201900 <kfree+0x26>
        intr_enable();
ffffffffc0201990:	c09fe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc0201994:	bff1                	j	ffffffffc0201970 <kfree+0x96>
ffffffffc0201996:	c03fe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc020199a:	b751                	j	ffffffffc020191e <kfree+0x44>
ffffffffc020199c:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc020199e:	00004617          	auipc	a2,0x4
ffffffffc02019a2:	e4260613          	addi	a2,a2,-446 # ffffffffc02057e0 <default_pmm_manager+0x108>
ffffffffc02019a6:	06200593          	li	a1,98
ffffffffc02019aa:	00004517          	auipc	a0,0x4
ffffffffc02019ae:	d8e50513          	addi	a0,a0,-626 # ffffffffc0205738 <default_pmm_manager+0x60>
ffffffffc02019b2:	a95fe0ef          	jal	ra,ffffffffc0200446 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02019b6:	86a2                	mv	a3,s0
ffffffffc02019b8:	00004617          	auipc	a2,0x4
ffffffffc02019bc:	e0060613          	addi	a2,a2,-512 # ffffffffc02057b8 <default_pmm_manager+0xe0>
ffffffffc02019c0:	06e00593          	li	a1,110
ffffffffc02019c4:	00004517          	auipc	a0,0x4
ffffffffc02019c8:	d7450513          	addi	a0,a0,-652 # ffffffffc0205738 <default_pmm_manager+0x60>
ffffffffc02019cc:	a7bfe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02019d0 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc02019d0:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02019d2:	00004617          	auipc	a2,0x4
ffffffffc02019d6:	e0e60613          	addi	a2,a2,-498 # ffffffffc02057e0 <default_pmm_manager+0x108>
ffffffffc02019da:	06200593          	li	a1,98
ffffffffc02019de:	00004517          	auipc	a0,0x4
ffffffffc02019e2:	d5a50513          	addi	a0,a0,-678 # ffffffffc0205738 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc02019e6:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02019e8:	a5ffe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02019ec <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc02019ec:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc02019ee:	00004617          	auipc	a2,0x4
ffffffffc02019f2:	e1260613          	addi	a2,a2,-494 # ffffffffc0205800 <default_pmm_manager+0x128>
ffffffffc02019f6:	07400593          	li	a1,116
ffffffffc02019fa:	00004517          	auipc	a0,0x4
ffffffffc02019fe:	d3e50513          	addi	a0,a0,-706 # ffffffffc0205738 <default_pmm_manager+0x60>
pte2page(pte_t pte) {
ffffffffc0201a02:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0201a04:	a43fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201a08 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201a08:	7139                	addi	sp,sp,-64
ffffffffc0201a0a:	f426                	sd	s1,40(sp)
ffffffffc0201a0c:	f04a                	sd	s2,32(sp)
ffffffffc0201a0e:	ec4e                	sd	s3,24(sp)
ffffffffc0201a10:	e852                	sd	s4,16(sp)
ffffffffc0201a12:	e456                	sd	s5,8(sp)
ffffffffc0201a14:	e05a                	sd	s6,0(sp)
ffffffffc0201a16:	fc06                	sd	ra,56(sp)
ffffffffc0201a18:	f822                	sd	s0,48(sp)
ffffffffc0201a1a:	84aa                	mv	s1,a0
ffffffffc0201a1c:	00014917          	auipc	s2,0x14
ffffffffc0201a20:	b5490913          	addi	s2,s2,-1196 # ffffffffc0215570 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201a24:	4a05                	li	s4,1
ffffffffc0201a26:	00014a97          	auipc	s5,0x14
ffffffffc0201a2a:	b6aa8a93          	addi	s5,s5,-1174 # ffffffffc0215590 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201a2e:	0005099b          	sext.w	s3,a0
ffffffffc0201a32:	00014b17          	auipc	s6,0x14
ffffffffc0201a36:	b66b0b13          	addi	s6,s6,-1178 # ffffffffc0215598 <check_mm_struct>
ffffffffc0201a3a:	a01d                	j	ffffffffc0201a60 <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201a3c:	00093783          	ld	a5,0(s2)
ffffffffc0201a40:	6f9c                	ld	a5,24(a5)
ffffffffc0201a42:	9782                	jalr	a5
ffffffffc0201a44:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0201a46:	4601                	li	a2,0
ffffffffc0201a48:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201a4a:	ec0d                	bnez	s0,ffffffffc0201a84 <alloc_pages+0x7c>
ffffffffc0201a4c:	029a6c63          	bltu	s4,s1,ffffffffc0201a84 <alloc_pages+0x7c>
ffffffffc0201a50:	000aa783          	lw	a5,0(s5)
ffffffffc0201a54:	2781                	sext.w	a5,a5
ffffffffc0201a56:	c79d                	beqz	a5,ffffffffc0201a84 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201a58:	000b3503          	ld	a0,0(s6)
ffffffffc0201a5c:	037010ef          	jal	ra,ffffffffc0203292 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a60:	100027f3          	csrr	a5,sstatus
ffffffffc0201a64:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201a66:	8526                	mv	a0,s1
ffffffffc0201a68:	dbf1                	beqz	a5,ffffffffc0201a3c <alloc_pages+0x34>
        intr_disable();
ffffffffc0201a6a:	b35fe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc0201a6e:	00093783          	ld	a5,0(s2)
ffffffffc0201a72:	8526                	mv	a0,s1
ffffffffc0201a74:	6f9c                	ld	a5,24(a5)
ffffffffc0201a76:	9782                	jalr	a5
ffffffffc0201a78:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201a7a:	b1ffe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201a7e:	4601                	li	a2,0
ffffffffc0201a80:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201a82:	d469                	beqz	s0,ffffffffc0201a4c <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201a84:	70e2                	ld	ra,56(sp)
ffffffffc0201a86:	8522                	mv	a0,s0
ffffffffc0201a88:	7442                	ld	s0,48(sp)
ffffffffc0201a8a:	74a2                	ld	s1,40(sp)
ffffffffc0201a8c:	7902                	ld	s2,32(sp)
ffffffffc0201a8e:	69e2                	ld	s3,24(sp)
ffffffffc0201a90:	6a42                	ld	s4,16(sp)
ffffffffc0201a92:	6aa2                	ld	s5,8(sp)
ffffffffc0201a94:	6b02                	ld	s6,0(sp)
ffffffffc0201a96:	6121                	addi	sp,sp,64
ffffffffc0201a98:	8082                	ret

ffffffffc0201a9a <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a9a:	100027f3          	csrr	a5,sstatus
ffffffffc0201a9e:	8b89                	andi	a5,a5,2
ffffffffc0201aa0:	e799                	bnez	a5,ffffffffc0201aae <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201aa2:	00014797          	auipc	a5,0x14
ffffffffc0201aa6:	ace7b783          	ld	a5,-1330(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0201aaa:	739c                	ld	a5,32(a5)
ffffffffc0201aac:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201aae:	1101                	addi	sp,sp,-32
ffffffffc0201ab0:	ec06                	sd	ra,24(sp)
ffffffffc0201ab2:	e822                	sd	s0,16(sp)
ffffffffc0201ab4:	e426                	sd	s1,8(sp)
ffffffffc0201ab6:	842a                	mv	s0,a0
ffffffffc0201ab8:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201aba:	ae5fe0ef          	jal	ra,ffffffffc020059e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201abe:	00014797          	auipc	a5,0x14
ffffffffc0201ac2:	ab27b783          	ld	a5,-1358(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0201ac6:	739c                	ld	a5,32(a5)
ffffffffc0201ac8:	85a6                	mv	a1,s1
ffffffffc0201aca:	8522                	mv	a0,s0
ffffffffc0201acc:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201ace:	6442                	ld	s0,16(sp)
ffffffffc0201ad0:	60e2                	ld	ra,24(sp)
ffffffffc0201ad2:	64a2                	ld	s1,8(sp)
ffffffffc0201ad4:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201ad6:	ac3fe06f          	j	ffffffffc0200598 <intr_enable>

ffffffffc0201ada <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ada:	100027f3          	csrr	a5,sstatus
ffffffffc0201ade:	8b89                	andi	a5,a5,2
ffffffffc0201ae0:	e799                	bnez	a5,ffffffffc0201aee <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201ae2:	00014797          	auipc	a5,0x14
ffffffffc0201ae6:	a8e7b783          	ld	a5,-1394(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0201aea:	779c                	ld	a5,40(a5)
ffffffffc0201aec:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201aee:	1141                	addi	sp,sp,-16
ffffffffc0201af0:	e406                	sd	ra,8(sp)
ffffffffc0201af2:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201af4:	aabfe0ef          	jal	ra,ffffffffc020059e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201af8:	00014797          	auipc	a5,0x14
ffffffffc0201afc:	a787b783          	ld	a5,-1416(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0201b00:	779c                	ld	a5,40(a5)
ffffffffc0201b02:	9782                	jalr	a5
ffffffffc0201b04:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201b06:	a93fe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201b0a:	60a2                	ld	ra,8(sp)
ffffffffc0201b0c:	8522                	mv	a0,s0
ffffffffc0201b0e:	6402                	ld	s0,0(sp)
ffffffffc0201b10:	0141                	addi	sp,sp,16
ffffffffc0201b12:	8082                	ret

ffffffffc0201b14 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201b14:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201b18:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201b1c:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201b1e:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201b20:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201b22:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201b26:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201b28:	f04a                	sd	s2,32(sp)
ffffffffc0201b2a:	ec4e                	sd	s3,24(sp)
ffffffffc0201b2c:	e852                	sd	s4,16(sp)
ffffffffc0201b2e:	fc06                	sd	ra,56(sp)
ffffffffc0201b30:	f822                	sd	s0,48(sp)
ffffffffc0201b32:	e456                	sd	s5,8(sp)
ffffffffc0201b34:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201b36:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201b3a:	892e                	mv	s2,a1
ffffffffc0201b3c:	89b2                	mv	s3,a2
ffffffffc0201b3e:	00014a17          	auipc	s4,0x14
ffffffffc0201b42:	a22a0a13          	addi	s4,s4,-1502 # ffffffffc0215560 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201b46:	e7b5                	bnez	a5,ffffffffc0201bb2 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201b48:	12060b63          	beqz	a2,ffffffffc0201c7e <get_pte+0x16a>
ffffffffc0201b4c:	4505                	li	a0,1
ffffffffc0201b4e:	ebbff0ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0201b52:	842a                	mv	s0,a0
ffffffffc0201b54:	12050563          	beqz	a0,ffffffffc0201c7e <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201b58:	00014b17          	auipc	s6,0x14
ffffffffc0201b5c:	a10b0b13          	addi	s6,s6,-1520 # ffffffffc0215568 <pages>
ffffffffc0201b60:	000b3503          	ld	a0,0(s6)
ffffffffc0201b64:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201b68:	00014a17          	auipc	s4,0x14
ffffffffc0201b6c:	9f8a0a13          	addi	s4,s4,-1544 # ffffffffc0215560 <npage>
ffffffffc0201b70:	40a40533          	sub	a0,s0,a0
ffffffffc0201b74:	8519                	srai	a0,a0,0x6
ffffffffc0201b76:	9556                	add	a0,a0,s5
ffffffffc0201b78:	000a3703          	ld	a4,0(s4)
ffffffffc0201b7c:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201b80:	4685                	li	a3,1
ffffffffc0201b82:	c014                	sw	a3,0(s0)
ffffffffc0201b84:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201b86:	0532                	slli	a0,a0,0xc
ffffffffc0201b88:	14e7f263          	bgeu	a5,a4,ffffffffc0201ccc <get_pte+0x1b8>
ffffffffc0201b8c:	00014797          	auipc	a5,0x14
ffffffffc0201b90:	9ec7b783          	ld	a5,-1556(a5) # ffffffffc0215578 <va_pa_offset>
ffffffffc0201b94:	6605                	lui	a2,0x1
ffffffffc0201b96:	4581                	li	a1,0
ffffffffc0201b98:	953e                	add	a0,a0,a5
ffffffffc0201b9a:	5a1020ef          	jal	ra,ffffffffc020493a <memset>
    return page - pages + nbase;
ffffffffc0201b9e:	000b3683          	ld	a3,0(s6)
ffffffffc0201ba2:	40d406b3          	sub	a3,s0,a3
ffffffffc0201ba6:	8699                	srai	a3,a3,0x6
ffffffffc0201ba8:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201baa:	06aa                	slli	a3,a3,0xa
ffffffffc0201bac:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201bb0:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201bb2:	77fd                	lui	a5,0xfffff
ffffffffc0201bb4:	068a                	slli	a3,a3,0x2
ffffffffc0201bb6:	000a3703          	ld	a4,0(s4)
ffffffffc0201bba:	8efd                	and	a3,a3,a5
ffffffffc0201bbc:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201bc0:	0ce7f163          	bgeu	a5,a4,ffffffffc0201c82 <get_pte+0x16e>
ffffffffc0201bc4:	00014a97          	auipc	s5,0x14
ffffffffc0201bc8:	9b4a8a93          	addi	s5,s5,-1612 # ffffffffc0215578 <va_pa_offset>
ffffffffc0201bcc:	000ab403          	ld	s0,0(s5)
ffffffffc0201bd0:	01595793          	srli	a5,s2,0x15
ffffffffc0201bd4:	1ff7f793          	andi	a5,a5,511
ffffffffc0201bd8:	96a2                	add	a3,a3,s0
ffffffffc0201bda:	00379413          	slli	s0,a5,0x3
ffffffffc0201bde:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201be0:	6014                	ld	a3,0(s0)
ffffffffc0201be2:	0016f793          	andi	a5,a3,1
ffffffffc0201be6:	e3ad                	bnez	a5,ffffffffc0201c48 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201be8:	08098b63          	beqz	s3,ffffffffc0201c7e <get_pte+0x16a>
ffffffffc0201bec:	4505                	li	a0,1
ffffffffc0201bee:	e1bff0ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0201bf2:	84aa                	mv	s1,a0
ffffffffc0201bf4:	c549                	beqz	a0,ffffffffc0201c7e <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201bf6:	00014b17          	auipc	s6,0x14
ffffffffc0201bfa:	972b0b13          	addi	s6,s6,-1678 # ffffffffc0215568 <pages>
ffffffffc0201bfe:	000b3503          	ld	a0,0(s6)
ffffffffc0201c02:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201c06:	000a3703          	ld	a4,0(s4)
ffffffffc0201c0a:	40a48533          	sub	a0,s1,a0
ffffffffc0201c0e:	8519                	srai	a0,a0,0x6
ffffffffc0201c10:	954e                	add	a0,a0,s3
ffffffffc0201c12:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201c16:	4685                	li	a3,1
ffffffffc0201c18:	c094                	sw	a3,0(s1)
ffffffffc0201c1a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c1c:	0532                	slli	a0,a0,0xc
ffffffffc0201c1e:	08e7fa63          	bgeu	a5,a4,ffffffffc0201cb2 <get_pte+0x19e>
ffffffffc0201c22:	000ab783          	ld	a5,0(s5)
ffffffffc0201c26:	6605                	lui	a2,0x1
ffffffffc0201c28:	4581                	li	a1,0
ffffffffc0201c2a:	953e                	add	a0,a0,a5
ffffffffc0201c2c:	50f020ef          	jal	ra,ffffffffc020493a <memset>
    return page - pages + nbase;
ffffffffc0201c30:	000b3683          	ld	a3,0(s6)
ffffffffc0201c34:	40d486b3          	sub	a3,s1,a3
ffffffffc0201c38:	8699                	srai	a3,a3,0x6
ffffffffc0201c3a:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201c3c:	06aa                	slli	a3,a3,0xa
ffffffffc0201c3e:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201c42:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201c44:	000a3703          	ld	a4,0(s4)
ffffffffc0201c48:	068a                	slli	a3,a3,0x2
ffffffffc0201c4a:	757d                	lui	a0,0xfffff
ffffffffc0201c4c:	8ee9                	and	a3,a3,a0
ffffffffc0201c4e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201c52:	04e7f463          	bgeu	a5,a4,ffffffffc0201c9a <get_pte+0x186>
ffffffffc0201c56:	000ab503          	ld	a0,0(s5)
ffffffffc0201c5a:	00c95913          	srli	s2,s2,0xc
ffffffffc0201c5e:	1ff97913          	andi	s2,s2,511
ffffffffc0201c62:	96aa                	add	a3,a3,a0
ffffffffc0201c64:	00391513          	slli	a0,s2,0x3
ffffffffc0201c68:	9536                	add	a0,a0,a3
}
ffffffffc0201c6a:	70e2                	ld	ra,56(sp)
ffffffffc0201c6c:	7442                	ld	s0,48(sp)
ffffffffc0201c6e:	74a2                	ld	s1,40(sp)
ffffffffc0201c70:	7902                	ld	s2,32(sp)
ffffffffc0201c72:	69e2                	ld	s3,24(sp)
ffffffffc0201c74:	6a42                	ld	s4,16(sp)
ffffffffc0201c76:	6aa2                	ld	s5,8(sp)
ffffffffc0201c78:	6b02                	ld	s6,0(sp)
ffffffffc0201c7a:	6121                	addi	sp,sp,64
ffffffffc0201c7c:	8082                	ret
            return NULL;
ffffffffc0201c7e:	4501                	li	a0,0
ffffffffc0201c80:	b7ed                	j	ffffffffc0201c6a <get_pte+0x156>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201c82:	00004617          	auipc	a2,0x4
ffffffffc0201c86:	a8e60613          	addi	a2,a2,-1394 # ffffffffc0205710 <default_pmm_manager+0x38>
ffffffffc0201c8a:	0e400593          	li	a1,228
ffffffffc0201c8e:	00004517          	auipc	a0,0x4
ffffffffc0201c92:	b9a50513          	addi	a0,a0,-1126 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0201c96:	fb0fe0ef          	jal	ra,ffffffffc0200446 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201c9a:	00004617          	auipc	a2,0x4
ffffffffc0201c9e:	a7660613          	addi	a2,a2,-1418 # ffffffffc0205710 <default_pmm_manager+0x38>
ffffffffc0201ca2:	0ef00593          	li	a1,239
ffffffffc0201ca6:	00004517          	auipc	a0,0x4
ffffffffc0201caa:	b8250513          	addi	a0,a0,-1150 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0201cae:	f98fe0ef          	jal	ra,ffffffffc0200446 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201cb2:	86aa                	mv	a3,a0
ffffffffc0201cb4:	00004617          	auipc	a2,0x4
ffffffffc0201cb8:	a5c60613          	addi	a2,a2,-1444 # ffffffffc0205710 <default_pmm_manager+0x38>
ffffffffc0201cbc:	0ec00593          	li	a1,236
ffffffffc0201cc0:	00004517          	auipc	a0,0x4
ffffffffc0201cc4:	b6850513          	addi	a0,a0,-1176 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0201cc8:	f7efe0ef          	jal	ra,ffffffffc0200446 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201ccc:	86aa                	mv	a3,a0
ffffffffc0201cce:	00004617          	auipc	a2,0x4
ffffffffc0201cd2:	a4260613          	addi	a2,a2,-1470 # ffffffffc0205710 <default_pmm_manager+0x38>
ffffffffc0201cd6:	0e100593          	li	a1,225
ffffffffc0201cda:	00004517          	auipc	a0,0x4
ffffffffc0201cde:	b4e50513          	addi	a0,a0,-1202 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0201ce2:	f64fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201ce6 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201ce6:	1141                	addi	sp,sp,-16
ffffffffc0201ce8:	e022                	sd	s0,0(sp)
ffffffffc0201cea:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201cec:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201cee:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201cf0:	e25ff0ef          	jal	ra,ffffffffc0201b14 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201cf4:	c011                	beqz	s0,ffffffffc0201cf8 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201cf6:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201cf8:	c511                	beqz	a0,ffffffffc0201d04 <get_page+0x1e>
ffffffffc0201cfa:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201cfc:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201cfe:	0017f713          	andi	a4,a5,1
ffffffffc0201d02:	e709                	bnez	a4,ffffffffc0201d0c <get_page+0x26>
}
ffffffffc0201d04:	60a2                	ld	ra,8(sp)
ffffffffc0201d06:	6402                	ld	s0,0(sp)
ffffffffc0201d08:	0141                	addi	sp,sp,16
ffffffffc0201d0a:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201d0c:	078a                	slli	a5,a5,0x2
ffffffffc0201d0e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d10:	00014717          	auipc	a4,0x14
ffffffffc0201d14:	85073703          	ld	a4,-1968(a4) # ffffffffc0215560 <npage>
ffffffffc0201d18:	00e7ff63          	bgeu	a5,a4,ffffffffc0201d36 <get_page+0x50>
ffffffffc0201d1c:	60a2                	ld	ra,8(sp)
ffffffffc0201d1e:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0201d20:	fff80537          	lui	a0,0xfff80
ffffffffc0201d24:	97aa                	add	a5,a5,a0
ffffffffc0201d26:	079a                	slli	a5,a5,0x6
ffffffffc0201d28:	00014517          	auipc	a0,0x14
ffffffffc0201d2c:	84053503          	ld	a0,-1984(a0) # ffffffffc0215568 <pages>
ffffffffc0201d30:	953e                	add	a0,a0,a5
ffffffffc0201d32:	0141                	addi	sp,sp,16
ffffffffc0201d34:	8082                	ret
ffffffffc0201d36:	c9bff0ef          	jal	ra,ffffffffc02019d0 <pa2page.part.0>

ffffffffc0201d3a <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201d3a:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201d3c:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201d3e:	ec26                	sd	s1,24(sp)
ffffffffc0201d40:	f406                	sd	ra,40(sp)
ffffffffc0201d42:	f022                	sd	s0,32(sp)
ffffffffc0201d44:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201d46:	dcfff0ef          	jal	ra,ffffffffc0201b14 <get_pte>
    if (ptep != NULL) {
ffffffffc0201d4a:	c511                	beqz	a0,ffffffffc0201d56 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201d4c:	611c                	ld	a5,0(a0)
ffffffffc0201d4e:	842a                	mv	s0,a0
ffffffffc0201d50:	0017f713          	andi	a4,a5,1
ffffffffc0201d54:	e711                	bnez	a4,ffffffffc0201d60 <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201d56:	70a2                	ld	ra,40(sp)
ffffffffc0201d58:	7402                	ld	s0,32(sp)
ffffffffc0201d5a:	64e2                	ld	s1,24(sp)
ffffffffc0201d5c:	6145                	addi	sp,sp,48
ffffffffc0201d5e:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201d60:	078a                	slli	a5,a5,0x2
ffffffffc0201d62:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d64:	00013717          	auipc	a4,0x13
ffffffffc0201d68:	7fc73703          	ld	a4,2044(a4) # ffffffffc0215560 <npage>
ffffffffc0201d6c:	06e7f363          	bgeu	a5,a4,ffffffffc0201dd2 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d70:	fff80537          	lui	a0,0xfff80
ffffffffc0201d74:	97aa                	add	a5,a5,a0
ffffffffc0201d76:	079a                	slli	a5,a5,0x6
ffffffffc0201d78:	00013517          	auipc	a0,0x13
ffffffffc0201d7c:	7f053503          	ld	a0,2032(a0) # ffffffffc0215568 <pages>
ffffffffc0201d80:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201d82:	411c                	lw	a5,0(a0)
ffffffffc0201d84:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201d88:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201d8a:	cb11                	beqz	a4,ffffffffc0201d9e <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201d8c:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201d90:	12048073          	sfence.vma	s1
}
ffffffffc0201d94:	70a2                	ld	ra,40(sp)
ffffffffc0201d96:	7402                	ld	s0,32(sp)
ffffffffc0201d98:	64e2                	ld	s1,24(sp)
ffffffffc0201d9a:	6145                	addi	sp,sp,48
ffffffffc0201d9c:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d9e:	100027f3          	csrr	a5,sstatus
ffffffffc0201da2:	8b89                	andi	a5,a5,2
ffffffffc0201da4:	eb89                	bnez	a5,ffffffffc0201db6 <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0201da6:	00013797          	auipc	a5,0x13
ffffffffc0201daa:	7ca7b783          	ld	a5,1994(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0201dae:	739c                	ld	a5,32(a5)
ffffffffc0201db0:	4585                	li	a1,1
ffffffffc0201db2:	9782                	jalr	a5
    if (flag) {
ffffffffc0201db4:	bfe1                	j	ffffffffc0201d8c <page_remove+0x52>
        intr_disable();
ffffffffc0201db6:	e42a                	sd	a0,8(sp)
ffffffffc0201db8:	fe6fe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc0201dbc:	00013797          	auipc	a5,0x13
ffffffffc0201dc0:	7b47b783          	ld	a5,1972(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0201dc4:	739c                	ld	a5,32(a5)
ffffffffc0201dc6:	6522                	ld	a0,8(sp)
ffffffffc0201dc8:	4585                	li	a1,1
ffffffffc0201dca:	9782                	jalr	a5
        intr_enable();
ffffffffc0201dcc:	fccfe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc0201dd0:	bf75                	j	ffffffffc0201d8c <page_remove+0x52>
ffffffffc0201dd2:	bffff0ef          	jal	ra,ffffffffc02019d0 <pa2page.part.0>

ffffffffc0201dd6 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201dd6:	7139                	addi	sp,sp,-64
ffffffffc0201dd8:	e852                	sd	s4,16(sp)
ffffffffc0201dda:	8a32                	mv	s4,a2
ffffffffc0201ddc:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201dde:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201de0:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201de2:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201de4:	f426                	sd	s1,40(sp)
ffffffffc0201de6:	fc06                	sd	ra,56(sp)
ffffffffc0201de8:	f04a                	sd	s2,32(sp)
ffffffffc0201dea:	ec4e                	sd	s3,24(sp)
ffffffffc0201dec:	e456                	sd	s5,8(sp)
ffffffffc0201dee:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201df0:	d25ff0ef          	jal	ra,ffffffffc0201b14 <get_pte>
    if (ptep == NULL) {
ffffffffc0201df4:	c961                	beqz	a0,ffffffffc0201ec4 <page_insert+0xee>
    page->ref += 1;
ffffffffc0201df6:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0201df8:	611c                	ld	a5,0(a0)
ffffffffc0201dfa:	89aa                	mv	s3,a0
ffffffffc0201dfc:	0016871b          	addiw	a4,a3,1
ffffffffc0201e00:	c018                	sw	a4,0(s0)
ffffffffc0201e02:	0017f713          	andi	a4,a5,1
ffffffffc0201e06:	ef05                	bnez	a4,ffffffffc0201e3e <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0201e08:	00013717          	auipc	a4,0x13
ffffffffc0201e0c:	76073703          	ld	a4,1888(a4) # ffffffffc0215568 <pages>
ffffffffc0201e10:	8c19                	sub	s0,s0,a4
ffffffffc0201e12:	000807b7          	lui	a5,0x80
ffffffffc0201e16:	8419                	srai	s0,s0,0x6
ffffffffc0201e18:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201e1a:	042a                	slli	s0,s0,0xa
ffffffffc0201e1c:	8cc1                	or	s1,s1,s0
ffffffffc0201e1e:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201e22:	0099b023          	sd	s1,0(s3) # 80000 <kern_entry-0xffffffffc0180000>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201e26:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0201e2a:	4501                	li	a0,0
}
ffffffffc0201e2c:	70e2                	ld	ra,56(sp)
ffffffffc0201e2e:	7442                	ld	s0,48(sp)
ffffffffc0201e30:	74a2                	ld	s1,40(sp)
ffffffffc0201e32:	7902                	ld	s2,32(sp)
ffffffffc0201e34:	69e2                	ld	s3,24(sp)
ffffffffc0201e36:	6a42                	ld	s4,16(sp)
ffffffffc0201e38:	6aa2                	ld	s5,8(sp)
ffffffffc0201e3a:	6121                	addi	sp,sp,64
ffffffffc0201e3c:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201e3e:	078a                	slli	a5,a5,0x2
ffffffffc0201e40:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e42:	00013717          	auipc	a4,0x13
ffffffffc0201e46:	71e73703          	ld	a4,1822(a4) # ffffffffc0215560 <npage>
ffffffffc0201e4a:	06e7ff63          	bgeu	a5,a4,ffffffffc0201ec8 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e4e:	00013a97          	auipc	s5,0x13
ffffffffc0201e52:	71aa8a93          	addi	s5,s5,1818 # ffffffffc0215568 <pages>
ffffffffc0201e56:	000ab703          	ld	a4,0(s5)
ffffffffc0201e5a:	fff80937          	lui	s2,0xfff80
ffffffffc0201e5e:	993e                	add	s2,s2,a5
ffffffffc0201e60:	091a                	slli	s2,s2,0x6
ffffffffc0201e62:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc0201e64:	01240c63          	beq	s0,s2,ffffffffc0201e7c <page_insert+0xa6>
    page->ref -= 1;
ffffffffc0201e68:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fd6aa3c>
ffffffffc0201e6c:	fff7869b          	addiw	a3,a5,-1
ffffffffc0201e70:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0201e74:	c691                	beqz	a3,ffffffffc0201e80 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201e76:	120a0073          	sfence.vma	s4
}
ffffffffc0201e7a:	bf59                	j	ffffffffc0201e10 <page_insert+0x3a>
ffffffffc0201e7c:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201e7e:	bf49                	j	ffffffffc0201e10 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e80:	100027f3          	csrr	a5,sstatus
ffffffffc0201e84:	8b89                	andi	a5,a5,2
ffffffffc0201e86:	ef91                	bnez	a5,ffffffffc0201ea2 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc0201e88:	00013797          	auipc	a5,0x13
ffffffffc0201e8c:	6e87b783          	ld	a5,1768(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0201e90:	739c                	ld	a5,32(a5)
ffffffffc0201e92:	4585                	li	a1,1
ffffffffc0201e94:	854a                	mv	a0,s2
ffffffffc0201e96:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0201e98:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201e9c:	120a0073          	sfence.vma	s4
ffffffffc0201ea0:	bf85                	j	ffffffffc0201e10 <page_insert+0x3a>
        intr_disable();
ffffffffc0201ea2:	efcfe0ef          	jal	ra,ffffffffc020059e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201ea6:	00013797          	auipc	a5,0x13
ffffffffc0201eaa:	6ca7b783          	ld	a5,1738(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0201eae:	739c                	ld	a5,32(a5)
ffffffffc0201eb0:	4585                	li	a1,1
ffffffffc0201eb2:	854a                	mv	a0,s2
ffffffffc0201eb4:	9782                	jalr	a5
        intr_enable();
ffffffffc0201eb6:	ee2fe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc0201eba:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201ebe:	120a0073          	sfence.vma	s4
ffffffffc0201ec2:	b7b9                	j	ffffffffc0201e10 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0201ec4:	5571                	li	a0,-4
ffffffffc0201ec6:	b79d                	j	ffffffffc0201e2c <page_insert+0x56>
ffffffffc0201ec8:	b09ff0ef          	jal	ra,ffffffffc02019d0 <pa2page.part.0>

ffffffffc0201ecc <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201ecc:	00004797          	auipc	a5,0x4
ffffffffc0201ed0:	80c78793          	addi	a5,a5,-2036 # ffffffffc02056d8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201ed4:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201ed6:	711d                	addi	sp,sp,-96
ffffffffc0201ed8:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201eda:	00004517          	auipc	a0,0x4
ffffffffc0201ede:	95e50513          	addi	a0,a0,-1698 # ffffffffc0205838 <default_pmm_manager+0x160>
    pmm_manager = &default_pmm_manager;
ffffffffc0201ee2:	00013b97          	auipc	s7,0x13
ffffffffc0201ee6:	68eb8b93          	addi	s7,s7,1678 # ffffffffc0215570 <pmm_manager>
void pmm_init(void) {
ffffffffc0201eea:	ec86                	sd	ra,88(sp)
ffffffffc0201eec:	e4a6                	sd	s1,72(sp)
ffffffffc0201eee:	fc4e                	sd	s3,56(sp)
ffffffffc0201ef0:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201ef2:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0201ef6:	e8a2                	sd	s0,80(sp)
ffffffffc0201ef8:	e0ca                	sd	s2,64(sp)
ffffffffc0201efa:	f852                	sd	s4,48(sp)
ffffffffc0201efc:	f456                	sd	s5,40(sp)
ffffffffc0201efe:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201f00:	a80fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    pmm_manager->init();
ffffffffc0201f04:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201f08:	00013997          	auipc	s3,0x13
ffffffffc0201f0c:	67098993          	addi	s3,s3,1648 # ffffffffc0215578 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0201f10:	00013497          	auipc	s1,0x13
ffffffffc0201f14:	65048493          	addi	s1,s1,1616 # ffffffffc0215560 <npage>
    pmm_manager->init();
ffffffffc0201f18:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201f1a:	00013b17          	auipc	s6,0x13
ffffffffc0201f1e:	64eb0b13          	addi	s6,s6,1614 # ffffffffc0215568 <pages>
    pmm_manager->init();
ffffffffc0201f22:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201f24:	57f5                	li	a5,-3
ffffffffc0201f26:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201f28:	00004517          	auipc	a0,0x4
ffffffffc0201f2c:	92850513          	addi	a0,a0,-1752 # ffffffffc0205850 <default_pmm_manager+0x178>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201f30:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc0201f34:	a4cfe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201f38:	46c5                	li	a3,17
ffffffffc0201f3a:	06ee                	slli	a3,a3,0x1b
ffffffffc0201f3c:	40100613          	li	a2,1025
ffffffffc0201f40:	07e005b7          	lui	a1,0x7e00
ffffffffc0201f44:	16fd                	addi	a3,a3,-1
ffffffffc0201f46:	0656                	slli	a2,a2,0x15
ffffffffc0201f48:	00004517          	auipc	a0,0x4
ffffffffc0201f4c:	92050513          	addi	a0,a0,-1760 # ffffffffc0205868 <default_pmm_manager+0x190>
ffffffffc0201f50:	a30fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201f54:	777d                	lui	a4,0xfffff
ffffffffc0201f56:	00014797          	auipc	a5,0x14
ffffffffc0201f5a:	66d78793          	addi	a5,a5,1645 # ffffffffc02165c3 <end+0xfff>
ffffffffc0201f5e:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201f60:	00088737          	lui	a4,0x88
ffffffffc0201f64:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201f66:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201f6a:	4701                	li	a4,0
ffffffffc0201f6c:	4585                	li	a1,1
ffffffffc0201f6e:	fff80837          	lui	a6,0xfff80
ffffffffc0201f72:	a019                	j	ffffffffc0201f78 <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc0201f74:	000b3783          	ld	a5,0(s6)
ffffffffc0201f78:	00671693          	slli	a3,a4,0x6
ffffffffc0201f7c:	97b6                	add	a5,a5,a3
ffffffffc0201f7e:	07a1                	addi	a5,a5,8
ffffffffc0201f80:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201f84:	6090                	ld	a2,0(s1)
ffffffffc0201f86:	0705                	addi	a4,a4,1
ffffffffc0201f88:	010607b3          	add	a5,a2,a6
ffffffffc0201f8c:	fef764e3          	bltu	a4,a5,ffffffffc0201f74 <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201f90:	000b3503          	ld	a0,0(s6)
ffffffffc0201f94:	079a                	slli	a5,a5,0x6
ffffffffc0201f96:	c0200737          	lui	a4,0xc0200
ffffffffc0201f9a:	00f506b3          	add	a3,a0,a5
ffffffffc0201f9e:	60e6e563          	bltu	a3,a4,ffffffffc02025a8 <pmm_init+0x6dc>
ffffffffc0201fa2:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0201fa6:	4745                	li	a4,17
ffffffffc0201fa8:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201faa:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0201fac:	4ae6e563          	bltu	a3,a4,ffffffffc0202456 <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0201fb0:	00004517          	auipc	a0,0x4
ffffffffc0201fb4:	8e050513          	addi	a0,a0,-1824 # ffffffffc0205890 <default_pmm_manager+0x1b8>
ffffffffc0201fb8:	9c8fe0ef          	jal	ra,ffffffffc0200180 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201fbc:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201fc0:	00013917          	auipc	s2,0x13
ffffffffc0201fc4:	59890913          	addi	s2,s2,1432 # ffffffffc0215558 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201fc8:	7b9c                	ld	a5,48(a5)
ffffffffc0201fca:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201fcc:	00004517          	auipc	a0,0x4
ffffffffc0201fd0:	8dc50513          	addi	a0,a0,-1828 # ffffffffc02058a8 <default_pmm_manager+0x1d0>
ffffffffc0201fd4:	9acfe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201fd8:	00007697          	auipc	a3,0x7
ffffffffc0201fdc:	02868693          	addi	a3,a3,40 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201fe0:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201fe4:	c02007b7          	lui	a5,0xc0200
ffffffffc0201fe8:	5cf6ec63          	bltu	a3,a5,ffffffffc02025c0 <pmm_init+0x6f4>
ffffffffc0201fec:	0009b783          	ld	a5,0(s3)
ffffffffc0201ff0:	8e9d                	sub	a3,a3,a5
ffffffffc0201ff2:	00013797          	auipc	a5,0x13
ffffffffc0201ff6:	54d7bf23          	sd	a3,1374(a5) # ffffffffc0215550 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ffa:	100027f3          	csrr	a5,sstatus
ffffffffc0201ffe:	8b89                	andi	a5,a5,2
ffffffffc0202000:	48079263          	bnez	a5,ffffffffc0202484 <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202004:	000bb783          	ld	a5,0(s7)
ffffffffc0202008:	779c                	ld	a5,40(a5)
ffffffffc020200a:	9782                	jalr	a5
ffffffffc020200c:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020200e:	6098                	ld	a4,0(s1)
ffffffffc0202010:	c80007b7          	lui	a5,0xc8000
ffffffffc0202014:	83b1                	srli	a5,a5,0xc
ffffffffc0202016:	5ee7e163          	bltu	a5,a4,ffffffffc02025f8 <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020201a:	00093503          	ld	a0,0(s2)
ffffffffc020201e:	5a050d63          	beqz	a0,ffffffffc02025d8 <pmm_init+0x70c>
ffffffffc0202022:	03451793          	slli	a5,a0,0x34
ffffffffc0202026:	5a079963          	bnez	a5,ffffffffc02025d8 <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020202a:	4601                	li	a2,0
ffffffffc020202c:	4581                	li	a1,0
ffffffffc020202e:	cb9ff0ef          	jal	ra,ffffffffc0201ce6 <get_page>
ffffffffc0202032:	62051563          	bnez	a0,ffffffffc020265c <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0202036:	4505                	li	a0,1
ffffffffc0202038:	9d1ff0ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc020203c:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020203e:	00093503          	ld	a0,0(s2)
ffffffffc0202042:	4681                	li	a3,0
ffffffffc0202044:	4601                	li	a2,0
ffffffffc0202046:	85d2                	mv	a1,s4
ffffffffc0202048:	d8fff0ef          	jal	ra,ffffffffc0201dd6 <page_insert>
ffffffffc020204c:	5e051863          	bnez	a0,ffffffffc020263c <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202050:	00093503          	ld	a0,0(s2)
ffffffffc0202054:	4601                	li	a2,0
ffffffffc0202056:	4581                	li	a1,0
ffffffffc0202058:	abdff0ef          	jal	ra,ffffffffc0201b14 <get_pte>
ffffffffc020205c:	5c050063          	beqz	a0,ffffffffc020261c <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc0202060:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202062:	0017f713          	andi	a4,a5,1
ffffffffc0202066:	5a070963          	beqz	a4,ffffffffc0202618 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc020206a:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020206c:	078a                	slli	a5,a5,0x2
ffffffffc020206e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202070:	52e7fa63          	bgeu	a5,a4,ffffffffc02025a4 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202074:	000b3683          	ld	a3,0(s6)
ffffffffc0202078:	fff80637          	lui	a2,0xfff80
ffffffffc020207c:	97b2                	add	a5,a5,a2
ffffffffc020207e:	079a                	slli	a5,a5,0x6
ffffffffc0202080:	97b6                	add	a5,a5,a3
ffffffffc0202082:	10fa16e3          	bne	s4,a5,ffffffffc020298e <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc0202086:	000a2683          	lw	a3,0(s4)
ffffffffc020208a:	4785                	li	a5,1
ffffffffc020208c:	12f69de3          	bne	a3,a5,ffffffffc02029c6 <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202090:	00093503          	ld	a0,0(s2)
ffffffffc0202094:	77fd                	lui	a5,0xfffff
ffffffffc0202096:	6114                	ld	a3,0(a0)
ffffffffc0202098:	068a                	slli	a3,a3,0x2
ffffffffc020209a:	8efd                	and	a3,a3,a5
ffffffffc020209c:	00c6d613          	srli	a2,a3,0xc
ffffffffc02020a0:	10e677e3          	bgeu	a2,a4,ffffffffc02029ae <pmm_init+0xae2>
ffffffffc02020a4:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02020a8:	96e2                	add	a3,a3,s8
ffffffffc02020aa:	0006ba83          	ld	s5,0(a3)
ffffffffc02020ae:	0a8a                	slli	s5,s5,0x2
ffffffffc02020b0:	00fafab3          	and	s5,s5,a5
ffffffffc02020b4:	00cad793          	srli	a5,s5,0xc
ffffffffc02020b8:	62e7f263          	bgeu	a5,a4,ffffffffc02026dc <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02020bc:	4601                	li	a2,0
ffffffffc02020be:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02020c0:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02020c2:	a53ff0ef          	jal	ra,ffffffffc0201b14 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02020c6:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02020c8:	5f551a63          	bne	a0,s5,ffffffffc02026bc <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc02020cc:	4505                	li	a0,1
ffffffffc02020ce:	93bff0ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc02020d2:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02020d4:	00093503          	ld	a0,0(s2)
ffffffffc02020d8:	46d1                	li	a3,20
ffffffffc02020da:	6605                	lui	a2,0x1
ffffffffc02020dc:	85d6                	mv	a1,s5
ffffffffc02020de:	cf9ff0ef          	jal	ra,ffffffffc0201dd6 <page_insert>
ffffffffc02020e2:	58051d63          	bnez	a0,ffffffffc020267c <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02020e6:	00093503          	ld	a0,0(s2)
ffffffffc02020ea:	4601                	li	a2,0
ffffffffc02020ec:	6585                	lui	a1,0x1
ffffffffc02020ee:	a27ff0ef          	jal	ra,ffffffffc0201b14 <get_pte>
ffffffffc02020f2:	0e050ae3          	beqz	a0,ffffffffc02029e6 <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc02020f6:	611c                	ld	a5,0(a0)
ffffffffc02020f8:	0107f713          	andi	a4,a5,16
ffffffffc02020fc:	6e070d63          	beqz	a4,ffffffffc02027f6 <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc0202100:	8b91                	andi	a5,a5,4
ffffffffc0202102:	6a078a63          	beqz	a5,ffffffffc02027b6 <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202106:	00093503          	ld	a0,0(s2)
ffffffffc020210a:	611c                	ld	a5,0(a0)
ffffffffc020210c:	8bc1                	andi	a5,a5,16
ffffffffc020210e:	68078463          	beqz	a5,ffffffffc0202796 <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc0202112:	000aa703          	lw	a4,0(s5)
ffffffffc0202116:	4785                	li	a5,1
ffffffffc0202118:	58f71263          	bne	a4,a5,ffffffffc020269c <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020211c:	4681                	li	a3,0
ffffffffc020211e:	6605                	lui	a2,0x1
ffffffffc0202120:	85d2                	mv	a1,s4
ffffffffc0202122:	cb5ff0ef          	jal	ra,ffffffffc0201dd6 <page_insert>
ffffffffc0202126:	62051863          	bnez	a0,ffffffffc0202756 <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc020212a:	000a2703          	lw	a4,0(s4)
ffffffffc020212e:	4789                	li	a5,2
ffffffffc0202130:	60f71363          	bne	a4,a5,ffffffffc0202736 <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc0202134:	000aa783          	lw	a5,0(s5)
ffffffffc0202138:	5c079f63          	bnez	a5,ffffffffc0202716 <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020213c:	00093503          	ld	a0,0(s2)
ffffffffc0202140:	4601                	li	a2,0
ffffffffc0202142:	6585                	lui	a1,0x1
ffffffffc0202144:	9d1ff0ef          	jal	ra,ffffffffc0201b14 <get_pte>
ffffffffc0202148:	5a050763          	beqz	a0,ffffffffc02026f6 <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc020214c:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020214e:	00177793          	andi	a5,a4,1
ffffffffc0202152:	4c078363          	beqz	a5,ffffffffc0202618 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc0202156:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202158:	00271793          	slli	a5,a4,0x2
ffffffffc020215c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020215e:	44d7f363          	bgeu	a5,a3,ffffffffc02025a4 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202162:	000b3683          	ld	a3,0(s6)
ffffffffc0202166:	fff80637          	lui	a2,0xfff80
ffffffffc020216a:	97b2                	add	a5,a5,a2
ffffffffc020216c:	079a                	slli	a5,a5,0x6
ffffffffc020216e:	97b6                	add	a5,a5,a3
ffffffffc0202170:	6efa1363          	bne	s4,a5,ffffffffc0202856 <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202174:	8b41                	andi	a4,a4,16
ffffffffc0202176:	6c071063          	bnez	a4,ffffffffc0202836 <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc020217a:	00093503          	ld	a0,0(s2)
ffffffffc020217e:	4581                	li	a1,0
ffffffffc0202180:	bbbff0ef          	jal	ra,ffffffffc0201d3a <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202184:	000a2703          	lw	a4,0(s4)
ffffffffc0202188:	4785                	li	a5,1
ffffffffc020218a:	68f71663          	bne	a4,a5,ffffffffc0202816 <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc020218e:	000aa783          	lw	a5,0(s5)
ffffffffc0202192:	74079e63          	bnez	a5,ffffffffc02028ee <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0202196:	00093503          	ld	a0,0(s2)
ffffffffc020219a:	6585                	lui	a1,0x1
ffffffffc020219c:	b9fff0ef          	jal	ra,ffffffffc0201d3a <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02021a0:	000a2783          	lw	a5,0(s4)
ffffffffc02021a4:	72079563          	bnez	a5,ffffffffc02028ce <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc02021a8:	000aa783          	lw	a5,0(s5)
ffffffffc02021ac:	70079163          	bnez	a5,ffffffffc02028ae <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02021b0:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02021b4:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02021b6:	000a3683          	ld	a3,0(s4)
ffffffffc02021ba:	068a                	slli	a3,a3,0x2
ffffffffc02021bc:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02021be:	3ee6f363          	bgeu	a3,a4,ffffffffc02025a4 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02021c2:	fff807b7          	lui	a5,0xfff80
ffffffffc02021c6:	000b3503          	ld	a0,0(s6)
ffffffffc02021ca:	96be                	add	a3,a3,a5
ffffffffc02021cc:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc02021ce:	00d507b3          	add	a5,a0,a3
ffffffffc02021d2:	4390                	lw	a2,0(a5)
ffffffffc02021d4:	4785                	li	a5,1
ffffffffc02021d6:	6af61c63          	bne	a2,a5,ffffffffc020288e <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc02021da:	8699                	srai	a3,a3,0x6
ffffffffc02021dc:	000805b7          	lui	a1,0x80
ffffffffc02021e0:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc02021e2:	00c69613          	slli	a2,a3,0xc
ffffffffc02021e6:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02021e8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02021ea:	68e67663          	bgeu	a2,a4,ffffffffc0202876 <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02021ee:	0009b603          	ld	a2,0(s3)
ffffffffc02021f2:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc02021f4:	629c                	ld	a5,0(a3)
ffffffffc02021f6:	078a                	slli	a5,a5,0x2
ffffffffc02021f8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02021fa:	3ae7f563          	bgeu	a5,a4,ffffffffc02025a4 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02021fe:	8f8d                	sub	a5,a5,a1
ffffffffc0202200:	079a                	slli	a5,a5,0x6
ffffffffc0202202:	953e                	add	a0,a0,a5
ffffffffc0202204:	100027f3          	csrr	a5,sstatus
ffffffffc0202208:	8b89                	andi	a5,a5,2
ffffffffc020220a:	2c079763          	bnez	a5,ffffffffc02024d8 <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc020220e:	000bb783          	ld	a5,0(s7)
ffffffffc0202212:	4585                	li	a1,1
ffffffffc0202214:	739c                	ld	a5,32(a5)
ffffffffc0202216:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202218:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc020221c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020221e:	078a                	slli	a5,a5,0x2
ffffffffc0202220:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202222:	38e7f163          	bgeu	a5,a4,ffffffffc02025a4 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202226:	000b3503          	ld	a0,0(s6)
ffffffffc020222a:	fff80737          	lui	a4,0xfff80
ffffffffc020222e:	97ba                	add	a5,a5,a4
ffffffffc0202230:	079a                	slli	a5,a5,0x6
ffffffffc0202232:	953e                	add	a0,a0,a5
ffffffffc0202234:	100027f3          	csrr	a5,sstatus
ffffffffc0202238:	8b89                	andi	a5,a5,2
ffffffffc020223a:	28079363          	bnez	a5,ffffffffc02024c0 <pmm_init+0x5f4>
ffffffffc020223e:	000bb783          	ld	a5,0(s7)
ffffffffc0202242:	4585                	li	a1,1
ffffffffc0202244:	739c                	ld	a5,32(a5)
ffffffffc0202246:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202248:	00093783          	ld	a5,0(s2)
ffffffffc020224c:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fd6aa3c>
  asm volatile("sfence.vma");
ffffffffc0202250:	12000073          	sfence.vma
ffffffffc0202254:	100027f3          	csrr	a5,sstatus
ffffffffc0202258:	8b89                	andi	a5,a5,2
ffffffffc020225a:	24079963          	bnez	a5,ffffffffc02024ac <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc020225e:	000bb783          	ld	a5,0(s7)
ffffffffc0202262:	779c                	ld	a5,40(a5)
ffffffffc0202264:	9782                	jalr	a5
ffffffffc0202266:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202268:	71441363          	bne	s0,s4,ffffffffc020296e <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020226c:	00004517          	auipc	a0,0x4
ffffffffc0202270:	92450513          	addi	a0,a0,-1756 # ffffffffc0205b90 <default_pmm_manager+0x4b8>
ffffffffc0202274:	f0dfd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0202278:	100027f3          	csrr	a5,sstatus
ffffffffc020227c:	8b89                	andi	a5,a5,2
ffffffffc020227e:	20079d63          	bnez	a5,ffffffffc0202498 <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202282:	000bb783          	ld	a5,0(s7)
ffffffffc0202286:	779c                	ld	a5,40(a5)
ffffffffc0202288:	9782                	jalr	a5
ffffffffc020228a:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020228c:	6098                	ld	a4,0(s1)
ffffffffc020228e:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202292:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202294:	00c71793          	slli	a5,a4,0xc
ffffffffc0202298:	6a05                	lui	s4,0x1
ffffffffc020229a:	02f47c63          	bgeu	s0,a5,ffffffffc02022d2 <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020229e:	00c45793          	srli	a5,s0,0xc
ffffffffc02022a2:	00093503          	ld	a0,0(s2)
ffffffffc02022a6:	2ee7f263          	bgeu	a5,a4,ffffffffc020258a <pmm_init+0x6be>
ffffffffc02022aa:	0009b583          	ld	a1,0(s3)
ffffffffc02022ae:	4601                	li	a2,0
ffffffffc02022b0:	95a2                	add	a1,a1,s0
ffffffffc02022b2:	863ff0ef          	jal	ra,ffffffffc0201b14 <get_pte>
ffffffffc02022b6:	2a050a63          	beqz	a0,ffffffffc020256a <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02022ba:	611c                	ld	a5,0(a0)
ffffffffc02022bc:	078a                	slli	a5,a5,0x2
ffffffffc02022be:	0157f7b3          	and	a5,a5,s5
ffffffffc02022c2:	28879463          	bne	a5,s0,ffffffffc020254a <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02022c6:	6098                	ld	a4,0(s1)
ffffffffc02022c8:	9452                	add	s0,s0,s4
ffffffffc02022ca:	00c71793          	slli	a5,a4,0xc
ffffffffc02022ce:	fcf468e3          	bltu	s0,a5,ffffffffc020229e <pmm_init+0x3d2>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc02022d2:	00093783          	ld	a5,0(s2)
ffffffffc02022d6:	639c                	ld	a5,0(a5)
ffffffffc02022d8:	66079b63          	bnez	a5,ffffffffc020294e <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc02022dc:	4505                	li	a0,1
ffffffffc02022de:	f2aff0ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc02022e2:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02022e4:	00093503          	ld	a0,0(s2)
ffffffffc02022e8:	4699                	li	a3,6
ffffffffc02022ea:	10000613          	li	a2,256
ffffffffc02022ee:	85d6                	mv	a1,s5
ffffffffc02022f0:	ae7ff0ef          	jal	ra,ffffffffc0201dd6 <page_insert>
ffffffffc02022f4:	62051d63          	bnez	a0,ffffffffc020292e <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc02022f8:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fde9a3c>
ffffffffc02022fc:	4785                	li	a5,1
ffffffffc02022fe:	60f71863          	bne	a4,a5,ffffffffc020290e <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202302:	00093503          	ld	a0,0(s2)
ffffffffc0202306:	6405                	lui	s0,0x1
ffffffffc0202308:	4699                	li	a3,6
ffffffffc020230a:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc020230e:	85d6                	mv	a1,s5
ffffffffc0202310:	ac7ff0ef          	jal	ra,ffffffffc0201dd6 <page_insert>
ffffffffc0202314:	46051163          	bnez	a0,ffffffffc0202776 <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc0202318:	000aa703          	lw	a4,0(s5)
ffffffffc020231c:	4789                	li	a5,2
ffffffffc020231e:	72f71463          	bne	a4,a5,ffffffffc0202a46 <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202322:	00004597          	auipc	a1,0x4
ffffffffc0202326:	9a658593          	addi	a1,a1,-1626 # ffffffffc0205cc8 <default_pmm_manager+0x5f0>
ffffffffc020232a:	10000513          	li	a0,256
ffffffffc020232e:	5c6020ef          	jal	ra,ffffffffc02048f4 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202332:	10040593          	addi	a1,s0,256
ffffffffc0202336:	10000513          	li	a0,256
ffffffffc020233a:	5cc020ef          	jal	ra,ffffffffc0204906 <strcmp>
ffffffffc020233e:	6e051463          	bnez	a0,ffffffffc0202a26 <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc0202342:	000b3683          	ld	a3,0(s6)
ffffffffc0202346:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc020234a:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc020234c:	40da86b3          	sub	a3,s5,a3
ffffffffc0202350:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202352:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202354:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202356:	8031                	srli	s0,s0,0xc
ffffffffc0202358:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc020235c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020235e:	50f77c63          	bgeu	a4,a5,ffffffffc0202876 <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202362:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202366:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020236a:	96be                	add	a3,a3,a5
ffffffffc020236c:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202370:	54e020ef          	jal	ra,ffffffffc02048be <strlen>
ffffffffc0202374:	68051963          	bnez	a0,ffffffffc0202a06 <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202378:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020237c:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020237e:	000a3683          	ld	a3,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0202382:	068a                	slli	a3,a3,0x2
ffffffffc0202384:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202386:	20f6ff63          	bgeu	a3,a5,ffffffffc02025a4 <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc020238a:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020238c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020238e:	4ef47463          	bgeu	s0,a5,ffffffffc0202876 <pmm_init+0x9aa>
ffffffffc0202392:	0009b403          	ld	s0,0(s3)
ffffffffc0202396:	9436                	add	s0,s0,a3
ffffffffc0202398:	100027f3          	csrr	a5,sstatus
ffffffffc020239c:	8b89                	andi	a5,a5,2
ffffffffc020239e:	18079b63          	bnez	a5,ffffffffc0202534 <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc02023a2:	000bb783          	ld	a5,0(s7)
ffffffffc02023a6:	4585                	li	a1,1
ffffffffc02023a8:	8556                	mv	a0,s5
ffffffffc02023aa:	739c                	ld	a5,32(a5)
ffffffffc02023ac:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02023ae:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02023b0:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02023b2:	078a                	slli	a5,a5,0x2
ffffffffc02023b4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023b6:	1ee7f763          	bgeu	a5,a4,ffffffffc02025a4 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02023ba:	000b3503          	ld	a0,0(s6)
ffffffffc02023be:	fff80737          	lui	a4,0xfff80
ffffffffc02023c2:	97ba                	add	a5,a5,a4
ffffffffc02023c4:	079a                	slli	a5,a5,0x6
ffffffffc02023c6:	953e                	add	a0,a0,a5
ffffffffc02023c8:	100027f3          	csrr	a5,sstatus
ffffffffc02023cc:	8b89                	andi	a5,a5,2
ffffffffc02023ce:	14079763          	bnez	a5,ffffffffc020251c <pmm_init+0x650>
ffffffffc02023d2:	000bb783          	ld	a5,0(s7)
ffffffffc02023d6:	4585                	li	a1,1
ffffffffc02023d8:	739c                	ld	a5,32(a5)
ffffffffc02023da:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02023dc:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02023e0:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02023e2:	078a                	slli	a5,a5,0x2
ffffffffc02023e4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023e6:	1ae7ff63          	bgeu	a5,a4,ffffffffc02025a4 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02023ea:	000b3503          	ld	a0,0(s6)
ffffffffc02023ee:	fff80737          	lui	a4,0xfff80
ffffffffc02023f2:	97ba                	add	a5,a5,a4
ffffffffc02023f4:	079a                	slli	a5,a5,0x6
ffffffffc02023f6:	953e                	add	a0,a0,a5
ffffffffc02023f8:	100027f3          	csrr	a5,sstatus
ffffffffc02023fc:	8b89                	andi	a5,a5,2
ffffffffc02023fe:	10079363          	bnez	a5,ffffffffc0202504 <pmm_init+0x638>
ffffffffc0202402:	000bb783          	ld	a5,0(s7)
ffffffffc0202406:	4585                	li	a1,1
ffffffffc0202408:	739c                	ld	a5,32(a5)
ffffffffc020240a:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc020240c:	00093783          	ld	a5,0(s2)
ffffffffc0202410:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0202414:	12000073          	sfence.vma
ffffffffc0202418:	100027f3          	csrr	a5,sstatus
ffffffffc020241c:	8b89                	andi	a5,a5,2
ffffffffc020241e:	0c079963          	bnez	a5,ffffffffc02024f0 <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202422:	000bb783          	ld	a5,0(s7)
ffffffffc0202426:	779c                	ld	a5,40(a5)
ffffffffc0202428:	9782                	jalr	a5
ffffffffc020242a:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc020242c:	3a8c1563          	bne	s8,s0,ffffffffc02027d6 <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202430:	00004517          	auipc	a0,0x4
ffffffffc0202434:	91050513          	addi	a0,a0,-1776 # ffffffffc0205d40 <default_pmm_manager+0x668>
ffffffffc0202438:	d49fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc020243c:	6446                	ld	s0,80(sp)
ffffffffc020243e:	60e6                	ld	ra,88(sp)
ffffffffc0202440:	64a6                	ld	s1,72(sp)
ffffffffc0202442:	6906                	ld	s2,64(sp)
ffffffffc0202444:	79e2                	ld	s3,56(sp)
ffffffffc0202446:	7a42                	ld	s4,48(sp)
ffffffffc0202448:	7aa2                	ld	s5,40(sp)
ffffffffc020244a:	7b02                	ld	s6,32(sp)
ffffffffc020244c:	6be2                	ld	s7,24(sp)
ffffffffc020244e:	6c42                	ld	s8,16(sp)
ffffffffc0202450:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc0202452:	bb8ff06f          	j	ffffffffc020180a <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202456:	6785                	lui	a5,0x1
ffffffffc0202458:	17fd                	addi	a5,a5,-1
ffffffffc020245a:	96be                	add	a3,a3,a5
ffffffffc020245c:	77fd                	lui	a5,0xfffff
ffffffffc020245e:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc0202460:	00c7d693          	srli	a3,a5,0xc
ffffffffc0202464:	14c6f063          	bgeu	a3,a2,ffffffffc02025a4 <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc0202468:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc020246c:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020246e:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0202472:	6a10                	ld	a2,16(a2)
ffffffffc0202474:	069a                	slli	a3,a3,0x6
ffffffffc0202476:	00c7d593          	srli	a1,a5,0xc
ffffffffc020247a:	9536                	add	a0,a0,a3
ffffffffc020247c:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc020247e:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202482:	b63d                	j	ffffffffc0201fb0 <pmm_init+0xe4>
        intr_disable();
ffffffffc0202484:	91afe0ef          	jal	ra,ffffffffc020059e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202488:	000bb783          	ld	a5,0(s7)
ffffffffc020248c:	779c                	ld	a5,40(a5)
ffffffffc020248e:	9782                	jalr	a5
ffffffffc0202490:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202492:	906fe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc0202496:	bea5                	j	ffffffffc020200e <pmm_init+0x142>
        intr_disable();
ffffffffc0202498:	906fe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc020249c:	000bb783          	ld	a5,0(s7)
ffffffffc02024a0:	779c                	ld	a5,40(a5)
ffffffffc02024a2:	9782                	jalr	a5
ffffffffc02024a4:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc02024a6:	8f2fe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc02024aa:	b3cd                	j	ffffffffc020228c <pmm_init+0x3c0>
        intr_disable();
ffffffffc02024ac:	8f2fe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc02024b0:	000bb783          	ld	a5,0(s7)
ffffffffc02024b4:	779c                	ld	a5,40(a5)
ffffffffc02024b6:	9782                	jalr	a5
ffffffffc02024b8:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc02024ba:	8defe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc02024be:	b36d                	j	ffffffffc0202268 <pmm_init+0x39c>
ffffffffc02024c0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02024c2:	8dcfe0ef          	jal	ra,ffffffffc020059e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02024c6:	000bb783          	ld	a5,0(s7)
ffffffffc02024ca:	6522                	ld	a0,8(sp)
ffffffffc02024cc:	4585                	li	a1,1
ffffffffc02024ce:	739c                	ld	a5,32(a5)
ffffffffc02024d0:	9782                	jalr	a5
        intr_enable();
ffffffffc02024d2:	8c6fe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc02024d6:	bb8d                	j	ffffffffc0202248 <pmm_init+0x37c>
ffffffffc02024d8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02024da:	8c4fe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc02024de:	000bb783          	ld	a5,0(s7)
ffffffffc02024e2:	6522                	ld	a0,8(sp)
ffffffffc02024e4:	4585                	li	a1,1
ffffffffc02024e6:	739c                	ld	a5,32(a5)
ffffffffc02024e8:	9782                	jalr	a5
        intr_enable();
ffffffffc02024ea:	8aefe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc02024ee:	b32d                	j	ffffffffc0202218 <pmm_init+0x34c>
        intr_disable();
ffffffffc02024f0:	8aefe0ef          	jal	ra,ffffffffc020059e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02024f4:	000bb783          	ld	a5,0(s7)
ffffffffc02024f8:	779c                	ld	a5,40(a5)
ffffffffc02024fa:	9782                	jalr	a5
ffffffffc02024fc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02024fe:	89afe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc0202502:	b72d                	j	ffffffffc020242c <pmm_init+0x560>
ffffffffc0202504:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202506:	898fe0ef          	jal	ra,ffffffffc020059e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020250a:	000bb783          	ld	a5,0(s7)
ffffffffc020250e:	6522                	ld	a0,8(sp)
ffffffffc0202510:	4585                	li	a1,1
ffffffffc0202512:	739c                	ld	a5,32(a5)
ffffffffc0202514:	9782                	jalr	a5
        intr_enable();
ffffffffc0202516:	882fe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc020251a:	bdcd                	j	ffffffffc020240c <pmm_init+0x540>
ffffffffc020251c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020251e:	880fe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc0202522:	000bb783          	ld	a5,0(s7)
ffffffffc0202526:	6522                	ld	a0,8(sp)
ffffffffc0202528:	4585                	li	a1,1
ffffffffc020252a:	739c                	ld	a5,32(a5)
ffffffffc020252c:	9782                	jalr	a5
        intr_enable();
ffffffffc020252e:	86afe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc0202532:	b56d                	j	ffffffffc02023dc <pmm_init+0x510>
        intr_disable();
ffffffffc0202534:	86afe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc0202538:	000bb783          	ld	a5,0(s7)
ffffffffc020253c:	4585                	li	a1,1
ffffffffc020253e:	8556                	mv	a0,s5
ffffffffc0202540:	739c                	ld	a5,32(a5)
ffffffffc0202542:	9782                	jalr	a5
        intr_enable();
ffffffffc0202544:	854fe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc0202548:	b59d                	j	ffffffffc02023ae <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020254a:	00003697          	auipc	a3,0x3
ffffffffc020254e:	6a668693          	addi	a3,a3,1702 # ffffffffc0205bf0 <default_pmm_manager+0x518>
ffffffffc0202552:	00003617          	auipc	a2,0x3
ffffffffc0202556:	dd660613          	addi	a2,a2,-554 # ffffffffc0205328 <commands+0x738>
ffffffffc020255a:	19e00593          	li	a1,414
ffffffffc020255e:	00003517          	auipc	a0,0x3
ffffffffc0202562:	2ca50513          	addi	a0,a0,714 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0202566:	ee1fd0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020256a:	00003697          	auipc	a3,0x3
ffffffffc020256e:	64668693          	addi	a3,a3,1606 # ffffffffc0205bb0 <default_pmm_manager+0x4d8>
ffffffffc0202572:	00003617          	auipc	a2,0x3
ffffffffc0202576:	db660613          	addi	a2,a2,-586 # ffffffffc0205328 <commands+0x738>
ffffffffc020257a:	19d00593          	li	a1,413
ffffffffc020257e:	00003517          	auipc	a0,0x3
ffffffffc0202582:	2aa50513          	addi	a0,a0,682 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0202586:	ec1fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020258a:	86a2                	mv	a3,s0
ffffffffc020258c:	00003617          	auipc	a2,0x3
ffffffffc0202590:	18460613          	addi	a2,a2,388 # ffffffffc0205710 <default_pmm_manager+0x38>
ffffffffc0202594:	19d00593          	li	a1,413
ffffffffc0202598:	00003517          	auipc	a0,0x3
ffffffffc020259c:	29050513          	addi	a0,a0,656 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc02025a0:	ea7fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02025a4:	c2cff0ef          	jal	ra,ffffffffc02019d0 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02025a8:	00003617          	auipc	a2,0x3
ffffffffc02025ac:	21060613          	addi	a2,a2,528 # ffffffffc02057b8 <default_pmm_manager+0xe0>
ffffffffc02025b0:	07f00593          	li	a1,127
ffffffffc02025b4:	00003517          	auipc	a0,0x3
ffffffffc02025b8:	27450513          	addi	a0,a0,628 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc02025bc:	e8bfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02025c0:	00003617          	auipc	a2,0x3
ffffffffc02025c4:	1f860613          	addi	a2,a2,504 # ffffffffc02057b8 <default_pmm_manager+0xe0>
ffffffffc02025c8:	0c300593          	li	a1,195
ffffffffc02025cc:	00003517          	auipc	a0,0x3
ffffffffc02025d0:	25c50513          	addi	a0,a0,604 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc02025d4:	e73fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02025d8:	00003697          	auipc	a3,0x3
ffffffffc02025dc:	31068693          	addi	a3,a3,784 # ffffffffc02058e8 <default_pmm_manager+0x210>
ffffffffc02025e0:	00003617          	auipc	a2,0x3
ffffffffc02025e4:	d4860613          	addi	a2,a2,-696 # ffffffffc0205328 <commands+0x738>
ffffffffc02025e8:	16100593          	li	a1,353
ffffffffc02025ec:	00003517          	auipc	a0,0x3
ffffffffc02025f0:	23c50513          	addi	a0,a0,572 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc02025f4:	e53fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02025f8:	00003697          	auipc	a3,0x3
ffffffffc02025fc:	2d068693          	addi	a3,a3,720 # ffffffffc02058c8 <default_pmm_manager+0x1f0>
ffffffffc0202600:	00003617          	auipc	a2,0x3
ffffffffc0202604:	d2860613          	addi	a2,a2,-728 # ffffffffc0205328 <commands+0x738>
ffffffffc0202608:	16000593          	li	a1,352
ffffffffc020260c:	00003517          	auipc	a0,0x3
ffffffffc0202610:	21c50513          	addi	a0,a0,540 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0202614:	e33fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202618:	bd4ff0ef          	jal	ra,ffffffffc02019ec <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020261c:	00003697          	auipc	a3,0x3
ffffffffc0202620:	35c68693          	addi	a3,a3,860 # ffffffffc0205978 <default_pmm_manager+0x2a0>
ffffffffc0202624:	00003617          	auipc	a2,0x3
ffffffffc0202628:	d0460613          	addi	a2,a2,-764 # ffffffffc0205328 <commands+0x738>
ffffffffc020262c:	16900593          	li	a1,361
ffffffffc0202630:	00003517          	auipc	a0,0x3
ffffffffc0202634:	1f850513          	addi	a0,a0,504 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0202638:	e0ffd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020263c:	00003697          	auipc	a3,0x3
ffffffffc0202640:	30c68693          	addi	a3,a3,780 # ffffffffc0205948 <default_pmm_manager+0x270>
ffffffffc0202644:	00003617          	auipc	a2,0x3
ffffffffc0202648:	ce460613          	addi	a2,a2,-796 # ffffffffc0205328 <commands+0x738>
ffffffffc020264c:	16600593          	li	a1,358
ffffffffc0202650:	00003517          	auipc	a0,0x3
ffffffffc0202654:	1d850513          	addi	a0,a0,472 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0202658:	deffd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020265c:	00003697          	auipc	a3,0x3
ffffffffc0202660:	2c468693          	addi	a3,a3,708 # ffffffffc0205920 <default_pmm_manager+0x248>
ffffffffc0202664:	00003617          	auipc	a2,0x3
ffffffffc0202668:	cc460613          	addi	a2,a2,-828 # ffffffffc0205328 <commands+0x738>
ffffffffc020266c:	16200593          	li	a1,354
ffffffffc0202670:	00003517          	auipc	a0,0x3
ffffffffc0202674:	1b850513          	addi	a0,a0,440 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0202678:	dcffd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020267c:	00003697          	auipc	a3,0x3
ffffffffc0202680:	38468693          	addi	a3,a3,900 # ffffffffc0205a00 <default_pmm_manager+0x328>
ffffffffc0202684:	00003617          	auipc	a2,0x3
ffffffffc0202688:	ca460613          	addi	a2,a2,-860 # ffffffffc0205328 <commands+0x738>
ffffffffc020268c:	17200593          	li	a1,370
ffffffffc0202690:	00003517          	auipc	a0,0x3
ffffffffc0202694:	19850513          	addi	a0,a0,408 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0202698:	daffd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc020269c:	00003697          	auipc	a3,0x3
ffffffffc02026a0:	40468693          	addi	a3,a3,1028 # ffffffffc0205aa0 <default_pmm_manager+0x3c8>
ffffffffc02026a4:	00003617          	auipc	a2,0x3
ffffffffc02026a8:	c8460613          	addi	a2,a2,-892 # ffffffffc0205328 <commands+0x738>
ffffffffc02026ac:	17700593          	li	a1,375
ffffffffc02026b0:	00003517          	auipc	a0,0x3
ffffffffc02026b4:	17850513          	addi	a0,a0,376 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc02026b8:	d8ffd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02026bc:	00003697          	auipc	a3,0x3
ffffffffc02026c0:	31c68693          	addi	a3,a3,796 # ffffffffc02059d8 <default_pmm_manager+0x300>
ffffffffc02026c4:	00003617          	auipc	a2,0x3
ffffffffc02026c8:	c6460613          	addi	a2,a2,-924 # ffffffffc0205328 <commands+0x738>
ffffffffc02026cc:	16f00593          	li	a1,367
ffffffffc02026d0:	00003517          	auipc	a0,0x3
ffffffffc02026d4:	15850513          	addi	a0,a0,344 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc02026d8:	d6ffd0ef          	jal	ra,ffffffffc0200446 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02026dc:	86d6                	mv	a3,s5
ffffffffc02026de:	00003617          	auipc	a2,0x3
ffffffffc02026e2:	03260613          	addi	a2,a2,50 # ffffffffc0205710 <default_pmm_manager+0x38>
ffffffffc02026e6:	16e00593          	li	a1,366
ffffffffc02026ea:	00003517          	auipc	a0,0x3
ffffffffc02026ee:	13e50513          	addi	a0,a0,318 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc02026f2:	d55fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02026f6:	00003697          	auipc	a3,0x3
ffffffffc02026fa:	34268693          	addi	a3,a3,834 # ffffffffc0205a38 <default_pmm_manager+0x360>
ffffffffc02026fe:	00003617          	auipc	a2,0x3
ffffffffc0202702:	c2a60613          	addi	a2,a2,-982 # ffffffffc0205328 <commands+0x738>
ffffffffc0202706:	17c00593          	li	a1,380
ffffffffc020270a:	00003517          	auipc	a0,0x3
ffffffffc020270e:	11e50513          	addi	a0,a0,286 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0202712:	d35fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202716:	00003697          	auipc	a3,0x3
ffffffffc020271a:	3ea68693          	addi	a3,a3,1002 # ffffffffc0205b00 <default_pmm_manager+0x428>
ffffffffc020271e:	00003617          	auipc	a2,0x3
ffffffffc0202722:	c0a60613          	addi	a2,a2,-1014 # ffffffffc0205328 <commands+0x738>
ffffffffc0202726:	17b00593          	li	a1,379
ffffffffc020272a:	00003517          	auipc	a0,0x3
ffffffffc020272e:	0fe50513          	addi	a0,a0,254 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0202732:	d15fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202736:	00003697          	auipc	a3,0x3
ffffffffc020273a:	3b268693          	addi	a3,a3,946 # ffffffffc0205ae8 <default_pmm_manager+0x410>
ffffffffc020273e:	00003617          	auipc	a2,0x3
ffffffffc0202742:	bea60613          	addi	a2,a2,-1046 # ffffffffc0205328 <commands+0x738>
ffffffffc0202746:	17a00593          	li	a1,378
ffffffffc020274a:	00003517          	auipc	a0,0x3
ffffffffc020274e:	0de50513          	addi	a0,a0,222 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0202752:	cf5fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202756:	00003697          	auipc	a3,0x3
ffffffffc020275a:	36268693          	addi	a3,a3,866 # ffffffffc0205ab8 <default_pmm_manager+0x3e0>
ffffffffc020275e:	00003617          	auipc	a2,0x3
ffffffffc0202762:	bca60613          	addi	a2,a2,-1078 # ffffffffc0205328 <commands+0x738>
ffffffffc0202766:	17900593          	li	a1,377
ffffffffc020276a:	00003517          	auipc	a0,0x3
ffffffffc020276e:	0be50513          	addi	a0,a0,190 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0202772:	cd5fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202776:	00003697          	auipc	a3,0x3
ffffffffc020277a:	4fa68693          	addi	a3,a3,1274 # ffffffffc0205c70 <default_pmm_manager+0x598>
ffffffffc020277e:	00003617          	auipc	a2,0x3
ffffffffc0202782:	baa60613          	addi	a2,a2,-1110 # ffffffffc0205328 <commands+0x738>
ffffffffc0202786:	1a700593          	li	a1,423
ffffffffc020278a:	00003517          	auipc	a0,0x3
ffffffffc020278e:	09e50513          	addi	a0,a0,158 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0202792:	cb5fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202796:	00003697          	auipc	a3,0x3
ffffffffc020279a:	2f268693          	addi	a3,a3,754 # ffffffffc0205a88 <default_pmm_manager+0x3b0>
ffffffffc020279e:	00003617          	auipc	a2,0x3
ffffffffc02027a2:	b8a60613          	addi	a2,a2,-1142 # ffffffffc0205328 <commands+0x738>
ffffffffc02027a6:	17600593          	li	a1,374
ffffffffc02027aa:	00003517          	auipc	a0,0x3
ffffffffc02027ae:	07e50513          	addi	a0,a0,126 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc02027b2:	c95fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02027b6:	00003697          	auipc	a3,0x3
ffffffffc02027ba:	2c268693          	addi	a3,a3,706 # ffffffffc0205a78 <default_pmm_manager+0x3a0>
ffffffffc02027be:	00003617          	auipc	a2,0x3
ffffffffc02027c2:	b6a60613          	addi	a2,a2,-1174 # ffffffffc0205328 <commands+0x738>
ffffffffc02027c6:	17500593          	li	a1,373
ffffffffc02027ca:	00003517          	auipc	a0,0x3
ffffffffc02027ce:	05e50513          	addi	a0,a0,94 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc02027d2:	c75fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02027d6:	00003697          	auipc	a3,0x3
ffffffffc02027da:	39a68693          	addi	a3,a3,922 # ffffffffc0205b70 <default_pmm_manager+0x498>
ffffffffc02027de:	00003617          	auipc	a2,0x3
ffffffffc02027e2:	b4a60613          	addi	a2,a2,-1206 # ffffffffc0205328 <commands+0x738>
ffffffffc02027e6:	1b800593          	li	a1,440
ffffffffc02027ea:	00003517          	auipc	a0,0x3
ffffffffc02027ee:	03e50513          	addi	a0,a0,62 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc02027f2:	c55fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02027f6:	00003697          	auipc	a3,0x3
ffffffffc02027fa:	27268693          	addi	a3,a3,626 # ffffffffc0205a68 <default_pmm_manager+0x390>
ffffffffc02027fe:	00003617          	auipc	a2,0x3
ffffffffc0202802:	b2a60613          	addi	a2,a2,-1238 # ffffffffc0205328 <commands+0x738>
ffffffffc0202806:	17400593          	li	a1,372
ffffffffc020280a:	00003517          	auipc	a0,0x3
ffffffffc020280e:	01e50513          	addi	a0,a0,30 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0202812:	c35fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202816:	00003697          	auipc	a3,0x3
ffffffffc020281a:	1aa68693          	addi	a3,a3,426 # ffffffffc02059c0 <default_pmm_manager+0x2e8>
ffffffffc020281e:	00003617          	auipc	a2,0x3
ffffffffc0202822:	b0a60613          	addi	a2,a2,-1270 # ffffffffc0205328 <commands+0x738>
ffffffffc0202826:	18100593          	li	a1,385
ffffffffc020282a:	00003517          	auipc	a0,0x3
ffffffffc020282e:	ffe50513          	addi	a0,a0,-2 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0202832:	c15fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202836:	00003697          	auipc	a3,0x3
ffffffffc020283a:	2e268693          	addi	a3,a3,738 # ffffffffc0205b18 <default_pmm_manager+0x440>
ffffffffc020283e:	00003617          	auipc	a2,0x3
ffffffffc0202842:	aea60613          	addi	a2,a2,-1302 # ffffffffc0205328 <commands+0x738>
ffffffffc0202846:	17e00593          	li	a1,382
ffffffffc020284a:	00003517          	auipc	a0,0x3
ffffffffc020284e:	fde50513          	addi	a0,a0,-34 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0202852:	bf5fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202856:	00003697          	auipc	a3,0x3
ffffffffc020285a:	15268693          	addi	a3,a3,338 # ffffffffc02059a8 <default_pmm_manager+0x2d0>
ffffffffc020285e:	00003617          	auipc	a2,0x3
ffffffffc0202862:	aca60613          	addi	a2,a2,-1334 # ffffffffc0205328 <commands+0x738>
ffffffffc0202866:	17d00593          	li	a1,381
ffffffffc020286a:	00003517          	auipc	a0,0x3
ffffffffc020286e:	fbe50513          	addi	a0,a0,-66 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0202872:	bd5fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202876:	00003617          	auipc	a2,0x3
ffffffffc020287a:	e9a60613          	addi	a2,a2,-358 # ffffffffc0205710 <default_pmm_manager+0x38>
ffffffffc020287e:	06900593          	li	a1,105
ffffffffc0202882:	00003517          	auipc	a0,0x3
ffffffffc0202886:	eb650513          	addi	a0,a0,-330 # ffffffffc0205738 <default_pmm_manager+0x60>
ffffffffc020288a:	bbdfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020288e:	00003697          	auipc	a3,0x3
ffffffffc0202892:	2ba68693          	addi	a3,a3,698 # ffffffffc0205b48 <default_pmm_manager+0x470>
ffffffffc0202896:	00003617          	auipc	a2,0x3
ffffffffc020289a:	a9260613          	addi	a2,a2,-1390 # ffffffffc0205328 <commands+0x738>
ffffffffc020289e:	18800593          	li	a1,392
ffffffffc02028a2:	00003517          	auipc	a0,0x3
ffffffffc02028a6:	f8650513          	addi	a0,a0,-122 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc02028aa:	b9dfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02028ae:	00003697          	auipc	a3,0x3
ffffffffc02028b2:	25268693          	addi	a3,a3,594 # ffffffffc0205b00 <default_pmm_manager+0x428>
ffffffffc02028b6:	00003617          	auipc	a2,0x3
ffffffffc02028ba:	a7260613          	addi	a2,a2,-1422 # ffffffffc0205328 <commands+0x738>
ffffffffc02028be:	18600593          	li	a1,390
ffffffffc02028c2:	00003517          	auipc	a0,0x3
ffffffffc02028c6:	f6650513          	addi	a0,a0,-154 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc02028ca:	b7dfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02028ce:	00003697          	auipc	a3,0x3
ffffffffc02028d2:	26268693          	addi	a3,a3,610 # ffffffffc0205b30 <default_pmm_manager+0x458>
ffffffffc02028d6:	00003617          	auipc	a2,0x3
ffffffffc02028da:	a5260613          	addi	a2,a2,-1454 # ffffffffc0205328 <commands+0x738>
ffffffffc02028de:	18500593          	li	a1,389
ffffffffc02028e2:	00003517          	auipc	a0,0x3
ffffffffc02028e6:	f4650513          	addi	a0,a0,-186 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc02028ea:	b5dfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02028ee:	00003697          	auipc	a3,0x3
ffffffffc02028f2:	21268693          	addi	a3,a3,530 # ffffffffc0205b00 <default_pmm_manager+0x428>
ffffffffc02028f6:	00003617          	auipc	a2,0x3
ffffffffc02028fa:	a3260613          	addi	a2,a2,-1486 # ffffffffc0205328 <commands+0x738>
ffffffffc02028fe:	18200593          	li	a1,386
ffffffffc0202902:	00003517          	auipc	a0,0x3
ffffffffc0202906:	f2650513          	addi	a0,a0,-218 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc020290a:	b3dfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p) == 1);
ffffffffc020290e:	00003697          	auipc	a3,0x3
ffffffffc0202912:	34a68693          	addi	a3,a3,842 # ffffffffc0205c58 <default_pmm_manager+0x580>
ffffffffc0202916:	00003617          	auipc	a2,0x3
ffffffffc020291a:	a1260613          	addi	a2,a2,-1518 # ffffffffc0205328 <commands+0x738>
ffffffffc020291e:	1a600593          	li	a1,422
ffffffffc0202922:	00003517          	auipc	a0,0x3
ffffffffc0202926:	f0650513          	addi	a0,a0,-250 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc020292a:	b1dfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020292e:	00003697          	auipc	a3,0x3
ffffffffc0202932:	2f268693          	addi	a3,a3,754 # ffffffffc0205c20 <default_pmm_manager+0x548>
ffffffffc0202936:	00003617          	auipc	a2,0x3
ffffffffc020293a:	9f260613          	addi	a2,a2,-1550 # ffffffffc0205328 <commands+0x738>
ffffffffc020293e:	1a500593          	li	a1,421
ffffffffc0202942:	00003517          	auipc	a0,0x3
ffffffffc0202946:	ee650513          	addi	a0,a0,-282 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc020294a:	afdfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc020294e:	00003697          	auipc	a3,0x3
ffffffffc0202952:	2ba68693          	addi	a3,a3,698 # ffffffffc0205c08 <default_pmm_manager+0x530>
ffffffffc0202956:	00003617          	auipc	a2,0x3
ffffffffc020295a:	9d260613          	addi	a2,a2,-1582 # ffffffffc0205328 <commands+0x738>
ffffffffc020295e:	1a100593          	li	a1,417
ffffffffc0202962:	00003517          	auipc	a0,0x3
ffffffffc0202966:	ec650513          	addi	a0,a0,-314 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc020296a:	addfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020296e:	00003697          	auipc	a3,0x3
ffffffffc0202972:	20268693          	addi	a3,a3,514 # ffffffffc0205b70 <default_pmm_manager+0x498>
ffffffffc0202976:	00003617          	auipc	a2,0x3
ffffffffc020297a:	9b260613          	addi	a2,a2,-1614 # ffffffffc0205328 <commands+0x738>
ffffffffc020297e:	19000593          	li	a1,400
ffffffffc0202982:	00003517          	auipc	a0,0x3
ffffffffc0202986:	ea650513          	addi	a0,a0,-346 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc020298a:	abdfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020298e:	00003697          	auipc	a3,0x3
ffffffffc0202992:	01a68693          	addi	a3,a3,26 # ffffffffc02059a8 <default_pmm_manager+0x2d0>
ffffffffc0202996:	00003617          	auipc	a2,0x3
ffffffffc020299a:	99260613          	addi	a2,a2,-1646 # ffffffffc0205328 <commands+0x738>
ffffffffc020299e:	16a00593          	li	a1,362
ffffffffc02029a2:	00003517          	auipc	a0,0x3
ffffffffc02029a6:	e8650513          	addi	a0,a0,-378 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc02029aa:	a9dfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02029ae:	00003617          	auipc	a2,0x3
ffffffffc02029b2:	d6260613          	addi	a2,a2,-670 # ffffffffc0205710 <default_pmm_manager+0x38>
ffffffffc02029b6:	16d00593          	li	a1,365
ffffffffc02029ba:	00003517          	auipc	a0,0x3
ffffffffc02029be:	e6e50513          	addi	a0,a0,-402 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc02029c2:	a85fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02029c6:	00003697          	auipc	a3,0x3
ffffffffc02029ca:	ffa68693          	addi	a3,a3,-6 # ffffffffc02059c0 <default_pmm_manager+0x2e8>
ffffffffc02029ce:	00003617          	auipc	a2,0x3
ffffffffc02029d2:	95a60613          	addi	a2,a2,-1702 # ffffffffc0205328 <commands+0x738>
ffffffffc02029d6:	16b00593          	li	a1,363
ffffffffc02029da:	00003517          	auipc	a0,0x3
ffffffffc02029de:	e4e50513          	addi	a0,a0,-434 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc02029e2:	a65fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02029e6:	00003697          	auipc	a3,0x3
ffffffffc02029ea:	05268693          	addi	a3,a3,82 # ffffffffc0205a38 <default_pmm_manager+0x360>
ffffffffc02029ee:	00003617          	auipc	a2,0x3
ffffffffc02029f2:	93a60613          	addi	a2,a2,-1734 # ffffffffc0205328 <commands+0x738>
ffffffffc02029f6:	17300593          	li	a1,371
ffffffffc02029fa:	00003517          	auipc	a0,0x3
ffffffffc02029fe:	e2e50513          	addi	a0,a0,-466 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0202a02:	a45fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a06:	00003697          	auipc	a3,0x3
ffffffffc0202a0a:	31268693          	addi	a3,a3,786 # ffffffffc0205d18 <default_pmm_manager+0x640>
ffffffffc0202a0e:	00003617          	auipc	a2,0x3
ffffffffc0202a12:	91a60613          	addi	a2,a2,-1766 # ffffffffc0205328 <commands+0x738>
ffffffffc0202a16:	1af00593          	li	a1,431
ffffffffc0202a1a:	00003517          	auipc	a0,0x3
ffffffffc0202a1e:	e0e50513          	addi	a0,a0,-498 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0202a22:	a25fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202a26:	00003697          	auipc	a3,0x3
ffffffffc0202a2a:	2ba68693          	addi	a3,a3,698 # ffffffffc0205ce0 <default_pmm_manager+0x608>
ffffffffc0202a2e:	00003617          	auipc	a2,0x3
ffffffffc0202a32:	8fa60613          	addi	a2,a2,-1798 # ffffffffc0205328 <commands+0x738>
ffffffffc0202a36:	1ac00593          	li	a1,428
ffffffffc0202a3a:	00003517          	auipc	a0,0x3
ffffffffc0202a3e:	dee50513          	addi	a0,a0,-530 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0202a42:	a05fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202a46:	00003697          	auipc	a3,0x3
ffffffffc0202a4a:	26a68693          	addi	a3,a3,618 # ffffffffc0205cb0 <default_pmm_manager+0x5d8>
ffffffffc0202a4e:	00003617          	auipc	a2,0x3
ffffffffc0202a52:	8da60613          	addi	a2,a2,-1830 # ffffffffc0205328 <commands+0x738>
ffffffffc0202a56:	1a800593          	li	a1,424
ffffffffc0202a5a:	00003517          	auipc	a0,0x3
ffffffffc0202a5e:	dce50513          	addi	a0,a0,-562 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0202a62:	9e5fd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0202a66 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202a66:	12058073          	sfence.vma	a1
}
ffffffffc0202a6a:	8082                	ret

ffffffffc0202a6c <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202a6c:	7179                	addi	sp,sp,-48
ffffffffc0202a6e:	e84a                	sd	s2,16(sp)
ffffffffc0202a70:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202a72:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202a74:	f022                	sd	s0,32(sp)
ffffffffc0202a76:	ec26                	sd	s1,24(sp)
ffffffffc0202a78:	e44e                	sd	s3,8(sp)
ffffffffc0202a7a:	f406                	sd	ra,40(sp)
ffffffffc0202a7c:	84ae                	mv	s1,a1
ffffffffc0202a7e:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202a80:	f89fe0ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0202a84:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202a86:	cd09                	beqz	a0,ffffffffc0202aa0 <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202a88:	85aa                	mv	a1,a0
ffffffffc0202a8a:	86ce                	mv	a3,s3
ffffffffc0202a8c:	8626                	mv	a2,s1
ffffffffc0202a8e:	854a                	mv	a0,s2
ffffffffc0202a90:	b46ff0ef          	jal	ra,ffffffffc0201dd6 <page_insert>
ffffffffc0202a94:	ed21                	bnez	a0,ffffffffc0202aec <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc0202a96:	00013797          	auipc	a5,0x13
ffffffffc0202a9a:	afa7a783          	lw	a5,-1286(a5) # ffffffffc0215590 <swap_init_ok>
ffffffffc0202a9e:	eb89                	bnez	a5,ffffffffc0202ab0 <pgdir_alloc_page+0x44>
}
ffffffffc0202aa0:	70a2                	ld	ra,40(sp)
ffffffffc0202aa2:	8522                	mv	a0,s0
ffffffffc0202aa4:	7402                	ld	s0,32(sp)
ffffffffc0202aa6:	64e2                	ld	s1,24(sp)
ffffffffc0202aa8:	6942                	ld	s2,16(sp)
ffffffffc0202aaa:	69a2                	ld	s3,8(sp)
ffffffffc0202aac:	6145                	addi	sp,sp,48
ffffffffc0202aae:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202ab0:	4681                	li	a3,0
ffffffffc0202ab2:	8622                	mv	a2,s0
ffffffffc0202ab4:	85a6                	mv	a1,s1
ffffffffc0202ab6:	00013517          	auipc	a0,0x13
ffffffffc0202aba:	ae253503          	ld	a0,-1310(a0) # ffffffffc0215598 <check_mm_struct>
ffffffffc0202abe:	7c8000ef          	jal	ra,ffffffffc0203286 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202ac2:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202ac4:	fc04                	sd	s1,56(s0)
            assert(page_ref(page) == 1);
ffffffffc0202ac6:	4785                	li	a5,1
ffffffffc0202ac8:	fcf70ce3          	beq	a4,a5,ffffffffc0202aa0 <pgdir_alloc_page+0x34>
ffffffffc0202acc:	00003697          	auipc	a3,0x3
ffffffffc0202ad0:	29468693          	addi	a3,a3,660 # ffffffffc0205d60 <default_pmm_manager+0x688>
ffffffffc0202ad4:	00003617          	auipc	a2,0x3
ffffffffc0202ad8:	85460613          	addi	a2,a2,-1964 # ffffffffc0205328 <commands+0x738>
ffffffffc0202adc:	14800593          	li	a1,328
ffffffffc0202ae0:	00003517          	auipc	a0,0x3
ffffffffc0202ae4:	d4850513          	addi	a0,a0,-696 # ffffffffc0205828 <default_pmm_manager+0x150>
ffffffffc0202ae8:	95ffd0ef          	jal	ra,ffffffffc0200446 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202aec:	100027f3          	csrr	a5,sstatus
ffffffffc0202af0:	8b89                	andi	a5,a5,2
ffffffffc0202af2:	eb99                	bnez	a5,ffffffffc0202b08 <pgdir_alloc_page+0x9c>
        pmm_manager->free_pages(base, n);
ffffffffc0202af4:	00013797          	auipc	a5,0x13
ffffffffc0202af8:	a7c7b783          	ld	a5,-1412(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0202afc:	739c                	ld	a5,32(a5)
ffffffffc0202afe:	8522                	mv	a0,s0
ffffffffc0202b00:	4585                	li	a1,1
ffffffffc0202b02:	9782                	jalr	a5
            return NULL;
ffffffffc0202b04:	4401                	li	s0,0
ffffffffc0202b06:	bf69                	j	ffffffffc0202aa0 <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc0202b08:	a97fd0ef          	jal	ra,ffffffffc020059e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202b0c:	00013797          	auipc	a5,0x13
ffffffffc0202b10:	a647b783          	ld	a5,-1436(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0202b14:	739c                	ld	a5,32(a5)
ffffffffc0202b16:	8522                	mv	a0,s0
ffffffffc0202b18:	4585                	li	a1,1
ffffffffc0202b1a:	9782                	jalr	a5
            return NULL;
ffffffffc0202b1c:	4401                	li	s0,0
        intr_enable();
ffffffffc0202b1e:	a7bfd0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc0202b22:	bfbd                	j	ffffffffc0202aa0 <pgdir_alloc_page+0x34>

ffffffffc0202b24 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0202b24:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0202b26:	00003617          	auipc	a2,0x3
ffffffffc0202b2a:	cba60613          	addi	a2,a2,-838 # ffffffffc02057e0 <default_pmm_manager+0x108>
ffffffffc0202b2e:	06200593          	li	a1,98
ffffffffc0202b32:	00003517          	auipc	a0,0x3
ffffffffc0202b36:	c0650513          	addi	a0,a0,-1018 # ffffffffc0205738 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc0202b3a:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0202b3c:	90bfd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0202b40 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202b40:	7135                	addi	sp,sp,-160
ffffffffc0202b42:	ed06                	sd	ra,152(sp)
ffffffffc0202b44:	e922                	sd	s0,144(sp)
ffffffffc0202b46:	e526                	sd	s1,136(sp)
ffffffffc0202b48:	e14a                	sd	s2,128(sp)
ffffffffc0202b4a:	fcce                	sd	s3,120(sp)
ffffffffc0202b4c:	f8d2                	sd	s4,112(sp)
ffffffffc0202b4e:	f4d6                	sd	s5,104(sp)
ffffffffc0202b50:	f0da                	sd	s6,96(sp)
ffffffffc0202b52:	ecde                	sd	s7,88(sp)
ffffffffc0202b54:	e8e2                	sd	s8,80(sp)
ffffffffc0202b56:	e4e6                	sd	s9,72(sp)
ffffffffc0202b58:	e0ea                	sd	s10,64(sp)
ffffffffc0202b5a:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202b5c:	4a0010ef          	jal	ra,ffffffffc0203ffc <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202b60:	00013697          	auipc	a3,0x13
ffffffffc0202b64:	a206b683          	ld	a3,-1504(a3) # ffffffffc0215580 <max_swap_offset>
ffffffffc0202b68:	010007b7          	lui	a5,0x1000
ffffffffc0202b6c:	ff968713          	addi	a4,a3,-7
ffffffffc0202b70:	17e1                	addi	a5,a5,-8
ffffffffc0202b72:	42e7e063          	bltu	a5,a4,ffffffffc0202f92 <swap_init+0x452>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc0202b76:	00007797          	auipc	a5,0x7
ffffffffc0202b7a:	49a78793          	addi	a5,a5,1178 # ffffffffc020a010 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0202b7e:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0202b80:	00013b97          	auipc	s7,0x13
ffffffffc0202b84:	a08b8b93          	addi	s7,s7,-1528 # ffffffffc0215588 <sm>
ffffffffc0202b88:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc0202b8c:	9702                	jalr	a4
ffffffffc0202b8e:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc0202b90:	c10d                	beqz	a0,ffffffffc0202bb2 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0202b92:	60ea                	ld	ra,152(sp)
ffffffffc0202b94:	644a                	ld	s0,144(sp)
ffffffffc0202b96:	64aa                	ld	s1,136(sp)
ffffffffc0202b98:	79e6                	ld	s3,120(sp)
ffffffffc0202b9a:	7a46                	ld	s4,112(sp)
ffffffffc0202b9c:	7aa6                	ld	s5,104(sp)
ffffffffc0202b9e:	7b06                	ld	s6,96(sp)
ffffffffc0202ba0:	6be6                	ld	s7,88(sp)
ffffffffc0202ba2:	6c46                	ld	s8,80(sp)
ffffffffc0202ba4:	6ca6                	ld	s9,72(sp)
ffffffffc0202ba6:	6d06                	ld	s10,64(sp)
ffffffffc0202ba8:	7de2                	ld	s11,56(sp)
ffffffffc0202baa:	854a                	mv	a0,s2
ffffffffc0202bac:	690a                	ld	s2,128(sp)
ffffffffc0202bae:	610d                	addi	sp,sp,160
ffffffffc0202bb0:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202bb2:	000bb783          	ld	a5,0(s7)
ffffffffc0202bb6:	00003517          	auipc	a0,0x3
ffffffffc0202bba:	1f250513          	addi	a0,a0,498 # ffffffffc0205da8 <default_pmm_manager+0x6d0>
    return listelm->next;
ffffffffc0202bbe:	0000f417          	auipc	s0,0xf
ffffffffc0202bc2:	89a40413          	addi	s0,s0,-1894 # ffffffffc0211458 <free_area>
ffffffffc0202bc6:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202bc8:	4785                	li	a5,1
ffffffffc0202bca:	00013717          	auipc	a4,0x13
ffffffffc0202bce:	9cf72323          	sw	a5,-1594(a4) # ffffffffc0215590 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202bd2:	daefd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0202bd6:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0202bd8:	4d01                	li	s10,0
ffffffffc0202bda:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bdc:	32878b63          	beq	a5,s0,ffffffffc0202f12 <swap_init+0x3d2>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202be0:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202be4:	8b09                	andi	a4,a4,2
ffffffffc0202be6:	32070863          	beqz	a4,ffffffffc0202f16 <swap_init+0x3d6>
        count ++, total += p->property;
ffffffffc0202bea:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202bee:	679c                	ld	a5,8(a5)
ffffffffc0202bf0:	2d85                	addiw	s11,s11,1
ffffffffc0202bf2:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bf6:	fe8795e3          	bne	a5,s0,ffffffffc0202be0 <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0202bfa:	84ea                	mv	s1,s10
ffffffffc0202bfc:	edffe0ef          	jal	ra,ffffffffc0201ada <nr_free_pages>
ffffffffc0202c00:	42951163          	bne	a0,s1,ffffffffc0203022 <swap_init+0x4e2>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202c04:	866a                	mv	a2,s10
ffffffffc0202c06:	85ee                	mv	a1,s11
ffffffffc0202c08:	00003517          	auipc	a0,0x3
ffffffffc0202c0c:	1b850513          	addi	a0,a0,440 # ffffffffc0205dc0 <default_pmm_manager+0x6e8>
ffffffffc0202c10:	d70fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202c14:	3a5000ef          	jal	ra,ffffffffc02037b8 <mm_create>
ffffffffc0202c18:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0202c1a:	46050463          	beqz	a0,ffffffffc0203082 <swap_init+0x542>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202c1e:	00013797          	auipc	a5,0x13
ffffffffc0202c22:	97a78793          	addi	a5,a5,-1670 # ffffffffc0215598 <check_mm_struct>
ffffffffc0202c26:	6398                	ld	a4,0(a5)
ffffffffc0202c28:	3c071d63          	bnez	a4,ffffffffc0203002 <swap_init+0x4c2>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202c2c:	00013717          	auipc	a4,0x13
ffffffffc0202c30:	92c70713          	addi	a4,a4,-1748 # ffffffffc0215558 <boot_pgdir>
ffffffffc0202c34:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc0202c38:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc0202c3a:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202c3e:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202c42:	42079063          	bnez	a5,ffffffffc0203062 <swap_init+0x522>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202c46:	6599                	lui	a1,0x6
ffffffffc0202c48:	460d                	li	a2,3
ffffffffc0202c4a:	6505                	lui	a0,0x1
ffffffffc0202c4c:	3b5000ef          	jal	ra,ffffffffc0203800 <vma_create>
ffffffffc0202c50:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202c52:	52050463          	beqz	a0,ffffffffc020317a <swap_init+0x63a>

     insert_vma_struct(mm, vma);
ffffffffc0202c56:	8556                	mv	a0,s5
ffffffffc0202c58:	417000ef          	jal	ra,ffffffffc020386e <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202c5c:	00003517          	auipc	a0,0x3
ffffffffc0202c60:	1d450513          	addi	a0,a0,468 # ffffffffc0205e30 <default_pmm_manager+0x758>
ffffffffc0202c64:	d1cfd0ef          	jal	ra,ffffffffc0200180 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202c68:	018ab503          	ld	a0,24(s5)
ffffffffc0202c6c:	4605                	li	a2,1
ffffffffc0202c6e:	6585                	lui	a1,0x1
ffffffffc0202c70:	ea5fe0ef          	jal	ra,ffffffffc0201b14 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202c74:	4c050363          	beqz	a0,ffffffffc020313a <swap_init+0x5fa>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202c78:	00003517          	auipc	a0,0x3
ffffffffc0202c7c:	20850513          	addi	a0,a0,520 # ffffffffc0205e80 <default_pmm_manager+0x7a8>
ffffffffc0202c80:	0000f497          	auipc	s1,0xf
ffffffffc0202c84:	81048493          	addi	s1,s1,-2032 # ffffffffc0211490 <check_rp>
ffffffffc0202c88:	cf8fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c8c:	0000f997          	auipc	s3,0xf
ffffffffc0202c90:	82498993          	addi	s3,s3,-2012 # ffffffffc02114b0 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202c94:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc0202c96:	4505                	li	a0,1
ffffffffc0202c98:	d71fe0ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0202c9c:	00aa3023          	sd	a0,0(s4)
          assert(check_rp[i] != NULL );
ffffffffc0202ca0:	2c050963          	beqz	a0,ffffffffc0202f72 <swap_init+0x432>
ffffffffc0202ca4:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202ca6:	8b89                	andi	a5,a5,2
ffffffffc0202ca8:	32079d63          	bnez	a5,ffffffffc0202fe2 <swap_init+0x4a2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202cac:	0a21                	addi	s4,s4,8
ffffffffc0202cae:	ff3a14e3          	bne	s4,s3,ffffffffc0202c96 <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202cb2:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202cb4:	0000ea17          	auipc	s4,0xe
ffffffffc0202cb8:	7dca0a13          	addi	s4,s4,2012 # ffffffffc0211490 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc0202cbc:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc0202cbe:	ec3e                	sd	a5,24(sp)
ffffffffc0202cc0:	641c                	ld	a5,8(s0)
ffffffffc0202cc2:	e400                	sd	s0,8(s0)
ffffffffc0202cc4:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202cc6:	481c                	lw	a5,16(s0)
ffffffffc0202cc8:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0202cca:	0000e797          	auipc	a5,0xe
ffffffffc0202cce:	7807af23          	sw	zero,1950(a5) # ffffffffc0211468 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202cd2:	000a3503          	ld	a0,0(s4)
ffffffffc0202cd6:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202cd8:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc0202cda:	dc1fe0ef          	jal	ra,ffffffffc0201a9a <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202cde:	ff3a1ae3          	bne	s4,s3,ffffffffc0202cd2 <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202ce2:	01042a03          	lw	s4,16(s0)
ffffffffc0202ce6:	4791                	li	a5,4
ffffffffc0202ce8:	42fa1963          	bne	s4,a5,ffffffffc020311a <swap_init+0x5da>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202cec:	00003517          	auipc	a0,0x3
ffffffffc0202cf0:	21c50513          	addi	a0,a0,540 # ffffffffc0205f08 <default_pmm_manager+0x830>
ffffffffc0202cf4:	c8cfd0ef          	jal	ra,ffffffffc0200180 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202cf8:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202cfa:	00013797          	auipc	a5,0x13
ffffffffc0202cfe:	8a07a323          	sw	zero,-1882(a5) # ffffffffc02155a0 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202d02:	4629                	li	a2,10
ffffffffc0202d04:	00c70023          	sb	a2,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202d08:	00013697          	auipc	a3,0x13
ffffffffc0202d0c:	8986a683          	lw	a3,-1896(a3) # ffffffffc02155a0 <pgfault_num>
ffffffffc0202d10:	4585                	li	a1,1
ffffffffc0202d12:	00013797          	auipc	a5,0x13
ffffffffc0202d16:	88e78793          	addi	a5,a5,-1906 # ffffffffc02155a0 <pgfault_num>
ffffffffc0202d1a:	54b69063          	bne	a3,a1,ffffffffc020325a <swap_init+0x71a>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202d1e:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc0202d22:	4398                	lw	a4,0(a5)
ffffffffc0202d24:	2701                	sext.w	a4,a4
ffffffffc0202d26:	3cd71a63          	bne	a4,a3,ffffffffc02030fa <swap_init+0x5ba>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202d2a:	6689                	lui	a3,0x2
ffffffffc0202d2c:	462d                	li	a2,11
ffffffffc0202d2e:	00c68023          	sb	a2,0(a3) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202d32:	4398                	lw	a4,0(a5)
ffffffffc0202d34:	4589                	li	a1,2
ffffffffc0202d36:	2701                	sext.w	a4,a4
ffffffffc0202d38:	4ab71163          	bne	a4,a1,ffffffffc02031da <swap_init+0x69a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202d3c:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202d40:	4394                	lw	a3,0(a5)
ffffffffc0202d42:	2681                	sext.w	a3,a3
ffffffffc0202d44:	4ae69b63          	bne	a3,a4,ffffffffc02031fa <swap_init+0x6ba>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202d48:	668d                	lui	a3,0x3
ffffffffc0202d4a:	4631                	li	a2,12
ffffffffc0202d4c:	00c68023          	sb	a2,0(a3) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202d50:	4398                	lw	a4,0(a5)
ffffffffc0202d52:	458d                	li	a1,3
ffffffffc0202d54:	2701                	sext.w	a4,a4
ffffffffc0202d56:	4cb71263          	bne	a4,a1,ffffffffc020321a <swap_init+0x6da>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202d5a:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202d5e:	4394                	lw	a3,0(a5)
ffffffffc0202d60:	2681                	sext.w	a3,a3
ffffffffc0202d62:	4ce69c63          	bne	a3,a4,ffffffffc020323a <swap_init+0x6fa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202d66:	6691                	lui	a3,0x4
ffffffffc0202d68:	4635                	li	a2,13
ffffffffc0202d6a:	00c68023          	sb	a2,0(a3) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202d6e:	4398                	lw	a4,0(a5)
ffffffffc0202d70:	2701                	sext.w	a4,a4
ffffffffc0202d72:	43471463          	bne	a4,s4,ffffffffc020319a <swap_init+0x65a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202d76:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202d7a:	439c                	lw	a5,0(a5)
ffffffffc0202d7c:	2781                	sext.w	a5,a5
ffffffffc0202d7e:	42e79e63          	bne	a5,a4,ffffffffc02031ba <swap_init+0x67a>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202d82:	481c                	lw	a5,16(s0)
ffffffffc0202d84:	2a079f63          	bnez	a5,ffffffffc0203042 <swap_init+0x502>
ffffffffc0202d88:	0000e797          	auipc	a5,0xe
ffffffffc0202d8c:	72878793          	addi	a5,a5,1832 # ffffffffc02114b0 <swap_in_seq_no>
ffffffffc0202d90:	0000e717          	auipc	a4,0xe
ffffffffc0202d94:	74870713          	addi	a4,a4,1864 # ffffffffc02114d8 <swap_out_seq_no>
ffffffffc0202d98:	0000e617          	auipc	a2,0xe
ffffffffc0202d9c:	74060613          	addi	a2,a2,1856 # ffffffffc02114d8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202da0:	56fd                	li	a3,-1
ffffffffc0202da2:	c394                	sw	a3,0(a5)
ffffffffc0202da4:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202da6:	0791                	addi	a5,a5,4
ffffffffc0202da8:	0711                	addi	a4,a4,4
ffffffffc0202daa:	fec79ce3          	bne	a5,a2,ffffffffc0202da2 <swap_init+0x262>
ffffffffc0202dae:	0000e717          	auipc	a4,0xe
ffffffffc0202db2:	6c270713          	addi	a4,a4,1730 # ffffffffc0211470 <check_ptep>
ffffffffc0202db6:	0000e697          	auipc	a3,0xe
ffffffffc0202dba:	6da68693          	addi	a3,a3,1754 # ffffffffc0211490 <check_rp>
ffffffffc0202dbe:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202dc0:	00012c17          	auipc	s8,0x12
ffffffffc0202dc4:	7a0c0c13          	addi	s8,s8,1952 # ffffffffc0215560 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202dc8:	00012c97          	auipc	s9,0x12
ffffffffc0202dcc:	7a0c8c93          	addi	s9,s9,1952 # ffffffffc0215568 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202dd0:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202dd4:	4601                	li	a2,0
ffffffffc0202dd6:	855a                	mv	a0,s6
ffffffffc0202dd8:	e836                	sd	a3,16(sp)
ffffffffc0202dda:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc0202ddc:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202dde:	d37fe0ef          	jal	ra,ffffffffc0201b14 <get_pte>
ffffffffc0202de2:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202de4:	65a2                	ld	a1,8(sp)
ffffffffc0202de6:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202de8:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc0202dea:	1c050063          	beqz	a0,ffffffffc0202faa <swap_init+0x46a>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202dee:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202df0:	0017f613          	andi	a2,a5,1
ffffffffc0202df4:	1c060b63          	beqz	a2,ffffffffc0202fca <swap_init+0x48a>
    if (PPN(pa) >= npage) {
ffffffffc0202df8:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202dfc:	078a                	slli	a5,a5,0x2
ffffffffc0202dfe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e00:	12c7fd63          	bgeu	a5,a2,ffffffffc0202f3a <swap_init+0x3fa>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e04:	00004617          	auipc	a2,0x4
ffffffffc0202e08:	ba460613          	addi	a2,a2,-1116 # ffffffffc02069a8 <nbase>
ffffffffc0202e0c:	00063a03          	ld	s4,0(a2)
ffffffffc0202e10:	000cb603          	ld	a2,0(s9)
ffffffffc0202e14:	6288                	ld	a0,0(a3)
ffffffffc0202e16:	414787b3          	sub	a5,a5,s4
ffffffffc0202e1a:	079a                	slli	a5,a5,0x6
ffffffffc0202e1c:	97b2                	add	a5,a5,a2
ffffffffc0202e1e:	12f51a63          	bne	a0,a5,ffffffffc0202f52 <swap_init+0x412>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202e22:	6785                	lui	a5,0x1
ffffffffc0202e24:	95be                	add	a1,a1,a5
ffffffffc0202e26:	6795                	lui	a5,0x5
ffffffffc0202e28:	0721                	addi	a4,a4,8
ffffffffc0202e2a:	06a1                	addi	a3,a3,8
ffffffffc0202e2c:	faf592e3          	bne	a1,a5,ffffffffc0202dd0 <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202e30:	00003517          	auipc	a0,0x3
ffffffffc0202e34:	18050513          	addi	a0,a0,384 # ffffffffc0205fb0 <default_pmm_manager+0x8d8>
ffffffffc0202e38:	b48fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    int ret = sm->check_swap();
ffffffffc0202e3c:	000bb783          	ld	a5,0(s7)
ffffffffc0202e40:	7f9c                	ld	a5,56(a5)
ffffffffc0202e42:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202e44:	30051b63          	bnez	a0,ffffffffc020315a <swap_init+0x61a>

     nr_free = nr_free_store;
ffffffffc0202e48:	77a2                	ld	a5,40(sp)
ffffffffc0202e4a:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc0202e4c:	67e2                	ld	a5,24(sp)
ffffffffc0202e4e:	e01c                	sd	a5,0(s0)
ffffffffc0202e50:	7782                	ld	a5,32(sp)
ffffffffc0202e52:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202e54:	6088                	ld	a0,0(s1)
ffffffffc0202e56:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202e58:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc0202e5a:	c41fe0ef          	jal	ra,ffffffffc0201a9a <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202e5e:	ff349be3          	bne	s1,s3,ffffffffc0202e54 <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202e62:	8556                	mv	a0,s5
ffffffffc0202e64:	2db000ef          	jal	ra,ffffffffc020393e <mm_destroy>

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202e68:	00012797          	auipc	a5,0x12
ffffffffc0202e6c:	6f078793          	addi	a5,a5,1776 # ffffffffc0215558 <boot_pgdir>
ffffffffc0202e70:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0202e72:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202e76:	639c                	ld	a5,0(a5)
ffffffffc0202e78:	078a                	slli	a5,a5,0x2
ffffffffc0202e7a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e7c:	0ae7fd63          	bgeu	a5,a4,ffffffffc0202f36 <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e80:	414786b3          	sub	a3,a5,s4
ffffffffc0202e84:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0202e86:	8699                	srai	a3,a3,0x6
ffffffffc0202e88:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0202e8a:	00c69793          	slli	a5,a3,0xc
ffffffffc0202e8e:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0202e90:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc0202e94:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202e96:	22e7f663          	bgeu	a5,a4,ffffffffc02030c2 <swap_init+0x582>
     free_page(pde2page(pd0[0]));
ffffffffc0202e9a:	00012797          	auipc	a5,0x12
ffffffffc0202e9e:	6de7b783          	ld	a5,1758(a5) # ffffffffc0215578 <va_pa_offset>
ffffffffc0202ea2:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ea4:	629c                	ld	a5,0(a3)
ffffffffc0202ea6:	078a                	slli	a5,a5,0x2
ffffffffc0202ea8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202eaa:	08e7f663          	bgeu	a5,a4,ffffffffc0202f36 <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc0202eae:	414787b3          	sub	a5,a5,s4
ffffffffc0202eb2:	079a                	slli	a5,a5,0x6
ffffffffc0202eb4:	953e                	add	a0,a0,a5
ffffffffc0202eb6:	4585                	li	a1,1
ffffffffc0202eb8:	be3fe0ef          	jal	ra,ffffffffc0201a9a <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ebc:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0202ec0:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ec4:	078a                	slli	a5,a5,0x2
ffffffffc0202ec6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ec8:	06e7f763          	bgeu	a5,a4,ffffffffc0202f36 <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ecc:	000cb503          	ld	a0,0(s9)
ffffffffc0202ed0:	414787b3          	sub	a5,a5,s4
ffffffffc0202ed4:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0202ed6:	4585                	li	a1,1
ffffffffc0202ed8:	953e                	add	a0,a0,a5
ffffffffc0202eda:	bc1fe0ef          	jal	ra,ffffffffc0201a9a <free_pages>
     pgdir[0] = 0;
ffffffffc0202ede:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0202ee2:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0202ee6:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202ee8:	00878a63          	beq	a5,s0,ffffffffc0202efc <swap_init+0x3bc>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202eec:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202ef0:	679c                	ld	a5,8(a5)
ffffffffc0202ef2:	3dfd                	addiw	s11,s11,-1
ffffffffc0202ef4:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202ef8:	fe879ae3          	bne	a5,s0,ffffffffc0202eec <swap_init+0x3ac>
     }
     assert(count==0);
ffffffffc0202efc:	1c0d9f63          	bnez	s11,ffffffffc02030da <swap_init+0x59a>
     assert(total==0);
ffffffffc0202f00:	1a0d1163          	bnez	s10,ffffffffc02030a2 <swap_init+0x562>

     cprintf("check_swap() succeeded!\n");
ffffffffc0202f04:	00003517          	auipc	a0,0x3
ffffffffc0202f08:	0fc50513          	addi	a0,a0,252 # ffffffffc0206000 <default_pmm_manager+0x928>
ffffffffc0202f0c:	a74fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0202f10:	b149                	j	ffffffffc0202b92 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f12:	4481                	li	s1,0
ffffffffc0202f14:	b1e5                	j	ffffffffc0202bfc <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc0202f16:	00002697          	auipc	a3,0x2
ffffffffc0202f1a:	40268693          	addi	a3,a3,1026 # ffffffffc0205318 <commands+0x728>
ffffffffc0202f1e:	00002617          	auipc	a2,0x2
ffffffffc0202f22:	40a60613          	addi	a2,a2,1034 # ffffffffc0205328 <commands+0x738>
ffffffffc0202f26:	0bd00593          	li	a1,189
ffffffffc0202f2a:	00003517          	auipc	a0,0x3
ffffffffc0202f2e:	e6e50513          	addi	a0,a0,-402 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc0202f32:	d14fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202f36:	befff0ef          	jal	ra,ffffffffc0202b24 <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc0202f3a:	00003617          	auipc	a2,0x3
ffffffffc0202f3e:	8a660613          	addi	a2,a2,-1882 # ffffffffc02057e0 <default_pmm_manager+0x108>
ffffffffc0202f42:	06200593          	li	a1,98
ffffffffc0202f46:	00002517          	auipc	a0,0x2
ffffffffc0202f4a:	7f250513          	addi	a0,a0,2034 # ffffffffc0205738 <default_pmm_manager+0x60>
ffffffffc0202f4e:	cf8fd0ef          	jal	ra,ffffffffc0200446 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202f52:	00003697          	auipc	a3,0x3
ffffffffc0202f56:	03668693          	addi	a3,a3,54 # ffffffffc0205f88 <default_pmm_manager+0x8b0>
ffffffffc0202f5a:	00002617          	auipc	a2,0x2
ffffffffc0202f5e:	3ce60613          	addi	a2,a2,974 # ffffffffc0205328 <commands+0x738>
ffffffffc0202f62:	0fd00593          	li	a1,253
ffffffffc0202f66:	00003517          	auipc	a0,0x3
ffffffffc0202f6a:	e3250513          	addi	a0,a0,-462 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc0202f6e:	cd8fd0ef          	jal	ra,ffffffffc0200446 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202f72:	00003697          	auipc	a3,0x3
ffffffffc0202f76:	f3668693          	addi	a3,a3,-202 # ffffffffc0205ea8 <default_pmm_manager+0x7d0>
ffffffffc0202f7a:	00002617          	auipc	a2,0x2
ffffffffc0202f7e:	3ae60613          	addi	a2,a2,942 # ffffffffc0205328 <commands+0x738>
ffffffffc0202f82:	0dd00593          	li	a1,221
ffffffffc0202f86:	00003517          	auipc	a0,0x3
ffffffffc0202f8a:	e1250513          	addi	a0,a0,-494 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc0202f8e:	cb8fd0ef          	jal	ra,ffffffffc0200446 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202f92:	00003617          	auipc	a2,0x3
ffffffffc0202f96:	de660613          	addi	a2,a2,-538 # ffffffffc0205d78 <default_pmm_manager+0x6a0>
ffffffffc0202f9a:	02a00593          	li	a1,42
ffffffffc0202f9e:	00003517          	auipc	a0,0x3
ffffffffc0202fa2:	dfa50513          	addi	a0,a0,-518 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc0202fa6:	ca0fd0ef          	jal	ra,ffffffffc0200446 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202faa:	00003697          	auipc	a3,0x3
ffffffffc0202fae:	fc668693          	addi	a3,a3,-58 # ffffffffc0205f70 <default_pmm_manager+0x898>
ffffffffc0202fb2:	00002617          	auipc	a2,0x2
ffffffffc0202fb6:	37660613          	addi	a2,a2,886 # ffffffffc0205328 <commands+0x738>
ffffffffc0202fba:	0fc00593          	li	a1,252
ffffffffc0202fbe:	00003517          	auipc	a0,0x3
ffffffffc0202fc2:	dda50513          	addi	a0,a0,-550 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc0202fc6:	c80fd0ef          	jal	ra,ffffffffc0200446 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202fca:	00003617          	auipc	a2,0x3
ffffffffc0202fce:	83660613          	addi	a2,a2,-1994 # ffffffffc0205800 <default_pmm_manager+0x128>
ffffffffc0202fd2:	07400593          	li	a1,116
ffffffffc0202fd6:	00002517          	auipc	a0,0x2
ffffffffc0202fda:	76250513          	addi	a0,a0,1890 # ffffffffc0205738 <default_pmm_manager+0x60>
ffffffffc0202fde:	c68fd0ef          	jal	ra,ffffffffc0200446 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202fe2:	00003697          	auipc	a3,0x3
ffffffffc0202fe6:	ede68693          	addi	a3,a3,-290 # ffffffffc0205ec0 <default_pmm_manager+0x7e8>
ffffffffc0202fea:	00002617          	auipc	a2,0x2
ffffffffc0202fee:	33e60613          	addi	a2,a2,830 # ffffffffc0205328 <commands+0x738>
ffffffffc0202ff2:	0de00593          	li	a1,222
ffffffffc0202ff6:	00003517          	auipc	a0,0x3
ffffffffc0202ffa:	da250513          	addi	a0,a0,-606 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc0202ffe:	c48fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203002:	00003697          	auipc	a3,0x3
ffffffffc0203006:	df668693          	addi	a3,a3,-522 # ffffffffc0205df8 <default_pmm_manager+0x720>
ffffffffc020300a:	00002617          	auipc	a2,0x2
ffffffffc020300e:	31e60613          	addi	a2,a2,798 # ffffffffc0205328 <commands+0x738>
ffffffffc0203012:	0c800593          	li	a1,200
ffffffffc0203016:	00003517          	auipc	a0,0x3
ffffffffc020301a:	d8250513          	addi	a0,a0,-638 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc020301e:	c28fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203022:	00002697          	auipc	a3,0x2
ffffffffc0203026:	33668693          	addi	a3,a3,822 # ffffffffc0205358 <commands+0x768>
ffffffffc020302a:	00002617          	auipc	a2,0x2
ffffffffc020302e:	2fe60613          	addi	a2,a2,766 # ffffffffc0205328 <commands+0x738>
ffffffffc0203032:	0c000593          	li	a1,192
ffffffffc0203036:	00003517          	auipc	a0,0x3
ffffffffc020303a:	d6250513          	addi	a0,a0,-670 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc020303e:	c08fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert( nr_free == 0);         
ffffffffc0203042:	00002697          	auipc	a3,0x2
ffffffffc0203046:	4be68693          	addi	a3,a3,1214 # ffffffffc0205500 <commands+0x910>
ffffffffc020304a:	00002617          	auipc	a2,0x2
ffffffffc020304e:	2de60613          	addi	a2,a2,734 # ffffffffc0205328 <commands+0x738>
ffffffffc0203052:	0f400593          	li	a1,244
ffffffffc0203056:	00003517          	auipc	a0,0x3
ffffffffc020305a:	d4250513          	addi	a0,a0,-702 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc020305e:	be8fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203062:	00003697          	auipc	a3,0x3
ffffffffc0203066:	dae68693          	addi	a3,a3,-594 # ffffffffc0205e10 <default_pmm_manager+0x738>
ffffffffc020306a:	00002617          	auipc	a2,0x2
ffffffffc020306e:	2be60613          	addi	a2,a2,702 # ffffffffc0205328 <commands+0x738>
ffffffffc0203072:	0cd00593          	li	a1,205
ffffffffc0203076:	00003517          	auipc	a0,0x3
ffffffffc020307a:	d2250513          	addi	a0,a0,-734 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc020307e:	bc8fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(mm != NULL);
ffffffffc0203082:	00003697          	auipc	a3,0x3
ffffffffc0203086:	d6668693          	addi	a3,a3,-666 # ffffffffc0205de8 <default_pmm_manager+0x710>
ffffffffc020308a:	00002617          	auipc	a2,0x2
ffffffffc020308e:	29e60613          	addi	a2,a2,670 # ffffffffc0205328 <commands+0x738>
ffffffffc0203092:	0c500593          	li	a1,197
ffffffffc0203096:	00003517          	auipc	a0,0x3
ffffffffc020309a:	d0250513          	addi	a0,a0,-766 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc020309e:	ba8fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(total==0);
ffffffffc02030a2:	00003697          	auipc	a3,0x3
ffffffffc02030a6:	f4e68693          	addi	a3,a3,-178 # ffffffffc0205ff0 <default_pmm_manager+0x918>
ffffffffc02030aa:	00002617          	auipc	a2,0x2
ffffffffc02030ae:	27e60613          	addi	a2,a2,638 # ffffffffc0205328 <commands+0x738>
ffffffffc02030b2:	11d00593          	li	a1,285
ffffffffc02030b6:	00003517          	auipc	a0,0x3
ffffffffc02030ba:	ce250513          	addi	a0,a0,-798 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc02030be:	b88fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc02030c2:	00002617          	auipc	a2,0x2
ffffffffc02030c6:	64e60613          	addi	a2,a2,1614 # ffffffffc0205710 <default_pmm_manager+0x38>
ffffffffc02030ca:	06900593          	li	a1,105
ffffffffc02030ce:	00002517          	auipc	a0,0x2
ffffffffc02030d2:	66a50513          	addi	a0,a0,1642 # ffffffffc0205738 <default_pmm_manager+0x60>
ffffffffc02030d6:	b70fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(count==0);
ffffffffc02030da:	00003697          	auipc	a3,0x3
ffffffffc02030de:	f0668693          	addi	a3,a3,-250 # ffffffffc0205fe0 <default_pmm_manager+0x908>
ffffffffc02030e2:	00002617          	auipc	a2,0x2
ffffffffc02030e6:	24660613          	addi	a2,a2,582 # ffffffffc0205328 <commands+0x738>
ffffffffc02030ea:	11c00593          	li	a1,284
ffffffffc02030ee:	00003517          	auipc	a0,0x3
ffffffffc02030f2:	caa50513          	addi	a0,a0,-854 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc02030f6:	b50fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==1);
ffffffffc02030fa:	00003697          	auipc	a3,0x3
ffffffffc02030fe:	e3668693          	addi	a3,a3,-458 # ffffffffc0205f30 <default_pmm_manager+0x858>
ffffffffc0203102:	00002617          	auipc	a2,0x2
ffffffffc0203106:	22660613          	addi	a2,a2,550 # ffffffffc0205328 <commands+0x738>
ffffffffc020310a:	09600593          	li	a1,150
ffffffffc020310e:	00003517          	auipc	a0,0x3
ffffffffc0203112:	c8a50513          	addi	a0,a0,-886 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc0203116:	b30fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020311a:	00003697          	auipc	a3,0x3
ffffffffc020311e:	dc668693          	addi	a3,a3,-570 # ffffffffc0205ee0 <default_pmm_manager+0x808>
ffffffffc0203122:	00002617          	auipc	a2,0x2
ffffffffc0203126:	20660613          	addi	a2,a2,518 # ffffffffc0205328 <commands+0x738>
ffffffffc020312a:	0eb00593          	li	a1,235
ffffffffc020312e:	00003517          	auipc	a0,0x3
ffffffffc0203132:	c6a50513          	addi	a0,a0,-918 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc0203136:	b10fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc020313a:	00003697          	auipc	a3,0x3
ffffffffc020313e:	d2e68693          	addi	a3,a3,-722 # ffffffffc0205e68 <default_pmm_manager+0x790>
ffffffffc0203142:	00002617          	auipc	a2,0x2
ffffffffc0203146:	1e660613          	addi	a2,a2,486 # ffffffffc0205328 <commands+0x738>
ffffffffc020314a:	0d800593          	li	a1,216
ffffffffc020314e:	00003517          	auipc	a0,0x3
ffffffffc0203152:	c4a50513          	addi	a0,a0,-950 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc0203156:	af0fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(ret==0);
ffffffffc020315a:	00003697          	auipc	a3,0x3
ffffffffc020315e:	e7e68693          	addi	a3,a3,-386 # ffffffffc0205fd8 <default_pmm_manager+0x900>
ffffffffc0203162:	00002617          	auipc	a2,0x2
ffffffffc0203166:	1c660613          	addi	a2,a2,454 # ffffffffc0205328 <commands+0x738>
ffffffffc020316a:	10300593          	li	a1,259
ffffffffc020316e:	00003517          	auipc	a0,0x3
ffffffffc0203172:	c2a50513          	addi	a0,a0,-982 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc0203176:	ad0fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(vma != NULL);
ffffffffc020317a:	00003697          	auipc	a3,0x3
ffffffffc020317e:	ca668693          	addi	a3,a3,-858 # ffffffffc0205e20 <default_pmm_manager+0x748>
ffffffffc0203182:	00002617          	auipc	a2,0x2
ffffffffc0203186:	1a660613          	addi	a2,a2,422 # ffffffffc0205328 <commands+0x738>
ffffffffc020318a:	0d000593          	li	a1,208
ffffffffc020318e:	00003517          	auipc	a0,0x3
ffffffffc0203192:	c0a50513          	addi	a0,a0,-1014 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc0203196:	ab0fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==4);
ffffffffc020319a:	00003697          	auipc	a3,0x3
ffffffffc020319e:	dc668693          	addi	a3,a3,-570 # ffffffffc0205f60 <default_pmm_manager+0x888>
ffffffffc02031a2:	00002617          	auipc	a2,0x2
ffffffffc02031a6:	18660613          	addi	a2,a2,390 # ffffffffc0205328 <commands+0x738>
ffffffffc02031aa:	0a000593          	li	a1,160
ffffffffc02031ae:	00003517          	auipc	a0,0x3
ffffffffc02031b2:	bea50513          	addi	a0,a0,-1046 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc02031b6:	a90fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==4);
ffffffffc02031ba:	00003697          	auipc	a3,0x3
ffffffffc02031be:	da668693          	addi	a3,a3,-602 # ffffffffc0205f60 <default_pmm_manager+0x888>
ffffffffc02031c2:	00002617          	auipc	a2,0x2
ffffffffc02031c6:	16660613          	addi	a2,a2,358 # ffffffffc0205328 <commands+0x738>
ffffffffc02031ca:	0a200593          	li	a1,162
ffffffffc02031ce:	00003517          	auipc	a0,0x3
ffffffffc02031d2:	bca50513          	addi	a0,a0,-1078 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc02031d6:	a70fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==2);
ffffffffc02031da:	00003697          	auipc	a3,0x3
ffffffffc02031de:	d6668693          	addi	a3,a3,-666 # ffffffffc0205f40 <default_pmm_manager+0x868>
ffffffffc02031e2:	00002617          	auipc	a2,0x2
ffffffffc02031e6:	14660613          	addi	a2,a2,326 # ffffffffc0205328 <commands+0x738>
ffffffffc02031ea:	09800593          	li	a1,152
ffffffffc02031ee:	00003517          	auipc	a0,0x3
ffffffffc02031f2:	baa50513          	addi	a0,a0,-1110 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc02031f6:	a50fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==2);
ffffffffc02031fa:	00003697          	auipc	a3,0x3
ffffffffc02031fe:	d4668693          	addi	a3,a3,-698 # ffffffffc0205f40 <default_pmm_manager+0x868>
ffffffffc0203202:	00002617          	auipc	a2,0x2
ffffffffc0203206:	12660613          	addi	a2,a2,294 # ffffffffc0205328 <commands+0x738>
ffffffffc020320a:	09a00593          	li	a1,154
ffffffffc020320e:	00003517          	auipc	a0,0x3
ffffffffc0203212:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc0203216:	a30fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==3);
ffffffffc020321a:	00003697          	auipc	a3,0x3
ffffffffc020321e:	d3668693          	addi	a3,a3,-714 # ffffffffc0205f50 <default_pmm_manager+0x878>
ffffffffc0203222:	00002617          	auipc	a2,0x2
ffffffffc0203226:	10660613          	addi	a2,a2,262 # ffffffffc0205328 <commands+0x738>
ffffffffc020322a:	09c00593          	li	a1,156
ffffffffc020322e:	00003517          	auipc	a0,0x3
ffffffffc0203232:	b6a50513          	addi	a0,a0,-1174 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc0203236:	a10fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==3);
ffffffffc020323a:	00003697          	auipc	a3,0x3
ffffffffc020323e:	d1668693          	addi	a3,a3,-746 # ffffffffc0205f50 <default_pmm_manager+0x878>
ffffffffc0203242:	00002617          	auipc	a2,0x2
ffffffffc0203246:	0e660613          	addi	a2,a2,230 # ffffffffc0205328 <commands+0x738>
ffffffffc020324a:	09e00593          	li	a1,158
ffffffffc020324e:	00003517          	auipc	a0,0x3
ffffffffc0203252:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc0203256:	9f0fd0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(pgfault_num==1);
ffffffffc020325a:	00003697          	auipc	a3,0x3
ffffffffc020325e:	cd668693          	addi	a3,a3,-810 # ffffffffc0205f30 <default_pmm_manager+0x858>
ffffffffc0203262:	00002617          	auipc	a2,0x2
ffffffffc0203266:	0c660613          	addi	a2,a2,198 # ffffffffc0205328 <commands+0x738>
ffffffffc020326a:	09400593          	li	a1,148
ffffffffc020326e:	00003517          	auipc	a0,0x3
ffffffffc0203272:	b2a50513          	addi	a0,a0,-1238 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc0203276:	9d0fd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020327a <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc020327a:	00012797          	auipc	a5,0x12
ffffffffc020327e:	30e7b783          	ld	a5,782(a5) # ffffffffc0215588 <sm>
ffffffffc0203282:	6b9c                	ld	a5,16(a5)
ffffffffc0203284:	8782                	jr	a5

ffffffffc0203286 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203286:	00012797          	auipc	a5,0x12
ffffffffc020328a:	3027b783          	ld	a5,770(a5) # ffffffffc0215588 <sm>
ffffffffc020328e:	739c                	ld	a5,32(a5)
ffffffffc0203290:	8782                	jr	a5

ffffffffc0203292 <swap_out>:
{
ffffffffc0203292:	711d                	addi	sp,sp,-96
ffffffffc0203294:	ec86                	sd	ra,88(sp)
ffffffffc0203296:	e8a2                	sd	s0,80(sp)
ffffffffc0203298:	e4a6                	sd	s1,72(sp)
ffffffffc020329a:	e0ca                	sd	s2,64(sp)
ffffffffc020329c:	fc4e                	sd	s3,56(sp)
ffffffffc020329e:	f852                	sd	s4,48(sp)
ffffffffc02032a0:	f456                	sd	s5,40(sp)
ffffffffc02032a2:	f05a                	sd	s6,32(sp)
ffffffffc02032a4:	ec5e                	sd	s7,24(sp)
ffffffffc02032a6:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc02032a8:	cde9                	beqz	a1,ffffffffc0203382 <swap_out+0xf0>
ffffffffc02032aa:	8a2e                	mv	s4,a1
ffffffffc02032ac:	892a                	mv	s2,a0
ffffffffc02032ae:	8ab2                	mv	s5,a2
ffffffffc02032b0:	4401                	li	s0,0
ffffffffc02032b2:	00012997          	auipc	s3,0x12
ffffffffc02032b6:	2d698993          	addi	s3,s3,726 # ffffffffc0215588 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02032ba:	00003b17          	auipc	s6,0x3
ffffffffc02032be:	dc6b0b13          	addi	s6,s6,-570 # ffffffffc0206080 <default_pmm_manager+0x9a8>
                    cprintf("SWAP: failed to save\n");
ffffffffc02032c2:	00003b97          	auipc	s7,0x3
ffffffffc02032c6:	da6b8b93          	addi	s7,s7,-602 # ffffffffc0206068 <default_pmm_manager+0x990>
ffffffffc02032ca:	a825                	j	ffffffffc0203302 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02032cc:	67a2                	ld	a5,8(sp)
ffffffffc02032ce:	8626                	mv	a2,s1
ffffffffc02032d0:	85a2                	mv	a1,s0
ffffffffc02032d2:	7f94                	ld	a3,56(a5)
ffffffffc02032d4:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc02032d6:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02032d8:	82b1                	srli	a3,a3,0xc
ffffffffc02032da:	0685                	addi	a3,a3,1
ffffffffc02032dc:	ea5fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02032e0:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc02032e2:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02032e4:	7d1c                	ld	a5,56(a0)
ffffffffc02032e6:	83b1                	srli	a5,a5,0xc
ffffffffc02032e8:	0785                	addi	a5,a5,1
ffffffffc02032ea:	07a2                	slli	a5,a5,0x8
ffffffffc02032ec:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc02032f0:	faafe0ef          	jal	ra,ffffffffc0201a9a <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc02032f4:	01893503          	ld	a0,24(s2)
ffffffffc02032f8:	85a6                	mv	a1,s1
ffffffffc02032fa:	f6cff0ef          	jal	ra,ffffffffc0202a66 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc02032fe:	048a0d63          	beq	s4,s0,ffffffffc0203358 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203302:	0009b783          	ld	a5,0(s3)
ffffffffc0203306:	8656                	mv	a2,s5
ffffffffc0203308:	002c                	addi	a1,sp,8
ffffffffc020330a:	7b9c                	ld	a5,48(a5)
ffffffffc020330c:	854a                	mv	a0,s2
ffffffffc020330e:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203310:	e12d                	bnez	a0,ffffffffc0203372 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203312:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203314:	01893503          	ld	a0,24(s2)
ffffffffc0203318:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc020331a:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020331c:	85a6                	mv	a1,s1
ffffffffc020331e:	ff6fe0ef          	jal	ra,ffffffffc0201b14 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203322:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203324:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203326:	8b85                	andi	a5,a5,1
ffffffffc0203328:	cfb9                	beqz	a5,ffffffffc0203386 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc020332a:	65a2                	ld	a1,8(sp)
ffffffffc020332c:	7d9c                	ld	a5,56(a1)
ffffffffc020332e:	83b1                	srli	a5,a5,0xc
ffffffffc0203330:	0785                	addi	a5,a5,1
ffffffffc0203332:	00879513          	slli	a0,a5,0x8
ffffffffc0203336:	4ff000ef          	jal	ra,ffffffffc0204034 <swapfs_write>
ffffffffc020333a:	d949                	beqz	a0,ffffffffc02032cc <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc020333c:	855e                	mv	a0,s7
ffffffffc020333e:	e43fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203342:	0009b783          	ld	a5,0(s3)
ffffffffc0203346:	6622                	ld	a2,8(sp)
ffffffffc0203348:	4681                	li	a3,0
ffffffffc020334a:	739c                	ld	a5,32(a5)
ffffffffc020334c:	85a6                	mv	a1,s1
ffffffffc020334e:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203350:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203352:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203354:	fa8a17e3          	bne	s4,s0,ffffffffc0203302 <swap_out+0x70>
}
ffffffffc0203358:	60e6                	ld	ra,88(sp)
ffffffffc020335a:	8522                	mv	a0,s0
ffffffffc020335c:	6446                	ld	s0,80(sp)
ffffffffc020335e:	64a6                	ld	s1,72(sp)
ffffffffc0203360:	6906                	ld	s2,64(sp)
ffffffffc0203362:	79e2                	ld	s3,56(sp)
ffffffffc0203364:	7a42                	ld	s4,48(sp)
ffffffffc0203366:	7aa2                	ld	s5,40(sp)
ffffffffc0203368:	7b02                	ld	s6,32(sp)
ffffffffc020336a:	6be2                	ld	s7,24(sp)
ffffffffc020336c:	6c42                	ld	s8,16(sp)
ffffffffc020336e:	6125                	addi	sp,sp,96
ffffffffc0203370:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203372:	85a2                	mv	a1,s0
ffffffffc0203374:	00003517          	auipc	a0,0x3
ffffffffc0203378:	cac50513          	addi	a0,a0,-852 # ffffffffc0206020 <default_pmm_manager+0x948>
ffffffffc020337c:	e05fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                  break;
ffffffffc0203380:	bfe1                	j	ffffffffc0203358 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203382:	4401                	li	s0,0
ffffffffc0203384:	bfd1                	j	ffffffffc0203358 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203386:	00003697          	auipc	a3,0x3
ffffffffc020338a:	cca68693          	addi	a3,a3,-822 # ffffffffc0206050 <default_pmm_manager+0x978>
ffffffffc020338e:	00002617          	auipc	a2,0x2
ffffffffc0203392:	f9a60613          	addi	a2,a2,-102 # ffffffffc0205328 <commands+0x738>
ffffffffc0203396:	06900593          	li	a1,105
ffffffffc020339a:	00003517          	auipc	a0,0x3
ffffffffc020339e:	9fe50513          	addi	a0,a0,-1538 # ffffffffc0205d98 <default_pmm_manager+0x6c0>
ffffffffc02033a2:	8a4fd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02033a6 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc02033a6:	0000e797          	auipc	a5,0xe
ffffffffc02033aa:	15a78793          	addi	a5,a5,346 # ffffffffc0211500 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc02033ae:	f51c                	sd	a5,40(a0)
ffffffffc02033b0:	e79c                	sd	a5,8(a5)
ffffffffc02033b2:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc02033b4:	4501                	li	a0,0
ffffffffc02033b6:	8082                	ret

ffffffffc02033b8 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc02033b8:	4501                	li	a0,0
ffffffffc02033ba:	8082                	ret

ffffffffc02033bc <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02033bc:	4501                	li	a0,0
ffffffffc02033be:	8082                	ret

ffffffffc02033c0 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02033c0:	4501                	li	a0,0
ffffffffc02033c2:	8082                	ret

ffffffffc02033c4 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc02033c4:	711d                	addi	sp,sp,-96
ffffffffc02033c6:	fc4e                	sd	s3,56(sp)
ffffffffc02033c8:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02033ca:	00003517          	auipc	a0,0x3
ffffffffc02033ce:	cf650513          	addi	a0,a0,-778 # ffffffffc02060c0 <default_pmm_manager+0x9e8>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02033d2:	698d                	lui	s3,0x3
ffffffffc02033d4:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc02033d6:	e0ca                	sd	s2,64(sp)
ffffffffc02033d8:	ec86                	sd	ra,88(sp)
ffffffffc02033da:	e8a2                	sd	s0,80(sp)
ffffffffc02033dc:	e4a6                	sd	s1,72(sp)
ffffffffc02033de:	f456                	sd	s5,40(sp)
ffffffffc02033e0:	f05a                	sd	s6,32(sp)
ffffffffc02033e2:	ec5e                	sd	s7,24(sp)
ffffffffc02033e4:	e862                	sd	s8,16(sp)
ffffffffc02033e6:	e466                	sd	s9,8(sp)
ffffffffc02033e8:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02033ea:	d97fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02033ee:	01498023          	sb	s4,0(s3) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc02033f2:	00012917          	auipc	s2,0x12
ffffffffc02033f6:	1ae92903          	lw	s2,430(s2) # ffffffffc02155a0 <pgfault_num>
ffffffffc02033fa:	4791                	li	a5,4
ffffffffc02033fc:	14f91e63          	bne	s2,a5,ffffffffc0203558 <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203400:	00003517          	auipc	a0,0x3
ffffffffc0203404:	d0050513          	addi	a0,a0,-768 # ffffffffc0206100 <default_pmm_manager+0xa28>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203408:	6a85                	lui	s5,0x1
ffffffffc020340a:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020340c:	d75fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203410:	00012417          	auipc	s0,0x12
ffffffffc0203414:	19040413          	addi	s0,s0,400 # ffffffffc02155a0 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203418:	016a8023          	sb	s6,0(s5) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc020341c:	4004                	lw	s1,0(s0)
ffffffffc020341e:	2481                	sext.w	s1,s1
ffffffffc0203420:	2b249c63          	bne	s1,s2,ffffffffc02036d8 <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203424:	00003517          	auipc	a0,0x3
ffffffffc0203428:	d0450513          	addi	a0,a0,-764 # ffffffffc0206128 <default_pmm_manager+0xa50>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020342c:	6b91                	lui	s7,0x4
ffffffffc020342e:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203430:	d51fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203434:	018b8023          	sb	s8,0(s7) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0203438:	00042903          	lw	s2,0(s0)
ffffffffc020343c:	2901                	sext.w	s2,s2
ffffffffc020343e:	26991d63          	bne	s2,s1,ffffffffc02036b8 <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203442:	00003517          	auipc	a0,0x3
ffffffffc0203446:	d0e50513          	addi	a0,a0,-754 # ffffffffc0206150 <default_pmm_manager+0xa78>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020344a:	6c89                	lui	s9,0x2
ffffffffc020344c:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020344e:	d33fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203452:	01ac8023          	sb	s10,0(s9) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc0203456:	401c                	lw	a5,0(s0)
ffffffffc0203458:	2781                	sext.w	a5,a5
ffffffffc020345a:	23279f63          	bne	a5,s2,ffffffffc0203698 <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc020345e:	00003517          	auipc	a0,0x3
ffffffffc0203462:	d1a50513          	addi	a0,a0,-742 # ffffffffc0206178 <default_pmm_manager+0xaa0>
ffffffffc0203466:	d1bfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020346a:	6795                	lui	a5,0x5
ffffffffc020346c:	4739                	li	a4,14
ffffffffc020346e:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203472:	4004                	lw	s1,0(s0)
ffffffffc0203474:	4795                	li	a5,5
ffffffffc0203476:	2481                	sext.w	s1,s1
ffffffffc0203478:	20f49063          	bne	s1,a5,ffffffffc0203678 <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020347c:	00003517          	auipc	a0,0x3
ffffffffc0203480:	cd450513          	addi	a0,a0,-812 # ffffffffc0206150 <default_pmm_manager+0xa78>
ffffffffc0203484:	cfdfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203488:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc020348c:	401c                	lw	a5,0(s0)
ffffffffc020348e:	2781                	sext.w	a5,a5
ffffffffc0203490:	1c979463          	bne	a5,s1,ffffffffc0203658 <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203494:	00003517          	auipc	a0,0x3
ffffffffc0203498:	c6c50513          	addi	a0,a0,-916 # ffffffffc0206100 <default_pmm_manager+0xa28>
ffffffffc020349c:	ce5fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02034a0:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc02034a4:	401c                	lw	a5,0(s0)
ffffffffc02034a6:	4719                	li	a4,6
ffffffffc02034a8:	2781                	sext.w	a5,a5
ffffffffc02034aa:	18e79763          	bne	a5,a4,ffffffffc0203638 <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02034ae:	00003517          	auipc	a0,0x3
ffffffffc02034b2:	ca250513          	addi	a0,a0,-862 # ffffffffc0206150 <default_pmm_manager+0xa78>
ffffffffc02034b6:	ccbfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02034ba:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc02034be:	401c                	lw	a5,0(s0)
ffffffffc02034c0:	471d                	li	a4,7
ffffffffc02034c2:	2781                	sext.w	a5,a5
ffffffffc02034c4:	14e79a63          	bne	a5,a4,ffffffffc0203618 <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02034c8:	00003517          	auipc	a0,0x3
ffffffffc02034cc:	bf850513          	addi	a0,a0,-1032 # ffffffffc02060c0 <default_pmm_manager+0x9e8>
ffffffffc02034d0:	cb1fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02034d4:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc02034d8:	401c                	lw	a5,0(s0)
ffffffffc02034da:	4721                	li	a4,8
ffffffffc02034dc:	2781                	sext.w	a5,a5
ffffffffc02034de:	10e79d63          	bne	a5,a4,ffffffffc02035f8 <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02034e2:	00003517          	auipc	a0,0x3
ffffffffc02034e6:	c4650513          	addi	a0,a0,-954 # ffffffffc0206128 <default_pmm_manager+0xa50>
ffffffffc02034ea:	c97fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02034ee:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc02034f2:	401c                	lw	a5,0(s0)
ffffffffc02034f4:	4725                	li	a4,9
ffffffffc02034f6:	2781                	sext.w	a5,a5
ffffffffc02034f8:	0ee79063          	bne	a5,a4,ffffffffc02035d8 <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02034fc:	00003517          	auipc	a0,0x3
ffffffffc0203500:	c7c50513          	addi	a0,a0,-900 # ffffffffc0206178 <default_pmm_manager+0xaa0>
ffffffffc0203504:	c7dfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203508:	6795                	lui	a5,0x5
ffffffffc020350a:	4739                	li	a4,14
ffffffffc020350c:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc0203510:	4004                	lw	s1,0(s0)
ffffffffc0203512:	47a9                	li	a5,10
ffffffffc0203514:	2481                	sext.w	s1,s1
ffffffffc0203516:	0af49163          	bne	s1,a5,ffffffffc02035b8 <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020351a:	00003517          	auipc	a0,0x3
ffffffffc020351e:	be650513          	addi	a0,a0,-1050 # ffffffffc0206100 <default_pmm_manager+0xa28>
ffffffffc0203522:	c5ffc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203526:	6785                	lui	a5,0x1
ffffffffc0203528:	0007c783          	lbu	a5,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc020352c:	06979663          	bne	a5,s1,ffffffffc0203598 <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0203530:	401c                	lw	a5,0(s0)
ffffffffc0203532:	472d                	li	a4,11
ffffffffc0203534:	2781                	sext.w	a5,a5
ffffffffc0203536:	04e79163          	bne	a5,a4,ffffffffc0203578 <_fifo_check_swap+0x1b4>
}
ffffffffc020353a:	60e6                	ld	ra,88(sp)
ffffffffc020353c:	6446                	ld	s0,80(sp)
ffffffffc020353e:	64a6                	ld	s1,72(sp)
ffffffffc0203540:	6906                	ld	s2,64(sp)
ffffffffc0203542:	79e2                	ld	s3,56(sp)
ffffffffc0203544:	7a42                	ld	s4,48(sp)
ffffffffc0203546:	7aa2                	ld	s5,40(sp)
ffffffffc0203548:	7b02                	ld	s6,32(sp)
ffffffffc020354a:	6be2                	ld	s7,24(sp)
ffffffffc020354c:	6c42                	ld	s8,16(sp)
ffffffffc020354e:	6ca2                	ld	s9,8(sp)
ffffffffc0203550:	6d02                	ld	s10,0(sp)
ffffffffc0203552:	4501                	li	a0,0
ffffffffc0203554:	6125                	addi	sp,sp,96
ffffffffc0203556:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203558:	00003697          	auipc	a3,0x3
ffffffffc020355c:	a0868693          	addi	a3,a3,-1528 # ffffffffc0205f60 <default_pmm_manager+0x888>
ffffffffc0203560:	00002617          	auipc	a2,0x2
ffffffffc0203564:	dc860613          	addi	a2,a2,-568 # ffffffffc0205328 <commands+0x738>
ffffffffc0203568:	05100593          	li	a1,81
ffffffffc020356c:	00003517          	auipc	a0,0x3
ffffffffc0203570:	b7c50513          	addi	a0,a0,-1156 # ffffffffc02060e8 <default_pmm_manager+0xa10>
ffffffffc0203574:	ed3fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==11);
ffffffffc0203578:	00003697          	auipc	a3,0x3
ffffffffc020357c:	cb068693          	addi	a3,a3,-848 # ffffffffc0206228 <default_pmm_manager+0xb50>
ffffffffc0203580:	00002617          	auipc	a2,0x2
ffffffffc0203584:	da860613          	addi	a2,a2,-600 # ffffffffc0205328 <commands+0x738>
ffffffffc0203588:	07300593          	li	a1,115
ffffffffc020358c:	00003517          	auipc	a0,0x3
ffffffffc0203590:	b5c50513          	addi	a0,a0,-1188 # ffffffffc02060e8 <default_pmm_manager+0xa10>
ffffffffc0203594:	eb3fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203598:	00003697          	auipc	a3,0x3
ffffffffc020359c:	c6868693          	addi	a3,a3,-920 # ffffffffc0206200 <default_pmm_manager+0xb28>
ffffffffc02035a0:	00002617          	auipc	a2,0x2
ffffffffc02035a4:	d8860613          	addi	a2,a2,-632 # ffffffffc0205328 <commands+0x738>
ffffffffc02035a8:	07100593          	li	a1,113
ffffffffc02035ac:	00003517          	auipc	a0,0x3
ffffffffc02035b0:	b3c50513          	addi	a0,a0,-1220 # ffffffffc02060e8 <default_pmm_manager+0xa10>
ffffffffc02035b4:	e93fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==10);
ffffffffc02035b8:	00003697          	auipc	a3,0x3
ffffffffc02035bc:	c3868693          	addi	a3,a3,-968 # ffffffffc02061f0 <default_pmm_manager+0xb18>
ffffffffc02035c0:	00002617          	auipc	a2,0x2
ffffffffc02035c4:	d6860613          	addi	a2,a2,-664 # ffffffffc0205328 <commands+0x738>
ffffffffc02035c8:	06f00593          	li	a1,111
ffffffffc02035cc:	00003517          	auipc	a0,0x3
ffffffffc02035d0:	b1c50513          	addi	a0,a0,-1252 # ffffffffc02060e8 <default_pmm_manager+0xa10>
ffffffffc02035d4:	e73fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==9);
ffffffffc02035d8:	00003697          	auipc	a3,0x3
ffffffffc02035dc:	c0868693          	addi	a3,a3,-1016 # ffffffffc02061e0 <default_pmm_manager+0xb08>
ffffffffc02035e0:	00002617          	auipc	a2,0x2
ffffffffc02035e4:	d4860613          	addi	a2,a2,-696 # ffffffffc0205328 <commands+0x738>
ffffffffc02035e8:	06c00593          	li	a1,108
ffffffffc02035ec:	00003517          	auipc	a0,0x3
ffffffffc02035f0:	afc50513          	addi	a0,a0,-1284 # ffffffffc02060e8 <default_pmm_manager+0xa10>
ffffffffc02035f4:	e53fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==8);
ffffffffc02035f8:	00003697          	auipc	a3,0x3
ffffffffc02035fc:	bd868693          	addi	a3,a3,-1064 # ffffffffc02061d0 <default_pmm_manager+0xaf8>
ffffffffc0203600:	00002617          	auipc	a2,0x2
ffffffffc0203604:	d2860613          	addi	a2,a2,-728 # ffffffffc0205328 <commands+0x738>
ffffffffc0203608:	06900593          	li	a1,105
ffffffffc020360c:	00003517          	auipc	a0,0x3
ffffffffc0203610:	adc50513          	addi	a0,a0,-1316 # ffffffffc02060e8 <default_pmm_manager+0xa10>
ffffffffc0203614:	e33fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==7);
ffffffffc0203618:	00003697          	auipc	a3,0x3
ffffffffc020361c:	ba868693          	addi	a3,a3,-1112 # ffffffffc02061c0 <default_pmm_manager+0xae8>
ffffffffc0203620:	00002617          	auipc	a2,0x2
ffffffffc0203624:	d0860613          	addi	a2,a2,-760 # ffffffffc0205328 <commands+0x738>
ffffffffc0203628:	06600593          	li	a1,102
ffffffffc020362c:	00003517          	auipc	a0,0x3
ffffffffc0203630:	abc50513          	addi	a0,a0,-1348 # ffffffffc02060e8 <default_pmm_manager+0xa10>
ffffffffc0203634:	e13fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==6);
ffffffffc0203638:	00003697          	auipc	a3,0x3
ffffffffc020363c:	b7868693          	addi	a3,a3,-1160 # ffffffffc02061b0 <default_pmm_manager+0xad8>
ffffffffc0203640:	00002617          	auipc	a2,0x2
ffffffffc0203644:	ce860613          	addi	a2,a2,-792 # ffffffffc0205328 <commands+0x738>
ffffffffc0203648:	06300593          	li	a1,99
ffffffffc020364c:	00003517          	auipc	a0,0x3
ffffffffc0203650:	a9c50513          	addi	a0,a0,-1380 # ffffffffc02060e8 <default_pmm_manager+0xa10>
ffffffffc0203654:	df3fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==5);
ffffffffc0203658:	00003697          	auipc	a3,0x3
ffffffffc020365c:	b4868693          	addi	a3,a3,-1208 # ffffffffc02061a0 <default_pmm_manager+0xac8>
ffffffffc0203660:	00002617          	auipc	a2,0x2
ffffffffc0203664:	cc860613          	addi	a2,a2,-824 # ffffffffc0205328 <commands+0x738>
ffffffffc0203668:	06000593          	li	a1,96
ffffffffc020366c:	00003517          	auipc	a0,0x3
ffffffffc0203670:	a7c50513          	addi	a0,a0,-1412 # ffffffffc02060e8 <default_pmm_manager+0xa10>
ffffffffc0203674:	dd3fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==5);
ffffffffc0203678:	00003697          	auipc	a3,0x3
ffffffffc020367c:	b2868693          	addi	a3,a3,-1240 # ffffffffc02061a0 <default_pmm_manager+0xac8>
ffffffffc0203680:	00002617          	auipc	a2,0x2
ffffffffc0203684:	ca860613          	addi	a2,a2,-856 # ffffffffc0205328 <commands+0x738>
ffffffffc0203688:	05d00593          	li	a1,93
ffffffffc020368c:	00003517          	auipc	a0,0x3
ffffffffc0203690:	a5c50513          	addi	a0,a0,-1444 # ffffffffc02060e8 <default_pmm_manager+0xa10>
ffffffffc0203694:	db3fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==4);
ffffffffc0203698:	00003697          	auipc	a3,0x3
ffffffffc020369c:	8c868693          	addi	a3,a3,-1848 # ffffffffc0205f60 <default_pmm_manager+0x888>
ffffffffc02036a0:	00002617          	auipc	a2,0x2
ffffffffc02036a4:	c8860613          	addi	a2,a2,-888 # ffffffffc0205328 <commands+0x738>
ffffffffc02036a8:	05a00593          	li	a1,90
ffffffffc02036ac:	00003517          	auipc	a0,0x3
ffffffffc02036b0:	a3c50513          	addi	a0,a0,-1476 # ffffffffc02060e8 <default_pmm_manager+0xa10>
ffffffffc02036b4:	d93fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==4);
ffffffffc02036b8:	00003697          	auipc	a3,0x3
ffffffffc02036bc:	8a868693          	addi	a3,a3,-1880 # ffffffffc0205f60 <default_pmm_manager+0x888>
ffffffffc02036c0:	00002617          	auipc	a2,0x2
ffffffffc02036c4:	c6860613          	addi	a2,a2,-920 # ffffffffc0205328 <commands+0x738>
ffffffffc02036c8:	05700593          	li	a1,87
ffffffffc02036cc:	00003517          	auipc	a0,0x3
ffffffffc02036d0:	a1c50513          	addi	a0,a0,-1508 # ffffffffc02060e8 <default_pmm_manager+0xa10>
ffffffffc02036d4:	d73fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==4);
ffffffffc02036d8:	00003697          	auipc	a3,0x3
ffffffffc02036dc:	88868693          	addi	a3,a3,-1912 # ffffffffc0205f60 <default_pmm_manager+0x888>
ffffffffc02036e0:	00002617          	auipc	a2,0x2
ffffffffc02036e4:	c4860613          	addi	a2,a2,-952 # ffffffffc0205328 <commands+0x738>
ffffffffc02036e8:	05400593          	li	a1,84
ffffffffc02036ec:	00003517          	auipc	a0,0x3
ffffffffc02036f0:	9fc50513          	addi	a0,a0,-1540 # ffffffffc02060e8 <default_pmm_manager+0xa10>
ffffffffc02036f4:	d53fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02036f8 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02036f8:	751c                	ld	a5,40(a0)
{
ffffffffc02036fa:	1141                	addi	sp,sp,-16
ffffffffc02036fc:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc02036fe:	cf91                	beqz	a5,ffffffffc020371a <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0203700:	ee0d                	bnez	a2,ffffffffc020373a <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0203702:	679c                	ld	a5,8(a5)
}
ffffffffc0203704:	60a2                	ld	ra,8(sp)
ffffffffc0203706:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0203708:	6394                	ld	a3,0(a5)
ffffffffc020370a:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc020370c:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0203710:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203712:	e314                	sd	a3,0(a4)
ffffffffc0203714:	e19c                	sd	a5,0(a1)
}
ffffffffc0203716:	0141                	addi	sp,sp,16
ffffffffc0203718:	8082                	ret
         assert(head != NULL);
ffffffffc020371a:	00003697          	auipc	a3,0x3
ffffffffc020371e:	b1e68693          	addi	a3,a3,-1250 # ffffffffc0206238 <default_pmm_manager+0xb60>
ffffffffc0203722:	00002617          	auipc	a2,0x2
ffffffffc0203726:	c0660613          	addi	a2,a2,-1018 # ffffffffc0205328 <commands+0x738>
ffffffffc020372a:	04100593          	li	a1,65
ffffffffc020372e:	00003517          	auipc	a0,0x3
ffffffffc0203732:	9ba50513          	addi	a0,a0,-1606 # ffffffffc02060e8 <default_pmm_manager+0xa10>
ffffffffc0203736:	d11fc0ef          	jal	ra,ffffffffc0200446 <__panic>
     assert(in_tick==0);
ffffffffc020373a:	00003697          	auipc	a3,0x3
ffffffffc020373e:	b0e68693          	addi	a3,a3,-1266 # ffffffffc0206248 <default_pmm_manager+0xb70>
ffffffffc0203742:	00002617          	auipc	a2,0x2
ffffffffc0203746:	be660613          	addi	a2,a2,-1050 # ffffffffc0205328 <commands+0x738>
ffffffffc020374a:	04200593          	li	a1,66
ffffffffc020374e:	00003517          	auipc	a0,0x3
ffffffffc0203752:	99a50513          	addi	a0,a0,-1638 # ffffffffc02060e8 <default_pmm_manager+0xa10>
ffffffffc0203756:	cf1fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020375a <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020375a:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc020375c:	cb91                	beqz	a5,ffffffffc0203770 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020375e:	6394                	ld	a3,0(a5)
ffffffffc0203760:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc0203764:	e398                	sd	a4,0(a5)
ffffffffc0203766:	e698                	sd	a4,8(a3)
}
ffffffffc0203768:	4501                	li	a0,0
    elm->next = next;
ffffffffc020376a:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc020376c:	f614                	sd	a3,40(a2)
ffffffffc020376e:	8082                	ret
{
ffffffffc0203770:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203772:	00003697          	auipc	a3,0x3
ffffffffc0203776:	ae668693          	addi	a3,a3,-1306 # ffffffffc0206258 <default_pmm_manager+0xb80>
ffffffffc020377a:	00002617          	auipc	a2,0x2
ffffffffc020377e:	bae60613          	addi	a2,a2,-1106 # ffffffffc0205328 <commands+0x738>
ffffffffc0203782:	03200593          	li	a1,50
ffffffffc0203786:	00003517          	auipc	a0,0x3
ffffffffc020378a:	96250513          	addi	a0,a0,-1694 # ffffffffc02060e8 <default_pmm_manager+0xa10>
{
ffffffffc020378e:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0203790:	cb7fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203794 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203794:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203796:	00003697          	auipc	a3,0x3
ffffffffc020379a:	afa68693          	addi	a3,a3,-1286 # ffffffffc0206290 <default_pmm_manager+0xbb8>
ffffffffc020379e:	00002617          	auipc	a2,0x2
ffffffffc02037a2:	b8a60613          	addi	a2,a2,-1142 # ffffffffc0205328 <commands+0x738>
ffffffffc02037a6:	07e00593          	li	a1,126
ffffffffc02037aa:	00003517          	auipc	a0,0x3
ffffffffc02037ae:	b0650513          	addi	a0,a0,-1274 # ffffffffc02062b0 <default_pmm_manager+0xbd8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02037b2:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02037b4:	c93fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02037b8 <mm_create>:
mm_create(void) {
ffffffffc02037b8:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02037ba:	03000513          	li	a0,48
mm_create(void) {
ffffffffc02037be:	e022                	sd	s0,0(sp)
ffffffffc02037c0:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02037c2:	868fe0ef          	jal	ra,ffffffffc020182a <kmalloc>
ffffffffc02037c6:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02037c8:	c105                	beqz	a0,ffffffffc02037e8 <mm_create+0x30>
    elm->prev = elm->next = elm;
ffffffffc02037ca:	e408                	sd	a0,8(s0)
ffffffffc02037cc:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02037ce:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02037d2:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02037d6:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02037da:	00012797          	auipc	a5,0x12
ffffffffc02037de:	db67a783          	lw	a5,-586(a5) # ffffffffc0215590 <swap_init_ok>
ffffffffc02037e2:	eb81                	bnez	a5,ffffffffc02037f2 <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc02037e4:	02053423          	sd	zero,40(a0)
}
ffffffffc02037e8:	60a2                	ld	ra,8(sp)
ffffffffc02037ea:	8522                	mv	a0,s0
ffffffffc02037ec:	6402                	ld	s0,0(sp)
ffffffffc02037ee:	0141                	addi	sp,sp,16
ffffffffc02037f0:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02037f2:	a89ff0ef          	jal	ra,ffffffffc020327a <swap_init_mm>
}
ffffffffc02037f6:	60a2                	ld	ra,8(sp)
ffffffffc02037f8:	8522                	mv	a0,s0
ffffffffc02037fa:	6402                	ld	s0,0(sp)
ffffffffc02037fc:	0141                	addi	sp,sp,16
ffffffffc02037fe:	8082                	ret

ffffffffc0203800 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0203800:	1101                	addi	sp,sp,-32
ffffffffc0203802:	e04a                	sd	s2,0(sp)
ffffffffc0203804:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203806:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020380a:	e822                	sd	s0,16(sp)
ffffffffc020380c:	e426                	sd	s1,8(sp)
ffffffffc020380e:	ec06                	sd	ra,24(sp)
ffffffffc0203810:	84ae                	mv	s1,a1
ffffffffc0203812:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203814:	816fe0ef          	jal	ra,ffffffffc020182a <kmalloc>
    if (vma != NULL) {
ffffffffc0203818:	c509                	beqz	a0,ffffffffc0203822 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc020381a:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc020381e:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203820:	cd00                	sw	s0,24(a0)
}
ffffffffc0203822:	60e2                	ld	ra,24(sp)
ffffffffc0203824:	6442                	ld	s0,16(sp)
ffffffffc0203826:	64a2                	ld	s1,8(sp)
ffffffffc0203828:	6902                	ld	s2,0(sp)
ffffffffc020382a:	6105                	addi	sp,sp,32
ffffffffc020382c:	8082                	ret

ffffffffc020382e <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc020382e:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0203830:	c505                	beqz	a0,ffffffffc0203858 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0203832:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203834:	c501                	beqz	a0,ffffffffc020383c <find_vma+0xe>
ffffffffc0203836:	651c                	ld	a5,8(a0)
ffffffffc0203838:	02f5f263          	bgeu	a1,a5,ffffffffc020385c <find_vma+0x2e>
    return listelm->next;
ffffffffc020383c:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc020383e:	00f68d63          	beq	a3,a5,ffffffffc0203858 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0203842:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203846:	00e5e663          	bltu	a1,a4,ffffffffc0203852 <find_vma+0x24>
ffffffffc020384a:	ff07b703          	ld	a4,-16(a5)
ffffffffc020384e:	00e5ec63          	bltu	a1,a4,ffffffffc0203866 <find_vma+0x38>
ffffffffc0203852:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0203854:	fef697e3          	bne	a3,a5,ffffffffc0203842 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0203858:	4501                	li	a0,0
}
ffffffffc020385a:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020385c:	691c                	ld	a5,16(a0)
ffffffffc020385e:	fcf5ffe3          	bgeu	a1,a5,ffffffffc020383c <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0203862:	ea88                	sd	a0,16(a3)
ffffffffc0203864:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0203866:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc020386a:	ea88                	sd	a0,16(a3)
ffffffffc020386c:	8082                	ret

ffffffffc020386e <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc020386e:	6590                	ld	a2,8(a1)
ffffffffc0203870:	0105b803          	ld	a6,16(a1) # 1010 <kern_entry-0xffffffffc01feff0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0203874:	1141                	addi	sp,sp,-16
ffffffffc0203876:	e406                	sd	ra,8(sp)
ffffffffc0203878:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020387a:	01066763          	bltu	a2,a6,ffffffffc0203888 <insert_vma_struct+0x1a>
ffffffffc020387e:	a085                	j	ffffffffc02038de <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203880:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203884:	04e66863          	bltu	a2,a4,ffffffffc02038d4 <insert_vma_struct+0x66>
ffffffffc0203888:	86be                	mv	a3,a5
ffffffffc020388a:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc020388c:	fef51ae3          	bne	a0,a5,ffffffffc0203880 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0203890:	02a68463          	beq	a3,a0,ffffffffc02038b8 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203894:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203898:	fe86b883          	ld	a7,-24(a3)
ffffffffc020389c:	08e8f163          	bgeu	a7,a4,ffffffffc020391e <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02038a0:	04e66f63          	bltu	a2,a4,ffffffffc02038fe <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc02038a4:	00f50a63          	beq	a0,a5,ffffffffc02038b8 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02038a8:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02038ac:	05076963          	bltu	a4,a6,ffffffffc02038fe <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02038b0:	ff07b603          	ld	a2,-16(a5)
ffffffffc02038b4:	02c77363          	bgeu	a4,a2,ffffffffc02038da <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02038b8:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02038ba:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02038bc:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02038c0:	e390                	sd	a2,0(a5)
ffffffffc02038c2:	e690                	sd	a2,8(a3)
}
ffffffffc02038c4:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02038c6:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02038c8:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc02038ca:	0017079b          	addiw	a5,a4,1
ffffffffc02038ce:	d11c                	sw	a5,32(a0)
}
ffffffffc02038d0:	0141                	addi	sp,sp,16
ffffffffc02038d2:	8082                	ret
    if (le_prev != list) {
ffffffffc02038d4:	fca690e3          	bne	a3,a0,ffffffffc0203894 <insert_vma_struct+0x26>
ffffffffc02038d8:	bfd1                	j	ffffffffc02038ac <insert_vma_struct+0x3e>
ffffffffc02038da:	ebbff0ef          	jal	ra,ffffffffc0203794 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02038de:	00003697          	auipc	a3,0x3
ffffffffc02038e2:	9e268693          	addi	a3,a3,-1566 # ffffffffc02062c0 <default_pmm_manager+0xbe8>
ffffffffc02038e6:	00002617          	auipc	a2,0x2
ffffffffc02038ea:	a4260613          	addi	a2,a2,-1470 # ffffffffc0205328 <commands+0x738>
ffffffffc02038ee:	08500593          	li	a1,133
ffffffffc02038f2:	00003517          	auipc	a0,0x3
ffffffffc02038f6:	9be50513          	addi	a0,a0,-1602 # ffffffffc02062b0 <default_pmm_manager+0xbd8>
ffffffffc02038fa:	b4dfc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02038fe:	00003697          	auipc	a3,0x3
ffffffffc0203902:	a0268693          	addi	a3,a3,-1534 # ffffffffc0206300 <default_pmm_manager+0xc28>
ffffffffc0203906:	00002617          	auipc	a2,0x2
ffffffffc020390a:	a2260613          	addi	a2,a2,-1502 # ffffffffc0205328 <commands+0x738>
ffffffffc020390e:	07d00593          	li	a1,125
ffffffffc0203912:	00003517          	auipc	a0,0x3
ffffffffc0203916:	99e50513          	addi	a0,a0,-1634 # ffffffffc02062b0 <default_pmm_manager+0xbd8>
ffffffffc020391a:	b2dfc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020391e:	00003697          	auipc	a3,0x3
ffffffffc0203922:	9c268693          	addi	a3,a3,-1598 # ffffffffc02062e0 <default_pmm_manager+0xc08>
ffffffffc0203926:	00002617          	auipc	a2,0x2
ffffffffc020392a:	a0260613          	addi	a2,a2,-1534 # ffffffffc0205328 <commands+0x738>
ffffffffc020392e:	07c00593          	li	a1,124
ffffffffc0203932:	00003517          	auipc	a0,0x3
ffffffffc0203936:	97e50513          	addi	a0,a0,-1666 # ffffffffc02062b0 <default_pmm_manager+0xbd8>
ffffffffc020393a:	b0dfc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020393e <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc020393e:	1141                	addi	sp,sp,-16
ffffffffc0203940:	e022                	sd	s0,0(sp)
ffffffffc0203942:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203944:	6508                	ld	a0,8(a0)
ffffffffc0203946:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0203948:	00a40c63          	beq	s0,a0,ffffffffc0203960 <mm_destroy+0x22>
    __list_del(listelm->prev, listelm->next);
ffffffffc020394c:	6118                	ld	a4,0(a0)
ffffffffc020394e:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0203950:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203952:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203954:	e398                	sd	a4,0(a5)
ffffffffc0203956:	f85fd0ef          	jal	ra,ffffffffc02018da <kfree>
    return listelm->next;
ffffffffc020395a:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020395c:	fea418e3          	bne	s0,a0,ffffffffc020394c <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
ffffffffc0203960:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0203962:	6402                	ld	s0,0(sp)
ffffffffc0203964:	60a2                	ld	ra,8(sp)
ffffffffc0203966:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0203968:	f73fd06f          	j	ffffffffc02018da <kfree>

ffffffffc020396c <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc020396c:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020396e:	03000513          	li	a0,48
vmm_init(void) {
ffffffffc0203972:	fc06                	sd	ra,56(sp)
ffffffffc0203974:	f822                	sd	s0,48(sp)
ffffffffc0203976:	f426                	sd	s1,40(sp)
ffffffffc0203978:	f04a                	sd	s2,32(sp)
ffffffffc020397a:	ec4e                	sd	s3,24(sp)
ffffffffc020397c:	e852                	sd	s4,16(sp)
ffffffffc020397e:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203980:	eabfd0ef          	jal	ra,ffffffffc020182a <kmalloc>
    if (mm != NULL) {
ffffffffc0203984:	58050e63          	beqz	a0,ffffffffc0203f20 <vmm_init+0x5b4>
    elm->prev = elm->next = elm;
ffffffffc0203988:	e508                	sd	a0,8(a0)
ffffffffc020398a:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc020398c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203990:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203994:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203998:	00012797          	auipc	a5,0x12
ffffffffc020399c:	bf87a783          	lw	a5,-1032(a5) # ffffffffc0215590 <swap_init_ok>
ffffffffc02039a0:	84aa                	mv	s1,a0
ffffffffc02039a2:	e7b9                	bnez	a5,ffffffffc02039f0 <vmm_init+0x84>
        else mm->sm_priv = NULL;
ffffffffc02039a4:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc02039a8:	03200413          	li	s0,50
ffffffffc02039ac:	a811                	j	ffffffffc02039c0 <vmm_init+0x54>
        vma->vm_start = vm_start;
ffffffffc02039ae:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02039b0:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02039b2:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc02039b6:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02039b8:	8526                	mv	a0,s1
ffffffffc02039ba:	eb5ff0ef          	jal	ra,ffffffffc020386e <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02039be:	cc05                	beqz	s0,ffffffffc02039f6 <vmm_init+0x8a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02039c0:	03000513          	li	a0,48
ffffffffc02039c4:	e67fd0ef          	jal	ra,ffffffffc020182a <kmalloc>
ffffffffc02039c8:	85aa                	mv	a1,a0
ffffffffc02039ca:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc02039ce:	f165                	bnez	a0,ffffffffc02039ae <vmm_init+0x42>
        assert(vma != NULL);
ffffffffc02039d0:	00002697          	auipc	a3,0x2
ffffffffc02039d4:	45068693          	addi	a3,a3,1104 # ffffffffc0205e20 <default_pmm_manager+0x748>
ffffffffc02039d8:	00002617          	auipc	a2,0x2
ffffffffc02039dc:	95060613          	addi	a2,a2,-1712 # ffffffffc0205328 <commands+0x738>
ffffffffc02039e0:	0c900593          	li	a1,201
ffffffffc02039e4:	00003517          	auipc	a0,0x3
ffffffffc02039e8:	8cc50513          	addi	a0,a0,-1844 # ffffffffc02062b0 <default_pmm_manager+0xbd8>
ffffffffc02039ec:	a5bfc0ef          	jal	ra,ffffffffc0200446 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02039f0:	88bff0ef          	jal	ra,ffffffffc020327a <swap_init_mm>
ffffffffc02039f4:	bf55                	j	ffffffffc02039a8 <vmm_init+0x3c>
ffffffffc02039f6:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02039fa:	1f900913          	li	s2,505
ffffffffc02039fe:	a819                	j	ffffffffc0203a14 <vmm_init+0xa8>
        vma->vm_start = vm_start;
ffffffffc0203a00:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203a02:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203a04:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203a08:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203a0a:	8526                	mv	a0,s1
ffffffffc0203a0c:	e63ff0ef          	jal	ra,ffffffffc020386e <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203a10:	03240a63          	beq	s0,s2,ffffffffc0203a44 <vmm_init+0xd8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203a14:	03000513          	li	a0,48
ffffffffc0203a18:	e13fd0ef          	jal	ra,ffffffffc020182a <kmalloc>
ffffffffc0203a1c:	85aa                	mv	a1,a0
ffffffffc0203a1e:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0203a22:	fd79                	bnez	a0,ffffffffc0203a00 <vmm_init+0x94>
        assert(vma != NULL);
ffffffffc0203a24:	00002697          	auipc	a3,0x2
ffffffffc0203a28:	3fc68693          	addi	a3,a3,1020 # ffffffffc0205e20 <default_pmm_manager+0x748>
ffffffffc0203a2c:	00002617          	auipc	a2,0x2
ffffffffc0203a30:	8fc60613          	addi	a2,a2,-1796 # ffffffffc0205328 <commands+0x738>
ffffffffc0203a34:	0cf00593          	li	a1,207
ffffffffc0203a38:	00003517          	auipc	a0,0x3
ffffffffc0203a3c:	87850513          	addi	a0,a0,-1928 # ffffffffc02062b0 <default_pmm_manager+0xbd8>
ffffffffc0203a40:	a07fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    return listelm->next;
ffffffffc0203a44:	649c                	ld	a5,8(s1)
ffffffffc0203a46:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0203a48:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0203a4c:	30f48e63          	beq	s1,a5,ffffffffc0203d68 <vmm_init+0x3fc>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203a50:	fe87b683          	ld	a3,-24(a5)
ffffffffc0203a54:	ffe70613          	addi	a2,a4,-2
ffffffffc0203a58:	2ad61863          	bne	a2,a3,ffffffffc0203d08 <vmm_init+0x39c>
ffffffffc0203a5c:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203a60:	2ae69463          	bne	a3,a4,ffffffffc0203d08 <vmm_init+0x39c>
    for (i = 1; i <= step2; i ++) {
ffffffffc0203a64:	0715                	addi	a4,a4,5
ffffffffc0203a66:	679c                	ld	a5,8(a5)
ffffffffc0203a68:	feb712e3          	bne	a4,a1,ffffffffc0203a4c <vmm_init+0xe0>
ffffffffc0203a6c:	4a1d                	li	s4,7
ffffffffc0203a6e:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203a70:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203a74:	85a2                	mv	a1,s0
ffffffffc0203a76:	8526                	mv	a0,s1
ffffffffc0203a78:	db7ff0ef          	jal	ra,ffffffffc020382e <find_vma>
ffffffffc0203a7c:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0203a7e:	34050563          	beqz	a0,ffffffffc0203dc8 <vmm_init+0x45c>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0203a82:	00140593          	addi	a1,s0,1
ffffffffc0203a86:	8526                	mv	a0,s1
ffffffffc0203a88:	da7ff0ef          	jal	ra,ffffffffc020382e <find_vma>
ffffffffc0203a8c:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203a8e:	34050d63          	beqz	a0,ffffffffc0203de8 <vmm_init+0x47c>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0203a92:	85d2                	mv	a1,s4
ffffffffc0203a94:	8526                	mv	a0,s1
ffffffffc0203a96:	d99ff0ef          	jal	ra,ffffffffc020382e <find_vma>
        assert(vma3 == NULL);
ffffffffc0203a9a:	36051763          	bnez	a0,ffffffffc0203e08 <vmm_init+0x49c>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0203a9e:	00340593          	addi	a1,s0,3
ffffffffc0203aa2:	8526                	mv	a0,s1
ffffffffc0203aa4:	d8bff0ef          	jal	ra,ffffffffc020382e <find_vma>
        assert(vma4 == NULL);
ffffffffc0203aa8:	2e051063          	bnez	a0,ffffffffc0203d88 <vmm_init+0x41c>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0203aac:	00440593          	addi	a1,s0,4
ffffffffc0203ab0:	8526                	mv	a0,s1
ffffffffc0203ab2:	d7dff0ef          	jal	ra,ffffffffc020382e <find_vma>
        assert(vma5 == NULL);
ffffffffc0203ab6:	2e051963          	bnez	a0,ffffffffc0203da8 <vmm_init+0x43c>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203aba:	00893783          	ld	a5,8(s2)
ffffffffc0203abe:	26879563          	bne	a5,s0,ffffffffc0203d28 <vmm_init+0x3bc>
ffffffffc0203ac2:	01093783          	ld	a5,16(s2)
ffffffffc0203ac6:	27479163          	bne	a5,s4,ffffffffc0203d28 <vmm_init+0x3bc>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203aca:	0089b783          	ld	a5,8(s3)
ffffffffc0203ace:	26879d63          	bne	a5,s0,ffffffffc0203d48 <vmm_init+0x3dc>
ffffffffc0203ad2:	0109b783          	ld	a5,16(s3)
ffffffffc0203ad6:	27479963          	bne	a5,s4,ffffffffc0203d48 <vmm_init+0x3dc>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203ada:	0415                	addi	s0,s0,5
ffffffffc0203adc:	0a15                	addi	s4,s4,5
ffffffffc0203ade:	f9541be3          	bne	s0,s5,ffffffffc0203a74 <vmm_init+0x108>
ffffffffc0203ae2:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0203ae4:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0203ae6:	85a2                	mv	a1,s0
ffffffffc0203ae8:	8526                	mv	a0,s1
ffffffffc0203aea:	d45ff0ef          	jal	ra,ffffffffc020382e <find_vma>
ffffffffc0203aee:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0203af2:	c90d                	beqz	a0,ffffffffc0203b24 <vmm_init+0x1b8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203af4:	6914                	ld	a3,16(a0)
ffffffffc0203af6:	6510                	ld	a2,8(a0)
ffffffffc0203af8:	00003517          	auipc	a0,0x3
ffffffffc0203afc:	92850513          	addi	a0,a0,-1752 # ffffffffc0206420 <default_pmm_manager+0xd48>
ffffffffc0203b00:	e80fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203b04:	00003697          	auipc	a3,0x3
ffffffffc0203b08:	94468693          	addi	a3,a3,-1724 # ffffffffc0206448 <default_pmm_manager+0xd70>
ffffffffc0203b0c:	00002617          	auipc	a2,0x2
ffffffffc0203b10:	81c60613          	addi	a2,a2,-2020 # ffffffffc0205328 <commands+0x738>
ffffffffc0203b14:	0f100593          	li	a1,241
ffffffffc0203b18:	00002517          	auipc	a0,0x2
ffffffffc0203b1c:	79850513          	addi	a0,a0,1944 # ffffffffc02062b0 <default_pmm_manager+0xbd8>
ffffffffc0203b20:	927fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0203b24:	147d                	addi	s0,s0,-1
ffffffffc0203b26:	fd2410e3          	bne	s0,s2,ffffffffc0203ae6 <vmm_init+0x17a>
ffffffffc0203b2a:	a801                	j	ffffffffc0203b3a <vmm_init+0x1ce>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203b2c:	6118                	ld	a4,0(a0)
ffffffffc0203b2e:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0203b30:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203b32:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203b34:	e398                	sd	a4,0(a5)
ffffffffc0203b36:	da5fd0ef          	jal	ra,ffffffffc02018da <kfree>
    return listelm->next;
ffffffffc0203b3a:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc0203b3c:	fea498e3          	bne	s1,a0,ffffffffc0203b2c <vmm_init+0x1c0>
    kfree(mm); //kfree mm
ffffffffc0203b40:	8526                	mv	a0,s1
ffffffffc0203b42:	d99fd0ef          	jal	ra,ffffffffc02018da <kfree>
    }

    mm_destroy(mm);

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203b46:	00003517          	auipc	a0,0x3
ffffffffc0203b4a:	91a50513          	addi	a0,a0,-1766 # ffffffffc0206460 <default_pmm_manager+0xd88>
ffffffffc0203b4e:	e32fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203b52:	f89fd0ef          	jal	ra,ffffffffc0201ada <nr_free_pages>
ffffffffc0203b56:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203b58:	03000513          	li	a0,48
ffffffffc0203b5c:	ccffd0ef          	jal	ra,ffffffffc020182a <kmalloc>
ffffffffc0203b60:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203b62:	2c050363          	beqz	a0,ffffffffc0203e28 <vmm_init+0x4bc>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203b66:	00012797          	auipc	a5,0x12
ffffffffc0203b6a:	a2a7a783          	lw	a5,-1494(a5) # ffffffffc0215590 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc0203b6e:	e508                	sd	a0,8(a0)
ffffffffc0203b70:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203b72:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203b76:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203b7a:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203b7e:	18079263          	bnez	a5,ffffffffc0203d02 <vmm_init+0x396>
        else mm->sm_priv = NULL;
ffffffffc0203b82:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();
    assert(check_mm_struct != NULL);

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203b86:	00012917          	auipc	s2,0x12
ffffffffc0203b8a:	9d293903          	ld	s2,-1582(s2) # ffffffffc0215558 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0203b8e:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc0203b92:	00012717          	auipc	a4,0x12
ffffffffc0203b96:	a0873323          	sd	s0,-1530(a4) # ffffffffc0215598 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203b9a:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc0203b9e:	36079163          	bnez	a5,ffffffffc0203f00 <vmm_init+0x594>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203ba2:	03000513          	li	a0,48
ffffffffc0203ba6:	c85fd0ef          	jal	ra,ffffffffc020182a <kmalloc>
ffffffffc0203baa:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc0203bac:	2a050263          	beqz	a0,ffffffffc0203e50 <vmm_init+0x4e4>
        vma->vm_end = vm_end;
ffffffffc0203bb0:	002007b7          	lui	a5,0x200
ffffffffc0203bb4:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc0203bb8:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203bba:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203bbc:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc0203bc0:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0203bc2:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc0203bc6:	ca9ff0ef          	jal	ra,ffffffffc020386e <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203bca:	10000593          	li	a1,256
ffffffffc0203bce:	8522                	mv	a0,s0
ffffffffc0203bd0:	c5fff0ef          	jal	ra,ffffffffc020382e <find_vma>
ffffffffc0203bd4:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0203bd8:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203bdc:	28a99a63          	bne	s3,a0,ffffffffc0203e70 <vmm_init+0x504>
        *(char *)(addr + i) = i;
ffffffffc0203be0:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc0203be4:	0785                	addi	a5,a5,1
ffffffffc0203be6:	fee79de3          	bne	a5,a4,ffffffffc0203be0 <vmm_init+0x274>
        sum += i;
ffffffffc0203bea:	6705                	lui	a4,0x1
ffffffffc0203bec:	10000793          	li	a5,256
ffffffffc0203bf0:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0203bf4:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0203bf8:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0203bfc:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0203bfe:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0203c00:	fec79ce3          	bne	a5,a2,ffffffffc0203bf8 <vmm_init+0x28c>
    }
    assert(sum == 0);
ffffffffc0203c04:	28071663          	bnez	a4,ffffffffc0203e90 <vmm_init+0x524>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c08:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203c0c:	00012a97          	auipc	s5,0x12
ffffffffc0203c10:	954a8a93          	addi	s5,s5,-1708 # ffffffffc0215560 <npage>
ffffffffc0203c14:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c18:	078a                	slli	a5,a5,0x2
ffffffffc0203c1a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203c1c:	28c7fa63          	bgeu	a5,a2,ffffffffc0203eb0 <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc0203c20:	00003a17          	auipc	s4,0x3
ffffffffc0203c24:	d88a3a03          	ld	s4,-632(s4) # ffffffffc02069a8 <nbase>
ffffffffc0203c28:	414787b3          	sub	a5,a5,s4
ffffffffc0203c2c:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc0203c2e:	8799                	srai	a5,a5,0x6
ffffffffc0203c30:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0203c32:	00c79713          	slli	a4,a5,0xc
ffffffffc0203c36:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203c38:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0203c3c:	28c77663          	bgeu	a4,a2,ffffffffc0203ec8 <vmm_init+0x55c>
ffffffffc0203c40:	00012997          	auipc	s3,0x12
ffffffffc0203c44:	9389b983          	ld	s3,-1736(s3) # ffffffffc0215578 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203c48:	4581                	li	a1,0
ffffffffc0203c4a:	854a                	mv	a0,s2
ffffffffc0203c4c:	99b6                	add	s3,s3,a3
ffffffffc0203c4e:	8ecfe0ef          	jal	ra,ffffffffc0201d3a <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c52:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0203c56:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c5a:	078a                	slli	a5,a5,0x2
ffffffffc0203c5c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203c5e:	24e7f963          	bgeu	a5,a4,ffffffffc0203eb0 <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc0203c62:	00012997          	auipc	s3,0x12
ffffffffc0203c66:	90698993          	addi	s3,s3,-1786 # ffffffffc0215568 <pages>
ffffffffc0203c6a:	0009b503          	ld	a0,0(s3)
ffffffffc0203c6e:	414787b3          	sub	a5,a5,s4
ffffffffc0203c72:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0203c74:	953e                	add	a0,a0,a5
ffffffffc0203c76:	4585                	li	a1,1
ffffffffc0203c78:	e23fd0ef          	jal	ra,ffffffffc0201a9a <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c7c:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203c80:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c84:	078a                	slli	a5,a5,0x2
ffffffffc0203c86:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203c88:	22e7f463          	bgeu	a5,a4,ffffffffc0203eb0 <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc0203c8c:	0009b503          	ld	a0,0(s3)
ffffffffc0203c90:	414787b3          	sub	a5,a5,s4
ffffffffc0203c94:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0203c96:	4585                	li	a1,1
ffffffffc0203c98:	953e                	add	a0,a0,a5
ffffffffc0203c9a:	e01fd0ef          	jal	ra,ffffffffc0201a9a <free_pages>
    pgdir[0] = 0;
ffffffffc0203c9e:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0203ca2:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0203ca6:	6408                	ld	a0,8(s0)
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0203ca8:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203cac:	00a40c63          	beq	s0,a0,ffffffffc0203cc4 <vmm_init+0x358>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203cb0:	6118                	ld	a4,0(a0)
ffffffffc0203cb2:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0203cb4:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203cb6:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203cb8:	e398                	sd	a4,0(a5)
ffffffffc0203cba:	c21fd0ef          	jal	ra,ffffffffc02018da <kfree>
    return listelm->next;
ffffffffc0203cbe:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203cc0:	fea418e3          	bne	s0,a0,ffffffffc0203cb0 <vmm_init+0x344>
    kfree(mm); //kfree mm
ffffffffc0203cc4:	8522                	mv	a0,s0
ffffffffc0203cc6:	c15fd0ef          	jal	ra,ffffffffc02018da <kfree>
    mm_destroy(mm);
    check_mm_struct = NULL;
ffffffffc0203cca:	00012797          	auipc	a5,0x12
ffffffffc0203cce:	8c07b723          	sd	zero,-1842(a5) # ffffffffc0215598 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203cd2:	e09fd0ef          	jal	ra,ffffffffc0201ada <nr_free_pages>
ffffffffc0203cd6:	20a49563          	bne	s1,a0,ffffffffc0203ee0 <vmm_init+0x574>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203cda:	00002517          	auipc	a0,0x2
ffffffffc0203cde:	7fe50513          	addi	a0,a0,2046 # ffffffffc02064d8 <default_pmm_manager+0xe00>
ffffffffc0203ce2:	c9efc0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0203ce6:	7442                	ld	s0,48(sp)
ffffffffc0203ce8:	70e2                	ld	ra,56(sp)
ffffffffc0203cea:	74a2                	ld	s1,40(sp)
ffffffffc0203cec:	7902                	ld	s2,32(sp)
ffffffffc0203cee:	69e2                	ld	s3,24(sp)
ffffffffc0203cf0:	6a42                	ld	s4,16(sp)
ffffffffc0203cf2:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203cf4:	00003517          	auipc	a0,0x3
ffffffffc0203cf8:	80450513          	addi	a0,a0,-2044 # ffffffffc02064f8 <default_pmm_manager+0xe20>
}
ffffffffc0203cfc:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203cfe:	c82fc06f          	j	ffffffffc0200180 <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203d02:	d78ff0ef          	jal	ra,ffffffffc020327a <swap_init_mm>
ffffffffc0203d06:	b541                	j	ffffffffc0203b86 <vmm_init+0x21a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203d08:	00002697          	auipc	a3,0x2
ffffffffc0203d0c:	63068693          	addi	a3,a3,1584 # ffffffffc0206338 <default_pmm_manager+0xc60>
ffffffffc0203d10:	00001617          	auipc	a2,0x1
ffffffffc0203d14:	61860613          	addi	a2,a2,1560 # ffffffffc0205328 <commands+0x738>
ffffffffc0203d18:	0d800593          	li	a1,216
ffffffffc0203d1c:	00002517          	auipc	a0,0x2
ffffffffc0203d20:	59450513          	addi	a0,a0,1428 # ffffffffc02062b0 <default_pmm_manager+0xbd8>
ffffffffc0203d24:	f22fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203d28:	00002697          	auipc	a3,0x2
ffffffffc0203d2c:	69868693          	addi	a3,a3,1688 # ffffffffc02063c0 <default_pmm_manager+0xce8>
ffffffffc0203d30:	00001617          	auipc	a2,0x1
ffffffffc0203d34:	5f860613          	addi	a2,a2,1528 # ffffffffc0205328 <commands+0x738>
ffffffffc0203d38:	0e800593          	li	a1,232
ffffffffc0203d3c:	00002517          	auipc	a0,0x2
ffffffffc0203d40:	57450513          	addi	a0,a0,1396 # ffffffffc02062b0 <default_pmm_manager+0xbd8>
ffffffffc0203d44:	f02fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203d48:	00002697          	auipc	a3,0x2
ffffffffc0203d4c:	6a868693          	addi	a3,a3,1704 # ffffffffc02063f0 <default_pmm_manager+0xd18>
ffffffffc0203d50:	00001617          	auipc	a2,0x1
ffffffffc0203d54:	5d860613          	addi	a2,a2,1496 # ffffffffc0205328 <commands+0x738>
ffffffffc0203d58:	0e900593          	li	a1,233
ffffffffc0203d5c:	00002517          	auipc	a0,0x2
ffffffffc0203d60:	55450513          	addi	a0,a0,1364 # ffffffffc02062b0 <default_pmm_manager+0xbd8>
ffffffffc0203d64:	ee2fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203d68:	00002697          	auipc	a3,0x2
ffffffffc0203d6c:	5b868693          	addi	a3,a3,1464 # ffffffffc0206320 <default_pmm_manager+0xc48>
ffffffffc0203d70:	00001617          	auipc	a2,0x1
ffffffffc0203d74:	5b860613          	addi	a2,a2,1464 # ffffffffc0205328 <commands+0x738>
ffffffffc0203d78:	0d600593          	li	a1,214
ffffffffc0203d7c:	00002517          	auipc	a0,0x2
ffffffffc0203d80:	53450513          	addi	a0,a0,1332 # ffffffffc02062b0 <default_pmm_manager+0xbd8>
ffffffffc0203d84:	ec2fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma4 == NULL);
ffffffffc0203d88:	00002697          	auipc	a3,0x2
ffffffffc0203d8c:	61868693          	addi	a3,a3,1560 # ffffffffc02063a0 <default_pmm_manager+0xcc8>
ffffffffc0203d90:	00001617          	auipc	a2,0x1
ffffffffc0203d94:	59860613          	addi	a2,a2,1432 # ffffffffc0205328 <commands+0x738>
ffffffffc0203d98:	0e400593          	li	a1,228
ffffffffc0203d9c:	00002517          	auipc	a0,0x2
ffffffffc0203da0:	51450513          	addi	a0,a0,1300 # ffffffffc02062b0 <default_pmm_manager+0xbd8>
ffffffffc0203da4:	ea2fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma5 == NULL);
ffffffffc0203da8:	00002697          	auipc	a3,0x2
ffffffffc0203dac:	60868693          	addi	a3,a3,1544 # ffffffffc02063b0 <default_pmm_manager+0xcd8>
ffffffffc0203db0:	00001617          	auipc	a2,0x1
ffffffffc0203db4:	57860613          	addi	a2,a2,1400 # ffffffffc0205328 <commands+0x738>
ffffffffc0203db8:	0e600593          	li	a1,230
ffffffffc0203dbc:	00002517          	auipc	a0,0x2
ffffffffc0203dc0:	4f450513          	addi	a0,a0,1268 # ffffffffc02062b0 <default_pmm_manager+0xbd8>
ffffffffc0203dc4:	e82fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma1 != NULL);
ffffffffc0203dc8:	00002697          	auipc	a3,0x2
ffffffffc0203dcc:	5a868693          	addi	a3,a3,1448 # ffffffffc0206370 <default_pmm_manager+0xc98>
ffffffffc0203dd0:	00001617          	auipc	a2,0x1
ffffffffc0203dd4:	55860613          	addi	a2,a2,1368 # ffffffffc0205328 <commands+0x738>
ffffffffc0203dd8:	0de00593          	li	a1,222
ffffffffc0203ddc:	00002517          	auipc	a0,0x2
ffffffffc0203de0:	4d450513          	addi	a0,a0,1236 # ffffffffc02062b0 <default_pmm_manager+0xbd8>
ffffffffc0203de4:	e62fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma2 != NULL);
ffffffffc0203de8:	00002697          	auipc	a3,0x2
ffffffffc0203dec:	59868693          	addi	a3,a3,1432 # ffffffffc0206380 <default_pmm_manager+0xca8>
ffffffffc0203df0:	00001617          	auipc	a2,0x1
ffffffffc0203df4:	53860613          	addi	a2,a2,1336 # ffffffffc0205328 <commands+0x738>
ffffffffc0203df8:	0e000593          	li	a1,224
ffffffffc0203dfc:	00002517          	auipc	a0,0x2
ffffffffc0203e00:	4b450513          	addi	a0,a0,1204 # ffffffffc02062b0 <default_pmm_manager+0xbd8>
ffffffffc0203e04:	e42fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma3 == NULL);
ffffffffc0203e08:	00002697          	auipc	a3,0x2
ffffffffc0203e0c:	58868693          	addi	a3,a3,1416 # ffffffffc0206390 <default_pmm_manager+0xcb8>
ffffffffc0203e10:	00001617          	auipc	a2,0x1
ffffffffc0203e14:	51860613          	addi	a2,a2,1304 # ffffffffc0205328 <commands+0x738>
ffffffffc0203e18:	0e200593          	li	a1,226
ffffffffc0203e1c:	00002517          	auipc	a0,0x2
ffffffffc0203e20:	49450513          	addi	a0,a0,1172 # ffffffffc02062b0 <default_pmm_manager+0xbd8>
ffffffffc0203e24:	e22fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203e28:	00002697          	auipc	a3,0x2
ffffffffc0203e2c:	6e868693          	addi	a3,a3,1768 # ffffffffc0206510 <default_pmm_manager+0xe38>
ffffffffc0203e30:	00001617          	auipc	a2,0x1
ffffffffc0203e34:	4f860613          	addi	a2,a2,1272 # ffffffffc0205328 <commands+0x738>
ffffffffc0203e38:	10100593          	li	a1,257
ffffffffc0203e3c:	00002517          	auipc	a0,0x2
ffffffffc0203e40:	47450513          	addi	a0,a0,1140 # ffffffffc02062b0 <default_pmm_manager+0xbd8>
    check_mm_struct = mm_create();
ffffffffc0203e44:	00011797          	auipc	a5,0x11
ffffffffc0203e48:	7407ba23          	sd	zero,1876(a5) # ffffffffc0215598 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc0203e4c:	dfafc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(vma != NULL);
ffffffffc0203e50:	00002697          	auipc	a3,0x2
ffffffffc0203e54:	fd068693          	addi	a3,a3,-48 # ffffffffc0205e20 <default_pmm_manager+0x748>
ffffffffc0203e58:	00001617          	auipc	a2,0x1
ffffffffc0203e5c:	4d060613          	addi	a2,a2,1232 # ffffffffc0205328 <commands+0x738>
ffffffffc0203e60:	10800593          	li	a1,264
ffffffffc0203e64:	00002517          	auipc	a0,0x2
ffffffffc0203e68:	44c50513          	addi	a0,a0,1100 # ffffffffc02062b0 <default_pmm_manager+0xbd8>
ffffffffc0203e6c:	ddafc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203e70:	00002697          	auipc	a3,0x2
ffffffffc0203e74:	61068693          	addi	a3,a3,1552 # ffffffffc0206480 <default_pmm_manager+0xda8>
ffffffffc0203e78:	00001617          	auipc	a2,0x1
ffffffffc0203e7c:	4b060613          	addi	a2,a2,1200 # ffffffffc0205328 <commands+0x738>
ffffffffc0203e80:	10d00593          	li	a1,269
ffffffffc0203e84:	00002517          	auipc	a0,0x2
ffffffffc0203e88:	42c50513          	addi	a0,a0,1068 # ffffffffc02062b0 <default_pmm_manager+0xbd8>
ffffffffc0203e8c:	dbafc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(sum == 0);
ffffffffc0203e90:	00002697          	auipc	a3,0x2
ffffffffc0203e94:	61068693          	addi	a3,a3,1552 # ffffffffc02064a0 <default_pmm_manager+0xdc8>
ffffffffc0203e98:	00001617          	auipc	a2,0x1
ffffffffc0203e9c:	49060613          	addi	a2,a2,1168 # ffffffffc0205328 <commands+0x738>
ffffffffc0203ea0:	11700593          	li	a1,279
ffffffffc0203ea4:	00002517          	auipc	a0,0x2
ffffffffc0203ea8:	40c50513          	addi	a0,a0,1036 # ffffffffc02062b0 <default_pmm_manager+0xbd8>
ffffffffc0203eac:	d9afc0ef          	jal	ra,ffffffffc0200446 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203eb0:	00002617          	auipc	a2,0x2
ffffffffc0203eb4:	93060613          	addi	a2,a2,-1744 # ffffffffc02057e0 <default_pmm_manager+0x108>
ffffffffc0203eb8:	06200593          	li	a1,98
ffffffffc0203ebc:	00002517          	auipc	a0,0x2
ffffffffc0203ec0:	87c50513          	addi	a0,a0,-1924 # ffffffffc0205738 <default_pmm_manager+0x60>
ffffffffc0203ec4:	d82fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203ec8:	00002617          	auipc	a2,0x2
ffffffffc0203ecc:	84860613          	addi	a2,a2,-1976 # ffffffffc0205710 <default_pmm_manager+0x38>
ffffffffc0203ed0:	06900593          	li	a1,105
ffffffffc0203ed4:	00002517          	auipc	a0,0x2
ffffffffc0203ed8:	86450513          	addi	a0,a0,-1948 # ffffffffc0205738 <default_pmm_manager+0x60>
ffffffffc0203edc:	d6afc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203ee0:	00002697          	auipc	a3,0x2
ffffffffc0203ee4:	5d068693          	addi	a3,a3,1488 # ffffffffc02064b0 <default_pmm_manager+0xdd8>
ffffffffc0203ee8:	00001617          	auipc	a2,0x1
ffffffffc0203eec:	44060613          	addi	a2,a2,1088 # ffffffffc0205328 <commands+0x738>
ffffffffc0203ef0:	12400593          	li	a1,292
ffffffffc0203ef4:	00002517          	auipc	a0,0x2
ffffffffc0203ef8:	3bc50513          	addi	a0,a0,956 # ffffffffc02062b0 <default_pmm_manager+0xbd8>
ffffffffc0203efc:	d4afc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203f00:	00002697          	auipc	a3,0x2
ffffffffc0203f04:	f1068693          	addi	a3,a3,-240 # ffffffffc0205e10 <default_pmm_manager+0x738>
ffffffffc0203f08:	00001617          	auipc	a2,0x1
ffffffffc0203f0c:	42060613          	addi	a2,a2,1056 # ffffffffc0205328 <commands+0x738>
ffffffffc0203f10:	10500593          	li	a1,261
ffffffffc0203f14:	00002517          	auipc	a0,0x2
ffffffffc0203f18:	39c50513          	addi	a0,a0,924 # ffffffffc02062b0 <default_pmm_manager+0xbd8>
ffffffffc0203f1c:	d2afc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(mm != NULL);
ffffffffc0203f20:	00002697          	auipc	a3,0x2
ffffffffc0203f24:	ec868693          	addi	a3,a3,-312 # ffffffffc0205de8 <default_pmm_manager+0x710>
ffffffffc0203f28:	00001617          	auipc	a2,0x1
ffffffffc0203f2c:	40060613          	addi	a2,a2,1024 # ffffffffc0205328 <commands+0x738>
ffffffffc0203f30:	0c200593          	li	a1,194
ffffffffc0203f34:	00002517          	auipc	a0,0x2
ffffffffc0203f38:	37c50513          	addi	a0,a0,892 # ffffffffc02062b0 <default_pmm_manager+0xbd8>
ffffffffc0203f3c:	d0afc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203f40 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203f40:	1101                	addi	sp,sp,-32
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203f42:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203f44:	e822                	sd	s0,16(sp)
ffffffffc0203f46:	e426                	sd	s1,8(sp)
ffffffffc0203f48:	ec06                	sd	ra,24(sp)
ffffffffc0203f4a:	e04a                	sd	s2,0(sp)
ffffffffc0203f4c:	8432                	mv	s0,a2
ffffffffc0203f4e:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203f50:	8dfff0ef          	jal	ra,ffffffffc020382e <find_vma>

    pgfault_num++;
ffffffffc0203f54:	00011797          	auipc	a5,0x11
ffffffffc0203f58:	64c7a783          	lw	a5,1612(a5) # ffffffffc02155a0 <pgfault_num>
ffffffffc0203f5c:	2785                	addiw	a5,a5,1
ffffffffc0203f5e:	00011717          	auipc	a4,0x11
ffffffffc0203f62:	64f72123          	sw	a5,1602(a4) # ffffffffc02155a0 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203f66:	c931                	beqz	a0,ffffffffc0203fba <do_pgfault+0x7a>
ffffffffc0203f68:	651c                	ld	a5,8(a0)
ffffffffc0203f6a:	04f46863          	bltu	s0,a5,ffffffffc0203fba <do_pgfault+0x7a>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203f6e:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203f70:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203f72:	8b89                	andi	a5,a5,2
ffffffffc0203f74:	e39d                	bnez	a5,ffffffffc0203f9a <do_pgfault+0x5a>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203f76:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203f78:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203f7a:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203f7c:	4605                	li	a2,1
ffffffffc0203f7e:	85a2                	mv	a1,s0
ffffffffc0203f80:	b95fd0ef          	jal	ra,ffffffffc0201b14 <get_pte>
ffffffffc0203f84:	cd21                	beqz	a0,ffffffffc0203fdc <do_pgfault+0x9c>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0203f86:	610c                	ld	a1,0(a0)
ffffffffc0203f88:	c999                	beqz	a1,ffffffffc0203f9e <do_pgfault+0x5e>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203f8a:	00011797          	auipc	a5,0x11
ffffffffc0203f8e:	6067a783          	lw	a5,1542(a5) # ffffffffc0215590 <swap_init_ok>
ffffffffc0203f92:	cf8d                	beqz	a5,ffffffffc0203fcc <do_pgfault+0x8c>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            page->pra_vaddr = addr;
ffffffffc0203f94:	02003c23          	sd	zero,56(zero) # 38 <kern_entry-0xffffffffc01fffc8>
ffffffffc0203f98:	9002                	ebreak
        perm |= READ_WRITE;
ffffffffc0203f9a:	495d                	li	s2,23
ffffffffc0203f9c:	bfe9                	j	ffffffffc0203f76 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203f9e:	6c88                	ld	a0,24(s1)
ffffffffc0203fa0:	864a                	mv	a2,s2
ffffffffc0203fa2:	85a2                	mv	a1,s0
ffffffffc0203fa4:	ac9fe0ef          	jal	ra,ffffffffc0202a6c <pgdir_alloc_page>
ffffffffc0203fa8:	87aa                	mv	a5,a0
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0203faa:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203fac:	c3a1                	beqz	a5,ffffffffc0203fec <do_pgfault+0xac>
failed:
    return ret;
}
ffffffffc0203fae:	60e2                	ld	ra,24(sp)
ffffffffc0203fb0:	6442                	ld	s0,16(sp)
ffffffffc0203fb2:	64a2                	ld	s1,8(sp)
ffffffffc0203fb4:	6902                	ld	s2,0(sp)
ffffffffc0203fb6:	6105                	addi	sp,sp,32
ffffffffc0203fb8:	8082                	ret
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203fba:	85a2                	mv	a1,s0
ffffffffc0203fbc:	00002517          	auipc	a0,0x2
ffffffffc0203fc0:	56c50513          	addi	a0,a0,1388 # ffffffffc0206528 <default_pmm_manager+0xe50>
ffffffffc0203fc4:	9bcfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    int ret = -E_INVAL;
ffffffffc0203fc8:	5575                	li	a0,-3
        goto failed;
ffffffffc0203fca:	b7d5                	j	ffffffffc0203fae <do_pgfault+0x6e>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203fcc:	00002517          	auipc	a0,0x2
ffffffffc0203fd0:	5d450513          	addi	a0,a0,1492 # ffffffffc02065a0 <default_pmm_manager+0xec8>
ffffffffc0203fd4:	9acfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203fd8:	5571                	li	a0,-4
            goto failed;
ffffffffc0203fda:	bfd1                	j	ffffffffc0203fae <do_pgfault+0x6e>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0203fdc:	00002517          	auipc	a0,0x2
ffffffffc0203fe0:	57c50513          	addi	a0,a0,1404 # ffffffffc0206558 <default_pmm_manager+0xe80>
ffffffffc0203fe4:	99cfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203fe8:	5571                	li	a0,-4
        goto failed;
ffffffffc0203fea:	b7d1                	j	ffffffffc0203fae <do_pgfault+0x6e>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203fec:	00002517          	auipc	a0,0x2
ffffffffc0203ff0:	58c50513          	addi	a0,a0,1420 # ffffffffc0206578 <default_pmm_manager+0xea0>
ffffffffc0203ff4:	98cfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203ff8:	5571                	li	a0,-4
            goto failed;
ffffffffc0203ffa:	bf55                	j	ffffffffc0203fae <do_pgfault+0x6e>

ffffffffc0203ffc <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203ffc:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203ffe:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204000:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204002:	d66fc0ef          	jal	ra,ffffffffc0200568 <ide_device_valid>
ffffffffc0204006:	cd01                	beqz	a0,ffffffffc020401e <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204008:	4505                	li	a0,1
ffffffffc020400a:	d64fc0ef          	jal	ra,ffffffffc020056e <ide_device_size>
}
ffffffffc020400e:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204010:	810d                	srli	a0,a0,0x3
ffffffffc0204012:	00011797          	auipc	a5,0x11
ffffffffc0204016:	56a7b723          	sd	a0,1390(a5) # ffffffffc0215580 <max_swap_offset>
}
ffffffffc020401a:	0141                	addi	sp,sp,16
ffffffffc020401c:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc020401e:	00002617          	auipc	a2,0x2
ffffffffc0204022:	5aa60613          	addi	a2,a2,1450 # ffffffffc02065c8 <default_pmm_manager+0xef0>
ffffffffc0204026:	45b5                	li	a1,13
ffffffffc0204028:	00002517          	auipc	a0,0x2
ffffffffc020402c:	5c050513          	addi	a0,a0,1472 # ffffffffc02065e8 <default_pmm_manager+0xf10>
ffffffffc0204030:	c16fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0204034 <swapfs_write>:
swapfs_read(swap_entry_t entry, struct Page *page) {
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204034:	1141                	addi	sp,sp,-16
ffffffffc0204036:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204038:	00855793          	srli	a5,a0,0x8
ffffffffc020403c:	cbb1                	beqz	a5,ffffffffc0204090 <swapfs_write+0x5c>
ffffffffc020403e:	00011717          	auipc	a4,0x11
ffffffffc0204042:	54273703          	ld	a4,1346(a4) # ffffffffc0215580 <max_swap_offset>
ffffffffc0204046:	04e7f563          	bgeu	a5,a4,ffffffffc0204090 <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc020404a:	00011617          	auipc	a2,0x11
ffffffffc020404e:	51e63603          	ld	a2,1310(a2) # ffffffffc0215568 <pages>
ffffffffc0204052:	8d91                	sub	a1,a1,a2
ffffffffc0204054:	4065d613          	srai	a2,a1,0x6
ffffffffc0204058:	00003717          	auipc	a4,0x3
ffffffffc020405c:	95073703          	ld	a4,-1712(a4) # ffffffffc02069a8 <nbase>
ffffffffc0204060:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204062:	00c61713          	slli	a4,a2,0xc
ffffffffc0204066:	8331                	srli	a4,a4,0xc
ffffffffc0204068:	00011697          	auipc	a3,0x11
ffffffffc020406c:	4f86b683          	ld	a3,1272(a3) # ffffffffc0215560 <npage>
ffffffffc0204070:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204074:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204076:	02d77963          	bgeu	a4,a3,ffffffffc02040a8 <swapfs_write+0x74>
}
ffffffffc020407a:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020407c:	00011797          	auipc	a5,0x11
ffffffffc0204080:	4fc7b783          	ld	a5,1276(a5) # ffffffffc0215578 <va_pa_offset>
ffffffffc0204084:	46a1                	li	a3,8
ffffffffc0204086:	963e                	add	a2,a2,a5
ffffffffc0204088:	4505                	li	a0,1
}
ffffffffc020408a:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020408c:	ce8fc06f          	j	ffffffffc0200574 <ide_write_secs>
ffffffffc0204090:	86aa                	mv	a3,a0
ffffffffc0204092:	00002617          	auipc	a2,0x2
ffffffffc0204096:	56e60613          	addi	a2,a2,1390 # ffffffffc0206600 <default_pmm_manager+0xf28>
ffffffffc020409a:	45e5                	li	a1,25
ffffffffc020409c:	00002517          	auipc	a0,0x2
ffffffffc02040a0:	54c50513          	addi	a0,a0,1356 # ffffffffc02065e8 <default_pmm_manager+0xf10>
ffffffffc02040a4:	ba2fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02040a8:	86b2                	mv	a3,a2
ffffffffc02040aa:	06900593          	li	a1,105
ffffffffc02040ae:	00001617          	auipc	a2,0x1
ffffffffc02040b2:	66260613          	addi	a2,a2,1634 # ffffffffc0205710 <default_pmm_manager+0x38>
ffffffffc02040b6:	00001517          	auipc	a0,0x1
ffffffffc02040ba:	68250513          	addi	a0,a0,1666 # ffffffffc0205738 <default_pmm_manager+0x60>
ffffffffc02040be:	b88fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02040c2 <init_main>:
    panic("process exit!!.\n");
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc02040c2:	7179                	addi	sp,sp,-48
ffffffffc02040c4:	ec26                	sd	s1,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc02040c6:	00011497          	auipc	s1,0x11
ffffffffc02040ca:	44a48493          	addi	s1,s1,1098 # ffffffffc0215510 <name.0>
init_main(void *arg) {
ffffffffc02040ce:	f022                	sd	s0,32(sp)
ffffffffc02040d0:	e84a                	sd	s2,16(sp)
ffffffffc02040d2:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02040d4:	00011917          	auipc	s2,0x11
ffffffffc02040d8:	4d493903          	ld	s2,1236(s2) # ffffffffc02155a8 <current>
    memset(name, 0, sizeof(name));
ffffffffc02040dc:	4641                	li	a2,16
ffffffffc02040de:	4581                	li	a1,0
ffffffffc02040e0:	8526                	mv	a0,s1
init_main(void *arg) {
ffffffffc02040e2:	f406                	sd	ra,40(sp)
ffffffffc02040e4:	e44e                	sd	s3,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02040e6:	00492983          	lw	s3,4(s2)
    memset(name, 0, sizeof(name));
ffffffffc02040ea:	051000ef          	jal	ra,ffffffffc020493a <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02040ee:	0b490593          	addi	a1,s2,180
ffffffffc02040f2:	463d                	li	a2,15
ffffffffc02040f4:	8526                	mv	a0,s1
ffffffffc02040f6:	057000ef          	jal	ra,ffffffffc020494c <memcpy>
ffffffffc02040fa:	862a                	mv	a2,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02040fc:	85ce                	mv	a1,s3
ffffffffc02040fe:	00002517          	auipc	a0,0x2
ffffffffc0204102:	52250513          	addi	a0,a0,1314 # ffffffffc0206620 <default_pmm_manager+0xf48>
ffffffffc0204106:	87afc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc020410a:	85a2                	mv	a1,s0
ffffffffc020410c:	00002517          	auipc	a0,0x2
ffffffffc0204110:	53c50513          	addi	a0,a0,1340 # ffffffffc0206648 <default_pmm_manager+0xf70>
ffffffffc0204114:	86cfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc0204118:	00002517          	auipc	a0,0x2
ffffffffc020411c:	54050513          	addi	a0,a0,1344 # ffffffffc0206658 <default_pmm_manager+0xf80>
ffffffffc0204120:	860fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
}
ffffffffc0204124:	70a2                	ld	ra,40(sp)
ffffffffc0204126:	7402                	ld	s0,32(sp)
ffffffffc0204128:	64e2                	ld	s1,24(sp)
ffffffffc020412a:	6942                	ld	s2,16(sp)
ffffffffc020412c:	69a2                	ld	s3,8(sp)
ffffffffc020412e:	4501                	li	a0,0
ffffffffc0204130:	6145                	addi	sp,sp,48
ffffffffc0204132:	8082                	ret

ffffffffc0204134 <proc_run>:
}
ffffffffc0204134:	8082                	ret

ffffffffc0204136 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0204136:	7169                	addi	sp,sp,-304
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204138:	12000613          	li	a2,288
ffffffffc020413c:	4581                	li	a1,0
ffffffffc020413e:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0204140:	f606                	sd	ra,296(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204142:	7f8000ef          	jal	ra,ffffffffc020493a <memset>
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204146:	100027f3          	csrr	a5,sstatus
}
ffffffffc020414a:	70b2                	ld	ra,296(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc020414c:	00011517          	auipc	a0,0x11
ffffffffc0204150:	47452503          	lw	a0,1140(a0) # ffffffffc02155c0 <nr_process>
ffffffffc0204154:	6785                	lui	a5,0x1
    int ret = -E_NO_FREE_PROC;
ffffffffc0204156:	00f52533          	slt	a0,a0,a5
}
ffffffffc020415a:	156d                	addi	a0,a0,-5
ffffffffc020415c:	6155                	addi	sp,sp,304
ffffffffc020415e:	8082                	ret

ffffffffc0204160 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0204160:	7139                	addi	sp,sp,-64
ffffffffc0204162:	f426                	sd	s1,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0204164:	00011797          	auipc	a5,0x11
ffffffffc0204168:	3bc78793          	addi	a5,a5,956 # ffffffffc0215520 <proc_list>
ffffffffc020416c:	fc06                	sd	ra,56(sp)
ffffffffc020416e:	f822                	sd	s0,48(sp)
ffffffffc0204170:	f04a                	sd	s2,32(sp)
ffffffffc0204172:	ec4e                	sd	s3,24(sp)
ffffffffc0204174:	e852                	sd	s4,16(sp)
ffffffffc0204176:	e456                	sd	s5,8(sp)
ffffffffc0204178:	0000d497          	auipc	s1,0xd
ffffffffc020417c:	39848493          	addi	s1,s1,920 # ffffffffc0211510 <hash_list>
ffffffffc0204180:	e79c                	sd	a5,8(a5)
ffffffffc0204182:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0204184:	00011717          	auipc	a4,0x11
ffffffffc0204188:	38c70713          	addi	a4,a4,908 # ffffffffc0215510 <name.0>
ffffffffc020418c:	87a6                	mv	a5,s1
ffffffffc020418e:	e79c                	sd	a5,8(a5)
ffffffffc0204190:	e39c                	sd	a5,0(a5)
ffffffffc0204192:	07c1                	addi	a5,a5,16
ffffffffc0204194:	fef71de3          	bne	a4,a5,ffffffffc020418e <proc_init+0x2e>
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204198:	0e800513          	li	a0,232
ffffffffc020419c:	e8efd0ef          	jal	ra,ffffffffc020182a <kmalloc>
ffffffffc02041a0:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc02041a2:	1e050863          	beqz	a0,ffffffffc0204392 <proc_init+0x232>
    proc -> state = PROC_UNINIT;
ffffffffc02041a6:	59fd                	li	s3,-1
ffffffffc02041a8:	1982                	slli	s3,s3,0x20
    memset(&(proc -> context), 0, sizeof(struct context));
ffffffffc02041aa:	07000613          	li	a2,112
ffffffffc02041ae:	4581                	li	a1,0
    proc -> state = PROC_UNINIT;
ffffffffc02041b0:	01353023          	sd	s3,0(a0)
    proc -> runs = 0;
ffffffffc02041b4:	00052423          	sw	zero,8(a0)
    proc -> kstack = 0;
ffffffffc02041b8:	00053823          	sd	zero,16(a0)
    proc -> need_resched = 0;
ffffffffc02041bc:	00052c23          	sw	zero,24(a0)
    proc -> parent = NULL;
ffffffffc02041c0:	02053023          	sd	zero,32(a0)
    proc -> mm = NULL;
ffffffffc02041c4:	02053423          	sd	zero,40(a0)
    memset(&(proc -> context), 0, sizeof(struct context));
ffffffffc02041c8:	03050513          	addi	a0,a0,48
ffffffffc02041cc:	76e000ef          	jal	ra,ffffffffc020493a <memset>
    proc -> cr3 = boot_cr3;
ffffffffc02041d0:	00011a97          	auipc	s5,0x11
ffffffffc02041d4:	380a8a93          	addi	s5,s5,896 # ffffffffc0215550 <boot_cr3>
ffffffffc02041d8:	000ab783          	ld	a5,0(s5)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02041dc:	4641                	li	a2,16
ffffffffc02041de:	4581                	li	a1,0
    proc -> cr3 = boot_cr3;
ffffffffc02041e0:	f45c                	sd	a5,168(s0)
    proc -> tf = NULL;
ffffffffc02041e2:	0a043023          	sd	zero,160(s0)
    proc -> flags = 0;
ffffffffc02041e6:	0a042823          	sw	zero,176(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02041ea:	0b440513          	addi	a0,s0,180
ffffffffc02041ee:	74c000ef          	jal	ra,ffffffffc020493a <memset>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc02041f2:	00011917          	auipc	s2,0x11
ffffffffc02041f6:	3be90913          	addi	s2,s2,958 # ffffffffc02155b0 <idleproc>
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc02041fa:	07000513          	li	a0,112
    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc02041fe:	00893023          	sd	s0,0(s2)
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc0204202:	e28fd0ef          	jal	ra,ffffffffc020182a <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0204206:	07000613          	li	a2,112
ffffffffc020420a:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc020420c:	842a                	mv	s0,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc020420e:	72c000ef          	jal	ra,ffffffffc020493a <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc0204212:	00093503          	ld	a0,0(s2)
ffffffffc0204216:	85a2                	mv	a1,s0
ffffffffc0204218:	07000613          	li	a2,112
ffffffffc020421c:	03050513          	addi	a0,a0,48
ffffffffc0204220:	744000ef          	jal	ra,ffffffffc0204964 <memcmp>
ffffffffc0204224:	8a2a                	mv	s4,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc0204226:	453d                	li	a0,15
ffffffffc0204228:	e02fd0ef          	jal	ra,ffffffffc020182a <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc020422c:	463d                	li	a2,15
ffffffffc020422e:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc0204230:	842a                	mv	s0,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0204232:	708000ef          	jal	ra,ffffffffc020493a <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc0204236:	00093503          	ld	a0,0(s2)
ffffffffc020423a:	463d                	li	a2,15
ffffffffc020423c:	85a2                	mv	a1,s0
ffffffffc020423e:	0b450513          	addi	a0,a0,180
ffffffffc0204242:	722000ef          	jal	ra,ffffffffc0204964 <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc0204246:	00093783          	ld	a5,0(s2)
ffffffffc020424a:	000ab703          	ld	a4,0(s5)
ffffffffc020424e:	77d4                	ld	a3,168(a5)
ffffffffc0204250:	0ee68663          	beq	a3,a4,ffffffffc020433c <proc_init+0x1dc>
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0204254:	4709                	li	a4,2
ffffffffc0204256:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204258:	00003717          	auipc	a4,0x3
ffffffffc020425c:	da870713          	addi	a4,a4,-600 # ffffffffc0207000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204260:	0b478413          	addi	s0,a5,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204264:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;
ffffffffc0204266:	4705                	li	a4,1
ffffffffc0204268:	cf98                	sw	a4,24(a5)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020426a:	4641                	li	a2,16
ffffffffc020426c:	4581                	li	a1,0
ffffffffc020426e:	8522                	mv	a0,s0
ffffffffc0204270:	6ca000ef          	jal	ra,ffffffffc020493a <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204274:	463d                	li	a2,15
ffffffffc0204276:	00002597          	auipc	a1,0x2
ffffffffc020427a:	44a58593          	addi	a1,a1,1098 # ffffffffc02066c0 <default_pmm_manager+0xfe8>
ffffffffc020427e:	8522                	mv	a0,s0
ffffffffc0204280:	6cc000ef          	jal	ra,ffffffffc020494c <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0204284:	00011717          	auipc	a4,0x11
ffffffffc0204288:	33c70713          	addi	a4,a4,828 # ffffffffc02155c0 <nr_process>
ffffffffc020428c:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc020428e:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204292:	4601                	li	a2,0
    nr_process ++;
ffffffffc0204294:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204296:	00002597          	auipc	a1,0x2
ffffffffc020429a:	43258593          	addi	a1,a1,1074 # ffffffffc02066c8 <default_pmm_manager+0xff0>
ffffffffc020429e:	00000517          	auipc	a0,0x0
ffffffffc02042a2:	e2450513          	addi	a0,a0,-476 # ffffffffc02040c2 <init_main>
    nr_process ++;
ffffffffc02042a6:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc02042a8:	00011797          	auipc	a5,0x11
ffffffffc02042ac:	30d7b023          	sd	a3,768(a5) # ffffffffc02155a8 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02042b0:	e87ff0ef          	jal	ra,ffffffffc0204136 <kernel_thread>
ffffffffc02042b4:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc02042b6:	0ea05e63          	blez	a0,ffffffffc02043b2 <proc_init+0x252>
    if (0 < pid && pid < MAX_PID) {
ffffffffc02042ba:	6789                	lui	a5,0x2
ffffffffc02042bc:	fff5071b          	addiw	a4,a0,-1
ffffffffc02042c0:	17f9                	addi	a5,a5,-2
ffffffffc02042c2:	2501                	sext.w	a0,a0
ffffffffc02042c4:	02e7e363          	bltu	a5,a4,ffffffffc02042ea <proc_init+0x18a>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02042c8:	45a9                	li	a1,10
ffffffffc02042ca:	1f0000ef          	jal	ra,ffffffffc02044ba <hash32>
ffffffffc02042ce:	02051793          	slli	a5,a0,0x20
ffffffffc02042d2:	01c7d693          	srli	a3,a5,0x1c
ffffffffc02042d6:	96a6                	add	a3,a3,s1
ffffffffc02042d8:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc02042da:	a029                	j	ffffffffc02042e4 <proc_init+0x184>
            if (proc->pid == pid) {
ffffffffc02042dc:	f2c7a703          	lw	a4,-212(a5) # 1f2c <kern_entry-0xffffffffc01fe0d4>
ffffffffc02042e0:	0a870663          	beq	a4,s0,ffffffffc020438c <proc_init+0x22c>
    return listelm->next;
ffffffffc02042e4:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02042e6:	fef69be3          	bne	a3,a5,ffffffffc02042dc <proc_init+0x17c>
    return NULL;
ffffffffc02042ea:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02042ec:	0b478493          	addi	s1,a5,180
ffffffffc02042f0:	4641                	li	a2,16
ffffffffc02042f2:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc02042f4:	00011417          	auipc	s0,0x11
ffffffffc02042f8:	2c440413          	addi	s0,s0,708 # ffffffffc02155b8 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02042fc:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc02042fe:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204300:	63a000ef          	jal	ra,ffffffffc020493a <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204304:	463d                	li	a2,15
ffffffffc0204306:	00002597          	auipc	a1,0x2
ffffffffc020430a:	3f258593          	addi	a1,a1,1010 # ffffffffc02066f8 <default_pmm_manager+0x1020>
ffffffffc020430e:	8526                	mv	a0,s1
ffffffffc0204310:	63c000ef          	jal	ra,ffffffffc020494c <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204314:	00093783          	ld	a5,0(s2)
ffffffffc0204318:	cbe9                	beqz	a5,ffffffffc02043ea <proc_init+0x28a>
ffffffffc020431a:	43dc                	lw	a5,4(a5)
ffffffffc020431c:	e7f9                	bnez	a5,ffffffffc02043ea <proc_init+0x28a>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020431e:	601c                	ld	a5,0(s0)
ffffffffc0204320:	c7cd                	beqz	a5,ffffffffc02043ca <proc_init+0x26a>
ffffffffc0204322:	43d8                	lw	a4,4(a5)
ffffffffc0204324:	4785                	li	a5,1
ffffffffc0204326:	0af71263          	bne	a4,a5,ffffffffc02043ca <proc_init+0x26a>
}
ffffffffc020432a:	70e2                	ld	ra,56(sp)
ffffffffc020432c:	7442                	ld	s0,48(sp)
ffffffffc020432e:	74a2                	ld	s1,40(sp)
ffffffffc0204330:	7902                	ld	s2,32(sp)
ffffffffc0204332:	69e2                	ld	s3,24(sp)
ffffffffc0204334:	6a42                	ld	s4,16(sp)
ffffffffc0204336:	6aa2                	ld	s5,8(sp)
ffffffffc0204338:	6121                	addi	sp,sp,64
ffffffffc020433a:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc020433c:	73d8                	ld	a4,160(a5)
ffffffffc020433e:	f0071be3          	bnez	a4,ffffffffc0204254 <proc_init+0xf4>
ffffffffc0204342:	f00a19e3          	bnez	s4,ffffffffc0204254 <proc_init+0xf4>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc0204346:	6398                	ld	a4,0(a5)
ffffffffc0204348:	f13716e3          	bne	a4,s3,ffffffffc0204254 <proc_init+0xf4>
ffffffffc020434c:	4798                	lw	a4,8(a5)
ffffffffc020434e:	f00713e3          	bnez	a4,ffffffffc0204254 <proc_init+0xf4>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc0204352:	6b98                	ld	a4,16(a5)
ffffffffc0204354:	f00710e3          	bnez	a4,ffffffffc0204254 <proc_init+0xf4>
ffffffffc0204358:	4f98                	lw	a4,24(a5)
ffffffffc020435a:	2701                	sext.w	a4,a4
ffffffffc020435c:	ee071ce3          	bnez	a4,ffffffffc0204254 <proc_init+0xf4>
ffffffffc0204360:	7398                	ld	a4,32(a5)
ffffffffc0204362:	ee0719e3          	bnez	a4,ffffffffc0204254 <proc_init+0xf4>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc0204366:	7798                	ld	a4,40(a5)
ffffffffc0204368:	ee0716e3          	bnez	a4,ffffffffc0204254 <proc_init+0xf4>
ffffffffc020436c:	0b07a703          	lw	a4,176(a5)
ffffffffc0204370:	8d59                	or	a0,a0,a4
ffffffffc0204372:	0005071b          	sext.w	a4,a0
ffffffffc0204376:	ec071fe3          	bnez	a4,ffffffffc0204254 <proc_init+0xf4>
        cprintf("alloc_proc() correct!\n");
ffffffffc020437a:	00002517          	auipc	a0,0x2
ffffffffc020437e:	32e50513          	addi	a0,a0,814 # ffffffffc02066a8 <default_pmm_manager+0xfd0>
ffffffffc0204382:	dfffb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    idleproc->pid = 0;
ffffffffc0204386:	00093783          	ld	a5,0(s2)
ffffffffc020438a:	b5e9                	j	ffffffffc0204254 <proc_init+0xf4>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc020438c:	f2878793          	addi	a5,a5,-216
ffffffffc0204390:	bfb1                	j	ffffffffc02042ec <proc_init+0x18c>
        panic("cannot alloc idleproc.\n");
ffffffffc0204392:	00002617          	auipc	a2,0x2
ffffffffc0204396:	3be60613          	addi	a2,a2,958 # ffffffffc0206750 <default_pmm_manager+0x1078>
ffffffffc020439a:	16400593          	li	a1,356
ffffffffc020439e:	00002517          	auipc	a0,0x2
ffffffffc02043a2:	2f250513          	addi	a0,a0,754 # ffffffffc0206690 <default_pmm_manager+0xfb8>
    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc02043a6:	00011797          	auipc	a5,0x11
ffffffffc02043aa:	2007b523          	sd	zero,522(a5) # ffffffffc02155b0 <idleproc>
        panic("cannot alloc idleproc.\n");
ffffffffc02043ae:	898fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        panic("create init_main failed.\n");
ffffffffc02043b2:	00002617          	auipc	a2,0x2
ffffffffc02043b6:	32660613          	addi	a2,a2,806 # ffffffffc02066d8 <default_pmm_manager+0x1000>
ffffffffc02043ba:	18400593          	li	a1,388
ffffffffc02043be:	00002517          	auipc	a0,0x2
ffffffffc02043c2:	2d250513          	addi	a0,a0,722 # ffffffffc0206690 <default_pmm_manager+0xfb8>
ffffffffc02043c6:	880fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02043ca:	00002697          	auipc	a3,0x2
ffffffffc02043ce:	35e68693          	addi	a3,a3,862 # ffffffffc0206728 <default_pmm_manager+0x1050>
ffffffffc02043d2:	00001617          	auipc	a2,0x1
ffffffffc02043d6:	f5660613          	addi	a2,a2,-170 # ffffffffc0205328 <commands+0x738>
ffffffffc02043da:	18b00593          	li	a1,395
ffffffffc02043de:	00002517          	auipc	a0,0x2
ffffffffc02043e2:	2b250513          	addi	a0,a0,690 # ffffffffc0206690 <default_pmm_manager+0xfb8>
ffffffffc02043e6:	860fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02043ea:	00002697          	auipc	a3,0x2
ffffffffc02043ee:	31668693          	addi	a3,a3,790 # ffffffffc0206700 <default_pmm_manager+0x1028>
ffffffffc02043f2:	00001617          	auipc	a2,0x1
ffffffffc02043f6:	f3660613          	addi	a2,a2,-202 # ffffffffc0205328 <commands+0x738>
ffffffffc02043fa:	18a00593          	li	a1,394
ffffffffc02043fe:	00002517          	auipc	a0,0x2
ffffffffc0204402:	29250513          	addi	a0,a0,658 # ffffffffc0206690 <default_pmm_manager+0xfb8>
ffffffffc0204406:	840fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020440a <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc020440a:	1141                	addi	sp,sp,-16
ffffffffc020440c:	e022                	sd	s0,0(sp)
ffffffffc020440e:	e406                	sd	ra,8(sp)
ffffffffc0204410:	00011417          	auipc	s0,0x11
ffffffffc0204414:	19840413          	addi	s0,s0,408 # ffffffffc02155a8 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0204418:	6018                	ld	a4,0(s0)
ffffffffc020441a:	4f1c                	lw	a5,24(a4)
ffffffffc020441c:	2781                	sext.w	a5,a5
ffffffffc020441e:	dff5                	beqz	a5,ffffffffc020441a <cpu_idle+0x10>
            schedule();
ffffffffc0204420:	006000ef          	jal	ra,ffffffffc0204426 <schedule>
ffffffffc0204424:	bfd5                	j	ffffffffc0204418 <cpu_idle+0xe>

ffffffffc0204426 <schedule>:
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
    proc->state = PROC_RUNNABLE;
}

void
schedule(void) {
ffffffffc0204426:	1141                	addi	sp,sp,-16
ffffffffc0204428:	e406                	sd	ra,8(sp)
ffffffffc020442a:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020442c:	100027f3          	csrr	a5,sstatus
ffffffffc0204430:	8b89                	andi	a5,a5,2
ffffffffc0204432:	4401                	li	s0,0
ffffffffc0204434:	efbd                	bnez	a5,ffffffffc02044b2 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0204436:	00011897          	auipc	a7,0x11
ffffffffc020443a:	1728b883          	ld	a7,370(a7) # ffffffffc02155a8 <current>
ffffffffc020443e:	0008ac23          	sw	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204442:	00011517          	auipc	a0,0x11
ffffffffc0204446:	16e53503          	ld	a0,366(a0) # ffffffffc02155b0 <idleproc>
ffffffffc020444a:	04a88e63          	beq	a7,a0,ffffffffc02044a6 <schedule+0x80>
ffffffffc020444e:	0c888693          	addi	a3,a7,200
ffffffffc0204452:	00011617          	auipc	a2,0x11
ffffffffc0204456:	0ce60613          	addi	a2,a2,206 # ffffffffc0215520 <proc_list>
        le = last;
ffffffffc020445a:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc020445c:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc020445e:	4809                	li	a6,2
ffffffffc0204460:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0204462:	00c78863          	beq	a5,a2,ffffffffc0204472 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204466:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc020446a:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc020446e:	03070163          	beq	a4,a6,ffffffffc0204490 <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc0204472:	fef697e3          	bne	a3,a5,ffffffffc0204460 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0204476:	ed89                	bnez	a1,ffffffffc0204490 <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0204478:	451c                	lw	a5,8(a0)
ffffffffc020447a:	2785                	addiw	a5,a5,1
ffffffffc020447c:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc020447e:	00a88463          	beq	a7,a0,ffffffffc0204486 <schedule+0x60>
            proc_run(next);
ffffffffc0204482:	cb3ff0ef          	jal	ra,ffffffffc0204134 <proc_run>
    if (flag) {
ffffffffc0204486:	e819                	bnez	s0,ffffffffc020449c <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0204488:	60a2                	ld	ra,8(sp)
ffffffffc020448a:	6402                	ld	s0,0(sp)
ffffffffc020448c:	0141                	addi	sp,sp,16
ffffffffc020448e:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0204490:	4198                	lw	a4,0(a1)
ffffffffc0204492:	4789                	li	a5,2
ffffffffc0204494:	fef712e3          	bne	a4,a5,ffffffffc0204478 <schedule+0x52>
ffffffffc0204498:	852e                	mv	a0,a1
ffffffffc020449a:	bff9                	j	ffffffffc0204478 <schedule+0x52>
}
ffffffffc020449c:	6402                	ld	s0,0(sp)
ffffffffc020449e:	60a2                	ld	ra,8(sp)
ffffffffc02044a0:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02044a2:	8f6fc06f          	j	ffffffffc0200598 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02044a6:	00011617          	auipc	a2,0x11
ffffffffc02044aa:	07a60613          	addi	a2,a2,122 # ffffffffc0215520 <proc_list>
ffffffffc02044ae:	86b2                	mv	a3,a2
ffffffffc02044b0:	b76d                	j	ffffffffc020445a <schedule+0x34>
        intr_disable();
ffffffffc02044b2:	8ecfc0ef          	jal	ra,ffffffffc020059e <intr_disable>
        return 1;
ffffffffc02044b6:	4405                	li	s0,1
ffffffffc02044b8:	bfbd                	j	ffffffffc0204436 <schedule+0x10>

ffffffffc02044ba <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02044ba:	9e3707b7          	lui	a5,0x9e370
ffffffffc02044be:	2785                	addiw	a5,a5,1
ffffffffc02044c0:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc02044c4:	02000793          	li	a5,32
ffffffffc02044c8:	9f8d                	subw	a5,a5,a1
}
ffffffffc02044ca:	00f5553b          	srlw	a0,a0,a5
ffffffffc02044ce:	8082                	ret

ffffffffc02044d0 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02044d0:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02044d4:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02044d6:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02044da:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02044dc:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02044e0:	f022                	sd	s0,32(sp)
ffffffffc02044e2:	ec26                	sd	s1,24(sp)
ffffffffc02044e4:	e84a                	sd	s2,16(sp)
ffffffffc02044e6:	f406                	sd	ra,40(sp)
ffffffffc02044e8:	e44e                	sd	s3,8(sp)
ffffffffc02044ea:	84aa                	mv	s1,a0
ffffffffc02044ec:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02044ee:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02044f2:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02044f4:	03067e63          	bgeu	a2,a6,ffffffffc0204530 <printnum+0x60>
ffffffffc02044f8:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02044fa:	00805763          	blez	s0,ffffffffc0204508 <printnum+0x38>
ffffffffc02044fe:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204500:	85ca                	mv	a1,s2
ffffffffc0204502:	854e                	mv	a0,s3
ffffffffc0204504:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204506:	fc65                	bnez	s0,ffffffffc02044fe <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204508:	1a02                	slli	s4,s4,0x20
ffffffffc020450a:	00002797          	auipc	a5,0x2
ffffffffc020450e:	25e78793          	addi	a5,a5,606 # ffffffffc0206768 <default_pmm_manager+0x1090>
ffffffffc0204512:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204516:	9a3e                	add	s4,s4,a5
}
ffffffffc0204518:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020451a:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020451e:	70a2                	ld	ra,40(sp)
ffffffffc0204520:	69a2                	ld	s3,8(sp)
ffffffffc0204522:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204524:	85ca                	mv	a1,s2
ffffffffc0204526:	87a6                	mv	a5,s1
}
ffffffffc0204528:	6942                	ld	s2,16(sp)
ffffffffc020452a:	64e2                	ld	s1,24(sp)
ffffffffc020452c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020452e:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204530:	03065633          	divu	a2,a2,a6
ffffffffc0204534:	8722                	mv	a4,s0
ffffffffc0204536:	f9bff0ef          	jal	ra,ffffffffc02044d0 <printnum>
ffffffffc020453a:	b7f9                	j	ffffffffc0204508 <printnum+0x38>

ffffffffc020453c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020453c:	7119                	addi	sp,sp,-128
ffffffffc020453e:	f4a6                	sd	s1,104(sp)
ffffffffc0204540:	f0ca                	sd	s2,96(sp)
ffffffffc0204542:	ecce                	sd	s3,88(sp)
ffffffffc0204544:	e8d2                	sd	s4,80(sp)
ffffffffc0204546:	e4d6                	sd	s5,72(sp)
ffffffffc0204548:	e0da                	sd	s6,64(sp)
ffffffffc020454a:	fc5e                	sd	s7,56(sp)
ffffffffc020454c:	f06a                	sd	s10,32(sp)
ffffffffc020454e:	fc86                	sd	ra,120(sp)
ffffffffc0204550:	f8a2                	sd	s0,112(sp)
ffffffffc0204552:	f862                	sd	s8,48(sp)
ffffffffc0204554:	f466                	sd	s9,40(sp)
ffffffffc0204556:	ec6e                	sd	s11,24(sp)
ffffffffc0204558:	892a                	mv	s2,a0
ffffffffc020455a:	84ae                	mv	s1,a1
ffffffffc020455c:	8d32                	mv	s10,a2
ffffffffc020455e:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204560:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204564:	5b7d                	li	s6,-1
ffffffffc0204566:	00002a97          	auipc	s5,0x2
ffffffffc020456a:	22ea8a93          	addi	s5,s5,558 # ffffffffc0206794 <default_pmm_manager+0x10bc>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020456e:	00002b97          	auipc	s7,0x2
ffffffffc0204572:	402b8b93          	addi	s7,s7,1026 # ffffffffc0206970 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204576:	000d4503          	lbu	a0,0(s10)
ffffffffc020457a:	001d0413          	addi	s0,s10,1
ffffffffc020457e:	01350a63          	beq	a0,s3,ffffffffc0204592 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0204582:	c121                	beqz	a0,ffffffffc02045c2 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0204584:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204586:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204588:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020458a:	fff44503          	lbu	a0,-1(s0)
ffffffffc020458e:	ff351ae3          	bne	a0,s3,ffffffffc0204582 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204592:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204596:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020459a:	4c81                	li	s9,0
ffffffffc020459c:	4881                	li	a7,0
        width = precision = -1;
ffffffffc020459e:	5c7d                	li	s8,-1
ffffffffc02045a0:	5dfd                	li	s11,-1
ffffffffc02045a2:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02045a6:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02045a8:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02045ac:	0ff5f593          	zext.b	a1,a1
ffffffffc02045b0:	00140d13          	addi	s10,s0,1
ffffffffc02045b4:	04b56263          	bltu	a0,a1,ffffffffc02045f8 <vprintfmt+0xbc>
ffffffffc02045b8:	058a                	slli	a1,a1,0x2
ffffffffc02045ba:	95d6                	add	a1,a1,s5
ffffffffc02045bc:	4194                	lw	a3,0(a1)
ffffffffc02045be:	96d6                	add	a3,a3,s5
ffffffffc02045c0:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02045c2:	70e6                	ld	ra,120(sp)
ffffffffc02045c4:	7446                	ld	s0,112(sp)
ffffffffc02045c6:	74a6                	ld	s1,104(sp)
ffffffffc02045c8:	7906                	ld	s2,96(sp)
ffffffffc02045ca:	69e6                	ld	s3,88(sp)
ffffffffc02045cc:	6a46                	ld	s4,80(sp)
ffffffffc02045ce:	6aa6                	ld	s5,72(sp)
ffffffffc02045d0:	6b06                	ld	s6,64(sp)
ffffffffc02045d2:	7be2                	ld	s7,56(sp)
ffffffffc02045d4:	7c42                	ld	s8,48(sp)
ffffffffc02045d6:	7ca2                	ld	s9,40(sp)
ffffffffc02045d8:	7d02                	ld	s10,32(sp)
ffffffffc02045da:	6de2                	ld	s11,24(sp)
ffffffffc02045dc:	6109                	addi	sp,sp,128
ffffffffc02045de:	8082                	ret
            padc = '0';
ffffffffc02045e0:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02045e2:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02045e6:	846a                	mv	s0,s10
ffffffffc02045e8:	00140d13          	addi	s10,s0,1
ffffffffc02045ec:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02045f0:	0ff5f593          	zext.b	a1,a1
ffffffffc02045f4:	fcb572e3          	bgeu	a0,a1,ffffffffc02045b8 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02045f8:	85a6                	mv	a1,s1
ffffffffc02045fa:	02500513          	li	a0,37
ffffffffc02045fe:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204600:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204604:	8d22                	mv	s10,s0
ffffffffc0204606:	f73788e3          	beq	a5,s3,ffffffffc0204576 <vprintfmt+0x3a>
ffffffffc020460a:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020460e:	1d7d                	addi	s10,s10,-1
ffffffffc0204610:	ff379de3          	bne	a5,s3,ffffffffc020460a <vprintfmt+0xce>
ffffffffc0204614:	b78d                	j	ffffffffc0204576 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0204616:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020461a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020461e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204620:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204624:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204628:	02d86463          	bltu	a6,a3,ffffffffc0204650 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020462c:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204630:	002c169b          	slliw	a3,s8,0x2
ffffffffc0204634:	0186873b          	addw	a4,a3,s8
ffffffffc0204638:	0017171b          	slliw	a4,a4,0x1
ffffffffc020463c:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020463e:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0204642:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204644:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0204648:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020464c:	fed870e3          	bgeu	a6,a3,ffffffffc020462c <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0204650:	f40ddce3          	bgez	s11,ffffffffc02045a8 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0204654:	8de2                	mv	s11,s8
ffffffffc0204656:	5c7d                	li	s8,-1
ffffffffc0204658:	bf81                	j	ffffffffc02045a8 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020465a:	fffdc693          	not	a3,s11
ffffffffc020465e:	96fd                	srai	a3,a3,0x3f
ffffffffc0204660:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204664:	00144603          	lbu	a2,1(s0)
ffffffffc0204668:	2d81                	sext.w	s11,s11
ffffffffc020466a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020466c:	bf35                	j	ffffffffc02045a8 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020466e:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204672:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204676:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204678:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020467a:	bfd9                	j	ffffffffc0204650 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020467c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020467e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204682:	01174463          	blt	a4,a7,ffffffffc020468a <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0204686:	1a088e63          	beqz	a7,ffffffffc0204842 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020468a:	000a3603          	ld	a2,0(s4)
ffffffffc020468e:	46c1                	li	a3,16
ffffffffc0204690:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204692:	2781                	sext.w	a5,a5
ffffffffc0204694:	876e                	mv	a4,s11
ffffffffc0204696:	85a6                	mv	a1,s1
ffffffffc0204698:	854a                	mv	a0,s2
ffffffffc020469a:	e37ff0ef          	jal	ra,ffffffffc02044d0 <printnum>
            break;
ffffffffc020469e:	bde1                	j	ffffffffc0204576 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02046a0:	000a2503          	lw	a0,0(s4)
ffffffffc02046a4:	85a6                	mv	a1,s1
ffffffffc02046a6:	0a21                	addi	s4,s4,8
ffffffffc02046a8:	9902                	jalr	s2
            break;
ffffffffc02046aa:	b5f1                	j	ffffffffc0204576 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02046ac:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02046ae:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02046b2:	01174463          	blt	a4,a7,ffffffffc02046ba <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02046b6:	18088163          	beqz	a7,ffffffffc0204838 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02046ba:	000a3603          	ld	a2,0(s4)
ffffffffc02046be:	46a9                	li	a3,10
ffffffffc02046c0:	8a2e                	mv	s4,a1
ffffffffc02046c2:	bfc1                	j	ffffffffc0204692 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02046c4:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02046c8:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02046ca:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02046cc:	bdf1                	j	ffffffffc02045a8 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02046ce:	85a6                	mv	a1,s1
ffffffffc02046d0:	02500513          	li	a0,37
ffffffffc02046d4:	9902                	jalr	s2
            break;
ffffffffc02046d6:	b545                	j	ffffffffc0204576 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02046d8:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02046dc:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02046de:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02046e0:	b5e1                	j	ffffffffc02045a8 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02046e2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02046e4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02046e8:	01174463          	blt	a4,a7,ffffffffc02046f0 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02046ec:	14088163          	beqz	a7,ffffffffc020482e <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02046f0:	000a3603          	ld	a2,0(s4)
ffffffffc02046f4:	46a1                	li	a3,8
ffffffffc02046f6:	8a2e                	mv	s4,a1
ffffffffc02046f8:	bf69                	j	ffffffffc0204692 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02046fa:	03000513          	li	a0,48
ffffffffc02046fe:	85a6                	mv	a1,s1
ffffffffc0204700:	e03e                	sd	a5,0(sp)
ffffffffc0204702:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204704:	85a6                	mv	a1,s1
ffffffffc0204706:	07800513          	li	a0,120
ffffffffc020470a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020470c:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020470e:	6782                	ld	a5,0(sp)
ffffffffc0204710:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204712:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0204716:	bfb5                	j	ffffffffc0204692 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204718:	000a3403          	ld	s0,0(s4)
ffffffffc020471c:	008a0713          	addi	a4,s4,8
ffffffffc0204720:	e03a                	sd	a4,0(sp)
ffffffffc0204722:	14040263          	beqz	s0,ffffffffc0204866 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0204726:	0fb05763          	blez	s11,ffffffffc0204814 <vprintfmt+0x2d8>
ffffffffc020472a:	02d00693          	li	a3,45
ffffffffc020472e:	0cd79163          	bne	a5,a3,ffffffffc02047f0 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204732:	00044783          	lbu	a5,0(s0)
ffffffffc0204736:	0007851b          	sext.w	a0,a5
ffffffffc020473a:	cf85                	beqz	a5,ffffffffc0204772 <vprintfmt+0x236>
ffffffffc020473c:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204740:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204744:	000c4563          	bltz	s8,ffffffffc020474e <vprintfmt+0x212>
ffffffffc0204748:	3c7d                	addiw	s8,s8,-1
ffffffffc020474a:	036c0263          	beq	s8,s6,ffffffffc020476e <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020474e:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204750:	0e0c8e63          	beqz	s9,ffffffffc020484c <vprintfmt+0x310>
ffffffffc0204754:	3781                	addiw	a5,a5,-32
ffffffffc0204756:	0ef47b63          	bgeu	s0,a5,ffffffffc020484c <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020475a:	03f00513          	li	a0,63
ffffffffc020475e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204760:	000a4783          	lbu	a5,0(s4)
ffffffffc0204764:	3dfd                	addiw	s11,s11,-1
ffffffffc0204766:	0a05                	addi	s4,s4,1
ffffffffc0204768:	0007851b          	sext.w	a0,a5
ffffffffc020476c:	ffe1                	bnez	a5,ffffffffc0204744 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc020476e:	01b05963          	blez	s11,ffffffffc0204780 <vprintfmt+0x244>
ffffffffc0204772:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204774:	85a6                	mv	a1,s1
ffffffffc0204776:	02000513          	li	a0,32
ffffffffc020477a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020477c:	fe0d9be3          	bnez	s11,ffffffffc0204772 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204780:	6a02                	ld	s4,0(sp)
ffffffffc0204782:	bbd5                	j	ffffffffc0204576 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204784:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204786:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020478a:	01174463          	blt	a4,a7,ffffffffc0204792 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc020478e:	08088d63          	beqz	a7,ffffffffc0204828 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0204792:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0204796:	0a044d63          	bltz	s0,ffffffffc0204850 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020479a:	8622                	mv	a2,s0
ffffffffc020479c:	8a66                	mv	s4,s9
ffffffffc020479e:	46a9                	li	a3,10
ffffffffc02047a0:	bdcd                	j	ffffffffc0204692 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02047a2:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02047a6:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02047a8:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02047aa:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02047ae:	8fb5                	xor	a5,a5,a3
ffffffffc02047b0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02047b4:	02d74163          	blt	a4,a3,ffffffffc02047d6 <vprintfmt+0x29a>
ffffffffc02047b8:	00369793          	slli	a5,a3,0x3
ffffffffc02047bc:	97de                	add	a5,a5,s7
ffffffffc02047be:	639c                	ld	a5,0(a5)
ffffffffc02047c0:	cb99                	beqz	a5,ffffffffc02047d6 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02047c2:	86be                	mv	a3,a5
ffffffffc02047c4:	00000617          	auipc	a2,0x0
ffffffffc02047c8:	1ec60613          	addi	a2,a2,492 # ffffffffc02049b0 <etext+0x28>
ffffffffc02047cc:	85a6                	mv	a1,s1
ffffffffc02047ce:	854a                	mv	a0,s2
ffffffffc02047d0:	0ce000ef          	jal	ra,ffffffffc020489e <printfmt>
ffffffffc02047d4:	b34d                	j	ffffffffc0204576 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02047d6:	00002617          	auipc	a2,0x2
ffffffffc02047da:	fb260613          	addi	a2,a2,-78 # ffffffffc0206788 <default_pmm_manager+0x10b0>
ffffffffc02047de:	85a6                	mv	a1,s1
ffffffffc02047e0:	854a                	mv	a0,s2
ffffffffc02047e2:	0bc000ef          	jal	ra,ffffffffc020489e <printfmt>
ffffffffc02047e6:	bb41                	j	ffffffffc0204576 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02047e8:	00002417          	auipc	s0,0x2
ffffffffc02047ec:	f9840413          	addi	s0,s0,-104 # ffffffffc0206780 <default_pmm_manager+0x10a8>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02047f0:	85e2                	mv	a1,s8
ffffffffc02047f2:	8522                	mv	a0,s0
ffffffffc02047f4:	e43e                	sd	a5,8(sp)
ffffffffc02047f6:	0e2000ef          	jal	ra,ffffffffc02048d8 <strnlen>
ffffffffc02047fa:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02047fe:	01b05b63          	blez	s11,ffffffffc0204814 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0204802:	67a2                	ld	a5,8(sp)
ffffffffc0204804:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204808:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020480a:	85a6                	mv	a1,s1
ffffffffc020480c:	8552                	mv	a0,s4
ffffffffc020480e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204810:	fe0d9ce3          	bnez	s11,ffffffffc0204808 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204814:	00044783          	lbu	a5,0(s0)
ffffffffc0204818:	00140a13          	addi	s4,s0,1
ffffffffc020481c:	0007851b          	sext.w	a0,a5
ffffffffc0204820:	d3a5                	beqz	a5,ffffffffc0204780 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204822:	05e00413          	li	s0,94
ffffffffc0204826:	bf39                	j	ffffffffc0204744 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0204828:	000a2403          	lw	s0,0(s4)
ffffffffc020482c:	b7ad                	j	ffffffffc0204796 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020482e:	000a6603          	lwu	a2,0(s4)
ffffffffc0204832:	46a1                	li	a3,8
ffffffffc0204834:	8a2e                	mv	s4,a1
ffffffffc0204836:	bdb1                	j	ffffffffc0204692 <vprintfmt+0x156>
ffffffffc0204838:	000a6603          	lwu	a2,0(s4)
ffffffffc020483c:	46a9                	li	a3,10
ffffffffc020483e:	8a2e                	mv	s4,a1
ffffffffc0204840:	bd89                	j	ffffffffc0204692 <vprintfmt+0x156>
ffffffffc0204842:	000a6603          	lwu	a2,0(s4)
ffffffffc0204846:	46c1                	li	a3,16
ffffffffc0204848:	8a2e                	mv	s4,a1
ffffffffc020484a:	b5a1                	j	ffffffffc0204692 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020484c:	9902                	jalr	s2
ffffffffc020484e:	bf09                	j	ffffffffc0204760 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0204850:	85a6                	mv	a1,s1
ffffffffc0204852:	02d00513          	li	a0,45
ffffffffc0204856:	e03e                	sd	a5,0(sp)
ffffffffc0204858:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020485a:	6782                	ld	a5,0(sp)
ffffffffc020485c:	8a66                	mv	s4,s9
ffffffffc020485e:	40800633          	neg	a2,s0
ffffffffc0204862:	46a9                	li	a3,10
ffffffffc0204864:	b53d                	j	ffffffffc0204692 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0204866:	03b05163          	blez	s11,ffffffffc0204888 <vprintfmt+0x34c>
ffffffffc020486a:	02d00693          	li	a3,45
ffffffffc020486e:	f6d79de3          	bne	a5,a3,ffffffffc02047e8 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0204872:	00002417          	auipc	s0,0x2
ffffffffc0204876:	f0e40413          	addi	s0,s0,-242 # ffffffffc0206780 <default_pmm_manager+0x10a8>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020487a:	02800793          	li	a5,40
ffffffffc020487e:	02800513          	li	a0,40
ffffffffc0204882:	00140a13          	addi	s4,s0,1
ffffffffc0204886:	bd6d                	j	ffffffffc0204740 <vprintfmt+0x204>
ffffffffc0204888:	00002a17          	auipc	s4,0x2
ffffffffc020488c:	ef9a0a13          	addi	s4,s4,-263 # ffffffffc0206781 <default_pmm_manager+0x10a9>
ffffffffc0204890:	02800513          	li	a0,40
ffffffffc0204894:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204898:	05e00413          	li	s0,94
ffffffffc020489c:	b565                	j	ffffffffc0204744 <vprintfmt+0x208>

ffffffffc020489e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020489e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02048a0:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02048a4:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02048a6:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02048a8:	ec06                	sd	ra,24(sp)
ffffffffc02048aa:	f83a                	sd	a4,48(sp)
ffffffffc02048ac:	fc3e                	sd	a5,56(sp)
ffffffffc02048ae:	e0c2                	sd	a6,64(sp)
ffffffffc02048b0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02048b2:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02048b4:	c89ff0ef          	jal	ra,ffffffffc020453c <vprintfmt>
}
ffffffffc02048b8:	60e2                	ld	ra,24(sp)
ffffffffc02048ba:	6161                	addi	sp,sp,80
ffffffffc02048bc:	8082                	ret

ffffffffc02048be <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02048be:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02048c2:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02048c4:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02048c6:	cb81                	beqz	a5,ffffffffc02048d6 <strlen+0x18>
        cnt ++;
ffffffffc02048c8:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02048ca:	00a707b3          	add	a5,a4,a0
ffffffffc02048ce:	0007c783          	lbu	a5,0(a5)
ffffffffc02048d2:	fbfd                	bnez	a5,ffffffffc02048c8 <strlen+0xa>
ffffffffc02048d4:	8082                	ret
    }
    return cnt;
}
ffffffffc02048d6:	8082                	ret

ffffffffc02048d8 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02048d8:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02048da:	e589                	bnez	a1,ffffffffc02048e4 <strnlen+0xc>
ffffffffc02048dc:	a811                	j	ffffffffc02048f0 <strnlen+0x18>
        cnt ++;
ffffffffc02048de:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02048e0:	00f58863          	beq	a1,a5,ffffffffc02048f0 <strnlen+0x18>
ffffffffc02048e4:	00f50733          	add	a4,a0,a5
ffffffffc02048e8:	00074703          	lbu	a4,0(a4)
ffffffffc02048ec:	fb6d                	bnez	a4,ffffffffc02048de <strnlen+0x6>
ffffffffc02048ee:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02048f0:	852e                	mv	a0,a1
ffffffffc02048f2:	8082                	ret

ffffffffc02048f4 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02048f4:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02048f6:	0005c703          	lbu	a4,0(a1)
ffffffffc02048fa:	0785                	addi	a5,a5,1
ffffffffc02048fc:	0585                	addi	a1,a1,1
ffffffffc02048fe:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204902:	fb75                	bnez	a4,ffffffffc02048f6 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204904:	8082                	ret

ffffffffc0204906 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204906:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020490a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020490e:	cb89                	beqz	a5,ffffffffc0204920 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0204910:	0505                	addi	a0,a0,1
ffffffffc0204912:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204914:	fee789e3          	beq	a5,a4,ffffffffc0204906 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204918:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020491c:	9d19                	subw	a0,a0,a4
ffffffffc020491e:	8082                	ret
ffffffffc0204920:	4501                	li	a0,0
ffffffffc0204922:	bfed                	j	ffffffffc020491c <strcmp+0x16>

ffffffffc0204924 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204924:	00054783          	lbu	a5,0(a0)
ffffffffc0204928:	c799                	beqz	a5,ffffffffc0204936 <strchr+0x12>
        if (*s == c) {
ffffffffc020492a:	00f58763          	beq	a1,a5,ffffffffc0204938 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020492e:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0204932:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204934:	fbfd                	bnez	a5,ffffffffc020492a <strchr+0x6>
    }
    return NULL;
ffffffffc0204936:	4501                	li	a0,0
}
ffffffffc0204938:	8082                	ret

ffffffffc020493a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020493a:	ca01                	beqz	a2,ffffffffc020494a <memset+0x10>
ffffffffc020493c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020493e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204940:	0785                	addi	a5,a5,1
ffffffffc0204942:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204946:	fec79de3          	bne	a5,a2,ffffffffc0204940 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020494a:	8082                	ret

ffffffffc020494c <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020494c:	ca19                	beqz	a2,ffffffffc0204962 <memcpy+0x16>
ffffffffc020494e:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204950:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204952:	0005c703          	lbu	a4,0(a1)
ffffffffc0204956:	0585                	addi	a1,a1,1
ffffffffc0204958:	0785                	addi	a5,a5,1
ffffffffc020495a:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020495e:	fec59ae3          	bne	a1,a2,ffffffffc0204952 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204962:	8082                	ret

ffffffffc0204964 <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0204964:	c205                	beqz	a2,ffffffffc0204984 <memcmp+0x20>
ffffffffc0204966:	962e                	add	a2,a2,a1
ffffffffc0204968:	a019                	j	ffffffffc020496e <memcmp+0xa>
ffffffffc020496a:	00c58d63          	beq	a1,a2,ffffffffc0204984 <memcmp+0x20>
        if (*s1 != *s2) {
ffffffffc020496e:	00054783          	lbu	a5,0(a0)
ffffffffc0204972:	0005c703          	lbu	a4,0(a1)
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0204976:	0505                	addi	a0,a0,1
ffffffffc0204978:	0585                	addi	a1,a1,1
        if (*s1 != *s2) {
ffffffffc020497a:	fee788e3          	beq	a5,a4,ffffffffc020496a <memcmp+0x6>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020497e:	40e7853b          	subw	a0,a5,a4
ffffffffc0204982:	8082                	ret
    }
    return 0;
ffffffffc0204984:	4501                	li	a0,0
}
ffffffffc0204986:	8082                	ret
