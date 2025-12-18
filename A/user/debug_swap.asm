
user/_debug_swap:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
//Debug simple swap test
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
  14:	0880                	addi	s0,sp,80
  int pid = getpid();
  16:	3d6000ef          	jal	3ec <getpid>
  1a:	85aa                	mv	a1,a0
  printf("Debug swap test (PID %d)\n", pid);
  1c:	00001517          	auipc	a0,0x1
  20:	95450513          	addi	a0,a0,-1708 # 970 <malloc+0xf6>
  24:	79e000ef          	jal	7c2 <printf>
  
  // Allocate just a few pages to force swapping
  char *a = sbrk(40 * 4096);  // 40 pages to force some swapping
  28:	00028537          	lui	a0,0x28
  2c:	30c000ef          	jal	338 <sbrk>
  30:	892a                	mv	s2,a0
  32:	89aa                	mv	s3,a0
  34:	0c800493          	li	s1,200
  
  // Write unique data to first byte of each page
  for(int i = 0; i < 40; i++) {
    a[i * 4096] = 200 + i;  // Write values 200, 201, 202, ...
    printf("Written: page %d = %d\n", i, 200 + i);
  38:	00001b17          	auipc	s6,0x1
  3c:	958b0b13          	addi	s6,s6,-1704 # 990 <malloc+0x116>
  for(int i = 0; i < 40; i++) {
  40:	6a85                	lui	s5,0x1
  42:	0f000a13          	li	s4,240
    a[i * 4096] = 200 + i;  // Write values 200, 201, 202, ...
  46:	00998023          	sb	s1,0(s3)
    printf("Written: page %d = %d\n", i, 200 + i);
  4a:	8626                	mv	a2,s1
  4c:	f384859b          	addiw	a1,s1,-200
  50:	855a                	mv	a0,s6
  52:	770000ef          	jal	7c2 <printf>
  for(int i = 0; i < 40; i++) {
  56:	99d6                	add	s3,s3,s5
  58:	2485                	addiw	s1,s1,1
  5a:	ff4496e3          	bne	s1,s4,46 <main+0x46>
  }
  
  printf("All writes complete, now reading back...\n");
  5e:	00001517          	auipc	a0,0x1
  62:	94a50513          	addi	a0,a0,-1718 # 9a8 <malloc+0x12e>
  66:	75c000ef          	jal	7c2 <printf>
  6a:	0c800493          	li	s1,200
  
  // Read back and verify
  int errors = 0;
  6e:	4a01                	li	s4,0
  for(int i = 0; i < 40; i++) {
    int expected = 200 + i;
    int actual = a[i * 4096];
    printf("Read: page %d = %d (expected %d)\n", i, actual, expected);
  70:	00001b97          	auipc	s7,0x1
  74:	968b8b93          	addi	s7,s7,-1688 # 9d8 <malloc+0x15e>
  for(int i = 0; i < 40; i++) {
  78:	6b05                	lui	s6,0x1
  7a:	0f000a93          	li	s5,240
  7e:	a029                	j	88 <main+0x88>
  80:	995a                	add	s2,s2,s6
  82:	2485                	addiw	s1,s1,1
  84:	01548f63          	beq	s1,s5,a2 <main+0xa2>
    int actual = a[i * 4096];
  88:	00094983          	lbu	s3,0(s2)
    printf("Read: page %d = %d (expected %d)\n", i, actual, expected);
  8c:	86a6                	mv	a3,s1
  8e:	864e                	mv	a2,s3
  90:	f384859b          	addiw	a1,s1,-200
  94:	855e                	mv	a0,s7
  96:	72c000ef          	jal	7c2 <printf>
    if(actual != expected) {
  9a:	ff3483e3          	beq	s1,s3,80 <main+0x80>
      errors++;
  9e:	2a05                	addiw	s4,s4,1
  a0:	b7c5                	j	80 <main+0x80>
    }
  }
  
  printf("Debug test done: %d errors out of 40 pages\n", errors);
  a2:	85d2                	mv	a1,s4
  a4:	00001517          	auipc	a0,0x1
  a8:	95c50513          	addi	a0,a0,-1700 # a00 <malloc+0x186>
  ac:	716000ef          	jal	7c2 <printf>
  exit(0);
  b0:	4501                	li	a0,0
  b2:	2ba000ef          	jal	36c <exit>

00000000000000b6 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  b6:	1141                	addi	sp,sp,-16
  b8:	e406                	sd	ra,8(sp)
  ba:	e022                	sd	s0,0(sp)
  bc:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  be:	f43ff0ef          	jal	0 <main>
  exit(r);
  c2:	2aa000ef          	jal	36c <exit>

00000000000000c6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  c6:	1141                	addi	sp,sp,-16
  c8:	e406                	sd	ra,8(sp)
  ca:	e022                	sd	s0,0(sp)
  cc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ce:	87aa                	mv	a5,a0
  d0:	0585                	addi	a1,a1,1
  d2:	0785                	addi	a5,a5,1
  d4:	fff5c703          	lbu	a4,-1(a1)
  d8:	fee78fa3          	sb	a4,-1(a5)
  dc:	fb75                	bnez	a4,d0 <strcpy+0xa>
    ;
  return os;
}
  de:	60a2                	ld	ra,8(sp)
  e0:	6402                	ld	s0,0(sp)
  e2:	0141                	addi	sp,sp,16
  e4:	8082                	ret

00000000000000e6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e6:	1141                	addi	sp,sp,-16
  e8:	e406                	sd	ra,8(sp)
  ea:	e022                	sd	s0,0(sp)
  ec:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ee:	00054783          	lbu	a5,0(a0)
  f2:	cb91                	beqz	a5,106 <strcmp+0x20>
  f4:	0005c703          	lbu	a4,0(a1)
  f8:	00f71763          	bne	a4,a5,106 <strcmp+0x20>
    p++, q++;
  fc:	0505                	addi	a0,a0,1
  fe:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 100:	00054783          	lbu	a5,0(a0)
 104:	fbe5                	bnez	a5,f4 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 106:	0005c503          	lbu	a0,0(a1)
}
 10a:	40a7853b          	subw	a0,a5,a0
 10e:	60a2                	ld	ra,8(sp)
 110:	6402                	ld	s0,0(sp)
 112:	0141                	addi	sp,sp,16
 114:	8082                	ret

0000000000000116 <strlen>:

uint
strlen(const char *s)
{
 116:	1141                	addi	sp,sp,-16
 118:	e406                	sd	ra,8(sp)
 11a:	e022                	sd	s0,0(sp)
 11c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 11e:	00054783          	lbu	a5,0(a0)
 122:	cf91                	beqz	a5,13e <strlen+0x28>
 124:	00150793          	addi	a5,a0,1
 128:	86be                	mv	a3,a5
 12a:	0785                	addi	a5,a5,1
 12c:	fff7c703          	lbu	a4,-1(a5)
 130:	ff65                	bnez	a4,128 <strlen+0x12>
 132:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 136:	60a2                	ld	ra,8(sp)
 138:	6402                	ld	s0,0(sp)
 13a:	0141                	addi	sp,sp,16
 13c:	8082                	ret
  for(n = 0; s[n]; n++)
 13e:	4501                	li	a0,0
 140:	bfdd                	j	136 <strlen+0x20>

0000000000000142 <memset>:

void*
memset(void *dst, int c, uint n)
{
 142:	1141                	addi	sp,sp,-16
 144:	e406                	sd	ra,8(sp)
 146:	e022                	sd	s0,0(sp)
 148:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 14a:	ca19                	beqz	a2,160 <memset+0x1e>
 14c:	87aa                	mv	a5,a0
 14e:	1602                	slli	a2,a2,0x20
 150:	9201                	srli	a2,a2,0x20
 152:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 156:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 15a:	0785                	addi	a5,a5,1
 15c:	fee79de3          	bne	a5,a4,156 <memset+0x14>
  }
  return dst;
}
 160:	60a2                	ld	ra,8(sp)
 162:	6402                	ld	s0,0(sp)
 164:	0141                	addi	sp,sp,16
 166:	8082                	ret

0000000000000168 <strchr>:

char*
strchr(const char *s, char c)
{
 168:	1141                	addi	sp,sp,-16
 16a:	e406                	sd	ra,8(sp)
 16c:	e022                	sd	s0,0(sp)
 16e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 170:	00054783          	lbu	a5,0(a0)
 174:	cf81                	beqz	a5,18c <strchr+0x24>
    if(*s == c)
 176:	00f58763          	beq	a1,a5,184 <strchr+0x1c>
  for(; *s; s++)
 17a:	0505                	addi	a0,a0,1
 17c:	00054783          	lbu	a5,0(a0)
 180:	fbfd                	bnez	a5,176 <strchr+0xe>
      return (char*)s;
  return 0;
 182:	4501                	li	a0,0
}
 184:	60a2                	ld	ra,8(sp)
 186:	6402                	ld	s0,0(sp)
 188:	0141                	addi	sp,sp,16
 18a:	8082                	ret
  return 0;
 18c:	4501                	li	a0,0
 18e:	bfdd                	j	184 <strchr+0x1c>

0000000000000190 <gets>:

char*
gets(char *buf, int max)
{
 190:	711d                	addi	sp,sp,-96
 192:	ec86                	sd	ra,88(sp)
 194:	e8a2                	sd	s0,80(sp)
 196:	e4a6                	sd	s1,72(sp)
 198:	e0ca                	sd	s2,64(sp)
 19a:	fc4e                	sd	s3,56(sp)
 19c:	f852                	sd	s4,48(sp)
 19e:	f456                	sd	s5,40(sp)
 1a0:	f05a                	sd	s6,32(sp)
 1a2:	ec5e                	sd	s7,24(sp)
 1a4:	e862                	sd	s8,16(sp)
 1a6:	1080                	addi	s0,sp,96
 1a8:	8baa                	mv	s7,a0
 1aa:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ac:	892a                	mv	s2,a0
 1ae:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1b0:	faf40b13          	addi	s6,s0,-81
 1b4:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 1b6:	8c26                	mv	s8,s1
 1b8:	0014899b          	addiw	s3,s1,1
 1bc:	84ce                	mv	s1,s3
 1be:	0349d463          	bge	s3,s4,1e6 <gets+0x56>
    cc = read(0, &c, 1);
 1c2:	8656                	mv	a2,s5
 1c4:	85da                	mv	a1,s6
 1c6:	4501                	li	a0,0
 1c8:	1bc000ef          	jal	384 <read>
    if(cc < 1)
 1cc:	00a05d63          	blez	a0,1e6 <gets+0x56>
      break;
    buf[i++] = c;
 1d0:	faf44783          	lbu	a5,-81(s0)
 1d4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1d8:	0905                	addi	s2,s2,1
 1da:	ff678713          	addi	a4,a5,-10
 1de:	c319                	beqz	a4,1e4 <gets+0x54>
 1e0:	17cd                	addi	a5,a5,-13
 1e2:	fbf1                	bnez	a5,1b6 <gets+0x26>
    buf[i++] = c;
 1e4:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 1e6:	9c5e                	add	s8,s8,s7
 1e8:	000c0023          	sb	zero,0(s8)
  return buf;
}
 1ec:	855e                	mv	a0,s7
 1ee:	60e6                	ld	ra,88(sp)
 1f0:	6446                	ld	s0,80(sp)
 1f2:	64a6                	ld	s1,72(sp)
 1f4:	6906                	ld	s2,64(sp)
 1f6:	79e2                	ld	s3,56(sp)
 1f8:	7a42                	ld	s4,48(sp)
 1fa:	7aa2                	ld	s5,40(sp)
 1fc:	7b02                	ld	s6,32(sp)
 1fe:	6be2                	ld	s7,24(sp)
 200:	6c42                	ld	s8,16(sp)
 202:	6125                	addi	sp,sp,96
 204:	8082                	ret

0000000000000206 <stat>:

int
stat(const char *n, struct stat *st)
{
 206:	1101                	addi	sp,sp,-32
 208:	ec06                	sd	ra,24(sp)
 20a:	e822                	sd	s0,16(sp)
 20c:	e04a                	sd	s2,0(sp)
 20e:	1000                	addi	s0,sp,32
 210:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 212:	4581                	li	a1,0
 214:	198000ef          	jal	3ac <open>
  if(fd < 0)
 218:	02054263          	bltz	a0,23c <stat+0x36>
 21c:	e426                	sd	s1,8(sp)
 21e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 220:	85ca                	mv	a1,s2
 222:	1a2000ef          	jal	3c4 <fstat>
 226:	892a                	mv	s2,a0
  close(fd);
 228:	8526                	mv	a0,s1
 22a:	16a000ef          	jal	394 <close>
  return r;
 22e:	64a2                	ld	s1,8(sp)
}
 230:	854a                	mv	a0,s2
 232:	60e2                	ld	ra,24(sp)
 234:	6442                	ld	s0,16(sp)
 236:	6902                	ld	s2,0(sp)
 238:	6105                	addi	sp,sp,32
 23a:	8082                	ret
    return -1;
 23c:	57fd                	li	a5,-1
 23e:	893e                	mv	s2,a5
 240:	bfc5                	j	230 <stat+0x2a>

0000000000000242 <atoi>:

int
atoi(const char *s)
{
 242:	1141                	addi	sp,sp,-16
 244:	e406                	sd	ra,8(sp)
 246:	e022                	sd	s0,0(sp)
 248:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 24a:	00054683          	lbu	a3,0(a0)
 24e:	fd06879b          	addiw	a5,a3,-48
 252:	0ff7f793          	zext.b	a5,a5
 256:	4625                	li	a2,9
 258:	02f66963          	bltu	a2,a5,28a <atoi+0x48>
 25c:	872a                	mv	a4,a0
  n = 0;
 25e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 260:	0705                	addi	a4,a4,1
 262:	0025179b          	slliw	a5,a0,0x2
 266:	9fa9                	addw	a5,a5,a0
 268:	0017979b          	slliw	a5,a5,0x1
 26c:	9fb5                	addw	a5,a5,a3
 26e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 272:	00074683          	lbu	a3,0(a4)
 276:	fd06879b          	addiw	a5,a3,-48
 27a:	0ff7f793          	zext.b	a5,a5
 27e:	fef671e3          	bgeu	a2,a5,260 <atoi+0x1e>
  return n;
}
 282:	60a2                	ld	ra,8(sp)
 284:	6402                	ld	s0,0(sp)
 286:	0141                	addi	sp,sp,16
 288:	8082                	ret
  n = 0;
 28a:	4501                	li	a0,0
 28c:	bfdd                	j	282 <atoi+0x40>

000000000000028e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 28e:	1141                	addi	sp,sp,-16
 290:	e406                	sd	ra,8(sp)
 292:	e022                	sd	s0,0(sp)
 294:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 296:	02b57563          	bgeu	a0,a1,2c0 <memmove+0x32>
    while(n-- > 0)
 29a:	00c05f63          	blez	a2,2b8 <memmove+0x2a>
 29e:	1602                	slli	a2,a2,0x20
 2a0:	9201                	srli	a2,a2,0x20
 2a2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2a6:	872a                	mv	a4,a0
      *dst++ = *src++;
 2a8:	0585                	addi	a1,a1,1
 2aa:	0705                	addi	a4,a4,1
 2ac:	fff5c683          	lbu	a3,-1(a1)
 2b0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2b4:	fee79ae3          	bne	a5,a4,2a8 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2b8:	60a2                	ld	ra,8(sp)
 2ba:	6402                	ld	s0,0(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret
    while(n-- > 0)
 2c0:	fec05ce3          	blez	a2,2b8 <memmove+0x2a>
    dst += n;
 2c4:	00c50733          	add	a4,a0,a2
    src += n;
 2c8:	95b2                	add	a1,a1,a2
 2ca:	fff6079b          	addiw	a5,a2,-1
 2ce:	1782                	slli	a5,a5,0x20
 2d0:	9381                	srli	a5,a5,0x20
 2d2:	fff7c793          	not	a5,a5
 2d6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2d8:	15fd                	addi	a1,a1,-1
 2da:	177d                	addi	a4,a4,-1
 2dc:	0005c683          	lbu	a3,0(a1)
 2e0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2e4:	fef71ae3          	bne	a4,a5,2d8 <memmove+0x4a>
 2e8:	bfc1                	j	2b8 <memmove+0x2a>

00000000000002ea <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2ea:	1141                	addi	sp,sp,-16
 2ec:	e406                	sd	ra,8(sp)
 2ee:	e022                	sd	s0,0(sp)
 2f0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2f2:	c61d                	beqz	a2,320 <memcmp+0x36>
 2f4:	1602                	slli	a2,a2,0x20
 2f6:	9201                	srli	a2,a2,0x20
 2f8:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 2fc:	00054783          	lbu	a5,0(a0)
 300:	0005c703          	lbu	a4,0(a1)
 304:	00e79863          	bne	a5,a4,314 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 308:	0505                	addi	a0,a0,1
    p2++;
 30a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 30c:	fed518e3          	bne	a0,a3,2fc <memcmp+0x12>
  }
  return 0;
 310:	4501                	li	a0,0
 312:	a019                	j	318 <memcmp+0x2e>
      return *p1 - *p2;
 314:	40e7853b          	subw	a0,a5,a4
}
 318:	60a2                	ld	ra,8(sp)
 31a:	6402                	ld	s0,0(sp)
 31c:	0141                	addi	sp,sp,16
 31e:	8082                	ret
  return 0;
 320:	4501                	li	a0,0
 322:	bfdd                	j	318 <memcmp+0x2e>

