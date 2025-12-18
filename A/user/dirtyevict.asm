
user/_dirtyevict:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

#define PAGES 70

int main() {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  printf("Dirty eviction test starting\n");
   8:	00001517          	auipc	a0,0x1
   c:	8f850513          	addi	a0,a0,-1800 # 900 <malloc+0xfa>
  10:	73e000ef          	jal	74e <printf>
  char *a = sbrk(PAGES * 4096);
  14:	00046537          	lui	a0,0x46
  18:	2ac000ef          	jal	2c4 <sbrk>
  for(int i = 0; i < PAGES; i++) {      // write to all pages
  1c:	4781                	li	a5,0
  1e:	6685                	lui	a3,0x1
  20:	04600713          	li	a4,70
    a[i * 4096] = i;
  24:	00f50023          	sb	a5,0(a0) # 46000 <base+0x44ff0>
  for(int i = 0; i < PAGES; i++) {      // write to all pages
  28:	2785                	addiw	a5,a5,1
  2a:	9536                	add	a0,a0,a3
  2c:	fee79ce3          	bne	a5,a4,24 <main+0x24>
  }
  printf("Dirty eviction test done\n");
  30:	00001517          	auipc	a0,0x1
  34:	8f050513          	addi	a0,a0,-1808 # 920 <malloc+0x11a>
  38:	716000ef          	jal	74e <printf>
  exit(0);
  3c:	4501                	li	a0,0
  3e:	2ba000ef          	jal	2f8 <exit>

0000000000000042 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  42:	1141                	addi	sp,sp,-16
  44:	e406                	sd	ra,8(sp)
  46:	e022                	sd	s0,0(sp)
  48:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  4a:	fb7ff0ef          	jal	0 <main>
  exit(r);
  4e:	2aa000ef          	jal	2f8 <exit>

0000000000000052 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  52:	1141                	addi	sp,sp,-16
  54:	e406                	sd	ra,8(sp)
  56:	e022                	sd	s0,0(sp)
  58:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  5a:	87aa                	mv	a5,a0
  5c:	0585                	addi	a1,a1,1
  5e:	0785                	addi	a5,a5,1
  60:	fff5c703          	lbu	a4,-1(a1)
  64:	fee78fa3          	sb	a4,-1(a5)
  68:	fb75                	bnez	a4,5c <strcpy+0xa>
    ;
  return os;
}
  6a:	60a2                	ld	ra,8(sp)
  6c:	6402                	ld	s0,0(sp)
  6e:	0141                	addi	sp,sp,16
  70:	8082                	ret

0000000000000072 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  72:	1141                	addi	sp,sp,-16
  74:	e406                	sd	ra,8(sp)
  76:	e022                	sd	s0,0(sp)
  78:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  7a:	00054783          	lbu	a5,0(a0)
  7e:	cb91                	beqz	a5,92 <strcmp+0x20>
  80:	0005c703          	lbu	a4,0(a1)
  84:	00f71763          	bne	a4,a5,92 <strcmp+0x20>
    p++, q++;
  88:	0505                	addi	a0,a0,1
  8a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  8c:	00054783          	lbu	a5,0(a0)
  90:	fbe5                	bnez	a5,80 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  92:	0005c503          	lbu	a0,0(a1)
}
  96:	40a7853b          	subw	a0,a5,a0
  9a:	60a2                	ld	ra,8(sp)
  9c:	6402                	ld	s0,0(sp)
  9e:	0141                	addi	sp,sp,16
  a0:	8082                	ret

00000000000000a2 <strlen>:

uint
strlen(const char *s)
{
  a2:	1141                	addi	sp,sp,-16
  a4:	e406                	sd	ra,8(sp)
  a6:	e022                	sd	s0,0(sp)
  a8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  aa:	00054783          	lbu	a5,0(a0)
  ae:	cf91                	beqz	a5,ca <strlen+0x28>
  b0:	00150793          	addi	a5,a0,1
  b4:	86be                	mv	a3,a5
  b6:	0785                	addi	a5,a5,1
  b8:	fff7c703          	lbu	a4,-1(a5)
  bc:	ff65                	bnez	a4,b4 <strlen+0x12>
  be:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
  c2:	60a2                	ld	ra,8(sp)
  c4:	6402                	ld	s0,0(sp)
  c6:	0141                	addi	sp,sp,16
  c8:	8082                	ret
  for(n = 0; s[n]; n++)
  ca:	4501                	li	a0,0
  cc:	bfdd                	j	c2 <strlen+0x20>

00000000000000ce <memset>:

void*
memset(void *dst, int c, uint n)
{
  ce:	1141                	addi	sp,sp,-16
  d0:	e406                	sd	ra,8(sp)
  d2:	e022                	sd	s0,0(sp)
  d4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  d6:	ca19                	beqz	a2,ec <memset+0x1e>
  d8:	87aa                	mv	a5,a0
  da:	1602                	slli	a2,a2,0x20
  dc:	9201                	srli	a2,a2,0x20
  de:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  e2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  e6:	0785                	addi	a5,a5,1
  e8:	fee79de3          	bne	a5,a4,e2 <memset+0x14>
  }
  return dst;
}
  ec:	60a2                	ld	ra,8(sp)
  ee:	6402                	ld	s0,0(sp)
  f0:	0141                	addi	sp,sp,16
  f2:	8082                	ret

00000000000000f4 <strchr>:

