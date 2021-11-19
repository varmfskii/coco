#ifndef MEM_H
#define MEM_H
#include <stdint.h>
#include <stdio.h>

typedef struct memory_t {
  uint16_t lo, hi, exec;
  char *data;
} memory_t;

memory_t *alloc_mem(void);
void free_mem(memory_t *m);

static inline uint16_t read16(FILE *in) {
  uint16_t v=getc(in)<<8;
  return v|getc(in);
}

static inline void write16(uint16_t v, FILE *out) {
  putc(v>>8, out);
  putc(v&0xff, out);
}
#endif
