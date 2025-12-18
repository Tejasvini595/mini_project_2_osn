
user/_test_memstat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"

int main(void) 
{
   0:	81010113          	addi	sp,sp,-2032
   4:	7e113423          	sd	ra,2024(sp)
   8:	7e813023          	sd	s0,2016(sp)
   c:	7c913c23          	sd	s1,2008(sp)
  10:	7d213823          	sd	s2,2000(sp)
  14:	7d313423          	sd	s3,1992(sp)
  18:	7d413023          	sd	s4,1984(sp)
  1c:	7b513c23          	sd	s5,1976(sp)
  20:	7b613823          	sd	s6,1968(sp)
  24:	7b713423          	sd	s7,1960(sp)
  28:	7b813023          	sd	s8,1952(sp)
  2c:	7f010413          	addi	s0,sp,2032
  30:	b8010113          	addi	sp,sp,-1152
    struct proc_mem_stat stat;
    
    // Test the memstat system call
    if (memstat(&stat) < 0) 
  34:	80040513          	addi	a0,s0,-2048
  38:	fb050513          	addi	a0,a0,-80
  3c:	be850513          	addi	a0,a0,-1048
  40:	464000ef          	jal	4a4 <memstat>
  44:	0a054763          	bltz	a0,f2 <main+0xf2>
    {
        printf("memstat() failed\n");
        exit(1);
    }
    
    printf("Memory statistics for process %d:\n", stat.pid);
  48:	80040493          	addi	s1,s0,-2048
  4c:	fb048493          	addi	s1,s1,-80
  50:	be84a583          	lw	a1,-1048(s1)
  54:	00001517          	auipc	a0,0x1
  58:	9fc50513          	addi	a0,a0,-1540 # a50 <malloc+0x13e>
  5c:	7fe000ef          	jal	85a <printf>
    printf("  Total pages: %d\n", stat.num_pages_total);
  60:	bec4a583          	lw	a1,-1044(s1)
  64:	00001517          	auipc	a0,0x1
  68:	a1450513          	addi	a0,a0,-1516 # a78 <malloc+0x166>
  6c:	7ee000ef          	jal	85a <printf>
    printf("  Resident pages: %d\n", stat.num_resident_pages);
  70:	bf04a583          	lw	a1,-1040(s1)
  74:	00001517          	auipc	a0,0x1
  78:	a1c50513          	addi	a0,a0,-1508 # a90 <malloc+0x17e>
  7c:	7de000ef          	jal	85a <printf>
    printf("  Swapped pages: %d\n", stat.num_swapped_pages);
  80:	bf44a583          	lw	a1,-1036(s1)
  84:	00001517          	auipc	a0,0x1
  88:	a2450513          	addi	a0,a0,-1500 # aa8 <malloc+0x196>
  8c:	7ce000ef          	jal	85a <printf>
    printf("  Next FIFO seq: %d\n", stat.next_fifo_seq);
  90:	bf84a583          	lw	a1,-1032(s1)
  94:	00001517          	auipc	a0,0x1
  98:	a2c50513          	addi	a0,a0,-1492 # ac0 <malloc+0x1ae>
  9c:	7be000ef          	jal	85a <printf>
    
    printf("\nDetailed page information:\n");
  a0:	00001517          	auipc	a0,0x1
  a4:	a3850513          	addi	a0,a0,-1480 # ad8 <malloc+0x1c6>
  a8:	7b2000ef          	jal	85a <printf>
    for(int i = 0; i < stat.num_resident_pages + stat.num_swapped_pages && i < 10; i++) {
  ac:	bf04a703          	lw	a4,-1040(s1)
  b0:	bf44a783          	lw	a5,-1036(s1)
  b4:	9fb9                	addw	a5,a5,a4
  b6:	08f05963          	blez	a5,148 <main+0x148>
  ba:	80040493          	addi	s1,s0,-2048
  be:	fb048493          	addi	s1,s1,-80
  c2:	c0048493          	addi	s1,s1,-1024
  c6:	4901                	li	s2,0
        printf("  Page %d: va=0x%lx state=%s dirty=%d seq=%d\n", 
  c8:	4b05                	li	s6,1
  ca:	00001a97          	auipc	s5,0x1
  ce:	956a8a93          	addi	s5,s5,-1706 # a20 <malloc+0x10e>
               i, stat.pages[i].va,
               (stat.pages[i].state == RESIDENT) ? "RESIDENT" :
               (stat.pages[i].state == SWAPPED) ? "SWAPPED" : "UNMAPPED",
  d2:	4c09                	li	s8,2
        printf("  Page %d: va=0x%lx state=%s dirty=%d seq=%d\n", 
  d4:	00001b97          	auipc	s7,0x1
  d8:	93cb8b93          	addi	s7,s7,-1732 # a10 <malloc+0xfe>
  dc:	00001a17          	auipc	s4,0x1
  e0:	a1ca0a13          	addi	s4,s4,-1508 # af8 <malloc+0x1e6>
    for(int i = 0; i < stat.num_resident_pages + stat.num_swapped_pages && i < 10; i++) {
  e4:	80040993          	addi	s3,s0,-2048
  e8:	fb098993          	addi	s3,s3,-80
  ec:	80098993          	addi	s3,s3,-2048
  f0:	a835                	j	12c <main+0x12c>
        printf("memstat() failed\n");
  f2:	00001517          	auipc	a0,0x1
  f6:	94650513          	addi	a0,a0,-1722 # a38 <malloc+0x126>
  fa:	760000ef          	jal	85a <printf>
        exit(1);
  fe:	4505                	li	a0,1
 100:	304000ef          	jal	404 <exit>
        printf("  Page %d: va=0x%lx state=%s dirty=%d seq=%d\n", 
 104:	4b1c                	lw	a5,16(a4)
 106:	4758                	lw	a4,12(a4)
 108:	85ca                	mv	a1,s2
 10a:	8552                	mv	a0,s4
 10c:	74e000ef          	jal	85a <printf>
    for(int i = 0; i < stat.num_resident_pages + stat.num_swapped_pages && i < 10; i++) {
 110:	0019079b          	addiw	a5,s2,1
 114:	893e                	mv	s2,a5
 116:	04e1                	addi	s1,s1,24
 118:	3f09a683          	lw	a3,1008(s3)
 11c:	3f49a703          	lw	a4,1012(s3)
 120:	9f35                	addw	a4,a4,a3
 122:	02e7d363          	bge	a5,a4,148 <main+0x148>
 126:	00a7a793          	slti	a5,a5,10
 12a:	cf99                	beqz	a5,148 <main+0x148>
        printf("  Page %d: va=0x%lx state=%s dirty=%d seq=%d\n", 
 12c:	8726                	mv	a4,s1
 12e:	6090                	ld	a2,0(s1)
               (stat.pages[i].state == RESIDENT) ? "RESIDENT" :
 130:	449c                	lw	a5,8(s1)
        printf("  Page %d: va=0x%lx state=%s dirty=%d seq=%d\n", 
 132:	86d6                	mv	a3,s5
 134:	fd6788e3          	beq	a5,s6,104 <main+0x104>
 138:	86de                	mv	a3,s7
               (stat.pages[i].state == SWAPPED) ? "SWAPPED" : "UNMAPPED",
 13a:	fd8795e3          	bne	a5,s8,104 <main+0x104>
        printf("  Page %d: va=0x%lx state=%s dirty=%d seq=%d\n", 
 13e:	00001697          	auipc	a3,0x1
 142:	8f268693          	addi	a3,a3,-1806 # a30 <malloc+0x11e>
 146:	bf7d                	j	104 <main+0x104>
               stat.pages[i].is_dirty,
               stat.pages[i].seq);
    }
    
    exit(0);
 148:	4501                	li	a0,0
 14a:	2ba000ef          	jal	404 <exit>

000000000000014e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 14e:	1141                	addi	sp,sp,-16
 150:	e406                	sd	ra,8(sp)
 152:	e022                	sd	s0,0(sp)
 154:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 156:	eabff0ef          	jal	0 <main>
  exit(r);
 15a:	2aa000ef          	jal	404 <exit>

000000000000015e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 15e:	1141                	addi	sp,sp,-16
 160:	e406                	sd	ra,8(sp)
 162:	e022                	sd	s0,0(sp)
 164:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 166:	87aa                	mv	a5,a0
 168:	0585                	addi	a1,a1,1
 16a:	0785                	addi	a5,a5,1
 16c:	fff5c703          	lbu	a4,-1(a1)
 170:	fee78fa3          	sb	a4,-1(a5)
 174:	fb75                	bnez	a4,168 <strcpy+0xa>
    ;
  return os;
}
 176:	60a2                	ld	ra,8(sp)
 178:	6402                	ld	s0,0(sp)
 17a:	0141                	addi	sp,sp,16
 17c:	8082                	ret

000000000000017e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 17e:	1141                	addi	sp,sp,-16
 180:	e406                	sd	ra,8(sp)
 182:	e022                	sd	s0,0(sp)
 184:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 186:	00054783          	lbu	a5,0(a0)
 18a:	cb91                	beqz	a5,19e <strcmp+0x20>
 18c:	0005c703          	lbu	a4,0(a1)
 190:	00f71763          	bne	a4,a5,19e <strcmp+0x20>
    p++, q++;
 194:	0505                	addi	a0,a0,1
 196:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 198:	00054783          	lbu	a5,0(a0)
 19c:	fbe5                	bnez	a5,18c <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 19e:	0005c503          	lbu	a0,0(a1)
}
 1a2:	40a7853b          	subw	a0,a5,a0
 1a6:	60a2                	ld	ra,8(sp)
 1a8:	6402                	ld	s0,0(sp)
 1aa:	0141                	addi	sp,sp,16
 1ac:	8082                	ret

00000000000001ae <strlen>:

uint
strlen(const char *s)
{
 1ae:	1141                	addi	sp,sp,-16
 1b0:	e406                	sd	ra,8(sp)
 1b2:	e022                	sd	s0,0(sp)
 1b4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1b6:	00054783          	lbu	a5,0(a0)
 1ba:	cf91                	beqz	a5,1d6 <strlen+0x28>
 1bc:	00150793          	addi	a5,a0,1
 1c0:	86be                	mv	a3,a5
 1c2:	0785                	addi	a5,a5,1
 1c4:	fff7c703          	lbu	a4,-1(a5)
 1c8:	ff65                	bnez	a4,1c0 <strlen+0x12>
 1ca:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 1ce:	60a2                	ld	ra,8(sp)
 1d0:	6402                	ld	s0,0(sp)
 1d2:	0141                	addi	sp,sp,16
 1d4:	8082                	ret
  for(n = 0; s[n]; n++)
 1d6:	4501                	li	a0,0
 1d8:	bfdd                	j	1ce <strlen+0x20>

00000000000001da <memset>:

void*
memset(void *dst, int c, uint n)
{
 1da:	1141                	addi	sp,sp,-16
 1dc:	e406                	sd	ra,8(sp)
 1de:	e022                	sd	s0,0(sp)
 1e0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1e2:	ca19                	beqz	a2,1f8 <memset+0x1e>
 1e4:	87aa                	mv	a5,a0
 1e6:	1602                	slli	a2,a2,0x20
 1e8:	9201                	srli	a2,a2,0x20
 1ea:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1ee:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1f2:	0785                	addi	a5,a5,1
 1f4:	fee79de3          	bne	a5,a4,1ee <memset+0x14>
  }
  return dst;
}
 1f8:	60a2                	ld	ra,8(sp)
 1fa:	6402                	ld	s0,0(sp)
 1fc:	0141                	addi	sp,sp,16
 1fe:	8082                	ret

0000000000000200 <strchr>:

char*
strchr(const char *s, char c)
{
 200:	1141                	addi	sp,sp,-16
 202:	e406                	sd	ra,8(sp)
 204:	e022                	sd	s0,0(sp)
 206:	0800                	addi	s0,sp,16
  for(; *s; s++)
 208:	00054783          	lbu	a5,0(a0)
 20c:	cf81                	beqz	a5,224 <strchr+0x24>
    if(*s == c)
 20e:	00f58763          	beq	a1,a5,21c <strchr+0x1c>
  for(; *s; s++)
 212:	0505                	addi	a0,a0,1
 214:	00054783          	lbu	a5,0(a0)
 218:	fbfd                	bnez	a5,20e <strchr+0xe>
      return (char*)s;
  return 0;
 21a:	4501                	li	a0,0
}
 21c:	60a2                	ld	ra,8(sp)
 21e:	6402                	ld	s0,0(sp)
 220:	0141                	addi	sp,sp,16
 222:	8082                	ret
  return 0;
 224:	4501                	li	a0,0
 226:	bfdd                	j	21c <strchr+0x1c>

0000000000000228 <gets>:

char*
gets(char *buf, int max)
{
 228:	711d                	addi	sp,sp,-96
 22a:	ec86                	sd	ra,88(sp)
 22c:	e8a2                	sd	s0,80(sp)
 22e:	e4a6                	sd	s1,72(sp)
 230:	e0ca                	sd	s2,64(sp)
 232:	fc4e                	sd	s3,56(sp)
 234:	f852                	sd	s4,48(sp)
 236:	f456                	sd	s5,40(sp)
 238:	f05a                	sd	s6,32(sp)
 23a:	ec5e                	sd	s7,24(sp)
 23c:	e862                	sd	s8,16(sp)
 23e:	1080                	addi	s0,sp,96
 240:	8baa                	mv	s7,a0
 242:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 244:	892a                	mv	s2,a0
 246:	4481                	li	s1,0
    cc = read(0, &c, 1);
 248:	faf40b13          	addi	s6,s0,-81
 24c:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 24e:	8c26                	mv	s8,s1
 250:	0014899b          	addiw	s3,s1,1
 254:	84ce                	mv	s1,s3
 256:	0349d463          	bge	s3,s4,27e <gets+0x56>
    cc = read(0, &c, 1);
 25a:	8656                	mv	a2,s5
 25c:	85da                	mv	a1,s6
 25e:	4501                	li	a0,0
 260:	1bc000ef          	jal	41c <read>
    if(cc < 1)
 264:	00a05d63          	blez	a0,27e <gets+0x56>
      break;
    buf[i++] = c;
 268:	faf44783          	lbu	a5,-81(s0)
 26c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 270:	0905                	addi	s2,s2,1
 272:	ff678713          	addi	a4,a5,-10
 276:	c319                	beqz	a4,27c <gets+0x54>
 278:	17cd                	addi	a5,a5,-13
 27a:	fbf1                	bnez	a5,24e <gets+0x26>
    buf[i++] = c;
 27c:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 27e:	9c5e                	add	s8,s8,s7
 280:	000c0023          	sb	zero,0(s8)
  return buf;
}
 284:	855e                	mv	a0,s7
 286:	60e6                	ld	ra,88(sp)
 288:	6446                	ld	s0,80(sp)
 28a:	64a6                	ld	s1,72(sp)
 28c:	6906                	ld	s2,64(sp)
 28e:	79e2                	ld	s3,56(sp)
 290:	7a42                	ld	s4,48(sp)
 292:	7aa2                	ld	s5,40(sp)
 294:	7b02                	ld	s6,32(sp)
 296:	6be2                	ld	s7,24(sp)
 298:	6c42                	ld	s8,16(sp)
 29a:	6125                	addi	sp,sp,96
 29c:	8082                	ret

000000000000029e <stat>:

int
stat(const char *n, struct stat *st)
{
 29e:	1101                	addi	sp,sp,-32
 2a0:	ec06                	sd	ra,24(sp)
 2a2:	e822                	sd	s0,16(sp)
 2a4:	e04a                	sd	s2,0(sp)
 2a6:	1000                	addi	s0,sp,32
 2a8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2aa:	4581                	li	a1,0
 2ac:	198000ef          	jal	444 <open>
  if(fd < 0)
 2b0:	02054263          	bltz	a0,2d4 <stat+0x36>
 2b4:	e426                	sd	s1,8(sp)
 2b6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2b8:	85ca                	mv	a1,s2
 2ba:	1a2000ef          	jal	45c <fstat>
 2be:	892a                	mv	s2,a0
  close(fd);
 2c0:	8526                	mv	a0,s1
 2c2:	16a000ef          	jal	42c <close>
  return r;
 2c6:	64a2                	ld	s1,8(sp)
}
 2c8:	854a                	mv	a0,s2
 2ca:	60e2                	ld	ra,24(sp)
 2cc:	6442                	ld	s0,16(sp)
 2ce:	6902                	ld	s2,0(sp)
 2d0:	6105                	addi	sp,sp,32
 2d2:	8082                	ret
    return -1;
 2d4:	57fd                	li	a5,-1
 2d6:	893e                	mv	s2,a5
 2d8:	bfc5                	j	2c8 <stat+0x2a>

00000000000002da <atoi>:

int
atoi(const char *s)
{
 2da:	1141                	addi	sp,sp,-16
 2dc:	e406                	sd	ra,8(sp)
 2de:	e022                	sd	s0,0(sp)
 2e0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2e2:	00054683          	lbu	a3,0(a0)
 2e6:	fd06879b          	addiw	a5,a3,-48
 2ea:	0ff7f793          	zext.b	a5,a5
 2ee:	4625                	li	a2,9
 2f0:	02f66963          	bltu	a2,a5,322 <atoi+0x48>
 2f4:	872a                	mv	a4,a0
  n = 0;
 2f6:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2f8:	0705                	addi	a4,a4,1
 2fa:	0025179b          	slliw	a5,a0,0x2
 2fe:	9fa9                	addw	a5,a5,a0
 300:	0017979b          	slliw	a5,a5,0x1
 304:	9fb5                	addw	a5,a5,a3
 306:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 30a:	00074683          	lbu	a3,0(a4)
 30e:	fd06879b          	addiw	a5,a3,-48
 312:	0ff7f793          	zext.b	a5,a5
 316:	fef671e3          	bgeu	a2,a5,2f8 <atoi+0x1e>
  return n;
}
 31a:	60a2                	ld	ra,8(sp)
 31c:	6402                	ld	s0,0(sp)
 31e:	0141                	addi	sp,sp,16
 320:	8082                	ret
  n = 0;
 322:	4501                	li	a0,0
 324:	bfdd                	j	31a <atoi+0x40>

0000000000000326 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 326:	1141                	addi	sp,sp,-16
 328:	e406                	sd	ra,8(sp)
 32a:	e022                	sd	s0,0(sp)
 32c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 32e:	02b57563          	bgeu	a0,a1,358 <memmove+0x32>
    while(n-- > 0)
 332:	00c05f63          	blez	a2,350 <memmove+0x2a>
 336:	1602                	slli	a2,a2,0x20
 338:	9201                	srli	a2,a2,0x20
 33a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 33e:	872a                	mv	a4,a0
      *dst++ = *src++;
 340:	0585                	addi	a1,a1,1
 342:	0705                	addi	a4,a4,1
 344:	fff5c683          	lbu	a3,-1(a1)
 348:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 34c:	fee79ae3          	bne	a5,a4,340 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 350:	60a2                	ld	ra,8(sp)
 352:	6402                	ld	s0,0(sp)
 354:	0141                	addi	sp,sp,16
 356:	8082                	ret
    while(n-- > 0)
 358:	fec05ce3          	blez	a2,350 <memmove+0x2a>
    dst += n;
 35c:	00c50733          	add	a4,a0,a2
    src += n;
 360:	95b2                	add	a1,a1,a2
 362:	fff6079b          	addiw	a5,a2,-1
 366:	1782                	slli	a5,a5,0x20
 368:	9381                	srli	a5,a5,0x20
 36a:	fff7c793          	not	a5,a5
 36e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 370:	15fd                	addi	a1,a1,-1
 372:	177d                	addi	a4,a4,-1
 374:	0005c683          	lbu	a3,0(a1)
 378:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 37c:	fef71ae3          	bne	a4,a5,370 <memmove+0x4a>
 380:	bfc1                	j	350 <memmove+0x2a>

0000000000000382 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 382:	1141                	addi	sp,sp,-16
 384:	e406                	sd	ra,8(sp)
 386:	e022                	sd	s0,0(sp)
 388:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 38a:	c61d                	beqz	a2,3b8 <memcmp+0x36>
 38c:	1602                	slli	a2,a2,0x20
 38e:	9201                	srli	a2,a2,0x20
 390:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 394:	00054783          	lbu	a5,0(a0)
 398:	0005c703          	lbu	a4,0(a1)
 39c:	00e79863          	bne	a5,a4,3ac <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 3a0:	0505                	addi	a0,a0,1
    p2++;
 3a2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3a4:	fed518e3          	bne	a0,a3,394 <memcmp+0x12>
  }
  return 0;
 3a8:	4501                	li	a0,0
 3aa:	a019                	j	3b0 <memcmp+0x2e>
      return *p1 - *p2;
 3ac:	40e7853b          	subw	a0,a5,a4
}
 3b0:	60a2                	ld	ra,8(sp)
 3b2:	6402                	ld	s0,0(sp)
 3b4:	0141                	addi	sp,sp,16
 3b6:	8082                	ret
  return 0;
 3b8:	4501                	li	a0,0
 3ba:	bfdd                	j	3b0 <memcmp+0x2e>

00000000000003bc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3bc:	1141                	addi	sp,sp,-16
 3be:	e406                	sd	ra,8(sp)
 3c0:	e022                	sd	s0,0(sp)
 3c2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3c4:	f63ff0ef          	jal	326 <memmove>
}
 3c8:	60a2                	ld	ra,8(sp)
 3ca:	6402                	ld	s0,0(sp)
 3cc:	0141                	addi	sp,sp,16
 3ce:	8082                	ret

00000000000003d0 <sbrk>:

char *
sbrk(int n) {
 3d0:	1141                	addi	sp,sp,-16
 3d2:	e406                	sd	ra,8(sp)
 3d4:	e022                	sd	s0,0(sp)
 3d6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3d8:	4585                	li	a1,1
 3da:	0b2000ef          	jal	48c <sys_sbrk>
}
 3de:	60a2                	ld	ra,8(sp)
 3e0:	6402                	ld	s0,0(sp)
 3e2:	0141                	addi	sp,sp,16
 3e4:	8082                	ret

00000000000003e6 <sbrklazy>:

char *
sbrklazy(int n) {
 3e6:	1141                	addi	sp,sp,-16
 3e8:	e406                	sd	ra,8(sp)
 3ea:	e022                	sd	s0,0(sp)
 3ec:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3ee:	4589                	li	a1,2
 3f0:	09c000ef          	jal	48c <sys_sbrk>
}
 3f4:	60a2                	ld	ra,8(sp)
 3f6:	6402                	ld	s0,0(sp)
 3f8:	0141                	addi	sp,sp,16
 3fa:	8082                	ret

00000000000003fc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3fc:	4885                	li	a7,1
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <exit>:
.global exit
exit:
 li a7, SYS_exit
 404:	4889                	li	a7,2
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <wait>:
.global wait
wait:
 li a7, SYS_wait
 40c:	488d                	li	a7,3
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 414:	4891                	li	a7,4
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <read>:
.global read
read:
 li a7, SYS_read
 41c:	4895                	li	a7,5
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <write>:
.global write
write:
 li a7, SYS_write
 424:	48c1                	li	a7,16
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <close>:
.global close
close:
 li a7, SYS_close
 42c:	48d5                	li	a7,21
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <kill>:
.global kill
kill:
 li a7, SYS_kill
 434:	4899                	li	a7,6
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <exec>:
.global exec
exec:
 li a7, SYS_exec
 43c:	489d                	li	a7,7
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <open>:
.global open
open:
 li a7, SYS_open
 444:	48bd                	li	a7,15
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 44c:	48c5                	li	a7,17
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 454:	48c9                	li	a7,18
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 45c:	48a1                	li	a7,8
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <link>:
.global link
link:
 li a7, SYS_link
 464:	48cd                	li	a7,19
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 46c:	48d1                	li	a7,20
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 474:	48a5                	li	a7,9
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <dup>:
.global dup
dup:
 li a7, SYS_dup
 47c:	48a9                	li	a7,10
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 484:	48ad                	li	a7,11
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 48c:	48b1                	li	a7,12
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <pause>:
.global pause
pause:
 li a7, SYS_pause
 494:	48b5                	li	a7,13
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 49c:	48b9                	li	a7,14
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <memstat>:
.global memstat
memstat:
 li a7, SYS_memstat
 4a4:	48d9                	li	a7,22
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <enable_bonus>:
.global enable_bonus
enable_bonus:
 li a7, SYS_enable_bonus
 4ac:	48dd                	li	a7,23
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4b4:	1101                	addi	sp,sp,-32
 4b6:	ec06                	sd	ra,24(sp)
 4b8:	e822                	sd	s0,16(sp)
 4ba:	1000                	addi	s0,sp,32
 4bc:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4c0:	4605                	li	a2,1
 4c2:	fef40593          	addi	a1,s0,-17
 4c6:	f5fff0ef          	jal	424 <write>
}
 4ca:	60e2                	ld	ra,24(sp)
 4cc:	6442                	ld	s0,16(sp)
 4ce:	6105                	addi	sp,sp,32
 4d0:	8082                	ret

00000000000004d2 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4d2:	715d                	addi	sp,sp,-80
 4d4:	e486                	sd	ra,72(sp)
 4d6:	e0a2                	sd	s0,64(sp)
 4d8:	f84a                	sd	s2,48(sp)
 4da:	f44e                	sd	s3,40(sp)
 4dc:	0880                	addi	s0,sp,80
 4de:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4e0:	c6d1                	beqz	a3,56c <printint+0x9a>
 4e2:	0805d563          	bgez	a1,56c <printint+0x9a>
    neg = 1;
    x = -xx;
 4e6:	40b005b3          	neg	a1,a1
    neg = 1;
 4ea:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 4ec:	fb840993          	addi	s3,s0,-72
  neg = 0;
 4f0:	86ce                	mv	a3,s3
  i = 0;
 4f2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4f4:	00000817          	auipc	a6,0x0
 4f8:	63c80813          	addi	a6,a6,1596 # b30 <digits>
 4fc:	88ba                	mv	a7,a4
 4fe:	0017051b          	addiw	a0,a4,1
 502:	872a                	mv	a4,a0
 504:	02c5f7b3          	remu	a5,a1,a2
 508:	97c2                	add	a5,a5,a6
 50a:	0007c783          	lbu	a5,0(a5)
 50e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 512:	87ae                	mv	a5,a1
 514:	02c5d5b3          	divu	a1,a1,a2
 518:	0685                	addi	a3,a3,1
 51a:	fec7f1e3          	bgeu	a5,a2,4fc <printint+0x2a>
  if(neg)
 51e:	00030c63          	beqz	t1,536 <printint+0x64>
    buf[i++] = '-';
 522:	fd050793          	addi	a5,a0,-48
 526:	00878533          	add	a0,a5,s0
 52a:	02d00793          	li	a5,45
 52e:	fef50423          	sb	a5,-24(a0)
 532:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 536:	02e05563          	blez	a4,560 <printint+0x8e>
 53a:	fc26                	sd	s1,56(sp)
 53c:	377d                	addiw	a4,a4,-1
 53e:	00e984b3          	add	s1,s3,a4
 542:	19fd                	addi	s3,s3,-1
 544:	99ba                	add	s3,s3,a4
 546:	1702                	slli	a4,a4,0x20
 548:	9301                	srli	a4,a4,0x20
 54a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 54e:	0004c583          	lbu	a1,0(s1)
 552:	854a                	mv	a0,s2
 554:	f61ff0ef          	jal	4b4 <putc>
  while(--i >= 0)
 558:	14fd                	addi	s1,s1,-1
 55a:	ff349ae3          	bne	s1,s3,54e <printint+0x7c>
 55e:	74e2                	ld	s1,56(sp)
}
 560:	60a6                	ld	ra,72(sp)
 562:	6406                	ld	s0,64(sp)
 564:	7942                	ld	s2,48(sp)
 566:	79a2                	ld	s3,40(sp)
 568:	6161                	addi	sp,sp,80
 56a:	8082                	ret
  neg = 0;
 56c:	4301                	li	t1,0
 56e:	bfbd                	j	4ec <printint+0x1a>

0000000000000570 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 570:	711d                	addi	sp,sp,-96
 572:	ec86                	sd	ra,88(sp)
 574:	e8a2                	sd	s0,80(sp)
 576:	e4a6                	sd	s1,72(sp)
 578:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 57a:	0005c483          	lbu	s1,0(a1)
 57e:	22048363          	beqz	s1,7a4 <vprintf+0x234>
 582:	e0ca                	sd	s2,64(sp)
 584:	fc4e                	sd	s3,56(sp)
 586:	f852                	sd	s4,48(sp)
 588:	f456                	sd	s5,40(sp)
 58a:	f05a                	sd	s6,32(sp)
 58c:	ec5e                	sd	s7,24(sp)
 58e:	e862                	sd	s8,16(sp)
 590:	8b2a                	mv	s6,a0
 592:	8a2e                	mv	s4,a1
 594:	8bb2                	mv	s7,a2
  state = 0;
 596:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 598:	4901                	li	s2,0
 59a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 59c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5a0:	06400c13          	li	s8,100
 5a4:	a00d                	j	5c6 <vprintf+0x56>
        putc(fd, c0);
 5a6:	85a6                	mv	a1,s1
 5a8:	855a                	mv	a0,s6
 5aa:	f0bff0ef          	jal	4b4 <putc>
 5ae:	a019                	j	5b4 <vprintf+0x44>
    } else if(state == '%'){
 5b0:	03598363          	beq	s3,s5,5d6 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 5b4:	0019079b          	addiw	a5,s2,1
 5b8:	893e                	mv	s2,a5
 5ba:	873e                	mv	a4,a5
 5bc:	97d2                	add	a5,a5,s4
 5be:	0007c483          	lbu	s1,0(a5)
 5c2:	1c048a63          	beqz	s1,796 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 5c6:	0004879b          	sext.w	a5,s1
    if(state == 0){
 5ca:	fe0993e3          	bnez	s3,5b0 <vprintf+0x40>
      if(c0 == '%'){
 5ce:	fd579ce3          	bne	a5,s5,5a6 <vprintf+0x36>
        state = '%';
 5d2:	89be                	mv	s3,a5
 5d4:	b7c5                	j	5b4 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 5d6:	00ea06b3          	add	a3,s4,a4
 5da:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 5de:	1c060863          	beqz	a2,7ae <vprintf+0x23e>
      if(c0 == 'd'){
 5e2:	03878763          	beq	a5,s8,610 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5e6:	f9478693          	addi	a3,a5,-108
 5ea:	0016b693          	seqz	a3,a3
 5ee:	f9c60593          	addi	a1,a2,-100
 5f2:	e99d                	bnez	a1,628 <vprintf+0xb8>
 5f4:	ca95                	beqz	a3,628 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5f6:	008b8493          	addi	s1,s7,8
 5fa:	4685                	li	a3,1
 5fc:	4629                	li	a2,10
 5fe:	000bb583          	ld	a1,0(s7)
 602:	855a                	mv	a0,s6
 604:	ecfff0ef          	jal	4d2 <printint>
        i += 1;
 608:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 60a:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 60c:	4981                	li	s3,0
 60e:	b75d                	j	5b4 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 610:	008b8493          	addi	s1,s7,8
 614:	4685                	li	a3,1
 616:	4629                	li	a2,10
 618:	000ba583          	lw	a1,0(s7)
 61c:	855a                	mv	a0,s6
 61e:	eb5ff0ef          	jal	4d2 <printint>
 622:	8ba6                	mv	s7,s1
      state = 0;
 624:	4981                	li	s3,0
 626:	b779                	j	5b4 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 628:	9752                	add	a4,a4,s4
 62a:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 62e:	f9460713          	addi	a4,a2,-108
 632:	00173713          	seqz	a4,a4
 636:	8f75                	and	a4,a4,a3
 638:	f9c58513          	addi	a0,a1,-100
 63c:	18051363          	bnez	a0,7c2 <vprintf+0x252>
 640:	18070163          	beqz	a4,7c2 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 644:	008b8493          	addi	s1,s7,8
 648:	4685                	li	a3,1
 64a:	4629                	li	a2,10
 64c:	000bb583          	ld	a1,0(s7)
 650:	855a                	mv	a0,s6
 652:	e81ff0ef          	jal	4d2 <printint>
        i += 2;
 656:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 658:	8ba6                	mv	s7,s1
      state = 0;
 65a:	4981                	li	s3,0
        i += 2;
 65c:	bfa1                	j	5b4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 65e:	008b8493          	addi	s1,s7,8
 662:	4681                	li	a3,0
 664:	4629                	li	a2,10
 666:	000be583          	lwu	a1,0(s7)
 66a:	855a                	mv	a0,s6
 66c:	e67ff0ef          	jal	4d2 <printint>
 670:	8ba6                	mv	s7,s1
      state = 0;
 672:	4981                	li	s3,0
 674:	b781                	j	5b4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 676:	008b8493          	addi	s1,s7,8
 67a:	4681                	li	a3,0
 67c:	4629                	li	a2,10
 67e:	000bb583          	ld	a1,0(s7)
 682:	855a                	mv	a0,s6
 684:	e4fff0ef          	jal	4d2 <printint>
        i += 1;
 688:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 68a:	8ba6                	mv	s7,s1
      state = 0;
 68c:	4981                	li	s3,0
 68e:	b71d                	j	5b4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 690:	008b8493          	addi	s1,s7,8
 694:	4681                	li	a3,0
 696:	4629                	li	a2,10
 698:	000bb583          	ld	a1,0(s7)
 69c:	855a                	mv	a0,s6
 69e:	e35ff0ef          	jal	4d2 <printint>
        i += 2;
 6a2:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a4:	8ba6                	mv	s7,s1
      state = 0;
 6a6:	4981                	li	s3,0
        i += 2;
 6a8:	b731                	j	5b4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6aa:	008b8493          	addi	s1,s7,8
 6ae:	4681                	li	a3,0
 6b0:	4641                	li	a2,16
 6b2:	000be583          	lwu	a1,0(s7)
 6b6:	855a                	mv	a0,s6
 6b8:	e1bff0ef          	jal	4d2 <printint>
 6bc:	8ba6                	mv	s7,s1
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	bdd5                	j	5b4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c2:	008b8493          	addi	s1,s7,8
 6c6:	4681                	li	a3,0
 6c8:	4641                	li	a2,16
 6ca:	000bb583          	ld	a1,0(s7)
 6ce:	855a                	mv	a0,s6
 6d0:	e03ff0ef          	jal	4d2 <printint>
        i += 1;
 6d4:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d6:	8ba6                	mv	s7,s1
      state = 0;
 6d8:	4981                	li	s3,0
 6da:	bde9                	j	5b4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6dc:	008b8493          	addi	s1,s7,8
 6e0:	4681                	li	a3,0
 6e2:	4641                	li	a2,16
 6e4:	000bb583          	ld	a1,0(s7)
 6e8:	855a                	mv	a0,s6
 6ea:	de9ff0ef          	jal	4d2 <printint>
        i += 2;
 6ee:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6f0:	8ba6                	mv	s7,s1
      state = 0;
 6f2:	4981                	li	s3,0
        i += 2;
 6f4:	b5c1                	j	5b4 <vprintf+0x44>
 6f6:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 6f8:	008b8793          	addi	a5,s7,8
 6fc:	8cbe                	mv	s9,a5
 6fe:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 702:	03000593          	li	a1,48
 706:	855a                	mv	a0,s6
 708:	dadff0ef          	jal	4b4 <putc>
  putc(fd, 'x');
 70c:	07800593          	li	a1,120
 710:	855a                	mv	a0,s6
 712:	da3ff0ef          	jal	4b4 <putc>
 716:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 718:	00000b97          	auipc	s7,0x0
 71c:	418b8b93          	addi	s7,s7,1048 # b30 <digits>
 720:	03c9d793          	srli	a5,s3,0x3c
 724:	97de                	add	a5,a5,s7
 726:	0007c583          	lbu	a1,0(a5)
 72a:	855a                	mv	a0,s6
 72c:	d89ff0ef          	jal	4b4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 730:	0992                	slli	s3,s3,0x4
 732:	34fd                	addiw	s1,s1,-1
 734:	f4f5                	bnez	s1,720 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 736:	8be6                	mv	s7,s9
      state = 0;
 738:	4981                	li	s3,0
 73a:	6ca2                	ld	s9,8(sp)
 73c:	bda5                	j	5b4 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 73e:	008b8493          	addi	s1,s7,8
 742:	000bc583          	lbu	a1,0(s7)
 746:	855a                	mv	a0,s6
 748:	d6dff0ef          	jal	4b4 <putc>
 74c:	8ba6                	mv	s7,s1
      state = 0;
 74e:	4981                	li	s3,0
 750:	b595                	j	5b4 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 752:	008b8993          	addi	s3,s7,8
 756:	000bb483          	ld	s1,0(s7)
 75a:	cc91                	beqz	s1,776 <vprintf+0x206>
        for(; *s; s++)
 75c:	0004c583          	lbu	a1,0(s1)
 760:	c985                	beqz	a1,790 <vprintf+0x220>
          putc(fd, *s);
 762:	855a                	mv	a0,s6
 764:	d51ff0ef          	jal	4b4 <putc>
        for(; *s; s++)
 768:	0485                	addi	s1,s1,1
 76a:	0004c583          	lbu	a1,0(s1)
 76e:	f9f5                	bnez	a1,762 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 770:	8bce                	mv	s7,s3
      state = 0;
 772:	4981                	li	s3,0
 774:	b581                	j	5b4 <vprintf+0x44>
          s = "(null)";
 776:	00000497          	auipc	s1,0x0
 77a:	3b248493          	addi	s1,s1,946 # b28 <malloc+0x216>
        for(; *s; s++)
 77e:	02800593          	li	a1,40
 782:	b7c5                	j	762 <vprintf+0x1f2>
        putc(fd, '%');
 784:	85be                	mv	a1,a5
 786:	855a                	mv	a0,s6
 788:	d2dff0ef          	jal	4b4 <putc>
      state = 0;
 78c:	4981                	li	s3,0
 78e:	b51d                	j	5b4 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 790:	8bce                	mv	s7,s3
      state = 0;
 792:	4981                	li	s3,0
 794:	b505                	j	5b4 <vprintf+0x44>
 796:	6906                	ld	s2,64(sp)
 798:	79e2                	ld	s3,56(sp)
 79a:	7a42                	ld	s4,48(sp)
 79c:	7aa2                	ld	s5,40(sp)
 79e:	7b02                	ld	s6,32(sp)
 7a0:	6be2                	ld	s7,24(sp)
 7a2:	6c42                	ld	s8,16(sp)
    }
  }
}
 7a4:	60e6                	ld	ra,88(sp)
 7a6:	6446                	ld	s0,80(sp)
 7a8:	64a6                	ld	s1,72(sp)
 7aa:	6125                	addi	sp,sp,96
 7ac:	8082                	ret
      if(c0 == 'd'){
 7ae:	06400713          	li	a4,100
 7b2:	e4e78fe3          	beq	a5,a4,610 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 7b6:	f9478693          	addi	a3,a5,-108
 7ba:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 7be:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7c0:	4701                	li	a4,0
      } else if(c0 == 'u'){
 7c2:	07500513          	li	a0,117
 7c6:	e8a78ce3          	beq	a5,a0,65e <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 7ca:	f8b60513          	addi	a0,a2,-117
 7ce:	e119                	bnez	a0,7d4 <vprintf+0x264>
 7d0:	ea0693e3          	bnez	a3,676 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7d4:	f8b58513          	addi	a0,a1,-117
 7d8:	e119                	bnez	a0,7de <vprintf+0x26e>
 7da:	ea071be3          	bnez	a4,690 <vprintf+0x120>
      } else if(c0 == 'x'){
 7de:	07800513          	li	a0,120
 7e2:	eca784e3          	beq	a5,a0,6aa <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 7e6:	f8860613          	addi	a2,a2,-120
 7ea:	e219                	bnez	a2,7f0 <vprintf+0x280>
 7ec:	ec069be3          	bnez	a3,6c2 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7f0:	f8858593          	addi	a1,a1,-120
 7f4:	e199                	bnez	a1,7fa <vprintf+0x28a>
 7f6:	ee0713e3          	bnez	a4,6dc <vprintf+0x16c>
      } else if(c0 == 'p'){
 7fa:	07000713          	li	a4,112
 7fe:	eee78ce3          	beq	a5,a4,6f6 <vprintf+0x186>
      } else if(c0 == 'c'){
 802:	06300713          	li	a4,99
 806:	f2e78ce3          	beq	a5,a4,73e <vprintf+0x1ce>
      } else if(c0 == 's'){
 80a:	07300713          	li	a4,115
 80e:	f4e782e3          	beq	a5,a4,752 <vprintf+0x1e2>
      } else if(c0 == '%'){
 812:	02500713          	li	a4,37
 816:	f6e787e3          	beq	a5,a4,784 <vprintf+0x214>
        putc(fd, '%');
 81a:	02500593          	li	a1,37
 81e:	855a                	mv	a0,s6
 820:	c95ff0ef          	jal	4b4 <putc>
        putc(fd, c0);
 824:	85a6                	mv	a1,s1
 826:	855a                	mv	a0,s6
 828:	c8dff0ef          	jal	4b4 <putc>
      state = 0;
 82c:	4981                	li	s3,0
 82e:	b359                	j	5b4 <vprintf+0x44>

0000000000000830 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 830:	715d                	addi	sp,sp,-80
 832:	ec06                	sd	ra,24(sp)
 834:	e822                	sd	s0,16(sp)
 836:	1000                	addi	s0,sp,32
 838:	e010                	sd	a2,0(s0)
 83a:	e414                	sd	a3,8(s0)
 83c:	e818                	sd	a4,16(s0)
 83e:	ec1c                	sd	a5,24(s0)
 840:	03043023          	sd	a6,32(s0)
 844:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 848:	8622                	mv	a2,s0
 84a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 84e:	d23ff0ef          	jal	570 <vprintf>
}
 852:	60e2                	ld	ra,24(sp)
 854:	6442                	ld	s0,16(sp)
 856:	6161                	addi	sp,sp,80
 858:	8082                	ret

000000000000085a <printf>:

void
printf(const char *fmt, ...)
{
 85a:	711d                	addi	sp,sp,-96
 85c:	ec06                	sd	ra,24(sp)
 85e:	e822                	sd	s0,16(sp)
 860:	1000                	addi	s0,sp,32
 862:	e40c                	sd	a1,8(s0)
 864:	e810                	sd	a2,16(s0)
 866:	ec14                	sd	a3,24(s0)
 868:	f018                	sd	a4,32(s0)
 86a:	f41c                	sd	a5,40(s0)
 86c:	03043823          	sd	a6,48(s0)
 870:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 874:	00840613          	addi	a2,s0,8
 878:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 87c:	85aa                	mv	a1,a0
 87e:	4505                	li	a0,1
 880:	cf1ff0ef          	jal	570 <vprintf>
}
 884:	60e2                	ld	ra,24(sp)
 886:	6442                	ld	s0,16(sp)
 888:	6125                	addi	sp,sp,96
 88a:	8082                	ret

000000000000088c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 88c:	1141                	addi	sp,sp,-16
 88e:	e406                	sd	ra,8(sp)
 890:	e022                	sd	s0,0(sp)
 892:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 894:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 898:	00000797          	auipc	a5,0x0
 89c:	7687b783          	ld	a5,1896(a5) # 1000 <freep>
 8a0:	a039                	j	8ae <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a2:	6398                	ld	a4,0(a5)
 8a4:	00e7e463          	bltu	a5,a4,8ac <free+0x20>
 8a8:	00e6ea63          	bltu	a3,a4,8bc <free+0x30>
{
 8ac:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ae:	fed7fae3          	bgeu	a5,a3,8a2 <free+0x16>
 8b2:	6398                	ld	a4,0(a5)
 8b4:	00e6e463          	bltu	a3,a4,8bc <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8b8:	fee7eae3          	bltu	a5,a4,8ac <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8bc:	ff852583          	lw	a1,-8(a0)
 8c0:	6390                	ld	a2,0(a5)
 8c2:	02059813          	slli	a6,a1,0x20
 8c6:	01c85713          	srli	a4,a6,0x1c
 8ca:	9736                	add	a4,a4,a3
 8cc:	02e60563          	beq	a2,a4,8f6 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 8d0:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 8d4:	4790                	lw	a2,8(a5)
 8d6:	02061593          	slli	a1,a2,0x20
 8da:	01c5d713          	srli	a4,a1,0x1c
 8de:	973e                	add	a4,a4,a5
 8e0:	02e68263          	beq	a3,a4,904 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 8e4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8e6:	00000717          	auipc	a4,0x0
 8ea:	70f73d23          	sd	a5,1818(a4) # 1000 <freep>
}
 8ee:	60a2                	ld	ra,8(sp)
 8f0:	6402                	ld	s0,0(sp)
 8f2:	0141                	addi	sp,sp,16
 8f4:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 8f6:	4618                	lw	a4,8(a2)
 8f8:	9f2d                	addw	a4,a4,a1
 8fa:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8fe:	6398                	ld	a4,0(a5)
 900:	6310                	ld	a2,0(a4)
 902:	b7f9                	j	8d0 <free+0x44>
    p->s.size += bp->s.size;
 904:	ff852703          	lw	a4,-8(a0)
 908:	9f31                	addw	a4,a4,a2
 90a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 90c:	ff053683          	ld	a3,-16(a0)
 910:	bfd1                	j	8e4 <free+0x58>

0000000000000912 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 912:	7139                	addi	sp,sp,-64
 914:	fc06                	sd	ra,56(sp)
 916:	f822                	sd	s0,48(sp)
 918:	f04a                	sd	s2,32(sp)
 91a:	ec4e                	sd	s3,24(sp)
 91c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 91e:	02051993          	slli	s3,a0,0x20
 922:	0209d993          	srli	s3,s3,0x20
 926:	09bd                	addi	s3,s3,15
 928:	0049d993          	srli	s3,s3,0x4
 92c:	2985                	addiw	s3,s3,1
 92e:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 930:	00000517          	auipc	a0,0x0
 934:	6d053503          	ld	a0,1744(a0) # 1000 <freep>
 938:	c905                	beqz	a0,968 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 93a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 93c:	4798                	lw	a4,8(a5)
 93e:	09377663          	bgeu	a4,s3,9ca <malloc+0xb8>
 942:	f426                	sd	s1,40(sp)
 944:	e852                	sd	s4,16(sp)
 946:	e456                	sd	s5,8(sp)
 948:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 94a:	8a4e                	mv	s4,s3
 94c:	6705                	lui	a4,0x1
 94e:	00e9f363          	bgeu	s3,a4,954 <malloc+0x42>
 952:	6a05                	lui	s4,0x1
 954:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 958:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 95c:	00000497          	auipc	s1,0x0
 960:	6a448493          	addi	s1,s1,1700 # 1000 <freep>
  if(p == SBRK_ERROR)
 964:	5afd                	li	s5,-1
 966:	a83d                	j	9a4 <malloc+0x92>
 968:	f426                	sd	s1,40(sp)
 96a:	e852                	sd	s4,16(sp)
 96c:	e456                	sd	s5,8(sp)
 96e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 970:	00000797          	auipc	a5,0x0
 974:	6a078793          	addi	a5,a5,1696 # 1010 <base>
 978:	00000717          	auipc	a4,0x0
 97c:	68f73423          	sd	a5,1672(a4) # 1000 <freep>
 980:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 982:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 986:	b7d1                	j	94a <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 988:	6398                	ld	a4,0(a5)
 98a:	e118                	sd	a4,0(a0)
 98c:	a899                	j	9e2 <malloc+0xd0>
  hp->s.size = nu;
 98e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 992:	0541                	addi	a0,a0,16
 994:	ef9ff0ef          	jal	88c <free>
  return freep;
 998:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 99a:	c125                	beqz	a0,9fa <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 99c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 99e:	4798                	lw	a4,8(a5)
 9a0:	03277163          	bgeu	a4,s2,9c2 <malloc+0xb0>
    if(p == freep)
 9a4:	6098                	ld	a4,0(s1)
 9a6:	853e                	mv	a0,a5
 9a8:	fef71ae3          	bne	a4,a5,99c <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 9ac:	8552                	mv	a0,s4
 9ae:	a23ff0ef          	jal	3d0 <sbrk>
  if(p == SBRK_ERROR)
 9b2:	fd551ee3          	bne	a0,s5,98e <malloc+0x7c>
        return 0;
 9b6:	4501                	li	a0,0
 9b8:	74a2                	ld	s1,40(sp)
 9ba:	6a42                	ld	s4,16(sp)
 9bc:	6aa2                	ld	s5,8(sp)
 9be:	6b02                	ld	s6,0(sp)
 9c0:	a03d                	j	9ee <malloc+0xdc>
 9c2:	74a2                	ld	s1,40(sp)
 9c4:	6a42                	ld	s4,16(sp)
 9c6:	6aa2                	ld	s5,8(sp)
 9c8:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9ca:	fae90fe3          	beq	s2,a4,988 <malloc+0x76>
        p->s.size -= nunits;
 9ce:	4137073b          	subw	a4,a4,s3
 9d2:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9d4:	02071693          	slli	a3,a4,0x20
 9d8:	01c6d713          	srli	a4,a3,0x1c
 9dc:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9de:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9e2:	00000717          	auipc	a4,0x0
 9e6:	60a73f23          	sd	a0,1566(a4) # 1000 <freep>
      return (void*)(p + 1);
 9ea:	01078513          	addi	a0,a5,16
  }
}
 9ee:	70e2                	ld	ra,56(sp)
 9f0:	7442                	ld	s0,48(sp)
 9f2:	7902                	ld	s2,32(sp)
 9f4:	69e2                	ld	s3,24(sp)
 9f6:	6121                	addi	sp,sp,64
 9f8:	8082                	ret
 9fa:	74a2                	ld	s1,40(sp)
 9fc:	6a42                	ld	s4,16(sp)
 9fe:	6aa2                	ld	s5,8(sp)
 a00:	6b02                	ld	s6,0(sp)
 a02:	b7f5                	j	9ee <malloc+0xdc>
