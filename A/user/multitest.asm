
user/_multitest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	0080                	addi	s0,sp,64
    int pages = 80;   // Each process allocates 80 pages to force eviction
    int i;
    char *p;
    int pid;

    printf("multitest starting: forking two processes\n");
   8:	00001517          	auipc	a0,0x1
   c:	9b850513          	addi	a0,a0,-1608 # 9c0 <malloc+0xfc>
  10:	7fc000ef          	jal	80c <printf>

    pid = fork();
  14:	39a000ef          	jal	3ae <fork>
    if(pid == 0) {
  18:	e92d                	bnez	a0,8a <main+0x8a>
  1a:	f426                	sd	s1,40(sp)
  1c:	f04a                	sd	s2,32(sp)
  1e:	ec4e                	sd	s3,24(sp)
  20:	e852                	sd	s4,16(sp)
  22:	e456                	sd	s5,8(sp)
  24:	e05a                	sd	s6,0(sp)
  26:	84aa                	mv	s1,a0
        // Child process
        printf("Child process starting allocation\n");
  28:	00001517          	auipc	a0,0x1
  2c:	9c850513          	addi	a0,a0,-1592 # 9f0 <malloc+0x12c>
  30:	7dc000ef          	jal	80c <printf>
        for(i = 0; i < pages; i++){
            p = sbrk(4096);
  34:	6985                	lui	s3,0x1
            if(p == (char*)-1){
  36:	597d                	li	s2,-1
                printf("Child: sbrk failed at page %d\n", i);
                exit(1);
            }
            p[0] = 0xAA;  // Mark child pages with 0xAA
  38:	faa00b13          	li	s6,-86
            printf("Child allocated page %d\n", i);
  3c:	00001a97          	auipc	s5,0x1
  40:	9fca8a93          	addi	s5,s5,-1540 # a38 <malloc+0x174>
        for(i = 0; i < pages; i++){
  44:	05000a13          	li	s4,80
            p = sbrk(4096);
  48:	854e                	mv	a0,s3
  4a:	338000ef          	jal	382 <sbrk>
            if(p == (char*)-1){
  4e:	03250463          	beq	a0,s2,76 <main+0x76>
            p[0] = 0xAA;  // Mark child pages with 0xAA
  52:	01650023          	sb	s6,0(a0)
            printf("Child allocated page %d\n", i);
  56:	85a6                	mv	a1,s1
  58:	8556                	mv	a0,s5
  5a:	7b2000ef          	jal	80c <printf>
        for(i = 0; i < pages; i++){
  5e:	2485                	addiw	s1,s1,1
  60:	ff4494e3          	bne	s1,s4,48 <main+0x48>
        }
        printf("Child process completed\n");
  64:	00001517          	auipc	a0,0x1
  68:	9f450513          	addi	a0,a0,-1548 # a58 <malloc+0x194>
  6c:	7a0000ef          	jal	80c <printf>
        exit(0);
  70:	4501                	li	a0,0
  72:	344000ef          	jal	3b6 <exit>
                printf("Child: sbrk failed at page %d\n", i);
  76:	85a6                	mv	a1,s1
  78:	00001517          	auipc	a0,0x1
  7c:	9a050513          	addi	a0,a0,-1632 # a18 <malloc+0x154>
  80:	78c000ef          	jal	80c <printf>
                exit(1);
  84:	4505                	li	a0,1
  86:	330000ef          	jal	3b6 <exit>
  8a:	f426                	sd	s1,40(sp)
  8c:	f04a                	sd	s2,32(sp)
  8e:	ec4e                	sd	s3,24(sp)
  90:	e852                	sd	s4,16(sp)
  92:	e456                	sd	s5,8(sp)
  94:	e05a                	sd	s6,0(sp)
    } else {
        // Parent process
        printf("Parent process starting allocation\n");
  96:	00001517          	auipc	a0,0x1
  9a:	9e250513          	addi	a0,a0,-1566 # a78 <malloc+0x1b4>
  9e:	76e000ef          	jal	80c <printf>
        for(i = 0; i < pages; i++){
  a2:	4481                	li	s1,0
            p = sbrk(4096);
  a4:	6985                	lui	s3,0x1
            if(p == (char*)-1){
  a6:	597d                	li	s2,-1
                printf("Parent: sbrk failed at page %d\n", i);
                exit(1);
            }
            p[0] = 0xBB;  // Mark parent pages with 0xBB
  a8:	fbb00b13          	li	s6,-69
            printf("Parent allocated page %d\n", i);
  ac:	00001a97          	auipc	s5,0x1
  b0:	a14a8a93          	addi	s5,s5,-1516 # ac0 <malloc+0x1fc>
        for(i = 0; i < pages; i++){
  b4:	05000a13          	li	s4,80
            p = sbrk(4096);
  b8:	854e                	mv	a0,s3
  ba:	2c8000ef          	jal	382 <sbrk>
            if(p == (char*)-1){
  be:	03250763          	beq	a0,s2,ec <main+0xec>
            p[0] = 0xBB;  // Mark parent pages with 0xBB
  c2:	01650023          	sb	s6,0(a0)
            printf("Parent allocated page %d\n", i);
  c6:	85a6                	mv	a1,s1
  c8:	8556                	mv	a0,s5
  ca:	742000ef          	jal	80c <printf>
        for(i = 0; i < pages; i++){
  ce:	2485                	addiw	s1,s1,1
  d0:	ff4494e3          	bne	s1,s4,b8 <main+0xb8>
        }
        wait(0);  // Wait for child to complete
  d4:	4501                	li	a0,0
  d6:	2e8000ef          	jal	3be <wait>
        printf("Parent process completed\n");
  da:	00001517          	auipc	a0,0x1
  de:	a0650513          	addi	a0,a0,-1530 # ae0 <malloc+0x21c>
  e2:	72a000ef          	jal	80c <printf>
    }
    
    exit(0);
  e6:	4501                	li	a0,0
  e8:	2ce000ef          	jal	3b6 <exit>
                printf("Parent: sbrk failed at page %d\n", i);
  ec:	85a6                	mv	a1,s1
  ee:	00001517          	auipc	a0,0x1
  f2:	9b250513          	addi	a0,a0,-1614 # aa0 <malloc+0x1dc>
  f6:	716000ef          	jal	80c <printf>
                exit(1);
  fa:	4505                	li	a0,1
  fc:	2ba000ef          	jal	3b6 <exit>

0000000000000100 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 100:	1141                	addi	sp,sp,-16
 102:	e406                	sd	ra,8(sp)
 104:	e022                	sd	s0,0(sp)
 106:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 108:	ef9ff0ef          	jal	0 <main>
  exit(r);
 10c:	2aa000ef          	jal	3b6 <exit>

0000000000000110 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 110:	1141                	addi	sp,sp,-16
 112:	e406                	sd	ra,8(sp)
 114:	e022                	sd	s0,0(sp)
 116:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 118:	87aa                	mv	a5,a0
 11a:	0585                	addi	a1,a1,1
 11c:	0785                	addi	a5,a5,1
 11e:	fff5c703          	lbu	a4,-1(a1)
 122:	fee78fa3          	sb	a4,-1(a5)
 126:	fb75                	bnez	a4,11a <strcpy+0xa>
    ;
  return os;
}
 128:	60a2                	ld	ra,8(sp)
 12a:	6402                	ld	s0,0(sp)
 12c:	0141                	addi	sp,sp,16
 12e:	8082                	ret

0000000000000130 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 130:	1141                	addi	sp,sp,-16
 132:	e406                	sd	ra,8(sp)
 134:	e022                	sd	s0,0(sp)
 136:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 138:	00054783          	lbu	a5,0(a0)
 13c:	cb91                	beqz	a5,150 <strcmp+0x20>
 13e:	0005c703          	lbu	a4,0(a1)
 142:	00f71763          	bne	a4,a5,150 <strcmp+0x20>
    p++, q++;
 146:	0505                	addi	a0,a0,1
 148:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 14a:	00054783          	lbu	a5,0(a0)
 14e:	fbe5                	bnez	a5,13e <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 150:	0005c503          	lbu	a0,0(a1)
}
 154:	40a7853b          	subw	a0,a5,a0
 158:	60a2                	ld	ra,8(sp)
 15a:	6402                	ld	s0,0(sp)
 15c:	0141                	addi	sp,sp,16
 15e:	8082                	ret

0000000000000160 <strlen>:

uint
strlen(const char *s)
{
 160:	1141                	addi	sp,sp,-16
 162:	e406                	sd	ra,8(sp)
 164:	e022                	sd	s0,0(sp)
 166:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 168:	00054783          	lbu	a5,0(a0)
 16c:	cf91                	beqz	a5,188 <strlen+0x28>
 16e:	00150793          	addi	a5,a0,1
 172:	86be                	mv	a3,a5
 174:	0785                	addi	a5,a5,1
 176:	fff7c703          	lbu	a4,-1(a5)
 17a:	ff65                	bnez	a4,172 <strlen+0x12>
 17c:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 180:	60a2                	ld	ra,8(sp)
 182:	6402                	ld	s0,0(sp)
 184:	0141                	addi	sp,sp,16
 186:	8082                	ret
  for(n = 0; s[n]; n++)
 188:	4501                	li	a0,0
 18a:	bfdd                	j	180 <strlen+0x20>

000000000000018c <memset>:

void*
memset(void *dst, int c, uint n)
{
 18c:	1141                	addi	sp,sp,-16
 18e:	e406                	sd	ra,8(sp)
 190:	e022                	sd	s0,0(sp)
 192:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 194:	ca19                	beqz	a2,1aa <memset+0x1e>
 196:	87aa                	mv	a5,a0
 198:	1602                	slli	a2,a2,0x20
 19a:	9201                	srli	a2,a2,0x20
 19c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1a0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1a4:	0785                	addi	a5,a5,1
 1a6:	fee79de3          	bne	a5,a4,1a0 <memset+0x14>
  }
  return dst;
}
 1aa:	60a2                	ld	ra,8(sp)
 1ac:	6402                	ld	s0,0(sp)
 1ae:	0141                	addi	sp,sp,16
 1b0:	8082                	ret

00000000000001b2 <strchr>:

char*
strchr(const char *s, char c)
{
 1b2:	1141                	addi	sp,sp,-16
 1b4:	e406                	sd	ra,8(sp)
 1b6:	e022                	sd	s0,0(sp)
 1b8:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1ba:	00054783          	lbu	a5,0(a0)
 1be:	cf81                	beqz	a5,1d6 <strchr+0x24>
    if(*s == c)
 1c0:	00f58763          	beq	a1,a5,1ce <strchr+0x1c>
  for(; *s; s++)
 1c4:	0505                	addi	a0,a0,1
 1c6:	00054783          	lbu	a5,0(a0)
 1ca:	fbfd                	bnez	a5,1c0 <strchr+0xe>
      return (char*)s;
  return 0;
 1cc:	4501                	li	a0,0
}
 1ce:	60a2                	ld	ra,8(sp)
 1d0:	6402                	ld	s0,0(sp)
 1d2:	0141                	addi	sp,sp,16
 1d4:	8082                	ret
  return 0;
 1d6:	4501                	li	a0,0
 1d8:	bfdd                	j	1ce <strchr+0x1c>

00000000000001da <gets>:

char*
gets(char *buf, int max)
{
 1da:	711d                	addi	sp,sp,-96
 1dc:	ec86                	sd	ra,88(sp)
 1de:	e8a2                	sd	s0,80(sp)
 1e0:	e4a6                	sd	s1,72(sp)
 1e2:	e0ca                	sd	s2,64(sp)
 1e4:	fc4e                	sd	s3,56(sp)
 1e6:	f852                	sd	s4,48(sp)
 1e8:	f456                	sd	s5,40(sp)
 1ea:	f05a                	sd	s6,32(sp)
 1ec:	ec5e                	sd	s7,24(sp)
 1ee:	e862                	sd	s8,16(sp)
 1f0:	1080                	addi	s0,sp,96
 1f2:	8baa                	mv	s7,a0
 1f4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1f6:	892a                	mv	s2,a0
 1f8:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1fa:	faf40b13          	addi	s6,s0,-81
 1fe:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 200:	8c26                	mv	s8,s1
 202:	0014899b          	addiw	s3,s1,1
 206:	84ce                	mv	s1,s3
 208:	0349d463          	bge	s3,s4,230 <gets+0x56>
    cc = read(0, &c, 1);
 20c:	8656                	mv	a2,s5
 20e:	85da                	mv	a1,s6
 210:	4501                	li	a0,0
 212:	1bc000ef          	jal	3ce <read>
    if(cc < 1)
 216:	00a05d63          	blez	a0,230 <gets+0x56>
      break;
    buf[i++] = c;
 21a:	faf44783          	lbu	a5,-81(s0)
 21e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 222:	0905                	addi	s2,s2,1
 224:	ff678713          	addi	a4,a5,-10
 228:	c319                	beqz	a4,22e <gets+0x54>
 22a:	17cd                	addi	a5,a5,-13
 22c:	fbf1                	bnez	a5,200 <gets+0x26>
    buf[i++] = c;
 22e:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 230:	9c5e                	add	s8,s8,s7
 232:	000c0023          	sb	zero,0(s8)
  return buf;
}
 236:	855e                	mv	a0,s7
 238:	60e6                	ld	ra,88(sp)
 23a:	6446                	ld	s0,80(sp)
 23c:	64a6                	ld	s1,72(sp)
 23e:	6906                	ld	s2,64(sp)
 240:	79e2                	ld	s3,56(sp)
 242:	7a42                	ld	s4,48(sp)
 244:	7aa2                	ld	s5,40(sp)
 246:	7b02                	ld	s6,32(sp)
 248:	6be2                	ld	s7,24(sp)
 24a:	6c42                	ld	s8,16(sp)
 24c:	6125                	addi	sp,sp,96
 24e:	8082                	ret

0000000000000250 <stat>:

int
stat(const char *n, struct stat *st)
{
 250:	1101                	addi	sp,sp,-32
 252:	ec06                	sd	ra,24(sp)
 254:	e822                	sd	s0,16(sp)
 256:	e04a                	sd	s2,0(sp)
 258:	1000                	addi	s0,sp,32
 25a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 25c:	4581                	li	a1,0
 25e:	198000ef          	jal	3f6 <open>
  if(fd < 0)
 262:	02054263          	bltz	a0,286 <stat+0x36>
 266:	e426                	sd	s1,8(sp)
 268:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 26a:	85ca                	mv	a1,s2
 26c:	1a2000ef          	jal	40e <fstat>
 270:	892a                	mv	s2,a0
  close(fd);
 272:	8526                	mv	a0,s1
 274:	16a000ef          	jal	3de <close>
  return r;
 278:	64a2                	ld	s1,8(sp)
}
 27a:	854a                	mv	a0,s2
 27c:	60e2                	ld	ra,24(sp)
 27e:	6442                	ld	s0,16(sp)
 280:	6902                	ld	s2,0(sp)
 282:	6105                	addi	sp,sp,32
 284:	8082                	ret
    return -1;
 286:	57fd                	li	a5,-1
 288:	893e                	mv	s2,a5
 28a:	bfc5                	j	27a <stat+0x2a>

000000000000028c <atoi>:

int
atoi(const char *s)
{
 28c:	1141                	addi	sp,sp,-16
 28e:	e406                	sd	ra,8(sp)
 290:	e022                	sd	s0,0(sp)
 292:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 294:	00054683          	lbu	a3,0(a0)
 298:	fd06879b          	addiw	a5,a3,-48
 29c:	0ff7f793          	zext.b	a5,a5
 2a0:	4625                	li	a2,9
 2a2:	02f66963          	bltu	a2,a5,2d4 <atoi+0x48>
 2a6:	872a                	mv	a4,a0
  n = 0;
 2a8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2aa:	0705                	addi	a4,a4,1
 2ac:	0025179b          	slliw	a5,a0,0x2
 2b0:	9fa9                	addw	a5,a5,a0
 2b2:	0017979b          	slliw	a5,a5,0x1
 2b6:	9fb5                	addw	a5,a5,a3
 2b8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2bc:	00074683          	lbu	a3,0(a4)
 2c0:	fd06879b          	addiw	a5,a3,-48
 2c4:	0ff7f793          	zext.b	a5,a5
 2c8:	fef671e3          	bgeu	a2,a5,2aa <atoi+0x1e>
  return n;
}
 2cc:	60a2                	ld	ra,8(sp)
 2ce:	6402                	ld	s0,0(sp)
 2d0:	0141                	addi	sp,sp,16
 2d2:	8082                	ret
  n = 0;
 2d4:	4501                	li	a0,0
 2d6:	bfdd                	j	2cc <atoi+0x40>

00000000000002d8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2d8:	1141                	addi	sp,sp,-16
 2da:	e406                	sd	ra,8(sp)
 2dc:	e022                	sd	s0,0(sp)
 2de:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2e0:	02b57563          	bgeu	a0,a1,30a <memmove+0x32>
    while(n-- > 0)
 2e4:	00c05f63          	blez	a2,302 <memmove+0x2a>
 2e8:	1602                	slli	a2,a2,0x20
 2ea:	9201                	srli	a2,a2,0x20
 2ec:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2f0:	872a                	mv	a4,a0
      *dst++ = *src++;
 2f2:	0585                	addi	a1,a1,1
 2f4:	0705                	addi	a4,a4,1
 2f6:	fff5c683          	lbu	a3,-1(a1)
 2fa:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2fe:	fee79ae3          	bne	a5,a4,2f2 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 302:	60a2                	ld	ra,8(sp)
 304:	6402                	ld	s0,0(sp)
 306:	0141                	addi	sp,sp,16
 308:	8082                	ret
    while(n-- > 0)
 30a:	fec05ce3          	blez	a2,302 <memmove+0x2a>
    dst += n;
 30e:	00c50733          	add	a4,a0,a2
    src += n;
 312:	95b2                	add	a1,a1,a2
 314:	fff6079b          	addiw	a5,a2,-1
 318:	1782                	slli	a5,a5,0x20
 31a:	9381                	srli	a5,a5,0x20
 31c:	fff7c793          	not	a5,a5
 320:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 322:	15fd                	addi	a1,a1,-1
 324:	177d                	addi	a4,a4,-1
 326:	0005c683          	lbu	a3,0(a1)
 32a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 32e:	fef71ae3          	bne	a4,a5,322 <memmove+0x4a>
 332:	bfc1                	j	302 <memmove+0x2a>

0000000000000334 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 334:	1141                	addi	sp,sp,-16
 336:	e406                	sd	ra,8(sp)
 338:	e022                	sd	s0,0(sp)
 33a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 33c:	c61d                	beqz	a2,36a <memcmp+0x36>
 33e:	1602                	slli	a2,a2,0x20
 340:	9201                	srli	a2,a2,0x20
 342:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 346:	00054783          	lbu	a5,0(a0)
 34a:	0005c703          	lbu	a4,0(a1)
 34e:	00e79863          	bne	a5,a4,35e <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 352:	0505                	addi	a0,a0,1
    p2++;
 354:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 356:	fed518e3          	bne	a0,a3,346 <memcmp+0x12>
  }
  return 0;
 35a:	4501                	li	a0,0
 35c:	a019                	j	362 <memcmp+0x2e>
      return *p1 - *p2;
 35e:	40e7853b          	subw	a0,a5,a4
}
 362:	60a2                	ld	ra,8(sp)
 364:	6402                	ld	s0,0(sp)
 366:	0141                	addi	sp,sp,16
 368:	8082                	ret
  return 0;
 36a:	4501                	li	a0,0
 36c:	bfdd                	j	362 <memcmp+0x2e>

000000000000036e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 36e:	1141                	addi	sp,sp,-16
 370:	e406                	sd	ra,8(sp)
 372:	e022                	sd	s0,0(sp)
 374:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 376:	f63ff0ef          	jal	2d8 <memmove>
}
 37a:	60a2                	ld	ra,8(sp)
 37c:	6402                	ld	s0,0(sp)
 37e:	0141                	addi	sp,sp,16
 380:	8082                	ret

0000000000000382 <sbrk>:

char *
sbrk(int n) {
 382:	1141                	addi	sp,sp,-16
 384:	e406                	sd	ra,8(sp)
 386:	e022                	sd	s0,0(sp)
 388:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 38a:	4585                	li	a1,1
 38c:	0b2000ef          	jal	43e <sys_sbrk>
}
 390:	60a2                	ld	ra,8(sp)
 392:	6402                	ld	s0,0(sp)
 394:	0141                	addi	sp,sp,16
 396:	8082                	ret

0000000000000398 <sbrklazy>:

char *
sbrklazy(int n) {
 398:	1141                	addi	sp,sp,-16
 39a:	e406                	sd	ra,8(sp)
 39c:	e022                	sd	s0,0(sp)
 39e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3a0:	4589                	li	a1,2
 3a2:	09c000ef          	jal	43e <sys_sbrk>
}
 3a6:	60a2                	ld	ra,8(sp)
 3a8:	6402                	ld	s0,0(sp)
 3aa:	0141                	addi	sp,sp,16
 3ac:	8082                	ret

00000000000003ae <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3ae:	4885                	li	a7,1
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3b6:	4889                	li	a7,2
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <wait>:
.global wait
wait:
 li a7, SYS_wait
 3be:	488d                	li	a7,3
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3c6:	4891                	li	a7,4
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <read>:
.global read
read:
 li a7, SYS_read
 3ce:	4895                	li	a7,5
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <write>:
.global write
write:
 li a7, SYS_write
 3d6:	48c1                	li	a7,16
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <close>:
.global close
close:
 li a7, SYS_close
 3de:	48d5                	li	a7,21
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3e6:	4899                	li	a7,6
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <exec>:
.global exec
exec:
 li a7, SYS_exec
 3ee:	489d                	li	a7,7
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <open>:
.global open
open:
 li a7, SYS_open
 3f6:	48bd                	li	a7,15
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3fe:	48c5                	li	a7,17
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 406:	48c9                	li	a7,18
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 40e:	48a1                	li	a7,8
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <link>:
.global link
link:
 li a7, SYS_link
 416:	48cd                	li	a7,19
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 41e:	48d1                	li	a7,20
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 426:	48a5                	li	a7,9
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <dup>:
.global dup
dup:
 li a7, SYS_dup
 42e:	48a9                	li	a7,10
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 436:	48ad                	li	a7,11
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 43e:	48b1                	li	a7,12
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <pause>:
.global pause
pause:
 li a7, SYS_pause
 446:	48b5                	li	a7,13
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 44e:	48b9                	li	a7,14
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <memstat>:
.global memstat
memstat:
 li a7, SYS_memstat
 456:	48d9                	li	a7,22
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <enable_bonus>:
.global enable_bonus
enable_bonus:
 li a7, SYS_enable_bonus
 45e:	48dd                	li	a7,23
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 466:	1101                	addi	sp,sp,-32
 468:	ec06                	sd	ra,24(sp)
 46a:	e822                	sd	s0,16(sp)
 46c:	1000                	addi	s0,sp,32
 46e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 472:	4605                	li	a2,1
 474:	fef40593          	addi	a1,s0,-17
 478:	f5fff0ef          	jal	3d6 <write>
}
 47c:	60e2                	ld	ra,24(sp)
 47e:	6442                	ld	s0,16(sp)
 480:	6105                	addi	sp,sp,32
 482:	8082                	ret

