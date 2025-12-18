
user/_test_swapfull:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
//part3 - Test 5: Swap-full termination
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main() {
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	fc26                	sd	s1,56(sp)
   8:	f84a                	sd	s2,48(sp)
   a:	f44e                	sd	s3,40(sp)
   c:	f052                	sd	s4,32(sp)
   e:	ec56                	sd	s5,24(sp)
  10:	e85a                	sd	s6,16(sp)
  12:	e45e                	sd	s7,8(sp)
  14:	e062                	sd	s8,0(sp)
  16:	0880                	addi	s0,sp,80
  printf("Swap-full test starting\n");
  18:	00001517          	auipc	a0,0x1
  1c:	93850513          	addi	a0,a0,-1736 # 950 <malloc+0xfa>
  20:	77e000ef          	jal	79e <printf>
  
  // Allocate more than 1024 pages (your swap cap)
  char *a = sbrk(1200 * 4096);
  24:	004b0537          	lui	a0,0x4b0
  28:	2ec000ef          	jal	314 <sbrk>
  2c:	892a                	mv	s2,a0
  for(int i = 0; i < 1200; i++) {
  2e:	4481                	li	s1,0
    a[i * 4096] = i;   // force dirty evictions
    if(i % 100 == 99) {
  30:	51eb89b7          	lui	s3,0x51eb8
  34:	51f98993          	addi	s3,s3,1311 # 51eb851f <base+0x51eb750f>
  38:	06400b93          	li	s7,100
  3c:	06300b13          	li	s6,99
      printf("Allocated %d pages so far\n", i + 1);
  40:	00001c17          	auipc	s8,0x1
  44:	930c0c13          	addi	s8,s8,-1744 # 970 <malloc+0x11a>
  for(int i = 0; i < 1200; i++) {
  48:	6a85                	lui	s5,0x1
  4a:	4b000a13          	li	s4,1200
  4e:	a029                	j	58 <main+0x58>
  50:	2485                	addiw	s1,s1,1
  52:	9956                	add	s2,s2,s5
  54:	03448663          	beq	s1,s4,80 <main+0x80>
    a[i * 4096] = i;   // force dirty evictions
  58:	00990023          	sb	s1,0(s2)
    if(i % 100 == 99) {
  5c:	033487b3          	mul	a5,s1,s3
  60:	9795                	srai	a5,a5,0x25
  62:	41f4d71b          	sraiw	a4,s1,0x1f
  66:	9f99                	subw	a5,a5,a4
  68:	02fb87bb          	mulw	a5,s7,a5
  6c:	40f487bb          	subw	a5,s1,a5
  70:	ff6790e3          	bne	a5,s6,50 <main+0x50>
      printf("Allocated %d pages so far\n", i + 1);
  74:	0014859b          	addiw	a1,s1,1
  78:	8562                	mv	a0,s8
  7a:	724000ef          	jal	79e <printf>
  7e:	bfc9                	j	50 <main+0x50>
    }
  }
  printf("Should not reach here - swap should be full\n");
  80:	00001517          	auipc	a0,0x1
  84:	91050513          	addi	a0,a0,-1776 # 990 <malloc+0x13a>
  88:	716000ef          	jal	79e <printf>
  exit(0);
  8c:	4501                	li	a0,0
  8e:	2ba000ef          	jal	348 <exit>

0000000000000092 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  92:	1141                	addi	sp,sp,-16
  94:	e406                	sd	ra,8(sp)
  96:	e022                	sd	s0,0(sp)
  98:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  9a:	f67ff0ef          	jal	0 <main>
  exit(r);
  9e:	2aa000ef          	jal	348 <exit>

00000000000000a2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  a2:	1141                	addi	sp,sp,-16
  a4:	e406                	sd	ra,8(sp)
  a6:	e022                	sd	s0,0(sp)
  a8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  aa:	87aa                	mv	a5,a0
  ac:	0585                	addi	a1,a1,1
  ae:	0785                	addi	a5,a5,1
  b0:	fff5c703          	lbu	a4,-1(a1)
  b4:	fee78fa3          	sb	a4,-1(a5)
  b8:	fb75                	bnez	a4,ac <strcpy+0xa>
    ;
  return os;
}
  ba:	60a2                	ld	ra,8(sp)
  bc:	6402                	ld	s0,0(sp)
  be:	0141                	addi	sp,sp,16
  c0:	8082                	ret

00000000000000c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c2:	1141                	addi	sp,sp,-16
  c4:	e406                	sd	ra,8(sp)
  c6:	e022                	sd	s0,0(sp)
  c8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ca:	00054783          	lbu	a5,0(a0)
  ce:	cb91                	beqz	a5,e2 <strcmp+0x20>
  d0:	0005c703          	lbu	a4,0(a1)
  d4:	00f71763          	bne	a4,a5,e2 <strcmp+0x20>
    p++, q++;
  d8:	0505                	addi	a0,a0,1
  da:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  dc:	00054783          	lbu	a5,0(a0)
  e0:	fbe5                	bnez	a5,d0 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  e2:	0005c503          	lbu	a0,0(a1)
}
  e6:	40a7853b          	subw	a0,a5,a0
  ea:	60a2                	ld	ra,8(sp)
  ec:	6402                	ld	s0,0(sp)
  ee:	0141                	addi	sp,sp,16
  f0:	8082                	ret

00000000000000f2 <strlen>:

uint
strlen(const char *s)
{
  f2:	1141                	addi	sp,sp,-16
  f4:	e406                	sd	ra,8(sp)
  f6:	e022                	sd	s0,0(sp)
  f8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  fa:	00054783          	lbu	a5,0(a0)
  fe:	cf91                	beqz	a5,11a <strlen+0x28>
 100:	00150793          	addi	a5,a0,1
 104:	86be                	mv	a3,a5
 106:	0785                	addi	a5,a5,1
 108:	fff7c703          	lbu	a4,-1(a5)
 10c:	ff65                	bnez	a4,104 <strlen+0x12>
 10e:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 112:	60a2                	ld	ra,8(sp)
 114:	6402                	ld	s0,0(sp)
 116:	0141                	addi	sp,sp,16
 118:	8082                	ret
  for(n = 0; s[n]; n++)
 11a:	4501                	li	a0,0
 11c:	bfdd                	j	112 <strlen+0x20>

000000000000011e <memset>:

void*
memset(void *dst, int c, uint n)
{
 11e:	1141                	addi	sp,sp,-16
 120:	e406                	sd	ra,8(sp)
 122:	e022                	sd	s0,0(sp)
 124:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 126:	ca19                	beqz	a2,13c <memset+0x1e>
 128:	87aa                	mv	a5,a0
 12a:	1602                	slli	a2,a2,0x20
 12c:	9201                	srli	a2,a2,0x20
 12e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 132:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 136:	0785                	addi	a5,a5,1
 138:	fee79de3          	bne	a5,a4,132 <memset+0x14>
  }
  return dst;
}
 13c:	60a2                	ld	ra,8(sp)
 13e:	6402                	ld	s0,0(sp)
 140:	0141                	addi	sp,sp,16
 142:	8082                	ret

0000000000000144 <strchr>:

char*
strchr(const char *s, char c)
{
 144:	1141                	addi	sp,sp,-16
 146:	e406                	sd	ra,8(sp)
 148:	e022                	sd	s0,0(sp)
 14a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 14c:	00054783          	lbu	a5,0(a0)
 150:	cf81                	beqz	a5,168 <strchr+0x24>
    if(*s == c)
 152:	00f58763          	beq	a1,a5,160 <strchr+0x1c>
  for(; *s; s++)
 156:	0505                	addi	a0,a0,1
 158:	00054783          	lbu	a5,0(a0)
 15c:	fbfd                	bnez	a5,152 <strchr+0xe>
      return (char*)s;
  return 0;
 15e:	4501                	li	a0,0
}
 160:	60a2                	ld	ra,8(sp)
 162:	6402                	ld	s0,0(sp)
 164:	0141                	addi	sp,sp,16
 166:	8082                	ret
  return 0;
 168:	4501                	li	a0,0
 16a:	bfdd                	j	160 <strchr+0x1c>

000000000000016c <gets>:

char*
gets(char *buf, int max)
{
 16c:	711d                	addi	sp,sp,-96
 16e:	ec86                	sd	ra,88(sp)
 170:	e8a2                	sd	s0,80(sp)
 172:	e4a6                	sd	s1,72(sp)
 174:	e0ca                	sd	s2,64(sp)
 176:	fc4e                	sd	s3,56(sp)
 178:	f852                	sd	s4,48(sp)
 17a:	f456                	sd	s5,40(sp)
 17c:	f05a                	sd	s6,32(sp)
 17e:	ec5e                	sd	s7,24(sp)
 180:	e862                	sd	s8,16(sp)
 182:	1080                	addi	s0,sp,96
 184:	8baa                	mv	s7,a0
 186:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 188:	892a                	mv	s2,a0
 18a:	4481                	li	s1,0
    cc = read(0, &c, 1);
 18c:	faf40b13          	addi	s6,s0,-81
 190:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 192:	8c26                	mv	s8,s1
 194:	0014899b          	addiw	s3,s1,1
 198:	84ce                	mv	s1,s3
 19a:	0349d463          	bge	s3,s4,1c2 <gets+0x56>
    cc = read(0, &c, 1);
 19e:	8656                	mv	a2,s5
 1a0:	85da                	mv	a1,s6
 1a2:	4501                	li	a0,0
 1a4:	1bc000ef          	jal	360 <read>
    if(cc < 1)
 1a8:	00a05d63          	blez	a0,1c2 <gets+0x56>
      break;
    buf[i++] = c;
 1ac:	faf44783          	lbu	a5,-81(s0)
 1b0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1b4:	0905                	addi	s2,s2,1
 1b6:	ff678713          	addi	a4,a5,-10
 1ba:	c319                	beqz	a4,1c0 <gets+0x54>
 1bc:	17cd                	addi	a5,a5,-13
 1be:	fbf1                	bnez	a5,192 <gets+0x26>
    buf[i++] = c;
 1c0:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 1c2:	9c5e                	add	s8,s8,s7
 1c4:	000c0023          	sb	zero,0(s8)
  return buf;
}
 1c8:	855e                	mv	a0,s7
 1ca:	60e6                	ld	ra,88(sp)
 1cc:	6446                	ld	s0,80(sp)
 1ce:	64a6                	ld	s1,72(sp)
 1d0:	6906                	ld	s2,64(sp)
 1d2:	79e2                	ld	s3,56(sp)
 1d4:	7a42                	ld	s4,48(sp)
 1d6:	7aa2                	ld	s5,40(sp)
 1d8:	7b02                	ld	s6,32(sp)
 1da:	6be2                	ld	s7,24(sp)
 1dc:	6c42                	ld	s8,16(sp)
 1de:	6125                	addi	sp,sp,96
 1e0:	8082                	ret

00000000000001e2 <stat>:

int
stat(const char *n, struct stat *st)
{
 1e2:	1101                	addi	sp,sp,-32
 1e4:	ec06                	sd	ra,24(sp)
 1e6:	e822                	sd	s0,16(sp)
 1e8:	e04a                	sd	s2,0(sp)
 1ea:	1000                	addi	s0,sp,32
 1ec:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ee:	4581                	li	a1,0
 1f0:	198000ef          	jal	388 <open>
  if(fd < 0)
 1f4:	02054263          	bltz	a0,218 <stat+0x36>
 1f8:	e426                	sd	s1,8(sp)
 1fa:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1fc:	85ca                	mv	a1,s2
 1fe:	1a2000ef          	jal	3a0 <fstat>
 202:	892a                	mv	s2,a0
  close(fd);
 204:	8526                	mv	a0,s1
 206:	16a000ef          	jal	370 <close>
  return r;
 20a:	64a2                	ld	s1,8(sp)
}
 20c:	854a                	mv	a0,s2
 20e:	60e2                	ld	ra,24(sp)
 210:	6442                	ld	s0,16(sp)
 212:	6902                	ld	s2,0(sp)
 214:	6105                	addi	sp,sp,32
 216:	8082                	ret
    return -1;
 218:	57fd                	li	a5,-1
 21a:	893e                	mv	s2,a5
 21c:	bfc5                	j	20c <stat+0x2a>

000000000000021e <atoi>:

int
atoi(const char *s)
{
 21e:	1141                	addi	sp,sp,-16
 220:	e406                	sd	ra,8(sp)
 222:	e022                	sd	s0,0(sp)
 224:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 226:	00054683          	lbu	a3,0(a0)
 22a:	fd06879b          	addiw	a5,a3,-48
 22e:	0ff7f793          	zext.b	a5,a5
 232:	4625                	li	a2,9
 234:	02f66963          	bltu	a2,a5,266 <atoi+0x48>
 238:	872a                	mv	a4,a0
  n = 0;
 23a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 23c:	0705                	addi	a4,a4,1
 23e:	0025179b          	slliw	a5,a0,0x2
 242:	9fa9                	addw	a5,a5,a0
 244:	0017979b          	slliw	a5,a5,0x1
 248:	9fb5                	addw	a5,a5,a3
 24a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 24e:	00074683          	lbu	a3,0(a4)
 252:	fd06879b          	addiw	a5,a3,-48
 256:	0ff7f793          	zext.b	a5,a5
 25a:	fef671e3          	bgeu	a2,a5,23c <atoi+0x1e>
  return n;
}
 25e:	60a2                	ld	ra,8(sp)
 260:	6402                	ld	s0,0(sp)
 262:	0141                	addi	sp,sp,16
 264:	8082                	ret
  n = 0;
 266:	4501                	li	a0,0
 268:	bfdd                	j	25e <atoi+0x40>

000000000000026a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 26a:	1141                	addi	sp,sp,-16
 26c:	e406                	sd	ra,8(sp)
 26e:	e022                	sd	s0,0(sp)
 270:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 272:	02b57563          	bgeu	a0,a1,29c <memmove+0x32>
    while(n-- > 0)
 276:	00c05f63          	blez	a2,294 <memmove+0x2a>
 27a:	1602                	slli	a2,a2,0x20
 27c:	9201                	srli	a2,a2,0x20
 27e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 282:	872a                	mv	a4,a0
      *dst++ = *src++;
 284:	0585                	addi	a1,a1,1
 286:	0705                	addi	a4,a4,1
 288:	fff5c683          	lbu	a3,-1(a1)
 28c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 290:	fee79ae3          	bne	a5,a4,284 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 294:	60a2                	ld	ra,8(sp)
 296:	6402                	ld	s0,0(sp)
 298:	0141                	addi	sp,sp,16
 29a:	8082                	ret
    while(n-- > 0)
 29c:	fec05ce3          	blez	a2,294 <memmove+0x2a>
    dst += n;
 2a0:	00c50733          	add	a4,a0,a2
    src += n;
 2a4:	95b2                	add	a1,a1,a2
 2a6:	fff6079b          	addiw	a5,a2,-1
 2aa:	1782                	slli	a5,a5,0x20
 2ac:	9381                	srli	a5,a5,0x20
 2ae:	fff7c793          	not	a5,a5
 2b2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2b4:	15fd                	addi	a1,a1,-1
 2b6:	177d                	addi	a4,a4,-1
 2b8:	0005c683          	lbu	a3,0(a1)
 2bc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2c0:	fef71ae3          	bne	a4,a5,2b4 <memmove+0x4a>
 2c4:	bfc1                	j	294 <memmove+0x2a>

00000000000002c6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2c6:	1141                	addi	sp,sp,-16
 2c8:	e406                	sd	ra,8(sp)
 2ca:	e022                	sd	s0,0(sp)
 2cc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2ce:	c61d                	beqz	a2,2fc <memcmp+0x36>
 2d0:	1602                	slli	a2,a2,0x20
 2d2:	9201                	srli	a2,a2,0x20
 2d4:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 2d8:	00054783          	lbu	a5,0(a0)
 2dc:	0005c703          	lbu	a4,0(a1)
 2e0:	00e79863          	bne	a5,a4,2f0 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 2e4:	0505                	addi	a0,a0,1
    p2++;
 2e6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2e8:	fed518e3          	bne	a0,a3,2d8 <memcmp+0x12>
  }
  return 0;
 2ec:	4501                	li	a0,0
 2ee:	a019                	j	2f4 <memcmp+0x2e>
      return *p1 - *p2;
 2f0:	40e7853b          	subw	a0,a5,a4
}
 2f4:	60a2                	ld	ra,8(sp)
 2f6:	6402                	ld	s0,0(sp)
 2f8:	0141                	addi	sp,sp,16
 2fa:	8082                	ret
  return 0;
 2fc:	4501                	li	a0,0
 2fe:	bfdd                	j	2f4 <memcmp+0x2e>