char*
strchr(const char *s, char c)
{
  f4:	1141                	addi	sp,sp,-16
  f6:	e406                	sd	ra,8(sp)
  f8:	e022                	sd	s0,0(sp)
  fa:	0800                	addi	s0,sp,16
  for(; *s; s++)
  fc:	00054783          	lbu	a5,0(a0)
 100:	cf81                	beqz	a5,118 <strchr+0x24>
    if(*s == c)
 102:	00f58763          	beq	a1,a5,110 <strchr+0x1c>
  for(; *s; s++)
 106:	0505                	addi	a0,a0,1
 108:	00054783          	lbu	a5,0(a0)
 10c:	fbfd                	bnez	a5,102 <strchr+0xe>
      return (char*)s;
  return 0;
 10e:	4501                	li	a0,0
}
 110:	60a2                	ld	ra,8(sp)
 112:	6402                	ld	s0,0(sp)
 114:	0141                	addi	sp,sp,16
 116:	8082                	ret
  return 0;
 118:	4501                	li	a0,0
 11a:	bfdd                	j	110 <strchr+0x1c>

000000000000011c <gets>:

char*
gets(char *buf, int max)
{
 11c:	711d                	addi	sp,sp,-96
 11e:	ec86                	sd	ra,88(sp)
 120:	e8a2                	sd	s0,80(sp)
 122:	e4a6                	sd	s1,72(sp)
 124:	e0ca                	sd	s2,64(sp)
 126:	fc4e                	sd	s3,56(sp)
 128:	f852                	sd	s4,48(sp)
 12a:	f456                	sd	s5,40(sp)
 12c:	f05a                	sd	s6,32(sp)
 12e:	ec5e                	sd	s7,24(sp)
 130:	e862                	sd	s8,16(sp)
 132:	1080                	addi	s0,sp,96
 134:	8baa                	mv	s7,a0
 136:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 138:	892a                	mv	s2,a0
 13a:	4481                	li	s1,0
    cc = read(0, &c, 1);
 13c:	faf40b13          	addi	s6,s0,-81
 140:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 142:	8c26                	mv	s8,s1
 144:	0014899b          	addiw	s3,s1,1
 148:	84ce                	mv	s1,s3
 14a:	0349d463          	bge	s3,s4,172 <gets+0x56>
    cc = read(0, &c, 1);
 14e:	8656                	mv	a2,s5
 150:	85da                	mv	a1,s6
 152:	4501                	li	a0,0
 154:	1bc000ef          	jal	310 <read>
    if(cc < 1)
 158:	00a05d63          	blez	a0,172 <gets+0x56>
      break;
    buf[i++] = c;
 15c:	faf44783          	lbu	a5,-81(s0)
 160:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 164:	0905                	addi	s2,s2,1
 166:	ff678713          	addi	a4,a5,-10
 16a:	c319                	beqz	a4,170 <gets+0x54>
 16c:	17cd                	addi	a5,a5,-13
 16e:	fbf1                	bnez	a5,142 <gets+0x26>
    buf[i++] = c;
 170:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 172:	9c5e                	add	s8,s8,s7
 174:	000c0023          	sb	zero,0(s8)
  return buf;
}
 178:	855e                	mv	a0,s7
 17a:	60e6                	ld	ra,88(sp)
 17c:	6446                	ld	s0,80(sp)
 17e:	64a6                	ld	s1,72(sp)
 180:	6906                	ld	s2,64(sp)
 182:	79e2                	ld	s3,56(sp)
 184:	7a42                	ld	s4,48(sp)
 186:	7aa2                	ld	s5,40(sp)
 188:	7b02                	ld	s6,32(sp)
 18a:	6be2                	ld	s7,24(sp)
 18c:	6c42                	ld	s8,16(sp)
 18e:	6125                	addi	sp,sp,96
 190:	8082                	ret

0000000000000192 <stat>:

int
stat(const char *n, struct stat *st)
{
 192:	1101                	addi	sp,sp,-32
 194:	ec06                	sd	ra,24(sp)
 196:	e822                	sd	s0,16(sp)
 198:	e04a                	sd	s2,0(sp)
 19a:	1000                	addi	s0,sp,32
 19c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 19e:	4581                	li	a1,0
 1a0:	198000ef          	jal	338 <open>
  if(fd < 0)
 1a4:	02054263          	bltz	a0,1c8 <stat+0x36>
 1a8:	e426                	sd	s1,8(sp)
 1aa:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1ac:	85ca                	mv	a1,s2
 1ae:	1a2000ef          	jal	350 <fstat>
 1b2:	892a                	mv	s2,a0
  close(fd);
 1b4:	8526                	mv	a0,s1
 1b6:	16a000ef          	jal	320 <close>
  return r;
 1ba:	64a2                	ld	s1,8(sp)
}
 1bc:	854a                	mv	a0,s2
 1be:	60e2                	ld	ra,24(sp)
 1c0:	6442                	ld	s0,16(sp)
 1c2:	6902                	ld	s2,0(sp)
 1c4:	6105                	addi	sp,sp,32
 1c6:	8082                	ret
    return -1;
 1c8:	57fd                	li	a5,-1
 1ca:	893e                	mv	s2,a5
 1cc:	bfc5                	j	1bc <stat+0x2a>

00000000000001ce <atoi>:

int
atoi(const char *s)
{
 1ce:	1141                	addi	sp,sp,-16
 1d0:	e406                	sd	ra,8(sp)
 1d2:	e022                	sd	s0,0(sp)
 1d4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1d6:	00054683          	lbu	a3,0(a0)
 1da:	fd06879b          	addiw	a5,a3,-48 # fd0 <digits+0x688>
 1de:	0ff7f793          	zext.b	a5,a5
 1e2:	4625                	li	a2,9
 1e4:	02f66963          	bltu	a2,a5,216 <atoi+0x48>
 1e8:	872a                	mv	a4,a0
  n = 0;
 1ea:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1ec:	0705                	addi	a4,a4,1
 1ee:	0025179b          	slliw	a5,a0,0x2
 1f2:	9fa9                	addw	a5,a5,a0
 1f4:	0017979b          	slliw	a5,a5,0x1
 1f8:	9fb5                	addw	a5,a5,a3
 1fa:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1fe:	00074683          	lbu	a3,0(a4)
 202:	fd06879b          	addiw	a5,a3,-48
 206:	0ff7f793          	zext.b	a5,a5
 20a:	fef671e3          	bgeu	a2,a5,1ec <atoi+0x1e>
  return n;
}
 20e:	60a2                	ld	ra,8(sp)
 210:	6402                	ld	s0,0(sp)
 212:	0141                	addi	sp,sp,16
 214:	8082                	ret
  n = 0;
 216:	4501                	li	a0,0
 218:	bfdd                	j	20e <atoi+0x40>

000000000000021a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 21a:	1141                	addi	sp,sp,-16
 21c:	e406                	sd	ra,8(sp)
 21e:	e022                	sd	s0,0(sp)
 220:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 222:	02b57563          	bgeu	a0,a1,24c <memmove+0x32>
    while(n-- > 0)
 226:	00c05f63          	blez	a2,244 <memmove+0x2a>
 22a:	1602                	slli	a2,a2,0x20
 22c:	9201                	srli	a2,a2,0x20
 22e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 232:	872a                	mv	a4,a0
      *dst++ = *src++;
 234:	0585                	addi	a1,a1,1
 236:	0705                	addi	a4,a4,1
 238:	fff5c683          	lbu	a3,-1(a1)
 23c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 240:	fee79ae3          	bne	a5,a4,234 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 244:	60a2                	ld	ra,8(sp)
 246:	6402                	ld	s0,0(sp)
 248:	0141                	addi	sp,sp,16
 24a:	8082                	ret
    while(n-- > 0)
 24c:	fec05ce3          	blez	a2,244 <memmove+0x2a>
    dst += n;
 250:	00c50733          	add	a4,a0,a2
    src += n;
 254:	95b2                	add	a1,a1,a2
 256:	fff6079b          	addiw	a5,a2,-1
 25a:	1782                	slli	a5,a5,0x20
 25c:	9381                	srli	a5,a5,0x20
 25e:	fff7c793          	not	a5,a5
 262:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 264:	15fd                	addi	a1,a1,-1
 266:	177d                	addi	a4,a4,-1
 268:	0005c683          	lbu	a3,0(a1)
 26c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 270:	fef71ae3          	bne	a4,a5,264 <memmove+0x4a>
 274:	bfc1                	j	244 <memmove+0x2a>

0000000000000276 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 276:	1141                	addi	sp,sp,-16
 278:	e406                	sd	ra,8(sp)
 27a:	e022                	sd	s0,0(sp)
 27c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 27e:	c61d                	beqz	a2,2ac <memcmp+0x36>
 280:	1602                	slli	a2,a2,0x20
 282:	9201                	srli	a2,a2,0x20
 284:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 288:	00054783          	lbu	a5,0(a0)
 28c:	0005c703          	lbu	a4,0(a1)
 290:	00e79863          	bne	a5,a4,2a0 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 294:	0505                	addi	a0,a0,1
    p2++;
 296:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 298:	fed518e3          	bne	a0,a3,288 <memcmp+0x12>
  }
  return 0;
 29c:	4501                	li	a0,0
 29e:	a019                	j	2a4 <memcmp+0x2e>
      return *p1 - *p2;
 2a0:	40e7853b          	subw	a0,a5,a4
}
 2a4:	60a2                	ld	ra,8(sp)
 2a6:	6402                	ld	s0,0(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret
  return 0;
 2ac:	4501                	li	a0,0
 2ae:	bfdd                	j	2a4 <memcmp+0x2e>

00000000000002b0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2b0:	1141                	addi	sp,sp,-16
 2b2:	e406                	sd	ra,8(sp)
 2b4:	e022                	sd	s0,0(sp)
 2b6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2b8:	f63ff0ef          	jal	21a <memmove>
}
 2bc:	60a2                	ld	ra,8(sp)
 2be:	6402                	ld	s0,0(sp)
 2c0:	0141                	addi	sp,sp,16
 2c2:	8082                	ret

00000000000002c4 <sbrk>:

char *
sbrk(int n) {
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e406                	sd	ra,8(sp)
 2c8:	e022                	sd	s0,0(sp)
 2ca:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2cc:	4585                	li	a1,1
 2ce:	0b2000ef          	jal	380 <sys_sbrk>
}
 2d2:	60a2                	ld	ra,8(sp)
 2d4:	6402                	ld	s0,0(sp)
 2d6:	0141                	addi	sp,sp,16
 2d8:	8082                	ret

00000000000002da <sbrklazy>:

