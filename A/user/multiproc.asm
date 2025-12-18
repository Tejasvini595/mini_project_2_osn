
user/_multiproc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

#define PAGES 70

int main() {
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  int pid = getpid();
  10:	3cc000ef          	jal	3dc <getpid>
  14:	89aa                	mv	s3,a0
  printf("Multi-process test starting (PID %d)\n", pid);
  16:	85aa                	mv	a1,a0
  18:	00001517          	auipc	a0,0x1
  1c:	94850513          	addi	a0,a0,-1720 # 960 <malloc+0xf6>
  20:	792000ef          	jal	7b2 <printf>
  
  int *a = (int*)sbrk(PAGES * 4096);
  24:	00046537          	lui	a0,0x46
  28:	300000ef          	jal	328 <sbrk>
  2c:	87aa                	mv	a5,a0
  for(int i = 0; i < PAGES; i++) {
  2e:	3e800713          	li	a4,1000
  32:	02e9873b          	mulw	a4,s3,a4
  36:	893a                	mv	s2,a4
  38:	84aa                	mv	s1,a0
  3a:	00046a37          	lui	s4,0x46
  3e:	9a2a                	add	s4,s4,a0
  40:	6685                	lui	a3,0x1
    a[i * 1024] = pid * 1000 + i;  // unique values per process (1024 ints per 4KB page)
  42:	c398                	sw	a4,0(a5)
  for(int i = 0; i < PAGES; i++) {
  44:	2705                	addiw	a4,a4,1
  46:	97b6                	add	a5,a5,a3
  48:	ff479de3          	bne	a5,s4,42 <main+0x42>
  }
  
  printf("PID %d allocated %d pages\n", pid, PAGES);
  4c:	04600613          	li	a2,70
  50:	85ce                	mv	a1,s3
  52:	00001517          	auipc	a0,0x1
  56:	93650513          	addi	a0,a0,-1738 # 988 <malloc+0x11e>
  5a:	758000ef          	jal	7b2 <printf>
  5e:	67e1                	lui	a5,0x18
  60:	6a078793          	addi	a5,a5,1696 # 186a0 <base+0x17690>
  
  // Do some work to let other processes run
  for(int j = 0; j < 100000; j++) {
  64:	37fd                	addiw	a5,a5,-1
  66:	fffd                	bnez	a5,64 <main+0x64>
    // busy wait
  }
  
  // Verify our data is still correct
  int errors = 0;
  68:	4601                	li	a2,0
  for(int i = 0; i < PAGES; i++) {
  6a:	6705                	lui	a4,0x1
  6c:	a029                	j	76 <main+0x76>
  6e:	94ba                	add	s1,s1,a4
  70:	2905                	addiw	s2,s2,1
  72:	01448763          	beq	s1,s4,80 <main+0x80>
    if(a[i * 1024] != pid * 1000 + i) {
  76:	409c                	lw	a5,0(s1)
  78:	ff278be3          	beq	a5,s2,6e <main+0x6e>
      errors++;
  7c:	2605                	addiw	a2,a2,1
  7e:	bfc5                	j	6e <main+0x6e>
    }
  }
  
  if(errors == 0) {
  80:	ea19                	bnez	a2,96 <main+0x96>
    printf("PID %d: All data correct after swap isolation test\n", pid);
  82:	85ce                	mv	a1,s3
  84:	00001517          	auipc	a0,0x1
  88:	92450513          	addi	a0,a0,-1756 # 9a8 <malloc+0x13e>
  8c:	726000ef          	jal	7b2 <printf>
  } else {
    printf("PID %d: ERROR - %d pages corrupted!\n", pid, errors);
  }
  
  exit(0);
  90:	4501                	li	a0,0
  92:	2ca000ef          	jal	35c <exit>
    printf("PID %d: ERROR - %d pages corrupted!\n", pid, errors);
  96:	85ce                	mv	a1,s3
  98:	00001517          	auipc	a0,0x1
  9c:	94850513          	addi	a0,a0,-1720 # 9e0 <malloc+0x176>
  a0:	712000ef          	jal	7b2 <printf>
  a4:	b7f5                	j	90 <main+0x90>

00000000000000a6 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  a6:	1141                	addi	sp,sp,-16
  a8:	e406                	sd	ra,8(sp)
  aa:	e022                	sd	s0,0(sp)
  ac:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  ae:	f53ff0ef          	jal	0 <main>
  exit(r);
  b2:	2aa000ef          	jal	35c <exit>

00000000000000b6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  b6:	1141                	addi	sp,sp,-16
  b8:	e406                	sd	ra,8(sp)
  ba:	e022                	sd	s0,0(sp)
  bc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  be:	87aa                	mv	a5,a0
  c0:	0585                	addi	a1,a1,1
  c2:	0785                	addi	a5,a5,1
  c4:	fff5c703          	lbu	a4,-1(a1)
  c8:	fee78fa3          	sb	a4,-1(a5)
  cc:	fb75                	bnez	a4,c0 <strcpy+0xa>
    ;
  return os;
}
  ce:	60a2                	ld	ra,8(sp)
  d0:	6402                	ld	s0,0(sp)
  d2:	0141                	addi	sp,sp,16
  d4:	8082                	ret

00000000000000d6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  d6:	1141                	addi	sp,sp,-16
  d8:	e406                	sd	ra,8(sp)
  da:	e022                	sd	s0,0(sp)
  dc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  de:	00054783          	lbu	a5,0(a0)
  e2:	cb91                	beqz	a5,f6 <strcmp+0x20>
  e4:	0005c703          	lbu	a4,0(a1)
  e8:	00f71763          	bne	a4,a5,f6 <strcmp+0x20>
    p++, q++;
  ec:	0505                	addi	a0,a0,1
  ee:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  f0:	00054783          	lbu	a5,0(a0)
  f4:	fbe5                	bnez	a5,e4 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  f6:	0005c503          	lbu	a0,0(a1)
}
  fa:	40a7853b          	subw	a0,a5,a0
  fe:	60a2                	ld	ra,8(sp)
 100:	6402                	ld	s0,0(sp)
 102:	0141                	addi	sp,sp,16
 104:	8082                	ret

