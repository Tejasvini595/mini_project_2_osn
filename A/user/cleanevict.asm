
user/_cleanevict:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

#define PAGES 70   // choose > resident limit to force eviction

int main() {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  printf("Clean eviction test starting\n");
   8:	00001517          	auipc	a0,0x1
   c:	8f850513          	addi	a0,a0,-1800 # 900 <malloc+0xf4>
  10:	744000ef          	jal	754 <printf>
  char *a = sbrk(PAGES * 4096);
  14:	00046537          	lui	a0,0x46
  18:	2b2000ef          	jal	2ca <sbrk>
  for(int i = 0; i < PAGES; i += 2) {   // touch alternate pages read-only
  1c:	00046737          	lui	a4,0x46
  20:	972a                	add	a4,a4,a0
  22:	6689                	lui	a3,0x2
    volatile char x = a[i * 4096];
  24:	00054783          	lbu	a5,0(a0) # 46000 <base+0x44ff0>
  28:	fef407a3          	sb	a5,-17(s0)
    (void)x; // suppress unused variable warning
  2c:	fef44783          	lbu	a5,-17(s0)
  for(int i = 0; i < PAGES; i += 2) {   // touch alternate pages read-only
  30:	9536                	add	a0,a0,a3
  32:	fee519e3          	bne	a0,a4,24 <main+0x24>
  }
  printf("Clean eviction test done\n");
  36:	00001517          	auipc	a0,0x1
  3a:	8ea50513          	addi	a0,a0,-1814 # 920 <malloc+0x114>
  3e:	716000ef          	jal	754 <printf>
  exit(0);
  42:	4501                	li	a0,0
  44:	2ba000ef          	jal	2fe <exit>

0000000000000048 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  48:	1141                	addi	sp,sp,-16
  4a:	e406                	sd	ra,8(sp)
  4c:	e022                	sd	s0,0(sp)
  4e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  50:	fb1ff0ef          	jal	0 <main>
  exit(r);
  54:	2aa000ef          	jal	2fe <exit>

0000000000000058 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  58:	1141                	addi	sp,sp,-16
  5a:	e406                	sd	ra,8(sp)
  5c:	e022                	sd	s0,0(sp)
  5e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  60:	87aa                	mv	a5,a0
  62:	0585                	addi	a1,a1,1
  64:	0785                	addi	a5,a5,1
  66:	fff5c703          	lbu	a4,-1(a1)
  6a:	fee78fa3          	sb	a4,-1(a5)
  6e:	fb75                	bnez	a4,62 <strcpy+0xa>
    ;
  return os;
}
  70:	60a2                	ld	ra,8(sp)
  72:	6402                	ld	s0,0(sp)
  74:	0141                	addi	sp,sp,16
  76:	8082                	ret

0000000000000078 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  78:	1141                	addi	sp,sp,-16
  7a:	e406                	sd	ra,8(sp)
  7c:	e022                	sd	s0,0(sp)
  7e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  80:	00054783          	lbu	a5,0(a0)
  84:	cb91                	beqz	a5,98 <strcmp+0x20>
  86:	0005c703          	lbu	a4,0(a1)
  8a:	00f71763          	bne	a4,a5,98 <strcmp+0x20>
    p++, q++;
  8e:	0505                	addi	a0,a0,1
  90:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  92:	00054783          	lbu	a5,0(a0)
  96:	fbe5                	bnez	a5,86 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  98:	0005c503          	lbu	a0,0(a1)
}
  9c:	40a7853b          	subw	a0,a5,a0
  a0:	60a2                	ld	ra,8(sp)
  a2:	6402                	ld	s0,0(sp)
  a4:	0141                	addi	sp,sp,16
  a6:	8082                	ret

00000000000000a8 <strlen>:

uint
strlen(const char *s)
{
  a8:	1141                	addi	sp,sp,-16
  aa:	e406                	sd	ra,8(sp)
  ac:	e022                	sd	s0,0(sp)
  ae:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  b0:	00054783          	lbu	a5,0(a0)
  b4:	cf91                	beqz	a5,d0 <strlen+0x28>
  b6:	00150793          	addi	a5,a0,1
  ba:	86be                	mv	a3,a5
  bc:	0785                	addi	a5,a5,1
  be:	fff7c703          	lbu	a4,-1(a5)
  c2:	ff65                	bnez	a4,ba <strlen+0x12>
  c4:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
  c8:	60a2                	ld	ra,8(sp)
  ca:	6402                	ld	s0,0(sp)
  cc:	0141                	addi	sp,sp,16
  ce:	8082                	ret
  for(n = 0; s[n]; n++)
  d0:	4501                	li	a0,0
  d2:	bfdd                	j	c8 <strlen+0x20>

00000000000000d4 <memset>:

void*
memset(void *dst, int c, uint n)
{
  d4:	1141                	addi	sp,sp,-16
  d6:	e406                	sd	ra,8(sp)
  d8:	e022                	sd	s0,0(sp)
  da:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  dc:	ca19                	beqz	a2,f2 <memset+0x1e>
  de:	87aa                	mv	a5,a0
  e0:	1602                	slli	a2,a2,0x20
  e2:	9201                	srli	a2,a2,0x20
  e4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  e8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  ec:	0785                	addi	a5,a5,1
  ee:	fee79de3          	bne	a5,a4,e8 <memset+0x14>
  }
  return dst;
}
  f2:	60a2                	ld	ra,8(sp)
  f4:	6402                	ld	s0,0(sp)
  f6:	0141                	addi	sp,sp,16
  f8:	8082                	ret

00000000000000fa <strchr>:

char*
strchr(const char *s, char c)
{
  fa:	1141                	addi	sp,sp,-16
  fc:	e406                	sd	ra,8(sp)
  fe:	e022                	sd	s0,0(sp)
 100:	0800                	addi	s0,sp,16
  for(; *s; s++)
 102:	00054783          	lbu	a5,0(a0)
 106:	cf81                	beqz	a5,11e <strchr+0x24>
    if(*s == c)
 108:	00f58763          	beq	a1,a5,116 <strchr+0x1c>
  for(; *s; s++)
 10c:	0505                	addi	a0,a0,1
 10e:	00054783          	lbu	a5,0(a0)
 112:	fbfd                	bnez	a5,108 <strchr+0xe>
      return (char*)s;
  return 0;
 114:	4501                	li	a0,0
}
 116:	60a2                	ld	ra,8(sp)
 118:	6402                	ld	s0,0(sp)
 11a:	0141                	addi	sp,sp,16
 11c:	8082                	ret
  return 0;
 11e:	4501                	li	a0,0
 120:	bfdd                	j	116 <strchr+0x1c>

0000000000000122 <gets>:

char*
gets(char *buf, int max)
{
 122:	711d                	addi	sp,sp,-96
 124:	ec86                	sd	ra,88(sp)
 126:	e8a2                	sd	s0,80(sp)
 128:	e4a6                	sd	s1,72(sp)
 12a:	e0ca                	sd	s2,64(sp)
 12c:	fc4e                	sd	s3,56(sp)
 12e:	f852                	sd	s4,48(sp)
 130:	f456                	sd	s5,40(sp)
 132:	f05a                	sd	s6,32(sp)
 134:	ec5e                	sd	s7,24(sp)
 136:	e862                	sd	s8,16(sp)
 138:	1080                	addi	s0,sp,96
 13a:	8baa                	mv	s7,a0
 13c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 13e:	892a                	mv	s2,a0
 140:	4481                	li	s1,0
    cc = read(0, &c, 1);
 142:	faf40b13          	addi	s6,s0,-81
 146:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 148:	8c26                	mv	s8,s1
 14a:	0014899b          	addiw	s3,s1,1
 14e:	84ce                	mv	s1,s3
 150:	0349d463          	bge	s3,s4,178 <gets+0x56>
    cc = read(0, &c, 1);
 154:	8656                	mv	a2,s5
 156:	85da                	mv	a1,s6
 158:	4501                	li	a0,0
 15a:	1bc000ef          	jal	316 <read>
    if(cc < 1)
 15e:	00a05d63          	blez	a0,178 <gets+0x56>
      break;
    buf[i++] = c;
 162:	faf44783          	lbu	a5,-81(s0)
 166:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 16a:	0905                	addi	s2,s2,1
 16c:	ff678713          	addi	a4,a5,-10
 170:	c319                	beqz	a4,176 <gets+0x54>
 172:	17cd                	addi	a5,a5,-13
 174:	fbf1                	bnez	a5,148 <gets+0x26>
    buf[i++] = c;
 176:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 178:	9c5e                	add	s8,s8,s7
 17a:	000c0023          	sb	zero,0(s8)
  return buf;
}
 17e:	855e                	mv	a0,s7
 180:	60e6                	ld	ra,88(sp)
 182:	6446                	ld	s0,80(sp)
 184:	64a6                	ld	s1,72(sp)
 186:	6906                	ld	s2,64(sp)
 188:	79e2                	ld	s3,56(sp)
 18a:	7a42                	ld	s4,48(sp)
 18c:	7aa2                	ld	s5,40(sp)
 18e:	7b02                	ld	s6,32(sp)
 190:	6be2                	ld	s7,24(sp)
 192:	6c42                	ld	s8,16(sp)
 194:	6125                	addi	sp,sp,96
 196:	8082                	ret

0000000000000198 <stat>:

int
stat(const char *n, struct stat *st)
{
 198:	1101                	addi	sp,sp,-32
 19a:	ec06                	sd	ra,24(sp)
 19c:	e822                	sd	s0,16(sp)
 19e:	e04a                	sd	s2,0(sp)
 1a0:	1000                	addi	s0,sp,32
 1a2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1a4:	4581                	li	a1,0
 1a6:	198000ef          	jal	33e <open>
  if(fd < 0)
 1aa:	02054263          	bltz	a0,1ce <stat+0x36>
 1ae:	e426                	sd	s1,8(sp)
 1b0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1b2:	85ca                	mv	a1,s2
 1b4:	1a2000ef          	jal	356 <fstat>
 1b8:	892a                	mv	s2,a0
  close(fd);
 1ba:	8526                	mv	a0,s1
 1bc:	16a000ef          	jal	326 <close>
  return r;
 1c0:	64a2                	ld	s1,8(sp)
}
 1c2:	854a                	mv	a0,s2
 1c4:	60e2                	ld	ra,24(sp)
 1c6:	6442                	ld	s0,16(sp)
 1c8:	6902                	ld	s2,0(sp)
 1ca:	6105                	addi	sp,sp,32
 1cc:	8082                	ret
    return -1;
 1ce:	57fd                	li	a5,-1
 1d0:	893e                	mv	s2,a5
 1d2:	bfc5                	j	1c2 <stat+0x2a>

00000000000001d4 <atoi>:

int
atoi(const char *s)
{
 1d4:	1141                	addi	sp,sp,-16
 1d6:	e406                	sd	ra,8(sp)
 1d8:	e022                	sd	s0,0(sp)
 1da:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1dc:	00054683          	lbu	a3,0(a0)
 1e0:	fd06879b          	addiw	a5,a3,-48 # 1fd0 <base+0xfc0>
 1e4:	0ff7f793          	zext.b	a5,a5
 1e8:	4625                	li	a2,9
 1ea:	02f66963          	bltu	a2,a5,21c <atoi+0x48>
 1ee:	872a                	mv	a4,a0
  n = 0;
 1f0:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1f2:	0705                	addi	a4,a4,1 # 46001 <base+0x44ff1>
 1f4:	0025179b          	slliw	a5,a0,0x2
 1f8:	9fa9                	addw	a5,a5,a0
 1fa:	0017979b          	slliw	a5,a5,0x1
 1fe:	9fb5                	addw	a5,a5,a3
 200:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 204:	00074683          	lbu	a3,0(a4)
 208:	fd06879b          	addiw	a5,a3,-48
 20c:	0ff7f793          	zext.b	a5,a5
 210:	fef671e3          	bgeu	a2,a5,1f2 <atoi+0x1e>
  return n;
}
 214:	60a2                	ld	ra,8(sp)
 216:	6402                	ld	s0,0(sp)
 218:	0141                	addi	sp,sp,16
 21a:	8082                	ret
  n = 0;
 21c:	4501                	li	a0,0
 21e:	bfdd                	j	214 <atoi+0x40>

0000000000000220 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 220:	1141                	addi	sp,sp,-16
 222:	e406                	sd	ra,8(sp)
 224:	e022                	sd	s0,0(sp)
 226:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 228:	02b57563          	bgeu	a0,a1,252 <memmove+0x32>
    while(n-- > 0)
 22c:	00c05f63          	blez	a2,24a <memmove+0x2a>
 230:	1602                	slli	a2,a2,0x20
 232:	9201                	srli	a2,a2,0x20
 234:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 238:	872a                	mv	a4,a0
      *dst++ = *src++;
 23a:	0585                	addi	a1,a1,1
 23c:	0705                	addi	a4,a4,1
 23e:	fff5c683          	lbu	a3,-1(a1)
 242:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 246:	fee79ae3          	bne	a5,a4,23a <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 24a:	60a2                	ld	ra,8(sp)
 24c:	6402                	ld	s0,0(sp)
 24e:	0141                	addi	sp,sp,16
 250:	8082                	ret
    while(n-- > 0)
 252:	fec05ce3          	blez	a2,24a <memmove+0x2a>
    dst += n;
 256:	00c50733          	add	a4,a0,a2
    src += n;
 25a:	95b2                	add	a1,a1,a2
 25c:	fff6079b          	addiw	a5,a2,-1
 260:	1782                	slli	a5,a5,0x20
 262:	9381                	srli	a5,a5,0x20
 264:	fff7c793          	not	a5,a5
 268:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 26a:	15fd                	addi	a1,a1,-1
 26c:	177d                	addi	a4,a4,-1
 26e:	0005c683          	lbu	a3,0(a1)
 272:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 276:	fef71ae3          	bne	a4,a5,26a <memmove+0x4a>
 27a:	bfc1                	j	24a <memmove+0x2a>

000000000000027c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e406                	sd	ra,8(sp)
 280:	e022                	sd	s0,0(sp)
 282:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 284:	c61d                	beqz	a2,2b2 <memcmp+0x36>
 286:	1602                	slli	a2,a2,0x20
 288:	9201                	srli	a2,a2,0x20
 28a:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 28e:	00054783          	lbu	a5,0(a0)
 292:	0005c703          	lbu	a4,0(a1)
 296:	00e79863          	bne	a5,a4,2a6 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 29a:	0505                	addi	a0,a0,1
    p2++;
 29c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 29e:	fed518e3          	bne	a0,a3,28e <memcmp+0x12>
  }
  return 0;
 2a2:	4501                	li	a0,0
 2a4:	a019                	j	2aa <memcmp+0x2e>
      return *p1 - *p2;
 2a6:	40e7853b          	subw	a0,a5,a4
}
 2aa:	60a2                	ld	ra,8(sp)
 2ac:	6402                	ld	s0,0(sp)
 2ae:	0141                	addi	sp,sp,16
 2b0:	8082                	ret
  return 0;
 2b2:	4501                	li	a0,0
 2b4:	bfdd                	j	2aa <memcmp+0x2e>

00000000000002b6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2b6:	1141                	addi	sp,sp,-16
 2b8:	e406                	sd	ra,8(sp)
 2ba:	e022                	sd	s0,0(sp)
 2bc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2be:	f63ff0ef          	jal	220 <memmove>
}
 2c2:	60a2                	ld	ra,8(sp)
 2c4:	6402                	ld	s0,0(sp)
 2c6:	0141                	addi	sp,sp,16
 2c8:	8082                	ret

00000000000002ca <sbrk>:

char *
sbrk(int n) {
 2ca:	1141                	addi	sp,sp,-16
 2cc:	e406                	sd	ra,8(sp)
 2ce:	e022                	sd	s0,0(sp)
 2d0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2d2:	4585                	li	a1,1
 2d4:	0b2000ef          	jal	386 <sys_sbrk>
}
 2d8:	60a2                	ld	ra,8(sp)
 2da:	6402                	ld	s0,0(sp)
 2dc:	0141                	addi	sp,sp,16
 2de:	8082                	ret

00000000000002e0 <sbrklazy>:

char *
sbrklazy(int n) {
 2e0:	1141                	addi	sp,sp,-16
 2e2:	e406                	sd	ra,8(sp)
 2e4:	e022                	sd	s0,0(sp)
 2e6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2e8:	4589                	li	a1,2
 2ea:	09c000ef          	jal	386 <sys_sbrk>
}
 2ee:	60a2                	ld	ra,8(sp)
 2f0:	6402                	ld	s0,0(sp)
 2f2:	0141                	addi	sp,sp,16
 2f4:	8082                	ret

