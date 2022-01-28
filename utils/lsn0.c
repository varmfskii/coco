#include <stdio.h>
#include <stdint.h>

typedef struct opt {
  uint8_t dtp;
  uint8_t drv;
  uint8_t stp;
  uint8_t typ;
  uint8_t dns;
  uint8_t cyl[2];
  uint8_t sid;
  uint8_t vfy;
  uint8_t sct[2];
  uint8_t t0s[2];
  uint8_t ilv;
  uint8_t sas;
  uint8_t tfm;
  uint8_t exten[2];
  uint8_t stoff;
  uint8_t att;
  uint8_t fd[3];
  uint8_t dfd[3];
  uint8_t dcp[4];
  uint8_t dvt[2];
} opt;

typedef struct lsn0 {
  uint8_t tot[3];
  uint8_t tks;
  uint8_t map[2];
  uint8_t bit[2];
  uint8_t dir[3];
  uint8_t own[2];
  uint8_t att;
  uint8_t dsk[2];
  uint8_t fmt;
  uint8_t spt[2];
  uint8_t res[2];
  uint8_t bt[3];
  uint8_t bsz[2];
  uint8_t dat[5];
  uint8_t nam[32];
  opt opt;
  uint8_t xxx[161];
} lsn0;

static inline int get2(uint8_t *v) {
  return (v[0]<<8)+v[1];
}

static inline int get3(uint8_t *v) {
  return (v[0]<<16)+(v[1]<<8)+v[2];
}  

static inline int get4(uint8_t *v) {
  return (v[0]<<24)+(v[1]<<16)+(v[2]<<8)+v[3];
}  

static inline void print_high(char *s) {
  while(!((*s)&0x80)) putchar(*(s++));
  putchar(*s&0x7f);
}

int main(int argc, uint8_t *argv[]) {
  lsn0 lsn0;
  
  FILE *in=stdin;

  if (argc==2) {
    in=fopen(argv[1], "r");
    if (!in) {
      perror(argv[1]);
      return -1;
    }
  }
  fread(&lsn0, 1, 256, in);
  if (in!=stdin) fclose(in);
  printf("Sectors: %d\n", get3(lsn0.tot));
  printf("Sectors per track (0): %d\n", lsn0.tks);
  printf("Allocation bitmap size: %d\n", get2(lsn0.map));
  printf("Cluster size: %d\n", get2(lsn0.bit));
  printf("Root dir lsn: %d\n", get3(lsn0.dir));
  printf("Owner ID: %d\n", get2(lsn0.own));
  printf("Attributes: %02x = ", lsn0.att);
  for(int i=7; i>=0; i--) putchar(((1<<i)&lsn0.att)?"dsewrewr"[7-i]:'-');
  putchar('\n');
  printf("Sectors per track: %d\n", get2(lsn0.spt));
  printf("Reserved: %04x\n", get2(lsn0.res));
  printf("Boot lsn: %d\n", get3(lsn0.bt));
  printf("Boot size: %d\n", get2(lsn0.bsz));
  printf("Creation time: %d/%02d/%02d %02d:%02d\n", 1900+lsn0.dat[0],
	 lsn0.dat[1], lsn0.dat[2], lsn0.dat[3], lsn0.dat[4]);
  printf("Name: ");
  print_high(lsn0.nam);
  putchar('\n');
  puts("--------------------------------------");
  printf("Device class: %d = ", lsn0.opt.dtp);
  switch(lsn0.opt.dtp) {
  case 0:
    puts("SCF");
    break;
  case 1:
    puts("RBF");
    break;
  case 2:
    puts("PIPE");
    break;
  case 3:
    puts("SBF");
    break;
  default:
    puts("Unknown");
  }
  printf("Drive number: %d\n", lsn0.opt.drv);
  printf("Device type: %02x\n", lsn0.opt.typ);
  printf("Density capability: %02x\n", lsn0.opt.dns);
  printf("Number of cylinders: %d\n", get2(lsn0.opt.cyl));
  printf("Number of sides: %d\n", lsn0.opt.sid);
  printf("Verify: %s\n", lsn0.opt.vfy?"false":"true");
  printf("Sectors per track: %d\n", get2(lsn0.opt.sct));
  printf("Sectors in track 0: %d\n", get2(lsn0.opt.t0s));
  printf("Sector interleave: %d\n", lsn0.opt.ilv);
  printf("Segment allocation size: %d\n", lsn0.opt.sas);
  printf("DMA transfer mode: %d\n", lsn0.opt.tfm);
  printf("Path extension: %d\n", get2(lsn0.opt.exten));
  printf("Sector/track offset: %d\n", lsn0.opt.stoff);
}
