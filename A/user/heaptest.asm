
user/_heaptest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int main() {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  char *p = sbrk(4096);   // request 1 page
   a:	6505                	lui	a0,0x1
   c:	2ae000ef          	jal	2ba <sbrk>
  10:	84aa                	mv	s1,a0
  // do not touch it yet
  printf("Allocated, but not touched.\n");
  12:	00001517          	auipc	a0,0x1
  16:	8de50513          	addi	a0,a0,-1826 # 8f0 <malloc+0xf4>
  1a:	72a000ef          	jal	744 <printf>

  *p = 42;   // first write → should trigger PAGEFAULT → ALLOC
  1e:	02a00793          	li	a5,42
  22:	00f48023          	sb	a5,0(s1)
  printf("Heap write successful.\n");
  26:	00001517          	auipc	a0,0x1
  2a:	8ea50513          	addi	a0,a0,-1814 # 910 <malloc+0x114>
  2e:	716000ef          	jal	744 <printf>
  exit(0);
  32:	4501                	li	a0,0
  34:	2ba000ef          	jal	2ee <exit>

0000000000000038 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  38:	1141                	addi	sp,sp,-16
  3a:	e406                	sd	ra,8(sp)
  3c:	e022                	sd	s0,0(sp)
  3e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  40:	fc1ff0ef          	jal	0 <main>
  exit(r);
  44:	2aa000ef          	jal	2ee <exit>

0000000000000048 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  48:	1141                	addi	sp,sp,-16
  4a:	e406                	sd	ra,8(sp)
  4c:	e022                	sd	s0,0(sp)
  4e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  50:	87aa                	mv	a5,a0
  52:	0585                	addi	a1,a1,1
  54:	0785                	addi	a5,a5,1
  56:	fff5c703          	lbu	a4,-1(a1)
  5a:	fee78fa3          	sb	a4,-1(a5)
  5e:	fb75                	bnez	a4,52 <strcpy+0xa>
    ;
  return os;
}
  60:	60a2                	ld	ra,8(sp)
  62:	6402                	ld	s0,0(sp)
  64:	0141                	addi	sp,sp,16
  66:	8082                	ret

0000000000000068 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  68:	1141                	addi	sp,sp,-16
  6a:	e406                	sd	ra,8(sp)
  6c:	e022                	sd	s0,0(sp)
  6e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  70:	00054783          	lbu	a5,0(a0)
  74:	cb91                	beqz	a5,88 <strcmp+0x20>
  76:	0005c703          	lbu	a4,0(a1)
  7a:	00f71763          	bne	a4,a5,88 <strcmp+0x20>
    p++, q++;
  7e:	0505                	addi	a0,a0,1
  80:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  82:	00054783          	lbu	a5,0(a0)
  86:	fbe5                	bnez	a5,76 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  88:	0005c503          	lbu	a0,0(a1)
}
  8c:	40a7853b          	subw	a0,a5,a0
  90:	60a2                	ld	ra,8(sp)
  92:	6402                	ld	s0,0(sp)
  94:	0141                	addi	sp,sp,16
  96:	8082                	ret

0000000000000098 <strlen>:

uint
strlen(const char *s)
{
  98:	1141                	addi	sp,sp,-16
  9a:	e406                	sd	ra,8(sp)
  9c:	e022                	sd	s0,0(sp)
  9e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  a0:	00054783          	lbu	a5,0(a0)
  a4:	cf91                	beqz	a5,c0 <strlen+0x28>
  a6:	00150793          	addi	a5,a0,1
  aa:	86be                	mv	a3,a5
  ac:	0785                	addi	a5,a5,1
  ae:	fff7c703          	lbu	a4,-1(a5)
  b2:	ff65                	bnez	a4,aa <strlen+0x12>
  b4:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
  b8:	60a2                	ld	ra,8(sp)
  ba:	6402                	ld	s0,0(sp)
  bc:	0141                	addi	sp,sp,16
  be:	8082                	ret
  for(n = 0; s[n]; n++)
  c0:	4501                	li	a0,0
  c2:	bfdd                	j	b8 <strlen+0x20>

00000000000000c4 <memset>:

void*
memset(void *dst, int c, uint n)
{
  c4:	1141                	addi	sp,sp,-16
  c6:	e406                	sd	ra,8(sp)
  c8:	e022                	sd	s0,0(sp)
  ca:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  cc:	ca19                	beqz	a2,e2 <memset+0x1e>
  ce:	87aa                	mv	a5,a0
  d0:	1602                	slli	a2,a2,0x20
  d2:	9201                	srli	a2,a2,0x20
  d4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  d8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  dc:	0785                	addi	a5,a5,1
  de:	fee79de3          	bne	a5,a4,d8 <memset+0x14>
  }
  return dst;
}
  e2:	60a2                	ld	ra,8(sp)
  e4:	6402                	ld	s0,0(sp)
  e6:	0141                	addi	sp,sp,16
  e8:	8082                	ret

00000000000000ea <strchr>:

char*
strchr(const char *s, char c)
{
  ea:	1141                	addi	sp,sp,-16
  ec:	e406                	sd	ra,8(sp)
  ee:	e022                	sd	s0,0(sp)
  f0:	0800                	addi	s0,sp,16
  for(; *s; s++)
  f2:	00054783          	lbu	a5,0(a0)
  f6:	cf81                	beqz	a5,10e <strchr+0x24>
    if(*s == c)
  f8:	00f58763          	beq	a1,a5,106 <strchr+0x1c>
  for(; *s; s++)
  fc:	0505                	addi	a0,a0,1
  fe:	00054783          	lbu	a5,0(a0)
 102:	fbfd                	bnez	a5,f8 <strchr+0xe>
      return (char*)s;
  return 0;
 104:	4501                	li	a0,0
}
 106:	60a2                	ld	ra,8(sp)
 108:	6402                	ld	s0,0(sp)
 10a:	0141                	addi	sp,sp,16
 10c:	8082                	ret
  return 0;
 10e:	4501                	li	a0,0
 110:	bfdd                	j	106 <strchr+0x1c>