0000000000000106 <strlen>:

uint
strlen(const char *s)
{
 106:	1141                	addi	sp,sp,-16
 108:	e406                	sd	ra,8(sp)
 10a:	e022                	sd	s0,0(sp)
 10c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 10e:	00054783          	lbu	a5,0(a0)
 112:	cf91                	beqz	a5,12e <strlen+0x28>
 114:	00150793          	addi	a5,a0,1
 118:	86be                	mv	a3,a5
 11a:	0785                	addi	a5,a5,1
 11c:	fff7c703          	lbu	a4,-1(a5)
 120:	ff65                	bnez	a4,118 <strlen+0x12>
 122:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 126:	60a2                	ld	ra,8(sp)
 128:	6402                	ld	s0,0(sp)
 12a:	0141                	addi	sp,sp,16
 12c:	8082                	ret
  for(n = 0; s[n]; n++)
 12e:	4501                	li	a0,0
 130:	bfdd                	j	126 <strlen+0x20>

0000000000000132 <memset>:

void*
memset(void *dst, int c, uint n)
{
 132:	1141                	addi	sp,sp,-16
 134:	e406                	sd	ra,8(sp)
 136:	e022                	sd	s0,0(sp)
 138:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 13a:	ca19                	beqz	a2,150 <memset+0x1e>
 13c:	87aa                	mv	a5,a0
 13e:	1602                	slli	a2,a2,0x20
 140:	9201                	srli	a2,a2,0x20
 142:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 146:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 14a:	0785                	addi	a5,a5,1
 14c:	fee79de3          	bne	a5,a4,146 <memset+0x14>
  }
  return dst;
}
 150:	60a2                	ld	ra,8(sp)
 152:	6402                	ld	s0,0(sp)
 154:	0141                	addi	sp,sp,16
 156:	8082                	ret

0000000000000158 <strchr>:

char*
strchr(const char *s, char c)
{
 158:	1141                	addi	sp,sp,-16
 15a:	e406                	sd	ra,8(sp)
 15c:	e022                	sd	s0,0(sp)
 15e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 160:	00054783          	lbu	a5,0(a0)
 164:	cf81                	beqz	a5,17c <strchr+0x24>
    if(*s == c)
 166:	00f58763          	beq	a1,a5,174 <strchr+0x1c>
  for(; *s; s++)
 16a:	0505                	addi	a0,a0,1
 16c:	00054783          	lbu	a5,0(a0)
 170:	fbfd                	bnez	a5,166 <strchr+0xe>
      return (char*)s;
  return 0;
 172:	4501                	li	a0,0
}
 174:	60a2                	ld	ra,8(sp)
 176:	6402                	ld	s0,0(sp)
 178:	0141                	addi	sp,sp,16
 17a:	8082                	ret
  return 0;
 17c:	4501                	li	a0,0
 17e:	bfdd                	j	174 <strchr+0x1c>

0000000000000180 <gets>:

char*
gets(char *buf, int max)
{
 180:	711d                	addi	sp,sp,-96
 182:	ec86                	sd	ra,88(sp)
 184:	e8a2                	sd	s0,80(sp)
 186:	e4a6                	sd	s1,72(sp)
 188:	e0ca                	sd	s2,64(sp)
 18a:	fc4e                	sd	s3,56(sp)
 18c:	f852                	sd	s4,48(sp)
 18e:	f456                	sd	s5,40(sp)
 190:	f05a                	sd	s6,32(sp)
 192:	ec5e                	sd	s7,24(sp)
 194:	e862                	sd	s8,16(sp)
 196:	1080                	addi	s0,sp,96
 198:	8baa                	mv	s7,a0
 19a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 19c:	892a                	mv	s2,a0
 19e:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1a0:	faf40b13          	addi	s6,s0,-81
 1a4:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 1a6:	8c26                	mv	s8,s1
 1a8:	0014899b          	addiw	s3,s1,1
 1ac:	84ce                	mv	s1,s3
 1ae:	0349d463          	bge	s3,s4,1d6 <gets+0x56>
    cc = read(0, &c, 1);
 1b2:	8656                	mv	a2,s5
 1b4:	85da                	mv	a1,s6
 1b6:	4501                	li	a0,0
 1b8:	1bc000ef          	jal	374 <read>
    if(cc < 1)
 1bc:	00a05d63          	blez	a0,1d6 <gets+0x56>
      break;
    buf[i++] = c;
 1c0:	faf44783          	lbu	a5,-81(s0)
 1c4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1c8:	0905                	addi	s2,s2,1
 1ca:	ff678713          	addi	a4,a5,-10
 1ce:	c319                	beqz	a4,1d4 <gets+0x54>
 1d0:	17cd                	addi	a5,a5,-13
 1d2:	fbf1                	bnez	a5,1a6 <gets+0x26>
    buf[i++] = c;
 1d4:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 1d6:	9c5e                	add	s8,s8,s7
 1d8:	000c0023          	sb	zero,0(s8)
  return buf;
}
 1dc:	855e                	mv	a0,s7
 1de:	60e6                	ld	ra,88(sp)
 1e0:	6446                	ld	s0,80(sp)
 1e2:	64a6                	ld	s1,72(sp)
 1e4:	6906                	ld	s2,64(sp)
 1e6:	79e2                	ld	s3,56(sp)
 1e8:	7a42                	ld	s4,48(sp)
 1ea:	7aa2                	ld	s5,40(sp)
 1ec:	7b02                	ld	s6,32(sp)
 1ee:	6be2                	ld	s7,24(sp)
 1f0:	6c42                	ld	s8,16(sp)
 1f2:	6125                	addi	sp,sp,96
 1f4:	8082                	ret

00000000000001f6 <stat>:

int
stat(const char *n, struct stat *st)
{
 1f6:	1101                	addi	sp,sp,-32
 1f8:	ec06                	sd	ra,24(sp)
 1fa:	e822                	sd	s0,16(sp)
 1fc:	e04a                	sd	s2,0(sp)
 1fe:	1000                	addi	s0,sp,32
 200:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 202:	4581                	li	a1,0
 204:	198000ef          	jal	39c <open>
  if(fd < 0)
 208:	02054263          	bltz	a0,22c <stat+0x36>
 20c:	e426                	sd	s1,8(sp)
 20e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 210:	85ca                	mv	a1,s2
 212:	1a2000ef          	jal	3b4 <fstat>
 216:	892a                	mv	s2,a0
  close(fd);
 218:	8526                	mv	a0,s1
 21a:	16a000ef          	jal	384 <close>
  return r;
 21e:	64a2                	ld	s1,8(sp)
}
 220:	854a                	mv	a0,s2
 222:	60e2                	ld	ra,24(sp)
 224:	6442                	ld	s0,16(sp)
 226:	6902                	ld	s2,0(sp)
 228:	6105                	addi	sp,sp,32
 22a:	8082                	ret
    return -1;
 22c:	57fd                	li	a5,-1
 22e:	893e                	mv	s2,a5
 230:	bfc5                	j	220 <stat+0x2a>

0000000000000232 <atoi>:

int
atoi(const char *s)
{
 232:	1141                	addi	sp,sp,-16
 234:	e406                	sd	ra,8(sp)
 236:	e022                	sd	s0,0(sp)
 238:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 23a:	00054683          	lbu	a3,0(a0)
 23e:	fd06879b          	addiw	a5,a3,-48 # fd0 <digits+0x5c0>
 242:	0ff7f793          	zext.b	a5,a5
 246:	4625                	li	a2,9
 248:	02f66963          	bltu	a2,a5,27a <atoi+0x48>
 24c:	872a                	mv	a4,a0
  n = 0;
 24e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 250:	0705                	addi	a4,a4,1 # 1001 <freep+0x1>
 252:	0025179b          	slliw	a5,a0,0x2
 256:	9fa9                	addw	a5,a5,a0
 258:	0017979b          	slliw	a5,a5,0x1
 25c:	9fb5                	addw	a5,a5,a3
 25e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 262:	00074683          	lbu	a3,0(a4)
 266:	fd06879b          	addiw	a5,a3,-48
 26a:	0ff7f793          	zext.b	a5,a5
 26e:	fef671e3          	bgeu	a2,a5,250 <atoi+0x1e>
  return n;
}
 272:	60a2                	ld	ra,8(sp)
 274:	6402                	ld	s0,0(sp)
 276:	0141                	addi	sp,sp,16
 278:	8082                	ret
  n = 0;
 27a:	4501                	li	a0,0
 27c:	bfdd                	j	272 <atoi+0x40>

000000000000027e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 27e:	1141                	addi	sp,sp,-16
 280:	e406                	sd	ra,8(sp)
 282:	e022                	sd	s0,0(sp)
 284:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 286:	02b57563          	bgeu	a0,a1,2b0 <memmove+0x32>
    while(n-- > 0)
 28a:	00c05f63          	blez	a2,2a8 <memmove+0x2a>
 28e:	1602                	slli	a2,a2,0x20
 290:	9201                	srli	a2,a2,0x20
 292:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 296:	872a                	mv	a4,a0
      *dst++ = *src++;
 298:	0585                	addi	a1,a1,1
 29a:	0705                	addi	a4,a4,1
 29c:	fff5c683          	lbu	a3,-1(a1)
 2a0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2a4:	fee79ae3          	bne	a5,a4,298 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2a8:	60a2                	ld	ra,8(sp)
 2aa:	6402                	ld	s0,0(sp)
 2ac:	0141                	addi	sp,sp,16
 2ae:	8082                	ret
    while(n-- > 0)
 2b0:	fec05ce3          	blez	a2,2a8 <memmove+0x2a>
    dst += n;
 2b4:	00c50733          	add	a4,a0,a2
    src += n;
 2b8:	95b2                	add	a1,a1,a2
 2ba:	fff6079b          	addiw	a5,a2,-1
 2be:	1782                	slli	a5,a5,0x20
 2c0:	9381                	srli	a5,a5,0x20
 2c2:	fff7c793          	not	a5,a5
 2c6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2c8:	15fd                	addi	a1,a1,-1
 2ca:	177d                	addi	a4,a4,-1
 2cc:	0005c683          	lbu	a3,0(a1)
 2d0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2d4:	fef71ae3          	bne	a4,a5,2c8 <memmove+0x4a>
 2d8:	bfc1                	j	2a8 <memmove+0x2a>

00000000000002da <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2da:	1141                	addi	sp,sp,-16
 2dc:	e406                	sd	ra,8(sp)
 2de:	e022                	sd	s0,0(sp)
 2e0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2e2:	c61d                	beqz	a2,310 <memcmp+0x36>
 2e4:	1602                	slli	a2,a2,0x20
 2e6:	9201                	srli	a2,a2,0x20
 2e8:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 2ec:	00054783          	lbu	a5,0(a0)
 2f0:	0005c703          	lbu	a4,0(a1)
 2f4:	00e79863          	bne	a5,a4,304 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 2f8:	0505                	addi	a0,a0,1
    p2++;
 2fa:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2fc:	fed518e3          	bne	a0,a3,2ec <memcmp+0x12>
  }
  return 0;
 300:	4501                	li	a0,0
 302:	a019                	j	308 <memcmp+0x2e>
      return *p1 - *p2;
 304:	40e7853b          	subw	a0,a5,a4
}
 308:	60a2                	ld	ra,8(sp)
 30a:	6402                	ld	s0,0(sp)
 30c:	0141                	addi	sp,sp,16
 30e:	8082                	ret
  return 0;
 310:	4501                	li	a0,0
 312:	bfdd                	j	308 <memcmp+0x2e>