0000000000000324 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 324:	1141                	addi	sp,sp,-16
 326:	e406                	sd	ra,8(sp)
 328:	e022                	sd	s0,0(sp)
 32a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 32c:	f63ff0ef          	jal	28e <memmove>
}
 330:	60a2                	ld	ra,8(sp)
 332:	6402                	ld	s0,0(sp)
 334:	0141                	addi	sp,sp,16
 336:	8082                	ret

0000000000000338 <sbrk>:

char *
sbrk(int n) {
 338:	1141                	addi	sp,sp,-16
 33a:	e406                	sd	ra,8(sp)
 33c:	e022                	sd	s0,0(sp)
 33e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 340:	4585                	li	a1,1
 342:	0b2000ef          	jal	3f4 <sys_sbrk>
}
 346:	60a2                	ld	ra,8(sp)
 348:	6402                	ld	s0,0(sp)
 34a:	0141                	addi	sp,sp,16
 34c:	8082                	ret

000000000000034e <sbrklazy>:

char *
sbrklazy(int n) {
 34e:	1141                	addi	sp,sp,-16
 350:	e406                	sd	ra,8(sp)
 352:	e022                	sd	s0,0(sp)
 354:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 356:	4589                	li	a1,2
 358:	09c000ef          	jal	3f4 <sys_sbrk>
}
 35c:	60a2                	ld	ra,8(sp)
 35e:	6402                	ld	s0,0(sp)
 360:	0141                	addi	sp,sp,16
 362:	8082                	ret

