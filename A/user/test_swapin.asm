
user/_test_swapin:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

#define PAGES 70

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
  printf("Swap-in test starting\n");
  18:	00001517          	auipc	a0,0x1
  1c:	98850513          	addi	a0,a0,-1656 # 9a0 <malloc+0x100>
  20:	7c8000ef          	jal	7e8 <printf>
  int *a = (int*)sbrk(PAGES * 4096);
  24:	00046537          	lui	a0,0x46
  28:	336000ef          	jal	35e <sbrk>
  2c:	892a                	mv	s2,a0
  2e:	87aa                	mv	a5,a0
  
  // Write to all pages (make them dirty)
  for(int i = 0; i < PAGES; i++) {
  30:	4481                	li	s1,0
  32:	6685                	lui	a3,0x1
  34:	04600713          	li	a4,70
    a[i * 1024] = i; // Store full integers, 1024 ints per page
  38:	c384                	sw	s1,0(a5)
  for(int i = 0; i < PAGES; i++) {
  3a:	2485                	addiw	s1,s1,1
  3c:	97b6                	add	a5,a5,a3
  3e:	fee49de3          	bne	s1,a4,38 <main+0x38>
  }
  
  // Force eviction by allocating more pages
  printf("Forcing more evictions...\n");
  42:	00001517          	auipc	a0,0x1
  46:	97e50513          	addi	a0,a0,-1666 # 9c0 <malloc+0x120>
  4a:	79e000ef          	jal	7e8 <printf>
  for(int i = PAGES; i < 2 * PAGES; i++) {
    int *b = (int*)sbrk(4096);
  4e:	6a05                	lui	s4,0x1
  for(int i = PAGES; i < 2 * PAGES; i++) {
  50:	08c00993          	li	s3,140
    int *b = (int*)sbrk(4096);
  54:	8552                	mv	a0,s4
  56:	308000ef          	jal	35e <sbrk>
    *b = i; // write to trigger dirty eviction
  5a:	c104                	sw	s1,0(a0)
  for(int i = PAGES; i < 2 * PAGES; i++) {
  5c:	2485                	addiw	s1,s1,1
  5e:	ff349be3          	bne	s1,s3,54 <main+0x54>
  }
  
  // Now re-access first half to trigger swap-in
  printf("Re-accessing swapped pages...\n");
  62:	00001517          	auipc	a0,0x1
  66:	97e50513          	addi	a0,a0,-1666 # 9e0 <malloc+0x140>
  6a:	77e000ef          	jal	7e8 <printf>
  for(int i = 0; i < PAGES; i++) {
  6e:	4481                	li	s1,0
    printf("%d ", a[i * 1024]);
  70:	00001b97          	auipc	s7,0x1
  74:	990b8b93          	addi	s7,s7,-1648 # a00 <malloc+0x160>
    if(i % 10 == 9) printf("\n"); // newline every 10 numbers
  78:	666669b7          	lui	s3,0x66666
  7c:	66798993          	addi	s3,s3,1639 # 66666667 <base+0x66665657>
  80:	4b25                	li	s6,9
  82:	00001c17          	auipc	s8,0x1
  86:	986c0c13          	addi	s8,s8,-1658 # a08 <malloc+0x168>
  for(int i = 0; i < PAGES; i++) {
  8a:	6a85                	lui	s5,0x1
  8c:	04600a13          	li	s4,70
  90:	a029                	j	9a <main+0x9a>
  92:	2485                	addiw	s1,s1,1
  94:	9956                	add	s2,s2,s5
  96:	03448a63          	beq	s1,s4,ca <main+0xca>
    printf("%d ", a[i * 1024]);
  9a:	00092583          	lw	a1,0(s2)
  9e:	855e                	mv	a0,s7
  a0:	748000ef          	jal	7e8 <printf>
    if(i % 10 == 9) printf("\n"); // newline every 10 numbers
  a4:	03348733          	mul	a4,s1,s3
  a8:	9709                	srai	a4,a4,0x22
  aa:	41f4d79b          	sraiw	a5,s1,0x1f
  ae:	9f1d                	subw	a4,a4,a5
  b0:	0027179b          	slliw	a5,a4,0x2
  b4:	9fb9                	addw	a5,a5,a4
  b6:	0017979b          	slliw	a5,a5,0x1
  ba:	40f487bb          	subw	a5,s1,a5
  be:	fd679ae3          	bne	a5,s6,92 <main+0x92>
  c2:	8562                	mv	a0,s8
  c4:	724000ef          	jal	7e8 <printf>
  c8:	b7e9                	j	92 <main+0x92>
  }
  printf("\nSwap-in test done\n");
  ca:	00001517          	auipc	a0,0x1
  ce:	94650513          	addi	a0,a0,-1722 # a10 <malloc+0x170>
  d2:	716000ef          	jal	7e8 <printf>
  exit(0);
  d6:	4501                	li	a0,0
  d8:	2ba000ef          	jal	392 <exit>

00000000000000dc <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  dc:	1141                	addi	sp,sp,-16
  de:	e406                	sd	ra,8(sp)
  e0:	e022                	sd	s0,0(sp)
  e2:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  e4:	f1dff0ef          	jal	0 <main>
  exit(r);
  e8:	2aa000ef          	jal	392 <exit>

00000000000000ec <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  ec:	1141                	addi	sp,sp,-16
  ee:	e406                	sd	ra,8(sp)
  f0:	e022                	sd	s0,0(sp)
  f2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  f4:	87aa                	mv	a5,a0
  f6:	0585                	addi	a1,a1,1
  f8:	0785                	addi	a5,a5,1
  fa:	fff5c703          	lbu	a4,-1(a1)
  fe:	fee78fa3          	sb	a4,-1(a5)
 102:	fb75                	bnez	a4,f6 <strcpy+0xa>
    ;
  return os;
}
 104:	60a2                	ld	ra,8(sp)
 106:	6402                	ld	s0,0(sp)
 108:	0141                	addi	sp,sp,16
 10a:	8082                	ret

000000000000010c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 10c:	1141                	addi	sp,sp,-16
 10e:	e406                	sd	ra,8(sp)
 110:	e022                	sd	s0,0(sp)
 112:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 114:	00054783          	lbu	a5,0(a0)
 118:	cb91                	beqz	a5,12c <strcmp+0x20>
 11a:	0005c703          	lbu	a4,0(a1)
 11e:	00f71763          	bne	a4,a5,12c <strcmp+0x20>
    p++, q++;
 122:	0505                	addi	a0,a0,1
 124:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 126:	00054783          	lbu	a5,0(a0)
 12a:	fbe5                	bnez	a5,11a <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 12c:	0005c503          	lbu	a0,0(a1)
}
 130:	40a7853b          	subw	a0,a5,a0
 134:	60a2                	ld	ra,8(sp)
 136:	6402                	ld	s0,0(sp)
 138:	0141                	addi	sp,sp,16
 13a:	8082                	ret

000000000000013c <strlen>:

uint
strlen(const char *s)
{
 13c:	1141                	addi	sp,sp,-16
 13e:	e406                	sd	ra,8(sp)
 140:	e022                	sd	s0,0(sp)
 142:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 144:	00054783          	lbu	a5,0(a0)
 148:	cf91                	beqz	a5,164 <strlen+0x28>
 14a:	00150793          	addi	a5,a0,1
 14e:	86be                	mv	a3,a5
 150:	0785                	addi	a5,a5,1
 152:	fff7c703          	lbu	a4,-1(a5)
 156:	ff65                	bnez	a4,14e <strlen+0x12>
 158:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 15c:	60a2                	ld	ra,8(sp)
 15e:	6402                	ld	s0,0(sp)
 160:	0141                	addi	sp,sp,16
 162:	8082                	ret
  for(n = 0; s[n]; n++)
 164:	4501                	li	a0,0
 166:	bfdd                	j	15c <strlen+0x20>

0000000000000168 <memset>:

void*
memset(void *dst, int c, uint n)
{
 168:	1141                	addi	sp,sp,-16
 16a:	e406                	sd	ra,8(sp)
 16c:	e022                	sd	s0,0(sp)
 16e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 170:	ca19                	beqz	a2,186 <memset+0x1e>
 172:	87aa                	mv	a5,a0
 174:	1602                	slli	a2,a2,0x20
 176:	9201                	srli	a2,a2,0x20
 178:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 17c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 180:	0785                	addi	a5,a5,1
 182:	fee79de3          	bne	a5,a4,17c <memset+0x14>
  }
  return dst;
}
 186:	60a2                	ld	ra,8(sp)
 188:	6402                	ld	s0,0(sp)
 18a:	0141                	addi	sp,sp,16
 18c:	8082                	ret

000000000000018e <strchr>:

char*
strchr(const char *s, char c)
{
 18e:	1141                	addi	sp,sp,-16
 190:	e406                	sd	ra,8(sp)
 192:	e022                	sd	s0,0(sp)
 194:	0800                	addi	s0,sp,16
  for(; *s; s++)
 196:	00054783          	lbu	a5,0(a0)
 19a:	cf81                	beqz	a5,1b2 <strchr+0x24>
    if(*s == c)
 19c:	00f58763          	beq	a1,a5,1aa <strchr+0x1c>
  for(; *s; s++)
 1a0:	0505                	addi	a0,a0,1
 1a2:	00054783          	lbu	a5,0(a0)
 1a6:	fbfd                	bnez	a5,19c <strchr+0xe>
      return (char*)s;
  return 0;
 1a8:	4501                	li	a0,0
}
 1aa:	60a2                	ld	ra,8(sp)
 1ac:	6402                	ld	s0,0(sp)
 1ae:	0141                	addi	sp,sp,16
 1b0:	8082                	ret
  return 0;
 1b2:	4501                	li	a0,0
 1b4:	bfdd                	j	1aa <strchr+0x1c>

00000000000001b6 <gets>:

char*
gets(char *buf, int max)
{
 1b6:	711d                	addi	sp,sp,-96
 1b8:	ec86                	sd	ra,88(sp)
 1ba:	e8a2                	sd	s0,80(sp)
 1bc:	e4a6                	sd	s1,72(sp)
 1be:	e0ca                	sd	s2,64(sp)
 1c0:	fc4e                	sd	s3,56(sp)
 1c2:	f852                	sd	s4,48(sp)
 1c4:	f456                	sd	s5,40(sp)
 1c6:	f05a                	sd	s6,32(sp)
 1c8:	ec5e                	sd	s7,24(sp)
 1ca:	e862                	sd	s8,16(sp)
 1cc:	1080                	addi	s0,sp,96
 1ce:	8baa                	mv	s7,a0
 1d0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d2:	892a                	mv	s2,a0
 1d4:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1d6:	faf40b13          	addi	s6,s0,-81
 1da:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 1dc:	8c26                	mv	s8,s1
 1de:	0014899b          	addiw	s3,s1,1
 1e2:	84ce                	mv	s1,s3
 1e4:	0349d463          	bge	s3,s4,20c <gets+0x56>
    cc = read(0, &c, 1);
 1e8:	8656                	mv	a2,s5
 1ea:	85da                	mv	a1,s6
 1ec:	4501                	li	a0,0
 1ee:	1bc000ef          	jal	3aa <read>
    if(cc < 1)
 1f2:	00a05d63          	blez	a0,20c <gets+0x56>
      break;
    buf[i++] = c;
 1f6:	faf44783          	lbu	a5,-81(s0)
 1fa:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1fe:	0905                	addi	s2,s2,1
 200:	ff678713          	addi	a4,a5,-10
 204:	c319                	beqz	a4,20a <gets+0x54>
 206:	17cd                	addi	a5,a5,-13
 208:	fbf1                	bnez	a5,1dc <gets+0x26>
    buf[i++] = c;
 20a:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 20c:	9c5e                	add	s8,s8,s7
 20e:	000c0023          	sb	zero,0(s8)
  return buf;
}
 212:	855e                	mv	a0,s7
 214:	60e6                	ld	ra,88(sp)
 216:	6446                	ld	s0,80(sp)
 218:	64a6                	ld	s1,72(sp)
 21a:	6906                	ld	s2,64(sp)
 21c:	79e2                	ld	s3,56(sp)
 21e:	7a42                	ld	s4,48(sp)
 220:	7aa2                	ld	s5,40(sp)
 222:	7b02                	ld	s6,32(sp)
 224:	6be2                	ld	s7,24(sp)
 226:	6c42                	ld	s8,16(sp)
 228:	6125                	addi	sp,sp,96
 22a:	8082                	ret

000000000000022c <stat>:

int
stat(const char *n, struct stat *st)
{
 22c:	1101                	addi	sp,sp,-32
 22e:	ec06                	sd	ra,24(sp)
 230:	e822                	sd	s0,16(sp)
 232:	e04a                	sd	s2,0(sp)
 234:	1000                	addi	s0,sp,32
 236:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 238:	4581                	li	a1,0
 23a:	198000ef          	jal	3d2 <open>
  if(fd < 0)
 23e:	02054263          	bltz	a0,262 <stat+0x36>
 242:	e426                	sd	s1,8(sp)
 244:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 246:	85ca                	mv	a1,s2
 248:	1a2000ef          	jal	3ea <fstat>
 24c:	892a                	mv	s2,a0
  close(fd);
 24e:	8526                	mv	a0,s1
 250:	16a000ef          	jal	3ba <close>
  return r;
 254:	64a2                	ld	s1,8(sp)
}
 256:	854a                	mv	a0,s2
 258:	60e2                	ld	ra,24(sp)
 25a:	6442                	ld	s0,16(sp)
 25c:	6902                	ld	s2,0(sp)
 25e:	6105                	addi	sp,sp,32
 260:	8082                	ret
    return -1;
 262:	57fd                	li	a5,-1
 264:	893e                	mv	s2,a5
 266:	bfc5                	j	256 <stat+0x2a>

0000000000000268 <atoi>:

int
atoi(const char *s)
{
 268:	1141                	addi	sp,sp,-16
 26a:	e406                	sd	ra,8(sp)
 26c:	e022                	sd	s0,0(sp)
 26e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 270:	00054683          	lbu	a3,0(a0)
 274:	fd06879b          	addiw	a5,a3,-48 # fd0 <digits+0x5a0>
 278:	0ff7f793          	zext.b	a5,a5
 27c:	4625                	li	a2,9
 27e:	02f66963          	bltu	a2,a5,2b0 <atoi+0x48>
 282:	872a                	mv	a4,a0
  n = 0;
 284:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 286:	0705                	addi	a4,a4,1
 288:	0025179b          	slliw	a5,a0,0x2
 28c:	9fa9                	addw	a5,a5,a0
 28e:	0017979b          	slliw	a5,a5,0x1
 292:	9fb5                	addw	a5,a5,a3
 294:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 298:	00074683          	lbu	a3,0(a4)
 29c:	fd06879b          	addiw	a5,a3,-48
 2a0:	0ff7f793          	zext.b	a5,a5
 2a4:	fef671e3          	bgeu	a2,a5,286 <atoi+0x1e>
  return n;
}
 2a8:	60a2                	ld	ra,8(sp)
 2aa:	6402                	ld	s0,0(sp)
 2ac:	0141                	addi	sp,sp,16
 2ae:	8082                	ret
  n = 0;
 2b0:	4501                	li	a0,0
 2b2:	bfdd                	j	2a8 <atoi+0x40>

00000000000002b4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2b4:	1141                	addi	sp,sp,-16
 2b6:	e406                	sd	ra,8(sp)
 2b8:	e022                	sd	s0,0(sp)
 2ba:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2bc:	02b57563          	bgeu	a0,a1,2e6 <memmove+0x32>
    while(n-- > 0)
 2c0:	00c05f63          	blez	a2,2de <memmove+0x2a>
 2c4:	1602                	slli	a2,a2,0x20
 2c6:	9201                	srli	a2,a2,0x20
 2c8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2cc:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ce:	0585                	addi	a1,a1,1
 2d0:	0705                	addi	a4,a4,1
 2d2:	fff5c683          	lbu	a3,-1(a1)
 2d6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2da:	fee79ae3          	bne	a5,a4,2ce <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2de:	60a2                	ld	ra,8(sp)
 2e0:	6402                	ld	s0,0(sp)
 2e2:	0141                	addi	sp,sp,16
 2e4:	8082                	ret
    while(n-- > 0)
 2e6:	fec05ce3          	blez	a2,2de <memmove+0x2a>
    dst += n;
 2ea:	00c50733          	add	a4,a0,a2
    src += n;
 2ee:	95b2                	add	a1,a1,a2
 2f0:	fff6079b          	addiw	a5,a2,-1
 2f4:	1782                	slli	a5,a5,0x20
 2f6:	9381                	srli	a5,a5,0x20
 2f8:	fff7c793          	not	a5,a5
 2fc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2fe:	15fd                	addi	a1,a1,-1
 300:	177d                	addi	a4,a4,-1
 302:	0005c683          	lbu	a3,0(a1)
 306:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 30a:	fef71ae3          	bne	a4,a5,2fe <memmove+0x4a>
 30e:	bfc1                	j	2de <memmove+0x2a>

0000000000000310 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 310:	1141                	addi	sp,sp,-16
 312:	e406                	sd	ra,8(sp)
 314:	e022                	sd	s0,0(sp)
 316:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 318:	c61d                	beqz	a2,346 <memcmp+0x36>
 31a:	1602                	slli	a2,a2,0x20
 31c:	9201                	srli	a2,a2,0x20
 31e:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 322:	00054783          	lbu	a5,0(a0)
 326:	0005c703          	lbu	a4,0(a1)
 32a:	00e79863          	bne	a5,a4,33a <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 32e:	0505                	addi	a0,a0,1
    p2++;
 330:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 332:	fed518e3          	bne	a0,a3,322 <memcmp+0x12>
  }
  return 0;
 336:	4501                	li	a0,0
 338:	a019                	j	33e <memcmp+0x2e>
      return *p1 - *p2;
 33a:	40e7853b          	subw	a0,a5,a4
}
 33e:	60a2                	ld	ra,8(sp)
 340:	6402                	ld	s0,0(sp)
 342:	0141                	addi	sp,sp,16
 344:	8082                	ret
  return 0;
 346:	4501                	li	a0,0
 348:	bfdd                	j	33e <memcmp+0x2e>