0000000000000300 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 300:	1141                	addi	sp,sp,-16
 302:	e406                	sd	ra,8(sp)
 304:	e022                	sd	s0,0(sp)
 306:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 308:	f63ff0ef          	jal	26a <memmove>
}
 30c:	60a2                	ld	ra,8(sp)
 30e:	6402                	ld	s0,0(sp)
 310:	0141                	addi	sp,sp,16
 312:	8082                	ret

0000000000000314 <sbrk>:

char *
sbrk(int n) {
 314:	1141                	addi	sp,sp,-16
 316:	e406                	sd	ra,8(sp)
 318:	e022                	sd	s0,0(sp)
 31a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 31c:	4585                	li	a1,1
 31e:	0b2000ef          	jal	3d0 <sys_sbrk>
}
 322:	60a2                	ld	ra,8(sp)
 324:	6402                	ld	s0,0(sp)
 326:	0141                	addi	sp,sp,16
 328:	8082                	ret

000000000000032a <sbrklazy>:

char *
sbrklazy(int n) {
 32a:	1141                	addi	sp,sp,-16
 32c:	e406                	sd	ra,8(sp)
 32e:	e022                	sd	s0,0(sp)
 330:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 332:	4589                	li	a1,2
 334:	09c000ef          	jal	3d0 <sys_sbrk>
}
 338:	60a2                	ld	ra,8(sp)
 33a:	6402                	ld	s0,0(sp)
 33c:	0141                	addi	sp,sp,16
 33e:	8082                	ret