0000000000000364 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 364:	4885                	li	a7,1
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <exit>:
.global exit
exit:
 li a7, SYS_exit
 36c:	4889                	li	a7,2
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <wait>:
.global wait
wait:
 li a7, SYS_wait
 374:	488d                	li	a7,3
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 37c:	4891                	li	a7,4
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <read>:
.global read
read:
 li a7, SYS_read
 384:	4895                	li	a7,5
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <write>:
.global write
write:
 li a7, SYS_write
 38c:	48c1                	li	a7,16
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <close>:
.global close
close:
 li a7, SYS_close
 394:	48d5                	li	a7,21
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <kill>:
.global kill
kill:
 li a7, SYS_kill
 39c:	4899                	li	a7,6
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3a4:	489d                	li	a7,7
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <open>:
.global open
open:
 li a7, SYS_open
 3ac:	48bd                	li	a7,15
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3b4:	48c5                	li	a7,17
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3bc:	48c9                	li	a7,18
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3c4:	48a1                	li	a7,8
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <link>:
.global link
link:
 li a7, SYS_link
 3cc:	48cd                	li	a7,19
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3d4:	48d1                	li	a7,20
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3dc:	48a5                	li	a7,9
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3e4:	48a9                	li	a7,10
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3ec:	48ad                	li	a7,11
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3f4:	48b1                	li	a7,12
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <pause>:
.global pause
pause:
 li a7, SYS_pause
 3fc:	48b5                	li	a7,13
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 404:	48b9                	li	a7,14
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <memstat>:
.global memstat
memstat:
 li a7, SYS_memstat
 40c:	48d9                	li	a7,22
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <enable_bonus>:
.global enable_bonus
enable_bonus:
 li a7, SYS_enable_bonus
 414:	48dd                	li	a7,23
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 41c:	1101                	addi	sp,sp,-32
 41e:	ec06                	sd	ra,24(sp)
 420:	e822                	sd	s0,16(sp)
 422:	1000                	addi	s0,sp,32
 424:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 428:	4605                	li	a2,1
 42a:	fef40593          	addi	a1,s0,-17
 42e:	f5fff0ef          	jal	38c <write>
}
 432:	60e2                	ld	ra,24(sp)
 434:	6442                	ld	s0,16(sp)
 436:	6105                	addi	sp,sp,32
 438:	8082                	ret