char *
sbrklazy(int n) {
 2da:	1141                	addi	sp,sp,-16
 2dc:	e406                	sd	ra,8(sp)
 2de:	e022                	sd	s0,0(sp)
 2e0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2e2:	4589                	li	a1,2
 2e4:	09c000ef          	jal	380 <sys_sbrk>
}
 2e8:	60a2                	ld	ra,8(sp)
 2ea:	6402                	ld	s0,0(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret

00000000000002f0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2f0:	4885                	li	a7,1
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2f8:	4889                	li	a7,2
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <wait>:
.global wait
wait:
 li a7, SYS_wait
 300:	488d                	li	a7,3
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 308:	4891                	li	a7,4
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <read>:
.global read
read:
 li a7, SYS_read
 310:	4895                	li	a7,5
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <write>:
.global write
write:
 li a7, SYS_write
 318:	48c1                	li	a7,16
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <close>:
.global close
close:
 li a7, SYS_close
 320:	48d5                	li	a7,21
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <kill>:
.global kill
kill:
 li a7, SYS_kill
 328:	4899                	li	a7,6
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <exec>:
.global exec
exec:
 li a7, SYS_exec
 330:	489d                	li	a7,7
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <open>:
.global open
open:
 li a7, SYS_open
 338:	48bd                	li	a7,15
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 340:	48c5                	li	a7,17
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 348:	48c9                	li	a7,18
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 350:	48a1                	li	a7,8
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <link>:
.global link
link:
 li a7, SYS_link
 358:	48cd                	li	a7,19
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 360:	48d1                	li	a7,20
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 368:	48a5                	li	a7,9
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <dup>:
.global dup
dup:
 li a7, SYS_dup
 370:	48a9                	li	a7,10
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 378:	48ad                	li	a7,11
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 380:	48b1                	li	a7,12
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <pause>:
.global pause
pause:
 li a7, SYS_pause
 388:	48b5                	li	a7,13
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 390:	48b9                	li	a7,14
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <memstat>:
.global memstat
memstat:
 li a7, SYS_memstat
 398:	48d9                	li	a7,22
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <enable_bonus>:
.global enable_bonus
enable_bonus:
 li a7, SYS_enable_bonus
 3a0:	48dd                	li	a7,23
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3a8:	1101                	addi	sp,sp,-32
 3aa:	ec06                	sd	ra,24(sp)
 3ac:	e822                	sd	s0,16(sp)
 3ae:	1000                	addi	s0,sp,32
 3b0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3b4:	4605                	li	a2,1
 3b6:	fef40593          	addi	a1,s0,-17
 3ba:	f5fff0ef          	jal	318 <write>
}
 3be:	60e2                	ld	ra,24(sp)
 3c0:	6442                	ld	s0,16(sp)
 3c2:	6105                	addi	sp,sp,32
 3c4:	8082                	ret

00000000000003c6 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3c6:	715d                	addi	sp,sp,-80
 3c8:	e486                	sd	ra,72(sp)
 3ca:	e0a2                	sd	s0,64(sp)
 3cc:	f84a                	sd	s2,48(sp)
 3ce:	f44e                	sd	s3,40(sp)
 3d0:	0880                	addi	s0,sp,80
 3d2:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3d4:	c6d1                	beqz	a3,460 <printint+0x9a>
 3d6:	0805d563          	bgez	a1,460 <printint+0x9a>
    neg = 1;
    x = -xx;
 3da:	40b005b3          	neg	a1,a1
    neg = 1;
 3de:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 3e0:	fb840993          	addi	s3,s0,-72
  neg = 0;
 3e4:	86ce                	mv	a3,s3
  i = 0;
 3e6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3e8:	00000817          	auipc	a6,0x0
 3ec:	56080813          	addi	a6,a6,1376 # 948 <digits>
 3f0:	88ba                	mv	a7,a4
 3f2:	0017051b          	addiw	a0,a4,1
 3f6:	872a                	mv	a4,a0
 3f8:	02c5f7b3          	remu	a5,a1,a2
 3fc:	97c2                	add	a5,a5,a6
 3fe:	0007c783          	lbu	a5,0(a5)
 402:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 406:	87ae                	mv	a5,a1
 408:	02c5d5b3          	divu	a1,a1,a2
 40c:	0685                	addi	a3,a3,1
 40e:	fec7f1e3          	bgeu	a5,a2,3f0 <printint+0x2a>
  if(neg)
 412:	00030c63          	beqz	t1,42a <printint+0x64>
    buf[i++] = '-';
 416:	fd050793          	addi	a5,a0,-48
 41a:	00878533          	add	a0,a5,s0
 41e:	02d00793          	li	a5,45
 422:	fef50423          	sb	a5,-24(a0)
 426:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 42a:	02e05563          	blez	a4,454 <printint+0x8e>
 42e:	fc26                	sd	s1,56(sp)
 430:	377d                	addiw	a4,a4,-1
 432:	00e984b3          	add	s1,s3,a4
 436:	19fd                	addi	s3,s3,-1
 438:	99ba                	add	s3,s3,a4
 43a:	1702                	slli	a4,a4,0x20
 43c:	9301                	srli	a4,a4,0x20
 43e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 442:	0004c583          	lbu	a1,0(s1)
 446:	854a                	mv	a0,s2
 448:	f61ff0ef          	jal	3a8 <putc>
  while(--i >= 0)
 44c:	14fd                	addi	s1,s1,-1
 44e:	ff349ae3          	bne	s1,s3,442 <printint+0x7c>
 452:	74e2                	ld	s1,56(sp)
}
 454:	60a6                	ld	ra,72(sp)
 456:	6406                	ld	s0,64(sp)
 458:	7942                	ld	s2,48(sp)
 45a:	79a2                	ld	s3,40(sp)
 45c:	6161                	addi	sp,sp,80
 45e:	8082                	ret
  neg = 0;
 460:	4301                	li	t1,0
 462:	bfbd                	j	3e0 <printint+0x1a>