0000000000000112 <gets>:

char*
gets(char *buf, int max)
{
 112:	711d                	addi	sp,sp,-96
 114:	ec86                	sd	ra,88(sp)
 116:	e8a2                	sd	s0,80(sp)
 118:	e4a6                	sd	s1,72(sp)
 11a:	e0ca                	sd	s2,64(sp)
 11c:	fc4e                	sd	s3,56(sp)
 11e:	f852                	sd	s4,48(sp)
 120:	f456                	sd	s5,40(sp)
 122:	f05a                	sd	s6,32(sp)
 124:	ec5e                	sd	s7,24(sp)
 126:	e862                	sd	s8,16(sp)
 128:	1080                	addi	s0,sp,96
 12a:	8baa                	mv	s7,a0
 12c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 12e:	892a                	mv	s2,a0
 130:	4481                	li	s1,0
    cc = read(0, &c, 1);
 132:	faf40b13          	addi	s6,s0,-81
 136:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 138:	8c26                	mv	s8,s1
 13a:	0014899b          	addiw	s3,s1,1
 13e:	84ce                	mv	s1,s3
 140:	0349d463          	bge	s3,s4,168 <gets+0x56>
    cc = read(0, &c, 1);
 144:	8656                	mv	a2,s5
 146:	85da                	mv	a1,s6
 148:	4501                	li	a0,0
 14a:	1bc000ef          	jal	306 <read>
    if(cc < 1)
 14e:	00a05d63          	blez	a0,168 <gets+0x56>
      break;
    buf[i++] = c;
 152:	faf44783          	lbu	a5,-81(s0)
 156:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 15a:	0905                	addi	s2,s2,1
 15c:	ff678713          	addi	a4,a5,-10
 160:	c319                	beqz	a4,166 <gets+0x54>
 162:	17cd                	addi	a5,a5,-13
 164:	fbf1                	bnez	a5,138 <gets+0x26>
    buf[i++] = c;
 166:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 168:	9c5e                	add	s8,s8,s7
 16a:	000c0023          	sb	zero,0(s8)
  return buf;
}
 16e:	855e                	mv	a0,s7
 170:	60e6                	ld	ra,88(sp)
 172:	6446                	ld	s0,80(sp)
 174:	64a6                	ld	s1,72(sp)
 176:	6906                	ld	s2,64(sp)
 178:	79e2                	ld	s3,56(sp)
 17a:	7a42                	ld	s4,48(sp)
 17c:	7aa2                	ld	s5,40(sp)
 17e:	7b02                	ld	s6,32(sp)
 180:	6be2                	ld	s7,24(sp)
 182:	6c42                	ld	s8,16(sp)
 184:	6125                	addi	sp,sp,96
 186:	8082                	ret

0000000000000188 <stat>:

int
stat(const char *n, struct stat *st)
{
 188:	1101                	addi	sp,sp,-32
 18a:	ec06                	sd	ra,24(sp)
 18c:	e822                	sd	s0,16(sp)
 18e:	e04a                	sd	s2,0(sp)
 190:	1000                	addi	s0,sp,32
 192:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 194:	4581                	li	a1,0
 196:	198000ef          	jal	32e <open>
  if(fd < 0)
 19a:	02054263          	bltz	a0,1be <stat+0x36>
 19e:	e426                	sd	s1,8(sp)
 1a0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1a2:	85ca                	mv	a1,s2
 1a4:	1a2000ef          	jal	346 <fstat>
 1a8:	892a                	mv	s2,a0
  close(fd);
 1aa:	8526                	mv	a0,s1
 1ac:	16a000ef          	jal	316 <close>
  return r;
 1b0:	64a2                	ld	s1,8(sp)
}
 1b2:	854a                	mv	a0,s2
 1b4:	60e2                	ld	ra,24(sp)
 1b6:	6442                	ld	s0,16(sp)
 1b8:	6902                	ld	s2,0(sp)
 1ba:	6105                	addi	sp,sp,32
 1bc:	8082                	ret
    return -1;
 1be:	57fd                	li	a5,-1
 1c0:	893e                	mv	s2,a5
 1c2:	bfc5                	j	1b2 <stat+0x2a>

00000000000001c4 <atoi>:

int
atoi(const char *s)
{
 1c4:	1141                	addi	sp,sp,-16
 1c6:	e406                	sd	ra,8(sp)
 1c8:	e022                	sd	s0,0(sp)
 1ca:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1cc:	00054683          	lbu	a3,0(a0)
 1d0:	fd06879b          	addiw	a5,a3,-48
 1d4:	0ff7f793          	zext.b	a5,a5
 1d8:	4625                	li	a2,9
 1da:	02f66963          	bltu	a2,a5,20c <atoi+0x48>
 1de:	872a                	mv	a4,a0
  n = 0;
 1e0:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1e2:	0705                	addi	a4,a4,1
 1e4:	0025179b          	slliw	a5,a0,0x2
 1e8:	9fa9                	addw	a5,a5,a0
 1ea:	0017979b          	slliw	a5,a5,0x1
 1ee:	9fb5                	addw	a5,a5,a3
 1f0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1f4:	00074683          	lbu	a3,0(a4)
 1f8:	fd06879b          	addiw	a5,a3,-48
 1fc:	0ff7f793          	zext.b	a5,a5
 200:	fef671e3          	bgeu	a2,a5,1e2 <atoi+0x1e>
  return n;
}
 204:	60a2                	ld	ra,8(sp)
 206:	6402                	ld	s0,0(sp)
 208:	0141                	addi	sp,sp,16
 20a:	8082                	ret
  n = 0;
 20c:	4501                	li	a0,0
 20e:	bfdd                	j	204 <atoi+0x40>

