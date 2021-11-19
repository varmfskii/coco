#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include "ddos.h"

ddos_t *alloc_ddos(size_t len) {
  ddos_t *d;

  d=malloc(sizeof(ddos_t));
  d->c55=0x55;
  d->length=len;
  d->caa=0xaa;
  d->data=malloc(len);
  return d;
}

void free_ddos(ddos_t *d) {
  if (!d) return;
  if (d->data) free(d->data);
  free(d);
}

ddos_t *read_ddos(FILE *in) {
  int c;
  uint8_t type;
  uint16_t load, length, exec;
  ddos_t *ddos;

#ifdef DEBUG
  fprintf(stderr, "read_ddos()\n");
#endif
  if((c=getc(in))!=0x55) {
    fprintf(stderr, "Not a bin file 1 %02x\n", c);
    errno=EIO;
    return NULL;
  }
  if ((c=getc(in))!=0x02) {
    fprintf(stderr, "Not a bin file 2\n");
    errno=EIO;
    return NULL;
  }
  type=c;
  load=read16(in);
  length=read16(in);
  exec=read16(in);
  if (feof(in)) {
    fprintf(stderr, "Premature end of file\n");
    errno=EIO;
    return NULL;
  }
  if ((c=getc(in))!=0xaa) {
    fprintf(stderr, "Not a bin file 3\n");
    errno=EIO;
    return NULL;
  }
  ddos=alloc_ddos(length);
  if (fread(ddos->data, 1, length, in)!=length) {
    fprintf(stderr, "Premature end of file\n");
    free_ddos(ddos);
    errno=EIO;
    return NULL;
  }
  ddos->type=type;
  ddos->load=load;
  ddos->length=length;
  ddos->exec=exec;
  return ddos;
}

void write_ddos(FILE *out, ddos_t *d) {
  putc(d->c55, out);
  putc(d->type, out);
  write16(d->load, out);
  write16(d->length, out);
  write16(d->exec, out);
  putc(d->caa, out);
  fwrite(d->data, 1, d->length, out);
}

memory_t *ddos2mem(ddos_t *d) {
  memory_t *mem;

  mem=malloc(sizeof(memory_t));
  mem->data=malloc(0x10000);
  mem->lo=d->load;
  mem->hi=d->load+d->length-1;
  mem->exec=d->exec;
  memcpy(mem->data+mem->lo, d->data, d->length);
  return mem;
}

ddos_t *mem2ddos(memory_t *m) {
  ddos_t *ddos;

  ddos=malloc(sizeof(ddos_t));
  ddos->c55=0x55;
  ddos->type=0x02;
  ddos->load=m->lo;
  ddos->length=m->hi-m->lo+1;
  ddos->exec=m->exec;
  ddos->caa=0xaa;
  ddos->data=malloc(ddos->length);
  memcpy(ddos->data, m->data+m->lo, ddos->length);
  return ddos;
}

void ddos_info(FILE *in, FILE *out) {
  ddos_t *d;

#ifdef DEBUG
  fprintf(stderr, "ddos_info()\n");
#endif
  if (!(d=read_ddos(in))) return;
  fprintf(out, "Type: %02x\n", d->type);
  fprintf(out, "Load address: %04x\n", d->load);
  fprintf(out, "Length: %04x\n", d->length);
  fprintf(out, "Execution address: %04x\n", d->exec);
  free_ddos(d);
}
