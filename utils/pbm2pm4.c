#include <stdio.h>
#include <getopt.h>
#include <stdlib.h>
#include <ctype.h>

#define DEF_ADDR 0x0e00
#define IMGSZ 6144

char *readppm(FILE *);
int getint(FILE *);
int getpixel(FILE *);
int skip_ws(FILE *);
void binfoot(FILE *);
void binhead(int, FILE *);
void pm4(char *, FILE *);
void usage(char *);

int main(int argc, char *argv[]) {
  char sopts[]="a:bhi:o:r";
  struct option lopts[] = {
    {"address", 1, NULL, 'a'},
    {"bin", 0, NULL, 'b'},
    {"help", 0, NULL, 'h'},
    {"in", 1, NULL, 'i'},
    {"out", 1, NULL, 'o'},
    {"raw", 0, NULL, 'r'},
    {NULL, 0, 0, 0}
  };
  int ix=0;
  int bin=1;
  int address=0;
  FILE *in, *out;
  char *inname=NULL;
  char *outname=NULL;
  char *data;
  int opt;
  char buffer[256];
  
  while((opt=getopt_long(argc, argv, sopts, lopts, &ix))!=-1) {
    switch(opt) {
    case 'h':
      usage(argv[0]);
      return 0;
    case 'i':
      if (inname) {
	fprintf(stderr, "Multiple input file names specified\n");
	usage(argv[0]);
	return 1;
      }
      inname=optarg;
      break;
    case 'o':
      if (outname) {
	fprintf(stderr, "Multiple output file names specified\n");
	usage(argv[0]);
	return 1;
      }
      outname=optarg;
      break;
    case 'a':
      if (address) {
	fprintf(stderr, "Multiple addresses specified\n");
	usage(argv[0]);
	return 1;
      }
      sscanf(optarg, "%i", &address);
      break;
    case 'r':
      bin=0;
      break;
    case 'b':
      bin=1;
      break;
    default:
      fprintf(stderr, "Unknown option %c\n", opt);
      usage(argv[0]);
      return 1;
    }
  }
  if (bin && !address) address=DEF_ADDR;
  if (inname) {
    if (!(in=fopen(inname, "r"))) {
      perror(inname);
      return 1;
    }
  } else {
    in=stdin;
  }
  if (outname) {
    if (!(out=fopen(outname, "w"))) {
      perror(outname);
      return 1;
    }
  } else {
    out=stdout;
  }
  data=readppm(in);
  if (in!=stdin) fclose(in);
  if (bin) binhead(address, out);
  pm4(data, out);
  if (bin) binfoot(out);
  if (out!=stdout) fclose(out);
  return 0;
}

char *readppm(FILE *in) {
  char *data;
  char magic[3];
  char word[256];
  int c, i, j, raw, acc, w, h;

  if ((c=getc(in))==EOF) {
    fprintf(stderr, "Empty file\n");
    exit(1);
  }
  magic[0]=c;
  magic[2]='\0';
  if ((c=getc(in))==EOF) {
    fprintf(stderr, "Premature end of file\n");
    exit(1);
  }
  magic[1]=c;
  if (magic[0]!='P' || (magic[1]!='1' && magic[1]!='4')) {
    fprintf(stderr, "Bad magic number\n", magic);
    exit(1);
  }
  raw=magic[1]=='4';
  w=getint(in);
#ifdef DEBUG
  fprintf(stderr, "width: %d\n", w);
#endif
  h=getint(in);
#ifdef DEBUG
  fprintf(stderr, "height: %d\n", h);
#endif
  if ((c=getc(in))==EOF) {
    fprintf(stderr, "Premature end of file\n");
    exit(1);
  }
  if (!isspace(c)) {
#ifdef DEBUG
  fprintf(stderr, "first ");
#endif
    fprintf(stderr, "Malformed file\n");
    exit(1);
  }
  data = calloc(1, IMGSZ);
  if (raw) {
    for(i=0; i<h; i++) {
      for(j=0; j<(w+7)/8; j++) {
	if ((c=getc(in))==EOF) {
	  fprintf(stderr, "Premature end of file\n");
	  free(data);
	  exit(1);
	}
	if (i<192 && j<32) data[32*i+j]=c;
      }
    }
  } else {
    for(i=0; i<h; i++) {
      for(j=0; j<w; j++) {
	if (!j%8) {
	  if (i<192 && j-8<256 && (i || j)) {
	    if (j)
	      data[i*32+j/8-1]=acc;
	    else
	      data[(i-1)*32+(w-1)/8]=acc;
	  }
	  acc=0;
	}
	c=getpixel(in);
	acc<<=1;
	if (c='1')
	  acc |= 1;
	else if (c!='0') {
#ifdef DEBUG
	  fprintf(stderr, "second [%c] ", c);
#endif
	  fprintf(stderr, "Malformed file\n");
	  free(data);
	  exit(1);
	}
      }
    }
  }
  return data;
}

void binfoot(FILE *out) {
  putc(0xff, out);
  putc(0x00, out);
  putc(0x00, out);
  putc(0x00, out);
  putc(0x00, out);
}

void binhead(int address, FILE *out) {
  putc(0x00, out);
  putc(IMGSZ/0x100, out);
  putc(IMGSZ&0xff, out);
  putc(address/0x100, out);
  putc(address&0xff, out);
}

void pm4(char *data, FILE *out) {
  int i;

  for(i=0; i<IMGSZ; i++) putc(~data[i], out);
}

int skip_ws(FILE *in) {
  int c;
  while(isspace(c=getc(in))) {
    if (c=='\n' || c=='\r') {
      if ((c=getc(in))=='#') {
	while((c=getc(in))!=EOF && c!='\n' && c!='\r');
	if (c==EOF) {
	  fprintf(stderr, "Premature end of file");
	  exit(1);
	}
      } else if (!isspace(c)) {
	return c;
      }
    }
  }
  return c;
}

int getint(FILE *in) {
  int c;
  int acc=0;

  c=skip_ws(in);
  for(;;) {
    if (c==EOF) {
      fprintf(stderr, "Premature end of file");
      exit(1);
    }
    if (isspace(c)) {
      ungetc(c, in);
      return acc;
    }
    if (!isdigit(c)) {
#ifdef DEBUG
      fprintf(stderr, "third [%d] ", c);
#endif
      fprintf(stderr, "Malformed file");
      exit(1);
    }      
    acc=10*acc+c-'0';
    c=getc(in);
  }
}

void usage(char *name) {
  fprintf(stderr, "Usage: %s <options>\n", name);
}

int getpixel(FILE *in) {
  int c;

  c=skip_ws(in);
  if (c==EOF) {
      fprintf(stderr, "Premature end of file");
      exit(1);
  }
  if (c=='0' || c=='1') {
    return c-'0';
  }
#ifdef DEBUG
  fprintf(stderr, "fourth [%c] ", c);
#endif
  fprintf(stderr, "Malformed file\n");
  exit(1);
}
