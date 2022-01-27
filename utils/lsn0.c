#include <stdio.h>
#include <stdint.h>

typedef struct id {
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
  uint8_t opt[193];
} id;

int get2(uint8_t *);
int get3(uint8_t *);
void print_high(char *);

int main(int argc, uint8_t *argv[]) {
  id lsn0;
  
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
  printf("Attributes: %02x\n", lsn0.att);
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
  for(int i=0; i<193; i++) {
    if (i%16==15)
      printf("%02x\n", lsn0.opt[i]);
    else
      printf("%02x ", lsn0.opt[i]);
  }
  putchar('\n');
}

int get2(uint8_t *v) {
  return v[0]*256+v[1];
}

int get3(uint8_t *v) {
  return v[0]*65536+v[1]*256+v[2];
}  

void print_high(char *s) {
  while(!((*s)&0x80)) putchar(*(s++));
  putchar(*s&0x7f);
}
