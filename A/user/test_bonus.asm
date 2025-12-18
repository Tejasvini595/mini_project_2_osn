
user/_test_bonus:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"

int main(void) {
   0:	81010113          	addi	sp,sp,-2032
   4:	7e113423          	sd	ra,2024(sp)
   8:	7e813023          	sd	s0,2016(sp)
   c:	7c913c23          	sd	s1,2008(sp)
  10:	7d213823          	sd	s2,2000(sp)
  14:	7d313423          	sd	s3,1992(sp)
  18:	7d413023          	sd	s4,1984(sp)
  1c:	7b513c23          	sd	s5,1976(sp)
  20:	7b613823          	sd	s6,1968(sp)
  24:	7f010413          	addi	s0,sp,2032
  28:	b9010113          	addi	sp,sp,-1136
    struct proc_mem_stat stat;
    
    printf("=== BONUS: LFU-Recent Algorithm Test ===\n");
  2c:	00001517          	auipc	a0,0x1
  30:	a5c50513          	addi	a0,a0,-1444 # a88 <malloc+0x122>
  34:	07b000ef          	jal	8ae <printf>
    
    // Test with FIFO first
    printf("\n1. Testing with FIFO algorithm (default):\n");
  38:	00001517          	auipc	a0,0x1
  3c:	a8050513          	addi	a0,a0,-1408 # ab8 <malloc+0x152>
  40:	06f000ef          	jal	8ae <printf>
    if (memstat(&stat) < 0) {
  44:	80040513          	addi	a0,s0,-2048
  48:	fc050513          	addi	a0,a0,-64
  4c:	be850513          	addi	a0,a0,-1048
  50:	4a8000ef          	jal	4f8 <memstat>
  54:	0c054763          	bltz	a0,122 <main+0x122>
        printf("memstat() failed\n");
        exit(1);
    }
    printf("  FIFO - Total pages: %d, Resident: %d, Swapped: %d\n", 
  58:	80040793          	addi	a5,s0,-2048
  5c:	fc078793          	addi	a5,a5,-64
  60:	bf47a683          	lw	a3,-1036(a5)
  64:	bf07a603          	lw	a2,-1040(a5)
  68:	bec7a583          	lw	a1,-1044(a5)
  6c:	00001517          	auipc	a0,0x1
  70:	a9450513          	addi	a0,a0,-1388 # b00 <malloc+0x19a>
  74:	03b000ef          	jal	8ae <printf>
           stat.num_pages_total, stat.num_resident_pages, stat.num_swapped_pages);
    
    // Enable bonus algorithm
    printf("\n2. Enabling LFU-Recent algorithm...\n");
  78:	00001517          	auipc	a0,0x1
  7c:	ac050513          	addi	a0,a0,-1344 # b38 <malloc+0x1d2>
  80:	02f000ef          	jal	8ae <printf>
    enable_bonus();
  84:	47c000ef          	jal	500 <enable_bonus>
    
    // Allocate some memory to trigger page usage
    char *ptr1 = sbrk(4096);  // Allocate 1 page
  88:	6505                	lui	a0,0x1
  8a:	39a000ef          	jal	424 <sbrk>
  8e:	84aa                	mv	s1,a0
    char *ptr2 = sbrk(4096);  // Allocate another page
  90:	6505                	lui	a0,0x1
  92:	392000ef          	jal	424 <sbrk>
    
    // Write to the pages to make them dirty and trigger access tracking
    *ptr1 = 'A';
    *ptr2 = 'B';
  96:	04200793          	li	a5,66
  9a:	00f50023          	sb	a5,0(a0) # 1000 <digits+0x3c0>
    
    // Access ptr1 multiple times to increase its frequency
    for(int i = 0; i < 5; i++) {
  9e:	04500793          	li	a5,69
  a2:	00f48023          	sb	a5,0(s1)
        *ptr1 = 'A' + i;
    }
    
    printf("\n3. Testing with LFU-Recent algorithm:\n");
  a6:	00001517          	auipc	a0,0x1
  aa:	aba50513          	addi	a0,a0,-1350 # b60 <malloc+0x1fa>
  ae:	001000ef          	jal	8ae <printf>
    if (memstat(&stat) < 0) {
  b2:	80040513          	addi	a0,s0,-2048
  b6:	fc050513          	addi	a0,a0,-64
  ba:	be850513          	addi	a0,a0,-1048
  be:	43a000ef          	jal	4f8 <memstat>
  c2:	06054963          	bltz	a0,134 <main+0x134>
        printf("memstat() failed\n");
        exit(1);
    }
    printf("  LFU-Recent - Total pages: %d, Resident: %d, Swapped: %d\n", 
  c6:	80040493          	addi	s1,s0,-2048
  ca:	fc048493          	addi	s1,s1,-64
  ce:	bf44a683          	lw	a3,-1036(s1)
  d2:	bf04a603          	lw	a2,-1040(s1)
  d6:	bec4a583          	lw	a1,-1044(s1)
  da:	00001517          	auipc	a0,0x1
  de:	aae50513          	addi	a0,a0,-1362 # b88 <malloc+0x222>
  e2:	7cc000ef          	jal	8ae <printf>
           stat.num_pages_total, stat.num_resident_pages, stat.num_swapped_pages);
    
    printf("\n4. Page details:\n");
  e6:	00001517          	auipc	a0,0x1
  ea:	ae250513          	addi	a0,a0,-1310 # bc8 <malloc+0x262>
  ee:	7c0000ef          	jal	8ae <printf>
    for(int i = 0; i < stat.num_pages_total && i < 10; i++) {
  f2:	bec4a783          	lw	a5,-1044(s1)
  f6:	08f05d63          	blez	a5,190 <main+0x190>
  fa:	80040493          	addi	s1,s0,-2048
  fe:	fc048493          	addi	s1,s1,-64
 102:	c0048493          	addi	s1,s1,-1024
 106:	4901                	li	s2,0
        if(stat.pages[i].va != 0) {
            printf("  Page %d: va=0x%lx state=%s dirty=%d\n", 
 108:	4a85                	li	s5,1
 10a:	00001a17          	auipc	s4,0x1
 10e:	ad6a0a13          	addi	s4,s4,-1322 # be0 <malloc+0x27a>
                   i, stat.pages[i].va, 
                   (stat.pages[i].state == RESIDENT) ? "RESIDENT" : 
                   (stat.pages[i].state == SWAPPED) ? "SWAPPED" : "UNMAPPED",
 112:	4b09                	li	s6,2
    for(int i = 0; i < stat.num_pages_total && i < 10; i++) {
 114:	80040993          	addi	s3,s0,-2048
 118:	fc098993          	addi	s3,s3,-64
 11c:	80098993          	addi	s3,s3,-2048
 120:	a099                	j	166 <main+0x166>
        printf("memstat() failed\n");
 122:	00001517          	auipc	a0,0x1
 126:	9c650513          	addi	a0,a0,-1594 # ae8 <malloc+0x182>
 12a:	784000ef          	jal	8ae <printf>
        exit(1);
 12e:	4505                	li	a0,1
 130:	328000ef          	jal	458 <exit>
        printf("memstat() failed\n");
 134:	00001517          	auipc	a0,0x1
 138:	9b450513          	addi	a0,a0,-1612 # ae8 <malloc+0x182>
 13c:	772000ef          	jal	8ae <printf>
        exit(1);
 140:	4505                	li	a0,1
 142:	316000ef          	jal	458 <exit>
            printf("  Page %d: va=0x%lx state=%s dirty=%d\n", 
 146:	47d8                	lw	a4,12(a5)
 148:	85ca                	mv	a1,s2
 14a:	8552                	mv	a0,s4
 14c:	762000ef          	jal	8ae <printf>
    for(int i = 0; i < stat.num_pages_total && i < 10; i++) {
 150:	0019079b          	addiw	a5,s2,1
 154:	893e                	mv	s2,a5
 156:	04e1                	addi	s1,s1,24
 158:	3ec9a703          	lw	a4,1004(s3)
 15c:	02e7da63          	bge	a5,a4,190 <main+0x190>
 160:	00a7a793          	slti	a5,a5,10
 164:	c795                	beqz	a5,190 <main+0x190>
        if(stat.pages[i].va != 0) {
 166:	87a6                	mv	a5,s1
 168:	6090                	ld	a2,0(s1)
 16a:	d27d                	beqz	a2,150 <main+0x150>
                   (stat.pages[i].state == RESIDENT) ? "RESIDENT" : 
 16c:	4498                	lw	a4,8(s1)
            printf("  Page %d: va=0x%lx state=%s dirty=%d\n", 
 16e:	00001697          	auipc	a3,0x1
 172:	90268693          	addi	a3,a3,-1790 # a70 <malloc+0x10a>
 176:	fd5708e3          	beq	a4,s5,146 <main+0x146>
 17a:	00001697          	auipc	a3,0x1
 17e:	8e668693          	addi	a3,a3,-1818 # a60 <malloc+0xfa>
                   (stat.pages[i].state == SWAPPED) ? "SWAPPED" : "UNMAPPED",
 182:	fd6712e3          	bne	a4,s6,146 <main+0x146>
            printf("  Page %d: va=0x%lx state=%s dirty=%d\n", 
 186:	00001697          	auipc	a3,0x1
 18a:	8fa68693          	addi	a3,a3,-1798 # a80 <malloc+0x11a>
 18e:	bf65                	j	146 <main+0x146>
                   stat.pages[i].is_dirty);
        }
    }
    
    printf("\nBONUS: LFU-Recent algorithm test completed!\n");
 190:	00001517          	auipc	a0,0x1
 194:	a7850513          	addi	a0,a0,-1416 # c08 <malloc+0x2a2>
 198:	716000ef          	jal	8ae <printf>
    exit(0);
 19c:	4501                	li	a0,0
 19e:	2ba000ef          	jal	458 <exit>

00000000000001a2 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1a2:	1141                	addi	sp,sp,-16
 1a4:	e406                	sd	ra,8(sp)
 1a6:	e022                	sd	s0,0(sp)
 1a8:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1aa:	e57ff0ef          	jal	0 <main>
  exit(r);
 1ae:	2aa000ef          	jal	458 <exit>

00000000000001b2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1b2:	1141                	addi	sp,sp,-16
 1b4:	e406                	sd	ra,8(sp)
 1b6:	e022                	sd	s0,0(sp)
 1b8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1ba:	87aa                	mv	a5,a0
 1bc:	0585                	addi	a1,a1,1
 1be:	0785                	addi	a5,a5,1
 1c0:	fff5c703          	lbu	a4,-1(a1)
 1c4:	fee78fa3          	sb	a4,-1(a5)
 1c8:	fb75                	bnez	a4,1bc <strcpy+0xa>
    ;
  return os;
}
 1ca:	60a2                	ld	ra,8(sp)
 1cc:	6402                	ld	s0,0(sp)
 1ce:	0141                	addi	sp,sp,16
 1d0:	8082                	ret

00000000000001d2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1d2:	1141                	addi	sp,sp,-16
 1d4:	e406                	sd	ra,8(sp)
 1d6:	e022                	sd	s0,0(sp)
 1d8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1da:	00054783          	lbu	a5,0(a0)
 1de:	cb91                	beqz	a5,1f2 <strcmp+0x20>
 1e0:	0005c703          	lbu	a4,0(a1)
 1e4:	00f71763          	bne	a4,a5,1f2 <strcmp+0x20>
    p++, q++;
 1e8:	0505                	addi	a0,a0,1
 1ea:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1ec:	00054783          	lbu	a5,0(a0)
 1f0:	fbe5                	bnez	a5,1e0 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 1f2:	0005c503          	lbu	a0,0(a1)
}
 1f6:	40a7853b          	subw	a0,a5,a0
 1fa:	60a2                	ld	ra,8(sp)
 1fc:	6402                	ld	s0,0(sp)
 1fe:	0141                	addi	sp,sp,16
 200:	8082                	ret

0000000000000202 <strlen>:

uint
strlen(const char *s)
{
 202:	1141                	addi	sp,sp,-16
 204:	e406                	sd	ra,8(sp)
 206:	e022                	sd	s0,0(sp)
 208:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 20a:	00054783          	lbu	a5,0(a0)
 20e:	cf91                	beqz	a5,22a <strlen+0x28>
 210:	00150793          	addi	a5,a0,1
 214:	86be                	mv	a3,a5
 216:	0785                	addi	a5,a5,1
 218:	fff7c703          	lbu	a4,-1(a5)
 21c:	ff65                	bnez	a4,214 <strlen+0x12>
 21e:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 222:	60a2                	ld	ra,8(sp)
 224:	6402                	ld	s0,0(sp)
 226:	0141                	addi	sp,sp,16
 228:	8082                	ret
  for(n = 0; s[n]; n++)
 22a:	4501                	li	a0,0
 22c:	bfdd                	j	222 <strlen+0x20>

000000000000022e <memset>:

void*
memset(void *dst, int c, uint n)
{
 22e:	1141                	addi	sp,sp,-16
 230:	e406                	sd	ra,8(sp)
 232:	e022                	sd	s0,0(sp)
 234:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 236:	ca19                	beqz	a2,24c <memset+0x1e>
 238:	87aa                	mv	a5,a0
 23a:	1602                	slli	a2,a2,0x20
 23c:	9201                	srli	a2,a2,0x20
 23e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 242:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 246:	0785                	addi	a5,a5,1
 248:	fee79de3          	bne	a5,a4,242 <memset+0x14>
  }
  return dst;
}
 24c:	60a2                	ld	ra,8(sp)
 24e:	6402                	ld	s0,0(sp)
 250:	0141                	addi	sp,sp,16
 252:	8082                	ret

0000000000000254 <strchr>:

char*
strchr(const char *s, char c)
{
 254:	1141                	addi	sp,sp,-16
 256:	e406                	sd	ra,8(sp)
 258:	e022                	sd	s0,0(sp)
 25a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 25c:	00054783          	lbu	a5,0(a0)
 260:	cf81                	beqz	a5,278 <strchr+0x24>
    if(*s == c)
 262:	00f58763          	beq	a1,a5,270 <strchr+0x1c>
  for(; *s; s++)
 266:	0505                	addi	a0,a0,1
 268:	00054783          	lbu	a5,0(a0)
 26c:	fbfd                	bnez	a5,262 <strchr+0xe>
      return (char*)s;
  return 0;
 26e:	4501                	li	a0,0
}
 270:	60a2                	ld	ra,8(sp)
 272:	6402                	ld	s0,0(sp)
 274:	0141                	addi	sp,sp,16
 276:	8082                	ret
  return 0;
 278:	4501                	li	a0,0
 27a:	bfdd                	j	270 <strchr+0x1c>

000000000000027c <gets>:

char*
gets(char *buf, int max)
{
 27c:	711d                	addi	sp,sp,-96
 27e:	ec86                	sd	ra,88(sp)
 280:	e8a2                	sd	s0,80(sp)
 282:	e4a6                	sd	s1,72(sp)
 284:	e0ca                	sd	s2,64(sp)
 286:	fc4e                	sd	s3,56(sp)
 288:	f852                	sd	s4,48(sp)
 28a:	f456                	sd	s5,40(sp)
 28c:	f05a                	sd	s6,32(sp)
 28e:	ec5e                	sd	s7,24(sp)
 290:	e862                	sd	s8,16(sp)
 292:	1080                	addi	s0,sp,96
 294:	8baa                	mv	s7,a0
 296:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 298:	892a                	mv	s2,a0
 29a:	4481                	li	s1,0
    cc = read(0, &c, 1);
 29c:	faf40b13          	addi	s6,s0,-81
 2a0:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 2a2:	8c26                	mv	s8,s1
 2a4:	0014899b          	addiw	s3,s1,1
 2a8:	84ce                	mv	s1,s3
 2aa:	0349d463          	bge	s3,s4,2d2 <gets+0x56>
    cc = read(0, &c, 1);
 2ae:	8656                	mv	a2,s5
 2b0:	85da                	mv	a1,s6
 2b2:	4501                	li	a0,0
 2b4:	1bc000ef          	jal	470 <read>
    if(cc < 1)
 2b8:	00a05d63          	blez	a0,2d2 <gets+0x56>
      break;
    buf[i++] = c;
 2bc:	faf44783          	lbu	a5,-81(s0)
 2c0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2c4:	0905                	addi	s2,s2,1
 2c6:	ff678713          	addi	a4,a5,-10
 2ca:	c319                	beqz	a4,2d0 <gets+0x54>
 2cc:	17cd                	addi	a5,a5,-13
 2ce:	fbf1                	bnez	a5,2a2 <gets+0x26>
    buf[i++] = c;
 2d0:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 2d2:	9c5e                	add	s8,s8,s7
 2d4:	000c0023          	sb	zero,0(s8)
  return buf;
}
 2d8:	855e                	mv	a0,s7
 2da:	60e6                	ld	ra,88(sp)
 2dc:	6446                	ld	s0,80(sp)
 2de:	64a6                	ld	s1,72(sp)
 2e0:	6906                	ld	s2,64(sp)
 2e2:	79e2                	ld	s3,56(sp)
 2e4:	7a42                	ld	s4,48(sp)
 2e6:	7aa2                	ld	s5,40(sp)
 2e8:	7b02                	ld	s6,32(sp)
 2ea:	6be2                	ld	s7,24(sp)
 2ec:	6c42                	ld	s8,16(sp)
 2ee:	6125                	addi	sp,sp,96
 2f0:	8082                	ret

00000000000002f2 <stat>:

int
stat(const char *n, struct stat *st)
{
 2f2:	1101                	addi	sp,sp,-32
 2f4:	ec06                	sd	ra,24(sp)
 2f6:	e822                	sd	s0,16(sp)
 2f8:	e04a                	sd	s2,0(sp)
 2fa:	1000                	addi	s0,sp,32
 2fc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2fe:	4581                	li	a1,0
 300:	198000ef          	jal	498 <open>
  if(fd < 0)
 304:	02054263          	bltz	a0,328 <stat+0x36>
 308:	e426                	sd	s1,8(sp)
 30a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 30c:	85ca                	mv	a1,s2
 30e:	1a2000ef          	jal	4b0 <fstat>
 312:	892a                	mv	s2,a0
  close(fd);
 314:	8526                	mv	a0,s1
 316:	16a000ef          	jal	480 <close>
  return r;
 31a:	64a2                	ld	s1,8(sp)
}
 31c:	854a                	mv	a0,s2
 31e:	60e2                	ld	ra,24(sp)
 320:	6442                	ld	s0,16(sp)
 322:	6902                	ld	s2,0(sp)
 324:	6105                	addi	sp,sp,32
 326:	8082                	ret
    return -1;
 328:	57fd                	li	a5,-1
 32a:	893e                	mv	s2,a5
 32c:	bfc5                	j	31c <stat+0x2a>

000000000000032e <atoi>:

int
atoi(const char *s)
{
 32e:	1141                	addi	sp,sp,-16
 330:	e406                	sd	ra,8(sp)
 332:	e022                	sd	s0,0(sp)
 334:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 336:	00054683          	lbu	a3,0(a0)
 33a:	fd06879b          	addiw	a5,a3,-48
 33e:	0ff7f793          	zext.b	a5,a5
 342:	4625                	li	a2,9
 344:	02f66963          	bltu	a2,a5,376 <atoi+0x48>
 348:	872a                	mv	a4,a0
  n = 0;
 34a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 34c:	0705                	addi	a4,a4,1
 34e:	0025179b          	slliw	a5,a0,0x2
 352:	9fa9                	addw	a5,a5,a0
 354:	0017979b          	slliw	a5,a5,0x1
 358:	9fb5                	addw	a5,a5,a3
 35a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 35e:	00074683          	lbu	a3,0(a4)
 362:	fd06879b          	addiw	a5,a3,-48
 366:	0ff7f793          	zext.b	a5,a5
 36a:	fef671e3          	bgeu	a2,a5,34c <atoi+0x1e>
  return n;
}
 36e:	60a2                	ld	ra,8(sp)
 370:	6402                	ld	s0,0(sp)
 372:	0141                	addi	sp,sp,16
 374:	8082                	ret
  n = 0;
 376:	4501                	li	a0,0
 378:	bfdd                	j	36e <atoi+0x40>

000000000000037a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 37a:	1141                	addi	sp,sp,-16
 37c:	e406                	sd	ra,8(sp)
 37e:	e022                	sd	s0,0(sp)
 380:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 382:	02b57563          	bgeu	a0,a1,3ac <memmove+0x32>
    while(n-- > 0)
 386:	00c05f63          	blez	a2,3a4 <memmove+0x2a>
 38a:	1602                	slli	a2,a2,0x20
 38c:	9201                	srli	a2,a2,0x20
 38e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 392:	872a                	mv	a4,a0
      *dst++ = *src++;
 394:	0585                	addi	a1,a1,1
 396:	0705                	addi	a4,a4,1
 398:	fff5c683          	lbu	a3,-1(a1)
 39c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3a0:	fee79ae3          	bne	a5,a4,394 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3a4:	60a2                	ld	ra,8(sp)
 3a6:	6402                	ld	s0,0(sp)
 3a8:	0141                	addi	sp,sp,16
 3aa:	8082                	ret
    while(n-- > 0)
 3ac:	fec05ce3          	blez	a2,3a4 <memmove+0x2a>
    dst += n;
 3b0:	00c50733          	add	a4,a0,a2
    src += n;
 3b4:	95b2                	add	a1,a1,a2
 3b6:	fff6079b          	addiw	a5,a2,-1
 3ba:	1782                	slli	a5,a5,0x20
 3bc:	9381                	srli	a5,a5,0x20
 3be:	fff7c793          	not	a5,a5
 3c2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3c4:	15fd                	addi	a1,a1,-1
 3c6:	177d                	addi	a4,a4,-1
 3c8:	0005c683          	lbu	a3,0(a1)
 3cc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3d0:	fef71ae3          	bne	a4,a5,3c4 <memmove+0x4a>
 3d4:	bfc1                	j	3a4 <memmove+0x2a>

00000000000003d6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3d6:	1141                	addi	sp,sp,-16
 3d8:	e406                	sd	ra,8(sp)
 3da:	e022                	sd	s0,0(sp)
 3dc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3de:	c61d                	beqz	a2,40c <memcmp+0x36>
 3e0:	1602                	slli	a2,a2,0x20
 3e2:	9201                	srli	a2,a2,0x20
 3e4:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 3e8:	00054783          	lbu	a5,0(a0)
 3ec:	0005c703          	lbu	a4,0(a1)
 3f0:	00e79863          	bne	a5,a4,400 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 3f4:	0505                	addi	a0,a0,1
    p2++;
 3f6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3f8:	fed518e3          	bne	a0,a3,3e8 <memcmp+0x12>
  }
  return 0;
 3fc:	4501                	li	a0,0
 3fe:	a019                	j	404 <memcmp+0x2e>
      return *p1 - *p2;
 400:	40e7853b          	subw	a0,a5,a4
}
 404:	60a2                	ld	ra,8(sp)
 406:	6402                	ld	s0,0(sp)
 408:	0141                	addi	sp,sp,16
 40a:	8082                	ret
  return 0;
 40c:	4501                	li	a0,0
 40e:	bfdd                	j	404 <memcmp+0x2e>

0000000000000410 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 410:	1141                	addi	sp,sp,-16
 412:	e406                	sd	ra,8(sp)
 414:	e022                	sd	s0,0(sp)
 416:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 418:	f63ff0ef          	jal	37a <memmove>
}
 41c:	60a2                	ld	ra,8(sp)
 41e:	6402                	ld	s0,0(sp)
 420:	0141                	addi	sp,sp,16
 422:	8082                	ret

0000000000000424 <sbrk>:

char *
sbrk(int n) {
 424:	1141                	addi	sp,sp,-16
 426:	e406                	sd	ra,8(sp)
 428:	e022                	sd	s0,0(sp)
 42a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 42c:	4585                	li	a1,1
 42e:	0b2000ef          	jal	4e0 <sys_sbrk>
}
 432:	60a2                	ld	ra,8(sp)
 434:	6402                	ld	s0,0(sp)
 436:	0141                	addi	sp,sp,16
 438:	8082                	ret

000000000000043a <sbrklazy>:

char *
sbrklazy(int n) {
 43a:	1141                	addi	sp,sp,-16
 43c:	e406                	sd	ra,8(sp)
 43e:	e022                	sd	s0,0(sp)
 440:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 442:	4589                	li	a1,2
 444:	09c000ef          	jal	4e0 <sys_sbrk>
}
 448:	60a2                	ld	ra,8(sp)
 44a:	6402                	ld	s0,0(sp)
 44c:	0141                	addi	sp,sp,16
 44e:	8082                	ret

0000000000000450 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 450:	4885                	li	a7,1
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <exit>:
.global exit
exit:
 li a7, SYS_exit
 458:	4889                	li	a7,2
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <wait>:
.global wait
wait:
 li a7, SYS_wait
 460:	488d                	li	a7,3
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 468:	4891                	li	a7,4
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <read>:
.global read
read:
 li a7, SYS_read
 470:	4895                	li	a7,5
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <write>:
.global write
write:
 li a7, SYS_write
 478:	48c1                	li	a7,16
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <close>:
.global close
close:
 li a7, SYS_close
 480:	48d5                	li	a7,21
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <kill>:
.global kill
kill:
 li a7, SYS_kill
 488:	4899                	li	a7,6
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <exec>:
.global exec
exec:
 li a7, SYS_exec
 490:	489d                	li	a7,7
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <open>:
.global open
open:
 li a7, SYS_open
 498:	48bd                	li	a7,15
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4a0:	48c5                	li	a7,17
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4a8:	48c9                	li	a7,18
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4b0:	48a1                	li	a7,8
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <link>:
.global link
link:
 li a7, SYS_link
 4b8:	48cd                	li	a7,19
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4c0:	48d1                	li	a7,20
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4c8:	48a5                	li	a7,9
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4d0:	48a9                	li	a7,10
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4d8:	48ad                	li	a7,11
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4e0:	48b1                	li	a7,12
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <pause>:
.global pause
pause:
 li a7, SYS_pause
 4e8:	48b5                	li	a7,13
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4f0:	48b9                	li	a7,14
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <memstat>:
.global memstat
memstat:
 li a7, SYS_memstat
 4f8:	48d9                	li	a7,22
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <enable_bonus>:
.global enable_bonus
enable_bonus:
 li a7, SYS_enable_bonus
 500:	48dd                	li	a7,23
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 508:	1101                	addi	sp,sp,-32
 50a:	ec06                	sd	ra,24(sp)
 50c:	e822                	sd	s0,16(sp)
 50e:	1000                	addi	s0,sp,32
 510:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 514:	4605                	li	a2,1
 516:	fef40593          	addi	a1,s0,-17
 51a:	f5fff0ef          	jal	478 <write>
}
 51e:	60e2                	ld	ra,24(sp)
 520:	6442                	ld	s0,16(sp)
 522:	6105                	addi	sp,sp,32
 524:	8082                	ret

0000000000000526 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 526:	715d                	addi	sp,sp,-80
 528:	e486                	sd	ra,72(sp)
 52a:	e0a2                	sd	s0,64(sp)
 52c:	f84a                	sd	s2,48(sp)
 52e:	f44e                	sd	s3,40(sp)
 530:	0880                	addi	s0,sp,80
 532:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 534:	c6d1                	beqz	a3,5c0 <printint+0x9a>
 536:	0805d563          	bgez	a1,5c0 <printint+0x9a>
    neg = 1;
    x = -xx;
 53a:	40b005b3          	neg	a1,a1
    neg = 1;
 53e:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 540:	fb840993          	addi	s3,s0,-72
  neg = 0;
 544:	86ce                	mv	a3,s3
  i = 0;
 546:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 548:	00000817          	auipc	a6,0x0
 54c:	6f880813          	addi	a6,a6,1784 # c40 <digits>
 550:	88ba                	mv	a7,a4
 552:	0017051b          	addiw	a0,a4,1
 556:	872a                	mv	a4,a0
 558:	02c5f7b3          	remu	a5,a1,a2
 55c:	97c2                	add	a5,a5,a6
 55e:	0007c783          	lbu	a5,0(a5)
 562:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 566:	87ae                	mv	a5,a1
 568:	02c5d5b3          	divu	a1,a1,a2
 56c:	0685                	addi	a3,a3,1
 56e:	fec7f1e3          	bgeu	a5,a2,550 <printint+0x2a>
  if(neg)
 572:	00030c63          	beqz	t1,58a <printint+0x64>
    buf[i++] = '-';
 576:	fd050793          	addi	a5,a0,-48
 57a:	00878533          	add	a0,a5,s0
 57e:	02d00793          	li	a5,45
 582:	fef50423          	sb	a5,-24(a0)
 586:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 58a:	02e05563          	blez	a4,5b4 <printint+0x8e>
 58e:	fc26                	sd	s1,56(sp)
 590:	377d                	addiw	a4,a4,-1
 592:	00e984b3          	add	s1,s3,a4
 596:	19fd                	addi	s3,s3,-1
 598:	99ba                	add	s3,s3,a4
 59a:	1702                	slli	a4,a4,0x20
 59c:	9301                	srli	a4,a4,0x20
 59e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5a2:	0004c583          	lbu	a1,0(s1)
 5a6:	854a                	mv	a0,s2
 5a8:	f61ff0ef          	jal	508 <putc>
  while(--i >= 0)
 5ac:	14fd                	addi	s1,s1,-1
 5ae:	ff349ae3          	bne	s1,s3,5a2 <printint+0x7c>
 5b2:	74e2                	ld	s1,56(sp)
}
 5b4:	60a6                	ld	ra,72(sp)
 5b6:	6406                	ld	s0,64(sp)
 5b8:	7942                	ld	s2,48(sp)
 5ba:	79a2                	ld	s3,40(sp)
 5bc:	6161                	addi	sp,sp,80
 5be:	8082                	ret
  neg = 0;
 5c0:	4301                	li	t1,0
 5c2:	bfbd                	j	540 <printint+0x1a>

