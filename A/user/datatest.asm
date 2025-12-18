
user/_datatest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int global = 12345;  // should live in .data

int main() {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  printf("Global var: %d\n", global);  // read from data segment
   8:	00001597          	auipc	a1,0x1
   c:	ff85a583          	lw	a1,-8(a1) # 1000 <global>
  10:	00001517          	auipc	a0,0x1
  14:	8d050513          	addi	a0,a0,-1840 # 8e0 <malloc+0xfa>
  18:	716000ef          	jal	72e <printf>
  exit(0);
  1c:	4501                	li	a0,0
  1e:	2ba000ef          	jal	2d8 <exit>

0000000000000022 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  22:	1141                	addi	sp,sp,-16
  24:	e406                	sd	ra,8(sp)
  26:	e022                	sd	s0,0(sp)
  28:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  2a:	fd7ff0ef          	jal	0 <main>
  exit(r);
  2e:	2aa000ef          	jal	2d8 <exit>

0000000000000032 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  32:	1141                	addi	sp,sp,-16
  34:	e406                	sd	ra,8(sp)
  36:	e022                	sd	s0,0(sp)
  38:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  3a:	87aa                	mv	a5,a0
  3c:	0585                	addi	a1,a1,1
  3e:	0785                	addi	a5,a5,1
  40:	fff5c703          	lbu	a4,-1(a1)
  44:	fee78fa3          	sb	a4,-1(a5)
  48:	fb75                	bnez	a4,3c <strcpy+0xa>
    ;
  return os;
}
  4a:	60a2                	ld	ra,8(sp)
  4c:	6402                	ld	s0,0(sp)
  4e:	0141                	addi	sp,sp,16
  50:	8082                	ret

0000000000000052 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  52:	1141                	addi	sp,sp,-16
  54:	e406                	sd	ra,8(sp)
  56:	e022                	sd	s0,0(sp)
  58:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  5a:	00054783          	lbu	a5,0(a0)
  5e:	cb91                	beqz	a5,72 <strcmp+0x20>
  60:	0005c703          	lbu	a4,0(a1)
  64:	00f71763          	bne	a4,a5,72 <strcmp+0x20>
    p++, q++;
  68:	0505                	addi	a0,a0,1
  6a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  6c:	00054783          	lbu	a5,0(a0)
  70:	fbe5                	bnez	a5,60 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  72:	0005c503          	lbu	a0,0(a1)
}
  76:	40a7853b          	subw	a0,a5,a0
  7a:	60a2                	ld	ra,8(sp)
  7c:	6402                	ld	s0,0(sp)
  7e:	0141                	addi	sp,sp,16
  80:	8082                	ret

0000000000000082 <strlen>:

uint
strlen(const char *s)
{
  82:	1141                	addi	sp,sp,-16
  84:	e406                	sd	ra,8(sp)
  86:	e022                	sd	s0,0(sp)
  88:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  8a:	00054783          	lbu	a5,0(a0)
  8e:	cf91                	beqz	a5,aa <strlen+0x28>
  90:	00150793          	addi	a5,a0,1
  94:	86be                	mv	a3,a5
  96:	0785                	addi	a5,a5,1
  98:	fff7c703          	lbu	a4,-1(a5)
  9c:	ff65                	bnez	a4,94 <strlen+0x12>
  9e:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
  a2:	60a2                	ld	ra,8(sp)
  a4:	6402                	ld	s0,0(sp)
  a6:	0141                	addi	sp,sp,16
  a8:	8082                	ret
  for(n = 0; s[n]; n++)
  aa:	4501                	li	a0,0
  ac:	bfdd                	j	a2 <strlen+0x20>

00000000000000ae <memset>:

void*
memset(void *dst, int c, uint n)
{
  ae:	1141                	addi	sp,sp,-16
  b0:	e406                	sd	ra,8(sp)
  b2:	e022                	sd	s0,0(sp)
  b4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  b6:	ca19                	beqz	a2,cc <memset+0x1e>
  b8:	87aa                	mv	a5,a0
  ba:	1602                	slli	a2,a2,0x20
  bc:	9201                	srli	a2,a2,0x20
  be:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  c2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  c6:	0785                	addi	a5,a5,1
  c8:	fee79de3          	bne	a5,a4,c2 <memset+0x14>
  }
  return dst;
}
  cc:	60a2                	ld	ra,8(sp)
  ce:	6402                	ld	s0,0(sp)
  d0:	0141                	addi	sp,sp,16
  d2:	8082                	ret

00000000000000d4 <strchr>:

char*
strchr(const char *s, char c)
{
  d4:	1141                	addi	sp,sp,-16
  d6:	e406                	sd	ra,8(sp)
  d8:	e022                	sd	s0,0(sp)
  da:	0800                	addi	s0,sp,16
  for(; *s; s++)
  dc:	00054783          	lbu	a5,0(a0)
  e0:	cf81                	beqz	a5,f8 <strchr+0x24>
    if(*s == c)
  e2:	00f58763          	beq	a1,a5,f0 <strchr+0x1c>
  for(; *s; s++)
  e6:	0505                	addi	a0,a0,1
  e8:	00054783          	lbu	a5,0(a0)
  ec:	fbfd                	bnez	a5,e2 <strchr+0xe>
      return (char*)s;
  return 0;
  ee:	4501                	li	a0,0
}
  f0:	60a2                	ld	ra,8(sp)
  f2:	6402                	ld	s0,0(sp)
  f4:	0141                	addi	sp,sp,16
  f6:	8082                	ret
  return 0;
  f8:	4501                	li	a0,0
  fa:	bfdd                	j	f0 <strchr+0x1c>