0000000000000464 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 464:	711d                	addi	sp,sp,-96
 466:	ec86                	sd	ra,88(sp)
 468:	e8a2                	sd	s0,80(sp)
 46a:	e4a6                	sd	s1,72(sp)
 46c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 46e:	0005c483          	lbu	s1,0(a1)
 472:	22048363          	beqz	s1,698 <vprintf+0x234>
 476:	e0ca                	sd	s2,64(sp)
 478:	fc4e                	sd	s3,56(sp)
 47a:	f852                	sd	s4,48(sp)
 47c:	f456                	sd	s5,40(sp)
 47e:	f05a                	sd	s6,32(sp)
 480:	ec5e                	sd	s7,24(sp)
 482:	e862                	sd	s8,16(sp)
 484:	8b2a                	mv	s6,a0
 486:	8a2e                	mv	s4,a1
 488:	8bb2                	mv	s7,a2
  state = 0;
 48a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 48c:	4901                	li	s2,0
 48e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 490:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 494:	06400c13          	li	s8,100
 498:	a00d                	j	4ba <vprintf+0x56>
        putc(fd, c0);
 49a:	85a6                	mv	a1,s1
 49c:	855a                	mv	a0,s6
 49e:	f0bff0ef          	jal	3a8 <putc>
 4a2:	a019                	j	4a8 <vprintf+0x44>
    } else if(state == '%'){
 4a4:	03598363          	beq	s3,s5,4ca <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 4a8:	0019079b          	addiw	a5,s2,1
 4ac:	893e                	mv	s2,a5
 4ae:	873e                	mv	a4,a5
 4b0:	97d2                	add	a5,a5,s4
 4b2:	0007c483          	lbu	s1,0(a5)
 4b6:	1c048a63          	beqz	s1,68a <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 4ba:	0004879b          	sext.w	a5,s1
    if(state == 0){
 4be:	fe0993e3          	bnez	s3,4a4 <vprintf+0x40>
      if(c0 == '%'){
 4c2:	fd579ce3          	bne	a5,s5,49a <vprintf+0x36>
        state = '%';
 4c6:	89be                	mv	s3,a5
 4c8:	b7c5                	j	4a8 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 4ca:	00ea06b3          	add	a3,s4,a4
 4ce:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 4d2:	1c060863          	beqz	a2,6a2 <vprintf+0x23e>
      if(c0 == 'd'){
 4d6:	03878763          	beq	a5,s8,504 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4da:	f9478693          	addi	a3,a5,-108
 4de:	0016b693          	seqz	a3,a3
 4e2:	f9c60593          	addi	a1,a2,-100
 4e6:	e99d                	bnez	a1,51c <vprintf+0xb8>
 4e8:	ca95                	beqz	a3,51c <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 4ea:	008b8493          	addi	s1,s7,8
 4ee:	4685                	li	a3,1
 4f0:	4629                	li	a2,10
 4f2:	000bb583          	ld	a1,0(s7)
 4f6:	855a                	mv	a0,s6
 4f8:	ecfff0ef          	jal	3c6 <printint>
        i += 1;
 4fc:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 4fe:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 500:	4981                	li	s3,0
 502:	b75d                	j	4a8 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 504:	008b8493          	addi	s1,s7,8
 508:	4685                	li	a3,1
 50a:	4629                	li	a2,10
 50c:	000ba583          	lw	a1,0(s7)
 510:	855a                	mv	a0,s6
 512:	eb5ff0ef          	jal	3c6 <printint>
 516:	8ba6                	mv	s7,s1
      state = 0;
 518:	4981                	li	s3,0
 51a:	b779                	j	4a8 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 51c:	9752                	add	a4,a4,s4
 51e:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 522:	f9460713          	addi	a4,a2,-108
 526:	00173713          	seqz	a4,a4
 52a:	8f75                	and	a4,a4,a3
 52c:	f9c58513          	addi	a0,a1,-100
 530:	18051363          	bnez	a0,6b6 <vprintf+0x252>
 534:	18070163          	beqz	a4,6b6 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 538:	008b8493          	addi	s1,s7,8
 53c:	4685                	li	a3,1
 53e:	4629                	li	a2,10
 540:	000bb583          	ld	a1,0(s7)
 544:	855a                	mv	a0,s6
 546:	e81ff0ef          	jal	3c6 <printint>
        i += 2;
 54a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 54c:	8ba6                	mv	s7,s1
      state = 0;
 54e:	4981                	li	s3,0
        i += 2;
 550:	bfa1                	j	4a8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 552:	008b8493          	addi	s1,s7,8
 556:	4681                	li	a3,0
 558:	4629                	li	a2,10
 55a:	000be583          	lwu	a1,0(s7)
 55e:	855a                	mv	a0,s6
 560:	e67ff0ef          	jal	3c6 <printint>
 564:	8ba6                	mv	s7,s1
      state = 0;
 566:	4981                	li	s3,0
 568:	b781                	j	4a8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 56a:	008b8493          	addi	s1,s7,8
 56e:	4681                	li	a3,0
 570:	4629                	li	a2,10
 572:	000bb583          	ld	a1,0(s7)
 576:	855a                	mv	a0,s6
 578:	e4fff0ef          	jal	3c6 <printint>
        i += 1;
 57c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 57e:	8ba6                	mv	s7,s1
      state = 0;
 580:	4981                	li	s3,0
 582:	b71d                	j	4a8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 584:	008b8493          	addi	s1,s7,8
 588:	4681                	li	a3,0
 58a:	4629                	li	a2,10
 58c:	000bb583          	ld	a1,0(s7)
 590:	855a                	mv	a0,s6
 592:	e35ff0ef          	jal	3c6 <printint>
        i += 2;
 596:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 598:	8ba6                	mv	s7,s1
      state = 0;
 59a:	4981                	li	s3,0
        i += 2;
 59c:	b731                	j	4a8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 59e:	008b8493          	addi	s1,s7,8
 5a2:	4681                	li	a3,0
 5a4:	4641                	li	a2,16
 5a6:	000be583          	lwu	a1,0(s7)
 5aa:	855a                	mv	a0,s6
 5ac:	e1bff0ef          	jal	3c6 <printint>
 5b0:	8ba6                	mv	s7,s1
      state = 0;
 5b2:	4981                	li	s3,0
 5b4:	bdd5                	j	4a8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5b6:	008b8493          	addi	s1,s7,8
 5ba:	4681                	li	a3,0
 5bc:	4641                	li	a2,16
 5be:	000bb583          	ld	a1,0(s7)
 5c2:	855a                	mv	a0,s6
 5c4:	e03ff0ef          	jal	3c6 <printint>
        i += 1;
 5c8:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ca:	8ba6                	mv	s7,s1
      state = 0;
 5cc:	4981                	li	s3,0
 5ce:	bde9                	j	4a8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5d0:	008b8493          	addi	s1,s7,8
 5d4:	4681                	li	a3,0
 5d6:	4641                	li	a2,16
 5d8:	000bb583          	ld	a1,0(s7)
 5dc:	855a                	mv	a0,s6
 5de:	de9ff0ef          	jal	3c6 <printint>
        i += 2;
 5e2:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5e4:	8ba6                	mv	s7,s1
      state = 0;
 5e6:	4981                	li	s3,0
        i += 2;
 5e8:	b5c1                	j	4a8 <vprintf+0x44>
 5ea:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 5ec:	008b8793          	addi	a5,s7,8
 5f0:	8cbe                	mv	s9,a5
 5f2:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5f6:	03000593          	li	a1,48
 5fa:	855a                	mv	a0,s6
 5fc:	dadff0ef          	jal	3a8 <putc>
  putc(fd, 'x');
 600:	07800593          	li	a1,120
 604:	855a                	mv	a0,s6
 606:	da3ff0ef          	jal	3a8 <putc>
 60a:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 60c:	00000b97          	auipc	s7,0x0
 610:	33cb8b93          	addi	s7,s7,828 # 948 <digits>
 614:	03c9d793          	srli	a5,s3,0x3c
 618:	97de                	add	a5,a5,s7
 61a:	0007c583          	lbu	a1,0(a5)
 61e:	855a                	mv	a0,s6
 620:	d89ff0ef          	jal	3a8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 624:	0992                	slli	s3,s3,0x4
 626:	34fd                	addiw	s1,s1,-1
 628:	f4f5                	bnez	s1,614 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 62a:	8be6                	mv	s7,s9
      state = 0;
 62c:	4981                	li	s3,0
 62e:	6ca2                	ld	s9,8(sp)
 630:	bda5                	j	4a8 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 632:	008b8493          	addi	s1,s7,8
 636:	000bc583          	lbu	a1,0(s7)
 63a:	855a                	mv	a0,s6
 63c:	d6dff0ef          	jal	3a8 <putc>
 640:	8ba6                	mv	s7,s1
      state = 0;
 642:	4981                	li	s3,0
 644:	b595                	j	4a8 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 646:	008b8993          	addi	s3,s7,8
 64a:	000bb483          	ld	s1,0(s7)
 64e:	cc91                	beqz	s1,66a <vprintf+0x206>
        for(; *s; s++)
 650:	0004c583          	lbu	a1,0(s1)
 654:	c985                	beqz	a1,684 <vprintf+0x220>
          putc(fd, *s);
 656:	855a                	mv	a0,s6
 658:	d51ff0ef          	jal	3a8 <putc>
        for(; *s; s++)
 65c:	0485                	addi	s1,s1,1
 65e:	0004c583          	lbu	a1,0(s1)
 662:	f9f5                	bnez	a1,656 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 664:	8bce                	mv	s7,s3
      state = 0;
 666:	4981                	li	s3,0
 668:	b581                	j	4a8 <vprintf+0x44>
          s = "(null)";
 66a:	00000497          	auipc	s1,0x0
 66e:	2d648493          	addi	s1,s1,726 # 940 <malloc+0x13a>
        for(; *s; s++)
 672:	02800593          	li	a1,40
 676:	b7c5                	j	656 <vprintf+0x1f2>
        putc(fd, '%');
 678:	85be                	mv	a1,a5
 67a:	855a                	mv	a0,s6
 67c:	d2dff0ef          	jal	3a8 <putc>
      state = 0;
 680:	4981                	li	s3,0
 682:	b51d                	j	4a8 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 684:	8bce                	mv	s7,s3
      state = 0;
 686:	4981                	li	s3,0
 688:	b505                	j	4a8 <vprintf+0x44>
 68a:	6906                	ld	s2,64(sp)
 68c:	79e2                	ld	s3,56(sp)
 68e:	7a42                	ld	s4,48(sp)
 690:	7aa2                	ld	s5,40(sp)
 692:	7b02                	ld	s6,32(sp)
 694:	6be2                	ld	s7,24(sp)
 696:	6c42                	ld	s8,16(sp)
    }
  }
}
 698:	60e6                	ld	ra,88(sp)
 69a:	6446                	ld	s0,80(sp)
 69c:	64a6                	ld	s1,72(sp)
 69e:	6125                	addi	sp,sp,96
 6a0:	8082                	ret
      if(c0 == 'd'){
 6a2:	06400713          	li	a4,100
 6a6:	e4e78fe3          	beq	a5,a4,504 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 6aa:	f9478693          	addi	a3,a5,-108
 6ae:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 6b2:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6b4:	4701                	li	a4,0
      } else if(c0 == 'u'){
 6b6:	07500513          	li	a0,117
 6ba:	e8a78ce3          	beq	a5,a0,552 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 6be:	f8b60513          	addi	a0,a2,-117
 6c2:	e119                	bnez	a0,6c8 <vprintf+0x264>
 6c4:	ea0693e3          	bnez	a3,56a <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6c8:	f8b58513          	addi	a0,a1,-117
 6cc:	e119                	bnez	a0,6d2 <vprintf+0x26e>
 6ce:	ea071be3          	bnez	a4,584 <vprintf+0x120>
      } else if(c0 == 'x'){
 6d2:	07800513          	li	a0,120
 6d6:	eca784e3          	beq	a5,a0,59e <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 6da:	f8860613          	addi	a2,a2,-120
 6de:	e219                	bnez	a2,6e4 <vprintf+0x280>
 6e0:	ec069be3          	bnez	a3,5b6 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6e4:	f8858593          	addi	a1,a1,-120
 6e8:	e199                	bnez	a1,6ee <vprintf+0x28a>
 6ea:	ee0713e3          	bnez	a4,5d0 <vprintf+0x16c>
      } else if(c0 == 'p'){
 6ee:	07000713          	li	a4,112
 6f2:	eee78ce3          	beq	a5,a4,5ea <vprintf+0x186>
      } else if(c0 == 'c'){
 6f6:	06300713          	li	a4,99
 6fa:	f2e78ce3          	beq	a5,a4,632 <vprintf+0x1ce>
      } else if(c0 == 's'){
 6fe:	07300713          	li	a4,115
 702:	f4e782e3          	beq	a5,a4,646 <vprintf+0x1e2>
      } else if(c0 == '%'){
 706:	02500713          	li	a4,37
 70a:	f6e787e3          	beq	a5,a4,678 <vprintf+0x214>
        putc(fd, '%');
 70e:	02500593          	li	a1,37
 712:	855a                	mv	a0,s6
 714:	c95ff0ef          	jal	3a8 <putc>
        putc(fd, c0);
 718:	85a6                	mv	a1,s1
 71a:	855a                	mv	a0,s6
 71c:	c8dff0ef          	jal	3a8 <putc>
      state = 0;
 720:	4981                	li	s3,0
 722:	b359                	j	4a8 <vprintf+0x44>

0000000000000724 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 724:	715d                	addi	sp,sp,-80
 726:	ec06                	sd	ra,24(sp)
 728:	e822                	sd	s0,16(sp)
 72a:	1000                	addi	s0,sp,32
 72c:	e010                	sd	a2,0(s0)
 72e:	e414                	sd	a3,8(s0)
 730:	e818                	sd	a4,16(s0)
 732:	ec1c                	sd	a5,24(s0)
 734:	03043023          	sd	a6,32(s0)
 738:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 73c:	8622                	mv	a2,s0
 73e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 742:	d23ff0ef          	jal	464 <vprintf>
}
 746:	60e2                	ld	ra,24(sp)
 748:	6442                	ld	s0,16(sp)
 74a:	6161                	addi	sp,sp,80
 74c:	8082                	ret

000000000000074e <printf>:

void
printf(const char *fmt, ...)
{
 74e:	711d                	addi	sp,sp,-96
 750:	ec06                	sd	ra,24(sp)
 752:	e822                	sd	s0,16(sp)
 754:	1000                	addi	s0,sp,32
 756:	e40c                	sd	a1,8(s0)
 758:	e810                	sd	a2,16(s0)
 75a:	ec14                	sd	a3,24(s0)
 75c:	f018                	sd	a4,32(s0)
 75e:	f41c                	sd	a5,40(s0)
 760:	03043823          	sd	a6,48(s0)
 764:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 768:	00840613          	addi	a2,s0,8
 76c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 770:	85aa                	mv	a1,a0
 772:	4505                	li	a0,1
 774:	cf1ff0ef          	jal	464 <vprintf>
}
 778:	60e2                	ld	ra,24(sp)
 77a:	6442                	ld	s0,16(sp)
 77c:	6125                	addi	sp,sp,96
 77e:	8082                	ret

0000000000000780 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 780:	1141                	addi	sp,sp,-16
 782:	e406                	sd	ra,8(sp)
 784:	e022                	sd	s0,0(sp)
 786:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 788:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 78c:	00001797          	auipc	a5,0x1
 790:	8747b783          	ld	a5,-1932(a5) # 1000 <freep>
 794:	a039                	j	7a2 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 796:	6398                	ld	a4,0(a5)
 798:	00e7e463          	bltu	a5,a4,7a0 <free+0x20>
 79c:	00e6ea63          	bltu	a3,a4,7b0 <free+0x30>
{
 7a0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a2:	fed7fae3          	bgeu	a5,a3,796 <free+0x16>
 7a6:	6398                	ld	a4,0(a5)
 7a8:	00e6e463          	bltu	a3,a4,7b0 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ac:	fee7eae3          	bltu	a5,a4,7a0 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7b0:	ff852583          	lw	a1,-8(a0)
 7b4:	6390                	ld	a2,0(a5)
 7b6:	02059813          	slli	a6,a1,0x20
 7ba:	01c85713          	srli	a4,a6,0x1c
 7be:	9736                	add	a4,a4,a3
 7c0:	02e60563          	beq	a2,a4,7ea <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 7c4:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 7c8:	4790                	lw	a2,8(a5)
 7ca:	02061593          	slli	a1,a2,0x20
 7ce:	01c5d713          	srli	a4,a1,0x1c
 7d2:	973e                	add	a4,a4,a5
 7d4:	02e68263          	beq	a3,a4,7f8 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 7d8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7da:	00001717          	auipc	a4,0x1
 7de:	82f73323          	sd	a5,-2010(a4) # 1000 <freep>
}
 7e2:	60a2                	ld	ra,8(sp)
 7e4:	6402                	ld	s0,0(sp)
 7e6:	0141                	addi	sp,sp,16
 7e8:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 7ea:	4618                	lw	a4,8(a2)
 7ec:	9f2d                	addw	a4,a4,a1
 7ee:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7f2:	6398                	ld	a4,0(a5)
 7f4:	6310                	ld	a2,0(a4)
 7f6:	b7f9                	j	7c4 <free+0x44>
    p->s.size += bp->s.size;
 7f8:	ff852703          	lw	a4,-8(a0)
 7fc:	9f31                	addw	a4,a4,a2
 7fe:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 800:	ff053683          	ld	a3,-16(a0)
 804:	bfd1                	j	7d8 <free+0x58>

0000000000000806 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 806:	7139                	addi	sp,sp,-64
 808:	fc06                	sd	ra,56(sp)
 80a:	f822                	sd	s0,48(sp)
 80c:	f04a                	sd	s2,32(sp)
 80e:	ec4e                	sd	s3,24(sp)
 810:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 812:	02051993          	slli	s3,a0,0x20
 816:	0209d993          	srli	s3,s3,0x20
 81a:	09bd                	addi	s3,s3,15
 81c:	0049d993          	srli	s3,s3,0x4
 820:	2985                	addiw	s3,s3,1
 822:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 824:	00000517          	auipc	a0,0x0
 828:	7dc53503          	ld	a0,2012(a0) # 1000 <freep>
 82c:	c905                	beqz	a0,85c <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 82e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 830:	4798                	lw	a4,8(a5)
 832:	09377663          	bgeu	a4,s3,8be <malloc+0xb8>
 836:	f426                	sd	s1,40(sp)
 838:	e852                	sd	s4,16(sp)
 83a:	e456                	sd	s5,8(sp)
 83c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 83e:	8a4e                	mv	s4,s3
 840:	6705                	lui	a4,0x1
 842:	00e9f363          	bgeu	s3,a4,848 <malloc+0x42>
 846:	6a05                	lui	s4,0x1
 848:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 84c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 850:	00000497          	auipc	s1,0x0
 854:	7b048493          	addi	s1,s1,1968 # 1000 <freep>
  if(p == SBRK_ERROR)
 858:	5afd                	li	s5,-1
 85a:	a83d                	j	898 <malloc+0x92>
 85c:	f426                	sd	s1,40(sp)
 85e:	e852                	sd	s4,16(sp)
 860:	e456                	sd	s5,8(sp)
 862:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 864:	00000797          	auipc	a5,0x0
 868:	7ac78793          	addi	a5,a5,1964 # 1010 <base>
 86c:	00000717          	auipc	a4,0x0
 870:	78f73a23          	sd	a5,1940(a4) # 1000 <freep>
 874:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 876:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 87a:	b7d1                	j	83e <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 87c:	6398                	ld	a4,0(a5)
 87e:	e118                	sd	a4,0(a0)
 880:	a899                	j	8d6 <malloc+0xd0>
  hp->s.size = nu;
 882:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 886:	0541                	addi	a0,a0,16
 888:	ef9ff0ef          	jal	780 <free>
  return freep;
 88c:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 88e:	c125                	beqz	a0,8ee <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 890:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 892:	4798                	lw	a4,8(a5)
 894:	03277163          	bgeu	a4,s2,8b6 <malloc+0xb0>
    if(p == freep)
 898:	6098                	ld	a4,0(s1)
 89a:	853e                	mv	a0,a5
 89c:	fef71ae3          	bne	a4,a5,890 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 8a0:	8552                	mv	a0,s4
 8a2:	a23ff0ef          	jal	2c4 <sbrk>
  if(p == SBRK_ERROR)
 8a6:	fd551ee3          	bne	a0,s5,882 <malloc+0x7c>
        return 0;
 8aa:	4501                	li	a0,0
 8ac:	74a2                	ld	s1,40(sp)
 8ae:	6a42                	ld	s4,16(sp)
 8b0:	6aa2                	ld	s5,8(sp)
 8b2:	6b02                	ld	s6,0(sp)
 8b4:	a03d                	j	8e2 <malloc+0xdc>
 8b6:	74a2                	ld	s1,40(sp)
 8b8:	6a42                	ld	s4,16(sp)
 8ba:	6aa2                	ld	s5,8(sp)
 8bc:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8be:	fae90fe3          	beq	s2,a4,87c <malloc+0x76>
        p->s.size -= nunits;
 8c2:	4137073b          	subw	a4,a4,s3
 8c6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8c8:	02071693          	slli	a3,a4,0x20
 8cc:	01c6d713          	srli	a4,a3,0x1c
 8d0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8d2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8d6:	00000717          	auipc	a4,0x0
 8da:	72a73523          	sd	a0,1834(a4) # 1000 <freep>
      return (void*)(p + 1);
 8de:	01078513          	addi	a0,a5,16
  }
}
 8e2:	70e2                	ld	ra,56(sp)
 8e4:	7442                	ld	s0,48(sp)
 8e6:	7902                	ld	s2,32(sp)
 8e8:	69e2                	ld	s3,24(sp)
 8ea:	6121                	addi	sp,sp,64
 8ec:	8082                	ret
 8ee:	74a2                	ld	s1,40(sp)
 8f0:	6a42                	ld	s4,16(sp)
 8f2:	6aa2                	ld	s5,8(sp)
 8f4:	6b02                	ld	s6,0(sp)
 8f6:	b7f5                	j	8e2 <malloc+0xdc>