0000000000000314 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 314:	1141                	addi	sp,sp,-16
 316:	e406                	sd	ra,8(sp)
 318:	e022                	sd	s0,0(sp)
 31a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 31c:	f63ff0ef          	jal	27e <memmove>
}
 320:	60a2                	ld	ra,8(sp)
 322:	6402                	ld	s0,0(sp)
 324:	0141                	addi	sp,sp,16
 326:	8082                	ret

0000000000000328 <sbrk>:

char *
sbrk(int n) {
 328:	1141                	addi	sp,sp,-16
 32a:	e406                	sd	ra,8(sp)
 32c:	e022                	sd	s0,0(sp)
 32e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 330:	4585                	li	a1,1
 332:	0b2000ef          	jal	3e4 <sys_sbrk>
}
 336:	60a2                	ld	ra,8(sp)
 338:	6402                	ld	s0,0(sp)
 33a:	0141                	addi	sp,sp,16
 33c:	8082                	ret

000000000000033e <sbrklazy>:

char *
sbrklazy(int n) {
 33e:	1141                	addi	sp,sp,-16
 340:	e406                	sd	ra,8(sp)
 342:	e022                	sd	s0,0(sp)
 344:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 346:	4589                	li	a1,2
 348:	09c000ef          	jal	3e4 <sys_sbrk>
}
 34c:	60a2                	ld	ra,8(sp)
 34e:	6402                	ld	s0,0(sp)
 350:	0141                	addi	sp,sp,16
 352:	8082                	ret

0000000000000354 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 354:	4885                	li	a7,1
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <exit>:
.global exit
exit:
 li a7, SYS_exit
 35c:	4889                	li	a7,2
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <wait>:
.global wait
wait:
 li a7, SYS_wait
 364:	488d                	li	a7,3
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 36c:	4891                	li	a7,4
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <read>:
.global read
read:
 li a7, SYS_read
 374:	4895                	li	a7,5
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <write>:
.global write
write:
 li a7, SYS_write
 37c:	48c1                	li	a7,16
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <close>:
.global close
close:
 li a7, SYS_close
 384:	48d5                	li	a7,21
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <kill>:
.global kill
kill:
 li a7, SYS_kill
 38c:	4899                	li	a7,6
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <exec>:
.global exec
exec:
 li a7, SYS_exec
 394:	489d                	li	a7,7
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <open>:
.global open
open:
 li a7, SYS_open
 39c:	48bd                	li	a7,15
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3a4:	48c5                	li	a7,17
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ac:	48c9                	li	a7,18
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3b4:	48a1                	li	a7,8
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <link>:
.global link
link:
 li a7, SYS_link
 3bc:	48cd                	li	a7,19
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3c4:	48d1                	li	a7,20
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3cc:	48a5                	li	a7,9
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3d4:	48a9                	li	a7,10
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3dc:	48ad                	li	a7,11
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3e4:	48b1                	li	a7,12
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <pause>:
.global pause
pause:
 li a7, SYS_pause
 3ec:	48b5                	li	a7,13
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3f4:	48b9                	li	a7,14
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <memstat>:
.global memstat
memstat:
 li a7, SYS_memstat
 3fc:	48d9                	li	a7,22
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <enable_bonus>:
.global enable_bonus
enable_bonus:
 li a7, SYS_enable_bonus
 404:	48dd                	li	a7,23
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 40c:	1101                	addi	sp,sp,-32
 40e:	ec06                	sd	ra,24(sp)
 410:	e822                	sd	s0,16(sp)
 412:	1000                	addi	s0,sp,32
 414:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 418:	4605                	li	a2,1
 41a:	fef40593          	addi	a1,s0,-17
 41e:	f5fff0ef          	jal	37c <write>
}
 422:	60e2                	ld	ra,24(sp)
 424:	6442                	ld	s0,16(sp)
 426:	6105                	addi	sp,sp,32
 428:	8082                	ret

000000000000042a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 42a:	715d                	addi	sp,sp,-80
 42c:	e486                	sd	ra,72(sp)
 42e:	e0a2                	sd	s0,64(sp)
 430:	f84a                	sd	s2,48(sp)
 432:	f44e                	sd	s3,40(sp)
 434:	0880                	addi	s0,sp,80
 436:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 438:	c6d1                	beqz	a3,4c4 <printint+0x9a>
 43a:	0805d563          	bgez	a1,4c4 <printint+0x9a>
    neg = 1;
    x = -xx;
 43e:	40b005b3          	neg	a1,a1
    neg = 1;
 442:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 444:	fb840993          	addi	s3,s0,-72
  neg = 0;
 448:	86ce                	mv	a3,s3
  i = 0;
 44a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 44c:	00000817          	auipc	a6,0x0
 450:	5c480813          	addi	a6,a6,1476 # a10 <digits>
 454:	88ba                	mv	a7,a4
 456:	0017051b          	addiw	a0,a4,1
 45a:	872a                	mv	a4,a0
 45c:	02c5f7b3          	remu	a5,a1,a2
 460:	97c2                	add	a5,a5,a6
 462:	0007c783          	lbu	a5,0(a5)
 466:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 46a:	87ae                	mv	a5,a1
 46c:	02c5d5b3          	divu	a1,a1,a2
 470:	0685                	addi	a3,a3,1
 472:	fec7f1e3          	bgeu	a5,a2,454 <printint+0x2a>
  if(neg)
 476:	00030c63          	beqz	t1,48e <printint+0x64>
    buf[i++] = '-';
 47a:	fd050793          	addi	a5,a0,-48
 47e:	00878533          	add	a0,a5,s0
 482:	02d00793          	li	a5,45
 486:	fef50423          	sb	a5,-24(a0)
 48a:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 48e:	02e05563          	blez	a4,4b8 <printint+0x8e>
 492:	fc26                	sd	s1,56(sp)
 494:	377d                	addiw	a4,a4,-1
 496:	00e984b3          	add	s1,s3,a4
 49a:	19fd                	addi	s3,s3,-1
 49c:	99ba                	add	s3,s3,a4
 49e:	1702                	slli	a4,a4,0x20
 4a0:	9301                	srli	a4,a4,0x20
 4a2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4a6:	0004c583          	lbu	a1,0(s1)
 4aa:	854a                	mv	a0,s2
 4ac:	f61ff0ef          	jal	40c <putc>
  while(--i >= 0)
 4b0:	14fd                	addi	s1,s1,-1
 4b2:	ff349ae3          	bne	s1,s3,4a6 <printint+0x7c>
 4b6:	74e2                	ld	s1,56(sp)
}
 4b8:	60a6                	ld	ra,72(sp)
 4ba:	6406                	ld	s0,64(sp)
 4bc:	7942                	ld	s2,48(sp)
 4be:	79a2                	ld	s3,40(sp)
 4c0:	6161                	addi	sp,sp,80
 4c2:	8082                	ret
  neg = 0;
 4c4:	4301                	li	t1,0
 4c6:	bfbd                	j	444 <printint+0x1a>

