#ifndef DECB_H
#define DECB_H
#include <stdio.h>
#include "mem.h"

typedef struct decb_block {
  struct decb_block *next;
  uint8_t type;
  uint16_t address, length;
  char *data;
} decb_block;

decb_block *allocblock(size_t len);
void free_blocks(decb_block *b);
decb_block *read_blocks(FILE *in);
void write_blocks(FILE *out, decb_block *d);
memory_t *blocks2mem(decb_block *b);
decb_block *mem2blocks(memory_t *m);
void decb_info(FILE *out, FILE *in);
#endif
