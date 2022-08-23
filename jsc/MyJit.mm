//
//  MyJit.m
//  jsc
//
//  Created by Lehem on 2022/8/17.
//

#import "MyJit.h"

#include <iostream>
#include <sys/mman.h>

@implementation MyJit


- (long)jit:(long)input {
    const size_t size = 0x1000;
    
    // 开辟内存
#if TARGET_OS_SIMULATOR
    void *addr = mmap(nullptr, size, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE | MAP_ANON, -1, 0);
    //    void *addr = mmap(nullptr, size, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE | MAP_ANON | MAP_JIT, -1, 0);
#else
    void *addr = mmap(nullptr, size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANON, -1, 0);
//    void *addr = mmap(nullptr, size, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE | MAP_ANON, -1, 0);
    //    void *addr = mmap(nullptr, size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANON | MAP_JIT, -1, 0);
#endif
    
    // 以 square 源码
    //    int square(int num) {
    //        return num * num;
    //    }
    // 这个网站可以在线汇编，有多版本编译器可以选择
    // https://godbolt.org/
    
    // 86_64 clang 13.0.0 (iOS 模拟器) 汇编代码
    //    push    rbp
    //    mov     rbp, rsp
    //    mov     dword ptr [rbp - 4], edi
    //    mov     eax, dword ptr [rbp - 4]
    //    imul    eax, dword ptr [rbp - 4]
    //    pop     rbp
    //    ret
    
#if TARGET_OS_SIMULATOR
    // 86_64 的机器码
    unsigned char machineCode[] = {0x55, 0x48, 0x89, 0xE5, 0x89, 0x7D, 0xFC, 0x8B, 0x45, 0xFC, 0x0F, 0xAF, 0x45, 0xFC, 0x5D, 0xC3};
#else
    //    sub     sp, sp, #16
    //    str     w0, [sp, 12]
    //    ldr     w0, [sp, 12]
    //    mul     w0, w0, w0
    //    add     sp, sp, 16
    //    ret
    
    // arm64 gcc 12.1 的机器码
    unsigned char machineCode[] = {0xFF, 0x43, 0x00, 0xD1, 0xE0, 0x0F, 0x00, 0xB9, 0xE0, 0x0F, 0x40, 0xB9, 0x00, 0x7C, 0x00, 0x1B, 0xFF, 0x43, 0x00, 0x91, 0xC0, 0x03, 0x5F, 0xD6};
    
    // arm64 gcc 5.4 的机器码
    //    unsigned char machineCode[] = {0xFF, 0x43, 0x00, 0xD1, 0xE0, 0x0F, 0x00, 0xB9, 0xE1, 0x0F, 0x40, 0xB9, 0xE0, 0x0F, 0x40, 0xB9, 0x20, 0x7C, 0x00, 0x1B, 0xFF, 0x43, 0x00, 0x91, 0xC0, 0x03, 0x5F, 0xD6};
#endif
    
    // 把代码写入到内存中
    memcpy(addr, machineCode, sizeof(machineCode));
    
    
#if TARGET_OS_IPHONE
    // W^R 机制，需要改动权限
    int r = mprotect(addr, size, PROT_READ | PROT_EXEC);
    std::cout << "protect return = " << r << std::endl;
#endif
    
    auto square = (long (*)(long)) addr;
    long result = square(input);
    std::cout << "result = " << result << std::endl;
    return result;
}


@end