000000000000034a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 34a:	1141                	addi	sp,sp,-16
 34c:	e406                	sd	ra,8(sp)
 34e:	e022                	sd	s0,0(sp)
 350:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 352:	f63ff0ef          	jal	2b4 <memmove>
}
 356:	60a2                	ld	ra,8(sp)
 358:	6402                	ld	s0,0(sp)
 35a:	0141                	addi	sp,sp,16
 35c:	8082                	ret

000000000000035e <sbrk>:

char *
sbrk(int n) {
 35e:	1141                	addi	sp,sp,-16
 360:	e406                	sd	ra,8(sp)
 362:	e022                	sd	s0,0(sp)
 364:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 366:	4585                	li	a1,1
 368:	0b2000ef          	jal	41a <sys_sbrk>
}
 36c:	60a2                	ld	ra,8(sp)
 36e:	6402                	ld	s0,0(sp)
 370:	0141                	addi	sp,sp,16
 372:	8082                	ret

0000000000000374 <sbrklazy>:

char *
sbrklazy(int n) {
 374:	1141                	addi	sp,sp,-16
 376:	e406                	sd	ra,8(sp)
 378:	e022                	sd	s0,0(sp)
 37a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 37c:	4589                	li	a1,2
 37e:	09c000ef          	jal	41a <sys_sbrk>
}
 382:	60a2                	ld	ra,8(sp)
 384:	6402                	ld	s0,0(sp)
 386:	0141                	addi	sp,sp,16
 388:	8082                	ret