0000000000000340 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 340:	4885                	li	a7,1
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <exit>:
.global exit
exit:
 li a7, SYS_exit
 348:	4889                	li	a7,2
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <wait>:
.global wait
wait:
 li a7, SYS_wait
 350:	488d                	li	a7,3
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 358:	4891                	li	a7,4
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <read>:
.global read
read:
 li a7, SYS_read
 360:	4895                	li	a7,5
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <write>:
.global write
write:
 li a7, SYS_write
 368:	48c1                	li	a7,16
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <close>:
.global close
close:
 li a7, SYS_close
 370:	48d5                	li	a7,21
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <kill>:
.global kill
kill:
 li a7, SYS_kill
 378:	4899                	li	a7,6
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <exec>:
.global exec
exec:
 li a7, SYS_exec
 380:	489d                	li	a7,7
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <open>:
.global open
open:
 li a7, SYS_open
 388:	48bd                	li	a7,15
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 390:	48c5                	li	a7,17
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 398:	48c9                	li	a7,18
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3a0:	48a1                	li	a7,8
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <link>:
.global link
link:
 li a7, SYS_link
 3a8:	48cd                	li	a7,19
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3b0:	48d1                	li	a7,20
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3b8:	48a5                	li	a7,9
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3c0:	48a9                	li	a7,10
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3c8:	48ad                	li	a7,11
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3d0:	48b1                	li	a7,12
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3d8:	48b5                	li	a7,13
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3e0:	48b9                	li	a7,14
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <memstat>:
.global memstat
memstat:
 li a7, SYS_memstat
 3e8:	48d9                	li	a7,22
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <enable_bonus>:
.global enable_bonus
enable_bonus:
 li a7, SYS_enable_bonus
 3f0:	48dd                	li	a7,23
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3f8:	1101                	addi	sp,sp,-32
 3fa:	ec06                	sd	ra,24(sp)
 3fc:	e822                	sd	s0,16(sp)
 3fe:	1000                	addi	s0,sp,32
 400:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 404:	4605                	li	a2,1
 406:	fef40593          	addi	a1,s0,-17
 40a:	f5fff0ef          	jal	368 <write>
}
 40e:	60e2                	ld	ra,24(sp)
 410:	6442                	ld	s0,16(sp)
 412:	6105                	addi	sp,sp,32
 414:	8082                	ret

