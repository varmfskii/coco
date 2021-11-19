#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "decb.h"

decb_block *read_block(FILE *);
void write_block(FILE *out, decb_block *b);

decb_block *alloc_block(size_t len) {
  decb_block *b;

  b=malloc(sizeof(decb_block));
  if (len) 
    b->data=malloc(len);
  else
    b->data=NULL;
  b->length=len;
  b->next=NULL;
  return b;
}
  
void free_blocks(decb_block *b) {
  if (!b) return;
  free_blocks(b->next);
  if (b->data) free(b->data);
  free(b);
}

memory_t *blocks2mem(decb_block *b) {
  int lo, hi, exec;
  int thi, tlo;
  memory_t *mem;
  decb_block *this;

  mem=alloc_mem();
  lo=65535;
  hi=-1;
  for(this=b; this; this=this->next) {
    if (this->length) {
      tlo=this->address;
      thi=tlo+this->length-1;
      if (tlo<lo) lo=tlo;
      if (thi>hi) hi=thi;
      memcpy(mem->data+tlo, this->data, this->length);
    } else if (this->type==0xff) exec=this->address;
  }
  mem->lo=lo;
  mem->hi=hi;
  mem->exec=exec;
#ifdef DEBUG
  fprintf(stderr, "mem: %04x %04x %04x\n", mem->lo, mem->hi, mem->exec);
#endif
  return mem;
}

decb_block *mem2blocks(memory_t *m) {
  decb_block *one, *two;
  size_t len=m->hi-m->lo+1;
  
  one=alloc_block(len);
  one->type=0x00;
  one->address=m->lo;
  if (one->length) memcpy(one->data, m->data+m->lo, one->length);
  one->next=two=alloc_block(0);
  two->type=0xff;
  two->address=m->exec;
  return one;
}

decb_block *read_blocks(FILE *in) {
  decb_block *first, *this, *new;

  first=NULL;
  while((new=read_block(in))) {
#ifdef DEBUG
    fprintf(stderr, "block: %02x %04x %04x\n", new->type, new->address, new->length);
#endif
    if (first) {
      this->next=new;
    } else {
      first=new;
    }
    this=new;
  }
  if(errno) {
    free_blocks(first);
    return NULL;
  }
  return first;
}

decb_block *read_block(FILE *in) {
  int c;
  size_t l;
  uint16_t address, length;
  decb_block *b;
  if ((c=getc(in))==EOF) {
    errno=0;
    return NULL;
  }
  if (c!=0x00 && c!=0xff) {
    fprintf(stderr, "Unknown block type %02x\n", c);
    errno=EIO;
    return NULL;
  }
  length=read16(in);
  address=read16(in);
  if(feof(in)) {
    fprintf(stderr, "Premature end of file\n");
    errno=EIO;
    return NULL;
  }
  if (length && c) {
    fprintf(stderr, "Malformed block\n");
    errno=EIO;
    return NULL;
  }
  b=alloc_block(length);
  b->type=c;
  b->address=address;
  b->next=NULL;
  if (length) {
    l=fread(b->data, 1, length, in);
    if (l!=length) {
      errno=EIO;
      fprintf(stderr, "Premature end of file %d!=%d\n", l, length);
      free_blocks(b);
      errno=EIO;
      return NULL;
    }
  }
  return b;
}

void write_blocks(FILE *out, decb_block *b) {
  decb_block *this;
  for(this=b; this; this=this->next) write_block(out, this);
}

void write_block(FILE *out, decb_block *b) {
  putc(b->type, out);
  write16(b->length, out);
  write16(b->address, out);
  if (b->length) fwrite(b->data, 1, b->length, out);
}

void decb_info(FILE *in, FILE *out) {
  decb_block *b, *this;

#ifdef DEBUG
  fprintf(stderr, "decb_info()\n");
#endif
  b=read_blocks(in);
  for(this=b; this; this=this->next) {
#ifdef DEBUG
    fprintf(stderr, "this=%p\n", b);
#endif
    if (this->type==0x00) {
      fprintf(out, "Start address: %04x, length: %04x\n", this->address, this->length);
    } else {
      fprintf(out, "Execution address: %04x\n", this->address);
    }
  }
  free_blocks(b);
}