0000000000000484 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 484:	715d                	addi	sp,sp,-80
 486:	e486                	sd	ra,72(sp)
 488:	e0a2                	sd	s0,64(sp)
 48a:	f84a                	sd	s2,48(sp)
 48c:	f44e                	sd	s3,40(sp)
 48e:	0880                	addi	s0,sp,80
 490:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 492:	c6d1                	beqz	a3,51e <printint+0x9a>
 494:	0805d563          	bgez	a1,51e <printint+0x9a>
    neg = 1;
    x = -xx;
 498:	40b005b3          	neg	a1,a1
    neg = 1;
 49c:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 49e:	fb840993          	addi	s3,s0,-72
  neg = 0;
 4a2:	86ce                	mv	a3,s3
  i = 0;
 4a4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4a6:	00000817          	auipc	a6,0x0
 4aa:	66280813          	addi	a6,a6,1634 # b08 <digits>
 4ae:	88ba                	mv	a7,a4
 4b0:	0017051b          	addiw	a0,a4,1
 4b4:	872a                	mv	a4,a0
 4b6:	02c5f7b3          	remu	a5,a1,a2
 4ba:	97c2                	add	a5,a5,a6
 4bc:	0007c783          	lbu	a5,0(a5)
 4c0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4c4:	87ae                	mv	a5,a1
 4c6:	02c5d5b3          	divu	a1,a1,a2
 4ca:	0685                	addi	a3,a3,1
 4cc:	fec7f1e3          	bgeu	a5,a2,4ae <printint+0x2a>
  if(neg)
 4d0:	00030c63          	beqz	t1,4e8 <printint+0x64>
    buf[i++] = '-';
 4d4:	fd050793          	addi	a5,a0,-48
 4d8:	00878533          	add	a0,a5,s0
 4dc:	02d00793          	li	a5,45
 4e0:	fef50423          	sb	a5,-24(a0)
 4e4:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 4e8:	02e05563          	blez	a4,512 <printint+0x8e>
 4ec:	fc26                	sd	s1,56(sp)
 4ee:	377d                	addiw	a4,a4,-1
 4f0:	00e984b3          	add	s1,s3,a4
 4f4:	19fd                	addi	s3,s3,-1 # fff <digits+0x4f7>
 4f6:	99ba                	add	s3,s3,a4
 4f8:	1702                	slli	a4,a4,0x20
 4fa:	9301                	srli	a4,a4,0x20
 4fc:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 500:	0004c583          	lbu	a1,0(s1)
 504:	854a                	mv	a0,s2
 506:	f61ff0ef          	jal	466 <putc>
  while(--i >= 0)
 50a:	14fd                	addi	s1,s1,-1
 50c:	ff349ae3          	bne	s1,s3,500 <printint+0x7c>
 510:	74e2                	ld	s1,56(sp)
}
 512:	60a6                	ld	ra,72(sp)
 514:	6406                	ld	s0,64(sp)
 516:	7942                	ld	s2,48(sp)
 518:	79a2                	ld	s3,40(sp)
 51a:	6161                	addi	sp,sp,80
 51c:	8082                	ret
  neg = 0;
 51e:	4301                	li	t1,0
 520:	bfbd                	j	49e <printint+0x1a>