00000000000004c8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4c8:	711d                	addi	sp,sp,-96
 4ca:	ec86                	sd	ra,88(sp)
 4cc:	e8a2                	sd	s0,80(sp)
 4ce:	e4a6                	sd	s1,72(sp)
 4d0:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4d2:	0005c483          	lbu	s1,0(a1)
 4d6:	22048363          	beqz	s1,6fc <vprintf+0x234>
 4da:	e0ca                	sd	s2,64(sp)
 4dc:	fc4e                	sd	s3,56(sp)
 4de:	f852                	sd	s4,48(sp)
 4e0:	f456                	sd	s5,40(sp)
 4e2:	f05a                	sd	s6,32(sp)
 4e4:	ec5e                	sd	s7,24(sp)
 4e6:	e862                	sd	s8,16(sp)
 4e8:	8b2a                	mv	s6,a0
 4ea:	8a2e                	mv	s4,a1
 4ec:	8bb2                	mv	s7,a2
  state = 0;
 4ee:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4f0:	4901                	li	s2,0
 4f2:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4f4:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4f8:	06400c13          	li	s8,100
 4fc:	a00d                	j	51e <vprintf+0x56>
        putc(fd, c0);
 4fe:	85a6                	mv	a1,s1
 500:	855a                	mv	a0,s6
 502:	f0bff0ef          	jal	40c <putc>
 506:	a019                	j	50c <vprintf+0x44>
    } else if(state == '%'){
 508:	03598363          	beq	s3,s5,52e <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 50c:	0019079b          	addiw	a5,s2,1
 510:	893e                	mv	s2,a5
 512:	873e                	mv	a4,a5
 514:	97d2                	add	a5,a5,s4
 516:	0007c483          	lbu	s1,0(a5)
 51a:	1c048a63          	beqz	s1,6ee <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 51e:	0004879b          	sext.w	a5,s1
    if(state == 0){
 522:	fe0993e3          	bnez	s3,508 <vprintf+0x40>
      if(c0 == '%'){
 526:	fd579ce3          	bne	a5,s5,4fe <vprintf+0x36>
        state = '%';
 52a:	89be                	mv	s3,a5
 52c:	b7c5                	j	50c <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 52e:	00ea06b3          	add	a3,s4,a4
 532:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 536:	1c060863          	beqz	a2,706 <vprintf+0x23e>
      if(c0 == 'd'){
 53a:	03878763          	beq	a5,s8,568 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 53e:	f9478693          	addi	a3,a5,-108
 542:	0016b693          	seqz	a3,a3
 546:	f9c60593          	addi	a1,a2,-100
 54a:	e99d                	bnez	a1,580 <vprintf+0xb8>
 54c:	ca95                	beqz	a3,580 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 54e:	008b8493          	addi	s1,s7,8
 552:	4685                	li	a3,1
 554:	4629                	li	a2,10
 556:	000bb583          	ld	a1,0(s7)
 55a:	855a                	mv	a0,s6
 55c:	ecfff0ef          	jal	42a <printint>
        i += 1;
 560:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 562:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 564:	4981                	li	s3,0
 566:	b75d                	j	50c <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 568:	008b8493          	addi	s1,s7,8
 56c:	4685                	li	a3,1
 56e:	4629                	li	a2,10
 570:	000ba583          	lw	a1,0(s7)
 574:	855a                	mv	a0,s6
 576:	eb5ff0ef          	jal	42a <printint>
 57a:	8ba6                	mv	s7,s1
      state = 0;
 57c:	4981                	li	s3,0
 57e:	b779                	j	50c <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 580:	9752                	add	a4,a4,s4
 582:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 586:	f9460713          	addi	a4,a2,-108
 58a:	00173713          	seqz	a4,a4
 58e:	8f75                	and	a4,a4,a3
 590:	f9c58513          	addi	a0,a1,-100
 594:	18051363          	bnez	a0,71a <vprintf+0x252>
 598:	18070163          	beqz	a4,71a <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 59c:	008b8493          	addi	s1,s7,8
 5a0:	4685                	li	a3,1
 5a2:	4629                	li	a2,10
 5a4:	000bb583          	ld	a1,0(s7)
 5a8:	855a                	mv	a0,s6
 5aa:	e81ff0ef          	jal	42a <printint>
        i += 2;
 5ae:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5b0:	8ba6                	mv	s7,s1
      state = 0;
 5b2:	4981                	li	s3,0
        i += 2;
 5b4:	bfa1                	j	50c <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5b6:	008b8493          	addi	s1,s7,8
 5ba:	4681                	li	a3,0
 5bc:	4629                	li	a2,10
 5be:	000be583          	lwu	a1,0(s7)
 5c2:	855a                	mv	a0,s6
 5c4:	e67ff0ef          	jal	42a <printint>
 5c8:	8ba6                	mv	s7,s1
      state = 0;
 5ca:	4981                	li	s3,0
 5cc:	b781                	j	50c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ce:	008b8493          	addi	s1,s7,8
 5d2:	4681                	li	a3,0
 5d4:	4629                	li	a2,10
 5d6:	000bb583          	ld	a1,0(s7)
 5da:	855a                	mv	a0,s6
 5dc:	e4fff0ef          	jal	42a <printint>
        i += 1;
 5e0:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5e2:	8ba6                	mv	s7,s1
      state = 0;
 5e4:	4981                	li	s3,0
 5e6:	b71d                	j	50c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5e8:	008b8493          	addi	s1,s7,8
 5ec:	4681                	li	a3,0
 5ee:	4629                	li	a2,10
 5f0:	000bb583          	ld	a1,0(s7)
 5f4:	855a                	mv	a0,s6
 5f6:	e35ff0ef          	jal	42a <printint>
        i += 2;
 5fa:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5fc:	8ba6                	mv	s7,s1
      state = 0;
 5fe:	4981                	li	s3,0
        i += 2;
 600:	b731                	j	50c <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 602:	008b8493          	addi	s1,s7,8
 606:	4681                	li	a3,0
 608:	4641                	li	a2,16
 60a:	000be583          	lwu	a1,0(s7)
 60e:	855a                	mv	a0,s6
 610:	e1bff0ef          	jal	42a <printint>
 614:	8ba6                	mv	s7,s1
      state = 0;
 616:	4981                	li	s3,0
 618:	bdd5                	j	50c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 61a:	008b8493          	addi	s1,s7,8
 61e:	4681                	li	a3,0
 620:	4641                	li	a2,16
 622:	000bb583          	ld	a1,0(s7)
 626:	855a                	mv	a0,s6
 628:	e03ff0ef          	jal	42a <printint>
        i += 1;
 62c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 62e:	8ba6                	mv	s7,s1
      state = 0;
 630:	4981                	li	s3,0
 632:	bde9                	j	50c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 634:	008b8493          	addi	s1,s7,8
 638:	4681                	li	a3,0
 63a:	4641                	li	a2,16
 63c:	000bb583          	ld	a1,0(s7)
 640:	855a                	mv	a0,s6
 642:	de9ff0ef          	jal	42a <printint>
        i += 2;
 646:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 648:	8ba6                	mv	s7,s1
      state = 0;
 64a:	4981                	li	s3,0
        i += 2;
 64c:	b5c1                	j	50c <vprintf+0x44>
 64e:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 650:	008b8793          	addi	a5,s7,8
 654:	8cbe                	mv	s9,a5
 656:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 65a:	03000593          	li	a1,48
 65e:	855a                	mv	a0,s6
 660:	dadff0ef          	jal	40c <putc>
  putc(fd, 'x');
 664:	07800593          	li	a1,120
 668:	855a                	mv	a0,s6
 66a:	da3ff0ef          	jal	40c <putc>
 66e:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 670:	00000b97          	auipc	s7,0x0
 674:	3a0b8b93          	addi	s7,s7,928 # a10 <digits>
 678:	03c9d793          	srli	a5,s3,0x3c
 67c:	97de                	add	a5,a5,s7
 67e:	0007c583          	lbu	a1,0(a5)
 682:	855a                	mv	a0,s6
 684:	d89ff0ef          	jal	40c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 688:	0992                	slli	s3,s3,0x4
 68a:	34fd                	addiw	s1,s1,-1
 68c:	f4f5                	bnez	s1,678 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 68e:	8be6                	mv	s7,s9
      state = 0;
 690:	4981                	li	s3,0
 692:	6ca2                	ld	s9,8(sp)
 694:	bda5                	j	50c <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 696:	008b8493          	addi	s1,s7,8
 69a:	000bc583          	lbu	a1,0(s7)
 69e:	855a                	mv	a0,s6
 6a0:	d6dff0ef          	jal	40c <putc>
 6a4:	8ba6                	mv	s7,s1
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	b595                	j	50c <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6aa:	008b8993          	addi	s3,s7,8
 6ae:	000bb483          	ld	s1,0(s7)
 6b2:	cc91                	beqz	s1,6ce <vprintf+0x206>
        for(; *s; s++)
 6b4:	0004c583          	lbu	a1,0(s1)
 6b8:	c985                	beqz	a1,6e8 <vprintf+0x220>
          putc(fd, *s);
 6ba:	855a                	mv	a0,s6
 6bc:	d51ff0ef          	jal	40c <putc>
        for(; *s; s++)
 6c0:	0485                	addi	s1,s1,1
 6c2:	0004c583          	lbu	a1,0(s1)
 6c6:	f9f5                	bnez	a1,6ba <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 6c8:	8bce                	mv	s7,s3
      state = 0;
 6ca:	4981                	li	s3,0
 6cc:	b581                	j	50c <vprintf+0x44>
          s = "(null)";
 6ce:	00000497          	auipc	s1,0x0
 6d2:	33a48493          	addi	s1,s1,826 # a08 <malloc+0x19e>
        for(; *s; s++)
 6d6:	02800593          	li	a1,40
 6da:	b7c5                	j	6ba <vprintf+0x1f2>
        putc(fd, '%');
 6dc:	85be                	mv	a1,a5
 6de:	855a                	mv	a0,s6
 6e0:	d2dff0ef          	jal	40c <putc>
      state = 0;
 6e4:	4981                	li	s3,0
 6e6:	b51d                	j	50c <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6e8:	8bce                	mv	s7,s3
      state = 0;
 6ea:	4981                	li	s3,0
 6ec:	b505                	j	50c <vprintf+0x44>
 6ee:	6906                	ld	s2,64(sp)
 6f0:	79e2                	ld	s3,56(sp)
 6f2:	7a42                	ld	s4,48(sp)
 6f4:	7aa2                	ld	s5,40(sp)
 6f6:	7b02                	ld	s6,32(sp)
 6f8:	6be2                	ld	s7,24(sp)
 6fa:	6c42                	ld	s8,16(sp)
    }
  }
}
 6fc:	60e6                	ld	ra,88(sp)
 6fe:	6446                	ld	s0,80(sp)
 700:	64a6                	ld	s1,72(sp)
 702:	6125                	addi	sp,sp,96
 704:	8082                	ret
      if(c0 == 'd'){
 706:	06400713          	li	a4,100
 70a:	e4e78fe3          	beq	a5,a4,568 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 70e:	f9478693          	addi	a3,a5,-108
 712:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 716:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 718:	4701                	li	a4,0
      } else if(c0 == 'u'){
 71a:	07500513          	li	a0,117
 71e:	e8a78ce3          	beq	a5,a0,5b6 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 722:	f8b60513          	addi	a0,a2,-117
 726:	e119                	bnez	a0,72c <vprintf+0x264>
 728:	ea0693e3          	bnez	a3,5ce <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 72c:	f8b58513          	addi	a0,a1,-117
 730:	e119                	bnez	a0,736 <vprintf+0x26e>
 732:	ea071be3          	bnez	a4,5e8 <vprintf+0x120>
      } else if(c0 == 'x'){
 736:	07800513          	li	a0,120
 73a:	eca784e3          	beq	a5,a0,602 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 73e:	f8860613          	addi	a2,a2,-120
 742:	e219                	bnez	a2,748 <vprintf+0x280>
 744:	ec069be3          	bnez	a3,61a <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 748:	f8858593          	addi	a1,a1,-120
 74c:	e199                	bnez	a1,752 <vprintf+0x28a>
 74e:	ee0713e3          	bnez	a4,634 <vprintf+0x16c>
      } else if(c0 == 'p'){
 752:	07000713          	li	a4,112
 756:	eee78ce3          	beq	a5,a4,64e <vprintf+0x186>
      } else if(c0 == 'c'){
 75a:	06300713          	li	a4,99
 75e:	f2e78ce3          	beq	a5,a4,696 <vprintf+0x1ce>
      } else if(c0 == 's'){
 762:	07300713          	li	a4,115
 766:	f4e782e3          	beq	a5,a4,6aa <vprintf+0x1e2>
      } else if(c0 == '%'){
 76a:	02500713          	li	a4,37
 76e:	f6e787e3          	beq	a5,a4,6dc <vprintf+0x214>
        putc(fd, '%');
 772:	02500593          	li	a1,37
 776:	855a                	mv	a0,s6
 778:	c95ff0ef          	jal	40c <putc>
        putc(fd, c0);
 77c:	85a6                	mv	a1,s1
 77e:	855a                	mv	a0,s6
 780:	c8dff0ef          	jal	40c <putc>
      state = 0;
 784:	4981                	li	s3,0
 786:	b359                	j	50c <vprintf+0x44>

0000000000000788 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 788:	715d                	addi	sp,sp,-80
 78a:	ec06                	sd	ra,24(sp)
 78c:	e822                	sd	s0,16(sp)
 78e:	1000                	addi	s0,sp,32
 790:	e010                	sd	a2,0(s0)
 792:	e414                	sd	a3,8(s0)
 794:	e818                	sd	a4,16(s0)
 796:	ec1c                	sd	a5,24(s0)
 798:	03043023          	sd	a6,32(s0)
 79c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7a0:	8622                	mv	a2,s0
 7a2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7a6:	d23ff0ef          	jal	4c8 <vprintf>
}
 7aa:	60e2                	ld	ra,24(sp)
 7ac:	6442                	ld	s0,16(sp)
 7ae:	6161                	addi	sp,sp,80
 7b0:	8082                	ret

00000000000007b2 <printf>:

void
printf(const char *fmt, ...)
{
 7b2:	711d                	addi	sp,sp,-96
 7b4:	ec06                	sd	ra,24(sp)
 7b6:	e822                	sd	s0,16(sp)
 7b8:	1000                	addi	s0,sp,32
 7ba:	e40c                	sd	a1,8(s0)
 7bc:	e810                	sd	a2,16(s0)
 7be:	ec14                	sd	a3,24(s0)
 7c0:	f018                	sd	a4,32(s0)
 7c2:	f41c                	sd	a5,40(s0)
 7c4:	03043823          	sd	a6,48(s0)
 7c8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7cc:	00840613          	addi	a2,s0,8
 7d0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7d4:	85aa                	mv	a1,a0
 7d6:	4505                	li	a0,1
 7d8:	cf1ff0ef          	jal	4c8 <vprintf>
}
 7dc:	60e2                	ld	ra,24(sp)
 7de:	6442                	ld	s0,16(sp)
 7e0:	6125                	addi	sp,sp,96
 7e2:	8082                	ret

00000000000007e4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7e4:	1141                	addi	sp,sp,-16
 7e6:	e406                	sd	ra,8(sp)
 7e8:	e022                	sd	s0,0(sp)
 7ea:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7ec:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f0:	00001797          	auipc	a5,0x1
 7f4:	8107b783          	ld	a5,-2032(a5) # 1000 <freep>
 7f8:	a039                	j	806 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7fa:	6398                	ld	a4,0(a5)
 7fc:	00e7e463          	bltu	a5,a4,804 <free+0x20>
 800:	00e6ea63          	bltu	a3,a4,814 <free+0x30>
{
 804:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 806:	fed7fae3          	bgeu	a5,a3,7fa <free+0x16>
 80a:	6398                	ld	a4,0(a5)
 80c:	00e6e463          	bltu	a3,a4,814 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 810:	fee7eae3          	bltu	a5,a4,804 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 814:	ff852583          	lw	a1,-8(a0)
 818:	6390                	ld	a2,0(a5)
 81a:	02059813          	slli	a6,a1,0x20
 81e:	01c85713          	srli	a4,a6,0x1c
 822:	9736                	add	a4,a4,a3
 824:	02e60563          	beq	a2,a4,84e <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 828:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 82c:	4790                	lw	a2,8(a5)
 82e:	02061593          	slli	a1,a2,0x20
 832:	01c5d713          	srli	a4,a1,0x1c
 836:	973e                	add	a4,a4,a5
 838:	02e68263          	beq	a3,a4,85c <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 83c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 83e:	00000717          	auipc	a4,0x0
 842:	7cf73123          	sd	a5,1986(a4) # 1000 <freep>
}
 846:	60a2                	ld	ra,8(sp)
 848:	6402                	ld	s0,0(sp)
 84a:	0141                	addi	sp,sp,16
 84c:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 84e:	4618                	lw	a4,8(a2)
 850:	9f2d                	addw	a4,a4,a1
 852:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 856:	6398                	ld	a4,0(a5)
 858:	6310                	ld	a2,0(a4)
 85a:	b7f9                	j	828 <free+0x44>
    p->s.size += bp->s.size;
 85c:	ff852703          	lw	a4,-8(a0)
 860:	9f31                	addw	a4,a4,a2
 862:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 864:	ff053683          	ld	a3,-16(a0)
 868:	bfd1                	j	83c <free+0x58>

000000000000086a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 86a:	7139                	addi	sp,sp,-64
 86c:	fc06                	sd	ra,56(sp)
 86e:	f822                	sd	s0,48(sp)
 870:	f04a                	sd	s2,32(sp)
 872:	ec4e                	sd	s3,24(sp)
 874:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 876:	02051993          	slli	s3,a0,0x20
 87a:	0209d993          	srli	s3,s3,0x20
 87e:	09bd                	addi	s3,s3,15
 880:	0049d993          	srli	s3,s3,0x4
 884:	2985                	addiw	s3,s3,1
 886:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 888:	00000517          	auipc	a0,0x0
 88c:	77853503          	ld	a0,1912(a0) # 1000 <freep>
 890:	c905                	beqz	a0,8c0 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 892:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 894:	4798                	lw	a4,8(a5)
 896:	09377663          	bgeu	a4,s3,922 <malloc+0xb8>
 89a:	f426                	sd	s1,40(sp)
 89c:	e852                	sd	s4,16(sp)
 89e:	e456                	sd	s5,8(sp)
 8a0:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8a2:	8a4e                	mv	s4,s3
 8a4:	6705                	lui	a4,0x1
 8a6:	00e9f363          	bgeu	s3,a4,8ac <malloc+0x42>
 8aa:	6a05                	lui	s4,0x1
 8ac:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8b0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8b4:	00000497          	auipc	s1,0x0
 8b8:	74c48493          	addi	s1,s1,1868 # 1000 <freep>
  if(p == SBRK_ERROR)
 8bc:	5afd                	li	s5,-1
 8be:	a83d                	j	8fc <malloc+0x92>
 8c0:	f426                	sd	s1,40(sp)
 8c2:	e852                	sd	s4,16(sp)
 8c4:	e456                	sd	s5,8(sp)
 8c6:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8c8:	00000797          	auipc	a5,0x0
 8cc:	74878793          	addi	a5,a5,1864 # 1010 <base>
 8d0:	00000717          	auipc	a4,0x0
 8d4:	72f73823          	sd	a5,1840(a4) # 1000 <freep>
 8d8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8da:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8de:	b7d1                	j	8a2 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8e0:	6398                	ld	a4,0(a5)
 8e2:	e118                	sd	a4,0(a0)
 8e4:	a899                	j	93a <malloc+0xd0>
  hp->s.size = nu;
 8e6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8ea:	0541                	addi	a0,a0,16
 8ec:	ef9ff0ef          	jal	7e4 <free>
  return freep;
 8f0:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8f2:	c125                	beqz	a0,952 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8f6:	4798                	lw	a4,8(a5)
 8f8:	03277163          	bgeu	a4,s2,91a <malloc+0xb0>
    if(p == freep)
 8fc:	6098                	ld	a4,0(s1)
 8fe:	853e                	mv	a0,a5
 900:	fef71ae3          	bne	a4,a5,8f4 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 904:	8552                	mv	a0,s4
 906:	a23ff0ef          	jal	328 <sbrk>
  if(p == SBRK_ERROR)
 90a:	fd551ee3          	bne	a0,s5,8e6 <malloc+0x7c>
        return 0;
 90e:	4501                	li	a0,0
 910:	74a2                	ld	s1,40(sp)
 912:	6a42                	ld	s4,16(sp)
 914:	6aa2                	ld	s5,8(sp)
 916:	6b02                	ld	s6,0(sp)
 918:	a03d                	j	946 <malloc+0xdc>
 91a:	74a2                	ld	s1,40(sp)
 91c:	6a42                	ld	s4,16(sp)
 91e:	6aa2                	ld	s5,8(sp)
 920:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 922:	fae90fe3          	beq	s2,a4,8e0 <malloc+0x76>
        p->s.size -= nunits;
 926:	4137073b          	subw	a4,a4,s3
 92a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 92c:	02071693          	slli	a3,a4,0x20
 930:	01c6d713          	srli	a4,a3,0x1c
 934:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 936:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 93a:	00000717          	auipc	a4,0x0
 93e:	6ca73323          	sd	a0,1734(a4) # 1000 <freep>
      return (void*)(p + 1);
 942:	01078513          	addi	a0,a5,16
  }
}
 946:	70e2                	ld	ra,56(sp)
 948:	7442                	ld	s0,48(sp)
 94a:	7902                	ld	s2,32(sp)
 94c:	69e2                	ld	s3,24(sp)
 94e:	6121                	addi	sp,sp,64
 950:	8082                	ret
 952:	74a2                	ld	s1,40(sp)
 954:	6a42                	ld	s4,16(sp)
 956:	6aa2                	ld	s5,8(sp)
 958:	6b02                	ld	s6,0(sp)
 95a:	b7f5                	j	946 <malloc+0xdc>