00000000000002f6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2f6:	4885                	li	a7,1
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <exit>:
.global exit
exit:
 li a7, SYS_exit
 2fe:	4889                	li	a7,2
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <wait>:
.global wait
wait:
 li a7, SYS_wait
 306:	488d                	li	a7,3
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 30e:	4891                	li	a7,4
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <read>:
.global read
read:
 li a7, SYS_read
 316:	4895                	li	a7,5
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <write>:
.global write
write:
 li a7, SYS_write
 31e:	48c1                	li	a7,16
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <close>:
.global close
close:
 li a7, SYS_close
 326:	48d5                	li	a7,21
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <kill>:
.global kill
kill:
 li a7, SYS_kill
 32e:	4899                	li	a7,6
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <exec>:
.global exec
exec:
 li a7, SYS_exec
 336:	489d                	li	a7,7
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <open>:
.global open
open:
 li a7, SYS_open
 33e:	48bd                	li	a7,15
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 346:	48c5                	li	a7,17
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 34e:	48c9                	li	a7,18
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 356:	48a1                	li	a7,8
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <link>:
.global link
link:
 li a7, SYS_link
 35e:	48cd                	li	a7,19
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 366:	48d1                	li	a7,20
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 36e:	48a5                	li	a7,9
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <dup>:
.global dup
dup:
 li a7, SYS_dup
 376:	48a9                	li	a7,10
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 37e:	48ad                	li	a7,11
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 386:	48b1                	li	a7,12
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <pause>:
.global pause
pause:
 li a7, SYS_pause
 38e:	48b5                	li	a7,13
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 396:	48b9                	li	a7,14
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <memstat>:
.global memstat
memstat:
 li a7, SYS_memstat
 39e:	48d9                	li	a7,22
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <enable_bonus>:
.global enable_bonus
enable_bonus:
 li a7, SYS_enable_bonus
 3a6:	48dd                	li	a7,23
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3ae:	1101                	addi	sp,sp,-32
 3b0:	ec06                	sd	ra,24(sp)
 3b2:	e822                	sd	s0,16(sp)
 3b4:	1000                	addi	s0,sp,32
 3b6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3ba:	4605                	li	a2,1
 3bc:	fef40593          	addi	a1,s0,-17
 3c0:	f5fff0ef          	jal	31e <write>
}
 3c4:	60e2                	ld	ra,24(sp)
 3c6:	6442                	ld	s0,16(sp)
 3c8:	6105                	addi	sp,sp,32
 3ca:	8082                	ret

00000000000003cc <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3cc:	715d                	addi	sp,sp,-80
 3ce:	e486                	sd	ra,72(sp)
 3d0:	e0a2                	sd	s0,64(sp)
 3d2:	f84a                	sd	s2,48(sp)
 3d4:	f44e                	sd	s3,40(sp)
 3d6:	0880                	addi	s0,sp,80
 3d8:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3da:	c6d1                	beqz	a3,466 <printint+0x9a>
 3dc:	0805d563          	bgez	a1,466 <printint+0x9a>
    neg = 1;
    x = -xx;
 3e0:	40b005b3          	neg	a1,a1
    neg = 1;
 3e4:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 3e6:	fb840993          	addi	s3,s0,-72
  neg = 0;
 3ea:	86ce                	mv	a3,s3
  i = 0;
 3ec:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3ee:	00000817          	auipc	a6,0x0
 3f2:	55a80813          	addi	a6,a6,1370 # 948 <digits>
 3f6:	88ba                	mv	a7,a4
 3f8:	0017051b          	addiw	a0,a4,1
 3fc:	872a                	mv	a4,a0
 3fe:	02c5f7b3          	remu	a5,a1,a2
 402:	97c2                	add	a5,a5,a6
 404:	0007c783          	lbu	a5,0(a5)
 408:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 40c:	87ae                	mv	a5,a1
 40e:	02c5d5b3          	divu	a1,a1,a2
 412:	0685                	addi	a3,a3,1
 414:	fec7f1e3          	bgeu	a5,a2,3f6 <printint+0x2a>
  if(neg)
 418:	00030c63          	beqz	t1,430 <printint+0x64>
    buf[i++] = '-';
 41c:	fd050793          	addi	a5,a0,-48
 420:	00878533          	add	a0,a5,s0
 424:	02d00793          	li	a5,45
 428:	fef50423          	sb	a5,-24(a0)
 42c:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 430:	02e05563          	blez	a4,45a <printint+0x8e>
 434:	fc26                	sd	s1,56(sp)
 436:	377d                	addiw	a4,a4,-1
 438:	00e984b3          	add	s1,s3,a4
 43c:	19fd                	addi	s3,s3,-1
 43e:	99ba                	add	s3,s3,a4
 440:	1702                	slli	a4,a4,0x20
 442:	9301                	srli	a4,a4,0x20
 444:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 448:	0004c583          	lbu	a1,0(s1)
 44c:	854a                	mv	a0,s2
 44e:	f61ff0ef          	jal	3ae <putc>
  while(--i >= 0)
 452:	14fd                	addi	s1,s1,-1
 454:	ff349ae3          	bne	s1,s3,448 <printint+0x7c>
 458:	74e2                	ld	s1,56(sp)
}
 45a:	60a6                	ld	ra,72(sp)
 45c:	6406                	ld	s0,64(sp)
 45e:	7942                	ld	s2,48(sp)
 460:	79a2                	ld	s3,40(sp)
 462:	6161                	addi	sp,sp,80
 464:	8082                	ret
  neg = 0;
 466:	4301                	li	t1,0
 468:	bfbd                	j	3e6 <printint+0x1a>

