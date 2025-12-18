
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000d117          	auipc	sp,0xd
    80000004:	3d010113          	addi	sp,sp,976 # 8000d3d0 <stack0>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04e000ef          	jal	80000064 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000024:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000028:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002c:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80000030:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000034:	577d                	li	a4,-1
    80000036:	177e                	slli	a4,a4,0x3f
    80000038:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    8000003a:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003e:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000042:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000046:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    8000004a:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004e:	000f4737          	lui	a4,0xf4
    80000052:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000056:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000058:	14d79073          	csrw	stimecmp,a5
}
    8000005c:	60a2                	ld	ra,8(sp)
    8000005e:	6402                	ld	s0,0(sp)
    80000060:	0141                	addi	sp,sp,16
    80000062:	8082                	ret

0000000080000064 <start>:
{
    80000064:	1141                	addi	sp,sp,-16
    80000066:	e406                	sd	ra,8(sp)
    80000068:	e022                	sd	s0,0(sp)
    8000006a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000070:	7779                	lui	a4,0xffffe
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fd2ad27>
    80000076:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000078:	6705                	lui	a4,0x1
    8000007a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000080:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000084:	00001797          	auipc	a5,0x1
    80000088:	e2e78793          	addi	a5,a5,-466 # 80000eb2 <main>
    8000008c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80000090:	4781                	li	a5,0
    80000092:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000096:	67c1                	lui	a5,0x10
    80000098:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000009a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000a2:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a6:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000aa:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000ae:	57fd                	li	a5,-1
    800000b0:	83a9                	srli	a5,a5,0xa
    800000b2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b6:	47bd                	li	a5,15
    800000b8:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000bc:	f61ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000c0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c8:	30200073          	mret
}
    800000cc:	60a2                	ld	ra,8(sp)
    800000ce:	6402                	ld	s0,0(sp)
    800000d0:	0141                	addi	sp,sp,16
    800000d2:	8082                	ret

00000000800000d4 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d4:	7119                	addi	sp,sp,-128
    800000d6:	fc86                	sd	ra,120(sp)
    800000d8:	f8a2                	sd	s0,112(sp)
    800000da:	f4a6                	sd	s1,104(sp)
    800000dc:	0100                	addi	s0,sp,128
  char buf[32];
  int i = 0;

  while(i < n){
    800000de:	06c05b63          	blez	a2,80000154 <consolewrite+0x80>
    800000e2:	f0ca                	sd	s2,96(sp)
    800000e4:	ecce                	sd	s3,88(sp)
    800000e6:	e8d2                	sd	s4,80(sp)
    800000e8:	e4d6                	sd	s5,72(sp)
    800000ea:	e0da                	sd	s6,64(sp)
    800000ec:	fc5e                	sd	s7,56(sp)
    800000ee:	f862                	sd	s8,48(sp)
    800000f0:	f466                	sd	s9,40(sp)
    800000f2:	f06a                	sd	s10,32(sp)
    800000f4:	8b2a                	mv	s6,a0
    800000f6:	8bae                	mv	s7,a1
    800000f8:	8a32                	mv	s4,a2
  int i = 0;
    800000fa:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000fc:	02000c93          	li	s9,32
    80000100:	02000d13          	li	s10,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000104:	f8040a93          	addi	s5,s0,-128
    80000108:	5c7d                	li	s8,-1
    8000010a:	a025                	j	80000132 <consolewrite+0x5e>
    if(nn > n - i)
    8000010c:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000110:	86ce                	mv	a3,s3
    80000112:	01748633          	add	a2,s1,s7
    80000116:	85da                	mv	a1,s6
    80000118:	8556                	mv	a0,s5
    8000011a:	0df030ef          	jal	800039f8 <either_copyin>
    8000011e:	03850d63          	beq	a0,s8,80000158 <consolewrite+0x84>
      break;
    uartwrite(buf, nn);
    80000122:	85ce                	mv	a1,s3
    80000124:	8556                	mv	a0,s5
    80000126:	7b4000ef          	jal	800008da <uartwrite>
    i += nn;
    8000012a:	009904bb          	addw	s1,s2,s1
  while(i < n){
    8000012e:	0144d963          	bge	s1,s4,80000140 <consolewrite+0x6c>
    if(nn > n - i)
    80000132:	409a07bb          	subw	a5,s4,s1
    80000136:	893e                	mv	s2,a5
    80000138:	fcfcdae3          	bge	s9,a5,8000010c <consolewrite+0x38>
    8000013c:	896a                	mv	s2,s10
    8000013e:	b7f9                	j	8000010c <consolewrite+0x38>
    80000140:	7906                	ld	s2,96(sp)
    80000142:	69e6                	ld	s3,88(sp)
    80000144:	6a46                	ld	s4,80(sp)
    80000146:	6aa6                	ld	s5,72(sp)
    80000148:	6b06                	ld	s6,64(sp)
    8000014a:	7be2                	ld	s7,56(sp)
    8000014c:	7c42                	ld	s8,48(sp)
    8000014e:	7ca2                	ld	s9,40(sp)
    80000150:	7d02                	ld	s10,32(sp)
    80000152:	a821                	j	8000016a <consolewrite+0x96>
  int i = 0;
    80000154:	4481                	li	s1,0
    80000156:	a811                	j	8000016a <consolewrite+0x96>
    80000158:	7906                	ld	s2,96(sp)
    8000015a:	69e6                	ld	s3,88(sp)
    8000015c:	6a46                	ld	s4,80(sp)
    8000015e:	6aa6                	ld	s5,72(sp)
    80000160:	6b06                	ld	s6,64(sp)
    80000162:	7be2                	ld	s7,56(sp)
    80000164:	7c42                	ld	s8,48(sp)
    80000166:	7ca2                	ld	s9,40(sp)
    80000168:	7d02                	ld	s10,32(sp)
  }

  return i;
}
    8000016a:	8526                	mv	a0,s1
    8000016c:	70e6                	ld	ra,120(sp)
    8000016e:	7446                	ld	s0,112(sp)
    80000170:	74a6                	ld	s1,104(sp)
    80000172:	6109                	addi	sp,sp,128
    80000174:	8082                	ret

0000000080000176 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000176:	711d                	addi	sp,sp,-96
    80000178:	ec86                	sd	ra,88(sp)
    8000017a:	e8a2                	sd	s0,80(sp)
    8000017c:	e4a6                	sd	s1,72(sp)
    8000017e:	e0ca                	sd	s2,64(sp)
    80000180:	fc4e                	sd	s3,56(sp)
    80000182:	f852                	sd	s4,48(sp)
    80000184:	f05a                	sd	s6,32(sp)
    80000186:	ec5e                	sd	s7,24(sp)
    80000188:	1080                	addi	s0,sp,96
    8000018a:	8b2a                	mv	s6,a0
    8000018c:	8a2e                	mv	s4,a1
    8000018e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000190:	8bb2                	mv	s7,a2
  acquire(&cons.lock);
    80000192:	00015517          	auipc	a0,0x15
    80000196:	23e50513          	addi	a0,a0,574 # 800153d0 <cons>
    8000019a:	293000ef          	jal	80000c2c <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019e:	00015497          	auipc	s1,0x15
    800001a2:	23248493          	addi	s1,s1,562 # 800153d0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a6:	00015917          	auipc	s2,0x15
    800001aa:	2c290913          	addi	s2,s2,706 # 80015468 <cons+0x98>
  while(n > 0){
    800001ae:	0b305b63          	blez	s3,80000264 <consoleread+0xee>
    while(cons.r == cons.w){
    800001b2:	0984a783          	lw	a5,152(s1)
    800001b6:	09c4a703          	lw	a4,156(s1)
    800001ba:	0af71063          	bne	a4,a5,8000025a <consoleread+0xe4>
      if(killed(myproc())){
    800001be:	487020ef          	jal	80002e44 <myproc>
    800001c2:	6cc030ef          	jal	8000388e <killed>
    800001c6:	e12d                	bnez	a0,80000228 <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    800001c8:	85a6                	mv	a1,s1
    800001ca:	854a                	mv	a0,s2
    800001cc:	46a030ef          	jal	80003636 <sleep>
    while(cons.r == cons.w){
    800001d0:	0984a783          	lw	a5,152(s1)
    800001d4:	09c4a703          	lw	a4,156(s1)
    800001d8:	fef703e3          	beq	a4,a5,800001be <consoleread+0x48>
    800001dc:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00015717          	auipc	a4,0x15
    800001e2:	1f270713          	addi	a4,a4,498 # 800153d0 <cons>
    800001e6:	0017869b          	addiw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	andi	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070a9b          	sext.w	s5,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	04da8663          	beq	s5,a3,8000024a <consoleread+0xd4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	addi	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	855a                	mv	a0,s6
    80000210:	79e030ef          	jal	800039ae <either_copyout>
    80000214:	57fd                	li	a5,-1
    80000216:	04f50663          	beq	a0,a5,80000262 <consoleread+0xec>
      break;

    dst++;
    8000021a:	0a05                	addi	s4,s4,1
    --n;
    8000021c:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000021e:	47a9                	li	a5,10
    80000220:	04fa8b63          	beq	s5,a5,80000276 <consoleread+0x100>
    80000224:	7aa2                	ld	s5,40(sp)
    80000226:	b761                	j	800001ae <consoleread+0x38>
        release(&cons.lock);
    80000228:	00015517          	auipc	a0,0x15
    8000022c:	1a850513          	addi	a0,a0,424 # 800153d0 <cons>
    80000230:	291000ef          	jal	80000cc0 <release>
        return -1;
    80000234:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000236:	60e6                	ld	ra,88(sp)
    80000238:	6446                	ld	s0,80(sp)
    8000023a:	64a6                	ld	s1,72(sp)
    8000023c:	6906                	ld	s2,64(sp)
    8000023e:	79e2                	ld	s3,56(sp)
    80000240:	7a42                	ld	s4,48(sp)
    80000242:	7b02                	ld	s6,32(sp)
    80000244:	6be2                	ld	s7,24(sp)
    80000246:	6125                	addi	sp,sp,96
    80000248:	8082                	ret
      if(n < target){
    8000024a:	0179fa63          	bgeu	s3,s7,8000025e <consoleread+0xe8>
        cons.r--;
    8000024e:	00015717          	auipc	a4,0x15
    80000252:	20f72d23          	sw	a5,538(a4) # 80015468 <cons+0x98>
    80000256:	7aa2                	ld	s5,40(sp)
    80000258:	a031                	j	80000264 <consoleread+0xee>
    8000025a:	f456                	sd	s5,40(sp)
    8000025c:	b749                	j	800001de <consoleread+0x68>
    8000025e:	7aa2                	ld	s5,40(sp)
    80000260:	a011                	j	80000264 <consoleread+0xee>
    80000262:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000264:	00015517          	auipc	a0,0x15
    80000268:	16c50513          	addi	a0,a0,364 # 800153d0 <cons>
    8000026c:	255000ef          	jal	80000cc0 <release>
  return target - n;
    80000270:	413b853b          	subw	a0,s7,s3
    80000274:	b7c9                	j	80000236 <consoleread+0xc0>
    80000276:	7aa2                	ld	s5,40(sp)
    80000278:	b7f5                	j	80000264 <consoleread+0xee>

000000008000027a <consputc>:
{
    8000027a:	1141                	addi	sp,sp,-16
    8000027c:	e406                	sd	ra,8(sp)
    8000027e:	e022                	sd	s0,0(sp)
    80000280:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000282:	10000793          	li	a5,256
    80000286:	00f50863          	beq	a0,a5,80000296 <consputc+0x1c>
    uartputc_sync(c);
    8000028a:	6e4000ef          	jal	8000096e <uartputc_sync>
}
    8000028e:	60a2                	ld	ra,8(sp)
    80000290:	6402                	ld	s0,0(sp)
    80000292:	0141                	addi	sp,sp,16
    80000294:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000296:	4521                	li	a0,8
    80000298:	6d6000ef          	jal	8000096e <uartputc_sync>
    8000029c:	02000513          	li	a0,32
    800002a0:	6ce000ef          	jal	8000096e <uartputc_sync>
    800002a4:	4521                	li	a0,8
    800002a6:	6c8000ef          	jal	8000096e <uartputc_sync>
    800002aa:	b7d5                	j	8000028e <consputc+0x14>

00000000800002ac <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ac:	1101                	addi	sp,sp,-32
    800002ae:	ec06                	sd	ra,24(sp)
    800002b0:	e822                	sd	s0,16(sp)
    800002b2:	e426                	sd	s1,8(sp)
    800002b4:	1000                	addi	s0,sp,32
    800002b6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b8:	00015517          	auipc	a0,0x15
    800002bc:	11850513          	addi	a0,a0,280 # 800153d0 <cons>
    800002c0:	16d000ef          	jal	80000c2c <acquire>

  switch(c){
    800002c4:	47d5                	li	a5,21
    800002c6:	08f48d63          	beq	s1,a5,80000360 <consoleintr+0xb4>
    800002ca:	0297c563          	blt	a5,s1,800002f4 <consoleintr+0x48>
    800002ce:	47a1                	li	a5,8
    800002d0:	0ef48263          	beq	s1,a5,800003b4 <consoleintr+0x108>
    800002d4:	47c1                	li	a5,16
    800002d6:	10f49363          	bne	s1,a5,800003dc <consoleintr+0x130>
  case C('P'):  // Print process list.
    procdump();
    800002da:	768030ef          	jal	80003a42 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002de:	00015517          	auipc	a0,0x15
    800002e2:	0f250513          	addi	a0,a0,242 # 800153d0 <cons>
    800002e6:	1db000ef          	jal	80000cc0 <release>
}
    800002ea:	60e2                	ld	ra,24(sp)
    800002ec:	6442                	ld	s0,16(sp)
    800002ee:	64a2                	ld	s1,8(sp)
    800002f0:	6105                	addi	sp,sp,32
    800002f2:	8082                	ret
  switch(c){
    800002f4:	07f00793          	li	a5,127
    800002f8:	0af48e63          	beq	s1,a5,800003b4 <consoleintr+0x108>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fc:	00015717          	auipc	a4,0x15
    80000300:	0d470713          	addi	a4,a4,212 # 800153d0 <cons>
    80000304:	0a072783          	lw	a5,160(a4)
    80000308:	09872703          	lw	a4,152(a4)
    8000030c:	9f99                	subw	a5,a5,a4
    8000030e:	07f00713          	li	a4,127
    80000312:	fcf766e3          	bltu	a4,a5,800002de <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000316:	47b5                	li	a5,13
    80000318:	0cf48563          	beq	s1,a5,800003e2 <consoleintr+0x136>
      consputc(c);
    8000031c:	8526                	mv	a0,s1
    8000031e:	f5dff0ef          	jal	8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000322:	00015717          	auipc	a4,0x15
    80000326:	0ae70713          	addi	a4,a4,174 # 800153d0 <cons>
    8000032a:	0a072683          	lw	a3,160(a4)
    8000032e:	0016879b          	addiw	a5,a3,1
    80000332:	863e                	mv	a2,a5
    80000334:	0af72023          	sw	a5,160(a4)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	9736                	add	a4,a4,a3
    8000033e:	00970c23          	sb	s1,24(a4)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	ff648713          	addi	a4,s1,-10
    80000346:	c371                	beqz	a4,8000040a <consoleintr+0x15e>
    80000348:	14f1                	addi	s1,s1,-4
    8000034a:	c0e1                	beqz	s1,8000040a <consoleintr+0x15e>
    8000034c:	00015717          	auipc	a4,0x15
    80000350:	11c72703          	lw	a4,284(a4) # 80015468 <cons+0x98>
    80000354:	9f99                	subw	a5,a5,a4
    80000356:	08000713          	li	a4,128
    8000035a:	f8e792e3          	bne	a5,a4,800002de <consoleintr+0x32>
    8000035e:	a075                	j	8000040a <consoleintr+0x15e>
    80000360:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000362:	00015717          	auipc	a4,0x15
    80000366:	06e70713          	addi	a4,a4,110 # 800153d0 <cons>
    8000036a:	0a072783          	lw	a5,160(a4)
    8000036e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000372:	00015497          	auipc	s1,0x15
    80000376:	05e48493          	addi	s1,s1,94 # 800153d0 <cons>
    while(cons.e != cons.w &&
    8000037a:	4929                	li	s2,10
    8000037c:	02f70863          	beq	a4,a5,800003ac <consoleintr+0x100>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000380:	37fd                	addiw	a5,a5,-1
    80000382:	07f7f713          	andi	a4,a5,127
    80000386:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000388:	01874703          	lbu	a4,24(a4)
    8000038c:	03270263          	beq	a4,s2,800003b0 <consoleintr+0x104>
      cons.e--;
    80000390:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000394:	10000513          	li	a0,256
    80000398:	ee3ff0ef          	jal	8000027a <consputc>
    while(cons.e != cons.w &&
    8000039c:	0a04a783          	lw	a5,160(s1)
    800003a0:	09c4a703          	lw	a4,156(s1)
    800003a4:	fcf71ee3          	bne	a4,a5,80000380 <consoleintr+0xd4>
    800003a8:	6902                	ld	s2,0(sp)
    800003aa:	bf15                	j	800002de <consoleintr+0x32>
    800003ac:	6902                	ld	s2,0(sp)
    800003ae:	bf05                	j	800002de <consoleintr+0x32>
    800003b0:	6902                	ld	s2,0(sp)
    800003b2:	b735                	j	800002de <consoleintr+0x32>
    if(cons.e != cons.w){
    800003b4:	00015717          	auipc	a4,0x15
    800003b8:	01c70713          	addi	a4,a4,28 # 800153d0 <cons>
    800003bc:	0a072783          	lw	a5,160(a4)
    800003c0:	09c72703          	lw	a4,156(a4)
    800003c4:	f0f70de3          	beq	a4,a5,800002de <consoleintr+0x32>
      cons.e--;
    800003c8:	37fd                	addiw	a5,a5,-1
    800003ca:	00015717          	auipc	a4,0x15
    800003ce:	0af72323          	sw	a5,166(a4) # 80015470 <cons+0xa0>
      consputc(BACKSPACE);
    800003d2:	10000513          	li	a0,256
    800003d6:	ea5ff0ef          	jal	8000027a <consputc>
    800003da:	b711                	j	800002de <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003dc:	f00481e3          	beqz	s1,800002de <consoleintr+0x32>
    800003e0:	bf31                	j	800002fc <consoleintr+0x50>
      consputc(c);
    800003e2:	4529                	li	a0,10
    800003e4:	e97ff0ef          	jal	8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003e8:	00015797          	auipc	a5,0x15
    800003ec:	fe878793          	addi	a5,a5,-24 # 800153d0 <cons>
    800003f0:	0a07a703          	lw	a4,160(a5)
    800003f4:	0017069b          	addiw	a3,a4,1
    800003f8:	8636                	mv	a2,a3
    800003fa:	0ad7a023          	sw	a3,160(a5)
    800003fe:	07f77713          	andi	a4,a4,127
    80000402:	97ba                	add	a5,a5,a4
    80000404:	4729                	li	a4,10
    80000406:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040a:	00015797          	auipc	a5,0x15
    8000040e:	06c7a123          	sw	a2,98(a5) # 8001546c <cons+0x9c>
        wakeup(&cons.r);
    80000412:	00015517          	auipc	a0,0x15
    80000416:	05650513          	addi	a0,a0,86 # 80015468 <cons+0x98>
    8000041a:	268030ef          	jal	80003682 <wakeup>
    8000041e:	b5c1                	j	800002de <consoleintr+0x32>

0000000080000420 <consoleinit>:

void
consoleinit(void)
{
    80000420:	1141                	addi	sp,sp,-16
    80000422:	e406                	sd	ra,8(sp)
    80000424:	e022                	sd	s0,0(sp)
    80000426:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000428:	00009597          	auipc	a1,0x9
    8000042c:	bd858593          	addi	a1,a1,-1064 # 80009000 <etext>
    80000430:	00015517          	auipc	a0,0x15
    80000434:	fa050513          	addi	a0,a0,-96 # 800153d0 <cons>
    80000438:	76a000ef          	jal	80000ba2 <initlock>

  uartinit();
    8000043c:	448000ef          	jal	80000884 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000440:	002d2797          	auipc	a5,0x2d2
    80000444:	50078793          	addi	a5,a5,1280 # 802d2940 <devsw>
    80000448:	00000717          	auipc	a4,0x0
    8000044c:	d2e70713          	addi	a4,a4,-722 # 80000176 <consoleread>
    80000450:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000452:	00000717          	auipc	a4,0x0
    80000456:	c8270713          	addi	a4,a4,-894 # 800000d4 <consolewrite>
    8000045a:	ef98                	sd	a4,24(a5)
}
    8000045c:	60a2                	ld	ra,8(sp)
    8000045e:	6402                	ld	s0,0(sp)
    80000460:	0141                	addi	sp,sp,16
    80000462:	8082                	ret

0000000080000464 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000464:	7139                	addi	sp,sp,-64
    80000466:	fc06                	sd	ra,56(sp)
    80000468:	f822                	sd	s0,48(sp)
    8000046a:	f04a                	sd	s2,32(sp)
    8000046c:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    8000046e:	c219                	beqz	a2,80000474 <printint+0x10>
    80000470:	08054163          	bltz	a0,800004f2 <printint+0x8e>
    x = -xx;
  else
    x = xx;
    80000474:	4301                	li	t1,0

  i = 0;
    80000476:	fc840913          	addi	s2,s0,-56
    x = xx;
    8000047a:	86ca                	mv	a3,s2
  i = 0;
    8000047c:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    8000047e:	0000a817          	auipc	a6,0xa
    80000482:	dd280813          	addi	a6,a6,-558 # 8000a250 <digits>
    80000486:	88ba                	mv	a7,a4
    80000488:	0017061b          	addiw	a2,a4,1
    8000048c:	8732                	mv	a4,a2
    8000048e:	02b577b3          	remu	a5,a0,a1
    80000492:	97c2                	add	a5,a5,a6
    80000494:	0007c783          	lbu	a5,0(a5)
    80000498:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    8000049c:	87aa                	mv	a5,a0
    8000049e:	02b55533          	divu	a0,a0,a1
    800004a2:	0685                	addi	a3,a3,1
    800004a4:	feb7f1e3          	bgeu	a5,a1,80000486 <printint+0x22>

  if(sign)
    800004a8:	00030c63          	beqz	t1,800004c0 <printint+0x5c>
    buf[i++] = '-';
    800004ac:	fe060793          	addi	a5,a2,-32
    800004b0:	00878633          	add	a2,a5,s0
    800004b4:	02d00793          	li	a5,45
    800004b8:	fef60423          	sb	a5,-24(a2)
    800004bc:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
    800004c0:	02e05463          	blez	a4,800004e8 <printint+0x84>
    800004c4:	f426                	sd	s1,40(sp)
    800004c6:	377d                	addiw	a4,a4,-1
    800004c8:	00e904b3          	add	s1,s2,a4
    800004cc:	197d                	addi	s2,s2,-1
    800004ce:	993a                	add	s2,s2,a4
    800004d0:	1702                	slli	a4,a4,0x20
    800004d2:	9301                	srli	a4,a4,0x20
    800004d4:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    800004d8:	0004c503          	lbu	a0,0(s1)
    800004dc:	d9fff0ef          	jal	8000027a <consputc>
  while(--i >= 0)
    800004e0:	14fd                	addi	s1,s1,-1
    800004e2:	ff249be3          	bne	s1,s2,800004d8 <printint+0x74>
    800004e6:	74a2                	ld	s1,40(sp)
}
    800004e8:	70e2                	ld	ra,56(sp)
    800004ea:	7442                	ld	s0,48(sp)
    800004ec:	7902                	ld	s2,32(sp)
    800004ee:	6121                	addi	sp,sp,64
    800004f0:	8082                	ret
    x = -xx;
    800004f2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f6:	4305                	li	t1,1
    x = -xx;
    800004f8:	bfbd                	j	80000476 <printint+0x12>

00000000800004fa <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004fa:	7131                	addi	sp,sp,-192
    800004fc:	fc86                	sd	ra,120(sp)
    800004fe:	f8a2                	sd	s0,112(sp)
    80000500:	f0ca                	sd	s2,96(sp)
    80000502:	0100                	addi	s0,sp,128
    80000504:	892a                	mv	s2,a0
    80000506:	e40c                	sd	a1,8(s0)
    80000508:	e810                	sd	a2,16(s0)
    8000050a:	ec14                	sd	a3,24(s0)
    8000050c:	f018                	sd	a4,32(s0)
    8000050e:	f41c                	sd	a5,40(s0)
    80000510:	03043823          	sd	a6,48(s0)
    80000514:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80000518:	0000d797          	auipc	a5,0xd
    8000051c:	e8c7a783          	lw	a5,-372(a5) # 8000d3a4 <panicking>
    80000520:	cf9d                	beqz	a5,8000055e <printf+0x64>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	00094503          	lbu	a0,0(s2)
    8000052e:	22050663          	beqz	a0,8000075a <printf+0x260>
    80000532:	f4a6                	sd	s1,104(sp)
    80000534:	ecce                	sd	s3,88(sp)
    80000536:	e8d2                	sd	s4,80(sp)
    80000538:	e4d6                	sd	s5,72(sp)
    8000053a:	e0da                	sd	s6,64(sp)
    8000053c:	fc5e                	sd	s7,56(sp)
    8000053e:	f862                	sd	s8,48(sp)
    80000540:	f06a                	sd	s10,32(sp)
    80000542:	ec6e                	sd	s11,24(sp)
    80000544:	4a01                	li	s4,0
    if(cx != '%'){
    80000546:	02500993          	li	s3,37
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000054a:	07500c13          	li	s8,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    8000054e:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000552:	07000d93          	li	s11,112
      printint(va_arg(ap, uint64), 10, 0);
    80000556:	4b29                	li	s6,10
    if(c0 == 'd'){
    80000558:	06400b93          	li	s7,100
    8000055c:	a015                	j	80000580 <printf+0x86>
    acquire(&pr.lock);
    8000055e:	00015517          	auipc	a0,0x15
    80000562:	f1a50513          	addi	a0,a0,-230 # 80015478 <pr>
    80000566:	6c6000ef          	jal	80000c2c <acquire>
    8000056a:	bf65                	j	80000522 <printf+0x28>
      consputc(cx);
    8000056c:	d0fff0ef          	jal	8000027a <consputc>
      continue;
    80000570:	84d2                	mv	s1,s4
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000572:	2485                	addiw	s1,s1,1
    80000574:	8a26                	mv	s4,s1
    80000576:	94ca                	add	s1,s1,s2
    80000578:	0004c503          	lbu	a0,0(s1)
    8000057c:	1c050663          	beqz	a0,80000748 <printf+0x24e>
    if(cx != '%'){
    80000580:	ff3516e3          	bne	a0,s3,8000056c <printf+0x72>
    i++;
    80000584:	001a079b          	addiw	a5,s4,1
    80000588:	84be                	mv	s1,a5
    c0 = fmt[i+0] & 0xff;
    8000058a:	00f90733          	add	a4,s2,a5
    8000058e:	00074a83          	lbu	s5,0(a4)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000592:	200a8963          	beqz	s5,800007a4 <printf+0x2aa>
    80000596:	00174683          	lbu	a3,1(a4)
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059a:	1e068c63          	beqz	a3,80000792 <printf+0x298>
    if(c0 == 'd'){
    8000059e:	037a8863          	beq	s5,s7,800005ce <printf+0xd4>
    } else if(c0 == 'l' && c1 == 'd'){
    800005a2:	f94a8713          	addi	a4,s5,-108
    800005a6:	00173713          	seqz	a4,a4
    800005aa:	f9c68613          	addi	a2,a3,-100
    800005ae:	ee05                	bnez	a2,800005e6 <printf+0xec>
    800005b0:	cb1d                	beqz	a4,800005e6 <printf+0xec>
      printint(va_arg(ap, uint64), 10, 1);
    800005b2:	f8843783          	ld	a5,-120(s0)
    800005b6:	00878713          	addi	a4,a5,8
    800005ba:	f8e43423          	sd	a4,-120(s0)
    800005be:	4605                	li	a2,1
    800005c0:	85da                	mv	a1,s6
    800005c2:	6388                	ld	a0,0(a5)
    800005c4:	ea1ff0ef          	jal	80000464 <printint>
      i += 1;
    800005c8:	002a049b          	addiw	s1,s4,2
    800005cc:	b75d                	j	80000572 <printf+0x78>
      printint(va_arg(ap, int), 10, 1);
    800005ce:	f8843783          	ld	a5,-120(s0)
    800005d2:	00878713          	addi	a4,a5,8
    800005d6:	f8e43423          	sd	a4,-120(s0)
    800005da:	4605                	li	a2,1
    800005dc:	85da                	mv	a1,s6
    800005de:	4388                	lw	a0,0(a5)
    800005e0:	e85ff0ef          	jal	80000464 <printint>
    800005e4:	b779                	j	80000572 <printf+0x78>
    if(c1) c2 = fmt[i+2] & 0xff;
    800005e6:	97ca                	add	a5,a5,s2
    800005e8:	8636                	mv	a2,a3
    800005ea:	0027c683          	lbu	a3,2(a5)
    800005ee:	a2c9                	j	800007b0 <printf+0x2b6>
      printint(va_arg(ap, uint64), 10, 1);
    800005f0:	f8843783          	ld	a5,-120(s0)
    800005f4:	00878713          	addi	a4,a5,8
    800005f8:	f8e43423          	sd	a4,-120(s0)
    800005fc:	4605                	li	a2,1
    800005fe:	45a9                	li	a1,10
    80000600:	6388                	ld	a0,0(a5)
    80000602:	e63ff0ef          	jal	80000464 <printint>
      i += 2;
    80000606:	003a049b          	addiw	s1,s4,3
    8000060a:	b7a5                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint32), 10, 0);
    8000060c:	f8843783          	ld	a5,-120(s0)
    80000610:	00878713          	addi	a4,a5,8
    80000614:	f8e43423          	sd	a4,-120(s0)
    80000618:	4601                	li	a2,0
    8000061a:	85da                	mv	a1,s6
    8000061c:	0007e503          	lwu	a0,0(a5)
    80000620:	e45ff0ef          	jal	80000464 <printint>
    80000624:	b7b9                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000626:	f8843783          	ld	a5,-120(s0)
    8000062a:	00878713          	addi	a4,a5,8
    8000062e:	f8e43423          	sd	a4,-120(s0)
    80000632:	4601                	li	a2,0
    80000634:	85da                	mv	a1,s6
    80000636:	6388                	ld	a0,0(a5)
    80000638:	e2dff0ef          	jal	80000464 <printint>
      i += 1;
    8000063c:	002a049b          	addiw	s1,s4,2
    80000640:	bf0d                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000642:	f8843783          	ld	a5,-120(s0)
    80000646:	00878713          	addi	a4,a5,8
    8000064a:	f8e43423          	sd	a4,-120(s0)
    8000064e:	4601                	li	a2,0
    80000650:	45a9                	li	a1,10
    80000652:	6388                	ld	a0,0(a5)
    80000654:	e11ff0ef          	jal	80000464 <printint>
      i += 2;
    80000658:	003a049b          	addiw	s1,s4,3
    8000065c:	bf19                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint32), 16, 0);
    8000065e:	f8843783          	ld	a5,-120(s0)
    80000662:	00878713          	addi	a4,a5,8
    80000666:	f8e43423          	sd	a4,-120(s0)
    8000066a:	4601                	li	a2,0
    8000066c:	45c1                	li	a1,16
    8000066e:	0007e503          	lwu	a0,0(a5)
    80000672:	df3ff0ef          	jal	80000464 <printint>
    80000676:	bdf5                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	45c1                	li	a1,16
    80000686:	6388                	ld	a0,0(a5)
    80000688:	dddff0ef          	jal	80000464 <printint>
      i += 1;
    8000068c:	002a049b          	addiw	s1,s4,2
    80000690:	b5cd                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000692:	f8843783          	ld	a5,-120(s0)
    80000696:	00878713          	addi	a4,a5,8
    8000069a:	f8e43423          	sd	a4,-120(s0)
    8000069e:	4601                	li	a2,0
    800006a0:	45c1                	li	a1,16
    800006a2:	6388                	ld	a0,0(a5)
    800006a4:	dc1ff0ef          	jal	80000464 <printint>
      i += 2;
    800006a8:	003a049b          	addiw	s1,s4,3
    800006ac:	b5d9                	j	80000572 <printf+0x78>
    800006ae:	f466                	sd	s9,40(sp)
      printptr(va_arg(ap, uint64));
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	0007ba83          	ld	s5,0(a5)
  consputc('0');
    800006c0:	03000513          	li	a0,48
    800006c4:	bb7ff0ef          	jal	8000027a <consputc>
  consputc('x');
    800006c8:	07800513          	li	a0,120
    800006cc:	bafff0ef          	jal	8000027a <consputc>
    800006d0:	4a41                	li	s4,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006d2:	0000ac97          	auipc	s9,0xa
    800006d6:	b7ec8c93          	addi	s9,s9,-1154 # 8000a250 <digits>
    800006da:	03cad793          	srli	a5,s5,0x3c
    800006de:	97e6                	add	a5,a5,s9
    800006e0:	0007c503          	lbu	a0,0(a5)
    800006e4:	b97ff0ef          	jal	8000027a <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006e8:	0a92                	slli	s5,s5,0x4
    800006ea:	3a7d                	addiw	s4,s4,-1
    800006ec:	fe0a17e3          	bnez	s4,800006da <printf+0x1e0>
    800006f0:	7ca2                	ld	s9,40(sp)
    800006f2:	b541                	j	80000572 <printf+0x78>
    } else if(c0 == 'c'){
      consputc(va_arg(ap, uint));
    800006f4:	f8843783          	ld	a5,-120(s0)
    800006f8:	00878713          	addi	a4,a5,8
    800006fc:	f8e43423          	sd	a4,-120(s0)
    80000700:	4388                	lw	a0,0(a5)
    80000702:	b79ff0ef          	jal	8000027a <consputc>
    80000706:	b5b5                	j	80000572 <printf+0x78>
    } else if(c0 == 's'){
      if((s = va_arg(ap, char*)) == 0)
    80000708:	f8843783          	ld	a5,-120(s0)
    8000070c:	00878713          	addi	a4,a5,8
    80000710:	f8e43423          	sd	a4,-120(s0)
    80000714:	0007ba03          	ld	s4,0(a5)
    80000718:	000a0d63          	beqz	s4,80000732 <printf+0x238>
        s = "(null)";
      for(; *s; s++)
    8000071c:	000a4503          	lbu	a0,0(s4)
    80000720:	e40509e3          	beqz	a0,80000572 <printf+0x78>
        consputc(*s);
    80000724:	b57ff0ef          	jal	8000027a <consputc>
      for(; *s; s++)
    80000728:	0a05                	addi	s4,s4,1
    8000072a:	000a4503          	lbu	a0,0(s4)
    8000072e:	f97d                	bnez	a0,80000724 <printf+0x22a>
    80000730:	b589                	j	80000572 <printf+0x78>
        s = "(null)";
    80000732:	00009a17          	auipc	s4,0x9
    80000736:	8d6a0a13          	addi	s4,s4,-1834 # 80009008 <etext+0x8>
      for(; *s; s++)
    8000073a:	02800513          	li	a0,40
    8000073e:	b7dd                	j	80000724 <printf+0x22a>
    } else if(c0 == '%'){
      consputc('%');
    80000740:	8556                	mv	a0,s5
    80000742:	b39ff0ef          	jal	8000027a <consputc>
    80000746:	b535                	j	80000572 <printf+0x78>
    80000748:	74a6                	ld	s1,104(sp)
    8000074a:	69e6                	ld	s3,88(sp)
    8000074c:	6a46                	ld	s4,80(sp)
    8000074e:	6aa6                	ld	s5,72(sp)
    80000750:	6b06                	ld	s6,64(sp)
    80000752:	7be2                	ld	s7,56(sp)
    80000754:	7c42                	ld	s8,48(sp)
    80000756:	7d02                	ld	s10,32(sp)
    80000758:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    8000075a:	0000d797          	auipc	a5,0xd
    8000075e:	c4a7a783          	lw	a5,-950(a5) # 8000d3a4 <panicking>
    80000762:	c38d                	beqz	a5,80000784 <printf+0x28a>
    release(&pr.lock);

  return 0;
}
    80000764:	4501                	li	a0,0
    80000766:	70e6                	ld	ra,120(sp)
    80000768:	7446                	ld	s0,112(sp)
    8000076a:	7906                	ld	s2,96(sp)
    8000076c:	6129                	addi	sp,sp,192
    8000076e:	8082                	ret
    80000770:	74a6                	ld	s1,104(sp)
    80000772:	69e6                	ld	s3,88(sp)
    80000774:	6a46                	ld	s4,80(sp)
    80000776:	6aa6                	ld	s5,72(sp)
    80000778:	6b06                	ld	s6,64(sp)
    8000077a:	7be2                	ld	s7,56(sp)
    8000077c:	7c42                	ld	s8,48(sp)
    8000077e:	7d02                	ld	s10,32(sp)
    80000780:	6de2                	ld	s11,24(sp)
    80000782:	bfe1                	j	8000075a <printf+0x260>
    release(&pr.lock);
    80000784:	00015517          	auipc	a0,0x15
    80000788:	cf450513          	addi	a0,a0,-780 # 80015478 <pr>
    8000078c:	534000ef          	jal	80000cc0 <release>
  return 0;
    80000790:	bfd1                	j	80000764 <printf+0x26a>
    if(c0 == 'd'){
    80000792:	e37a8ee3          	beq	s5,s7,800005ce <printf+0xd4>
    } else if(c0 == 'l' && c1 == 'd'){
    80000796:	f94a8713          	addi	a4,s5,-108
    8000079a:	00173713          	seqz	a4,a4
    8000079e:	8636                	mv	a2,a3
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800007a0:	4781                	li	a5,0
    800007a2:	a00d                	j	800007c4 <printf+0x2ca>
    } else if(c0 == 'l' && c1 == 'd'){
    800007a4:	f94a8713          	addi	a4,s5,-108
    800007a8:	00173713          	seqz	a4,a4
    c1 = c2 = 0;
    800007ac:	8656                	mv	a2,s5
    800007ae:	86d6                	mv	a3,s5
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800007b0:	f9460793          	addi	a5,a2,-108
    800007b4:	0017b793          	seqz	a5,a5
    800007b8:	8ff9                	and	a5,a5,a4
    800007ba:	f9c68593          	addi	a1,a3,-100
    800007be:	e199                	bnez	a1,800007c4 <printf+0x2ca>
    800007c0:	e20798e3          	bnez	a5,800005f0 <printf+0xf6>
    } else if(c0 == 'u'){
    800007c4:	e58a84e3          	beq	s5,s8,8000060c <printf+0x112>
    } else if(c0 == 'l' && c1 == 'u'){
    800007c8:	f8b60593          	addi	a1,a2,-117
    800007cc:	e199                	bnez	a1,800007d2 <printf+0x2d8>
    800007ce:	e4071ce3          	bnez	a4,80000626 <printf+0x12c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800007d2:	f8b68593          	addi	a1,a3,-117
    800007d6:	e199                	bnez	a1,800007dc <printf+0x2e2>
    800007d8:	e60795e3          	bnez	a5,80000642 <printf+0x148>
    } else if(c0 == 'x'){
    800007dc:	e9aa81e3          	beq	s5,s10,8000065e <printf+0x164>
    } else if(c0 == 'l' && c1 == 'x'){
    800007e0:	f8860613          	addi	a2,a2,-120
    800007e4:	e219                	bnez	a2,800007ea <printf+0x2f0>
    800007e6:	e80719e3          	bnez	a4,80000678 <printf+0x17e>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    800007ea:	f8868693          	addi	a3,a3,-120
    800007ee:	e299                	bnez	a3,800007f4 <printf+0x2fa>
    800007f0:	ea0791e3          	bnez	a5,80000692 <printf+0x198>
    } else if(c0 == 'p'){
    800007f4:	ebba8de3          	beq	s5,s11,800006ae <printf+0x1b4>
    } else if(c0 == 'c'){
    800007f8:	06300793          	li	a5,99
    800007fc:	eefa8ce3          	beq	s5,a5,800006f4 <printf+0x1fa>
    } else if(c0 == 's'){
    80000800:	07300793          	li	a5,115
    80000804:	f0fa82e3          	beq	s5,a5,80000708 <printf+0x20e>
    } else if(c0 == '%'){
    80000808:	02500793          	li	a5,37
    8000080c:	f2fa8ae3          	beq	s5,a5,80000740 <printf+0x246>
    } else if(c0 == 0){
    80000810:	f60a80e3          	beqz	s5,80000770 <printf+0x276>
      consputc('%');
    80000814:	02500513          	li	a0,37
    80000818:	a63ff0ef          	jal	8000027a <consputc>
      consputc(c0);
    8000081c:	8556                	mv	a0,s5
    8000081e:	a5dff0ef          	jal	8000027a <consputc>
    80000822:	bb81                	j	80000572 <printf+0x78>

0000000080000824 <panic>:

void
panic(char *s)
{
    80000824:	1101                	addi	sp,sp,-32
    80000826:	ec06                	sd	ra,24(sp)
    80000828:	e822                	sd	s0,16(sp)
    8000082a:	e426                	sd	s1,8(sp)
    8000082c:	e04a                	sd	s2,0(sp)
    8000082e:	1000                	addi	s0,sp,32
    80000830:	892a                	mv	s2,a0
  panicking = 1;
    80000832:	4485                	li	s1,1
    80000834:	0000d797          	auipc	a5,0xd
    80000838:	b697a823          	sw	s1,-1168(a5) # 8000d3a4 <panicking>
  printf("panic: ");
    8000083c:	00008517          	auipc	a0,0x8
    80000840:	7dc50513          	addi	a0,a0,2012 # 80009018 <etext+0x18>
    80000844:	cb7ff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000848:	85ca                	mv	a1,s2
    8000084a:	00008517          	auipc	a0,0x8
    8000084e:	7d650513          	addi	a0,a0,2006 # 80009020 <etext+0x20>
    80000852:	ca9ff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000856:	0000d797          	auipc	a5,0xd
    8000085a:	b497a523          	sw	s1,-1206(a5) # 8000d3a0 <panicked>
  for(;;)
    8000085e:	a001                	j	8000085e <panic+0x3a>

0000000080000860 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000860:	1141                	addi	sp,sp,-16
    80000862:	e406                	sd	ra,8(sp)
    80000864:	e022                	sd	s0,0(sp)
    80000866:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000868:	00008597          	auipc	a1,0x8
    8000086c:	7c058593          	addi	a1,a1,1984 # 80009028 <etext+0x28>
    80000870:	00015517          	auipc	a0,0x15
    80000874:	c0850513          	addi	a0,a0,-1016 # 80015478 <pr>
    80000878:	32a000ef          	jal	80000ba2 <initlock>
}
    8000087c:	60a2                	ld	ra,8(sp)
    8000087e:	6402                	ld	s0,0(sp)
    80000880:	0141                	addi	sp,sp,16
    80000882:	8082                	ret

0000000080000884 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000884:	1141                	addi	sp,sp,-16
    80000886:	e406                	sd	ra,8(sp)
    80000888:	e022                	sd	s0,0(sp)
    8000088a:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000088c:	100007b7          	lui	a5,0x10000
    80000890:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000894:	10000737          	lui	a4,0x10000
    80000898:	f8000693          	li	a3,-128
    8000089c:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800008a0:	468d                	li	a3,3
    800008a2:	10000637          	lui	a2,0x10000
    800008a6:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800008aa:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800008ae:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800008b2:	8732                	mv	a4,a2
    800008b4:	461d                	li	a2,7
    800008b6:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800008ba:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    800008be:	00008597          	auipc	a1,0x8
    800008c2:	77258593          	addi	a1,a1,1906 # 80009030 <etext+0x30>
    800008c6:	00015517          	auipc	a0,0x15
    800008ca:	bca50513          	addi	a0,a0,-1078 # 80015490 <tx_lock>
    800008ce:	2d4000ef          	jal	80000ba2 <initlock>
}
    800008d2:	60a2                	ld	ra,8(sp)
    800008d4:	6402                	ld	s0,0(sp)
    800008d6:	0141                	addi	sp,sp,16
    800008d8:	8082                	ret

00000000800008da <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008da:	715d                	addi	sp,sp,-80
    800008dc:	e486                	sd	ra,72(sp)
    800008de:	e0a2                	sd	s0,64(sp)
    800008e0:	fc26                	sd	s1,56(sp)
    800008e2:	ec56                	sd	s5,24(sp)
    800008e4:	0880                	addi	s0,sp,80
    800008e6:	8aaa                	mv	s5,a0
    800008e8:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008ea:	00015517          	auipc	a0,0x15
    800008ee:	ba650513          	addi	a0,a0,-1114 # 80015490 <tx_lock>
    800008f2:	33a000ef          	jal	80000c2c <acquire>

  int i = 0;
  while(i < n){ 
    800008f6:	06905063          	blez	s1,80000956 <uartwrite+0x7c>
    800008fa:	f84a                	sd	s2,48(sp)
    800008fc:	f44e                	sd	s3,40(sp)
    800008fe:	f052                	sd	s4,32(sp)
    80000900:	e85a                	sd	s6,16(sp)
    80000902:	e45e                	sd	s7,8(sp)
    80000904:	8a56                	mv	s4,s5
    80000906:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    80000908:	0000d497          	auipc	s1,0xd
    8000090c:	aa448493          	addi	s1,s1,-1372 # 8000d3ac <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000910:	00015997          	auipc	s3,0x15
    80000914:	b8098993          	addi	s3,s3,-1152 # 80015490 <tx_lock>
    80000918:	0000d917          	auipc	s2,0xd
    8000091c:	a9090913          	addi	s2,s2,-1392 # 8000d3a8 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    80000920:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    80000924:	4b05                	li	s6,1
    80000926:	a005                	j	80000946 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    80000928:	85ce                	mv	a1,s3
    8000092a:	854a                	mv	a0,s2
    8000092c:	50b020ef          	jal	80003636 <sleep>
    while(tx_busy != 0){
    80000930:	409c                	lw	a5,0(s1)
    80000932:	fbfd                	bnez	a5,80000928 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    80000934:	000a4783          	lbu	a5,0(s4)
    80000938:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    8000093c:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    80000940:	0a05                	addi	s4,s4,1
    80000942:	015a0563          	beq	s4,s5,8000094c <uartwrite+0x72>
    while(tx_busy != 0){
    80000946:	409c                	lw	a5,0(s1)
    80000948:	f3e5                	bnez	a5,80000928 <uartwrite+0x4e>
    8000094a:	b7ed                	j	80000934 <uartwrite+0x5a>
    8000094c:	7942                	ld	s2,48(sp)
    8000094e:	79a2                	ld	s3,40(sp)
    80000950:	7a02                	ld	s4,32(sp)
    80000952:	6b42                	ld	s6,16(sp)
    80000954:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000956:	00015517          	auipc	a0,0x15
    8000095a:	b3a50513          	addi	a0,a0,-1222 # 80015490 <tx_lock>
    8000095e:	362000ef          	jal	80000cc0 <release>
}
    80000962:	60a6                	ld	ra,72(sp)
    80000964:	6406                	ld	s0,64(sp)
    80000966:	74e2                	ld	s1,56(sp)
    80000968:	6ae2                	ld	s5,24(sp)
    8000096a:	6161                	addi	sp,sp,80
    8000096c:	8082                	ret

000000008000096e <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000096e:	1101                	addi	sp,sp,-32
    80000970:	ec06                	sd	ra,24(sp)
    80000972:	e822                	sd	s0,16(sp)
    80000974:	e426                	sd	s1,8(sp)
    80000976:	1000                	addi	s0,sp,32
    80000978:	84aa                	mv	s1,a0
  if(panicking == 0)
    8000097a:	0000d797          	auipc	a5,0xd
    8000097e:	a2a7a783          	lw	a5,-1494(a5) # 8000d3a4 <panicking>
    80000982:	cf95                	beqz	a5,800009be <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000984:	0000d797          	auipc	a5,0xd
    80000988:	a1c7a783          	lw	a5,-1508(a5) # 8000d3a0 <panicked>
    8000098c:	ef85                	bnez	a5,800009c4 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000098e:	10000737          	lui	a4,0x10000
    80000992:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000994:	00074783          	lbu	a5,0(a4)
    80000998:	0207f793          	andi	a5,a5,32
    8000099c:	dfe5                	beqz	a5,80000994 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000099e:	0ff4f513          	zext.b	a0,s1
    800009a2:	100007b7          	lui	a5,0x10000
    800009a6:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    800009aa:	0000d797          	auipc	a5,0xd
    800009ae:	9fa7a783          	lw	a5,-1542(a5) # 8000d3a4 <panicking>
    800009b2:	cb91                	beqz	a5,800009c6 <uartputc_sync+0x58>
    pop_off();
}
    800009b4:	60e2                	ld	ra,24(sp)
    800009b6:	6442                	ld	s0,16(sp)
    800009b8:	64a2                	ld	s1,8(sp)
    800009ba:	6105                	addi	sp,sp,32
    800009bc:	8082                	ret
    push_off();
    800009be:	22a000ef          	jal	80000be8 <push_off>
    800009c2:	b7c9                	j	80000984 <uartputc_sync+0x16>
    for(;;)
    800009c4:	a001                	j	800009c4 <uartputc_sync+0x56>
    pop_off();
    800009c6:	2aa000ef          	jal	80000c70 <pop_off>
}
    800009ca:	b7ed                	j	800009b4 <uartputc_sync+0x46>

00000000800009cc <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009cc:	1141                	addi	sp,sp,-16
    800009ce:	e406                	sd	ra,8(sp)
    800009d0:	e022                	sd	s0,0(sp)
    800009d2:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    800009d4:	100007b7          	lui	a5,0x10000
    800009d8:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009dc:	8b85                	andi	a5,a5,1
    800009de:	cb89                	beqz	a5,800009f0 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009e0:	100007b7          	lui	a5,0x10000
    800009e4:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009e8:	60a2                	ld	ra,8(sp)
    800009ea:	6402                	ld	s0,0(sp)
    800009ec:	0141                	addi	sp,sp,16
    800009ee:	8082                	ret
    return -1;
    800009f0:	557d                	li	a0,-1
    800009f2:	bfdd                	j	800009e8 <uartgetc+0x1c>

00000000800009f4 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009f4:	1101                	addi	sp,sp,-32
    800009f6:	ec06                	sd	ra,24(sp)
    800009f8:	e822                	sd	s0,16(sp)
    800009fa:	e426                	sd	s1,8(sp)
    800009fc:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009fe:	100007b7          	lui	a5,0x10000
    80000a02:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>

  acquire(&tx_lock);
    80000a06:	00015517          	auipc	a0,0x15
    80000a0a:	a8a50513          	addi	a0,a0,-1398 # 80015490 <tx_lock>
    80000a0e:	21e000ef          	jal	80000c2c <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    80000a12:	100007b7          	lui	a5,0x10000
    80000a16:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a1a:	0207f793          	andi	a5,a5,32
    80000a1e:	ef99                	bnez	a5,80000a3c <uartintr+0x48>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    80000a20:	00015517          	auipc	a0,0x15
    80000a24:	a7050513          	addi	a0,a0,-1424 # 80015490 <tx_lock>
    80000a28:	298000ef          	jal	80000cc0 <release>

  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a2c:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a2e:	f9fff0ef          	jal	800009cc <uartgetc>
    if(c == -1)
    80000a32:	02950063          	beq	a0,s1,80000a52 <uartintr+0x5e>
      break;
    consoleintr(c);
    80000a36:	877ff0ef          	jal	800002ac <consoleintr>
  while(1){
    80000a3a:	bfd5                	j	80000a2e <uartintr+0x3a>
    tx_busy = 0;
    80000a3c:	0000d797          	auipc	a5,0xd
    80000a40:	9607a823          	sw	zero,-1680(a5) # 8000d3ac <tx_busy>
    wakeup(&tx_chan);
    80000a44:	0000d517          	auipc	a0,0xd
    80000a48:	96450513          	addi	a0,a0,-1692 # 8000d3a8 <tx_chan>
    80000a4c:	437020ef          	jal	80003682 <wakeup>
    80000a50:	bfc1                	j	80000a20 <uartintr+0x2c>
  }
}
    80000a52:	60e2                	ld	ra,24(sp)
    80000a54:	6442                	ld	s0,16(sp)
    80000a56:	64a2                	ld	s1,8(sp)
    80000a58:	6105                	addi	sp,sp,32
    80000a5a:	8082                	ret

0000000080000a5c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a5c:	1101                	addi	sp,sp,-32
    80000a5e:	ec06                	sd	ra,24(sp)
    80000a60:	e822                	sd	s0,16(sp)
    80000a62:	e426                	sd	s1,8(sp)
    80000a64:	e04a                	sd	s2,0(sp)
    80000a66:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a68:	002d3797          	auipc	a5,0x2d3
    80000a6c:	07078793          	addi	a5,a5,112 # 802d3ad8 <end>
    80000a70:	00f53733          	sltu	a4,a0,a5
    80000a74:	10100793          	li	a5,257
    80000a78:	07de                	slli	a5,a5,0x17
    80000a7a:	17fd                	addi	a5,a5,-1
    80000a7c:	00a7b7b3          	sltu	a5,a5,a0
    80000a80:	8fd9                	or	a5,a5,a4
    80000a82:	ef95                	bnez	a5,80000abe <kfree+0x62>
    80000a84:	84aa                	mv	s1,a0
    80000a86:	03451793          	slli	a5,a0,0x34
    80000a8a:	eb95                	bnez	a5,80000abe <kfree+0x62>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a8c:	6605                	lui	a2,0x1
    80000a8e:	4585                	li	a1,1
    80000a90:	26c000ef          	jal	80000cfc <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a94:	00015917          	auipc	s2,0x15
    80000a98:	a1490913          	addi	s2,s2,-1516 # 800154a8 <kmem>
    80000a9c:	854a                	mv	a0,s2
    80000a9e:	18e000ef          	jal	80000c2c <acquire>
  r->next = kmem.freelist;
    80000aa2:	01893783          	ld	a5,24(s2)
    80000aa6:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000aa8:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000aac:	854a                	mv	a0,s2
    80000aae:	212000ef          	jal	80000cc0 <release>
}
    80000ab2:	60e2                	ld	ra,24(sp)
    80000ab4:	6442                	ld	s0,16(sp)
    80000ab6:	64a2                	ld	s1,8(sp)
    80000ab8:	6902                	ld	s2,0(sp)
    80000aba:	6105                	addi	sp,sp,32
    80000abc:	8082                	ret
    panic("kfree");
    80000abe:	00008517          	auipc	a0,0x8
    80000ac2:	57a50513          	addi	a0,a0,1402 # 80009038 <etext+0x38>
    80000ac6:	d5fff0ef          	jal	80000824 <panic>

0000000080000aca <freerange>:
{
    80000aca:	7179                	addi	sp,sp,-48
    80000acc:	f406                	sd	ra,40(sp)
    80000ace:	f022                	sd	s0,32(sp)
    80000ad0:	ec26                	sd	s1,24(sp)
    80000ad2:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ad4:	6785                	lui	a5,0x1
    80000ad6:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ada:	00e504b3          	add	s1,a0,a4
    80000ade:	777d                	lui	a4,0xfffff
    80000ae0:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae2:	94be                	add	s1,s1,a5
    80000ae4:	0295e263          	bltu	a1,s1,80000b08 <freerange+0x3e>
    80000ae8:	e84a                	sd	s2,16(sp)
    80000aea:	e44e                	sd	s3,8(sp)
    80000aec:	e052                	sd	s4,0(sp)
    80000aee:	892e                	mv	s2,a1
    kfree(p);
    80000af0:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af2:	89be                	mv	s3,a5
    kfree(p);
    80000af4:	01448533          	add	a0,s1,s4
    80000af8:	f65ff0ef          	jal	80000a5c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000afc:	94ce                	add	s1,s1,s3
    80000afe:	fe997be3          	bgeu	s2,s1,80000af4 <freerange+0x2a>
    80000b02:	6942                	ld	s2,16(sp)
    80000b04:	69a2                	ld	s3,8(sp)
    80000b06:	6a02                	ld	s4,0(sp)
}
    80000b08:	70a2                	ld	ra,40(sp)
    80000b0a:	7402                	ld	s0,32(sp)
    80000b0c:	64e2                	ld	s1,24(sp)
    80000b0e:	6145                	addi	sp,sp,48
    80000b10:	8082                	ret

0000000080000b12 <kinit>:
{
    80000b12:	1141                	addi	sp,sp,-16
    80000b14:	e406                	sd	ra,8(sp)
    80000b16:	e022                	sd	s0,0(sp)
    80000b18:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b1a:	00008597          	auipc	a1,0x8
    80000b1e:	52658593          	addi	a1,a1,1318 # 80009040 <etext+0x40>
    80000b22:	00015517          	auipc	a0,0x15
    80000b26:	98650513          	addi	a0,a0,-1658 # 800154a8 <kmem>
    80000b2a:	078000ef          	jal	80000ba2 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2e:	10100593          	li	a1,257
    80000b32:	05de                	slli	a1,a1,0x17
    80000b34:	002d3517          	auipc	a0,0x2d3
    80000b38:	fa450513          	addi	a0,a0,-92 # 802d3ad8 <end>
    80000b3c:	f8fff0ef          	jal	80000aca <freerange>
}
    80000b40:	60a2                	ld	ra,8(sp)
    80000b42:	6402                	ld	s0,0(sp)
    80000b44:	0141                	addi	sp,sp,16
    80000b46:	8082                	ret

0000000080000b48 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b48:	1101                	addi	sp,sp,-32
    80000b4a:	ec06                	sd	ra,24(sp)
    80000b4c:	e822                	sd	s0,16(sp)
    80000b4e:	e426                	sd	s1,8(sp)
    80000b50:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b52:	00015517          	auipc	a0,0x15
    80000b56:	95650513          	addi	a0,a0,-1706 # 800154a8 <kmem>
    80000b5a:	0d2000ef          	jal	80000c2c <acquire>
  r = kmem.freelist;
    80000b5e:	00015497          	auipc	s1,0x15
    80000b62:	9624b483          	ld	s1,-1694(s1) # 800154c0 <kmem+0x18>
  if(r)
    80000b66:	c49d                	beqz	s1,80000b94 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b68:	609c                	ld	a5,0(s1)
    80000b6a:	00015717          	auipc	a4,0x15
    80000b6e:	94f73b23          	sd	a5,-1706(a4) # 800154c0 <kmem+0x18>
  release(&kmem.lock);
    80000b72:	00015517          	auipc	a0,0x15
    80000b76:	93650513          	addi	a0,a0,-1738 # 800154a8 <kmem>
    80000b7a:	146000ef          	jal	80000cc0 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b7e:	6605                	lui	a2,0x1
    80000b80:	4595                	li	a1,5
    80000b82:	8526                	mv	a0,s1
    80000b84:	178000ef          	jal	80000cfc <memset>
  return (void*)r;
}
    80000b88:	8526                	mv	a0,s1
    80000b8a:	60e2                	ld	ra,24(sp)
    80000b8c:	6442                	ld	s0,16(sp)
    80000b8e:	64a2                	ld	s1,8(sp)
    80000b90:	6105                	addi	sp,sp,32
    80000b92:	8082                	ret
  release(&kmem.lock);
    80000b94:	00015517          	auipc	a0,0x15
    80000b98:	91450513          	addi	a0,a0,-1772 # 800154a8 <kmem>
    80000b9c:	124000ef          	jal	80000cc0 <release>
  if(r)
    80000ba0:	b7e5                	j	80000b88 <kalloc+0x40>

0000000080000ba2 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000ba2:	1141                	addi	sp,sp,-16
    80000ba4:	e406                	sd	ra,8(sp)
    80000ba6:	e022                	sd	s0,0(sp)
    80000ba8:	0800                	addi	s0,sp,16
  lk->name = name;
    80000baa:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bac:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bb0:	00053823          	sd	zero,16(a0)
}
    80000bb4:	60a2                	ld	ra,8(sp)
    80000bb6:	6402                	ld	s0,0(sp)
    80000bb8:	0141                	addi	sp,sp,16
    80000bba:	8082                	ret

0000000080000bbc <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bbc:	411c                	lw	a5,0(a0)
    80000bbe:	e399                	bnez	a5,80000bc4 <holding+0x8>
    80000bc0:	4501                	li	a0,0
  return r;
}
    80000bc2:	8082                	ret
{
    80000bc4:	1101                	addi	sp,sp,-32
    80000bc6:	ec06                	sd	ra,24(sp)
    80000bc8:	e822                	sd	s0,16(sp)
    80000bca:	e426                	sd	s1,8(sp)
    80000bcc:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bce:	691c                	ld	a5,16(a0)
    80000bd0:	84be                	mv	s1,a5
    80000bd2:	252020ef          	jal	80002e24 <mycpu>
    80000bd6:	40a48533          	sub	a0,s1,a0
    80000bda:	00153513          	seqz	a0,a0
}
    80000bde:	60e2                	ld	ra,24(sp)
    80000be0:	6442                	ld	s0,16(sp)
    80000be2:	64a2                	ld	s1,8(sp)
    80000be4:	6105                	addi	sp,sp,32
    80000be6:	8082                	ret

0000000080000be8 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000be8:	1101                	addi	sp,sp,-32
    80000bea:	ec06                	sd	ra,24(sp)
    80000bec:	e822                	sd	s0,16(sp)
    80000bee:	e426                	sd	s1,8(sp)
    80000bf0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bf2:	100027f3          	csrr	a5,sstatus
    80000bf6:	84be                	mv	s1,a5
    80000bf8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bfc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bfe:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000c02:	222020ef          	jal	80002e24 <mycpu>
    80000c06:	5d3c                	lw	a5,120(a0)
    80000c08:	cb99                	beqz	a5,80000c1e <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c0a:	21a020ef          	jal	80002e24 <mycpu>
    80000c0e:	5d3c                	lw	a5,120(a0)
    80000c10:	2785                	addiw	a5,a5,1
    80000c12:	dd3c                	sw	a5,120(a0)
}
    80000c14:	60e2                	ld	ra,24(sp)
    80000c16:	6442                	ld	s0,16(sp)
    80000c18:	64a2                	ld	s1,8(sp)
    80000c1a:	6105                	addi	sp,sp,32
    80000c1c:	8082                	ret
    mycpu()->intena = old;
    80000c1e:	206020ef          	jal	80002e24 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c22:	0014d793          	srli	a5,s1,0x1
    80000c26:	8b85                	andi	a5,a5,1
    80000c28:	dd7c                	sw	a5,124(a0)
    80000c2a:	b7c5                	j	80000c0a <push_off+0x22>

0000000080000c2c <acquire>:
{
    80000c2c:	1101                	addi	sp,sp,-32
    80000c2e:	ec06                	sd	ra,24(sp)
    80000c30:	e822                	sd	s0,16(sp)
    80000c32:	e426                	sd	s1,8(sp)
    80000c34:	1000                	addi	s0,sp,32
    80000c36:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c38:	fb1ff0ef          	jal	80000be8 <push_off>
  if(holding(lk))
    80000c3c:	8526                	mv	a0,s1
    80000c3e:	f7fff0ef          	jal	80000bbc <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c42:	4705                	li	a4,1
  if(holding(lk))
    80000c44:	e105                	bnez	a0,80000c64 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c46:	87ba                	mv	a5,a4
    80000c48:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c4c:	2781                	sext.w	a5,a5
    80000c4e:	ffe5                	bnez	a5,80000c46 <acquire+0x1a>
  __sync_synchronize();
    80000c50:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c54:	1d0020ef          	jal	80002e24 <mycpu>
    80000c58:	e888                	sd	a0,16(s1)
}
    80000c5a:	60e2                	ld	ra,24(sp)
    80000c5c:	6442                	ld	s0,16(sp)
    80000c5e:	64a2                	ld	s1,8(sp)
    80000c60:	6105                	addi	sp,sp,32
    80000c62:	8082                	ret
    panic("acquire");
    80000c64:	00008517          	auipc	a0,0x8
    80000c68:	3e450513          	addi	a0,a0,996 # 80009048 <etext+0x48>
    80000c6c:	bb9ff0ef          	jal	80000824 <panic>

0000000080000c70 <pop_off>:

void
pop_off(void)
{
    80000c70:	1141                	addi	sp,sp,-16
    80000c72:	e406                	sd	ra,8(sp)
    80000c74:	e022                	sd	s0,0(sp)
    80000c76:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c78:	1ac020ef          	jal	80002e24 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c7c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c80:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c82:	e39d                	bnez	a5,80000ca8 <pop_off+0x38>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c84:	5d3c                	lw	a5,120(a0)
    80000c86:	02f05763          	blez	a5,80000cb4 <pop_off+0x44>
    panic("pop_off");
  c->noff -= 1;
    80000c8a:	37fd                	addiw	a5,a5,-1
    80000c8c:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c8e:	eb89                	bnez	a5,80000ca0 <pop_off+0x30>
    80000c90:	5d7c                	lw	a5,124(a0)
    80000c92:	c799                	beqz	a5,80000ca0 <pop_off+0x30>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c94:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c98:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c9c:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000ca0:	60a2                	ld	ra,8(sp)
    80000ca2:	6402                	ld	s0,0(sp)
    80000ca4:	0141                	addi	sp,sp,16
    80000ca6:	8082                	ret
    panic("pop_off - interruptible");
    80000ca8:	00008517          	auipc	a0,0x8
    80000cac:	3a850513          	addi	a0,a0,936 # 80009050 <etext+0x50>
    80000cb0:	b75ff0ef          	jal	80000824 <panic>
    panic("pop_off");
    80000cb4:	00008517          	auipc	a0,0x8
    80000cb8:	3b450513          	addi	a0,a0,948 # 80009068 <etext+0x68>
    80000cbc:	b69ff0ef          	jal	80000824 <panic>

0000000080000cc0 <release>:
{
    80000cc0:	1101                	addi	sp,sp,-32
    80000cc2:	ec06                	sd	ra,24(sp)
    80000cc4:	e822                	sd	s0,16(sp)
    80000cc6:	e426                	sd	s1,8(sp)
    80000cc8:	1000                	addi	s0,sp,32
    80000cca:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000ccc:	ef1ff0ef          	jal	80000bbc <holding>
    80000cd0:	c105                	beqz	a0,80000cf0 <release+0x30>
  lk->cpu = 0;
    80000cd2:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cd6:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000cda:	0310000f          	fence	rw,w
    80000cde:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000ce2:	f8fff0ef          	jal	80000c70 <pop_off>
}
    80000ce6:	60e2                	ld	ra,24(sp)
    80000ce8:	6442                	ld	s0,16(sp)
    80000cea:	64a2                	ld	s1,8(sp)
    80000cec:	6105                	addi	sp,sp,32
    80000cee:	8082                	ret
    panic("release");
    80000cf0:	00008517          	auipc	a0,0x8
    80000cf4:	38050513          	addi	a0,a0,896 # 80009070 <etext+0x70>
    80000cf8:	b2dff0ef          	jal	80000824 <panic>

0000000080000cfc <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cfc:	1141                	addi	sp,sp,-16
    80000cfe:	e406                	sd	ra,8(sp)
    80000d00:	e022                	sd	s0,0(sp)
    80000d02:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d04:	ca19                	beqz	a2,80000d1a <memset+0x1e>
    80000d06:	87aa                	mv	a5,a0
    80000d08:	1602                	slli	a2,a2,0x20
    80000d0a:	9201                	srli	a2,a2,0x20
    80000d0c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d10:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d14:	0785                	addi	a5,a5,1
    80000d16:	fee79de3          	bne	a5,a4,80000d10 <memset+0x14>
  }
  return dst;
}
    80000d1a:	60a2                	ld	ra,8(sp)
    80000d1c:	6402                	ld	s0,0(sp)
    80000d1e:	0141                	addi	sp,sp,16
    80000d20:	8082                	ret

0000000080000d22 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d22:	1141                	addi	sp,sp,-16
    80000d24:	e406                	sd	ra,8(sp)
    80000d26:	e022                	sd	s0,0(sp)
    80000d28:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d2a:	c61d                	beqz	a2,80000d58 <memcmp+0x36>
    80000d2c:	1602                	slli	a2,a2,0x20
    80000d2e:	9201                	srli	a2,a2,0x20
    80000d30:	00c506b3          	add	a3,a0,a2
    if(*s1 != *s2)
    80000d34:	00054783          	lbu	a5,0(a0)
    80000d38:	0005c703          	lbu	a4,0(a1)
    80000d3c:	00e79863          	bne	a5,a4,80000d4c <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    80000d40:	0505                	addi	a0,a0,1
    80000d42:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d44:	fed518e3          	bne	a0,a3,80000d34 <memcmp+0x12>
  }

  return 0;
    80000d48:	4501                	li	a0,0
    80000d4a:	a019                	j	80000d50 <memcmp+0x2e>
      return *s1 - *s2;
    80000d4c:	40e7853b          	subw	a0,a5,a4
}
    80000d50:	60a2                	ld	ra,8(sp)
    80000d52:	6402                	ld	s0,0(sp)
    80000d54:	0141                	addi	sp,sp,16
    80000d56:	8082                	ret
  return 0;
    80000d58:	4501                	li	a0,0
    80000d5a:	bfdd                	j	80000d50 <memcmp+0x2e>

0000000080000d5c <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d5c:	1141                	addi	sp,sp,-16
    80000d5e:	e406                	sd	ra,8(sp)
    80000d60:	e022                	sd	s0,0(sp)
    80000d62:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d64:	c205                	beqz	a2,80000d84 <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d66:	02a5e363          	bltu	a1,a0,80000d8c <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d6a:	1602                	slli	a2,a2,0x20
    80000d6c:	9201                	srli	a2,a2,0x20
    80000d6e:	00c587b3          	add	a5,a1,a2
{
    80000d72:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d74:	0585                	addi	a1,a1,1
    80000d76:	0705                	addi	a4,a4,1
    80000d78:	fff5c683          	lbu	a3,-1(a1)
    80000d7c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d80:	feb79ae3          	bne	a5,a1,80000d74 <memmove+0x18>

  return dst;
}
    80000d84:	60a2                	ld	ra,8(sp)
    80000d86:	6402                	ld	s0,0(sp)
    80000d88:	0141                	addi	sp,sp,16
    80000d8a:	8082                	ret
  if(s < d && s + n > d){
    80000d8c:	02061693          	slli	a3,a2,0x20
    80000d90:	9281                	srli	a3,a3,0x20
    80000d92:	00d58733          	add	a4,a1,a3
    80000d96:	fce57ae3          	bgeu	a0,a4,80000d6a <memmove+0xe>
    d += n;
    80000d9a:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d9c:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000da0:	1782                	slli	a5,a5,0x20
    80000da2:	9381                	srli	a5,a5,0x20
    80000da4:	fff7c793          	not	a5,a5
    80000da8:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000daa:	177d                	addi	a4,a4,-1
    80000dac:	16fd                	addi	a3,a3,-1
    80000dae:	00074603          	lbu	a2,0(a4)
    80000db2:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000db6:	fee79ae3          	bne	a5,a4,80000daa <memmove+0x4e>
    80000dba:	b7e9                	j	80000d84 <memmove+0x28>

0000000080000dbc <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dbc:	1141                	addi	sp,sp,-16
    80000dbe:	e406                	sd	ra,8(sp)
    80000dc0:	e022                	sd	s0,0(sp)
    80000dc2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dc4:	f99ff0ef          	jal	80000d5c <memmove>
}
    80000dc8:	60a2                	ld	ra,8(sp)
    80000dca:	6402                	ld	s0,0(sp)
    80000dcc:	0141                	addi	sp,sp,16
    80000dce:	8082                	ret

0000000080000dd0 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dd0:	1141                	addi	sp,sp,-16
    80000dd2:	e406                	sd	ra,8(sp)
    80000dd4:	e022                	sd	s0,0(sp)
    80000dd6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dd8:	ce11                	beqz	a2,80000df4 <strncmp+0x24>
    80000dda:	00054783          	lbu	a5,0(a0)
    80000dde:	cf89                	beqz	a5,80000df8 <strncmp+0x28>
    80000de0:	0005c703          	lbu	a4,0(a1)
    80000de4:	00f71a63          	bne	a4,a5,80000df8 <strncmp+0x28>
    n--, p++, q++;
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	0505                	addi	a0,a0,1
    80000dec:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dee:	f675                	bnez	a2,80000dda <strncmp+0xa>
  if(n == 0)
    return 0;
    80000df0:	4501                	li	a0,0
    80000df2:	a801                	j	80000e02 <strncmp+0x32>
    80000df4:	4501                	li	a0,0
    80000df6:	a031                	j	80000e02 <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000df8:	00054503          	lbu	a0,0(a0)
    80000dfc:	0005c783          	lbu	a5,0(a1)
    80000e00:	9d1d                	subw	a0,a0,a5
}
    80000e02:	60a2                	ld	ra,8(sp)
    80000e04:	6402                	ld	s0,0(sp)
    80000e06:	0141                	addi	sp,sp,16
    80000e08:	8082                	ret

0000000080000e0a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e0a:	1141                	addi	sp,sp,-16
    80000e0c:	e406                	sd	ra,8(sp)
    80000e0e:	e022                	sd	s0,0(sp)
    80000e10:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e12:	87aa                	mv	a5,a0
    80000e14:	a011                	j	80000e18 <strncpy+0xe>
    80000e16:	8636                	mv	a2,a3
    80000e18:	02c05863          	blez	a2,80000e48 <strncpy+0x3e>
    80000e1c:	fff6069b          	addiw	a3,a2,-1
    80000e20:	8836                	mv	a6,a3
    80000e22:	0785                	addi	a5,a5,1
    80000e24:	0005c703          	lbu	a4,0(a1)
    80000e28:	fee78fa3          	sb	a4,-1(a5)
    80000e2c:	0585                	addi	a1,a1,1
    80000e2e:	f765                	bnez	a4,80000e16 <strncpy+0xc>
    ;
  while(n-- > 0)
    80000e30:	873e                	mv	a4,a5
    80000e32:	01005b63          	blez	a6,80000e48 <strncpy+0x3e>
    80000e36:	9fb1                	addw	a5,a5,a2
    80000e38:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e3a:	0705                	addi	a4,a4,1
    80000e3c:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e40:	40e786bb          	subw	a3,a5,a4
    80000e44:	fed04be3          	bgtz	a3,80000e3a <strncpy+0x30>
  return os;
}
    80000e48:	60a2                	ld	ra,8(sp)
    80000e4a:	6402                	ld	s0,0(sp)
    80000e4c:	0141                	addi	sp,sp,16
    80000e4e:	8082                	ret

0000000080000e50 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e50:	1141                	addi	sp,sp,-16
    80000e52:	e406                	sd	ra,8(sp)
    80000e54:	e022                	sd	s0,0(sp)
    80000e56:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e58:	02c05363          	blez	a2,80000e7e <safestrcpy+0x2e>
    80000e5c:	fff6069b          	addiw	a3,a2,-1
    80000e60:	1682                	slli	a3,a3,0x20
    80000e62:	9281                	srli	a3,a3,0x20
    80000e64:	96ae                	add	a3,a3,a1
    80000e66:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e68:	00d58963          	beq	a1,a3,80000e7a <safestrcpy+0x2a>
    80000e6c:	0585                	addi	a1,a1,1
    80000e6e:	0785                	addi	a5,a5,1
    80000e70:	fff5c703          	lbu	a4,-1(a1)
    80000e74:	fee78fa3          	sb	a4,-1(a5)
    80000e78:	fb65                	bnez	a4,80000e68 <safestrcpy+0x18>
    ;
  *s = 0;
    80000e7a:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e7e:	60a2                	ld	ra,8(sp)
    80000e80:	6402                	ld	s0,0(sp)
    80000e82:	0141                	addi	sp,sp,16
    80000e84:	8082                	ret

0000000080000e86 <strlen>:

int
strlen(const char *s)
{
    80000e86:	1141                	addi	sp,sp,-16
    80000e88:	e406                	sd	ra,8(sp)
    80000e8a:	e022                	sd	s0,0(sp)
    80000e8c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e8e:	00054783          	lbu	a5,0(a0)
    80000e92:	cf91                	beqz	a5,80000eae <strlen+0x28>
    80000e94:	00150793          	addi	a5,a0,1
    80000e98:	86be                	mv	a3,a5
    80000e9a:	0785                	addi	a5,a5,1
    80000e9c:	fff7c703          	lbu	a4,-1(a5)
    80000ea0:	ff65                	bnez	a4,80000e98 <strlen+0x12>
    80000ea2:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000ea6:	60a2                	ld	ra,8(sp)
    80000ea8:	6402                	ld	s0,0(sp)
    80000eaa:	0141                	addi	sp,sp,16
    80000eac:	8082                	ret
  for(n = 0; s[n]; n++)
    80000eae:	4501                	li	a0,0
    80000eb0:	bfdd                	j	80000ea6 <strlen+0x20>

0000000080000eb2 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000eb2:	1141                	addi	sp,sp,-16
    80000eb4:	e406                	sd	ra,8(sp)
    80000eb6:	e022                	sd	s0,0(sp)
    80000eb8:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000eba:	757010ef          	jal	80002e10 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ebe:	0000c717          	auipc	a4,0xc
    80000ec2:	4f270713          	addi	a4,a4,1266 # 8000d3b0 <started>
  if(cpuid() == 0){
    80000ec6:	c51d                	beqz	a0,80000ef4 <main+0x42>
    while(started == 0)
    80000ec8:	431c                	lw	a5,0(a4)
    80000eca:	2781                	sext.w	a5,a5
    80000ecc:	dff5                	beqz	a5,80000ec8 <main+0x16>
      ;
    __sync_synchronize();
    80000ece:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000ed2:	73f010ef          	jal	80002e10 <cpuid>
    80000ed6:	85aa                	mv	a1,a0
    80000ed8:	00008517          	auipc	a0,0x8
    80000edc:	1c050513          	addi	a0,a0,448 # 80009098 <etext+0x98>
    80000ee0:	e1aff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000ee4:	080000ef          	jal	80000f64 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ee8:	495020ef          	jal	80003b7c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eec:	1ec060ef          	jal	800070d8 <plicinithart>
  }

  scheduler();        
    80000ef0:	5a8020ef          	jal	80003498 <scheduler>
    consoleinit();
    80000ef4:	d2cff0ef          	jal	80000420 <consoleinit>
    printfinit();
    80000ef8:	969ff0ef          	jal	80000860 <printfinit>
    printf("\n");
    80000efc:	00008517          	auipc	a0,0x8
    80000f00:	17c50513          	addi	a0,a0,380 # 80009078 <etext+0x78>
    80000f04:	df6ff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000f08:	00008517          	auipc	a0,0x8
    80000f0c:	17850513          	addi	a0,a0,376 # 80009080 <etext+0x80>
    80000f10:	deaff0ef          	jal	800004fa <printf>
    printf("\n");
    80000f14:	00008517          	auipc	a0,0x8
    80000f18:	16450513          	addi	a0,a0,356 # 80009078 <etext+0x78>
    80000f1c:	ddeff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000f20:	bf3ff0ef          	jal	80000b12 <kinit>
    kvminit();       // create kernel page table
    80000f24:	2ce000ef          	jal	800011f2 <kvminit>
    kvminithart();   // turn on paging
    80000f28:	03c000ef          	jal	80000f64 <kvminithart>
    procinit();      // process table
    80000f2c:	629010ef          	jal	80002d54 <procinit>
    trapinit();      // trap vectors
    80000f30:	429020ef          	jal	80003b58 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f34:	449020ef          	jal	80003b7c <trapinithart>
    plicinit();      // set up interrupt controller
    80000f38:	186060ef          	jal	800070be <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f3c:	19c060ef          	jal	800070d8 <plicinithart>
    binit();         // buffer cache
    80000f40:	5e6030ef          	jal	80004526 <binit>
    iinit();         // inode table
    80000f44:	339030ef          	jal	80004a7c <iinit>
    fileinit();      // file table
    80000f48:	265040ef          	jal	800059ac <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f4c:	27c060ef          	jal	800071c8 <virtio_disk_init>
    userinit();      // first user process
    80000f50:	2f4020ef          	jal	80003244 <userinit>
    __sync_synchronize();
    80000f54:	0330000f          	fence	rw,rw
    started = 1;
    80000f58:	4785                	li	a5,1
    80000f5a:	0000c717          	auipc	a4,0xc
    80000f5e:	44f72b23          	sw	a5,1110(a4) # 8000d3b0 <started>
    80000f62:	b779                	j	80000ef0 <main+0x3e>

0000000080000f64 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000f64:	1141                	addi	sp,sp,-16
    80000f66:	e406                	sd	ra,8(sp)
    80000f68:	e022                	sd	s0,0(sp)
    80000f6a:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f6c:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f70:	0000c797          	auipc	a5,0xc
    80000f74:	4487b783          	ld	a5,1096(a5) # 8000d3b8 <kernel_pagetable>
    80000f78:	83b1                	srli	a5,a5,0xc
    80000f7a:	577d                	li	a4,-1
    80000f7c:	177e                	slli	a4,a4,0x3f
    80000f7e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f80:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f84:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f88:	60a2                	ld	ra,8(sp)
    80000f8a:	6402                	ld	s0,0(sp)
    80000f8c:	0141                	addi	sp,sp,16
    80000f8e:	8082                	ret

0000000080000f90 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f90:	7139                	addi	sp,sp,-64
    80000f92:	fc06                	sd	ra,56(sp)
    80000f94:	f822                	sd	s0,48(sp)
    80000f96:	f426                	sd	s1,40(sp)
    80000f98:	f04a                	sd	s2,32(sp)
    80000f9a:	ec4e                	sd	s3,24(sp)
    80000f9c:	e852                	sd	s4,16(sp)
    80000f9e:	e456                	sd	s5,8(sp)
    80000fa0:	e05a                	sd	s6,0(sp)
    80000fa2:	0080                	addi	s0,sp,64
    80000fa4:	84aa                	mv	s1,a0
    80000fa6:	89ae                	mv	s3,a1
    80000fa8:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    80000faa:	57fd                	li	a5,-1
    80000fac:	83e9                	srli	a5,a5,0x1a
    80000fae:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fb0:	4ab1                	li	s5,12
  if(va >= MAXVA)
    80000fb2:	04b7e263          	bltu	a5,a1,80000ff6 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000fb6:	0149d933          	srl	s2,s3,s4
    80000fba:	1ff97913          	andi	s2,s2,511
    80000fbe:	090e                	slli	s2,s2,0x3
    80000fc0:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fc2:	00093483          	ld	s1,0(s2)
    80000fc6:	0014f793          	andi	a5,s1,1
    80000fca:	cf85                	beqz	a5,80001002 <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fcc:	80a9                	srli	s1,s1,0xa
    80000fce:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    80000fd0:	3a5d                	addiw	s4,s4,-9
    80000fd2:	ff5a12e3          	bne	s4,s5,80000fb6 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80000fd6:	00c9d513          	srli	a0,s3,0xc
    80000fda:	1ff57513          	andi	a0,a0,511
    80000fde:	050e                	slli	a0,a0,0x3
    80000fe0:	9526                	add	a0,a0,s1
}
    80000fe2:	70e2                	ld	ra,56(sp)
    80000fe4:	7442                	ld	s0,48(sp)
    80000fe6:	74a2                	ld	s1,40(sp)
    80000fe8:	7902                	ld	s2,32(sp)
    80000fea:	69e2                	ld	s3,24(sp)
    80000fec:	6a42                	ld	s4,16(sp)
    80000fee:	6aa2                	ld	s5,8(sp)
    80000ff0:	6b02                	ld	s6,0(sp)
    80000ff2:	6121                	addi	sp,sp,64
    80000ff4:	8082                	ret
    panic("walk");
    80000ff6:	00008517          	auipc	a0,0x8
    80000ffa:	0ba50513          	addi	a0,a0,186 # 800090b0 <etext+0xb0>
    80000ffe:	827ff0ef          	jal	80000824 <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001002:	020b0263          	beqz	s6,80001026 <walk+0x96>
    80001006:	b43ff0ef          	jal	80000b48 <kalloc>
    8000100a:	84aa                	mv	s1,a0
    8000100c:	d979                	beqz	a0,80000fe2 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    8000100e:	6605                	lui	a2,0x1
    80001010:	4581                	li	a1,0
    80001012:	cebff0ef          	jal	80000cfc <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001016:	00c4d793          	srli	a5,s1,0xc
    8000101a:	07aa                	slli	a5,a5,0xa
    8000101c:	0017e793          	ori	a5,a5,1
    80001020:	00f93023          	sd	a5,0(s2)
    80001024:	b775                	j	80000fd0 <walk+0x40>
        return 0;
    80001026:	4501                	li	a0,0
    80001028:	bf6d                	j	80000fe2 <walk+0x52>

000000008000102a <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000102a:	57fd                	li	a5,-1
    8000102c:	83e9                	srli	a5,a5,0x1a
    8000102e:	00b7f463          	bgeu	a5,a1,80001036 <walkaddr+0xc>
    return 0;
    80001032:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001034:	8082                	ret
{
    80001036:	1141                	addi	sp,sp,-16
    80001038:	e406                	sd	ra,8(sp)
    8000103a:	e022                	sd	s0,0(sp)
    8000103c:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000103e:	4601                	li	a2,0
    80001040:	f51ff0ef          	jal	80000f90 <walk>
  if(pte == 0)
    80001044:	c901                	beqz	a0,80001054 <walkaddr+0x2a>
  if((*pte & PTE_V) == 0)
    80001046:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001048:	0117f693          	andi	a3,a5,17
    8000104c:	4745                	li	a4,17
    return 0;
    8000104e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001050:	00e68663          	beq	a3,a4,8000105c <walkaddr+0x32>
}
    80001054:	60a2                	ld	ra,8(sp)
    80001056:	6402                	ld	s0,0(sp)
    80001058:	0141                	addi	sp,sp,16
    8000105a:	8082                	ret
  pa = PTE2PA(*pte);
    8000105c:	83a9                	srli	a5,a5,0xa
    8000105e:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001062:	bfcd                	j	80001054 <walkaddr+0x2a>

0000000080001064 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001064:	715d                	addi	sp,sp,-80
    80001066:	e486                	sd	ra,72(sp)
    80001068:	e0a2                	sd	s0,64(sp)
    8000106a:	fc26                	sd	s1,56(sp)
    8000106c:	f84a                	sd	s2,48(sp)
    8000106e:	f44e                	sd	s3,40(sp)
    80001070:	f052                	sd	s4,32(sp)
    80001072:	ec56                	sd	s5,24(sp)
    80001074:	e85a                	sd	s6,16(sp)
    80001076:	e45e                	sd	s7,8(sp)
    80001078:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000107a:	03459793          	slli	a5,a1,0x34
    8000107e:	eba1                	bnez	a5,800010ce <mappages+0x6a>
    80001080:	8a2a                	mv	s4,a0
    80001082:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001084:	03461793          	slli	a5,a2,0x34
    80001088:	eba9                	bnez	a5,800010da <mappages+0x76>
    panic("mappages: size not aligned");

  if(size == 0)
    8000108a:	ce31                	beqz	a2,800010e6 <mappages+0x82>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000108c:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    80001090:	80060613          	addi	a2,a2,-2048
    80001094:	00b60933          	add	s2,a2,a1
  a = va;
    80001098:	84ae                	mv	s1,a1
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    8000109a:	4b05                	li	s6,1
    8000109c:	40b689b3          	sub	s3,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010a0:	6b85                	lui	s7,0x1
    if((pte = walk(pagetable, a, 1)) == 0)
    800010a2:	865a                	mv	a2,s6
    800010a4:	85a6                	mv	a1,s1
    800010a6:	8552                	mv	a0,s4
    800010a8:	ee9ff0ef          	jal	80000f90 <walk>
    800010ac:	c929                	beqz	a0,800010fe <mappages+0x9a>
    if(*pte & PTE_V)
    800010ae:	611c                	ld	a5,0(a0)
    800010b0:	8b85                	andi	a5,a5,1
    800010b2:	e3a1                	bnez	a5,800010f2 <mappages+0x8e>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010b4:	013487b3          	add	a5,s1,s3
    800010b8:	83b1                	srli	a5,a5,0xc
    800010ba:	07aa                	slli	a5,a5,0xa
    800010bc:	0157e7b3          	or	a5,a5,s5
    800010c0:	0017e793          	ori	a5,a5,1
    800010c4:	e11c                	sd	a5,0(a0)
    if(a == last)
    800010c6:	05248863          	beq	s1,s2,80001116 <mappages+0xb2>
    a += PGSIZE;
    800010ca:	94de                	add	s1,s1,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010cc:	bfd9                	j	800010a2 <mappages+0x3e>
    panic("mappages: va not aligned");
    800010ce:	00008517          	auipc	a0,0x8
    800010d2:	fea50513          	addi	a0,a0,-22 # 800090b8 <etext+0xb8>
    800010d6:	f4eff0ef          	jal	80000824 <panic>
    panic("mappages: size not aligned");
    800010da:	00008517          	auipc	a0,0x8
    800010de:	ffe50513          	addi	a0,a0,-2 # 800090d8 <etext+0xd8>
    800010e2:	f42ff0ef          	jal	80000824 <panic>
    panic("mappages: size");
    800010e6:	00008517          	auipc	a0,0x8
    800010ea:	01250513          	addi	a0,a0,18 # 800090f8 <etext+0xf8>
    800010ee:	f36ff0ef          	jal	80000824 <panic>
      panic("mappages: remap");
    800010f2:	00008517          	auipc	a0,0x8
    800010f6:	01650513          	addi	a0,a0,22 # 80009108 <etext+0x108>
    800010fa:	f2aff0ef          	jal	80000824 <panic>
      return -1;
    800010fe:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001100:	60a6                	ld	ra,72(sp)
    80001102:	6406                	ld	s0,64(sp)
    80001104:	74e2                	ld	s1,56(sp)
    80001106:	7942                	ld	s2,48(sp)
    80001108:	79a2                	ld	s3,40(sp)
    8000110a:	7a02                	ld	s4,32(sp)
    8000110c:	6ae2                	ld	s5,24(sp)
    8000110e:	6b42                	ld	s6,16(sp)
    80001110:	6ba2                	ld	s7,8(sp)
    80001112:	6161                	addi	sp,sp,80
    80001114:	8082                	ret
  return 0;
    80001116:	4501                	li	a0,0
    80001118:	b7e5                	j	80001100 <mappages+0x9c>

000000008000111a <kvmmap>:
{
    8000111a:	1141                	addi	sp,sp,-16
    8000111c:	e406                	sd	ra,8(sp)
    8000111e:	e022                	sd	s0,0(sp)
    80001120:	0800                	addi	s0,sp,16
    80001122:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001124:	86b2                	mv	a3,a2
    80001126:	863e                	mv	a2,a5
    80001128:	f3dff0ef          	jal	80001064 <mappages>
    8000112c:	e509                	bnez	a0,80001136 <kvmmap+0x1c>
}
    8000112e:	60a2                	ld	ra,8(sp)
    80001130:	6402                	ld	s0,0(sp)
    80001132:	0141                	addi	sp,sp,16
    80001134:	8082                	ret
    panic("kvmmap");
    80001136:	00008517          	auipc	a0,0x8
    8000113a:	fe250513          	addi	a0,a0,-30 # 80009118 <etext+0x118>
    8000113e:	ee6ff0ef          	jal	80000824 <panic>

0000000080001142 <kvmmake>:
{
    80001142:	1101                	addi	sp,sp,-32
    80001144:	ec06                	sd	ra,24(sp)
    80001146:	e822                	sd	s0,16(sp)
    80001148:	e426                	sd	s1,8(sp)
    8000114a:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000114c:	9fdff0ef          	jal	80000b48 <kalloc>
    80001150:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001152:	6605                	lui	a2,0x1
    80001154:	4581                	li	a1,0
    80001156:	ba7ff0ef          	jal	80000cfc <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000115a:	4719                	li	a4,6
    8000115c:	6685                	lui	a3,0x1
    8000115e:	10000637          	lui	a2,0x10000
    80001162:	85b2                	mv	a1,a2
    80001164:	8526                	mv	a0,s1
    80001166:	fb5ff0ef          	jal	8000111a <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000116a:	4719                	li	a4,6
    8000116c:	6685                	lui	a3,0x1
    8000116e:	10001637          	lui	a2,0x10001
    80001172:	85b2                	mv	a1,a2
    80001174:	8526                	mv	a0,s1
    80001176:	fa5ff0ef          	jal	8000111a <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000117a:	4719                	li	a4,6
    8000117c:	040006b7          	lui	a3,0x4000
    80001180:	0c000637          	lui	a2,0xc000
    80001184:	85b2                	mv	a1,a2
    80001186:	8526                	mv	a0,s1
    80001188:	f93ff0ef          	jal	8000111a <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000118c:	4729                	li	a4,10
    8000118e:	80008697          	auipc	a3,0x80008
    80001192:	e7268693          	addi	a3,a3,-398 # 9000 <_entry-0x7fff7000>
    80001196:	4605                	li	a2,1
    80001198:	067e                	slli	a2,a2,0x1f
    8000119a:	85b2                	mv	a1,a2
    8000119c:	8526                	mv	a0,s1
    8000119e:	f7dff0ef          	jal	8000111a <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011a2:	4719                	li	a4,6
    800011a4:	00008697          	auipc	a3,0x8
    800011a8:	e5c68693          	addi	a3,a3,-420 # 80009000 <etext>
    800011ac:	10100793          	li	a5,257
    800011b0:	07de                	slli	a5,a5,0x17
    800011b2:	40d786b3          	sub	a3,a5,a3
    800011b6:	00008617          	auipc	a2,0x8
    800011ba:	e4a60613          	addi	a2,a2,-438 # 80009000 <etext>
    800011be:	85b2                	mv	a1,a2
    800011c0:	8526                	mv	a0,s1
    800011c2:	f59ff0ef          	jal	8000111a <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011c6:	4729                	li	a4,10
    800011c8:	6685                	lui	a3,0x1
    800011ca:	00007617          	auipc	a2,0x7
    800011ce:	e3660613          	addi	a2,a2,-458 # 80008000 <_trampoline>
    800011d2:	040005b7          	lui	a1,0x4000
    800011d6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011d8:	05b2                	slli	a1,a1,0xc
    800011da:	8526                	mv	a0,s1
    800011dc:	f3fff0ef          	jal	8000111a <kvmmap>
  proc_mapstacks(kpgtbl);
    800011e0:	8526                	mv	a0,s1
    800011e2:	2c9010ef          	jal	80002caa <proc_mapstacks>
}
    800011e6:	8526                	mv	a0,s1
    800011e8:	60e2                	ld	ra,24(sp)
    800011ea:	6442                	ld	s0,16(sp)
    800011ec:	64a2                	ld	s1,8(sp)
    800011ee:	6105                	addi	sp,sp,32
    800011f0:	8082                	ret

00000000800011f2 <kvminit>:
{
    800011f2:	1141                	addi	sp,sp,-16
    800011f4:	e406                	sd	ra,8(sp)
    800011f6:	e022                	sd	s0,0(sp)
    800011f8:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011fa:	f49ff0ef          	jal	80001142 <kvmmake>
    800011fe:	0000c797          	auipc	a5,0xc
    80001202:	1aa7bd23          	sd	a0,442(a5) # 8000d3b8 <kernel_pagetable>
}
    80001206:	60a2                	ld	ra,8(sp)
    80001208:	6402                	ld	s0,0(sp)
    8000120a:	0141                	addi	sp,sp,16
    8000120c:	8082                	ret

000000008000120e <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000120e:	1101                	addi	sp,sp,-32
    80001210:	ec06                	sd	ra,24(sp)
    80001212:	e822                	sd	s0,16(sp)
    80001214:	e426                	sd	s1,8(sp)
    80001216:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001218:	931ff0ef          	jal	80000b48 <kalloc>
    8000121c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000121e:	c509                	beqz	a0,80001228 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001220:	6605                	lui	a2,0x1
    80001222:	4581                	li	a1,0
    80001224:	ad9ff0ef          	jal	80000cfc <memset>
  return pagetable;
}
    80001228:	8526                	mv	a0,s1
    8000122a:	60e2                	ld	ra,24(sp)
    8000122c:	6442                	ld	s0,16(sp)
    8000122e:	64a2                	ld	s1,8(sp)
    80001230:	6105                	addi	sp,sp,32
    80001232:	8082                	ret

0000000080001234 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001234:	7139                	addi	sp,sp,-64
    80001236:	fc06                	sd	ra,56(sp)
    80001238:	f822                	sd	s0,48(sp)
    8000123a:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000123c:	03459793          	slli	a5,a1,0x34
    80001240:	e38d                	bnez	a5,80001262 <uvmunmap+0x2e>
    80001242:	f04a                	sd	s2,32(sp)
    80001244:	ec4e                	sd	s3,24(sp)
    80001246:	e852                	sd	s4,16(sp)
    80001248:	e456                	sd	s5,8(sp)
    8000124a:	e05a                	sd	s6,0(sp)
    8000124c:	8a2a                	mv	s4,a0
    8000124e:	892e                	mv	s2,a1
    80001250:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001252:	0632                	slli	a2,a2,0xc
    80001254:	00b609b3          	add	s3,a2,a1
    80001258:	6b05                	lui	s6,0x1
    8000125a:	0535f963          	bgeu	a1,s3,800012ac <uvmunmap+0x78>
    8000125e:	f426                	sd	s1,40(sp)
    80001260:	a015                	j	80001284 <uvmunmap+0x50>
    80001262:	f426                	sd	s1,40(sp)
    80001264:	f04a                	sd	s2,32(sp)
    80001266:	ec4e                	sd	s3,24(sp)
    80001268:	e852                	sd	s4,16(sp)
    8000126a:	e456                	sd	s5,8(sp)
    8000126c:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    8000126e:	00008517          	auipc	a0,0x8
    80001272:	eb250513          	addi	a0,a0,-334 # 80009120 <etext+0x120>
    80001276:	daeff0ef          	jal	80000824 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000127a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000127e:	995a                	add	s2,s2,s6
    80001280:	03397563          	bgeu	s2,s3,800012aa <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    80001284:	4601                	li	a2,0
    80001286:	85ca                	mv	a1,s2
    80001288:	8552                	mv	a0,s4
    8000128a:	d07ff0ef          	jal	80000f90 <walk>
    8000128e:	84aa                	mv	s1,a0
    80001290:	d57d                	beqz	a0,8000127e <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    80001292:	611c                	ld	a5,0(a0)
    80001294:	0017f713          	andi	a4,a5,1
    80001298:	d37d                	beqz	a4,8000127e <uvmunmap+0x4a>
    if(do_free){
    8000129a:	fe0a80e3          	beqz	s5,8000127a <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    8000129e:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    800012a0:	00c79513          	slli	a0,a5,0xc
    800012a4:	fb8ff0ef          	jal	80000a5c <kfree>
    800012a8:	bfc9                	j	8000127a <uvmunmap+0x46>
    800012aa:	74a2                	ld	s1,40(sp)
    800012ac:	7902                	ld	s2,32(sp)
    800012ae:	69e2                	ld	s3,24(sp)
    800012b0:	6a42                	ld	s4,16(sp)
    800012b2:	6aa2                	ld	s5,8(sp)
    800012b4:	6b02                	ld	s6,0(sp)
  }
}
    800012b6:	70e2                	ld	ra,56(sp)
    800012b8:	7442                	ld	s0,48(sp)
    800012ba:	6121                	addi	sp,sp,64
    800012bc:	8082                	ret

00000000800012be <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012be:	7139                	addi	sp,sp,-64
    800012c0:	fc06                	sd	ra,56(sp)
    800012c2:	f822                	sd	s0,48(sp)
    800012c4:	f04a                	sd	s2,32(sp)
    800012c6:	e852                	sd	s4,16(sp)
    800012c8:	e456                	sd	s5,8(sp)
    800012ca:	0080                	addi	s0,sp,64
    800012cc:	8aaa                	mv	s5,a0
    800012ce:	892e                	mv	s2,a1
    800012d0:	8a32                	mv	s4,a2
  struct proc *p = myproc();
    800012d2:	373010ef          	jal	80002e44 <myproc>
  
  if(newsz >= oldsz)
    800012d6:	0d2a7963          	bgeu	s4,s2,800013a8 <uvmdealloc+0xea>
    800012da:	f426                	sd	s1,40(sp)
    800012dc:	ec4e                	sd	s3,24(sp)
    800012de:	89aa                	mv	s3,a0
    return oldsz;

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800012e0:	6785                	lui	a5,0x1
    800012e2:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012e4:	00fa04b3          	add	s1,s4,a5
    800012e8:	777d                	lui	a4,0xfffff
    800012ea:	8cf9                	and	s1,s1,a4
    800012ec:	993e                	add	s2,s2,a5
    800012ee:	00e97933          	and	s2,s2,a4
    800012f2:	0124ec63          	bltu	s1,s2,8000130a <uvmdealloc+0x4c>
    800012f6:	74a2                	ld	s1,40(sp)
    800012f8:	69e2                	ld	s3,24(sp)
      }
    }
  }

  return newsz;
}
    800012fa:	8552                	mv	a0,s4
    800012fc:	70e2                	ld	ra,56(sp)
    800012fe:	7442                	ld	s0,48(sp)
    80001300:	7902                	ld	s2,32(sp)
    80001302:	6a42                	ld	s4,16(sp)
    80001304:	6aa2                	ld	s5,8(sp)
    80001306:	6121                	addi	sp,sp,64
    80001308:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000130a:	40990633          	sub	a2,s2,s1
    8000130e:	8231                	srli	a2,a2,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001310:	4685                	li	a3,1
    80001312:	2601                	sext.w	a2,a2
    80001314:	85a6                	mv	a1,s1
    80001316:	8556                	mv	a0,s5
    80001318:	f1dff0ef          	jal	80001234 <uvmunmap>
    if(p) {
    8000131c:	08098863          	beqz	s3,800013ac <uvmdealloc+0xee>
        for(int i = 0; i < MAX_RESIDENT_PAGES; i++) {
    80001320:	04000593          	li	a1,64
            p->num_resident_pages--;
    80001324:	6505                	lui	a0,0x1
    80001326:	00a988b3          	add	a7,s3,a0
    8000132a:	c4850313          	addi	t1,a0,-952 # c48 <_entry-0x7ffff3b8>
        for(int i = 0; i < MAX_SWAP_PAGES; i++) {
    8000132e:	40000613          	li	a2,1024
            p->num_swapped_pages--;
    80001332:	682d                	lui	a6,0xb
    80001334:	984e                	add	a6,a6,s3
    80001336:	a0ad                	j	800013a0 <uvmdealloc+0xe2>
        for(int i = 0; i < MAX_RESIDENT_PAGES; i++) {
    80001338:	2705                	addiw	a4,a4,1 # fffffffffffff001 <end+0xffffffff7fd2b529>
    8000133a:	02878793          	addi	a5,a5,40
    8000133e:	02b70363          	beq	a4,a1,80001364 <uvmdealloc+0xa6>
          if(p->resident_pages[i].in_use && p->resident_pages[i].va == va) {
    80001342:	4bd4                	lw	a3,20(a5)
    80001344:	daf5                	beqz	a3,80001338 <uvmdealloc+0x7a>
    80001346:	6394                	ld	a3,0(a5)
    80001348:	fe9698e3          	bne	a3,s1,80001338 <uvmdealloc+0x7a>
            p->resident_pages[i].in_use = 0;
    8000134c:	00271793          	slli	a5,a4,0x2
    80001350:	97ba                	add	a5,a5,a4
    80001352:	078e                	slli	a5,a5,0x3
    80001354:	97ce                	add	a5,a5,s3
    80001356:	1a07aa23          	sw	zero,436(a5)
            p->num_resident_pages--;
    8000135a:	ba08a783          	lw	a5,-1120(a7)
    8000135e:	37fd                	addiw	a5,a5,-1
    80001360:	baf8a023          	sw	a5,-1120(a7)
        for(int i = 0; i < MAX_SWAP_PAGES; i++) {
    80001364:	006987b3          	add	a5,s3,t1
    80001368:	4701                	li	a4,0
    8000136a:	a031                	j	80001376 <uvmdealloc+0xb8>
    8000136c:	2705                	addiw	a4,a4,1
    8000136e:	02878793          	addi	a5,a5,40
    80001372:	02c70463          	beq	a4,a2,8000139a <uvmdealloc+0xdc>
          if(p->swapped_pages[i].in_use && p->swapped_pages[i].va == va) {
    80001376:	4bd4                	lw	a3,20(a5)
    80001378:	daf5                	beqz	a3,8000136c <uvmdealloc+0xae>
    8000137a:	6394                	ld	a3,0(a5)
    8000137c:	fe9698e3          	bne	a3,s1,8000136c <uvmdealloc+0xae>
            p->swapped_pages[i].in_use = 0;
    80001380:	00271793          	slli	a5,a4,0x2
    80001384:	97ba                	add	a5,a5,a4
    80001386:	078e                	slli	a5,a5,0x3
    80001388:	97ce                	add	a5,a5,s3
    8000138a:	97aa                	add	a5,a5,a0
    8000138c:	c407ae23          	sw	zero,-932(a5)
            p->num_swapped_pages--;
    80001390:	c4882783          	lw	a5,-952(a6) # ac48 <_entry-0x7fff53b8>
    80001394:	37fd                	addiw	a5,a5,-1
    80001396:	c4f82423          	sw	a5,-952(a6)
      for(va = PGROUNDUP(newsz); va < PGROUNDUP(oldsz); va += PGSIZE) {
    8000139a:	94aa                	add	s1,s1,a0
    8000139c:	0124fb63          	bgeu	s1,s2,800013b2 <uvmdealloc+0xf4>
        for(int i = 0; i < MAX_RESIDENT_PAGES; i++) {
    800013a0:	1a098793          	addi	a5,s3,416
    800013a4:	4701                	li	a4,0
    800013a6:	bf71                	j	80001342 <uvmdealloc+0x84>
    return oldsz;
    800013a8:	8a4a                	mv	s4,s2
    800013aa:	bf81                	j	800012fa <uvmdealloc+0x3c>
    800013ac:	74a2                	ld	s1,40(sp)
    800013ae:	69e2                	ld	s3,24(sp)
    800013b0:	b7a9                	j	800012fa <uvmdealloc+0x3c>
    800013b2:	74a2                	ld	s1,40(sp)
    800013b4:	69e2                	ld	s3,24(sp)
    800013b6:	b791                	j	800012fa <uvmdealloc+0x3c>

00000000800013b8 <uvmalloc>:
  if(newsz < oldsz)
    800013b8:	0ab66163          	bltu	a2,a1,8000145a <uvmalloc+0xa2>
{
    800013bc:	715d                	addi	sp,sp,-80
    800013be:	e486                	sd	ra,72(sp)
    800013c0:	e0a2                	sd	s0,64(sp)
    800013c2:	f84a                	sd	s2,48(sp)
    800013c4:	f052                	sd	s4,32(sp)
    800013c6:	ec56                	sd	s5,24(sp)
    800013c8:	e45e                	sd	s7,8(sp)
    800013ca:	0880                	addi	s0,sp,80
    800013cc:	8aaa                	mv	s5,a0
    800013ce:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800013d0:	6785                	lui	a5,0x1
    800013d2:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013d4:	95be                	add	a1,a1,a5
    800013d6:	77fd                	lui	a5,0xfffff
    800013d8:	00f5f933          	and	s2,a1,a5
    800013dc:	8bca                	mv	s7,s2
  for(a = oldsz; a < newsz; a += PGSIZE){
    800013de:	08c97063          	bgeu	s2,a2,8000145e <uvmalloc+0xa6>
    800013e2:	fc26                	sd	s1,56(sp)
    800013e4:	f44e                	sd	s3,40(sp)
    800013e6:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    800013e8:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800013ea:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800013ee:	f5aff0ef          	jal	80000b48 <kalloc>
    800013f2:	84aa                	mv	s1,a0
    if(mem == 0){
    800013f4:	c50d                	beqz	a0,8000141e <uvmalloc+0x66>
    memset(mem, 0, PGSIZE);
    800013f6:	864e                	mv	a2,s3
    800013f8:	4581                	li	a1,0
    800013fa:	903ff0ef          	jal	80000cfc <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800013fe:	875a                	mv	a4,s6
    80001400:	86a6                	mv	a3,s1
    80001402:	864e                	mv	a2,s3
    80001404:	85ca                	mv	a1,s2
    80001406:	8556                	mv	a0,s5
    80001408:	c5dff0ef          	jal	80001064 <mappages>
    8000140c:	e915                	bnez	a0,80001440 <uvmalloc+0x88>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000140e:	994e                	add	s2,s2,s3
    80001410:	fd496fe3          	bltu	s2,s4,800013ee <uvmalloc+0x36>
  return newsz;
    80001414:	8552                	mv	a0,s4
    80001416:	74e2                	ld	s1,56(sp)
    80001418:	79a2                	ld	s3,40(sp)
    8000141a:	6b42                	ld	s6,16(sp)
    8000141c:	a811                	j	80001430 <uvmalloc+0x78>
      uvmdealloc(pagetable, a, oldsz);
    8000141e:	865e                	mv	a2,s7
    80001420:	85ca                	mv	a1,s2
    80001422:	8556                	mv	a0,s5
    80001424:	e9bff0ef          	jal	800012be <uvmdealloc>
      return 0;
    80001428:	4501                	li	a0,0
    8000142a:	74e2                	ld	s1,56(sp)
    8000142c:	79a2                	ld	s3,40(sp)
    8000142e:	6b42                	ld	s6,16(sp)
}
    80001430:	60a6                	ld	ra,72(sp)
    80001432:	6406                	ld	s0,64(sp)
    80001434:	7942                	ld	s2,48(sp)
    80001436:	7a02                	ld	s4,32(sp)
    80001438:	6ae2                	ld	s5,24(sp)
    8000143a:	6ba2                	ld	s7,8(sp)
    8000143c:	6161                	addi	sp,sp,80
    8000143e:	8082                	ret
      kfree(mem);
    80001440:	8526                	mv	a0,s1
    80001442:	e1aff0ef          	jal	80000a5c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001446:	865e                	mv	a2,s7
    80001448:	85ca                	mv	a1,s2
    8000144a:	8556                	mv	a0,s5
    8000144c:	e73ff0ef          	jal	800012be <uvmdealloc>
      return 0;
    80001450:	4501                	li	a0,0
    80001452:	74e2                	ld	s1,56(sp)
    80001454:	79a2                	ld	s3,40(sp)
    80001456:	6b42                	ld	s6,16(sp)
    80001458:	bfe1                	j	80001430 <uvmalloc+0x78>
    return oldsz;
    8000145a:	852e                	mv	a0,a1
}
    8000145c:	8082                	ret
  return newsz;
    8000145e:	8532                	mv	a0,a2
    80001460:	bfc1                	j	80001430 <uvmalloc+0x78>

0000000080001462 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001462:	7179                	addi	sp,sp,-48
    80001464:	f406                	sd	ra,40(sp)
    80001466:	f022                	sd	s0,32(sp)
    80001468:	ec26                	sd	s1,24(sp)
    8000146a:	e84a                	sd	s2,16(sp)
    8000146c:	e44e                	sd	s3,8(sp)
    8000146e:	e052                	sd	s4,0(sp)
    80001470:	1800                	addi	s0,sp,48
    80001472:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001474:	84aa                	mv	s1,a0
    80001476:	6985                	lui	s3,0x1
    80001478:	99aa                	add	s3,s3,a0
    8000147a:	a811                	j	8000148e <freewalk+0x2c>
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      // This is a leaf PTE - in demand paging, this can happen
      // if exec fails after allocating pages. Clean it up.
      uint64 pa = PTE2PA(pte);
    8000147c:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);  // Free the physical page
    8000147e:	0532                	slli	a0,a0,0xc
    80001480:	ddcff0ef          	jal	80000a5c <kfree>
      pagetable[i] = 0;  // Clear the PTE
    80001484:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001488:	04a1                	addi	s1,s1,8
    8000148a:	03348063          	beq	s1,s3,800014aa <freewalk+0x48>
    pte_t pte = pagetable[i];
    8000148e:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001490:	00157793          	andi	a5,a0,1
    80001494:	dbf5                	beqz	a5,80001488 <freewalk+0x26>
    80001496:	00e57793          	andi	a5,a0,14
    8000149a:	f3ed                	bnez	a5,8000147c <freewalk+0x1a>
      uint64 child = PTE2PA(pte);
    8000149c:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    8000149e:	0532                	slli	a0,a0,0xc
    800014a0:	fc3ff0ef          	jal	80001462 <freewalk>
      pagetable[i] = 0;
    800014a4:	0004b023          	sd	zero,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014a8:	b7c5                	j	80001488 <freewalk+0x26>
    }
  }
  kfree((void*)pagetable);
    800014aa:	8552                	mv	a0,s4
    800014ac:	db0ff0ef          	jal	80000a5c <kfree>
}
    800014b0:	70a2                	ld	ra,40(sp)
    800014b2:	7402                	ld	s0,32(sp)
    800014b4:	64e2                	ld	s1,24(sp)
    800014b6:	6942                	ld	s2,16(sp)
    800014b8:	69a2                	ld	s3,8(sp)
    800014ba:	6a02                	ld	s4,0(sp)
    800014bc:	6145                	addi	sp,sp,48
    800014be:	8082                	ret

00000000800014c0 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800014c0:	1101                	addi	sp,sp,-32
    800014c2:	ec06                	sd	ra,24(sp)
    800014c4:	e822                	sd	s0,16(sp)
    800014c6:	e426                	sd	s1,8(sp)
    800014c8:	1000                	addi	s0,sp,32
    800014ca:	84aa                	mv	s1,a0
  if(sz > 0)
    800014cc:	e989                	bnez	a1,800014de <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800014ce:	8526                	mv	a0,s1
    800014d0:	f93ff0ef          	jal	80001462 <freewalk>
}
    800014d4:	60e2                	ld	ra,24(sp)
    800014d6:	6442                	ld	s0,16(sp)
    800014d8:	64a2                	ld	s1,8(sp)
    800014da:	6105                	addi	sp,sp,32
    800014dc:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800014de:	6785                	lui	a5,0x1
    800014e0:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014e2:	95be                	add	a1,a1,a5
    800014e4:	4685                	li	a3,1
    800014e6:	00c5d613          	srli	a2,a1,0xc
    800014ea:	4581                	li	a1,0
    800014ec:	d49ff0ef          	jal	80001234 <uvmunmap>
    800014f0:	bff9                	j	800014ce <uvmfree+0xe>

00000000800014f2 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800014f2:	ca59                	beqz	a2,80001588 <uvmcopy+0x96>
{
    800014f4:	715d                	addi	sp,sp,-80
    800014f6:	e486                	sd	ra,72(sp)
    800014f8:	e0a2                	sd	s0,64(sp)
    800014fa:	fc26                	sd	s1,56(sp)
    800014fc:	f84a                	sd	s2,48(sp)
    800014fe:	f44e                	sd	s3,40(sp)
    80001500:	f052                	sd	s4,32(sp)
    80001502:	ec56                	sd	s5,24(sp)
    80001504:	e85a                	sd	s6,16(sp)
    80001506:	e45e                	sd	s7,8(sp)
    80001508:	0880                	addi	s0,sp,80
    8000150a:	8b2a                	mv	s6,a0
    8000150c:	8bae                	mv	s7,a1
    8000150e:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001510:	4481                	li	s1,0
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001512:	6a05                	lui	s4,0x1
    80001514:	a021                	j	8000151c <uvmcopy+0x2a>
  for(i = 0; i < sz; i += PGSIZE){
    80001516:	94d2                	add	s1,s1,s4
    80001518:	0554fc63          	bgeu	s1,s5,80001570 <uvmcopy+0x7e>
    if((pte = walk(old, i, 0)) == 0)
    8000151c:	4601                	li	a2,0
    8000151e:	85a6                	mv	a1,s1
    80001520:	855a                	mv	a0,s6
    80001522:	a6fff0ef          	jal	80000f90 <walk>
    80001526:	d965                	beqz	a0,80001516 <uvmcopy+0x24>
    if((*pte & PTE_V) == 0)
    80001528:	00053983          	ld	s3,0(a0)
    8000152c:	0019f793          	andi	a5,s3,1
    80001530:	d3fd                	beqz	a5,80001516 <uvmcopy+0x24>
    if((mem = kalloc()) == 0)
    80001532:	e16ff0ef          	jal	80000b48 <kalloc>
    80001536:	892a                	mv	s2,a0
    80001538:	c11d                	beqz	a0,8000155e <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    8000153a:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char*)pa, PGSIZE);
    8000153e:	8652                	mv	a2,s4
    80001540:	05b2                	slli	a1,a1,0xc
    80001542:	81bff0ef          	jal	80000d5c <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001546:	3ff9f713          	andi	a4,s3,1023
    8000154a:	86ca                	mv	a3,s2
    8000154c:	8652                	mv	a2,s4
    8000154e:	85a6                	mv	a1,s1
    80001550:	855e                	mv	a0,s7
    80001552:	b13ff0ef          	jal	80001064 <mappages>
    80001556:	d161                	beqz	a0,80001516 <uvmcopy+0x24>
      kfree(mem);
    80001558:	854a                	mv	a0,s2
    8000155a:	d02ff0ef          	jal	80000a5c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000155e:	4685                	li	a3,1
    80001560:	00c4d613          	srli	a2,s1,0xc
    80001564:	4581                	li	a1,0
    80001566:	855e                	mv	a0,s7
    80001568:	ccdff0ef          	jal	80001234 <uvmunmap>
  return -1;
    8000156c:	557d                	li	a0,-1
    8000156e:	a011                	j	80001572 <uvmcopy+0x80>
  return 0;
    80001570:	4501                	li	a0,0
}
    80001572:	60a6                	ld	ra,72(sp)
    80001574:	6406                	ld	s0,64(sp)
    80001576:	74e2                	ld	s1,56(sp)
    80001578:	7942                	ld	s2,48(sp)
    8000157a:	79a2                	ld	s3,40(sp)
    8000157c:	7a02                	ld	s4,32(sp)
    8000157e:	6ae2                	ld	s5,24(sp)
    80001580:	6b42                	ld	s6,16(sp)
    80001582:	6ba2                	ld	s7,8(sp)
    80001584:	6161                	addi	sp,sp,80
    80001586:	8082                	ret
  return 0;
    80001588:	4501                	li	a0,0
}
    8000158a:	8082                	ret

000000008000158c <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000158c:	1141                	addi	sp,sp,-16
    8000158e:	e406                	sd	ra,8(sp)
    80001590:	e022                	sd	s0,0(sp)
    80001592:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001594:	4601                	li	a2,0
    80001596:	9fbff0ef          	jal	80000f90 <walk>
  if(pte == 0)
    8000159a:	c901                	beqz	a0,800015aa <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000159c:	611c                	ld	a5,0(a0)
    8000159e:	9bbd                	andi	a5,a5,-17
    800015a0:	e11c                	sd	a5,0(a0)
}
    800015a2:	60a2                	ld	ra,8(sp)
    800015a4:	6402                	ld	s0,0(sp)
    800015a6:	0141                	addi	sp,sp,16
    800015a8:	8082                	ret
    panic("uvmclear");
    800015aa:	00008517          	auipc	a0,0x8
    800015ae:	b8e50513          	addi	a0,a0,-1138 # 80009138 <etext+0x138>
    800015b2:	a72ff0ef          	jal	80000824 <panic>

00000000800015b6 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800015b6:	cac5                	beqz	a3,80001666 <copyinstr+0xb0>
{
    800015b8:	715d                	addi	sp,sp,-80
    800015ba:	e486                	sd	ra,72(sp)
    800015bc:	e0a2                	sd	s0,64(sp)
    800015be:	fc26                	sd	s1,56(sp)
    800015c0:	f84a                	sd	s2,48(sp)
    800015c2:	f44e                	sd	s3,40(sp)
    800015c4:	f052                	sd	s4,32(sp)
    800015c6:	ec56                	sd	s5,24(sp)
    800015c8:	e85a                	sd	s6,16(sp)
    800015ca:	e45e                	sd	s7,8(sp)
    800015cc:	0880                	addi	s0,sp,80
    800015ce:	8aaa                	mv	s5,a0
    800015d0:	84ae                	mv	s1,a1
    800015d2:	8bb2                	mv	s7,a2
    800015d4:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800015d6:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800015d8:	6a05                	lui	s4,0x1
    800015da:	a82d                	j	80001614 <copyinstr+0x5e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800015dc:	00078023          	sb	zero,0(a5)
        got_null = 1;
    800015e0:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800015e2:	0017c793          	xori	a5,a5,1
    800015e6:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800015ea:	60a6                	ld	ra,72(sp)
    800015ec:	6406                	ld	s0,64(sp)
    800015ee:	74e2                	ld	s1,56(sp)
    800015f0:	7942                	ld	s2,48(sp)
    800015f2:	79a2                	ld	s3,40(sp)
    800015f4:	7a02                	ld	s4,32(sp)
    800015f6:	6ae2                	ld	s5,24(sp)
    800015f8:	6b42                	ld	s6,16(sp)
    800015fa:	6ba2                	ld	s7,8(sp)
    800015fc:	6161                	addi	sp,sp,80
    800015fe:	8082                	ret
    80001600:	fff98713          	addi	a4,s3,-1 # fff <_entry-0x7ffff001>
    80001604:	9726                	add	a4,a4,s1
      --max;
    80001606:	40b709b3          	sub	s3,a4,a1
    srcva = va0 + PGSIZE;
    8000160a:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    8000160e:	04e58463          	beq	a1,a4,80001656 <copyinstr+0xa0>
{
    80001612:	84be                	mv	s1,a5
    va0 = PGROUNDDOWN(srcva);
    80001614:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    80001618:	85ca                	mv	a1,s2
    8000161a:	8556                	mv	a0,s5
    8000161c:	a0fff0ef          	jal	8000102a <walkaddr>
    if(pa0 == 0)
    80001620:	cd0d                	beqz	a0,8000165a <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001622:	417906b3          	sub	a3,s2,s7
    80001626:	96d2                	add	a3,a3,s4
    if(n > max)
    80001628:	00d9f363          	bgeu	s3,a3,8000162e <copyinstr+0x78>
    8000162c:	86ce                	mv	a3,s3
    while(n > 0){
    8000162e:	ca85                	beqz	a3,8000165e <copyinstr+0xa8>
    char *p = (char *) (pa0 + (srcva - va0));
    80001630:	01750633          	add	a2,a0,s7
    80001634:	41260633          	sub	a2,a2,s2
    80001638:	87a6                	mv	a5,s1
      if(*p == '\0'){
    8000163a:	8e05                	sub	a2,a2,s1
    while(n > 0){
    8000163c:	96a6                	add	a3,a3,s1
    8000163e:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001640:	00f60733          	add	a4,a2,a5
    80001644:	00074703          	lbu	a4,0(a4)
    80001648:	db51                	beqz	a4,800015dc <copyinstr+0x26>
        *dst = *p;
    8000164a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000164e:	0785                	addi	a5,a5,1
    while(n > 0){
    80001650:	fed797e3          	bne	a5,a3,8000163e <copyinstr+0x88>
    80001654:	b775                	j	80001600 <copyinstr+0x4a>
    80001656:	4781                	li	a5,0
    80001658:	b769                	j	800015e2 <copyinstr+0x2c>
      return -1;
    8000165a:	557d                	li	a0,-1
    8000165c:	b779                	j	800015ea <copyinstr+0x34>
    srcva = va0 + PGSIZE;
    8000165e:	6b85                	lui	s7,0x1
    80001660:	9bca                	add	s7,s7,s2
    80001662:	87a6                	mv	a5,s1
    80001664:	b77d                	j	80001612 <copyinstr+0x5c>
  int got_null = 0;
    80001666:	4781                	li	a5,0
  if(got_null){
    80001668:	0017c793          	xori	a5,a5,1
    8000166c:	40f0053b          	negw	a0,a5
}
    80001670:	8082                	ret

0000000080001672 <clear_resident_pages>:
}

//part1 - Clear all resident pages when exec starts (reset FIFO state)
void
clear_resident_pages(void)
{
    80001672:	1141                	addi	sp,sp,-16
    80001674:	e406                	sd	ra,8(sp)
    80001676:	e022                	sd	s0,0(sp)
    80001678:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000167a:	7ca010ef          	jal	80002e44 <myproc>
  
  // Clear all resident page tracking
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) {
    8000167e:	1a050793          	addi	a5,a0,416
    80001682:	7ff50713          	addi	a4,a0,2047
    80001686:	3a170713          	addi	a4,a4,929
    p->resident_pages[i].in_use = 0;
    p->resident_pages[i].va = 0;
    p->resident_pages[i].seq = 0;
    p->resident_pages[i].is_dirty = 0;
    p->resident_pages[i].swap_slot = -1;
    8000168a:	56fd                	li	a3,-1
    p->resident_pages[i].in_use = 0;
    8000168c:	0007aa23          	sw	zero,20(a5)
    p->resident_pages[i].va = 0;
    80001690:	0007b023          	sd	zero,0(a5)
    p->resident_pages[i].seq = 0;
    80001694:	0007a423          	sw	zero,8(a5)
    p->resident_pages[i].is_dirty = 0;
    80001698:	0007a623          	sw	zero,12(a5)
    p->resident_pages[i].swap_slot = -1;
    8000169c:	cb94                	sw	a3,16(a5)
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) {
    8000169e:	02878793          	addi	a5,a5,40
    800016a2:	fee795e3          	bne	a5,a4,8000168c <clear_resident_pages+0x1a>
    800016a6:	7ff50793          	addi	a5,a0,2047
    800016aa:	44978793          	addi	a5,a5,1097
    800016ae:	672d                	lui	a4,0xb
    800016b0:	c4870713          	addi	a4,a4,-952 # ac48 <_entry-0x7fff53b8>
    800016b4:	972a                	add	a4,a4,a0
  for(int i = 0; i < MAX_SWAP_PAGES; i++) {
    p->swapped_pages[i].in_use = 0;
    p->swapped_pages[i].va = 0;
    p->swapped_pages[i].seq = 0;
    p->swapped_pages[i].is_dirty = 0;
    p->swapped_pages[i].swap_slot = -1;
    800016b6:	56fd                	li	a3,-1
    p->swapped_pages[i].in_use = 0;
    800016b8:	0007aa23          	sw	zero,20(a5)
    p->swapped_pages[i].va = 0;
    800016bc:	0007b023          	sd	zero,0(a5)
    p->swapped_pages[i].seq = 0;
    800016c0:	0007a423          	sw	zero,8(a5)
    p->swapped_pages[i].is_dirty = 0;
    800016c4:	0007a623          	sw	zero,12(a5)
    p->swapped_pages[i].swap_slot = -1;
    800016c8:	cb94                	sw	a3,16(a5)
  for(int i = 0; i < MAX_SWAP_PAGES; i++) {
    800016ca:	02878793          	addi	a5,a5,40
    800016ce:	fee795e3          	bne	a5,a4,800016b8 <clear_resident_pages+0x46>
  }
  
  p->num_resident_pages = 0;
    800016d2:	7ff50793          	addi	a5,a0,2047
    800016d6:	3a07a0a3          	sw	zero,929(a5)
  p->num_swapped_pages = 0;
    800016da:	67ad                	lui	a5,0xb
    800016dc:	97aa                	add	a5,a5,a0
    800016de:	c407a423          	sw	zero,-952(a5) # ac48 <_entry-0x7fff53b8>
  p->next_fifo_seq = 1;  // Reset sequence counter
    800016e2:	4705                	li	a4,1
    800016e4:	18e52c23          	sw	a4,408(a0)
  p->memfull_logged = 0; // Reset MEMFULL flag for new exec
    800016e8:	ca07a423          	sw	zero,-856(a5)
}
    800016ec:	60a2                	ld	ra,8(sp)
    800016ee:	6402                	ld	s0,0(sp)
    800016f0:	0141                	addi	sp,sp,16
    800016f2:	8082                	ret

00000000800016f4 <enable_bonus_algorithm>:

// BONUS: Enable LFU-Recent page replacement algorithm
// Call this function to switch from FIFO to LFU-Recent for the current process
void
enable_bonus_algorithm(void)
{
    800016f4:	1141                	addi	sp,sp,-16
    800016f6:	e406                	sd	ra,8(sp)
    800016f8:	e022                	sd	s0,0(sp)
    800016fa:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800016fc:	748010ef          	jal	80002e44 <myproc>
  p->use_bonus_algorithm = 1;
    80001700:	67ad                	lui	a5,0xb
    80001702:	97aa                	add	a5,a5,a0
    80001704:	4705                	li	a4,1
    80001706:	cae7a623          	sw	a4,-852(a5) # acac <_entry-0x7fff5354>
  p->global_time_counter = 1; // Initialize time counter
    8000170a:	cae7b823          	sd	a4,-848(a5)
  
  // Initialize bonus fields for existing resident pages
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) {
    8000170e:	1b450793          	addi	a5,a0,436
    80001712:	7ff50613          	addi	a2,a0,2047
    80001716:	3b560613          	addi	a2,a2,949 # 13b5 <_entry-0x7fffec4b>
    if(p->resident_pages[i].in_use) {
      p->resident_pages[i].access_frequency = 1; // Initial access
    8000171a:	883a                	mv	a6,a4
      p->resident_pages[i].last_access_time = p->global_time_counter++;
    8000171c:	66ad                	lui	a3,0xb
    8000171e:	96aa                	add	a3,a3,a0
    80001720:	a029                	j	8000172a <enable_bonus_algorithm+0x36>
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) {
    80001722:	02878793          	addi	a5,a5,40
    80001726:	00c78f63          	beq	a5,a2,80001744 <enable_bonus_algorithm+0x50>
    if(p->resident_pages[i].in_use) {
    8000172a:	4398                	lw	a4,0(a5)
    8000172c:	db7d                	beqz	a4,80001722 <enable_bonus_algorithm+0x2e>
      p->resident_pages[i].access_frequency = 1; // Initial access
    8000172e:	0107a223          	sw	a6,4(a5)
      p->resident_pages[i].last_access_time = p->global_time_counter++;
    80001732:	cb06b703          	ld	a4,-848(a3) # acb0 <_entry-0x7fff5350>
    80001736:	00170593          	addi	a1,a4,1
    8000173a:	cab6b823          	sd	a1,-848(a3)
    8000173e:	00e7b623          	sd	a4,12(a5)
    80001742:	b7c5                	j	80001722 <enable_bonus_algorithm+0x2e>
    }
  }
  
  printf("[pid %d] BONUS: LFU-Recent algorithm enabled\n", p->pid);
    80001744:	590c                	lw	a1,48(a0)
    80001746:	00008517          	auipc	a0,0x8
    8000174a:	a0250513          	addi	a0,a0,-1534 # 80009148 <etext+0x148>
    8000174e:	dadfe0ef          	jal	800004fa <printf>
}
    80001752:	60a2                	ld	ra,8(sp)
    80001754:	6402                	ld	s0,0(sp)
    80001756:	0141                	addi	sp,sp,16
    80001758:	8082                	ret

000000008000175a <update_page_access>:

// BONUS: Update page access statistics for LFU-Recent algorithm
// Called whenever a page is accessed (not just on page faults)
void
update_page_access(uint64 va)
{
    8000175a:	1101                	addi	sp,sp,-32
    8000175c:	ec06                	sd	ra,24(sp)
    8000175e:	e822                	sd	s0,16(sp)
    80001760:	e426                	sd	s1,8(sp)
    80001762:	1000                	addi	s0,sp,32
    80001764:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001766:	6de010ef          	jal	80002e44 <myproc>
  
  // Only update if using bonus algorithm
  if(!p->use_bonus_algorithm) {
    8000176a:	67ad                	lui	a5,0xb
    8000176c:	97aa                	add	a5,a5,a0
    8000176e:	cac7a783          	lw	a5,-852(a5) # acac <_entry-0x7fff5354>
    80001772:	cba9                	beqz	a5,800017c4 <update_page_access+0x6a>
    80001774:	1a050793          	addi	a5,a0,416
    return;
  }
  
  // Find the page in resident pages and update access stats
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) {
    80001778:	4701                	li	a4,0
    8000177a:	04000613          	li	a2,64
    8000177e:	a031                	j	8000178a <update_page_access+0x30>
    80001780:	2705                	addiw	a4,a4,1
    80001782:	02878793          	addi	a5,a5,40
    80001786:	02c70f63          	beq	a4,a2,800017c4 <update_page_access+0x6a>
    if(p->resident_pages[i].in_use && p->resident_pages[i].va == va) {
    8000178a:	4bd4                	lw	a3,20(a5)
    8000178c:	daf5                	beqz	a3,80001780 <update_page_access+0x26>
    8000178e:	6394                	ld	a3,0(a5)
    80001790:	fe9698e3          	bne	a3,s1,80001780 <update_page_access+0x26>
      p->resident_pages[i].access_frequency++;
    80001794:	00271793          	slli	a5,a4,0x2
    80001798:	00e786b3          	add	a3,a5,a4
    8000179c:	068e                	slli	a3,a3,0x3
    8000179e:	96aa                	add	a3,a3,a0
    800017a0:	1b86a603          	lw	a2,440(a3)
    800017a4:	2605                	addiw	a2,a2,1
    800017a6:	1ac6ac23          	sw	a2,440(a3)
      p->resident_pages[i].last_access_time = p->global_time_counter++;
    800017aa:	66ad                	lui	a3,0xb
    800017ac:	96aa                	add	a3,a3,a0
    800017ae:	cb06b603          	ld	a2,-848(a3) # acb0 <_entry-0x7fff5350>
    800017b2:	00160593          	addi	a1,a2,1
    800017b6:	cab6b823          	sd	a1,-848(a3)
    800017ba:	97ba                	add	a5,a5,a4
    800017bc:	078e                	slli	a5,a5,0x3
    800017be:	953e                	add	a0,a0,a5
    800017c0:	1cc53023          	sd	a2,448(a0)
      break;
    }
  }
}
    800017c4:	60e2                	ld	ra,24(sp)
    800017c6:	6442                	ld	s0,16(sp)
    800017c8:	64a2                	ld	s1,8(sp)
    800017ca:	6105                	addi	sp,sp,32
    800017cc:	8082                	ret

00000000800017ce <ismapped>:

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800017ce:	1141                	addi	sp,sp,-16
    800017d0:	e406                	sd	ra,8(sp)
    800017d2:	e022                	sd	s0,0(sp)
    800017d4:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800017d6:	4601                	li	a2,0
    800017d8:	fb8ff0ef          	jal	80000f90 <walk>
  if (pte == 0) {
    800017dc:	c119                	beqz	a0,800017e2 <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V){
    800017de:	6108                	ld	a0,0(a0)
    800017e0:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800017e2:	60a2                	ld	ra,8(sp)
    800017e4:	6402                	ld	s0,0(sp)
    800017e6:	0141                	addi	sp,sp,16
    800017e8:	8082                	ret

00000000800017ea <create_swap_file>:
//part3 - Swap file management functions

// Create a unique swap file for the process
int
create_swap_file(void)
{
    800017ea:	7179                	addi	sp,sp,-48
    800017ec:	f406                	sd	ra,40(sp)
    800017ee:	f022                	sd	s0,32(sp)
    800017f0:	ec26                	sd	s1,24(sp)
    800017f2:	e84a                	sd	s2,16(sp)
    800017f4:	e44e                	sd	s3,8(sp)
    800017f6:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800017f8:	64c010ef          	jal	80002e44 <myproc>
    800017fc:	84aa                	mv	s1,a0
  char *base = "/pgswp";
  int len = 0;
  while(base[len]) len++; // manual strlen
  
  // Copy base name
  for(int i = 0; i < len; i++) {
    800017fe:	00008797          	auipc	a5,0x8
    80001802:	97a78793          	addi	a5,a5,-1670 # 80009178 <etext+0x178>
    80001806:	7ff50713          	addi	a4,a0,2047
    8000180a:	3b170713          	addi	a4,a4,945
    8000180e:	00008617          	auipc	a2,0x8
    80001812:	97060613          	addi	a2,a2,-1680 # 8000917e <etext+0x17e>
    p->swapfilename[i] = base[i];
    80001816:	0007c683          	lbu	a3,0(a5)
    8000181a:	00d70023          	sb	a3,0(a4)
  for(int i = 0; i < len; i++) {
    8000181e:	0785                	addi	a5,a5,1
    80001820:	0705                	addi	a4,a4,1
    80001822:	fec79ae3          	bne	a5,a2,80001816 <create_swap_file+0x2c>
  }
  
  // Add PID as 5-digit number
  int pid = p->pid;
    80001826:	5898                	lw	a4,48(s1)
  p->swapfilename[len + 4] = '0' + (pid % 10); pid /= 10;
    80001828:	6905                	lui	s2,0x1
    8000182a:	9926                	add	s2,s2,s1
    8000182c:	666667b7          	lui	a5,0x66666
    80001830:	66778793          	addi	a5,a5,1639 # 66666667 <_entry-0x19999999>
    80001834:	02f706b3          	mul	a3,a4,a5
    80001838:	9689                	srai	a3,a3,0x22
    8000183a:	41f7561b          	sraiw	a2,a4,0x1f
    8000183e:	9e91                	subw	a3,a3,a2
    80001840:	0026961b          	slliw	a2,a3,0x2
    80001844:	9e35                	addw	a2,a2,a3
    80001846:	0016161b          	slliw	a2,a2,0x1
    8000184a:	9f11                	subw	a4,a4,a2
    8000184c:	0307071b          	addiw	a4,a4,48
    80001850:	bae90d23          	sb	a4,-1094(s2) # bba <_entry-0x7ffff446>
  p->swapfilename[len + 3] = '0' + (pid % 10); pid /= 10;
    80001854:	02f68733          	mul	a4,a3,a5
    80001858:	9709                	srai	a4,a4,0x22
    8000185a:	41f6d61b          	sraiw	a2,a3,0x1f
    8000185e:	9f11                	subw	a4,a4,a2
    80001860:	0027161b          	slliw	a2,a4,0x2
    80001864:	9e39                	addw	a2,a2,a4
    80001866:	0016161b          	slliw	a2,a2,0x1
    8000186a:	9e91                	subw	a3,a3,a2
    8000186c:	0306869b          	addiw	a3,a3,48
    80001870:	bad90ca3          	sb	a3,-1095(s2)
  p->swapfilename[len + 2] = '0' + (pid % 10); pid /= 10;
    80001874:	02f706b3          	mul	a3,a4,a5
    80001878:	9689                	srai	a3,a3,0x22
    8000187a:	41f7561b          	sraiw	a2,a4,0x1f
    8000187e:	9e91                	subw	a3,a3,a2
    80001880:	0026961b          	slliw	a2,a3,0x2
    80001884:	9e35                	addw	a2,a2,a3
    80001886:	0016161b          	slliw	a2,a2,0x1
    8000188a:	9f11                	subw	a4,a4,a2
    8000188c:	0307071b          	addiw	a4,a4,48
    80001890:	bae90c23          	sb	a4,-1096(s2)
  p->swapfilename[len + 1] = '0' + (pid % 10); pid /= 10;
    80001894:	02f68733          	mul	a4,a3,a5
    80001898:	9709                	srai	a4,a4,0x22
    8000189a:	41f6d61b          	sraiw	a2,a3,0x1f
    8000189e:	9f11                	subw	a4,a4,a2
    800018a0:	0027161b          	slliw	a2,a4,0x2
    800018a4:	9e39                	addw	a2,a2,a4
    800018a6:	0016161b          	slliw	a2,a2,0x1
    800018aa:	9e91                	subw	a3,a3,a2
    800018ac:	0306869b          	addiw	a3,a3,48
    800018b0:	bad90ba3          	sb	a3,-1097(s2)
  p->swapfilename[len + 0] = '0' + (pid % 10);
    800018b4:	02f707b3          	mul	a5,a4,a5
    800018b8:	9789                	srai	a5,a5,0x22
    800018ba:	41f7569b          	sraiw	a3,a4,0x1f
    800018be:	9f95                	subw	a5,a5,a3
    800018c0:	0027969b          	slliw	a3,a5,0x2
    800018c4:	9fb5                	addw	a5,a5,a3
    800018c6:	0017979b          	slliw	a5,a5,0x1
    800018ca:	9f1d                	subw	a4,a4,a5
    800018cc:	0307071b          	addiw	a4,a4,48
    800018d0:	bae90b23          	sb	a4,-1098(s2)
  p->swapfilename[len + 5] = 0; // null terminator
    800018d4:	ba090da3          	sb	zero,-1093(s2)
  
  // Create the swap file
  begin_op();
    800018d8:	579030ef          	jal	80005650 <begin_op>
  p->swapfile = create(p->swapfilename, T_FILE, 0, 0);
    800018dc:	7ff48993          	addi	s3,s1,2047
    800018e0:	3b198993          	addi	s3,s3,945
    800018e4:	4681                	li	a3,0
    800018e6:	4601                	li	a2,0
    800018e8:	4589                	li	a1,2
    800018ea:	854e                	mv	a0,s3
    800018ec:	1c4050ef          	jal	80006ab0 <create>
    800018f0:	baa93423          	sd	a0,-1112(s2)
  if(p->swapfile == 0) {
    800018f4:	c921                	beqz	a0,80001944 <create_swap_file+0x15a>
    end_op();
    return -1;
  }
  
  // NO pre-allocation - file will grow on-demand
  p->swap_slots_used = 0;
    800018f6:	7ff48793          	addi	a5,s1,2047
    800018fa:	3c07a0a3          	sw	zero,961(a5)
  for(int i = 0; i < SWAP_BITMAP_SIZE; i++) 
    800018fe:	3c978793          	addi	a5,a5,969
    80001902:	7ff48713          	addi	a4,s1,2047
    80001906:	44970713          	addi	a4,a4,1097
  {
    p->swap_bitmap[i] = 0;
    8000190a:	0007b023          	sd	zero,0(a5)
  for(int i = 0; i < SWAP_BITMAP_SIZE; i++) 
    8000190e:	07a1                	addi	a5,a5,8
    80001910:	fee79de3          	bne	a5,a4,8000190a <create_swap_file+0x120>
  }
  p->num_swapped_pages = 0;
    80001914:	67ad                	lui	a5,0xb
    80001916:	97a6                	add	a5,a5,s1
    80001918:	c407a423          	sw	zero,-952(a5) # ac48 <_entry-0x7fff53b8>
  
  iunlock(p->swapfile);
    8000191c:	3d6030ef          	jal	80004cf2 <iunlock>
  end_op();
    80001920:	5a1030ef          	jal	800056c0 <end_op>
  
  printf("[pid %d] SWAP file created: %s\n", p->pid, p->swapfilename);
    80001924:	864e                	mv	a2,s3
    80001926:	588c                	lw	a1,48(s1)
    80001928:	00008517          	auipc	a0,0x8
    8000192c:	85850513          	addi	a0,a0,-1960 # 80009180 <etext+0x180>
    80001930:	bcbfe0ef          	jal	800004fa <printf>
  return 0;
    80001934:	4501                	li	a0,0
}
    80001936:	70a2                	ld	ra,40(sp)
    80001938:	7402                	ld	s0,32(sp)
    8000193a:	64e2                	ld	s1,24(sp)
    8000193c:	6942                	ld	s2,16(sp)
    8000193e:	69a2                	ld	s3,8(sp)
    80001940:	6145                	addi	sp,sp,48
    80001942:	8082                	ret
    end_op();
    80001944:	57d030ef          	jal	800056c0 <end_op>
    return -1;
    80001948:	557d                	li	a0,-1
    8000194a:	b7f5                	j	80001936 <create_swap_file+0x14c>

000000008000194c <alloc_swap_slot>:


// Find a free swap slot
int
alloc_swap_slot(void)
{
    8000194c:	1101                	addi	sp,sp,-32
    8000194e:	ec06                	sd	ra,24(sp)
    80001950:	e822                	sd	s0,16(sp)
    80001952:	e426                	sd	s1,8(sp)
    80001954:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001956:	4ee010ef          	jal	80002e44 <myproc>
  
  // Check if we have space
  if(p->swap_slots_used >= MAX_SWAP_SLOTS) 
    8000195a:	7ff50793          	addi	a5,a0,2047
    8000195e:	3c17a603          	lw	a2,961(a5)
    80001962:	3ff00793          	li	a5,1023
    80001966:	02c7c463          	blt	a5,a2,8000198e <alloc_swap_slot+0x42>
    8000196a:	7ff50f93          	addi	t6,a0,2047
    8000196e:	3c9f8f93          	addi	t6,t6,969
    80001972:	4301                	li	t1,0
    80001974:	04000e13          	li	t3,64
           p->pid, p->swap_slots_used, MAX_SWAP_SLOTS);
    return -1; // No free slots
  }
  
  // Find first free bit in bitmap
  for(int word = 0; word < SWAP_BITMAP_SIZE; word++) 
    80001978:	4f01                	li	t5,0
  {
    if(p->swap_bitmap[word] != 0xFFFFFFFFFFFFFFFF) 
    8000197a:	52fd                	li	t0,-1
    8000197c:	6e85                	lui	t4,0x1
    8000197e:	c58e8e93          	addi	t4,t4,-936 # c58 <_entry-0x7ffff3a8>
    80001982:	65ad                	lui	a1,0xb
    80001984:	c5858593          	addi	a1,a1,-936 # ac58 <_entry-0x7fff53a8>
    80001988:	95aa                	add	a1,a1,a0
  for(int word = 0; word < SWAP_BITMAP_SIZE; word++) 
    8000198a:	43c1                	li	t2,16
    8000198c:	a851                	j	80001a20 <alloc_swap_slot+0xd4>
    printf("[pid %d] SWAP FULL: slots_used=%d >= MAX_SWAP_SLOTS=%d\n", 
    8000198e:	40000693          	li	a3,1024
    80001992:	590c                	lw	a1,48(a0)
    80001994:	00008517          	auipc	a0,0x8
    80001998:	80c50513          	addi	a0,a0,-2036 # 800091a0 <etext+0x1a0>
    8000199c:	b5ffe0ef          	jal	800004fa <printf>
    return -1; // No free slots
    800019a0:	54fd                	li	s1,-1
    800019a2:	a08d                	j	80001a04 <alloc_swap_slot+0xb8>
          int slot = word * 64 + bit;
          if(slot < MAX_SWAP_SLOTS) 
          {
            // Double-check this slot is not already used by another page
            int already_used = 0;
            for(int i = 0; i < MAX_SWAP_PAGES; i++) 
    800019a4:	02878793          	addi	a5,a5,40
    800019a8:	02b78463          	beq	a5,a1,800019d0 <alloc_swap_slot+0x84>
            {
              if(p->swapped_pages[i].in_use && p->swapped_pages[i].swap_slot == slot) 
    800019ac:	43d8                	lw	a4,4(a5)
    800019ae:	db7d                	beqz	a4,800019a4 <alloc_swap_slot+0x58>
    800019b0:	4398                	lw	a4,0(a5)
    800019b2:	fe9719e3          	bne	a4,s1,800019a4 <alloc_swap_slot+0x58>
      for(int bit = 0; bit < 64; bit++) 
    800019b6:	2685                	addiw	a3,a3,1
    800019b8:	05c68c63          	beq	a3,t3,80001a10 <alloc_swap_slot+0xc4>
    800019bc:	0066883b          	addw	a6,a3,t1
        if((p->swap_bitmap[word] & (1UL << bit)) == 0) 
    800019c0:	0108d7b3          	srl	a5,a7,a6
    800019c4:	8b85                	andi	a5,a5,1
    800019c6:	fbe5                	bnez	a5,800019b6 <alloc_swap_slot+0x6a>
          int slot = word * 64 + bit;
    800019c8:	84b6                	mv	s1,a3
          if(slot < MAX_SWAP_SLOTS) 
    800019ca:	01d507b3          	add	a5,a0,t4
    800019ce:	bff9                	j	800019ac <alloc_swap_slot+0x60>
              }
            }
            
            if(!already_used) 
            {
              p->swap_bitmap[word] |= (1UL << bit);
    800019d0:	178f0793          	addi	a5,t5,376
    800019d4:	078e                	slli	a5,a5,0x3
    800019d6:	97aa                	add	a5,a5,a0
    800019d8:	4705                	li	a4,1
    800019da:	01071733          	sll	a4,a4,a6
    800019de:	01176733          	or	a4,a4,a7
    800019e2:	e798                	sd	a4,8(a5)
              p->swap_slots_used++;
    800019e4:	0016069b          	addiw	a3,a2,1
    800019e8:	7ff50793          	addi	a5,a0,2047
    800019ec:	3cd7a0a3          	sw	a3,961(a5)
              printf("[pid %d] ALLOCATED slot=%d (slots_used=%d/%d)\n", 
    800019f0:	40000713          	li	a4,1024
    800019f4:	8626                	mv	a2,s1
    800019f6:	590c                	lw	a1,48(a0)
    800019f8:	00007517          	auipc	a0,0x7
    800019fc:	7e050513          	addi	a0,a0,2016 # 800091d8 <etext+0x1d8>
    80001a00:	afbfe0ef          	jal	800004fa <printf>
  }
  
  printf("[pid %d] NO FREE SLOTS: bitmap full? slots_used=%d\n", 
         p->pid, p->swap_slots_used);
  return -1; // Should not reach here if swap_slots_used count is correct
}
    80001a04:	8526                	mv	a0,s1
    80001a06:	60e2                	ld	ra,24(sp)
    80001a08:	6442                	ld	s0,16(sp)
    80001a0a:	64a2                	ld	s1,8(sp)
    80001a0c:	6105                	addi	sp,sp,32
    80001a0e:	8082                	ret
  for(int word = 0; word < SWAP_BITMAP_SIZE; word++) 
    80001a10:	2f05                	addiw	t5,t5,1
    80001a12:	0fa1                	addi	t6,t6,8
    80001a14:	040e0e1b          	addiw	t3,t3,64
    80001a18:	fc03031b          	addiw	t1,t1,-64
    80001a1c:	007f0963          	beq	t5,t2,80001a2e <alloc_swap_slot+0xe2>
    if(p->swap_bitmap[word] != 0xFFFFFFFFFFFFFFFF) 
    80001a20:	000fb883          	ld	a7,0(t6)
    80001a24:	fe5886e3          	beq	a7,t0,80001a10 <alloc_swap_slot+0xc4>
    80001a28:	006f169b          	slliw	a3,t5,0x6
    80001a2c:	bf41                	j	800019bc <alloc_swap_slot+0x70>
  printf("[pid %d] NO FREE SLOTS: bitmap full? slots_used=%d\n", 
    80001a2e:	590c                	lw	a1,48(a0)
    80001a30:	00007517          	auipc	a0,0x7
    80001a34:	7d850513          	addi	a0,a0,2008 # 80009208 <etext+0x208>
    80001a38:	ac3fe0ef          	jal	800004fa <printf>
  return -1; // Should not reach here if swap_slots_used count is correct
    80001a3c:	54fd                	li	s1,-1
    80001a3e:	b7d9                	j	80001a04 <alloc_swap_slot+0xb8>

0000000080001a40 <free_swap_slot>:

// Free a swap slot
void
free_swap_slot(int slot)
{
    80001a40:	1101                	addi	sp,sp,-32
    80001a42:	ec06                	sd	ra,24(sp)
    80001a44:	e822                	sd	s0,16(sp)
    80001a46:	e426                	sd	s1,8(sp)
    80001a48:	1000                	addi	s0,sp,32
    80001a4a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001a4c:	3f8010ef          	jal	80002e44 <myproc>
  
  if(slot < 0 || slot >= MAX_SWAP_SLOTS) {
    80001a50:	3ff00793          	li	a5,1023
    80001a54:	0297e563          	bltu	a5,s1,80001a7e <free_swap_slot+0x3e>
    return;
  }
  
  int word = slot / 64;
    80001a58:	41f4d79b          	sraiw	a5,s1,0x1f
    80001a5c:	01a7d79b          	srliw	a5,a5,0x1a
    80001a60:	9fa5                	addw	a5,a5,s1
    80001a62:	4067d79b          	sraiw	a5,a5,0x6
    80001a66:	078e                	slli	a5,a5,0x3
    80001a68:	97aa                	add	a5,a5,a0
  int bit = slot % 64;
  
  if(p->swap_bitmap[word] & (1UL << bit)) {
    80001a6a:	7ff78713          	addi	a4,a5,2047
    80001a6e:	3c973683          	ld	a3,969(a4)
    80001a72:	03f4f613          	andi	a2,s1,63
    80001a76:	00c6d733          	srl	a4,a3,a2
    80001a7a:	8b05                	andi	a4,a4,1
    80001a7c:	e711                	bnez	a4,80001a88 <free_swap_slot+0x48>
    p->swap_bitmap[word] &= ~(1UL << bit);
    p->swap_slots_used--;
    printf("[pid %d] FREED slot=%d (slots_used=%d/%d)\n", 
           p->pid, slot, p->swap_slots_used, MAX_SWAP_SLOTS);
  }
}
    80001a7e:	60e2                	ld	ra,24(sp)
    80001a80:	6442                	ld	s0,16(sp)
    80001a82:	64a2                	ld	s1,8(sp)
    80001a84:	6105                	addi	sp,sp,32
    80001a86:	8082                	ret
    p->swap_bitmap[word] &= ~(1UL << bit);
    80001a88:	6585                	lui	a1,0x1
    80001a8a:	97ae                	add	a5,a5,a1
    80001a8c:	4705                	li	a4,1
    80001a8e:	00c71733          	sll	a4,a4,a2
    80001a92:	fff74713          	not	a4,a4
    80001a96:	8f75                	and	a4,a4,a3
    80001a98:	bce7b423          	sd	a4,-1080(a5)
    p->swap_slots_used--;
    80001a9c:	00b507b3          	add	a5,a0,a1
    80001aa0:	bc07a683          	lw	a3,-1088(a5)
    80001aa4:	36fd                	addiw	a3,a3,-1
    80001aa6:	bcd7a023          	sw	a3,-1088(a5)
    printf("[pid %d] FREED slot=%d (slots_used=%d/%d)\n", 
    80001aaa:	40000713          	li	a4,1024
    80001aae:	8626                	mv	a2,s1
    80001ab0:	590c                	lw	a1,48(a0)
    80001ab2:	00007517          	auipc	a0,0x7
    80001ab6:	78e50513          	addi	a0,a0,1934 # 80009240 <etext+0x240>
    80001aba:	a41fe0ef          	jal	800004fa <printf>
    80001abe:	b7c1                	j	80001a7e <free_swap_slot+0x3e>

0000000080001ac0 <swap_out_page>:

// Write a page to swap
int
swap_out_page(uint64 va, char *mem, int is_dirty)
{
    80001ac0:	711d                	addi	sp,sp,-96
    80001ac2:	ec86                	sd	ra,88(sp)
    80001ac4:	e8a2                	sd	s0,80(sp)
    80001ac6:	e4a6                	sd	s1,72(sp)
    80001ac8:	e0ca                	sd	s2,64(sp)
    80001aca:	fc4e                	sd	s3,56(sp)
    80001acc:	f852                	sd	s4,48(sp)
    80001ace:	e862                	sd	s8,16(sp)
    80001ad0:	1080                	addi	s0,sp,96
    80001ad2:	8a2a                	mv	s4,a0
    80001ad4:	89ae                	mv	s3,a1
    80001ad6:	8c32                	mv	s8,a2
  struct proc *p = myproc();
    80001ad8:	36c010ef          	jal	80002e44 <myproc>
    80001adc:	84aa                	mv	s1,a0
  
  // Check if swap file is valid, create one if needed
  if(p->swapfile == 0) {
    80001ade:	7ff50793          	addi	a5,a0,2047
    80001ae2:	3a97b783          	ld	a5,937(a5)
    80001ae6:	0c078e63          	beqz	a5,80001bc2 <swap_out_page+0x102>
      return -1;
    }
  }
  
  // Allocate swap slot
  int slot = alloc_swap_slot();
    80001aea:	e63ff0ef          	jal	8000194c <alloc_swap_slot>
    80001aee:	892a                	mv	s2,a0
  if(slot < 0) {
    80001af0:	0e054663          	bltz	a0,80001bdc <swap_out_page+0x11c>
    printf("[pid %d] SWAPFULL\n", p->pid);
    return -1; // No free swap slots
  }
  
  // Write page to swap file
  begin_op();
    80001af4:	35d030ef          	jal	80005650 <begin_op>
  
  // Double-check swap file is still valid after begin_op
  if(p->swapfile == 0) {
    80001af8:	7ff48793          	addi	a5,s1,2047
    80001afc:	3a97b503          	ld	a0,937(a5)
    80001b00:	0e050763          	beqz	a0,80001bee <swap_out_page+0x12e>
    80001b04:	f456                	sd	s5,40(sp)
    80001b06:	f05a                	sd	s6,32(sp)
    80001b08:	ec5e                	sd	s7,24(sp)
    end_op();
    free_swap_slot(slot);
    return -1;
  }
  
  ilock(p->swapfile);
    80001b0a:	13a030ef          	jal	80004c44 <ilock>
  
  uint64 offset = slot * PGSIZE;
    80001b0e:	00c91a9b          	slliw	s5,s2,0xc
  printf("[pid %d] SWAPOUT_DEBUG: writing slot=%d offset=%lu size=%d\n", 
    80001b12:	6705                	lui	a4,0x1
    80001b14:	86d6                	mv	a3,s5
    80001b16:	864a                	mv	a2,s2
    80001b18:	588c                	lw	a1,48(s1)
    80001b1a:	00007517          	auipc	a0,0x7
    80001b1e:	7c650513          	addi	a0,a0,1990 # 800092e0 <etext+0x2e0>
    80001b22:	9d9fe0ef          	jal	800004fa <printf>
         p->pid, slot, offset, PGSIZE);
  
  // Ensure the file is large enough - extend if necessary
  uint64 required_size = offset + PGSIZE;
    80001b26:	6785                	lui	a5,0x1
    80001b28:	00fa86b3          	add	a3,s5,a5
  if(p->swapfile->size < required_size) {
    80001b2c:	97a6                	add	a5,a5,s1
    80001b2e:	ba87b783          	ld	a5,-1112(a5) # ba8 <_entry-0x7ffff458>
    80001b32:	47f0                	lw	a2,76(a5)
    80001b34:	02061793          	slli	a5,a2,0x20
    80001b38:	9381                	srli	a5,a5,0x20
    80001b3a:	0cd7e863          	bltu	a5,a3,80001c0a <swap_out_page+0x14a>
           p->pid, p->swapfile->size, required_size);
    // We don't need to explicitly extend - writei will do it if we write sequential data
    // But we can ensure the inode knows the final size
  }
  
  int written = writei(p->swapfile, 0, (uint64)mem, offset, PGSIZE);
    80001b3e:	6b05                	lui	s6,0x1
    80001b40:	016487b3          	add	a5,s1,s6
    80001b44:	875a                	mv	a4,s6
    80001b46:	86d6                	mv	a3,s5
    80001b48:	864e                	mv	a2,s3
    80001b4a:	4581                	li	a1,0
    80001b4c:	ba87b503          	ld	a0,-1112(a5)
    80001b50:	578030ef          	jal	800050c8 <writei>
    80001b54:	8baa                	mv	s7,a0
  printf("[pid %d] SWAPOUT_DEBUG: wrote %d bytes to offset %lu\n", 
    80001b56:	86d6                	mv	a3,s5
    80001b58:	862a                	mv	a2,a0
    80001b5a:	588c                	lw	a1,48(s1)
    80001b5c:	00008517          	auipc	a0,0x8
    80001b60:	80450513          	addi	a0,a0,-2044 # 80009360 <etext+0x360>
    80001b64:	997fe0ef          	jal	800004fa <printf>
         p->pid, written, offset);
         
  if(written != PGSIZE) {
    80001b68:	0b6b9963          	bne	s7,s6,80001c1a <swap_out_page+0x15a>
    end_op();
    free_swap_slot(slot);
    return -1;
  }
  
  iunlock(p->swapfile);
    80001b6c:	7ff48793          	addi	a5,s1,2047
    80001b70:	3a97b503          	ld	a0,937(a5)
    80001b74:	17e030ef          	jal	80004cf2 <iunlock>
  end_op();
    80001b78:	349030ef          	jal	800056c0 <end_op>
  
  // Debug: Log first integer value of written data
  int *intdata = (int*)mem;
  printf("[pid %d] SWAPOUT_DATA va=0x%lx slot=%d first_int=%d (bytes=%d,%d,%d,%d)\n", 
    80001b7c:	588c                	lw	a1,48(s1)
    80001b7e:	0039c783          	lbu	a5,3(s3)
    80001b82:	e03e                	sd	a5,0(sp)
    80001b84:	0029c883          	lbu	a7,2(s3)
    80001b88:	0019c803          	lbu	a6,1(s3)
    80001b8c:	0009c783          	lbu	a5,0(s3)
    80001b90:	0009a703          	lw	a4,0(s3)
    80001b94:	86ca                	mv	a3,s2
    80001b96:	8652                	mv	a2,s4
    80001b98:	00008517          	auipc	a0,0x8
    80001b9c:	87850513          	addi	a0,a0,-1928 # 80009410 <etext+0x410>
    80001ba0:	95bfe0ef          	jal	800004fa <printf>
         p->pid, va, slot, *intdata, 
         ((char*)mem)[0] & 0xFF, ((char*)mem)[1] & 0xFF, 
         ((char*)mem)[2] & 0xFF, ((char*)mem)[3] & 0xFF);
  
  // Add to swapped pages list with dirty status preserved
  for(int i = 0; i < MAX_SWAP_PAGES; i++) {
    80001ba4:	7ff48793          	addi	a5,s1,2047
    80001ba8:	45d78793          	addi	a5,a5,1117
    80001bac:	4701                	li	a4,0
    80001bae:	40000813          	li	a6,1024
    if(!p->swapped_pages[i].in_use) {
    80001bb2:	438c                	lw	a1,0(a5)
    80001bb4:	c9c5                	beqz	a1,80001c64 <swap_out_page+0x1a4>
  for(int i = 0; i < MAX_SWAP_PAGES; i++) {
    80001bb6:	2705                	addiw	a4,a4,1 # 1001 <_entry-0x7fffefff>
    80001bb8:	02878793          	addi	a5,a5,40
    80001bbc:	ff071be3          	bne	a4,a6,80001bb2 <swap_out_page+0xf2>
    80001bc0:	a8f9                	j	80001c9e <swap_out_page+0x1de>
    if(create_swap_file() < 0) {
    80001bc2:	c29ff0ef          	jal	800017ea <create_swap_file>
    80001bc6:	f20552e3          	bgez	a0,80001aea <swap_out_page+0x2a>
      printf("[pid %d] SWAPOUT_ERROR: no swap file\n", p->pid);
    80001bca:	588c                	lw	a1,48(s1)
    80001bcc:	00007517          	auipc	a0,0x7
    80001bd0:	6a450513          	addi	a0,a0,1700 # 80009270 <etext+0x270>
    80001bd4:	927fe0ef          	jal	800004fa <printf>
      return -1;
    80001bd8:	597d                	li	s2,-1
    80001bda:	a8f1                	j	80001cb6 <swap_out_page+0x1f6>
    printf("[pid %d] SWAPFULL\n", p->pid);
    80001bdc:	588c                	lw	a1,48(s1)
    80001bde:	00007517          	auipc	a0,0x7
    80001be2:	6ba50513          	addi	a0,a0,1722 # 80009298 <etext+0x298>
    80001be6:	915fe0ef          	jal	800004fa <printf>
    return -1; // No free swap slots
    80001bea:	597d                	li	s2,-1
    80001bec:	a0e9                	j	80001cb6 <swap_out_page+0x1f6>
    printf("[pid %d] SWAPOUT_ERROR: swap file disappeared\n", p->pid);
    80001bee:	588c                	lw	a1,48(s1)
    80001bf0:	00007517          	auipc	a0,0x7
    80001bf4:	6c050513          	addi	a0,a0,1728 # 800092b0 <etext+0x2b0>
    80001bf8:	903fe0ef          	jal	800004fa <printf>
    end_op();
    80001bfc:	2c5030ef          	jal	800056c0 <end_op>
    free_swap_slot(slot);
    80001c00:	854a                	mv	a0,s2
    80001c02:	e3fff0ef          	jal	80001a40 <free_swap_slot>
    return -1;
    80001c06:	597d                	li	s2,-1
    80001c08:	a07d                	j	80001cb6 <swap_out_page+0x1f6>
    printf("[pid %d] SWAPOUT_DEBUG: extending file from %d to %lu bytes\n", 
    80001c0a:	588c                	lw	a1,48(s1)
    80001c0c:	00007517          	auipc	a0,0x7
    80001c10:	71450513          	addi	a0,a0,1812 # 80009320 <etext+0x320>
    80001c14:	8e7fe0ef          	jal	800004fa <printf>
    80001c18:	b71d                	j	80001b3e <swap_out_page+0x7e>
    printf("[pid %d] WRITEI_FAILED: wrote %d bytes, expected %d\n", 
    80001c1a:	86da                	mv	a3,s6
    80001c1c:	865e                	mv	a2,s7
    80001c1e:	588c                	lw	a1,48(s1)
    80001c20:	00007517          	auipc	a0,0x7
    80001c24:	77850513          	addi	a0,a0,1912 # 80009398 <etext+0x398>
    80001c28:	8d3fe0ef          	jal	800004fa <printf>
    printf("[pid %d] SWAPOUT_DEBUG: file size=%d, offset=%lu, slot=%d\n", 
    80001c2c:	016489b3          	add	s3,s1,s6
    80001c30:	ba89b783          	ld	a5,-1112(s3)
    80001c34:	874a                	mv	a4,s2
    80001c36:	86d6                	mv	a3,s5
    80001c38:	47f0                	lw	a2,76(a5)
    80001c3a:	588c                	lw	a1,48(s1)
    80001c3c:	00007517          	auipc	a0,0x7
    80001c40:	79450513          	addi	a0,a0,1940 # 800093d0 <etext+0x3d0>
    80001c44:	8b7fe0ef          	jal	800004fa <printf>
    iunlock(p->swapfile);
    80001c48:	ba89b503          	ld	a0,-1112(s3)
    80001c4c:	0a6030ef          	jal	80004cf2 <iunlock>
    end_op();
    80001c50:	271030ef          	jal	800056c0 <end_op>
    free_swap_slot(slot);
    80001c54:	854a                	mv	a0,s2
    80001c56:	debff0ef          	jal	80001a40 <free_swap_slot>
    return -1;
    80001c5a:	597d                	li	s2,-1
    80001c5c:	7aa2                	ld	s5,40(sp)
    80001c5e:	7b02                	ld	s6,32(sp)
    80001c60:	6be2                	ld	s7,24(sp)
    80001c62:	a891                	j	80001cb6 <swap_out_page+0x1f6>
      p->swapped_pages[i].in_use = 1;
    80001c64:	00271693          	slli	a3,a4,0x2
    80001c68:	00e687b3          	add	a5,a3,a4
    80001c6c:	078e                	slli	a5,a5,0x3
    80001c6e:	97a6                	add	a5,a5,s1
    80001c70:	6605                	lui	a2,0x1
    80001c72:	97b2                	add	a5,a5,a2
    80001c74:	4585                	li	a1,1
    80001c76:	c4b7ae23          	sw	a1,-932(a5)
      p->swapped_pages[i].va = va;
    80001c7a:	c547b423          	sd	s4,-952(a5)
      p->swapped_pages[i].swap_slot = slot;
    80001c7e:	c527ac23          	sw	s2,-936(a5)
      p->swapped_pages[i].is_dirty = is_dirty; // Preserve dirty status
    80001c82:	00e687b3          	add	a5,a3,a4
    80001c86:	078e                	slli	a5,a5,0x3
    80001c88:	97a6                	add	a5,a5,s1
    80001c8a:	963e                	add	a2,a2,a5
    80001c8c:	c5862a23          	sw	s8,-940(a2) # c54 <_entry-0x7ffff3ac>
      p->num_swapped_pages++;
    80001c90:	67ad                	lui	a5,0xb
    80001c92:	97a6                	add	a5,a5,s1
    80001c94:	c487a703          	lw	a4,-952(a5) # ac48 <_entry-0x7fff53b8>
    80001c98:	2705                	addiw	a4,a4,1
    80001c9a:	c4e7a423          	sw	a4,-952(a5)
      break;
    }
  }
  
  printf("[pid %d] SWAPOUT va=0x%lx slot=%d\n", p->pid, va, slot);
    80001c9e:	86ca                	mv	a3,s2
    80001ca0:	8652                	mv	a2,s4
    80001ca2:	588c                	lw	a1,48(s1)
    80001ca4:	00007517          	auipc	a0,0x7
    80001ca8:	7bc50513          	addi	a0,a0,1980 # 80009460 <etext+0x460>
    80001cac:	84ffe0ef          	jal	800004fa <printf>
    80001cb0:	7aa2                	ld	s5,40(sp)
    80001cb2:	7b02                	ld	s6,32(sp)
    80001cb4:	6be2                	ld	s7,24(sp)
  return slot;
}
    80001cb6:	854a                	mv	a0,s2
    80001cb8:	60e6                	ld	ra,88(sp)
    80001cba:	6446                	ld	s0,80(sp)
    80001cbc:	64a6                	ld	s1,72(sp)
    80001cbe:	6906                	ld	s2,64(sp)
    80001cc0:	79e2                	ld	s3,56(sp)
    80001cc2:	7a42                	ld	s4,48(sp)
    80001cc4:	6c42                	ld	s8,16(sp)
    80001cc6:	6125                	addi	sp,sp,96
    80001cc8:	8082                	ret

0000000080001cca <evict_page>:
{
    80001cca:	7179                	addi	sp,sp,-48
    80001ccc:	f406                	sd	ra,40(sp)
    80001cce:	f022                	sd	s0,32(sp)
    80001cd0:	ec26                	sd	s1,24(sp)
    80001cd2:	e84a                	sd	s2,16(sp)
    80001cd4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001cd6:	16e010ef          	jal	80002e44 <myproc>
    80001cda:	892a                	mv	s2,a0
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) 
    80001cdc:	1a850793          	addi	a5,a0,424
    80001ce0:	4701                	li	a4,0
  int oldest_seq = -1;
    80001ce2:	587d                	li	a6,-1
  int oldest_idx = -1;
    80001ce4:	84c2                	mv	s1,a6
      if(oldest_idx == -1 || p->resident_pages[i].seq < oldest_seq) 
    80001ce6:	88c2                	mv	a7,a6
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) 
    80001ce8:	04000593          	li	a1,64
    80001cec:	a809                	j	80001cfe <evict_page+0x34>
        oldest_seq = p->resident_pages[i].seq;
    80001cee:	00062803          	lw	a6,0(a2)
        oldest_idx = i;
    80001cf2:	84ba                	mv	s1,a4
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) 
    80001cf4:	2705                	addiw	a4,a4,1
    80001cf6:	02878793          	addi	a5,a5,40
    80001cfa:	00b70b63          	beq	a4,a1,80001d10 <evict_page+0x46>
    if(p->resident_pages[i].in_use) 
    80001cfe:	863e                	mv	a2,a5
    80001d00:	47d4                	lw	a3,12(a5)
    80001d02:	daed                	beqz	a3,80001cf4 <evict_page+0x2a>
      if(oldest_idx == -1 || p->resident_pages[i].seq < oldest_seq) 
    80001d04:	ff1485e3          	beq	s1,a7,80001cee <evict_page+0x24>
    80001d08:	4394                	lw	a3,0(a5)
    80001d0a:	ff06d5e3          	bge	a3,a6,80001cf4 <evict_page+0x2a>
    80001d0e:	b7c5                	j	80001cee <evict_page+0x24>
  if(oldest_idx == -1) 
    80001d10:	57fd                	li	a5,-1
    return 0;
    80001d12:	4501                	li	a0,0
  if(oldest_idx == -1) 
    80001d14:	10f48463          	beq	s1,a5,80001e1c <evict_page+0x152>
    80001d18:	e44e                	sd	s3,8(sp)
  printf("[pid %d] VICTIM va=0x%lx seq=%d algo=FIFO\n", p->pid, victim->va, victim->seq);
    80001d1a:	00249993          	slli	s3,s1,0x2
    80001d1e:	99a6                	add	s3,s3,s1
    80001d20:	098e                	slli	s3,s3,0x3
    80001d22:	99ca                	add	s3,s3,s2
    80001d24:	1a89a683          	lw	a3,424(s3)
    80001d28:	1a09b603          	ld	a2,416(s3)
    80001d2c:	03092583          	lw	a1,48(s2)
    80001d30:	00007517          	auipc	a0,0x7
    80001d34:	75850513          	addi	a0,a0,1880 # 80009488 <etext+0x488>
    80001d38:	fc2fe0ef          	jal	800004fa <printf>
  int is_dirty = victim->is_dirty;
    80001d3c:	1ac9a983          	lw	s3,428(s3)
  if(is_dirty) 
    80001d40:	06098963          	beqz	s3,80001db2 <evict_page+0xe8>
    uint64 pa = walkaddr(p->pagetable, victim->va);
    80001d44:	00249793          	slli	a5,s1,0x2
    80001d48:	97a6                	add	a5,a5,s1
    80001d4a:	078e                	slli	a5,a5,0x3
    80001d4c:	97ca                	add	a5,a5,s2
    80001d4e:	1a07b583          	ld	a1,416(a5)
    80001d52:	05093503          	ld	a0,80(s2)
    80001d56:	ad4ff0ef          	jal	8000102a <walkaddr>
    if(pa != 0) 
    80001d5a:	c549                	beqz	a0,80001de4 <evict_page+0x11a>
      int slot = swap_out_page(victim->va, mem, is_dirty);
    80001d5c:	00249793          	slli	a5,s1,0x2
    80001d60:	97a6                	add	a5,a5,s1
    80001d62:	078e                	slli	a5,a5,0x3
    80001d64:	97ca                	add	a5,a5,s2
    80001d66:	864e                	mv	a2,s3
    80001d68:	85aa                	mv	a1,a0
    80001d6a:	1a07b503          	ld	a0,416(a5)
    80001d6e:	d53ff0ef          	jal	80001ac0 <swap_out_page>
      if(slot < 0) 
    80001d72:	02054263          	bltz	a0,80001d96 <evict_page+0xcc>
      printf("[pid %d] EVICT va=0x%lx state=dirty\n", p->pid, victim->va);
    80001d76:	00249793          	slli	a5,s1,0x2
    80001d7a:	97a6                	add	a5,a5,s1
    80001d7c:	078e                	slli	a5,a5,0x3
    80001d7e:	97ca                	add	a5,a5,s2
    80001d80:	1a07b603          	ld	a2,416(a5)
    80001d84:	03092583          	lw	a1,48(s2)
    80001d88:	00007517          	auipc	a0,0x7
    80001d8c:	75050513          	addi	a0,a0,1872 # 800094d8 <etext+0x4d8>
    80001d90:	f6afe0ef          	jal	800004fa <printf>
    80001d94:	a881                	j	80001de4 <evict_page+0x11a>
        printf("[pid %d] KILL swap-exhausted\n", p->pid);
    80001d96:	03092583          	lw	a1,48(s2)
    80001d9a:	00007517          	auipc	a0,0x7
    80001d9e:	71e50513          	addi	a0,a0,1822 # 800094b8 <etext+0x4b8>
    80001da2:	f58fe0ef          	jal	800004fa <printf>
        setkilled(p);
    80001da6:	854a                	mv	a0,s2
    80001da8:	2c3010ef          	jal	8000386a <setkilled>
        return 0;
    80001dac:	4501                	li	a0,0
    80001dae:	69a2                	ld	s3,8(sp)
    80001db0:	a0b5                	j	80001e1c <evict_page+0x152>
    printf("[pid %d] EVICT va=0x%lx state=clean\n", p->pid, victim->va);
    80001db2:	00249993          	slli	s3,s1,0x2
    80001db6:	99a6                	add	s3,s3,s1
    80001db8:	098e                	slli	s3,s3,0x3
    80001dba:	99ca                	add	s3,s3,s2
    80001dbc:	1a09b603          	ld	a2,416(s3)
    80001dc0:	03092583          	lw	a1,48(s2)
    80001dc4:	00007517          	auipc	a0,0x7
    80001dc8:	73c50513          	addi	a0,a0,1852 # 80009500 <etext+0x500>
    80001dcc:	f2efe0ef          	jal	800004fa <printf>
    printf("[pid %d] DISCARD va=0x%lx\n", p->pid, victim->va);
    80001dd0:	1a09b603          	ld	a2,416(s3)
    80001dd4:	03092583          	lw	a1,48(s2)
    80001dd8:	00007517          	auipc	a0,0x7
    80001ddc:	75050513          	addi	a0,a0,1872 # 80009528 <etext+0x528>
    80001de0:	f1afe0ef          	jal	800004fa <printf>
  uint64 pa = walkaddr(p->pagetable, victim->va);// finds physical address for a given virtual address
    80001de4:	00249793          	slli	a5,s1,0x2
    80001de8:	97a6                	add	a5,a5,s1
    80001dea:	078e                	slli	a5,a5,0x3
    80001dec:	97ca                	add	a5,a5,s2
    80001dee:	1a07b583          	ld	a1,416(a5)
    80001df2:	05093503          	ld	a0,80(s2)
    80001df6:	a34ff0ef          	jal	8000102a <walkaddr>
  if(pa != 0) 
    80001dfa:	e51d                	bnez	a0,80001e28 <evict_page+0x15e>
  victim->in_use = 0;
    80001dfc:	00249793          	slli	a5,s1,0x2
    80001e00:	97a6                	add	a5,a5,s1
    80001e02:	078e                	slli	a5,a5,0x3
    80001e04:	97ca                	add	a5,a5,s2
    80001e06:	1a07aa23          	sw	zero,436(a5)
  p->num_resident_pages--;
    80001e0a:	6785                	lui	a5,0x1
    80001e0c:	993e                	add	s2,s2,a5
    80001e0e:	ba092783          	lw	a5,-1120(s2)
    80001e12:	37fd                	addiw	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001e14:	baf92023          	sw	a5,-1120(s2)
  return 1;
    80001e18:	4505                	li	a0,1
    80001e1a:	69a2                	ld	s3,8(sp)
}
    80001e1c:	70a2                	ld	ra,40(sp)
    80001e1e:	7402                	ld	s0,32(sp)
    80001e20:	64e2                	ld	s1,24(sp)
    80001e22:	6942                	ld	s2,16(sp)
    80001e24:	6145                	addi	sp,sp,48
    80001e26:	8082                	ret
    uvmunmap(p->pagetable, victim->va, 1, 1); // Unmap and free
    80001e28:	00249793          	slli	a5,s1,0x2
    80001e2c:	97a6                	add	a5,a5,s1
    80001e2e:	078e                	slli	a5,a5,0x3
    80001e30:	97ca                	add	a5,a5,s2
    80001e32:	4685                	li	a3,1
    80001e34:	8636                	mv	a2,a3
    80001e36:	1a07b583          	ld	a1,416(a5)
    80001e3a:	05093503          	ld	a0,80(s2)
    80001e3e:	bf6ff0ef          	jal	80001234 <uvmunmap>
    80001e42:	bf6d                	j	80001dfc <evict_page+0x132>

0000000080001e44 <evict_page_lfu_recent>:
{
    80001e44:	7179                	addi	sp,sp,-48
    80001e46:	f406                	sd	ra,40(sp)
    80001e48:	f022                	sd	s0,32(sp)
    80001e4a:	ec26                	sd	s1,24(sp)
    80001e4c:	e84a                	sd	s2,16(sp)
    80001e4e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e50:	7f5000ef          	jal	80002e44 <myproc>
    80001e54:	892a                	mv	s2,a0
  if(!p->memfull_logged) {
    80001e56:	67ad                	lui	a5,0xb
    80001e58:	97aa                	add	a5,a5,a0
    80001e5a:	ca87a783          	lw	a5,-856(a5) # aca8 <_entry-0x7fff5358>
    80001e5e:	cf99                	beqz	a5,80001e7c <evict_page_lfu_recent+0x38>
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) 
    80001e60:	1b490713          	addi	a4,s2,436
{
    80001e64:	4681                	li	a3,0
    80001e66:	57fd                	li	a5,-1
    80001e68:	84be                	mv	s1,a5
      int score = calculate_lfu_recent_score(&p->resident_pages[i], p->global_time_counter);
    80001e6a:	632d                	lui	t1,0xb
    80001e6c:	934a                	add	t1,t1,s2
  int frequency_component = (page->access_frequency > 0) ? (1000 / page->access_frequency) : 1000;
    80001e6e:	3e800e13          	li	t3,1000
    80001e72:	3e800e93          	li	t4,1000
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) 
    80001e76:	04000513          	li	a0,64
    80001e7a:	a02d                	j	80001ea4 <evict_page_lfu_recent+0x60>
    printf("[pid %d] MEMFULL: Memory full, invoking LFU-Recent replacement\n", p->pid);
    80001e7c:	590c                	lw	a1,48(a0)
    80001e7e:	00007517          	auipc	a0,0x7
    80001e82:	6ca50513          	addi	a0,a0,1738 # 80009548 <etext+0x548>
    80001e86:	e74fe0ef          	jal	800004fa <printf>
    p->memfull_logged = 1;
    80001e8a:	67ad                	lui	a5,0xb
    80001e8c:	97ca                	add	a5,a5,s2
    80001e8e:	4705                	li	a4,1
    80001e90:	cae7a423          	sw	a4,-856(a5) # aca8 <_entry-0x7fff5358>
    80001e94:	b7f1                	j	80001e60 <evict_page_lfu_recent+0x1c>
        highest_score = score;
    80001e96:	87b2                	mv	a5,a2
        victim_idx = i;
    80001e98:	84b6                	mv	s1,a3
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) 
    80001e9a:	2685                	addiw	a3,a3,1
    80001e9c:	02870713          	addi	a4,a4,40
    80001ea0:	02a68963          	beq	a3,a0,80001ed2 <evict_page_lfu_recent+0x8e>
    if(p->resident_pages[i].in_use) 
    80001ea4:	85ba                	mv	a1,a4
    80001ea6:	4310                	lw	a2,0(a4)
    80001ea8:	da6d                	beqz	a2,80001e9a <evict_page_lfu_recent+0x56>
      int score = calculate_lfu_recent_score(&p->resident_pages[i], p->global_time_counter);
    80001eaa:	cb033603          	ld	a2,-848(t1) # acb0 <_entry-0x7fff5350>
  int frequency_component = (page->access_frequency > 0) ? (1000 / page->access_frequency) : 1000;
    80001eae:	00472883          	lw	a7,4(a4)
    80001eb2:	8872                	mv	a6,t3
    80001eb4:	01105463          	blez	a7,80001ebc <evict_page_lfu_recent+0x78>
    80001eb8:	031ec83b          	divw	a6,t4,a7
  int recency_component = (int)(current_time - page->last_access_time);
    80001ebc:	00c5b583          	ld	a1,12(a1) # 100c <_entry-0x7fffeff4>
    80001ec0:	9e0d                	subw	a2,a2,a1
  return frequency_component + recency_component;
    80001ec2:	0106063b          	addw	a2,a2,a6
      if(victim_idx == -1 || score > highest_score) 
    80001ec6:	00148593          	addi	a1,s1,1
    80001eca:	d5f1                	beqz	a1,80001e96 <evict_page_lfu_recent+0x52>
    80001ecc:	fcc7d7e3          	bge	a5,a2,80001e9a <evict_page_lfu_recent+0x56>
    80001ed0:	b7d9                	j	80001e96 <evict_page_lfu_recent+0x52>
  if(victim_idx == -1) 
    80001ed2:	577d                	li	a4,-1
    return 0;
    80001ed4:	4501                	li	a0,0
  if(victim_idx == -1) 
    80001ed6:	10e48663          	beq	s1,a4,80001fe2 <evict_page_lfu_recent+0x19e>
    80001eda:	e44e                	sd	s3,8(sp)
  printf("[pid %d] VICTIM va=0x%lx freq=%d last_access=%lu score=%d\n", 
    80001edc:	00249993          	slli	s3,s1,0x2
    80001ee0:	99a6                	add	s3,s3,s1
    80001ee2:	098e                	slli	s3,s3,0x3
    80001ee4:	99ca                	add	s3,s3,s2
    80001ee6:	1c09b703          	ld	a4,448(s3)
    80001eea:	1b89a683          	lw	a3,440(s3)
    80001eee:	1a09b603          	ld	a2,416(s3)
    80001ef2:	03092583          	lw	a1,48(s2)
    80001ef6:	00007517          	auipc	a0,0x7
    80001efa:	69250513          	addi	a0,a0,1682 # 80009588 <etext+0x588>
    80001efe:	dfcfe0ef          	jal	800004fa <printf>
  int is_dirty = victim->is_dirty;
    80001f02:	1ac9a983          	lw	s3,428(s3)
  if(is_dirty) 
    80001f06:	06098963          	beqz	s3,80001f78 <evict_page_lfu_recent+0x134>
    uint64 pa = walkaddr(p->pagetable, victim->va);
    80001f0a:	00249793          	slli	a5,s1,0x2
    80001f0e:	97a6                	add	a5,a5,s1
    80001f10:	078e                	slli	a5,a5,0x3
    80001f12:	97ca                	add	a5,a5,s2
    80001f14:	1a07b583          	ld	a1,416(a5)
    80001f18:	05093503          	ld	a0,80(s2)
    80001f1c:	90eff0ef          	jal	8000102a <walkaddr>
    if(pa != 0) 
    80001f20:	c549                	beqz	a0,80001faa <evict_page_lfu_recent+0x166>
      int slot = swap_out_page(victim->va, mem, is_dirty);
    80001f22:	00249793          	slli	a5,s1,0x2
    80001f26:	97a6                	add	a5,a5,s1
    80001f28:	078e                	slli	a5,a5,0x3
    80001f2a:	97ca                	add	a5,a5,s2
    80001f2c:	864e                	mv	a2,s3
    80001f2e:	85aa                	mv	a1,a0
    80001f30:	1a07b503          	ld	a0,416(a5)
    80001f34:	b8dff0ef          	jal	80001ac0 <swap_out_page>
      if(slot < 0) 
    80001f38:	02054263          	bltz	a0,80001f5c <evict_page_lfu_recent+0x118>
      printf("[pid %d] EVICT va=0x%lx state=dirty\n", p->pid, victim->va);
    80001f3c:	00249793          	slli	a5,s1,0x2
    80001f40:	97a6                	add	a5,a5,s1
    80001f42:	078e                	slli	a5,a5,0x3
    80001f44:	97ca                	add	a5,a5,s2
    80001f46:	1a07b603          	ld	a2,416(a5)
    80001f4a:	03092583          	lw	a1,48(s2)
    80001f4e:	00007517          	auipc	a0,0x7
    80001f52:	58a50513          	addi	a0,a0,1418 # 800094d8 <etext+0x4d8>
    80001f56:	da4fe0ef          	jal	800004fa <printf>
    80001f5a:	a881                	j	80001faa <evict_page_lfu_recent+0x166>
        printf("[pid %d] KILL swap-exhausted\n", p->pid);
    80001f5c:	03092583          	lw	a1,48(s2)
    80001f60:	00007517          	auipc	a0,0x7
    80001f64:	55850513          	addi	a0,a0,1368 # 800094b8 <etext+0x4b8>
    80001f68:	d92fe0ef          	jal	800004fa <printf>
        setkilled(p);
    80001f6c:	854a                	mv	a0,s2
    80001f6e:	0fd010ef          	jal	8000386a <setkilled>
        return 0;
    80001f72:	4501                	li	a0,0
    80001f74:	69a2                	ld	s3,8(sp)
    80001f76:	a0b5                	j	80001fe2 <evict_page_lfu_recent+0x19e>
    printf("[pid %d] EVICT va=0x%lx state=clean\n", p->pid, victim->va);
    80001f78:	00249993          	slli	s3,s1,0x2
    80001f7c:	99a6                	add	s3,s3,s1
    80001f7e:	098e                	slli	s3,s3,0x3
    80001f80:	99ca                	add	s3,s3,s2
    80001f82:	1a09b603          	ld	a2,416(s3)
    80001f86:	03092583          	lw	a1,48(s2)
    80001f8a:	00007517          	auipc	a0,0x7
    80001f8e:	57650513          	addi	a0,a0,1398 # 80009500 <etext+0x500>
    80001f92:	d68fe0ef          	jal	800004fa <printf>
    printf("[pid %d] DISCARD va=0x%lx\n", p->pid, victim->va);
    80001f96:	1a09b603          	ld	a2,416(s3)
    80001f9a:	03092583          	lw	a1,48(s2)
    80001f9e:	00007517          	auipc	a0,0x7
    80001fa2:	58a50513          	addi	a0,a0,1418 # 80009528 <etext+0x528>
    80001fa6:	d54fe0ef          	jal	800004fa <printf>
  uint64 pa = walkaddr(p->pagetable, victim->va);
    80001faa:	00249793          	slli	a5,s1,0x2
    80001fae:	97a6                	add	a5,a5,s1
    80001fb0:	078e                	slli	a5,a5,0x3
    80001fb2:	97ca                	add	a5,a5,s2
    80001fb4:	1a07b583          	ld	a1,416(a5)
    80001fb8:	05093503          	ld	a0,80(s2)
    80001fbc:	86eff0ef          	jal	8000102a <walkaddr>
  if(pa != 0) 
    80001fc0:	e51d                	bnez	a0,80001fee <evict_page_lfu_recent+0x1aa>
  victim->in_use = 0;
    80001fc2:	00249793          	slli	a5,s1,0x2
    80001fc6:	97a6                	add	a5,a5,s1
    80001fc8:	078e                	slli	a5,a5,0x3
    80001fca:	97ca                	add	a5,a5,s2
    80001fcc:	1a07aa23          	sw	zero,436(a5)
  p->num_resident_pages--;
    80001fd0:	6785                	lui	a5,0x1
    80001fd2:	993e                	add	s2,s2,a5
    80001fd4:	ba092783          	lw	a5,-1120(s2)
    80001fd8:	37fd                	addiw	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001fda:	baf92023          	sw	a5,-1120(s2)
  return 1;
    80001fde:	4505                	li	a0,1
    80001fe0:	69a2                	ld	s3,8(sp)
}
    80001fe2:	70a2                	ld	ra,40(sp)
    80001fe4:	7402                	ld	s0,32(sp)
    80001fe6:	64e2                	ld	s1,24(sp)
    80001fe8:	6942                	ld	s2,16(sp)
    80001fea:	6145                	addi	sp,sp,48
    80001fec:	8082                	ret
    uvmunmap(p->pagetable, victim->va, 1, 1); // Unmap and free
    80001fee:	00249793          	slli	a5,s1,0x2
    80001ff2:	97a6                	add	a5,a5,s1
    80001ff4:	078e                	slli	a5,a5,0x3
    80001ff6:	97ca                	add	a5,a5,s2
    80001ff8:	4685                	li	a3,1
    80001ffa:	8636                	mv	a2,a3
    80001ffc:	1a07b583          	ld	a1,416(a5)
    80002000:	05093503          	ld	a0,80(s2)
    80002004:	a30ff0ef          	jal	80001234 <uvmunmap>
    80002008:	bf6d                	j	80001fc2 <evict_page_lfu_recent+0x17e>

000000008000200a <evict_page_adaptive>:
{
    8000200a:	1141                	addi	sp,sp,-16
    8000200c:	e406                	sd	ra,8(sp)
    8000200e:	e022                	sd	s0,0(sp)
    80002010:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002012:	633000ef          	jal	80002e44 <myproc>
  if(p->use_bonus_algorithm) {
    80002016:	67ad                	lui	a5,0xb
    80002018:	953e                	add	a0,a0,a5
    8000201a:	cac52783          	lw	a5,-852(a0)
    8000201e:	c799                	beqz	a5,8000202c <evict_page_adaptive+0x22>
    return evict_page_lfu_recent();
    80002020:	e25ff0ef          	jal	80001e44 <evict_page_lfu_recent>
}
    80002024:	60a2                	ld	ra,8(sp)
    80002026:	6402                	ld	s0,0(sp)
    80002028:	0141                	addi	sp,sp,16
    8000202a:	8082                	ret
    return evict_page();
    8000202c:	c9fff0ef          	jal	80001cca <evict_page>
    80002030:	bfd5                	j	80002024 <evict_page_adaptive+0x1a>

0000000080002032 <add_resident_page>:
{
    80002032:	7179                	addi	sp,sp,-48
    80002034:	f406                	sd	ra,40(sp)
    80002036:	f022                	sd	s0,32(sp)
    80002038:	ec26                	sd	s1,24(sp)
    8000203a:	e84a                	sd	s2,16(sp)
    8000203c:	e44e                	sd	s3,8(sp)
    8000203e:	e052                	sd	s4,0(sp)
    80002040:	1800                	addi	s0,sp,48
    80002042:	89aa                	mv	s3,a0
    80002044:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80002046:	5ff000ef          	jal	80002e44 <myproc>
    8000204a:	84aa                	mv	s1,a0
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) {
    8000204c:	1b450913          	addi	s2,a0,436
  struct proc *p = myproc();
    80002050:	874a                	mv	a4,s2
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) {
    80002052:	4781                	li	a5,0
    80002054:	04000813          	li	a6,64
    if(!p->resident_pages[i].in_use) {
    80002058:	4314                	lw	a3,0(a4)
    8000205a:	ca95                	beqz	a3,8000208e <add_resident_page+0x5c>
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) {
    8000205c:	2785                	addiw	a5,a5,1 # b001 <_entry-0x7fff4fff>
    8000205e:	02870713          	addi	a4,a4,40
    80002062:	ff079be3          	bne	a5,a6,80002058 <add_resident_page+0x26>
  if(evict_page_adaptive() == 0) {
    80002066:	fa5ff0ef          	jal	8000200a <evict_page_adaptive>
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) 
    8000206a:	4781                	li	a5,0
    8000206c:	04000693          	li	a3,64
  if(evict_page_adaptive() == 0) {
    80002070:	cd35                	beqz	a0,800020ec <add_resident_page+0xba>
    if(!p->resident_pages[i].in_use) 
    80002072:	00092703          	lw	a4,0(s2)
    80002076:	c749                	beqz	a4,80002100 <add_resident_page+0xce>
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) 
    80002078:	2785                	addiw	a5,a5,1
    8000207a:	02890913          	addi	s2,s2,40
    8000207e:	fed79ae3          	bne	a5,a3,80002072 <add_resident_page+0x40>
  panic("add_resident_page: still no free slots after eviction");
    80002082:	00007517          	auipc	a0,0x7
    80002086:	59e50513          	addi	a0,a0,1438 # 80009620 <etext+0x620>
    8000208a:	f9afe0ef          	jal	80000824 <panic>
      p->resident_pages[i].va = va;
    8000208e:	00279713          	slli	a4,a5,0x2
    80002092:	00f70633          	add	a2,a4,a5
    80002096:	060e                	slli	a2,a2,0x3
    80002098:	9626                	add	a2,a2,s1
    8000209a:	1b363023          	sd	s3,416(a2)
      p->resident_pages[i].seq = p->next_fifo_seq++;
    8000209e:	1984a683          	lw	a3,408(s1)
    800020a2:	0016859b          	addiw	a1,a3,1
    800020a6:	18b4ac23          	sw	a1,408(s1)
    800020aa:	1ad62423          	sw	a3,424(a2)
      p->resident_pages[i].is_dirty = is_dirty;
    800020ae:	1b462623          	sw	s4,428(a2)
      p->resident_pages[i].swap_slot = -1;
    800020b2:	55fd                	li	a1,-1
    800020b4:	1ab62823          	sw	a1,432(a2)
      p->resident_pages[i].in_use = 1;
    800020b8:	4705                	li	a4,1
    800020ba:	1ae62a23          	sw	a4,436(a2)
      p->num_resident_pages++;
    800020be:	6785                	lui	a5,0x1
    800020c0:	97a6                	add	a5,a5,s1
    800020c2:	ba07a703          	lw	a4,-1120(a5) # ba0 <_entry-0x7ffff460>
    800020c6:	2705                	addiw	a4,a4,1
    800020c8:	bae7a023          	sw	a4,-1120(a5)
      printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, va, p->resident_pages[i].seq);
    800020cc:	864e                	mv	a2,s3
    800020ce:	588c                	lw	a1,48(s1)
    800020d0:	00007517          	auipc	a0,0x7
    800020d4:	4f850513          	addi	a0,a0,1272 # 800095c8 <etext+0x5c8>
    800020d8:	c22fe0ef          	jal	800004fa <printf>
}
    800020dc:	70a2                	ld	ra,40(sp)
    800020de:	7402                	ld	s0,32(sp)
    800020e0:	64e2                	ld	s1,24(sp)
    800020e2:	6942                	ld	s2,16(sp)
    800020e4:	69a2                	ld	s3,8(sp)
    800020e6:	6a02                	ld	s4,0(sp)
    800020e8:	6145                	addi	sp,sp,48
    800020ea:	8082                	ret
    printf("[pid %d] EVICTION FAILED - terminating process\n", p->pid);
    800020ec:	588c                	lw	a1,48(s1)
    800020ee:	00007517          	auipc	a0,0x7
    800020f2:	50250513          	addi	a0,a0,1282 # 800095f0 <etext+0x5f0>
    800020f6:	c04fe0ef          	jal	800004fa <printf>
    p->killed = 1;
    800020fa:	4785                	li	a5,1
    800020fc:	d49c                	sw	a5,40(s1)
    return;
    800020fe:	bff9                	j	800020dc <add_resident_page+0xaa>
      p->resident_pages[i].va = va;
    80002100:	00279613          	slli	a2,a5,0x2
    80002104:	00f60733          	add	a4,a2,a5
    80002108:	070e                	slli	a4,a4,0x3
    8000210a:	9726                	add	a4,a4,s1
    8000210c:	1b373023          	sd	s3,416(a4)
      p->resident_pages[i].seq = p->next_fifo_seq++;
    80002110:	1984a683          	lw	a3,408(s1)
    80002114:	0016859b          	addiw	a1,a3,1
    80002118:	18b4ac23          	sw	a1,408(s1)
    8000211c:	1ad72423          	sw	a3,424(a4)
      p->resident_pages[i].is_dirty = is_dirty;
    80002120:	1b472623          	sw	s4,428(a4)
      p->resident_pages[i].swap_slot = -1;
    80002124:	55fd                	li	a1,-1
    80002126:	1ab72823          	sw	a1,432(a4)
      p->resident_pages[i].in_use = 1;
    8000212a:	4585                	li	a1,1
    8000212c:	1ab72a23          	sw	a1,436(a4)
      p->resident_pages[i].access_frequency = 1;
    80002130:	1ab72c23          	sw	a1,440(a4)
      p->resident_pages[i].last_access_time = p->global_time_counter++;
    80002134:	672d                	lui	a4,0xb
    80002136:	9726                	add	a4,a4,s1
    80002138:	cb073583          	ld	a1,-848(a4) # acb0 <_entry-0x7fff5350>
    8000213c:	00158513          	addi	a0,a1,1
    80002140:	caa73823          	sd	a0,-848(a4)
    80002144:	97b2                	add	a5,a5,a2
    80002146:	078e                	slli	a5,a5,0x3
    80002148:	97a6                	add	a5,a5,s1
    8000214a:	1cb7b023          	sd	a1,448(a5)
      p->num_resident_pages++;
    8000214e:	6785                	lui	a5,0x1
    80002150:	97a6                	add	a5,a5,s1
    80002152:	ba07a703          	lw	a4,-1120(a5) # ba0 <_entry-0x7ffff460>
    80002156:	2705                	addiw	a4,a4,1
    80002158:	bae7a023          	sw	a4,-1120(a5)
      printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, va, p->resident_pages[i].seq);
    8000215c:	864e                	mv	a2,s3
    8000215e:	588c                	lw	a1,48(s1)
    80002160:	00007517          	auipc	a0,0x7
    80002164:	46850513          	addi	a0,a0,1128 # 800095c8 <etext+0x5c8>
    80002168:	b92fe0ef          	jal	800004fa <printf>
      return;
    8000216c:	bf85                	j	800020dc <add_resident_page+0xaa>

000000008000216e <allocate_zero_page>:
{
    8000216e:	715d                	addi	sp,sp,-80
    80002170:	e486                	sd	ra,72(sp)
    80002172:	e0a2                	sd	s0,64(sp)
    80002174:	fc26                	sd	s1,56(sp)
    80002176:	f84a                	sd	s2,48(sp)
    80002178:	f44e                	sd	s3,40(sp)
    8000217a:	ec56                	sd	s5,24(sp)
    8000217c:	e85a                	sd	s6,16(sp)
    8000217e:	e45e                	sd	s7,8(sp)
    80002180:	0880                	addi	s0,sp,80
    80002182:	8b2a                	mv	s6,a0
    80002184:	89ae                	mv	s3,a1
    80002186:	8bb2                	mv	s7,a2
  struct proc *p = myproc();
    80002188:	4bd000ef          	jal	80002e44 <myproc>
    8000218c:	84aa                	mv	s1,a0
  mem = kalloc();
    8000218e:	9bbfe0ef          	jal	80000b48 <kalloc>
    80002192:	892a                	mv	s2,a0
  if(mem == 0) {
    80002194:	cd41                	beqz	a0,8000222c <allocate_zero_page+0xbe>
    80002196:	f052                	sd	s4,32(sp)
  memset(mem, 0, PGSIZE);
    80002198:	6605                	lui	a2,0x1
    8000219a:	4581                	li	a1,0
    8000219c:	854a                	mv	a0,s2
    8000219e:	b5ffe0ef          	jal	80000cfc <memset>
  uint64 stack_limit = p->trapframe ? PGROUNDDOWN(p->trapframe->sp) - PGSIZE : 0;
    800021a2:	6cbc                	ld	a5,88(s1)
    800021a4:	cbe9                	beqz	a5,80002276 <allocate_zero_page+0x108>
  if((va >= p->heap_start && va < p->sz) || 
    800021a6:	1884b703          	ld	a4,392(s1)
    800021aa:	00e9e563          	bltu	s3,a4,800021b4 <allocate_zero_page+0x46>
    800021ae:	64b4                	ld	a3,72(s1)
    800021b0:	02d9e163          	bltu	s3,a3,800021d2 <allocate_zero_page+0x64>
  uint64 stack_limit = p->trapframe ? PGROUNDDOWN(p->trapframe->sp) - PGSIZE : 0;
    800021b4:	7b94                	ld	a3,48(a5)
    800021b6:	767d                	lui	a2,0xfffff
    800021b8:	8ef1                	and	a3,a3,a2
    800021ba:	96b2                	add	a3,a3,a2
     (p->trapframe && va >= stack_limit && va < PGROUNDUP(p->trapframe->sp))) {
    800021bc:	0ad9e463          	bltu	s3,a3,80002264 <allocate_zero_page+0xf6>
    800021c0:	c3d5                	beqz	a5,80002264 <allocate_zero_page+0xf6>
    800021c2:	7b9c                	ld	a5,48(a5)
    800021c4:	6685                	lui	a3,0x1
    800021c6:	16fd                	addi	a3,a3,-1 # fff <_entry-0x7ffff001>
    800021c8:	97b6                	add	a5,a5,a3
    800021ca:	8ff1                	and	a5,a5,a2
  int perm = PTE_R | PTE_U;
    800021cc:	46c9                	li	a3,18
     (p->trapframe && va >= stack_limit && va < PGROUNDUP(p->trapframe->sp))) {
    800021ce:	00f9f463          	bgeu	s3,a5,800021d6 <allocate_zero_page+0x68>
    perm |= PTE_W; // Heap and stack are writable
    800021d2:	47d9                	li	a5,22
    800021d4:	86be                	mv	a3,a5
  printf("[pid %d] ALLOCATE_ZERO_PAGE: va=0x%lx perm=0x%x (heap: 0x%lx-0x%lx, stack: one page below SP)\n", 
    800021d6:	64bc                	ld	a5,72(s1)
    800021d8:	8a36                	mv	s4,a3
    800021da:	864e                	mv	a2,s3
    800021dc:	588c                	lw	a1,48(s1)
    800021de:	00007517          	auipc	a0,0x7
    800021e2:	49250513          	addi	a0,a0,1170 # 80009670 <etext+0x670>
    800021e6:	b14fe0ef          	jal	800004fa <printf>
  if(mappages(pagetable, va, PGSIZE, (uint64)mem, perm) != 0) {
    800021ea:	8aca                	mv	s5,s2
    800021ec:	8752                	mv	a4,s4
    800021ee:	86ca                	mv	a3,s2
    800021f0:	6605                	lui	a2,0x1
    800021f2:	85ce                	mv	a1,s3
    800021f4:	855a                	mv	a0,s6
    800021f6:	e6ffe0ef          	jal	80001064 <mappages>
    800021fa:	e925                	bnez	a0,8000226a <allocate_zero_page+0xfc>
  printf("[pid %d] ALLOC va=0x%lx\n", p->pid, va);
    800021fc:	864e                	mv	a2,s3
    800021fe:	588c                	lw	a1,48(s1)
    80002200:	00007517          	auipc	a0,0x7
    80002204:	4d050513          	addi	a0,a0,1232 # 800096d0 <etext+0x6d0>
    80002208:	af2fe0ef          	jal	800004fa <printf>
  add_resident_page(va, is_write); // Mark dirty if it's a write access
    8000220c:	85de                	mv	a1,s7
    8000220e:	854e                	mv	a0,s3
    80002210:	e23ff0ef          	jal	80002032 <add_resident_page>
  return (uint64)mem;
    80002214:	7a02                	ld	s4,32(sp)
}
    80002216:	8556                	mv	a0,s5
    80002218:	60a6                	ld	ra,72(sp)
    8000221a:	6406                	ld	s0,64(sp)
    8000221c:	74e2                	ld	s1,56(sp)
    8000221e:	7942                	ld	s2,48(sp)
    80002220:	79a2                	ld	s3,40(sp)
    80002222:	6ae2                	ld	s5,24(sp)
    80002224:	6b42                	ld	s6,16(sp)
    80002226:	6ba2                	ld	s7,8(sp)
    80002228:	6161                	addi	sp,sp,80
    8000222a:	8082                	ret
    if(!p->memfull_logged) {
    8000222c:	67ad                	lui	a5,0xb
    8000222e:	97a6                	add	a5,a5,s1
    80002230:	ca87a783          	lw	a5,-856(a5) # aca8 <_entry-0x7fff5358>
    80002234:	cb99                	beqz	a5,8000224a <allocate_zero_page+0xdc>
    if(evict_page_adaptive() == 0) {
    80002236:	dd5ff0ef          	jal	8000200a <evict_page_adaptive>
      return 0;
    8000223a:	4a81                	li	s5,0
    if(evict_page_adaptive() == 0) {
    8000223c:	dd69                	beqz	a0,80002216 <allocate_zero_page+0xa8>
    mem = kalloc();
    8000223e:	90bfe0ef          	jal	80000b48 <kalloc>
    80002242:	892a                	mv	s2,a0
    if(mem == 0) {
    80002244:	f929                	bnez	a0,80002196 <allocate_zero_page+0x28>
      return 0;
    80002246:	4a81                	li	s5,0
    80002248:	b7f9                	j	80002216 <allocate_zero_page+0xa8>
      printf("[pid %d] MEMFULL\n", p->pid);
    8000224a:	588c                	lw	a1,48(s1)
    8000224c:	00007517          	auipc	a0,0x7
    80002250:	40c50513          	addi	a0,a0,1036 # 80009658 <etext+0x658>
    80002254:	aa6fe0ef          	jal	800004fa <printf>
      p->memfull_logged = 1;  // Only log once per process
    80002258:	67ad                	lui	a5,0xb
    8000225a:	97a6                	add	a5,a5,s1
    8000225c:	4705                	li	a4,1
    8000225e:	cae7a423          	sw	a4,-856(a5) # aca8 <_entry-0x7fff5358>
    80002262:	bfd1                	j	80002236 <allocate_zero_page+0xc8>
  int perm = PTE_R | PTE_U;
    80002264:	47c9                	li	a5,18
    80002266:	86be                	mv	a3,a5
    80002268:	b7bd                	j	800021d6 <allocate_zero_page+0x68>
    kfree(mem);
    8000226a:	854a                	mv	a0,s2
    8000226c:	ff0fe0ef          	jal	80000a5c <kfree>
    return 0;
    80002270:	4a81                	li	s5,0
    80002272:	7a02                	ld	s4,32(sp)
    80002274:	b74d                	j	80002216 <allocate_zero_page+0xa8>
  if((va >= p->heap_start && va < p->sz) || 
    80002276:	1884b703          	ld	a4,392(s1)
  int perm = PTE_R | PTE_U;
    8000227a:	47c9                	li	a5,18
    8000227c:	86be                	mv	a3,a5
  if((va >= p->heap_start && va < p->sz) || 
    8000227e:	f4e9ece3          	bltu	s3,a4,800021d6 <allocate_zero_page+0x68>
    80002282:	64bc                	ld	a5,72(s1)
    80002284:	f4f9e7e3          	bltu	s3,a5,800021d2 <allocate_zero_page+0x64>
    80002288:	b7b9                	j	800021d6 <allocate_zero_page+0x68>

000000008000228a <load_executable_page>:
{
    8000228a:	715d                	addi	sp,sp,-80
    8000228c:	e486                	sd	ra,72(sp)
    8000228e:	e0a2                	sd	s0,64(sp)
    80002290:	fc26                	sd	s1,56(sp)
    80002292:	f84a                	sd	s2,48(sp)
    80002294:	f44e                	sd	s3,40(sp)
    80002296:	f052                	sd	s4,32(sp)
    80002298:	e85a                	sd	s6,16(sp)
    8000229a:	e45e                	sd	s7,8(sp)
    8000229c:	0880                	addi	s0,sp,80
    8000229e:	8b2a                	mv	s6,a0
    800022a0:	89ae                	mv	s3,a1
    800022a2:	8bb2                	mv	s7,a2
  struct proc *p = myproc();
    800022a4:	3a1000ef          	jal	80002e44 <myproc>
    800022a8:	84aa                	mv	s1,a0
  if(va >= p->text_start && va < p->text_end) {
    800022aa:	16853783          	ld	a5,360(a0)
    800022ae:	00f9ec63          	bltu	s3,a5,800022c6 <load_executable_page+0x3c>
    800022b2:	17053783          	ld	a5,368(a0)
    800022b6:	00f9f863          	bgeu	s3,a5,800022c6 <load_executable_page+0x3c>
    800022ba:	ec56                	sd	s5,24(sp)
    seg = &p->text_seg;
    800022bc:	692d                	lui	s2,0xb
    800022be:	c5890913          	addi	s2,s2,-936 # ac58 <_entry-0x7fff53a8>
    800022c2:	992a                	add	s2,s2,a0
  if(seg == 0) {
    800022c4:	a839                	j	800022e2 <load_executable_page+0x58>
  } else if(va >= p->data_start && va < p->data_end) {
    800022c6:	1784b783          	ld	a5,376(s1)
    return 0; // Invalid address
    800022ca:	4a01                	li	s4,0
  } else if(va >= p->data_start && va < p->data_end) {
    800022cc:	08f9ee63          	bltu	s3,a5,80002368 <load_executable_page+0xde>
    800022d0:	1804b783          	ld	a5,384(s1)
    800022d4:	08f9fa63          	bgeu	s3,a5,80002368 <load_executable_page+0xde>
    800022d8:	ec56                	sd	s5,24(sp)
    seg = &p->data_seg;
    800022da:	692d                	lui	s2,0xb
    800022dc:	c8090913          	addi	s2,s2,-896 # ac80 <_entry-0x7fff5380>
    800022e0:	9926                	add	s2,s2,s1
  mem = kalloc();
    800022e2:	867fe0ef          	jal	80000b48 <kalloc>
    800022e6:	8aaa                	mv	s5,a0
  if(mem == 0) {
    800022e8:	c959                	beqz	a0,8000237e <load_executable_page+0xf4>
  memset(mem, 0, PGSIZE);
    800022ea:	6605                	lui	a2,0x1
    800022ec:	4581                	li	a1,0
    800022ee:	8556                	mv	a0,s5
    800022f0:	a0dfe0ef          	jal	80000cfc <memset>
  uint64 seg_offset = va - seg->va_start;
    800022f4:	00093703          	ld	a4,0(s2)
    800022f8:	40e987b3          	sub	a5,s3,a4
  if(seg_offset < seg->file_size) {
    800022fc:	01893603          	ld	a2,24(s2)
    80002300:	02c7fb63          	bgeu	a5,a2,80002336 <load_executable_page+0xac>
  uint64 file_offset = seg->file_offset + seg_offset;
    80002304:	01093683          	ld	a3,16(s2)
    80002308:	96be                	add	a3,a3,a5
    if(seg_offset + PGSIZE > seg->file_size) {
    8000230a:	6585                	lui	a1,0x1
    8000230c:	97ae                	add	a5,a5,a1
    8000230e:	00f67663          	bgeu	a2,a5,8000231a <load_executable_page+0x90>
      read_size = seg->file_size - seg_offset;
    80002312:	9732                	add	a4,a4,a2
    80002314:	413707b3          	sub	a5,a4,s3
    80002318:	85be                	mv	a1,a5
    if(readi(p->exec_inode, 0, (uint64)mem, file_offset, read_size) != read_size) {
    8000231a:	67ad                	lui	a5,0xb
    8000231c:	97a6                	add	a5,a5,s1
    8000231e:	8a2e                	mv	s4,a1
    80002320:	0005871b          	sext.w	a4,a1
    80002324:	2681                	sext.w	a3,a3
    80002326:	8656                	mv	a2,s5
    80002328:	4581                	li	a1,0
    8000232a:	c507b503          	ld	a0,-944(a5) # ac50 <_entry-0x7fff53b0>
    8000232e:	4a9020ef          	jal	80004fd6 <readi>
    80002332:	09451563          	bne	a0,s4,800023bc <load_executable_page+0x132>
  if(mappages(pagetable, va, PGSIZE, (uint64)mem, seg->perm | PTE_R | PTE_U) != 0) {
    80002336:	86d6                	mv	a3,s5
    80002338:	8a56                	mv	s4,s5
    8000233a:	02092703          	lw	a4,32(s2)
    8000233e:	01276713          	ori	a4,a4,18
    80002342:	6605                	lui	a2,0x1
    80002344:	85ce                	mv	a1,s3
    80002346:	855a                	mv	a0,s6
    80002348:	d1dfe0ef          	jal	80001064 <mappages>
    8000234c:	ed35                	bnez	a0,800023c8 <load_executable_page+0x13e>
  printf("[pid %d] LOADEXEC va=0x%lx\n", p->pid, va);
    8000234e:	864e                	mv	a2,s3
    80002350:	588c                	lw	a1,48(s1)
    80002352:	00007517          	auipc	a0,0x7
    80002356:	39e50513          	addi	a0,a0,926 # 800096f0 <etext+0x6f0>
    8000235a:	9a0fe0ef          	jal	800004fa <printf>
  add_resident_page(va, is_write); // Mark dirty if it's a write access
    8000235e:	85de                	mv	a1,s7
    80002360:	854e                	mv	a0,s3
    80002362:	cd1ff0ef          	jal	80002032 <add_resident_page>
  return (uint64)mem;
    80002366:	6ae2                	ld	s5,24(sp)
}
    80002368:	8552                	mv	a0,s4
    8000236a:	60a6                	ld	ra,72(sp)
    8000236c:	6406                	ld	s0,64(sp)
    8000236e:	74e2                	ld	s1,56(sp)
    80002370:	7942                	ld	s2,48(sp)
    80002372:	79a2                	ld	s3,40(sp)
    80002374:	7a02                	ld	s4,32(sp)
    80002376:	6b42                	ld	s6,16(sp)
    80002378:	6ba2                	ld	s7,8(sp)
    8000237a:	6161                	addi	sp,sp,80
    8000237c:	8082                	ret
    if(!p->memfull_logged) {
    8000237e:	67ad                	lui	a5,0xb
    80002380:	97a6                	add	a5,a5,s1
    80002382:	ca87a783          	lw	a5,-856(a5) # aca8 <_entry-0x7fff5358>
    80002386:	c799                	beqz	a5,80002394 <load_executable_page+0x10a>
    if(evict_page_adaptive() == 0) {
    80002388:	c83ff0ef          	jal	8000200a <evict_page_adaptive>
      return 0;
    8000238c:	4a01                	li	s4,0
    if(evict_page_adaptive() == 0) {
    8000238e:	e105                	bnez	a0,800023ae <load_executable_page+0x124>
    80002390:	6ae2                	ld	s5,24(sp)
    80002392:	bfd9                	j	80002368 <load_executable_page+0xde>
      printf("[pid %d] MEMFULL\n", p->pid);
    80002394:	588c                	lw	a1,48(s1)
    80002396:	00007517          	auipc	a0,0x7
    8000239a:	2c250513          	addi	a0,a0,706 # 80009658 <etext+0x658>
    8000239e:	95cfe0ef          	jal	800004fa <printf>
      p->memfull_logged = 1;  // Only log once per process
    800023a2:	67ad                	lui	a5,0xb
    800023a4:	97a6                	add	a5,a5,s1
    800023a6:	4705                	li	a4,1
    800023a8:	cae7a423          	sw	a4,-856(a5) # aca8 <_entry-0x7fff5358>
    800023ac:	bff1                	j	80002388 <load_executable_page+0xfe>
    mem = kalloc();
    800023ae:	f9afe0ef          	jal	80000b48 <kalloc>
    800023b2:	8aaa                	mv	s5,a0
    if(mem == 0) {
    800023b4:	f91d                	bnez	a0,800022ea <load_executable_page+0x60>
      return 0;
    800023b6:	4a01                	li	s4,0
    800023b8:	6ae2                	ld	s5,24(sp)
    800023ba:	b77d                	j	80002368 <load_executable_page+0xde>
      kfree(mem);
    800023bc:	8556                	mv	a0,s5
    800023be:	e9efe0ef          	jal	80000a5c <kfree>
      return 0;
    800023c2:	4a01                	li	s4,0
    800023c4:	6ae2                	ld	s5,24(sp)
    800023c6:	b74d                	j	80002368 <load_executable_page+0xde>
    kfree(mem);
    800023c8:	8556                	mv	a0,s5
    800023ca:	e92fe0ef          	jal	80000a5c <kfree>
    return 0;
    800023ce:	4a01                	li	s4,0
    800023d0:	6ae2                	ld	s5,24(sp)
    800023d2:	bf59                	j	80002368 <load_executable_page+0xde>

00000000800023d4 <swap_in_page>:

//Read a page from swap
int
swap_in_page(uint64 va, char *mem, int *was_dirty)
{
    800023d4:	715d                	addi	sp,sp,-80
    800023d6:	e486                	sd	ra,72(sp)
    800023d8:	e0a2                	sd	s0,64(sp)
    800023da:	fc26                	sd	s1,56(sp)
    800023dc:	f84a                	sd	s2,48(sp)
    800023de:	f44e                	sd	s3,40(sp)
    800023e0:	f052                	sd	s4,32(sp)
    800023e2:	0880                	addi	s0,sp,80
    800023e4:	84aa                	mv	s1,a0
    800023e6:	89ae                	mv	s3,a1
    800023e8:	8a32                	mv	s4,a2
  struct proc *p = myproc();
    800023ea:	25b000ef          	jal	80002e44 <myproc>
    800023ee:	892a                	mv	s2,a0
  
  //Find the swapped page
  int slot = -1;
  *was_dirty = 0; //Default to clean
    800023f0:	000a2023          	sw	zero,0(s4) # 1000 <_entry-0x7ffff000>
  for(int i = 0; i < MAX_SWAP_PAGES; i++) 
    800023f4:	7ff50793          	addi	a5,a0,2047
    800023f8:	44978793          	addi	a5,a5,1097
    800023fc:	4701                	li	a4,0
    800023fe:	40000813          	li	a6,1024
    80002402:	a031                	j	8000240e <swap_in_page+0x3a>
    80002404:	2705                	addiw	a4,a4,1
    80002406:	02878793          	addi	a5,a5,40
    8000240a:	0f070563          	beq	a4,a6,800024f4 <swap_in_page+0x120>
  {
    if(p->swapped_pages[i].in_use && p->swapped_pages[i].va == va) 
    8000240e:	4bd4                	lw	a3,20(a5)
    80002410:	daf5                	beqz	a3,80002404 <swap_in_page+0x30>
    80002412:	6394                	ld	a3,0(a5)
    80002414:	fe9698e3          	bne	a3,s1,80002404 <swap_in_page+0x30>
    80002418:	ec56                	sd	s5,24(sp)
    {
      slot = p->swapped_pages[i].swap_slot;
    8000241a:	00271793          	slli	a5,a4,0x2
    8000241e:	00e786b3          	add	a3,a5,a4
    80002422:	068e                	slli	a3,a3,0x3
    80002424:	96ca                	add	a3,a3,s2
    80002426:	6605                	lui	a2,0x1
    80002428:	96b2                	add	a3,a3,a2
    8000242a:	c586aa83          	lw	s5,-936(a3)
      *was_dirty = p->swapped_pages[i].is_dirty; //Restore dirty status
    8000242e:	c546a683          	lw	a3,-940(a3)
    80002432:	00da2023          	sw	a3,0(s4)
      //Remove from swapped pages list
      p->swapped_pages[i].in_use = 0;
    80002436:	97ba                	add	a5,a5,a4
    80002438:	078e                	slli	a5,a5,0x3
    8000243a:	97ca                	add	a5,a5,s2
    8000243c:	963e                	add	a2,a2,a5
    8000243e:	c4062e23          	sw	zero,-932(a2) # c5c <_entry-0x7ffff3a4>
      p->num_swapped_pages--;
    80002442:	67ad                	lui	a5,0xb
    80002444:	97ca                	add	a5,a5,s2
    80002446:	c487a703          	lw	a4,-952(a5) # ac48 <_entry-0x7fff53b8>
    8000244a:	377d                	addiw	a4,a4,-1
    8000244c:	c4e7a423          	sw	a4,-952(a5)
      break;
    }
  }
  
  if(slot < 0) 
    80002450:	0e0ac763          	bltz	s5,8000253e <swap_in_page+0x16a>
  {
    return -1; // Page not found in swap
  }
  
  // Check if swap file is valid
  if(p->swapfile == 0) {
    80002454:	7ff90793          	addi	a5,s2,2047
    80002458:	3a97b783          	ld	a5,937(a5)
    8000245c:	cfd1                	beqz	a5,800024f8 <swap_in_page+0x124>
    printf("[pid %d] SWAPIN_ERROR: no swap file\n", p->pid);
    return -1;
  }
  
  // Read page from swap file
  begin_op();
    8000245e:	1f2030ef          	jal	80005650 <begin_op>
  
  // Double-check swap file is still valid after begin_op
  if(p->swapfile == 0) {
    80002462:	7ff90793          	addi	a5,s2,2047
    80002466:	3a97b503          	ld	a0,937(a5)
    8000246a:	c155                	beqz	a0,8000250e <swap_in_page+0x13a>
    printf("[pid %d] SWAPIN_ERROR: swap file disappeared\n", p->pid);
    end_op();
    return -1;
  }
  
  ilock(p->swapfile);
    8000246c:	7d8020ef          	jal	80004c44 <ilock>
  
  uint64 offset = slot * PGSIZE;
  if(readi(p->swapfile, 0, (uint64)mem, offset, PGSIZE) != PGSIZE) 
    80002470:	6a05                	lui	s4,0x1
    80002472:	014907b3          	add	a5,s2,s4
    80002476:	8752                	mv	a4,s4
    80002478:	00ca969b          	slliw	a3,s5,0xc
    8000247c:	864e                	mv	a2,s3
    8000247e:	4581                	li	a1,0
    80002480:	ba87b503          	ld	a0,-1112(a5)
    80002484:	353020ef          	jal	80004fd6 <readi>
    80002488:	0b451063          	bne	a0,s4,80002528 <swap_in_page+0x154>
    iunlock(p->swapfile);
    end_op();
    return -1;
  }
  
  iunlock(p->swapfile);
    8000248c:	7ff90793          	addi	a5,s2,2047
    80002490:	3a97b503          	ld	a0,937(a5)
    80002494:	05f020ef          	jal	80004cf2 <iunlock>
  end_op();
    80002498:	228030ef          	jal	800056c0 <end_op>
  
  // Debug: Log first integer value of read data
  int *intdata = (int*)mem;
  printf("[pid %d] SWAPIN_DATA va=0x%lx slot=%d first_int=%d (bytes=%d,%d,%d,%d)\n", 
    8000249c:	03092583          	lw	a1,48(s2)
    800024a0:	0039c783          	lbu	a5,3(s3)
    800024a4:	e03e                	sd	a5,0(sp)
    800024a6:	0029c883          	lbu	a7,2(s3)
    800024aa:	0019c803          	lbu	a6,1(s3)
    800024ae:	0009c783          	lbu	a5,0(s3)
    800024b2:	0009a703          	lw	a4,0(s3)
    800024b6:	86d6                	mv	a3,s5
    800024b8:	8626                	mv	a2,s1
    800024ba:	00007517          	auipc	a0,0x7
    800024be:	2ae50513          	addi	a0,a0,686 # 80009768 <etext+0x768>
    800024c2:	838fe0ef          	jal	800004fa <printf>
         p->pid, va, slot, *intdata,
         ((char*)mem)[0] & 0xFF, ((char*)mem)[1] & 0xFF, 
         ((char*)mem)[2] & 0xFF, ((char*)mem)[3] & 0xFF);
  
  // Free the swap slot since page is now in memory
  free_swap_slot(slot);
    800024c6:	8556                	mv	a0,s5
    800024c8:	d78ff0ef          	jal	80001a40 <free_swap_slot>
  
  printf("[pid %d] SWAPIN va=0x%lx slot=%d\n", p->pid, va, slot);
    800024cc:	86d6                	mv	a3,s5
    800024ce:	8626                	mv	a2,s1
    800024d0:	03092583          	lw	a1,48(s2)
    800024d4:	00007517          	auipc	a0,0x7
    800024d8:	2dc50513          	addi	a0,a0,732 # 800097b0 <etext+0x7b0>
    800024dc:	81efe0ef          	jal	800004fa <printf>
  return 0;
    800024e0:	4501                	li	a0,0
    800024e2:	6ae2                	ld	s5,24(sp)
}
    800024e4:	60a6                	ld	ra,72(sp)
    800024e6:	6406                	ld	s0,64(sp)
    800024e8:	74e2                	ld	s1,56(sp)
    800024ea:	7942                	ld	s2,48(sp)
    800024ec:	79a2                	ld	s3,40(sp)
    800024ee:	7a02                	ld	s4,32(sp)
    800024f0:	6161                	addi	sp,sp,80
    800024f2:	8082                	ret
    return -1; // Page not found in swap
    800024f4:	557d                	li	a0,-1
    800024f6:	b7fd                	j	800024e4 <swap_in_page+0x110>
    printf("[pid %d] SWAPIN_ERROR: no swap file\n", p->pid);
    800024f8:	03092583          	lw	a1,48(s2)
    800024fc:	00007517          	auipc	a0,0x7
    80002500:	21450513          	addi	a0,a0,532 # 80009710 <etext+0x710>
    80002504:	ff7fd0ef          	jal	800004fa <printf>
    return -1;
    80002508:	557d                	li	a0,-1
    8000250a:	6ae2                	ld	s5,24(sp)
    8000250c:	bfe1                	j	800024e4 <swap_in_page+0x110>
    printf("[pid %d] SWAPIN_ERROR: swap file disappeared\n", p->pid);
    8000250e:	03092583          	lw	a1,48(s2)
    80002512:	00007517          	auipc	a0,0x7
    80002516:	22650513          	addi	a0,a0,550 # 80009738 <etext+0x738>
    8000251a:	fe1fd0ef          	jal	800004fa <printf>
    end_op();
    8000251e:	1a2030ef          	jal	800056c0 <end_op>
    return -1;
    80002522:	557d                	li	a0,-1
    80002524:	6ae2                	ld	s5,24(sp)
    80002526:	bf7d                	j	800024e4 <swap_in_page+0x110>
    iunlock(p->swapfile);
    80002528:	7ff90913          	addi	s2,s2,2047
    8000252c:	3a993503          	ld	a0,937(s2)
    80002530:	7c2020ef          	jal	80004cf2 <iunlock>
    end_op();
    80002534:	18c030ef          	jal	800056c0 <end_op>
    return -1;
    80002538:	557d                	li	a0,-1
    8000253a:	6ae2                	ld	s5,24(sp)
    8000253c:	b765                	j	800024e4 <swap_in_page+0x110>
    return -1; // Page not found in swap
    8000253e:	557d                	li	a0,-1
    80002540:	6ae2                	ld	s5,24(sp)
    80002542:	b74d                	j	800024e4 <swap_in_page+0x110>

0000000080002544 <is_swapped>:

// Check if a page is swapped
int
is_swapped(uint64 va)
{
    80002544:	1101                	addi	sp,sp,-32
    80002546:	ec06                	sd	ra,24(sp)
    80002548:	e822                	sd	s0,16(sp)
    8000254a:	e426                	sd	s1,8(sp)
    8000254c:	1000                	addi	s0,sp,32
    8000254e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002550:	0f5000ef          	jal	80002e44 <myproc>
  
  for(int i = 0; i < MAX_SWAP_PAGES; i++) {
    80002554:	7ff50793          	addi	a5,a0,2047
    80002558:	44978793          	addi	a5,a5,1097
    8000255c:	672d                	lui	a4,0xb
    8000255e:	c4870713          	addi	a4,a4,-952 # ac48 <_entry-0x7fff53b8>
    80002562:	00e506b3          	add	a3,a0,a4
    80002566:	a029                	j	80002570 <is_swapped+0x2c>
    80002568:	02878793          	addi	a5,a5,40
    8000256c:	00d78d63          	beq	a5,a3,80002586 <is_swapped+0x42>
    if(p->swapped_pages[i].in_use && p->swapped_pages[i].va == va) {
    80002570:	4bd8                	lw	a4,20(a5)
    80002572:	db7d                	beqz	a4,80002568 <is_swapped+0x24>
    80002574:	6398                	ld	a4,0(a5)
    80002576:	fe9719e3          	bne	a4,s1,80002568 <is_swapped+0x24>
      return 1;
    8000257a:	4505                	li	a0,1
    }
  }
  return 0;
}
    8000257c:	60e2                	ld	ra,24(sp)
    8000257e:	6442                	ld	s0,16(sp)
    80002580:	64a2                	ld	s1,8(sp)
    80002582:	6105                	addi	sp,sp,32
    80002584:	8082                	ret
  return 0;
    80002586:	4501                	li	a0,0
    80002588:	bfd5                	j	8000257c <is_swapped+0x38>

000000008000258a <vmfault>:
{
    8000258a:	715d                	addi	sp,sp,-80
    8000258c:	e486                	sd	ra,72(sp)
    8000258e:	e0a2                	sd	s0,64(sp)
    80002590:	fc26                	sd	s1,56(sp)
    80002592:	f84a                	sd	s2,48(sp)
    80002594:	f44e                	sd	s3,40(sp)
    80002596:	f052                	sd	s4,32(sp)
    80002598:	ec56                	sd	s5,24(sp)
    8000259a:	0880                	addi	s0,sp,80
    8000259c:	8aaa                	mv	s5,a0
    8000259e:	892e                	mv	s2,a1
    800025a0:	8a32                	mv	s4,a2
  struct proc *p = myproc();
    800025a2:	0a3000ef          	jal	80002e44 <myproc>
    800025a6:	84aa                	mv	s1,a0
  p->page_fault_count++;
    800025a8:	6705                	lui	a4,0x1
    800025aa:	972a                	add	a4,a4,a0
    800025ac:	ba472783          	lw	a5,-1116(a4) # ba4 <_entry-0x7ffff45c>
    800025b0:	0017861b          	addiw	a2,a5,1
    800025b4:	85b2                	mv	a1,a2
    800025b6:	bac72223          	sw	a2,-1116(a4)
  int fault_limit = (p->sz == 0) ? 20 : 1000;
    800025ba:	6534                	ld	a3,72(a0)
    800025bc:	3e800793          	li	a5,1000
    800025c0:	e291                	bnez	a3,800025c4 <vmfault+0x3a>
    800025c2:	47d1                	li	a5,20
  if(p->page_fault_count > fault_limit) {
    800025c4:	08b7c763          	blt	a5,a1,80002652 <vmfault+0xc8>
  if(va >= MAXVA) {
    800025c8:	57fd                	li	a5,-1
    800025ca:	83e9                	srli	a5,a5,0x1a
    800025cc:	0927ef63          	bltu	a5,s2,8000266a <vmfault+0xe0>
    800025d0:	e85a                	sd	s6,16(sp)
  uint64 page_va = PGROUNDDOWN(va);
    800025d2:	77fd                	lui	a5,0xfffff
    800025d4:	00f97933          	and	s2,s2,a5
    access_type = "read"; 
    800025d8:	00007797          	auipc	a5,0x7
    800025dc:	6f078793          	addi	a5,a5,1776 # 80009cc8 <etext+0xcc8>
    800025e0:	8b3e                	mv	s6,a5
  if(is_write) {
    800025e2:	000a0763          	beqz	s4,800025f0 <vmfault+0x66>
    access_type = "write";
    800025e6:	00007797          	auipc	a5,0x7
    800025ea:	1f278793          	addi	a5,a5,498 # 800097d8 <etext+0x7d8>
    800025ee:	8b3e                	mv	s6,a5
  if(ismapped(pagetable, page_va)) {
    800025f0:	85ca                	mv	a1,s2
    800025f2:	8556                	mv	a0,s5
    800025f4:	9daff0ef          	jal	800017ce <ismapped>
    return 0; // Already mapped, not a valid fault
    800025f8:	4981                	li	s3,0
  if(ismapped(pagetable, page_va)) {
    800025fa:	28051163          	bnez	a0,8000287c <vmfault+0x2f2>
  if(page_va >= p->text_start && page_va < p->text_end) {
    800025fe:	1684b783          	ld	a5,360(s1)
    80002602:	00f96663          	bltu	s2,a5,8000260e <vmfault+0x84>
    80002606:	1704b783          	ld	a5,368(s1)
    8000260a:	1cf96563          	bltu	s2,a5,800027d4 <vmfault+0x24a>
  else if(page_va >= p->data_start && page_va < p->data_end) {
    8000260e:	1784b783          	ld	a5,376(s1)
    80002612:	00f96663          	bltu	s2,a5,8000261e <vmfault+0x94>
    80002616:	1804b783          	ld	a5,384(s1)
    8000261a:	1af96d63          	bltu	s2,a5,800027d4 <vmfault+0x24a>
  else if(p->trapframe && page_va >= PGROUNDDOWN(p->trapframe->sp) - PGSIZE && 
    8000261e:	6cbc                	ld	a5,88(s1)
    80002620:	c7c9                	beqz	a5,800026aa <vmfault+0x120>
    80002622:	7b98                	ld	a4,48(a5)
    80002624:	77fd                	lui	a5,0xfffff
    80002626:	00f776b3          	and	a3,a4,a5
    8000262a:	97b6                	add	a5,a5,a3
    8000262c:	06f96f63          	bltu	s2,a5,800026aa <vmfault+0x120>
          page_va < PGROUNDUP(p->trapframe->sp)) {
    80002630:	6785                	lui	a5,0x1
    80002632:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80002634:	973e                	add	a4,a4,a5
    80002636:	77fd                	lui	a5,0xfffff
    80002638:	8f7d                	and	a4,a4,a5
  else if(p->trapframe && page_va >= PGROUNDDOWN(p->trapframe->sp) - PGSIZE && 
    8000263a:	06e97863          	bgeu	s2,a4,800026aa <vmfault+0x120>
    if(page_va < sp_page && page_va < p->sz) {
    8000263e:	20d97463          	bgeu	s2,a3,80002846 <vmfault+0x2bc>
    80002642:	64bc                	ld	a5,72(s1)
      cause = "stack";
    80002644:	00007717          	auipc	a4,0x7
    80002648:	1a470713          	addi	a4,a4,420 # 800097e8 <etext+0x7e8>
    if(page_va < sp_page && page_va < p->sz) {
    8000264c:	20f97163          	bgeu	s2,a5,8000284e <vmfault+0x2c4>
    80002650:	a0ad                	j	800026ba <vmfault+0x130>
    printf("[pid %d] KILL excessive page faults (count=%d, sz=0x%lx)\n", 
    80002652:	588c                	lw	a1,48(s1)
    80002654:	00007517          	auipc	a0,0x7
    80002658:	19c50513          	addi	a0,a0,412 # 800097f0 <etext+0x7f0>
    8000265c:	e9ffd0ef          	jal	800004fa <printf>
    setkilled(p);
    80002660:	8526                	mv	a0,s1
    80002662:	208010ef          	jal	8000386a <setkilled>
    return 0;
    80002666:	4981                	li	s3,0
    80002668:	a03d                	j	80002696 <vmfault+0x10c>
    printf("[pid %d] KILL invalid-access va=0x%lx access=%s\n", 
    8000266a:	588c                	lw	a1,48(s1)
    8000266c:	00007697          	auipc	a3,0x7
    80002670:	65c68693          	addi	a3,a3,1628 # 80009cc8 <etext+0xcc8>
    80002674:	000a0663          	beqz	s4,80002680 <vmfault+0xf6>
    80002678:	00007697          	auipc	a3,0x7
    8000267c:	16068693          	addi	a3,a3,352 # 800097d8 <etext+0x7d8>
    80002680:	864a                	mv	a2,s2
    80002682:	00007517          	auipc	a0,0x7
    80002686:	1ae50513          	addi	a0,a0,430 # 80009830 <etext+0x830>
    8000268a:	e71fd0ef          	jal	800004fa <printf>
    setkilled(p);
    8000268e:	8526                	mv	a0,s1
    80002690:	1da010ef          	jal	8000386a <setkilled>
    return 0;
    80002694:	4981                	li	s3,0
}
    80002696:	854e                	mv	a0,s3
    80002698:	60a6                	ld	ra,72(sp)
    8000269a:	6406                	ld	s0,64(sp)
    8000269c:	74e2                	ld	s1,56(sp)
    8000269e:	7942                	ld	s2,48(sp)
    800026a0:	79a2                	ld	s3,40(sp)
    800026a2:	7a02                	ld	s4,32(sp)
    800026a4:	6ae2                	ld	s5,24(sp)
    800026a6:	6161                	addi	sp,sp,80
    800026a8:	8082                	ret
  else if(p->sz > 0 && page_va >= p->heap_start && page_va < p->sz) {
    800026aa:	64bc                	ld	a5,72(s1)
    800026ac:	c799                	beqz	a5,800026ba <vmfault+0x130>
    800026ae:	1884b703          	ld	a4,392(s1)
    800026b2:	00e96463          	bltu	s2,a4,800026ba <vmfault+0x130>
    800026b6:	04f96363          	bltu	s2,a5,800026fc <vmfault+0x172>
  printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=%s\n", 
    800026ba:	00007717          	auipc	a4,0x7
    800026be:	1ae70713          	addi	a4,a4,430 # 80009868 <etext+0x868>
    800026c2:	86da                	mv	a3,s6
    800026c4:	864a                	mv	a2,s2
    800026c6:	588c                	lw	a1,48(s1)
    800026c8:	00007517          	auipc	a0,0x7
    800026cc:	1a850513          	addi	a0,a0,424 # 80009870 <etext+0x870>
    800026d0:	e2bfd0ef          	jal	800004fa <printf>
  if(is_swapped(page_va)) 
    800026d4:	854a                	mv	a0,s2
    800026d6:	e6fff0ef          	jal	80002544 <is_swapped>
    800026da:	10051e63          	bnez	a0,800027f6 <vmfault+0x26c>
    printf("[pid %d] KILL invalid-access va=0x%lx access=%s\n",
    800026de:	86da                	mv	a3,s6
    800026e0:	864a                	mv	a2,s2
    800026e2:	588c                	lw	a1,48(s1)
    800026e4:	00007517          	auipc	a0,0x7
    800026e8:	14c50513          	addi	a0,a0,332 # 80009830 <etext+0x830>
    800026ec:	e0ffd0ef          	jal	800004fa <printf>
    setkilled(p);
    800026f0:	8526                	mv	a0,s1
    800026f2:	178010ef          	jal	8000386a <setkilled>
    return 0;
    800026f6:	4981                	li	s3,0
    800026f8:	6b42                	ld	s6,16(sp)
    800026fa:	bf71                	j	80002696 <vmfault+0x10c>
    if(p->sz == p->stack_top && page_va >= p->sz - 2*PGSIZE) {
    800026fc:	1904b683          	ld	a3,400(s1)
      cause = "heap";
    80002700:	00007717          	auipc	a4,0x7
    80002704:	0e070713          	addi	a4,a4,224 # 800097e0 <etext+0x7e0>
    if(p->sz == p->stack_top && page_va >= p->sz - 2*PGSIZE) {
    80002708:	14d79363          	bne	a5,a3,8000284e <vmfault+0x2c4>
    8000270c:	7779                	lui	a4,0xffffe
    8000270e:	97ba                	add	a5,a5,a4
      cause = "heap";
    80002710:	00007717          	auipc	a4,0x7
    80002714:	0d070713          	addi	a4,a4,208 # 800097e0 <etext+0x7e0>
    if(p->sz == p->stack_top && page_va >= p->sz - 2*PGSIZE) {
    80002718:	12f96b63          	bltu	s2,a5,8000284e <vmfault+0x2c4>
    8000271c:	bf79                	j	800026ba <vmfault+0x130>
      if(!p->memfull_logged) 
    8000271e:	67ad                	lui	a5,0xb
    80002720:	97a6                	add	a5,a5,s1
    80002722:	ca87a783          	lw	a5,-856(a5) # aca8 <_entry-0x7fff5358>
    80002726:	c799                	beqz	a5,80002734 <vmfault+0x1aa>
      if(evict_page_adaptive() == 0)
    80002728:	8e3ff0ef          	jal	8000200a <evict_page_adaptive>
        return 0; // Could not evict
    8000272c:	4981                	li	s3,0
      if(evict_page_adaptive() == 0)
    8000272e:	e105                	bnez	a0,8000274e <vmfault+0x1c4>
    80002730:	6b42                	ld	s6,16(sp)
    80002732:	b795                	j	80002696 <vmfault+0x10c>
        printf("[pid %d] MEMFULL\n", p->pid);
    80002734:	588c                	lw	a1,48(s1)
    80002736:	00007517          	auipc	a0,0x7
    8000273a:	f2250513          	addi	a0,a0,-222 # 80009658 <etext+0x658>
    8000273e:	dbdfd0ef          	jal	800004fa <printf>
        p->memfull_logged = 1;
    80002742:	67ad                	lui	a5,0xb
    80002744:	97a6                	add	a5,a5,s1
    80002746:	4705                	li	a4,1
    80002748:	cae7a423          	sw	a4,-856(a5) # aca8 <_entry-0x7fff5358>
    8000274c:	bff1                	j	80002728 <vmfault+0x19e>
      mem = kalloc();
    8000274e:	bfafe0ef          	jal	80000b48 <kalloc>
    80002752:	89aa                	mv	s3,a0
      if(mem == 0) 
    80002754:	e555                	bnez	a0,80002800 <vmfault+0x276>
        return 0;
    80002756:	4981                	li	s3,0
    80002758:	6b42                	ld	s6,16(sp)
    8000275a:	bf35                	j	80002696 <vmfault+0x10c>
      kfree(mem);
    8000275c:	854e                	mv	a0,s3
    8000275e:	afefe0ef          	jal	80000a5c <kfree>
      return 0;
    80002762:	4981                	li	s3,0
    80002764:	6b42                	ld	s6,16(sp)
    80002766:	bf05                	j	80002696 <vmfault+0x10c>
    int perm = PTE_R | PTE_U;
    80002768:	4749                	li	a4,18
    if(page_va >= p->text_start && page_va < p->text_end) {
    8000276a:	1684b783          	ld	a5,360(s1)
    8000276e:	00f96863          	bltu	s2,a5,8000277e <vmfault+0x1f4>
    80002772:	1704b783          	ld	a5,368(s1)
    80002776:	00f97463          	bgeu	s2,a5,8000277e <vmfault+0x1f4>
      perm |= PTE_X; // Text is executable
    8000277a:	00876713          	ori	a4,a4,8
    if(mappages(pagetable, page_va, PGSIZE, (uint64)mem, perm) != 0) {
    8000277e:	86ce                	mv	a3,s3
    80002780:	6605                	lui	a2,0x1
    80002782:	85ca                	mv	a1,s2
    80002784:	8556                	mv	a0,s5
    80002786:	8dffe0ef          	jal	80001064 <mappages>
    8000278a:	c519                	beqz	a0,80002798 <vmfault+0x20e>
      kfree(mem);
    8000278c:	854e                	mv	a0,s3
    8000278e:	acefe0ef          	jal	80000a5c <kfree>
      return 0;
    80002792:	4981                	li	s3,0
    80002794:	6b42                	ld	s6,16(sp)
    80002796:	b701                	j	80002696 <vmfault+0x10c>
    int final_dirty = was_dirty || is_write; // Dirty if was dirty OR current write
    80002798:	fbc42583          	lw	a1,-68(s0)
    8000279c:	00ba65b3          	or	a1,s4,a1
    add_resident_page(page_va, final_dirty);
    800027a0:	00b035b3          	snez	a1,a1
    800027a4:	854a                	mv	a0,s2
    800027a6:	88dff0ef          	jal	80002032 <add_resident_page>
    return (uint64)mem;
    800027aa:	6b42                	ld	s6,16(sp)
    800027ac:	b5ed                	j	80002696 <vmfault+0x10c>
    mem = load_executable_page(pagetable, page_va, is_write);
    800027ae:	8652                	mv	a2,s4
    800027b0:	85ca                	mv	a1,s2
    800027b2:	8556                	mv	a0,s5
    800027b4:	ad7ff0ef          	jal	8000228a <load_executable_page>
    800027b8:	89aa                	mv	s3,a0
    800027ba:	a86d                	j	80002874 <vmfault+0x2ea>
    update_page_access(page_va);
    800027bc:	854a                	mv	a0,s2
    800027be:	f9dfe0ef          	jal	8000175a <update_page_access>
    800027c2:	6b42                	ld	s6,16(sp)
    800027c4:	bdc9                	j	80002696 <vmfault+0x10c>
    if((page_va >= p->heap_start && page_va < p->sz) || 
    800027c6:	1884b783          	ld	a5,392(s1)
    int perm = PTE_R | PTE_U;
    800027ca:	4749                	li	a4,18
    if((page_va >= p->heap_start && page_va < p->sz) || 
    800027cc:	f8f96fe3          	bltu	s2,a5,8000276a <vmfault+0x1e0>
    uint64 stack_limit = p->trapframe ? PGROUNDDOWN(p->trapframe->sp) - PGSIZE : 0;
    800027d0:	4781                	li	a5,0
    800027d2:	a881                	j	80002822 <vmfault+0x298>
  printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=%s\n", 
    800027d4:	00007717          	auipc	a4,0x7
    800027d8:	0cc70713          	addi	a4,a4,204 # 800098a0 <etext+0x8a0>
    800027dc:	86da                	mv	a3,s6
    800027de:	864a                	mv	a2,s2
    800027e0:	588c                	lw	a1,48(s1)
    800027e2:	00007517          	auipc	a0,0x7
    800027e6:	08e50513          	addi	a0,a0,142 # 80009870 <etext+0x870>
    800027ea:	d11fd0ef          	jal	800004fa <printf>
  if(is_swapped(page_va)) 
    800027ee:	854a                	mv	a0,s2
    800027f0:	d55ff0ef          	jal	80002544 <is_swapped>
    800027f4:	dd4d                	beqz	a0,800027ae <vmfault+0x224>
    char *mem = kalloc();
    800027f6:	b52fe0ef          	jal	80000b48 <kalloc>
    800027fa:	89aa                	mv	s3,a0
    if(mem == 0) {
    800027fc:	f20501e3          	beqz	a0,8000271e <vmfault+0x194>
    if(swap_in_page(page_va, mem, &was_dirty) != 0) {
    80002800:	fbc40613          	addi	a2,s0,-68
    80002804:	85ce                	mv	a1,s3
    80002806:	854a                	mv	a0,s2
    80002808:	bcdff0ef          	jal	800023d4 <swap_in_page>
    8000280c:	f921                	bnez	a0,8000275c <vmfault+0x1d2>
    uint64 stack_limit = p->trapframe ? PGROUNDDOWN(p->trapframe->sp) - PGSIZE : 0;
    8000280e:	6cb4                	ld	a3,88(s1)
    80002810:	dadd                	beqz	a3,800027c6 <vmfault+0x23c>
    80002812:	7a9c                	ld	a5,48(a3)
    80002814:	777d                	lui	a4,0xfffff
    80002816:	8ff9                	and	a5,a5,a4
    80002818:	97ba                	add	a5,a5,a4
    if((page_va >= p->heap_start && page_va < p->sz) || 
    8000281a:	1884b703          	ld	a4,392(s1)
    8000281e:	00e96663          	bltu	s2,a4,8000282a <vmfault+0x2a0>
    80002822:	64b0                	ld	a2,72(s1)
      perm |= PTE_W; // Heap and stack are writable
    80002824:	4759                	li	a4,22
    if((page_va >= p->heap_start && page_va < p->sz) || 
    80002826:	f4c962e3          	bltu	s2,a2,8000276a <vmfault+0x1e0>
       (p->trapframe && page_va >= stack_limit && page_va < PGROUNDUP(p->trapframe->sp))) {
    8000282a:	f2f96fe3          	bltu	s2,a5,80002768 <vmfault+0x1de>
    8000282e:	de8d                	beqz	a3,80002768 <vmfault+0x1de>
    80002830:	7a9c                	ld	a5,48(a3)
    80002832:	6705                	lui	a4,0x1
    80002834:	177d                	addi	a4,a4,-1 # fff <_entry-0x7ffff001>
    80002836:	97ba                	add	a5,a5,a4
    80002838:	777d                	lui	a4,0xfffff
    8000283a:	8ff9                	and	a5,a5,a4
      perm |= PTE_W; // Heap and stack are writable
    8000283c:	4759                	li	a4,22
       (p->trapframe && page_va >= stack_limit && page_va < PGROUNDUP(p->trapframe->sp))) {
    8000283e:	f2f966e3          	bltu	s2,a5,8000276a <vmfault+0x1e0>
    int perm = PTE_R | PTE_U;
    80002842:	4749                	li	a4,18
    80002844:	b71d                	j	8000276a <vmfault+0x1e0>
      cause = "stack";
    80002846:	00007717          	auipc	a4,0x7
    8000284a:	fa270713          	addi	a4,a4,-94 # 800097e8 <etext+0x7e8>
  printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=%s\n", 
    8000284e:	86da                	mv	a3,s6
    80002850:	864a                	mv	a2,s2
    80002852:	588c                	lw	a1,48(s1)
    80002854:	00007517          	auipc	a0,0x7
    80002858:	01c50513          	addi	a0,a0,28 # 80009870 <etext+0x870>
    8000285c:	c9ffd0ef          	jal	800004fa <printf>
  if(is_swapped(page_va)) 
    80002860:	854a                	mv	a0,s2
    80002862:	ce3ff0ef          	jal	80002544 <is_swapped>
    80002866:	f941                	bnez	a0,800027f6 <vmfault+0x26c>
    mem = allocate_zero_page(pagetable, page_va, is_write);
    80002868:	8652                	mv	a2,s4
    8000286a:	85ca                	mv	a1,s2
    8000286c:	8556                	mv	a0,s5
    8000286e:	901ff0ef          	jal	8000216e <allocate_zero_page>
    80002872:	89aa                	mv	s3,a0
  if(mem != 0) {
    80002874:	f40994e3          	bnez	s3,800027bc <vmfault+0x232>
    80002878:	6b42                	ld	s6,16(sp)
    8000287a:	bd31                	j	80002696 <vmfault+0x10c>
    8000287c:	6b42                	ld	s6,16(sp)
    8000287e:	bd21                	j	80002696 <vmfault+0x10c>

0000000080002880 <copyout>:
{
    80002880:	7159                	addi	sp,sp,-112
    80002882:	f486                	sd	ra,104(sp)
    80002884:	f0a2                	sd	s0,96(sp)
    80002886:	e0d2                	sd	s4,64(sp)
    80002888:	fc56                	sd	s5,56(sp)
    8000288a:	f45e                	sd	s7,40(sp)
    8000288c:	f062                	sd	s8,32(sp)
    8000288e:	1880                	addi	s0,sp,112
    80002890:	8c2a                	mv	s8,a0
    80002892:	8a2e                	mv	s4,a1
    80002894:	8bb2                	mv	s7,a2
    80002896:	8ab6                	mv	s5,a3
  struct proc *p = myproc();
    80002898:	5ac000ef          	jal	80002e44 <myproc>
  while(len > 0){
    8000289c:	0e0a8d63          	beqz	s5,80002996 <copyout+0x116>
    800028a0:	eca6                	sd	s1,88(sp)
    800028a2:	e8ca                	sd	s2,80(sp)
    800028a4:	e4ce                	sd	s3,72(sp)
    800028a6:	f85a                	sd	s6,48(sp)
    800028a8:	ec66                	sd	s9,24(sp)
    800028aa:	e86a                	sd	s10,16(sp)
    800028ac:	e46e                	sd	s11,8(sp)
    800028ae:	8b2a                	mv	s6,a0
    va0 = PGROUNDDOWN(dstva);
    800028b0:	7cfd                	lui	s9,0xfffff
    if(va0 >= 0x40000000UL) {
    800028b2:	40000db7          	lui	s11,0x40000
    n = PGSIZE - (dstva - va0);
    800028b6:	6d05                	lui	s10,0x1
    800028b8:	a8b1                	j	80002914 <copyout+0x94>
           is_swapped(va0)) {
    800028ba:	8526                	mv	a0,s1
    800028bc:	c89ff0ef          	jal	80002544 <is_swapped>
           (p->trapframe && va0 >= stack_limit && va0 < PGROUNDUP(p->trapframe->sp)) ||
    800028c0:	10050663          	beqz	a0,800029cc <copyout+0x14c>
      pa0 = vmfault(pagetable, va0, 1);  // vmfault returns physical address
    800028c4:	4605                	li	a2,1
    800028c6:	85a6                	mv	a1,s1
    800028c8:	8562                	mv	a0,s8
    800028ca:	cc1ff0ef          	jal	8000258a <vmfault>
    800028ce:	892a                	mv	s2,a0
      if(pa0 == 0) {
    800028d0:	10050763          	beqz	a0,800029de <copyout+0x15e>
    pte = walk(pagetable, va0, 0);
    800028d4:	4601                	li	a2,0
    800028d6:	85a6                	mv	a1,s1
    800028d8:	8562                	mv	a0,s8
    800028da:	eb6fe0ef          	jal	80000f90 <walk>
    if(pte == 0) {
    800028de:	10050963          	beqz	a0,800029f0 <copyout+0x170>
    if((*pte & PTE_W) == 0) {
    800028e2:	611c                	ld	a5,0(a0)
    800028e4:	8b91                	andi	a5,a5,4
    800028e6:	10078e63          	beqz	a5,80002a02 <copyout+0x182>
    n = PGSIZE - (dstva - va0);
    800028ea:	414489b3          	sub	s3,s1,s4
    800028ee:	99ea                	add	s3,s3,s10
    if(n > len)
    800028f0:	013af363          	bgeu	s5,s3,800028f6 <copyout+0x76>
    800028f4:	89d6                	mv	s3,s5
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800028f6:	409a0533          	sub	a0,s4,s1
    800028fa:	0009861b          	sext.w	a2,s3
    800028fe:	85de                	mv	a1,s7
    80002900:	954a                	add	a0,a0,s2
    80002902:	c5afe0ef          	jal	80000d5c <memmove>
    len -= n;
    80002906:	413a8ab3          	sub	s5,s5,s3
    src += n;
    8000290a:	9bce                	add	s7,s7,s3
    dstva = va0 + PGSIZE;
    8000290c:	01a48a33          	add	s4,s1,s10
  while(len > 0){
    80002910:	060a8a63          	beqz	s5,80002984 <copyout+0x104>
    va0 = PGROUNDDOWN(dstva);
    80002914:	019a74b3          	and	s1,s4,s9
    if(va0 >= 0x40000000UL) {
    80002918:	09b4f163          	bgeu	s1,s11,8000299a <copyout+0x11a>
    pa0 = walkaddr(pagetable, va0);
    8000291c:	85a6                	mv	a1,s1
    8000291e:	8562                	mv	a0,s8
    80002920:	f0afe0ef          	jal	8000102a <walkaddr>
    80002924:	892a                	mv	s2,a0
    if(pa0 == 0) {
    80002926:	f55d                	bnez	a0,800028d4 <copyout+0x54>
      if(p) {
    80002928:	080b0963          	beqz	s6,800029ba <copyout+0x13a>
        uint64 stack_limit = p->trapframe ? PGROUNDDOWN(p->trapframe->sp) - PGSIZE : 0;
    8000292c:	058b3783          	ld	a5,88(s6) # 1058 <_entry-0x7fffefa8>
    80002930:	c791                	beqz	a5,8000293c <copyout+0xbc>
    80002932:	0307b903          	ld	s2,48(a5)
    80002936:	01997933          	and	s2,s2,s9
    8000293a:	9966                	add	s2,s2,s9
        if((va0 >= p->text_start && va0 < p->text_end) ||
    8000293c:	168b3703          	ld	a4,360(s6)
    80002940:	00e4e663          	bltu	s1,a4,8000294c <copyout+0xcc>
    80002944:	170b3703          	ld	a4,368(s6)
    80002948:	f6e4eee3          	bltu	s1,a4,800028c4 <copyout+0x44>
    8000294c:	178b3703          	ld	a4,376(s6)
    80002950:	00e4e663          	bltu	s1,a4,8000295c <copyout+0xdc>
           (va0 >= p->data_start && va0 < p->data_end) ||
    80002954:	180b3703          	ld	a4,384(s6)
    80002958:	f6e4e6e3          	bltu	s1,a4,800028c4 <copyout+0x44>
    8000295c:	188b3703          	ld	a4,392(s6)
    80002960:	00e4e663          	bltu	s1,a4,8000296c <copyout+0xec>
           (va0 >= p->heap_start && va0 < p->sz) ||
    80002964:	048b3703          	ld	a4,72(s6)
    80002968:	f4e4eee3          	bltu	s1,a4,800028c4 <copyout+0x44>
           (p->trapframe && va0 >= stack_limit && va0 < PGROUNDUP(p->trapframe->sp)) ||
    8000296c:	f524e7e3          	bltu	s1,s2,800028ba <copyout+0x3a>
    80002970:	d7a9                	beqz	a5,800028ba <copyout+0x3a>
    80002972:	7b9c                	ld	a5,48(a5)
    80002974:	6705                	lui	a4,0x1
    80002976:	177d                	addi	a4,a4,-1 # fff <_entry-0x7ffff001>
    80002978:	97ba                	add	a5,a5,a4
    8000297a:	777d                	lui	a4,0xfffff
    8000297c:	8ff9                	and	a5,a5,a4
    8000297e:	f4f4e3e3          	bltu	s1,a5,800028c4 <copyout+0x44>
    80002982:	bf25                	j	800028ba <copyout+0x3a>
  return 0;
    80002984:	4501                	li	a0,0
    80002986:	64e6                	ld	s1,88(sp)
    80002988:	6946                	ld	s2,80(sp)
    8000298a:	69a6                	ld	s3,72(sp)
    8000298c:	7b42                	ld	s6,48(sp)
    8000298e:	6ce2                	ld	s9,24(sp)
    80002990:	6d42                	ld	s10,16(sp)
    80002992:	6da2                	ld	s11,8(sp)
    80002994:	a819                	j	800029aa <copyout+0x12a>
    80002996:	4501                	li	a0,0
    80002998:	a809                	j	800029aa <copyout+0x12a>
      return -1;
    8000299a:	557d                	li	a0,-1
    8000299c:	64e6                	ld	s1,88(sp)
    8000299e:	6946                	ld	s2,80(sp)
    800029a0:	69a6                	ld	s3,72(sp)
    800029a2:	7b42                	ld	s6,48(sp)
    800029a4:	6ce2                	ld	s9,24(sp)
    800029a6:	6d42                	ld	s10,16(sp)
    800029a8:	6da2                	ld	s11,8(sp)
}
    800029aa:	70a6                	ld	ra,104(sp)
    800029ac:	7406                	ld	s0,96(sp)
    800029ae:	6a06                	ld	s4,64(sp)
    800029b0:	7ae2                	ld	s5,56(sp)
    800029b2:	7ba2                	ld	s7,40(sp)
    800029b4:	7c02                	ld	s8,32(sp)
    800029b6:	6165                	addi	sp,sp,112
    800029b8:	8082                	ret
        return -1; // Don't try to fault in addresses outside valid regions
    800029ba:	557d                	li	a0,-1
    800029bc:	64e6                	ld	s1,88(sp)
    800029be:	6946                	ld	s2,80(sp)
    800029c0:	69a6                	ld	s3,72(sp)
    800029c2:	7b42                	ld	s6,48(sp)
    800029c4:	6ce2                	ld	s9,24(sp)
    800029c6:	6d42                	ld	s10,16(sp)
    800029c8:	6da2                	ld	s11,8(sp)
    800029ca:	b7c5                	j	800029aa <copyout+0x12a>
    800029cc:	557d                	li	a0,-1
    800029ce:	64e6                	ld	s1,88(sp)
    800029d0:	6946                	ld	s2,80(sp)
    800029d2:	69a6                	ld	s3,72(sp)
    800029d4:	7b42                	ld	s6,48(sp)
    800029d6:	6ce2                	ld	s9,24(sp)
    800029d8:	6d42                	ld	s10,16(sp)
    800029da:	6da2                	ld	s11,8(sp)
    800029dc:	b7f9                	j	800029aa <copyout+0x12a>
        return -1;
    800029de:	557d                	li	a0,-1
    800029e0:	64e6                	ld	s1,88(sp)
    800029e2:	6946                	ld	s2,80(sp)
    800029e4:	69a6                	ld	s3,72(sp)
    800029e6:	7b42                	ld	s6,48(sp)
    800029e8:	6ce2                	ld	s9,24(sp)
    800029ea:	6d42                	ld	s10,16(sp)
    800029ec:	6da2                	ld	s11,8(sp)
    800029ee:	bf75                	j	800029aa <copyout+0x12a>
      return -1;
    800029f0:	557d                	li	a0,-1
    800029f2:	64e6                	ld	s1,88(sp)
    800029f4:	6946                	ld	s2,80(sp)
    800029f6:	69a6                	ld	s3,72(sp)
    800029f8:	7b42                	ld	s6,48(sp)
    800029fa:	6ce2                	ld	s9,24(sp)
    800029fc:	6d42                	ld	s10,16(sp)
    800029fe:	6da2                	ld	s11,8(sp)
    80002a00:	b76d                	j	800029aa <copyout+0x12a>
      return -1;
    80002a02:	557d                	li	a0,-1
    80002a04:	64e6                	ld	s1,88(sp)
    80002a06:	6946                	ld	s2,80(sp)
    80002a08:	69a6                	ld	s3,72(sp)
    80002a0a:	7b42                	ld	s6,48(sp)
    80002a0c:	6ce2                	ld	s9,24(sp)
    80002a0e:	6d42                	ld	s10,16(sp)
    80002a10:	6da2                	ld	s11,8(sp)
    80002a12:	bf61                	j	800029aa <copyout+0x12a>

0000000080002a14 <copyin>:
{
    80002a14:	7159                	addi	sp,sp,-112
    80002a16:	f486                	sd	ra,104(sp)
    80002a18:	f0a2                	sd	s0,96(sp)
    80002a1a:	e4ce                	sd	s3,72(sp)
    80002a1c:	e0d2                	sd	s4,64(sp)
    80002a1e:	f85a                	sd	s6,48(sp)
    80002a20:	ec66                	sd	s9,24(sp)
    80002a22:	1880                	addi	s0,sp,112
    80002a24:	8caa                	mv	s9,a0
    80002a26:	8b2e                	mv	s6,a1
    80002a28:	89b2                	mv	s3,a2
    80002a2a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002a2c:	418000ef          	jal	80002e44 <myproc>
  while(len > 0){
    80002a30:	0c0a0d63          	beqz	s4,80002b0a <copyin+0xf6>
    80002a34:	eca6                	sd	s1,88(sp)
    80002a36:	e8ca                	sd	s2,80(sp)
    80002a38:	fc56                	sd	s5,56(sp)
    80002a3a:	f45e                	sd	s7,40(sp)
    80002a3c:	f062                	sd	s8,32(sp)
    80002a3e:	e86a                	sd	s10,16(sp)
    80002a40:	e46e                	sd	s11,8(sp)
    80002a42:	8aaa                	mv	s5,a0
    va0 = PGROUNDDOWN(srcva);
    80002a44:	7bfd                	lui	s7,0xfffff
    if(va0 >= 0x40000000UL) {
    80002a46:	40000d37          	lui	s10,0x40000
           (p->trapframe && va0 >= stack_limit && va0 < PGROUNDUP(p->trapframe->sp)) ||
    80002a4a:	6c05                	lui	s8,0x1
    80002a4c:	fffc0d93          	addi	s11,s8,-1 # fff <_entry-0x7ffff001>
    80002a50:	a081                	j	80002a90 <copyin+0x7c>
           is_swapped(va0)) {
    80002a52:	8526                	mv	a0,s1
    80002a54:	af1ff0ef          	jal	80002544 <is_swapped>
           (p->trapframe && va0 >= stack_limit && va0 < PGROUNDUP(p->trapframe->sp)) ||
    80002a58:	c565                	beqz	a0,80002b40 <copyin+0x12c>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80002a5a:	4601                	li	a2,0
    80002a5c:	85a6                	mv	a1,s1
    80002a5e:	8566                	mv	a0,s9
    80002a60:	b2bff0ef          	jal	8000258a <vmfault>
    80002a64:	c57d                	beqz	a0,80002b52 <copyin+0x13e>
    n = PGSIZE - (srcva - va0);
    80002a66:	41348933          	sub	s2,s1,s3
    80002a6a:	9962                	add	s2,s2,s8
    if(n > len)
    80002a6c:	012a7363          	bgeu	s4,s2,80002a72 <copyin+0x5e>
    80002a70:	8952                	mv	s2,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80002a72:	409985b3          	sub	a1,s3,s1
    80002a76:	0009061b          	sext.w	a2,s2
    80002a7a:	95aa                	add	a1,a1,a0
    80002a7c:	855a                	mv	a0,s6
    80002a7e:	adefe0ef          	jal	80000d5c <memmove>
    len -= n;
    80002a82:	412a0a33          	sub	s4,s4,s2
    dst += n;
    80002a86:	9b4a                	add	s6,s6,s2
    srcva = va0 + PGSIZE;
    80002a88:	018489b3          	add	s3,s1,s8
  while(len > 0){
    80002a8c:	060a0663          	beqz	s4,80002af8 <copyin+0xe4>
    va0 = PGROUNDDOWN(srcva);
    80002a90:	0179f4b3          	and	s1,s3,s7
    if(va0 >= 0x40000000UL) {
    80002a94:	07a4fd63          	bgeu	s1,s10,80002b0e <copyin+0xfa>
    pa0 = walkaddr(pagetable, va0);
    80002a98:	85a6                	mv	a1,s1
    80002a9a:	8566                	mv	a0,s9
    80002a9c:	d8efe0ef          	jal	8000102a <walkaddr>
    if(pa0 == 0) {
    80002aa0:	f179                	bnez	a0,80002a66 <copyin+0x52>
      if(p) {
    80002aa2:	080a8663          	beqz	s5,80002b2e <copyin+0x11a>
        uint64 stack_limit = p->trapframe ? PGROUNDDOWN(p->trapframe->sp) - PGSIZE : 0;
    80002aa6:	058ab783          	ld	a5,88(s5)
    80002aaa:	c789                	beqz	a5,80002ab4 <copyin+0xa0>
    80002aac:	7b88                	ld	a0,48(a5)
    80002aae:	01757533          	and	a0,a0,s7
    80002ab2:	955e                	add	a0,a0,s7
        if((va0 >= p->text_start && va0 < p->text_end) ||
    80002ab4:	168ab703          	ld	a4,360(s5)
    80002ab8:	00e4e663          	bltu	s1,a4,80002ac4 <copyin+0xb0>
    80002abc:	170ab703          	ld	a4,368(s5)
    80002ac0:	f8e4ede3          	bltu	s1,a4,80002a5a <copyin+0x46>
    80002ac4:	178ab703          	ld	a4,376(s5)
    80002ac8:	00e4e663          	bltu	s1,a4,80002ad4 <copyin+0xc0>
           (va0 >= p->data_start && va0 < p->data_end) ||
    80002acc:	180ab703          	ld	a4,384(s5)
    80002ad0:	f8e4e5e3          	bltu	s1,a4,80002a5a <copyin+0x46>
    80002ad4:	188ab703          	ld	a4,392(s5)
    80002ad8:	00e4e663          	bltu	s1,a4,80002ae4 <copyin+0xd0>
           (va0 >= p->heap_start && va0 < p->sz) ||
    80002adc:	048ab703          	ld	a4,72(s5)
    80002ae0:	f6e4ede3          	bltu	s1,a4,80002a5a <copyin+0x46>
           (p->trapframe && va0 >= stack_limit && va0 < PGROUNDUP(p->trapframe->sp)) ||
    80002ae4:	f6a4e7e3          	bltu	s1,a0,80002a52 <copyin+0x3e>
    80002ae8:	d7ad                	beqz	a5,80002a52 <copyin+0x3e>
    80002aea:	7b9c                	ld	a5,48(a5)
    80002aec:	97ee                	add	a5,a5,s11
    80002aee:	0177f7b3          	and	a5,a5,s7
    80002af2:	f6f4e4e3          	bltu	s1,a5,80002a5a <copyin+0x46>
    80002af6:	bfb1                	j	80002a52 <copyin+0x3e>
  return 0;
    80002af8:	4501                	li	a0,0
    80002afa:	64e6                	ld	s1,88(sp)
    80002afc:	6946                	ld	s2,80(sp)
    80002afe:	7ae2                	ld	s5,56(sp)
    80002b00:	7ba2                	ld	s7,40(sp)
    80002b02:	7c02                	ld	s8,32(sp)
    80002b04:	6d42                	ld	s10,16(sp)
    80002b06:	6da2                	ld	s11,8(sp)
    80002b08:	a819                	j	80002b1e <copyin+0x10a>
    80002b0a:	4501                	li	a0,0
    80002b0c:	a809                	j	80002b1e <copyin+0x10a>
      return -1;
    80002b0e:	557d                	li	a0,-1
    80002b10:	64e6                	ld	s1,88(sp)
    80002b12:	6946                	ld	s2,80(sp)
    80002b14:	7ae2                	ld	s5,56(sp)
    80002b16:	7ba2                	ld	s7,40(sp)
    80002b18:	7c02                	ld	s8,32(sp)
    80002b1a:	6d42                	ld	s10,16(sp)
    80002b1c:	6da2                	ld	s11,8(sp)
}
    80002b1e:	70a6                	ld	ra,104(sp)
    80002b20:	7406                	ld	s0,96(sp)
    80002b22:	69a6                	ld	s3,72(sp)
    80002b24:	6a06                	ld	s4,64(sp)
    80002b26:	7b42                	ld	s6,48(sp)
    80002b28:	6ce2                	ld	s9,24(sp)
    80002b2a:	6165                	addi	sp,sp,112
    80002b2c:	8082                	ret
        return -1; // Don't try to fault in addresses outside valid regions
    80002b2e:	557d                	li	a0,-1
    80002b30:	64e6                	ld	s1,88(sp)
    80002b32:	6946                	ld	s2,80(sp)
    80002b34:	7ae2                	ld	s5,56(sp)
    80002b36:	7ba2                	ld	s7,40(sp)
    80002b38:	7c02                	ld	s8,32(sp)
    80002b3a:	6d42                	ld	s10,16(sp)
    80002b3c:	6da2                	ld	s11,8(sp)
    80002b3e:	b7c5                	j	80002b1e <copyin+0x10a>
    80002b40:	557d                	li	a0,-1
    80002b42:	64e6                	ld	s1,88(sp)
    80002b44:	6946                	ld	s2,80(sp)
    80002b46:	7ae2                	ld	s5,56(sp)
    80002b48:	7ba2                	ld	s7,40(sp)
    80002b4a:	7c02                	ld	s8,32(sp)
    80002b4c:	6d42                	ld	s10,16(sp)
    80002b4e:	6da2                	ld	s11,8(sp)
    80002b50:	b7f9                	j	80002b1e <copyin+0x10a>
        return -1;
    80002b52:	557d                	li	a0,-1
    80002b54:	64e6                	ld	s1,88(sp)
    80002b56:	6946                	ld	s2,80(sp)
    80002b58:	7ae2                	ld	s5,56(sp)
    80002b5a:	7ba2                	ld	s7,40(sp)
    80002b5c:	7c02                	ld	s8,32(sp)
    80002b5e:	6d42                	ld	s10,16(sp)
    80002b60:	6da2                	ld	s11,8(sp)
    80002b62:	bf75                	j	80002b1e <copyin+0x10a>

0000000080002b64 <cleanup_swap_file>:

// Delete swap file on process exit
void
cleanup_swap_file(void)
{
    80002b64:	715d                	addi	sp,sp,-80
    80002b66:	e486                	sd	ra,72(sp)
    80002b68:	e0a2                	sd	s0,64(sp)
    80002b6a:	0880                	addi	s0,sp,80
  struct proc *p = myproc();
    80002b6c:	2d8000ef          	jal	80002e44 <myproc>
  
  if(p->swapfile) 
    80002b70:	7ff50793          	addi	a5,a0,2047
    80002b74:	3a97b783          	ld	a5,937(a5)
    80002b78:	cfd1                	beqz	a5,80002c14 <cleanup_swap_file+0xb0>
    80002b7a:	fc26                	sd	s1,56(sp)
    80002b7c:	f84a                	sd	s2,48(sp)
    80002b7e:	84aa                	mv	s1,a0
  {
    // Log cleanup
    printf("[pid %d] SWAPCLEANUP freed_slots=%d\n", p->pid, p->swap_slots_used);
    80002b80:	6905                	lui	s2,0x1
    80002b82:	992a                	add	s2,s2,a0
    80002b84:	bc092603          	lw	a2,-1088(s2) # bc0 <_entry-0x7ffff440>
    80002b88:	590c                	lw	a1,48(a0)
    80002b8a:	00007517          	auipc	a0,0x7
    80002b8e:	d1e50513          	addi	a0,a0,-738 # 800098a8 <etext+0x8a8>
    80002b92:	969fd0ef          	jal	800004fa <printf>
    
    // Close the swap file first
    begin_op();
    80002b96:	2bb020ef          	jal	80005650 <begin_op>
    iput(p->swapfile);
    80002b9a:	ba893503          	ld	a0,-1112(s2)
    80002b9e:	228020ef          	jal	80004dc6 <iput>
    p->swapfile = 0;
    80002ba2:	ba093423          	sd	zero,-1112(s2)
    end_op();
    80002ba6:	31b020ef          	jal	800056c0 <end_op>
    
    // Now delete the swap file from filesystem
    begin_op();
    80002baa:	2a7020ef          	jal	80005650 <begin_op>
    struct dirent de;
    char name[DIRSIZ];
    uint off;
    
    // Get parent directory and filename
    if((dp = nameiparent(p->swapfilename, name)) != 0) {
    80002bae:	fc040593          	addi	a1,s0,-64
    80002bb2:	7ff48513          	addi	a0,s1,2047
    80002bb6:	3b150513          	addi	a0,a0,945
    80002bba:	0d3020ef          	jal	8000548c <nameiparent>
    80002bbe:	84aa                	mv	s1,a0
    80002bc0:	c531                	beqz	a0,80002c0c <cleanup_swap_file+0xa8>
      ilock(dp);
    80002bc2:	082020ef          	jal	80004c44 <ilock>
      
      // Look up the swap file
      if((ip = dirlookup(dp, name, &off)) != 0) {
    80002bc6:	fbc40613          	addi	a2,s0,-68
    80002bca:	fc040593          	addi	a1,s0,-64
    80002bce:	8526                	mv	a0,s1
    80002bd0:	60e020ef          	jal	800051de <dirlookup>
    80002bd4:	892a                	mv	s2,a0
    80002bd6:	c905                	beqz	a0,80002c06 <cleanup_swap_file+0xa2>
        ilock(ip);
    80002bd8:	06c020ef          	jal	80004c44 <ilock>
        
        // Remove directory entry
        memset(&de, 0, sizeof(de));
    80002bdc:	4641                	li	a2,16
    80002bde:	4581                	li	a1,0
    80002be0:	fd040513          	addi	a0,s0,-48
    80002be4:	918fe0ef          	jal	80000cfc <memset>
        if(writei(dp, 0, (uint64)&de, off, sizeof(de)) == sizeof(de)) {
    80002be8:	4741                	li	a4,16
    80002bea:	fbc42683          	lw	a3,-68(s0)
    80002bee:	fd040613          	addi	a2,s0,-48
    80002bf2:	4581                	li	a1,0
    80002bf4:	8526                	mv	a0,s1
    80002bf6:	4d2020ef          	jal	800050c8 <writei>
    80002bfa:	47c1                	li	a5,16
    80002bfc:	02f50063          	beq	a0,a5,80002c1c <cleanup_swap_file+0xb8>
          // Decrease link count and update inode
          ip->nlink--;
          iupdate(ip);
        }
        
        iunlockput(ip);
    80002c00:	854a                	mv	a0,s2
    80002c02:	24e020ef          	jal	80004e50 <iunlockput>
      }
      
      iunlockput(dp);
    80002c06:	8526                	mv	a0,s1
    80002c08:	248020ef          	jal	80004e50 <iunlockput>
    }
    end_op();
    80002c0c:	2b5020ef          	jal	800056c0 <end_op>
    80002c10:	74e2                	ld	s1,56(sp)
    80002c12:	7942                	ld	s2,48(sp)
  }
}
    80002c14:	60a6                	ld	ra,72(sp)
    80002c16:	6406                	ld	s0,64(sp)
    80002c18:	6161                	addi	sp,sp,80
    80002c1a:	8082                	ret
          ip->nlink--;
    80002c1c:	04a95783          	lhu	a5,74(s2)
    80002c20:	37fd                	addiw	a5,a5,-1
    80002c22:	04f91523          	sh	a5,74(s2)
          iupdate(ip);
    80002c26:	854a                	mv	a0,s2
    80002c28:	769010ef          	jal	80004b90 <iupdate>
    80002c2c:	bfd1                	j	80002c00 <cleanup_swap_file+0x9c>

0000000080002c2e <free_resident_pages>:

// Clean up all resident pages before freeing page table
// This prevents "freewalk: leaf" panics in demand paging
void
free_resident_pages(pagetable_t pagetable, struct proc *p)
{
    80002c2e:	7139                	addi	sp,sp,-64
    80002c30:	fc06                	sd	ra,56(sp)
    80002c32:	f822                	sd	s0,48(sp)
    80002c34:	f426                	sd	s1,40(sp)
    80002c36:	f04a                	sd	s2,32(sp)
    80002c38:	ec4e                	sd	s3,24(sp)
    80002c3a:	e852                	sd	s4,16(sp)
    80002c3c:	e456                	sd	s5,8(sp)
    80002c3e:	e05a                	sd	s6,0(sp)
    80002c40:	0080                	addi	s0,sp,64
    80002c42:	8aaa                	mv	s5,a0
    80002c44:	8b2e                	mv	s6,a1
  pte_t *pte;
  uint64 pa;
  
  // Walk through all resident pages and free them
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) {
    80002c46:	1b458493          	addi	s1,a1,436 # 11b4 <_entry-0x7fffee4c>
    80002c4a:	7ff58a13          	addi	s4,a1,2047
    80002c4e:	3b5a0a13          	addi	s4,s4,949 # 13b5 <_entry-0x7fffec4b>
    80002c52:	a039                	j	80002c60 <free_resident_pages+0x32>
      kfree((void*)pa);
      *pte = 0;  // Clear the PTE
    }
    
    // Mark as free
    p->resident_pages[i].in_use = 0;
    80002c54:	0009a023          	sw	zero,0(s3)
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) {
    80002c58:	02848493          	addi	s1,s1,40
    80002c5c:	03448963          	beq	s1,s4,80002c8e <free_resident_pages+0x60>
    if(!p->resident_pages[i].in_use) continue;
    80002c60:	89a6                	mv	s3,s1
    80002c62:	409c                	lw	a5,0(s1)
    80002c64:	dbf5                	beqz	a5,80002c58 <free_resident_pages+0x2a>
    pte = walk(pagetable, va, 0);
    80002c66:	4601                	li	a2,0
    80002c68:	fec4b583          	ld	a1,-20(s1)
    80002c6c:	8556                	mv	a0,s5
    80002c6e:	b22fe0ef          	jal	80000f90 <walk>
    80002c72:	892a                	mv	s2,a0
    if(pte && (*pte & PTE_V)) {
    80002c74:	d165                	beqz	a0,80002c54 <free_resident_pages+0x26>
    80002c76:	611c                	ld	a5,0(a0)
    80002c78:	0017f713          	andi	a4,a5,1
    80002c7c:	df61                	beqz	a4,80002c54 <free_resident_pages+0x26>
      pa = PTE2PA(*pte);
    80002c7e:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    80002c80:	00c79513          	slli	a0,a5,0xc
    80002c84:	dd9fd0ef          	jal	80000a5c <kfree>
      *pte = 0;  // Clear the PTE
    80002c88:	00093023          	sd	zero,0(s2)
    80002c8c:	b7e1                	j	80002c54 <free_resident_pages+0x26>
  }
  
  // Reset resident page tracking
  p->num_resident_pages = 0;
    80002c8e:	7ffb0b13          	addi	s6,s6,2047
    80002c92:	3a0b20a3          	sw	zero,929(s6)
}
    80002c96:	70e2                	ld	ra,56(sp)
    80002c98:	7442                	ld	s0,48(sp)
    80002c9a:	74a2                	ld	s1,40(sp)
    80002c9c:	7902                	ld	s2,32(sp)
    80002c9e:	69e2                	ld	s3,24(sp)
    80002ca0:	6a42                	ld	s4,16(sp)
    80002ca2:	6aa2                	ld	s5,8(sp)
    80002ca4:	6b02                	ld	s6,0(sp)
    80002ca6:	6121                	addi	sp,sp,64
    80002ca8:	8082                	ret

0000000080002caa <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80002caa:	711d                	addi	sp,sp,-96
    80002cac:	ec86                	sd	ra,88(sp)
    80002cae:	e8a2                	sd	s0,80(sp)
    80002cb0:	e4a6                	sd	s1,72(sp)
    80002cb2:	e0ca                	sd	s2,64(sp)
    80002cb4:	fc4e                	sd	s3,56(sp)
    80002cb6:	f852                	sd	s4,48(sp)
    80002cb8:	f456                	sd	s5,40(sp)
    80002cba:	f05a                	sd	s6,32(sp)
    80002cbc:	ec5e                	sd	s7,24(sp)
    80002cbe:	e862                	sd	s8,16(sp)
    80002cc0:	e466                	sd	s9,8(sp)
    80002cc2:	1080                	addi	s0,sp,96
    80002cc4:	8aaa                	mv	s5,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80002cc6:	00013497          	auipc	s1,0x13
    80002cca:	c3248493          	addi	s1,s1,-974 # 800158f8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80002cce:	8ca6                	mv	s9,s1
    80002cd0:	236ef7b7          	lui	a5,0x236ef
    80002cd4:	078a                	slli	a5,a5,0x2
    80002cd6:	a2778793          	addi	a5,a5,-1497 # 236eea27 <_entry-0x5c9115d9>
    80002cda:	6c097937          	lui	s2,0x6c097
    80002cde:	0906                	slli	s2,s2,0x1
    80002ce0:	5d490913          	addi	s2,s2,1492 # 6c0975d4 <_entry-0x13f68a2c>
    80002ce4:	1902                	slli	s2,s2,0x20
    80002ce6:	993e                	add	s2,s2,a5
    80002ce8:	040009b7          	lui	s3,0x4000
    80002cec:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80002cee:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80002cf0:	4c19                	li	s8,6
    80002cf2:	6b85                	lui	s7,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    80002cf4:	6a2d                	lui	s4,0xb
    80002cf6:	cb8a0a13          	addi	s4,s4,-840 # acb8 <_entry-0x7fff5348>
    80002cfa:	002c6b17          	auipc	s6,0x2c6
    80002cfe:	9feb0b13          	addi	s6,s6,-1538 # 802c86f8 <tickslock>
    char *pa = kalloc();
    80002d02:	e47fd0ef          	jal	80000b48 <kalloc>
    80002d06:	862a                	mv	a2,a0
    if(pa == 0)
    80002d08:	c121                	beqz	a0,80002d48 <proc_mapstacks+0x9e>
    uint64 va = KSTACK((int) (p - proc));
    80002d0a:	419485b3          	sub	a1,s1,s9
    80002d0e:	858d                	srai	a1,a1,0x3
    80002d10:	032585b3          	mul	a1,a1,s2
    80002d14:	05b6                	slli	a1,a1,0xd
    80002d16:	6789                	lui	a5,0x2
    80002d18:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80002d1a:	8762                	mv	a4,s8
    80002d1c:	86de                	mv	a3,s7
    80002d1e:	40b985b3          	sub	a1,s3,a1
    80002d22:	8556                	mv	a0,s5
    80002d24:	bf6fe0ef          	jal	8000111a <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002d28:	94d2                	add	s1,s1,s4
    80002d2a:	fd649ce3          	bne	s1,s6,80002d02 <proc_mapstacks+0x58>
  }
}
    80002d2e:	60e6                	ld	ra,88(sp)
    80002d30:	6446                	ld	s0,80(sp)
    80002d32:	64a6                	ld	s1,72(sp)
    80002d34:	6906                	ld	s2,64(sp)
    80002d36:	79e2                	ld	s3,56(sp)
    80002d38:	7a42                	ld	s4,48(sp)
    80002d3a:	7aa2                	ld	s5,40(sp)
    80002d3c:	7b02                	ld	s6,32(sp)
    80002d3e:	6be2                	ld	s7,24(sp)
    80002d40:	6c42                	ld	s8,16(sp)
    80002d42:	6ca2                	ld	s9,8(sp)
    80002d44:	6125                	addi	sp,sp,96
    80002d46:	8082                	ret
      panic("kalloc");
    80002d48:	00007517          	auipc	a0,0x7
    80002d4c:	b8850513          	addi	a0,a0,-1144 # 800098d0 <etext+0x8d0>
    80002d50:	ad5fd0ef          	jal	80000824 <panic>

0000000080002d54 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80002d54:	715d                	addi	sp,sp,-80
    80002d56:	e486                	sd	ra,72(sp)
    80002d58:	e0a2                	sd	s0,64(sp)
    80002d5a:	fc26                	sd	s1,56(sp)
    80002d5c:	f84a                	sd	s2,48(sp)
    80002d5e:	f44e                	sd	s3,40(sp)
    80002d60:	f052                	sd	s4,32(sp)
    80002d62:	ec56                	sd	s5,24(sp)
    80002d64:	e85a                	sd	s6,16(sp)
    80002d66:	e45e                	sd	s7,8(sp)
    80002d68:	0880                	addi	s0,sp,80
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80002d6a:	00007597          	auipc	a1,0x7
    80002d6e:	b6e58593          	addi	a1,a1,-1170 # 800098d8 <etext+0x8d8>
    80002d72:	00012517          	auipc	a0,0x12
    80002d76:	75650513          	addi	a0,a0,1878 # 800154c8 <pid_lock>
    80002d7a:	e29fd0ef          	jal	80000ba2 <initlock>
  initlock(&wait_lock, "wait_lock");
    80002d7e:	00007597          	auipc	a1,0x7
    80002d82:	b6258593          	addi	a1,a1,-1182 # 800098e0 <etext+0x8e0>
    80002d86:	00012517          	auipc	a0,0x12
    80002d8a:	75a50513          	addi	a0,a0,1882 # 800154e0 <wait_lock>
    80002d8e:	e15fd0ef          	jal	80000ba2 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002d92:	00013497          	auipc	s1,0x13
    80002d96:	b6648493          	addi	s1,s1,-1178 # 800158f8 <proc>
      initlock(&p->lock, "proc");
    80002d9a:	00007b97          	auipc	s7,0x7
    80002d9e:	b56b8b93          	addi	s7,s7,-1194 # 800098f0 <etext+0x8f0>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80002da2:	8b26                	mv	s6,s1
    80002da4:	236ef7b7          	lui	a5,0x236ef
    80002da8:	078a                	slli	a5,a5,0x2
    80002daa:	a2778793          	addi	a5,a5,-1497 # 236eea27 <_entry-0x5c9115d9>
    80002dae:	6c097937          	lui	s2,0x6c097
    80002db2:	0906                	slli	s2,s2,0x1
    80002db4:	5d490913          	addi	s2,s2,1492 # 6c0975d4 <_entry-0x13f68a2c>
    80002db8:	1902                	slli	s2,s2,0x20
    80002dba:	993e                	add	s2,s2,a5
    80002dbc:	040009b7          	lui	s3,0x4000
    80002dc0:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80002dc2:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80002dc4:	6a2d                	lui	s4,0xb
    80002dc6:	cb8a0a13          	addi	s4,s4,-840 # acb8 <_entry-0x7fff5348>
    80002dca:	002c6a97          	auipc	s5,0x2c6
    80002dce:	92ea8a93          	addi	s5,s5,-1746 # 802c86f8 <tickslock>
      initlock(&p->lock, "proc");
    80002dd2:	85de                	mv	a1,s7
    80002dd4:	8526                	mv	a0,s1
    80002dd6:	dcdfd0ef          	jal	80000ba2 <initlock>
      p->state = UNUSED;
    80002dda:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80002dde:	416487b3          	sub	a5,s1,s6
    80002de2:	878d                	srai	a5,a5,0x3
    80002de4:	032787b3          	mul	a5,a5,s2
    80002de8:	07b6                	slli	a5,a5,0xd
    80002dea:	6709                	lui	a4,0x2
    80002dec:	9fb9                	addw	a5,a5,a4
    80002dee:	40f987b3          	sub	a5,s3,a5
    80002df2:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80002df4:	94d2                	add	s1,s1,s4
    80002df6:	fd549ee3          	bne	s1,s5,80002dd2 <procinit+0x7e>
  }
}
    80002dfa:	60a6                	ld	ra,72(sp)
    80002dfc:	6406                	ld	s0,64(sp)
    80002dfe:	74e2                	ld	s1,56(sp)
    80002e00:	7942                	ld	s2,48(sp)
    80002e02:	79a2                	ld	s3,40(sp)
    80002e04:	7a02                	ld	s4,32(sp)
    80002e06:	6ae2                	ld	s5,24(sp)
    80002e08:	6b42                	ld	s6,16(sp)
    80002e0a:	6ba2                	ld	s7,8(sp)
    80002e0c:	6161                	addi	sp,sp,80
    80002e0e:	8082                	ret

0000000080002e10 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80002e10:	1141                	addi	sp,sp,-16
    80002e12:	e406                	sd	ra,8(sp)
    80002e14:	e022                	sd	s0,0(sp)
    80002e16:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80002e18:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80002e1a:	2501                	sext.w	a0,a0
    80002e1c:	60a2                	ld	ra,8(sp)
    80002e1e:	6402                	ld	s0,0(sp)
    80002e20:	0141                	addi	sp,sp,16
    80002e22:	8082                	ret

0000000080002e24 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80002e24:	1141                	addi	sp,sp,-16
    80002e26:	e406                	sd	ra,8(sp)
    80002e28:	e022                	sd	s0,0(sp)
    80002e2a:	0800                	addi	s0,sp,16
    80002e2c:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80002e2e:	2781                	sext.w	a5,a5
    80002e30:	079e                	slli	a5,a5,0x7
  return c;
}
    80002e32:	00012517          	auipc	a0,0x12
    80002e36:	6c650513          	addi	a0,a0,1734 # 800154f8 <cpus>
    80002e3a:	953e                	add	a0,a0,a5
    80002e3c:	60a2                	ld	ra,8(sp)
    80002e3e:	6402                	ld	s0,0(sp)
    80002e40:	0141                	addi	sp,sp,16
    80002e42:	8082                	ret

0000000080002e44 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80002e44:	1101                	addi	sp,sp,-32
    80002e46:	ec06                	sd	ra,24(sp)
    80002e48:	e822                	sd	s0,16(sp)
    80002e4a:	e426                	sd	s1,8(sp)
    80002e4c:	1000                	addi	s0,sp,32
  push_off();
    80002e4e:	d9bfd0ef          	jal	80000be8 <push_off>
    80002e52:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80002e54:	2781                	sext.w	a5,a5
    80002e56:	079e                	slli	a5,a5,0x7
    80002e58:	00012717          	auipc	a4,0x12
    80002e5c:	67070713          	addi	a4,a4,1648 # 800154c8 <pid_lock>
    80002e60:	97ba                	add	a5,a5,a4
    80002e62:	7b9c                	ld	a5,48(a5)
    80002e64:	84be                	mv	s1,a5
  pop_off();
    80002e66:	e0bfd0ef          	jal	80000c70 <pop_off>
  return p;
}
    80002e6a:	8526                	mv	a0,s1
    80002e6c:	60e2                	ld	ra,24(sp)
    80002e6e:	6442                	ld	s0,16(sp)
    80002e70:	64a2                	ld	s1,8(sp)
    80002e72:	6105                	addi	sp,sp,32
    80002e74:	8082                	ret

0000000080002e76 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80002e76:	7179                	addi	sp,sp,-48
    80002e78:	f406                	sd	ra,40(sp)
    80002e7a:	f022                	sd	s0,32(sp)
    80002e7c:	ec26                	sd	s1,24(sp)
    80002e7e:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80002e80:	fc5ff0ef          	jal	80002e44 <myproc>
    80002e84:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80002e86:	e3bfd0ef          	jal	80000cc0 <release>

  if (first) 
    80002e8a:	0000a797          	auipc	a5,0xa
    80002e8e:	5067a783          	lw	a5,1286(a5) # 8000d390 <first.1>
    80002e92:	cf95                	beqz	a5,80002ece <forkret+0x58>
  {
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80002e94:	4505                	li	a0,1
    80002e96:	0a2020ef          	jal	80004f38 <fsinit>

    first = 0;
    80002e9a:	0000a797          	auipc	a5,0xa
    80002e9e:	4e07ab23          	sw	zero,1270(a5) # 8000d390 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80002ea2:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80002ea6:	00007797          	auipc	a5,0x7
    80002eaa:	a5278793          	addi	a5,a5,-1454 # 800098f8 <etext+0x8f8>
    80002eae:	fcf43823          	sd	a5,-48(s0)
    80002eb2:	fc043c23          	sd	zero,-40(s0)
    80002eb6:	fd040593          	addi	a1,s0,-48
    80002eba:	853e                	mv	a0,a5
    80002ebc:	204030ef          	jal	800060c0 <kexec>
    80002ec0:	6cbc                	ld	a5,88(s1)
    80002ec2:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) 
    80002ec4:	6cbc                	ld	a5,88(s1)
    80002ec6:	7bb8                	ld	a4,112(a5)
    80002ec8:	57fd                	li	a5,-1
    80002eca:	02f70d63          	beq	a4,a5,80002f04 <forkret+0x8e>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80002ece:	4cb000ef          	jal	80003b98 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002ed2:	68a8                	ld	a0,80(s1)
    80002ed4:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002ed6:	04000737          	lui	a4,0x4000
    80002eda:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002edc:	0732                	slli	a4,a4,0xc
    80002ede:	00005797          	auipc	a5,0x5
    80002ee2:	1be78793          	addi	a5,a5,446 # 8000809c <userret>
    80002ee6:	00005697          	auipc	a3,0x5
    80002eea:	11a68693          	addi	a3,a3,282 # 80008000 <_trampoline>
    80002eee:	8f95                	sub	a5,a5,a3
    80002ef0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002ef2:	577d                	li	a4,-1
    80002ef4:	177e                	slli	a4,a4,0x3f
    80002ef6:	8d59                	or	a0,a0,a4
    80002ef8:	9782                	jalr	a5
}
    80002efa:	70a2                	ld	ra,40(sp)
    80002efc:	7402                	ld	s0,32(sp)
    80002efe:	64e2                	ld	s1,24(sp)
    80002f00:	6145                	addi	sp,sp,48
    80002f02:	8082                	ret
      panic("exec");
    80002f04:	00007517          	auipc	a0,0x7
    80002f08:	99c50513          	addi	a0,a0,-1636 # 800098a0 <etext+0x8a0>
    80002f0c:	919fd0ef          	jal	80000824 <panic>

0000000080002f10 <allocpid>:
{
    80002f10:	1101                	addi	sp,sp,-32
    80002f12:	ec06                	sd	ra,24(sp)
    80002f14:	e822                	sd	s0,16(sp)
    80002f16:	e426                	sd	s1,8(sp)
    80002f18:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80002f1a:	00012517          	auipc	a0,0x12
    80002f1e:	5ae50513          	addi	a0,a0,1454 # 800154c8 <pid_lock>
    80002f22:	d0bfd0ef          	jal	80000c2c <acquire>
  pid = nextpid;
    80002f26:	0000a797          	auipc	a5,0xa
    80002f2a:	46e78793          	addi	a5,a5,1134 # 8000d394 <nextpid>
    80002f2e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80002f30:	0014871b          	addiw	a4,s1,1
    80002f34:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80002f36:	00012517          	auipc	a0,0x12
    80002f3a:	59250513          	addi	a0,a0,1426 # 800154c8 <pid_lock>
    80002f3e:	d83fd0ef          	jal	80000cc0 <release>
}
    80002f42:	8526                	mv	a0,s1
    80002f44:	60e2                	ld	ra,24(sp)
    80002f46:	6442                	ld	s0,16(sp)
    80002f48:	64a2                	ld	s1,8(sp)
    80002f4a:	6105                	addi	sp,sp,32
    80002f4c:	8082                	ret

0000000080002f4e <proc_pagetable>:
{
    80002f4e:	1101                	addi	sp,sp,-32
    80002f50:	ec06                	sd	ra,24(sp)
    80002f52:	e822                	sd	s0,16(sp)
    80002f54:	e426                	sd	s1,8(sp)
    80002f56:	e04a                	sd	s2,0(sp)
    80002f58:	1000                	addi	s0,sp,32
    80002f5a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80002f5c:	ab2fe0ef          	jal	8000120e <uvmcreate>
    80002f60:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80002f62:	cd05                	beqz	a0,80002f9a <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80002f64:	4729                	li	a4,10
    80002f66:	00005697          	auipc	a3,0x5
    80002f6a:	09a68693          	addi	a3,a3,154 # 80008000 <_trampoline>
    80002f6e:	6605                	lui	a2,0x1
    80002f70:	040005b7          	lui	a1,0x4000
    80002f74:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80002f76:	05b2                	slli	a1,a1,0xc
    80002f78:	8ecfe0ef          	jal	80001064 <mappages>
    80002f7c:	02054663          	bltz	a0,80002fa8 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80002f80:	4719                	li	a4,6
    80002f82:	05893683          	ld	a3,88(s2)
    80002f86:	6605                	lui	a2,0x1
    80002f88:	020005b7          	lui	a1,0x2000
    80002f8c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80002f8e:	05b6                	slli	a1,a1,0xd
    80002f90:	8526                	mv	a0,s1
    80002f92:	8d2fe0ef          	jal	80001064 <mappages>
    80002f96:	00054f63          	bltz	a0,80002fb4 <proc_pagetable+0x66>
}
    80002f9a:	8526                	mv	a0,s1
    80002f9c:	60e2                	ld	ra,24(sp)
    80002f9e:	6442                	ld	s0,16(sp)
    80002fa0:	64a2                	ld	s1,8(sp)
    80002fa2:	6902                	ld	s2,0(sp)
    80002fa4:	6105                	addi	sp,sp,32
    80002fa6:	8082                	ret
    uvmfree(pagetable, 0);
    80002fa8:	4581                	li	a1,0
    80002faa:	8526                	mv	a0,s1
    80002fac:	d14fe0ef          	jal	800014c0 <uvmfree>
    return 0;
    80002fb0:	4481                	li	s1,0
    80002fb2:	b7e5                	j	80002f9a <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80002fb4:	4681                	li	a3,0
    80002fb6:	4605                	li	a2,1
    80002fb8:	040005b7          	lui	a1,0x4000
    80002fbc:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80002fbe:	05b2                	slli	a1,a1,0xc
    80002fc0:	8526                	mv	a0,s1
    80002fc2:	a72fe0ef          	jal	80001234 <uvmunmap>
    uvmfree(pagetable, 0);
    80002fc6:	4581                	li	a1,0
    80002fc8:	8526                	mv	a0,s1
    80002fca:	cf6fe0ef          	jal	800014c0 <uvmfree>
    return 0;
    80002fce:	4481                	li	s1,0
    80002fd0:	b7e9                	j	80002f9a <proc_pagetable+0x4c>

0000000080002fd2 <proc_freepagetable>:
{
    80002fd2:	1101                	addi	sp,sp,-32
    80002fd4:	ec06                	sd	ra,24(sp)
    80002fd6:	e822                	sd	s0,16(sp)
    80002fd8:	e426                	sd	s1,8(sp)
    80002fda:	e04a                	sd	s2,0(sp)
    80002fdc:	1000                	addi	s0,sp,32
    80002fde:	84aa                	mv	s1,a0
    80002fe0:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80002fe2:	4681                	li	a3,0
    80002fe4:	4605                	li	a2,1
    80002fe6:	040005b7          	lui	a1,0x4000
    80002fea:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80002fec:	05b2                	slli	a1,a1,0xc
    80002fee:	a46fe0ef          	jal	80001234 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80002ff2:	4681                	li	a3,0
    80002ff4:	4605                	li	a2,1
    80002ff6:	020005b7          	lui	a1,0x2000
    80002ffa:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80002ffc:	05b6                	slli	a1,a1,0xd
    80002ffe:	8526                	mv	a0,s1
    80003000:	a34fe0ef          	jal	80001234 <uvmunmap>
  uvmfree(pagetable, sz);
    80003004:	85ca                	mv	a1,s2
    80003006:	8526                	mv	a0,s1
    80003008:	cb8fe0ef          	jal	800014c0 <uvmfree>
}
    8000300c:	60e2                	ld	ra,24(sp)
    8000300e:	6442                	ld	s0,16(sp)
    80003010:	64a2                	ld	s1,8(sp)
    80003012:	6902                	ld	s2,0(sp)
    80003014:	6105                	addi	sp,sp,32
    80003016:	8082                	ret

0000000080003018 <freeproc>:
{
    80003018:	1101                	addi	sp,sp,-32
    8000301a:	ec06                	sd	ra,24(sp)
    8000301c:	e822                	sd	s0,16(sp)
    8000301e:	e426                	sd	s1,8(sp)
    80003020:	1000                	addi	s0,sp,32
    80003022:	84aa                	mv	s1,a0
  if(p->trapframe)
    80003024:	6d28                	ld	a0,88(a0)
    80003026:	c119                	beqz	a0,8000302c <freeproc+0x14>
    kfree((void*)p->trapframe);
    80003028:	a35fd0ef          	jal	80000a5c <kfree>
  p->trapframe = 0;
    8000302c:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable) {
    80003030:	68a8                	ld	a0,80(s1)
    80003032:	c901                	beqz	a0,80003042 <freeproc+0x2a>
    free_resident_pages(p->pagetable, p);
    80003034:	85a6                	mv	a1,s1
    80003036:	bf9ff0ef          	jal	80002c2e <free_resident_pages>
    proc_freepagetable(p->pagetable, p->sz);
    8000303a:	64ac                	ld	a1,72(s1)
    8000303c:	68a8                	ld	a0,80(s1)
    8000303e:	f95ff0ef          	jal	80002fd2 <proc_freepagetable>
  p->pagetable = 0;
    80003042:	0404b823          	sd	zero,80(s1)
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) 
    80003046:	1b448793          	addi	a5,s1,436
    8000304a:	7ff48713          	addi	a4,s1,2047
    8000304e:	3b570713          	addi	a4,a4,949
    p->resident_pages[i].in_use = 0;
    80003052:	0007a023          	sw	zero,0(a5)
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) 
    80003056:	02878793          	addi	a5,a5,40
    8000305a:	fee79ce3          	bne	a5,a4,80003052 <freeproc+0x3a>
    8000305e:	7ff48793          	addi	a5,s1,2047
    80003062:	45d78793          	addi	a5,a5,1117
    80003066:	672d                	lui	a4,0xb
    80003068:	c5c70713          	addi	a4,a4,-932 # ac5c <_entry-0x7fff53a4>
    8000306c:	9726                	add	a4,a4,s1
    p->swapped_pages[i].in_use = 0;
    8000306e:	0007a023          	sw	zero,0(a5)
  for(int i = 0; i < MAX_SWAP_PAGES; i++) 
    80003072:	02878793          	addi	a5,a5,40
    80003076:	fee79ce3          	bne	a5,a4,8000306e <freeproc+0x56>
  if(p->exec_inode) 
    8000307a:	67ad                	lui	a5,0xb
    8000307c:	97a6                	add	a5,a5,s1
    8000307e:	c507b503          	ld	a0,-944(a5) # ac50 <_entry-0x7fff53b0>
    80003082:	c519                	beqz	a0,80003090 <freeproc+0x78>
    iput(p->exec_inode);
    80003084:	543010ef          	jal	80004dc6 <iput>
    p->exec_inode = 0;
    80003088:	67ad                	lui	a5,0xb
    8000308a:	97a6                	add	a5,a5,s1
    8000308c:	c407b823          	sd	zero,-944(a5) # ac50 <_entry-0x7fff53b0>
  p->sz = 0;
    80003090:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80003094:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80003098:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    8000309c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    800030a0:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    800030a4:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    800030a8:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    800030ac:	0004ac23          	sw	zero,24(s1)
}
    800030b0:	60e2                	ld	ra,24(sp)
    800030b2:	6442                	ld	s0,16(sp)
    800030b4:	64a2                	ld	s1,8(sp)
    800030b6:	6105                	addi	sp,sp,32
    800030b8:	8082                	ret

00000000800030ba <allocproc>:
{
    800030ba:	7179                	addi	sp,sp,-48
    800030bc:	f406                	sd	ra,40(sp)
    800030be:	f022                	sd	s0,32(sp)
    800030c0:	ec26                	sd	s1,24(sp)
    800030c2:	e84a                	sd	s2,16(sp)
    800030c4:	e44e                	sd	s3,8(sp)
    800030c6:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    800030c8:	00013497          	auipc	s1,0x13
    800030cc:	83048493          	addi	s1,s1,-2000 # 800158f8 <proc>
    800030d0:	692d                	lui	s2,0xb
    800030d2:	cb890913          	addi	s2,s2,-840 # acb8 <_entry-0x7fff5348>
    800030d6:	002c5997          	auipc	s3,0x2c5
    800030da:	62298993          	addi	s3,s3,1570 # 802c86f8 <tickslock>
    acquire(&p->lock);
    800030de:	8526                	mv	a0,s1
    800030e0:	b4dfd0ef          	jal	80000c2c <acquire>
    if(p->state == UNUSED) {
    800030e4:	4c9c                	lw	a5,24(s1)
    800030e6:	cb89                	beqz	a5,800030f8 <allocproc+0x3e>
      release(&p->lock);
    800030e8:	8526                	mv	a0,s1
    800030ea:	bd7fd0ef          	jal	80000cc0 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800030ee:	94ca                	add	s1,s1,s2
    800030f0:	ff3497e3          	bne	s1,s3,800030de <allocproc+0x24>
  return 0;
    800030f4:	4481                	li	s1,0
    800030f6:	aa39                	j	80003214 <allocproc+0x15a>
  p->pid = allocpid();
    800030f8:	e19ff0ef          	jal	80002f10 <allocpid>
    800030fc:	d888                	sw	a0,48(s1)
  p->state = USED;
    800030fe:	4785                	li	a5,1
    80003100:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80003102:	a47fd0ef          	jal	80000b48 <kalloc>
    80003106:	892a                	mv	s2,a0
    80003108:	eca8                	sd	a0,88(s1)
    8000310a:	10050d63          	beqz	a0,80003224 <allocproc+0x16a>
  p->pagetable = proc_pagetable(p);
    8000310e:	8526                	mv	a0,s1
    80003110:	e3fff0ef          	jal	80002f4e <proc_pagetable>
    80003114:	892a                	mv	s2,a0
    80003116:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80003118:	10050e63          	beqz	a0,80003234 <allocproc+0x17a>
    8000311c:	e052                	sd	s4,0(sp)
    8000311e:	8a26                	mv	s4,s1
  memset(&p->context, 0, sizeof(p->context));
    80003120:	07000613          	li	a2,112
    80003124:	4581                	li	a1,0
    80003126:	06048513          	addi	a0,s1,96
    8000312a:	bd3fd0ef          	jal	80000cfc <memset>
  p->context.ra = (uint64)forkret;
    8000312e:	00000797          	auipc	a5,0x0
    80003132:	d4878793          	addi	a5,a5,-696 # 80002e76 <forkret>
    80003136:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80003138:	60b8                	ld	a4,64(s1)
    8000313a:	6785                	lui	a5,0x1
    8000313c:	973e                	add	a4,a4,a5
    8000313e:	f4b8                	sd	a4,104(s1)
  p->text_start = p->text_end = 0;
    80003140:	1604b823          	sd	zero,368(s1)
    80003144:	1604b423          	sd	zero,360(s1)
  p->data_start = p->data_end = 0;
    80003148:	1804b023          	sd	zero,384(s1)
    8000314c:	1604bc23          	sd	zero,376(s1)
  p->heap_start = 0;
    80003150:	1804b423          	sd	zero,392(s1)
  p->stack_top = 0;
    80003154:	1804b823          	sd	zero,400(s1)
  p->next_fifo_seq = 1;
    80003158:	4985                	li	s3,1
    8000315a:	1934ac23          	sw	s3,408(s1)
  p->num_resident_pages = 0;
    8000315e:	97a6                	add	a5,a5,s1
    80003160:	ba07a023          	sw	zero,-1120(a5) # ba0 <_entry-0x7ffff460>
  p->page_fault_count = 0;
    80003164:	ba07a223          	sw	zero,-1116(a5)
  p->num_swapped_pages = 0;
    80003168:	692d                	lui	s2,0xb
    8000316a:	9926                	add	s2,s2,s1
    8000316c:	c4092423          	sw	zero,-952(s2) # ac48 <_entry-0x7fff53b8>
  p->swap_slots_used = 0;
    80003170:	bc07a023          	sw	zero,-1088(a5)
  p->swapfile = 0;
    80003174:	ba07b423          	sd	zero,-1112(a5)
  p->exec_inode = 0;
    80003178:	c4093823          	sd	zero,-944(s2)
  p->memfull_logged = 0;              // Initialize MEMFULL flag
    8000317c:	ca092423          	sw	zero,-856(s2)
  memset(p->swapfilename, 0, sizeof(p->swapfilename));
    80003180:	4641                	li	a2,16
    80003182:	4581                	li	a1,0
    80003184:	7ff48513          	addi	a0,s1,2047
    80003188:	3b150513          	addi	a0,a0,945
    8000318c:	b71fd0ef          	jal	80000cfc <memset>
  memset(p->swap_bitmap, 0, sizeof(p->swap_bitmap));
    80003190:	08000613          	li	a2,128
    80003194:	4581                	li	a1,0
    80003196:	7ff48513          	addi	a0,s1,2047
    8000319a:	3c950513          	addi	a0,a0,969
    8000319e:	b5ffd0ef          	jal	80000cfc <memset>
  memset(&p->text_seg, 0, sizeof(p->text_seg));
    800031a2:	02800613          	li	a2,40
    800031a6:	4581                	li	a1,0
    800031a8:	652d                	lui	a0,0xb
    800031aa:	c5850513          	addi	a0,a0,-936 # ac58 <_entry-0x7fff53a8>
    800031ae:	9526                	add	a0,a0,s1
    800031b0:	b4dfd0ef          	jal	80000cfc <memset>
  memset(&p->data_seg, 0, sizeof(p->data_seg));
    800031b4:	02800613          	li	a2,40
    800031b8:	4581                	li	a1,0
    800031ba:	652d                	lui	a0,0xb
    800031bc:	c8050513          	addi	a0,a0,-896 # ac80 <_entry-0x7fff5380>
    800031c0:	9526                	add	a0,a0,s1
    800031c2:	b3bfd0ef          	jal	80000cfc <memset>
  p->use_bonus_algorithm = 0;         // Default to FIFO algorithm
    800031c6:	ca092623          	sw	zero,-852(s2)
  p->global_time_counter = 1;         // Initialize time counter
    800031ca:	cb393823          	sd	s3,-848(s2)
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) {
    800031ce:	1b448793          	addi	a5,s1,436
    800031d2:	7ff48713          	addi	a4,s1,2047
    800031d6:	3b570713          	addi	a4,a4,949
    p->resident_pages[i].in_use = 0;
    800031da:	0007a023          	sw	zero,0(a5)
    p->resident_pages[i].access_frequency = 0;
    800031de:	0007a223          	sw	zero,4(a5)
    p->resident_pages[i].last_access_time = 0;
    800031e2:	0007b623          	sd	zero,12(a5)
  for(int i = 0; i < MAX_RESIDENT_PAGES; i++) {
    800031e6:	02878793          	addi	a5,a5,40
    800031ea:	fee798e3          	bne	a5,a4,800031da <allocproc+0x120>
    800031ee:	7ffa0793          	addi	a5,s4,2047
    800031f2:	45d78793          	addi	a5,a5,1117
    800031f6:	672d                	lui	a4,0xb
    800031f8:	c5c70713          	addi	a4,a4,-932 # ac5c <_entry-0x7fff53a4>
    800031fc:	9752                	add	a4,a4,s4
    p->swapped_pages[i].in_use = 0;
    800031fe:	0007a023          	sw	zero,0(a5)
    p->swapped_pages[i].access_frequency = 0;
    80003202:	0007a223          	sw	zero,4(a5)
    p->swapped_pages[i].last_access_time = 0;
    80003206:	0007b623          	sd	zero,12(a5)
  for(int i = 0; i < MAX_SWAP_PAGES; i++) {
    8000320a:	02878793          	addi	a5,a5,40
    8000320e:	fee798e3          	bne	a5,a4,800031fe <allocproc+0x144>
    80003212:	6a02                	ld	s4,0(sp)
}
    80003214:	8526                	mv	a0,s1
    80003216:	70a2                	ld	ra,40(sp)
    80003218:	7402                	ld	s0,32(sp)
    8000321a:	64e2                	ld	s1,24(sp)
    8000321c:	6942                	ld	s2,16(sp)
    8000321e:	69a2                	ld	s3,8(sp)
    80003220:	6145                	addi	sp,sp,48
    80003222:	8082                	ret
    freeproc(p);
    80003224:	8526                	mv	a0,s1
    80003226:	df3ff0ef          	jal	80003018 <freeproc>
    release(&p->lock);
    8000322a:	8526                	mv	a0,s1
    8000322c:	a95fd0ef          	jal	80000cc0 <release>
    return 0;
    80003230:	84ca                	mv	s1,s2
    80003232:	b7cd                	j	80003214 <allocproc+0x15a>
    freeproc(p);
    80003234:	8526                	mv	a0,s1
    80003236:	de3ff0ef          	jal	80003018 <freeproc>
    release(&p->lock);
    8000323a:	8526                	mv	a0,s1
    8000323c:	a85fd0ef          	jal	80000cc0 <release>
    return 0;
    80003240:	84ca                	mv	s1,s2
    80003242:	bfc9                	j	80003214 <allocproc+0x15a>

0000000080003244 <userinit>:
{
    80003244:	1101                	addi	sp,sp,-32
    80003246:	ec06                	sd	ra,24(sp)
    80003248:	e822                	sd	s0,16(sp)
    8000324a:	e426                	sd	s1,8(sp)
    8000324c:	1000                	addi	s0,sp,32
  p = allocproc();
    8000324e:	e6dff0ef          	jal	800030ba <allocproc>
    80003252:	84aa                	mv	s1,a0
  initproc = p;
    80003254:	0000a797          	auipc	a5,0xa
    80003258:	16a7b623          	sd	a0,364(a5) # 8000d3c0 <initproc>
  p->cwd = namei("/");
    8000325c:	00006517          	auipc	a0,0x6
    80003260:	6a450513          	addi	a0,a0,1700 # 80009900 <etext+0x900>
    80003264:	20e020ef          	jal	80005472 <namei>
    80003268:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    8000326c:	478d                	li	a5,3
    8000326e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80003270:	8526                	mv	a0,s1
    80003272:	a4ffd0ef          	jal	80000cc0 <release>
}
    80003276:	60e2                	ld	ra,24(sp)
    80003278:	6442                	ld	s0,16(sp)
    8000327a:	64a2                	ld	s1,8(sp)
    8000327c:	6105                	addi	sp,sp,32
    8000327e:	8082                	ret

0000000080003280 <growproc>:
{
    80003280:	1101                	addi	sp,sp,-32
    80003282:	ec06                	sd	ra,24(sp)
    80003284:	e822                	sd	s0,16(sp)
    80003286:	e426                	sd	s1,8(sp)
    80003288:	e04a                	sd	s2,0(sp)
    8000328a:	1000                	addi	s0,sp,32
    8000328c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000328e:	bb7ff0ef          	jal	80002e44 <myproc>
    80003292:	892a                	mv	s2,a0
  sz = p->sz;
    80003294:	652c                	ld	a1,72(a0)
  if(n > 0){
    80003296:	02905963          	blez	s1,800032c8 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    8000329a:	00b48633          	add	a2,s1,a1
    8000329e:	020007b7          	lui	a5,0x2000
    800032a2:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    800032a4:	07b6                	slli	a5,a5,0xd
    800032a6:	02c7ea63          	bltu	a5,a2,800032da <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    800032aa:	4691                	li	a3,4
    800032ac:	6928                	ld	a0,80(a0)
    800032ae:	90afe0ef          	jal	800013b8 <uvmalloc>
    800032b2:	85aa                	mv	a1,a0
    800032b4:	c50d                	beqz	a0,800032de <growproc+0x5e>
  p->sz = sz;
    800032b6:	04b93423          	sd	a1,72(s2)
  return 0;
    800032ba:	4501                	li	a0,0
}
    800032bc:	60e2                	ld	ra,24(sp)
    800032be:	6442                	ld	s0,16(sp)
    800032c0:	64a2                	ld	s1,8(sp)
    800032c2:	6902                	ld	s2,0(sp)
    800032c4:	6105                	addi	sp,sp,32
    800032c6:	8082                	ret
  } else if(n < 0){
    800032c8:	fe04d7e3          	bgez	s1,800032b6 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800032cc:	00b48633          	add	a2,s1,a1
    800032d0:	6928                	ld	a0,80(a0)
    800032d2:	fedfd0ef          	jal	800012be <uvmdealloc>
    800032d6:	85aa                	mv	a1,a0
    800032d8:	bff9                	j	800032b6 <growproc+0x36>
      return -1;
    800032da:	557d                	li	a0,-1
    800032dc:	b7c5                	j	800032bc <growproc+0x3c>
      return -1;
    800032de:	557d                	li	a0,-1
    800032e0:	bff1                	j	800032bc <growproc+0x3c>

00000000800032e2 <kfork>:
{
    800032e2:	7139                	addi	sp,sp,-64
    800032e4:	fc06                	sd	ra,56(sp)
    800032e6:	f822                	sd	s0,48(sp)
    800032e8:	f426                	sd	s1,40(sp)
    800032ea:	e852                	sd	s4,16(sp)
    800032ec:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    800032ee:	b57ff0ef          	jal	80002e44 <myproc>
    800032f2:	8a2a                	mv	s4,a0
  if((np = allocproc()) == 0){
    800032f4:	dc7ff0ef          	jal	800030ba <allocproc>
    800032f8:	18050e63          	beqz	a0,80003494 <kfork+0x1b2>
    800032fc:	ec4e                	sd	s3,24(sp)
    800032fe:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80003300:	048a3603          	ld	a2,72(s4)
    80003304:	692c                	ld	a1,80(a0)
    80003306:	050a3503          	ld	a0,80(s4)
    8000330a:	9e8fe0ef          	jal	800014f2 <uvmcopy>
    8000330e:	0e054c63          	bltz	a0,80003406 <kfork+0x124>
    80003312:	f04a                	sd	s2,32(sp)
    80003314:	e456                	sd	s5,8(sp)
  np->sz = p->sz;
    80003316:	048a3783          	ld	a5,72(s4)
    8000331a:	04f9b423          	sd	a5,72(s3)
  np->text_start = p->text_start;
    8000331e:	168a3783          	ld	a5,360(s4)
    80003322:	16f9b423          	sd	a5,360(s3)
  np->text_end = p->text_end;
    80003326:	170a3783          	ld	a5,368(s4)
    8000332a:	16f9b823          	sd	a5,368(s3)
  np->data_start = p->data_start;
    8000332e:	178a3783          	ld	a5,376(s4)
    80003332:	16f9bc23          	sd	a5,376(s3)
  np->data_end = p->data_end;
    80003336:	180a3783          	ld	a5,384(s4)
    8000333a:	18f9b023          	sd	a5,384(s3)
  np->heap_start = p->heap_start;
    8000333e:	188a3783          	ld	a5,392(s4)
    80003342:	18f9b423          	sd	a5,392(s3)
  np->stack_top = p->stack_top;
    80003346:	190a3783          	ld	a5,400(s4)
    8000334a:	18f9b823          	sd	a5,400(s3)
  np->next_fifo_seq = 1; // Start fresh FIFO sequence for child
    8000334e:	4785                	li	a5,1
    80003350:	18f9ac23          	sw	a5,408(s3)
  np->memfull_logged = 0; // Child starts with clean MEMFULL flag
    80003354:	67ad                	lui	a5,0xb
    80003356:	00f98733          	add	a4,s3,a5
    8000335a:	ca072423          	sw	zero,-856(a4)
  np->exec_inode = p->exec_inode;
    8000335e:	97d2                	add	a5,a5,s4
    80003360:	c507b503          	ld	a0,-944(a5) # ac50 <_entry-0x7fff53b0>
    80003364:	c4a73823          	sd	a0,-944(a4)
  if(np->exec_inode) 
    80003368:	c119                	beqz	a0,8000336e <kfork+0x8c>
    idup(np->exec_inode);
    8000336a:	0a5010ef          	jal	80004c0e <idup>
  np->text_seg = p->text_seg;
    8000336e:	67ad                	lui	a5,0xb
    80003370:	00f98733          	add	a4,s3,a5
    80003374:	97d2                	add	a5,a5,s4
    80003376:	c587b503          	ld	a0,-936(a5) # ac58 <_entry-0x7fff53a8>
    8000337a:	c607b583          	ld	a1,-928(a5)
    8000337e:	c687b603          	ld	a2,-920(a5)
    80003382:	c707b683          	ld	a3,-912(a5)
    80003386:	c4a73c23          	sd	a0,-936(a4)
    8000338a:	c6b73023          	sd	a1,-928(a4)
    8000338e:	c6c73423          	sd	a2,-920(a4)
    80003392:	c6d73823          	sd	a3,-912(a4)
    80003396:	c787b683          	ld	a3,-904(a5)
    8000339a:	c6d73c23          	sd	a3,-904(a4)
  np->data_seg = p->data_seg;
    8000339e:	c807b503          	ld	a0,-896(a5)
    800033a2:	c887b583          	ld	a1,-888(a5)
    800033a6:	c907b603          	ld	a2,-880(a5)
    800033aa:	c987b683          	ld	a3,-872(a5)
    800033ae:	c8a73023          	sd	a0,-896(a4)
    800033b2:	c8b73423          	sd	a1,-888(a4)
    800033b6:	c8c73823          	sd	a2,-880(a4)
    800033ba:	c8d73c23          	sd	a3,-872(a4)
    800033be:	ca07b783          	ld	a5,-864(a5)
    800033c2:	caf73023          	sd	a5,-864(a4)
  *(np->trapframe) = *(p->trapframe);
    800033c6:	058a3683          	ld	a3,88(s4)
    800033ca:	87b6                	mv	a5,a3
    800033cc:	0589b703          	ld	a4,88(s3)
    800033d0:	12068693          	addi	a3,a3,288
    800033d4:	6388                	ld	a0,0(a5)
    800033d6:	678c                	ld	a1,8(a5)
    800033d8:	6b90                	ld	a2,16(a5)
    800033da:	e308                	sd	a0,0(a4)
    800033dc:	e70c                	sd	a1,8(a4)
    800033de:	eb10                	sd	a2,16(a4)
    800033e0:	6f90                	ld	a2,24(a5)
    800033e2:	ef10                	sd	a2,24(a4)
    800033e4:	02078793          	addi	a5,a5,32
    800033e8:	02070713          	addi	a4,a4,32
    800033ec:	fed794e3          	bne	a5,a3,800033d4 <kfork+0xf2>
  np->trapframe->a0 = 0;
    800033f0:	0589b783          	ld	a5,88(s3)
    800033f4:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800033f8:	0d0a0493          	addi	s1,s4,208
    800033fc:	0d098913          	addi	s2,s3,208
    80003400:	150a0a93          	addi	s5,s4,336
    80003404:	a831                	j	80003420 <kfork+0x13e>
    freeproc(np);
    80003406:	854e                	mv	a0,s3
    80003408:	c11ff0ef          	jal	80003018 <freeproc>
    release(&np->lock);
    8000340c:	854e                	mv	a0,s3
    8000340e:	8b3fd0ef          	jal	80000cc0 <release>
    return -1;
    80003412:	54fd                	li	s1,-1
    80003414:	69e2                	ld	s3,24(sp)
    80003416:	a885                	j	80003486 <kfork+0x1a4>
  for(i = 0; i < NOFILE; i++)
    80003418:	04a1                	addi	s1,s1,8
    8000341a:	0921                	addi	s2,s2,8
    8000341c:	01548963          	beq	s1,s5,8000342e <kfork+0x14c>
    if(p->ofile[i])
    80003420:	6088                	ld	a0,0(s1)
    80003422:	d97d                	beqz	a0,80003418 <kfork+0x136>
      np->ofile[i] = filedup(p->ofile[i]);
    80003424:	60a020ef          	jal	80005a2e <filedup>
    80003428:	00a93023          	sd	a0,0(s2)
    8000342c:	b7f5                	j	80003418 <kfork+0x136>
  np->cwd = idup(p->cwd);
    8000342e:	150a3503          	ld	a0,336(s4)
    80003432:	7dc010ef          	jal	80004c0e <idup>
    80003436:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000343a:	4641                	li	a2,16
    8000343c:	158a0593          	addi	a1,s4,344
    80003440:	15898513          	addi	a0,s3,344
    80003444:	a0dfd0ef          	jal	80000e50 <safestrcpy>
  pid = np->pid;
    80003448:	0309a483          	lw	s1,48(s3)
  release(&np->lock);
    8000344c:	854e                	mv	a0,s3
    8000344e:	873fd0ef          	jal	80000cc0 <release>
  acquire(&wait_lock);
    80003452:	00012517          	auipc	a0,0x12
    80003456:	08e50513          	addi	a0,a0,142 # 800154e0 <wait_lock>
    8000345a:	fd2fd0ef          	jal	80000c2c <acquire>
  np->parent = p;
    8000345e:	0349bc23          	sd	s4,56(s3)
  release(&wait_lock);
    80003462:	00012517          	auipc	a0,0x12
    80003466:	07e50513          	addi	a0,a0,126 # 800154e0 <wait_lock>
    8000346a:	857fd0ef          	jal	80000cc0 <release>
  acquire(&np->lock);
    8000346e:	854e                	mv	a0,s3
    80003470:	fbcfd0ef          	jal	80000c2c <acquire>
  np->state = RUNNABLE;
    80003474:	478d                	li	a5,3
    80003476:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    8000347a:	854e                	mv	a0,s3
    8000347c:	845fd0ef          	jal	80000cc0 <release>
  return pid;
    80003480:	7902                	ld	s2,32(sp)
    80003482:	69e2                	ld	s3,24(sp)
    80003484:	6aa2                	ld	s5,8(sp)
}
    80003486:	8526                	mv	a0,s1
    80003488:	70e2                	ld	ra,56(sp)
    8000348a:	7442                	ld	s0,48(sp)
    8000348c:	74a2                	ld	s1,40(sp)
    8000348e:	6a42                	ld	s4,16(sp)
    80003490:	6121                	addi	sp,sp,64
    80003492:	8082                	ret
    return -1;
    80003494:	54fd                	li	s1,-1
    80003496:	bfc5                	j	80003486 <kfork+0x1a4>

0000000080003498 <scheduler>:
{
    80003498:	715d                	addi	sp,sp,-80
    8000349a:	e486                	sd	ra,72(sp)
    8000349c:	e0a2                	sd	s0,64(sp)
    8000349e:	fc26                	sd	s1,56(sp)
    800034a0:	f84a                	sd	s2,48(sp)
    800034a2:	f44e                	sd	s3,40(sp)
    800034a4:	f052                	sd	s4,32(sp)
    800034a6:	ec56                	sd	s5,24(sp)
    800034a8:	e85a                	sd	s6,16(sp)
    800034aa:	e45e                	sd	s7,8(sp)
    800034ac:	e062                	sd	s8,0(sp)
    800034ae:	0880                	addi	s0,sp,80
    800034b0:	8792                	mv	a5,tp
  int id = r_tp();
    800034b2:	2781                	sext.w	a5,a5
  c->proc = 0;
    800034b4:	00779b13          	slli	s6,a5,0x7
    800034b8:	00012717          	auipc	a4,0x12
    800034bc:	01070713          	addi	a4,a4,16 # 800154c8 <pid_lock>
    800034c0:	975a                	add	a4,a4,s6
    800034c2:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    800034c6:	00012717          	auipc	a4,0x12
    800034ca:	03a70713          	addi	a4,a4,58 # 80015500 <cpus+0x8>
    800034ce:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    800034d0:	4c11                	li	s8,4
        c->proc = p;
    800034d2:	079e                	slli	a5,a5,0x7
    800034d4:	00012a17          	auipc	s4,0x12
    800034d8:	ff4a0a13          	addi	s4,s4,-12 # 800154c8 <pid_lock>
    800034dc:	9a3e                	add	s4,s4,a5
        found = 1;
    800034de:	4b85                	li	s7,1
    800034e0:	a091                	j	80003524 <scheduler+0x8c>
      release(&p->lock);
    800034e2:	8526                	mv	a0,s1
    800034e4:	fdcfd0ef          	jal	80000cc0 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800034e8:	94ca                	add	s1,s1,s2
    800034ea:	002c5797          	auipc	a5,0x2c5
    800034ee:	20e78793          	addi	a5,a5,526 # 802c86f8 <tickslock>
    800034f2:	02f48563          	beq	s1,a5,8000351c <scheduler+0x84>
      acquire(&p->lock);
    800034f6:	8526                	mv	a0,s1
    800034f8:	f34fd0ef          	jal	80000c2c <acquire>
      if(p->state == RUNNABLE) {
    800034fc:	4c9c                	lw	a5,24(s1)
    800034fe:	ff3792e3          	bne	a5,s3,800034e2 <scheduler+0x4a>
        p->state = RUNNING;
    80003502:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80003506:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    8000350a:	06048593          	addi	a1,s1,96
    8000350e:	855a                	mv	a0,s6
    80003510:	5de000ef          	jal	80003aee <swtch>
        c->proc = 0;
    80003514:	020a3823          	sd	zero,48(s4)
        found = 1;
    80003518:	8ade                	mv	s5,s7
    8000351a:	b7e1                	j	800034e2 <scheduler+0x4a>
    if(found == 0) {
    8000351c:	000a9463          	bnez	s5,80003524 <scheduler+0x8c>
      asm volatile("wfi");
    80003520:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003524:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003528:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000352c:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003530:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80003534:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003536:	10079073          	csrw	sstatus,a5
    int found = 0;
    8000353a:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    8000353c:	00012497          	auipc	s1,0x12
    80003540:	3bc48493          	addi	s1,s1,956 # 800158f8 <proc>
      if(p->state == RUNNABLE) {
    80003544:	498d                	li	s3,3
    for(p = proc; p < &proc[NPROC]; p++) {
    80003546:	692d                	lui	s2,0xb
    80003548:	cb890913          	addi	s2,s2,-840 # acb8 <_entry-0x7fff5348>
    8000354c:	b76d                	j	800034f6 <scheduler+0x5e>

000000008000354e <sched>:
{
    8000354e:	7179                	addi	sp,sp,-48
    80003550:	f406                	sd	ra,40(sp)
    80003552:	f022                	sd	s0,32(sp)
    80003554:	ec26                	sd	s1,24(sp)
    80003556:	e84a                	sd	s2,16(sp)
    80003558:	e44e                	sd	s3,8(sp)
    8000355a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000355c:	8e9ff0ef          	jal	80002e44 <myproc>
    80003560:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80003562:	e5afd0ef          	jal	80000bbc <holding>
    80003566:	c935                	beqz	a0,800035da <sched+0x8c>
  asm volatile("mv %0, tp" : "=r" (x) );
    80003568:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000356a:	2781                	sext.w	a5,a5
    8000356c:	079e                	slli	a5,a5,0x7
    8000356e:	00012717          	auipc	a4,0x12
    80003572:	f5a70713          	addi	a4,a4,-166 # 800154c8 <pid_lock>
    80003576:	97ba                	add	a5,a5,a4
    80003578:	0a87a703          	lw	a4,168(a5)
    8000357c:	4785                	li	a5,1
    8000357e:	06f71463          	bne	a4,a5,800035e6 <sched+0x98>
  if(p->state == RUNNING)
    80003582:	4c98                	lw	a4,24(s1)
    80003584:	4791                	li	a5,4
    80003586:	06f70663          	beq	a4,a5,800035f2 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000358a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000358e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80003590:	e7bd                	bnez	a5,800035fe <sched+0xb0>
  asm volatile("mv %0, tp" : "=r" (x) );
    80003592:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80003594:	00012917          	auipc	s2,0x12
    80003598:	f3490913          	addi	s2,s2,-204 # 800154c8 <pid_lock>
    8000359c:	2781                	sext.w	a5,a5
    8000359e:	079e                	slli	a5,a5,0x7
    800035a0:	97ca                	add	a5,a5,s2
    800035a2:	0ac7a983          	lw	s3,172(a5)
    800035a6:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800035a8:	2781                	sext.w	a5,a5
    800035aa:	079e                	slli	a5,a5,0x7
    800035ac:	07a1                	addi	a5,a5,8
    800035ae:	00012597          	auipc	a1,0x12
    800035b2:	f4a58593          	addi	a1,a1,-182 # 800154f8 <cpus>
    800035b6:	95be                	add	a1,a1,a5
    800035b8:	06048513          	addi	a0,s1,96
    800035bc:	532000ef          	jal	80003aee <swtch>
    800035c0:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800035c2:	2781                	sext.w	a5,a5
    800035c4:	079e                	slli	a5,a5,0x7
    800035c6:	993e                	add	s2,s2,a5
    800035c8:	0b392623          	sw	s3,172(s2)
}
    800035cc:	70a2                	ld	ra,40(sp)
    800035ce:	7402                	ld	s0,32(sp)
    800035d0:	64e2                	ld	s1,24(sp)
    800035d2:	6942                	ld	s2,16(sp)
    800035d4:	69a2                	ld	s3,8(sp)
    800035d6:	6145                	addi	sp,sp,48
    800035d8:	8082                	ret
    panic("sched p->lock");
    800035da:	00006517          	auipc	a0,0x6
    800035de:	32e50513          	addi	a0,a0,814 # 80009908 <etext+0x908>
    800035e2:	a42fd0ef          	jal	80000824 <panic>
    panic("sched locks");
    800035e6:	00006517          	auipc	a0,0x6
    800035ea:	33250513          	addi	a0,a0,818 # 80009918 <etext+0x918>
    800035ee:	a36fd0ef          	jal	80000824 <panic>
    panic("sched RUNNING");
    800035f2:	00006517          	auipc	a0,0x6
    800035f6:	33650513          	addi	a0,a0,822 # 80009928 <etext+0x928>
    800035fa:	a2afd0ef          	jal	80000824 <panic>
    panic("sched interruptible");
    800035fe:	00006517          	auipc	a0,0x6
    80003602:	33a50513          	addi	a0,a0,826 # 80009938 <etext+0x938>
    80003606:	a1efd0ef          	jal	80000824 <panic>

000000008000360a <yield>:
{
    8000360a:	1101                	addi	sp,sp,-32
    8000360c:	ec06                	sd	ra,24(sp)
    8000360e:	e822                	sd	s0,16(sp)
    80003610:	e426                	sd	s1,8(sp)
    80003612:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80003614:	831ff0ef          	jal	80002e44 <myproc>
    80003618:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000361a:	e12fd0ef          	jal	80000c2c <acquire>
  p->state = RUNNABLE;
    8000361e:	478d                	li	a5,3
    80003620:	cc9c                	sw	a5,24(s1)
  sched();
    80003622:	f2dff0ef          	jal	8000354e <sched>
  release(&p->lock);
    80003626:	8526                	mv	a0,s1
    80003628:	e98fd0ef          	jal	80000cc0 <release>
}
    8000362c:	60e2                	ld	ra,24(sp)
    8000362e:	6442                	ld	s0,16(sp)
    80003630:	64a2                	ld	s1,8(sp)
    80003632:	6105                	addi	sp,sp,32
    80003634:	8082                	ret

0000000080003636 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80003636:	7179                	addi	sp,sp,-48
    80003638:	f406                	sd	ra,40(sp)
    8000363a:	f022                	sd	s0,32(sp)
    8000363c:	ec26                	sd	s1,24(sp)
    8000363e:	e84a                	sd	s2,16(sp)
    80003640:	e44e                	sd	s3,8(sp)
    80003642:	1800                	addi	s0,sp,48
    80003644:	89aa                	mv	s3,a0
    80003646:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003648:	ffcff0ef          	jal	80002e44 <myproc>
    8000364c:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000364e:	ddefd0ef          	jal	80000c2c <acquire>
  release(lk);
    80003652:	854a                	mv	a0,s2
    80003654:	e6cfd0ef          	jal	80000cc0 <release>

  // Go to sleep.
  p->chan = chan;
    80003658:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000365c:	4789                	li	a5,2
    8000365e:	cc9c                	sw	a5,24(s1)

  sched();
    80003660:	eefff0ef          	jal	8000354e <sched>

  // Tidy up.
  p->chan = 0;
    80003664:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80003668:	8526                	mv	a0,s1
    8000366a:	e56fd0ef          	jal	80000cc0 <release>
  acquire(lk);
    8000366e:	854a                	mv	a0,s2
    80003670:	dbcfd0ef          	jal	80000c2c <acquire>
}
    80003674:	70a2                	ld	ra,40(sp)
    80003676:	7402                	ld	s0,32(sp)
    80003678:	64e2                	ld	s1,24(sp)
    8000367a:	6942                	ld	s2,16(sp)
    8000367c:	69a2                	ld	s3,8(sp)
    8000367e:	6145                	addi	sp,sp,48
    80003680:	8082                	ret

0000000080003682 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80003682:	7139                	addi	sp,sp,-64
    80003684:	fc06                	sd	ra,56(sp)
    80003686:	f822                	sd	s0,48(sp)
    80003688:	f426                	sd	s1,40(sp)
    8000368a:	f04a                	sd	s2,32(sp)
    8000368c:	ec4e                	sd	s3,24(sp)
    8000368e:	e852                	sd	s4,16(sp)
    80003690:	e456                	sd	s5,8(sp)
    80003692:	e05a                	sd	s6,0(sp)
    80003694:	0080                	addi	s0,sp,64
    80003696:	8aaa                	mv	s5,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80003698:	00012497          	auipc	s1,0x12
    8000369c:	26048493          	addi	s1,s1,608 # 800158f8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800036a0:	4a09                	li	s4,2
        p->state = RUNNABLE;
    800036a2:	4b0d                	li	s6,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800036a4:	692d                	lui	s2,0xb
    800036a6:	cb890913          	addi	s2,s2,-840 # acb8 <_entry-0x7fff5348>
    800036aa:	002c5997          	auipc	s3,0x2c5
    800036ae:	04e98993          	addi	s3,s3,78 # 802c86f8 <tickslock>
    800036b2:	a039                	j	800036c0 <wakeup+0x3e>
      }
      release(&p->lock);
    800036b4:	8526                	mv	a0,s1
    800036b6:	e0afd0ef          	jal	80000cc0 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800036ba:	94ca                	add	s1,s1,s2
    800036bc:	03348263          	beq	s1,s3,800036e0 <wakeup+0x5e>
    if(p != myproc()){
    800036c0:	f84ff0ef          	jal	80002e44 <myproc>
    800036c4:	fe950be3          	beq	a0,s1,800036ba <wakeup+0x38>
      acquire(&p->lock);
    800036c8:	8526                	mv	a0,s1
    800036ca:	d62fd0ef          	jal	80000c2c <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800036ce:	4c9c                	lw	a5,24(s1)
    800036d0:	ff4792e3          	bne	a5,s4,800036b4 <wakeup+0x32>
    800036d4:	709c                	ld	a5,32(s1)
    800036d6:	fd579fe3          	bne	a5,s5,800036b4 <wakeup+0x32>
        p->state = RUNNABLE;
    800036da:	0164ac23          	sw	s6,24(s1)
    800036de:	bfd9                	j	800036b4 <wakeup+0x32>
    }
  }
}
    800036e0:	70e2                	ld	ra,56(sp)
    800036e2:	7442                	ld	s0,48(sp)
    800036e4:	74a2                	ld	s1,40(sp)
    800036e6:	7902                	ld	s2,32(sp)
    800036e8:	69e2                	ld	s3,24(sp)
    800036ea:	6a42                	ld	s4,16(sp)
    800036ec:	6aa2                	ld	s5,8(sp)
    800036ee:	6b02                	ld	s6,0(sp)
    800036f0:	6121                	addi	sp,sp,64
    800036f2:	8082                	ret

00000000800036f4 <reparent>:
{
    800036f4:	7139                	addi	sp,sp,-64
    800036f6:	fc06                	sd	ra,56(sp)
    800036f8:	f822                	sd	s0,48(sp)
    800036fa:	f426                	sd	s1,40(sp)
    800036fc:	f04a                	sd	s2,32(sp)
    800036fe:	ec4e                	sd	s3,24(sp)
    80003700:	e852                	sd	s4,16(sp)
    80003702:	e456                	sd	s5,8(sp)
    80003704:	0080                	addi	s0,sp,64
    80003706:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80003708:	00012497          	auipc	s1,0x12
    8000370c:	1f048493          	addi	s1,s1,496 # 800158f8 <proc>
      pp->parent = initproc;
    80003710:	0000aa97          	auipc	s5,0xa
    80003714:	cb0a8a93          	addi	s5,s5,-848 # 8000d3c0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80003718:	692d                	lui	s2,0xb
    8000371a:	cb890913          	addi	s2,s2,-840 # acb8 <_entry-0x7fff5348>
    8000371e:	002c5a17          	auipc	s4,0x2c5
    80003722:	fdaa0a13          	addi	s4,s4,-38 # 802c86f8 <tickslock>
    80003726:	a021                	j	8000372e <reparent+0x3a>
    80003728:	94ca                	add	s1,s1,s2
    8000372a:	01448b63          	beq	s1,s4,80003740 <reparent+0x4c>
    if(pp->parent == p){
    8000372e:	7c9c                	ld	a5,56(s1)
    80003730:	ff379ce3          	bne	a5,s3,80003728 <reparent+0x34>
      pp->parent = initproc;
    80003734:	000ab503          	ld	a0,0(s5)
    80003738:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000373a:	f49ff0ef          	jal	80003682 <wakeup>
    8000373e:	b7ed                	j	80003728 <reparent+0x34>
}
    80003740:	70e2                	ld	ra,56(sp)
    80003742:	7442                	ld	s0,48(sp)
    80003744:	74a2                	ld	s1,40(sp)
    80003746:	7902                	ld	s2,32(sp)
    80003748:	69e2                	ld	s3,24(sp)
    8000374a:	6a42                	ld	s4,16(sp)
    8000374c:	6aa2                	ld	s5,8(sp)
    8000374e:	6121                	addi	sp,sp,64
    80003750:	8082                	ret

0000000080003752 <kexit>:
{
    80003752:	7179                	addi	sp,sp,-48
    80003754:	f406                	sd	ra,40(sp)
    80003756:	f022                	sd	s0,32(sp)
    80003758:	ec26                	sd	s1,24(sp)
    8000375a:	e84a                	sd	s2,16(sp)
    8000375c:	e44e                	sd	s3,8(sp)
    8000375e:	e052                	sd	s4,0(sp)
    80003760:	1800                	addi	s0,sp,48
    80003762:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80003764:	ee0ff0ef          	jal	80002e44 <myproc>
    80003768:	89aa                	mv	s3,a0
  if(p == initproc)
    8000376a:	0000a797          	auipc	a5,0xa
    8000376e:	c567b783          	ld	a5,-938(a5) # 8000d3c0 <initproc>
    80003772:	0d050493          	addi	s1,a0,208
    80003776:	15050913          	addi	s2,a0,336
    8000377a:	00a79b63          	bne	a5,a0,80003790 <kexit+0x3e>
    panic("init exiting");
    8000377e:	00006517          	auipc	a0,0x6
    80003782:	1d250513          	addi	a0,a0,466 # 80009950 <etext+0x950>
    80003786:	89efd0ef          	jal	80000824 <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    8000378a:	04a1                	addi	s1,s1,8
    8000378c:	01248963          	beq	s1,s2,8000379e <kexit+0x4c>
    if(p->ofile[fd]){
    80003790:	6088                	ld	a0,0(s1)
    80003792:	dd65                	beqz	a0,8000378a <kexit+0x38>
      fileclose(f);
    80003794:	2e0020ef          	jal	80005a74 <fileclose>
      p->ofile[fd] = 0;
    80003798:	0004b023          	sd	zero,0(s1)
    8000379c:	b7fd                	j	8000378a <kexit+0x38>
  begin_op();
    8000379e:	6b3010ef          	jal	80005650 <begin_op>
  iput(p->cwd);
    800037a2:	1509b503          	ld	a0,336(s3)
    800037a6:	620010ef          	jal	80004dc6 <iput>
  end_op();
    800037aa:	717010ef          	jal	800056c0 <end_op>
  p->cwd = 0;
    800037ae:	1409b823          	sd	zero,336(s3)
  cleanup_swap_file();
    800037b2:	bb2ff0ef          	jal	80002b64 <cleanup_swap_file>
  acquire(&wait_lock);
    800037b6:	00012517          	auipc	a0,0x12
    800037ba:	d2a50513          	addi	a0,a0,-726 # 800154e0 <wait_lock>
    800037be:	c6efd0ef          	jal	80000c2c <acquire>
  reparent(p);
    800037c2:	854e                	mv	a0,s3
    800037c4:	f31ff0ef          	jal	800036f4 <reparent>
  wakeup(p->parent);
    800037c8:	0389b503          	ld	a0,56(s3)
    800037cc:	eb7ff0ef          	jal	80003682 <wakeup>
  acquire(&p->lock);
    800037d0:	854e                	mv	a0,s3
    800037d2:	c5afd0ef          	jal	80000c2c <acquire>
  p->xstate = status;
    800037d6:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800037da:	4795                	li	a5,5
    800037dc:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800037e0:	00012517          	auipc	a0,0x12
    800037e4:	d0050513          	addi	a0,a0,-768 # 800154e0 <wait_lock>
    800037e8:	cd8fd0ef          	jal	80000cc0 <release>
  sched();
    800037ec:	d63ff0ef          	jal	8000354e <sched>
  panic("zombie exit");
    800037f0:	00006517          	auipc	a0,0x6
    800037f4:	17050513          	addi	a0,a0,368 # 80009960 <etext+0x960>
    800037f8:	82cfd0ef          	jal	80000824 <panic>

00000000800037fc <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800037fc:	7179                	addi	sp,sp,-48
    800037fe:	f406                	sd	ra,40(sp)
    80003800:	f022                	sd	s0,32(sp)
    80003802:	ec26                	sd	s1,24(sp)
    80003804:	e84a                	sd	s2,16(sp)
    80003806:	e44e                	sd	s3,8(sp)
    80003808:	e052                	sd	s4,0(sp)
    8000380a:	1800                	addi	s0,sp,48
    8000380c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000380e:	00012497          	auipc	s1,0x12
    80003812:	0ea48493          	addi	s1,s1,234 # 800158f8 <proc>
    80003816:	69ad                	lui	s3,0xb
    80003818:	cb898993          	addi	s3,s3,-840 # acb8 <_entry-0x7fff5348>
    8000381c:	002c5a17          	auipc	s4,0x2c5
    80003820:	edca0a13          	addi	s4,s4,-292 # 802c86f8 <tickslock>
    acquire(&p->lock);
    80003824:	8526                	mv	a0,s1
    80003826:	c06fd0ef          	jal	80000c2c <acquire>
    if(p->pid == pid){
    8000382a:	589c                	lw	a5,48(s1)
    8000382c:	01278a63          	beq	a5,s2,80003840 <kkill+0x44>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80003830:	8526                	mv	a0,s1
    80003832:	c8efd0ef          	jal	80000cc0 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80003836:	94ce                	add	s1,s1,s3
    80003838:	ff4496e3          	bne	s1,s4,80003824 <kkill+0x28>
  }
  return -1;
    8000383c:	557d                	li	a0,-1
    8000383e:	a819                	j	80003854 <kkill+0x58>
      p->killed = 1;
    80003840:	4785                	li	a5,1
    80003842:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80003844:	4c98                	lw	a4,24(s1)
    80003846:	4789                	li	a5,2
    80003848:	00f70e63          	beq	a4,a5,80003864 <kkill+0x68>
      release(&p->lock);
    8000384c:	8526                	mv	a0,s1
    8000384e:	c72fd0ef          	jal	80000cc0 <release>
      return 0;
    80003852:	4501                	li	a0,0
}
    80003854:	70a2                	ld	ra,40(sp)
    80003856:	7402                	ld	s0,32(sp)
    80003858:	64e2                	ld	s1,24(sp)
    8000385a:	6942                	ld	s2,16(sp)
    8000385c:	69a2                	ld	s3,8(sp)
    8000385e:	6a02                	ld	s4,0(sp)
    80003860:	6145                	addi	sp,sp,48
    80003862:	8082                	ret
        p->state = RUNNABLE;
    80003864:	478d                	li	a5,3
    80003866:	cc9c                	sw	a5,24(s1)
    80003868:	b7d5                	j	8000384c <kkill+0x50>

000000008000386a <setkilled>:

void
setkilled(struct proc *p)
{
    8000386a:	1101                	addi	sp,sp,-32
    8000386c:	ec06                	sd	ra,24(sp)
    8000386e:	e822                	sd	s0,16(sp)
    80003870:	e426                	sd	s1,8(sp)
    80003872:	1000                	addi	s0,sp,32
    80003874:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80003876:	bb6fd0ef          	jal	80000c2c <acquire>
  p->killed = 1;
    8000387a:	4785                	li	a5,1
    8000387c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000387e:	8526                	mv	a0,s1
    80003880:	c40fd0ef          	jal	80000cc0 <release>
}
    80003884:	60e2                	ld	ra,24(sp)
    80003886:	6442                	ld	s0,16(sp)
    80003888:	64a2                	ld	s1,8(sp)
    8000388a:	6105                	addi	sp,sp,32
    8000388c:	8082                	ret

000000008000388e <killed>:

int
killed(struct proc *p)
{
    8000388e:	1101                	addi	sp,sp,-32
    80003890:	ec06                	sd	ra,24(sp)
    80003892:	e822                	sd	s0,16(sp)
    80003894:	e426                	sd	s1,8(sp)
    80003896:	e04a                	sd	s2,0(sp)
    80003898:	1000                	addi	s0,sp,32
    8000389a:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000389c:	b90fd0ef          	jal	80000c2c <acquire>
  k = p->killed;
    800038a0:	549c                	lw	a5,40(s1)
    800038a2:	893e                	mv	s2,a5
  release(&p->lock);
    800038a4:	8526                	mv	a0,s1
    800038a6:	c1afd0ef          	jal	80000cc0 <release>
  return k;
}
    800038aa:	854a                	mv	a0,s2
    800038ac:	60e2                	ld	ra,24(sp)
    800038ae:	6442                	ld	s0,16(sp)
    800038b0:	64a2                	ld	s1,8(sp)
    800038b2:	6902                	ld	s2,0(sp)
    800038b4:	6105                	addi	sp,sp,32
    800038b6:	8082                	ret

00000000800038b8 <kwait>:
{
    800038b8:	715d                	addi	sp,sp,-80
    800038ba:	e486                	sd	ra,72(sp)
    800038bc:	e0a2                	sd	s0,64(sp)
    800038be:	fc26                	sd	s1,56(sp)
    800038c0:	f84a                	sd	s2,48(sp)
    800038c2:	f44e                	sd	s3,40(sp)
    800038c4:	f052                	sd	s4,32(sp)
    800038c6:	ec56                	sd	s5,24(sp)
    800038c8:	e85a                	sd	s6,16(sp)
    800038ca:	e45e                	sd	s7,8(sp)
    800038cc:	0880                	addi	s0,sp,80
    800038ce:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800038d0:	d74ff0ef          	jal	80002e44 <myproc>
    800038d4:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800038d6:	00012517          	auipc	a0,0x12
    800038da:	c0a50513          	addi	a0,a0,-1014 # 800154e0 <wait_lock>
    800038de:	b4efd0ef          	jal	80000c2c <acquire>
        if(pp->state == ZOMBIE){
    800038e2:	4a95                	li	s5,5
        havekids = 1;
    800038e4:	4b05                	li	s6,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800038e6:	69ad                	lui	s3,0xb
    800038e8:	cb898993          	addi	s3,s3,-840 # acb8 <_entry-0x7fff5348>
    800038ec:	002c5a17          	auipc	s4,0x2c5
    800038f0:	e0ca0a13          	addi	s4,s4,-500 # 802c86f8 <tickslock>
    800038f4:	a879                	j	80003992 <kwait+0xda>
          pid = pp->pid;
    800038f6:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800038fa:	000b8c63          	beqz	s7,80003912 <kwait+0x5a>
    800038fe:	4691                	li	a3,4
    80003900:	02c48613          	addi	a2,s1,44
    80003904:	85de                	mv	a1,s7
    80003906:	05093503          	ld	a0,80(s2)
    8000390a:	f77fe0ef          	jal	80002880 <copyout>
    8000390e:	02054a63          	bltz	a0,80003942 <kwait+0x8a>
          freeproc(pp);
    80003912:	8526                	mv	a0,s1
    80003914:	f04ff0ef          	jal	80003018 <freeproc>
          release(&pp->lock);
    80003918:	8526                	mv	a0,s1
    8000391a:	ba6fd0ef          	jal	80000cc0 <release>
          release(&wait_lock);
    8000391e:	00012517          	auipc	a0,0x12
    80003922:	bc250513          	addi	a0,a0,-1086 # 800154e0 <wait_lock>
    80003926:	b9afd0ef          	jal	80000cc0 <release>
}
    8000392a:	854e                	mv	a0,s3
    8000392c:	60a6                	ld	ra,72(sp)
    8000392e:	6406                	ld	s0,64(sp)
    80003930:	74e2                	ld	s1,56(sp)
    80003932:	7942                	ld	s2,48(sp)
    80003934:	79a2                	ld	s3,40(sp)
    80003936:	7a02                	ld	s4,32(sp)
    80003938:	6ae2                	ld	s5,24(sp)
    8000393a:	6b42                	ld	s6,16(sp)
    8000393c:	6ba2                	ld	s7,8(sp)
    8000393e:	6161                	addi	sp,sp,80
    80003940:	8082                	ret
            release(&pp->lock);
    80003942:	8526                	mv	a0,s1
    80003944:	b7cfd0ef          	jal	80000cc0 <release>
            release(&wait_lock);
    80003948:	00012517          	auipc	a0,0x12
    8000394c:	b9850513          	addi	a0,a0,-1128 # 800154e0 <wait_lock>
    80003950:	b70fd0ef          	jal	80000cc0 <release>
            return -1;
    80003954:	59fd                	li	s3,-1
    80003956:	bfd1                	j	8000392a <kwait+0x72>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80003958:	94ce                	add	s1,s1,s3
    8000395a:	03448063          	beq	s1,s4,8000397a <kwait+0xc2>
      if(pp->parent == p){
    8000395e:	7c9c                	ld	a5,56(s1)
    80003960:	ff279ce3          	bne	a5,s2,80003958 <kwait+0xa0>
        acquire(&pp->lock);
    80003964:	8526                	mv	a0,s1
    80003966:	ac6fd0ef          	jal	80000c2c <acquire>
        if(pp->state == ZOMBIE){
    8000396a:	4c9c                	lw	a5,24(s1)
    8000396c:	f95785e3          	beq	a5,s5,800038f6 <kwait+0x3e>
        release(&pp->lock);
    80003970:	8526                	mv	a0,s1
    80003972:	b4efd0ef          	jal	80000cc0 <release>
        havekids = 1;
    80003976:	875a                	mv	a4,s6
    80003978:	b7c5                	j	80003958 <kwait+0xa0>
    if(!havekids || killed(p)){
    8000397a:	c315                	beqz	a4,8000399e <kwait+0xe6>
    8000397c:	854a                	mv	a0,s2
    8000397e:	f11ff0ef          	jal	8000388e <killed>
    80003982:	ed11                	bnez	a0,8000399e <kwait+0xe6>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80003984:	00012597          	auipc	a1,0x12
    80003988:	b5c58593          	addi	a1,a1,-1188 # 800154e0 <wait_lock>
    8000398c:	854a                	mv	a0,s2
    8000398e:	ca9ff0ef          	jal	80003636 <sleep>
    havekids = 0;
    80003992:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80003994:	00012497          	auipc	s1,0x12
    80003998:	f6448493          	addi	s1,s1,-156 # 800158f8 <proc>
    8000399c:	b7c9                	j	8000395e <kwait+0xa6>
      release(&wait_lock);
    8000399e:	00012517          	auipc	a0,0x12
    800039a2:	b4250513          	addi	a0,a0,-1214 # 800154e0 <wait_lock>
    800039a6:	b1afd0ef          	jal	80000cc0 <release>
      return -1;
    800039aa:	59fd                	li	s3,-1
    800039ac:	bfbd                	j	8000392a <kwait+0x72>

00000000800039ae <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800039ae:	7179                	addi	sp,sp,-48
    800039b0:	f406                	sd	ra,40(sp)
    800039b2:	f022                	sd	s0,32(sp)
    800039b4:	ec26                	sd	s1,24(sp)
    800039b6:	e84a                	sd	s2,16(sp)
    800039b8:	e44e                	sd	s3,8(sp)
    800039ba:	e052                	sd	s4,0(sp)
    800039bc:	1800                	addi	s0,sp,48
    800039be:	84aa                	mv	s1,a0
    800039c0:	8a2e                	mv	s4,a1
    800039c2:	89b2                	mv	s3,a2
    800039c4:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800039c6:	c7eff0ef          	jal	80002e44 <myproc>
  if(user_dst){
    800039ca:	cc99                	beqz	s1,800039e8 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800039cc:	86ca                	mv	a3,s2
    800039ce:	864e                	mv	a2,s3
    800039d0:	85d2                	mv	a1,s4
    800039d2:	6928                	ld	a0,80(a0)
    800039d4:	eadfe0ef          	jal	80002880 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800039d8:	70a2                	ld	ra,40(sp)
    800039da:	7402                	ld	s0,32(sp)
    800039dc:	64e2                	ld	s1,24(sp)
    800039de:	6942                	ld	s2,16(sp)
    800039e0:	69a2                	ld	s3,8(sp)
    800039e2:	6a02                	ld	s4,0(sp)
    800039e4:	6145                	addi	sp,sp,48
    800039e6:	8082                	ret
    memmove((char *)dst, src, len);
    800039e8:	0009061b          	sext.w	a2,s2
    800039ec:	85ce                	mv	a1,s3
    800039ee:	8552                	mv	a0,s4
    800039f0:	b6cfd0ef          	jal	80000d5c <memmove>
    return 0;
    800039f4:	8526                	mv	a0,s1
    800039f6:	b7cd                	j	800039d8 <either_copyout+0x2a>

00000000800039f8 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800039f8:	7179                	addi	sp,sp,-48
    800039fa:	f406                	sd	ra,40(sp)
    800039fc:	f022                	sd	s0,32(sp)
    800039fe:	ec26                	sd	s1,24(sp)
    80003a00:	e84a                	sd	s2,16(sp)
    80003a02:	e44e                	sd	s3,8(sp)
    80003a04:	e052                	sd	s4,0(sp)
    80003a06:	1800                	addi	s0,sp,48
    80003a08:	8a2a                	mv	s4,a0
    80003a0a:	84ae                	mv	s1,a1
    80003a0c:	89b2                	mv	s3,a2
    80003a0e:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80003a10:	c34ff0ef          	jal	80002e44 <myproc>
  if(user_src){
    80003a14:	cc99                	beqz	s1,80003a32 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80003a16:	86ca                	mv	a3,s2
    80003a18:	864e                	mv	a2,s3
    80003a1a:	85d2                	mv	a1,s4
    80003a1c:	6928                	ld	a0,80(a0)
    80003a1e:	ff7fe0ef          	jal	80002a14 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80003a22:	70a2                	ld	ra,40(sp)
    80003a24:	7402                	ld	s0,32(sp)
    80003a26:	64e2                	ld	s1,24(sp)
    80003a28:	6942                	ld	s2,16(sp)
    80003a2a:	69a2                	ld	s3,8(sp)
    80003a2c:	6a02                	ld	s4,0(sp)
    80003a2e:	6145                	addi	sp,sp,48
    80003a30:	8082                	ret
    memmove(dst, (char*)src, len);
    80003a32:	0009061b          	sext.w	a2,s2
    80003a36:	85ce                	mv	a1,s3
    80003a38:	8552                	mv	a0,s4
    80003a3a:	b22fd0ef          	jal	80000d5c <memmove>
    return 0;
    80003a3e:	8526                	mv	a0,s1
    80003a40:	b7cd                	j	80003a22 <either_copyin+0x2a>

0000000080003a42 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80003a42:	715d                	addi	sp,sp,-80
    80003a44:	e486                	sd	ra,72(sp)
    80003a46:	e0a2                	sd	s0,64(sp)
    80003a48:	fc26                	sd	s1,56(sp)
    80003a4a:	f84a                	sd	s2,48(sp)
    80003a4c:	f44e                	sd	s3,40(sp)
    80003a4e:	f052                	sd	s4,32(sp)
    80003a50:	ec56                	sd	s5,24(sp)
    80003a52:	e85a                	sd	s6,16(sp)
    80003a54:	e45e                	sd	s7,8(sp)
    80003a56:	e062                	sd	s8,0(sp)
    80003a58:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80003a5a:	00005517          	auipc	a0,0x5
    80003a5e:	61e50513          	addi	a0,a0,1566 # 80009078 <etext+0x78>
    80003a62:	a99fc0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80003a66:	00012497          	auipc	s1,0x12
    80003a6a:	fea48493          	addi	s1,s1,-22 # 80015a50 <proc+0x158>
    80003a6e:	002c5997          	auipc	s3,0x2c5
    80003a72:	de298993          	addi	s3,s3,-542 # 802c8850 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80003a76:	4b95                	li	s7,5
      state = states[p->state];
    else
      state = "???";
    80003a78:	00006a17          	auipc	s4,0x6
    80003a7c:	ef8a0a13          	addi	s4,s4,-264 # 80009970 <etext+0x970>
    printf("%d %s %s", p->pid, state, p->name);
    80003a80:	00006b17          	auipc	s6,0x6
    80003a84:	ef8b0b13          	addi	s6,s6,-264 # 80009978 <etext+0x978>
    printf("\n");
    80003a88:	00005a97          	auipc	s5,0x5
    80003a8c:	5f0a8a93          	addi	s5,s5,1520 # 80009078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80003a90:	00006c17          	auipc	s8,0x6
    80003a94:	7d8c0c13          	addi	s8,s8,2008 # 8000a268 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    80003a98:	692d                	lui	s2,0xb
    80003a9a:	cb890913          	addi	s2,s2,-840 # acb8 <_entry-0x7fff5348>
    80003a9e:	a821                	j	80003ab6 <procdump+0x74>
    printf("%d %s %s", p->pid, state, p->name);
    80003aa0:	ed86a583          	lw	a1,-296(a3)
    80003aa4:	855a                	mv	a0,s6
    80003aa6:	a55fc0ef          	jal	800004fa <printf>
    printf("\n");
    80003aaa:	8556                	mv	a0,s5
    80003aac:	a4ffc0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80003ab0:	94ca                	add	s1,s1,s2
    80003ab2:	03348263          	beq	s1,s3,80003ad6 <procdump+0x94>
    if(p->state == UNUSED)
    80003ab6:	86a6                	mv	a3,s1
    80003ab8:	ec04a783          	lw	a5,-320(s1)
    80003abc:	dbf5                	beqz	a5,80003ab0 <procdump+0x6e>
      state = "???";
    80003abe:	8652                	mv	a2,s4
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80003ac0:	fefbe0e3          	bltu	s7,a5,80003aa0 <procdump+0x5e>
    80003ac4:	02079713          	slli	a4,a5,0x20
    80003ac8:	01d75793          	srli	a5,a4,0x1d
    80003acc:	97e2                	add	a5,a5,s8
    80003ace:	6390                	ld	a2,0(a5)
    80003ad0:	fa61                	bnez	a2,80003aa0 <procdump+0x5e>
      state = "???";
    80003ad2:	8652                	mv	a2,s4
    80003ad4:	b7f1                	j	80003aa0 <procdump+0x5e>
  }
}
    80003ad6:	60a6                	ld	ra,72(sp)
    80003ad8:	6406                	ld	s0,64(sp)
    80003ada:	74e2                	ld	s1,56(sp)
    80003adc:	7942                	ld	s2,48(sp)
    80003ade:	79a2                	ld	s3,40(sp)
    80003ae0:	7a02                	ld	s4,32(sp)
    80003ae2:	6ae2                	ld	s5,24(sp)
    80003ae4:	6b42                	ld	s6,16(sp)
    80003ae6:	6ba2                	ld	s7,8(sp)
    80003ae8:	6c02                	ld	s8,0(sp)
    80003aea:	6161                	addi	sp,sp,80
    80003aec:	8082                	ret

0000000080003aee <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80003aee:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80003af2:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80003af6:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80003af8:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80003afa:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80003afe:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80003b02:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80003b06:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80003b0a:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80003b0e:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80003b12:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80003b16:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80003b1a:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80003b1e:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80003b22:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80003b26:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80003b2a:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80003b2c:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80003b2e:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80003b32:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80003b36:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80003b3a:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80003b3e:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80003b42:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80003b46:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80003b4a:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80003b4e:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80003b52:	0685bd83          	ld	s11,104(a1)
        
        ret
    80003b56:	8082                	ret

0000000080003b58 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80003b58:	1141                	addi	sp,sp,-16
    80003b5a:	e406                	sd	ra,8(sp)
    80003b5c:	e022                	sd	s0,0(sp)
    80003b5e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80003b60:	00006597          	auipc	a1,0x6
    80003b64:	e5858593          	addi	a1,a1,-424 # 800099b8 <etext+0x9b8>
    80003b68:	002c5517          	auipc	a0,0x2c5
    80003b6c:	b9050513          	addi	a0,a0,-1136 # 802c86f8 <tickslock>
    80003b70:	832fd0ef          	jal	80000ba2 <initlock>
}
    80003b74:	60a2                	ld	ra,8(sp)
    80003b76:	6402                	ld	s0,0(sp)
    80003b78:	0141                	addi	sp,sp,16
    80003b7a:	8082                	ret

0000000080003b7c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80003b7c:	1141                	addi	sp,sp,-16
    80003b7e:	e406                	sd	ra,8(sp)
    80003b80:	e022                	sd	s0,0(sp)
    80003b82:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003b84:	00003797          	auipc	a5,0x3
    80003b88:	4dc78793          	addi	a5,a5,1244 # 80007060 <kernelvec>
    80003b8c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80003b90:	60a2                	ld	ra,8(sp)
    80003b92:	6402                	ld	s0,0(sp)
    80003b94:	0141                	addi	sp,sp,16
    80003b96:	8082                	ret

0000000080003b98 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80003b98:	1141                	addi	sp,sp,-16
    80003b9a:	e406                	sd	ra,8(sp)
    80003b9c:	e022                	sd	s0,0(sp)
    80003b9e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80003ba0:	aa4ff0ef          	jal	80002e44 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003ba4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80003ba8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003baa:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80003bae:	04000737          	lui	a4,0x4000
    80003bb2:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80003bb4:	0732                	slli	a4,a4,0xc
    80003bb6:	00004797          	auipc	a5,0x4
    80003bba:	44a78793          	addi	a5,a5,1098 # 80008000 <_trampoline>
    80003bbe:	00004697          	auipc	a3,0x4
    80003bc2:	44268693          	addi	a3,a3,1090 # 80008000 <_trampoline>
    80003bc6:	8f95                	sub	a5,a5,a3
    80003bc8:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003bca:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80003bce:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80003bd0:	18002773          	csrr	a4,satp
    80003bd4:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80003bd6:	6d38                	ld	a4,88(a0)
    80003bd8:	613c                	ld	a5,64(a0)
    80003bda:	6685                	lui	a3,0x1
    80003bdc:	97b6                	add	a5,a5,a3
    80003bde:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80003be0:	6d3c                	ld	a5,88(a0)
    80003be2:	00000717          	auipc	a4,0x0
    80003be6:	0fc70713          	addi	a4,a4,252 # 80003cde <usertrap>
    80003bea:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80003bec:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80003bee:	8712                	mv	a4,tp
    80003bf0:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003bf2:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80003bf6:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80003bfa:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003bfe:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80003c02:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003c04:	6f9c                	ld	a5,24(a5)
    80003c06:	14179073          	csrw	sepc,a5
}
    80003c0a:	60a2                	ld	ra,8(sp)
    80003c0c:	6402                	ld	s0,0(sp)
    80003c0e:	0141                	addi	sp,sp,16
    80003c10:	8082                	ret

0000000080003c12 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80003c12:	1141                	addi	sp,sp,-16
    80003c14:	e406                	sd	ra,8(sp)
    80003c16:	e022                	sd	s0,0(sp)
    80003c18:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80003c1a:	9f6ff0ef          	jal	80002e10 <cpuid>
    80003c1e:	cd11                	beqz	a0,80003c3a <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80003c20:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80003c24:	000f4737          	lui	a4,0xf4
    80003c28:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80003c2c:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80003c2e:	14d79073          	csrw	stimecmp,a5
}
    80003c32:	60a2                	ld	ra,8(sp)
    80003c34:	6402                	ld	s0,0(sp)
    80003c36:	0141                	addi	sp,sp,16
    80003c38:	8082                	ret
    acquire(&tickslock);
    80003c3a:	002c5517          	auipc	a0,0x2c5
    80003c3e:	abe50513          	addi	a0,a0,-1346 # 802c86f8 <tickslock>
    80003c42:	febfc0ef          	jal	80000c2c <acquire>
    ticks++;
    80003c46:	00009717          	auipc	a4,0x9
    80003c4a:	78270713          	addi	a4,a4,1922 # 8000d3c8 <ticks>
    80003c4e:	431c                	lw	a5,0(a4)
    80003c50:	2785                	addiw	a5,a5,1
    80003c52:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80003c54:	853a                	mv	a0,a4
    80003c56:	a2dff0ef          	jal	80003682 <wakeup>
    release(&tickslock);
    80003c5a:	002c5517          	auipc	a0,0x2c5
    80003c5e:	a9e50513          	addi	a0,a0,-1378 # 802c86f8 <tickslock>
    80003c62:	85efd0ef          	jal	80000cc0 <release>
    80003c66:	bf6d                	j	80003c20 <clockintr+0xe>

0000000080003c68 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80003c68:	1101                	addi	sp,sp,-32
    80003c6a:	ec06                	sd	ra,24(sp)
    80003c6c:	e822                	sd	s0,16(sp)
    80003c6e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003c70:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80003c74:	57fd                	li	a5,-1
    80003c76:	17fe                	slli	a5,a5,0x3f
    80003c78:	07a5                	addi	a5,a5,9
    80003c7a:	00f70c63          	beq	a4,a5,80003c92 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80003c7e:	57fd                	li	a5,-1
    80003c80:	17fe                	slli	a5,a5,0x3f
    80003c82:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80003c84:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80003c86:	04f70863          	beq	a4,a5,80003cd6 <devintr+0x6e>
  }
}
    80003c8a:	60e2                	ld	ra,24(sp)
    80003c8c:	6442                	ld	s0,16(sp)
    80003c8e:	6105                	addi	sp,sp,32
    80003c90:	8082                	ret
    80003c92:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80003c94:	478030ef          	jal	8000710c <plic_claim>
    80003c98:	872a                	mv	a4,a0
    80003c9a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80003c9c:	47a9                	li	a5,10
    80003c9e:	00f50963          	beq	a0,a5,80003cb0 <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    80003ca2:	4785                	li	a5,1
    80003ca4:	00f50963          	beq	a0,a5,80003cb6 <devintr+0x4e>
    return 1;
    80003ca8:	4505                	li	a0,1
    } else if(irq){
    80003caa:	eb09                	bnez	a4,80003cbc <devintr+0x54>
    80003cac:	64a2                	ld	s1,8(sp)
    80003cae:	bff1                	j	80003c8a <devintr+0x22>
      uartintr();
    80003cb0:	d45fc0ef          	jal	800009f4 <uartintr>
    if(irq)
    80003cb4:	a819                	j	80003cca <devintr+0x62>
      virtio_disk_intr();
    80003cb6:	0ed030ef          	jal	800075a2 <virtio_disk_intr>
    if(irq)
    80003cba:	a801                	j	80003cca <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    80003cbc:	85ba                	mv	a1,a4
    80003cbe:	00006517          	auipc	a0,0x6
    80003cc2:	d0250513          	addi	a0,a0,-766 # 800099c0 <etext+0x9c0>
    80003cc6:	835fc0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80003cca:	8526                	mv	a0,s1
    80003ccc:	460030ef          	jal	8000712c <plic_complete>
    return 1;
    80003cd0:	4505                	li	a0,1
    80003cd2:	64a2                	ld	s1,8(sp)
    80003cd4:	bf5d                	j	80003c8a <devintr+0x22>
    clockintr();
    80003cd6:	f3dff0ef          	jal	80003c12 <clockintr>
    return 2;
    80003cda:	4509                	li	a0,2
    80003cdc:	b77d                	j	80003c8a <devintr+0x22>

0000000080003cde <usertrap>:
{
    80003cde:	1101                	addi	sp,sp,-32
    80003ce0:	ec06                	sd	ra,24(sp)
    80003ce2:	e822                	sd	s0,16(sp)
    80003ce4:	e426                	sd	s1,8(sp)
    80003ce6:	e04a                	sd	s2,0(sp)
    80003ce8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003cea:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80003cee:	1007f793          	andi	a5,a5,256
    80003cf2:	efb5                	bnez	a5,80003d6e <usertrap+0x90>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003cf4:	00003797          	auipc	a5,0x3
    80003cf8:	36c78793          	addi	a5,a5,876 # 80007060 <kernelvec>
    80003cfc:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80003d00:	944ff0ef          	jal	80002e44 <myproc>
    80003d04:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80003d06:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003d08:	14102773          	csrr	a4,sepc
    80003d0c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003d0e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80003d12:	47a1                	li	a5,8
    80003d14:	06f70363          	beq	a4,a5,80003d7a <usertrap+0x9c>
  } else if((which_dev = devintr()) != 0){
    80003d18:	f51ff0ef          	jal	80003c68 <devintr>
    80003d1c:	892a                	mv	s2,a0
    80003d1e:	10051e63          	bnez	a0,80003e3a <usertrap+0x15c>
    80003d22:	14202773          	csrr	a4,scause
  } else if(r_scause() == 12) {
    80003d26:	47b1                	li	a5,12
    80003d28:	08f70d63          	beq	a4,a5,80003dc2 <usertrap+0xe4>
    80003d2c:	14202773          	csrr	a4,scause
  } else if(r_scause() == 13) {
    80003d30:	47b5                	li	a5,13
    80003d32:	0af70c63          	beq	a4,a5,80003dea <usertrap+0x10c>
    80003d36:	14202773          	csrr	a4,scause
  } else if(r_scause() == 15) {
    80003d3a:	47bd                	li	a5,15
    80003d3c:	0cf70b63          	beq	a4,a5,80003e12 <usertrap+0x134>
    80003d40:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80003d44:	5890                	lw	a2,48(s1)
    80003d46:	00006517          	auipc	a0,0x6
    80003d4a:	d4250513          	addi	a0,a0,-702 # 80009a88 <etext+0xa88>
    80003d4e:	facfc0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003d52:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003d56:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80003d5a:	00006517          	auipc	a0,0x6
    80003d5e:	d5e50513          	addi	a0,a0,-674 # 80009ab8 <etext+0xab8>
    80003d62:	f98fc0ef          	jal	800004fa <printf>
    setkilled(p);
    80003d66:	8526                	mv	a0,s1
    80003d68:	b03ff0ef          	jal	8000386a <setkilled>
    80003d6c:	a035                	j	80003d98 <usertrap+0xba>
    panic("usertrap: not from user mode");
    80003d6e:	00006517          	auipc	a0,0x6
    80003d72:	c7250513          	addi	a0,a0,-910 # 800099e0 <etext+0x9e0>
    80003d76:	aaffc0ef          	jal	80000824 <panic>
    if(killed(p))
    80003d7a:	b15ff0ef          	jal	8000388e <killed>
    80003d7e:	ed15                	bnez	a0,80003dba <usertrap+0xdc>
    p->trapframe->epc += 4;
    80003d80:	6cb8                	ld	a4,88(s1)
    80003d82:	6f1c                	ld	a5,24(a4)
    80003d84:	0791                	addi	a5,a5,4
    80003d86:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003d88:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003d8c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003d90:	10079073          	csrw	sstatus,a5
    syscall();
    80003d94:	2a0000ef          	jal	80004034 <syscall>
  if(killed(p))
    80003d98:	8526                	mv	a0,s1
    80003d9a:	af5ff0ef          	jal	8000388e <killed>
    80003d9e:	e15d                	bnez	a0,80003e44 <usertrap+0x166>
  prepare_return();
    80003da0:	df9ff0ef          	jal	80003b98 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80003da4:	68a8                	ld	a0,80(s1)
    80003da6:	8131                	srli	a0,a0,0xc
    80003da8:	57fd                	li	a5,-1
    80003daa:	17fe                	slli	a5,a5,0x3f
    80003dac:	8d5d                	or	a0,a0,a5
}
    80003dae:	60e2                	ld	ra,24(sp)
    80003db0:	6442                	ld	s0,16(sp)
    80003db2:	64a2                	ld	s1,8(sp)
    80003db4:	6902                	ld	s2,0(sp)
    80003db6:	6105                	addi	sp,sp,32
    80003db8:	8082                	ret
      kexit(-1);
    80003dba:	557d                	li	a0,-1
    80003dbc:	997ff0ef          	jal	80003752 <kexit>
    80003dc0:	b7c1                	j	80003d80 <usertrap+0xa2>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003dc2:	143025f3          	csrr	a1,stval
    if(vmfault(p->pagetable, r_stval(), 0) == 0) {
    80003dc6:	4601                	li	a2,0
    80003dc8:	68a8                	ld	a0,80(s1)
    80003dca:	fc0fe0ef          	jal	8000258a <vmfault>
    80003dce:	f569                	bnez	a0,80003d98 <usertrap+0xba>
    80003dd0:	14302673          	csrr	a2,stval
      printf("[pid %d] KILL instruction page fault va=0x%lx\n", p->pid, r_stval());
    80003dd4:	588c                	lw	a1,48(s1)
    80003dd6:	00006517          	auipc	a0,0x6
    80003dda:	c2a50513          	addi	a0,a0,-982 # 80009a00 <etext+0xa00>
    80003dde:	f1cfc0ef          	jal	800004fa <printf>
      setkilled(p);
    80003de2:	8526                	mv	a0,s1
    80003de4:	a87ff0ef          	jal	8000386a <setkilled>
    80003de8:	bf45                	j	80003d98 <usertrap+0xba>
    80003dea:	143025f3          	csrr	a1,stval
    if(vmfault(p->pagetable, r_stval(), 0) == 0) {
    80003dee:	4601                	li	a2,0
    80003df0:	68a8                	ld	a0,80(s1)
    80003df2:	f98fe0ef          	jal	8000258a <vmfault>
    80003df6:	f14d                	bnez	a0,80003d98 <usertrap+0xba>
    80003df8:	14302673          	csrr	a2,stval
      printf("[pid %d] KILL load page fault va=0x%lx\n", p->pid, r_stval());
    80003dfc:	588c                	lw	a1,48(s1)
    80003dfe:	00006517          	auipc	a0,0x6
    80003e02:	c3250513          	addi	a0,a0,-974 # 80009a30 <etext+0xa30>
    80003e06:	ef4fc0ef          	jal	800004fa <printf>
      setkilled(p);
    80003e0a:	8526                	mv	a0,s1
    80003e0c:	a5fff0ef          	jal	8000386a <setkilled>
    80003e10:	b761                	j	80003d98 <usertrap+0xba>
    80003e12:	143025f3          	csrr	a1,stval
    if(vmfault(p->pagetable, r_stval(), 1) == 0) {
    80003e16:	4605                	li	a2,1
    80003e18:	68a8                	ld	a0,80(s1)
    80003e1a:	f70fe0ef          	jal	8000258a <vmfault>
    80003e1e:	fd2d                	bnez	a0,80003d98 <usertrap+0xba>
    80003e20:	14302673          	csrr	a2,stval
      printf("[pid %d] KILL store page fault va=0x%lx\n", p->pid, r_stval());
    80003e24:	588c                	lw	a1,48(s1)
    80003e26:	00006517          	auipc	a0,0x6
    80003e2a:	c3250513          	addi	a0,a0,-974 # 80009a58 <etext+0xa58>
    80003e2e:	eccfc0ef          	jal	800004fa <printf>
      setkilled(p);
    80003e32:	8526                	mv	a0,s1
    80003e34:	a37ff0ef          	jal	8000386a <setkilled>
    80003e38:	b785                	j	80003d98 <usertrap+0xba>
  if(killed(p))
    80003e3a:	8526                	mv	a0,s1
    80003e3c:	a53ff0ef          	jal	8000388e <killed>
    80003e40:	c511                	beqz	a0,80003e4c <usertrap+0x16e>
    80003e42:	a011                	j	80003e46 <usertrap+0x168>
    80003e44:	4901                	li	s2,0
    kexit(-1);
    80003e46:	557d                	li	a0,-1
    80003e48:	90bff0ef          	jal	80003752 <kexit>
  if(which_dev == 2)
    80003e4c:	4789                	li	a5,2
    80003e4e:	f4f919e3          	bne	s2,a5,80003da0 <usertrap+0xc2>
    yield();
    80003e52:	fb8ff0ef          	jal	8000360a <yield>
    80003e56:	b7a9                	j	80003da0 <usertrap+0xc2>

0000000080003e58 <kerneltrap>:
{
    80003e58:	7179                	addi	sp,sp,-48
    80003e5a:	f406                	sd	ra,40(sp)
    80003e5c:	f022                	sd	s0,32(sp)
    80003e5e:	ec26                	sd	s1,24(sp)
    80003e60:	e84a                	sd	s2,16(sp)
    80003e62:	e44e                	sd	s3,8(sp)
    80003e64:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003e66:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003e6a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003e6e:	142027f3          	csrr	a5,scause
    80003e72:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    80003e74:	1004f793          	andi	a5,s1,256
    80003e78:	c795                	beqz	a5,80003ea4 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003e7a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003e7e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80003e80:	eb85                	bnez	a5,80003eb0 <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    80003e82:	de7ff0ef          	jal	80003c68 <devintr>
    80003e86:	c91d                	beqz	a0,80003ebc <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    80003e88:	4789                	li	a5,2
    80003e8a:	04f50a63          	beq	a0,a5,80003ede <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003e8e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003e92:	10049073          	csrw	sstatus,s1
}
    80003e96:	70a2                	ld	ra,40(sp)
    80003e98:	7402                	ld	s0,32(sp)
    80003e9a:	64e2                	ld	s1,24(sp)
    80003e9c:	6942                	ld	s2,16(sp)
    80003e9e:	69a2                	ld	s3,8(sp)
    80003ea0:	6145                	addi	sp,sp,48
    80003ea2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003ea4:	00006517          	auipc	a0,0x6
    80003ea8:	c3c50513          	addi	a0,a0,-964 # 80009ae0 <etext+0xae0>
    80003eac:	979fc0ef          	jal	80000824 <panic>
    panic("kerneltrap: interrupts enabled");
    80003eb0:	00006517          	auipc	a0,0x6
    80003eb4:	c5850513          	addi	a0,a0,-936 # 80009b08 <etext+0xb08>
    80003eb8:	96dfc0ef          	jal	80000824 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003ebc:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003ec0:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80003ec4:	85ce                	mv	a1,s3
    80003ec6:	00006517          	auipc	a0,0x6
    80003eca:	c6250513          	addi	a0,a0,-926 # 80009b28 <etext+0xb28>
    80003ece:	e2cfc0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    80003ed2:	00006517          	auipc	a0,0x6
    80003ed6:	c7e50513          	addi	a0,a0,-898 # 80009b50 <etext+0xb50>
    80003eda:	94bfc0ef          	jal	80000824 <panic>
  if(which_dev == 2 && myproc() != 0)
    80003ede:	f67fe0ef          	jal	80002e44 <myproc>
    80003ee2:	d555                	beqz	a0,80003e8e <kerneltrap+0x36>
    yield();
    80003ee4:	f26ff0ef          	jal	8000360a <yield>
    80003ee8:	b75d                	j	80003e8e <kerneltrap+0x36>

0000000080003eea <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003eea:	1101                	addi	sp,sp,-32
    80003eec:	ec06                	sd	ra,24(sp)
    80003eee:	e822                	sd	s0,16(sp)
    80003ef0:	e426                	sd	s1,8(sp)
    80003ef2:	1000                	addi	s0,sp,32
    80003ef4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003ef6:	f4ffe0ef          	jal	80002e44 <myproc>
  switch (n) {
    80003efa:	4795                	li	a5,5
    80003efc:	0497e163          	bltu	a5,s1,80003f3e <argraw+0x54>
    80003f00:	048a                	slli	s1,s1,0x2
    80003f02:	00006717          	auipc	a4,0x6
    80003f06:	39670713          	addi	a4,a4,918 # 8000a298 <states.0+0x30>
    80003f0a:	94ba                	add	s1,s1,a4
    80003f0c:	409c                	lw	a5,0(s1)
    80003f0e:	97ba                	add	a5,a5,a4
    80003f10:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80003f12:	6d3c                	ld	a5,88(a0)
    80003f14:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003f16:	60e2                	ld	ra,24(sp)
    80003f18:	6442                	ld	s0,16(sp)
    80003f1a:	64a2                	ld	s1,8(sp)
    80003f1c:	6105                	addi	sp,sp,32
    80003f1e:	8082                	ret
    return p->trapframe->a1;
    80003f20:	6d3c                	ld	a5,88(a0)
    80003f22:	7fa8                	ld	a0,120(a5)
    80003f24:	bfcd                	j	80003f16 <argraw+0x2c>
    return p->trapframe->a2;
    80003f26:	6d3c                	ld	a5,88(a0)
    80003f28:	63c8                	ld	a0,128(a5)
    80003f2a:	b7f5                	j	80003f16 <argraw+0x2c>
    return p->trapframe->a3;
    80003f2c:	6d3c                	ld	a5,88(a0)
    80003f2e:	67c8                	ld	a0,136(a5)
    80003f30:	b7dd                	j	80003f16 <argraw+0x2c>
    return p->trapframe->a4;
    80003f32:	6d3c                	ld	a5,88(a0)
    80003f34:	6bc8                	ld	a0,144(a5)
    80003f36:	b7c5                	j	80003f16 <argraw+0x2c>
    return p->trapframe->a5;
    80003f38:	6d3c                	ld	a5,88(a0)
    80003f3a:	6fc8                	ld	a0,152(a5)
    80003f3c:	bfe9                	j	80003f16 <argraw+0x2c>
  panic("argraw");
    80003f3e:	00006517          	auipc	a0,0x6
    80003f42:	c2250513          	addi	a0,a0,-990 # 80009b60 <etext+0xb60>
    80003f46:	8dffc0ef          	jal	80000824 <panic>

0000000080003f4a <fetchaddr>:
{
    80003f4a:	1101                	addi	sp,sp,-32
    80003f4c:	ec06                	sd	ra,24(sp)
    80003f4e:	e822                	sd	s0,16(sp)
    80003f50:	e426                	sd	s1,8(sp)
    80003f52:	e04a                	sd	s2,0(sp)
    80003f54:	1000                	addi	s0,sp,32
    80003f56:	84aa                	mv	s1,a0
    80003f58:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003f5a:	eebfe0ef          	jal	80002e44 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80003f5e:	653c                	ld	a5,72(a0)
    80003f60:	02f4f663          	bgeu	s1,a5,80003f8c <fetchaddr+0x42>
    80003f64:	00848713          	addi	a4,s1,8
    80003f68:	02e7e463          	bltu	a5,a4,80003f90 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003f6c:	46a1                	li	a3,8
    80003f6e:	8626                	mv	a2,s1
    80003f70:	85ca                	mv	a1,s2
    80003f72:	6928                	ld	a0,80(a0)
    80003f74:	aa1fe0ef          	jal	80002a14 <copyin>
    80003f78:	00a03533          	snez	a0,a0
    80003f7c:	40a0053b          	negw	a0,a0
}
    80003f80:	60e2                	ld	ra,24(sp)
    80003f82:	6442                	ld	s0,16(sp)
    80003f84:	64a2                	ld	s1,8(sp)
    80003f86:	6902                	ld	s2,0(sp)
    80003f88:	6105                	addi	sp,sp,32
    80003f8a:	8082                	ret
    return -1;
    80003f8c:	557d                	li	a0,-1
    80003f8e:	bfcd                	j	80003f80 <fetchaddr+0x36>
    80003f90:	557d                	li	a0,-1
    80003f92:	b7fd                	j	80003f80 <fetchaddr+0x36>

0000000080003f94 <fetchstr>:
{
    80003f94:	7179                	addi	sp,sp,-48
    80003f96:	f406                	sd	ra,40(sp)
    80003f98:	f022                	sd	s0,32(sp)
    80003f9a:	ec26                	sd	s1,24(sp)
    80003f9c:	e84a                	sd	s2,16(sp)
    80003f9e:	e44e                	sd	s3,8(sp)
    80003fa0:	1800                	addi	s0,sp,48
    80003fa2:	89aa                	mv	s3,a0
    80003fa4:	84ae                	mv	s1,a1
    80003fa6:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80003fa8:	e9dfe0ef          	jal	80002e44 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80003fac:	86ca                	mv	a3,s2
    80003fae:	864e                	mv	a2,s3
    80003fb0:	85a6                	mv	a1,s1
    80003fb2:	6928                	ld	a0,80(a0)
    80003fb4:	e02fd0ef          	jal	800015b6 <copyinstr>
    80003fb8:	00054c63          	bltz	a0,80003fd0 <fetchstr+0x3c>
  return strlen(buf);
    80003fbc:	8526                	mv	a0,s1
    80003fbe:	ec9fc0ef          	jal	80000e86 <strlen>
}
    80003fc2:	70a2                	ld	ra,40(sp)
    80003fc4:	7402                	ld	s0,32(sp)
    80003fc6:	64e2                	ld	s1,24(sp)
    80003fc8:	6942                	ld	s2,16(sp)
    80003fca:	69a2                	ld	s3,8(sp)
    80003fcc:	6145                	addi	sp,sp,48
    80003fce:	8082                	ret
    return -1;
    80003fd0:	557d                	li	a0,-1
    80003fd2:	bfc5                	j	80003fc2 <fetchstr+0x2e>

0000000080003fd4 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80003fd4:	1101                	addi	sp,sp,-32
    80003fd6:	ec06                	sd	ra,24(sp)
    80003fd8:	e822                	sd	s0,16(sp)
    80003fda:	e426                	sd	s1,8(sp)
    80003fdc:	1000                	addi	s0,sp,32
    80003fde:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003fe0:	f0bff0ef          	jal	80003eea <argraw>
    80003fe4:	c088                	sw	a0,0(s1)
}
    80003fe6:	60e2                	ld	ra,24(sp)
    80003fe8:	6442                	ld	s0,16(sp)
    80003fea:	64a2                	ld	s1,8(sp)
    80003fec:	6105                	addi	sp,sp,32
    80003fee:	8082                	ret

0000000080003ff0 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80003ff0:	1101                	addi	sp,sp,-32
    80003ff2:	ec06                	sd	ra,24(sp)
    80003ff4:	e822                	sd	s0,16(sp)
    80003ff6:	e426                	sd	s1,8(sp)
    80003ff8:	1000                	addi	s0,sp,32
    80003ffa:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003ffc:	eefff0ef          	jal	80003eea <argraw>
    80004000:	e088                	sd	a0,0(s1)
}
    80004002:	60e2                	ld	ra,24(sp)
    80004004:	6442                	ld	s0,16(sp)
    80004006:	64a2                	ld	s1,8(sp)
    80004008:	6105                	addi	sp,sp,32
    8000400a:	8082                	ret

000000008000400c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000400c:	1101                	addi	sp,sp,-32
    8000400e:	ec06                	sd	ra,24(sp)
    80004010:	e822                	sd	s0,16(sp)
    80004012:	e426                	sd	s1,8(sp)
    80004014:	e04a                	sd	s2,0(sp)
    80004016:	1000                	addi	s0,sp,32
    80004018:	892e                	mv	s2,a1
    8000401a:	84b2                	mv	s1,a2
  *ip = argraw(n);
    8000401c:	ecfff0ef          	jal	80003eea <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80004020:	8626                	mv	a2,s1
    80004022:	85ca                	mv	a1,s2
    80004024:	f71ff0ef          	jal	80003f94 <fetchstr>
}
    80004028:	60e2                	ld	ra,24(sp)
    8000402a:	6442                	ld	s0,16(sp)
    8000402c:	64a2                	ld	s1,8(sp)
    8000402e:	6902                	ld	s2,0(sp)
    80004030:	6105                	addi	sp,sp,32
    80004032:	8082                	ret

0000000080004034 <syscall>:
[SYS_enable_bonus] sys_enable_bonus,
};

void
syscall(void)
{
    80004034:	1101                	addi	sp,sp,-32
    80004036:	ec06                	sd	ra,24(sp)
    80004038:	e822                	sd	s0,16(sp)
    8000403a:	e426                	sd	s1,8(sp)
    8000403c:	e04a                	sd	s2,0(sp)
    8000403e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80004040:	e05fe0ef          	jal	80002e44 <myproc>
    80004044:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80004046:	05853903          	ld	s2,88(a0)
    8000404a:	0a893783          	ld	a5,168(s2)
    8000404e:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80004052:	37fd                	addiw	a5,a5,-1
    80004054:	4759                	li	a4,22
    80004056:	00f76f63          	bltu	a4,a5,80004074 <syscall+0x40>
    8000405a:	00369713          	slli	a4,a3,0x3
    8000405e:	00006797          	auipc	a5,0x6
    80004062:	25278793          	addi	a5,a5,594 # 8000a2b0 <syscalls>
    80004066:	97ba                	add	a5,a5,a4
    80004068:	639c                	ld	a5,0(a5)
    8000406a:	c789                	beqz	a5,80004074 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000406c:	9782                	jalr	a5
    8000406e:	06a93823          	sd	a0,112(s2)
    80004072:	a829                	j	8000408c <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80004074:	15848613          	addi	a2,s1,344
    80004078:	588c                	lw	a1,48(s1)
    8000407a:	00006517          	auipc	a0,0x6
    8000407e:	aee50513          	addi	a0,a0,-1298 # 80009b68 <etext+0xb68>
    80004082:	c78fc0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80004086:	6cbc                	ld	a5,88(s1)
    80004088:	577d                	li	a4,-1
    8000408a:	fbb8                	sd	a4,112(a5)
  }
}
    8000408c:	60e2                	ld	ra,24(sp)
    8000408e:	6442                	ld	s0,16(sp)
    80004090:	64a2                	ld	s1,8(sp)
    80004092:	6902                	ld	s2,0(sp)
    80004094:	6105                	addi	sp,sp,32
    80004096:	8082                	ret

0000000080004098 <sys_exit>:
#include "vm.h"
#include "memstat.h"

uint64
sys_exit(void)
{
    80004098:	1101                	addi	sp,sp,-32
    8000409a:	ec06                	sd	ra,24(sp)
    8000409c:	e822                	sd	s0,16(sp)
    8000409e:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800040a0:	fec40593          	addi	a1,s0,-20
    800040a4:	4501                	li	a0,0
    800040a6:	f2fff0ef          	jal	80003fd4 <argint>
  kexit(n);
    800040aa:	fec42503          	lw	a0,-20(s0)
    800040ae:	ea4ff0ef          	jal	80003752 <kexit>
  return 0;  // not reached
}
    800040b2:	4501                	li	a0,0
    800040b4:	60e2                	ld	ra,24(sp)
    800040b6:	6442                	ld	s0,16(sp)
    800040b8:	6105                	addi	sp,sp,32
    800040ba:	8082                	ret

00000000800040bc <sys_getpid>:

uint64
sys_getpid(void)
{
    800040bc:	1141                	addi	sp,sp,-16
    800040be:	e406                	sd	ra,8(sp)
    800040c0:	e022                	sd	s0,0(sp)
    800040c2:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800040c4:	d81fe0ef          	jal	80002e44 <myproc>
}
    800040c8:	5908                	lw	a0,48(a0)
    800040ca:	60a2                	ld	ra,8(sp)
    800040cc:	6402                	ld	s0,0(sp)
    800040ce:	0141                	addi	sp,sp,16
    800040d0:	8082                	ret

00000000800040d2 <sys_fork>:

uint64
sys_fork(void)
{
    800040d2:	1141                	addi	sp,sp,-16
    800040d4:	e406                	sd	ra,8(sp)
    800040d6:	e022                	sd	s0,0(sp)
    800040d8:	0800                	addi	s0,sp,16
  return kfork();
    800040da:	a08ff0ef          	jal	800032e2 <kfork>
}
    800040de:	60a2                	ld	ra,8(sp)
    800040e0:	6402                	ld	s0,0(sp)
    800040e2:	0141                	addi	sp,sp,16
    800040e4:	8082                	ret

00000000800040e6 <sys_wait>:

uint64
sys_wait(void)
{
    800040e6:	1101                	addi	sp,sp,-32
    800040e8:	ec06                	sd	ra,24(sp)
    800040ea:	e822                	sd	s0,16(sp)
    800040ec:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800040ee:	fe840593          	addi	a1,s0,-24
    800040f2:	4501                	li	a0,0
    800040f4:	efdff0ef          	jal	80003ff0 <argaddr>
  return kwait(p);
    800040f8:	fe843503          	ld	a0,-24(s0)
    800040fc:	fbcff0ef          	jal	800038b8 <kwait>
}
    80004100:	60e2                	ld	ra,24(sp)
    80004102:	6442                	ld	s0,16(sp)
    80004104:	6105                	addi	sp,sp,32
    80004106:	8082                	ret

0000000080004108 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80004108:	7179                	addi	sp,sp,-48
    8000410a:	f406                	sd	ra,40(sp)
    8000410c:	f022                	sd	s0,32(sp)
    8000410e:	ec26                	sd	s1,24(sp)
    80004110:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80004112:	fd840593          	addi	a1,s0,-40
    80004116:	4501                	li	a0,0
    80004118:	ebdff0ef          	jal	80003fd4 <argint>
  argint(1, &t);
    8000411c:	fdc40593          	addi	a1,s0,-36
    80004120:	4505                	li	a0,1
    80004122:	eb3ff0ef          	jal	80003fd4 <argint>
  addr = myproc()->sz;
    80004126:	d1ffe0ef          	jal	80002e44 <myproc>
    8000412a:	6524                	ld	s1,72(a0)

  if(t == SBRK_LAZY) {
    8000412c:	fdc42703          	lw	a4,-36(s0)
    80004130:	4789                	li	a5,2
    80004132:	04f70463          	beq	a4,a5,8000417a <sys_sbrk+0x72>
    80004136:	e84a                	sd	s2,16(sp)
    }
  } else {
    // SBRK_EAGER mode (default for regular sbrk() calls)
    // Use hybrid allocation: lazy growing, immediate shrinking
    
    if(n < 0) {
    80004138:	fd842783          	lw	a5,-40(s0)
    8000413c:	0807c163          	bltz	a5,800041be <sys_sbrk+0xb6>
        return -1;
      }
    } else {
      //part1 - Lazily allocate memory: increase memory size but don't allocate physical pages
      // Physical pages will be allocated on demand when accessed (page fault)
      if(addr + n < addr)
    80004140:	00978933          	add	s2,a5,s1
        return -1;
      if(addr + n > TRAPFRAME)
    80004144:	020007b7          	lui	a5,0x2000
    80004148:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    8000414a:	07b6                	slli	a5,a5,0xd
    8000414c:	0b27e463          	bltu	a5,s2,800041f4 <sys_sbrk+0xec>
    80004150:	0a996263          	bltu	s2,s1,800041f4 <sys_sbrk+0xec>
        return -1;
      
      // BONUS: Add reasonable memory limit to prevent thrashing in usertests
      // Increase limit to allow sbrkmuch test to test swapping (e.g., 65536 pages = 256MB)
      // This allows for large allocations while still preventing infinite loops
      if((addr + n - myproc()->heap_start) > (65536 * PGSIZE)) {
    80004154:	cf1fe0ef          	jal	80002e44 <myproc>
    80004158:	18853783          	ld	a5,392(a0)
    8000415c:	40f907b3          	sub	a5,s2,a5
    80004160:	10000737          	lui	a4,0x10000
    80004164:	0af76063          	bltu	a4,a5,80004204 <sys_sbrk+0xfc>
        return -1; // Return error for excessive memory requests
      }
      
      myproc()->sz += n;
    80004168:	cddfe0ef          	jal	80002e44 <myproc>
    8000416c:	fd842703          	lw	a4,-40(s0)
    80004170:	653c                	ld	a5,72(a0)
    80004172:	97ba                	add	a5,a5,a4
    80004174:	e53c                	sd	a5,72(a0)
    80004176:	6942                	ld	s2,16(sp)
    80004178:	a041                	j	800041f8 <sys_sbrk+0xf0>
    if(n < 0) {
    8000417a:	fd842783          	lw	a5,-40(s0)
    8000417e:	0207c163          	bltz	a5,800041a0 <sys_sbrk+0x98>
      if(addr + n < addr)
    80004182:	97a6                	add	a5,a5,s1
      if(addr + n >= MAXVA)
    80004184:	4705                	li	a4,1
    80004186:	171a                	slli	a4,a4,0x26
    80004188:	04e7fe63          	bgeu	a5,a4,800041e4 <sys_sbrk+0xdc>
    8000418c:	0497ec63          	bltu	a5,s1,800041e4 <sys_sbrk+0xdc>
      myproc()->sz += n;
    80004190:	cb5fe0ef          	jal	80002e44 <myproc>
    80004194:	fd842703          	lw	a4,-40(s0)
    80004198:	653c                	ld	a5,72(a0)
    8000419a:	97ba                	add	a5,a5,a4
    8000419c:	e53c                	sd	a5,72(a0)
    8000419e:	a8a9                	j	800041f8 <sys_sbrk+0xf0>
    800041a0:	e84a                	sd	s2,16(sp)
      uint64 new_sz = addr + n;
    800041a2:	00978933          	add	s2,a5,s1
      if(new_sz < myproc()->heap_start) {
    800041a6:	c9ffe0ef          	jal	80002e44 <myproc>
    800041aa:	18853783          	ld	a5,392(a0)
    800041ae:	02f96863          	bltu	s2,a5,800041de <sys_sbrk+0xd6>
      myproc()->sz = new_sz;
    800041b2:	c93fe0ef          	jal	80002e44 <myproc>
    800041b6:	05253423          	sd	s2,72(a0)
    800041ba:	6942                	ld	s2,16(sp)
    800041bc:	a835                	j	800041f8 <sys_sbrk+0xf0>
      uint64 new_sz = addr + n;
    800041be:	00978933          	add	s2,a5,s1
      if(new_sz < myproc()->heap_start) {
    800041c2:	c83fe0ef          	jal	80002e44 <myproc>
    800041c6:	18853783          	ld	a5,392(a0)
    800041ca:	00f96f63          	bltu	s2,a5,800041e8 <sys_sbrk+0xe0>
      if(growproc(n) < 0) {
    800041ce:	fd842503          	lw	a0,-40(s0)
    800041d2:	8aeff0ef          	jal	80003280 <growproc>
    800041d6:	00054c63          	bltz	a0,800041ee <sys_sbrk+0xe6>
    800041da:	6942                	ld	s2,16(sp)
    800041dc:	a831                	j	800041f8 <sys_sbrk+0xf0>
        return -1;  // Error: would shrink below heap start
    800041de:	54fd                	li	s1,-1
    800041e0:	6942                	ld	s2,16(sp)
    800041e2:	a819                	j	800041f8 <sys_sbrk+0xf0>
        return -1;
    800041e4:	54fd                	li	s1,-1
    800041e6:	a809                	j	800041f8 <sys_sbrk+0xf0>
        return -1;  // Error: would shrink below heap start
    800041e8:	54fd                	li	s1,-1
    800041ea:	6942                	ld	s2,16(sp)
    800041ec:	a031                	j	800041f8 <sys_sbrk+0xf0>
        return -1;
    800041ee:	54fd                	li	s1,-1
    800041f0:	6942                	ld	s2,16(sp)
    800041f2:	a019                	j	800041f8 <sys_sbrk+0xf0>
        return -1;
    800041f4:	54fd                	li	s1,-1
    800041f6:	6942                	ld	s2,16(sp)
    }
  }
  
  return addr;
}
    800041f8:	8526                	mv	a0,s1
    800041fa:	70a2                	ld	ra,40(sp)
    800041fc:	7402                	ld	s0,32(sp)
    800041fe:	64e2                	ld	s1,24(sp)
    80004200:	6145                	addi	sp,sp,48
    80004202:	8082                	ret
        return -1; // Return error for excessive memory requests
    80004204:	54fd                	li	s1,-1
    80004206:	6942                	ld	s2,16(sp)
    80004208:	bfc5                	j	800041f8 <sys_sbrk+0xf0>

000000008000420a <sys_pause>:

uint64
sys_pause(void)
{
    8000420a:	7139                	addi	sp,sp,-64
    8000420c:	fc06                	sd	ra,56(sp)
    8000420e:	f822                	sd	s0,48(sp)
    80004210:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80004212:	fcc40593          	addi	a1,s0,-52
    80004216:	4501                	li	a0,0
    80004218:	dbdff0ef          	jal	80003fd4 <argint>
  if(n < 0)
    8000421c:	fcc42783          	lw	a5,-52(s0)
    80004220:	0607c863          	bltz	a5,80004290 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80004224:	002c4517          	auipc	a0,0x2c4
    80004228:	4d450513          	addi	a0,a0,1236 # 802c86f8 <tickslock>
    8000422c:	a01fc0ef          	jal	80000c2c <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80004230:	fcc42783          	lw	a5,-52(s0)
    80004234:	c3b9                	beqz	a5,8000427a <sys_pause+0x70>
    80004236:	f426                	sd	s1,40(sp)
    80004238:	f04a                	sd	s2,32(sp)
    8000423a:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    8000423c:	00009997          	auipc	s3,0x9
    80004240:	18c9a983          	lw	s3,396(s3) # 8000d3c8 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80004244:	002c4917          	auipc	s2,0x2c4
    80004248:	4b490913          	addi	s2,s2,1204 # 802c86f8 <tickslock>
    8000424c:	00009497          	auipc	s1,0x9
    80004250:	17c48493          	addi	s1,s1,380 # 8000d3c8 <ticks>
    if(killed(myproc())){
    80004254:	bf1fe0ef          	jal	80002e44 <myproc>
    80004258:	e36ff0ef          	jal	8000388e <killed>
    8000425c:	ed0d                	bnez	a0,80004296 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    8000425e:	85ca                	mv	a1,s2
    80004260:	8526                	mv	a0,s1
    80004262:	bd4ff0ef          	jal	80003636 <sleep>
  while(ticks - ticks0 < n){
    80004266:	409c                	lw	a5,0(s1)
    80004268:	413787bb          	subw	a5,a5,s3
    8000426c:	fcc42703          	lw	a4,-52(s0)
    80004270:	fee7e2e3          	bltu	a5,a4,80004254 <sys_pause+0x4a>
    80004274:	74a2                	ld	s1,40(sp)
    80004276:	7902                	ld	s2,32(sp)
    80004278:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    8000427a:	002c4517          	auipc	a0,0x2c4
    8000427e:	47e50513          	addi	a0,a0,1150 # 802c86f8 <tickslock>
    80004282:	a3ffc0ef          	jal	80000cc0 <release>
  return 0;
    80004286:	4501                	li	a0,0
}
    80004288:	70e2                	ld	ra,56(sp)
    8000428a:	7442                	ld	s0,48(sp)
    8000428c:	6121                	addi	sp,sp,64
    8000428e:	8082                	ret
    n = 0;
    80004290:	fc042623          	sw	zero,-52(s0)
    80004294:	bf41                	j	80004224 <sys_pause+0x1a>
      release(&tickslock);
    80004296:	002c4517          	auipc	a0,0x2c4
    8000429a:	46250513          	addi	a0,a0,1122 # 802c86f8 <tickslock>
    8000429e:	a23fc0ef          	jal	80000cc0 <release>
      return -1;
    800042a2:	557d                	li	a0,-1
    800042a4:	74a2                	ld	s1,40(sp)
    800042a6:	7902                	ld	s2,32(sp)
    800042a8:	69e2                	ld	s3,24(sp)
    800042aa:	bff9                	j	80004288 <sys_pause+0x7e>

00000000800042ac <sys_kill>:

uint64
sys_kill(void)
{
    800042ac:	1101                	addi	sp,sp,-32
    800042ae:	ec06                	sd	ra,24(sp)
    800042b0:	e822                	sd	s0,16(sp)
    800042b2:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800042b4:	fec40593          	addi	a1,s0,-20
    800042b8:	4501                	li	a0,0
    800042ba:	d1bff0ef          	jal	80003fd4 <argint>
  return kkill(pid);
    800042be:	fec42503          	lw	a0,-20(s0)
    800042c2:	d3aff0ef          	jal	800037fc <kkill>
}
    800042c6:	60e2                	ld	ra,24(sp)
    800042c8:	6442                	ld	s0,16(sp)
    800042ca:	6105                	addi	sp,sp,32
    800042cc:	8082                	ret

00000000800042ce <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800042ce:	1101                	addi	sp,sp,-32
    800042d0:	ec06                	sd	ra,24(sp)
    800042d2:	e822                	sd	s0,16(sp)
    800042d4:	e426                	sd	s1,8(sp)
    800042d6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800042d8:	002c4517          	auipc	a0,0x2c4
    800042dc:	42050513          	addi	a0,a0,1056 # 802c86f8 <tickslock>
    800042e0:	94dfc0ef          	jal	80000c2c <acquire>
  xticks = ticks;
    800042e4:	00009797          	auipc	a5,0x9
    800042e8:	0e47a783          	lw	a5,228(a5) # 8000d3c8 <ticks>
    800042ec:	84be                	mv	s1,a5
  release(&tickslock);
    800042ee:	002c4517          	auipc	a0,0x2c4
    800042f2:	40a50513          	addi	a0,a0,1034 # 802c86f8 <tickslock>
    800042f6:	9cbfc0ef          	jal	80000cc0 <release>
  return xticks;
}
    800042fa:	02049513          	slli	a0,s1,0x20
    800042fe:	9101                	srli	a0,a0,0x20
    80004300:	60e2                	ld	ra,24(sp)
    80004302:	6442                	ld	s0,16(sp)
    80004304:	64a2                	ld	s1,8(sp)
    80004306:	6105                	addi	sp,sp,32
    80004308:	8082                	ret

000000008000430a <sys_memstat>:

//part4 - Memory statistics system call
uint64
sys_memstat(void)
{
    8000430a:	81010113          	addi	sp,sp,-2032
    8000430e:	7e113423          	sd	ra,2024(sp)
    80004312:	7e813023          	sd	s0,2016(sp)
    80004316:	7c913c23          	sd	s1,2008(sp)
    8000431a:	7d213823          	sd	s2,2000(sp)
    8000431e:	7d313423          	sd	s3,1992(sp)
    80004322:	7d413023          	sd	s4,1984(sp)
    80004326:	7b513c23          	sd	s5,1976(sp)
    8000432a:	7b613823          	sd	s6,1968(sp)
    8000432e:	7b713423          	sd	s7,1960(sp)
    80004332:	7f010413          	addi	s0,sp,2032
    80004336:	b8010113          	addi	sp,sp,-1152
  uint64 info_addr;
  struct proc_mem_stat info;
  struct proc *p = myproc();
    8000433a:	b0bfe0ef          	jal	80002e44 <myproc>
    8000433e:	89aa                	mv	s3,a0
  
  // Get the user address for the proc_mem_stat structure
  argaddr(0, &info_addr);
    80004340:	fa840593          	addi	a1,s0,-88
    80004344:	4501                	li	a0,0
    80004346:	cabff0ef          	jal	80003ff0 <argaddr>
  
  // Fill in the basic process information
  info.pid = p->pid;
    8000434a:	80040793          	addi	a5,s0,-2048
    8000434e:	fb078793          	addi	a5,a5,-80
    80004352:	0309a703          	lw	a4,48(s3)
    80004356:	bee7a023          	sw	a4,-1056(a5)
  info.num_resident_pages = p->num_resident_pages;
    8000435a:	6685                	lui	a3,0x1
    8000435c:	00d98733          	add	a4,s3,a3
    80004360:	ba072703          	lw	a4,-1120(a4) # ffffba0 <_entry-0x70000460>
    80004364:	bee7a423          	sw	a4,-1048(a5)
  info.num_swapped_pages = p->num_swapped_pages;
    80004368:	672d                	lui	a4,0xb
    8000436a:	974e                	add	a4,a4,s3
    8000436c:	c4872703          	lw	a4,-952(a4) # ac48 <_entry-0x7fff53b8>
    80004370:	bee7a623          	sw	a4,-1044(a5)
  info.next_fifo_seq = p->next_fifo_seq;
    80004374:	1989a703          	lw	a4,408(s3)
    80004378:	bee7a823          	sw	a4,-1040(a5)
  
  // Calculate total pages from start to proc->sz
  uint64 total_pages = PGROUNDUP(p->sz) / PGSIZE;
    8000437c:	0489b703          	ld	a4,72(s3)
    80004380:	16fd                	addi	a3,a3,-1 # fff <_entry-0x7ffff001>
    80004382:	9736                	add	a4,a4,a3
    80004384:	8331                	srli	a4,a4,0xc
  info.num_pages_total = (int)total_pages;
    80004386:	bee7a223          	sw	a4,-1052(a5)
  info.pid = p->pid;
    8000438a:	80078793          	addi	a5,a5,-2048
  
  // Initialize pages array
  int page_count = 0;
  
  // Add resident pages
  for(int i = 0; i < MAX_RESIDENT_PAGES && page_count < MAX_PAGES_INFO; i++) {
    8000438e:	1a098713          	addi	a4,s3,416
    80004392:	4681                	li	a3,0
  int page_count = 0;
    80004394:	4901                	li	s2,0
    if(p->resident_pages[i].in_use) {
      info.pages[page_count].va = p->resident_pages[i].va;
    80004396:	85be                	mv	a1,a5
      info.pages[page_count].state = RESIDENT;
    80004398:	4805                	li	a6,1
      info.pages[page_count].is_dirty = p->resident_pages[i].is_dirty;
      info.pages[page_count].seq = p->resident_pages[i].seq;
      info.pages[page_count].swap_slot = -1;
    8000439a:	557d                	li	a0,-1
    8000439c:	a821                	j	800043b4 <sys_memstat+0xaa>
  for(int i = 0; i < MAX_RESIDENT_PAGES && page_count < MAX_PAGES_INFO; i++) {
    8000439e:	0016879b          	addiw	a5,a3,1
    800043a2:	86be                	mv	a3,a5
    800043a4:	02870713          	addi	a4,a4,40
    800043a8:	0407a793          	slti	a5,a5,64
    800043ac:	cb95                	beqz	a5,800043e0 <sys_memstat+0xd6>
    800043ae:	08092793          	slti	a5,s2,128
    800043b2:	c79d                	beqz	a5,800043e0 <sys_memstat+0xd6>
    if(p->resident_pages[i].in_use) {
    800043b4:	4b5c                	lw	a5,20(a4)
    800043b6:	d7e5                	beqz	a5,8000439e <sys_memstat+0x94>
      info.pages[page_count].va = p->resident_pages[i].va;
    800043b8:	6310                	ld	a2,0(a4)
    800043ba:	00191793          	slli	a5,s2,0x1
    800043be:	97ca                	add	a5,a5,s2
    800043c0:	078e                	slli	a5,a5,0x3
    800043c2:	97ae                	add	a5,a5,a1
    800043c4:	3ec7bc23          	sd	a2,1016(a5)
      info.pages[page_count].state = RESIDENT;
    800043c8:	4107a023          	sw	a6,1024(a5)
      info.pages[page_count].is_dirty = p->resident_pages[i].is_dirty;
    800043cc:	4750                	lw	a2,12(a4)
    800043ce:	40c7a223          	sw	a2,1028(a5)
      info.pages[page_count].seq = p->resident_pages[i].seq;
    800043d2:	4710                	lw	a2,8(a4)
    800043d4:	40c7a423          	sw	a2,1032(a5)
      info.pages[page_count].swap_slot = -1;
    800043d8:	40a7a623          	sw	a0,1036(a5)
      page_count++;
    800043dc:	2905                	addiw	s2,s2,1
    800043de:	b7c1                	j	8000439e <sys_memstat+0x94>
    }
  }
  
  // Add swapped pages
  for(int i = 0; i < MAX_SWAP_PAGES && page_count < MAX_PAGES_INFO; i++) {
    800043e0:	07f00793          	li	a5,127
    800043e4:	0d27cf63          	blt	a5,s2,800044c2 <sys_memstat+0x1b8>
    800043e8:	7ff98713          	addi	a4,s3,2047
    800043ec:	44970713          	addi	a4,a4,1097
    800043f0:	4681                	li	a3,0
    if(p->swapped_pages[i].in_use) {
      info.pages[page_count].va = p->swapped_pages[i].va;
    800043f2:	80040593          	addi	a1,s0,-2048
    800043f6:	fb058593          	addi	a1,a1,-80
    800043fa:	80058593          	addi	a1,a1,-2048
      info.pages[page_count].state = SWAPPED;
    800043fe:	4509                	li	a0,2
    80004400:	a821                	j	80004418 <sys_memstat+0x10e>
  for(int i = 0; i < MAX_SWAP_PAGES && page_count < MAX_PAGES_INFO; i++) {
    80004402:	0016879b          	addiw	a5,a3,1
    80004406:	86be                	mv	a3,a5
    80004408:	08092613          	slti	a2,s2,128
    8000440c:	02870713          	addi	a4,a4,40
    80004410:	4007a793          	slti	a5,a5,1024
    80004414:	cb8d                	beqz	a5,80004446 <sys_memstat+0x13c>
    80004416:	ca05                	beqz	a2,80004446 <sys_memstat+0x13c>
    if(p->swapped_pages[i].in_use) {
    80004418:	4b5c                	lw	a5,20(a4)
    8000441a:	d7e5                	beqz	a5,80004402 <sys_memstat+0xf8>
      info.pages[page_count].va = p->swapped_pages[i].va;
    8000441c:	6310                	ld	a2,0(a4)
    8000441e:	00191793          	slli	a5,s2,0x1
    80004422:	97ca                	add	a5,a5,s2
    80004424:	078e                	slli	a5,a5,0x3
    80004426:	97ae                	add	a5,a5,a1
    80004428:	3ec7bc23          	sd	a2,1016(a5)
      info.pages[page_count].state = SWAPPED;
    8000442c:	40a7a023          	sw	a0,1024(a5)
      info.pages[page_count].is_dirty = p->swapped_pages[i].is_dirty;
    80004430:	4750                	lw	a2,12(a4)
    80004432:	40c7a223          	sw	a2,1028(a5)
      info.pages[page_count].seq = p->swapped_pages[i].seq;
    80004436:	4710                	lw	a2,8(a4)
    80004438:	40c7a423          	sw	a2,1032(a5)
      info.pages[page_count].swap_slot = p->swapped_pages[i].swap_slot;
    8000443c:	4b10                	lw	a2,16(a4)
    8000443e:	40c7a623          	sw	a2,1036(a5)
      page_count++;
    80004442:	2905                	addiw	s2,s2,1
    80004444:	bf7d                	j	80004402 <sys_memstat+0xf8>
    }
  }
  
  // Add unmapped pages (pages that are in the address space but not allocated)
  for(uint64 va = 0; va < p->sz && page_count < MAX_PAGES_INFO; va += PGSIZE) {
    80004446:	0489b783          	ld	a5,72(s3)
    8000444a:	cfa5                	beqz	a5,800044c2 <sys_memstat+0x1b8>
    8000444c:	4481                	li	s1,0
    8000444e:	ca35                	beqz	a2,800044c2 <sys_memstat+0x1b8>
        break;
      }
    }
    
    if(!already_reported && !ismapped(p->pagetable, va)) {
      info.pages[page_count].va = va;
    80004450:	80040b13          	addi	s6,s0,-2048
    80004454:	fb0b0b13          	addi	s6,s6,-80
    80004458:	800b0b13          	addi	s6,s6,-2048
      info.pages[page_count].state = UNMAPPED;
      info.pages[page_count].is_dirty = 0;
      info.pages[page_count].seq = 0;
      info.pages[page_count].swap_slot = -1;
    8000445c:	5bfd                	li	s7,-1
  for(uint64 va = 0; va < p->sz && page_count < MAX_PAGES_INFO; va += PGSIZE) {
    8000445e:	6a85                	lui	s5,0x1
    80004460:	a809                	j	80004472 <sys_memstat+0x168>
    80004462:	94d6                	add	s1,s1,s5
    80004464:	0489b783          	ld	a5,72(s3)
    80004468:	04f4fd63          	bgeu	s1,a5,800044c2 <sys_memstat+0x1b8>
    8000446c:	08092793          	slti	a5,s2,128
    80004470:	cba9                	beqz	a5,800044c2 <sys_memstat+0x1b8>
    for(int j = 0; j < page_count; j++) {
    80004472:	03205163          	blez	s2,80004494 <sys_memstat+0x18a>
    80004476:	80040793          	addi	a5,s0,-2048
    8000447a:	b9078793          	addi	a5,a5,-1136
    8000447e:	00191693          	slli	a3,s2,0x1
    80004482:	96ca                	add	a3,a3,s2
    80004484:	068e                	slli	a3,a3,0x3
    80004486:	96be                	add	a3,a3,a5
      if(info.pages[j].va == va) {
    80004488:	6f98                	ld	a4,24(a5)
    8000448a:	fc970ce3          	beq	a4,s1,80004462 <sys_memstat+0x158>
    for(int j = 0; j < page_count; j++) {
    8000448e:	07e1                	addi	a5,a5,24
    80004490:	fef69ce3          	bne	a3,a5,80004488 <sys_memstat+0x17e>
    if(!already_reported && !ismapped(p->pagetable, va)) {
    80004494:	85a6                	mv	a1,s1
    80004496:	0509b503          	ld	a0,80(s3)
    8000449a:	b34fd0ef          	jal	800017ce <ismapped>
    8000449e:	f171                	bnez	a0,80004462 <sys_memstat+0x158>
      info.pages[page_count].va = va;
    800044a0:	00191793          	slli	a5,s2,0x1
    800044a4:	97ca                	add	a5,a5,s2
    800044a6:	078e                	slli	a5,a5,0x3
    800044a8:	97da                	add	a5,a5,s6
    800044aa:	3e97bc23          	sd	s1,1016(a5)
      info.pages[page_count].state = UNMAPPED;
    800044ae:	4007a023          	sw	zero,1024(a5)
      info.pages[page_count].is_dirty = 0;
    800044b2:	4007a223          	sw	zero,1028(a5)
      info.pages[page_count].seq = 0;
    800044b6:	4007a423          	sw	zero,1032(a5)
      info.pages[page_count].swap_slot = -1;
    800044ba:	4177a623          	sw	s7,1036(a5)
      page_count++;
    800044be:	2905                	addiw	s2,s2,1
    800044c0:	b74d                	j	80004462 <sys_memstat+0x158>
    }
  }
  
  // Copy the structure to user space
  if(copyout(p->pagetable, info_addr, (char*)&info, sizeof(info)) < 0) {
    800044c2:	6685                	lui	a3,0x1
    800044c4:	c1868693          	addi	a3,a3,-1000 # c18 <_entry-0x7ffff3e8>
    800044c8:	80040613          	addi	a2,s0,-2048
    800044cc:	fb060613          	addi	a2,a2,-80 # fb0 <_entry-0x7ffff050>
    800044d0:	be060613          	addi	a2,a2,-1056
    800044d4:	fa843583          	ld	a1,-88(s0)
    800044d8:	0509b503          	ld	a0,80(s3)
    800044dc:	ba4fe0ef          	jal	80002880 <copyout>
    return -1;
  }
  
  return 0;
}
    800044e0:	957d                	srai	a0,a0,0x3f
    800044e2:	48010113          	addi	sp,sp,1152
    800044e6:	7e813083          	ld	ra,2024(sp)
    800044ea:	7e013403          	ld	s0,2016(sp)
    800044ee:	7d813483          	ld	s1,2008(sp)
    800044f2:	7d013903          	ld	s2,2000(sp)
    800044f6:	7c813983          	ld	s3,1992(sp)
    800044fa:	7c013a03          	ld	s4,1984(sp)
    800044fe:	7b813a83          	ld	s5,1976(sp)
    80004502:	7b013b03          	ld	s6,1968(sp)
    80004506:	7a813b83          	ld	s7,1960(sp)
    8000450a:	7f010113          	addi	sp,sp,2032
    8000450e:	8082                	ret

0000000080004510 <sys_enable_bonus>:

// BONUS: System call to enable LFU-Recent page replacement algorithm
uint64
sys_enable_bonus(void)
{
    80004510:	1141                	addi	sp,sp,-16
    80004512:	e406                	sd	ra,8(sp)
    80004514:	e022                	sd	s0,0(sp)
    80004516:	0800                	addi	s0,sp,16
  enable_bonus_algorithm();
    80004518:	9dcfd0ef          	jal	800016f4 <enable_bonus_algorithm>
  return 0;
}
    8000451c:	4501                	li	a0,0
    8000451e:	60a2                	ld	ra,8(sp)
    80004520:	6402                	ld	s0,0(sp)
    80004522:	0141                	addi	sp,sp,16
    80004524:	8082                	ret

0000000080004526 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80004526:	7179                	addi	sp,sp,-48
    80004528:	f406                	sd	ra,40(sp)
    8000452a:	f022                	sd	s0,32(sp)
    8000452c:	ec26                	sd	s1,24(sp)
    8000452e:	e84a                	sd	s2,16(sp)
    80004530:	e44e                	sd	s3,8(sp)
    80004532:	e052                	sd	s4,0(sp)
    80004534:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80004536:	00005597          	auipc	a1,0x5
    8000453a:	65258593          	addi	a1,a1,1618 # 80009b88 <etext+0xb88>
    8000453e:	002c4517          	auipc	a0,0x2c4
    80004542:	1d250513          	addi	a0,a0,466 # 802c8710 <bcache>
    80004546:	e5cfc0ef          	jal	80000ba2 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000454a:	002cc797          	auipc	a5,0x2cc
    8000454e:	1c678793          	addi	a5,a5,454 # 802d0710 <bcache+0x8000>
    80004552:	002cc717          	auipc	a4,0x2cc
    80004556:	42670713          	addi	a4,a4,1062 # 802d0978 <bcache+0x8268>
    8000455a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000455e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80004562:	002c4497          	auipc	s1,0x2c4
    80004566:	1c648493          	addi	s1,s1,454 # 802c8728 <bcache+0x18>
    b->next = bcache.head.next;
    8000456a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000456c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000456e:	00005a17          	auipc	s4,0x5
    80004572:	622a0a13          	addi	s4,s4,1570 # 80009b90 <etext+0xb90>
    b->next = bcache.head.next;
    80004576:	2b893783          	ld	a5,696(s2)
    8000457a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000457c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80004580:	85d2                	mv	a1,s4
    80004582:	01048513          	addi	a0,s1,16
    80004586:	328010ef          	jal	800058ae <initsleeplock>
    bcache.head.next->prev = b;
    8000458a:	2b893783          	ld	a5,696(s2)
    8000458e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80004590:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80004594:	45848493          	addi	s1,s1,1112
    80004598:	fd349fe3          	bne	s1,s3,80004576 <binit+0x50>
  }
}
    8000459c:	70a2                	ld	ra,40(sp)
    8000459e:	7402                	ld	s0,32(sp)
    800045a0:	64e2                	ld	s1,24(sp)
    800045a2:	6942                	ld	s2,16(sp)
    800045a4:	69a2                	ld	s3,8(sp)
    800045a6:	6a02                	ld	s4,0(sp)
    800045a8:	6145                	addi	sp,sp,48
    800045aa:	8082                	ret

00000000800045ac <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800045ac:	7179                	addi	sp,sp,-48
    800045ae:	f406                	sd	ra,40(sp)
    800045b0:	f022                	sd	s0,32(sp)
    800045b2:	ec26                	sd	s1,24(sp)
    800045b4:	e84a                	sd	s2,16(sp)
    800045b6:	e44e                	sd	s3,8(sp)
    800045b8:	1800                	addi	s0,sp,48
    800045ba:	892a                	mv	s2,a0
    800045bc:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800045be:	002c4517          	auipc	a0,0x2c4
    800045c2:	15250513          	addi	a0,a0,338 # 802c8710 <bcache>
    800045c6:	e66fc0ef          	jal	80000c2c <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800045ca:	002cc497          	auipc	s1,0x2cc
    800045ce:	3fe4b483          	ld	s1,1022(s1) # 802d09c8 <bcache+0x82b8>
    800045d2:	002cc797          	auipc	a5,0x2cc
    800045d6:	3a678793          	addi	a5,a5,934 # 802d0978 <bcache+0x8268>
    800045da:	02f48b63          	beq	s1,a5,80004610 <bread+0x64>
    800045de:	873e                	mv	a4,a5
    800045e0:	a021                	j	800045e8 <bread+0x3c>
    800045e2:	68a4                	ld	s1,80(s1)
    800045e4:	02e48663          	beq	s1,a4,80004610 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    800045e8:	449c                	lw	a5,8(s1)
    800045ea:	ff279ce3          	bne	a5,s2,800045e2 <bread+0x36>
    800045ee:	44dc                	lw	a5,12(s1)
    800045f0:	ff3799e3          	bne	a5,s3,800045e2 <bread+0x36>
      b->refcnt++;
    800045f4:	40bc                	lw	a5,64(s1)
    800045f6:	2785                	addiw	a5,a5,1
    800045f8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800045fa:	002c4517          	auipc	a0,0x2c4
    800045fe:	11650513          	addi	a0,a0,278 # 802c8710 <bcache>
    80004602:	ebefc0ef          	jal	80000cc0 <release>
      acquiresleep(&b->lock);
    80004606:	01048513          	addi	a0,s1,16
    8000460a:	2da010ef          	jal	800058e4 <acquiresleep>
      return b;
    8000460e:	a889                	j	80004660 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80004610:	002cc497          	auipc	s1,0x2cc
    80004614:	3b04b483          	ld	s1,944(s1) # 802d09c0 <bcache+0x82b0>
    80004618:	002cc797          	auipc	a5,0x2cc
    8000461c:	36078793          	addi	a5,a5,864 # 802d0978 <bcache+0x8268>
    80004620:	00f48863          	beq	s1,a5,80004630 <bread+0x84>
    80004624:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80004626:	40bc                	lw	a5,64(s1)
    80004628:	cb91                	beqz	a5,8000463c <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000462a:	64a4                	ld	s1,72(s1)
    8000462c:	fee49de3          	bne	s1,a4,80004626 <bread+0x7a>
  panic("bget: no buffers");
    80004630:	00005517          	auipc	a0,0x5
    80004634:	56850513          	addi	a0,a0,1384 # 80009b98 <etext+0xb98>
    80004638:	9ecfc0ef          	jal	80000824 <panic>
      b->dev = dev;
    8000463c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80004640:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80004644:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80004648:	4785                	li	a5,1
    8000464a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000464c:	002c4517          	auipc	a0,0x2c4
    80004650:	0c450513          	addi	a0,a0,196 # 802c8710 <bcache>
    80004654:	e6cfc0ef          	jal	80000cc0 <release>
      acquiresleep(&b->lock);
    80004658:	01048513          	addi	a0,s1,16
    8000465c:	288010ef          	jal	800058e4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80004660:	409c                	lw	a5,0(s1)
    80004662:	cb89                	beqz	a5,80004674 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80004664:	8526                	mv	a0,s1
    80004666:	70a2                	ld	ra,40(sp)
    80004668:	7402                	ld	s0,32(sp)
    8000466a:	64e2                	ld	s1,24(sp)
    8000466c:	6942                	ld	s2,16(sp)
    8000466e:	69a2                	ld	s3,8(sp)
    80004670:	6145                	addi	sp,sp,48
    80004672:	8082                	ret
    virtio_disk_rw(b, 0);
    80004674:	4581                	li	a1,0
    80004676:	8526                	mv	a0,s1
    80004678:	519020ef          	jal	80007390 <virtio_disk_rw>
    b->valid = 1;
    8000467c:	4785                	li	a5,1
    8000467e:	c09c                	sw	a5,0(s1)
  return b;
    80004680:	b7d5                	j	80004664 <bread+0xb8>

0000000080004682 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80004682:	1101                	addi	sp,sp,-32
    80004684:	ec06                	sd	ra,24(sp)
    80004686:	e822                	sd	s0,16(sp)
    80004688:	e426                	sd	s1,8(sp)
    8000468a:	1000                	addi	s0,sp,32
    8000468c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000468e:	0541                	addi	a0,a0,16
    80004690:	2d2010ef          	jal	80005962 <holdingsleep>
    80004694:	c911                	beqz	a0,800046a8 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80004696:	4585                	li	a1,1
    80004698:	8526                	mv	a0,s1
    8000469a:	4f7020ef          	jal	80007390 <virtio_disk_rw>
}
    8000469e:	60e2                	ld	ra,24(sp)
    800046a0:	6442                	ld	s0,16(sp)
    800046a2:	64a2                	ld	s1,8(sp)
    800046a4:	6105                	addi	sp,sp,32
    800046a6:	8082                	ret
    panic("bwrite");
    800046a8:	00005517          	auipc	a0,0x5
    800046ac:	50850513          	addi	a0,a0,1288 # 80009bb0 <etext+0xbb0>
    800046b0:	974fc0ef          	jal	80000824 <panic>

00000000800046b4 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800046b4:	1101                	addi	sp,sp,-32
    800046b6:	ec06                	sd	ra,24(sp)
    800046b8:	e822                	sd	s0,16(sp)
    800046ba:	e426                	sd	s1,8(sp)
    800046bc:	e04a                	sd	s2,0(sp)
    800046be:	1000                	addi	s0,sp,32
    800046c0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800046c2:	01050913          	addi	s2,a0,16
    800046c6:	854a                	mv	a0,s2
    800046c8:	29a010ef          	jal	80005962 <holdingsleep>
    800046cc:	c125                	beqz	a0,8000472c <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    800046ce:	854a                	mv	a0,s2
    800046d0:	25a010ef          	jal	8000592a <releasesleep>

  acquire(&bcache.lock);
    800046d4:	002c4517          	auipc	a0,0x2c4
    800046d8:	03c50513          	addi	a0,a0,60 # 802c8710 <bcache>
    800046dc:	d50fc0ef          	jal	80000c2c <acquire>
  b->refcnt--;
    800046e0:	40bc                	lw	a5,64(s1)
    800046e2:	37fd                	addiw	a5,a5,-1
    800046e4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800046e6:	e79d                	bnez	a5,80004714 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800046e8:	68b8                	ld	a4,80(s1)
    800046ea:	64bc                	ld	a5,72(s1)
    800046ec:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800046ee:	68b8                	ld	a4,80(s1)
    800046f0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800046f2:	002cc797          	auipc	a5,0x2cc
    800046f6:	01e78793          	addi	a5,a5,30 # 802d0710 <bcache+0x8000>
    800046fa:	2b87b703          	ld	a4,696(a5)
    800046fe:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80004700:	002cc717          	auipc	a4,0x2cc
    80004704:	27870713          	addi	a4,a4,632 # 802d0978 <bcache+0x8268>
    80004708:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000470a:	2b87b703          	ld	a4,696(a5)
    8000470e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80004710:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80004714:	002c4517          	auipc	a0,0x2c4
    80004718:	ffc50513          	addi	a0,a0,-4 # 802c8710 <bcache>
    8000471c:	da4fc0ef          	jal	80000cc0 <release>
}
    80004720:	60e2                	ld	ra,24(sp)
    80004722:	6442                	ld	s0,16(sp)
    80004724:	64a2                	ld	s1,8(sp)
    80004726:	6902                	ld	s2,0(sp)
    80004728:	6105                	addi	sp,sp,32
    8000472a:	8082                	ret
    panic("brelse");
    8000472c:	00005517          	auipc	a0,0x5
    80004730:	48c50513          	addi	a0,a0,1164 # 80009bb8 <etext+0xbb8>
    80004734:	8f0fc0ef          	jal	80000824 <panic>

0000000080004738 <bpin>:

void
bpin(struct buf *b) {
    80004738:	1101                	addi	sp,sp,-32
    8000473a:	ec06                	sd	ra,24(sp)
    8000473c:	e822                	sd	s0,16(sp)
    8000473e:	e426                	sd	s1,8(sp)
    80004740:	1000                	addi	s0,sp,32
    80004742:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80004744:	002c4517          	auipc	a0,0x2c4
    80004748:	fcc50513          	addi	a0,a0,-52 # 802c8710 <bcache>
    8000474c:	ce0fc0ef          	jal	80000c2c <acquire>
  b->refcnt++;
    80004750:	40bc                	lw	a5,64(s1)
    80004752:	2785                	addiw	a5,a5,1
    80004754:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80004756:	002c4517          	auipc	a0,0x2c4
    8000475a:	fba50513          	addi	a0,a0,-70 # 802c8710 <bcache>
    8000475e:	d62fc0ef          	jal	80000cc0 <release>
}
    80004762:	60e2                	ld	ra,24(sp)
    80004764:	6442                	ld	s0,16(sp)
    80004766:	64a2                	ld	s1,8(sp)
    80004768:	6105                	addi	sp,sp,32
    8000476a:	8082                	ret

000000008000476c <bunpin>:

void
bunpin(struct buf *b) {
    8000476c:	1101                	addi	sp,sp,-32
    8000476e:	ec06                	sd	ra,24(sp)
    80004770:	e822                	sd	s0,16(sp)
    80004772:	e426                	sd	s1,8(sp)
    80004774:	1000                	addi	s0,sp,32
    80004776:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80004778:	002c4517          	auipc	a0,0x2c4
    8000477c:	f9850513          	addi	a0,a0,-104 # 802c8710 <bcache>
    80004780:	cacfc0ef          	jal	80000c2c <acquire>
  b->refcnt--;
    80004784:	40bc                	lw	a5,64(s1)
    80004786:	37fd                	addiw	a5,a5,-1
    80004788:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000478a:	002c4517          	auipc	a0,0x2c4
    8000478e:	f8650513          	addi	a0,a0,-122 # 802c8710 <bcache>
    80004792:	d2efc0ef          	jal	80000cc0 <release>
}
    80004796:	60e2                	ld	ra,24(sp)
    80004798:	6442                	ld	s0,16(sp)
    8000479a:	64a2                	ld	s1,8(sp)
    8000479c:	6105                	addi	sp,sp,32
    8000479e:	8082                	ret

00000000800047a0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800047a0:	1101                	addi	sp,sp,-32
    800047a2:	ec06                	sd	ra,24(sp)
    800047a4:	e822                	sd	s0,16(sp)
    800047a6:	e426                	sd	s1,8(sp)
    800047a8:	e04a                	sd	s2,0(sp)
    800047aa:	1000                	addi	s0,sp,32
    800047ac:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800047ae:	00d5d79b          	srliw	a5,a1,0xd
    800047b2:	002cc597          	auipc	a1,0x2cc
    800047b6:	63a5a583          	lw	a1,1594(a1) # 802d0dec <sb+0x1c>
    800047ba:	9dbd                	addw	a1,a1,a5
    800047bc:	df1ff0ef          	jal	800045ac <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800047c0:	0074f713          	andi	a4,s1,7
    800047c4:	4785                	li	a5,1
    800047c6:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    800047ca:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    800047cc:	90d9                	srli	s1,s1,0x36
    800047ce:	00950733          	add	a4,a0,s1
    800047d2:	05874703          	lbu	a4,88(a4)
    800047d6:	00e7f6b3          	and	a3,a5,a4
    800047da:	c29d                	beqz	a3,80004800 <bfree+0x60>
    800047dc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800047de:	94aa                	add	s1,s1,a0
    800047e0:	fff7c793          	not	a5,a5
    800047e4:	8f7d                	and	a4,a4,a5
    800047e6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800047ea:	000010ef          	jal	800057ea <log_write>
  brelse(bp);
    800047ee:	854a                	mv	a0,s2
    800047f0:	ec5ff0ef          	jal	800046b4 <brelse>
}
    800047f4:	60e2                	ld	ra,24(sp)
    800047f6:	6442                	ld	s0,16(sp)
    800047f8:	64a2                	ld	s1,8(sp)
    800047fa:	6902                	ld	s2,0(sp)
    800047fc:	6105                	addi	sp,sp,32
    800047fe:	8082                	ret
    panic("freeing free block");
    80004800:	00005517          	auipc	a0,0x5
    80004804:	3c050513          	addi	a0,a0,960 # 80009bc0 <etext+0xbc0>
    80004808:	81cfc0ef          	jal	80000824 <panic>

000000008000480c <balloc>:
{
    8000480c:	715d                	addi	sp,sp,-80
    8000480e:	e486                	sd	ra,72(sp)
    80004810:	e0a2                	sd	s0,64(sp)
    80004812:	fc26                	sd	s1,56(sp)
    80004814:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80004816:	002cc797          	auipc	a5,0x2cc
    8000481a:	5be7a783          	lw	a5,1470(a5) # 802d0dd4 <sb+0x4>
    8000481e:	0e078263          	beqz	a5,80004902 <balloc+0xf6>
    80004822:	f84a                	sd	s2,48(sp)
    80004824:	f44e                	sd	s3,40(sp)
    80004826:	f052                	sd	s4,32(sp)
    80004828:	ec56                	sd	s5,24(sp)
    8000482a:	e85a                	sd	s6,16(sp)
    8000482c:	e45e                	sd	s7,8(sp)
    8000482e:	e062                	sd	s8,0(sp)
    80004830:	8baa                	mv	s7,a0
    80004832:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80004834:	002ccb17          	auipc	s6,0x2cc
    80004838:	59cb0b13          	addi	s6,s6,1436 # 802d0dd0 <sb>
      m = 1 << (bi % 8);
    8000483c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000483e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80004840:	6c09                	lui	s8,0x2
    80004842:	a09d                	j	800048a8 <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80004844:	97ca                	add	a5,a5,s2
    80004846:	8e55                	or	a2,a2,a3
    80004848:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000484c:	854a                	mv	a0,s2
    8000484e:	79d000ef          	jal	800057ea <log_write>
        brelse(bp);
    80004852:	854a                	mv	a0,s2
    80004854:	e61ff0ef          	jal	800046b4 <brelse>
  bp = bread(dev, bno);
    80004858:	85a6                	mv	a1,s1
    8000485a:	855e                	mv	a0,s7
    8000485c:	d51ff0ef          	jal	800045ac <bread>
    80004860:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80004862:	40000613          	li	a2,1024
    80004866:	4581                	li	a1,0
    80004868:	05850513          	addi	a0,a0,88
    8000486c:	c90fc0ef          	jal	80000cfc <memset>
  log_write(bp);
    80004870:	854a                	mv	a0,s2
    80004872:	779000ef          	jal	800057ea <log_write>
  brelse(bp);
    80004876:	854a                	mv	a0,s2
    80004878:	e3dff0ef          	jal	800046b4 <brelse>
}
    8000487c:	7942                	ld	s2,48(sp)
    8000487e:	79a2                	ld	s3,40(sp)
    80004880:	7a02                	ld	s4,32(sp)
    80004882:	6ae2                	ld	s5,24(sp)
    80004884:	6b42                	ld	s6,16(sp)
    80004886:	6ba2                	ld	s7,8(sp)
    80004888:	6c02                	ld	s8,0(sp)
}
    8000488a:	8526                	mv	a0,s1
    8000488c:	60a6                	ld	ra,72(sp)
    8000488e:	6406                	ld	s0,64(sp)
    80004890:	74e2                	ld	s1,56(sp)
    80004892:	6161                	addi	sp,sp,80
    80004894:	8082                	ret
    brelse(bp);
    80004896:	854a                	mv	a0,s2
    80004898:	e1dff0ef          	jal	800046b4 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000489c:	015c0abb          	addw	s5,s8,s5
    800048a0:	004b2783          	lw	a5,4(s6)
    800048a4:	04faf863          	bgeu	s5,a5,800048f4 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    800048a8:	40dad59b          	sraiw	a1,s5,0xd
    800048ac:	01cb2783          	lw	a5,28(s6)
    800048b0:	9dbd                	addw	a1,a1,a5
    800048b2:	855e                	mv	a0,s7
    800048b4:	cf9ff0ef          	jal	800045ac <bread>
    800048b8:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800048ba:	004b2503          	lw	a0,4(s6)
    800048be:	84d6                	mv	s1,s5
    800048c0:	4701                	li	a4,0
    800048c2:	fca4fae3          	bgeu	s1,a0,80004896 <balloc+0x8a>
      m = 1 << (bi % 8);
    800048c6:	00777693          	andi	a3,a4,7
    800048ca:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800048ce:	41f7579b          	sraiw	a5,a4,0x1f
    800048d2:	01d7d79b          	srliw	a5,a5,0x1d
    800048d6:	9fb9                	addw	a5,a5,a4
    800048d8:	4037d79b          	sraiw	a5,a5,0x3
    800048dc:	00f90633          	add	a2,s2,a5
    800048e0:	05864603          	lbu	a2,88(a2)
    800048e4:	00c6f5b3          	and	a1,a3,a2
    800048e8:	ddb1                	beqz	a1,80004844 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800048ea:	2705                	addiw	a4,a4,1
    800048ec:	2485                	addiw	s1,s1,1
    800048ee:	fd471ae3          	bne	a4,s4,800048c2 <balloc+0xb6>
    800048f2:	b755                	j	80004896 <balloc+0x8a>
    800048f4:	7942                	ld	s2,48(sp)
    800048f6:	79a2                	ld	s3,40(sp)
    800048f8:	7a02                	ld	s4,32(sp)
    800048fa:	6ae2                	ld	s5,24(sp)
    800048fc:	6b42                	ld	s6,16(sp)
    800048fe:	6ba2                	ld	s7,8(sp)
    80004900:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80004902:	00005517          	auipc	a0,0x5
    80004906:	2d650513          	addi	a0,a0,726 # 80009bd8 <etext+0xbd8>
    8000490a:	bf1fb0ef          	jal	800004fa <printf>
  return 0;
    8000490e:	4481                	li	s1,0
    80004910:	bfad                	j	8000488a <balloc+0x7e>

0000000080004912 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80004912:	7179                	addi	sp,sp,-48
    80004914:	f406                	sd	ra,40(sp)
    80004916:	f022                	sd	s0,32(sp)
    80004918:	ec26                	sd	s1,24(sp)
    8000491a:	e84a                	sd	s2,16(sp)
    8000491c:	e44e                	sd	s3,8(sp)
    8000491e:	1800                	addi	s0,sp,48
    80004920:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80004922:	47ad                	li	a5,11
    80004924:	02b7e363          	bltu	a5,a1,8000494a <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    80004928:	02059793          	slli	a5,a1,0x20
    8000492c:	01e7d593          	srli	a1,a5,0x1e
    80004930:	00b509b3          	add	s3,a0,a1
    80004934:	0509a483          	lw	s1,80(s3)
    80004938:	e0b5                	bnez	s1,8000499c <bmap+0x8a>
      addr = balloc(ip->dev);
    8000493a:	4108                	lw	a0,0(a0)
    8000493c:	ed1ff0ef          	jal	8000480c <balloc>
    80004940:	84aa                	mv	s1,a0
      if(addr == 0)
    80004942:	cd29                	beqz	a0,8000499c <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80004944:	04a9a823          	sw	a0,80(s3)
    80004948:	a891                	j	8000499c <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000494a:	ff45879b          	addiw	a5,a1,-12
    8000494e:	873e                	mv	a4,a5
    80004950:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    80004952:	0ff00793          	li	a5,255
    80004956:	06e7e763          	bltu	a5,a4,800049c4 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000495a:	08052483          	lw	s1,128(a0)
    8000495e:	e891                	bnez	s1,80004972 <bmap+0x60>
      addr = balloc(ip->dev);
    80004960:	4108                	lw	a0,0(a0)
    80004962:	eabff0ef          	jal	8000480c <balloc>
    80004966:	84aa                	mv	s1,a0
      if(addr == 0)
    80004968:	c915                	beqz	a0,8000499c <bmap+0x8a>
    8000496a:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000496c:	08a92023          	sw	a0,128(s2)
    80004970:	a011                	j	80004974 <bmap+0x62>
    80004972:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80004974:	85a6                	mv	a1,s1
    80004976:	00092503          	lw	a0,0(s2)
    8000497a:	c33ff0ef          	jal	800045ac <bread>
    8000497e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80004980:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80004984:	02099713          	slli	a4,s3,0x20
    80004988:	01e75593          	srli	a1,a4,0x1e
    8000498c:	97ae                	add	a5,a5,a1
    8000498e:	89be                	mv	s3,a5
    80004990:	4384                	lw	s1,0(a5)
    80004992:	cc89                	beqz	s1,800049ac <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80004994:	8552                	mv	a0,s4
    80004996:	d1fff0ef          	jal	800046b4 <brelse>
    return addr;
    8000499a:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000499c:	8526                	mv	a0,s1
    8000499e:	70a2                	ld	ra,40(sp)
    800049a0:	7402                	ld	s0,32(sp)
    800049a2:	64e2                	ld	s1,24(sp)
    800049a4:	6942                	ld	s2,16(sp)
    800049a6:	69a2                	ld	s3,8(sp)
    800049a8:	6145                	addi	sp,sp,48
    800049aa:	8082                	ret
      addr = balloc(ip->dev);
    800049ac:	00092503          	lw	a0,0(s2)
    800049b0:	e5dff0ef          	jal	8000480c <balloc>
    800049b4:	84aa                	mv	s1,a0
      if(addr){
    800049b6:	dd79                	beqz	a0,80004994 <bmap+0x82>
        a[bn] = addr;
    800049b8:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    800049bc:	8552                	mv	a0,s4
    800049be:	62d000ef          	jal	800057ea <log_write>
    800049c2:	bfc9                	j	80004994 <bmap+0x82>
    800049c4:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800049c6:	00005517          	auipc	a0,0x5
    800049ca:	22a50513          	addi	a0,a0,554 # 80009bf0 <etext+0xbf0>
    800049ce:	e57fb0ef          	jal	80000824 <panic>

00000000800049d2 <iget>:
{
    800049d2:	7179                	addi	sp,sp,-48
    800049d4:	f406                	sd	ra,40(sp)
    800049d6:	f022                	sd	s0,32(sp)
    800049d8:	ec26                	sd	s1,24(sp)
    800049da:	e84a                	sd	s2,16(sp)
    800049dc:	e44e                	sd	s3,8(sp)
    800049de:	e052                	sd	s4,0(sp)
    800049e0:	1800                	addi	s0,sp,48
    800049e2:	892a                	mv	s2,a0
    800049e4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800049e6:	002cc517          	auipc	a0,0x2cc
    800049ea:	40a50513          	addi	a0,a0,1034 # 802d0df0 <itable>
    800049ee:	a3efc0ef          	jal	80000c2c <acquire>
  empty = 0;
    800049f2:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800049f4:	002cc497          	auipc	s1,0x2cc
    800049f8:	41448493          	addi	s1,s1,1044 # 802d0e08 <itable+0x18>
    800049fc:	002ce697          	auipc	a3,0x2ce
    80004a00:	e9c68693          	addi	a3,a3,-356 # 802d2898 <log>
    80004a04:	a809                	j	80004a16 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004a06:	e781                	bnez	a5,80004a0e <iget+0x3c>
    80004a08:	00099363          	bnez	s3,80004a0e <iget+0x3c>
      empty = ip;
    80004a0c:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004a0e:	08848493          	addi	s1,s1,136
    80004a12:	02d48563          	beq	s1,a3,80004a3c <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80004a16:	449c                	lw	a5,8(s1)
    80004a18:	fef057e3          	blez	a5,80004a06 <iget+0x34>
    80004a1c:	4098                	lw	a4,0(s1)
    80004a1e:	ff2718e3          	bne	a4,s2,80004a0e <iget+0x3c>
    80004a22:	40d8                	lw	a4,4(s1)
    80004a24:	ff4715e3          	bne	a4,s4,80004a0e <iget+0x3c>
      ip->ref++;
    80004a28:	2785                	addiw	a5,a5,1
    80004a2a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80004a2c:	002cc517          	auipc	a0,0x2cc
    80004a30:	3c450513          	addi	a0,a0,964 # 802d0df0 <itable>
    80004a34:	a8cfc0ef          	jal	80000cc0 <release>
      return ip;
    80004a38:	89a6                	mv	s3,s1
    80004a3a:	a015                	j	80004a5e <iget+0x8c>
  if(empty == 0)
    80004a3c:	02098a63          	beqz	s3,80004a70 <iget+0x9e>
  ip->dev = dev;
    80004a40:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    80004a44:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80004a48:	4785                	li	a5,1
    80004a4a:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80004a4e:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    80004a52:	002cc517          	auipc	a0,0x2cc
    80004a56:	39e50513          	addi	a0,a0,926 # 802d0df0 <itable>
    80004a5a:	a66fc0ef          	jal	80000cc0 <release>
}
    80004a5e:	854e                	mv	a0,s3
    80004a60:	70a2                	ld	ra,40(sp)
    80004a62:	7402                	ld	s0,32(sp)
    80004a64:	64e2                	ld	s1,24(sp)
    80004a66:	6942                	ld	s2,16(sp)
    80004a68:	69a2                	ld	s3,8(sp)
    80004a6a:	6a02                	ld	s4,0(sp)
    80004a6c:	6145                	addi	sp,sp,48
    80004a6e:	8082                	ret
    panic("iget: no inodes");
    80004a70:	00005517          	auipc	a0,0x5
    80004a74:	19850513          	addi	a0,a0,408 # 80009c08 <etext+0xc08>
    80004a78:	dadfb0ef          	jal	80000824 <panic>

0000000080004a7c <iinit>:
{
    80004a7c:	7179                	addi	sp,sp,-48
    80004a7e:	f406                	sd	ra,40(sp)
    80004a80:	f022                	sd	s0,32(sp)
    80004a82:	ec26                	sd	s1,24(sp)
    80004a84:	e84a                	sd	s2,16(sp)
    80004a86:	e44e                	sd	s3,8(sp)
    80004a88:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80004a8a:	00005597          	auipc	a1,0x5
    80004a8e:	18e58593          	addi	a1,a1,398 # 80009c18 <etext+0xc18>
    80004a92:	002cc517          	auipc	a0,0x2cc
    80004a96:	35e50513          	addi	a0,a0,862 # 802d0df0 <itable>
    80004a9a:	908fc0ef          	jal	80000ba2 <initlock>
  for(i = 0; i < NINODE; i++) {
    80004a9e:	002cc497          	auipc	s1,0x2cc
    80004aa2:	37a48493          	addi	s1,s1,890 # 802d0e18 <itable+0x28>
    80004aa6:	002ce997          	auipc	s3,0x2ce
    80004aaa:	e0298993          	addi	s3,s3,-510 # 802d28a8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80004aae:	00005917          	auipc	s2,0x5
    80004ab2:	17290913          	addi	s2,s2,370 # 80009c20 <etext+0xc20>
    80004ab6:	85ca                	mv	a1,s2
    80004ab8:	8526                	mv	a0,s1
    80004aba:	5f5000ef          	jal	800058ae <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80004abe:	08848493          	addi	s1,s1,136
    80004ac2:	ff349ae3          	bne	s1,s3,80004ab6 <iinit+0x3a>
}
    80004ac6:	70a2                	ld	ra,40(sp)
    80004ac8:	7402                	ld	s0,32(sp)
    80004aca:	64e2                	ld	s1,24(sp)
    80004acc:	6942                	ld	s2,16(sp)
    80004ace:	69a2                	ld	s3,8(sp)
    80004ad0:	6145                	addi	sp,sp,48
    80004ad2:	8082                	ret

0000000080004ad4 <ialloc>:
{
    80004ad4:	7139                	addi	sp,sp,-64
    80004ad6:	fc06                	sd	ra,56(sp)
    80004ad8:	f822                	sd	s0,48(sp)
    80004ada:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80004adc:	002cc717          	auipc	a4,0x2cc
    80004ae0:	30072703          	lw	a4,768(a4) # 802d0ddc <sb+0xc>
    80004ae4:	4785                	li	a5,1
    80004ae6:	06e7f063          	bgeu	a5,a4,80004b46 <ialloc+0x72>
    80004aea:	f426                	sd	s1,40(sp)
    80004aec:	f04a                	sd	s2,32(sp)
    80004aee:	ec4e                	sd	s3,24(sp)
    80004af0:	e852                	sd	s4,16(sp)
    80004af2:	e456                	sd	s5,8(sp)
    80004af4:	e05a                	sd	s6,0(sp)
    80004af6:	8aaa                	mv	s5,a0
    80004af8:	8b2e                	mv	s6,a1
    80004afa:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80004afc:	002cca17          	auipc	s4,0x2cc
    80004b00:	2d4a0a13          	addi	s4,s4,724 # 802d0dd0 <sb>
    80004b04:	00495593          	srli	a1,s2,0x4
    80004b08:	018a2783          	lw	a5,24(s4)
    80004b0c:	9dbd                	addw	a1,a1,a5
    80004b0e:	8556                	mv	a0,s5
    80004b10:	a9dff0ef          	jal	800045ac <bread>
    80004b14:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80004b16:	05850993          	addi	s3,a0,88
    80004b1a:	00f97793          	andi	a5,s2,15
    80004b1e:	079a                	slli	a5,a5,0x6
    80004b20:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80004b22:	00099783          	lh	a5,0(s3)
    80004b26:	cb9d                	beqz	a5,80004b5c <ialloc+0x88>
    brelse(bp);
    80004b28:	b8dff0ef          	jal	800046b4 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80004b2c:	0905                	addi	s2,s2,1
    80004b2e:	00ca2703          	lw	a4,12(s4)
    80004b32:	0009079b          	sext.w	a5,s2
    80004b36:	fce7e7e3          	bltu	a5,a4,80004b04 <ialloc+0x30>
    80004b3a:	74a2                	ld	s1,40(sp)
    80004b3c:	7902                	ld	s2,32(sp)
    80004b3e:	69e2                	ld	s3,24(sp)
    80004b40:	6a42                	ld	s4,16(sp)
    80004b42:	6aa2                	ld	s5,8(sp)
    80004b44:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80004b46:	00005517          	auipc	a0,0x5
    80004b4a:	0e250513          	addi	a0,a0,226 # 80009c28 <etext+0xc28>
    80004b4e:	9adfb0ef          	jal	800004fa <printf>
  return 0;
    80004b52:	4501                	li	a0,0
}
    80004b54:	70e2                	ld	ra,56(sp)
    80004b56:	7442                	ld	s0,48(sp)
    80004b58:	6121                	addi	sp,sp,64
    80004b5a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80004b5c:	04000613          	li	a2,64
    80004b60:	4581                	li	a1,0
    80004b62:	854e                	mv	a0,s3
    80004b64:	998fc0ef          	jal	80000cfc <memset>
      dip->type = type;
    80004b68:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80004b6c:	8526                	mv	a0,s1
    80004b6e:	47d000ef          	jal	800057ea <log_write>
      brelse(bp);
    80004b72:	8526                	mv	a0,s1
    80004b74:	b41ff0ef          	jal	800046b4 <brelse>
      return iget(dev, inum);
    80004b78:	0009059b          	sext.w	a1,s2
    80004b7c:	8556                	mv	a0,s5
    80004b7e:	e55ff0ef          	jal	800049d2 <iget>
    80004b82:	74a2                	ld	s1,40(sp)
    80004b84:	7902                	ld	s2,32(sp)
    80004b86:	69e2                	ld	s3,24(sp)
    80004b88:	6a42                	ld	s4,16(sp)
    80004b8a:	6aa2                	ld	s5,8(sp)
    80004b8c:	6b02                	ld	s6,0(sp)
    80004b8e:	b7d9                	j	80004b54 <ialloc+0x80>

0000000080004b90 <iupdate>:
{
    80004b90:	1101                	addi	sp,sp,-32
    80004b92:	ec06                	sd	ra,24(sp)
    80004b94:	e822                	sd	s0,16(sp)
    80004b96:	e426                	sd	s1,8(sp)
    80004b98:	e04a                	sd	s2,0(sp)
    80004b9a:	1000                	addi	s0,sp,32
    80004b9c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004b9e:	415c                	lw	a5,4(a0)
    80004ba0:	0047d79b          	srliw	a5,a5,0x4
    80004ba4:	002cc597          	auipc	a1,0x2cc
    80004ba8:	2445a583          	lw	a1,580(a1) # 802d0de8 <sb+0x18>
    80004bac:	9dbd                	addw	a1,a1,a5
    80004bae:	4108                	lw	a0,0(a0)
    80004bb0:	9fdff0ef          	jal	800045ac <bread>
    80004bb4:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004bb6:	05850793          	addi	a5,a0,88
    80004bba:	40d8                	lw	a4,4(s1)
    80004bbc:	8b3d                	andi	a4,a4,15
    80004bbe:	071a                	slli	a4,a4,0x6
    80004bc0:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80004bc2:	04449703          	lh	a4,68(s1)
    80004bc6:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80004bca:	04649703          	lh	a4,70(s1)
    80004bce:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80004bd2:	04849703          	lh	a4,72(s1)
    80004bd6:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80004bda:	04a49703          	lh	a4,74(s1)
    80004bde:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80004be2:	44f8                	lw	a4,76(s1)
    80004be4:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80004be6:	03400613          	li	a2,52
    80004bea:	05048593          	addi	a1,s1,80
    80004bee:	00c78513          	addi	a0,a5,12
    80004bf2:	96afc0ef          	jal	80000d5c <memmove>
  log_write(bp);
    80004bf6:	854a                	mv	a0,s2
    80004bf8:	3f3000ef          	jal	800057ea <log_write>
  brelse(bp);
    80004bfc:	854a                	mv	a0,s2
    80004bfe:	ab7ff0ef          	jal	800046b4 <brelse>
}
    80004c02:	60e2                	ld	ra,24(sp)
    80004c04:	6442                	ld	s0,16(sp)
    80004c06:	64a2                	ld	s1,8(sp)
    80004c08:	6902                	ld	s2,0(sp)
    80004c0a:	6105                	addi	sp,sp,32
    80004c0c:	8082                	ret

0000000080004c0e <idup>:
{
    80004c0e:	1101                	addi	sp,sp,-32
    80004c10:	ec06                	sd	ra,24(sp)
    80004c12:	e822                	sd	s0,16(sp)
    80004c14:	e426                	sd	s1,8(sp)
    80004c16:	1000                	addi	s0,sp,32
    80004c18:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004c1a:	002cc517          	auipc	a0,0x2cc
    80004c1e:	1d650513          	addi	a0,a0,470 # 802d0df0 <itable>
    80004c22:	80afc0ef          	jal	80000c2c <acquire>
  ip->ref++;
    80004c26:	449c                	lw	a5,8(s1)
    80004c28:	2785                	addiw	a5,a5,1
    80004c2a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004c2c:	002cc517          	auipc	a0,0x2cc
    80004c30:	1c450513          	addi	a0,a0,452 # 802d0df0 <itable>
    80004c34:	88cfc0ef          	jal	80000cc0 <release>
}
    80004c38:	8526                	mv	a0,s1
    80004c3a:	60e2                	ld	ra,24(sp)
    80004c3c:	6442                	ld	s0,16(sp)
    80004c3e:	64a2                	ld	s1,8(sp)
    80004c40:	6105                	addi	sp,sp,32
    80004c42:	8082                	ret

0000000080004c44 <ilock>:
{
    80004c44:	1101                	addi	sp,sp,-32
    80004c46:	ec06                	sd	ra,24(sp)
    80004c48:	e822                	sd	s0,16(sp)
    80004c4a:	e426                	sd	s1,8(sp)
    80004c4c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80004c4e:	cd19                	beqz	a0,80004c6c <ilock+0x28>
    80004c50:	84aa                	mv	s1,a0
    80004c52:	451c                	lw	a5,8(a0)
    80004c54:	00f05c63          	blez	a5,80004c6c <ilock+0x28>
  acquiresleep(&ip->lock);
    80004c58:	0541                	addi	a0,a0,16
    80004c5a:	48b000ef          	jal	800058e4 <acquiresleep>
  if(ip->valid == 0){
    80004c5e:	40bc                	lw	a5,64(s1)
    80004c60:	cf89                	beqz	a5,80004c7a <ilock+0x36>
}
    80004c62:	60e2                	ld	ra,24(sp)
    80004c64:	6442                	ld	s0,16(sp)
    80004c66:	64a2                	ld	s1,8(sp)
    80004c68:	6105                	addi	sp,sp,32
    80004c6a:	8082                	ret
    80004c6c:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80004c6e:	00005517          	auipc	a0,0x5
    80004c72:	fd250513          	addi	a0,a0,-46 # 80009c40 <etext+0xc40>
    80004c76:	baffb0ef          	jal	80000824 <panic>
    80004c7a:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004c7c:	40dc                	lw	a5,4(s1)
    80004c7e:	0047d79b          	srliw	a5,a5,0x4
    80004c82:	002cc597          	auipc	a1,0x2cc
    80004c86:	1665a583          	lw	a1,358(a1) # 802d0de8 <sb+0x18>
    80004c8a:	9dbd                	addw	a1,a1,a5
    80004c8c:	4088                	lw	a0,0(s1)
    80004c8e:	91fff0ef          	jal	800045ac <bread>
    80004c92:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004c94:	05850593          	addi	a1,a0,88
    80004c98:	40dc                	lw	a5,4(s1)
    80004c9a:	8bbd                	andi	a5,a5,15
    80004c9c:	079a                	slli	a5,a5,0x6
    80004c9e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80004ca0:	00059783          	lh	a5,0(a1)
    80004ca4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004ca8:	00259783          	lh	a5,2(a1)
    80004cac:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80004cb0:	00459783          	lh	a5,4(a1)
    80004cb4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004cb8:	00659783          	lh	a5,6(a1)
    80004cbc:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80004cc0:	459c                	lw	a5,8(a1)
    80004cc2:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80004cc4:	03400613          	li	a2,52
    80004cc8:	05b1                	addi	a1,a1,12
    80004cca:	05048513          	addi	a0,s1,80
    80004cce:	88efc0ef          	jal	80000d5c <memmove>
    brelse(bp);
    80004cd2:	854a                	mv	a0,s2
    80004cd4:	9e1ff0ef          	jal	800046b4 <brelse>
    ip->valid = 1;
    80004cd8:	4785                	li	a5,1
    80004cda:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80004cdc:	04449783          	lh	a5,68(s1)
    80004ce0:	c399                	beqz	a5,80004ce6 <ilock+0xa2>
    80004ce2:	6902                	ld	s2,0(sp)
    80004ce4:	bfbd                	j	80004c62 <ilock+0x1e>
      panic("ilock: no type");
    80004ce6:	00005517          	auipc	a0,0x5
    80004cea:	f6250513          	addi	a0,a0,-158 # 80009c48 <etext+0xc48>
    80004cee:	b37fb0ef          	jal	80000824 <panic>

0000000080004cf2 <iunlock>:
{
    80004cf2:	1101                	addi	sp,sp,-32
    80004cf4:	ec06                	sd	ra,24(sp)
    80004cf6:	e822                	sd	s0,16(sp)
    80004cf8:	e426                	sd	s1,8(sp)
    80004cfa:	e04a                	sd	s2,0(sp)
    80004cfc:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004cfe:	c505                	beqz	a0,80004d26 <iunlock+0x34>
    80004d00:	84aa                	mv	s1,a0
    80004d02:	01050913          	addi	s2,a0,16
    80004d06:	854a                	mv	a0,s2
    80004d08:	45b000ef          	jal	80005962 <holdingsleep>
    80004d0c:	cd09                	beqz	a0,80004d26 <iunlock+0x34>
    80004d0e:	449c                	lw	a5,8(s1)
    80004d10:	00f05b63          	blez	a5,80004d26 <iunlock+0x34>
  releasesleep(&ip->lock);
    80004d14:	854a                	mv	a0,s2
    80004d16:	415000ef          	jal	8000592a <releasesleep>
}
    80004d1a:	60e2                	ld	ra,24(sp)
    80004d1c:	6442                	ld	s0,16(sp)
    80004d1e:	64a2                	ld	s1,8(sp)
    80004d20:	6902                	ld	s2,0(sp)
    80004d22:	6105                	addi	sp,sp,32
    80004d24:	8082                	ret
    panic("iunlock");
    80004d26:	00005517          	auipc	a0,0x5
    80004d2a:	f3250513          	addi	a0,a0,-206 # 80009c58 <etext+0xc58>
    80004d2e:	af7fb0ef          	jal	80000824 <panic>

0000000080004d32 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004d32:	7179                	addi	sp,sp,-48
    80004d34:	f406                	sd	ra,40(sp)
    80004d36:	f022                	sd	s0,32(sp)
    80004d38:	ec26                	sd	s1,24(sp)
    80004d3a:	e84a                	sd	s2,16(sp)
    80004d3c:	e44e                	sd	s3,8(sp)
    80004d3e:	1800                	addi	s0,sp,48
    80004d40:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004d42:	05050493          	addi	s1,a0,80
    80004d46:	08050913          	addi	s2,a0,128
    80004d4a:	a021                	j	80004d52 <itrunc+0x20>
    80004d4c:	0491                	addi	s1,s1,4
    80004d4e:	01248b63          	beq	s1,s2,80004d64 <itrunc+0x32>
    if(ip->addrs[i]){
    80004d52:	408c                	lw	a1,0(s1)
    80004d54:	dde5                	beqz	a1,80004d4c <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80004d56:	0009a503          	lw	a0,0(s3)
    80004d5a:	a47ff0ef          	jal	800047a0 <bfree>
      ip->addrs[i] = 0;
    80004d5e:	0004a023          	sw	zero,0(s1)
    80004d62:	b7ed                	j	80004d4c <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80004d64:	0809a583          	lw	a1,128(s3)
    80004d68:	ed89                	bnez	a1,80004d82 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004d6a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004d6e:	854e                	mv	a0,s3
    80004d70:	e21ff0ef          	jal	80004b90 <iupdate>
}
    80004d74:	70a2                	ld	ra,40(sp)
    80004d76:	7402                	ld	s0,32(sp)
    80004d78:	64e2                	ld	s1,24(sp)
    80004d7a:	6942                	ld	s2,16(sp)
    80004d7c:	69a2                	ld	s3,8(sp)
    80004d7e:	6145                	addi	sp,sp,48
    80004d80:	8082                	ret
    80004d82:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004d84:	0009a503          	lw	a0,0(s3)
    80004d88:	825ff0ef          	jal	800045ac <bread>
    80004d8c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80004d8e:	05850493          	addi	s1,a0,88
    80004d92:	45850913          	addi	s2,a0,1112
    80004d96:	a021                	j	80004d9e <itrunc+0x6c>
    80004d98:	0491                	addi	s1,s1,4
    80004d9a:	01248963          	beq	s1,s2,80004dac <itrunc+0x7a>
      if(a[j])
    80004d9e:	408c                	lw	a1,0(s1)
    80004da0:	dde5                	beqz	a1,80004d98 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80004da2:	0009a503          	lw	a0,0(s3)
    80004da6:	9fbff0ef          	jal	800047a0 <bfree>
    80004daa:	b7fd                	j	80004d98 <itrunc+0x66>
    brelse(bp);
    80004dac:	8552                	mv	a0,s4
    80004dae:	907ff0ef          	jal	800046b4 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004db2:	0809a583          	lw	a1,128(s3)
    80004db6:	0009a503          	lw	a0,0(s3)
    80004dba:	9e7ff0ef          	jal	800047a0 <bfree>
    ip->addrs[NDIRECT] = 0;
    80004dbe:	0809a023          	sw	zero,128(s3)
    80004dc2:	6a02                	ld	s4,0(sp)
    80004dc4:	b75d                	j	80004d6a <itrunc+0x38>

0000000080004dc6 <iput>:
{
    80004dc6:	1101                	addi	sp,sp,-32
    80004dc8:	ec06                	sd	ra,24(sp)
    80004dca:	e822                	sd	s0,16(sp)
    80004dcc:	e426                	sd	s1,8(sp)
    80004dce:	1000                	addi	s0,sp,32
    80004dd0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004dd2:	002cc517          	auipc	a0,0x2cc
    80004dd6:	01e50513          	addi	a0,a0,30 # 802d0df0 <itable>
    80004dda:	e53fb0ef          	jal	80000c2c <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004dde:	4498                	lw	a4,8(s1)
    80004de0:	4785                	li	a5,1
    80004de2:	02f70063          	beq	a4,a5,80004e02 <iput+0x3c>
  ip->ref--;
    80004de6:	449c                	lw	a5,8(s1)
    80004de8:	37fd                	addiw	a5,a5,-1
    80004dea:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004dec:	002cc517          	auipc	a0,0x2cc
    80004df0:	00450513          	addi	a0,a0,4 # 802d0df0 <itable>
    80004df4:	ecdfb0ef          	jal	80000cc0 <release>
}
    80004df8:	60e2                	ld	ra,24(sp)
    80004dfa:	6442                	ld	s0,16(sp)
    80004dfc:	64a2                	ld	s1,8(sp)
    80004dfe:	6105                	addi	sp,sp,32
    80004e00:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004e02:	40bc                	lw	a5,64(s1)
    80004e04:	d3ed                	beqz	a5,80004de6 <iput+0x20>
    80004e06:	04a49783          	lh	a5,74(s1)
    80004e0a:	fff1                	bnez	a5,80004de6 <iput+0x20>
    80004e0c:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80004e0e:	01048793          	addi	a5,s1,16
    80004e12:	893e                	mv	s2,a5
    80004e14:	853e                	mv	a0,a5
    80004e16:	2cf000ef          	jal	800058e4 <acquiresleep>
    release(&itable.lock);
    80004e1a:	002cc517          	auipc	a0,0x2cc
    80004e1e:	fd650513          	addi	a0,a0,-42 # 802d0df0 <itable>
    80004e22:	e9ffb0ef          	jal	80000cc0 <release>
    itrunc(ip);
    80004e26:	8526                	mv	a0,s1
    80004e28:	f0bff0ef          	jal	80004d32 <itrunc>
    ip->type = 0;
    80004e2c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004e30:	8526                	mv	a0,s1
    80004e32:	d5fff0ef          	jal	80004b90 <iupdate>
    ip->valid = 0;
    80004e36:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004e3a:	854a                	mv	a0,s2
    80004e3c:	2ef000ef          	jal	8000592a <releasesleep>
    acquire(&itable.lock);
    80004e40:	002cc517          	auipc	a0,0x2cc
    80004e44:	fb050513          	addi	a0,a0,-80 # 802d0df0 <itable>
    80004e48:	de5fb0ef          	jal	80000c2c <acquire>
    80004e4c:	6902                	ld	s2,0(sp)
    80004e4e:	bf61                	j	80004de6 <iput+0x20>

0000000080004e50 <iunlockput>:
{
    80004e50:	1101                	addi	sp,sp,-32
    80004e52:	ec06                	sd	ra,24(sp)
    80004e54:	e822                	sd	s0,16(sp)
    80004e56:	e426                	sd	s1,8(sp)
    80004e58:	1000                	addi	s0,sp,32
    80004e5a:	84aa                	mv	s1,a0
  iunlock(ip);
    80004e5c:	e97ff0ef          	jal	80004cf2 <iunlock>
  iput(ip);
    80004e60:	8526                	mv	a0,s1
    80004e62:	f65ff0ef          	jal	80004dc6 <iput>
}
    80004e66:	60e2                	ld	ra,24(sp)
    80004e68:	6442                	ld	s0,16(sp)
    80004e6a:	64a2                	ld	s1,8(sp)
    80004e6c:	6105                	addi	sp,sp,32
    80004e6e:	8082                	ret

0000000080004e70 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80004e70:	002cc717          	auipc	a4,0x2cc
    80004e74:	f6c72703          	lw	a4,-148(a4) # 802d0ddc <sb+0xc>
    80004e78:	4785                	li	a5,1
    80004e7a:	0ae7fe63          	bgeu	a5,a4,80004f36 <ireclaim+0xc6>
{
    80004e7e:	7139                	addi	sp,sp,-64
    80004e80:	fc06                	sd	ra,56(sp)
    80004e82:	f822                	sd	s0,48(sp)
    80004e84:	f426                	sd	s1,40(sp)
    80004e86:	f04a                	sd	s2,32(sp)
    80004e88:	ec4e                	sd	s3,24(sp)
    80004e8a:	e852                	sd	s4,16(sp)
    80004e8c:	e456                	sd	s5,8(sp)
    80004e8e:	e05a                	sd	s6,0(sp)
    80004e90:	0080                	addi	s0,sp,64
    80004e92:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80004e94:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80004e96:	002cca17          	auipc	s4,0x2cc
    80004e9a:	f3aa0a13          	addi	s4,s4,-198 # 802d0dd0 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80004e9e:	00005b17          	auipc	s6,0x5
    80004ea2:	dc2b0b13          	addi	s6,s6,-574 # 80009c60 <etext+0xc60>
    80004ea6:	a099                	j	80004eec <ireclaim+0x7c>
    80004ea8:	85ce                	mv	a1,s3
    80004eaa:	855a                	mv	a0,s6
    80004eac:	e4efb0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    80004eb0:	85ce                	mv	a1,s3
    80004eb2:	8556                	mv	a0,s5
    80004eb4:	b1fff0ef          	jal	800049d2 <iget>
    80004eb8:	89aa                	mv	s3,a0
    brelse(bp);
    80004eba:	854a                	mv	a0,s2
    80004ebc:	ff8ff0ef          	jal	800046b4 <brelse>
    if (ip) {
    80004ec0:	00098f63          	beqz	s3,80004ede <ireclaim+0x6e>
      begin_op();
    80004ec4:	78c000ef          	jal	80005650 <begin_op>
      ilock(ip);
    80004ec8:	854e                	mv	a0,s3
    80004eca:	d7bff0ef          	jal	80004c44 <ilock>
      iunlock(ip);
    80004ece:	854e                	mv	a0,s3
    80004ed0:	e23ff0ef          	jal	80004cf2 <iunlock>
      iput(ip);
    80004ed4:	854e                	mv	a0,s3
    80004ed6:	ef1ff0ef          	jal	80004dc6 <iput>
      end_op();
    80004eda:	7e6000ef          	jal	800056c0 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80004ede:	0485                	addi	s1,s1,1
    80004ee0:	00ca2703          	lw	a4,12(s4)
    80004ee4:	0004879b          	sext.w	a5,s1
    80004ee8:	02e7fd63          	bgeu	a5,a4,80004f22 <ireclaim+0xb2>
    80004eec:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80004ef0:	0044d593          	srli	a1,s1,0x4
    80004ef4:	018a2783          	lw	a5,24(s4)
    80004ef8:	9dbd                	addw	a1,a1,a5
    80004efa:	8556                	mv	a0,s5
    80004efc:	eb0ff0ef          	jal	800045ac <bread>
    80004f00:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80004f02:	05850793          	addi	a5,a0,88
    80004f06:	00f9f713          	andi	a4,s3,15
    80004f0a:	071a                	slli	a4,a4,0x6
    80004f0c:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80004f0e:	00079703          	lh	a4,0(a5)
    80004f12:	c701                	beqz	a4,80004f1a <ireclaim+0xaa>
    80004f14:	00679783          	lh	a5,6(a5)
    80004f18:	dbc1                	beqz	a5,80004ea8 <ireclaim+0x38>
    brelse(bp);
    80004f1a:	854a                	mv	a0,s2
    80004f1c:	f98ff0ef          	jal	800046b4 <brelse>
    if (ip) {
    80004f20:	bf7d                	j	80004ede <ireclaim+0x6e>
}
    80004f22:	70e2                	ld	ra,56(sp)
    80004f24:	7442                	ld	s0,48(sp)
    80004f26:	74a2                	ld	s1,40(sp)
    80004f28:	7902                	ld	s2,32(sp)
    80004f2a:	69e2                	ld	s3,24(sp)
    80004f2c:	6a42                	ld	s4,16(sp)
    80004f2e:	6aa2                	ld	s5,8(sp)
    80004f30:	6b02                	ld	s6,0(sp)
    80004f32:	6121                	addi	sp,sp,64
    80004f34:	8082                	ret
    80004f36:	8082                	ret

0000000080004f38 <fsinit>:
fsinit(int dev) {
    80004f38:	1101                	addi	sp,sp,-32
    80004f3a:	ec06                	sd	ra,24(sp)
    80004f3c:	e822                	sd	s0,16(sp)
    80004f3e:	e426                	sd	s1,8(sp)
    80004f40:	e04a                	sd	s2,0(sp)
    80004f42:	1000                	addi	s0,sp,32
    80004f44:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80004f46:	4585                	li	a1,1
    80004f48:	e64ff0ef          	jal	800045ac <bread>
    80004f4c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80004f4e:	02000613          	li	a2,32
    80004f52:	05850593          	addi	a1,a0,88
    80004f56:	002cc517          	auipc	a0,0x2cc
    80004f5a:	e7a50513          	addi	a0,a0,-390 # 802d0dd0 <sb>
    80004f5e:	dfffb0ef          	jal	80000d5c <memmove>
  brelse(bp);
    80004f62:	8526                	mv	a0,s1
    80004f64:	f50ff0ef          	jal	800046b4 <brelse>
  if(sb.magic != FSMAGIC)
    80004f68:	002cc717          	auipc	a4,0x2cc
    80004f6c:	e6872703          	lw	a4,-408(a4) # 802d0dd0 <sb>
    80004f70:	102037b7          	lui	a5,0x10203
    80004f74:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80004f78:	02f71263          	bne	a4,a5,80004f9c <fsinit+0x64>
  initlog(dev, &sb);
    80004f7c:	002cc597          	auipc	a1,0x2cc
    80004f80:	e5458593          	addi	a1,a1,-428 # 802d0dd0 <sb>
    80004f84:	854a                	mv	a0,s2
    80004f86:	648000ef          	jal	800055ce <initlog>
  ireclaim(dev);
    80004f8a:	854a                	mv	a0,s2
    80004f8c:	ee5ff0ef          	jal	80004e70 <ireclaim>
}
    80004f90:	60e2                	ld	ra,24(sp)
    80004f92:	6442                	ld	s0,16(sp)
    80004f94:	64a2                	ld	s1,8(sp)
    80004f96:	6902                	ld	s2,0(sp)
    80004f98:	6105                	addi	sp,sp,32
    80004f9a:	8082                	ret
    panic("invalid file system");
    80004f9c:	00005517          	auipc	a0,0x5
    80004fa0:	ce450513          	addi	a0,a0,-796 # 80009c80 <etext+0xc80>
    80004fa4:	881fb0ef          	jal	80000824 <panic>

0000000080004fa8 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004fa8:	1141                	addi	sp,sp,-16
    80004faa:	e406                	sd	ra,8(sp)
    80004fac:	e022                	sd	s0,0(sp)
    80004fae:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004fb0:	411c                	lw	a5,0(a0)
    80004fb2:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004fb4:	415c                	lw	a5,4(a0)
    80004fb6:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004fb8:	04451783          	lh	a5,68(a0)
    80004fbc:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004fc0:	04a51783          	lh	a5,74(a0)
    80004fc4:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004fc8:	04c56783          	lwu	a5,76(a0)
    80004fcc:	e99c                	sd	a5,16(a1)
}
    80004fce:	60a2                	ld	ra,8(sp)
    80004fd0:	6402                	ld	s0,0(sp)
    80004fd2:	0141                	addi	sp,sp,16
    80004fd4:	8082                	ret

0000000080004fd6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004fd6:	457c                	lw	a5,76(a0)
    80004fd8:	0ed7e663          	bltu	a5,a3,800050c4 <readi+0xee>
{
    80004fdc:	7159                	addi	sp,sp,-112
    80004fde:	f486                	sd	ra,104(sp)
    80004fe0:	f0a2                	sd	s0,96(sp)
    80004fe2:	eca6                	sd	s1,88(sp)
    80004fe4:	e0d2                	sd	s4,64(sp)
    80004fe6:	fc56                	sd	s5,56(sp)
    80004fe8:	f85a                	sd	s6,48(sp)
    80004fea:	f45e                	sd	s7,40(sp)
    80004fec:	1880                	addi	s0,sp,112
    80004fee:	8b2a                	mv	s6,a0
    80004ff0:	8bae                	mv	s7,a1
    80004ff2:	8a32                	mv	s4,a2
    80004ff4:	84b6                	mv	s1,a3
    80004ff6:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004ff8:	9f35                	addw	a4,a4,a3
    return 0;
    80004ffa:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004ffc:	0ad76b63          	bltu	a4,a3,800050b2 <readi+0xdc>
    80005000:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80005002:	00e7f463          	bgeu	a5,a4,8000500a <readi+0x34>
    n = ip->size - off;
    80005006:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000500a:	080a8b63          	beqz	s5,800050a0 <readi+0xca>
    8000500e:	e8ca                	sd	s2,80(sp)
    80005010:	f062                	sd	s8,32(sp)
    80005012:	ec66                	sd	s9,24(sp)
    80005014:	e86a                	sd	s10,16(sp)
    80005016:	e46e                	sd	s11,8(sp)
    80005018:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000501a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000501e:	5c7d                	li	s8,-1
    80005020:	a80d                	j	80005052 <readi+0x7c>
    80005022:	020d1d93          	slli	s11,s10,0x20
    80005026:	020ddd93          	srli	s11,s11,0x20
    8000502a:	05890613          	addi	a2,s2,88
    8000502e:	86ee                	mv	a3,s11
    80005030:	963e                	add	a2,a2,a5
    80005032:	85d2                	mv	a1,s4
    80005034:	855e                	mv	a0,s7
    80005036:	979fe0ef          	jal	800039ae <either_copyout>
    8000503a:	05850363          	beq	a0,s8,80005080 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000503e:	854a                	mv	a0,s2
    80005040:	e74ff0ef          	jal	800046b4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80005044:	013d09bb          	addw	s3,s10,s3
    80005048:	009d04bb          	addw	s1,s10,s1
    8000504c:	9a6e                	add	s4,s4,s11
    8000504e:	0559f363          	bgeu	s3,s5,80005094 <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80005052:	00a4d59b          	srliw	a1,s1,0xa
    80005056:	855a                	mv	a0,s6
    80005058:	8bbff0ef          	jal	80004912 <bmap>
    8000505c:	85aa                	mv	a1,a0
    if(addr == 0)
    8000505e:	c139                	beqz	a0,800050a4 <readi+0xce>
    bp = bread(ip->dev, addr);
    80005060:	000b2503          	lw	a0,0(s6)
    80005064:	d48ff0ef          	jal	800045ac <bread>
    80005068:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000506a:	3ff4f793          	andi	a5,s1,1023
    8000506e:	40fc873b          	subw	a4,s9,a5
    80005072:	413a86bb          	subw	a3,s5,s3
    80005076:	8d3a                	mv	s10,a4
    80005078:	fae6f5e3          	bgeu	a3,a4,80005022 <readi+0x4c>
    8000507c:	8d36                	mv	s10,a3
    8000507e:	b755                	j	80005022 <readi+0x4c>
      brelse(bp);
    80005080:	854a                	mv	a0,s2
    80005082:	e32ff0ef          	jal	800046b4 <brelse>
      tot = -1;
    80005086:	59fd                	li	s3,-1
      break;
    80005088:	6946                	ld	s2,80(sp)
    8000508a:	7c02                	ld	s8,32(sp)
    8000508c:	6ce2                	ld	s9,24(sp)
    8000508e:	6d42                	ld	s10,16(sp)
    80005090:	6da2                	ld	s11,8(sp)
    80005092:	a831                	j	800050ae <readi+0xd8>
    80005094:	6946                	ld	s2,80(sp)
    80005096:	7c02                	ld	s8,32(sp)
    80005098:	6ce2                	ld	s9,24(sp)
    8000509a:	6d42                	ld	s10,16(sp)
    8000509c:	6da2                	ld	s11,8(sp)
    8000509e:	a801                	j	800050ae <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800050a0:	89d6                	mv	s3,s5
    800050a2:	a031                	j	800050ae <readi+0xd8>
    800050a4:	6946                	ld	s2,80(sp)
    800050a6:	7c02                	ld	s8,32(sp)
    800050a8:	6ce2                	ld	s9,24(sp)
    800050aa:	6d42                	ld	s10,16(sp)
    800050ac:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800050ae:	854e                	mv	a0,s3
    800050b0:	69a6                	ld	s3,72(sp)
}
    800050b2:	70a6                	ld	ra,104(sp)
    800050b4:	7406                	ld	s0,96(sp)
    800050b6:	64e6                	ld	s1,88(sp)
    800050b8:	6a06                	ld	s4,64(sp)
    800050ba:	7ae2                	ld	s5,56(sp)
    800050bc:	7b42                	ld	s6,48(sp)
    800050be:	7ba2                	ld	s7,40(sp)
    800050c0:	6165                	addi	sp,sp,112
    800050c2:	8082                	ret
    return 0;
    800050c4:	4501                	li	a0,0
}
    800050c6:	8082                	ret

00000000800050c8 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800050c8:	457c                	lw	a5,76(a0)
    800050ca:	0ed7eb63          	bltu	a5,a3,800051c0 <writei+0xf8>
{
    800050ce:	7159                	addi	sp,sp,-112
    800050d0:	f486                	sd	ra,104(sp)
    800050d2:	f0a2                	sd	s0,96(sp)
    800050d4:	e8ca                	sd	s2,80(sp)
    800050d6:	e0d2                	sd	s4,64(sp)
    800050d8:	fc56                	sd	s5,56(sp)
    800050da:	f85a                	sd	s6,48(sp)
    800050dc:	f45e                	sd	s7,40(sp)
    800050de:	1880                	addi	s0,sp,112
    800050e0:	8aaa                	mv	s5,a0
    800050e2:	8bae                	mv	s7,a1
    800050e4:	8a32                	mv	s4,a2
    800050e6:	8936                	mv	s2,a3
    800050e8:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800050ea:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800050ee:	00043737          	lui	a4,0x43
    800050f2:	0cf76963          	bltu	a4,a5,800051c4 <writei+0xfc>
    800050f6:	0cd7e763          	bltu	a5,a3,800051c4 <writei+0xfc>
    800050fa:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800050fc:	0a0b0a63          	beqz	s6,800051b0 <writei+0xe8>
    80005100:	eca6                	sd	s1,88(sp)
    80005102:	f062                	sd	s8,32(sp)
    80005104:	ec66                	sd	s9,24(sp)
    80005106:	e86a                	sd	s10,16(sp)
    80005108:	e46e                	sd	s11,8(sp)
    8000510a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000510c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80005110:	5c7d                	li	s8,-1
    80005112:	a825                	j	8000514a <writei+0x82>
    80005114:	020d1d93          	slli	s11,s10,0x20
    80005118:	020ddd93          	srli	s11,s11,0x20
    8000511c:	05848513          	addi	a0,s1,88
    80005120:	86ee                	mv	a3,s11
    80005122:	8652                	mv	a2,s4
    80005124:	85de                	mv	a1,s7
    80005126:	953e                	add	a0,a0,a5
    80005128:	8d1fe0ef          	jal	800039f8 <either_copyin>
    8000512c:	05850663          	beq	a0,s8,80005178 <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80005130:	8526                	mv	a0,s1
    80005132:	6b8000ef          	jal	800057ea <log_write>
    brelse(bp);
    80005136:	8526                	mv	a0,s1
    80005138:	d7cff0ef          	jal	800046b4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000513c:	013d09bb          	addw	s3,s10,s3
    80005140:	012d093b          	addw	s2,s10,s2
    80005144:	9a6e                	add	s4,s4,s11
    80005146:	0369fc63          	bgeu	s3,s6,8000517e <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    8000514a:	00a9559b          	srliw	a1,s2,0xa
    8000514e:	8556                	mv	a0,s5
    80005150:	fc2ff0ef          	jal	80004912 <bmap>
    80005154:	85aa                	mv	a1,a0
    if(addr == 0)
    80005156:	c505                	beqz	a0,8000517e <writei+0xb6>
    bp = bread(ip->dev, addr);
    80005158:	000aa503          	lw	a0,0(s5) # 1000 <_entry-0x7ffff000>
    8000515c:	c50ff0ef          	jal	800045ac <bread>
    80005160:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80005162:	3ff97793          	andi	a5,s2,1023
    80005166:	40fc873b          	subw	a4,s9,a5
    8000516a:	413b06bb          	subw	a3,s6,s3
    8000516e:	8d3a                	mv	s10,a4
    80005170:	fae6f2e3          	bgeu	a3,a4,80005114 <writei+0x4c>
    80005174:	8d36                	mv	s10,a3
    80005176:	bf79                	j	80005114 <writei+0x4c>
      brelse(bp);
    80005178:	8526                	mv	a0,s1
    8000517a:	d3aff0ef          	jal	800046b4 <brelse>
  }

  if(off > ip->size)
    8000517e:	04caa783          	lw	a5,76(s5)
    80005182:	0327f963          	bgeu	a5,s2,800051b4 <writei+0xec>
    ip->size = off;
    80005186:	052aa623          	sw	s2,76(s5)
    8000518a:	64e6                	ld	s1,88(sp)
    8000518c:	7c02                	ld	s8,32(sp)
    8000518e:	6ce2                	ld	s9,24(sp)
    80005190:	6d42                	ld	s10,16(sp)
    80005192:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80005194:	8556                	mv	a0,s5
    80005196:	9fbff0ef          	jal	80004b90 <iupdate>

  return tot;
    8000519a:	854e                	mv	a0,s3
    8000519c:	69a6                	ld	s3,72(sp)
}
    8000519e:	70a6                	ld	ra,104(sp)
    800051a0:	7406                	ld	s0,96(sp)
    800051a2:	6946                	ld	s2,80(sp)
    800051a4:	6a06                	ld	s4,64(sp)
    800051a6:	7ae2                	ld	s5,56(sp)
    800051a8:	7b42                	ld	s6,48(sp)
    800051aa:	7ba2                	ld	s7,40(sp)
    800051ac:	6165                	addi	sp,sp,112
    800051ae:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800051b0:	89da                	mv	s3,s6
    800051b2:	b7cd                	j	80005194 <writei+0xcc>
    800051b4:	64e6                	ld	s1,88(sp)
    800051b6:	7c02                	ld	s8,32(sp)
    800051b8:	6ce2                	ld	s9,24(sp)
    800051ba:	6d42                	ld	s10,16(sp)
    800051bc:	6da2                	ld	s11,8(sp)
    800051be:	bfd9                	j	80005194 <writei+0xcc>
    return -1;
    800051c0:	557d                	li	a0,-1
}
    800051c2:	8082                	ret
    return -1;
    800051c4:	557d                	li	a0,-1
    800051c6:	bfe1                	j	8000519e <writei+0xd6>

00000000800051c8 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800051c8:	1141                	addi	sp,sp,-16
    800051ca:	e406                	sd	ra,8(sp)
    800051cc:	e022                	sd	s0,0(sp)
    800051ce:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800051d0:	4639                	li	a2,14
    800051d2:	bfffb0ef          	jal	80000dd0 <strncmp>
}
    800051d6:	60a2                	ld	ra,8(sp)
    800051d8:	6402                	ld	s0,0(sp)
    800051da:	0141                	addi	sp,sp,16
    800051dc:	8082                	ret

00000000800051de <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800051de:	711d                	addi	sp,sp,-96
    800051e0:	ec86                	sd	ra,88(sp)
    800051e2:	e8a2                	sd	s0,80(sp)
    800051e4:	e4a6                	sd	s1,72(sp)
    800051e6:	e0ca                	sd	s2,64(sp)
    800051e8:	fc4e                	sd	s3,56(sp)
    800051ea:	f852                	sd	s4,48(sp)
    800051ec:	f456                	sd	s5,40(sp)
    800051ee:	f05a                	sd	s6,32(sp)
    800051f0:	ec5e                	sd	s7,24(sp)
    800051f2:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800051f4:	04451703          	lh	a4,68(a0)
    800051f8:	4785                	li	a5,1
    800051fa:	00f71f63          	bne	a4,a5,80005218 <dirlookup+0x3a>
    800051fe:	892a                	mv	s2,a0
    80005200:	8aae                	mv	s5,a1
    80005202:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80005204:	457c                	lw	a5,76(a0)
    80005206:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005208:	fa040a13          	addi	s4,s0,-96
    8000520c:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    8000520e:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80005212:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80005214:	e39d                	bnez	a5,8000523a <dirlookup+0x5c>
    80005216:	a8b9                	j	80005274 <dirlookup+0x96>
    panic("dirlookup not DIR");
    80005218:	00005517          	auipc	a0,0x5
    8000521c:	a8050513          	addi	a0,a0,-1408 # 80009c98 <etext+0xc98>
    80005220:	e04fb0ef          	jal	80000824 <panic>
      panic("dirlookup read");
    80005224:	00005517          	auipc	a0,0x5
    80005228:	a8c50513          	addi	a0,a0,-1396 # 80009cb0 <etext+0xcb0>
    8000522c:	df8fb0ef          	jal	80000824 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80005230:	24c1                	addiw	s1,s1,16
    80005232:	04c92783          	lw	a5,76(s2)
    80005236:	02f4fe63          	bgeu	s1,a5,80005272 <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000523a:	874e                	mv	a4,s3
    8000523c:	86a6                	mv	a3,s1
    8000523e:	8652                	mv	a2,s4
    80005240:	4581                	li	a1,0
    80005242:	854a                	mv	a0,s2
    80005244:	d93ff0ef          	jal	80004fd6 <readi>
    80005248:	fd351ee3          	bne	a0,s3,80005224 <dirlookup+0x46>
    if(de.inum == 0)
    8000524c:	fa045783          	lhu	a5,-96(s0)
    80005250:	d3e5                	beqz	a5,80005230 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    80005252:	85da                	mv	a1,s6
    80005254:	8556                	mv	a0,s5
    80005256:	f73ff0ef          	jal	800051c8 <namecmp>
    8000525a:	f979                	bnez	a0,80005230 <dirlookup+0x52>
      if(poff)
    8000525c:	000b8463          	beqz	s7,80005264 <dirlookup+0x86>
        *poff = off;
    80005260:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80005264:	fa045583          	lhu	a1,-96(s0)
    80005268:	00092503          	lw	a0,0(s2)
    8000526c:	f66ff0ef          	jal	800049d2 <iget>
    80005270:	a011                	j	80005274 <dirlookup+0x96>
  return 0;
    80005272:	4501                	li	a0,0
}
    80005274:	60e6                	ld	ra,88(sp)
    80005276:	6446                	ld	s0,80(sp)
    80005278:	64a6                	ld	s1,72(sp)
    8000527a:	6906                	ld	s2,64(sp)
    8000527c:	79e2                	ld	s3,56(sp)
    8000527e:	7a42                	ld	s4,48(sp)
    80005280:	7aa2                	ld	s5,40(sp)
    80005282:	7b02                	ld	s6,32(sp)
    80005284:	6be2                	ld	s7,24(sp)
    80005286:	6125                	addi	sp,sp,96
    80005288:	8082                	ret

000000008000528a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000528a:	711d                	addi	sp,sp,-96
    8000528c:	ec86                	sd	ra,88(sp)
    8000528e:	e8a2                	sd	s0,80(sp)
    80005290:	e4a6                	sd	s1,72(sp)
    80005292:	e0ca                	sd	s2,64(sp)
    80005294:	fc4e                	sd	s3,56(sp)
    80005296:	f852                	sd	s4,48(sp)
    80005298:	f456                	sd	s5,40(sp)
    8000529a:	f05a                	sd	s6,32(sp)
    8000529c:	ec5e                	sd	s7,24(sp)
    8000529e:	e862                	sd	s8,16(sp)
    800052a0:	e466                	sd	s9,8(sp)
    800052a2:	e06a                	sd	s10,0(sp)
    800052a4:	1080                	addi	s0,sp,96
    800052a6:	84aa                	mv	s1,a0
    800052a8:	8b2e                	mv	s6,a1
    800052aa:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800052ac:	00054703          	lbu	a4,0(a0)
    800052b0:	02f00793          	li	a5,47
    800052b4:	00f70f63          	beq	a4,a5,800052d2 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800052b8:	b8dfd0ef          	jal	80002e44 <myproc>
    800052bc:	15053503          	ld	a0,336(a0)
    800052c0:	94fff0ef          	jal	80004c0e <idup>
    800052c4:	8a2a                	mv	s4,a0
  while(*path == '/')
    800052c6:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    800052ca:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    800052cc:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800052ce:	4b85                	li	s7,1
    800052d0:	a879                	j	8000536e <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    800052d2:	4585                	li	a1,1
    800052d4:	852e                	mv	a0,a1
    800052d6:	efcff0ef          	jal	800049d2 <iget>
    800052da:	8a2a                	mv	s4,a0
    800052dc:	b7ed                	j	800052c6 <namex+0x3c>
      iunlockput(ip);
    800052de:	8552                	mv	a0,s4
    800052e0:	b71ff0ef          	jal	80004e50 <iunlockput>
      return 0;
    800052e4:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800052e6:	8552                	mv	a0,s4
    800052e8:	60e6                	ld	ra,88(sp)
    800052ea:	6446                	ld	s0,80(sp)
    800052ec:	64a6                	ld	s1,72(sp)
    800052ee:	6906                	ld	s2,64(sp)
    800052f0:	79e2                	ld	s3,56(sp)
    800052f2:	7a42                	ld	s4,48(sp)
    800052f4:	7aa2                	ld	s5,40(sp)
    800052f6:	7b02                	ld	s6,32(sp)
    800052f8:	6be2                	ld	s7,24(sp)
    800052fa:	6c42                	ld	s8,16(sp)
    800052fc:	6ca2                	ld	s9,8(sp)
    800052fe:	6d02                	ld	s10,0(sp)
    80005300:	6125                	addi	sp,sp,96
    80005302:	8082                	ret
      iunlock(ip);
    80005304:	8552                	mv	a0,s4
    80005306:	9edff0ef          	jal	80004cf2 <iunlock>
      return ip;
    8000530a:	bff1                	j	800052e6 <namex+0x5c>
      iunlockput(ip);
    8000530c:	8552                	mv	a0,s4
    8000530e:	b43ff0ef          	jal	80004e50 <iunlockput>
      return 0;
    80005312:	8a4a                	mv	s4,s2
    80005314:	bfc9                	j	800052e6 <namex+0x5c>
  len = path - s;
    80005316:	40990633          	sub	a2,s2,s1
    8000531a:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    8000531e:	09ac5463          	bge	s8,s10,800053a6 <namex+0x11c>
    memmove(name, s, DIRSIZ);
    80005322:	8666                	mv	a2,s9
    80005324:	85a6                	mv	a1,s1
    80005326:	8556                	mv	a0,s5
    80005328:	a35fb0ef          	jal	80000d5c <memmove>
    8000532c:	84ca                	mv	s1,s2
  while(*path == '/')
    8000532e:	0004c783          	lbu	a5,0(s1)
    80005332:	01379763          	bne	a5,s3,80005340 <namex+0xb6>
    path++;
    80005336:	0485                	addi	s1,s1,1
  while(*path == '/')
    80005338:	0004c783          	lbu	a5,0(s1)
    8000533c:	ff378de3          	beq	a5,s3,80005336 <namex+0xac>
    ilock(ip);
    80005340:	8552                	mv	a0,s4
    80005342:	903ff0ef          	jal	80004c44 <ilock>
    if(ip->type != T_DIR){
    80005346:	044a1783          	lh	a5,68(s4)
    8000534a:	f9779ae3          	bne	a5,s7,800052de <namex+0x54>
    if(nameiparent && *path == '\0'){
    8000534e:	000b0563          	beqz	s6,80005358 <namex+0xce>
    80005352:	0004c783          	lbu	a5,0(s1)
    80005356:	d7dd                	beqz	a5,80005304 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80005358:	4601                	li	a2,0
    8000535a:	85d6                	mv	a1,s5
    8000535c:	8552                	mv	a0,s4
    8000535e:	e81ff0ef          	jal	800051de <dirlookup>
    80005362:	892a                	mv	s2,a0
    80005364:	d545                	beqz	a0,8000530c <namex+0x82>
    iunlockput(ip);
    80005366:	8552                	mv	a0,s4
    80005368:	ae9ff0ef          	jal	80004e50 <iunlockput>
    ip = next;
    8000536c:	8a4a                	mv	s4,s2
  while(*path == '/')
    8000536e:	0004c783          	lbu	a5,0(s1)
    80005372:	01379763          	bne	a5,s3,80005380 <namex+0xf6>
    path++;
    80005376:	0485                	addi	s1,s1,1
  while(*path == '/')
    80005378:	0004c783          	lbu	a5,0(s1)
    8000537c:	ff378de3          	beq	a5,s3,80005376 <namex+0xec>
  if(*path == 0)
    80005380:	cf8d                	beqz	a5,800053ba <namex+0x130>
  while(*path != '/' && *path != 0)
    80005382:	0004c783          	lbu	a5,0(s1)
    80005386:	fd178713          	addi	a4,a5,-47
    8000538a:	cb19                	beqz	a4,800053a0 <namex+0x116>
    8000538c:	cb91                	beqz	a5,800053a0 <namex+0x116>
    8000538e:	8926                	mv	s2,s1
    path++;
    80005390:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80005392:	00094783          	lbu	a5,0(s2)
    80005396:	fd178713          	addi	a4,a5,-47
    8000539a:	df35                	beqz	a4,80005316 <namex+0x8c>
    8000539c:	fbf5                	bnez	a5,80005390 <namex+0x106>
    8000539e:	bfa5                	j	80005316 <namex+0x8c>
    800053a0:	8926                	mv	s2,s1
  len = path - s;
    800053a2:	4d01                	li	s10,0
    800053a4:	4601                	li	a2,0
    memmove(name, s, len);
    800053a6:	2601                	sext.w	a2,a2
    800053a8:	85a6                	mv	a1,s1
    800053aa:	8556                	mv	a0,s5
    800053ac:	9b1fb0ef          	jal	80000d5c <memmove>
    name[len] = 0;
    800053b0:	9d56                	add	s10,s10,s5
    800053b2:	000d0023          	sb	zero,0(s10) # 40000000 <_entry-0x40000000>
    800053b6:	84ca                	mv	s1,s2
    800053b8:	bf9d                	j	8000532e <namex+0xa4>
  if(nameiparent){
    800053ba:	f20b06e3          	beqz	s6,800052e6 <namex+0x5c>
    iput(ip);
    800053be:	8552                	mv	a0,s4
    800053c0:	a07ff0ef          	jal	80004dc6 <iput>
    return 0;
    800053c4:	4a01                	li	s4,0
    800053c6:	b705                	j	800052e6 <namex+0x5c>

00000000800053c8 <dirlink>:
{
    800053c8:	715d                	addi	sp,sp,-80
    800053ca:	e486                	sd	ra,72(sp)
    800053cc:	e0a2                	sd	s0,64(sp)
    800053ce:	f84a                	sd	s2,48(sp)
    800053d0:	ec56                	sd	s5,24(sp)
    800053d2:	e85a                	sd	s6,16(sp)
    800053d4:	0880                	addi	s0,sp,80
    800053d6:	892a                	mv	s2,a0
    800053d8:	8aae                	mv	s5,a1
    800053da:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800053dc:	4601                	li	a2,0
    800053de:	e01ff0ef          	jal	800051de <dirlookup>
    800053e2:	ed1d                	bnez	a0,80005420 <dirlink+0x58>
    800053e4:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800053e6:	04c92483          	lw	s1,76(s2)
    800053ea:	c4b9                	beqz	s1,80005438 <dirlink+0x70>
    800053ec:	f44e                	sd	s3,40(sp)
    800053ee:	f052                	sd	s4,32(sp)
    800053f0:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800053f2:	fb040a13          	addi	s4,s0,-80
    800053f6:	49c1                	li	s3,16
    800053f8:	874e                	mv	a4,s3
    800053fa:	86a6                	mv	a3,s1
    800053fc:	8652                	mv	a2,s4
    800053fe:	4581                	li	a1,0
    80005400:	854a                	mv	a0,s2
    80005402:	bd5ff0ef          	jal	80004fd6 <readi>
    80005406:	03351163          	bne	a0,s3,80005428 <dirlink+0x60>
    if(de.inum == 0)
    8000540a:	fb045783          	lhu	a5,-80(s0)
    8000540e:	c39d                	beqz	a5,80005434 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80005410:	24c1                	addiw	s1,s1,16
    80005412:	04c92783          	lw	a5,76(s2)
    80005416:	fef4e1e3          	bltu	s1,a5,800053f8 <dirlink+0x30>
    8000541a:	79a2                	ld	s3,40(sp)
    8000541c:	7a02                	ld	s4,32(sp)
    8000541e:	a829                	j	80005438 <dirlink+0x70>
    iput(ip);
    80005420:	9a7ff0ef          	jal	80004dc6 <iput>
    return -1;
    80005424:	557d                	li	a0,-1
    80005426:	a83d                	j	80005464 <dirlink+0x9c>
      panic("dirlink read");
    80005428:	00005517          	auipc	a0,0x5
    8000542c:	89850513          	addi	a0,a0,-1896 # 80009cc0 <etext+0xcc0>
    80005430:	bf4fb0ef          	jal	80000824 <panic>
    80005434:	79a2                	ld	s3,40(sp)
    80005436:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80005438:	4639                	li	a2,14
    8000543a:	85d6                	mv	a1,s5
    8000543c:	fb240513          	addi	a0,s0,-78
    80005440:	9cbfb0ef          	jal	80000e0a <strncpy>
  de.inum = inum;
    80005444:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005448:	4741                	li	a4,16
    8000544a:	86a6                	mv	a3,s1
    8000544c:	fb040613          	addi	a2,s0,-80
    80005450:	4581                	li	a1,0
    80005452:	854a                	mv	a0,s2
    80005454:	c75ff0ef          	jal	800050c8 <writei>
    80005458:	1541                	addi	a0,a0,-16
    8000545a:	00a03533          	snez	a0,a0
    8000545e:	40a0053b          	negw	a0,a0
    80005462:	74e2                	ld	s1,56(sp)
}
    80005464:	60a6                	ld	ra,72(sp)
    80005466:	6406                	ld	s0,64(sp)
    80005468:	7942                	ld	s2,48(sp)
    8000546a:	6ae2                	ld	s5,24(sp)
    8000546c:	6b42                	ld	s6,16(sp)
    8000546e:	6161                	addi	sp,sp,80
    80005470:	8082                	ret

0000000080005472 <namei>:

struct inode*
namei(char *path)
{
    80005472:	1101                	addi	sp,sp,-32
    80005474:	ec06                	sd	ra,24(sp)
    80005476:	e822                	sd	s0,16(sp)
    80005478:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000547a:	fe040613          	addi	a2,s0,-32
    8000547e:	4581                	li	a1,0
    80005480:	e0bff0ef          	jal	8000528a <namex>
}
    80005484:	60e2                	ld	ra,24(sp)
    80005486:	6442                	ld	s0,16(sp)
    80005488:	6105                	addi	sp,sp,32
    8000548a:	8082                	ret

000000008000548c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000548c:	1141                	addi	sp,sp,-16
    8000548e:	e406                	sd	ra,8(sp)
    80005490:	e022                	sd	s0,0(sp)
    80005492:	0800                	addi	s0,sp,16
    80005494:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80005496:	4585                	li	a1,1
    80005498:	df3ff0ef          	jal	8000528a <namex>
}
    8000549c:	60a2                	ld	ra,8(sp)
    8000549e:	6402                	ld	s0,0(sp)
    800054a0:	0141                	addi	sp,sp,16
    800054a2:	8082                	ret

00000000800054a4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800054a4:	1101                	addi	sp,sp,-32
    800054a6:	ec06                	sd	ra,24(sp)
    800054a8:	e822                	sd	s0,16(sp)
    800054aa:	e426                	sd	s1,8(sp)
    800054ac:	e04a                	sd	s2,0(sp)
    800054ae:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800054b0:	002cd917          	auipc	s2,0x2cd
    800054b4:	3e890913          	addi	s2,s2,1000 # 802d2898 <log>
    800054b8:	01892583          	lw	a1,24(s2)
    800054bc:	02492503          	lw	a0,36(s2)
    800054c0:	8ecff0ef          	jal	800045ac <bread>
    800054c4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800054c6:	02892603          	lw	a2,40(s2)
    800054ca:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800054cc:	00c05f63          	blez	a2,800054ea <write_head+0x46>
    800054d0:	002cd717          	auipc	a4,0x2cd
    800054d4:	3f470713          	addi	a4,a4,1012 # 802d28c4 <log+0x2c>
    800054d8:	87aa                	mv	a5,a0
    800054da:	060a                	slli	a2,a2,0x2
    800054dc:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800054de:	4314                	lw	a3,0(a4)
    800054e0:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800054e2:	0711                	addi	a4,a4,4
    800054e4:	0791                	addi	a5,a5,4
    800054e6:	fec79ce3          	bne	a5,a2,800054de <write_head+0x3a>
  }
  bwrite(buf);
    800054ea:	8526                	mv	a0,s1
    800054ec:	996ff0ef          	jal	80004682 <bwrite>
  brelse(buf);
    800054f0:	8526                	mv	a0,s1
    800054f2:	9c2ff0ef          	jal	800046b4 <brelse>
}
    800054f6:	60e2                	ld	ra,24(sp)
    800054f8:	6442                	ld	s0,16(sp)
    800054fa:	64a2                	ld	s1,8(sp)
    800054fc:	6902                	ld	s2,0(sp)
    800054fe:	6105                	addi	sp,sp,32
    80005500:	8082                	ret

0000000080005502 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80005502:	002cd797          	auipc	a5,0x2cd
    80005506:	3be7a783          	lw	a5,958(a5) # 802d28c0 <log+0x28>
    8000550a:	0cf05163          	blez	a5,800055cc <install_trans+0xca>
{
    8000550e:	715d                	addi	sp,sp,-80
    80005510:	e486                	sd	ra,72(sp)
    80005512:	e0a2                	sd	s0,64(sp)
    80005514:	fc26                	sd	s1,56(sp)
    80005516:	f84a                	sd	s2,48(sp)
    80005518:	f44e                	sd	s3,40(sp)
    8000551a:	f052                	sd	s4,32(sp)
    8000551c:	ec56                	sd	s5,24(sp)
    8000551e:	e85a                	sd	s6,16(sp)
    80005520:	e45e                	sd	s7,8(sp)
    80005522:	e062                	sd	s8,0(sp)
    80005524:	0880                	addi	s0,sp,80
    80005526:	8b2a                	mv	s6,a0
    80005528:	002cda97          	auipc	s5,0x2cd
    8000552c:	39ca8a93          	addi	s5,s5,924 # 802d28c4 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005530:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80005532:	00004c17          	auipc	s8,0x4
    80005536:	79ec0c13          	addi	s8,s8,1950 # 80009cd0 <etext+0xcd0>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000553a:	002cda17          	auipc	s4,0x2cd
    8000553e:	35ea0a13          	addi	s4,s4,862 # 802d2898 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80005542:	40000b93          	li	s7,1024
    80005546:	a025                	j	8000556e <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80005548:	000aa603          	lw	a2,0(s5)
    8000554c:	85ce                	mv	a1,s3
    8000554e:	8562                	mv	a0,s8
    80005550:	fabfa0ef          	jal	800004fa <printf>
    80005554:	a839                	j	80005572 <install_trans+0x70>
    brelse(lbuf);
    80005556:	854a                	mv	a0,s2
    80005558:	95cff0ef          	jal	800046b4 <brelse>
    brelse(dbuf);
    8000555c:	8526                	mv	a0,s1
    8000555e:	956ff0ef          	jal	800046b4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005562:	2985                	addiw	s3,s3,1
    80005564:	0a91                	addi	s5,s5,4
    80005566:	028a2783          	lw	a5,40(s4)
    8000556a:	04f9d563          	bge	s3,a5,800055b4 <install_trans+0xb2>
    if(recovering) {
    8000556e:	fc0b1de3          	bnez	s6,80005548 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80005572:	018a2583          	lw	a1,24(s4)
    80005576:	013585bb          	addw	a1,a1,s3
    8000557a:	2585                	addiw	a1,a1,1
    8000557c:	024a2503          	lw	a0,36(s4)
    80005580:	82cff0ef          	jal	800045ac <bread>
    80005584:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80005586:	000aa583          	lw	a1,0(s5)
    8000558a:	024a2503          	lw	a0,36(s4)
    8000558e:	81eff0ef          	jal	800045ac <bread>
    80005592:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80005594:	865e                	mv	a2,s7
    80005596:	05890593          	addi	a1,s2,88
    8000559a:	05850513          	addi	a0,a0,88
    8000559e:	fbefb0ef          	jal	80000d5c <memmove>
    bwrite(dbuf);  // write dst to disk
    800055a2:	8526                	mv	a0,s1
    800055a4:	8deff0ef          	jal	80004682 <bwrite>
    if(recovering == 0)
    800055a8:	fa0b17e3          	bnez	s6,80005556 <install_trans+0x54>
      bunpin(dbuf);
    800055ac:	8526                	mv	a0,s1
    800055ae:	9beff0ef          	jal	8000476c <bunpin>
    800055b2:	b755                	j	80005556 <install_trans+0x54>
}
    800055b4:	60a6                	ld	ra,72(sp)
    800055b6:	6406                	ld	s0,64(sp)
    800055b8:	74e2                	ld	s1,56(sp)
    800055ba:	7942                	ld	s2,48(sp)
    800055bc:	79a2                	ld	s3,40(sp)
    800055be:	7a02                	ld	s4,32(sp)
    800055c0:	6ae2                	ld	s5,24(sp)
    800055c2:	6b42                	ld	s6,16(sp)
    800055c4:	6ba2                	ld	s7,8(sp)
    800055c6:	6c02                	ld	s8,0(sp)
    800055c8:	6161                	addi	sp,sp,80
    800055ca:	8082                	ret
    800055cc:	8082                	ret

00000000800055ce <initlog>:
{
    800055ce:	7179                	addi	sp,sp,-48
    800055d0:	f406                	sd	ra,40(sp)
    800055d2:	f022                	sd	s0,32(sp)
    800055d4:	ec26                	sd	s1,24(sp)
    800055d6:	e84a                	sd	s2,16(sp)
    800055d8:	e44e                	sd	s3,8(sp)
    800055da:	1800                	addi	s0,sp,48
    800055dc:	84aa                	mv	s1,a0
    800055de:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800055e0:	002cd917          	auipc	s2,0x2cd
    800055e4:	2b890913          	addi	s2,s2,696 # 802d2898 <log>
    800055e8:	00004597          	auipc	a1,0x4
    800055ec:	70858593          	addi	a1,a1,1800 # 80009cf0 <etext+0xcf0>
    800055f0:	854a                	mv	a0,s2
    800055f2:	db0fb0ef          	jal	80000ba2 <initlock>
  log.start = sb->logstart;
    800055f6:	0149a583          	lw	a1,20(s3)
    800055fa:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    800055fe:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80005602:	8526                	mv	a0,s1
    80005604:	fa9fe0ef          	jal	800045ac <bread>
  log.lh.n = lh->n;
    80005608:	4d30                	lw	a2,88(a0)
    8000560a:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    8000560e:	00c05f63          	blez	a2,8000562c <initlog+0x5e>
    80005612:	87aa                	mv	a5,a0
    80005614:	002cd717          	auipc	a4,0x2cd
    80005618:	2b070713          	addi	a4,a4,688 # 802d28c4 <log+0x2c>
    8000561c:	060a                	slli	a2,a2,0x2
    8000561e:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80005620:	4ff4                	lw	a3,92(a5)
    80005622:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80005624:	0791                	addi	a5,a5,4
    80005626:	0711                	addi	a4,a4,4
    80005628:	fec79ce3          	bne	a5,a2,80005620 <initlog+0x52>
  brelse(buf);
    8000562c:	888ff0ef          	jal	800046b4 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80005630:	4505                	li	a0,1
    80005632:	ed1ff0ef          	jal	80005502 <install_trans>
  log.lh.n = 0;
    80005636:	002cd797          	auipc	a5,0x2cd
    8000563a:	2807a523          	sw	zero,650(a5) # 802d28c0 <log+0x28>
  write_head(); // clear the log
    8000563e:	e67ff0ef          	jal	800054a4 <write_head>
}
    80005642:	70a2                	ld	ra,40(sp)
    80005644:	7402                	ld	s0,32(sp)
    80005646:	64e2                	ld	s1,24(sp)
    80005648:	6942                	ld	s2,16(sp)
    8000564a:	69a2                	ld	s3,8(sp)
    8000564c:	6145                	addi	sp,sp,48
    8000564e:	8082                	ret

0000000080005650 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80005650:	1101                	addi	sp,sp,-32
    80005652:	ec06                	sd	ra,24(sp)
    80005654:	e822                	sd	s0,16(sp)
    80005656:	e426                	sd	s1,8(sp)
    80005658:	e04a                	sd	s2,0(sp)
    8000565a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000565c:	002cd517          	auipc	a0,0x2cd
    80005660:	23c50513          	addi	a0,a0,572 # 802d2898 <log>
    80005664:	dc8fb0ef          	jal	80000c2c <acquire>
  while(1){
    if(log.committing){
    80005668:	002cd497          	auipc	s1,0x2cd
    8000566c:	23048493          	addi	s1,s1,560 # 802d2898 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80005670:	4979                	li	s2,30
    80005672:	a029                	j	8000567c <begin_op+0x2c>
      sleep(&log, &log.lock);
    80005674:	85a6                	mv	a1,s1
    80005676:	8526                	mv	a0,s1
    80005678:	fbffd0ef          	jal	80003636 <sleep>
    if(log.committing){
    8000567c:	509c                	lw	a5,32(s1)
    8000567e:	fbfd                	bnez	a5,80005674 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80005680:	4cd8                	lw	a4,28(s1)
    80005682:	2705                	addiw	a4,a4,1
    80005684:	0027179b          	slliw	a5,a4,0x2
    80005688:	9fb9                	addw	a5,a5,a4
    8000568a:	0017979b          	slliw	a5,a5,0x1
    8000568e:	5494                	lw	a3,40(s1)
    80005690:	9fb5                	addw	a5,a5,a3
    80005692:	00f95763          	bge	s2,a5,800056a0 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80005696:	85a6                	mv	a1,s1
    80005698:	8526                	mv	a0,s1
    8000569a:	f9dfd0ef          	jal	80003636 <sleep>
    8000569e:	bff9                	j	8000567c <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800056a0:	002cd797          	auipc	a5,0x2cd
    800056a4:	20e7aa23          	sw	a4,532(a5) # 802d28b4 <log+0x1c>
      release(&log.lock);
    800056a8:	002cd517          	auipc	a0,0x2cd
    800056ac:	1f050513          	addi	a0,a0,496 # 802d2898 <log>
    800056b0:	e10fb0ef          	jal	80000cc0 <release>
      break;
    }
  }
}
    800056b4:	60e2                	ld	ra,24(sp)
    800056b6:	6442                	ld	s0,16(sp)
    800056b8:	64a2                	ld	s1,8(sp)
    800056ba:	6902                	ld	s2,0(sp)
    800056bc:	6105                	addi	sp,sp,32
    800056be:	8082                	ret

00000000800056c0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800056c0:	7139                	addi	sp,sp,-64
    800056c2:	fc06                	sd	ra,56(sp)
    800056c4:	f822                	sd	s0,48(sp)
    800056c6:	f426                	sd	s1,40(sp)
    800056c8:	f04a                	sd	s2,32(sp)
    800056ca:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800056cc:	002cd497          	auipc	s1,0x2cd
    800056d0:	1cc48493          	addi	s1,s1,460 # 802d2898 <log>
    800056d4:	8526                	mv	a0,s1
    800056d6:	d56fb0ef          	jal	80000c2c <acquire>
  log.outstanding -= 1;
    800056da:	4cdc                	lw	a5,28(s1)
    800056dc:	37fd                	addiw	a5,a5,-1
    800056de:	893e                	mv	s2,a5
    800056e0:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    800056e2:	509c                	lw	a5,32(s1)
    800056e4:	e7b1                	bnez	a5,80005730 <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    800056e6:	04091e63          	bnez	s2,80005742 <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    800056ea:	002cd497          	auipc	s1,0x2cd
    800056ee:	1ae48493          	addi	s1,s1,430 # 802d2898 <log>
    800056f2:	4785                	li	a5,1
    800056f4:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800056f6:	8526                	mv	a0,s1
    800056f8:	dc8fb0ef          	jal	80000cc0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800056fc:	549c                	lw	a5,40(s1)
    800056fe:	06f04463          	bgtz	a5,80005766 <end_op+0xa6>
    acquire(&log.lock);
    80005702:	002cd517          	auipc	a0,0x2cd
    80005706:	19650513          	addi	a0,a0,406 # 802d2898 <log>
    8000570a:	d22fb0ef          	jal	80000c2c <acquire>
    log.committing = 0;
    8000570e:	002cd797          	auipc	a5,0x2cd
    80005712:	1a07a523          	sw	zero,426(a5) # 802d28b8 <log+0x20>
    wakeup(&log);
    80005716:	002cd517          	auipc	a0,0x2cd
    8000571a:	18250513          	addi	a0,a0,386 # 802d2898 <log>
    8000571e:	f65fd0ef          	jal	80003682 <wakeup>
    release(&log.lock);
    80005722:	002cd517          	auipc	a0,0x2cd
    80005726:	17650513          	addi	a0,a0,374 # 802d2898 <log>
    8000572a:	d96fb0ef          	jal	80000cc0 <release>
}
    8000572e:	a035                	j	8000575a <end_op+0x9a>
    80005730:	ec4e                	sd	s3,24(sp)
    80005732:	e852                	sd	s4,16(sp)
    80005734:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80005736:	00004517          	auipc	a0,0x4
    8000573a:	5c250513          	addi	a0,a0,1474 # 80009cf8 <etext+0xcf8>
    8000573e:	8e6fb0ef          	jal	80000824 <panic>
    wakeup(&log);
    80005742:	002cd517          	auipc	a0,0x2cd
    80005746:	15650513          	addi	a0,a0,342 # 802d2898 <log>
    8000574a:	f39fd0ef          	jal	80003682 <wakeup>
  release(&log.lock);
    8000574e:	002cd517          	auipc	a0,0x2cd
    80005752:	14a50513          	addi	a0,a0,330 # 802d2898 <log>
    80005756:	d6afb0ef          	jal	80000cc0 <release>
}
    8000575a:	70e2                	ld	ra,56(sp)
    8000575c:	7442                	ld	s0,48(sp)
    8000575e:	74a2                	ld	s1,40(sp)
    80005760:	7902                	ld	s2,32(sp)
    80005762:	6121                	addi	sp,sp,64
    80005764:	8082                	ret
    80005766:	ec4e                	sd	s3,24(sp)
    80005768:	e852                	sd	s4,16(sp)
    8000576a:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    8000576c:	002cda97          	auipc	s5,0x2cd
    80005770:	158a8a93          	addi	s5,s5,344 # 802d28c4 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80005774:	002cda17          	auipc	s4,0x2cd
    80005778:	124a0a13          	addi	s4,s4,292 # 802d2898 <log>
    8000577c:	018a2583          	lw	a1,24(s4)
    80005780:	012585bb          	addw	a1,a1,s2
    80005784:	2585                	addiw	a1,a1,1
    80005786:	024a2503          	lw	a0,36(s4)
    8000578a:	e23fe0ef          	jal	800045ac <bread>
    8000578e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80005790:	000aa583          	lw	a1,0(s5)
    80005794:	024a2503          	lw	a0,36(s4)
    80005798:	e15fe0ef          	jal	800045ac <bread>
    8000579c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000579e:	40000613          	li	a2,1024
    800057a2:	05850593          	addi	a1,a0,88
    800057a6:	05848513          	addi	a0,s1,88
    800057aa:	db2fb0ef          	jal	80000d5c <memmove>
    bwrite(to);  // write the log
    800057ae:	8526                	mv	a0,s1
    800057b0:	ed3fe0ef          	jal	80004682 <bwrite>
    brelse(from);
    800057b4:	854e                	mv	a0,s3
    800057b6:	efffe0ef          	jal	800046b4 <brelse>
    brelse(to);
    800057ba:	8526                	mv	a0,s1
    800057bc:	ef9fe0ef          	jal	800046b4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800057c0:	2905                	addiw	s2,s2,1
    800057c2:	0a91                	addi	s5,s5,4
    800057c4:	028a2783          	lw	a5,40(s4)
    800057c8:	faf94ae3          	blt	s2,a5,8000577c <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800057cc:	cd9ff0ef          	jal	800054a4 <write_head>
    install_trans(0); // Now install writes to home locations
    800057d0:	4501                	li	a0,0
    800057d2:	d31ff0ef          	jal	80005502 <install_trans>
    log.lh.n = 0;
    800057d6:	002cd797          	auipc	a5,0x2cd
    800057da:	0e07a523          	sw	zero,234(a5) # 802d28c0 <log+0x28>
    write_head();    // Erase the transaction from the log
    800057de:	cc7ff0ef          	jal	800054a4 <write_head>
    800057e2:	69e2                	ld	s3,24(sp)
    800057e4:	6a42                	ld	s4,16(sp)
    800057e6:	6aa2                	ld	s5,8(sp)
    800057e8:	bf29                	j	80005702 <end_op+0x42>

00000000800057ea <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800057ea:	1101                	addi	sp,sp,-32
    800057ec:	ec06                	sd	ra,24(sp)
    800057ee:	e822                	sd	s0,16(sp)
    800057f0:	e426                	sd	s1,8(sp)
    800057f2:	1000                	addi	s0,sp,32
    800057f4:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800057f6:	002cd517          	auipc	a0,0x2cd
    800057fa:	0a250513          	addi	a0,a0,162 # 802d2898 <log>
    800057fe:	c2efb0ef          	jal	80000c2c <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80005802:	002cd617          	auipc	a2,0x2cd
    80005806:	0be62603          	lw	a2,190(a2) # 802d28c0 <log+0x28>
    8000580a:	47f5                	li	a5,29
    8000580c:	04c7cd63          	blt	a5,a2,80005866 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80005810:	002cd797          	auipc	a5,0x2cd
    80005814:	0a47a783          	lw	a5,164(a5) # 802d28b4 <log+0x1c>
    80005818:	04f05d63          	blez	a5,80005872 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000581c:	4781                	li	a5,0
    8000581e:	06c05063          	blez	a2,8000587e <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80005822:	44cc                	lw	a1,12(s1)
    80005824:	002cd717          	auipc	a4,0x2cd
    80005828:	0a070713          	addi	a4,a4,160 # 802d28c4 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    8000582c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000582e:	4314                	lw	a3,0(a4)
    80005830:	04b68763          	beq	a3,a1,8000587e <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80005834:	2785                	addiw	a5,a5,1
    80005836:	0711                	addi	a4,a4,4
    80005838:	fef61be3          	bne	a2,a5,8000582e <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000583c:	060a                	slli	a2,a2,0x2
    8000583e:	02060613          	addi	a2,a2,32
    80005842:	002cd797          	auipc	a5,0x2cd
    80005846:	05678793          	addi	a5,a5,86 # 802d2898 <log>
    8000584a:	97b2                	add	a5,a5,a2
    8000584c:	44d8                	lw	a4,12(s1)
    8000584e:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80005850:	8526                	mv	a0,s1
    80005852:	ee7fe0ef          	jal	80004738 <bpin>
    log.lh.n++;
    80005856:	002cd717          	auipc	a4,0x2cd
    8000585a:	04270713          	addi	a4,a4,66 # 802d2898 <log>
    8000585e:	571c                	lw	a5,40(a4)
    80005860:	2785                	addiw	a5,a5,1
    80005862:	d71c                	sw	a5,40(a4)
    80005864:	a815                	j	80005898 <log_write+0xae>
    panic("too big a transaction");
    80005866:	00004517          	auipc	a0,0x4
    8000586a:	4a250513          	addi	a0,a0,1186 # 80009d08 <etext+0xd08>
    8000586e:	fb7fa0ef          	jal	80000824 <panic>
    panic("log_write outside of trans");
    80005872:	00004517          	auipc	a0,0x4
    80005876:	4ae50513          	addi	a0,a0,1198 # 80009d20 <etext+0xd20>
    8000587a:	fabfa0ef          	jal	80000824 <panic>
  log.lh.block[i] = b->blockno;
    8000587e:	00279693          	slli	a3,a5,0x2
    80005882:	02068693          	addi	a3,a3,32
    80005886:	002cd717          	auipc	a4,0x2cd
    8000588a:	01270713          	addi	a4,a4,18 # 802d2898 <log>
    8000588e:	9736                	add	a4,a4,a3
    80005890:	44d4                	lw	a3,12(s1)
    80005892:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80005894:	faf60ee3          	beq	a2,a5,80005850 <log_write+0x66>
  }
  release(&log.lock);
    80005898:	002cd517          	auipc	a0,0x2cd
    8000589c:	00050513          	mv	a0,a0
    800058a0:	c20fb0ef          	jal	80000cc0 <release>
}
    800058a4:	60e2                	ld	ra,24(sp)
    800058a6:	6442                	ld	s0,16(sp)
    800058a8:	64a2                	ld	s1,8(sp)
    800058aa:	6105                	addi	sp,sp,32
    800058ac:	8082                	ret

00000000800058ae <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800058ae:	1101                	addi	sp,sp,-32
    800058b0:	ec06                	sd	ra,24(sp)
    800058b2:	e822                	sd	s0,16(sp)
    800058b4:	e426                	sd	s1,8(sp)
    800058b6:	e04a                	sd	s2,0(sp)
    800058b8:	1000                	addi	s0,sp,32
    800058ba:	84aa                	mv	s1,a0
    800058bc:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800058be:	00004597          	auipc	a1,0x4
    800058c2:	48258593          	addi	a1,a1,1154 # 80009d40 <etext+0xd40>
    800058c6:	0521                	addi	a0,a0,8 # 802d28a0 <log+0x8>
    800058c8:	adafb0ef          	jal	80000ba2 <initlock>
  lk->name = name;
    800058cc:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800058d0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800058d4:	0204a423          	sw	zero,40(s1)
}
    800058d8:	60e2                	ld	ra,24(sp)
    800058da:	6442                	ld	s0,16(sp)
    800058dc:	64a2                	ld	s1,8(sp)
    800058de:	6902                	ld	s2,0(sp)
    800058e0:	6105                	addi	sp,sp,32
    800058e2:	8082                	ret

00000000800058e4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800058e4:	1101                	addi	sp,sp,-32
    800058e6:	ec06                	sd	ra,24(sp)
    800058e8:	e822                	sd	s0,16(sp)
    800058ea:	e426                	sd	s1,8(sp)
    800058ec:	e04a                	sd	s2,0(sp)
    800058ee:	1000                	addi	s0,sp,32
    800058f0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800058f2:	00850913          	addi	s2,a0,8
    800058f6:	854a                	mv	a0,s2
    800058f8:	b34fb0ef          	jal	80000c2c <acquire>
  while (lk->locked) {
    800058fc:	409c                	lw	a5,0(s1)
    800058fe:	c799                	beqz	a5,8000590c <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80005900:	85ca                	mv	a1,s2
    80005902:	8526                	mv	a0,s1
    80005904:	d33fd0ef          	jal	80003636 <sleep>
  while (lk->locked) {
    80005908:	409c                	lw	a5,0(s1)
    8000590a:	fbfd                	bnez	a5,80005900 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    8000590c:	4785                	li	a5,1
    8000590e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80005910:	d34fd0ef          	jal	80002e44 <myproc>
    80005914:	591c                	lw	a5,48(a0)
    80005916:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80005918:	854a                	mv	a0,s2
    8000591a:	ba6fb0ef          	jal	80000cc0 <release>
}
    8000591e:	60e2                	ld	ra,24(sp)
    80005920:	6442                	ld	s0,16(sp)
    80005922:	64a2                	ld	s1,8(sp)
    80005924:	6902                	ld	s2,0(sp)
    80005926:	6105                	addi	sp,sp,32
    80005928:	8082                	ret

000000008000592a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000592a:	1101                	addi	sp,sp,-32
    8000592c:	ec06                	sd	ra,24(sp)
    8000592e:	e822                	sd	s0,16(sp)
    80005930:	e426                	sd	s1,8(sp)
    80005932:	e04a                	sd	s2,0(sp)
    80005934:	1000                	addi	s0,sp,32
    80005936:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005938:	00850913          	addi	s2,a0,8
    8000593c:	854a                	mv	a0,s2
    8000593e:	aeefb0ef          	jal	80000c2c <acquire>
  lk->locked = 0;
    80005942:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005946:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000594a:	8526                	mv	a0,s1
    8000594c:	d37fd0ef          	jal	80003682 <wakeup>
  release(&lk->lk);
    80005950:	854a                	mv	a0,s2
    80005952:	b6efb0ef          	jal	80000cc0 <release>
}
    80005956:	60e2                	ld	ra,24(sp)
    80005958:	6442                	ld	s0,16(sp)
    8000595a:	64a2                	ld	s1,8(sp)
    8000595c:	6902                	ld	s2,0(sp)
    8000595e:	6105                	addi	sp,sp,32
    80005960:	8082                	ret

0000000080005962 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80005962:	7179                	addi	sp,sp,-48
    80005964:	f406                	sd	ra,40(sp)
    80005966:	f022                	sd	s0,32(sp)
    80005968:	ec26                	sd	s1,24(sp)
    8000596a:	e84a                	sd	s2,16(sp)
    8000596c:	1800                	addi	s0,sp,48
    8000596e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80005970:	00850913          	addi	s2,a0,8
    80005974:	854a                	mv	a0,s2
    80005976:	ab6fb0ef          	jal	80000c2c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000597a:	409c                	lw	a5,0(s1)
    8000597c:	ef81                	bnez	a5,80005994 <holdingsleep+0x32>
    8000597e:	4481                	li	s1,0
  release(&lk->lk);
    80005980:	854a                	mv	a0,s2
    80005982:	b3efb0ef          	jal	80000cc0 <release>
  return r;
}
    80005986:	8526                	mv	a0,s1
    80005988:	70a2                	ld	ra,40(sp)
    8000598a:	7402                	ld	s0,32(sp)
    8000598c:	64e2                	ld	s1,24(sp)
    8000598e:	6942                	ld	s2,16(sp)
    80005990:	6145                	addi	sp,sp,48
    80005992:	8082                	ret
    80005994:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80005996:	0284a983          	lw	s3,40(s1)
    8000599a:	caafd0ef          	jal	80002e44 <myproc>
    8000599e:	5904                	lw	s1,48(a0)
    800059a0:	413484b3          	sub	s1,s1,s3
    800059a4:	0014b493          	seqz	s1,s1
    800059a8:	69a2                	ld	s3,8(sp)
    800059aa:	bfd9                	j	80005980 <holdingsleep+0x1e>

00000000800059ac <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800059ac:	1141                	addi	sp,sp,-16
    800059ae:	e406                	sd	ra,8(sp)
    800059b0:	e022                	sd	s0,0(sp)
    800059b2:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800059b4:	00004597          	auipc	a1,0x4
    800059b8:	39c58593          	addi	a1,a1,924 # 80009d50 <etext+0xd50>
    800059bc:	002cd517          	auipc	a0,0x2cd
    800059c0:	02450513          	addi	a0,a0,36 # 802d29e0 <ftable>
    800059c4:	9defb0ef          	jal	80000ba2 <initlock>
}
    800059c8:	60a2                	ld	ra,8(sp)
    800059ca:	6402                	ld	s0,0(sp)
    800059cc:	0141                	addi	sp,sp,16
    800059ce:	8082                	ret

00000000800059d0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800059d0:	1101                	addi	sp,sp,-32
    800059d2:	ec06                	sd	ra,24(sp)
    800059d4:	e822                	sd	s0,16(sp)
    800059d6:	e426                	sd	s1,8(sp)
    800059d8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800059da:	002cd517          	auipc	a0,0x2cd
    800059de:	00650513          	addi	a0,a0,6 # 802d29e0 <ftable>
    800059e2:	a4afb0ef          	jal	80000c2c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800059e6:	002cd497          	auipc	s1,0x2cd
    800059ea:	01248493          	addi	s1,s1,18 # 802d29f8 <ftable+0x18>
    800059ee:	002ce717          	auipc	a4,0x2ce
    800059f2:	faa70713          	addi	a4,a4,-86 # 802d3998 <disk>
    if(f->ref == 0){
    800059f6:	40dc                	lw	a5,4(s1)
    800059f8:	cf89                	beqz	a5,80005a12 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800059fa:	02848493          	addi	s1,s1,40
    800059fe:	fee49ce3          	bne	s1,a4,800059f6 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80005a02:	002cd517          	auipc	a0,0x2cd
    80005a06:	fde50513          	addi	a0,a0,-34 # 802d29e0 <ftable>
    80005a0a:	ab6fb0ef          	jal	80000cc0 <release>
  return 0;
    80005a0e:	4481                	li	s1,0
    80005a10:	a809                	j	80005a22 <filealloc+0x52>
      f->ref = 1;
    80005a12:	4785                	li	a5,1
    80005a14:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80005a16:	002cd517          	auipc	a0,0x2cd
    80005a1a:	fca50513          	addi	a0,a0,-54 # 802d29e0 <ftable>
    80005a1e:	aa2fb0ef          	jal	80000cc0 <release>
}
    80005a22:	8526                	mv	a0,s1
    80005a24:	60e2                	ld	ra,24(sp)
    80005a26:	6442                	ld	s0,16(sp)
    80005a28:	64a2                	ld	s1,8(sp)
    80005a2a:	6105                	addi	sp,sp,32
    80005a2c:	8082                	ret

0000000080005a2e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80005a2e:	1101                	addi	sp,sp,-32
    80005a30:	ec06                	sd	ra,24(sp)
    80005a32:	e822                	sd	s0,16(sp)
    80005a34:	e426                	sd	s1,8(sp)
    80005a36:	1000                	addi	s0,sp,32
    80005a38:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80005a3a:	002cd517          	auipc	a0,0x2cd
    80005a3e:	fa650513          	addi	a0,a0,-90 # 802d29e0 <ftable>
    80005a42:	9eafb0ef          	jal	80000c2c <acquire>
  if(f->ref < 1)
    80005a46:	40dc                	lw	a5,4(s1)
    80005a48:	02f05063          	blez	a5,80005a68 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80005a4c:	2785                	addiw	a5,a5,1
    80005a4e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80005a50:	002cd517          	auipc	a0,0x2cd
    80005a54:	f9050513          	addi	a0,a0,-112 # 802d29e0 <ftable>
    80005a58:	a68fb0ef          	jal	80000cc0 <release>
  return f;
}
    80005a5c:	8526                	mv	a0,s1
    80005a5e:	60e2                	ld	ra,24(sp)
    80005a60:	6442                	ld	s0,16(sp)
    80005a62:	64a2                	ld	s1,8(sp)
    80005a64:	6105                	addi	sp,sp,32
    80005a66:	8082                	ret
    panic("filedup");
    80005a68:	00004517          	auipc	a0,0x4
    80005a6c:	2f050513          	addi	a0,a0,752 # 80009d58 <etext+0xd58>
    80005a70:	db5fa0ef          	jal	80000824 <panic>

0000000080005a74 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80005a74:	7139                	addi	sp,sp,-64
    80005a76:	fc06                	sd	ra,56(sp)
    80005a78:	f822                	sd	s0,48(sp)
    80005a7a:	f426                	sd	s1,40(sp)
    80005a7c:	0080                	addi	s0,sp,64
    80005a7e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80005a80:	002cd517          	auipc	a0,0x2cd
    80005a84:	f6050513          	addi	a0,a0,-160 # 802d29e0 <ftable>
    80005a88:	9a4fb0ef          	jal	80000c2c <acquire>
  if(f->ref < 1)
    80005a8c:	40dc                	lw	a5,4(s1)
    80005a8e:	04f05a63          	blez	a5,80005ae2 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80005a92:	37fd                	addiw	a5,a5,-1
    80005a94:	c0dc                	sw	a5,4(s1)
    80005a96:	06f04063          	bgtz	a5,80005af6 <fileclose+0x82>
    80005a9a:	f04a                	sd	s2,32(sp)
    80005a9c:	ec4e                	sd	s3,24(sp)
    80005a9e:	e852                	sd	s4,16(sp)
    80005aa0:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80005aa2:	0004a903          	lw	s2,0(s1)
    80005aa6:	0094c783          	lbu	a5,9(s1)
    80005aaa:	89be                	mv	s3,a5
    80005aac:	689c                	ld	a5,16(s1)
    80005aae:	8a3e                	mv	s4,a5
    80005ab0:	6c9c                	ld	a5,24(s1)
    80005ab2:	8abe                	mv	s5,a5
  f->ref = 0;
    80005ab4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80005ab8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80005abc:	002cd517          	auipc	a0,0x2cd
    80005ac0:	f2450513          	addi	a0,a0,-220 # 802d29e0 <ftable>
    80005ac4:	9fcfb0ef          	jal	80000cc0 <release>

  if(ff.type == FD_PIPE){
    80005ac8:	4785                	li	a5,1
    80005aca:	04f90163          	beq	s2,a5,80005b0c <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80005ace:	ffe9079b          	addiw	a5,s2,-2
    80005ad2:	4705                	li	a4,1
    80005ad4:	04f77563          	bgeu	a4,a5,80005b1e <fileclose+0xaa>
    80005ad8:	7902                	ld	s2,32(sp)
    80005ada:	69e2                	ld	s3,24(sp)
    80005adc:	6a42                	ld	s4,16(sp)
    80005ade:	6aa2                	ld	s5,8(sp)
    80005ae0:	a00d                	j	80005b02 <fileclose+0x8e>
    80005ae2:	f04a                	sd	s2,32(sp)
    80005ae4:	ec4e                	sd	s3,24(sp)
    80005ae6:	e852                	sd	s4,16(sp)
    80005ae8:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80005aea:	00004517          	auipc	a0,0x4
    80005aee:	27650513          	addi	a0,a0,630 # 80009d60 <etext+0xd60>
    80005af2:	d33fa0ef          	jal	80000824 <panic>
    release(&ftable.lock);
    80005af6:	002cd517          	auipc	a0,0x2cd
    80005afa:	eea50513          	addi	a0,a0,-278 # 802d29e0 <ftable>
    80005afe:	9c2fb0ef          	jal	80000cc0 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80005b02:	70e2                	ld	ra,56(sp)
    80005b04:	7442                	ld	s0,48(sp)
    80005b06:	74a2                	ld	s1,40(sp)
    80005b08:	6121                	addi	sp,sp,64
    80005b0a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80005b0c:	85ce                	mv	a1,s3
    80005b0e:	8552                	mv	a0,s4
    80005b10:	348000ef          	jal	80005e58 <pipeclose>
    80005b14:	7902                	ld	s2,32(sp)
    80005b16:	69e2                	ld	s3,24(sp)
    80005b18:	6a42                	ld	s4,16(sp)
    80005b1a:	6aa2                	ld	s5,8(sp)
    80005b1c:	b7dd                	j	80005b02 <fileclose+0x8e>
    begin_op();
    80005b1e:	b33ff0ef          	jal	80005650 <begin_op>
    iput(ff.ip);
    80005b22:	8556                	mv	a0,s5
    80005b24:	aa2ff0ef          	jal	80004dc6 <iput>
    end_op();
    80005b28:	b99ff0ef          	jal	800056c0 <end_op>
    80005b2c:	7902                	ld	s2,32(sp)
    80005b2e:	69e2                	ld	s3,24(sp)
    80005b30:	6a42                	ld	s4,16(sp)
    80005b32:	6aa2                	ld	s5,8(sp)
    80005b34:	b7f9                	j	80005b02 <fileclose+0x8e>

0000000080005b36 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80005b36:	715d                	addi	sp,sp,-80
    80005b38:	e486                	sd	ra,72(sp)
    80005b3a:	e0a2                	sd	s0,64(sp)
    80005b3c:	fc26                	sd	s1,56(sp)
    80005b3e:	f052                	sd	s4,32(sp)
    80005b40:	0880                	addi	s0,sp,80
    80005b42:	84aa                	mv	s1,a0
    80005b44:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80005b46:	afefd0ef          	jal	80002e44 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80005b4a:	409c                	lw	a5,0(s1)
    80005b4c:	37f9                	addiw	a5,a5,-2
    80005b4e:	4705                	li	a4,1
    80005b50:	04f76263          	bltu	a4,a5,80005b94 <filestat+0x5e>
    80005b54:	f84a                	sd	s2,48(sp)
    80005b56:	f44e                	sd	s3,40(sp)
    80005b58:	89aa                	mv	s3,a0
    ilock(f->ip);
    80005b5a:	6c88                	ld	a0,24(s1)
    80005b5c:	8e8ff0ef          	jal	80004c44 <ilock>
    stati(f->ip, &st);
    80005b60:	fb840913          	addi	s2,s0,-72
    80005b64:	85ca                	mv	a1,s2
    80005b66:	6c88                	ld	a0,24(s1)
    80005b68:	c40ff0ef          	jal	80004fa8 <stati>
    iunlock(f->ip);
    80005b6c:	6c88                	ld	a0,24(s1)
    80005b6e:	984ff0ef          	jal	80004cf2 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80005b72:	46e1                	li	a3,24
    80005b74:	864a                	mv	a2,s2
    80005b76:	85d2                	mv	a1,s4
    80005b78:	0509b503          	ld	a0,80(s3)
    80005b7c:	d05fc0ef          	jal	80002880 <copyout>
    80005b80:	41f5551b          	sraiw	a0,a0,0x1f
    80005b84:	7942                	ld	s2,48(sp)
    80005b86:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80005b88:	60a6                	ld	ra,72(sp)
    80005b8a:	6406                	ld	s0,64(sp)
    80005b8c:	74e2                	ld	s1,56(sp)
    80005b8e:	7a02                	ld	s4,32(sp)
    80005b90:	6161                	addi	sp,sp,80
    80005b92:	8082                	ret
  return -1;
    80005b94:	557d                	li	a0,-1
    80005b96:	bfcd                	j	80005b88 <filestat+0x52>

0000000080005b98 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80005b98:	7179                	addi	sp,sp,-48
    80005b9a:	f406                	sd	ra,40(sp)
    80005b9c:	f022                	sd	s0,32(sp)
    80005b9e:	e84a                	sd	s2,16(sp)
    80005ba0:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005ba2:	00854783          	lbu	a5,8(a0)
    80005ba6:	cfd1                	beqz	a5,80005c42 <fileread+0xaa>
    80005ba8:	ec26                	sd	s1,24(sp)
    80005baa:	e44e                	sd	s3,8(sp)
    80005bac:	84aa                	mv	s1,a0
    80005bae:	892e                	mv	s2,a1
    80005bb0:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    80005bb2:	411c                	lw	a5,0(a0)
    80005bb4:	4705                	li	a4,1
    80005bb6:	04e78363          	beq	a5,a4,80005bfc <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005bba:	470d                	li	a4,3
    80005bbc:	04e78763          	beq	a5,a4,80005c0a <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005bc0:	4709                	li	a4,2
    80005bc2:	06e79a63          	bne	a5,a4,80005c36 <fileread+0x9e>
    ilock(f->ip);
    80005bc6:	6d08                	ld	a0,24(a0)
    80005bc8:	87cff0ef          	jal	80004c44 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80005bcc:	874e                	mv	a4,s3
    80005bce:	5094                	lw	a3,32(s1)
    80005bd0:	864a                	mv	a2,s2
    80005bd2:	4585                	li	a1,1
    80005bd4:	6c88                	ld	a0,24(s1)
    80005bd6:	c00ff0ef          	jal	80004fd6 <readi>
    80005bda:	892a                	mv	s2,a0
    80005bdc:	00a05563          	blez	a0,80005be6 <fileread+0x4e>
      f->off += r;
    80005be0:	509c                	lw	a5,32(s1)
    80005be2:	9fa9                	addw	a5,a5,a0
    80005be4:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005be6:	6c88                	ld	a0,24(s1)
    80005be8:	90aff0ef          	jal	80004cf2 <iunlock>
    80005bec:	64e2                	ld	s1,24(sp)
    80005bee:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80005bf0:	854a                	mv	a0,s2
    80005bf2:	70a2                	ld	ra,40(sp)
    80005bf4:	7402                	ld	s0,32(sp)
    80005bf6:	6942                	ld	s2,16(sp)
    80005bf8:	6145                	addi	sp,sp,48
    80005bfa:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005bfc:	6908                	ld	a0,16(a0)
    80005bfe:	3b0000ef          	jal	80005fae <piperead>
    80005c02:	892a                	mv	s2,a0
    80005c04:	64e2                	ld	s1,24(sp)
    80005c06:	69a2                	ld	s3,8(sp)
    80005c08:	b7e5                	j	80005bf0 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005c0a:	02451783          	lh	a5,36(a0)
    80005c0e:	03079693          	slli	a3,a5,0x30
    80005c12:	92c1                	srli	a3,a3,0x30
    80005c14:	4725                	li	a4,9
    80005c16:	02d76963          	bltu	a4,a3,80005c48 <fileread+0xb0>
    80005c1a:	0792                	slli	a5,a5,0x4
    80005c1c:	002cd717          	auipc	a4,0x2cd
    80005c20:	d2470713          	addi	a4,a4,-732 # 802d2940 <devsw>
    80005c24:	97ba                	add	a5,a5,a4
    80005c26:	639c                	ld	a5,0(a5)
    80005c28:	c78d                	beqz	a5,80005c52 <fileread+0xba>
    r = devsw[f->major].read(1, addr, n);
    80005c2a:	4505                	li	a0,1
    80005c2c:	9782                	jalr	a5
    80005c2e:	892a                	mv	s2,a0
    80005c30:	64e2                	ld	s1,24(sp)
    80005c32:	69a2                	ld	s3,8(sp)
    80005c34:	bf75                	j	80005bf0 <fileread+0x58>
    panic("fileread");
    80005c36:	00004517          	auipc	a0,0x4
    80005c3a:	13a50513          	addi	a0,a0,314 # 80009d70 <etext+0xd70>
    80005c3e:	be7fa0ef          	jal	80000824 <panic>
    return -1;
    80005c42:	57fd                	li	a5,-1
    80005c44:	893e                	mv	s2,a5
    80005c46:	b76d                	j	80005bf0 <fileread+0x58>
      return -1;
    80005c48:	57fd                	li	a5,-1
    80005c4a:	893e                	mv	s2,a5
    80005c4c:	64e2                	ld	s1,24(sp)
    80005c4e:	69a2                	ld	s3,8(sp)
    80005c50:	b745                	j	80005bf0 <fileread+0x58>
    80005c52:	57fd                	li	a5,-1
    80005c54:	893e                	mv	s2,a5
    80005c56:	64e2                	ld	s1,24(sp)
    80005c58:	69a2                	ld	s3,8(sp)
    80005c5a:	bf59                	j	80005bf0 <fileread+0x58>

0000000080005c5c <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80005c5c:	00954783          	lbu	a5,9(a0)
    80005c60:	10078f63          	beqz	a5,80005d7e <filewrite+0x122>
{
    80005c64:	711d                	addi	sp,sp,-96
    80005c66:	ec86                	sd	ra,88(sp)
    80005c68:	e8a2                	sd	s0,80(sp)
    80005c6a:	e0ca                	sd	s2,64(sp)
    80005c6c:	f456                	sd	s5,40(sp)
    80005c6e:	f05a                	sd	s6,32(sp)
    80005c70:	1080                	addi	s0,sp,96
    80005c72:	892a                	mv	s2,a0
    80005c74:	8b2e                	mv	s6,a1
    80005c76:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    80005c78:	411c                	lw	a5,0(a0)
    80005c7a:	4705                	li	a4,1
    80005c7c:	02e78a63          	beq	a5,a4,80005cb0 <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005c80:	470d                	li	a4,3
    80005c82:	02e78b63          	beq	a5,a4,80005cb8 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005c86:	4709                	li	a4,2
    80005c88:	0ce79f63          	bne	a5,a4,80005d66 <filewrite+0x10a>
    80005c8c:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005c8e:	0ac05a63          	blez	a2,80005d42 <filewrite+0xe6>
    80005c92:	e4a6                	sd	s1,72(sp)
    80005c94:	fc4e                	sd	s3,56(sp)
    80005c96:	ec5e                	sd	s7,24(sp)
    80005c98:	e862                	sd	s8,16(sp)
    80005c9a:	e466                	sd	s9,8(sp)
    int i = 0;
    80005c9c:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80005c9e:	6b85                	lui	s7,0x1
    80005ca0:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80005ca4:	6785                	lui	a5,0x1
    80005ca6:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80005caa:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005cac:	4c05                	li	s8,1
    80005cae:	a8ad                	j	80005d28 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80005cb0:	6908                	ld	a0,16(a0)
    80005cb2:	204000ef          	jal	80005eb6 <pipewrite>
    80005cb6:	a04d                	j	80005d58 <filewrite+0xfc>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005cb8:	02451783          	lh	a5,36(a0)
    80005cbc:	03079693          	slli	a3,a5,0x30
    80005cc0:	92c1                	srli	a3,a3,0x30
    80005cc2:	4725                	li	a4,9
    80005cc4:	0ad76f63          	bltu	a4,a3,80005d82 <filewrite+0x126>
    80005cc8:	0792                	slli	a5,a5,0x4
    80005cca:	002cd717          	auipc	a4,0x2cd
    80005cce:	c7670713          	addi	a4,a4,-906 # 802d2940 <devsw>
    80005cd2:	97ba                	add	a5,a5,a4
    80005cd4:	679c                	ld	a5,8(a5)
    80005cd6:	cbc5                	beqz	a5,80005d86 <filewrite+0x12a>
    ret = devsw[f->major].write(1, addr, n);
    80005cd8:	4505                	li	a0,1
    80005cda:	9782                	jalr	a5
    80005cdc:	a8b5                	j	80005d58 <filewrite+0xfc>
      if(n1 > max)
    80005cde:	2981                	sext.w	s3,s3
      begin_op();
    80005ce0:	971ff0ef          	jal	80005650 <begin_op>
      ilock(f->ip);
    80005ce4:	01893503          	ld	a0,24(s2)
    80005ce8:	f5dfe0ef          	jal	80004c44 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005cec:	874e                	mv	a4,s3
    80005cee:	02092683          	lw	a3,32(s2)
    80005cf2:	016a0633          	add	a2,s4,s6
    80005cf6:	85e2                	mv	a1,s8
    80005cf8:	01893503          	ld	a0,24(s2)
    80005cfc:	bccff0ef          	jal	800050c8 <writei>
    80005d00:	84aa                	mv	s1,a0
    80005d02:	00a05763          	blez	a0,80005d10 <filewrite+0xb4>
        f->off += r;
    80005d06:	02092783          	lw	a5,32(s2)
    80005d0a:	9fa9                	addw	a5,a5,a0
    80005d0c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005d10:	01893503          	ld	a0,24(s2)
    80005d14:	fdffe0ef          	jal	80004cf2 <iunlock>
      end_op();
    80005d18:	9a9ff0ef          	jal	800056c0 <end_op>

      if(r != n1){
    80005d1c:	02999563          	bne	s3,s1,80005d46 <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    80005d20:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    80005d24:	015a5963          	bge	s4,s5,80005d36 <filewrite+0xda>
      int n1 = n - i;
    80005d28:	414a87bb          	subw	a5,s5,s4
    80005d2c:	89be                	mv	s3,a5
      if(n1 > max)
    80005d2e:	fafbd8e3          	bge	s7,a5,80005cde <filewrite+0x82>
    80005d32:	89e6                	mv	s3,s9
    80005d34:	b76d                	j	80005cde <filewrite+0x82>
    80005d36:	64a6                	ld	s1,72(sp)
    80005d38:	79e2                	ld	s3,56(sp)
    80005d3a:	6be2                	ld	s7,24(sp)
    80005d3c:	6c42                	ld	s8,16(sp)
    80005d3e:	6ca2                	ld	s9,8(sp)
    80005d40:	a801                	j	80005d50 <filewrite+0xf4>
    int i = 0;
    80005d42:	4a01                	li	s4,0
    80005d44:	a031                	j	80005d50 <filewrite+0xf4>
    80005d46:	64a6                	ld	s1,72(sp)
    80005d48:	79e2                	ld	s3,56(sp)
    80005d4a:	6be2                	ld	s7,24(sp)
    80005d4c:	6c42                	ld	s8,16(sp)
    80005d4e:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80005d50:	034a9d63          	bne	s5,s4,80005d8a <filewrite+0x12e>
    80005d54:	8556                	mv	a0,s5
    80005d56:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005d58:	60e6                	ld	ra,88(sp)
    80005d5a:	6446                	ld	s0,80(sp)
    80005d5c:	6906                	ld	s2,64(sp)
    80005d5e:	7aa2                	ld	s5,40(sp)
    80005d60:	7b02                	ld	s6,32(sp)
    80005d62:	6125                	addi	sp,sp,96
    80005d64:	8082                	ret
    80005d66:	e4a6                	sd	s1,72(sp)
    80005d68:	fc4e                	sd	s3,56(sp)
    80005d6a:	f852                	sd	s4,48(sp)
    80005d6c:	ec5e                	sd	s7,24(sp)
    80005d6e:	e862                	sd	s8,16(sp)
    80005d70:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80005d72:	00004517          	auipc	a0,0x4
    80005d76:	00e50513          	addi	a0,a0,14 # 80009d80 <etext+0xd80>
    80005d7a:	aabfa0ef          	jal	80000824 <panic>
    return -1;
    80005d7e:	557d                	li	a0,-1
}
    80005d80:	8082                	ret
      return -1;
    80005d82:	557d                	li	a0,-1
    80005d84:	bfd1                	j	80005d58 <filewrite+0xfc>
    80005d86:	557d                	li	a0,-1
    80005d88:	bfc1                	j	80005d58 <filewrite+0xfc>
    ret = (i == n ? n : -1);
    80005d8a:	557d                	li	a0,-1
    80005d8c:	7a42                	ld	s4,48(sp)
    80005d8e:	b7e9                	j	80005d58 <filewrite+0xfc>

0000000080005d90 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005d90:	7179                	addi	sp,sp,-48
    80005d92:	f406                	sd	ra,40(sp)
    80005d94:	f022                	sd	s0,32(sp)
    80005d96:	ec26                	sd	s1,24(sp)
    80005d98:	e052                	sd	s4,0(sp)
    80005d9a:	1800                	addi	s0,sp,48
    80005d9c:	84aa                	mv	s1,a0
    80005d9e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005da0:	0005b023          	sd	zero,0(a1)
    80005da4:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005da8:	c29ff0ef          	jal	800059d0 <filealloc>
    80005dac:	e088                	sd	a0,0(s1)
    80005dae:	c549                	beqz	a0,80005e38 <pipealloc+0xa8>
    80005db0:	c21ff0ef          	jal	800059d0 <filealloc>
    80005db4:	00aa3023          	sd	a0,0(s4)
    80005db8:	cd25                	beqz	a0,80005e30 <pipealloc+0xa0>
    80005dba:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005dbc:	d8dfa0ef          	jal	80000b48 <kalloc>
    80005dc0:	892a                	mv	s2,a0
    80005dc2:	c12d                	beqz	a0,80005e24 <pipealloc+0x94>
    80005dc4:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80005dc6:	4985                	li	s3,1
    80005dc8:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005dcc:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005dd0:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005dd4:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005dd8:	00004597          	auipc	a1,0x4
    80005ddc:	fb858593          	addi	a1,a1,-72 # 80009d90 <etext+0xd90>
    80005de0:	dc3fa0ef          	jal	80000ba2 <initlock>
  (*f0)->type = FD_PIPE;
    80005de4:	609c                	ld	a5,0(s1)
    80005de6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005dea:	609c                	ld	a5,0(s1)
    80005dec:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005df0:	609c                	ld	a5,0(s1)
    80005df2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005df6:	609c                	ld	a5,0(s1)
    80005df8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005dfc:	000a3783          	ld	a5,0(s4)
    80005e00:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005e04:	000a3783          	ld	a5,0(s4)
    80005e08:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005e0c:	000a3783          	ld	a5,0(s4)
    80005e10:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005e14:	000a3783          	ld	a5,0(s4)
    80005e18:	0127b823          	sd	s2,16(a5)
  return 0;
    80005e1c:	4501                	li	a0,0
    80005e1e:	6942                	ld	s2,16(sp)
    80005e20:	69a2                	ld	s3,8(sp)
    80005e22:	a01d                	j	80005e48 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005e24:	6088                	ld	a0,0(s1)
    80005e26:	c119                	beqz	a0,80005e2c <pipealloc+0x9c>
    80005e28:	6942                	ld	s2,16(sp)
    80005e2a:	a029                	j	80005e34 <pipealloc+0xa4>
    80005e2c:	6942                	ld	s2,16(sp)
    80005e2e:	a029                	j	80005e38 <pipealloc+0xa8>
    80005e30:	6088                	ld	a0,0(s1)
    80005e32:	c10d                	beqz	a0,80005e54 <pipealloc+0xc4>
    fileclose(*f0);
    80005e34:	c41ff0ef          	jal	80005a74 <fileclose>
  if(*f1)
    80005e38:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005e3c:	557d                	li	a0,-1
  if(*f1)
    80005e3e:	c789                	beqz	a5,80005e48 <pipealloc+0xb8>
    fileclose(*f1);
    80005e40:	853e                	mv	a0,a5
    80005e42:	c33ff0ef          	jal	80005a74 <fileclose>
  return -1;
    80005e46:	557d                	li	a0,-1
}
    80005e48:	70a2                	ld	ra,40(sp)
    80005e4a:	7402                	ld	s0,32(sp)
    80005e4c:	64e2                	ld	s1,24(sp)
    80005e4e:	6a02                	ld	s4,0(sp)
    80005e50:	6145                	addi	sp,sp,48
    80005e52:	8082                	ret
  return -1;
    80005e54:	557d                	li	a0,-1
    80005e56:	bfcd                	j	80005e48 <pipealloc+0xb8>

0000000080005e58 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005e58:	1101                	addi	sp,sp,-32
    80005e5a:	ec06                	sd	ra,24(sp)
    80005e5c:	e822                	sd	s0,16(sp)
    80005e5e:	e426                	sd	s1,8(sp)
    80005e60:	e04a                	sd	s2,0(sp)
    80005e62:	1000                	addi	s0,sp,32
    80005e64:	84aa                	mv	s1,a0
    80005e66:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005e68:	dc5fa0ef          	jal	80000c2c <acquire>
  if(writable){
    80005e6c:	02090763          	beqz	s2,80005e9a <pipeclose+0x42>
    pi->writeopen = 0;
    80005e70:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005e74:	21848513          	addi	a0,s1,536
    80005e78:	80bfd0ef          	jal	80003682 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005e7c:	2204a783          	lw	a5,544(s1)
    80005e80:	e781                	bnez	a5,80005e88 <pipeclose+0x30>
    80005e82:	2244a783          	lw	a5,548(s1)
    80005e86:	c38d                	beqz	a5,80005ea8 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    80005e88:	8526                	mv	a0,s1
    80005e8a:	e37fa0ef          	jal	80000cc0 <release>
}
    80005e8e:	60e2                	ld	ra,24(sp)
    80005e90:	6442                	ld	s0,16(sp)
    80005e92:	64a2                	ld	s1,8(sp)
    80005e94:	6902                	ld	s2,0(sp)
    80005e96:	6105                	addi	sp,sp,32
    80005e98:	8082                	ret
    pi->readopen = 0;
    80005e9a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005e9e:	21c48513          	addi	a0,s1,540
    80005ea2:	fe0fd0ef          	jal	80003682 <wakeup>
    80005ea6:	bfd9                	j	80005e7c <pipeclose+0x24>
    release(&pi->lock);
    80005ea8:	8526                	mv	a0,s1
    80005eaa:	e17fa0ef          	jal	80000cc0 <release>
    kfree((char*)pi);
    80005eae:	8526                	mv	a0,s1
    80005eb0:	badfa0ef          	jal	80000a5c <kfree>
    80005eb4:	bfe9                	j	80005e8e <pipeclose+0x36>

0000000080005eb6 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005eb6:	7159                	addi	sp,sp,-112
    80005eb8:	f486                	sd	ra,104(sp)
    80005eba:	f0a2                	sd	s0,96(sp)
    80005ebc:	eca6                	sd	s1,88(sp)
    80005ebe:	e8ca                	sd	s2,80(sp)
    80005ec0:	e4ce                	sd	s3,72(sp)
    80005ec2:	e0d2                	sd	s4,64(sp)
    80005ec4:	fc56                	sd	s5,56(sp)
    80005ec6:	1880                	addi	s0,sp,112
    80005ec8:	84aa                	mv	s1,a0
    80005eca:	8aae                	mv	s5,a1
    80005ecc:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005ece:	f77fc0ef          	jal	80002e44 <myproc>
    80005ed2:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005ed4:	8526                	mv	a0,s1
    80005ed6:	d57fa0ef          	jal	80000c2c <acquire>
  while(i < n){
    80005eda:	0d405263          	blez	s4,80005f9e <pipewrite+0xe8>
    80005ede:	f85a                	sd	s6,48(sp)
    80005ee0:	f45e                	sd	s7,40(sp)
    80005ee2:	f062                	sd	s8,32(sp)
    80005ee4:	ec66                	sd	s9,24(sp)
    80005ee6:	e86a                	sd	s10,16(sp)
  int i = 0;
    80005ee8:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005eea:	f9f40c13          	addi	s8,s0,-97
    80005eee:	4b85                	li	s7,1
    80005ef0:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005ef2:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005ef6:	21c48c93          	addi	s9,s1,540
    80005efa:	a82d                	j	80005f34 <pipewrite+0x7e>
      release(&pi->lock);
    80005efc:	8526                	mv	a0,s1
    80005efe:	dc3fa0ef          	jal	80000cc0 <release>
      return -1;
    80005f02:	597d                	li	s2,-1
    80005f04:	7b42                	ld	s6,48(sp)
    80005f06:	7ba2                	ld	s7,40(sp)
    80005f08:	7c02                	ld	s8,32(sp)
    80005f0a:	6ce2                	ld	s9,24(sp)
    80005f0c:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005f0e:	854a                	mv	a0,s2
    80005f10:	70a6                	ld	ra,104(sp)
    80005f12:	7406                	ld	s0,96(sp)
    80005f14:	64e6                	ld	s1,88(sp)
    80005f16:	6946                	ld	s2,80(sp)
    80005f18:	69a6                	ld	s3,72(sp)
    80005f1a:	6a06                	ld	s4,64(sp)
    80005f1c:	7ae2                	ld	s5,56(sp)
    80005f1e:	6165                	addi	sp,sp,112
    80005f20:	8082                	ret
      wakeup(&pi->nread);
    80005f22:	856a                	mv	a0,s10
    80005f24:	f5efd0ef          	jal	80003682 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005f28:	85a6                	mv	a1,s1
    80005f2a:	8566                	mv	a0,s9
    80005f2c:	f0afd0ef          	jal	80003636 <sleep>
  while(i < n){
    80005f30:	05495a63          	bge	s2,s4,80005f84 <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    80005f34:	2204a783          	lw	a5,544(s1)
    80005f38:	d3f1                	beqz	a5,80005efc <pipewrite+0x46>
    80005f3a:	854e                	mv	a0,s3
    80005f3c:	953fd0ef          	jal	8000388e <killed>
    80005f40:	fd55                	bnez	a0,80005efc <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005f42:	2184a783          	lw	a5,536(s1)
    80005f46:	21c4a703          	lw	a4,540(s1)
    80005f4a:	2007879b          	addiw	a5,a5,512
    80005f4e:	fcf70ae3          	beq	a4,a5,80005f22 <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005f52:	86de                	mv	a3,s7
    80005f54:	01590633          	add	a2,s2,s5
    80005f58:	85e2                	mv	a1,s8
    80005f5a:	0509b503          	ld	a0,80(s3)
    80005f5e:	ab7fc0ef          	jal	80002a14 <copyin>
    80005f62:	05650063          	beq	a0,s6,80005fa2 <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005f66:	21c4a783          	lw	a5,540(s1)
    80005f6a:	0017871b          	addiw	a4,a5,1
    80005f6e:	20e4ae23          	sw	a4,540(s1)
    80005f72:	1ff7f793          	andi	a5,a5,511
    80005f76:	97a6                	add	a5,a5,s1
    80005f78:	f9f44703          	lbu	a4,-97(s0)
    80005f7c:	00e78c23          	sb	a4,24(a5)
      i++;
    80005f80:	2905                	addiw	s2,s2,1
    80005f82:	b77d                	j	80005f30 <pipewrite+0x7a>
    80005f84:	7b42                	ld	s6,48(sp)
    80005f86:	7ba2                	ld	s7,40(sp)
    80005f88:	7c02                	ld	s8,32(sp)
    80005f8a:	6ce2                	ld	s9,24(sp)
    80005f8c:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80005f8e:	21848513          	addi	a0,s1,536
    80005f92:	ef0fd0ef          	jal	80003682 <wakeup>
  release(&pi->lock);
    80005f96:	8526                	mv	a0,s1
    80005f98:	d29fa0ef          	jal	80000cc0 <release>
  return i;
    80005f9c:	bf8d                	j	80005f0e <pipewrite+0x58>
  int i = 0;
    80005f9e:	4901                	li	s2,0
    80005fa0:	b7fd                	j	80005f8e <pipewrite+0xd8>
    80005fa2:	7b42                	ld	s6,48(sp)
    80005fa4:	7ba2                	ld	s7,40(sp)
    80005fa6:	7c02                	ld	s8,32(sp)
    80005fa8:	6ce2                	ld	s9,24(sp)
    80005faa:	6d42                	ld	s10,16(sp)
    80005fac:	b7cd                	j	80005f8e <pipewrite+0xd8>

0000000080005fae <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005fae:	711d                	addi	sp,sp,-96
    80005fb0:	ec86                	sd	ra,88(sp)
    80005fb2:	e8a2                	sd	s0,80(sp)
    80005fb4:	e4a6                	sd	s1,72(sp)
    80005fb6:	e0ca                	sd	s2,64(sp)
    80005fb8:	fc4e                	sd	s3,56(sp)
    80005fba:	f852                	sd	s4,48(sp)
    80005fbc:	f456                	sd	s5,40(sp)
    80005fbe:	1080                	addi	s0,sp,96
    80005fc0:	84aa                	mv	s1,a0
    80005fc2:	892e                	mv	s2,a1
    80005fc4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005fc6:	e7ffc0ef          	jal	80002e44 <myproc>
    80005fca:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005fcc:	8526                	mv	a0,s1
    80005fce:	c5ffa0ef          	jal	80000c2c <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005fd2:	2184a703          	lw	a4,536(s1)
    80005fd6:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005fda:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005fde:	02f71763          	bne	a4,a5,8000600c <piperead+0x5e>
    80005fe2:	2244a783          	lw	a5,548(s1)
    80005fe6:	cf85                	beqz	a5,8000601e <piperead+0x70>
    if(killed(pr)){
    80005fe8:	8552                	mv	a0,s4
    80005fea:	8a5fd0ef          	jal	8000388e <killed>
    80005fee:	e11d                	bnez	a0,80006014 <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005ff0:	85a6                	mv	a1,s1
    80005ff2:	854e                	mv	a0,s3
    80005ff4:	e42fd0ef          	jal	80003636 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005ff8:	2184a703          	lw	a4,536(s1)
    80005ffc:	21c4a783          	lw	a5,540(s1)
    80006000:	fef701e3          	beq	a4,a5,80005fe2 <piperead+0x34>
    80006004:	f05a                	sd	s6,32(sp)
    80006006:	ec5e                	sd	s7,24(sp)
    80006008:	e862                	sd	s8,16(sp)
    8000600a:	a829                	j	80006024 <piperead+0x76>
    8000600c:	f05a                	sd	s6,32(sp)
    8000600e:	ec5e                	sd	s7,24(sp)
    80006010:	e862                	sd	s8,16(sp)
    80006012:	a809                	j	80006024 <piperead+0x76>
      release(&pi->lock);
    80006014:	8526                	mv	a0,s1
    80006016:	cabfa0ef          	jal	80000cc0 <release>
      return -1;
    8000601a:	59fd                	li	s3,-1
    8000601c:	a0a5                	j	80006084 <piperead+0xd6>
    8000601e:	f05a                	sd	s6,32(sp)
    80006020:	ec5e                	sd	s7,24(sp)
    80006022:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80006024:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80006026:	faf40c13          	addi	s8,s0,-81
    8000602a:	4b85                	li	s7,1
    8000602c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000602e:	05505163          	blez	s5,80006070 <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    80006032:	2184a783          	lw	a5,536(s1)
    80006036:	21c4a703          	lw	a4,540(s1)
    8000603a:	02f70b63          	beq	a4,a5,80006070 <piperead+0xc2>
    ch = pi->data[pi->nread % PIPESIZE];
    8000603e:	1ff7f793          	andi	a5,a5,511
    80006042:	97a6                	add	a5,a5,s1
    80006044:	0187c783          	lbu	a5,24(a5)
    80006048:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    8000604c:	86de                	mv	a3,s7
    8000604e:	8662                	mv	a2,s8
    80006050:	85ca                	mv	a1,s2
    80006052:	050a3503          	ld	a0,80(s4)
    80006056:	82bfc0ef          	jal	80002880 <copyout>
    8000605a:	03650f63          	beq	a0,s6,80006098 <piperead+0xea>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    8000605e:	2184a783          	lw	a5,536(s1)
    80006062:	2785                	addiw	a5,a5,1
    80006064:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80006068:	2985                	addiw	s3,s3,1
    8000606a:	0905                	addi	s2,s2,1
    8000606c:	fd3a93e3          	bne	s5,s3,80006032 <piperead+0x84>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80006070:	21c48513          	addi	a0,s1,540
    80006074:	e0efd0ef          	jal	80003682 <wakeup>
  release(&pi->lock);
    80006078:	8526                	mv	a0,s1
    8000607a:	c47fa0ef          	jal	80000cc0 <release>
    8000607e:	7b02                	ld	s6,32(sp)
    80006080:	6be2                	ld	s7,24(sp)
    80006082:	6c42                	ld	s8,16(sp)
  return i;
}
    80006084:	854e                	mv	a0,s3
    80006086:	60e6                	ld	ra,88(sp)
    80006088:	6446                	ld	s0,80(sp)
    8000608a:	64a6                	ld	s1,72(sp)
    8000608c:	6906                	ld	s2,64(sp)
    8000608e:	79e2                	ld	s3,56(sp)
    80006090:	7a42                	ld	s4,48(sp)
    80006092:	7aa2                	ld	s5,40(sp)
    80006094:	6125                	addi	sp,sp,96
    80006096:	8082                	ret
      if(i == 0)
    80006098:	fc099ce3          	bnez	s3,80006070 <piperead+0xc2>
        i = -1;
    8000609c:	89aa                	mv	s3,a0
    8000609e:	bfc9                	j	80006070 <piperead+0xc2>

00000000800060a0 <flags2perm>:
//part1 - Commented out loadseg declaration since we're using demand loading
//static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800060a0:	1141                	addi	sp,sp,-16
    800060a2:	e406                	sd	ra,8(sp)
    800060a4:	e022                	sd	s0,0(sp)
    800060a6:	0800                	addi	s0,sp,16
    800060a8:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800060aa:	0035151b          	slliw	a0,a0,0x3
    800060ae:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    800060b0:	8b89                	andi	a5,a5,2
    800060b2:	c399                	beqz	a5,800060b8 <flags2perm+0x18>
      perm |= PTE_W;
    800060b4:	00456513          	ori	a0,a0,4
    return perm;
}
    800060b8:	60a2                	ld	ra,8(sp)
    800060ba:	6402                	ld	s0,0(sp)
    800060bc:	0141                	addi	sp,sp,16
    800060be:	8082                	ret

00000000800060c0 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800060c0:	dc010113          	addi	sp,sp,-576
    800060c4:	22113c23          	sd	ra,568(sp)
    800060c8:	22813823          	sd	s0,560(sp)
    800060cc:	22913423          	sd	s1,552(sp)
    800060d0:	21413823          	sd	s4,528(sp)
    800060d4:	0480                	addi	s0,sp,576
    800060d6:	84aa                	mv	s1,a0
    800060d8:	dea43023          	sd	a0,-544(s0)
    800060dc:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800060e0:	d65fc0ef          	jal	80002e44 <myproc>
    800060e4:	8a2a                	mv	s4,a0

  begin_op();
    800060e6:	d6aff0ef          	jal	80005650 <begin_op>

  //part1 - Debug: exec starting
  printf("[pid %d] EXEC starting: %s\n", p->pid, path);
    800060ea:	8626                	mv	a2,s1
    800060ec:	030a2583          	lw	a1,48(s4)
    800060f0:	00004517          	auipc	a0,0x4
    800060f4:	ca850513          	addi	a0,a0,-856 # 80009d98 <etext+0xd98>
    800060f8:	c02fa0ef          	jal	800004fa <printf>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800060fc:	8526                	mv	a0,s1
    800060fe:	b74ff0ef          	jal	80005472 <namei>
    80006102:	c551                	beqz	a0,8000618e <kexec+0xce>
    80006104:	23213023          	sd	s2,544(sp)
    80006108:	892a                	mv	s2,a0
    printf("[pid %d] EXEC failed: cannot open %s\n", p->pid, path);
    end_op();
    return -1;
  }
  ilock(ip);
    8000610a:	b3bfe0ef          	jal	80004c44 <ilock>

  //part1 - Debug: file opened successfully
  printf("[pid %d] EXEC file opened successfully\n", p->pid);
    8000610e:	030a2583          	lw	a1,48(s4)
    80006112:	00004517          	auipc	a0,0x4
    80006116:	cce50513          	addi	a0,a0,-818 # 80009de0 <etext+0xde0>
    8000611a:	be0fa0ef          	jal	800004fa <printf>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf)) {
    8000611e:	04000713          	li	a4,64
    80006122:	4681                	li	a3,0
    80006124:	e5040613          	addi	a2,s0,-432
    80006128:	4581                	li	a1,0
    8000612a:	854a                	mv	a0,s2
    8000612c:	eabfe0ef          	jal	80004fd6 <readi>
    80006130:	04000793          	li	a5,64
    80006134:	06f51b63          	bne	a0,a5,800061aa <kexec+0xea>
    printf("[pid %d] EXEC failed: cannot read ELF header\n", p->pid);
    goto bad;
  }

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC) {
    80006138:	e5042703          	lw	a4,-432(s0)
    8000613c:	464c47b7          	lui	a5,0x464c4
    80006140:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80006144:	06f70c63          	beq	a4,a5,800061bc <kexec+0xfc>
    printf("[pid %d] EXEC failed: not an ELF file\n", p->pid);
    80006148:	030a2583          	lw	a1,48(s4)
    8000614c:	00004517          	auipc	a0,0x4
    80006150:	cec50513          	addi	a0,a0,-788 # 80009e38 <etext+0xe38>
    80006154:	ba6fa0ef          	jal	800004fa <printf>
  printf("[pid %d] EXEC completed successfully, entry=0x%lx sp=0x%lx\n", p->pid, elf.entry, sp);

  return argc; // this ends up in a0, the first argument to main(argc, argv)

 bad:
  printf("[pid %d] EXEC failed: going to bad label\n", p->pid);
    80006158:	030a2583          	lw	a1,48(s4)
    8000615c:	00004517          	auipc	a0,0x4
    80006160:	f7450513          	addi	a0,a0,-140 # 8000a0d0 <etext+0x10d0>
    80006164:	b96fa0ef          	jal	800004fa <printf>
  if(pagetable) {
    // Note: freewalk() now handles leftover pages automatically
    proc_freepagetable(pagetable, sz);
  }
  if(ip){
    iunlockput(ip);
    80006168:	854a                	mv	a0,s2
    8000616a:	ce7fe0ef          	jal	80004e50 <iunlockput>
    end_op();
    8000616e:	d52ff0ef          	jal	800056c0 <end_op>
  }
  return -1;
    80006172:	557d                	li	a0,-1
    80006174:	22013903          	ld	s2,544(sp)
}
    80006178:	23813083          	ld	ra,568(sp)
    8000617c:	23013403          	ld	s0,560(sp)
    80006180:	22813483          	ld	s1,552(sp)
    80006184:	21013a03          	ld	s4,528(sp)
    80006188:	24010113          	addi	sp,sp,576
    8000618c:	8082                	ret
    printf("[pid %d] EXEC failed: cannot open %s\n", p->pid, path);
    8000618e:	de043603          	ld	a2,-544(s0)
    80006192:	030a2583          	lw	a1,48(s4)
    80006196:	00004517          	auipc	a0,0x4
    8000619a:	c2250513          	addi	a0,a0,-990 # 80009db8 <etext+0xdb8>
    8000619e:	b5cfa0ef          	jal	800004fa <printf>
    end_op();
    800061a2:	d1eff0ef          	jal	800056c0 <end_op>
    return -1;
    800061a6:	557d                	li	a0,-1
    800061a8:	bfc1                	j	80006178 <kexec+0xb8>
    printf("[pid %d] EXEC failed: cannot read ELF header\n", p->pid);
    800061aa:	030a2583          	lw	a1,48(s4)
    800061ae:	00004517          	auipc	a0,0x4
    800061b2:	c5a50513          	addi	a0,a0,-934 # 80009e08 <etext+0xe08>
    800061b6:	b44fa0ef          	jal	800004fa <printf>
    goto bad;
    800061ba:	bf79                	j	80006158 <kexec+0x98>
  if((pagetable = proc_pagetable(p)) == 0) {
    800061bc:	8552                	mv	a0,s4
    800061be:	d91fc0ef          	jal	80002f4e <proc_pagetable>
    800061c2:	dea43423          	sd	a0,-536(s0)
    800061c6:	c525                	beqz	a0,8000622e <kexec+0x16e>
    800061c8:	21313c23          	sd	s3,536(sp)
    800061cc:	21513423          	sd	s5,520(sp)
    800061d0:	21613023          	sd	s6,512(sp)
    800061d4:	ffde                	sd	s7,504(sp)
    800061d6:	fbe2                	sd	s8,496(sp)
    800061d8:	f7e6                	sd	s9,488(sp)
    800061da:	f3ea                	sd	s10,480(sp)
  printf("[pid %d] EXEC starting segment processing\n", p->pid);
    800061dc:	030a2583          	lw	a1,48(s4)
    800061e0:	00004517          	auipc	a0,0x4
    800061e4:	cb050513          	addi	a0,a0,-848 # 80009e90 <etext+0xe90>
    800061e8:	b12fa0ef          	jal	800004fa <printf>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800061ec:	e8845783          	lhu	a5,-376(s0)
    800061f0:	28078a63          	beqz	a5,80006484 <kexec+0x3c4>
    800061f4:	efee                	sd	s11,472(sp)
    800061f6:	e7042683          	lw	a3,-400(s0)
  uint64 text_start = 0, text_end = 0, data_start = 0, data_end = 0;
    800061fa:	dc043023          	sd	zero,-576(s0)
    800061fe:	dc043423          	sd	zero,-568(s0)
    80006202:	dc043823          	sd	zero,-560(s0)
    80006206:	dc043c23          	sd	zero,-552(s0)
  int text_seg_found = 0, data_seg_found = 0;
    8000620a:	de043823          	sd	zero,-528(s0)
    8000620e:	de043c23          	sd	zero,-520(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80006212:	4d01                	li	s10,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80006214:	4981                	li	s3,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80006216:	e1840d93          	addi	s11,s0,-488
    8000621a:	03800b13          	li	s6,56
    if(ph.type != ELF_PROG_LOAD)
    8000621e:	4c85                	li	s9,1
    if(ph.vaddr % PGSIZE != 0)
    80006220:	6785                	lui	a5,0x1
    80006222:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80006224:	e0f43423          	sd	a5,-504(s0)
        p->data_seg.va_start = ph.vaddr;
    80006228:	6c2d                	lui	s8,0xb
    8000622a:	9c52                	add	s8,s8,s4
    8000622c:	a899                	j	80006282 <kexec+0x1c2>
    printf("[pid %d] EXEC failed: cannot create page table\n", p->pid);
    8000622e:	030a2583          	lw	a1,48(s4)
    80006232:	00004517          	auipc	a0,0x4
    80006236:	c2e50513          	addi	a0,a0,-978 # 80009e60 <etext+0xe60>
    8000623a:	ac0fa0ef          	jal	800004fa <printf>
    goto bad;
    8000623e:	bf29                	j	80006158 <kexec+0x98>
      if(!data_seg_found) {
    80006240:	df043703          	ld	a4,-528(s0)
    80006244:	e70d                	bnez	a4,8000626e <kexec+0x1ae>
        p->data_seg.va_start = ph.vaddr;
    80006246:	c95c3023          	sd	s5,-896(s8) # ac80 <_entry-0x7fff5380>
        p->data_seg.va_end = ph.vaddr + ph.memsz;
    8000624a:	c89c3423          	sd	s1,-888(s8)
        p->data_seg.file_offset = ph.off;
    8000624e:	e2043703          	ld	a4,-480(s0)
    80006252:	c8ec3823          	sd	a4,-880(s8)
        p->data_seg.file_size = ph.filesz;
    80006256:	c8fc3c23          	sd	a5,-872(s8)
        p->data_seg.perm = flags2perm(ph.flags);
    8000625a:	e47ff0ef          	jal	800060a0 <flags2perm>
    8000625e:	caac2023          	sw	a0,-864(s8)
        data_end = ph.vaddr + ph.memsz;
    80006262:	dc943023          	sd	s1,-576(s0)
        data_start = ph.vaddr;
    80006266:	dd543423          	sd	s5,-568(s0)
        data_seg_found = 1;
    8000626a:	df943823          	sd	s9,-528(s0)
    if(ph.vaddr + ph.memsz > sz)
    8000626e:	009d7363          	bgeu	s10,s1,80006274 <kexec+0x1b4>
    80006272:	8d26                	mv	s10,s1
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80006274:	2985                	addiw	s3,s3,1
    80006276:	038b869b          	addiw	a3,s7,56
    8000627a:	e8845783          	lhu	a5,-376(s0)
    8000627e:	06f9dd63          	bge	s3,a5,800062f8 <kexec+0x238>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80006282:	8bb6                	mv	s7,a3
    80006284:	875a                	mv	a4,s6
    80006286:	866e                	mv	a2,s11
    80006288:	4581                	li	a1,0
    8000628a:	854a                	mv	a0,s2
    8000628c:	d4bfe0ef          	jal	80004fd6 <readi>
    80006290:	35651863          	bne	a0,s6,800065e0 <kexec+0x520>
    if(ph.type != ELF_PROG_LOAD)
    80006294:	e1842783          	lw	a5,-488(s0)
    80006298:	fd979ee3          	bne	a5,s9,80006274 <kexec+0x1b4>
    if(ph.memsz < ph.filesz)
    8000629c:	e4043483          	ld	s1,-448(s0)
    800062a0:	e3843783          	ld	a5,-456(s0)
    800062a4:	36f4ec63          	bltu	s1,a5,8000661c <kexec+0x55c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800062a8:	e2843a83          	ld	s5,-472(s0)
    800062ac:	94d6                	add	s1,s1,s5
    800062ae:	3754e963          	bltu	s1,s5,80006620 <kexec+0x560>
    if(ph.vaddr % PGSIZE != 0)
    800062b2:	e0843703          	ld	a4,-504(s0)
    800062b6:	00eaf733          	and	a4,s5,a4
    800062ba:	36071563          	bnez	a4,80006624 <kexec+0x564>
    if(ph.flags & ELF_PROG_FLAG_EXEC) {
    800062be:	e1c42503          	lw	a0,-484(s0)
    800062c2:	00157713          	andi	a4,a0,1
    800062c6:	df2d                	beqz	a4,80006240 <kexec+0x180>
      if(!text_seg_found) {
    800062c8:	df843703          	ld	a4,-520(s0)
    800062cc:	f34d                	bnez	a4,8000626e <kexec+0x1ae>
        p->text_seg.va_start = ph.vaddr;
    800062ce:	c55c3c23          	sd	s5,-936(s8)
        p->text_seg.va_end = ph.vaddr + ph.memsz;
    800062d2:	c69c3023          	sd	s1,-928(s8)
        p->text_seg.file_offset = ph.off;
    800062d6:	e2043703          	ld	a4,-480(s0)
    800062da:	c6ec3423          	sd	a4,-920(s8)
        p->text_seg.file_size = ph.filesz;
    800062de:	c6fc3823          	sd	a5,-912(s8)
        p->text_seg.perm = flags2perm(ph.flags);
    800062e2:	dbfff0ef          	jal	800060a0 <flags2perm>
    800062e6:	c6ac2c23          	sw	a0,-904(s8)
        text_end = ph.vaddr + ph.memsz;
    800062ea:	dc943823          	sd	s1,-560(s0)
        text_start = ph.vaddr;
    800062ee:	dd543c23          	sd	s5,-552(s0)
        text_seg_found = 1;
    800062f2:	df943c23          	sd	s9,-520(s0)
    800062f6:	bfa5                	j	8000626e <kexec+0x1ae>
    800062f8:	6dfe                	ld	s11,472(sp)
  p->exec_inode = ip;
    800062fa:	67ad                	lui	a5,0xb
    800062fc:	97d2                	add	a5,a5,s4
    800062fe:	c527b823          	sd	s2,-944(a5) # ac50 <_entry-0x7fff53b0>
  idup(ip); // Increment reference count
    80006302:	854a                	mv	a0,s2
    80006304:	90bfe0ef          	jal	80004c0e <idup>
  iunlockput(ip);
    80006308:	854a                	mv	a0,s2
    8000630a:	b47fe0ef          	jal	80004e50 <iunlockput>
  end_op();
    8000630e:	bb2ff0ef          	jal	800056c0 <end_op>
  p = myproc();
    80006312:	b33fc0ef          	jal	80002e44 <myproc>
    80006316:	8a2a                	mv	s4,a0
  uint64 oldsz = p->sz;
    80006318:	04853c83          	ld	s9,72(a0)
  clear_resident_pages();
    8000631c:	b56fb0ef          	jal	80001672 <clear_resident_pages>
  sz = PGROUNDUP(sz);
    80006320:	6605                	lui	a2,0x1
    80006322:	fff60793          	addi	a5,a2,-1 # fff <_entry-0x7ffff001>
    80006326:	9d3e                	add	s10,s10,a5
    80006328:	777d                	lui	a4,0xfffff
    8000632a:	00ed7d33          	and	s10,s10,a4
  p->text_start = text_start;
    8000632e:	dd843683          	ld	a3,-552(s0)
    80006332:	16da3423          	sd	a3,360(s4)
  p->text_end = text_end;
    80006336:	dd043683          	ld	a3,-560(s0)
    8000633a:	16da3823          	sd	a3,368(s4)
  p->data_start = data_start;  
    8000633e:	dc843683          	ld	a3,-568(s0)
    80006342:	16da3c23          	sd	a3,376(s4)
  p->data_end = data_end;
    80006346:	dc043683          	ld	a3,-576(s0)
    8000634a:	18da3023          	sd	a3,384(s4)
  p->heap_start = PGROUNDUP(data_end); // Heap starts after data segment
    8000634e:	97b6                	add	a5,a5,a3
    80006350:	8ff9                	and	a5,a5,a4
    80006352:	18fa3423          	sd	a5,392(s4)
  if((sz1 = uvmalloc(pagetable, sz, sz + PGSIZE, PTE_W)) == 0) {
    80006356:	4691                	li	a3,4
    80006358:	966a                	add	a2,a2,s10
    8000635a:	85ea                	mv	a1,s10
    8000635c:	de843503          	ld	a0,-536(s0)
    80006360:	858fb0ef          	jal	800013b8 <uvmalloc>
    80006364:	8b2a                	mv	s6,a0
    80006366:	12050963          	beqz	a0,80006498 <kexec+0x3d8>
  printf("[pid %d] EXEC stack allocated successfully\n", p->pid);
    8000636a:	030a2583          	lw	a1,48(s4)
    8000636e:	00004517          	auipc	a0,0x4
    80006372:	b8a50513          	addi	a0,a0,-1142 # 80009ef8 <etext+0xef8>
    80006376:	984fa0ef          	jal	800004fa <printf>
  p->stack_top = stack_bottom + (USERSTACK+1)*PGSIZE; // Full stack top for validation
    8000637a:	6d09                	lui	s10,0x2
    8000637c:	9d5a                	add	s10,s10,s6
    8000637e:	19aa3823          	sd	s10,400(s4)
  p->sz = stack_bottom; // p->sz should be end of heap, start of stack
    80006382:	056a3423          	sd	s6,72(s4)
  p->trapframe->sp = sp;
    80006386:	058a3783          	ld	a5,88(s4)
    8000638a:	03a7b823          	sd	s10,48(a5)
  p->next_fifo_seq = 1;
    8000638e:	4785                	li	a5,1
    80006390:	18fa2c23          	sw	a5,408(s4)
  p->num_resident_pages = 0;
    80006394:	6785                	lui	a5,0x1
    80006396:	97d2                	add	a5,a5,s4
    80006398:	ba07a023          	sw	zero,-1120(a5) # ba0 <_entry-0x7ffff460>
  p->num_swapped_pages = 0;
    8000639c:	672d                	lui	a4,0xb
    8000639e:	9752                	add	a4,a4,s4
    800063a0:	c4072423          	sw	zero,-952(a4) # ac48 <_entry-0x7fff53b8>
  p->swap_slots_used = 0;
    800063a4:	bc07a023          	sw	zero,-1088(a5)
  p->swapfile = 0;
    800063a8:	ba07b423          	sd	zero,-1112(a5)
  for(int j = 0; j < SWAP_BITMAP_SIZE; j++) {
    800063ac:	7ffa0793          	addi	a5,s4,2047
    800063b0:	3c978793          	addi	a5,a5,969
    800063b4:	7ffa0713          	addi	a4,s4,2047
    800063b8:	44970713          	addi	a4,a4,1097
    p->swap_bitmap[j] = 0;
    800063bc:	0007b023          	sd	zero,0(a5)
  for(int j = 0; j < SWAP_BITMAP_SIZE; j++) {
    800063c0:	07a1                	addi	a5,a5,8
    800063c2:	fee79de3          	bne	a5,a4,800063bc <kexec+0x2fc>
  if(create_swap_file() != 0) {
    800063c6:	c24fb0ef          	jal	800017ea <create_swap_file>
    800063ca:	0e051963          	bnez	a0,800064bc <kexec+0x3fc>
  stackbase = sp - USERSTACK*PGSIZE;
    800063ce:	6785                	lui	a5,0x1
    800063d0:	9b3e                	add	s6,s6,a5
  printf("[pid %d] INIT-LAZYMAP text=[0x%lx,0x%lx) data=[0x%lx,0x%lx) heap_start=0x%lx stack_top=0x%lx\n",
    800063d2:	190a3883          	ld	a7,400(s4)
    800063d6:	188a3803          	ld	a6,392(s4)
    800063da:	180a3783          	ld	a5,384(s4)
    800063de:	178a3703          	ld	a4,376(s4)
    800063e2:	170a3683          	ld	a3,368(s4)
    800063e6:	168a3603          	ld	a2,360(s4)
    800063ea:	030a2583          	lw	a1,48(s4)
    800063ee:	00004517          	auipc	a0,0x4
    800063f2:	b6a50513          	addi	a0,a0,-1174 # 80009f58 <etext+0xf58>
    800063f6:	904fa0ef          	jal	800004fa <printf>
  for(argc = 0; argv[argc]; argc++) {
    800063fa:	e0043783          	ld	a5,-512(s0)
    800063fe:	6388                	ld	a0,0(a5)
    80006400:	0e050163          	beqz	a0,800064e2 <kexec+0x422>
    80006404:	e9040993          	addi	s3,s0,-368
    80006408:	f9040c13          	addi	s8,s0,-112
  sp = p->stack_top;
    8000640c:	896a                	mv	s2,s10
  for(argc = 0; argv[argc]; argc++) {
    8000640e:	4481                	li	s1,0
    printf("[pid %d] EXEC copying arg %ld: '%s' to sp=0x%lx\n", p->pid, argc, argv[argc], sp);
    80006410:	00004b97          	auipc	s7,0x4
    80006414:	ba8b8b93          	addi	s7,s7,-1112 # 80009fb8 <etext+0xfb8>
    sp -= strlen(argv[argc]) + 1;
    80006418:	a6ffa0ef          	jal	80000e86 <strlen>
    8000641c:	2505                	addiw	a0,a0,1
    8000641e:	40a90533          	sub	a0,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80006422:	ff057913          	andi	s2,a0,-16
    p->trapframe->sp = sp;
    80006426:	058a3783          	ld	a5,88(s4)
    8000642a:	0327b823          	sd	s2,48(a5) # 1030 <_entry-0x7fffefd0>
    if(sp < stackbase)
    8000642e:	1b696763          	bltu	s2,s6,800065dc <kexec+0x51c>
    printf("[pid %d] EXEC copying arg %ld: '%s' to sp=0x%lx\n", p->pid, argc, argv[argc], sp);
    80006432:	874a                	mv	a4,s2
    80006434:	e0043a83          	ld	s5,-512(s0)
    80006438:	000ab683          	ld	a3,0(s5)
    8000643c:	8626                	mv	a2,s1
    8000643e:	030a2583          	lw	a1,48(s4)
    80006442:	855e                	mv	a0,s7
    80006444:	8b6fa0ef          	jal	800004fa <printf>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0) {
    80006448:	000aba83          	ld	s5,0(s5)
    8000644c:	8556                	mv	a0,s5
    8000644e:	a39fa0ef          	jal	80000e86 <strlen>
    80006452:	0015069b          	addiw	a3,a0,1
    80006456:	8656                	mv	a2,s5
    80006458:	85ca                	mv	a1,s2
    8000645a:	de843503          	ld	a0,-536(s0)
    8000645e:	c22fc0ef          	jal	80002880 <copyout>
    80006462:	06054663          	bltz	a0,800064ce <kexec+0x40e>
    ustack[argc] = sp;
    80006466:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000646a:	0485                	addi	s1,s1,1
    8000646c:	e0043783          	ld	a5,-512(s0)
    80006470:	07a1                	addi	a5,a5,8
    80006472:	e0f43023          	sd	a5,-512(s0)
    80006476:	6388                	ld	a0,0(a5)
    80006478:	c53d                	beqz	a0,800064e6 <kexec+0x426>
    if(argc >= MAXARG)
    8000647a:	09a1                	addi	s3,s3,8
    8000647c:	f9899ee3          	bne	s3,s8,80006418 <kexec+0x358>
  ip = 0;
    80006480:	4901                	li	s2,0
    80006482:	a285                	j	800065e2 <kexec+0x522>
  uint64 text_start = 0, text_end = 0, data_start = 0, data_end = 0;
    80006484:	dc043023          	sd	zero,-576(s0)
    80006488:	dc043423          	sd	zero,-568(s0)
    8000648c:	dc043823          	sd	zero,-560(s0)
    80006490:	dc043c23          	sd	zero,-552(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80006494:	4d01                	li	s10,0
    80006496:	b595                	j	800062fa <kexec+0x23a>
    printf("[pid %d] EXEC failed: cannot allocate stack page\n", p->pid);
    80006498:	030a2583          	lw	a1,48(s4)
    8000649c:	00004517          	auipc	a0,0x4
    800064a0:	a2450513          	addi	a0,a0,-1500 # 80009ec0 <etext+0xec0>
    800064a4:	856fa0ef          	jal	800004fa <printf>
  printf("[pid %d] EXEC failed: going to bad label\n", p->pid);
    800064a8:	030a2583          	lw	a1,48(s4)
    800064ac:	00004517          	auipc	a0,0x4
    800064b0:	c2450513          	addi	a0,a0,-988 # 8000a0d0 <etext+0x10d0>
    800064b4:	846fa0ef          	jal	800004fa <printf>
    800064b8:	4901                	li	s2,0
    800064ba:	aa25                	j	800065f2 <kexec+0x532>
    printf("[pid %d] EXEC failed: cannot create swap file\n", p->pid);
    800064bc:	030a2583          	lw	a1,48(s4)
    800064c0:	00004517          	auipc	a0,0x4
    800064c4:	a6850513          	addi	a0,a0,-1432 # 80009f28 <etext+0xf28>
    800064c8:	832fa0ef          	jal	800004fa <printf>
    goto bad;
    800064cc:	bff1                	j	800064a8 <kexec+0x3e8>
      printf("[pid %d] EXEC failed: copyout failed for arg %ld\n", p->pid, argc);
    800064ce:	8626                	mv	a2,s1
    800064d0:	030a2583          	lw	a1,48(s4)
    800064d4:	00004517          	auipc	a0,0x4
    800064d8:	b1c50513          	addi	a0,a0,-1252 # 80009ff0 <etext+0xff0>
    800064dc:	81efa0ef          	jal	800004fa <printf>
      goto bad;
    800064e0:	b7e1                	j	800064a8 <kexec+0x3e8>
  sp = p->stack_top;
    800064e2:	896a                	mv	s2,s10
  for(argc = 0; argv[argc]; argc++) {
    800064e4:	4481                	li	s1,0
  ustack[argc] = 0;
    800064e6:	00349793          	slli	a5,s1,0x3
    800064ea:	f9078793          	addi	a5,a5,-112
    800064ee:	97a2                	add	a5,a5,s0
    800064f0:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800064f4:	00349993          	slli	s3,s1,0x3
    800064f8:	09a1                	addi	s3,s3,8
    800064fa:	41390933          	sub	s2,s2,s3
  sp -= sp % 16;
    800064fe:	ff097913          	andi	s2,s2,-16
  p->trapframe->sp = sp;
    80006502:	058a3783          	ld	a5,88(s4)
    80006506:	0327b823          	sd	s2,48(a5)
  if(sp < stackbase)
    8000650a:	f9696fe3          	bltu	s2,s6,800064a8 <kexec+0x3e8>
  printf("[pid %d] EXEC copying ustack to sp=0x%lx\n", p->pid, sp);
    8000650e:	864a                	mv	a2,s2
    80006510:	030a2583          	lw	a1,48(s4)
    80006514:	00004517          	auipc	a0,0x4
    80006518:	b1450513          	addi	a0,a0,-1260 # 8000a028 <etext+0x1028>
    8000651c:	fdff90ef          	jal	800004fa <printf>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0) {
    80006520:	86ce                	mv	a3,s3
    80006522:	e9040613          	addi	a2,s0,-368
    80006526:	85ca                	mv	a1,s2
    80006528:	de843503          	ld	a0,-536(s0)
    8000652c:	b54fc0ef          	jal	80002880 <copyout>
    80006530:	00054f63          	bltz	a0,8000654e <kexec+0x48e>
  p->trapframe->a1 = sp;
    80006534:	058a3783          	ld	a5,88(s4)
    80006538:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000653c:	de043783          	ld	a5,-544(s0)
    80006540:	0007c703          	lbu	a4,0(a5)
    80006544:	c71d                	beqz	a4,80006572 <kexec+0x4b2>
    80006546:	0785                	addi	a5,a5,1
    if(*s == '/')
    80006548:	02f00693          	li	a3,47
    8000654c:	a005                	j	8000656c <kexec+0x4ac>
    printf("[pid %d] EXEC failed: copyout failed for ustack\n", p->pid);
    8000654e:	030a2583          	lw	a1,48(s4)
    80006552:	00004517          	auipc	a0,0x4
    80006556:	b0650513          	addi	a0,a0,-1274 # 8000a058 <etext+0x1058>
    8000655a:	fa1f90ef          	jal	800004fa <printf>
    goto bad;
    8000655e:	b7a9                	j	800064a8 <kexec+0x3e8>
      last = s+1;
    80006560:	def43023          	sd	a5,-544(s0)
  for(last=s=path; *s; s++)
    80006564:	0785                	addi	a5,a5,1
    80006566:	fff7c703          	lbu	a4,-1(a5)
    8000656a:	c701                	beqz	a4,80006572 <kexec+0x4b2>
    if(*s == '/')
    8000656c:	fed71ce3          	bne	a4,a3,80006564 <kexec+0x4a4>
    80006570:	bfc5                	j	80006560 <kexec+0x4a0>
  safestrcpy(p->name, last, sizeof(p->name));
    80006572:	4641                	li	a2,16
    80006574:	de043583          	ld	a1,-544(s0)
    80006578:	158a0513          	addi	a0,s4,344
    8000657c:	8d5fa0ef          	jal	80000e50 <safestrcpy>
  oldpagetable = p->pagetable;
    80006580:	050a3503          	ld	a0,80(s4)
  p->pagetable = pagetable;
    80006584:	de843783          	ld	a5,-536(s0)
    80006588:	04fa3823          	sd	a5,80(s4)
  p->sz = sz;
    8000658c:	05aa3423          	sd	s10,72(s4)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80006590:	058a3783          	ld	a5,88(s4)
    80006594:	e6843703          	ld	a4,-408(s0)
    80006598:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000659a:	058a3783          	ld	a5,88(s4)
    8000659e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800065a2:	85e6                	mv	a1,s9
    800065a4:	a2ffc0ef          	jal	80002fd2 <proc_freepagetable>
  printf("[pid %d] EXEC completed successfully, entry=0x%lx sp=0x%lx\n", p->pid, elf.entry, sp);
    800065a8:	86ca                	mv	a3,s2
    800065aa:	e6843603          	ld	a2,-408(s0)
    800065ae:	030a2583          	lw	a1,48(s4)
    800065b2:	00004517          	auipc	a0,0x4
    800065b6:	ade50513          	addi	a0,a0,-1314 # 8000a090 <etext+0x1090>
    800065ba:	f41f90ef          	jal	800004fa <printf>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800065be:	0004851b          	sext.w	a0,s1
    800065c2:	22013903          	ld	s2,544(sp)
    800065c6:	21813983          	ld	s3,536(sp)
    800065ca:	20813a83          	ld	s5,520(sp)
    800065ce:	20013b03          	ld	s6,512(sp)
    800065d2:	7bfe                	ld	s7,504(sp)
    800065d4:	7c5e                	ld	s8,496(sp)
    800065d6:	7cbe                	ld	s9,488(sp)
    800065d8:	7d1e                	ld	s10,480(sp)
    800065da:	be79                	j	80006178 <kexec+0xb8>
  ip = 0;
    800065dc:	4901                	li	s2,0
    800065de:	a011                	j	800065e2 <kexec+0x522>
    800065e0:	6dfe                	ld	s11,472(sp)
  printf("[pid %d] EXEC failed: going to bad label\n", p->pid);
    800065e2:	030a2583          	lw	a1,48(s4)
    800065e6:	00004517          	auipc	a0,0x4
    800065ea:	aea50513          	addi	a0,a0,-1302 # 8000a0d0 <etext+0x10d0>
    800065ee:	f0df90ef          	jal	800004fa <printf>
    proc_freepagetable(pagetable, sz);
    800065f2:	85ea                	mv	a1,s10
    800065f4:	de843503          	ld	a0,-536(s0)
    800065f8:	9dbfc0ef          	jal	80002fd2 <proc_freepagetable>
  return -1;
    800065fc:	557d                	li	a0,-1
  if(ip){
    800065fe:	02091563          	bnez	s2,80006628 <kexec+0x568>
    80006602:	22013903          	ld	s2,544(sp)
    80006606:	21813983          	ld	s3,536(sp)
    8000660a:	20813a83          	ld	s5,520(sp)
    8000660e:	20013b03          	ld	s6,512(sp)
    80006612:	7bfe                	ld	s7,504(sp)
    80006614:	7c5e                	ld	s8,496(sp)
    80006616:	7cbe                	ld	s9,488(sp)
    80006618:	7d1e                	ld	s10,480(sp)
    8000661a:	beb9                	j	80006178 <kexec+0xb8>
    8000661c:	6dfe                	ld	s11,472(sp)
    8000661e:	b7d1                	j	800065e2 <kexec+0x522>
    80006620:	6dfe                	ld	s11,472(sp)
    80006622:	b7c1                	j	800065e2 <kexec+0x522>
    80006624:	6dfe                	ld	s11,472(sp)
    80006626:	bf75                	j	800065e2 <kexec+0x522>
    80006628:	21813983          	ld	s3,536(sp)
    8000662c:	20813a83          	ld	s5,520(sp)
    80006630:	20013b03          	ld	s6,512(sp)
    80006634:	7bfe                	ld	s7,504(sp)
    80006636:	7c5e                	ld	s8,496(sp)
    80006638:	7cbe                	ld	s9,488(sp)
    8000663a:	7d1e                	ld	s10,480(sp)
    8000663c:	b635                	j	80006168 <kexec+0xa8>

000000008000663e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000663e:	7179                	addi	sp,sp,-48
    80006640:	f406                	sd	ra,40(sp)
    80006642:	f022                	sd	s0,32(sp)
    80006644:	ec26                	sd	s1,24(sp)
    80006646:	e84a                	sd	s2,16(sp)
    80006648:	1800                	addi	s0,sp,48
    8000664a:	892e                	mv	s2,a1
    8000664c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000664e:	fdc40593          	addi	a1,s0,-36
    80006652:	983fd0ef          	jal	80003fd4 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80006656:	fdc42703          	lw	a4,-36(s0)
    8000665a:	47bd                	li	a5,15
    8000665c:	02e7ea63          	bltu	a5,a4,80006690 <argfd+0x52>
    80006660:	fe4fc0ef          	jal	80002e44 <myproc>
    80006664:	fdc42703          	lw	a4,-36(s0)
    80006668:	00371793          	slli	a5,a4,0x3
    8000666c:	0d078793          	addi	a5,a5,208
    80006670:	953e                	add	a0,a0,a5
    80006672:	611c                	ld	a5,0(a0)
    80006674:	c385                	beqz	a5,80006694 <argfd+0x56>
    return -1;
  if(pfd)
    80006676:	00090463          	beqz	s2,8000667e <argfd+0x40>
    *pfd = fd;
    8000667a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000667e:	4501                	li	a0,0
  if(pf)
    80006680:	c091                	beqz	s1,80006684 <argfd+0x46>
    *pf = f;
    80006682:	e09c                	sd	a5,0(s1)
}
    80006684:	70a2                	ld	ra,40(sp)
    80006686:	7402                	ld	s0,32(sp)
    80006688:	64e2                	ld	s1,24(sp)
    8000668a:	6942                	ld	s2,16(sp)
    8000668c:	6145                	addi	sp,sp,48
    8000668e:	8082                	ret
    return -1;
    80006690:	557d                	li	a0,-1
    80006692:	bfcd                	j	80006684 <argfd+0x46>
    80006694:	557d                	li	a0,-1
    80006696:	b7fd                	j	80006684 <argfd+0x46>

0000000080006698 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80006698:	1101                	addi	sp,sp,-32
    8000669a:	ec06                	sd	ra,24(sp)
    8000669c:	e822                	sd	s0,16(sp)
    8000669e:	e426                	sd	s1,8(sp)
    800066a0:	1000                	addi	s0,sp,32
    800066a2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800066a4:	fa0fc0ef          	jal	80002e44 <myproc>
    800066a8:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800066aa:	0d050793          	addi	a5,a0,208
    800066ae:	4501                	li	a0,0
    800066b0:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800066b2:	6398                	ld	a4,0(a5)
    800066b4:	cb19                	beqz	a4,800066ca <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800066b6:	2505                	addiw	a0,a0,1
    800066b8:	07a1                	addi	a5,a5,8
    800066ba:	fed51ce3          	bne	a0,a3,800066b2 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800066be:	557d                	li	a0,-1
}
    800066c0:	60e2                	ld	ra,24(sp)
    800066c2:	6442                	ld	s0,16(sp)
    800066c4:	64a2                	ld	s1,8(sp)
    800066c6:	6105                	addi	sp,sp,32
    800066c8:	8082                	ret
      p->ofile[fd] = f;
    800066ca:	00351793          	slli	a5,a0,0x3
    800066ce:	0d078793          	addi	a5,a5,208
    800066d2:	963e                	add	a2,a2,a5
    800066d4:	e204                	sd	s1,0(a2)
      return fd;
    800066d6:	b7ed                	j	800066c0 <fdalloc+0x28>

00000000800066d8 <sys_dup>:

uint64
sys_dup(void)
{
    800066d8:	7179                	addi	sp,sp,-48
    800066da:	f406                	sd	ra,40(sp)
    800066dc:	f022                	sd	s0,32(sp)
    800066de:	1800                	addi	s0,sp,48
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
    800066e0:	fd840613          	addi	a2,s0,-40
    800066e4:	4581                	li	a1,0
    800066e6:	4501                	li	a0,0
    800066e8:	f57ff0ef          	jal	8000663e <argfd>
    return -1;
    800066ec:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800066ee:	02054363          	bltz	a0,80006714 <sys_dup+0x3c>
    800066f2:	ec26                	sd	s1,24(sp)
    800066f4:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800066f6:	fd843483          	ld	s1,-40(s0)
    800066fa:	8526                	mv	a0,s1
    800066fc:	f9dff0ef          	jal	80006698 <fdalloc>
    80006700:	892a                	mv	s2,a0
    return -1;
    80006702:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80006704:	00054d63          	bltz	a0,8000671e <sys_dup+0x46>
  filedup(f);
    80006708:	8526                	mv	a0,s1
    8000670a:	b24ff0ef          	jal	80005a2e <filedup>
  return fd;
    8000670e:	87ca                	mv	a5,s2
    80006710:	64e2                	ld	s1,24(sp)
    80006712:	6942                	ld	s2,16(sp)
}
    80006714:	853e                	mv	a0,a5
    80006716:	70a2                	ld	ra,40(sp)
    80006718:	7402                	ld	s0,32(sp)
    8000671a:	6145                	addi	sp,sp,48
    8000671c:	8082                	ret
    8000671e:	64e2                	ld	s1,24(sp)
    80006720:	6942                	ld	s2,16(sp)
    80006722:	bfcd                	j	80006714 <sys_dup+0x3c>

0000000080006724 <sys_read>:

uint64
sys_read(void)
{
    80006724:	7179                	addi	sp,sp,-48
    80006726:	f406                	sd	ra,40(sp)
    80006728:	f022                	sd	s0,32(sp)
    8000672a:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  argaddr(1, &p);
    8000672c:	fd840593          	addi	a1,s0,-40
    80006730:	4505                	li	a0,1
    80006732:	8bffd0ef          	jal	80003ff0 <argaddr>
  argint(2, &n);
    80006736:	fe440593          	addi	a1,s0,-28
    8000673a:	4509                	li	a0,2
    8000673c:	899fd0ef          	jal	80003fd4 <argint>
  if(argfd(0, 0, &f) < 0)
    80006740:	fe840613          	addi	a2,s0,-24
    80006744:	4581                	li	a1,0
    80006746:	4501                	li	a0,0
    80006748:	ef7ff0ef          	jal	8000663e <argfd>
    8000674c:	87aa                	mv	a5,a0
    return -1;
    8000674e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80006750:	0007ca63          	bltz	a5,80006764 <sys_read+0x40>
  return fileread(f, p, n);
    80006754:	fe442603          	lw	a2,-28(s0)
    80006758:	fd843583          	ld	a1,-40(s0)
    8000675c:	fe843503          	ld	a0,-24(s0)
    80006760:	c38ff0ef          	jal	80005b98 <fileread>
}
    80006764:	70a2                	ld	ra,40(sp)
    80006766:	7402                	ld	s0,32(sp)
    80006768:	6145                	addi	sp,sp,48
    8000676a:	8082                	ret

000000008000676c <sys_write>:

uint64
sys_write(void)
{
    8000676c:	7179                	addi	sp,sp,-48
    8000676e:	f406                	sd	ra,40(sp)
    80006770:	f022                	sd	s0,32(sp)
    80006772:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;
  
  argaddr(1, &p);
    80006774:	fd840593          	addi	a1,s0,-40
    80006778:	4505                	li	a0,1
    8000677a:	877fd0ef          	jal	80003ff0 <argaddr>
  argint(2, &n);
    8000677e:	fe440593          	addi	a1,s0,-28
    80006782:	4509                	li	a0,2
    80006784:	851fd0ef          	jal	80003fd4 <argint>
  if(argfd(0, 0, &f) < 0)
    80006788:	fe840613          	addi	a2,s0,-24
    8000678c:	4581                	li	a1,0
    8000678e:	4501                	li	a0,0
    80006790:	eafff0ef          	jal	8000663e <argfd>
    80006794:	87aa                	mv	a5,a0
    return -1;
    80006796:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80006798:	0007ca63          	bltz	a5,800067ac <sys_write+0x40>

  return filewrite(f, p, n);
    8000679c:	fe442603          	lw	a2,-28(s0)
    800067a0:	fd843583          	ld	a1,-40(s0)
    800067a4:	fe843503          	ld	a0,-24(s0)
    800067a8:	cb4ff0ef          	jal	80005c5c <filewrite>
}
    800067ac:	70a2                	ld	ra,40(sp)
    800067ae:	7402                	ld	s0,32(sp)
    800067b0:	6145                	addi	sp,sp,48
    800067b2:	8082                	ret

00000000800067b4 <sys_close>:

uint64
sys_close(void)
{
    800067b4:	1101                	addi	sp,sp,-32
    800067b6:	ec06                	sd	ra,24(sp)
    800067b8:	e822                	sd	s0,16(sp)
    800067ba:	1000                	addi	s0,sp,32
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
    800067bc:	fe040613          	addi	a2,s0,-32
    800067c0:	fec40593          	addi	a1,s0,-20
    800067c4:	4501                	li	a0,0
    800067c6:	e79ff0ef          	jal	8000663e <argfd>
    return -1;
    800067ca:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800067cc:	02054163          	bltz	a0,800067ee <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    800067d0:	e74fc0ef          	jal	80002e44 <myproc>
    800067d4:	fec42783          	lw	a5,-20(s0)
    800067d8:	078e                	slli	a5,a5,0x3
    800067da:	0d078793          	addi	a5,a5,208
    800067de:	953e                	add	a0,a0,a5
    800067e0:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800067e4:	fe043503          	ld	a0,-32(s0)
    800067e8:	a8cff0ef          	jal	80005a74 <fileclose>
  return 0;
    800067ec:	4781                	li	a5,0
}
    800067ee:	853e                	mv	a0,a5
    800067f0:	60e2                	ld	ra,24(sp)
    800067f2:	6442                	ld	s0,16(sp)
    800067f4:	6105                	addi	sp,sp,32
    800067f6:	8082                	ret

00000000800067f8 <sys_fstat>:

uint64
sys_fstat(void)
{
    800067f8:	1101                	addi	sp,sp,-32
    800067fa:	ec06                	sd	ra,24(sp)
    800067fc:	e822                	sd	s0,16(sp)
    800067fe:	1000                	addi	s0,sp,32
  struct file *f;
  uint64 st; // user pointer to struct stat

  argaddr(1, &st);
    80006800:	fe040593          	addi	a1,s0,-32
    80006804:	4505                	li	a0,1
    80006806:	feafd0ef          	jal	80003ff0 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000680a:	fe840613          	addi	a2,s0,-24
    8000680e:	4581                	li	a1,0
    80006810:	4501                	li	a0,0
    80006812:	e2dff0ef          	jal	8000663e <argfd>
    80006816:	87aa                	mv	a5,a0
    return -1;
    80006818:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000681a:	0007c863          	bltz	a5,8000682a <sys_fstat+0x32>
  return filestat(f, st);
    8000681e:	fe043583          	ld	a1,-32(s0)
    80006822:	fe843503          	ld	a0,-24(s0)
    80006826:	b10ff0ef          	jal	80005b36 <filestat>
}
    8000682a:	60e2                	ld	ra,24(sp)
    8000682c:	6442                	ld	s0,16(sp)
    8000682e:	6105                	addi	sp,sp,32
    80006830:	8082                	ret

0000000080006832 <sys_link>:

// Create the path new as a link to the same inode as old.
uint64
sys_link(void)
{
    80006832:	7169                	addi	sp,sp,-304
    80006834:	f606                	sd	ra,296(sp)
    80006836:	f222                	sd	s0,288(sp)
    80006838:	1a00                	addi	s0,sp,304
  char name[DIRSIZ], new[MAXPATH], old[MAXPATH];
  struct inode *dp, *ip;

  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000683a:	08000613          	li	a2,128
    8000683e:	ed040593          	addi	a1,s0,-304
    80006842:	4501                	li	a0,0
    80006844:	fc8fd0ef          	jal	8000400c <argstr>
    return -1;
    80006848:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000684a:	0c054e63          	bltz	a0,80006926 <sys_link+0xf4>
    8000684e:	08000613          	li	a2,128
    80006852:	f5040593          	addi	a1,s0,-176
    80006856:	4505                	li	a0,1
    80006858:	fb4fd0ef          	jal	8000400c <argstr>
    return -1;
    8000685c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000685e:	0c054463          	bltz	a0,80006926 <sys_link+0xf4>
    80006862:	ee26                	sd	s1,280(sp)

  begin_op();
    80006864:	dedfe0ef          	jal	80005650 <begin_op>
  if((ip = namei(old)) == 0){
    80006868:	ed040513          	addi	a0,s0,-304
    8000686c:	c07fe0ef          	jal	80005472 <namei>
    80006870:	84aa                	mv	s1,a0
    80006872:	c53d                	beqz	a0,800068e0 <sys_link+0xae>
    end_op();
    return -1;
  }

  ilock(ip);
    80006874:	bd0fe0ef          	jal	80004c44 <ilock>
  if(ip->type == T_DIR){
    80006878:	04449703          	lh	a4,68(s1)
    8000687c:	4785                	li	a5,1
    8000687e:	06f70663          	beq	a4,a5,800068ea <sys_link+0xb8>
    80006882:	ea4a                	sd	s2,272(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  ip->nlink++;
    80006884:	04a4d783          	lhu	a5,74(s1)
    80006888:	2785                	addiw	a5,a5,1
    8000688a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000688e:	8526                	mv	a0,s1
    80006890:	b00fe0ef          	jal	80004b90 <iupdate>
  iunlock(ip);
    80006894:	8526                	mv	a0,s1
    80006896:	c5cfe0ef          	jal	80004cf2 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
    8000689a:	fd040593          	addi	a1,s0,-48
    8000689e:	f5040513          	addi	a0,s0,-176
    800068a2:	bebfe0ef          	jal	8000548c <nameiparent>
    800068a6:	892a                	mv	s2,a0
    800068a8:	cd21                	beqz	a0,80006900 <sys_link+0xce>
    goto bad;
  ilock(dp);
    800068aa:	b9afe0ef          	jal	80004c44 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800068ae:	854a                	mv	a0,s2
    800068b0:	00092703          	lw	a4,0(s2)
    800068b4:	409c                	lw	a5,0(s1)
    800068b6:	04f71263          	bne	a4,a5,800068fa <sys_link+0xc8>
    800068ba:	40d0                	lw	a2,4(s1)
    800068bc:	fd040593          	addi	a1,s0,-48
    800068c0:	b09fe0ef          	jal	800053c8 <dirlink>
    800068c4:	02054b63          	bltz	a0,800068fa <sys_link+0xc8>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
    800068c8:	854a                	mv	a0,s2
    800068ca:	d86fe0ef          	jal	80004e50 <iunlockput>
  iput(ip);
    800068ce:	8526                	mv	a0,s1
    800068d0:	cf6fe0ef          	jal	80004dc6 <iput>

  end_op();
    800068d4:	dedfe0ef          	jal	800056c0 <end_op>

  return 0;
    800068d8:	4781                	li	a5,0
    800068da:	64f2                	ld	s1,280(sp)
    800068dc:	6952                	ld	s2,272(sp)
    800068de:	a0a1                	j	80006926 <sys_link+0xf4>
    end_op();
    800068e0:	de1fe0ef          	jal	800056c0 <end_op>
    return -1;
    800068e4:	57fd                	li	a5,-1
    800068e6:	64f2                	ld	s1,280(sp)
    800068e8:	a83d                	j	80006926 <sys_link+0xf4>
    iunlockput(ip);
    800068ea:	8526                	mv	a0,s1
    800068ec:	d64fe0ef          	jal	80004e50 <iunlockput>
    end_op();
    800068f0:	dd1fe0ef          	jal	800056c0 <end_op>
    return -1;
    800068f4:	57fd                	li	a5,-1
    800068f6:	64f2                	ld	s1,280(sp)
    800068f8:	a03d                	j	80006926 <sys_link+0xf4>
    iunlockput(dp);
    800068fa:	854a                	mv	a0,s2
    800068fc:	d54fe0ef          	jal	80004e50 <iunlockput>

bad:
  ilock(ip);
    80006900:	8526                	mv	a0,s1
    80006902:	b42fe0ef          	jal	80004c44 <ilock>
  ip->nlink--;
    80006906:	04a4d783          	lhu	a5,74(s1)
    8000690a:	37fd                	addiw	a5,a5,-1
    8000690c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006910:	8526                	mv	a0,s1
    80006912:	a7efe0ef          	jal	80004b90 <iupdate>
  iunlockput(ip);
    80006916:	8526                	mv	a0,s1
    80006918:	d38fe0ef          	jal	80004e50 <iunlockput>
  end_op();
    8000691c:	da5fe0ef          	jal	800056c0 <end_op>
  return -1;
    80006920:	57fd                	li	a5,-1
    80006922:	64f2                	ld	s1,280(sp)
    80006924:	6952                	ld	s2,272(sp)
}
    80006926:	853e                	mv	a0,a5
    80006928:	70b2                	ld	ra,296(sp)
    8000692a:	7412                	ld	s0,288(sp)
    8000692c:	6155                	addi	sp,sp,304
    8000692e:	8082                	ret

0000000080006930 <sys_unlink>:
  return 1;
}

uint64
sys_unlink(void)
{
    80006930:	7151                	addi	sp,sp,-240
    80006932:	f586                	sd	ra,232(sp)
    80006934:	f1a2                	sd	s0,224(sp)
    80006936:	1980                	addi	s0,sp,240
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], path[MAXPATH];
  uint off;

  if(argstr(0, path, MAXPATH) < 0)
    80006938:	08000613          	li	a2,128
    8000693c:	f3040593          	addi	a1,s0,-208
    80006940:	4501                	li	a0,0
    80006942:	ecafd0ef          	jal	8000400c <argstr>
    80006946:	14054d63          	bltz	a0,80006aa0 <sys_unlink+0x170>
    8000694a:	eda6                	sd	s1,216(sp)
    return -1;

  begin_op();
    8000694c:	d05fe0ef          	jal	80005650 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80006950:	fb040593          	addi	a1,s0,-80
    80006954:	f3040513          	addi	a0,s0,-208
    80006958:	b35fe0ef          	jal	8000548c <nameiparent>
    8000695c:	84aa                	mv	s1,a0
    8000695e:	c955                	beqz	a0,80006a12 <sys_unlink+0xe2>
    end_op();
    return -1;
  }

  ilock(dp);
    80006960:	ae4fe0ef          	jal	80004c44 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80006964:	00003597          	auipc	a1,0x3
    80006968:	79c58593          	addi	a1,a1,1948 # 8000a100 <etext+0x1100>
    8000696c:	fb040513          	addi	a0,s0,-80
    80006970:	859fe0ef          	jal	800051c8 <namecmp>
    80006974:	10050b63          	beqz	a0,80006a8a <sys_unlink+0x15a>
    80006978:	00003597          	auipc	a1,0x3
    8000697c:	79058593          	addi	a1,a1,1936 # 8000a108 <etext+0x1108>
    80006980:	fb040513          	addi	a0,s0,-80
    80006984:	845fe0ef          	jal	800051c8 <namecmp>
    80006988:	10050163          	beqz	a0,80006a8a <sys_unlink+0x15a>
    8000698c:	e9ca                	sd	s2,208(sp)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    8000698e:	f2c40613          	addi	a2,s0,-212
    80006992:	fb040593          	addi	a1,s0,-80
    80006996:	8526                	mv	a0,s1
    80006998:	847fe0ef          	jal	800051de <dirlookup>
    8000699c:	892a                	mv	s2,a0
    8000699e:	0e050563          	beqz	a0,80006a88 <sys_unlink+0x158>
    800069a2:	e5ce                	sd	s3,200(sp)
    goto bad;
  ilock(ip);
    800069a4:	aa0fe0ef          	jal	80004c44 <ilock>

  if(ip->nlink < 1)
    800069a8:	04a91783          	lh	a5,74(s2)
    800069ac:	06f05863          	blez	a5,80006a1c <sys_unlink+0xec>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    800069b0:	04491703          	lh	a4,68(s2)
    800069b4:	4785                	li	a5,1
    800069b6:	06f70963          	beq	a4,a5,80006a28 <sys_unlink+0xf8>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    800069ba:	fc040993          	addi	s3,s0,-64
    800069be:	4641                	li	a2,16
    800069c0:	4581                	li	a1,0
    800069c2:	854e                	mv	a0,s3
    800069c4:	b38fa0ef          	jal	80000cfc <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800069c8:	4741                	li	a4,16
    800069ca:	f2c42683          	lw	a3,-212(s0)
    800069ce:	864e                	mv	a2,s3
    800069d0:	4581                	li	a1,0
    800069d2:	8526                	mv	a0,s1
    800069d4:	ef4fe0ef          	jal	800050c8 <writei>
    800069d8:	47c1                	li	a5,16
    800069da:	08f51863          	bne	a0,a5,80006a6a <sys_unlink+0x13a>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    800069de:	04491703          	lh	a4,68(s2)
    800069e2:	4785                	li	a5,1
    800069e4:	08f70963          	beq	a4,a5,80006a76 <sys_unlink+0x146>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    800069e8:	8526                	mv	a0,s1
    800069ea:	c66fe0ef          	jal	80004e50 <iunlockput>

  ip->nlink--;
    800069ee:	04a95783          	lhu	a5,74(s2)
    800069f2:	37fd                	addiw	a5,a5,-1
    800069f4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800069f8:	854a                	mv	a0,s2
    800069fa:	996fe0ef          	jal	80004b90 <iupdate>
  iunlockput(ip);
    800069fe:	854a                	mv	a0,s2
    80006a00:	c50fe0ef          	jal	80004e50 <iunlockput>

  end_op();
    80006a04:	cbdfe0ef          	jal	800056c0 <end_op>

  return 0;
    80006a08:	4501                	li	a0,0
    80006a0a:	64ee                	ld	s1,216(sp)
    80006a0c:	694e                	ld	s2,208(sp)
    80006a0e:	69ae                	ld	s3,200(sp)
    80006a10:	a061                	j	80006a98 <sys_unlink+0x168>
    end_op();
    80006a12:	caffe0ef          	jal	800056c0 <end_op>
    return -1;
    80006a16:	557d                	li	a0,-1
    80006a18:	64ee                	ld	s1,216(sp)
    80006a1a:	a8bd                	j	80006a98 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80006a1c:	00003517          	auipc	a0,0x3
    80006a20:	6f450513          	addi	a0,a0,1780 # 8000a110 <etext+0x1110>
    80006a24:	e01f90ef          	jal	80000824 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006a28:	04c92703          	lw	a4,76(s2)
    80006a2c:	02000793          	li	a5,32
    80006a30:	f8e7f5e3          	bgeu	a5,a4,800069ba <sys_unlink+0x8a>
    80006a34:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006a36:	4741                	li	a4,16
    80006a38:	86ce                	mv	a3,s3
    80006a3a:	f1840613          	addi	a2,s0,-232
    80006a3e:	4581                	li	a1,0
    80006a40:	854a                	mv	a0,s2
    80006a42:	d94fe0ef          	jal	80004fd6 <readi>
    80006a46:	47c1                	li	a5,16
    80006a48:	00f51b63          	bne	a0,a5,80006a5e <sys_unlink+0x12e>
    if(de.inum != 0)
    80006a4c:	f1845783          	lhu	a5,-232(s0)
    80006a50:	ebb1                	bnez	a5,80006aa4 <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006a52:	29c1                	addiw	s3,s3,16
    80006a54:	04c92783          	lw	a5,76(s2)
    80006a58:	fcf9efe3          	bltu	s3,a5,80006a36 <sys_unlink+0x106>
    80006a5c:	bfb9                	j	800069ba <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80006a5e:	00003517          	auipc	a0,0x3
    80006a62:	6ca50513          	addi	a0,a0,1738 # 8000a128 <etext+0x1128>
    80006a66:	dbff90ef          	jal	80000824 <panic>
    panic("unlink: writei");
    80006a6a:	00003517          	auipc	a0,0x3
    80006a6e:	6d650513          	addi	a0,a0,1750 # 8000a140 <etext+0x1140>
    80006a72:	db3f90ef          	jal	80000824 <panic>
    dp->nlink--;
    80006a76:	04a4d783          	lhu	a5,74(s1)
    80006a7a:	37fd                	addiw	a5,a5,-1
    80006a7c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80006a80:	8526                	mv	a0,s1
    80006a82:	90efe0ef          	jal	80004b90 <iupdate>
    80006a86:	b78d                	j	800069e8 <sys_unlink+0xb8>
    80006a88:	694e                	ld	s2,208(sp)

bad:
  iunlockput(dp);
    80006a8a:	8526                	mv	a0,s1
    80006a8c:	bc4fe0ef          	jal	80004e50 <iunlockput>
  end_op();
    80006a90:	c31fe0ef          	jal	800056c0 <end_op>
  return -1;
    80006a94:	557d                	li	a0,-1
    80006a96:	64ee                	ld	s1,216(sp)
}
    80006a98:	70ae                	ld	ra,232(sp)
    80006a9a:	740e                	ld	s0,224(sp)
    80006a9c:	616d                	addi	sp,sp,240
    80006a9e:	8082                	ret
    return -1;
    80006aa0:	557d                	li	a0,-1
    80006aa2:	bfdd                	j	80006a98 <sys_unlink+0x168>
    iunlockput(ip);
    80006aa4:	854a                	mv	a0,s2
    80006aa6:	baafe0ef          	jal	80004e50 <iunlockput>
    goto bad;
    80006aaa:	694e                	ld	s2,208(sp)
    80006aac:	69ae                	ld	s3,200(sp)
    80006aae:	bff1                	j	80006a8a <sys_unlink+0x15a>

0000000080006ab0 <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
    80006ab0:	715d                	addi	sp,sp,-80
    80006ab2:	e486                	sd	ra,72(sp)
    80006ab4:	e0a2                	sd	s0,64(sp)
    80006ab6:	fc26                	sd	s1,56(sp)
    80006ab8:	f84a                	sd	s2,48(sp)
    80006aba:	f44e                	sd	s3,40(sp)
    80006abc:	f052                	sd	s4,32(sp)
    80006abe:	ec56                	sd	s5,24(sp)
    80006ac0:	e85a                	sd	s6,16(sp)
    80006ac2:	0880                	addi	s0,sp,80
    80006ac4:	892e                	mv	s2,a1
    80006ac6:	8a2e                	mv	s4,a1
    80006ac8:	8ab2                	mv	s5,a2
    80006aca:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80006acc:	fb040593          	addi	a1,s0,-80
    80006ad0:	9bdfe0ef          	jal	8000548c <nameiparent>
    80006ad4:	84aa                	mv	s1,a0
    80006ad6:	10050763          	beqz	a0,80006be4 <create+0x134>
    return 0;

  ilock(dp);
    80006ada:	96afe0ef          	jal	80004c44 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80006ade:	4601                	li	a2,0
    80006ae0:	fb040593          	addi	a1,s0,-80
    80006ae4:	8526                	mv	a0,s1
    80006ae6:	ef8fe0ef          	jal	800051de <dirlookup>
    80006aea:	89aa                	mv	s3,a0
    80006aec:	c131                	beqz	a0,80006b30 <create+0x80>
    iunlockput(dp);
    80006aee:	8526                	mv	a0,s1
    80006af0:	b60fe0ef          	jal	80004e50 <iunlockput>
    ilock(ip);
    80006af4:	854e                	mv	a0,s3
    80006af6:	94efe0ef          	jal	80004c44 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80006afa:	4789                	li	a5,2
    80006afc:	02f91563          	bne	s2,a5,80006b26 <create+0x76>
    80006b00:	0449d783          	lhu	a5,68(s3)
    80006b04:	37f9                	addiw	a5,a5,-2
    80006b06:	17c2                	slli	a5,a5,0x30
    80006b08:	93c1                	srli	a5,a5,0x30
    80006b0a:	4705                	li	a4,1
    80006b0c:	00f76d63          	bltu	a4,a5,80006b26 <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80006b10:	854e                	mv	a0,s3
    80006b12:	60a6                	ld	ra,72(sp)
    80006b14:	6406                	ld	s0,64(sp)
    80006b16:	74e2                	ld	s1,56(sp)
    80006b18:	7942                	ld	s2,48(sp)
    80006b1a:	79a2                	ld	s3,40(sp)
    80006b1c:	7a02                	ld	s4,32(sp)
    80006b1e:	6ae2                	ld	s5,24(sp)
    80006b20:	6b42                	ld	s6,16(sp)
    80006b22:	6161                	addi	sp,sp,80
    80006b24:	8082                	ret
    iunlockput(ip);
    80006b26:	854e                	mv	a0,s3
    80006b28:	b28fe0ef          	jal	80004e50 <iunlockput>
    return 0;
    80006b2c:	4981                	li	s3,0
    80006b2e:	b7cd                	j	80006b10 <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    80006b30:	85ca                	mv	a1,s2
    80006b32:	4088                	lw	a0,0(s1)
    80006b34:	fa1fd0ef          	jal	80004ad4 <ialloc>
    80006b38:	892a                	mv	s2,a0
    80006b3a:	cd15                	beqz	a0,80006b76 <create+0xc6>
  ilock(ip);
    80006b3c:	908fe0ef          	jal	80004c44 <ilock>
  ip->major = major;
    80006b40:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    80006b44:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    80006b48:	4785                	li	a5,1
    80006b4a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80006b4e:	854a                	mv	a0,s2
    80006b50:	840fe0ef          	jal	80004b90 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80006b54:	4705                	li	a4,1
    80006b56:	02ea0463          	beq	s4,a4,80006b7e <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80006b5a:	00492603          	lw	a2,4(s2)
    80006b5e:	fb040593          	addi	a1,s0,-80
    80006b62:	8526                	mv	a0,s1
    80006b64:	865fe0ef          	jal	800053c8 <dirlink>
    80006b68:	06054263          	bltz	a0,80006bcc <create+0x11c>
  iunlockput(dp);
    80006b6c:	8526                	mv	a0,s1
    80006b6e:	ae2fe0ef          	jal	80004e50 <iunlockput>
  return ip;
    80006b72:	89ca                	mv	s3,s2
    80006b74:	bf71                	j	80006b10 <create+0x60>
    iunlockput(dp);
    80006b76:	8526                	mv	a0,s1
    80006b78:	ad8fe0ef          	jal	80004e50 <iunlockput>
    return 0;
    80006b7c:	bf51                	j	80006b10 <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80006b7e:	00492603          	lw	a2,4(s2)
    80006b82:	00003597          	auipc	a1,0x3
    80006b86:	57e58593          	addi	a1,a1,1406 # 8000a100 <etext+0x1100>
    80006b8a:	854a                	mv	a0,s2
    80006b8c:	83dfe0ef          	jal	800053c8 <dirlink>
    80006b90:	02054e63          	bltz	a0,80006bcc <create+0x11c>
    80006b94:	40d0                	lw	a2,4(s1)
    80006b96:	00003597          	auipc	a1,0x3
    80006b9a:	57258593          	addi	a1,a1,1394 # 8000a108 <etext+0x1108>
    80006b9e:	854a                	mv	a0,s2
    80006ba0:	829fe0ef          	jal	800053c8 <dirlink>
    80006ba4:	02054463          	bltz	a0,80006bcc <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80006ba8:	00492603          	lw	a2,4(s2)
    80006bac:	fb040593          	addi	a1,s0,-80
    80006bb0:	8526                	mv	a0,s1
    80006bb2:	817fe0ef          	jal	800053c8 <dirlink>
    80006bb6:	00054b63          	bltz	a0,80006bcc <create+0x11c>
    dp->nlink++;  // for ".."
    80006bba:	04a4d783          	lhu	a5,74(s1)
    80006bbe:	2785                	addiw	a5,a5,1
    80006bc0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80006bc4:	8526                	mv	a0,s1
    80006bc6:	fcbfd0ef          	jal	80004b90 <iupdate>
    80006bca:	b74d                	j	80006b6c <create+0xbc>
  ip->nlink = 0;
    80006bcc:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    80006bd0:	854a                	mv	a0,s2
    80006bd2:	fbffd0ef          	jal	80004b90 <iupdate>
  iunlockput(ip);
    80006bd6:	854a                	mv	a0,s2
    80006bd8:	a78fe0ef          	jal	80004e50 <iunlockput>
  iunlockput(dp);
    80006bdc:	8526                	mv	a0,s1
    80006bde:	a72fe0ef          	jal	80004e50 <iunlockput>
  return 0;
    80006be2:	b73d                	j	80006b10 <create+0x60>
    return 0;
    80006be4:	89aa                	mv	s3,a0
    80006be6:	b72d                	j	80006b10 <create+0x60>

0000000080006be8 <sys_open>:

uint64
sys_open(void)
{
    80006be8:	7131                	addi	sp,sp,-192
    80006bea:	fd06                	sd	ra,184(sp)
    80006bec:	f922                	sd	s0,176(sp)
    80006bee:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80006bf0:	f4c40593          	addi	a1,s0,-180
    80006bf4:	4505                	li	a0,1
    80006bf6:	bdefd0ef          	jal	80003fd4 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80006bfa:	08000613          	li	a2,128
    80006bfe:	f5040593          	addi	a1,s0,-176
    80006c02:	4501                	li	a0,0
    80006c04:	c08fd0ef          	jal	8000400c <argstr>
    80006c08:	87aa                	mv	a5,a0
    return -1;
    80006c0a:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80006c0c:	0a07c363          	bltz	a5,80006cb2 <sys_open+0xca>
    80006c10:	f526                	sd	s1,168(sp)

  begin_op();
    80006c12:	a3ffe0ef          	jal	80005650 <begin_op>

  if(omode & O_CREATE){
    80006c16:	f4c42783          	lw	a5,-180(s0)
    80006c1a:	2007f793          	andi	a5,a5,512
    80006c1e:	c3dd                	beqz	a5,80006cc4 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80006c20:	4681                	li	a3,0
    80006c22:	4601                	li	a2,0
    80006c24:	4589                	li	a1,2
    80006c26:	f5040513          	addi	a0,s0,-176
    80006c2a:	e87ff0ef          	jal	80006ab0 <create>
    80006c2e:	84aa                	mv	s1,a0
    if(ip == 0){
    80006c30:	c549                	beqz	a0,80006cba <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80006c32:	04449703          	lh	a4,68(s1)
    80006c36:	478d                	li	a5,3
    80006c38:	00f71763          	bne	a4,a5,80006c46 <sys_open+0x5e>
    80006c3c:	0464d703          	lhu	a4,70(s1)
    80006c40:	47a5                	li	a5,9
    80006c42:	0ae7ee63          	bltu	a5,a4,80006cfe <sys_open+0x116>
    80006c46:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80006c48:	d89fe0ef          	jal	800059d0 <filealloc>
    80006c4c:	892a                	mv	s2,a0
    80006c4e:	c561                	beqz	a0,80006d16 <sys_open+0x12e>
    80006c50:	ed4e                	sd	s3,152(sp)
    80006c52:	a47ff0ef          	jal	80006698 <fdalloc>
    80006c56:	89aa                	mv	s3,a0
    80006c58:	0a054b63          	bltz	a0,80006d0e <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80006c5c:	04449703          	lh	a4,68(s1)
    80006c60:	478d                	li	a5,3
    80006c62:	0cf70363          	beq	a4,a5,80006d28 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80006c66:	4789                	li	a5,2
    80006c68:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80006c6c:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80006c70:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80006c74:	f4c42783          	lw	a5,-180(s0)
    80006c78:	0017f713          	andi	a4,a5,1
    80006c7c:	00174713          	xori	a4,a4,1
    80006c80:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006c84:	0037f713          	andi	a4,a5,3
    80006c88:	00e03733          	snez	a4,a4
    80006c8c:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006c90:	4007f793          	andi	a5,a5,1024
    80006c94:	c791                	beqz	a5,80006ca0 <sys_open+0xb8>
    80006c96:	04449703          	lh	a4,68(s1)
    80006c9a:	4789                	li	a5,2
    80006c9c:	08f70d63          	beq	a4,a5,80006d36 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80006ca0:	8526                	mv	a0,s1
    80006ca2:	850fe0ef          	jal	80004cf2 <iunlock>
  end_op();
    80006ca6:	a1bfe0ef          	jal	800056c0 <end_op>

  return fd;
    80006caa:	854e                	mv	a0,s3
    80006cac:	74aa                	ld	s1,168(sp)
    80006cae:	790a                	ld	s2,160(sp)
    80006cb0:	69ea                	ld	s3,152(sp)
}
    80006cb2:	70ea                	ld	ra,184(sp)
    80006cb4:	744a                	ld	s0,176(sp)
    80006cb6:	6129                	addi	sp,sp,192
    80006cb8:	8082                	ret
      end_op();
    80006cba:	a07fe0ef          	jal	800056c0 <end_op>
      return -1;
    80006cbe:	557d                	li	a0,-1
    80006cc0:	74aa                	ld	s1,168(sp)
    80006cc2:	bfc5                	j	80006cb2 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    80006cc4:	f5040513          	addi	a0,s0,-176
    80006cc8:	faafe0ef          	jal	80005472 <namei>
    80006ccc:	84aa                	mv	s1,a0
    80006cce:	c11d                	beqz	a0,80006cf4 <sys_open+0x10c>
    ilock(ip);
    80006cd0:	f75fd0ef          	jal	80004c44 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80006cd4:	04449703          	lh	a4,68(s1)
    80006cd8:	4785                	li	a5,1
    80006cda:	f4f71ce3          	bne	a4,a5,80006c32 <sys_open+0x4a>
    80006cde:	f4c42783          	lw	a5,-180(s0)
    80006ce2:	d3b5                	beqz	a5,80006c46 <sys_open+0x5e>
      iunlockput(ip);
    80006ce4:	8526                	mv	a0,s1
    80006ce6:	96afe0ef          	jal	80004e50 <iunlockput>
      end_op();
    80006cea:	9d7fe0ef          	jal	800056c0 <end_op>
      return -1;
    80006cee:	557d                	li	a0,-1
    80006cf0:	74aa                	ld	s1,168(sp)
    80006cf2:	b7c1                	j	80006cb2 <sys_open+0xca>
      end_op();
    80006cf4:	9cdfe0ef          	jal	800056c0 <end_op>
      return -1;
    80006cf8:	557d                	li	a0,-1
    80006cfa:	74aa                	ld	s1,168(sp)
    80006cfc:	bf5d                	j	80006cb2 <sys_open+0xca>
    iunlockput(ip);
    80006cfe:	8526                	mv	a0,s1
    80006d00:	950fe0ef          	jal	80004e50 <iunlockput>
    end_op();
    80006d04:	9bdfe0ef          	jal	800056c0 <end_op>
    return -1;
    80006d08:	557d                	li	a0,-1
    80006d0a:	74aa                	ld	s1,168(sp)
    80006d0c:	b75d                	j	80006cb2 <sys_open+0xca>
      fileclose(f);
    80006d0e:	854a                	mv	a0,s2
    80006d10:	d65fe0ef          	jal	80005a74 <fileclose>
    80006d14:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80006d16:	8526                	mv	a0,s1
    80006d18:	938fe0ef          	jal	80004e50 <iunlockput>
    end_op();
    80006d1c:	9a5fe0ef          	jal	800056c0 <end_op>
    return -1;
    80006d20:	557d                	li	a0,-1
    80006d22:	74aa                	ld	s1,168(sp)
    80006d24:	790a                	ld	s2,160(sp)
    80006d26:	b771                	j	80006cb2 <sys_open+0xca>
    f->type = FD_DEVICE;
    80006d28:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80006d2c:	04649783          	lh	a5,70(s1)
    80006d30:	02f91223          	sh	a5,36(s2)
    80006d34:	bf35                	j	80006c70 <sys_open+0x88>
    itrunc(ip);
    80006d36:	8526                	mv	a0,s1
    80006d38:	ffbfd0ef          	jal	80004d32 <itrunc>
    80006d3c:	b795                	j	80006ca0 <sys_open+0xb8>

0000000080006d3e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006d3e:	7175                	addi	sp,sp,-144
    80006d40:	e506                	sd	ra,136(sp)
    80006d42:	e122                	sd	s0,128(sp)
    80006d44:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006d46:	90bfe0ef          	jal	80005650 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006d4a:	08000613          	li	a2,128
    80006d4e:	f7040593          	addi	a1,s0,-144
    80006d52:	4501                	li	a0,0
    80006d54:	ab8fd0ef          	jal	8000400c <argstr>
    80006d58:	02054363          	bltz	a0,80006d7e <sys_mkdir+0x40>
    80006d5c:	4681                	li	a3,0
    80006d5e:	4601                	li	a2,0
    80006d60:	4585                	li	a1,1
    80006d62:	f7040513          	addi	a0,s0,-144
    80006d66:	d4bff0ef          	jal	80006ab0 <create>
    80006d6a:	c911                	beqz	a0,80006d7e <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006d6c:	8e4fe0ef          	jal	80004e50 <iunlockput>
  end_op();
    80006d70:	951fe0ef          	jal	800056c0 <end_op>
  return 0;
    80006d74:	4501                	li	a0,0
}
    80006d76:	60aa                	ld	ra,136(sp)
    80006d78:	640a                	ld	s0,128(sp)
    80006d7a:	6149                	addi	sp,sp,144
    80006d7c:	8082                	ret
    end_op();
    80006d7e:	943fe0ef          	jal	800056c0 <end_op>
    return -1;
    80006d82:	557d                	li	a0,-1
    80006d84:	bfcd                	j	80006d76 <sys_mkdir+0x38>

0000000080006d86 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006d86:	7135                	addi	sp,sp,-160
    80006d88:	ed06                	sd	ra,152(sp)
    80006d8a:	e922                	sd	s0,144(sp)
    80006d8c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006d8e:	8c3fe0ef          	jal	80005650 <begin_op>
  argint(1, &major);
    80006d92:	f6c40593          	addi	a1,s0,-148
    80006d96:	4505                	li	a0,1
    80006d98:	a3cfd0ef          	jal	80003fd4 <argint>
  argint(2, &minor);
    80006d9c:	f6840593          	addi	a1,s0,-152
    80006da0:	4509                	li	a0,2
    80006da2:	a32fd0ef          	jal	80003fd4 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006da6:	08000613          	li	a2,128
    80006daa:	f7040593          	addi	a1,s0,-144
    80006dae:	4501                	li	a0,0
    80006db0:	a5cfd0ef          	jal	8000400c <argstr>
    80006db4:	02054563          	bltz	a0,80006dde <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006db8:	f6841683          	lh	a3,-152(s0)
    80006dbc:	f6c41603          	lh	a2,-148(s0)
    80006dc0:	458d                	li	a1,3
    80006dc2:	f7040513          	addi	a0,s0,-144
    80006dc6:	cebff0ef          	jal	80006ab0 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006dca:	c911                	beqz	a0,80006dde <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006dcc:	884fe0ef          	jal	80004e50 <iunlockput>
  end_op();
    80006dd0:	8f1fe0ef          	jal	800056c0 <end_op>
  return 0;
    80006dd4:	4501                	li	a0,0
}
    80006dd6:	60ea                	ld	ra,152(sp)
    80006dd8:	644a                	ld	s0,144(sp)
    80006dda:	610d                	addi	sp,sp,160
    80006ddc:	8082                	ret
    end_op();
    80006dde:	8e3fe0ef          	jal	800056c0 <end_op>
    return -1;
    80006de2:	557d                	li	a0,-1
    80006de4:	bfcd                	j	80006dd6 <sys_mknod+0x50>

0000000080006de6 <sys_chdir>:

uint64
sys_chdir(void)
{
    80006de6:	7135                	addi	sp,sp,-160
    80006de8:	ed06                	sd	ra,152(sp)
    80006dea:	e922                	sd	s0,144(sp)
    80006dec:	e14a                	sd	s2,128(sp)
    80006dee:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006df0:	854fc0ef          	jal	80002e44 <myproc>
    80006df4:	892a                	mv	s2,a0
  
  begin_op();
    80006df6:	85bfe0ef          	jal	80005650 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006dfa:	08000613          	li	a2,128
    80006dfe:	f6040593          	addi	a1,s0,-160
    80006e02:	4501                	li	a0,0
    80006e04:	a08fd0ef          	jal	8000400c <argstr>
    80006e08:	04054363          	bltz	a0,80006e4e <sys_chdir+0x68>
    80006e0c:	e526                	sd	s1,136(sp)
    80006e0e:	f6040513          	addi	a0,s0,-160
    80006e12:	e60fe0ef          	jal	80005472 <namei>
    80006e16:	84aa                	mv	s1,a0
    80006e18:	c915                	beqz	a0,80006e4c <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80006e1a:	e2bfd0ef          	jal	80004c44 <ilock>
  if(ip->type != T_DIR){
    80006e1e:	04449703          	lh	a4,68(s1)
    80006e22:	4785                	li	a5,1
    80006e24:	02f71963          	bne	a4,a5,80006e56 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006e28:	8526                	mv	a0,s1
    80006e2a:	ec9fd0ef          	jal	80004cf2 <iunlock>
  iput(p->cwd);
    80006e2e:	15093503          	ld	a0,336(s2)
    80006e32:	f95fd0ef          	jal	80004dc6 <iput>
  end_op();
    80006e36:	88bfe0ef          	jal	800056c0 <end_op>
  p->cwd = ip;
    80006e3a:	14993823          	sd	s1,336(s2)
  return 0;
    80006e3e:	4501                	li	a0,0
    80006e40:	64aa                	ld	s1,136(sp)
}
    80006e42:	60ea                	ld	ra,152(sp)
    80006e44:	644a                	ld	s0,144(sp)
    80006e46:	690a                	ld	s2,128(sp)
    80006e48:	610d                	addi	sp,sp,160
    80006e4a:	8082                	ret
    80006e4c:	64aa                	ld	s1,136(sp)
    end_op();
    80006e4e:	873fe0ef          	jal	800056c0 <end_op>
    return -1;
    80006e52:	557d                	li	a0,-1
    80006e54:	b7fd                	j	80006e42 <sys_chdir+0x5c>
    iunlockput(ip);
    80006e56:	8526                	mv	a0,s1
    80006e58:	ff9fd0ef          	jal	80004e50 <iunlockput>
    end_op();
    80006e5c:	865fe0ef          	jal	800056c0 <end_op>
    return -1;
    80006e60:	557d                	li	a0,-1
    80006e62:	64aa                	ld	s1,136(sp)
    80006e64:	bff9                	j	80006e42 <sys_chdir+0x5c>

0000000080006e66 <sys_exec>:

uint64
sys_exec(void)
{
    80006e66:	7105                	addi	sp,sp,-480
    80006e68:	ef86                	sd	ra,472(sp)
    80006e6a:	eba2                	sd	s0,464(sp)
    80006e6c:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80006e6e:	e2840593          	addi	a1,s0,-472
    80006e72:	4505                	li	a0,1
    80006e74:	97cfd0ef          	jal	80003ff0 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80006e78:	08000613          	li	a2,128
    80006e7c:	f3040593          	addi	a1,s0,-208
    80006e80:	4501                	li	a0,0
    80006e82:	98afd0ef          	jal	8000400c <argstr>
    80006e86:	87aa                	mv	a5,a0
    return -1;
    80006e88:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80006e8a:	0e07c063          	bltz	a5,80006f6a <sys_exec+0x104>
    80006e8e:	e7a6                	sd	s1,456(sp)
    80006e90:	e3ca                	sd	s2,448(sp)
    80006e92:	ff4e                	sd	s3,440(sp)
    80006e94:	fb52                	sd	s4,432(sp)
    80006e96:	f756                	sd	s5,424(sp)
    80006e98:	f35a                	sd	s6,416(sp)
    80006e9a:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80006e9c:	e3040a13          	addi	s4,s0,-464
    80006ea0:	10000613          	li	a2,256
    80006ea4:	4581                	li	a1,0
    80006ea6:	8552                	mv	a0,s4
    80006ea8:	e55f90ef          	jal	80000cfc <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006eac:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80006eae:	89d2                	mv	s3,s4
    80006eb0:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006eb2:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006eb6:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    80006eb8:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006ebc:	00391513          	slli	a0,s2,0x3
    80006ec0:	85d6                	mv	a1,s5
    80006ec2:	e2843783          	ld	a5,-472(s0)
    80006ec6:	953e                	add	a0,a0,a5
    80006ec8:	882fd0ef          	jal	80003f4a <fetchaddr>
    80006ecc:	02054663          	bltz	a0,80006ef8 <sys_exec+0x92>
    if(uarg == 0){
    80006ed0:	e2043783          	ld	a5,-480(s0)
    80006ed4:	c7a1                	beqz	a5,80006f1c <sys_exec+0xb6>
    argv[i] = kalloc();
    80006ed6:	c73f90ef          	jal	80000b48 <kalloc>
    80006eda:	85aa                	mv	a1,a0
    80006edc:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006ee0:	cd01                	beqz	a0,80006ef8 <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006ee2:	865a                	mv	a2,s6
    80006ee4:	e2043503          	ld	a0,-480(s0)
    80006ee8:	8acfd0ef          	jal	80003f94 <fetchstr>
    80006eec:	00054663          	bltz	a0,80006ef8 <sys_exec+0x92>
    if(i >= NELEM(argv)){
    80006ef0:	0905                	addi	s2,s2,1
    80006ef2:	09a1                	addi	s3,s3,8
    80006ef4:	fd7914e3          	bne	s2,s7,80006ebc <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006ef8:	100a0a13          	addi	s4,s4,256
    80006efc:	6088                	ld	a0,0(s1)
    80006efe:	cd31                	beqz	a0,80006f5a <sys_exec+0xf4>
    kfree(argv[i]);
    80006f00:	b5df90ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006f04:	04a1                	addi	s1,s1,8
    80006f06:	ff449be3          	bne	s1,s4,80006efc <sys_exec+0x96>
  return -1;
    80006f0a:	557d                	li	a0,-1
    80006f0c:	64be                	ld	s1,456(sp)
    80006f0e:	691e                	ld	s2,448(sp)
    80006f10:	79fa                	ld	s3,440(sp)
    80006f12:	7a5a                	ld	s4,432(sp)
    80006f14:	7aba                	ld	s5,424(sp)
    80006f16:	7b1a                	ld	s6,416(sp)
    80006f18:	6bfa                	ld	s7,408(sp)
    80006f1a:	a881                	j	80006f6a <sys_exec+0x104>
      argv[i] = 0;
    80006f1c:	0009079b          	sext.w	a5,s2
    80006f20:	e3040593          	addi	a1,s0,-464
    80006f24:	078e                	slli	a5,a5,0x3
    80006f26:	97ae                	add	a5,a5,a1
    80006f28:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    80006f2c:	f3040513          	addi	a0,s0,-208
    80006f30:	990ff0ef          	jal	800060c0 <kexec>
    80006f34:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006f36:	100a0a13          	addi	s4,s4,256
    80006f3a:	6088                	ld	a0,0(s1)
    80006f3c:	c511                	beqz	a0,80006f48 <sys_exec+0xe2>
    kfree(argv[i]);
    80006f3e:	b1ff90ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006f42:	04a1                	addi	s1,s1,8
    80006f44:	ff449be3          	bne	s1,s4,80006f3a <sys_exec+0xd4>
  return ret;
    80006f48:	854a                	mv	a0,s2
    80006f4a:	64be                	ld	s1,456(sp)
    80006f4c:	691e                	ld	s2,448(sp)
    80006f4e:	79fa                	ld	s3,440(sp)
    80006f50:	7a5a                	ld	s4,432(sp)
    80006f52:	7aba                	ld	s5,424(sp)
    80006f54:	7b1a                	ld	s6,416(sp)
    80006f56:	6bfa                	ld	s7,408(sp)
    80006f58:	a809                	j	80006f6a <sys_exec+0x104>
  return -1;
    80006f5a:	557d                	li	a0,-1
    80006f5c:	64be                	ld	s1,456(sp)
    80006f5e:	691e                	ld	s2,448(sp)
    80006f60:	79fa                	ld	s3,440(sp)
    80006f62:	7a5a                	ld	s4,432(sp)
    80006f64:	7aba                	ld	s5,424(sp)
    80006f66:	7b1a                	ld	s6,416(sp)
    80006f68:	6bfa                	ld	s7,408(sp)
}
    80006f6a:	60fe                	ld	ra,472(sp)
    80006f6c:	645e                	ld	s0,464(sp)
    80006f6e:	613d                	addi	sp,sp,480
    80006f70:	8082                	ret

0000000080006f72 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006f72:	7139                	addi	sp,sp,-64
    80006f74:	fc06                	sd	ra,56(sp)
    80006f76:	f822                	sd	s0,48(sp)
    80006f78:	f426                	sd	s1,40(sp)
    80006f7a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006f7c:	ec9fb0ef          	jal	80002e44 <myproc>
    80006f80:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006f82:	fd840593          	addi	a1,s0,-40
    80006f86:	4501                	li	a0,0
    80006f88:	868fd0ef          	jal	80003ff0 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80006f8c:	fc840593          	addi	a1,s0,-56
    80006f90:	fd040513          	addi	a0,s0,-48
    80006f94:	dfdfe0ef          	jal	80005d90 <pipealloc>
    return -1;
    80006f98:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006f9a:	0a054763          	bltz	a0,80007048 <sys_pipe+0xd6>
  fd0 = -1;
    80006f9e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006fa2:	fd043503          	ld	a0,-48(s0)
    80006fa6:	ef2ff0ef          	jal	80006698 <fdalloc>
    80006faa:	fca42223          	sw	a0,-60(s0)
    80006fae:	08054463          	bltz	a0,80007036 <sys_pipe+0xc4>
    80006fb2:	fc843503          	ld	a0,-56(s0)
    80006fb6:	ee2ff0ef          	jal	80006698 <fdalloc>
    80006fba:	fca42023          	sw	a0,-64(s0)
    80006fbe:	06054263          	bltz	a0,80007022 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006fc2:	4691                	li	a3,4
    80006fc4:	fc440613          	addi	a2,s0,-60
    80006fc8:	fd843583          	ld	a1,-40(s0)
    80006fcc:	68a8                	ld	a0,80(s1)
    80006fce:	8b3fb0ef          	jal	80002880 <copyout>
    80006fd2:	00054e63          	bltz	a0,80006fee <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006fd6:	4691                	li	a3,4
    80006fd8:	fc040613          	addi	a2,s0,-64
    80006fdc:	fd843583          	ld	a1,-40(s0)
    80006fe0:	95b6                	add	a1,a1,a3
    80006fe2:	68a8                	ld	a0,80(s1)
    80006fe4:	89dfb0ef          	jal	80002880 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006fe8:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006fea:	04055f63          	bgez	a0,80007048 <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    80006fee:	fc442783          	lw	a5,-60(s0)
    80006ff2:	078e                	slli	a5,a5,0x3
    80006ff4:	0d078793          	addi	a5,a5,208
    80006ff8:	97a6                	add	a5,a5,s1
    80006ffa:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006ffe:	fc042783          	lw	a5,-64(s0)
    80007002:	078e                	slli	a5,a5,0x3
    80007004:	0d078793          	addi	a5,a5,208
    80007008:	97a6                	add	a5,a5,s1
    8000700a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000700e:	fd043503          	ld	a0,-48(s0)
    80007012:	a63fe0ef          	jal	80005a74 <fileclose>
    fileclose(wf);
    80007016:	fc843503          	ld	a0,-56(s0)
    8000701a:	a5bfe0ef          	jal	80005a74 <fileclose>
    return -1;
    8000701e:	57fd                	li	a5,-1
    80007020:	a025                	j	80007048 <sys_pipe+0xd6>
    if(fd0 >= 0)
    80007022:	fc442783          	lw	a5,-60(s0)
    80007026:	0007c863          	bltz	a5,80007036 <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    8000702a:	078e                	slli	a5,a5,0x3
    8000702c:	0d078793          	addi	a5,a5,208
    80007030:	97a6                	add	a5,a5,s1
    80007032:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80007036:	fd043503          	ld	a0,-48(s0)
    8000703a:	a3bfe0ef          	jal	80005a74 <fileclose>
    fileclose(wf);
    8000703e:	fc843503          	ld	a0,-56(s0)
    80007042:	a33fe0ef          	jal	80005a74 <fileclose>
    return -1;
    80007046:	57fd                	li	a5,-1
}
    80007048:	853e                	mv	a0,a5
    8000704a:	70e2                	ld	ra,56(sp)
    8000704c:	7442                	ld	s0,48(sp)
    8000704e:	74a2                	ld	s1,40(sp)
    80007050:	6121                	addi	sp,sp,64
    80007052:	8082                	ret
	...

0000000080007060 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80007060:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80007062:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80007064:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80007066:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80007068:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000706a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000706c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000706e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80007070:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80007072:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80007074:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80007076:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80007078:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000707a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000707c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000707e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80007080:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80007082:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80007084:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80007086:	dd3fc0ef          	jal	80003e58 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000708a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000708c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000708e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80007090:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80007092:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80007094:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80007096:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80007098:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000709a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000709c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000709e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800070a0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800070a2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800070a4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800070a6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800070a8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800070aa:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800070ac:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800070ae:	10200073          	sret
    800070b2:	00000013          	nop
    800070b6:	00000013          	nop
    800070ba:	00000013          	nop

00000000800070be <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800070be:	1141                	addi	sp,sp,-16
    800070c0:	e406                	sd	ra,8(sp)
    800070c2:	e022                	sd	s0,0(sp)
    800070c4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800070c6:	0c000737          	lui	a4,0xc000
    800070ca:	4785                	li	a5,1
    800070cc:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800070ce:	c35c                	sw	a5,4(a4)
}
    800070d0:	60a2                	ld	ra,8(sp)
    800070d2:	6402                	ld	s0,0(sp)
    800070d4:	0141                	addi	sp,sp,16
    800070d6:	8082                	ret

00000000800070d8 <plicinithart>:

void
plicinithart(void)
{
    800070d8:	1141                	addi	sp,sp,-16
    800070da:	e406                	sd	ra,8(sp)
    800070dc:	e022                	sd	s0,0(sp)
    800070de:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800070e0:	d31fb0ef          	jal	80002e10 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800070e4:	0085171b          	slliw	a4,a0,0x8
    800070e8:	0c0027b7          	lui	a5,0xc002
    800070ec:	97ba                	add	a5,a5,a4
    800070ee:	40200713          	li	a4,1026
    800070f2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800070f6:	00d5151b          	slliw	a0,a0,0xd
    800070fa:	0c2017b7          	lui	a5,0xc201
    800070fe:	97aa                	add	a5,a5,a0
    80007100:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80007104:	60a2                	ld	ra,8(sp)
    80007106:	6402                	ld	s0,0(sp)
    80007108:	0141                	addi	sp,sp,16
    8000710a:	8082                	ret

000000008000710c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000710c:	1141                	addi	sp,sp,-16
    8000710e:	e406                	sd	ra,8(sp)
    80007110:	e022                	sd	s0,0(sp)
    80007112:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80007114:	cfdfb0ef          	jal	80002e10 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80007118:	00d5151b          	slliw	a0,a0,0xd
    8000711c:	0c2017b7          	lui	a5,0xc201
    80007120:	97aa                	add	a5,a5,a0
  return irq;
}
    80007122:	43c8                	lw	a0,4(a5)
    80007124:	60a2                	ld	ra,8(sp)
    80007126:	6402                	ld	s0,0(sp)
    80007128:	0141                	addi	sp,sp,16
    8000712a:	8082                	ret

000000008000712c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000712c:	1101                	addi	sp,sp,-32
    8000712e:	ec06                	sd	ra,24(sp)
    80007130:	e822                	sd	s0,16(sp)
    80007132:	e426                	sd	s1,8(sp)
    80007134:	1000                	addi	s0,sp,32
    80007136:	84aa                	mv	s1,a0
  int hart = cpuid();
    80007138:	cd9fb0ef          	jal	80002e10 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000713c:	00d5179b          	slliw	a5,a0,0xd
    80007140:	0c201737          	lui	a4,0xc201
    80007144:	97ba                	add	a5,a5,a4
    80007146:	c3c4                	sw	s1,4(a5)
}
    80007148:	60e2                	ld	ra,24(sp)
    8000714a:	6442                	ld	s0,16(sp)
    8000714c:	64a2                	ld	s1,8(sp)
    8000714e:	6105                	addi	sp,sp,32
    80007150:	8082                	ret

0000000080007152 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80007152:	1141                	addi	sp,sp,-16
    80007154:	e406                	sd	ra,8(sp)
    80007156:	e022                	sd	s0,0(sp)
    80007158:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000715a:	479d                	li	a5,7
    8000715c:	04a7ca63          	blt	a5,a0,800071b0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80007160:	002cd797          	auipc	a5,0x2cd
    80007164:	83878793          	addi	a5,a5,-1992 # 802d3998 <disk>
    80007168:	97aa                	add	a5,a5,a0
    8000716a:	0187c783          	lbu	a5,24(a5)
    8000716e:	e7b9                	bnez	a5,800071bc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80007170:	00451693          	slli	a3,a0,0x4
    80007174:	002cd797          	auipc	a5,0x2cd
    80007178:	82478793          	addi	a5,a5,-2012 # 802d3998 <disk>
    8000717c:	6398                	ld	a4,0(a5)
    8000717e:	9736                	add	a4,a4,a3
    80007180:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80007184:	6398                	ld	a4,0(a5)
    80007186:	9736                	add	a4,a4,a3
    80007188:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000718c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80007190:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80007194:	97aa                	add	a5,a5,a0
    80007196:	4705                	li	a4,1
    80007198:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000719c:	002cd517          	auipc	a0,0x2cd
    800071a0:	81450513          	addi	a0,a0,-2028 # 802d39b0 <disk+0x18>
    800071a4:	cdefc0ef          	jal	80003682 <wakeup>
}
    800071a8:	60a2                	ld	ra,8(sp)
    800071aa:	6402                	ld	s0,0(sp)
    800071ac:	0141                	addi	sp,sp,16
    800071ae:	8082                	ret
    panic("free_desc 1");
    800071b0:	00003517          	auipc	a0,0x3
    800071b4:	fa050513          	addi	a0,a0,-96 # 8000a150 <etext+0x1150>
    800071b8:	e6cf90ef          	jal	80000824 <panic>
    panic("free_desc 2");
    800071bc:	00003517          	auipc	a0,0x3
    800071c0:	fa450513          	addi	a0,a0,-92 # 8000a160 <etext+0x1160>
    800071c4:	e60f90ef          	jal	80000824 <panic>

00000000800071c8 <virtio_disk_init>:
{
    800071c8:	1101                	addi	sp,sp,-32
    800071ca:	ec06                	sd	ra,24(sp)
    800071cc:	e822                	sd	s0,16(sp)
    800071ce:	e426                	sd	s1,8(sp)
    800071d0:	e04a                	sd	s2,0(sp)
    800071d2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800071d4:	00003597          	auipc	a1,0x3
    800071d8:	f9c58593          	addi	a1,a1,-100 # 8000a170 <etext+0x1170>
    800071dc:	002cd517          	auipc	a0,0x2cd
    800071e0:	8e450513          	addi	a0,a0,-1820 # 802d3ac0 <disk+0x128>
    800071e4:	9bff90ef          	jal	80000ba2 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800071e8:	100017b7          	lui	a5,0x10001
    800071ec:	4398                	lw	a4,0(a5)
    800071ee:	2701                	sext.w	a4,a4
    800071f0:	747277b7          	lui	a5,0x74727
    800071f4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800071f8:	14f71863          	bne	a4,a5,80007348 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800071fc:	100017b7          	lui	a5,0x10001
    80007200:	43dc                	lw	a5,4(a5)
    80007202:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80007204:	4709                	li	a4,2
    80007206:	14e79163          	bne	a5,a4,80007348 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000720a:	100017b7          	lui	a5,0x10001
    8000720e:	479c                	lw	a5,8(a5)
    80007210:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80007212:	12e79b63          	bne	a5,a4,80007348 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80007216:	100017b7          	lui	a5,0x10001
    8000721a:	47d8                	lw	a4,12(a5)
    8000721c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000721e:	554d47b7          	lui	a5,0x554d4
    80007222:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80007226:	12f71163          	bne	a4,a5,80007348 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000722a:	100017b7          	lui	a5,0x10001
    8000722e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80007232:	4705                	li	a4,1
    80007234:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80007236:	470d                	li	a4,3
    80007238:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000723a:	10001737          	lui	a4,0x10001
    8000723e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80007240:	c7ffe6b7          	lui	a3,0xc7ffe
    80007244:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47d2ac87>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80007248:	8f75                	and	a4,a4,a3
    8000724a:	100016b7          	lui	a3,0x10001
    8000724e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80007250:	472d                	li	a4,11
    80007252:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80007254:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80007258:	439c                	lw	a5,0(a5)
    8000725a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000725e:	8ba1                	andi	a5,a5,8
    80007260:	0e078a63          	beqz	a5,80007354 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80007264:	100017b7          	lui	a5,0x10001
    80007268:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000726c:	43fc                	lw	a5,68(a5)
    8000726e:	2781                	sext.w	a5,a5
    80007270:	0e079863          	bnez	a5,80007360 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80007274:	100017b7          	lui	a5,0x10001
    80007278:	5bdc                	lw	a5,52(a5)
    8000727a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000727c:	0e078863          	beqz	a5,8000736c <virtio_disk_init+0x1a4>
  if(max < NUM)
    80007280:	471d                	li	a4,7
    80007282:	0ef77b63          	bgeu	a4,a5,80007378 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80007286:	8c3f90ef          	jal	80000b48 <kalloc>
    8000728a:	002cc497          	auipc	s1,0x2cc
    8000728e:	70e48493          	addi	s1,s1,1806 # 802d3998 <disk>
    80007292:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80007294:	8b5f90ef          	jal	80000b48 <kalloc>
    80007298:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000729a:	8aff90ef          	jal	80000b48 <kalloc>
    8000729e:	87aa                	mv	a5,a0
    800072a0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800072a2:	6088                	ld	a0,0(s1)
    800072a4:	0e050063          	beqz	a0,80007384 <virtio_disk_init+0x1bc>
    800072a8:	002cc717          	auipc	a4,0x2cc
    800072ac:	6f873703          	ld	a4,1784(a4) # 802d39a0 <disk+0x8>
    800072b0:	cb71                	beqz	a4,80007384 <virtio_disk_init+0x1bc>
    800072b2:	cbe9                	beqz	a5,80007384 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    800072b4:	6605                	lui	a2,0x1
    800072b6:	4581                	li	a1,0
    800072b8:	a45f90ef          	jal	80000cfc <memset>
  memset(disk.avail, 0, PGSIZE);
    800072bc:	002cc497          	auipc	s1,0x2cc
    800072c0:	6dc48493          	addi	s1,s1,1756 # 802d3998 <disk>
    800072c4:	6605                	lui	a2,0x1
    800072c6:	4581                	li	a1,0
    800072c8:	6488                	ld	a0,8(s1)
    800072ca:	a33f90ef          	jal	80000cfc <memset>
  memset(disk.used, 0, PGSIZE);
    800072ce:	6605                	lui	a2,0x1
    800072d0:	4581                	li	a1,0
    800072d2:	6888                	ld	a0,16(s1)
    800072d4:	a29f90ef          	jal	80000cfc <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800072d8:	100017b7          	lui	a5,0x10001
    800072dc:	4721                	li	a4,8
    800072de:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800072e0:	4098                	lw	a4,0(s1)
    800072e2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800072e6:	40d8                	lw	a4,4(s1)
    800072e8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800072ec:	649c                	ld	a5,8(s1)
    800072ee:	0007869b          	sext.w	a3,a5
    800072f2:	10001737          	lui	a4,0x10001
    800072f6:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800072fa:	9781                	srai	a5,a5,0x20
    800072fc:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80007300:	689c                	ld	a5,16(s1)
    80007302:	0007869b          	sext.w	a3,a5
    80007306:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000730a:	9781                	srai	a5,a5,0x20
    8000730c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80007310:	4785                	li	a5,1
    80007312:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80007314:	00f48c23          	sb	a5,24(s1)
    80007318:	00f48ca3          	sb	a5,25(s1)
    8000731c:	00f48d23          	sb	a5,26(s1)
    80007320:	00f48da3          	sb	a5,27(s1)
    80007324:	00f48e23          	sb	a5,28(s1)
    80007328:	00f48ea3          	sb	a5,29(s1)
    8000732c:	00f48f23          	sb	a5,30(s1)
    80007330:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80007334:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80007338:	07272823          	sw	s2,112(a4)
}
    8000733c:	60e2                	ld	ra,24(sp)
    8000733e:	6442                	ld	s0,16(sp)
    80007340:	64a2                	ld	s1,8(sp)
    80007342:	6902                	ld	s2,0(sp)
    80007344:	6105                	addi	sp,sp,32
    80007346:	8082                	ret
    panic("could not find virtio disk");
    80007348:	00003517          	auipc	a0,0x3
    8000734c:	e3850513          	addi	a0,a0,-456 # 8000a180 <etext+0x1180>
    80007350:	cd4f90ef          	jal	80000824 <panic>
    panic("virtio disk FEATURES_OK unset");
    80007354:	00003517          	auipc	a0,0x3
    80007358:	e4c50513          	addi	a0,a0,-436 # 8000a1a0 <etext+0x11a0>
    8000735c:	cc8f90ef          	jal	80000824 <panic>
    panic("virtio disk should not be ready");
    80007360:	00003517          	auipc	a0,0x3
    80007364:	e6050513          	addi	a0,a0,-416 # 8000a1c0 <etext+0x11c0>
    80007368:	cbcf90ef          	jal	80000824 <panic>
    panic("virtio disk has no queue 0");
    8000736c:	00003517          	auipc	a0,0x3
    80007370:	e7450513          	addi	a0,a0,-396 # 8000a1e0 <etext+0x11e0>
    80007374:	cb0f90ef          	jal	80000824 <panic>
    panic("virtio disk max queue too short");
    80007378:	00003517          	auipc	a0,0x3
    8000737c:	e8850513          	addi	a0,a0,-376 # 8000a200 <etext+0x1200>
    80007380:	ca4f90ef          	jal	80000824 <panic>
    panic("virtio disk kalloc");
    80007384:	00003517          	auipc	a0,0x3
    80007388:	e9c50513          	addi	a0,a0,-356 # 8000a220 <etext+0x1220>
    8000738c:	c98f90ef          	jal	80000824 <panic>

0000000080007390 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80007390:	711d                	addi	sp,sp,-96
    80007392:	ec86                	sd	ra,88(sp)
    80007394:	e8a2                	sd	s0,80(sp)
    80007396:	e4a6                	sd	s1,72(sp)
    80007398:	e0ca                	sd	s2,64(sp)
    8000739a:	fc4e                	sd	s3,56(sp)
    8000739c:	f852                	sd	s4,48(sp)
    8000739e:	f456                	sd	s5,40(sp)
    800073a0:	f05a                	sd	s6,32(sp)
    800073a2:	ec5e                	sd	s7,24(sp)
    800073a4:	e862                	sd	s8,16(sp)
    800073a6:	1080                	addi	s0,sp,96
    800073a8:	89aa                	mv	s3,a0
    800073aa:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800073ac:	00c52b83          	lw	s7,12(a0)
    800073b0:	001b9b9b          	slliw	s7,s7,0x1
    800073b4:	1b82                	slli	s7,s7,0x20
    800073b6:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    800073ba:	002cc517          	auipc	a0,0x2cc
    800073be:	70650513          	addi	a0,a0,1798 # 802d3ac0 <disk+0x128>
    800073c2:	86bf90ef          	jal	80000c2c <acquire>
  for(int i = 0; i < NUM; i++){
    800073c6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800073c8:	002cca97          	auipc	s5,0x2cc
    800073cc:	5d0a8a93          	addi	s5,s5,1488 # 802d3998 <disk>
  for(int i = 0; i < 3; i++){
    800073d0:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    800073d2:	5c7d                	li	s8,-1
    800073d4:	a095                	j	80007438 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    800073d6:	00fa8733          	add	a4,s5,a5
    800073da:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800073de:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800073e0:	0207c563          	bltz	a5,8000740a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    800073e4:	2905                	addiw	s2,s2,1
    800073e6:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800073e8:	05490c63          	beq	s2,s4,80007440 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    800073ec:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800073ee:	002cc717          	auipc	a4,0x2cc
    800073f2:	5aa70713          	addi	a4,a4,1450 # 802d3998 <disk>
    800073f6:	4781                	li	a5,0
    if(disk.free[i]){
    800073f8:	01874683          	lbu	a3,24(a4)
    800073fc:	fee9                	bnez	a3,800073d6 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    800073fe:	2785                	addiw	a5,a5,1
    80007400:	0705                	addi	a4,a4,1
    80007402:	fe979be3          	bne	a5,s1,800073f8 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80007406:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    8000740a:	01205d63          	blez	s2,80007424 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000740e:	fa042503          	lw	a0,-96(s0)
    80007412:	d41ff0ef          	jal	80007152 <free_desc>
      for(int j = 0; j < i; j++)
    80007416:	4785                	li	a5,1
    80007418:	0127d663          	bge	a5,s2,80007424 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000741c:	fa442503          	lw	a0,-92(s0)
    80007420:	d33ff0ef          	jal	80007152 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80007424:	002cc597          	auipc	a1,0x2cc
    80007428:	69c58593          	addi	a1,a1,1692 # 802d3ac0 <disk+0x128>
    8000742c:	002cc517          	auipc	a0,0x2cc
    80007430:	58450513          	addi	a0,a0,1412 # 802d39b0 <disk+0x18>
    80007434:	a02fc0ef          	jal	80003636 <sleep>
  for(int i = 0; i < 3; i++){
    80007438:	fa040613          	addi	a2,s0,-96
    8000743c:	4901                	li	s2,0
    8000743e:	b77d                	j	800073ec <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80007440:	fa042503          	lw	a0,-96(s0)
    80007444:	00451693          	slli	a3,a0,0x4

  if(write)
    80007448:	002cc797          	auipc	a5,0x2cc
    8000744c:	55078793          	addi	a5,a5,1360 # 802d3998 <disk>
    80007450:	00451713          	slli	a4,a0,0x4
    80007454:	0a070713          	addi	a4,a4,160
    80007458:	973e                	add	a4,a4,a5
    8000745a:	01603633          	snez	a2,s6
    8000745e:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80007460:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80007464:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80007468:	6398                	ld	a4,0(a5)
    8000746a:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000746c:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80007470:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80007472:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80007474:	6390                	ld	a2,0(a5)
    80007476:	00d60833          	add	a6,a2,a3
    8000747a:	4741                	li	a4,16
    8000747c:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80007480:	4585                	li	a1,1
    80007482:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80007486:	fa442703          	lw	a4,-92(s0)
    8000748a:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000748e:	0712                	slli	a4,a4,0x4
    80007490:	963a                	add	a2,a2,a4
    80007492:	05898813          	addi	a6,s3,88
    80007496:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000749a:	0007b883          	ld	a7,0(a5)
    8000749e:	9746                	add	a4,a4,a7
    800074a0:	40000613          	li	a2,1024
    800074a4:	c710                	sw	a2,8(a4)
  if(write)
    800074a6:	001b3613          	seqz	a2,s6
    800074aa:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800074ae:	8e4d                	or	a2,a2,a1
    800074b0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800074b4:	fa842603          	lw	a2,-88(s0)
    800074b8:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800074bc:	00451813          	slli	a6,a0,0x4
    800074c0:	02080813          	addi	a6,a6,32
    800074c4:	983e                	add	a6,a6,a5
    800074c6:	577d                	li	a4,-1
    800074c8:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800074cc:	0612                	slli	a2,a2,0x4
    800074ce:	98b2                	add	a7,a7,a2
    800074d0:	03068713          	addi	a4,a3,48
    800074d4:	973e                	add	a4,a4,a5
    800074d6:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800074da:	6398                	ld	a4,0(a5)
    800074dc:	9732                	add	a4,a4,a2
    800074de:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800074e0:	4689                	li	a3,2
    800074e2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800074e6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800074ea:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    800074ee:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800074f2:	6794                	ld	a3,8(a5)
    800074f4:	0026d703          	lhu	a4,2(a3)
    800074f8:	8b1d                	andi	a4,a4,7
    800074fa:	0706                	slli	a4,a4,0x1
    800074fc:	96ba                	add	a3,a3,a4
    800074fe:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80007502:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80007506:	6798                	ld	a4,8(a5)
    80007508:	00275783          	lhu	a5,2(a4)
    8000750c:	2785                	addiw	a5,a5,1
    8000750e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80007512:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80007516:	100017b7          	lui	a5,0x10001
    8000751a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000751e:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80007522:	002cc917          	auipc	s2,0x2cc
    80007526:	59e90913          	addi	s2,s2,1438 # 802d3ac0 <disk+0x128>
  while(b->disk == 1) {
    8000752a:	84ae                	mv	s1,a1
    8000752c:	00b79a63          	bne	a5,a1,80007540 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80007530:	85ca                	mv	a1,s2
    80007532:	854e                	mv	a0,s3
    80007534:	902fc0ef          	jal	80003636 <sleep>
  while(b->disk == 1) {
    80007538:	0049a783          	lw	a5,4(s3)
    8000753c:	fe978ae3          	beq	a5,s1,80007530 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80007540:	fa042903          	lw	s2,-96(s0)
    80007544:	00491713          	slli	a4,s2,0x4
    80007548:	02070713          	addi	a4,a4,32
    8000754c:	002cc797          	auipc	a5,0x2cc
    80007550:	44c78793          	addi	a5,a5,1100 # 802d3998 <disk>
    80007554:	97ba                	add	a5,a5,a4
    80007556:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000755a:	002cc997          	auipc	s3,0x2cc
    8000755e:	43e98993          	addi	s3,s3,1086 # 802d3998 <disk>
    80007562:	00491713          	slli	a4,s2,0x4
    80007566:	0009b783          	ld	a5,0(s3)
    8000756a:	97ba                	add	a5,a5,a4
    8000756c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80007570:	854a                	mv	a0,s2
    80007572:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80007576:	bddff0ef          	jal	80007152 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000757a:	8885                	andi	s1,s1,1
    8000757c:	f0fd                	bnez	s1,80007562 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000757e:	002cc517          	auipc	a0,0x2cc
    80007582:	54250513          	addi	a0,a0,1346 # 802d3ac0 <disk+0x128>
    80007586:	f3af90ef          	jal	80000cc0 <release>
}
    8000758a:	60e6                	ld	ra,88(sp)
    8000758c:	6446                	ld	s0,80(sp)
    8000758e:	64a6                	ld	s1,72(sp)
    80007590:	6906                	ld	s2,64(sp)
    80007592:	79e2                	ld	s3,56(sp)
    80007594:	7a42                	ld	s4,48(sp)
    80007596:	7aa2                	ld	s5,40(sp)
    80007598:	7b02                	ld	s6,32(sp)
    8000759a:	6be2                	ld	s7,24(sp)
    8000759c:	6c42                	ld	s8,16(sp)
    8000759e:	6125                	addi	sp,sp,96
    800075a0:	8082                	ret

00000000800075a2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800075a2:	1101                	addi	sp,sp,-32
    800075a4:	ec06                	sd	ra,24(sp)
    800075a6:	e822                	sd	s0,16(sp)
    800075a8:	e426                	sd	s1,8(sp)
    800075aa:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800075ac:	002cc497          	auipc	s1,0x2cc
    800075b0:	3ec48493          	addi	s1,s1,1004 # 802d3998 <disk>
    800075b4:	002cc517          	auipc	a0,0x2cc
    800075b8:	50c50513          	addi	a0,a0,1292 # 802d3ac0 <disk+0x128>
    800075bc:	e70f90ef          	jal	80000c2c <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800075c0:	100017b7          	lui	a5,0x10001
    800075c4:	53bc                	lw	a5,96(a5)
    800075c6:	8b8d                	andi	a5,a5,3
    800075c8:	10001737          	lui	a4,0x10001
    800075cc:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800075ce:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800075d2:	689c                	ld	a5,16(s1)
    800075d4:	0204d703          	lhu	a4,32(s1)
    800075d8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800075dc:	04f70863          	beq	a4,a5,8000762c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800075e0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800075e4:	6898                	ld	a4,16(s1)
    800075e6:	0204d783          	lhu	a5,32(s1)
    800075ea:	8b9d                	andi	a5,a5,7
    800075ec:	078e                	slli	a5,a5,0x3
    800075ee:	97ba                	add	a5,a5,a4
    800075f0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800075f2:	00479713          	slli	a4,a5,0x4
    800075f6:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    800075fa:	9726                	add	a4,a4,s1
    800075fc:	01074703          	lbu	a4,16(a4)
    80007600:	e329                	bnez	a4,80007642 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80007602:	0792                	slli	a5,a5,0x4
    80007604:	02078793          	addi	a5,a5,32
    80007608:	97a6                	add	a5,a5,s1
    8000760a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000760c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80007610:	872fc0ef          	jal	80003682 <wakeup>

    disk.used_idx += 1;
    80007614:	0204d783          	lhu	a5,32(s1)
    80007618:	2785                	addiw	a5,a5,1
    8000761a:	17c2                	slli	a5,a5,0x30
    8000761c:	93c1                	srli	a5,a5,0x30
    8000761e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80007622:	6898                	ld	a4,16(s1)
    80007624:	00275703          	lhu	a4,2(a4)
    80007628:	faf71ce3          	bne	a4,a5,800075e0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000762c:	002cc517          	auipc	a0,0x2cc
    80007630:	49450513          	addi	a0,a0,1172 # 802d3ac0 <disk+0x128>
    80007634:	e8cf90ef          	jal	80000cc0 <release>
}
    80007638:	60e2                	ld	ra,24(sp)
    8000763a:	6442                	ld	s0,16(sp)
    8000763c:	64a2                	ld	s1,8(sp)
    8000763e:	6105                	addi	sp,sp,32
    80007640:	8082                	ret
      panic("virtio_disk_intr status");
    80007642:	00003517          	auipc	a0,0x3
    80007646:	bf650513          	addi	a0,a0,-1034 # 8000a238 <etext+0x1238>
    8000764a:	9daf90ef          	jal	80000824 <panic>
	...

0000000080008000 <_trampoline>:
    80008000:	14051073          	csrw	sscratch,a0
    80008004:	02000537          	lui	a0,0x2000
    80008008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000800a:	0536                	slli	a0,a0,0xd
    8000800c:	02153423          	sd	ra,40(a0)
    80008010:	02253823          	sd	sp,48(a0)
    80008014:	02353c23          	sd	gp,56(a0)
    80008018:	04453023          	sd	tp,64(a0)
    8000801c:	04553423          	sd	t0,72(a0)
    80008020:	04653823          	sd	t1,80(a0)
    80008024:	04753c23          	sd	t2,88(a0)
    80008028:	f120                	sd	s0,96(a0)
    8000802a:	f524                	sd	s1,104(a0)
    8000802c:	fd2c                	sd	a1,120(a0)
    8000802e:	e150                	sd	a2,128(a0)
    80008030:	e554                	sd	a3,136(a0)
    80008032:	e958                	sd	a4,144(a0)
    80008034:	ed5c                	sd	a5,152(a0)
    80008036:	0b053023          	sd	a6,160(a0)
    8000803a:	0b153423          	sd	a7,168(a0)
    8000803e:	0b253823          	sd	s2,176(a0)
    80008042:	0b353c23          	sd	s3,184(a0)
    80008046:	0d453023          	sd	s4,192(a0)
    8000804a:	0d553423          	sd	s5,200(a0)
    8000804e:	0d653823          	sd	s6,208(a0)
    80008052:	0d753c23          	sd	s7,216(a0)
    80008056:	0f853023          	sd	s8,224(a0)
    8000805a:	0f953423          	sd	s9,232(a0)
    8000805e:	0fa53823          	sd	s10,240(a0)
    80008062:	0fb53c23          	sd	s11,248(a0)
    80008066:	11c53023          	sd	t3,256(a0)
    8000806a:	11d53423          	sd	t4,264(a0)
    8000806e:	11e53823          	sd	t5,272(a0)
    80008072:	11f53c23          	sd	t6,280(a0)
    80008076:	140022f3          	csrr	t0,sscratch
    8000807a:	06553823          	sd	t0,112(a0)
    8000807e:	00853103          	ld	sp,8(a0)
    80008082:	02053203          	ld	tp,32(a0)
    80008086:	01053283          	ld	t0,16(a0)
    8000808a:	00053303          	ld	t1,0(a0)
    8000808e:	12000073          	sfence.vma
    80008092:	18031073          	csrw	satp,t1
    80008096:	12000073          	sfence.vma
    8000809a:	9282                	jalr	t0

000000008000809c <userret>:
    8000809c:	12000073          	sfence.vma
    800080a0:	18051073          	csrw	satp,a0
    800080a4:	12000073          	sfence.vma
    800080a8:	02000537          	lui	a0,0x2000
    800080ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800080ae:	0536                	slli	a0,a0,0xd
    800080b0:	02853083          	ld	ra,40(a0)
    800080b4:	03053103          	ld	sp,48(a0)
    800080b8:	03853183          	ld	gp,56(a0)
    800080bc:	04053203          	ld	tp,64(a0)
    800080c0:	04853283          	ld	t0,72(a0)
    800080c4:	05053303          	ld	t1,80(a0)
    800080c8:	05853383          	ld	t2,88(a0)
    800080cc:	7120                	ld	s0,96(a0)
    800080ce:	7524                	ld	s1,104(a0)
    800080d0:	7d2c                	ld	a1,120(a0)
    800080d2:	6150                	ld	a2,128(a0)
    800080d4:	6554                	ld	a3,136(a0)
    800080d6:	6958                	ld	a4,144(a0)
    800080d8:	6d5c                	ld	a5,152(a0)
    800080da:	0a053803          	ld	a6,160(a0)
    800080de:	0a853883          	ld	a7,168(a0)
    800080e2:	0b053903          	ld	s2,176(a0)
    800080e6:	0b853983          	ld	s3,184(a0)
    800080ea:	0c053a03          	ld	s4,192(a0)
    800080ee:	0c853a83          	ld	s5,200(a0)
    800080f2:	0d053b03          	ld	s6,208(a0)
    800080f6:	0d853b83          	ld	s7,216(a0)
    800080fa:	0e053c03          	ld	s8,224(a0)
    800080fe:	0e853c83          	ld	s9,232(a0)
    80008102:	0f053d03          	ld	s10,240(a0)
    80008106:	0f853d83          	ld	s11,248(a0)
    8000810a:	10053e03          	ld	t3,256(a0)
    8000810e:	10853e83          	ld	t4,264(a0)
    80008112:	11053f03          	ld	t5,272(a0)
    80008116:	11853f83          	ld	t6,280(a0)
    8000811a:	7928                	ld	a0,112(a0)
    8000811c:	10200073          	sret
	...