0000000000000416 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 416:	715d                	addi	sp,sp,-80
 418:	e486                	sd	ra,72(sp)
 41a:	e0a2                	sd	s0,64(sp)
 41c:	f84a                	sd	s2,48(sp)
 41e:	f44e                	sd	s3,40(sp)
 420:	0880                	addi	s0,sp,80
 422:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 424:	c6d1                	beqz	a3,4b0 <printint+0x9a>
 426:	0805d563          	bgez	a1,4b0 <printint+0x9a>
    neg = 1;
    x = -xx;
 42a:	40b005b3          	neg	a1,a1
    neg = 1;
 42e:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 430:	fb840993          	addi	s3,s0,-72
  neg = 0;
 434:	86ce                	mv	a3,s3
  i = 0;
 436:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 438:	00000817          	auipc	a6,0x0
 43c:	59080813          	addi	a6,a6,1424 # 9c8 <digits>
 440:	88ba                	mv	a7,a4
 442:	0017051b          	addiw	a0,a4,1
 446:	872a                	mv	a4,a0
 448:	02c5f7b3          	remu	a5,a1,a2
 44c:	97c2                	add	a5,a5,a6
 44e:	0007c783          	lbu	a5,0(a5)
 452:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 456:	87ae                	mv	a5,a1
 458:	02c5d5b3          	divu	a1,a1,a2
 45c:	0685                	addi	a3,a3,1
 45e:	fec7f1e3          	bgeu	a5,a2,440 <printint+0x2a>
  if(neg)
 462:	00030c63          	beqz	t1,47a <printint+0x64>
    buf[i++] = '-';
 466:	fd050793          	addi	a5,a0,-48
 46a:	00878533          	add	a0,a5,s0
 46e:	02d00793          	li	a5,45
 472:	fef50423          	sb	a5,-24(a0)
 476:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 47a:	02e05563          	blez	a4,4a4 <printint+0x8e>
 47e:	fc26                	sd	s1,56(sp)
 480:	377d                	addiw	a4,a4,-1
 482:	00e984b3          	add	s1,s3,a4
 486:	19fd                	addi	s3,s3,-1
 488:	99ba                	add	s3,s3,a4
 48a:	1702                	slli	a4,a4,0x20
 48c:	9301                	srli	a4,a4,0x20
 48e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 492:	0004c583          	lbu	a1,0(s1)
 496:	854a                	mv	a0,s2
 498:	f61ff0ef          	jal	3f8 <putc>
  while(--i >= 0)
 49c:	14fd                	addi	s1,s1,-1
 49e:	ff349ae3          	bne	s1,s3,492 <printint+0x7c>
 4a2:	74e2                	ld	s1,56(sp)
}
 4a4:	60a6                	ld	ra,72(sp)
 4a6:	6406                	ld	s0,64(sp)
 4a8:	7942                	ld	s2,48(sp)
 4aa:	79a2                	ld	s3,40(sp)
 4ac:	6161                	addi	sp,sp,80
 4ae:	8082                	ret
  neg = 0;
 4b0:	4301                	li	t1,0
 4b2:	bfbd                	j	430 <printint+0x1a>