00000000000000fc <gets>:

char*
gets(char *buf, int max)
{
  fc:	711d                	addi	sp,sp,-96
  fe:	ec86                	sd	ra,88(sp)
 100:	e8a2                	sd	s0,80(sp)
 102:	e4a6                	sd	s1,72(sp)
 104:	e0ca                	sd	s2,64(sp)
 106:	fc4e                	sd	s3,56(sp)
 108:	f852                	sd	s4,48(sp)
 10a:	f456                	sd	s5,40(sp)
 10c:	f05a                	sd	s6,32(sp)
 10e:	ec5e                	sd	s7,24(sp)
 110:	e862                	sd	s8,16(sp)
 112:	1080                	addi	s0,sp,96
 114:	8baa                	mv	s7,a0
 116:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 118:	892a                	mv	s2,a0
 11a:	4481                	li	s1,0
    cc = read(0, &c, 1);
 11c:	faf40b13          	addi	s6,s0,-81
 120:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 122:	8c26                	mv	s8,s1
 124:	0014899b          	addiw	s3,s1,1
 128:	84ce                	mv	s1,s3
 12a:	0349d463          	bge	s3,s4,152 <gets+0x56>
    cc = read(0, &c, 1);
 12e:	8656                	mv	a2,s5
 130:	85da                	mv	a1,s6
 132:	4501                	li	a0,0
 134:	1bc000ef          	jal	2f0 <read>
    if(cc < 1)
 138:	00a05d63          	blez	a0,152 <gets+0x56>
      break;
    buf[i++] = c;
 13c:	faf44783          	lbu	a5,-81(s0)
 140:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 144:	0905                	addi	s2,s2,1
 146:	ff678713          	addi	a4,a5,-10
 14a:	c319                	beqz	a4,150 <gets+0x54>
 14c:	17cd                	addi	a5,a5,-13
 14e:	fbf1                	bnez	a5,122 <gets+0x26>
    buf[i++] = c;
 150:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 152:	9c5e                	add	s8,s8,s7
 154:	000c0023          	sb	zero,0(s8)
  return buf;
}
 158:	855e                	mv	a0,s7
 15a:	60e6                	ld	ra,88(sp)
 15c:	6446                	ld	s0,80(sp)
 15e:	64a6                	ld	s1,72(sp)
 160:	6906                	ld	s2,64(sp)
 162:	79e2                	ld	s3,56(sp)
 164:	7a42                	ld	s4,48(sp)
 166:	7aa2                	ld	s5,40(sp)
 168:	7b02                	ld	s6,32(sp)
 16a:	6be2                	ld	s7,24(sp)
 16c:	6c42                	ld	s8,16(sp)
 16e:	6125                	addi	sp,sp,96
 170:	8082                	ret

0000000000000172 <stat>:

int
stat(const char *n, struct stat *st)
{
 172:	1101                	addi	sp,sp,-32
 174:	ec06                	sd	ra,24(sp)
 176:	e822                	sd	s0,16(sp)
 178:	e04a                	sd	s2,0(sp)
 17a:	1000                	addi	s0,sp,32
 17c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 17e:	4581                	li	a1,0
 180:	198000ef          	jal	318 <open>
  if(fd < 0)
 184:	02054263          	bltz	a0,1a8 <stat+0x36>
 188:	e426                	sd	s1,8(sp)
 18a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 18c:	85ca                	mv	a1,s2
 18e:	1a2000ef          	jal	330 <fstat>
 192:	892a                	mv	s2,a0
  close(fd);
 194:	8526                	mv	a0,s1
 196:	16a000ef          	jal	300 <close>
  return r;
 19a:	64a2                	ld	s1,8(sp)
}
 19c:	854a                	mv	a0,s2
 19e:	60e2                	ld	ra,24(sp)
 1a0:	6442                	ld	s0,16(sp)
 1a2:	6902                	ld	s2,0(sp)
 1a4:	6105                	addi	sp,sp,32
 1a6:	8082                	ret
    return -1;
 1a8:	57fd                	li	a5,-1
 1aa:	893e                	mv	s2,a5
 1ac:	bfc5                	j	19c <stat+0x2a>

00000000000001ae <atoi>:

int
atoi(const char *s)
{
 1ae:	1141                	addi	sp,sp,-16
 1b0:	e406                	sd	ra,8(sp)
 1b2:	e022                	sd	s0,0(sp)
 1b4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1b6:	00054683          	lbu	a3,0(a0)
 1ba:	fd06879b          	addiw	a5,a3,-48
 1be:	0ff7f793          	zext.b	a5,a5
 1c2:	4625                	li	a2,9
 1c4:	02f66963          	bltu	a2,a5,1f6 <atoi+0x48>
 1c8:	872a                	mv	a4,a0
  n = 0;
 1ca:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1cc:	0705                	addi	a4,a4,1
 1ce:	0025179b          	slliw	a5,a0,0x2
 1d2:	9fa9                	addw	a5,a5,a0
 1d4:	0017979b          	slliw	a5,a5,0x1
 1d8:	9fb5                	addw	a5,a5,a3
 1da:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1de:	00074683          	lbu	a3,0(a4)
 1e2:	fd06879b          	addiw	a5,a3,-48
 1e6:	0ff7f793          	zext.b	a5,a5
 1ea:	fef671e3          	bgeu	a2,a5,1cc <atoi+0x1e>
  return n;
}
 1ee:	60a2                	ld	ra,8(sp)
 1f0:	6402                	ld	s0,0(sp)
 1f2:	0141                	addi	sp,sp,16
 1f4:	8082                	ret
  n = 0;
 1f6:	4501                	li	a0,0
 1f8:	bfdd                	j	1ee <atoi+0x40>