000000000000043a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 43a:	715d                	addi	sp,sp,-80
 43c:	e486                	sd	ra,72(sp)
 43e:	e0a2                	sd	s0,64(sp)
 440:	f84a                	sd	s2,48(sp)
 442:	f44e                	sd	s3,40(sp)
 444:	0880                	addi	s0,sp,80
 446:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 448:	c6d1                	beqz	a3,4d4 <printint+0x9a>
 44a:	0805d563          	bgez	a1,4d4 <printint+0x9a>
    neg = 1;
    x = -xx;
 44e:	40b005b3          	neg	a1,a1
    neg = 1;
 452:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 454:	fb840993          	addi	s3,s0,-72
  neg = 0;
 458:	86ce                	mv	a3,s3
  i = 0;
 45a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 45c:	00000817          	auipc	a6,0x0
 460:	5dc80813          	addi	a6,a6,1500 # a38 <digits>
 464:	88ba                	mv	a7,a4
 466:	0017051b          	addiw	a0,a4,1
 46a:	872a                	mv	a4,a0
 46c:	02c5f7b3          	remu	a5,a1,a2
 470:	97c2                	add	a5,a5,a6
 472:	0007c783          	lbu	a5,0(a5)
 476:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 47a:	87ae                	mv	a5,a1
 47c:	02c5d5b3          	divu	a1,a1,a2
 480:	0685                	addi	a3,a3,1
 482:	fec7f1e3          	bgeu	a5,a2,464 <printint+0x2a>
  if(neg)
 486:	00030c63          	beqz	t1,49e <printint+0x64>
    buf[i++] = '-';
 48a:	fd050793          	addi	a5,a0,-48
 48e:	00878533          	add	a0,a5,s0
 492:	02d00793          	li	a5,45
 496:	fef50423          	sb	a5,-24(a0)
 49a:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 49e:	02e05563          	blez	a4,4c8 <printint+0x8e>
 4a2:	fc26                	sd	s1,56(sp)
 4a4:	377d                	addiw	a4,a4,-1
 4a6:	00e984b3          	add	s1,s3,a4
 4aa:	19fd                	addi	s3,s3,-1
 4ac:	99ba                	add	s3,s3,a4
 4ae:	1702                	slli	a4,a4,0x20
 4b0:	9301                	srli	a4,a4,0x20
 4b2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4b6:	0004c583          	lbu	a1,0(s1)
 4ba:	854a                	mv	a0,s2
 4bc:	f61ff0ef          	jal	41c <putc>
  while(--i >= 0)
 4c0:	14fd                	addi	s1,s1,-1
 4c2:	ff349ae3          	bne	s1,s3,4b6 <printint+0x7c>
 4c6:	74e2                	ld	s1,56(sp)
}
 4c8:	60a6                	ld	ra,72(sp)
 4ca:	6406                	ld	s0,64(sp)
 4cc:	7942                	ld	s2,48(sp)
 4ce:	79a2                	ld	s3,40(sp)
 4d0:	6161                	addi	sp,sp,80
 4d2:	8082                	ret
  neg = 0;
 4d4:	4301                	li	t1,0
 4d6:	bfbd                	j	454 <printint+0x1a>

