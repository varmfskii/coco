#ifndef DDOS_H
#define DDOS_H
#include <stdio.h>
#include "mem.h"

typedef struct ddos_t {
  uint8_t c55, type;
  uint16_t load, length, exec;
  uint8_t caa;
  char *data;
} ddos_t;

ddos_t *alloc_ddos(size_t length);
void free_ddos(ddos_t *d);
ddos_t *read_ddos(FILE *in);
void write_ddos(FILE *out, ddos_t *d);
memory_t *ddos2mem(ddos_t *d);
ddos_t *mem2ddos(memory_t *m);
void ddos_info(FILE *out, FILE *in);
#endif