00000000000001fa <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1fa:	1141                	addi	sp,sp,-16
 1fc:	e406                	sd	ra,8(sp)
 1fe:	e022                	sd	s0,0(sp)
 200:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 202:	02b57563          	bgeu	a0,a1,22c <memmove+0x32>
    while(n-- > 0)
 206:	00c05f63          	blez	a2,224 <memmove+0x2a>
 20a:	1602                	slli	a2,a2,0x20
 20c:	9201                	srli	a2,a2,0x20
 20e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 212:	872a                	mv	a4,a0
      *dst++ = *src++;
 214:	0585                	addi	a1,a1,1
 216:	0705                	addi	a4,a4,1
 218:	fff5c683          	lbu	a3,-1(a1)
 21c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 220:	fee79ae3          	bne	a5,a4,214 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 224:	60a2                	ld	ra,8(sp)
 226:	6402                	ld	s0,0(sp)
 228:	0141                	addi	sp,sp,16
 22a:	8082                	ret
    while(n-- > 0)
 22c:	fec05ce3          	blez	a2,224 <memmove+0x2a>
    dst += n;
 230:	00c50733          	add	a4,a0,a2
    src += n;
 234:	95b2                	add	a1,a1,a2
 236:	fff6079b          	addiw	a5,a2,-1
 23a:	1782                	slli	a5,a5,0x20
 23c:	9381                	srli	a5,a5,0x20
 23e:	fff7c793          	not	a5,a5
 242:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 244:	15fd                	addi	a1,a1,-1
 246:	177d                	addi	a4,a4,-1
 248:	0005c683          	lbu	a3,0(a1)
 24c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 250:	fef71ae3          	bne	a4,a5,244 <memmove+0x4a>
 254:	bfc1                	j	224 <memmove+0x2a>

0000000000000256 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 256:	1141                	addi	sp,sp,-16
 258:	e406                	sd	ra,8(sp)
 25a:	e022                	sd	s0,0(sp)
 25c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 25e:	c61d                	beqz	a2,28c <memcmp+0x36>
 260:	1602                	slli	a2,a2,0x20
 262:	9201                	srli	a2,a2,0x20
 264:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 268:	00054783          	lbu	a5,0(a0)
 26c:	0005c703          	lbu	a4,0(a1)
 270:	00e79863          	bne	a5,a4,280 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 274:	0505                	addi	a0,a0,1
    p2++;
 276:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 278:	fed518e3          	bne	a0,a3,268 <memcmp+0x12>
  }
  return 0;
 27c:	4501                	li	a0,0
 27e:	a019                	j	284 <memcmp+0x2e>
      return *p1 - *p2;
 280:	40e7853b          	subw	a0,a5,a4
}
 284:	60a2                	ld	ra,8(sp)
 286:	6402                	ld	s0,0(sp)
 288:	0141                	addi	sp,sp,16
 28a:	8082                	ret
  return 0;
 28c:	4501                	li	a0,0
 28e:	bfdd                	j	284 <memcmp+0x2e>

0000000000000290 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 290:	1141                	addi	sp,sp,-16
 292:	e406                	sd	ra,8(sp)
 294:	e022                	sd	s0,0(sp)
 296:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 298:	f63ff0ef          	jal	1fa <memmove>
}
 29c:	60a2                	ld	ra,8(sp)
 29e:	6402                	ld	s0,0(sp)
 2a0:	0141                	addi	sp,sp,16
 2a2:	8082                	ret

00000000000002a4 <sbrk>:

char *
sbrk(int n) {
 2a4:	1141                	addi	sp,sp,-16
 2a6:	e406                	sd	ra,8(sp)
 2a8:	e022                	sd	s0,0(sp)
 2aa:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2ac:	4585                	li	a1,1
 2ae:	0b2000ef          	jal	360 <sys_sbrk>
}
 2b2:	60a2                	ld	ra,8(sp)
 2b4:	6402                	ld	s0,0(sp)
 2b6:	0141                	addi	sp,sp,16
 2b8:	8082                	ret

00000000000002ba <sbrklazy>:

char *
sbrklazy(int n) {
 2ba:	1141                	addi	sp,sp,-16
 2bc:	e406                	sd	ra,8(sp)
 2be:	e022                	sd	s0,0(sp)
 2c0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2c2:	4589                	li	a1,2
 2c4:	09c000ef          	jal	360 <sys_sbrk>
}
 2c8:	60a2                	ld	ra,8(sp)
 2ca:	6402                	ld	s0,0(sp)
 2cc:	0141                	addi	sp,sp,16
 2ce:	8082                	ret

00000000000002d0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2d0:	4885                	li	a7,1
 ecall
 2d2:	00000073          	ecall
 ret
 2d6:	8082                	ret

00000000000002d8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2d8:	4889                	li	a7,2
 ecall
 2da:	00000073          	ecall
 ret
 2de:	8082                	ret

00000000000002e0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2e0:	488d                	li	a7,3
 ecall
 2e2:	00000073          	ecall
 ret
 2e6:	8082                	ret

00000000000002e8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2e8:	4891                	li	a7,4
 ecall
 2ea:	00000073          	ecall
 ret
 2ee:	8082                	ret