000000000000038a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 38a:	4885                	li	a7,1
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <exit>:
.global exit
exit:
 li a7, SYS_exit
 392:	4889                	li	a7,2
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <wait>:
.global wait
wait:
 li a7, SYS_wait
 39a:	488d                	li	a7,3
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3a2:	4891                	li	a7,4
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <read>:
.global read
read:
 li a7, SYS_read
 3aa:	4895                	li	a7,5
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <write>:
.global write
write:
 li a7, SYS_write
 3b2:	48c1                	li	a7,16
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <close>:
.global close
close:
 li a7, SYS_close
 3ba:	48d5                	li	a7,21
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3c2:	4899                	li	a7,6
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <exec>:
.global exec
exec:
 li a7, SYS_exec
 3ca:	489d                	li	a7,7
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <open>:
.global open
open:
 li a7, SYS_open
 3d2:	48bd                	li	a7,15
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3da:	48c5                	li	a7,17
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3e2:	48c9                	li	a7,18
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3ea:	48a1                	li	a7,8
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <link>:
.global link
link:
 li a7, SYS_link
 3f2:	48cd                	li	a7,19
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3fa:	48d1                	li	a7,20
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 402:	48a5                	li	a7,9
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <dup>:
.global dup
dup:
 li a7, SYS_dup
 40a:	48a9                	li	a7,10
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 412:	48ad                	li	a7,11
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 41a:	48b1                	li	a7,12
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <pause>:
.global pause
pause:
 li a7, SYS_pause
 422:	48b5                	li	a7,13
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 42a:	48b9                	li	a7,14
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <memstat>:
.global memstat
memstat:
 li a7, SYS_memstat
 432:	48d9                	li	a7,22
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <enable_bonus>:
.global enable_bonus
enable_bonus:
 li a7, SYS_enable_bonus
 43a:	48dd                	li	a7,23
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 442:	1101                	addi	sp,sp,-32
 444:	ec06                	sd	ra,24(sp)
 446:	e822                	sd	s0,16(sp)
 448:	1000                	addi	s0,sp,32
 44a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 44e:	4605                	li	a2,1
 450:	fef40593          	addi	a1,s0,-17
 454:	f5fff0ef          	jal	3b2 <write>
}
 458:	60e2                	ld	ra,24(sp)
 45a:	6442                	ld	s0,16(sp)
 45c:	6105                	addi	sp,sp,32
 45e:	8082                	ret

