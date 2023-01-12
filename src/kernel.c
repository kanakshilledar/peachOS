#include "kernel.h"
#include <stdint.h>
uint16_t terminal_make_char(char c, char color) {
    return (color << 8) | c;
}
void kernel_main() {
    uint16_t * video_mem = (uint16_t *)(0xB8000);         // pointer for colored ascii characters
    video_mem[0] = terminal_make_char('C', 3);
//    video_mem[0] = 0x0341;
}