0000000000000210 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 210:	1141                	addi	sp,sp,-16
 212:	e406                	sd	ra,8(sp)
 214:	e022                	sd	s0,0(sp)
 216:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 218:	02b57563          	bgeu	a0,a1,242 <memmove+0x32>
    while(n-- > 0)
 21c:	00c05f63          	blez	a2,23a <memmove+0x2a>
 220:	1602                	slli	a2,a2,0x20
 222:	9201                	srli	a2,a2,0x20
 224:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 228:	872a                	mv	a4,a0
      *dst++ = *src++;
 22a:	0585                	addi	a1,a1,1
 22c:	0705                	addi	a4,a4,1
 22e:	fff5c683          	lbu	a3,-1(a1)
 232:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 236:	fee79ae3          	bne	a5,a4,22a <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 23a:	60a2                	ld	ra,8(sp)
 23c:	6402                	ld	s0,0(sp)
 23e:	0141                	addi	sp,sp,16
 240:	8082                	ret
    while(n-- > 0)
 242:	fec05ce3          	blez	a2,23a <memmove+0x2a>
    dst += n;
 246:	00c50733          	add	a4,a0,a2
    src += n;
 24a:	95b2                	add	a1,a1,a2
 24c:	fff6079b          	addiw	a5,a2,-1
 250:	1782                	slli	a5,a5,0x20
 252:	9381                	srli	a5,a5,0x20
 254:	fff7c793          	not	a5,a5
 258:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 25a:	15fd                	addi	a1,a1,-1
 25c:	177d                	addi	a4,a4,-1
 25e:	0005c683          	lbu	a3,0(a1)
 262:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 266:	fef71ae3          	bne	a4,a5,25a <memmove+0x4a>
 26a:	bfc1                	j	23a <memmove+0x2a>

000000000000026c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e406                	sd	ra,8(sp)
 270:	e022                	sd	s0,0(sp)
 272:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 274:	c61d                	beqz	a2,2a2 <memcmp+0x36>
 276:	1602                	slli	a2,a2,0x20
 278:	9201                	srli	a2,a2,0x20
 27a:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 27e:	00054783          	lbu	a5,0(a0)
 282:	0005c703          	lbu	a4,0(a1)
 286:	00e79863          	bne	a5,a4,296 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 28a:	0505                	addi	a0,a0,1
    p2++;
 28c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 28e:	fed518e3          	bne	a0,a3,27e <memcmp+0x12>
  }
  return 0;
 292:	4501                	li	a0,0
 294:	a019                	j	29a <memcmp+0x2e>
      return *p1 - *p2;
 296:	40e7853b          	subw	a0,a5,a4
}
 29a:	60a2                	ld	ra,8(sp)
 29c:	6402                	ld	s0,0(sp)
 29e:	0141                	addi	sp,sp,16
 2a0:	8082                	ret
  return 0;
 2a2:	4501                	li	a0,0
 2a4:	bfdd                	j	29a <memcmp+0x2e>

00000000000002a6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2a6:	1141                	addi	sp,sp,-16
 2a8:	e406                	sd	ra,8(sp)
 2aa:	e022                	sd	s0,0(sp)
 2ac:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2ae:	f63ff0ef          	jal	210 <memmove>
}
 2b2:	60a2                	ld	ra,8(sp)
 2b4:	6402                	ld	s0,0(sp)
 2b6:	0141                	addi	sp,sp,16
 2b8:	8082                	ret

00000000000002ba <sbrk>:

char *
sbrk(int n) {
 2ba:	1141                	addi	sp,sp,-16
 2bc:	e406                	sd	ra,8(sp)
 2be:	e022                	sd	s0,0(sp)
 2c0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2c2:	4585                	li	a1,1
 2c4:	0b2000ef          	jal	376 <sys_sbrk>
}
 2c8:	60a2                	ld	ra,8(sp)
 2ca:	6402                	ld	s0,0(sp)
 2cc:	0141                	addi	sp,sp,16
 2ce:	8082                	ret

00000000000002d0 <sbrklazy>:

char *
sbrklazy(int n) {
 2d0:	1141                	addi	sp,sp,-16
 2d2:	e406                	sd	ra,8(sp)
 2d4:	e022                	sd	s0,0(sp)
 2d6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2d8:	4589                	li	a1,2
 2da:	09c000ef          	jal	376 <sys_sbrk>
}
 2de:	60a2                	ld	ra,8(sp)
 2e0:	6402                	ld	s0,0(sp)
 2e2:	0141                	addi	sp,sp,16
 2e4:	8082                	ret