000000000000046a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 46a:	711d                	addi	sp,sp,-96
 46c:	ec86                	sd	ra,88(sp)
 46e:	e8a2                	sd	s0,80(sp)
 470:	e4a6                	sd	s1,72(sp)
 472:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 474:	0005c483          	lbu	s1,0(a1)
 478:	22048363          	beqz	s1,69e <vprintf+0x234>
 47c:	e0ca                	sd	s2,64(sp)
 47e:	fc4e                	sd	s3,56(sp)
 480:	f852                	sd	s4,48(sp)
 482:	f456                	sd	s5,40(sp)
 484:	f05a                	sd	s6,32(sp)
 486:	ec5e                	sd	s7,24(sp)
 488:	e862                	sd	s8,16(sp)
 48a:	8b2a                	mv	s6,a0
 48c:	8a2e                	mv	s4,a1
 48e:	8bb2                	mv	s7,a2
  state = 0;
 490:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 492:	4901                	li	s2,0
 494:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 496:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 49a:	06400c13          	li	s8,100
 49e:	a00d                	j	4c0 <vprintf+0x56>
        putc(fd, c0);
 4a0:	85a6                	mv	a1,s1
 4a2:	855a                	mv	a0,s6
 4a4:	f0bff0ef          	jal	3ae <putc>
 4a8:	a019                	j	4ae <vprintf+0x44>
    } else if(state == '%'){
 4aa:	03598363          	beq	s3,s5,4d0 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 4ae:	0019079b          	addiw	a5,s2,1
 4b2:	893e                	mv	s2,a5
 4b4:	873e                	mv	a4,a5
 4b6:	97d2                	add	a5,a5,s4
 4b8:	0007c483          	lbu	s1,0(a5)
 4bc:	1c048a63          	beqz	s1,690 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 4c0:	0004879b          	sext.w	a5,s1
    if(state == 0){
 4c4:	fe0993e3          	bnez	s3,4aa <vprintf+0x40>
      if(c0 == '%'){
 4c8:	fd579ce3          	bne	a5,s5,4a0 <vprintf+0x36>
        state = '%';
 4cc:	89be                	mv	s3,a5
 4ce:	b7c5                	j	4ae <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 4d0:	00ea06b3          	add	a3,s4,a4
 4d4:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 4d8:	1c060863          	beqz	a2,6a8 <vprintf+0x23e>
      if(c0 == 'd'){
 4dc:	03878763          	beq	a5,s8,50a <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4e0:	f9478693          	addi	a3,a5,-108
 4e4:	0016b693          	seqz	a3,a3
 4e8:	f9c60593          	addi	a1,a2,-100
 4ec:	e99d                	bnez	a1,522 <vprintf+0xb8>
 4ee:	ca95                	beqz	a3,522 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 4f0:	008b8493          	addi	s1,s7,8
 4f4:	4685                	li	a3,1
 4f6:	4629                	li	a2,10
 4f8:	000bb583          	ld	a1,0(s7)
 4fc:	855a                	mv	a0,s6
 4fe:	ecfff0ef          	jal	3cc <printint>
        i += 1;
 502:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 504:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 506:	4981                	li	s3,0
 508:	b75d                	j	4ae <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 50a:	008b8493          	addi	s1,s7,8
 50e:	4685                	li	a3,1
 510:	4629                	li	a2,10
 512:	000ba583          	lw	a1,0(s7)
 516:	855a                	mv	a0,s6
 518:	eb5ff0ef          	jal	3cc <printint>
 51c:	8ba6                	mv	s7,s1
      state = 0;
 51e:	4981                	li	s3,0
 520:	b779                	j	4ae <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 522:	9752                	add	a4,a4,s4
 524:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 528:	f9460713          	addi	a4,a2,-108
 52c:	00173713          	seqz	a4,a4
 530:	8f75                	and	a4,a4,a3
 532:	f9c58513          	addi	a0,a1,-100
 536:	18051363          	bnez	a0,6bc <vprintf+0x252>
 53a:	18070163          	beqz	a4,6bc <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 53e:	008b8493          	addi	s1,s7,8
 542:	4685                	li	a3,1
 544:	4629                	li	a2,10
 546:	000bb583          	ld	a1,0(s7)
 54a:	855a                	mv	a0,s6
 54c:	e81ff0ef          	jal	3cc <printint>
        i += 2;
 550:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 552:	8ba6                	mv	s7,s1
      state = 0;
 554:	4981                	li	s3,0
        i += 2;
 556:	bfa1                	j	4ae <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 558:	008b8493          	addi	s1,s7,8
 55c:	4681                	li	a3,0
 55e:	4629                	li	a2,10
 560:	000be583          	lwu	a1,0(s7)
 564:	855a                	mv	a0,s6
 566:	e67ff0ef          	jal	3cc <printint>
 56a:	8ba6                	mv	s7,s1
      state = 0;
 56c:	4981                	li	s3,0
 56e:	b781                	j	4ae <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 570:	008b8493          	addi	s1,s7,8
 574:	4681                	li	a3,0
 576:	4629                	li	a2,10
 578:	000bb583          	ld	a1,0(s7)
 57c:	855a                	mv	a0,s6
 57e:	e4fff0ef          	jal	3cc <printint>
        i += 1;
 582:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 584:	8ba6                	mv	s7,s1
      state = 0;
 586:	4981                	li	s3,0
 588:	b71d                	j	4ae <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 58a:	008b8493          	addi	s1,s7,8
 58e:	4681                	li	a3,0
 590:	4629                	li	a2,10
 592:	000bb583          	ld	a1,0(s7)
 596:	855a                	mv	a0,s6
 598:	e35ff0ef          	jal	3cc <printint>
        i += 2;
 59c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 59e:	8ba6                	mv	s7,s1
      state = 0;
 5a0:	4981                	li	s3,0
        i += 2;
 5a2:	b731                	j	4ae <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 5a4:	008b8493          	addi	s1,s7,8
 5a8:	4681                	li	a3,0
 5aa:	4641                	li	a2,16
 5ac:	000be583          	lwu	a1,0(s7)
 5b0:	855a                	mv	a0,s6
 5b2:	e1bff0ef          	jal	3cc <printint>
 5b6:	8ba6                	mv	s7,s1
      state = 0;
 5b8:	4981                	li	s3,0
 5ba:	bdd5                	j	4ae <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5bc:	008b8493          	addi	s1,s7,8
 5c0:	4681                	li	a3,0
 5c2:	4641                	li	a2,16
 5c4:	000bb583          	ld	a1,0(s7)
 5c8:	855a                	mv	a0,s6
 5ca:	e03ff0ef          	jal	3cc <printint>
        i += 1;
 5ce:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 5d0:	8ba6                	mv	s7,s1
      state = 0;
 5d2:	4981                	li	s3,0
 5d4:	bde9                	j	4ae <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5d6:	008b8493          	addi	s1,s7,8
 5da:	4681                	li	a3,0
 5dc:	4641                	li	a2,16
 5de:	000bb583          	ld	a1,0(s7)
 5e2:	855a                	mv	a0,s6
 5e4:	de9ff0ef          	jal	3cc <printint>
        i += 2;
 5e8:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ea:	8ba6                	mv	s7,s1
      state = 0;
 5ec:	4981                	li	s3,0
        i += 2;
 5ee:	b5c1                	j	4ae <vprintf+0x44>
 5f0:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 5f2:	008b8793          	addi	a5,s7,8
 5f6:	8cbe                	mv	s9,a5
 5f8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5fc:	03000593          	li	a1,48
 600:	855a                	mv	a0,s6
 602:	dadff0ef          	jal	3ae <putc>
  putc(fd, 'x');
 606:	07800593          	li	a1,120
 60a:	855a                	mv	a0,s6
 60c:	da3ff0ef          	jal	3ae <putc>
 610:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 612:	00000b97          	auipc	s7,0x0
 616:	336b8b93          	addi	s7,s7,822 # 948 <digits>
 61a:	03c9d793          	srli	a5,s3,0x3c
 61e:	97de                	add	a5,a5,s7
 620:	0007c583          	lbu	a1,0(a5)
 624:	855a                	mv	a0,s6
 626:	d89ff0ef          	jal	3ae <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 62a:	0992                	slli	s3,s3,0x4
 62c:	34fd                	addiw	s1,s1,-1
 62e:	f4f5                	bnez	s1,61a <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 630:	8be6                	mv	s7,s9
      state = 0;
 632:	4981                	li	s3,0
 634:	6ca2                	ld	s9,8(sp)
 636:	bda5                	j	4ae <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 638:	008b8493          	addi	s1,s7,8
 63c:	000bc583          	lbu	a1,0(s7)
 640:	855a                	mv	a0,s6
 642:	d6dff0ef          	jal	3ae <putc>
 646:	8ba6                	mv	s7,s1
      state = 0;
 648:	4981                	li	s3,0
 64a:	b595                	j	4ae <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 64c:	008b8993          	addi	s3,s7,8
 650:	000bb483          	ld	s1,0(s7)
 654:	cc91                	beqz	s1,670 <vprintf+0x206>
        for(; *s; s++)
 656:	0004c583          	lbu	a1,0(s1)
 65a:	c985                	beqz	a1,68a <vprintf+0x220>
          putc(fd, *s);
 65c:	855a                	mv	a0,s6
 65e:	d51ff0ef          	jal	3ae <putc>
        for(; *s; s++)
 662:	0485                	addi	s1,s1,1
 664:	0004c583          	lbu	a1,0(s1)
 668:	f9f5                	bnez	a1,65c <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 66a:	8bce                	mv	s7,s3
      state = 0;
 66c:	4981                	li	s3,0
 66e:	b581                	j	4ae <vprintf+0x44>
          s = "(null)";
 670:	00000497          	auipc	s1,0x0
 674:	2d048493          	addi	s1,s1,720 # 940 <malloc+0x134>
        for(; *s; s++)
 678:	02800593          	li	a1,40
 67c:	b7c5                	j	65c <vprintf+0x1f2>
        putc(fd, '%');
 67e:	85be                	mv	a1,a5
 680:	855a                	mv	a0,s6
 682:	d2dff0ef          	jal	3ae <putc>
      state = 0;
 686:	4981                	li	s3,0
 688:	b51d                	j	4ae <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 68a:	8bce                	mv	s7,s3
      state = 0;
 68c:	4981                	li	s3,0
 68e:	b505                	j	4ae <vprintf+0x44>
 690:	6906                	ld	s2,64(sp)
 692:	79e2                	ld	s3,56(sp)
 694:	7a42                	ld	s4,48(sp)
 696:	7aa2                	ld	s5,40(sp)
 698:	7b02                	ld	s6,32(sp)
 69a:	6be2                	ld	s7,24(sp)
 69c:	6c42                	ld	s8,16(sp)
    }
  }
}
 69e:	60e6                	ld	ra,88(sp)
 6a0:	6446                	ld	s0,80(sp)
 6a2:	64a6                	ld	s1,72(sp)
 6a4:	6125                	addi	sp,sp,96
 6a6:	8082                	ret
      if(c0 == 'd'){
 6a8:	06400713          	li	a4,100
 6ac:	e4e78fe3          	beq	a5,a4,50a <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 6b0:	f9478693          	addi	a3,a5,-108
 6b4:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 6b8:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6ba:	4701                	li	a4,0
      } else if(c0 == 'u'){
 6bc:	07500513          	li	a0,117
 6c0:	e8a78ce3          	beq	a5,a0,558 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 6c4:	f8b60513          	addi	a0,a2,-117
 6c8:	e119                	bnez	a0,6ce <vprintf+0x264>
 6ca:	ea0693e3          	bnez	a3,570 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6ce:	f8b58513          	addi	a0,a1,-117
 6d2:	e119                	bnez	a0,6d8 <vprintf+0x26e>
 6d4:	ea071be3          	bnez	a4,58a <vprintf+0x120>
      } else if(c0 == 'x'){
 6d8:	07800513          	li	a0,120
 6dc:	eca784e3          	beq	a5,a0,5a4 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 6e0:	f8860613          	addi	a2,a2,-120
 6e4:	e219                	bnez	a2,6ea <vprintf+0x280>
 6e6:	ec069be3          	bnez	a3,5bc <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6ea:	f8858593          	addi	a1,a1,-120
 6ee:	e199                	bnez	a1,6f4 <vprintf+0x28a>
 6f0:	ee0713e3          	bnez	a4,5d6 <vprintf+0x16c>
      } else if(c0 == 'p'){
 6f4:	07000713          	li	a4,112
 6f8:	eee78ce3          	beq	a5,a4,5f0 <vprintf+0x186>
      } else if(c0 == 'c'){
 6fc:	06300713          	li	a4,99
 700:	f2e78ce3          	beq	a5,a4,638 <vprintf+0x1ce>
      } else if(c0 == 's'){
 704:	07300713          	li	a4,115
 708:	f4e782e3          	beq	a5,a4,64c <vprintf+0x1e2>
      } else if(c0 == '%'){
 70c:	02500713          	li	a4,37
 710:	f6e787e3          	beq	a5,a4,67e <vprintf+0x214>
        putc(fd, '%');
 714:	02500593          	li	a1,37
 718:	855a                	mv	a0,s6
 71a:	c95ff0ef          	jal	3ae <putc>
        putc(fd, c0);
 71e:	85a6                	mv	a1,s1
 720:	855a                	mv	a0,s6
 722:	c8dff0ef          	jal	3ae <putc>
      state = 0;
 726:	4981                	li	s3,0
 728:	b359                	j	4ae <vprintf+0x44>

000000000000072a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 72a:	715d                	addi	sp,sp,-80
 72c:	ec06                	sd	ra,24(sp)
 72e:	e822                	sd	s0,16(sp)
 730:	1000                	addi	s0,sp,32
 732:	e010                	sd	a2,0(s0)
 734:	e414                	sd	a3,8(s0)
 736:	e818                	sd	a4,16(s0)
 738:	ec1c                	sd	a5,24(s0)
 73a:	03043023          	sd	a6,32(s0)
 73e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 742:	8622                	mv	a2,s0
 744:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 748:	d23ff0ef          	jal	46a <vprintf>
}
 74c:	60e2                	ld	ra,24(sp)
 74e:	6442                	ld	s0,16(sp)
 750:	6161                	addi	sp,sp,80
 752:	8082                	ret

0000000000000754 <printf>:

void
printf(const char *fmt, ...)
{
 754:	711d                	addi	sp,sp,-96
 756:	ec06                	sd	ra,24(sp)
 758:	e822                	sd	s0,16(sp)
 75a:	1000                	addi	s0,sp,32
 75c:	e40c                	sd	a1,8(s0)
 75e:	e810                	sd	a2,16(s0)
 760:	ec14                	sd	a3,24(s0)
 762:	f018                	sd	a4,32(s0)
 764:	f41c                	sd	a5,40(s0)
 766:	03043823          	sd	a6,48(s0)
 76a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 76e:	00840613          	addi	a2,s0,8
 772:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 776:	85aa                	mv	a1,a0
 778:	4505                	li	a0,1
 77a:	cf1ff0ef          	jal	46a <vprintf>
}
 77e:	60e2                	ld	ra,24(sp)
 780:	6442                	ld	s0,16(sp)
 782:	6125                	addi	sp,sp,96
 784:	8082                	ret

0000000000000786 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 786:	1141                	addi	sp,sp,-16
 788:	e406                	sd	ra,8(sp)
 78a:	e022                	sd	s0,0(sp)
 78c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 78e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 792:	00001797          	auipc	a5,0x1
 796:	86e7b783          	ld	a5,-1938(a5) # 1000 <freep>
 79a:	a039                	j	7a8 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 79c:	6398                	ld	a4,0(a5)
 79e:	00e7e463          	bltu	a5,a4,7a6 <free+0x20>
 7a2:	00e6ea63          	bltu	a3,a4,7b6 <free+0x30>
{
 7a6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a8:	fed7fae3          	bgeu	a5,a3,79c <free+0x16>
 7ac:	6398                	ld	a4,0(a5)
 7ae:	00e6e463          	bltu	a3,a4,7b6 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b2:	fee7eae3          	bltu	a5,a4,7a6 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7b6:	ff852583          	lw	a1,-8(a0)
 7ba:	6390                	ld	a2,0(a5)
 7bc:	02059813          	slli	a6,a1,0x20
 7c0:	01c85713          	srli	a4,a6,0x1c
 7c4:	9736                	add	a4,a4,a3
 7c6:	02e60563          	beq	a2,a4,7f0 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 7ca:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 7ce:	4790                	lw	a2,8(a5)
 7d0:	02061593          	slli	a1,a2,0x20
 7d4:	01c5d713          	srli	a4,a1,0x1c
 7d8:	973e                	add	a4,a4,a5
 7da:	02e68263          	beq	a3,a4,7fe <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 7de:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7e0:	00001717          	auipc	a4,0x1
 7e4:	82f73023          	sd	a5,-2016(a4) # 1000 <freep>
}
 7e8:	60a2                	ld	ra,8(sp)
 7ea:	6402                	ld	s0,0(sp)
 7ec:	0141                	addi	sp,sp,16
 7ee:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 7f0:	4618                	lw	a4,8(a2)
 7f2:	9f2d                	addw	a4,a4,a1
 7f4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7f8:	6398                	ld	a4,0(a5)
 7fa:	6310                	ld	a2,0(a4)
 7fc:	b7f9                	j	7ca <free+0x44>
    p->s.size += bp->s.size;
 7fe:	ff852703          	lw	a4,-8(a0)
 802:	9f31                	addw	a4,a4,a2
 804:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 806:	ff053683          	ld	a3,-16(a0)
 80a:	bfd1                	j	7de <free+0x58>

000000000000080c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 80c:	7139                	addi	sp,sp,-64
 80e:	fc06                	sd	ra,56(sp)
 810:	f822                	sd	s0,48(sp)
 812:	f04a                	sd	s2,32(sp)
 814:	ec4e                	sd	s3,24(sp)
 816:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 818:	02051993          	slli	s3,a0,0x20
 81c:	0209d993          	srli	s3,s3,0x20
 820:	09bd                	addi	s3,s3,15
 822:	0049d993          	srli	s3,s3,0x4
 826:	2985                	addiw	s3,s3,1
 828:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 82a:	00000517          	auipc	a0,0x0
 82e:	7d653503          	ld	a0,2006(a0) # 1000 <freep>
 832:	c905                	beqz	a0,862 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 834:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 836:	4798                	lw	a4,8(a5)
 838:	09377663          	bgeu	a4,s3,8c4 <malloc+0xb8>
 83c:	f426                	sd	s1,40(sp)
 83e:	e852                	sd	s4,16(sp)
 840:	e456                	sd	s5,8(sp)
 842:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 844:	8a4e                	mv	s4,s3
 846:	6705                	lui	a4,0x1
 848:	00e9f363          	bgeu	s3,a4,84e <malloc+0x42>
 84c:	6a05                	lui	s4,0x1
 84e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 852:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 856:	00000497          	auipc	s1,0x0
 85a:	7aa48493          	addi	s1,s1,1962 # 1000 <freep>
  if(p == SBRK_ERROR)
 85e:	5afd                	li	s5,-1
 860:	a83d                	j	89e <malloc+0x92>
 862:	f426                	sd	s1,40(sp)
 864:	e852                	sd	s4,16(sp)
 866:	e456                	sd	s5,8(sp)
 868:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 86a:	00000797          	auipc	a5,0x0
 86e:	7a678793          	addi	a5,a5,1958 # 1010 <base>
 872:	00000717          	auipc	a4,0x0
 876:	78f73723          	sd	a5,1934(a4) # 1000 <freep>
 87a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 87c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 880:	b7d1                	j	844 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 882:	6398                	ld	a4,0(a5)
 884:	e118                	sd	a4,0(a0)
 886:	a899                	j	8dc <malloc+0xd0>
  hp->s.size = nu;
 888:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 88c:	0541                	addi	a0,a0,16
 88e:	ef9ff0ef          	jal	786 <free>
  return freep;
 892:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 894:	c125                	beqz	a0,8f4 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 896:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 898:	4798                	lw	a4,8(a5)
 89a:	03277163          	bgeu	a4,s2,8bc <malloc+0xb0>
    if(p == freep)
 89e:	6098                	ld	a4,0(s1)
 8a0:	853e                	mv	a0,a5
 8a2:	fef71ae3          	bne	a4,a5,896 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 8a6:	8552                	mv	a0,s4
 8a8:	a23ff0ef          	jal	2ca <sbrk>
  if(p == SBRK_ERROR)
 8ac:	fd551ee3          	bne	a0,s5,888 <malloc+0x7c>
        return 0;
 8b0:	4501                	li	a0,0
 8b2:	74a2                	ld	s1,40(sp)
 8b4:	6a42                	ld	s4,16(sp)
 8b6:	6aa2                	ld	s5,8(sp)
 8b8:	6b02                	ld	s6,0(sp)
 8ba:	a03d                	j	8e8 <malloc+0xdc>
 8bc:	74a2                	ld	s1,40(sp)
 8be:	6a42                	ld	s4,16(sp)
 8c0:	6aa2                	ld	s5,8(sp)
 8c2:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8c4:	fae90fe3          	beq	s2,a4,882 <malloc+0x76>
        p->s.size -= nunits;
 8c8:	4137073b          	subw	a4,a4,s3
 8cc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8ce:	02071693          	slli	a3,a4,0x20
 8d2:	01c6d713          	srli	a4,a3,0x1c
 8d6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8d8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8dc:	00000717          	auipc	a4,0x0
 8e0:	72a73223          	sd	a0,1828(a4) # 1000 <freep>
      return (void*)(p + 1);
 8e4:	01078513          	addi	a0,a5,16
  }
}
 8e8:	70e2                	ld	ra,56(sp)
 8ea:	7442                	ld	s0,48(sp)
 8ec:	7902                	ld	s2,32(sp)
 8ee:	69e2                	ld	s3,24(sp)
 8f0:	6121                	addi	sp,sp,64
 8f2:	8082                	ret
 8f4:	74a2                	ld	s1,40(sp)
 8f6:	6a42                	ld	s4,16(sp)
 8f8:	6aa2                	ld	s5,8(sp)
 8fa:	6b02                	ld	s6,0(sp)
 8fc:	b7f5                	j	8e8 <malloc+0xdc>