0000000000000522 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 522:	711d                	addi	sp,sp,-96
 524:	ec86                	sd	ra,88(sp)
 526:	e8a2                	sd	s0,80(sp)
 528:	e4a6                	sd	s1,72(sp)
 52a:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 52c:	0005c483          	lbu	s1,0(a1)
 530:	22048363          	beqz	s1,756 <vprintf+0x234>
 534:	e0ca                	sd	s2,64(sp)
 536:	fc4e                	sd	s3,56(sp)
 538:	f852                	sd	s4,48(sp)
 53a:	f456                	sd	s5,40(sp)
 53c:	f05a                	sd	s6,32(sp)
 53e:	ec5e                	sd	s7,24(sp)
 540:	e862                	sd	s8,16(sp)
 542:	8b2a                	mv	s6,a0
 544:	8a2e                	mv	s4,a1
 546:	8bb2                	mv	s7,a2
  state = 0;
 548:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 54a:	4901                	li	s2,0
 54c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 54e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 552:	06400c13          	li	s8,100
 556:	a00d                	j	578 <vprintf+0x56>
        putc(fd, c0);
 558:	85a6                	mv	a1,s1
 55a:	855a                	mv	a0,s6
 55c:	f0bff0ef          	jal	466 <putc>
 560:	a019                	j	566 <vprintf+0x44>
    } else if(state == '%'){
 562:	03598363          	beq	s3,s5,588 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 566:	0019079b          	addiw	a5,s2,1
 56a:	893e                	mv	s2,a5
 56c:	873e                	mv	a4,a5
 56e:	97d2                	add	a5,a5,s4
 570:	0007c483          	lbu	s1,0(a5)
 574:	1c048a63          	beqz	s1,748 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 578:	0004879b          	sext.w	a5,s1
    if(state == 0){
 57c:	fe0993e3          	bnez	s3,562 <vprintf+0x40>
      if(c0 == '%'){
 580:	fd579ce3          	bne	a5,s5,558 <vprintf+0x36>
        state = '%';
 584:	89be                	mv	s3,a5
 586:	b7c5                	j	566 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 588:	00ea06b3          	add	a3,s4,a4
 58c:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 590:	1c060863          	beqz	a2,760 <vprintf+0x23e>
      if(c0 == 'd'){
 594:	03878763          	beq	a5,s8,5c2 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 598:	f9478693          	addi	a3,a5,-108
 59c:	0016b693          	seqz	a3,a3
 5a0:	f9c60593          	addi	a1,a2,-100
 5a4:	e99d                	bnez	a1,5da <vprintf+0xb8>
 5a6:	ca95                	beqz	a3,5da <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5a8:	008b8493          	addi	s1,s7,8
 5ac:	4685                	li	a3,1
 5ae:	4629                	li	a2,10
 5b0:	000bb583          	ld	a1,0(s7)
 5b4:	855a                	mv	a0,s6
 5b6:	ecfff0ef          	jal	484 <printint>
        i += 1;
 5ba:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5bc:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5be:	4981                	li	s3,0
 5c0:	b75d                	j	566 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 5c2:	008b8493          	addi	s1,s7,8
 5c6:	4685                	li	a3,1
 5c8:	4629                	li	a2,10
 5ca:	000ba583          	lw	a1,0(s7)
 5ce:	855a                	mv	a0,s6
 5d0:	eb5ff0ef          	jal	484 <printint>
 5d4:	8ba6                	mv	s7,s1
      state = 0;
 5d6:	4981                	li	s3,0
 5d8:	b779                	j	566 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 5da:	9752                	add	a4,a4,s4
 5dc:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5e0:	f9460713          	addi	a4,a2,-108
 5e4:	00173713          	seqz	a4,a4
 5e8:	8f75                	and	a4,a4,a3
 5ea:	f9c58513          	addi	a0,a1,-100
 5ee:	18051363          	bnez	a0,774 <vprintf+0x252>
 5f2:	18070163          	beqz	a4,774 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5f6:	008b8493          	addi	s1,s7,8
 5fa:	4685                	li	a3,1
 5fc:	4629                	li	a2,10
 5fe:	000bb583          	ld	a1,0(s7)
 602:	855a                	mv	a0,s6
 604:	e81ff0ef          	jal	484 <printint>
        i += 2;
 608:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 60a:	8ba6                	mv	s7,s1
      state = 0;
 60c:	4981                	li	s3,0
        i += 2;
 60e:	bfa1                	j	566 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 610:	008b8493          	addi	s1,s7,8
 614:	4681                	li	a3,0
 616:	4629                	li	a2,10
 618:	000be583          	lwu	a1,0(s7)
 61c:	855a                	mv	a0,s6
 61e:	e67ff0ef          	jal	484 <printint>
 622:	8ba6                	mv	s7,s1
      state = 0;
 624:	4981                	li	s3,0
 626:	b781                	j	566 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 628:	008b8493          	addi	s1,s7,8
 62c:	4681                	li	a3,0
 62e:	4629                	li	a2,10
 630:	000bb583          	ld	a1,0(s7)
 634:	855a                	mv	a0,s6
 636:	e4fff0ef          	jal	484 <printint>
        i += 1;
 63a:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 63c:	8ba6                	mv	s7,s1
      state = 0;
 63e:	4981                	li	s3,0
 640:	b71d                	j	566 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 642:	008b8493          	addi	s1,s7,8
 646:	4681                	li	a3,0
 648:	4629                	li	a2,10
 64a:	000bb583          	ld	a1,0(s7)
 64e:	855a                	mv	a0,s6
 650:	e35ff0ef          	jal	484 <printint>
        i += 2;
 654:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 656:	8ba6                	mv	s7,s1
      state = 0;
 658:	4981                	li	s3,0
        i += 2;
 65a:	b731                	j	566 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 65c:	008b8493          	addi	s1,s7,8
 660:	4681                	li	a3,0
 662:	4641                	li	a2,16
 664:	000be583          	lwu	a1,0(s7)
 668:	855a                	mv	a0,s6
 66a:	e1bff0ef          	jal	484 <printint>
 66e:	8ba6                	mv	s7,s1
      state = 0;
 670:	4981                	li	s3,0
 672:	bdd5                	j	566 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 674:	008b8493          	addi	s1,s7,8
 678:	4681                	li	a3,0
 67a:	4641                	li	a2,16
 67c:	000bb583          	ld	a1,0(s7)
 680:	855a                	mv	a0,s6
 682:	e03ff0ef          	jal	484 <printint>
        i += 1;
 686:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 688:	8ba6                	mv	s7,s1
      state = 0;
 68a:	4981                	li	s3,0
 68c:	bde9                	j	566 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 68e:	008b8493          	addi	s1,s7,8
 692:	4681                	li	a3,0
 694:	4641                	li	a2,16
 696:	000bb583          	ld	a1,0(s7)
 69a:	855a                	mv	a0,s6
 69c:	de9ff0ef          	jal	484 <printint>
        i += 2;
 6a0:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a2:	8ba6                	mv	s7,s1
      state = 0;
 6a4:	4981                	li	s3,0
        i += 2;
 6a6:	b5c1                	j	566 <vprintf+0x44>
 6a8:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 6aa:	008b8793          	addi	a5,s7,8
 6ae:	8cbe                	mv	s9,a5
 6b0:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6b4:	03000593          	li	a1,48
 6b8:	855a                	mv	a0,s6
 6ba:	dadff0ef          	jal	466 <putc>
  putc(fd, 'x');
 6be:	07800593          	li	a1,120
 6c2:	855a                	mv	a0,s6
 6c4:	da3ff0ef          	jal	466 <putc>
 6c8:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ca:	00000b97          	auipc	s7,0x0
 6ce:	43eb8b93          	addi	s7,s7,1086 # b08 <digits>
 6d2:	03c9d793          	srli	a5,s3,0x3c
 6d6:	97de                	add	a5,a5,s7
 6d8:	0007c583          	lbu	a1,0(a5)
 6dc:	855a                	mv	a0,s6
 6de:	d89ff0ef          	jal	466 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6e2:	0992                	slli	s3,s3,0x4
 6e4:	34fd                	addiw	s1,s1,-1
 6e6:	f4f5                	bnez	s1,6d2 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 6e8:	8be6                	mv	s7,s9
      state = 0;
 6ea:	4981                	li	s3,0
 6ec:	6ca2                	ld	s9,8(sp)
 6ee:	bda5                	j	566 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 6f0:	008b8493          	addi	s1,s7,8
 6f4:	000bc583          	lbu	a1,0(s7)
 6f8:	855a                	mv	a0,s6
 6fa:	d6dff0ef          	jal	466 <putc>
 6fe:	8ba6                	mv	s7,s1
      state = 0;
 700:	4981                	li	s3,0
 702:	b595                	j	566 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 704:	008b8993          	addi	s3,s7,8
 708:	000bb483          	ld	s1,0(s7)
 70c:	cc91                	beqz	s1,728 <vprintf+0x206>
        for(; *s; s++)
 70e:	0004c583          	lbu	a1,0(s1)
 712:	c985                	beqz	a1,742 <vprintf+0x220>
          putc(fd, *s);
 714:	855a                	mv	a0,s6
 716:	d51ff0ef          	jal	466 <putc>
        for(; *s; s++)
 71a:	0485                	addi	s1,s1,1
 71c:	0004c583          	lbu	a1,0(s1)
 720:	f9f5                	bnez	a1,714 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 722:	8bce                	mv	s7,s3
      state = 0;
 724:	4981                	li	s3,0
 726:	b581                	j	566 <vprintf+0x44>
          s = "(null)";
 728:	00000497          	auipc	s1,0x0
 72c:	3d848493          	addi	s1,s1,984 # b00 <malloc+0x23c>
        for(; *s; s++)
 730:	02800593          	li	a1,40
 734:	b7c5                	j	714 <vprintf+0x1f2>
        putc(fd, '%');
 736:	85be                	mv	a1,a5
 738:	855a                	mv	a0,s6
 73a:	d2dff0ef          	jal	466 <putc>
      state = 0;
 73e:	4981                	li	s3,0
 740:	b51d                	j	566 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 742:	8bce                	mv	s7,s3
      state = 0;
 744:	4981                	li	s3,0
 746:	b505                	j	566 <vprintf+0x44>
 748:	6906                	ld	s2,64(sp)
 74a:	79e2                	ld	s3,56(sp)
 74c:	7a42                	ld	s4,48(sp)
 74e:	7aa2                	ld	s5,40(sp)
 750:	7b02                	ld	s6,32(sp)
 752:	6be2                	ld	s7,24(sp)
 754:	6c42                	ld	s8,16(sp)
    }
  }
}
 756:	60e6                	ld	ra,88(sp)
 758:	6446                	ld	s0,80(sp)
 75a:	64a6                	ld	s1,72(sp)
 75c:	6125                	addi	sp,sp,96
 75e:	8082                	ret
      if(c0 == 'd'){
 760:	06400713          	li	a4,100
 764:	e4e78fe3          	beq	a5,a4,5c2 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 768:	f9478693          	addi	a3,a5,-108
 76c:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 770:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 772:	4701                	li	a4,0
      } else if(c0 == 'u'){
 774:	07500513          	li	a0,117
 778:	e8a78ce3          	beq	a5,a0,610 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 77c:	f8b60513          	addi	a0,a2,-117
 780:	e119                	bnez	a0,786 <vprintf+0x264>
 782:	ea0693e3          	bnez	a3,628 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 786:	f8b58513          	addi	a0,a1,-117
 78a:	e119                	bnez	a0,790 <vprintf+0x26e>
 78c:	ea071be3          	bnez	a4,642 <vprintf+0x120>
      } else if(c0 == 'x'){
 790:	07800513          	li	a0,120
 794:	eca784e3          	beq	a5,a0,65c <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 798:	f8860613          	addi	a2,a2,-120
 79c:	e219                	bnez	a2,7a2 <vprintf+0x280>
 79e:	ec069be3          	bnez	a3,674 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7a2:	f8858593          	addi	a1,a1,-120
 7a6:	e199                	bnez	a1,7ac <vprintf+0x28a>
 7a8:	ee0713e3          	bnez	a4,68e <vprintf+0x16c>
      } else if(c0 == 'p'){
 7ac:	07000713          	li	a4,112
 7b0:	eee78ce3          	beq	a5,a4,6a8 <vprintf+0x186>
      } else if(c0 == 'c'){
 7b4:	06300713          	li	a4,99
 7b8:	f2e78ce3          	beq	a5,a4,6f0 <vprintf+0x1ce>
      } else if(c0 == 's'){
 7bc:	07300713          	li	a4,115
 7c0:	f4e782e3          	beq	a5,a4,704 <vprintf+0x1e2>
      } else if(c0 == '%'){
 7c4:	02500713          	li	a4,37
 7c8:	f6e787e3          	beq	a5,a4,736 <vprintf+0x214>
        putc(fd, '%');
 7cc:	02500593          	li	a1,37
 7d0:	855a                	mv	a0,s6
 7d2:	c95ff0ef          	jal	466 <putc>
        putc(fd, c0);
 7d6:	85a6                	mv	a1,s1
 7d8:	855a                	mv	a0,s6
 7da:	c8dff0ef          	jal	466 <putc>
      state = 0;
 7de:	4981                	li	s3,0
 7e0:	b359                	j	566 <vprintf+0x44>

00000000000007e2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7e2:	715d                	addi	sp,sp,-80
 7e4:	ec06                	sd	ra,24(sp)
 7e6:	e822                	sd	s0,16(sp)
 7e8:	1000                	addi	s0,sp,32
 7ea:	e010                	sd	a2,0(s0)
 7ec:	e414                	sd	a3,8(s0)
 7ee:	e818                	sd	a4,16(s0)
 7f0:	ec1c                	sd	a5,24(s0)
 7f2:	03043023          	sd	a6,32(s0)
 7f6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7fa:	8622                	mv	a2,s0
 7fc:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 800:	d23ff0ef          	jal	522 <vprintf>
}
 804:	60e2                	ld	ra,24(sp)
 806:	6442                	ld	s0,16(sp)
 808:	6161                	addi	sp,sp,80
 80a:	8082                	ret

000000000000080c <printf>:

void
printf(const char *fmt, ...)
{
 80c:	711d                	addi	sp,sp,-96
 80e:	ec06                	sd	ra,24(sp)
 810:	e822                	sd	s0,16(sp)
 812:	1000                	addi	s0,sp,32
 814:	e40c                	sd	a1,8(s0)
 816:	e810                	sd	a2,16(s0)
 818:	ec14                	sd	a3,24(s0)
 81a:	f018                	sd	a4,32(s0)
 81c:	f41c                	sd	a5,40(s0)
 81e:	03043823          	sd	a6,48(s0)
 822:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 826:	00840613          	addi	a2,s0,8
 82a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 82e:	85aa                	mv	a1,a0
 830:	4505                	li	a0,1
 832:	cf1ff0ef          	jal	522 <vprintf>
}
 836:	60e2                	ld	ra,24(sp)
 838:	6442                	ld	s0,16(sp)
 83a:	6125                	addi	sp,sp,96
 83c:	8082                	ret

000000000000083e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 83e:	1141                	addi	sp,sp,-16
 840:	e406                	sd	ra,8(sp)
 842:	e022                	sd	s0,0(sp)
 844:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 846:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 84a:	00000797          	auipc	a5,0x0
 84e:	7b67b783          	ld	a5,1974(a5) # 1000 <freep>
 852:	a039                	j	860 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 854:	6398                	ld	a4,0(a5)
 856:	00e7e463          	bltu	a5,a4,85e <free+0x20>
 85a:	00e6ea63          	bltu	a3,a4,86e <free+0x30>
{
 85e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 860:	fed7fae3          	bgeu	a5,a3,854 <free+0x16>
 864:	6398                	ld	a4,0(a5)
 866:	00e6e463          	bltu	a3,a4,86e <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 86a:	fee7eae3          	bltu	a5,a4,85e <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 86e:	ff852583          	lw	a1,-8(a0)
 872:	6390                	ld	a2,0(a5)
 874:	02059813          	slli	a6,a1,0x20
 878:	01c85713          	srli	a4,a6,0x1c
 87c:	9736                	add	a4,a4,a3
 87e:	02e60563          	beq	a2,a4,8a8 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 882:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 886:	4790                	lw	a2,8(a5)
 888:	02061593          	slli	a1,a2,0x20
 88c:	01c5d713          	srli	a4,a1,0x1c
 890:	973e                	add	a4,a4,a5
 892:	02e68263          	beq	a3,a4,8b6 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 896:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 898:	00000717          	auipc	a4,0x0
 89c:	76f73423          	sd	a5,1896(a4) # 1000 <freep>
}
 8a0:	60a2                	ld	ra,8(sp)
 8a2:	6402                	ld	s0,0(sp)
 8a4:	0141                	addi	sp,sp,16
 8a6:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 8a8:	4618                	lw	a4,8(a2)
 8aa:	9f2d                	addw	a4,a4,a1
 8ac:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8b0:	6398                	ld	a4,0(a5)
 8b2:	6310                	ld	a2,0(a4)
 8b4:	b7f9                	j	882 <free+0x44>
    p->s.size += bp->s.size;
 8b6:	ff852703          	lw	a4,-8(a0)
 8ba:	9f31                	addw	a4,a4,a2
 8bc:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8be:	ff053683          	ld	a3,-16(a0)
 8c2:	bfd1                	j	896 <free+0x58>

00000000000008c4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8c4:	7139                	addi	sp,sp,-64
 8c6:	fc06                	sd	ra,56(sp)
 8c8:	f822                	sd	s0,48(sp)
 8ca:	f04a                	sd	s2,32(sp)
 8cc:	ec4e                	sd	s3,24(sp)
 8ce:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8d0:	02051993          	slli	s3,a0,0x20
 8d4:	0209d993          	srli	s3,s3,0x20
 8d8:	09bd                	addi	s3,s3,15
 8da:	0049d993          	srli	s3,s3,0x4
 8de:	2985                	addiw	s3,s3,1
 8e0:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 8e2:	00000517          	auipc	a0,0x0
 8e6:	71e53503          	ld	a0,1822(a0) # 1000 <freep>
 8ea:	c905                	beqz	a0,91a <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ec:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ee:	4798                	lw	a4,8(a5)
 8f0:	09377663          	bgeu	a4,s3,97c <malloc+0xb8>
 8f4:	f426                	sd	s1,40(sp)
 8f6:	e852                	sd	s4,16(sp)
 8f8:	e456                	sd	s5,8(sp)
 8fa:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8fc:	8a4e                	mv	s4,s3
 8fe:	6705                	lui	a4,0x1
 900:	00e9f363          	bgeu	s3,a4,906 <malloc+0x42>
 904:	6a05                	lui	s4,0x1
 906:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 90a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 90e:	00000497          	auipc	s1,0x0
 912:	6f248493          	addi	s1,s1,1778 # 1000 <freep>
  if(p == SBRK_ERROR)
 916:	5afd                	li	s5,-1
 918:	a83d                	j	956 <malloc+0x92>
 91a:	f426                	sd	s1,40(sp)
 91c:	e852                	sd	s4,16(sp)
 91e:	e456                	sd	s5,8(sp)
 920:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 922:	00000797          	auipc	a5,0x0
 926:	6ee78793          	addi	a5,a5,1774 # 1010 <base>
 92a:	00000717          	auipc	a4,0x0
 92e:	6cf73b23          	sd	a5,1750(a4) # 1000 <freep>
 932:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 934:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 938:	b7d1                	j	8fc <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 93a:	6398                	ld	a4,0(a5)
 93c:	e118                	sd	a4,0(a0)
 93e:	a899                	j	994 <malloc+0xd0>
  hp->s.size = nu;
 940:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 944:	0541                	addi	a0,a0,16
 946:	ef9ff0ef          	jal	83e <free>
  return freep;
 94a:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 94c:	c125                	beqz	a0,9ac <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 94e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 950:	4798                	lw	a4,8(a5)
 952:	03277163          	bgeu	a4,s2,974 <malloc+0xb0>
    if(p == freep)
 956:	6098                	ld	a4,0(s1)
 958:	853e                	mv	a0,a5
 95a:	fef71ae3          	bne	a4,a5,94e <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 95e:	8552                	mv	a0,s4
 960:	a23ff0ef          	jal	382 <sbrk>
  if(p == SBRK_ERROR)
 964:	fd551ee3          	bne	a0,s5,940 <malloc+0x7c>
        return 0;
 968:	4501                	li	a0,0
 96a:	74a2                	ld	s1,40(sp)
 96c:	6a42                	ld	s4,16(sp)
 96e:	6aa2                	ld	s5,8(sp)
 970:	6b02                	ld	s6,0(sp)
 972:	a03d                	j	9a0 <malloc+0xdc>
 974:	74a2                	ld	s1,40(sp)
 976:	6a42                	ld	s4,16(sp)
 978:	6aa2                	ld	s5,8(sp)
 97a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 97c:	fae90fe3          	beq	s2,a4,93a <malloc+0x76>
        p->s.size -= nunits;
 980:	4137073b          	subw	a4,a4,s3
 984:	c798                	sw	a4,8(a5)
        p += p->s.size;
 986:	02071693          	slli	a3,a4,0x20
 98a:	01c6d713          	srli	a4,a3,0x1c
 98e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 990:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 994:	00000717          	auipc	a4,0x0
 998:	66a73623          	sd	a0,1644(a4) # 1000 <freep>
      return (void*)(p + 1);
 99c:	01078513          	addi	a0,a5,16
  }
}
 9a0:	70e2                	ld	ra,56(sp)
 9a2:	7442                	ld	s0,48(sp)
 9a4:	7902                	ld	s2,32(sp)
 9a6:	69e2                	ld	s3,24(sp)
 9a8:	6121                	addi	sp,sp,64
 9aa:	8082                	ret
 9ac:	74a2                	ld	s1,40(sp)
 9ae:	6a42                	ld	s4,16(sp)
 9b0:	6aa2                	ld	s5,8(sp)
 9b2:	6b02                	ld	s6,0(sp)
 9b4:	b7f5                	j	9a0 <malloc+0xdc>