00000000000004d8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d8:	711d                	addi	sp,sp,-96
 4da:	ec86                	sd	ra,88(sp)
 4dc:	e8a2                	sd	s0,80(sp)
 4de:	e4a6                	sd	s1,72(sp)
 4e0:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4e2:	0005c483          	lbu	s1,0(a1)
 4e6:	22048363          	beqz	s1,70c <vprintf+0x234>
 4ea:	e0ca                	sd	s2,64(sp)
 4ec:	fc4e                	sd	s3,56(sp)
 4ee:	f852                	sd	s4,48(sp)
 4f0:	f456                	sd	s5,40(sp)
 4f2:	f05a                	sd	s6,32(sp)
 4f4:	ec5e                	sd	s7,24(sp)
 4f6:	e862                	sd	s8,16(sp)
 4f8:	8b2a                	mv	s6,a0
 4fa:	8a2e                	mv	s4,a1
 4fc:	8bb2                	mv	s7,a2
  state = 0;
 4fe:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 500:	4901                	li	s2,0
 502:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 504:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 508:	06400c13          	li	s8,100
 50c:	a00d                	j	52e <vprintf+0x56>
        putc(fd, c0);
 50e:	85a6                	mv	a1,s1
 510:	855a                	mv	a0,s6
 512:	f0bff0ef          	jal	41c <putc>
 516:	a019                	j	51c <vprintf+0x44>
    } else if(state == '%'){
 518:	03598363          	beq	s3,s5,53e <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 51c:	0019079b          	addiw	a5,s2,1
 520:	893e                	mv	s2,a5
 522:	873e                	mv	a4,a5
 524:	97d2                	add	a5,a5,s4
 526:	0007c483          	lbu	s1,0(a5)
 52a:	1c048a63          	beqz	s1,6fe <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 52e:	0004879b          	sext.w	a5,s1
    if(state == 0){
 532:	fe0993e3          	bnez	s3,518 <vprintf+0x40>
      if(c0 == '%'){
 536:	fd579ce3          	bne	a5,s5,50e <vprintf+0x36>
        state = '%';
 53a:	89be                	mv	s3,a5
 53c:	b7c5                	j	51c <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 53e:	00ea06b3          	add	a3,s4,a4
 542:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 546:	1c060863          	beqz	a2,716 <vprintf+0x23e>
      if(c0 == 'd'){
 54a:	03878763          	beq	a5,s8,578 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 54e:	f9478693          	addi	a3,a5,-108
 552:	0016b693          	seqz	a3,a3
 556:	f9c60593          	addi	a1,a2,-100
 55a:	e99d                	bnez	a1,590 <vprintf+0xb8>
 55c:	ca95                	beqz	a3,590 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 55e:	008b8493          	addi	s1,s7,8
 562:	4685                	li	a3,1
 564:	4629                	li	a2,10
 566:	000bb583          	ld	a1,0(s7)
 56a:	855a                	mv	a0,s6
 56c:	ecfff0ef          	jal	43a <printint>
        i += 1;
 570:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 572:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 574:	4981                	li	s3,0
 576:	b75d                	j	51c <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 578:	008b8493          	addi	s1,s7,8
 57c:	4685                	li	a3,1
 57e:	4629                	li	a2,10
 580:	000ba583          	lw	a1,0(s7)
 584:	855a                	mv	a0,s6
 586:	eb5ff0ef          	jal	43a <printint>
 58a:	8ba6                	mv	s7,s1
      state = 0;
 58c:	4981                	li	s3,0
 58e:	b779                	j	51c <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 590:	9752                	add	a4,a4,s4
 592:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 596:	f9460713          	addi	a4,a2,-108
 59a:	00173713          	seqz	a4,a4
 59e:	8f75                	and	a4,a4,a3
 5a0:	f9c58513          	addi	a0,a1,-100
 5a4:	18051363          	bnez	a0,72a <vprintf+0x252>
 5a8:	18070163          	beqz	a4,72a <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ac:	008b8493          	addi	s1,s7,8
 5b0:	4685                	li	a3,1
 5b2:	4629                	li	a2,10
 5b4:	000bb583          	ld	a1,0(s7)
 5b8:	855a                	mv	a0,s6
 5ba:	e81ff0ef          	jal	43a <printint>
        i += 2;
 5be:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5c0:	8ba6                	mv	s7,s1
      state = 0;
 5c2:	4981                	li	s3,0
        i += 2;
 5c4:	bfa1                	j	51c <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5c6:	008b8493          	addi	s1,s7,8
 5ca:	4681                	li	a3,0
 5cc:	4629                	li	a2,10
 5ce:	000be583          	lwu	a1,0(s7)
 5d2:	855a                	mv	a0,s6
 5d4:	e67ff0ef          	jal	43a <printint>
 5d8:	8ba6                	mv	s7,s1
      state = 0;
 5da:	4981                	li	s3,0
 5dc:	b781                	j	51c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5de:	008b8493          	addi	s1,s7,8
 5e2:	4681                	li	a3,0
 5e4:	4629                	li	a2,10
 5e6:	000bb583          	ld	a1,0(s7)
 5ea:	855a                	mv	a0,s6
 5ec:	e4fff0ef          	jal	43a <printint>
        i += 1;
 5f0:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f2:	8ba6                	mv	s7,s1
      state = 0;
 5f4:	4981                	li	s3,0
 5f6:	b71d                	j	51c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f8:	008b8493          	addi	s1,s7,8
 5fc:	4681                	li	a3,0
 5fe:	4629                	li	a2,10
 600:	000bb583          	ld	a1,0(s7)
 604:	855a                	mv	a0,s6
 606:	e35ff0ef          	jal	43a <printint>
        i += 2;
 60a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 60c:	8ba6                	mv	s7,s1
      state = 0;
 60e:	4981                	li	s3,0
        i += 2;
 610:	b731                	j	51c <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 612:	008b8493          	addi	s1,s7,8
 616:	4681                	li	a3,0
 618:	4641                	li	a2,16
 61a:	000be583          	lwu	a1,0(s7)
 61e:	855a                	mv	a0,s6
 620:	e1bff0ef          	jal	43a <printint>
 624:	8ba6                	mv	s7,s1
      state = 0;
 626:	4981                	li	s3,0
 628:	bdd5                	j	51c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 62a:	008b8493          	addi	s1,s7,8
 62e:	4681                	li	a3,0
 630:	4641                	li	a2,16
 632:	000bb583          	ld	a1,0(s7)
 636:	855a                	mv	a0,s6
 638:	e03ff0ef          	jal	43a <printint>
        i += 1;
 63c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 63e:	8ba6                	mv	s7,s1
      state = 0;
 640:	4981                	li	s3,0
 642:	bde9                	j	51c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 644:	008b8493          	addi	s1,s7,8
 648:	4681                	li	a3,0
 64a:	4641                	li	a2,16
 64c:	000bb583          	ld	a1,0(s7)
 650:	855a                	mv	a0,s6
 652:	de9ff0ef          	jal	43a <printint>
        i += 2;
 656:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 658:	8ba6                	mv	s7,s1
      state = 0;
 65a:	4981                	li	s3,0
        i += 2;
 65c:	b5c1                	j	51c <vprintf+0x44>
 65e:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 660:	008b8793          	addi	a5,s7,8
 664:	8cbe                	mv	s9,a5
 666:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 66a:	03000593          	li	a1,48
 66e:	855a                	mv	a0,s6
 670:	dadff0ef          	jal	41c <putc>
  putc(fd, 'x');
 674:	07800593          	li	a1,120
 678:	855a                	mv	a0,s6
 67a:	da3ff0ef          	jal	41c <putc>
 67e:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 680:	00000b97          	auipc	s7,0x0
 684:	3b8b8b93          	addi	s7,s7,952 # a38 <digits>
 688:	03c9d793          	srli	a5,s3,0x3c
 68c:	97de                	add	a5,a5,s7
 68e:	0007c583          	lbu	a1,0(a5)
 692:	855a                	mv	a0,s6
 694:	d89ff0ef          	jal	41c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 698:	0992                	slli	s3,s3,0x4
 69a:	34fd                	addiw	s1,s1,-1
 69c:	f4f5                	bnez	s1,688 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 69e:	8be6                	mv	s7,s9
      state = 0;
 6a0:	4981                	li	s3,0
 6a2:	6ca2                	ld	s9,8(sp)
 6a4:	bda5                	j	51c <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 6a6:	008b8493          	addi	s1,s7,8
 6aa:	000bc583          	lbu	a1,0(s7)
 6ae:	855a                	mv	a0,s6
 6b0:	d6dff0ef          	jal	41c <putc>
 6b4:	8ba6                	mv	s7,s1
      state = 0;
 6b6:	4981                	li	s3,0
 6b8:	b595                	j	51c <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6ba:	008b8993          	addi	s3,s7,8
 6be:	000bb483          	ld	s1,0(s7)
 6c2:	cc91                	beqz	s1,6de <vprintf+0x206>
        for(; *s; s++)
 6c4:	0004c583          	lbu	a1,0(s1)
 6c8:	c985                	beqz	a1,6f8 <vprintf+0x220>
          putc(fd, *s);
 6ca:	855a                	mv	a0,s6
 6cc:	d51ff0ef          	jal	41c <putc>
        for(; *s; s++)
 6d0:	0485                	addi	s1,s1,1
 6d2:	0004c583          	lbu	a1,0(s1)
 6d6:	f9f5                	bnez	a1,6ca <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 6d8:	8bce                	mv	s7,s3
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	b581                	j	51c <vprintf+0x44>
          s = "(null)";
 6de:	00000497          	auipc	s1,0x0
 6e2:	35248493          	addi	s1,s1,850 # a30 <malloc+0x1b6>
        for(; *s; s++)
 6e6:	02800593          	li	a1,40
 6ea:	b7c5                	j	6ca <vprintf+0x1f2>
        putc(fd, '%');
 6ec:	85be                	mv	a1,a5
 6ee:	855a                	mv	a0,s6
 6f0:	d2dff0ef          	jal	41c <putc>
      state = 0;
 6f4:	4981                	li	s3,0
 6f6:	b51d                	j	51c <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6f8:	8bce                	mv	s7,s3
      state = 0;
 6fa:	4981                	li	s3,0
 6fc:	b505                	j	51c <vprintf+0x44>
 6fe:	6906                	ld	s2,64(sp)
 700:	79e2                	ld	s3,56(sp)
 702:	7a42                	ld	s4,48(sp)
 704:	7aa2                	ld	s5,40(sp)
 706:	7b02                	ld	s6,32(sp)
 708:	6be2                	ld	s7,24(sp)
 70a:	6c42                	ld	s8,16(sp)
    }
  }
}
 70c:	60e6                	ld	ra,88(sp)
 70e:	6446                	ld	s0,80(sp)
 710:	64a6                	ld	s1,72(sp)
 712:	6125                	addi	sp,sp,96
 714:	8082                	ret
      if(c0 == 'd'){
 716:	06400713          	li	a4,100
 71a:	e4e78fe3          	beq	a5,a4,578 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 71e:	f9478693          	addi	a3,a5,-108
 722:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 726:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 728:	4701                	li	a4,0
      } else if(c0 == 'u'){
 72a:	07500513          	li	a0,117
 72e:	e8a78ce3          	beq	a5,a0,5c6 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 732:	f8b60513          	addi	a0,a2,-117
 736:	e119                	bnez	a0,73c <vprintf+0x264>
 738:	ea0693e3          	bnez	a3,5de <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 73c:	f8b58513          	addi	a0,a1,-117
 740:	e119                	bnez	a0,746 <vprintf+0x26e>
 742:	ea071be3          	bnez	a4,5f8 <vprintf+0x120>
      } else if(c0 == 'x'){
 746:	07800513          	li	a0,120
 74a:	eca784e3          	beq	a5,a0,612 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 74e:	f8860613          	addi	a2,a2,-120
 752:	e219                	bnez	a2,758 <vprintf+0x280>
 754:	ec069be3          	bnez	a3,62a <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 758:	f8858593          	addi	a1,a1,-120
 75c:	e199                	bnez	a1,762 <vprintf+0x28a>
 75e:	ee0713e3          	bnez	a4,644 <vprintf+0x16c>
      } else if(c0 == 'p'){
 762:	07000713          	li	a4,112
 766:	eee78ce3          	beq	a5,a4,65e <vprintf+0x186>
      } else if(c0 == 'c'){
 76a:	06300713          	li	a4,99
 76e:	f2e78ce3          	beq	a5,a4,6a6 <vprintf+0x1ce>
      } else if(c0 == 's'){
 772:	07300713          	li	a4,115
 776:	f4e782e3          	beq	a5,a4,6ba <vprintf+0x1e2>
      } else if(c0 == '%'){
 77a:	02500713          	li	a4,37
 77e:	f6e787e3          	beq	a5,a4,6ec <vprintf+0x214>
        putc(fd, '%');
 782:	02500593          	li	a1,37
 786:	855a                	mv	a0,s6
 788:	c95ff0ef          	jal	41c <putc>
        putc(fd, c0);
 78c:	85a6                	mv	a1,s1
 78e:	855a                	mv	a0,s6
 790:	c8dff0ef          	jal	41c <putc>
      state = 0;
 794:	4981                	li	s3,0
 796:	b359                	j	51c <vprintf+0x44>

0000000000000798 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 798:	715d                	addi	sp,sp,-80
 79a:	ec06                	sd	ra,24(sp)
 79c:	e822                	sd	s0,16(sp)
 79e:	1000                	addi	s0,sp,32
 7a0:	e010                	sd	a2,0(s0)
 7a2:	e414                	sd	a3,8(s0)
 7a4:	e818                	sd	a4,16(s0)
 7a6:	ec1c                	sd	a5,24(s0)
 7a8:	03043023          	sd	a6,32(s0)
 7ac:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7b0:	8622                	mv	a2,s0
 7b2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7b6:	d23ff0ef          	jal	4d8 <vprintf>
}
 7ba:	60e2                	ld	ra,24(sp)
 7bc:	6442                	ld	s0,16(sp)
 7be:	6161                	addi	sp,sp,80
 7c0:	8082                	ret

00000000000007c2 <printf>:

void
printf(const char *fmt, ...)
{
 7c2:	711d                	addi	sp,sp,-96
 7c4:	ec06                	sd	ra,24(sp)
 7c6:	e822                	sd	s0,16(sp)
 7c8:	1000                	addi	s0,sp,32
 7ca:	e40c                	sd	a1,8(s0)
 7cc:	e810                	sd	a2,16(s0)
 7ce:	ec14                	sd	a3,24(s0)
 7d0:	f018                	sd	a4,32(s0)
 7d2:	f41c                	sd	a5,40(s0)
 7d4:	03043823          	sd	a6,48(s0)
 7d8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7dc:	00840613          	addi	a2,s0,8
 7e0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7e4:	85aa                	mv	a1,a0
 7e6:	4505                	li	a0,1
 7e8:	cf1ff0ef          	jal	4d8 <vprintf>
}
 7ec:	60e2                	ld	ra,24(sp)
 7ee:	6442                	ld	s0,16(sp)
 7f0:	6125                	addi	sp,sp,96
 7f2:	8082                	ret

00000000000007f4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7f4:	1141                	addi	sp,sp,-16
 7f6:	e406                	sd	ra,8(sp)
 7f8:	e022                	sd	s0,0(sp)
 7fa:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7fc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 800:	00001797          	auipc	a5,0x1
 804:	8007b783          	ld	a5,-2048(a5) # 1000 <freep>
 808:	a039                	j	816 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 80a:	6398                	ld	a4,0(a5)
 80c:	00e7e463          	bltu	a5,a4,814 <free+0x20>
 810:	00e6ea63          	bltu	a3,a4,824 <free+0x30>
{
 814:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 816:	fed7fae3          	bgeu	a5,a3,80a <free+0x16>
 81a:	6398                	ld	a4,0(a5)
 81c:	00e6e463          	bltu	a3,a4,824 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 820:	fee7eae3          	bltu	a5,a4,814 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 824:	ff852583          	lw	a1,-8(a0)
 828:	6390                	ld	a2,0(a5)
 82a:	02059813          	slli	a6,a1,0x20
 82e:	01c85713          	srli	a4,a6,0x1c
 832:	9736                	add	a4,a4,a3
 834:	02e60563          	beq	a2,a4,85e <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 838:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 83c:	4790                	lw	a2,8(a5)
 83e:	02061593          	slli	a1,a2,0x20
 842:	01c5d713          	srli	a4,a1,0x1c
 846:	973e                	add	a4,a4,a5
 848:	02e68263          	beq	a3,a4,86c <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 84c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 84e:	00000717          	auipc	a4,0x0
 852:	7af73923          	sd	a5,1970(a4) # 1000 <freep>
}
 856:	60a2                	ld	ra,8(sp)
 858:	6402                	ld	s0,0(sp)
 85a:	0141                	addi	sp,sp,16
 85c:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 85e:	4618                	lw	a4,8(a2)
 860:	9f2d                	addw	a4,a4,a1
 862:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 866:	6398                	ld	a4,0(a5)
 868:	6310                	ld	a2,0(a4)
 86a:	b7f9                	j	838 <free+0x44>
    p->s.size += bp->s.size;
 86c:	ff852703          	lw	a4,-8(a0)
 870:	9f31                	addw	a4,a4,a2
 872:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 874:	ff053683          	ld	a3,-16(a0)
 878:	bfd1                	j	84c <free+0x58>

000000000000087a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 87a:	7139                	addi	sp,sp,-64
 87c:	fc06                	sd	ra,56(sp)
 87e:	f822                	sd	s0,48(sp)
 880:	f04a                	sd	s2,32(sp)
 882:	ec4e                	sd	s3,24(sp)
 884:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 886:	02051993          	slli	s3,a0,0x20
 88a:	0209d993          	srli	s3,s3,0x20
 88e:	09bd                	addi	s3,s3,15
 890:	0049d993          	srli	s3,s3,0x4
 894:	2985                	addiw	s3,s3,1
 896:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 898:	00000517          	auipc	a0,0x0
 89c:	76853503          	ld	a0,1896(a0) # 1000 <freep>
 8a0:	c905                	beqz	a0,8d0 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a4:	4798                	lw	a4,8(a5)
 8a6:	09377663          	bgeu	a4,s3,932 <malloc+0xb8>
 8aa:	f426                	sd	s1,40(sp)
 8ac:	e852                	sd	s4,16(sp)
 8ae:	e456                	sd	s5,8(sp)
 8b0:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8b2:	8a4e                	mv	s4,s3
 8b4:	6705                	lui	a4,0x1
 8b6:	00e9f363          	bgeu	s3,a4,8bc <malloc+0x42>
 8ba:	6a05                	lui	s4,0x1
 8bc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8c0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8c4:	00000497          	auipc	s1,0x0
 8c8:	73c48493          	addi	s1,s1,1852 # 1000 <freep>
  if(p == SBRK_ERROR)
 8cc:	5afd                	li	s5,-1
 8ce:	a83d                	j	90c <malloc+0x92>
 8d0:	f426                	sd	s1,40(sp)
 8d2:	e852                	sd	s4,16(sp)
 8d4:	e456                	sd	s5,8(sp)
 8d6:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8d8:	00000797          	auipc	a5,0x0
 8dc:	73878793          	addi	a5,a5,1848 # 1010 <base>
 8e0:	00000717          	auipc	a4,0x0
 8e4:	72f73023          	sd	a5,1824(a4) # 1000 <freep>
 8e8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ea:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8ee:	b7d1                	j	8b2 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8f0:	6398                	ld	a4,0(a5)
 8f2:	e118                	sd	a4,0(a0)
 8f4:	a899                	j	94a <malloc+0xd0>
  hp->s.size = nu;
 8f6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8fa:	0541                	addi	a0,a0,16
 8fc:	ef9ff0ef          	jal	7f4 <free>
  return freep;
 900:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 902:	c125                	beqz	a0,962 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 904:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 906:	4798                	lw	a4,8(a5)
 908:	03277163          	bgeu	a4,s2,92a <malloc+0xb0>
    if(p == freep)
 90c:	6098                	ld	a4,0(s1)
 90e:	853e                	mv	a0,a5
 910:	fef71ae3          	bne	a4,a5,904 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 914:	8552                	mv	a0,s4
 916:	a23ff0ef          	jal	338 <sbrk>
  if(p == SBRK_ERROR)
 91a:	fd551ee3          	bne	a0,s5,8f6 <malloc+0x7c>
        return 0;
 91e:	4501                	li	a0,0
 920:	74a2                	ld	s1,40(sp)
 922:	6a42                	ld	s4,16(sp)
 924:	6aa2                	ld	s5,8(sp)
 926:	6b02                	ld	s6,0(sp)
 928:	a03d                	j	956 <malloc+0xdc>
 92a:	74a2                	ld	s1,40(sp)
 92c:	6a42                	ld	s4,16(sp)
 92e:	6aa2                	ld	s5,8(sp)
 930:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 932:	fae90fe3          	beq	s2,a4,8f0 <malloc+0x76>
        p->s.size -= nunits;
 936:	4137073b          	subw	a4,a4,s3
 93a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 93c:	02071693          	slli	a3,a4,0x20
 940:	01c6d713          	srli	a4,a3,0x1c
 944:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 946:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 94a:	00000717          	auipc	a4,0x0
 94e:	6aa73b23          	sd	a0,1718(a4) # 1000 <freep>
      return (void*)(p + 1);
 952:	01078513          	addi	a0,a5,16
  }
}
 956:	70e2                	ld	ra,56(sp)
 958:	7442                	ld	s0,48(sp)
 95a:	7902                	ld	s2,32(sp)
 95c:	69e2                	ld	s3,24(sp)
 95e:	6121                	addi	sp,sp,64
 960:	8082                	ret
 962:	74a2                	ld	s1,40(sp)
 964:	6a42                	ld	s4,16(sp)
 966:	6aa2                	ld	s5,8(sp)
 968:	6b02                	ld	s6,0(sp)
 96a:	b7f5                	j	956 <malloc+0xdc>