0000000000000460 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 460:	715d                	addi	sp,sp,-80
 462:	e486                	sd	ra,72(sp)
 464:	e0a2                	sd	s0,64(sp)
 466:	f84a                	sd	s2,48(sp)
 468:	f44e                	sd	s3,40(sp)
 46a:	0880                	addi	s0,sp,80
 46c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 46e:	c6d1                	beqz	a3,4fa <printint+0x9a>
 470:	0805d563          	bgez	a1,4fa <printint+0x9a>
    neg = 1;
    x = -xx;
 474:	40b005b3          	neg	a1,a1
    neg = 1;
 478:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 47a:	fb840993          	addi	s3,s0,-72
  neg = 0;
 47e:	86ce                	mv	a3,s3
  i = 0;
 480:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 482:	00000817          	auipc	a6,0x0
 486:	5ae80813          	addi	a6,a6,1454 # a30 <digits>
 48a:	88ba                	mv	a7,a4
 48c:	0017051b          	addiw	a0,a4,1
 490:	872a                	mv	a4,a0
 492:	02c5f7b3          	remu	a5,a1,a2
 496:	97c2                	add	a5,a5,a6
 498:	0007c783          	lbu	a5,0(a5)
 49c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4a0:	87ae                	mv	a5,a1
 4a2:	02c5d5b3          	divu	a1,a1,a2
 4a6:	0685                	addi	a3,a3,1
 4a8:	fec7f1e3          	bgeu	a5,a2,48a <printint+0x2a>
  if(neg)
 4ac:	00030c63          	beqz	t1,4c4 <printint+0x64>
    buf[i++] = '-';
 4b0:	fd050793          	addi	a5,a0,-48
 4b4:	00878533          	add	a0,a5,s0
 4b8:	02d00793          	li	a5,45
 4bc:	fef50423          	sb	a5,-24(a0)
 4c0:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 4c4:	02e05563          	blez	a4,4ee <printint+0x8e>
 4c8:	fc26                	sd	s1,56(sp)
 4ca:	377d                	addiw	a4,a4,-1
 4cc:	00e984b3          	add	s1,s3,a4
 4d0:	19fd                	addi	s3,s3,-1
 4d2:	99ba                	add	s3,s3,a4
 4d4:	1702                	slli	a4,a4,0x20
 4d6:	9301                	srli	a4,a4,0x20
 4d8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4dc:	0004c583          	lbu	a1,0(s1)
 4e0:	854a                	mv	a0,s2
 4e2:	f61ff0ef          	jal	442 <putc>
  while(--i >= 0)
 4e6:	14fd                	addi	s1,s1,-1
 4e8:	ff349ae3          	bne	s1,s3,4dc <printint+0x7c>
 4ec:	74e2                	ld	s1,56(sp)
}
 4ee:	60a6                	ld	ra,72(sp)
 4f0:	6406                	ld	s0,64(sp)
 4f2:	7942                	ld	s2,48(sp)
 4f4:	79a2                	ld	s3,40(sp)
 4f6:	6161                	addi	sp,sp,80
 4f8:	8082                	ret
  neg = 0;
 4fa:	4301                	li	t1,0
 4fc:	bfbd                	j	47a <printint+0x1a>