00000000000002f0 <read>:
.global read
read:
 li a7, SYS_read
 2f0:	4895                	li	a7,5
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <write>:
.global write
write:
 li a7, SYS_write
 2f8:	48c1                	li	a7,16
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <close>:
.global close
close:
 li a7, SYS_close
 300:	48d5                	li	a7,21
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <kill>:
.global kill
kill:
 li a7, SYS_kill
 308:	4899                	li	a7,6
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <exec>:
.global exec
exec:
 li a7, SYS_exec
 310:	489d                	li	a7,7
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <open>:
.global open
open:
 li a7, SYS_open
 318:	48bd                	li	a7,15
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 320:	48c5                	li	a7,17
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 328:	48c9                	li	a7,18
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 330:	48a1                	li	a7,8
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <link>:
.global link
link:
 li a7, SYS_link
 338:	48cd                	li	a7,19
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 340:	48d1                	li	a7,20
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 348:	48a5                	li	a7,9
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <dup>:
.global dup
dup:
 li a7, SYS_dup
 350:	48a9                	li	a7,10
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 358:	48ad                	li	a7,11
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 360:	48b1                	li	a7,12
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <pause>:
.global pause
pause:
 li a7, SYS_pause
 368:	48b5                	li	a7,13
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 370:	48b9                	li	a7,14
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <memstat>:
.global memstat
memstat:
 li a7, SYS_memstat
 378:	48d9                	li	a7,22
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <enable_bonus>:
.global enable_bonus
enable_bonus:
 li a7, SYS_enable_bonus
 380:	48dd                	li	a7,23
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 388:	1101                	addi	sp,sp,-32
 38a:	ec06                	sd	ra,24(sp)
 38c:	e822                	sd	s0,16(sp)
 38e:	1000                	addi	s0,sp,32
 390:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 394:	4605                	li	a2,1
 396:	fef40593          	addi	a1,s0,-17
 39a:	f5fff0ef          	jal	2f8 <write>
}
 39e:	60e2                	ld	ra,24(sp)
 3a0:	6442                	ld	s0,16(sp)
 3a2:	6105                	addi	sp,sp,32
 3a4:	8082                	ret

00000000000003a6 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3a6:	715d                	addi	sp,sp,-80
 3a8:	e486                	sd	ra,72(sp)
 3aa:	e0a2                	sd	s0,64(sp)
 3ac:	f84a                	sd	s2,48(sp)
 3ae:	f44e                	sd	s3,40(sp)
 3b0:	0880                	addi	s0,sp,80
 3b2:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3b4:	c6d1                	beqz	a3,440 <printint+0x9a>
 3b6:	0805d563          	bgez	a1,440 <printint+0x9a>
    neg = 1;
    x = -xx;
 3ba:	40b005b3          	neg	a1,a1
    neg = 1;
 3be:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 3c0:	fb840993          	addi	s3,s0,-72
  neg = 0;
 3c4:	86ce                	mv	a3,s3
  i = 0;
 3c6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3c8:	00000817          	auipc	a6,0x0
 3cc:	53080813          	addi	a6,a6,1328 # 8f8 <digits>
 3d0:	88ba                	mv	a7,a4
 3d2:	0017051b          	addiw	a0,a4,1
 3d6:	872a                	mv	a4,a0
 3d8:	02c5f7b3          	remu	a5,a1,a2
 3dc:	97c2                	add	a5,a5,a6
 3de:	0007c783          	lbu	a5,0(a5)
 3e2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3e6:	87ae                	mv	a5,a1
 3e8:	02c5d5b3          	divu	a1,a1,a2
 3ec:	0685                	addi	a3,a3,1
 3ee:	fec7f1e3          	bgeu	a5,a2,3d0 <printint+0x2a>
  if(neg)
 3f2:	00030c63          	beqz	t1,40a <printint+0x64>
    buf[i++] = '-';
 3f6:	fd050793          	addi	a5,a0,-48
 3fa:	00878533          	add	a0,a5,s0
 3fe:	02d00793          	li	a5,45
 402:	fef50423          	sb	a5,-24(a0)
 406:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 40a:	02e05563          	blez	a4,434 <printint+0x8e>
 40e:	fc26                	sd	s1,56(sp)
 410:	377d                	addiw	a4,a4,-1
 412:	00e984b3          	add	s1,s3,a4
 416:	19fd                	addi	s3,s3,-1
 418:	99ba                	add	s3,s3,a4
 41a:	1702                	slli	a4,a4,0x20
 41c:	9301                	srli	a4,a4,0x20
 41e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 422:	0004c583          	lbu	a1,0(s1)
 426:	854a                	mv	a0,s2
 428:	f61ff0ef          	jal	388 <putc>
  while(--i >= 0)
 42c:	14fd                	addi	s1,s1,-1
 42e:	ff349ae3          	bne	s1,s3,422 <printint+0x7c>
 432:	74e2                	ld	s1,56(sp)
}
 434:	60a6                	ld	ra,72(sp)
 436:	6406                	ld	s0,64(sp)
 438:	7942                	ld	s2,48(sp)
 43a:	79a2                	ld	s3,40(sp)
 43c:	6161                	addi	sp,sp,80
 43e:	8082                	ret
  neg = 0;
 440:	4301                	li	t1,0
 442:	bfbd                	j	3c0 <printint+0x1a>

