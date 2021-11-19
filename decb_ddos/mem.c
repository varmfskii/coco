#include <stdlib.h>
#include "mem.h"

memory_t *alloc_mem(void) {
  memory_t *m;

  m=malloc(sizeof(memory_t));
  m->data=malloc(0x10000);
  return m;
}

void free_mem(memory_t *m) {
  if (!m) return;
  if (m->data) free(m->data);
  free(m);
}