00000000000005c4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5c4:	711d                	addi	sp,sp,-96
 5c6:	ec86                	sd	ra,88(sp)
 5c8:	e8a2                	sd	s0,80(sp)
 5ca:	e4a6                	sd	s1,72(sp)
 5cc:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5ce:	0005c483          	lbu	s1,0(a1)
 5d2:	22048363          	beqz	s1,7f8 <vprintf+0x234>
 5d6:	e0ca                	sd	s2,64(sp)
 5d8:	fc4e                	sd	s3,56(sp)
 5da:	f852                	sd	s4,48(sp)
 5dc:	f456                	sd	s5,40(sp)
 5de:	f05a                	sd	s6,32(sp)
 5e0:	ec5e                	sd	s7,24(sp)
 5e2:	e862                	sd	s8,16(sp)
 5e4:	8b2a                	mv	s6,a0
 5e6:	8a2e                	mv	s4,a1
 5e8:	8bb2                	mv	s7,a2
  state = 0;
 5ea:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5ec:	4901                	li	s2,0
 5ee:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5f0:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5f4:	06400c13          	li	s8,100
 5f8:	a00d                	j	61a <vprintf+0x56>
        putc(fd, c0);
 5fa:	85a6                	mv	a1,s1
 5fc:	855a                	mv	a0,s6
 5fe:	f0bff0ef          	jal	508 <putc>
 602:	a019                	j	608 <vprintf+0x44>
    } else if(state == '%'){
 604:	03598363          	beq	s3,s5,62a <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 608:	0019079b          	addiw	a5,s2,1
 60c:	893e                	mv	s2,a5
 60e:	873e                	mv	a4,a5
 610:	97d2                	add	a5,a5,s4
 612:	0007c483          	lbu	s1,0(a5)
 616:	1c048a63          	beqz	s1,7ea <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 61a:	0004879b          	sext.w	a5,s1
    if(state == 0){
 61e:	fe0993e3          	bnez	s3,604 <vprintf+0x40>
      if(c0 == '%'){
 622:	fd579ce3          	bne	a5,s5,5fa <vprintf+0x36>
        state = '%';
 626:	89be                	mv	s3,a5
 628:	b7c5                	j	608 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 62a:	00ea06b3          	add	a3,s4,a4
 62e:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 632:	1c060863          	beqz	a2,802 <vprintf+0x23e>
      if(c0 == 'd'){
 636:	03878763          	beq	a5,s8,664 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 63a:	f9478693          	addi	a3,a5,-108
 63e:	0016b693          	seqz	a3,a3
 642:	f9c60593          	addi	a1,a2,-100
 646:	e99d                	bnez	a1,67c <vprintf+0xb8>
 648:	ca95                	beqz	a3,67c <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 64a:	008b8493          	addi	s1,s7,8
 64e:	4685                	li	a3,1
 650:	4629                	li	a2,10
 652:	000bb583          	ld	a1,0(s7)
 656:	855a                	mv	a0,s6
 658:	ecfff0ef          	jal	526 <printint>
        i += 1;
 65c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 65e:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 660:	4981                	li	s3,0
 662:	b75d                	j	608 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 664:	008b8493          	addi	s1,s7,8
 668:	4685                	li	a3,1
 66a:	4629                	li	a2,10
 66c:	000ba583          	lw	a1,0(s7)
 670:	855a                	mv	a0,s6
 672:	eb5ff0ef          	jal	526 <printint>
 676:	8ba6                	mv	s7,s1
      state = 0;
 678:	4981                	li	s3,0
 67a:	b779                	j	608 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 67c:	9752                	add	a4,a4,s4
 67e:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 682:	f9460713          	addi	a4,a2,-108
 686:	00173713          	seqz	a4,a4
 68a:	8f75                	and	a4,a4,a3
 68c:	f9c58513          	addi	a0,a1,-100
 690:	18051363          	bnez	a0,816 <vprintf+0x252>
 694:	18070163          	beqz	a4,816 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 698:	008b8493          	addi	s1,s7,8
 69c:	4685                	li	a3,1
 69e:	4629                	li	a2,10
 6a0:	000bb583          	ld	a1,0(s7)
 6a4:	855a                	mv	a0,s6
 6a6:	e81ff0ef          	jal	526 <printint>
        i += 2;
 6aa:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6ac:	8ba6                	mv	s7,s1
      state = 0;
 6ae:	4981                	li	s3,0
        i += 2;
 6b0:	bfa1                	j	608 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6b2:	008b8493          	addi	s1,s7,8
 6b6:	4681                	li	a3,0
 6b8:	4629                	li	a2,10
 6ba:	000be583          	lwu	a1,0(s7)
 6be:	855a                	mv	a0,s6
 6c0:	e67ff0ef          	jal	526 <printint>
 6c4:	8ba6                	mv	s7,s1
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	b781                	j	608 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ca:	008b8493          	addi	s1,s7,8
 6ce:	4681                	li	a3,0
 6d0:	4629                	li	a2,10
 6d2:	000bb583          	ld	a1,0(s7)
 6d6:	855a                	mv	a0,s6
 6d8:	e4fff0ef          	jal	526 <printint>
        i += 1;
 6dc:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6de:	8ba6                	mv	s7,s1
      state = 0;
 6e0:	4981                	li	s3,0
 6e2:	b71d                	j	608 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6e4:	008b8493          	addi	s1,s7,8
 6e8:	4681                	li	a3,0
 6ea:	4629                	li	a2,10
 6ec:	000bb583          	ld	a1,0(s7)
 6f0:	855a                	mv	a0,s6
 6f2:	e35ff0ef          	jal	526 <printint>
        i += 2;
 6f6:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f8:	8ba6                	mv	s7,s1
      state = 0;
 6fa:	4981                	li	s3,0
        i += 2;
 6fc:	b731                	j	608 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6fe:	008b8493          	addi	s1,s7,8
 702:	4681                	li	a3,0
 704:	4641                	li	a2,16
 706:	000be583          	lwu	a1,0(s7)
 70a:	855a                	mv	a0,s6
 70c:	e1bff0ef          	jal	526 <printint>
 710:	8ba6                	mv	s7,s1
      state = 0;
 712:	4981                	li	s3,0
 714:	bdd5                	j	608 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 716:	008b8493          	addi	s1,s7,8
 71a:	4681                	li	a3,0
 71c:	4641                	li	a2,16
 71e:	000bb583          	ld	a1,0(s7)
 722:	855a                	mv	a0,s6
 724:	e03ff0ef          	jal	526 <printint>
        i += 1;
 728:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 72a:	8ba6                	mv	s7,s1
      state = 0;
 72c:	4981                	li	s3,0
 72e:	bde9                	j	608 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 730:	008b8493          	addi	s1,s7,8
 734:	4681                	li	a3,0
 736:	4641                	li	a2,16
 738:	000bb583          	ld	a1,0(s7)
 73c:	855a                	mv	a0,s6
 73e:	de9ff0ef          	jal	526 <printint>
        i += 2;
 742:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 744:	8ba6                	mv	s7,s1
      state = 0;
 746:	4981                	li	s3,0
        i += 2;
 748:	b5c1                	j	608 <vprintf+0x44>
 74a:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 74c:	008b8793          	addi	a5,s7,8
 750:	8cbe                	mv	s9,a5
 752:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 756:	03000593          	li	a1,48
 75a:	855a                	mv	a0,s6
 75c:	dadff0ef          	jal	508 <putc>
  putc(fd, 'x');
 760:	07800593          	li	a1,120
 764:	855a                	mv	a0,s6
 766:	da3ff0ef          	jal	508 <putc>
 76a:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 76c:	00000b97          	auipc	s7,0x0
 770:	4d4b8b93          	addi	s7,s7,1236 # c40 <digits>
 774:	03c9d793          	srli	a5,s3,0x3c
 778:	97de                	add	a5,a5,s7
 77a:	0007c583          	lbu	a1,0(a5)
 77e:	855a                	mv	a0,s6
 780:	d89ff0ef          	jal	508 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 784:	0992                	slli	s3,s3,0x4
 786:	34fd                	addiw	s1,s1,-1
 788:	f4f5                	bnez	s1,774 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 78a:	8be6                	mv	s7,s9
      state = 0;
 78c:	4981                	li	s3,0
 78e:	6ca2                	ld	s9,8(sp)
 790:	bda5                	j	608 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 792:	008b8493          	addi	s1,s7,8
 796:	000bc583          	lbu	a1,0(s7)
 79a:	855a                	mv	a0,s6
 79c:	d6dff0ef          	jal	508 <putc>
 7a0:	8ba6                	mv	s7,s1
      state = 0;
 7a2:	4981                	li	s3,0
 7a4:	b595                	j	608 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 7a6:	008b8993          	addi	s3,s7,8
 7aa:	000bb483          	ld	s1,0(s7)
 7ae:	cc91                	beqz	s1,7ca <vprintf+0x206>
        for(; *s; s++)
 7b0:	0004c583          	lbu	a1,0(s1)
 7b4:	c985                	beqz	a1,7e4 <vprintf+0x220>
          putc(fd, *s);
 7b6:	855a                	mv	a0,s6
 7b8:	d51ff0ef          	jal	508 <putc>
        for(; *s; s++)
 7bc:	0485                	addi	s1,s1,1
 7be:	0004c583          	lbu	a1,0(s1)
 7c2:	f9f5                	bnez	a1,7b6 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 7c4:	8bce                	mv	s7,s3
      state = 0;
 7c6:	4981                	li	s3,0
 7c8:	b581                	j	608 <vprintf+0x44>
          s = "(null)";
 7ca:	00000497          	auipc	s1,0x0
 7ce:	46e48493          	addi	s1,s1,1134 # c38 <malloc+0x2d2>
        for(; *s; s++)
 7d2:	02800593          	li	a1,40
 7d6:	b7c5                	j	7b6 <vprintf+0x1f2>
        putc(fd, '%');
 7d8:	85be                	mv	a1,a5
 7da:	855a                	mv	a0,s6
 7dc:	d2dff0ef          	jal	508 <putc>
      state = 0;
 7e0:	4981                	li	s3,0
 7e2:	b51d                	j	608 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 7e4:	8bce                	mv	s7,s3
      state = 0;
 7e6:	4981                	li	s3,0
 7e8:	b505                	j	608 <vprintf+0x44>
 7ea:	6906                	ld	s2,64(sp)
 7ec:	79e2                	ld	s3,56(sp)
 7ee:	7a42                	ld	s4,48(sp)
 7f0:	7aa2                	ld	s5,40(sp)
 7f2:	7b02                	ld	s6,32(sp)
 7f4:	6be2                	ld	s7,24(sp)
 7f6:	6c42                	ld	s8,16(sp)
    }
  }
}
 7f8:	60e6                	ld	ra,88(sp)
 7fa:	6446                	ld	s0,80(sp)
 7fc:	64a6                	ld	s1,72(sp)
 7fe:	6125                	addi	sp,sp,96
 800:	8082                	ret
      if(c0 == 'd'){
 802:	06400713          	li	a4,100
 806:	e4e78fe3          	beq	a5,a4,664 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 80a:	f9478693          	addi	a3,a5,-108
 80e:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 812:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 814:	4701                	li	a4,0
      } else if(c0 == 'u'){
 816:	07500513          	li	a0,117
 81a:	e8a78ce3          	beq	a5,a0,6b2 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 81e:	f8b60513          	addi	a0,a2,-117
 822:	e119                	bnez	a0,828 <vprintf+0x264>
 824:	ea0693e3          	bnez	a3,6ca <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 828:	f8b58513          	addi	a0,a1,-117
 82c:	e119                	bnez	a0,832 <vprintf+0x26e>
 82e:	ea071be3          	bnez	a4,6e4 <vprintf+0x120>
      } else if(c0 == 'x'){
 832:	07800513          	li	a0,120
 836:	eca784e3          	beq	a5,a0,6fe <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 83a:	f8860613          	addi	a2,a2,-120
 83e:	e219                	bnez	a2,844 <vprintf+0x280>
 840:	ec069be3          	bnez	a3,716 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 844:	f8858593          	addi	a1,a1,-120
 848:	e199                	bnez	a1,84e <vprintf+0x28a>
 84a:	ee0713e3          	bnez	a4,730 <vprintf+0x16c>
      } else if(c0 == 'p'){
 84e:	07000713          	li	a4,112
 852:	eee78ce3          	beq	a5,a4,74a <vprintf+0x186>
      } else if(c0 == 'c'){
 856:	06300713          	li	a4,99
 85a:	f2e78ce3          	beq	a5,a4,792 <vprintf+0x1ce>
      } else if(c0 == 's'){
 85e:	07300713          	li	a4,115
 862:	f4e782e3          	beq	a5,a4,7a6 <vprintf+0x1e2>
      } else if(c0 == '%'){
 866:	02500713          	li	a4,37
 86a:	f6e787e3          	beq	a5,a4,7d8 <vprintf+0x214>
        putc(fd, '%');
 86e:	02500593          	li	a1,37
 872:	855a                	mv	a0,s6
 874:	c95ff0ef          	jal	508 <putc>
        putc(fd, c0);
 878:	85a6                	mv	a1,s1
 87a:	855a                	mv	a0,s6
 87c:	c8dff0ef          	jal	508 <putc>
      state = 0;
 880:	4981                	li	s3,0
 882:	b359                	j	608 <vprintf+0x44>

0000000000000884 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 884:	715d                	addi	sp,sp,-80
 886:	ec06                	sd	ra,24(sp)
 888:	e822                	sd	s0,16(sp)
 88a:	1000                	addi	s0,sp,32
 88c:	e010                	sd	a2,0(s0)
 88e:	e414                	sd	a3,8(s0)
 890:	e818                	sd	a4,16(s0)
 892:	ec1c                	sd	a5,24(s0)
 894:	03043023          	sd	a6,32(s0)
 898:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 89c:	8622                	mv	a2,s0
 89e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8a2:	d23ff0ef          	jal	5c4 <vprintf>
}
 8a6:	60e2                	ld	ra,24(sp)
 8a8:	6442                	ld	s0,16(sp)
 8aa:	6161                	addi	sp,sp,80
 8ac:	8082                	ret

00000000000008ae <printf>:

void
printf(const char *fmt, ...)
{
 8ae:	711d                	addi	sp,sp,-96
 8b0:	ec06                	sd	ra,24(sp)
 8b2:	e822                	sd	s0,16(sp)
 8b4:	1000                	addi	s0,sp,32
 8b6:	e40c                	sd	a1,8(s0)
 8b8:	e810                	sd	a2,16(s0)
 8ba:	ec14                	sd	a3,24(s0)
 8bc:	f018                	sd	a4,32(s0)
 8be:	f41c                	sd	a5,40(s0)
 8c0:	03043823          	sd	a6,48(s0)
 8c4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8c8:	00840613          	addi	a2,s0,8
 8cc:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8d0:	85aa                	mv	a1,a0
 8d2:	4505                	li	a0,1
 8d4:	cf1ff0ef          	jal	5c4 <vprintf>
}
 8d8:	60e2                	ld	ra,24(sp)
 8da:	6442                	ld	s0,16(sp)
 8dc:	6125                	addi	sp,sp,96
 8de:	8082                	ret

00000000000008e0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8e0:	1141                	addi	sp,sp,-16
 8e2:	e406                	sd	ra,8(sp)
 8e4:	e022                	sd	s0,0(sp)
 8e6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8e8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ec:	00001797          	auipc	a5,0x1
 8f0:	7147b783          	ld	a5,1812(a5) # 2000 <freep>
 8f4:	a039                	j	902 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8f6:	6398                	ld	a4,0(a5)
 8f8:	00e7e463          	bltu	a5,a4,900 <free+0x20>
 8fc:	00e6ea63          	bltu	a3,a4,910 <free+0x30>
{
 900:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 902:	fed7fae3          	bgeu	a5,a3,8f6 <free+0x16>
 906:	6398                	ld	a4,0(a5)
 908:	00e6e463          	bltu	a3,a4,910 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 90c:	fee7eae3          	bltu	a5,a4,900 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 910:	ff852583          	lw	a1,-8(a0)
 914:	6390                	ld	a2,0(a5)
 916:	02059813          	slli	a6,a1,0x20
 91a:	01c85713          	srli	a4,a6,0x1c
 91e:	9736                	add	a4,a4,a3
 920:	02e60563          	beq	a2,a4,94a <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 924:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 928:	4790                	lw	a2,8(a5)
 92a:	02061593          	slli	a1,a2,0x20
 92e:	01c5d713          	srli	a4,a1,0x1c
 932:	973e                	add	a4,a4,a5
 934:	02e68263          	beq	a3,a4,958 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 938:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 93a:	00001717          	auipc	a4,0x1
 93e:	6cf73323          	sd	a5,1734(a4) # 2000 <freep>
}
 942:	60a2                	ld	ra,8(sp)
 944:	6402                	ld	s0,0(sp)
 946:	0141                	addi	sp,sp,16
 948:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 94a:	4618                	lw	a4,8(a2)
 94c:	9f2d                	addw	a4,a4,a1
 94e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 952:	6398                	ld	a4,0(a5)
 954:	6310                	ld	a2,0(a4)
 956:	b7f9                	j	924 <free+0x44>
    p->s.size += bp->s.size;
 958:	ff852703          	lw	a4,-8(a0)
 95c:	9f31                	addw	a4,a4,a2
 95e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 960:	ff053683          	ld	a3,-16(a0)
 964:	bfd1                	j	938 <free+0x58>

0000000000000966 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 966:	7139                	addi	sp,sp,-64
 968:	fc06                	sd	ra,56(sp)
 96a:	f822                	sd	s0,48(sp)
 96c:	f04a                	sd	s2,32(sp)
 96e:	ec4e                	sd	s3,24(sp)
 970:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 972:	02051993          	slli	s3,a0,0x20
 976:	0209d993          	srli	s3,s3,0x20
 97a:	09bd                	addi	s3,s3,15
 97c:	0049d993          	srli	s3,s3,0x4
 980:	2985                	addiw	s3,s3,1
 982:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 984:	00001517          	auipc	a0,0x1
 988:	67c53503          	ld	a0,1660(a0) # 2000 <freep>
 98c:	c905                	beqz	a0,9bc <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 98e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 990:	4798                	lw	a4,8(a5)
 992:	09377663          	bgeu	a4,s3,a1e <malloc+0xb8>
 996:	f426                	sd	s1,40(sp)
 998:	e852                	sd	s4,16(sp)
 99a:	e456                	sd	s5,8(sp)
 99c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 99e:	8a4e                	mv	s4,s3
 9a0:	6705                	lui	a4,0x1
 9a2:	00e9f363          	bgeu	s3,a4,9a8 <malloc+0x42>
 9a6:	6a05                	lui	s4,0x1
 9a8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9ac:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9b0:	00001497          	auipc	s1,0x1
 9b4:	65048493          	addi	s1,s1,1616 # 2000 <freep>
  if(p == SBRK_ERROR)
 9b8:	5afd                	li	s5,-1
 9ba:	a83d                	j	9f8 <malloc+0x92>
 9bc:	f426                	sd	s1,40(sp)
 9be:	e852                	sd	s4,16(sp)
 9c0:	e456                	sd	s5,8(sp)
 9c2:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9c4:	00001797          	auipc	a5,0x1
 9c8:	64c78793          	addi	a5,a5,1612 # 2010 <base>
 9cc:	00001717          	auipc	a4,0x1
 9d0:	62f73a23          	sd	a5,1588(a4) # 2000 <freep>
 9d4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9d6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9da:	b7d1                	j	99e <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 9dc:	6398                	ld	a4,0(a5)
 9de:	e118                	sd	a4,0(a0)
 9e0:	a899                	j	a36 <malloc+0xd0>
  hp->s.size = nu;
 9e2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9e6:	0541                	addi	a0,a0,16
 9e8:	ef9ff0ef          	jal	8e0 <free>
  return freep;
 9ec:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 9ee:	c125                	beqz	a0,a4e <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9f0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9f2:	4798                	lw	a4,8(a5)
 9f4:	03277163          	bgeu	a4,s2,a16 <malloc+0xb0>
    if(p == freep)
 9f8:	6098                	ld	a4,0(s1)
 9fa:	853e                	mv	a0,a5
 9fc:	fef71ae3          	bne	a4,a5,9f0 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 a00:	8552                	mv	a0,s4
 a02:	a23ff0ef          	jal	424 <sbrk>
  if(p == SBRK_ERROR)
 a06:	fd551ee3          	bne	a0,s5,9e2 <malloc+0x7c>
        return 0;
 a0a:	4501                	li	a0,0
 a0c:	74a2                	ld	s1,40(sp)
 a0e:	6a42                	ld	s4,16(sp)
 a10:	6aa2                	ld	s5,8(sp)
 a12:	6b02                	ld	s6,0(sp)
 a14:	a03d                	j	a42 <malloc+0xdc>
 a16:	74a2                	ld	s1,40(sp)
 a18:	6a42                	ld	s4,16(sp)
 a1a:	6aa2                	ld	s5,8(sp)
 a1c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a1e:	fae90fe3          	beq	s2,a4,9dc <malloc+0x76>
        p->s.size -= nunits;
 a22:	4137073b          	subw	a4,a4,s3
 a26:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a28:	02071693          	slli	a3,a4,0x20
 a2c:	01c6d713          	srli	a4,a3,0x1c
 a30:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a32:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a36:	00001717          	auipc	a4,0x1
 a3a:	5ca73523          	sd	a0,1482(a4) # 2000 <freep>
      return (void*)(p + 1);
 a3e:	01078513          	addi	a0,a5,16
  }
}
 a42:	70e2                	ld	ra,56(sp)
 a44:	7442                	ld	s0,48(sp)
 a46:	7902                	ld	s2,32(sp)
 a48:	69e2                	ld	s3,24(sp)
 a4a:	6121                	addi	sp,sp,64
 a4c:	8082                	ret
 a4e:	74a2                	ld	s1,40(sp)
 a50:	6a42                	ld	s4,16(sp)
 a52:	6aa2                	ld	s5,8(sp)
 a54:	6b02                	ld	s6,0(sp)
 a56:	b7f5                	j	a42 <malloc+0xdc>