00000000000004fe <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4fe:	711d                	addi	sp,sp,-96
 500:	ec86                	sd	ra,88(sp)
 502:	e8a2                	sd	s0,80(sp)
 504:	e4a6                	sd	s1,72(sp)
 506:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 508:	0005c483          	lbu	s1,0(a1)
 50c:	22048363          	beqz	s1,732 <vprintf+0x234>
 510:	e0ca                	sd	s2,64(sp)
 512:	fc4e                	sd	s3,56(sp)
 514:	f852                	sd	s4,48(sp)
 516:	f456                	sd	s5,40(sp)
 518:	f05a                	sd	s6,32(sp)
 51a:	ec5e                	sd	s7,24(sp)
 51c:	e862                	sd	s8,16(sp)
 51e:	8b2a                	mv	s6,a0
 520:	8a2e                	mv	s4,a1
 522:	8bb2                	mv	s7,a2
  state = 0;
 524:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 526:	4901                	li	s2,0
 528:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 52a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 52e:	06400c13          	li	s8,100
 532:	a00d                	j	554 <vprintf+0x56>
        putc(fd, c0);
 534:	85a6                	mv	a1,s1
 536:	855a                	mv	a0,s6
 538:	f0bff0ef          	jal	442 <putc>
 53c:	a019                	j	542 <vprintf+0x44>
    } else if(state == '%'){
 53e:	03598363          	beq	s3,s5,564 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 542:	0019079b          	addiw	a5,s2,1
 546:	893e                	mv	s2,a5
 548:	873e                	mv	a4,a5
 54a:	97d2                	add	a5,a5,s4
 54c:	0007c483          	lbu	s1,0(a5)
 550:	1c048a63          	beqz	s1,724 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 554:	0004879b          	sext.w	a5,s1
    if(state == 0){
 558:	fe0993e3          	bnez	s3,53e <vprintf+0x40>
      if(c0 == '%'){
 55c:	fd579ce3          	bne	a5,s5,534 <vprintf+0x36>
        state = '%';
 560:	89be                	mv	s3,a5
 562:	b7c5                	j	542 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 564:	00ea06b3          	add	a3,s4,a4
 568:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 56c:	1c060863          	beqz	a2,73c <vprintf+0x23e>
      if(c0 == 'd'){
 570:	03878763          	beq	a5,s8,59e <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 574:	f9478693          	addi	a3,a5,-108
 578:	0016b693          	seqz	a3,a3
 57c:	f9c60593          	addi	a1,a2,-100
 580:	e99d                	bnez	a1,5b6 <vprintf+0xb8>
 582:	ca95                	beqz	a3,5b6 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 584:	008b8493          	addi	s1,s7,8
 588:	4685                	li	a3,1
 58a:	4629                	li	a2,10
 58c:	000bb583          	ld	a1,0(s7)
 590:	855a                	mv	a0,s6
 592:	ecfff0ef          	jal	460 <printint>
        i += 1;
 596:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 598:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 59a:	4981                	li	s3,0
 59c:	b75d                	j	542 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 59e:	008b8493          	addi	s1,s7,8
 5a2:	4685                	li	a3,1
 5a4:	4629                	li	a2,10
 5a6:	000ba583          	lw	a1,0(s7)
 5aa:	855a                	mv	a0,s6
 5ac:	eb5ff0ef          	jal	460 <printint>
 5b0:	8ba6                	mv	s7,s1
      state = 0;
 5b2:	4981                	li	s3,0
 5b4:	b779                	j	542 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 5b6:	9752                	add	a4,a4,s4
 5b8:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5bc:	f9460713          	addi	a4,a2,-108
 5c0:	00173713          	seqz	a4,a4
 5c4:	8f75                	and	a4,a4,a3
 5c6:	f9c58513          	addi	a0,a1,-100
 5ca:	18051363          	bnez	a0,750 <vprintf+0x252>
 5ce:	18070163          	beqz	a4,750 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5d2:	008b8493          	addi	s1,s7,8
 5d6:	4685                	li	a3,1
 5d8:	4629                	li	a2,10
 5da:	000bb583          	ld	a1,0(s7)
 5de:	855a                	mv	a0,s6
 5e0:	e81ff0ef          	jal	460 <printint>
        i += 2;
 5e4:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5e6:	8ba6                	mv	s7,s1
      state = 0;
 5e8:	4981                	li	s3,0
        i += 2;
 5ea:	bfa1                	j	542 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5ec:	008b8493          	addi	s1,s7,8
 5f0:	4681                	li	a3,0
 5f2:	4629                	li	a2,10
 5f4:	000be583          	lwu	a1,0(s7)
 5f8:	855a                	mv	a0,s6
 5fa:	e67ff0ef          	jal	460 <printint>
 5fe:	8ba6                	mv	s7,s1
      state = 0;
 600:	4981                	li	s3,0
 602:	b781                	j	542 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 604:	008b8493          	addi	s1,s7,8
 608:	4681                	li	a3,0
 60a:	4629                	li	a2,10
 60c:	000bb583          	ld	a1,0(s7)
 610:	855a                	mv	a0,s6
 612:	e4fff0ef          	jal	460 <printint>
        i += 1;
 616:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 618:	8ba6                	mv	s7,s1
      state = 0;
 61a:	4981                	li	s3,0
 61c:	b71d                	j	542 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 61e:	008b8493          	addi	s1,s7,8
 622:	4681                	li	a3,0
 624:	4629                	li	a2,10
 626:	000bb583          	ld	a1,0(s7)
 62a:	855a                	mv	a0,s6
 62c:	e35ff0ef          	jal	460 <printint>
        i += 2;
 630:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 632:	8ba6                	mv	s7,s1
      state = 0;
 634:	4981                	li	s3,0
        i += 2;
 636:	b731                	j	542 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 638:	008b8493          	addi	s1,s7,8
 63c:	4681                	li	a3,0
 63e:	4641                	li	a2,16
 640:	000be583          	lwu	a1,0(s7)
 644:	855a                	mv	a0,s6
 646:	e1bff0ef          	jal	460 <printint>
 64a:	8ba6                	mv	s7,s1
      state = 0;
 64c:	4981                	li	s3,0
 64e:	bdd5                	j	542 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 650:	008b8493          	addi	s1,s7,8
 654:	4681                	li	a3,0
 656:	4641                	li	a2,16
 658:	000bb583          	ld	a1,0(s7)
 65c:	855a                	mv	a0,s6
 65e:	e03ff0ef          	jal	460 <printint>
        i += 1;
 662:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 664:	8ba6                	mv	s7,s1
      state = 0;
 666:	4981                	li	s3,0
 668:	bde9                	j	542 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 66a:	008b8493          	addi	s1,s7,8
 66e:	4681                	li	a3,0
 670:	4641                	li	a2,16
 672:	000bb583          	ld	a1,0(s7)
 676:	855a                	mv	a0,s6
 678:	de9ff0ef          	jal	460 <printint>
        i += 2;
 67c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 67e:	8ba6                	mv	s7,s1
      state = 0;
 680:	4981                	li	s3,0
        i += 2;
 682:	b5c1                	j	542 <vprintf+0x44>
 684:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 686:	008b8793          	addi	a5,s7,8
 68a:	8cbe                	mv	s9,a5
 68c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 690:	03000593          	li	a1,48
 694:	855a                	mv	a0,s6
 696:	dadff0ef          	jal	442 <putc>
  putc(fd, 'x');
 69a:	07800593          	li	a1,120
 69e:	855a                	mv	a0,s6
 6a0:	da3ff0ef          	jal	442 <putc>
 6a4:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6a6:	00000b97          	auipc	s7,0x0
 6aa:	38ab8b93          	addi	s7,s7,906 # a30 <digits>
 6ae:	03c9d793          	srli	a5,s3,0x3c
 6b2:	97de                	add	a5,a5,s7
 6b4:	0007c583          	lbu	a1,0(a5)
 6b8:	855a                	mv	a0,s6
 6ba:	d89ff0ef          	jal	442 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6be:	0992                	slli	s3,s3,0x4
 6c0:	34fd                	addiw	s1,s1,-1
 6c2:	f4f5                	bnez	s1,6ae <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 6c4:	8be6                	mv	s7,s9
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	6ca2                	ld	s9,8(sp)
 6ca:	bda5                	j	542 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 6cc:	008b8493          	addi	s1,s7,8
 6d0:	000bc583          	lbu	a1,0(s7)
 6d4:	855a                	mv	a0,s6
 6d6:	d6dff0ef          	jal	442 <putc>
 6da:	8ba6                	mv	s7,s1
      state = 0;
 6dc:	4981                	li	s3,0
 6de:	b595                	j	542 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6e0:	008b8993          	addi	s3,s7,8
 6e4:	000bb483          	ld	s1,0(s7)
 6e8:	cc91                	beqz	s1,704 <vprintf+0x206>
        for(; *s; s++)
 6ea:	0004c583          	lbu	a1,0(s1)
 6ee:	c985                	beqz	a1,71e <vprintf+0x220>
          putc(fd, *s);
 6f0:	855a                	mv	a0,s6
 6f2:	d51ff0ef          	jal	442 <putc>
        for(; *s; s++)
 6f6:	0485                	addi	s1,s1,1
 6f8:	0004c583          	lbu	a1,0(s1)
 6fc:	f9f5                	bnez	a1,6f0 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 6fe:	8bce                	mv	s7,s3
      state = 0;
 700:	4981                	li	s3,0
 702:	b581                	j	542 <vprintf+0x44>
          s = "(null)";
 704:	00000497          	auipc	s1,0x0
 708:	32448493          	addi	s1,s1,804 # a28 <malloc+0x188>
        for(; *s; s++)
 70c:	02800593          	li	a1,40
 710:	b7c5                	j	6f0 <vprintf+0x1f2>
        putc(fd, '%');
 712:	85be                	mv	a1,a5
 714:	855a                	mv	a0,s6
 716:	d2dff0ef          	jal	442 <putc>
      state = 0;
 71a:	4981                	li	s3,0
 71c:	b51d                	j	542 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 71e:	8bce                	mv	s7,s3
      state = 0;
 720:	4981                	li	s3,0
 722:	b505                	j	542 <vprintf+0x44>
 724:	6906                	ld	s2,64(sp)
 726:	79e2                	ld	s3,56(sp)
 728:	7a42                	ld	s4,48(sp)
 72a:	7aa2                	ld	s5,40(sp)
 72c:	7b02                	ld	s6,32(sp)
 72e:	6be2                	ld	s7,24(sp)
 730:	6c42                	ld	s8,16(sp)
    }
  }
}
 732:	60e6                	ld	ra,88(sp)
 734:	6446                	ld	s0,80(sp)
 736:	64a6                	ld	s1,72(sp)
 738:	6125                	addi	sp,sp,96
 73a:	8082                	ret
      if(c0 == 'd'){
 73c:	06400713          	li	a4,100
 740:	e4e78fe3          	beq	a5,a4,59e <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 744:	f9478693          	addi	a3,a5,-108
 748:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 74c:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 74e:	4701                	li	a4,0
      } else if(c0 == 'u'){
 750:	07500513          	li	a0,117
 754:	e8a78ce3          	beq	a5,a0,5ec <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 758:	f8b60513          	addi	a0,a2,-117
 75c:	e119                	bnez	a0,762 <vprintf+0x264>
 75e:	ea0693e3          	bnez	a3,604 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 762:	f8b58513          	addi	a0,a1,-117
 766:	e119                	bnez	a0,76c <vprintf+0x26e>
 768:	ea071be3          	bnez	a4,61e <vprintf+0x120>
      } else if(c0 == 'x'){
 76c:	07800513          	li	a0,120
 770:	eca784e3          	beq	a5,a0,638 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 774:	f8860613          	addi	a2,a2,-120
 778:	e219                	bnez	a2,77e <vprintf+0x280>
 77a:	ec069be3          	bnez	a3,650 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 77e:	f8858593          	addi	a1,a1,-120
 782:	e199                	bnez	a1,788 <vprintf+0x28a>
 784:	ee0713e3          	bnez	a4,66a <vprintf+0x16c>
      } else if(c0 == 'p'){
 788:	07000713          	li	a4,112
 78c:	eee78ce3          	beq	a5,a4,684 <vprintf+0x186>
      } else if(c0 == 'c'){
 790:	06300713          	li	a4,99
 794:	f2e78ce3          	beq	a5,a4,6cc <vprintf+0x1ce>
      } else if(c0 == 's'){
 798:	07300713          	li	a4,115
 79c:	f4e782e3          	beq	a5,a4,6e0 <vprintf+0x1e2>
      } else if(c0 == '%'){
 7a0:	02500713          	li	a4,37
 7a4:	f6e787e3          	beq	a5,a4,712 <vprintf+0x214>
        putc(fd, '%');
 7a8:	02500593          	li	a1,37
 7ac:	855a                	mv	a0,s6
 7ae:	c95ff0ef          	jal	442 <putc>
        putc(fd, c0);
 7b2:	85a6                	mv	a1,s1
 7b4:	855a                	mv	a0,s6
 7b6:	c8dff0ef          	jal	442 <putc>
      state = 0;
 7ba:	4981                	li	s3,0
 7bc:	b359                	j	542 <vprintf+0x44>

00000000000007be <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7be:	715d                	addi	sp,sp,-80
 7c0:	ec06                	sd	ra,24(sp)
 7c2:	e822                	sd	s0,16(sp)
 7c4:	1000                	addi	s0,sp,32
 7c6:	e010                	sd	a2,0(s0)
 7c8:	e414                	sd	a3,8(s0)
 7ca:	e818                	sd	a4,16(s0)
 7cc:	ec1c                	sd	a5,24(s0)
 7ce:	03043023          	sd	a6,32(s0)
 7d2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7d6:	8622                	mv	a2,s0
 7d8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7dc:	d23ff0ef          	jal	4fe <vprintf>
}
 7e0:	60e2                	ld	ra,24(sp)
 7e2:	6442                	ld	s0,16(sp)
 7e4:	6161                	addi	sp,sp,80
 7e6:	8082                	ret

00000000000007e8 <printf>:

void
printf(const char *fmt, ...)
{
 7e8:	711d                	addi	sp,sp,-96
 7ea:	ec06                	sd	ra,24(sp)
 7ec:	e822                	sd	s0,16(sp)
 7ee:	1000                	addi	s0,sp,32
 7f0:	e40c                	sd	a1,8(s0)
 7f2:	e810                	sd	a2,16(s0)
 7f4:	ec14                	sd	a3,24(s0)
 7f6:	f018                	sd	a4,32(s0)
 7f8:	f41c                	sd	a5,40(s0)
 7fa:	03043823          	sd	a6,48(s0)
 7fe:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 802:	00840613          	addi	a2,s0,8
 806:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 80a:	85aa                	mv	a1,a0
 80c:	4505                	li	a0,1
 80e:	cf1ff0ef          	jal	4fe <vprintf>
}
 812:	60e2                	ld	ra,24(sp)
 814:	6442                	ld	s0,16(sp)
 816:	6125                	addi	sp,sp,96
 818:	8082                	ret

000000000000081a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 81a:	1141                	addi	sp,sp,-16
 81c:	e406                	sd	ra,8(sp)
 81e:	e022                	sd	s0,0(sp)
 820:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 822:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 826:	00000797          	auipc	a5,0x0
 82a:	7da7b783          	ld	a5,2010(a5) # 1000 <freep>
 82e:	a039                	j	83c <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 830:	6398                	ld	a4,0(a5)
 832:	00e7e463          	bltu	a5,a4,83a <free+0x20>
 836:	00e6ea63          	bltu	a3,a4,84a <free+0x30>
{
 83a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83c:	fed7fae3          	bgeu	a5,a3,830 <free+0x16>
 840:	6398                	ld	a4,0(a5)
 842:	00e6e463          	bltu	a3,a4,84a <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 846:	fee7eae3          	bltu	a5,a4,83a <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 84a:	ff852583          	lw	a1,-8(a0)
 84e:	6390                	ld	a2,0(a5)
 850:	02059813          	slli	a6,a1,0x20
 854:	01c85713          	srli	a4,a6,0x1c
 858:	9736                	add	a4,a4,a3
 85a:	02e60563          	beq	a2,a4,884 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 85e:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 862:	4790                	lw	a2,8(a5)
 864:	02061593          	slli	a1,a2,0x20
 868:	01c5d713          	srli	a4,a1,0x1c
 86c:	973e                	add	a4,a4,a5
 86e:	02e68263          	beq	a3,a4,892 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 872:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 874:	00000717          	auipc	a4,0x0
 878:	78f73623          	sd	a5,1932(a4) # 1000 <freep>
}
 87c:	60a2                	ld	ra,8(sp)
 87e:	6402                	ld	s0,0(sp)
 880:	0141                	addi	sp,sp,16
 882:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 884:	4618                	lw	a4,8(a2)
 886:	9f2d                	addw	a4,a4,a1
 888:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 88c:	6398                	ld	a4,0(a5)
 88e:	6310                	ld	a2,0(a4)
 890:	b7f9                	j	85e <free+0x44>
    p->s.size += bp->s.size;
 892:	ff852703          	lw	a4,-8(a0)
 896:	9f31                	addw	a4,a4,a2
 898:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 89a:	ff053683          	ld	a3,-16(a0)
 89e:	bfd1                	j	872 <free+0x58>

00000000000008a0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8a0:	7139                	addi	sp,sp,-64
 8a2:	fc06                	sd	ra,56(sp)
 8a4:	f822                	sd	s0,48(sp)
 8a6:	f04a                	sd	s2,32(sp)
 8a8:	ec4e                	sd	s3,24(sp)
 8aa:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8ac:	02051993          	slli	s3,a0,0x20
 8b0:	0209d993          	srli	s3,s3,0x20
 8b4:	09bd                	addi	s3,s3,15
 8b6:	0049d993          	srli	s3,s3,0x4
 8ba:	2985                	addiw	s3,s3,1
 8bc:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 8be:	00000517          	auipc	a0,0x0
 8c2:	74253503          	ld	a0,1858(a0) # 1000 <freep>
 8c6:	c905                	beqz	a0,8f6 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ca:	4798                	lw	a4,8(a5)
 8cc:	09377663          	bgeu	a4,s3,958 <malloc+0xb8>
 8d0:	f426                	sd	s1,40(sp)
 8d2:	e852                	sd	s4,16(sp)
 8d4:	e456                	sd	s5,8(sp)
 8d6:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8d8:	8a4e                	mv	s4,s3
 8da:	6705                	lui	a4,0x1
 8dc:	00e9f363          	bgeu	s3,a4,8e2 <malloc+0x42>
 8e0:	6a05                	lui	s4,0x1
 8e2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8e6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8ea:	00000497          	auipc	s1,0x0
 8ee:	71648493          	addi	s1,s1,1814 # 1000 <freep>
  if(p == SBRK_ERROR)
 8f2:	5afd                	li	s5,-1
 8f4:	a83d                	j	932 <malloc+0x92>
 8f6:	f426                	sd	s1,40(sp)
 8f8:	e852                	sd	s4,16(sp)
 8fa:	e456                	sd	s5,8(sp)
 8fc:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8fe:	00000797          	auipc	a5,0x0
 902:	71278793          	addi	a5,a5,1810 # 1010 <base>
 906:	00000717          	auipc	a4,0x0
 90a:	6ef73d23          	sd	a5,1786(a4) # 1000 <freep>
 90e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 910:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 914:	b7d1                	j	8d8 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 916:	6398                	ld	a4,0(a5)
 918:	e118                	sd	a4,0(a0)
 91a:	a899                	j	970 <malloc+0xd0>
  hp->s.size = nu;
 91c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 920:	0541                	addi	a0,a0,16
 922:	ef9ff0ef          	jal	81a <free>
  return freep;
 926:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 928:	c125                	beqz	a0,988 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 92a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 92c:	4798                	lw	a4,8(a5)
 92e:	03277163          	bgeu	a4,s2,950 <malloc+0xb0>
    if(p == freep)
 932:	6098                	ld	a4,0(s1)
 934:	853e                	mv	a0,a5
 936:	fef71ae3          	bne	a4,a5,92a <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 93a:	8552                	mv	a0,s4
 93c:	a23ff0ef          	jal	35e <sbrk>
  if(p == SBRK_ERROR)
 940:	fd551ee3          	bne	a0,s5,91c <malloc+0x7c>
        return 0;
 944:	4501                	li	a0,0
 946:	74a2                	ld	s1,40(sp)
 948:	6a42                	ld	s4,16(sp)
 94a:	6aa2                	ld	s5,8(sp)
 94c:	6b02                	ld	s6,0(sp)
 94e:	a03d                	j	97c <malloc+0xdc>
 950:	74a2                	ld	s1,40(sp)
 952:	6a42                	ld	s4,16(sp)
 954:	6aa2                	ld	s5,8(sp)
 956:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 958:	fae90fe3          	beq	s2,a4,916 <malloc+0x76>
        p->s.size -= nunits;
 95c:	4137073b          	subw	a4,a4,s3
 960:	c798                	sw	a4,8(a5)
        p += p->s.size;
 962:	02071693          	slli	a3,a4,0x20
 966:	01c6d713          	srli	a4,a3,0x1c
 96a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 96c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 970:	00000717          	auipc	a4,0x0
 974:	68a73823          	sd	a0,1680(a4) # 1000 <freep>
      return (void*)(p + 1);
 978:	01078513          	addi	a0,a5,16
  }
}
 97c:	70e2                	ld	ra,56(sp)
 97e:	7442                	ld	s0,48(sp)
 980:	7902                	ld	s2,32(sp)
 982:	69e2                	ld	s3,24(sp)
 984:	6121                	addi	sp,sp,64
 986:	8082                	ret
 988:	74a2                	ld	s1,40(sp)
 98a:	6a42                	ld	s4,16(sp)
 98c:	6aa2                	ld	s5,8(sp)
 98e:	6b02                	ld	s6,0(sp)
 990:	b7f5                	j	97c <malloc+0xdc>