00000000000002e6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2e6:	4885                	li	a7,1
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <exit>:
.global exit
exit:
 li a7, SYS_exit
 2ee:	4889                	li	a7,2
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2f6:	488d                	li	a7,3
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2fe:	4891                	li	a7,4
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <read>:
.global read
read:
 li a7, SYS_read
 306:	4895                	li	a7,5
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <write>:
.global write
write:
 li a7, SYS_write
 30e:	48c1                	li	a7,16
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <close>:
.global close
close:
 li a7, SYS_close
 316:	48d5                	li	a7,21
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <kill>:
.global kill
kill:
 li a7, SYS_kill
 31e:	4899                	li	a7,6
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <exec>:
.global exec
exec:
 li a7, SYS_exec
 326:	489d                	li	a7,7
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <open>:
.global open
open:
 li a7, SYS_open
 32e:	48bd                	li	a7,15
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 336:	48c5                	li	a7,17
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 33e:	48c9                	li	a7,18
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 346:	48a1                	li	a7,8
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <link>:
.global link
link:
 li a7, SYS_link
 34e:	48cd                	li	a7,19
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 356:	48d1                	li	a7,20
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 35e:	48a5                	li	a7,9
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <dup>:
.global dup
dup:
 li a7, SYS_dup
 366:	48a9                	li	a7,10
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 36e:	48ad                	li	a7,11
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 376:	48b1                	li	a7,12
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <pause>:
.global pause
pause:
 li a7, SYS_pause
 37e:	48b5                	li	a7,13
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 386:	48b9                	li	a7,14
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <memstat>:
.global memstat
memstat:
 li a7, SYS_memstat
 38e:	48d9                	li	a7,22
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <enable_bonus>:
.global enable_bonus
enable_bonus:
 li a7, SYS_enable_bonus
 396:	48dd                	li	a7,23
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 39e:	1101                	addi	sp,sp,-32
 3a0:	ec06                	sd	ra,24(sp)
 3a2:	e822                	sd	s0,16(sp)
 3a4:	1000                	addi	s0,sp,32
 3a6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3aa:	4605                	li	a2,1
 3ac:	fef40593          	addi	a1,s0,-17
 3b0:	f5fff0ef          	jal	30e <write>
}
 3b4:	60e2                	ld	ra,24(sp)
 3b6:	6442                	ld	s0,16(sp)
 3b8:	6105                	addi	sp,sp,32
 3ba:	8082                	ret

00000000000003bc <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3bc:	715d                	addi	sp,sp,-80
 3be:	e486                	sd	ra,72(sp)
 3c0:	e0a2                	sd	s0,64(sp)
 3c2:	f84a                	sd	s2,48(sp)
 3c4:	f44e                	sd	s3,40(sp)
 3c6:	0880                	addi	s0,sp,80
 3c8:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3ca:	c6d1                	beqz	a3,456 <printint+0x9a>
 3cc:	0805d563          	bgez	a1,456 <printint+0x9a>
    neg = 1;
    x = -xx;
 3d0:	40b005b3          	neg	a1,a1
    neg = 1;
 3d4:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 3d6:	fb840993          	addi	s3,s0,-72
  neg = 0;
 3da:	86ce                	mv	a3,s3
  i = 0;
 3dc:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3de:	00000817          	auipc	a6,0x0
 3e2:	55280813          	addi	a6,a6,1362 # 930 <digits>
 3e6:	88ba                	mv	a7,a4
 3e8:	0017051b          	addiw	a0,a4,1
 3ec:	872a                	mv	a4,a0
 3ee:	02c5f7b3          	remu	a5,a1,a2
 3f2:	97c2                	add	a5,a5,a6
 3f4:	0007c783          	lbu	a5,0(a5)
 3f8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3fc:	87ae                	mv	a5,a1
 3fe:	02c5d5b3          	divu	a1,a1,a2
 402:	0685                	addi	a3,a3,1
 404:	fec7f1e3          	bgeu	a5,a2,3e6 <printint+0x2a>
  if(neg)
 408:	00030c63          	beqz	t1,420 <printint+0x64>
    buf[i++] = '-';
 40c:	fd050793          	addi	a5,a0,-48
 410:	00878533          	add	a0,a5,s0
 414:	02d00793          	li	a5,45
 418:	fef50423          	sb	a5,-24(a0)
 41c:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 420:	02e05563          	blez	a4,44a <printint+0x8e>
 424:	fc26                	sd	s1,56(sp)
 426:	377d                	addiw	a4,a4,-1
 428:	00e984b3          	add	s1,s3,a4
 42c:	19fd                	addi	s3,s3,-1
 42e:	99ba                	add	s3,s3,a4
 430:	1702                	slli	a4,a4,0x20
 432:	9301                	srli	a4,a4,0x20
 434:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 438:	0004c583          	lbu	a1,0(s1)
 43c:	854a                	mv	a0,s2
 43e:	f61ff0ef          	jal	39e <putc>
  while(--i >= 0)
 442:	14fd                	addi	s1,s1,-1
 444:	ff349ae3          	bne	s1,s3,438 <printint+0x7c>
 448:	74e2                	ld	s1,56(sp)
}
 44a:	60a6                	ld	ra,72(sp)
 44c:	6406                	ld	s0,64(sp)
 44e:	7942                	ld	s2,48(sp)
 450:	79a2                	ld	s3,40(sp)
 452:	6161                	addi	sp,sp,80
 454:	8082                	ret
  neg = 0;
 456:	4301                	li	t1,0
 458:	bfbd                	j	3d6 <printint+0x1a>

