#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <errno.h>
#include <string.h>
#include "mem.h"
#include "decb.h"
#include "ddos.h"

int ddos2decb(FILE *in, FILE *out);
int decb2ddos(FILE *in, FILE *out);
void help(char *);

int main(int argc, char *argv[]) {
  FILE *in, *out;
  char *inname=NULL;
  char *outname=NULL;
  char *errstr, *msg;
  int info=0;
  int intype, opt;
  char opts[]="ahi:o:";
  struct option longopts[]={
    {"info", 0, NULL, 'a'},
    {"help", 0, NULL, 'h'},
    {"in", 1, NULL, 'i'},
    {"out", 1, NULL, 'o'},
    {NULL, 0, NULL, 0}
  };
  
  while((opt=getopt_long(argc, argv, opts, longopts, NULL))>0) {
#ifdef DEBUG
    fprintf(stdout, "option %c\n", opt);
#endif
    switch(opt) {
    case 'a':
      info=1;
      break;
    case 'h':
      help(argv[0]);
      return 0;
    case 'i':
      inname=optarg;
      break;
    case 'o':
      outname=optarg;
      break;
    default:
      fprintf(stderr, "Unknown argument %c\n", opt);
      help(argv[0]);
      return -1;
    }
  }
  if (inname) {
    if (!(in=fopen(inname, "r"))) {
      msg="Unable to open %s";
      errstr=malloc(strlen(inname)+strlen(msg));
      sprintf(errstr, msg, inname);
      perror(errstr);
      return -1;
    }
  } else {
    in=stdin;
  }
  if (outname) {
    if (!(out=fopen(outname, "w"))) {
      msg="Unable to open %s";
      errstr=malloc(strlen(outname)+strlen(msg));
      sprintf(errstr, msg, outname);
      perror(errstr);
      return -1;
    }
  } else {
    out=stdout;
  }
  intype=getc(in);
#ifdef DEBUG
  fprintf(stderr, "Filetype %02x\n", intype);
#endif
  ungetc(intype, in);
  switch(intype) {
  case 0x00:
    if (info)
      decb_info(in, out);
    else
      decb2ddos(in, out);
    break;
  case 0x55:
    if (info)
      ddos_info(in, out);
    else
      ddos2decb(in, out);
    break;
  default:
    fprintf(stderr, "Unrecognized file type\n");
    return -1;
  }
  if (in!=stdin) fclose(in);
  if (out!=stdout) fclose(out);
  return 0;
}

int ddos2decb(FILE *in, FILE *out) {
  ddos_t *ddos;
  decb_block *blocks;
  memory_t *mem;

  if (!(ddos=read_ddos(in))) exit(-1);
  mem=ddos2mem(ddos);
  free_ddos(ddos);
  blocks=mem2blocks(mem);
  free_mem(mem);
  write_blocks(out, blocks);
  free_blocks(blocks);
}

int decb2ddos(FILE *in, FILE *out) {
  ddos_t *ddos;
  decb_block *blocks;
  memory_t *mem;

  if (!(blocks=read_blocks(in))) exit(-1);
  mem=blocks2mem(blocks);
  free_blocks(blocks);
  ddos=mem2ddos(mem);
  free_mem(mem);
  write_ddos(out, ddos);
  free_ddos(ddos);
}

void help(char *name) {
  fprintf(stderr, "%s: Converts between DECB and DragonDos binary files\n", name);
  fprintf(stderr, "Works in both directions and autodetects file type\n");
  fprintf(stderr, "Also able to show basic info for files.\n");
  fprintf(stderr, "Usage: %s [<options>]\n", name);
  fprintf(stderr, "\t-a\t\t--info\t\tPrint file info, do not convert\n");
  fprintf(stderr, "\t-h\t\t--help\t\tThis help message\n");
  fprintf(stderr, "\t-i<name>\t--in <name>\tInput file name\n");
  fprintf(stderr, "\t-o<name>\t--out <name>\tOutput file name\n");
}
  