0000000000000444 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 444:	711d                	addi	sp,sp,-96
 446:	ec86                	sd	ra,88(sp)
 448:	e8a2                	sd	s0,80(sp)
 44a:	e4a6                	sd	s1,72(sp)
 44c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 44e:	0005c483          	lbu	s1,0(a1)
 452:	22048363          	beqz	s1,678 <vprintf+0x234>
 456:	e0ca                	sd	s2,64(sp)
 458:	fc4e                	sd	s3,56(sp)
 45a:	f852                	sd	s4,48(sp)
 45c:	f456                	sd	s5,40(sp)
 45e:	f05a                	sd	s6,32(sp)
 460:	ec5e                	sd	s7,24(sp)
 462:	e862                	sd	s8,16(sp)
 464:	8b2a                	mv	s6,a0
 466:	8a2e                	mv	s4,a1
 468:	8bb2                	mv	s7,a2
  state = 0;
 46a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 46c:	4901                	li	s2,0
 46e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 470:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 474:	06400c13          	li	s8,100
 478:	a00d                	j	49a <vprintf+0x56>
        putc(fd, c0);
 47a:	85a6                	mv	a1,s1
 47c:	855a                	mv	a0,s6
 47e:	f0bff0ef          	jal	388 <putc>
 482:	a019                	j	488 <vprintf+0x44>
    } else if(state == '%'){
 484:	03598363          	beq	s3,s5,4aa <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 488:	0019079b          	addiw	a5,s2,1
 48c:	893e                	mv	s2,a5
 48e:	873e                	mv	a4,a5
 490:	97d2                	add	a5,a5,s4
 492:	0007c483          	lbu	s1,0(a5)
 496:	1c048a63          	beqz	s1,66a <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 49a:	0004879b          	sext.w	a5,s1
    if(state == 0){
 49e:	fe0993e3          	bnez	s3,484 <vprintf+0x40>
      if(c0 == '%'){
 4a2:	fd579ce3          	bne	a5,s5,47a <vprintf+0x36>
        state = '%';
 4a6:	89be                	mv	s3,a5
 4a8:	b7c5                	j	488 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 4aa:	00ea06b3          	add	a3,s4,a4
 4ae:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 4b2:	1c060863          	beqz	a2,682 <vprintf+0x23e>
      if(c0 == 'd'){
 4b6:	03878763          	beq	a5,s8,4e4 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4ba:	f9478693          	addi	a3,a5,-108
 4be:	0016b693          	seqz	a3,a3
 4c2:	f9c60593          	addi	a1,a2,-100
 4c6:	e99d                	bnez	a1,4fc <vprintf+0xb8>
 4c8:	ca95                	beqz	a3,4fc <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 4ca:	008b8493          	addi	s1,s7,8
 4ce:	4685                	li	a3,1
 4d0:	4629                	li	a2,10
 4d2:	000bb583          	ld	a1,0(s7)
 4d6:	855a                	mv	a0,s6
 4d8:	ecfff0ef          	jal	3a6 <printint>
        i += 1;
 4dc:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 4de:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 4e0:	4981                	li	s3,0
 4e2:	b75d                	j	488 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 4e4:	008b8493          	addi	s1,s7,8
 4e8:	4685                	li	a3,1
 4ea:	4629                	li	a2,10
 4ec:	000ba583          	lw	a1,0(s7)
 4f0:	855a                	mv	a0,s6
 4f2:	eb5ff0ef          	jal	3a6 <printint>
 4f6:	8ba6                	mv	s7,s1
      state = 0;
 4f8:	4981                	li	s3,0
 4fa:	b779                	j	488 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 4fc:	9752                	add	a4,a4,s4
 4fe:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 502:	f9460713          	addi	a4,a2,-108
 506:	00173713          	seqz	a4,a4
 50a:	8f75                	and	a4,a4,a3
 50c:	f9c58513          	addi	a0,a1,-100
 510:	18051363          	bnez	a0,696 <vprintf+0x252>
 514:	18070163          	beqz	a4,696 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 518:	008b8493          	addi	s1,s7,8
 51c:	4685                	li	a3,1
 51e:	4629                	li	a2,10
 520:	000bb583          	ld	a1,0(s7)
 524:	855a                	mv	a0,s6
 526:	e81ff0ef          	jal	3a6 <printint>
        i += 2;
 52a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 52c:	8ba6                	mv	s7,s1
      state = 0;
 52e:	4981                	li	s3,0
        i += 2;
 530:	bfa1                	j	488 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 532:	008b8493          	addi	s1,s7,8
 536:	4681                	li	a3,0
 538:	4629                	li	a2,10
 53a:	000be583          	lwu	a1,0(s7)
 53e:	855a                	mv	a0,s6
 540:	e67ff0ef          	jal	3a6 <printint>
 544:	8ba6                	mv	s7,s1
      state = 0;
 546:	4981                	li	s3,0
 548:	b781                	j	488 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 54a:	008b8493          	addi	s1,s7,8
 54e:	4681                	li	a3,0
 550:	4629                	li	a2,10
 552:	000bb583          	ld	a1,0(s7)
 556:	855a                	mv	a0,s6
 558:	e4fff0ef          	jal	3a6 <printint>
        i += 1;
 55c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 55e:	8ba6                	mv	s7,s1
      state = 0;
 560:	4981                	li	s3,0
 562:	b71d                	j	488 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 564:	008b8493          	addi	s1,s7,8
 568:	4681                	li	a3,0
 56a:	4629                	li	a2,10
 56c:	000bb583          	ld	a1,0(s7)
 570:	855a                	mv	a0,s6
 572:	e35ff0ef          	jal	3a6 <printint>
        i += 2;
 576:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 578:	8ba6                	mv	s7,s1
      state = 0;
 57a:	4981                	li	s3,0
        i += 2;
 57c:	b731                	j	488 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 57e:	008b8493          	addi	s1,s7,8
 582:	4681                	li	a3,0
 584:	4641                	li	a2,16
 586:	000be583          	lwu	a1,0(s7)
 58a:	855a                	mv	a0,s6
 58c:	e1bff0ef          	jal	3a6 <printint>
 590:	8ba6                	mv	s7,s1
      state = 0;
 592:	4981                	li	s3,0
 594:	bdd5                	j	488 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 596:	008b8493          	addi	s1,s7,8
 59a:	4681                	li	a3,0
 59c:	4641                	li	a2,16
 59e:	000bb583          	ld	a1,0(s7)
 5a2:	855a                	mv	a0,s6
 5a4:	e03ff0ef          	jal	3a6 <printint>
        i += 1;
 5a8:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 5aa:	8ba6                	mv	s7,s1
      state = 0;
 5ac:	4981                	li	s3,0
 5ae:	bde9                	j	488 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5b0:	008b8493          	addi	s1,s7,8
 5b4:	4681                	li	a3,0
 5b6:	4641                	li	a2,16
 5b8:	000bb583          	ld	a1,0(s7)
 5bc:	855a                	mv	a0,s6
 5be:	de9ff0ef          	jal	3a6 <printint>
        i += 2;
 5c2:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5c4:	8ba6                	mv	s7,s1
      state = 0;
 5c6:	4981                	li	s3,0
        i += 2;
 5c8:	b5c1                	j	488 <vprintf+0x44>
 5ca:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 5cc:	008b8793          	addi	a5,s7,8
 5d0:	8cbe                	mv	s9,a5
 5d2:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5d6:	03000593          	li	a1,48
 5da:	855a                	mv	a0,s6
 5dc:	dadff0ef          	jal	388 <putc>
  putc(fd, 'x');
 5e0:	07800593          	li	a1,120
 5e4:	855a                	mv	a0,s6
 5e6:	da3ff0ef          	jal	388 <putc>
 5ea:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5ec:	00000b97          	auipc	s7,0x0
 5f0:	30cb8b93          	addi	s7,s7,780 # 8f8 <digits>
 5f4:	03c9d793          	srli	a5,s3,0x3c
 5f8:	97de                	add	a5,a5,s7
 5fa:	0007c583          	lbu	a1,0(a5)
 5fe:	855a                	mv	a0,s6
 600:	d89ff0ef          	jal	388 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 604:	0992                	slli	s3,s3,0x4
 606:	34fd                	addiw	s1,s1,-1
 608:	f4f5                	bnez	s1,5f4 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 60a:	8be6                	mv	s7,s9
      state = 0;
 60c:	4981                	li	s3,0
 60e:	6ca2                	ld	s9,8(sp)
 610:	bda5                	j	488 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 612:	008b8493          	addi	s1,s7,8
 616:	000bc583          	lbu	a1,0(s7)
 61a:	855a                	mv	a0,s6
 61c:	d6dff0ef          	jal	388 <putc>
 620:	8ba6                	mv	s7,s1
      state = 0;
 622:	4981                	li	s3,0
 624:	b595                	j	488 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 626:	008b8993          	addi	s3,s7,8
 62a:	000bb483          	ld	s1,0(s7)
 62e:	cc91                	beqz	s1,64a <vprintf+0x206>
        for(; *s; s++)
 630:	0004c583          	lbu	a1,0(s1)
 634:	c985                	beqz	a1,664 <vprintf+0x220>
          putc(fd, *s);
 636:	855a                	mv	a0,s6
 638:	d51ff0ef          	jal	388 <putc>
        for(; *s; s++)
 63c:	0485                	addi	s1,s1,1
 63e:	0004c583          	lbu	a1,0(s1)
 642:	f9f5                	bnez	a1,636 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 644:	8bce                	mv	s7,s3
      state = 0;
 646:	4981                	li	s3,0
 648:	b581                	j	488 <vprintf+0x44>
          s = "(null)";
 64a:	00000497          	auipc	s1,0x0
 64e:	2a648493          	addi	s1,s1,678 # 8f0 <malloc+0x10a>
        for(; *s; s++)
 652:	02800593          	li	a1,40
 656:	b7c5                	j	636 <vprintf+0x1f2>
        putc(fd, '%');
 658:	85be                	mv	a1,a5
 65a:	855a                	mv	a0,s6
 65c:	d2dff0ef          	jal	388 <putc>
      state = 0;
 660:	4981                	li	s3,0
 662:	b51d                	j	488 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 664:	8bce                	mv	s7,s3
      state = 0;
 666:	4981                	li	s3,0
 668:	b505                	j	488 <vprintf+0x44>
 66a:	6906                	ld	s2,64(sp)
 66c:	79e2                	ld	s3,56(sp)
 66e:	7a42                	ld	s4,48(sp)
 670:	7aa2                	ld	s5,40(sp)
 672:	7b02                	ld	s6,32(sp)
 674:	6be2                	ld	s7,24(sp)
 676:	6c42                	ld	s8,16(sp)
    }
  }
}
 678:	60e6                	ld	ra,88(sp)
 67a:	6446                	ld	s0,80(sp)
 67c:	64a6                	ld	s1,72(sp)
 67e:	6125                	addi	sp,sp,96
 680:	8082                	ret
      if(c0 == 'd'){
 682:	06400713          	li	a4,100
 686:	e4e78fe3          	beq	a5,a4,4e4 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 68a:	f9478693          	addi	a3,a5,-108
 68e:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 692:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 694:	4701                	li	a4,0
      } else if(c0 == 'u'){
 696:	07500513          	li	a0,117
 69a:	e8a78ce3          	beq	a5,a0,532 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 69e:	f8b60513          	addi	a0,a2,-117
 6a2:	e119                	bnez	a0,6a8 <vprintf+0x264>
 6a4:	ea0693e3          	bnez	a3,54a <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6a8:	f8b58513          	addi	a0,a1,-117
 6ac:	e119                	bnez	a0,6b2 <vprintf+0x26e>
 6ae:	ea071be3          	bnez	a4,564 <vprintf+0x120>
      } else if(c0 == 'x'){
 6b2:	07800513          	li	a0,120
 6b6:	eca784e3          	beq	a5,a0,57e <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 6ba:	f8860613          	addi	a2,a2,-120
 6be:	e219                	bnez	a2,6c4 <vprintf+0x280>
 6c0:	ec069be3          	bnez	a3,596 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6c4:	f8858593          	addi	a1,a1,-120
 6c8:	e199                	bnez	a1,6ce <vprintf+0x28a>
 6ca:	ee0713e3          	bnez	a4,5b0 <vprintf+0x16c>
      } else if(c0 == 'p'){
 6ce:	07000713          	li	a4,112
 6d2:	eee78ce3          	beq	a5,a4,5ca <vprintf+0x186>
      } else if(c0 == 'c'){
 6d6:	06300713          	li	a4,99
 6da:	f2e78ce3          	beq	a5,a4,612 <vprintf+0x1ce>
      } else if(c0 == 's'){
 6de:	07300713          	li	a4,115
 6e2:	f4e782e3          	beq	a5,a4,626 <vprintf+0x1e2>
      } else if(c0 == '%'){
 6e6:	02500713          	li	a4,37
 6ea:	f6e787e3          	beq	a5,a4,658 <vprintf+0x214>
        putc(fd, '%');
 6ee:	02500593          	li	a1,37
 6f2:	855a                	mv	a0,s6
 6f4:	c95ff0ef          	jal	388 <putc>
        putc(fd, c0);
 6f8:	85a6                	mv	a1,s1
 6fa:	855a                	mv	a0,s6
 6fc:	c8dff0ef          	jal	388 <putc>
      state = 0;
 700:	4981                	li	s3,0
 702:	b359                	j	488 <vprintf+0x44>

0000000000000704 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 704:	715d                	addi	sp,sp,-80
 706:	ec06                	sd	ra,24(sp)
 708:	e822                	sd	s0,16(sp)
 70a:	1000                	addi	s0,sp,32
 70c:	e010                	sd	a2,0(s0)
 70e:	e414                	sd	a3,8(s0)
 710:	e818                	sd	a4,16(s0)
 712:	ec1c                	sd	a5,24(s0)
 714:	03043023          	sd	a6,32(s0)
 718:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 71c:	8622                	mv	a2,s0
 71e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 722:	d23ff0ef          	jal	444 <vprintf>
}
 726:	60e2                	ld	ra,24(sp)
 728:	6442                	ld	s0,16(sp)
 72a:	6161                	addi	sp,sp,80
 72c:	8082                	ret

000000000000072e <printf>:

void
printf(const char *fmt, ...)
{
 72e:	711d                	addi	sp,sp,-96
 730:	ec06                	sd	ra,24(sp)
 732:	e822                	sd	s0,16(sp)
 734:	1000                	addi	s0,sp,32
 736:	e40c                	sd	a1,8(s0)
 738:	e810                	sd	a2,16(s0)
 73a:	ec14                	sd	a3,24(s0)
 73c:	f018                	sd	a4,32(s0)
 73e:	f41c                	sd	a5,40(s0)
 740:	03043823          	sd	a6,48(s0)
 744:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 748:	00840613          	addi	a2,s0,8
 74c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 750:	85aa                	mv	a1,a0
 752:	4505                	li	a0,1
 754:	cf1ff0ef          	jal	444 <vprintf>
}
 758:	60e2                	ld	ra,24(sp)
 75a:	6442                	ld	s0,16(sp)
 75c:	6125                	addi	sp,sp,96
 75e:	8082                	ret

0000000000000760 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 760:	1141                	addi	sp,sp,-16
 762:	e406                	sd	ra,8(sp)
 764:	e022                	sd	s0,0(sp)
 766:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 768:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 76c:	00001797          	auipc	a5,0x1
 770:	8a47b783          	ld	a5,-1884(a5) # 1010 <freep>
 774:	a039                	j	782 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 776:	6398                	ld	a4,0(a5)
 778:	00e7e463          	bltu	a5,a4,780 <free+0x20>
 77c:	00e6ea63          	bltu	a3,a4,790 <free+0x30>
{
 780:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 782:	fed7fae3          	bgeu	a5,a3,776 <free+0x16>
 786:	6398                	ld	a4,0(a5)
 788:	00e6e463          	bltu	a3,a4,790 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 78c:	fee7eae3          	bltu	a5,a4,780 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 790:	ff852583          	lw	a1,-8(a0)
 794:	6390                	ld	a2,0(a5)
 796:	02059813          	slli	a6,a1,0x20
 79a:	01c85713          	srli	a4,a6,0x1c
 79e:	9736                	add	a4,a4,a3
 7a0:	02e60563          	beq	a2,a4,7ca <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 7a4:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 7a8:	4790                	lw	a2,8(a5)
 7aa:	02061593          	slli	a1,a2,0x20
 7ae:	01c5d713          	srli	a4,a1,0x1c
 7b2:	973e                	add	a4,a4,a5
 7b4:	02e68263          	beq	a3,a4,7d8 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 7b8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7ba:	00001717          	auipc	a4,0x1
 7be:	84f73b23          	sd	a5,-1962(a4) # 1010 <freep>
}
 7c2:	60a2                	ld	ra,8(sp)
 7c4:	6402                	ld	s0,0(sp)
 7c6:	0141                	addi	sp,sp,16
 7c8:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 7ca:	4618                	lw	a4,8(a2)
 7cc:	9f2d                	addw	a4,a4,a1
 7ce:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7d2:	6398                	ld	a4,0(a5)
 7d4:	6310                	ld	a2,0(a4)
 7d6:	b7f9                	j	7a4 <free+0x44>
    p->s.size += bp->s.size;
 7d8:	ff852703          	lw	a4,-8(a0)
 7dc:	9f31                	addw	a4,a4,a2
 7de:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7e0:	ff053683          	ld	a3,-16(a0)
 7e4:	bfd1                	j	7b8 <free+0x58>

00000000000007e6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7e6:	7139                	addi	sp,sp,-64
 7e8:	fc06                	sd	ra,56(sp)
 7ea:	f822                	sd	s0,48(sp)
 7ec:	f04a                	sd	s2,32(sp)
 7ee:	ec4e                	sd	s3,24(sp)
 7f0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7f2:	02051993          	slli	s3,a0,0x20
 7f6:	0209d993          	srli	s3,s3,0x20
 7fa:	09bd                	addi	s3,s3,15
 7fc:	0049d993          	srli	s3,s3,0x4
 800:	2985                	addiw	s3,s3,1
 802:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 804:	00001517          	auipc	a0,0x1
 808:	80c53503          	ld	a0,-2036(a0) # 1010 <freep>
 80c:	c905                	beqz	a0,83c <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 80e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 810:	4798                	lw	a4,8(a5)
 812:	09377663          	bgeu	a4,s3,89e <malloc+0xb8>
 816:	f426                	sd	s1,40(sp)
 818:	e852                	sd	s4,16(sp)
 81a:	e456                	sd	s5,8(sp)
 81c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 81e:	8a4e                	mv	s4,s3
 820:	6705                	lui	a4,0x1
 822:	00e9f363          	bgeu	s3,a4,828 <malloc+0x42>
 826:	6a05                	lui	s4,0x1
 828:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 82c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 830:	00000497          	auipc	s1,0x0
 834:	7e048493          	addi	s1,s1,2016 # 1010 <freep>
  if(p == SBRK_ERROR)
 838:	5afd                	li	s5,-1
 83a:	a83d                	j	878 <malloc+0x92>
 83c:	f426                	sd	s1,40(sp)
 83e:	e852                	sd	s4,16(sp)
 840:	e456                	sd	s5,8(sp)
 842:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 844:	00000797          	auipc	a5,0x0
 848:	7dc78793          	addi	a5,a5,2012 # 1020 <base>
 84c:	00000717          	auipc	a4,0x0
 850:	7cf73223          	sd	a5,1988(a4) # 1010 <freep>
 854:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 856:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 85a:	b7d1                	j	81e <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 85c:	6398                	ld	a4,0(a5)
 85e:	e118                	sd	a4,0(a0)
 860:	a899                	j	8b6 <malloc+0xd0>
  hp->s.size = nu;
 862:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 866:	0541                	addi	a0,a0,16
 868:	ef9ff0ef          	jal	760 <free>
  return freep;
 86c:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 86e:	c125                	beqz	a0,8ce <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 870:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 872:	4798                	lw	a4,8(a5)
 874:	03277163          	bgeu	a4,s2,896 <malloc+0xb0>
    if(p == freep)
 878:	6098                	ld	a4,0(s1)
 87a:	853e                	mv	a0,a5
 87c:	fef71ae3          	bne	a4,a5,870 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 880:	8552                	mv	a0,s4
 882:	a23ff0ef          	jal	2a4 <sbrk>
  if(p == SBRK_ERROR)
 886:	fd551ee3          	bne	a0,s5,862 <malloc+0x7c>
        return 0;
 88a:	4501                	li	a0,0
 88c:	74a2                	ld	s1,40(sp)
 88e:	6a42                	ld	s4,16(sp)
 890:	6aa2                	ld	s5,8(sp)
 892:	6b02                	ld	s6,0(sp)
 894:	a03d                	j	8c2 <malloc+0xdc>
 896:	74a2                	ld	s1,40(sp)
 898:	6a42                	ld	s4,16(sp)
 89a:	6aa2                	ld	s5,8(sp)
 89c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 89e:	fae90fe3          	beq	s2,a4,85c <malloc+0x76>
        p->s.size -= nunits;
 8a2:	4137073b          	subw	a4,a4,s3
 8a6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8a8:	02071693          	slli	a3,a4,0x20
 8ac:	01c6d713          	srli	a4,a3,0x1c
 8b0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8b2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8b6:	00000717          	auipc	a4,0x0
 8ba:	74a73d23          	sd	a0,1882(a4) # 1010 <freep>
      return (void*)(p + 1);
 8be:	01078513          	addi	a0,a5,16
  }
}
 8c2:	70e2                	ld	ra,56(sp)
 8c4:	7442                	ld	s0,48(sp)
 8c6:	7902                	ld	s2,32(sp)
 8c8:	69e2                	ld	s3,24(sp)
 8ca:	6121                	addi	sp,sp,64
 8cc:	8082                	ret
 8ce:	74a2                	ld	s1,40(sp)
 8d0:	6a42                	ld	s4,16(sp)
 8d2:	6aa2                	ld	s5,8(sp)
 8d4:	6b02                	ld	s6,0(sp)
 8d6:	b7f5                	j	8c2 <malloc+0xdc>