00000000000004b4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4b4:	711d                	addi	sp,sp,-96
 4b6:	ec86                	sd	ra,88(sp)
 4b8:	e8a2                	sd	s0,80(sp)
 4ba:	e4a6                	sd	s1,72(sp)
 4bc:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4be:	0005c483          	lbu	s1,0(a1)
 4c2:	22048363          	beqz	s1,6e8 <vprintf+0x234>
 4c6:	e0ca                	sd	s2,64(sp)
 4c8:	fc4e                	sd	s3,56(sp)
 4ca:	f852                	sd	s4,48(sp)
 4cc:	f456                	sd	s5,40(sp)
 4ce:	f05a                	sd	s6,32(sp)
 4d0:	ec5e                	sd	s7,24(sp)
 4d2:	e862                	sd	s8,16(sp)
 4d4:	8b2a                	mv	s6,a0
 4d6:	8a2e                	mv	s4,a1
 4d8:	8bb2                	mv	s7,a2
  state = 0;
 4da:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4dc:	4901                	li	s2,0
 4de:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4e0:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4e4:	06400c13          	li	s8,100
 4e8:	a00d                	j	50a <vprintf+0x56>
        putc(fd, c0);
 4ea:	85a6                	mv	a1,s1
 4ec:	855a                	mv	a0,s6
 4ee:	f0bff0ef          	jal	3f8 <putc>
 4f2:	a019                	j	4f8 <vprintf+0x44>
    } else if(state == '%'){
 4f4:	03598363          	beq	s3,s5,51a <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 4f8:	0019079b          	addiw	a5,s2,1
 4fc:	893e                	mv	s2,a5
 4fe:	873e                	mv	a4,a5
 500:	97d2                	add	a5,a5,s4
 502:	0007c483          	lbu	s1,0(a5)
 506:	1c048a63          	beqz	s1,6da <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 50a:	0004879b          	sext.w	a5,s1
    if(state == 0){
 50e:	fe0993e3          	bnez	s3,4f4 <vprintf+0x40>
      if(c0 == '%'){
 512:	fd579ce3          	bne	a5,s5,4ea <vprintf+0x36>
        state = '%';
 516:	89be                	mv	s3,a5
 518:	b7c5                	j	4f8 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 51a:	00ea06b3          	add	a3,s4,a4
 51e:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 522:	1c060863          	beqz	a2,6f2 <vprintf+0x23e>
      if(c0 == 'd'){
 526:	03878763          	beq	a5,s8,554 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 52a:	f9478693          	addi	a3,a5,-108
 52e:	0016b693          	seqz	a3,a3
 532:	f9c60593          	addi	a1,a2,-100
 536:	e99d                	bnez	a1,56c <vprintf+0xb8>
 538:	ca95                	beqz	a3,56c <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 53a:	008b8493          	addi	s1,s7,8
 53e:	4685                	li	a3,1
 540:	4629                	li	a2,10
 542:	000bb583          	ld	a1,0(s7)
 546:	855a                	mv	a0,s6
 548:	ecfff0ef          	jal	416 <printint>
        i += 1;
 54c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 54e:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 550:	4981                	li	s3,0
 552:	b75d                	j	4f8 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 554:	008b8493          	addi	s1,s7,8
 558:	4685                	li	a3,1
 55a:	4629                	li	a2,10
 55c:	000ba583          	lw	a1,0(s7)
 560:	855a                	mv	a0,s6
 562:	eb5ff0ef          	jal	416 <printint>
 566:	8ba6                	mv	s7,s1
      state = 0;
 568:	4981                	li	s3,0
 56a:	b779                	j	4f8 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 56c:	9752                	add	a4,a4,s4
 56e:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 572:	f9460713          	addi	a4,a2,-108
 576:	00173713          	seqz	a4,a4
 57a:	8f75                	and	a4,a4,a3
 57c:	f9c58513          	addi	a0,a1,-100
 580:	18051363          	bnez	a0,706 <vprintf+0x252>
 584:	18070163          	beqz	a4,706 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 588:	008b8493          	addi	s1,s7,8
 58c:	4685                	li	a3,1
 58e:	4629                	li	a2,10
 590:	000bb583          	ld	a1,0(s7)
 594:	855a                	mv	a0,s6
 596:	e81ff0ef          	jal	416 <printint>
        i += 2;
 59a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 59c:	8ba6                	mv	s7,s1
      state = 0;
 59e:	4981                	li	s3,0
        i += 2;
 5a0:	bfa1                	j	4f8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5a2:	008b8493          	addi	s1,s7,8
 5a6:	4681                	li	a3,0
 5a8:	4629                	li	a2,10
 5aa:	000be583          	lwu	a1,0(s7)
 5ae:	855a                	mv	a0,s6
 5b0:	e67ff0ef          	jal	416 <printint>
 5b4:	8ba6                	mv	s7,s1
      state = 0;
 5b6:	4981                	li	s3,0
 5b8:	b781                	j	4f8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ba:	008b8493          	addi	s1,s7,8
 5be:	4681                	li	a3,0
 5c0:	4629                	li	a2,10
 5c2:	000bb583          	ld	a1,0(s7)
 5c6:	855a                	mv	a0,s6
 5c8:	e4fff0ef          	jal	416 <printint>
        i += 1;
 5cc:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ce:	8ba6                	mv	s7,s1
      state = 0;
 5d0:	4981                	li	s3,0
 5d2:	b71d                	j	4f8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5d4:	008b8493          	addi	s1,s7,8
 5d8:	4681                	li	a3,0
 5da:	4629                	li	a2,10
 5dc:	000bb583          	ld	a1,0(s7)
 5e0:	855a                	mv	a0,s6
 5e2:	e35ff0ef          	jal	416 <printint>
        i += 2;
 5e6:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5e8:	8ba6                	mv	s7,s1
      state = 0;
 5ea:	4981                	li	s3,0
        i += 2;
 5ec:	b731                	j	4f8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 5ee:	008b8493          	addi	s1,s7,8
 5f2:	4681                	li	a3,0
 5f4:	4641                	li	a2,16
 5f6:	000be583          	lwu	a1,0(s7)
 5fa:	855a                	mv	a0,s6
 5fc:	e1bff0ef          	jal	416 <printint>
 600:	8ba6                	mv	s7,s1
      state = 0;
 602:	4981                	li	s3,0
 604:	bdd5                	j	4f8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 606:	008b8493          	addi	s1,s7,8
 60a:	4681                	li	a3,0
 60c:	4641                	li	a2,16
 60e:	000bb583          	ld	a1,0(s7)
 612:	855a                	mv	a0,s6
 614:	e03ff0ef          	jal	416 <printint>
        i += 1;
 618:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 61a:	8ba6                	mv	s7,s1
      state = 0;
 61c:	4981                	li	s3,0
 61e:	bde9                	j	4f8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 620:	008b8493          	addi	s1,s7,8
 624:	4681                	li	a3,0
 626:	4641                	li	a2,16
 628:	000bb583          	ld	a1,0(s7)
 62c:	855a                	mv	a0,s6
 62e:	de9ff0ef          	jal	416 <printint>
        i += 2;
 632:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 634:	8ba6                	mv	s7,s1
      state = 0;
 636:	4981                	li	s3,0
        i += 2;
 638:	b5c1                	j	4f8 <vprintf+0x44>
 63a:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 63c:	008b8793          	addi	a5,s7,8
 640:	8cbe                	mv	s9,a5
 642:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 646:	03000593          	li	a1,48
 64a:	855a                	mv	a0,s6
 64c:	dadff0ef          	jal	3f8 <putc>
  putc(fd, 'x');
 650:	07800593          	li	a1,120
 654:	855a                	mv	a0,s6
 656:	da3ff0ef          	jal	3f8 <putc>
 65a:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 65c:	00000b97          	auipc	s7,0x0
 660:	36cb8b93          	addi	s7,s7,876 # 9c8 <digits>
 664:	03c9d793          	srli	a5,s3,0x3c
 668:	97de                	add	a5,a5,s7
 66a:	0007c583          	lbu	a1,0(a5)
 66e:	855a                	mv	a0,s6
 670:	d89ff0ef          	jal	3f8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 674:	0992                	slli	s3,s3,0x4
 676:	34fd                	addiw	s1,s1,-1
 678:	f4f5                	bnez	s1,664 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 67a:	8be6                	mv	s7,s9
      state = 0;
 67c:	4981                	li	s3,0
 67e:	6ca2                	ld	s9,8(sp)
 680:	bda5                	j	4f8 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 682:	008b8493          	addi	s1,s7,8
 686:	000bc583          	lbu	a1,0(s7)
 68a:	855a                	mv	a0,s6
 68c:	d6dff0ef          	jal	3f8 <putc>
 690:	8ba6                	mv	s7,s1
      state = 0;
 692:	4981                	li	s3,0
 694:	b595                	j	4f8 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 696:	008b8993          	addi	s3,s7,8
 69a:	000bb483          	ld	s1,0(s7)
 69e:	cc91                	beqz	s1,6ba <vprintf+0x206>
        for(; *s; s++)
 6a0:	0004c583          	lbu	a1,0(s1)
 6a4:	c985                	beqz	a1,6d4 <vprintf+0x220>
          putc(fd, *s);
 6a6:	855a                	mv	a0,s6
 6a8:	d51ff0ef          	jal	3f8 <putc>
        for(; *s; s++)
 6ac:	0485                	addi	s1,s1,1
 6ae:	0004c583          	lbu	a1,0(s1)
 6b2:	f9f5                	bnez	a1,6a6 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 6b4:	8bce                	mv	s7,s3
      state = 0;
 6b6:	4981                	li	s3,0
 6b8:	b581                	j	4f8 <vprintf+0x44>
          s = "(null)";
 6ba:	00000497          	auipc	s1,0x0
 6be:	30648493          	addi	s1,s1,774 # 9c0 <malloc+0x16a>
        for(; *s; s++)
 6c2:	02800593          	li	a1,40
 6c6:	b7c5                	j	6a6 <vprintf+0x1f2>
        putc(fd, '%');
 6c8:	85be                	mv	a1,a5
 6ca:	855a                	mv	a0,s6
 6cc:	d2dff0ef          	jal	3f8 <putc>
      state = 0;
 6d0:	4981                	li	s3,0
 6d2:	b51d                	j	4f8 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6d4:	8bce                	mv	s7,s3
      state = 0;
 6d6:	4981                	li	s3,0
 6d8:	b505                	j	4f8 <vprintf+0x44>
 6da:	6906                	ld	s2,64(sp)
 6dc:	79e2                	ld	s3,56(sp)
 6de:	7a42                	ld	s4,48(sp)
 6e0:	7aa2                	ld	s5,40(sp)
 6e2:	7b02                	ld	s6,32(sp)
 6e4:	6be2                	ld	s7,24(sp)
 6e6:	6c42                	ld	s8,16(sp)
    }
  }
}
 6e8:	60e6                	ld	ra,88(sp)
 6ea:	6446                	ld	s0,80(sp)
 6ec:	64a6                	ld	s1,72(sp)
 6ee:	6125                	addi	sp,sp,96
 6f0:	8082                	ret
      if(c0 == 'd'){
 6f2:	06400713          	li	a4,100
 6f6:	e4e78fe3          	beq	a5,a4,554 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 6fa:	f9478693          	addi	a3,a5,-108
 6fe:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 702:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 704:	4701                	li	a4,0
      } else if(c0 == 'u'){
 706:	07500513          	li	a0,117
 70a:	e8a78ce3          	beq	a5,a0,5a2 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 70e:	f8b60513          	addi	a0,a2,-117
 712:	e119                	bnez	a0,718 <vprintf+0x264>
 714:	ea0693e3          	bnez	a3,5ba <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 718:	f8b58513          	addi	a0,a1,-117
 71c:	e119                	bnez	a0,722 <vprintf+0x26e>
 71e:	ea071be3          	bnez	a4,5d4 <vprintf+0x120>
      } else if(c0 == 'x'){
 722:	07800513          	li	a0,120
 726:	eca784e3          	beq	a5,a0,5ee <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 72a:	f8860613          	addi	a2,a2,-120
 72e:	e219                	bnez	a2,734 <vprintf+0x280>
 730:	ec069be3          	bnez	a3,606 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 734:	f8858593          	addi	a1,a1,-120
 738:	e199                	bnez	a1,73e <vprintf+0x28a>
 73a:	ee0713e3          	bnez	a4,620 <vprintf+0x16c>
      } else if(c0 == 'p'){
 73e:	07000713          	li	a4,112
 742:	eee78ce3          	beq	a5,a4,63a <vprintf+0x186>
      } else if(c0 == 'c'){
 746:	06300713          	li	a4,99
 74a:	f2e78ce3          	beq	a5,a4,682 <vprintf+0x1ce>
      } else if(c0 == 's'){
 74e:	07300713          	li	a4,115
 752:	f4e782e3          	beq	a5,a4,696 <vprintf+0x1e2>
      } else if(c0 == '%'){
 756:	02500713          	li	a4,37
 75a:	f6e787e3          	beq	a5,a4,6c8 <vprintf+0x214>
        putc(fd, '%');
 75e:	02500593          	li	a1,37
 762:	855a                	mv	a0,s6
 764:	c95ff0ef          	jal	3f8 <putc>
        putc(fd, c0);
 768:	85a6                	mv	a1,s1
 76a:	855a                	mv	a0,s6
 76c:	c8dff0ef          	jal	3f8 <putc>
      state = 0;
 770:	4981                	li	s3,0
 772:	b359                	j	4f8 <vprintf+0x44>

0000000000000774 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 774:	715d                	addi	sp,sp,-80
 776:	ec06                	sd	ra,24(sp)
 778:	e822                	sd	s0,16(sp)
 77a:	1000                	addi	s0,sp,32
 77c:	e010                	sd	a2,0(s0)
 77e:	e414                	sd	a3,8(s0)
 780:	e818                	sd	a4,16(s0)
 782:	ec1c                	sd	a5,24(s0)
 784:	03043023          	sd	a6,32(s0)
 788:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 78c:	8622                	mv	a2,s0
 78e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 792:	d23ff0ef          	jal	4b4 <vprintf>
}
 796:	60e2                	ld	ra,24(sp)
 798:	6442                	ld	s0,16(sp)
 79a:	6161                	addi	sp,sp,80
 79c:	8082                	ret

000000000000079e <printf>:

void
printf(const char *fmt, ...)
{
 79e:	711d                	addi	sp,sp,-96
 7a0:	ec06                	sd	ra,24(sp)
 7a2:	e822                	sd	s0,16(sp)
 7a4:	1000                	addi	s0,sp,32
 7a6:	e40c                	sd	a1,8(s0)
 7a8:	e810                	sd	a2,16(s0)
 7aa:	ec14                	sd	a3,24(s0)
 7ac:	f018                	sd	a4,32(s0)
 7ae:	f41c                	sd	a5,40(s0)
 7b0:	03043823          	sd	a6,48(s0)
 7b4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7b8:	00840613          	addi	a2,s0,8
 7bc:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7c0:	85aa                	mv	a1,a0
 7c2:	4505                	li	a0,1
 7c4:	cf1ff0ef          	jal	4b4 <vprintf>
}
 7c8:	60e2                	ld	ra,24(sp)
 7ca:	6442                	ld	s0,16(sp)
 7cc:	6125                	addi	sp,sp,96
 7ce:	8082                	ret

00000000000007d0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7d0:	1141                	addi	sp,sp,-16
 7d2:	e406                	sd	ra,8(sp)
 7d4:	e022                	sd	s0,0(sp)
 7d6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7d8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7dc:	00001797          	auipc	a5,0x1
 7e0:	8247b783          	ld	a5,-2012(a5) # 1000 <freep>
 7e4:	a039                	j	7f2 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e6:	6398                	ld	a4,0(a5)
 7e8:	00e7e463          	bltu	a5,a4,7f0 <free+0x20>
 7ec:	00e6ea63          	bltu	a3,a4,800 <free+0x30>
{
 7f0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f2:	fed7fae3          	bgeu	a5,a3,7e6 <free+0x16>
 7f6:	6398                	ld	a4,0(a5)
 7f8:	00e6e463          	bltu	a3,a4,800 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7fc:	fee7eae3          	bltu	a5,a4,7f0 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 800:	ff852583          	lw	a1,-8(a0)
 804:	6390                	ld	a2,0(a5)
 806:	02059813          	slli	a6,a1,0x20
 80a:	01c85713          	srli	a4,a6,0x1c
 80e:	9736                	add	a4,a4,a3
 810:	02e60563          	beq	a2,a4,83a <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 814:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 818:	4790                	lw	a2,8(a5)
 81a:	02061593          	slli	a1,a2,0x20
 81e:	01c5d713          	srli	a4,a1,0x1c
 822:	973e                	add	a4,a4,a5
 824:	02e68263          	beq	a3,a4,848 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 828:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 82a:	00000717          	auipc	a4,0x0
 82e:	7cf73b23          	sd	a5,2006(a4) # 1000 <freep>
}
 832:	60a2                	ld	ra,8(sp)
 834:	6402                	ld	s0,0(sp)
 836:	0141                	addi	sp,sp,16
 838:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 83a:	4618                	lw	a4,8(a2)
 83c:	9f2d                	addw	a4,a4,a1
 83e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 842:	6398                	ld	a4,0(a5)
 844:	6310                	ld	a2,0(a4)
 846:	b7f9                	j	814 <free+0x44>
    p->s.size += bp->s.size;
 848:	ff852703          	lw	a4,-8(a0)
 84c:	9f31                	addw	a4,a4,a2
 84e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 850:	ff053683          	ld	a3,-16(a0)
 854:	bfd1                	j	828 <free+0x58>

0000000000000856 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 856:	7139                	addi	sp,sp,-64
 858:	fc06                	sd	ra,56(sp)
 85a:	f822                	sd	s0,48(sp)
 85c:	f04a                	sd	s2,32(sp)
 85e:	ec4e                	sd	s3,24(sp)
 860:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 862:	02051993          	slli	s3,a0,0x20
 866:	0209d993          	srli	s3,s3,0x20
 86a:	09bd                	addi	s3,s3,15
 86c:	0049d993          	srli	s3,s3,0x4
 870:	2985                	addiw	s3,s3,1
 872:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 874:	00000517          	auipc	a0,0x0
 878:	78c53503          	ld	a0,1932(a0) # 1000 <freep>
 87c:	c905                	beqz	a0,8ac <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 87e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 880:	4798                	lw	a4,8(a5)
 882:	09377663          	bgeu	a4,s3,90e <malloc+0xb8>
 886:	f426                	sd	s1,40(sp)
 888:	e852                	sd	s4,16(sp)
 88a:	e456                	sd	s5,8(sp)
 88c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 88e:	8a4e                	mv	s4,s3
 890:	6705                	lui	a4,0x1
 892:	00e9f363          	bgeu	s3,a4,898 <malloc+0x42>
 896:	6a05                	lui	s4,0x1
 898:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 89c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8a0:	00000497          	auipc	s1,0x0
 8a4:	76048493          	addi	s1,s1,1888 # 1000 <freep>
  if(p == SBRK_ERROR)
 8a8:	5afd                	li	s5,-1
 8aa:	a83d                	j	8e8 <malloc+0x92>
 8ac:	f426                	sd	s1,40(sp)
 8ae:	e852                	sd	s4,16(sp)
 8b0:	e456                	sd	s5,8(sp)
 8b2:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8b4:	00000797          	auipc	a5,0x0
 8b8:	75c78793          	addi	a5,a5,1884 # 1010 <base>
 8bc:	00000717          	auipc	a4,0x0
 8c0:	74f73223          	sd	a5,1860(a4) # 1000 <freep>
 8c4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8c6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8ca:	b7d1                	j	88e <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8cc:	6398                	ld	a4,0(a5)
 8ce:	e118                	sd	a4,0(a0)
 8d0:	a899                	j	926 <malloc+0xd0>
  hp->s.size = nu;
 8d2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8d6:	0541                	addi	a0,a0,16
 8d8:	ef9ff0ef          	jal	7d0 <free>
  return freep;
 8dc:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8de:	c125                	beqz	a0,93e <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e2:	4798                	lw	a4,8(a5)
 8e4:	03277163          	bgeu	a4,s2,906 <malloc+0xb0>
    if(p == freep)
 8e8:	6098                	ld	a4,0(s1)
 8ea:	853e                	mv	a0,a5
 8ec:	fef71ae3          	bne	a4,a5,8e0 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 8f0:	8552                	mv	a0,s4
 8f2:	a23ff0ef          	jal	314 <sbrk>
  if(p == SBRK_ERROR)
 8f6:	fd551ee3          	bne	a0,s5,8d2 <malloc+0x7c>
        return 0;
 8fa:	4501                	li	a0,0
 8fc:	74a2                	ld	s1,40(sp)
 8fe:	6a42                	ld	s4,16(sp)
 900:	6aa2                	ld	s5,8(sp)
 902:	6b02                	ld	s6,0(sp)
 904:	a03d                	j	932 <malloc+0xdc>
 906:	74a2                	ld	s1,40(sp)
 908:	6a42                	ld	s4,16(sp)
 90a:	6aa2                	ld	s5,8(sp)
 90c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 90e:	fae90fe3          	beq	s2,a4,8cc <malloc+0x76>
        p->s.size -= nunits;
 912:	4137073b          	subw	a4,a4,s3
 916:	c798                	sw	a4,8(a5)
        p += p->s.size;
 918:	02071693          	slli	a3,a4,0x20
 91c:	01c6d713          	srli	a4,a3,0x1c
 920:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 922:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 926:	00000717          	auipc	a4,0x0
 92a:	6ca73d23          	sd	a0,1754(a4) # 1000 <freep>
      return (void*)(p + 1);
 92e:	01078513          	addi	a0,a5,16
  }
}
 932:	70e2                	ld	ra,56(sp)
 934:	7442                	ld	s0,48(sp)
 936:	7902                	ld	s2,32(sp)
 938:	69e2                	ld	s3,24(sp)
 93a:	6121                	addi	sp,sp,64
 93c:	8082                	ret
 93e:	74a2                	ld	s1,40(sp)
 940:	6a42                	ld	s4,16(sp)
 942:	6aa2                	ld	s5,8(sp)
 944:	6b02                	ld	s6,0(sp)
 946:	b7f5                	j	932 <malloc+0xdc>