000000000000045a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 45a:	711d                	addi	sp,sp,-96
 45c:	ec86                	sd	ra,88(sp)
 45e:	e8a2                	sd	s0,80(sp)
 460:	e4a6                	sd	s1,72(sp)
 462:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 464:	0005c483          	lbu	s1,0(a1)
 468:	22048363          	beqz	s1,68e <vprintf+0x234>
 46c:	e0ca                	sd	s2,64(sp)
 46e:	fc4e                	sd	s3,56(sp)
 470:	f852                	sd	s4,48(sp)
 472:	f456                	sd	s5,40(sp)
 474:	f05a                	sd	s6,32(sp)
 476:	ec5e                	sd	s7,24(sp)
 478:	e862                	sd	s8,16(sp)
 47a:	8b2a                	mv	s6,a0
 47c:	8a2e                	mv	s4,a1
 47e:	8bb2                	mv	s7,a2
  state = 0;
 480:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 482:	4901                	li	s2,0
 484:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 486:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 48a:	06400c13          	li	s8,100
 48e:	a00d                	j	4b0 <vprintf+0x56>
        putc(fd, c0);
 490:	85a6                	mv	a1,s1
 492:	855a                	mv	a0,s6
 494:	f0bff0ef          	jal	39e <putc>
 498:	a019                	j	49e <vprintf+0x44>
    } else if(state == '%'){
 49a:	03598363          	beq	s3,s5,4c0 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 49e:	0019079b          	addiw	a5,s2,1
 4a2:	893e                	mv	s2,a5
 4a4:	873e                	mv	a4,a5
 4a6:	97d2                	add	a5,a5,s4
 4a8:	0007c483          	lbu	s1,0(a5)
 4ac:	1c048a63          	beqz	s1,680 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 4b0:	0004879b          	sext.w	a5,s1
    if(state == 0){
 4b4:	fe0993e3          	bnez	s3,49a <vprintf+0x40>
      if(c0 == '%'){
 4b8:	fd579ce3          	bne	a5,s5,490 <vprintf+0x36>
        state = '%';
 4bc:	89be                	mv	s3,a5
 4be:	b7c5                	j	49e <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 4c0:	00ea06b3          	add	a3,s4,a4
 4c4:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 4c8:	1c060863          	beqz	a2,698 <vprintf+0x23e>
      if(c0 == 'd'){
 4cc:	03878763          	beq	a5,s8,4fa <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4d0:	f9478693          	addi	a3,a5,-108
 4d4:	0016b693          	seqz	a3,a3
 4d8:	f9c60593          	addi	a1,a2,-100
 4dc:	e99d                	bnez	a1,512 <vprintf+0xb8>
 4de:	ca95                	beqz	a3,512 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 4e0:	008b8493          	addi	s1,s7,8
 4e4:	4685                	li	a3,1
 4e6:	4629                	li	a2,10
 4e8:	000bb583          	ld	a1,0(s7)
 4ec:	855a                	mv	a0,s6
 4ee:	ecfff0ef          	jal	3bc <printint>
        i += 1;
 4f2:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 4f4:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 4f6:	4981                	li	s3,0
 4f8:	b75d                	j	49e <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 4fa:	008b8493          	addi	s1,s7,8
 4fe:	4685                	li	a3,1
 500:	4629                	li	a2,10
 502:	000ba583          	lw	a1,0(s7)
 506:	855a                	mv	a0,s6
 508:	eb5ff0ef          	jal	3bc <printint>
 50c:	8ba6                	mv	s7,s1
      state = 0;
 50e:	4981                	li	s3,0
 510:	b779                	j	49e <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 512:	9752                	add	a4,a4,s4
 514:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 518:	f9460713          	addi	a4,a2,-108
 51c:	00173713          	seqz	a4,a4
 520:	8f75                	and	a4,a4,a3
 522:	f9c58513          	addi	a0,a1,-100
 526:	18051363          	bnez	a0,6ac <vprintf+0x252>
 52a:	18070163          	beqz	a4,6ac <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 52e:	008b8493          	addi	s1,s7,8
 532:	4685                	li	a3,1
 534:	4629                	li	a2,10
 536:	000bb583          	ld	a1,0(s7)
 53a:	855a                	mv	a0,s6
 53c:	e81ff0ef          	jal	3bc <printint>
        i += 2;
 540:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 542:	8ba6                	mv	s7,s1
      state = 0;
 544:	4981                	li	s3,0
        i += 2;
 546:	bfa1                	j	49e <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 548:	008b8493          	addi	s1,s7,8
 54c:	4681                	li	a3,0
 54e:	4629                	li	a2,10
 550:	000be583          	lwu	a1,0(s7)
 554:	855a                	mv	a0,s6
 556:	e67ff0ef          	jal	3bc <printint>
 55a:	8ba6                	mv	s7,s1
      state = 0;
 55c:	4981                	li	s3,0
 55e:	b781                	j	49e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 560:	008b8493          	addi	s1,s7,8
 564:	4681                	li	a3,0
 566:	4629                	li	a2,10
 568:	000bb583          	ld	a1,0(s7)
 56c:	855a                	mv	a0,s6
 56e:	e4fff0ef          	jal	3bc <printint>
        i += 1;
 572:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 574:	8ba6                	mv	s7,s1
      state = 0;
 576:	4981                	li	s3,0
 578:	b71d                	j	49e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 57a:	008b8493          	addi	s1,s7,8
 57e:	4681                	li	a3,0
 580:	4629                	li	a2,10
 582:	000bb583          	ld	a1,0(s7)
 586:	855a                	mv	a0,s6
 588:	e35ff0ef          	jal	3bc <printint>
        i += 2;
 58c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 58e:	8ba6                	mv	s7,s1
      state = 0;
 590:	4981                	li	s3,0
        i += 2;
 592:	b731                	j	49e <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 594:	008b8493          	addi	s1,s7,8
 598:	4681                	li	a3,0
 59a:	4641                	li	a2,16
 59c:	000be583          	lwu	a1,0(s7)
 5a0:	855a                	mv	a0,s6
 5a2:	e1bff0ef          	jal	3bc <printint>
 5a6:	8ba6                	mv	s7,s1
      state = 0;
 5a8:	4981                	li	s3,0
 5aa:	bdd5                	j	49e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ac:	008b8493          	addi	s1,s7,8
 5b0:	4681                	li	a3,0
 5b2:	4641                	li	a2,16
 5b4:	000bb583          	ld	a1,0(s7)
 5b8:	855a                	mv	a0,s6
 5ba:	e03ff0ef          	jal	3bc <printint>
        i += 1;
 5be:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 5c0:	8ba6                	mv	s7,s1
      state = 0;
 5c2:	4981                	li	s3,0
 5c4:	bde9                	j	49e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5c6:	008b8493          	addi	s1,s7,8
 5ca:	4681                	li	a3,0
 5cc:	4641                	li	a2,16
 5ce:	000bb583          	ld	a1,0(s7)
 5d2:	855a                	mv	a0,s6
 5d4:	de9ff0ef          	jal	3bc <printint>
        i += 2;
 5d8:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5da:	8ba6                	mv	s7,s1
      state = 0;
 5dc:	4981                	li	s3,0
        i += 2;
 5de:	b5c1                	j	49e <vprintf+0x44>
 5e0:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 5e2:	008b8793          	addi	a5,s7,8
 5e6:	8cbe                	mv	s9,a5
 5e8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5ec:	03000593          	li	a1,48
 5f0:	855a                	mv	a0,s6
 5f2:	dadff0ef          	jal	39e <putc>
  putc(fd, 'x');
 5f6:	07800593          	li	a1,120
 5fa:	855a                	mv	a0,s6
 5fc:	da3ff0ef          	jal	39e <putc>
 600:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 602:	00000b97          	auipc	s7,0x0
 606:	32eb8b93          	addi	s7,s7,814 # 930 <digits>
 60a:	03c9d793          	srli	a5,s3,0x3c
 60e:	97de                	add	a5,a5,s7
 610:	0007c583          	lbu	a1,0(a5)
 614:	855a                	mv	a0,s6
 616:	d89ff0ef          	jal	39e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 61a:	0992                	slli	s3,s3,0x4
 61c:	34fd                	addiw	s1,s1,-1
 61e:	f4f5                	bnez	s1,60a <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 620:	8be6                	mv	s7,s9
      state = 0;
 622:	4981                	li	s3,0
 624:	6ca2                	ld	s9,8(sp)
 626:	bda5                	j	49e <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 628:	008b8493          	addi	s1,s7,8
 62c:	000bc583          	lbu	a1,0(s7)
 630:	855a                	mv	a0,s6
 632:	d6dff0ef          	jal	39e <putc>
 636:	8ba6                	mv	s7,s1
      state = 0;
 638:	4981                	li	s3,0
 63a:	b595                	j	49e <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 63c:	008b8993          	addi	s3,s7,8
 640:	000bb483          	ld	s1,0(s7)
 644:	cc91                	beqz	s1,660 <vprintf+0x206>
        for(; *s; s++)
 646:	0004c583          	lbu	a1,0(s1)
 64a:	c985                	beqz	a1,67a <vprintf+0x220>
          putc(fd, *s);
 64c:	855a                	mv	a0,s6
 64e:	d51ff0ef          	jal	39e <putc>
        for(; *s; s++)
 652:	0485                	addi	s1,s1,1
 654:	0004c583          	lbu	a1,0(s1)
 658:	f9f5                	bnez	a1,64c <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 65a:	8bce                	mv	s7,s3
      state = 0;
 65c:	4981                	li	s3,0
 65e:	b581                	j	49e <vprintf+0x44>
          s = "(null)";
 660:	00000497          	auipc	s1,0x0
 664:	2c848493          	addi	s1,s1,712 # 928 <malloc+0x12c>
        for(; *s; s++)
 668:	02800593          	li	a1,40
 66c:	b7c5                	j	64c <vprintf+0x1f2>
        putc(fd, '%');
 66e:	85be                	mv	a1,a5
 670:	855a                	mv	a0,s6
 672:	d2dff0ef          	jal	39e <putc>
      state = 0;
 676:	4981                	li	s3,0
 678:	b51d                	j	49e <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 67a:	8bce                	mv	s7,s3
      state = 0;
 67c:	4981                	li	s3,0
 67e:	b505                	j	49e <vprintf+0x44>
 680:	6906                	ld	s2,64(sp)
 682:	79e2                	ld	s3,56(sp)
 684:	7a42                	ld	s4,48(sp)
 686:	7aa2                	ld	s5,40(sp)
 688:	7b02                	ld	s6,32(sp)
 68a:	6be2                	ld	s7,24(sp)
 68c:	6c42                	ld	s8,16(sp)
    }
  }
}
 68e:	60e6                	ld	ra,88(sp)
 690:	6446                	ld	s0,80(sp)
 692:	64a6                	ld	s1,72(sp)
 694:	6125                	addi	sp,sp,96
 696:	8082                	ret
      if(c0 == 'd'){
 698:	06400713          	li	a4,100
 69c:	e4e78fe3          	beq	a5,a4,4fa <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 6a0:	f9478693          	addi	a3,a5,-108
 6a4:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 6a8:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6aa:	4701                	li	a4,0
      } else if(c0 == 'u'){
 6ac:	07500513          	li	a0,117
 6b0:	e8a78ce3          	beq	a5,a0,548 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 6b4:	f8b60513          	addi	a0,a2,-117
 6b8:	e119                	bnez	a0,6be <vprintf+0x264>
 6ba:	ea0693e3          	bnez	a3,560 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6be:	f8b58513          	addi	a0,a1,-117
 6c2:	e119                	bnez	a0,6c8 <vprintf+0x26e>
 6c4:	ea071be3          	bnez	a4,57a <vprintf+0x120>
      } else if(c0 == 'x'){
 6c8:	07800513          	li	a0,120
 6cc:	eca784e3          	beq	a5,a0,594 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 6d0:	f8860613          	addi	a2,a2,-120
 6d4:	e219                	bnez	a2,6da <vprintf+0x280>
 6d6:	ec069be3          	bnez	a3,5ac <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6da:	f8858593          	addi	a1,a1,-120
 6de:	e199                	bnez	a1,6e4 <vprintf+0x28a>
 6e0:	ee0713e3          	bnez	a4,5c6 <vprintf+0x16c>
      } else if(c0 == 'p'){
 6e4:	07000713          	li	a4,112
 6e8:	eee78ce3          	beq	a5,a4,5e0 <vprintf+0x186>
      } else if(c0 == 'c'){
 6ec:	06300713          	li	a4,99
 6f0:	f2e78ce3          	beq	a5,a4,628 <vprintf+0x1ce>
      } else if(c0 == 's'){
 6f4:	07300713          	li	a4,115
 6f8:	f4e782e3          	beq	a5,a4,63c <vprintf+0x1e2>
      } else if(c0 == '%'){
 6fc:	02500713          	li	a4,37
 700:	f6e787e3          	beq	a5,a4,66e <vprintf+0x214>
        putc(fd, '%');
 704:	02500593          	li	a1,37
 708:	855a                	mv	a0,s6
 70a:	c95ff0ef          	jal	39e <putc>
        putc(fd, c0);
 70e:	85a6                	mv	a1,s1
 710:	855a                	mv	a0,s6
 712:	c8dff0ef          	jal	39e <putc>
      state = 0;
 716:	4981                	li	s3,0
 718:	b359                	j	49e <vprintf+0x44>

000000000000071a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 71a:	715d                	addi	sp,sp,-80
 71c:	ec06                	sd	ra,24(sp)
 71e:	e822                	sd	s0,16(sp)
 720:	1000                	addi	s0,sp,32
 722:	e010                	sd	a2,0(s0)
 724:	e414                	sd	a3,8(s0)
 726:	e818                	sd	a4,16(s0)
 728:	ec1c                	sd	a5,24(s0)
 72a:	03043023          	sd	a6,32(s0)
 72e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 732:	8622                	mv	a2,s0
 734:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 738:	d23ff0ef          	jal	45a <vprintf>
}
 73c:	60e2                	ld	ra,24(sp)
 73e:	6442                	ld	s0,16(sp)
 740:	6161                	addi	sp,sp,80
 742:	8082                	ret

0000000000000744 <printf>:

void
printf(const char *fmt, ...)
{
 744:	711d                	addi	sp,sp,-96
 746:	ec06                	sd	ra,24(sp)
 748:	e822                	sd	s0,16(sp)
 74a:	1000                	addi	s0,sp,32
 74c:	e40c                	sd	a1,8(s0)
 74e:	e810                	sd	a2,16(s0)
 750:	ec14                	sd	a3,24(s0)
 752:	f018                	sd	a4,32(s0)
 754:	f41c                	sd	a5,40(s0)
 756:	03043823          	sd	a6,48(s0)
 75a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 75e:	00840613          	addi	a2,s0,8
 762:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 766:	85aa                	mv	a1,a0
 768:	4505                	li	a0,1
 76a:	cf1ff0ef          	jal	45a <vprintf>
}
 76e:	60e2                	ld	ra,24(sp)
 770:	6442                	ld	s0,16(sp)
 772:	6125                	addi	sp,sp,96
 774:	8082                	ret

0000000000000776 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 776:	1141                	addi	sp,sp,-16
 778:	e406                	sd	ra,8(sp)
 77a:	e022                	sd	s0,0(sp)
 77c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 77e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 782:	00001797          	auipc	a5,0x1
 786:	87e7b783          	ld	a5,-1922(a5) # 1000 <freep>
 78a:	a039                	j	798 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 78c:	6398                	ld	a4,0(a5)
 78e:	00e7e463          	bltu	a5,a4,796 <free+0x20>
 792:	00e6ea63          	bltu	a3,a4,7a6 <free+0x30>
{
 796:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 798:	fed7fae3          	bgeu	a5,a3,78c <free+0x16>
 79c:	6398                	ld	a4,0(a5)
 79e:	00e6e463          	bltu	a3,a4,7a6 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a2:	fee7eae3          	bltu	a5,a4,796 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7a6:	ff852583          	lw	a1,-8(a0)
 7aa:	6390                	ld	a2,0(a5)
 7ac:	02059813          	slli	a6,a1,0x20
 7b0:	01c85713          	srli	a4,a6,0x1c
 7b4:	9736                	add	a4,a4,a3
 7b6:	02e60563          	beq	a2,a4,7e0 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 7ba:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 7be:	4790                	lw	a2,8(a5)
 7c0:	02061593          	slli	a1,a2,0x20
 7c4:	01c5d713          	srli	a4,a1,0x1c
 7c8:	973e                	add	a4,a4,a5
 7ca:	02e68263          	beq	a3,a4,7ee <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 7ce:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7d0:	00001717          	auipc	a4,0x1
 7d4:	82f73823          	sd	a5,-2000(a4) # 1000 <freep>
}
 7d8:	60a2                	ld	ra,8(sp)
 7da:	6402                	ld	s0,0(sp)
 7dc:	0141                	addi	sp,sp,16
 7de:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 7e0:	4618                	lw	a4,8(a2)
 7e2:	9f2d                	addw	a4,a4,a1
 7e4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7e8:	6398                	ld	a4,0(a5)
 7ea:	6310                	ld	a2,0(a4)
 7ec:	b7f9                	j	7ba <free+0x44>
    p->s.size += bp->s.size;
 7ee:	ff852703          	lw	a4,-8(a0)
 7f2:	9f31                	addw	a4,a4,a2
 7f4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7f6:	ff053683          	ld	a3,-16(a0)
 7fa:	bfd1                	j	7ce <free+0x58>

00000000000007fc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7fc:	7139                	addi	sp,sp,-64
 7fe:	fc06                	sd	ra,56(sp)
 800:	f822                	sd	s0,48(sp)
 802:	f04a                	sd	s2,32(sp)
 804:	ec4e                	sd	s3,24(sp)
 806:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 808:	02051993          	slli	s3,a0,0x20
 80c:	0209d993          	srli	s3,s3,0x20
 810:	09bd                	addi	s3,s3,15
 812:	0049d993          	srli	s3,s3,0x4
 816:	2985                	addiw	s3,s3,1
 818:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 81a:	00000517          	auipc	a0,0x0
 81e:	7e653503          	ld	a0,2022(a0) # 1000 <freep>
 822:	c905                	beqz	a0,852 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 824:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 826:	4798                	lw	a4,8(a5)
 828:	09377663          	bgeu	a4,s3,8b4 <malloc+0xb8>
 82c:	f426                	sd	s1,40(sp)
 82e:	e852                	sd	s4,16(sp)
 830:	e456                	sd	s5,8(sp)
 832:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 834:	8a4e                	mv	s4,s3
 836:	6705                	lui	a4,0x1
 838:	00e9f363          	bgeu	s3,a4,83e <malloc+0x42>
 83c:	6a05                	lui	s4,0x1
 83e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 842:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 846:	00000497          	auipc	s1,0x0
 84a:	7ba48493          	addi	s1,s1,1978 # 1000 <freep>
  if(p == SBRK_ERROR)
 84e:	5afd                	li	s5,-1
 850:	a83d                	j	88e <malloc+0x92>
 852:	f426                	sd	s1,40(sp)
 854:	e852                	sd	s4,16(sp)
 856:	e456                	sd	s5,8(sp)
 858:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 85a:	00000797          	auipc	a5,0x0
 85e:	7b678793          	addi	a5,a5,1974 # 1010 <base>
 862:	00000717          	auipc	a4,0x0
 866:	78f73f23          	sd	a5,1950(a4) # 1000 <freep>
 86a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 86c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 870:	b7d1                	j	834 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 872:	6398                	ld	a4,0(a5)
 874:	e118                	sd	a4,0(a0)
 876:	a899                	j	8cc <malloc+0xd0>
  hp->s.size = nu;
 878:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 87c:	0541                	addi	a0,a0,16
 87e:	ef9ff0ef          	jal	776 <free>
  return freep;
 882:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 884:	c125                	beqz	a0,8e4 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 886:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 888:	4798                	lw	a4,8(a5)
 88a:	03277163          	bgeu	a4,s2,8ac <malloc+0xb0>
    if(p == freep)
 88e:	6098                	ld	a4,0(s1)
 890:	853e                	mv	a0,a5
 892:	fef71ae3          	bne	a4,a5,886 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 896:	8552                	mv	a0,s4
 898:	a23ff0ef          	jal	2ba <sbrk>
  if(p == SBRK_ERROR)
 89c:	fd551ee3          	bne	a0,s5,878 <malloc+0x7c>
        return 0;
 8a0:	4501                	li	a0,0
 8a2:	74a2                	ld	s1,40(sp)
 8a4:	6a42                	ld	s4,16(sp)
 8a6:	6aa2                	ld	s5,8(sp)
 8a8:	6b02                	ld	s6,0(sp)
 8aa:	a03d                	j	8d8 <malloc+0xdc>
 8ac:	74a2                	ld	s1,40(sp)
 8ae:	6a42                	ld	s4,16(sp)
 8b0:	6aa2                	ld	s5,8(sp)
 8b2:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8b4:	fae90fe3          	beq	s2,a4,872 <malloc+0x76>
        p->s.size -= nunits;
 8b8:	4137073b          	subw	a4,a4,s3
 8bc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8be:	02071693          	slli	a3,a4,0x20
 8c2:	01c6d713          	srli	a4,a3,0x1c
 8c6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8c8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8cc:	00000717          	auipc	a4,0x0
 8d0:	72a73a23          	sd	a0,1844(a4) # 1000 <freep>
      return (void*)(p + 1);
 8d4:	01078513          	addi	a0,a5,16
  }
}
 8d8:	70e2                	ld	ra,56(sp)
 8da:	7442                	ld	s0,48(sp)
 8dc:	7902                	ld	s2,32(sp)
 8de:	69e2                	ld	s3,24(sp)
 8e0:	6121                	addi	sp,sp,64
 8e2:	8082                	ret
 8e4:	74a2                	ld	s1,40(sp)
 8e6:	6a42                	ld	s4,16(sp)
 8e8:	6aa2                	ld	s5,8(sp)
 8ea:	6b02                	ld	s6,0(sp)
 8ec:	b7f5                	j	8d8 <malloc+0xdc>
