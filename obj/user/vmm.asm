
obj/user/vmm:     file format elf64-x86-64


Disassembly of section .text:

0000000000800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	movabs $USTACKTOP, %rax
  800020:	48 b8 00 e0 7f ef 00 	movabs $0xef7fe000,%rax
  800027:	00 00 00 
	cmpq %rax,%rsp
  80002a:	48 39 c4             	cmp    %rax,%rsp
	jne args_exist
  80002d:	75 04                	jne    800033 <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushq $0
  80002f:	6a 00                	pushq  $0x0
	pushq $0
  800031:	6a 00                	pushq  $0x0

0000000000800033 <args_exist>:

args_exist:
	movq 8(%rsp), %rsi
  800033:	48 8b 74 24 08       	mov    0x8(%rsp),%rsi
	movq (%rsp), %rdi
  800038:	48 8b 3c 24          	mov    (%rsp),%rdi
	call libmain
  80003c:	e8 9c 06 00 00       	callq  8006dd <libmain>
1:	jmp 1b
  800041:	eb fe                	jmp    800041 <args_exist+0xe>

0000000000800043 <map_in_guest>:
//
// Return 0 on success, <0 on failure.
//
static int
map_in_guest( envid_t guest, uintptr_t gpa, size_t memsz, 
	      int fd, size_t filesz, off_t fileoffset ) {
  800043:	55                   	push   %rbp
  800044:	48 89 e5             	mov    %rsp,%rbp
  800047:	48 83 ec 50          	sub    $0x50,%rsp
  80004b:	89 7d dc             	mov    %edi,-0x24(%rbp)
  80004e:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  800052:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800056:	89 4d d8             	mov    %ecx,-0x28(%rbp)
  800059:	4c 89 45 c0          	mov    %r8,-0x40(%rbp)
  80005d:	44 89 4d bc          	mov    %r9d,-0x44(%rbp)
	/* Your code here */
    int i, r;
    void *blk;


    if ((i = PGOFF(gpa))) {
  800061:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800065:	25 ff 0f 00 00       	and    $0xfff,%eax
  80006a:	89 45 fc             	mov    %eax,-0x4(%rbp)
  80006d:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  800071:	74 21                	je     800094 <map_in_guest+0x51>
        gpa -= i;
  800073:	8b 45 fc             	mov    -0x4(%rbp),%eax
  800076:	48 98                	cltq   
  800078:	48 29 45 d0          	sub    %rax,-0x30(%rbp)
        memsz += i;
  80007c:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80007f:	48 98                	cltq   
  800081:	48 01 45 c8          	add    %rax,-0x38(%rbp)
        filesz += i;
  800085:	8b 45 fc             	mov    -0x4(%rbp),%eax
  800088:	48 98                	cltq   
  80008a:	48 01 45 c0          	add    %rax,-0x40(%rbp)
        fileoffset -= i;
  80008e:	8b 45 fc             	mov    -0x4(%rbp),%eax
  800091:	29 45 bc             	sub    %eax,-0x44(%rbp)
    }

    for (i = 0; i < memsz; i += PGSIZE) {
  800094:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  80009b:	e9 0d 02 00 00       	jmpq   8002ad <map_in_guest+0x26a>
        if (i >= filesz) {
  8000a0:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8000a3:	48 98                	cltq   
  8000a5:	48 3b 45 c0          	cmp    -0x40(%rbp),%rax
  8000a9:	0f 82 bf 00 00 00    	jb     80016e <map_in_guest+0x12b>
            if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8000af:	ba 07 00 00 00       	mov    $0x7,%edx
  8000b4:	be 00 00 40 00       	mov    $0x400000,%esi
  8000b9:	bf 00 00 00 00       	mov    $0x0,%edi
  8000be:	48 b8 a0 1e 80 00 00 	movabs $0x801ea0,%rax
  8000c5:	00 00 00 
  8000c8:	ff d0                	callq  *%rax
  8000ca:	89 45 f8             	mov    %eax,-0x8(%rbp)
  8000cd:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  8000d1:	79 08                	jns    8000db <map_in_guest+0x98>
                  return r;
  8000d3:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8000d6:	e9 e6 01 00 00       	jmpq   8002c1 <map_in_guest+0x27e>
            if ((r = sys_ept_map(thisenv->env_id, UTEMP, guest, (void *)(gpa + i), __EPTE_FULL)) < 0)
  8000db:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8000de:	48 63 d0             	movslq %eax,%rdx
  8000e1:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8000e5:	48 01 d0             	add    %rdx,%rax
  8000e8:	48 89 c1             	mov    %rax,%rcx
  8000eb:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  8000f2:	00 00 00 
  8000f5:	48 8b 00             	mov    (%rax),%rax
  8000f8:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  8000fe:	8b 55 dc             	mov    -0x24(%rbp),%edx
  800101:	41 b8 07 00 00 00    	mov    $0x7,%r8d
  800107:	be 00 00 40 00       	mov    $0x400000,%esi
  80010c:	89 c7                	mov    %eax,%edi
  80010e:	48 b8 db 21 80 00 00 	movabs $0x8021db,%rax
  800115:	00 00 00 
  800118:	ff d0                	callq  *%rax
  80011a:	89 45 f8             	mov    %eax,-0x8(%rbp)
  80011d:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  800121:	79 30                	jns    800153 <map_in_guest+0x110>
                  panic("spawn: sys_ept_map data: %e", r);
  800123:	8b 45 f8             	mov    -0x8(%rbp),%eax
  800126:	89 c1                	mov    %eax,%ecx
  800128:	48 ba 20 47 80 00 00 	movabs $0x804720,%rdx
  80012f:	00 00 00 
  800132:	be 26 00 00 00       	mov    $0x26,%esi
  800137:	48 bf 3c 47 80 00 00 	movabs $0x80473c,%rdi
  80013e:	00 00 00 
  800141:	b8 00 00 00 00       	mov    $0x0,%eax
  800146:	49 b8 83 07 80 00 00 	movabs $0x800783,%r8
  80014d:	00 00 00 
  800150:	41 ff d0             	callq  *%r8
            sys_page_unmap(0, UTEMP);
  800153:	be 00 00 40 00       	mov    $0x400000,%esi
  800158:	bf 00 00 00 00       	mov    $0x0,%edi
  80015d:	48 b8 4b 1f 80 00 00 	movabs $0x801f4b,%rax
  800164:	00 00 00 
  800167:	ff d0                	callq  *%rax
  800169:	e9 38 01 00 00       	jmpq   8002a6 <map_in_guest+0x263>

        } else {
            if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80016e:	ba 07 00 00 00       	mov    $0x7,%edx
  800173:	be 00 00 40 00       	mov    $0x400000,%esi
  800178:	bf 00 00 00 00       	mov    $0x0,%edi
  80017d:	48 b8 a0 1e 80 00 00 	movabs $0x801ea0,%rax
  800184:	00 00 00 
  800187:	ff d0                	callq  *%rax
  800189:	89 45 f8             	mov    %eax,-0x8(%rbp)
  80018c:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  800190:	79 08                	jns    80019a <map_in_guest+0x157>
                return r;
  800192:	8b 45 f8             	mov    -0x8(%rbp),%eax
  800195:	e9 27 01 00 00       	jmpq   8002c1 <map_in_guest+0x27e>
            if ((r = seek(fd, fileoffset + i)) < 0)
  80019a:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80019d:	8b 55 bc             	mov    -0x44(%rbp),%edx
  8001a0:	01 c2                	add    %eax,%edx
  8001a2:	8b 45 d8             	mov    -0x28(%rbp),%eax
  8001a5:	89 d6                	mov    %edx,%esi
  8001a7:	89 c7                	mov    %eax,%edi
  8001a9:	48 b8 b4 2a 80 00 00 	movabs $0x802ab4,%rax
  8001b0:	00 00 00 
  8001b3:	ff d0                	callq  *%rax
  8001b5:	89 45 f8             	mov    %eax,-0x8(%rbp)
  8001b8:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  8001bc:	79 08                	jns    8001c6 <map_in_guest+0x183>
                return r;
  8001be:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8001c1:	e9 fb 00 00 00       	jmpq   8002c1 <map_in_guest+0x27e>
            if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8001c6:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%rbp)
  8001cd:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8001d0:	48 98                	cltq   
  8001d2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8001d6:	48 29 c2             	sub    %rax,%rdx
  8001d9:	48 89 d0             	mov    %rdx,%rax
  8001dc:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  8001e0:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8001e3:	48 63 d0             	movslq %eax,%rdx
  8001e6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8001ea:	48 39 c2             	cmp    %rax,%rdx
  8001ed:	48 0f 47 d0          	cmova  %rax,%rdx
  8001f1:	8b 45 d8             	mov    -0x28(%rbp),%eax
  8001f4:	be 00 00 40 00       	mov    $0x400000,%esi
  8001f9:	89 c7                	mov    %eax,%edi
  8001fb:	48 b8 6b 29 80 00 00 	movabs $0x80296b,%rax
  800202:	00 00 00 
  800205:	ff d0                	callq  *%rax
  800207:	89 45 f8             	mov    %eax,-0x8(%rbp)
  80020a:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  80020e:	79 08                	jns    800218 <map_in_guest+0x1d5>
                return r;
  800210:	8b 45 f8             	mov    -0x8(%rbp),%eax
  800213:	e9 a9 00 00 00       	jmpq   8002c1 <map_in_guest+0x27e>
            if ((r = sys_ept_map(thisenv->env_id, UTEMP, guest, (void *)(gpa + i), __EPTE_FULL)) < 0)
  800218:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80021b:	48 63 d0             	movslq %eax,%rdx
  80021e:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800222:	48 01 d0             	add    %rdx,%rax
  800225:	48 89 c1             	mov    %rax,%rcx
  800228:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  80022f:	00 00 00 
  800232:	48 8b 00             	mov    (%rax),%rax
  800235:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  80023b:	8b 55 dc             	mov    -0x24(%rbp),%edx
  80023e:	41 b8 07 00 00 00    	mov    $0x7,%r8d
  800244:	be 00 00 40 00       	mov    $0x400000,%esi
  800249:	89 c7                	mov    %eax,%edi
  80024b:	48 b8 db 21 80 00 00 	movabs $0x8021db,%rax
  800252:	00 00 00 
  800255:	ff d0                	callq  *%rax
  800257:	89 45 f8             	mov    %eax,-0x8(%rbp)
  80025a:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  80025e:	79 30                	jns    800290 <map_in_guest+0x24d>
                panic("spawn: sys_ept_map data: %e", r);
  800260:	8b 45 f8             	mov    -0x8(%rbp),%eax
  800263:	89 c1                	mov    %eax,%ecx
  800265:	48 ba 20 47 80 00 00 	movabs $0x804720,%rdx
  80026c:	00 00 00 
  80026f:	be 31 00 00 00       	mov    $0x31,%esi
  800274:	48 bf 3c 47 80 00 00 	movabs $0x80473c,%rdi
  80027b:	00 00 00 
  80027e:	b8 00 00 00 00       	mov    $0x0,%eax
  800283:	49 b8 83 07 80 00 00 	movabs $0x800783,%r8
  80028a:	00 00 00 
  80028d:	41 ff d0             	callq  *%r8
            sys_page_unmap(0, UTEMP);
  800290:	be 00 00 40 00       	mov    $0x400000,%esi
  800295:	bf 00 00 00 00       	mov    $0x0,%edi
  80029a:	48 b8 4b 1f 80 00 00 	movabs $0x801f4b,%rax
  8002a1:	00 00 00 
  8002a4:	ff d0                	callq  *%rax
    for (i = 0; i < memsz; i += PGSIZE) {
  8002a6:	81 45 fc 00 10 00 00 	addl   $0x1000,-0x4(%rbp)
  8002ad:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8002b0:	48 98                	cltq   
  8002b2:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  8002b6:	0f 82 e4 fd ff ff    	jb     8000a0 <map_in_guest+0x5d>
        }
    }
    return 0;
  8002bc:	b8 00 00 00 00       	mov    $0x0,%eax
} 
  8002c1:	c9                   	leaveq 
  8002c2:	c3                   	retq   

00000000008002c3 <copy_guest_kern_gpa>:
//
// Return 0 on success, <0 on error
//
// Hint: compare with ELF parsing in env.c, and use map_in_guest for each segment.
static int
copy_guest_kern_gpa( envid_t guest, char* fname ) {
  8002c3:	55                   	push   %rbp
  8002c4:	48 89 e5             	mov    %rsp,%rbp
  8002c7:	48 81 ec 40 02 00 00 	sub    $0x240,%rsp
  8002ce:	89 bd cc fd ff ff    	mov    %edi,-0x234(%rbp)
  8002d4:	48 89 b5 c0 fd ff ff 	mov    %rsi,-0x240(%rbp)

        int fd, i, r;
        struct Elf *elf;
        struct Proghdr *ph;
        int perm;
        if ((r = open(fname, O_RDONLY)) < 0)
  8002db:	48 8b 85 c0 fd ff ff 	mov    -0x240(%rbp),%rax
  8002e2:	be 00 00 00 00       	mov    $0x0,%esi
  8002e7:	48 89 c7             	mov    %rax,%rdi
  8002ea:	48 b8 6c 2d 80 00 00 	movabs $0x802d6c,%rax
  8002f1:	00 00 00 
  8002f4:	ff d0                	callq  *%rax
  8002f6:	89 45 f4             	mov    %eax,-0xc(%rbp)
  8002f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
  8002fd:	79 08                	jns    800307 <copy_guest_kern_gpa+0x44>
                return r;
  8002ff:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800302:	e9 61 01 00 00       	jmpq   800468 <copy_guest_kern_gpa+0x1a5>
        fd = r;
  800307:	8b 45 f4             	mov    -0xc(%rbp),%eax
  80030a:	89 45 fc             	mov    %eax,-0x4(%rbp)

        elf = (struct Elf*) elf_buf;
  80030d:	48 8d 85 d0 fd ff ff 	lea    -0x230(%rbp),%rax
  800314:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
        if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)  || elf->e_magic != ELF_MAGIC)
  800318:	48 8d 8d d0 fd ff ff 	lea    -0x230(%rbp),%rcx
  80031f:	8b 45 fc             	mov    -0x4(%rbp),%eax
  800322:	ba 00 02 00 00       	mov    $0x200,%edx
  800327:	48 89 ce             	mov    %rcx,%rsi
  80032a:	89 c7                	mov    %eax,%edi
  80032c:	48 b8 6b 29 80 00 00 	movabs $0x80296b,%rax
  800333:	00 00 00 
  800336:	ff d0                	callq  *%rax
  800338:	3d 00 02 00 00       	cmp    $0x200,%eax
  80033d:	75 0d                	jne    80034c <copy_guest_kern_gpa+0x89>
  80033f:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800343:	8b 00                	mov    (%rax),%eax
  800345:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
  80034a:	74 43                	je     80038f <copy_guest_kern_gpa+0xcc>
        {
                close(fd);
  80034c:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80034f:	89 c7                	mov    %eax,%edi
  800351:	48 b8 74 26 80 00 00 	movabs $0x802674,%rax
  800358:	00 00 00 
  80035b:	ff d0                	callq  *%rax
                cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80035d:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800361:	8b 00                	mov    (%rax),%eax
  800363:	ba 7f 45 4c 46       	mov    $0x464c457f,%edx
  800368:	89 c6                	mov    %eax,%esi
  80036a:	48 bf 47 47 80 00 00 	movabs $0x804747,%rdi
  800371:	00 00 00 
  800374:	b8 00 00 00 00       	mov    $0x0,%eax
  800379:	48 b9 bc 09 80 00 00 	movabs $0x8009bc,%rcx
  800380:	00 00 00 
  800383:	ff d1                	callq  *%rcx
                return -E_NOT_EXEC;
  800385:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80038a:	e9 d9 00 00 00       	jmpq   800468 <copy_guest_kern_gpa+0x1a5>
        }

        ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80038f:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800393:	48 8b 40 20          	mov    0x20(%rax),%rax
  800397:	48 8d 95 d0 fd ff ff 	lea    -0x230(%rbp),%rdx
  80039e:	48 01 d0             	add    %rdx,%rax
  8003a1:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
        for (i = 0; i < elf->e_phnum; i++, ph++) {
  8003a5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  8003ac:	eb 7a                	jmp    800428 <copy_guest_kern_gpa+0x165>
                if (ph->p_type != ELF_PROG_LOAD)
  8003ae:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8003b2:	8b 00                	mov    (%rax),%eax
  8003b4:	83 f8 01             	cmp    $0x1,%eax
  8003b7:	74 02                	je     8003bb <copy_guest_kern_gpa+0xf8>
                        continue;
  8003b9:	eb 64                	jmp    80041f <copy_guest_kern_gpa+0x15c>
                perm = PTE_P | PTE_U;
  8003bb:	c7 45 dc 05 00 00 00 	movl   $0x5,-0x24(%rbp)
                if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8003c2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8003c6:	8b 40 04             	mov    0x4(%rax),%eax
  8003c9:	83 e0 02             	and    $0x2,%eax
  8003cc:	85 c0                	test   %eax,%eax
  8003ce:	74 04                	je     8003d4 <copy_guest_kern_gpa+0x111>
                        perm |= PTE_W;
  8003d0:	83 4d dc 02          	orl    $0x2,-0x24(%rbp)
                if ((r = map_in_guest(guest, ph->p_pa, ph->p_memsz, fd, ph->p_filesz, ph->p_offset)) < 0)
  8003d4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8003d8:	48 8b 40 08          	mov    0x8(%rax),%rax
  8003dc:	41 89 c0             	mov    %eax,%r8d
  8003df:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8003e3:	48 8b 78 20          	mov    0x20(%rax),%rdi
  8003e7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8003eb:	48 8b 50 28          	mov    0x28(%rax),%rdx
  8003ef:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8003f3:	48 8b 70 18          	mov    0x18(%rax),%rsi
  8003f7:	8b 4d fc             	mov    -0x4(%rbp),%ecx
  8003fa:	8b 85 cc fd ff ff    	mov    -0x234(%rbp),%eax
  800400:	45 89 c1             	mov    %r8d,%r9d
  800403:	49 89 f8             	mov    %rdi,%r8
  800406:	89 c7                	mov    %eax,%edi
  800408:	48 b8 43 00 80 00 00 	movabs $0x800043,%rax
  80040f:	00 00 00 
  800412:	ff d0                	callq  *%rax
  800414:	89 45 f4             	mov    %eax,-0xc(%rbp)
  800417:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
  80041b:	79 02                	jns    80041f <copy_guest_kern_gpa+0x15c>
                        goto error;
  80041d:	eb 35                	jmp    800454 <copy_guest_kern_gpa+0x191>
        for (i = 0; i < elf->e_phnum; i++, ph++) {
  80041f:	83 45 f8 01          	addl   $0x1,-0x8(%rbp)
  800423:	48 83 45 e8 38       	addq   $0x38,-0x18(%rbp)
  800428:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80042c:	0f b7 40 38          	movzwl 0x38(%rax),%eax
  800430:	0f b7 c0             	movzwl %ax,%eax
  800433:	3b 45 f8             	cmp    -0x8(%rbp),%eax
  800436:	0f 8f 72 ff ff ff    	jg     8003ae <copy_guest_kern_gpa+0xeb>
        }
        close(fd);
  80043c:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80043f:	89 c7                	mov    %eax,%edi
  800441:	48 b8 74 26 80 00 00 	movabs $0x802674,%rax
  800448:	00 00 00 
  80044b:	ff d0                	callq  *%rax
        fd = -1;
  80044d:	c7 45 fc ff ff ff ff 	movl   $0xffffffff,-0x4(%rbp)

error:
    close(fd);
  800454:	8b 45 fc             	mov    -0x4(%rbp),%eax
  800457:	89 c7                	mov    %eax,%edi
  800459:	48 b8 74 26 80 00 00 	movabs $0x802674,%rax
  800460:	00 00 00 
  800463:	ff d0                	callq  *%rax
    return r;
  800465:	8b 45 f4             	mov    -0xc(%rbp),%eax

}
  800468:	c9                   	leaveq 
  800469:	c3                   	retq   

000000000080046a <umain>:

void
umain(int argc, char **argv) {
  80046a:	55                   	push   %rbp
  80046b:	48 89 e5             	mov    %rsp,%rbp
  80046e:	48 83 ec 60          	sub    $0x60,%rsp
  800472:	89 7d ac             	mov    %edi,-0x54(%rbp)
  800475:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  800479:	be 00 70 00 00       	mov    $0x7000,%esi
  80047e:	bf 00 00 00 01       	mov    $0x1000000,%edi
  800483:	48 b8 36 22 80 00 00 	movabs $0x802236,%rax
  80048a:	00 00 00 
  80048d:	ff d0                	callq  *%rax
  80048f:	89 45 fc             	mov    %eax,-0x4(%rbp)
  800492:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  800496:	79 2c                	jns    8004c4 <umain+0x5a>
  800498:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80049b:	89 c6                	mov    %eax,%esi
  80049d:	48 bf 68 47 80 00 00 	movabs $0x804768,%rdi
  8004a4:	00 00 00 
  8004a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ac:	48 ba bc 09 80 00 00 	movabs $0x8009bc,%rdx
  8004b3:	00 00 00 
  8004b6:	ff d2                	callq  *%rdx
  8004b8:	48 b8 60 07 80 00 00 	movabs $0x800760,%rax
  8004bf:	00 00 00 
  8004c2:	ff d0                	callq  *%rax
  8004c4:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004c7:	89 45 f8             	mov    %eax,-0x8(%rbp)
  8004ca:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8004cd:	48 be 8b 47 80 00 00 	movabs $0x80478b,%rsi
  8004d4:	00 00 00 
  8004d7:	89 c7                	mov    %eax,%edi
  8004d9:	48 b8 c3 02 80 00 00 	movabs $0x8002c3,%rax
  8004e0:	00 00 00 
  8004e3:	ff d0                	callq  *%rax
  8004e5:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8004e8:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8004ec:	79 2c                	jns    80051a <umain+0xb0>
  8004ee:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004f1:	89 c6                	mov    %eax,%esi
  8004f3:	48 bf 98 47 80 00 00 	movabs $0x804798,%rdi
  8004fa:	00 00 00 
  8004fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800502:	48 ba bc 09 80 00 00 	movabs $0x8009bc,%rdx
  800509:	00 00 00 
  80050c:	ff d2                	callq  *%rdx
  80050e:	48 b8 60 07 80 00 00 	movabs $0x800760,%rax
  800515:	00 00 00 
  800518:	ff d0                	callq  *%rax
  80051a:	be 00 00 00 00       	mov    $0x0,%esi
  80051f:	48 bf c1 47 80 00 00 	movabs $0x8047c1,%rdi
  800526:	00 00 00 
  800529:	48 b8 6c 2d 80 00 00 	movabs $0x802d6c,%rax
  800530:	00 00 00 
  800533:	ff d0                	callq  *%rax
  800535:	89 45 f4             	mov    %eax,-0xc(%rbp)
  800538:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
  80053c:	79 36                	jns    800574 <umain+0x10a>
  80053e:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800541:	89 c2                	mov    %eax,%edx
  800543:	48 be c1 47 80 00 00 	movabs $0x8047c1,%rsi
  80054a:	00 00 00 
  80054d:	48 bf cb 47 80 00 00 	movabs $0x8047cb,%rdi
  800554:	00 00 00 
  800557:	b8 00 00 00 00       	mov    $0x0,%eax
  80055c:	48 b9 bc 09 80 00 00 	movabs $0x8009bc,%rcx
  800563:	00 00 00 
  800566:	ff d1                	callq  *%rcx
  800568:	48 b8 60 07 80 00 00 	movabs $0x800760,%rax
  80056f:	00 00 00 
  800572:	ff d0                	callq  *%rax
  800574:	8b 55 f4             	mov    -0xc(%rbp),%edx
  800577:	8b 45 f8             	mov    -0x8(%rbp),%eax
  80057a:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800580:	41 b8 00 02 00 00    	mov    $0x200,%r8d
  800586:	89 d1                	mov    %edx,%ecx
  800588:	ba 00 02 00 00       	mov    $0x200,%edx
  80058d:	be 00 70 00 00       	mov    $0x7000,%esi
  800592:	89 c7                	mov    %eax,%edi
  800594:	48 b8 43 00 80 00 00 	movabs $0x800043,%rax
  80059b:	00 00 00 
  80059e:	ff d0                	callq  *%rax
  8005a0:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8005a3:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8005a7:	79 2c                	jns    8005d5 <umain+0x16b>
  8005a9:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8005ac:	89 c6                	mov    %eax,%esi
  8005ae:	48 bf e8 47 80 00 00 	movabs $0x8047e8,%rdi
  8005b5:	00 00 00 
  8005b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8005bd:	48 ba bc 09 80 00 00 	movabs $0x8009bc,%rdx
  8005c4:	00 00 00 
  8005c7:	ff d2                	callq  *%rdx
  8005c9:	48 b8 60 07 80 00 00 	movabs $0x800760,%rax
  8005d0:	00 00 00 
  8005d3:	ff d0                	callq  *%rax
  8005d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8005da:	48 ba 40 23 80 00 00 	movabs $0x802340,%rdx
  8005e1:	00 00 00 
  8005e4:	ff d2                	callq  *%rdx
  8005e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8005eb:	48 ba 02 23 80 00 00 	movabs $0x802302,%rdx
  8005f2:	00 00 00 
  8005f5:	ff d2                	callq  *%rdx
  8005f7:	89 45 f0             	mov    %eax,-0x10(%rbp)
  8005fa:	8b 55 f0             	mov    -0x10(%rbp),%edx
  8005fd:	48 8d 45 b0          	lea    -0x50(%rbp),%rax
  800601:	89 d1                	mov    %edx,%ecx
  800603:	48 ba 17 48 80 00 00 	movabs $0x804817,%rdx
  80060a:	00 00 00 
  80060d:	be 32 00 00 00       	mov    $0x32,%esi
  800612:	48 89 c7             	mov    %rax,%rdi
  800615:	b8 00 00 00 00       	mov    $0x0,%eax
  80061a:	49 b8 24 14 80 00 00 	movabs $0x801424,%r8
  800621:	00 00 00 
  800624:	41 ff d0             	callq  *%r8
  800627:	8b 45 f0             	mov    -0x10(%rbp),%eax
  80062a:	89 c6                	mov    %eax,%esi
  80062c:	48 bf 28 48 80 00 00 	movabs $0x804828,%rdi
  800633:	00 00 00 
  800636:	b8 00 00 00 00       	mov    $0x0,%eax
  80063b:	48 ba bc 09 80 00 00 	movabs $0x8009bc,%rdx
  800642:	00 00 00 
  800645:	ff d2                	callq  *%rdx
  800647:	48 8d 45 b0          	lea    -0x50(%rbp),%rax
  80064b:	48 89 c6             	mov    %rax,%rsi
  80064e:	48 bf 55 48 80 00 00 	movabs $0x804855,%rdi
  800655:	00 00 00 
  800658:	48 b8 ce 31 80 00 00 	movabs $0x8031ce,%rax
  80065f:	00 00 00 
  800662:	ff d0                	callq  *%rax
  800664:	89 45 ec             	mov    %eax,-0x14(%rbp)
  800667:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  80066b:	79 2c                	jns    800699 <umain+0x22f>
  80066d:	8b 45 ec             	mov    -0x14(%rbp),%eax
  800670:	89 c6                	mov    %eax,%esi
  800672:	48 bf 68 48 80 00 00 	movabs $0x804868,%rdi
  800679:	00 00 00 
  80067c:	b8 00 00 00 00       	mov    $0x0,%eax
  800681:	48 ba bc 09 80 00 00 	movabs $0x8009bc,%rdx
  800688:	00 00 00 
  80068b:	ff d2                	callq  *%rdx
  80068d:	48 b8 60 07 80 00 00 	movabs $0x800760,%rax
  800694:	00 00 00 
  800697:	ff d0                	callq  *%rax
  800699:	48 bf 8b 48 80 00 00 	movabs $0x80488b,%rdi
  8006a0:	00 00 00 
  8006a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a8:	48 ba bc 09 80 00 00 	movabs $0x8009bc,%rdx
  8006af:	00 00 00 
  8006b2:	ff d2                	callq  *%rdx
  8006b4:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8006b7:	be 02 00 00 00       	mov    $0x2,%esi
  8006bc:	89 c7                	mov    %eax,%edi
  8006be:	48 b8 95 1f 80 00 00 	movabs $0x801f95,%rax
  8006c5:	00 00 00 
  8006c8:	ff d0                	callq  *%rax
  8006ca:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8006cd:	89 c7                	mov    %eax,%edi
  8006cf:	48 b8 7e 41 80 00 00 	movabs $0x80417e,%rax
  8006d6:	00 00 00 
  8006d9:	ff d0                	callq  *%rax
  8006db:	c9                   	leaveq 
  8006dc:	c3                   	retq   

00000000008006dd <libmain>:
  8006dd:	55                   	push   %rbp
  8006de:	48 89 e5             	mov    %rsp,%rbp
  8006e1:	48 83 ec 10          	sub    $0x10,%rsp
  8006e5:	89 7d fc             	mov    %edi,-0x4(%rbp)
  8006e8:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8006ec:	48 b8 24 1e 80 00 00 	movabs $0x801e24,%rax
  8006f3:	00 00 00 
  8006f6:	ff d0                	callq  *%rax
  8006f8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8006fd:	48 98                	cltq   
  8006ff:	48 69 d0 68 01 00 00 	imul   $0x168,%rax,%rdx
  800706:	48 b8 00 00 80 00 80 	movabs $0x8000800000,%rax
  80070d:	00 00 00 
  800710:	48 01 c2             	add    %rax,%rdx
  800713:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  80071a:	00 00 00 
  80071d:	48 89 10             	mov    %rdx,(%rax)
  800720:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  800724:	7e 14                	jle    80073a <libmain+0x5d>
  800726:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80072a:	48 8b 10             	mov    (%rax),%rdx
  80072d:	48 b8 00 60 80 00 00 	movabs $0x806000,%rax
  800734:	00 00 00 
  800737:	48 89 10             	mov    %rdx,(%rax)
  80073a:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  80073e:	8b 45 fc             	mov    -0x4(%rbp),%eax
  800741:	48 89 d6             	mov    %rdx,%rsi
  800744:	89 c7                	mov    %eax,%edi
  800746:	48 b8 6a 04 80 00 00 	movabs $0x80046a,%rax
  80074d:	00 00 00 
  800750:	ff d0                	callq  *%rax
  800752:	48 b8 60 07 80 00 00 	movabs $0x800760,%rax
  800759:	00 00 00 
  80075c:	ff d0                	callq  *%rax
  80075e:	c9                   	leaveq 
  80075f:	c3                   	retq   

0000000000800760 <exit>:
  800760:	55                   	push   %rbp
  800761:	48 89 e5             	mov    %rsp,%rbp
  800764:	48 b8 bf 26 80 00 00 	movabs $0x8026bf,%rax
  80076b:	00 00 00 
  80076e:	ff d0                	callq  *%rax
  800770:	bf 00 00 00 00       	mov    $0x0,%edi
  800775:	48 b8 e0 1d 80 00 00 	movabs $0x801de0,%rax
  80077c:	00 00 00 
  80077f:	ff d0                	callq  *%rax
  800781:	5d                   	pop    %rbp
  800782:	c3                   	retq   

0000000000800783 <_panic>:
  800783:	55                   	push   %rbp
  800784:	48 89 e5             	mov    %rsp,%rbp
  800787:	53                   	push   %rbx
  800788:	48 81 ec f8 00 00 00 	sub    $0xf8,%rsp
  80078f:	48 89 bd 18 ff ff ff 	mov    %rdi,-0xe8(%rbp)
  800796:	89 b5 14 ff ff ff    	mov    %esi,-0xec(%rbp)
  80079c:	48 89 8d 58 ff ff ff 	mov    %rcx,-0xa8(%rbp)
  8007a3:	4c 89 85 60 ff ff ff 	mov    %r8,-0xa0(%rbp)
  8007aa:	4c 89 8d 68 ff ff ff 	mov    %r9,-0x98(%rbp)
  8007b1:	84 c0                	test   %al,%al
  8007b3:	74 23                	je     8007d8 <_panic+0x55>
  8007b5:	0f 29 85 70 ff ff ff 	movaps %xmm0,-0x90(%rbp)
  8007bc:	0f 29 4d 80          	movaps %xmm1,-0x80(%rbp)
  8007c0:	0f 29 55 90          	movaps %xmm2,-0x70(%rbp)
  8007c4:	0f 29 5d a0          	movaps %xmm3,-0x60(%rbp)
  8007c8:	0f 29 65 b0          	movaps %xmm4,-0x50(%rbp)
  8007cc:	0f 29 6d c0          	movaps %xmm5,-0x40(%rbp)
  8007d0:	0f 29 75 d0          	movaps %xmm6,-0x30(%rbp)
  8007d4:	0f 29 7d e0          	movaps %xmm7,-0x20(%rbp)
  8007d8:	48 89 95 08 ff ff ff 	mov    %rdx,-0xf8(%rbp)
  8007df:	c7 85 28 ff ff ff 18 	movl   $0x18,-0xd8(%rbp)
  8007e6:	00 00 00 
  8007e9:	c7 85 2c ff ff ff 30 	movl   $0x30,-0xd4(%rbp)
  8007f0:	00 00 00 
  8007f3:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8007f7:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
  8007fe:	48 8d 85 40 ff ff ff 	lea    -0xc0(%rbp),%rax
  800805:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  80080c:	48 b8 00 60 80 00 00 	movabs $0x806000,%rax
  800813:	00 00 00 
  800816:	48 8b 18             	mov    (%rax),%rbx
  800819:	48 b8 24 1e 80 00 00 	movabs $0x801e24,%rax
  800820:	00 00 00 
  800823:	ff d0                	callq  *%rax
  800825:	8b 8d 14 ff ff ff    	mov    -0xec(%rbp),%ecx
  80082b:	48 8b 95 18 ff ff ff 	mov    -0xe8(%rbp),%rdx
  800832:	41 89 c8             	mov    %ecx,%r8d
  800835:	48 89 d1             	mov    %rdx,%rcx
  800838:	48 89 da             	mov    %rbx,%rdx
  80083b:	89 c6                	mov    %eax,%esi
  80083d:	48 bf b0 48 80 00 00 	movabs $0x8048b0,%rdi
  800844:	00 00 00 
  800847:	b8 00 00 00 00       	mov    $0x0,%eax
  80084c:	49 b9 bc 09 80 00 00 	movabs $0x8009bc,%r9
  800853:	00 00 00 
  800856:	41 ff d1             	callq  *%r9
  800859:	48 8d 95 28 ff ff ff 	lea    -0xd8(%rbp),%rdx
  800860:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
  800867:	48 89 d6             	mov    %rdx,%rsi
  80086a:	48 89 c7             	mov    %rax,%rdi
  80086d:	48 b8 10 09 80 00 00 	movabs $0x800910,%rax
  800874:	00 00 00 
  800877:	ff d0                	callq  *%rax
  800879:	48 bf d3 48 80 00 00 	movabs $0x8048d3,%rdi
  800880:	00 00 00 
  800883:	b8 00 00 00 00       	mov    $0x0,%eax
  800888:	48 ba bc 09 80 00 00 	movabs $0x8009bc,%rdx
  80088f:	00 00 00 
  800892:	ff d2                	callq  *%rdx
  800894:	cc                   	int3   
  800895:	eb fd                	jmp    800894 <_panic+0x111>

0000000000800897 <putch>:
  800897:	55                   	push   %rbp
  800898:	48 89 e5             	mov    %rsp,%rbp
  80089b:	48 83 ec 10          	sub    $0x10,%rsp
  80089f:	89 7d fc             	mov    %edi,-0x4(%rbp)
  8008a2:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8008a6:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8008aa:	8b 00                	mov    (%rax),%eax
  8008ac:	8d 48 01             	lea    0x1(%rax),%ecx
  8008af:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8008b3:	89 0a                	mov    %ecx,(%rdx)
  8008b5:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8008b8:	89 d1                	mov    %edx,%ecx
  8008ba:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8008be:	48 98                	cltq   
  8008c0:	88 4c 02 08          	mov    %cl,0x8(%rdx,%rax,1)
  8008c4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8008c8:	8b 00                	mov    (%rax),%eax
  8008ca:	3d ff 00 00 00       	cmp    $0xff,%eax
  8008cf:	75 2c                	jne    8008fd <putch+0x66>
  8008d1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8008d5:	8b 00                	mov    (%rax),%eax
  8008d7:	48 98                	cltq   
  8008d9:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8008dd:	48 83 c2 08          	add    $0x8,%rdx
  8008e1:	48 89 c6             	mov    %rax,%rsi
  8008e4:	48 89 d7             	mov    %rdx,%rdi
  8008e7:	48 b8 58 1d 80 00 00 	movabs $0x801d58,%rax
  8008ee:	00 00 00 
  8008f1:	ff d0                	callq  *%rax
  8008f3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8008f7:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
  8008fd:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800901:	8b 40 04             	mov    0x4(%rax),%eax
  800904:	8d 50 01             	lea    0x1(%rax),%edx
  800907:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80090b:	89 50 04             	mov    %edx,0x4(%rax)
  80090e:	c9                   	leaveq 
  80090f:	c3                   	retq   

0000000000800910 <vcprintf>:
  800910:	55                   	push   %rbp
  800911:	48 89 e5             	mov    %rsp,%rbp
  800914:	48 81 ec 40 01 00 00 	sub    $0x140,%rsp
  80091b:	48 89 bd c8 fe ff ff 	mov    %rdi,-0x138(%rbp)
  800922:	48 89 b5 c0 fe ff ff 	mov    %rsi,-0x140(%rbp)
  800929:	48 8d 85 d8 fe ff ff 	lea    -0x128(%rbp),%rax
  800930:	48 8b 95 c0 fe ff ff 	mov    -0x140(%rbp),%rdx
  800937:	48 8b 0a             	mov    (%rdx),%rcx
  80093a:	48 89 08             	mov    %rcx,(%rax)
  80093d:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  800941:	48 89 48 08          	mov    %rcx,0x8(%rax)
  800945:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  800949:	48 89 50 10          	mov    %rdx,0x10(%rax)
  80094d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800954:	00 00 00 
  800957:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  80095e:	00 00 00 
  800961:	48 8d 8d d8 fe ff ff 	lea    -0x128(%rbp),%rcx
  800968:	48 8b 95 c8 fe ff ff 	mov    -0x138(%rbp),%rdx
  80096f:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800976:	48 89 c6             	mov    %rax,%rsi
  800979:	48 bf 97 08 80 00 00 	movabs $0x800897,%rdi
  800980:	00 00 00 
  800983:	48 b8 6f 0d 80 00 00 	movabs $0x800d6f,%rax
  80098a:	00 00 00 
  80098d:	ff d0                	callq  *%rax
  80098f:	8b 85 f0 fe ff ff    	mov    -0x110(%rbp),%eax
  800995:	48 98                	cltq   
  800997:	48 8d 95 f0 fe ff ff 	lea    -0x110(%rbp),%rdx
  80099e:	48 83 c2 08          	add    $0x8,%rdx
  8009a2:	48 89 c6             	mov    %rax,%rsi
  8009a5:	48 89 d7             	mov    %rdx,%rdi
  8009a8:	48 b8 58 1d 80 00 00 	movabs $0x801d58,%rax
  8009af:	00 00 00 
  8009b2:	ff d0                	callq  *%rax
  8009b4:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8009ba:	c9                   	leaveq 
  8009bb:	c3                   	retq   

00000000008009bc <cprintf>:
  8009bc:	55                   	push   %rbp
  8009bd:	48 89 e5             	mov    %rsp,%rbp
  8009c0:	48 81 ec 00 01 00 00 	sub    $0x100,%rsp
  8009c7:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8009ce:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8009d5:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8009dc:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8009e3:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8009ea:	84 c0                	test   %al,%al
  8009ec:	74 20                	je     800a0e <cprintf+0x52>
  8009ee:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8009f2:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8009f6:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8009fa:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8009fe:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800a02:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800a06:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800a0a:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  800a0e:	48 89 bd 08 ff ff ff 	mov    %rdi,-0xf8(%rbp)
  800a15:	c7 85 30 ff ff ff 08 	movl   $0x8,-0xd0(%rbp)
  800a1c:	00 00 00 
  800a1f:	c7 85 34 ff ff ff 30 	movl   $0x30,-0xcc(%rbp)
  800a26:	00 00 00 
  800a29:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800a2d:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  800a34:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800a3b:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800a42:	48 8d 85 18 ff ff ff 	lea    -0xe8(%rbp),%rax
  800a49:	48 8d 95 30 ff ff ff 	lea    -0xd0(%rbp),%rdx
  800a50:	48 8b 0a             	mov    (%rdx),%rcx
  800a53:	48 89 08             	mov    %rcx,(%rax)
  800a56:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  800a5a:	48 89 48 08          	mov    %rcx,0x8(%rax)
  800a5e:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  800a62:	48 89 50 10          	mov    %rdx,0x10(%rax)
  800a66:	48 8d 95 18 ff ff ff 	lea    -0xe8(%rbp),%rdx
  800a6d:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
  800a74:	48 89 d6             	mov    %rdx,%rsi
  800a77:	48 89 c7             	mov    %rax,%rdi
  800a7a:	48 b8 10 09 80 00 00 	movabs $0x800910,%rax
  800a81:	00 00 00 
  800a84:	ff d0                	callq  *%rax
  800a86:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%rbp)
  800a8c:	8b 85 4c ff ff ff    	mov    -0xb4(%rbp),%eax
  800a92:	c9                   	leaveq 
  800a93:	c3                   	retq   

0000000000800a94 <printnum>:
  800a94:	55                   	push   %rbp
  800a95:	48 89 e5             	mov    %rsp,%rbp
  800a98:	53                   	push   %rbx
  800a99:	48 83 ec 38          	sub    $0x38,%rsp
  800a9d:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  800aa1:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  800aa5:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  800aa9:	89 4d d4             	mov    %ecx,-0x2c(%rbp)
  800aac:	44 89 45 d0          	mov    %r8d,-0x30(%rbp)
  800ab0:	44 89 4d cc          	mov    %r9d,-0x34(%rbp)
  800ab4:	8b 45 d4             	mov    -0x2c(%rbp),%eax
  800ab7:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  800abb:	77 3b                	ja     800af8 <printnum+0x64>
  800abd:	8b 45 d0             	mov    -0x30(%rbp),%eax
  800ac0:	44 8d 40 ff          	lea    -0x1(%rax),%r8d
  800ac4:	8b 5d d4             	mov    -0x2c(%rbp),%ebx
  800ac7:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800acb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad0:	48 f7 f3             	div    %rbx
  800ad3:	48 89 c2             	mov    %rax,%rdx
  800ad6:	8b 7d cc             	mov    -0x34(%rbp),%edi
  800ad9:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
  800adc:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
  800ae0:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800ae4:	41 89 f9             	mov    %edi,%r9d
  800ae7:	48 89 c7             	mov    %rax,%rdi
  800aea:	48 b8 94 0a 80 00 00 	movabs $0x800a94,%rax
  800af1:	00 00 00 
  800af4:	ff d0                	callq  *%rax
  800af6:	eb 1e                	jmp    800b16 <printnum+0x82>
  800af8:	eb 12                	jmp    800b0c <printnum+0x78>
  800afa:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  800afe:	8b 55 cc             	mov    -0x34(%rbp),%edx
  800b01:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800b05:	48 89 ce             	mov    %rcx,%rsi
  800b08:	89 d7                	mov    %edx,%edi
  800b0a:	ff d0                	callq  *%rax
  800b0c:	83 6d d0 01          	subl   $0x1,-0x30(%rbp)
  800b10:	83 7d d0 00          	cmpl   $0x0,-0x30(%rbp)
  800b14:	7f e4                	jg     800afa <printnum+0x66>
  800b16:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
  800b19:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800b1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b22:	48 f7 f1             	div    %rcx
  800b25:	48 89 d0             	mov    %rdx,%rax
  800b28:	48 ba d0 4a 80 00 00 	movabs $0x804ad0,%rdx
  800b2f:	00 00 00 
  800b32:	0f b6 04 02          	movzbl (%rdx,%rax,1),%eax
  800b36:	0f be d0             	movsbl %al,%edx
  800b39:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  800b3d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800b41:	48 89 ce             	mov    %rcx,%rsi
  800b44:	89 d7                	mov    %edx,%edi
  800b46:	ff d0                	callq  *%rax
  800b48:	48 83 c4 38          	add    $0x38,%rsp
  800b4c:	5b                   	pop    %rbx
  800b4d:	5d                   	pop    %rbp
  800b4e:	c3                   	retq   

0000000000800b4f <getuint>:
  800b4f:	55                   	push   %rbp
  800b50:	48 89 e5             	mov    %rsp,%rbp
  800b53:	48 83 ec 1c          	sub    $0x1c,%rsp
  800b57:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  800b5b:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  800b5e:	83 7d e4 01          	cmpl   $0x1,-0x1c(%rbp)
  800b62:	7e 52                	jle    800bb6 <getuint+0x67>
  800b64:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800b68:	8b 00                	mov    (%rax),%eax
  800b6a:	83 f8 30             	cmp    $0x30,%eax
  800b6d:	73 24                	jae    800b93 <getuint+0x44>
  800b6f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800b73:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800b77:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800b7b:	8b 00                	mov    (%rax),%eax
  800b7d:	89 c0                	mov    %eax,%eax
  800b7f:	48 01 d0             	add    %rdx,%rax
  800b82:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800b86:	8b 12                	mov    (%rdx),%edx
  800b88:	8d 4a 08             	lea    0x8(%rdx),%ecx
  800b8b:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800b8f:	89 0a                	mov    %ecx,(%rdx)
  800b91:	eb 17                	jmp    800baa <getuint+0x5b>
  800b93:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800b97:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800b9b:	48 89 d0             	mov    %rdx,%rax
  800b9e:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800ba2:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800ba6:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  800baa:	48 8b 00             	mov    (%rax),%rax
  800bad:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800bb1:	e9 a3 00 00 00       	jmpq   800c59 <getuint+0x10a>
  800bb6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  800bba:	74 4f                	je     800c0b <getuint+0xbc>
  800bbc:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800bc0:	8b 00                	mov    (%rax),%eax
  800bc2:	83 f8 30             	cmp    $0x30,%eax
  800bc5:	73 24                	jae    800beb <getuint+0x9c>
  800bc7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800bcb:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800bcf:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800bd3:	8b 00                	mov    (%rax),%eax
  800bd5:	89 c0                	mov    %eax,%eax
  800bd7:	48 01 d0             	add    %rdx,%rax
  800bda:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800bde:	8b 12                	mov    (%rdx),%edx
  800be0:	8d 4a 08             	lea    0x8(%rdx),%ecx
  800be3:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800be7:	89 0a                	mov    %ecx,(%rdx)
  800be9:	eb 17                	jmp    800c02 <getuint+0xb3>
  800beb:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800bef:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800bf3:	48 89 d0             	mov    %rdx,%rax
  800bf6:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800bfa:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800bfe:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  800c02:	48 8b 00             	mov    (%rax),%rax
  800c05:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800c09:	eb 4e                	jmp    800c59 <getuint+0x10a>
  800c0b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800c0f:	8b 00                	mov    (%rax),%eax
  800c11:	83 f8 30             	cmp    $0x30,%eax
  800c14:	73 24                	jae    800c3a <getuint+0xeb>
  800c16:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800c1a:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800c1e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800c22:	8b 00                	mov    (%rax),%eax
  800c24:	89 c0                	mov    %eax,%eax
  800c26:	48 01 d0             	add    %rdx,%rax
  800c29:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800c2d:	8b 12                	mov    (%rdx),%edx
  800c2f:	8d 4a 08             	lea    0x8(%rdx),%ecx
  800c32:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800c36:	89 0a                	mov    %ecx,(%rdx)
  800c38:	eb 17                	jmp    800c51 <getuint+0x102>
  800c3a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800c3e:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800c42:	48 89 d0             	mov    %rdx,%rax
  800c45:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800c49:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800c4d:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  800c51:	8b 00                	mov    (%rax),%eax
  800c53:	89 c0                	mov    %eax,%eax
  800c55:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800c59:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800c5d:	c9                   	leaveq 
  800c5e:	c3                   	retq   

0000000000800c5f <getint>:
  800c5f:	55                   	push   %rbp
  800c60:	48 89 e5             	mov    %rsp,%rbp
  800c63:	48 83 ec 1c          	sub    $0x1c,%rsp
  800c67:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  800c6b:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  800c6e:	83 7d e4 01          	cmpl   $0x1,-0x1c(%rbp)
  800c72:	7e 52                	jle    800cc6 <getint+0x67>
  800c74:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800c78:	8b 00                	mov    (%rax),%eax
  800c7a:	83 f8 30             	cmp    $0x30,%eax
  800c7d:	73 24                	jae    800ca3 <getint+0x44>
  800c7f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800c83:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800c87:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800c8b:	8b 00                	mov    (%rax),%eax
  800c8d:	89 c0                	mov    %eax,%eax
  800c8f:	48 01 d0             	add    %rdx,%rax
  800c92:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800c96:	8b 12                	mov    (%rdx),%edx
  800c98:	8d 4a 08             	lea    0x8(%rdx),%ecx
  800c9b:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800c9f:	89 0a                	mov    %ecx,(%rdx)
  800ca1:	eb 17                	jmp    800cba <getint+0x5b>
  800ca3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800ca7:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800cab:	48 89 d0             	mov    %rdx,%rax
  800cae:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800cb2:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800cb6:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  800cba:	48 8b 00             	mov    (%rax),%rax
  800cbd:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800cc1:	e9 a3 00 00 00       	jmpq   800d69 <getint+0x10a>
  800cc6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  800cca:	74 4f                	je     800d1b <getint+0xbc>
  800ccc:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800cd0:	8b 00                	mov    (%rax),%eax
  800cd2:	83 f8 30             	cmp    $0x30,%eax
  800cd5:	73 24                	jae    800cfb <getint+0x9c>
  800cd7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800cdb:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800cdf:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800ce3:	8b 00                	mov    (%rax),%eax
  800ce5:	89 c0                	mov    %eax,%eax
  800ce7:	48 01 d0             	add    %rdx,%rax
  800cea:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800cee:	8b 12                	mov    (%rdx),%edx
  800cf0:	8d 4a 08             	lea    0x8(%rdx),%ecx
  800cf3:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800cf7:	89 0a                	mov    %ecx,(%rdx)
  800cf9:	eb 17                	jmp    800d12 <getint+0xb3>
  800cfb:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800cff:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800d03:	48 89 d0             	mov    %rdx,%rax
  800d06:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800d0a:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800d0e:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  800d12:	48 8b 00             	mov    (%rax),%rax
  800d15:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800d19:	eb 4e                	jmp    800d69 <getint+0x10a>
  800d1b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800d1f:	8b 00                	mov    (%rax),%eax
  800d21:	83 f8 30             	cmp    $0x30,%eax
  800d24:	73 24                	jae    800d4a <getint+0xeb>
  800d26:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800d2a:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800d2e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800d32:	8b 00                	mov    (%rax),%eax
  800d34:	89 c0                	mov    %eax,%eax
  800d36:	48 01 d0             	add    %rdx,%rax
  800d39:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800d3d:	8b 12                	mov    (%rdx),%edx
  800d3f:	8d 4a 08             	lea    0x8(%rdx),%ecx
  800d42:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800d46:	89 0a                	mov    %ecx,(%rdx)
  800d48:	eb 17                	jmp    800d61 <getint+0x102>
  800d4a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800d4e:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800d52:	48 89 d0             	mov    %rdx,%rax
  800d55:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800d59:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800d5d:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  800d61:	8b 00                	mov    (%rax),%eax
  800d63:	48 98                	cltq   
  800d65:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800d69:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800d6d:	c9                   	leaveq 
  800d6e:	c3                   	retq   

0000000000800d6f <vprintfmt>:
  800d6f:	55                   	push   %rbp
  800d70:	48 89 e5             	mov    %rsp,%rbp
  800d73:	41 54                	push   %r12
  800d75:	53                   	push   %rbx
  800d76:	48 83 ec 60          	sub    $0x60,%rsp
  800d7a:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  800d7e:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  800d82:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  800d86:	48 89 4d 90          	mov    %rcx,-0x70(%rbp)
  800d8a:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  800d8e:	48 8b 55 90          	mov    -0x70(%rbp),%rdx
  800d92:	48 8b 0a             	mov    (%rdx),%rcx
  800d95:	48 89 08             	mov    %rcx,(%rax)
  800d98:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  800d9c:	48 89 48 08          	mov    %rcx,0x8(%rax)
  800da0:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  800da4:	48 89 50 10          	mov    %rdx,0x10(%rax)
  800da8:	eb 17                	jmp    800dc1 <vprintfmt+0x52>
  800daa:	85 db                	test   %ebx,%ebx
  800dac:	0f 84 cc 04 00 00    	je     80127e <vprintfmt+0x50f>
  800db2:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  800db6:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800dba:	48 89 d6             	mov    %rdx,%rsi
  800dbd:	89 df                	mov    %ebx,%edi
  800dbf:	ff d0                	callq  *%rax
  800dc1:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800dc5:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800dc9:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  800dcd:	0f b6 00             	movzbl (%rax),%eax
  800dd0:	0f b6 d8             	movzbl %al,%ebx
  800dd3:	83 fb 25             	cmp    $0x25,%ebx
  800dd6:	75 d2                	jne    800daa <vprintfmt+0x3b>
  800dd8:	c6 45 d3 20          	movb   $0x20,-0x2d(%rbp)
  800ddc:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%rbp)
  800de3:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%rbp)
  800dea:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%rbp)
  800df1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%rbp)
  800df8:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800dfc:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800e00:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  800e04:	0f b6 00             	movzbl (%rax),%eax
  800e07:	0f b6 d8             	movzbl %al,%ebx
  800e0a:	8d 43 dd             	lea    -0x23(%rbx),%eax
  800e0d:	83 f8 55             	cmp    $0x55,%eax
  800e10:	0f 87 34 04 00 00    	ja     80124a <vprintfmt+0x4db>
  800e16:	89 c0                	mov    %eax,%eax
  800e18:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  800e1f:	00 
  800e20:	48 b8 f8 4a 80 00 00 	movabs $0x804af8,%rax
  800e27:	00 00 00 
  800e2a:	48 01 d0             	add    %rdx,%rax
  800e2d:	48 8b 00             	mov    (%rax),%rax
  800e30:	ff e0                	jmpq   *%rax
  800e32:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%rbp)
  800e36:	eb c0                	jmp    800df8 <vprintfmt+0x89>
  800e38:	c6 45 d3 30          	movb   $0x30,-0x2d(%rbp)
  800e3c:	eb ba                	jmp    800df8 <vprintfmt+0x89>
  800e3e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%rbp)
  800e45:	8b 55 d8             	mov    -0x28(%rbp),%edx
  800e48:	89 d0                	mov    %edx,%eax
  800e4a:	c1 e0 02             	shl    $0x2,%eax
  800e4d:	01 d0                	add    %edx,%eax
  800e4f:	01 c0                	add    %eax,%eax
  800e51:	01 d8                	add    %ebx,%eax
  800e53:	83 e8 30             	sub    $0x30,%eax
  800e56:	89 45 d8             	mov    %eax,-0x28(%rbp)
  800e59:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800e5d:	0f b6 00             	movzbl (%rax),%eax
  800e60:	0f be d8             	movsbl %al,%ebx
  800e63:	83 fb 2f             	cmp    $0x2f,%ebx
  800e66:	7e 0c                	jle    800e74 <vprintfmt+0x105>
  800e68:	83 fb 39             	cmp    $0x39,%ebx
  800e6b:	7f 07                	jg     800e74 <vprintfmt+0x105>
  800e6d:	48 83 45 98 01       	addq   $0x1,-0x68(%rbp)
  800e72:	eb d1                	jmp    800e45 <vprintfmt+0xd6>
  800e74:	eb 58                	jmp    800ece <vprintfmt+0x15f>
  800e76:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800e79:	83 f8 30             	cmp    $0x30,%eax
  800e7c:	73 17                	jae    800e95 <vprintfmt+0x126>
  800e7e:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800e82:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800e85:	89 c0                	mov    %eax,%eax
  800e87:	48 01 d0             	add    %rdx,%rax
  800e8a:	8b 55 b8             	mov    -0x48(%rbp),%edx
  800e8d:	83 c2 08             	add    $0x8,%edx
  800e90:	89 55 b8             	mov    %edx,-0x48(%rbp)
  800e93:	eb 0f                	jmp    800ea4 <vprintfmt+0x135>
  800e95:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800e99:	48 89 d0             	mov    %rdx,%rax
  800e9c:	48 83 c2 08          	add    $0x8,%rdx
  800ea0:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  800ea4:	8b 00                	mov    (%rax),%eax
  800ea6:	89 45 d8             	mov    %eax,-0x28(%rbp)
  800ea9:	eb 23                	jmp    800ece <vprintfmt+0x15f>
  800eab:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800eaf:	79 0c                	jns    800ebd <vprintfmt+0x14e>
  800eb1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%rbp)
  800eb8:	e9 3b ff ff ff       	jmpq   800df8 <vprintfmt+0x89>
  800ebd:	e9 36 ff ff ff       	jmpq   800df8 <vprintfmt+0x89>
  800ec2:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%rbp)
  800ec9:	e9 2a ff ff ff       	jmpq   800df8 <vprintfmt+0x89>
  800ece:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800ed2:	79 12                	jns    800ee6 <vprintfmt+0x177>
  800ed4:	8b 45 d8             	mov    -0x28(%rbp),%eax
  800ed7:	89 45 dc             	mov    %eax,-0x24(%rbp)
  800eda:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%rbp)
  800ee1:	e9 12 ff ff ff       	jmpq   800df8 <vprintfmt+0x89>
  800ee6:	e9 0d ff ff ff       	jmpq   800df8 <vprintfmt+0x89>
  800eeb:	83 45 e0 01          	addl   $0x1,-0x20(%rbp)
  800eef:	e9 04 ff ff ff       	jmpq   800df8 <vprintfmt+0x89>
  800ef4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ef7:	83 f8 30             	cmp    $0x30,%eax
  800efa:	73 17                	jae    800f13 <vprintfmt+0x1a4>
  800efc:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800f00:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800f03:	89 c0                	mov    %eax,%eax
  800f05:	48 01 d0             	add    %rdx,%rax
  800f08:	8b 55 b8             	mov    -0x48(%rbp),%edx
  800f0b:	83 c2 08             	add    $0x8,%edx
  800f0e:	89 55 b8             	mov    %edx,-0x48(%rbp)
  800f11:	eb 0f                	jmp    800f22 <vprintfmt+0x1b3>
  800f13:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800f17:	48 89 d0             	mov    %rdx,%rax
  800f1a:	48 83 c2 08          	add    $0x8,%rdx
  800f1e:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  800f22:	8b 10                	mov    (%rax),%edx
  800f24:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  800f28:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800f2c:	48 89 ce             	mov    %rcx,%rsi
  800f2f:	89 d7                	mov    %edx,%edi
  800f31:	ff d0                	callq  *%rax
  800f33:	e9 40 03 00 00       	jmpq   801278 <vprintfmt+0x509>
  800f38:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800f3b:	83 f8 30             	cmp    $0x30,%eax
  800f3e:	73 17                	jae    800f57 <vprintfmt+0x1e8>
  800f40:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800f44:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800f47:	89 c0                	mov    %eax,%eax
  800f49:	48 01 d0             	add    %rdx,%rax
  800f4c:	8b 55 b8             	mov    -0x48(%rbp),%edx
  800f4f:	83 c2 08             	add    $0x8,%edx
  800f52:	89 55 b8             	mov    %edx,-0x48(%rbp)
  800f55:	eb 0f                	jmp    800f66 <vprintfmt+0x1f7>
  800f57:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800f5b:	48 89 d0             	mov    %rdx,%rax
  800f5e:	48 83 c2 08          	add    $0x8,%rdx
  800f62:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  800f66:	8b 18                	mov    (%rax),%ebx
  800f68:	85 db                	test   %ebx,%ebx
  800f6a:	79 02                	jns    800f6e <vprintfmt+0x1ff>
  800f6c:	f7 db                	neg    %ebx
  800f6e:	83 fb 15             	cmp    $0x15,%ebx
  800f71:	7f 16                	jg     800f89 <vprintfmt+0x21a>
  800f73:	48 b8 20 4a 80 00 00 	movabs $0x804a20,%rax
  800f7a:	00 00 00 
  800f7d:	48 63 d3             	movslq %ebx,%rdx
  800f80:	4c 8b 24 d0          	mov    (%rax,%rdx,8),%r12
  800f84:	4d 85 e4             	test   %r12,%r12
  800f87:	75 2e                	jne    800fb7 <vprintfmt+0x248>
  800f89:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  800f8d:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800f91:	89 d9                	mov    %ebx,%ecx
  800f93:	48 ba e1 4a 80 00 00 	movabs $0x804ae1,%rdx
  800f9a:	00 00 00 
  800f9d:	48 89 c7             	mov    %rax,%rdi
  800fa0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa5:	49 b8 87 12 80 00 00 	movabs $0x801287,%r8
  800fac:	00 00 00 
  800faf:	41 ff d0             	callq  *%r8
  800fb2:	e9 c1 02 00 00       	jmpq   801278 <vprintfmt+0x509>
  800fb7:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  800fbb:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800fbf:	4c 89 e1             	mov    %r12,%rcx
  800fc2:	48 ba ea 4a 80 00 00 	movabs $0x804aea,%rdx
  800fc9:	00 00 00 
  800fcc:	48 89 c7             	mov    %rax,%rdi
  800fcf:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd4:	49 b8 87 12 80 00 00 	movabs $0x801287,%r8
  800fdb:	00 00 00 
  800fde:	41 ff d0             	callq  *%r8
  800fe1:	e9 92 02 00 00       	jmpq   801278 <vprintfmt+0x509>
  800fe6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800fe9:	83 f8 30             	cmp    $0x30,%eax
  800fec:	73 17                	jae    801005 <vprintfmt+0x296>
  800fee:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800ff2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ff5:	89 c0                	mov    %eax,%eax
  800ff7:	48 01 d0             	add    %rdx,%rax
  800ffa:	8b 55 b8             	mov    -0x48(%rbp),%edx
  800ffd:	83 c2 08             	add    $0x8,%edx
  801000:	89 55 b8             	mov    %edx,-0x48(%rbp)
  801003:	eb 0f                	jmp    801014 <vprintfmt+0x2a5>
  801005:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  801009:	48 89 d0             	mov    %rdx,%rax
  80100c:	48 83 c2 08          	add    $0x8,%rdx
  801010:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  801014:	4c 8b 20             	mov    (%rax),%r12
  801017:	4d 85 e4             	test   %r12,%r12
  80101a:	75 0a                	jne    801026 <vprintfmt+0x2b7>
  80101c:	49 bc ed 4a 80 00 00 	movabs $0x804aed,%r12
  801023:	00 00 00 
  801026:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  80102a:	7e 3f                	jle    80106b <vprintfmt+0x2fc>
  80102c:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%rbp)
  801030:	74 39                	je     80106b <vprintfmt+0x2fc>
  801032:	8b 45 d8             	mov    -0x28(%rbp),%eax
  801035:	48 98                	cltq   
  801037:	48 89 c6             	mov    %rax,%rsi
  80103a:	4c 89 e7             	mov    %r12,%rdi
  80103d:	48 b8 33 15 80 00 00 	movabs $0x801533,%rax
  801044:	00 00 00 
  801047:	ff d0                	callq  *%rax
  801049:	29 45 dc             	sub    %eax,-0x24(%rbp)
  80104c:	eb 17                	jmp    801065 <vprintfmt+0x2f6>
  80104e:	0f be 55 d3          	movsbl -0x2d(%rbp),%edx
  801052:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  801056:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80105a:	48 89 ce             	mov    %rcx,%rsi
  80105d:	89 d7                	mov    %edx,%edi
  80105f:	ff d0                	callq  *%rax
  801061:	83 6d dc 01          	subl   $0x1,-0x24(%rbp)
  801065:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  801069:	7f e3                	jg     80104e <vprintfmt+0x2df>
  80106b:	eb 37                	jmp    8010a4 <vprintfmt+0x335>
  80106d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
  801071:	74 1e                	je     801091 <vprintfmt+0x322>
  801073:	83 fb 1f             	cmp    $0x1f,%ebx
  801076:	7e 05                	jle    80107d <vprintfmt+0x30e>
  801078:	83 fb 7e             	cmp    $0x7e,%ebx
  80107b:	7e 14                	jle    801091 <vprintfmt+0x322>
  80107d:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  801081:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  801085:	48 89 d6             	mov    %rdx,%rsi
  801088:	bf 3f 00 00 00       	mov    $0x3f,%edi
  80108d:	ff d0                	callq  *%rax
  80108f:	eb 0f                	jmp    8010a0 <vprintfmt+0x331>
  801091:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  801095:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  801099:	48 89 d6             	mov    %rdx,%rsi
  80109c:	89 df                	mov    %ebx,%edi
  80109e:	ff d0                	callq  *%rax
  8010a0:	83 6d dc 01          	subl   $0x1,-0x24(%rbp)
  8010a4:	4c 89 e0             	mov    %r12,%rax
  8010a7:	4c 8d 60 01          	lea    0x1(%rax),%r12
  8010ab:	0f b6 00             	movzbl (%rax),%eax
  8010ae:	0f be d8             	movsbl %al,%ebx
  8010b1:	85 db                	test   %ebx,%ebx
  8010b3:	74 10                	je     8010c5 <vprintfmt+0x356>
  8010b5:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
  8010b9:	78 b2                	js     80106d <vprintfmt+0x2fe>
  8010bb:	83 6d d8 01          	subl   $0x1,-0x28(%rbp)
  8010bf:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
  8010c3:	79 a8                	jns    80106d <vprintfmt+0x2fe>
  8010c5:	eb 16                	jmp    8010dd <vprintfmt+0x36e>
  8010c7:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  8010cb:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8010cf:	48 89 d6             	mov    %rdx,%rsi
  8010d2:	bf 20 00 00 00       	mov    $0x20,%edi
  8010d7:	ff d0                	callq  *%rax
  8010d9:	83 6d dc 01          	subl   $0x1,-0x24(%rbp)
  8010dd:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  8010e1:	7f e4                	jg     8010c7 <vprintfmt+0x358>
  8010e3:	e9 90 01 00 00       	jmpq   801278 <vprintfmt+0x509>
  8010e8:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  8010ec:	be 03 00 00 00       	mov    $0x3,%esi
  8010f1:	48 89 c7             	mov    %rax,%rdi
  8010f4:	48 b8 5f 0c 80 00 00 	movabs $0x800c5f,%rax
  8010fb:	00 00 00 
  8010fe:	ff d0                	callq  *%rax
  801100:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  801104:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801108:	48 85 c0             	test   %rax,%rax
  80110b:	79 1d                	jns    80112a <vprintfmt+0x3bb>
  80110d:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  801111:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  801115:	48 89 d6             	mov    %rdx,%rsi
  801118:	bf 2d 00 00 00       	mov    $0x2d,%edi
  80111d:	ff d0                	callq  *%rax
  80111f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801123:	48 f7 d8             	neg    %rax
  801126:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  80112a:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%rbp)
  801131:	e9 d5 00 00 00       	jmpq   80120b <vprintfmt+0x49c>
  801136:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  80113a:	be 03 00 00 00       	mov    $0x3,%esi
  80113f:	48 89 c7             	mov    %rax,%rdi
  801142:	48 b8 4f 0b 80 00 00 	movabs $0x800b4f,%rax
  801149:	00 00 00 
  80114c:	ff d0                	callq  *%rax
  80114e:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  801152:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%rbp)
  801159:	e9 ad 00 00 00       	jmpq   80120b <vprintfmt+0x49c>
  80115e:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  801162:	be 03 00 00 00       	mov    $0x3,%esi
  801167:	48 89 c7             	mov    %rax,%rdi
  80116a:	48 b8 4f 0b 80 00 00 	movabs $0x800b4f,%rax
  801171:	00 00 00 
  801174:	ff d0                	callq  *%rax
  801176:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  80117a:	c7 45 e4 08 00 00 00 	movl   $0x8,-0x1c(%rbp)
  801181:	e9 85 00 00 00       	jmpq   80120b <vprintfmt+0x49c>
  801186:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  80118a:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80118e:	48 89 d6             	mov    %rdx,%rsi
  801191:	bf 30 00 00 00       	mov    $0x30,%edi
  801196:	ff d0                	callq  *%rax
  801198:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  80119c:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8011a0:	48 89 d6             	mov    %rdx,%rsi
  8011a3:	bf 78 00 00 00       	mov    $0x78,%edi
  8011a8:	ff d0                	callq  *%rax
  8011aa:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8011ad:	83 f8 30             	cmp    $0x30,%eax
  8011b0:	73 17                	jae    8011c9 <vprintfmt+0x45a>
  8011b2:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8011b6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8011b9:	89 c0                	mov    %eax,%eax
  8011bb:	48 01 d0             	add    %rdx,%rax
  8011be:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8011c1:	83 c2 08             	add    $0x8,%edx
  8011c4:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8011c7:	eb 0f                	jmp    8011d8 <vprintfmt+0x469>
  8011c9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8011cd:	48 89 d0             	mov    %rdx,%rax
  8011d0:	48 83 c2 08          	add    $0x8,%rdx
  8011d4:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  8011d8:	48 8b 00             	mov    (%rax),%rax
  8011db:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  8011df:	c7 45 e4 10 00 00 00 	movl   $0x10,-0x1c(%rbp)
  8011e6:	eb 23                	jmp    80120b <vprintfmt+0x49c>
  8011e8:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  8011ec:	be 03 00 00 00       	mov    $0x3,%esi
  8011f1:	48 89 c7             	mov    %rax,%rdi
  8011f4:	48 b8 4f 0b 80 00 00 	movabs $0x800b4f,%rax
  8011fb:	00 00 00 
  8011fe:	ff d0                	callq  *%rax
  801200:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  801204:	c7 45 e4 10 00 00 00 	movl   $0x10,-0x1c(%rbp)
  80120b:	44 0f be 45 d3       	movsbl -0x2d(%rbp),%r8d
  801210:	8b 4d e4             	mov    -0x1c(%rbp),%ecx
  801213:	8b 7d dc             	mov    -0x24(%rbp),%edi
  801216:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80121a:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  80121e:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  801222:	45 89 c1             	mov    %r8d,%r9d
  801225:	41 89 f8             	mov    %edi,%r8d
  801228:	48 89 c7             	mov    %rax,%rdi
  80122b:	48 b8 94 0a 80 00 00 	movabs $0x800a94,%rax
  801232:	00 00 00 
  801235:	ff d0                	callq  *%rax
  801237:	eb 3f                	jmp    801278 <vprintfmt+0x509>
  801239:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  80123d:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  801241:	48 89 d6             	mov    %rdx,%rsi
  801244:	89 df                	mov    %ebx,%edi
  801246:	ff d0                	callq  *%rax
  801248:	eb 2e                	jmp    801278 <vprintfmt+0x509>
  80124a:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  80124e:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  801252:	48 89 d6             	mov    %rdx,%rsi
  801255:	bf 25 00 00 00       	mov    $0x25,%edi
  80125a:	ff d0                	callq  *%rax
  80125c:	48 83 6d 98 01       	subq   $0x1,-0x68(%rbp)
  801261:	eb 05                	jmp    801268 <vprintfmt+0x4f9>
  801263:	48 83 6d 98 01       	subq   $0x1,-0x68(%rbp)
  801268:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80126c:	48 83 e8 01          	sub    $0x1,%rax
  801270:	0f b6 00             	movzbl (%rax),%eax
  801273:	3c 25                	cmp    $0x25,%al
  801275:	75 ec                	jne    801263 <vprintfmt+0x4f4>
  801277:	90                   	nop
  801278:	90                   	nop
  801279:	e9 43 fb ff ff       	jmpq   800dc1 <vprintfmt+0x52>
  80127e:	48 83 c4 60          	add    $0x60,%rsp
  801282:	5b                   	pop    %rbx
  801283:	41 5c                	pop    %r12
  801285:	5d                   	pop    %rbp
  801286:	c3                   	retq   

0000000000801287 <printfmt>:
  801287:	55                   	push   %rbp
  801288:	48 89 e5             	mov    %rsp,%rbp
  80128b:	48 81 ec f0 00 00 00 	sub    $0xf0,%rsp
  801292:	48 89 bd 28 ff ff ff 	mov    %rdi,-0xd8(%rbp)
  801299:	48 89 b5 20 ff ff ff 	mov    %rsi,-0xe0(%rbp)
  8012a0:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8012a7:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8012ae:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8012b5:	84 c0                	test   %al,%al
  8012b7:	74 20                	je     8012d9 <printfmt+0x52>
  8012b9:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8012bd:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8012c1:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8012c5:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8012c9:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8012cd:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8012d1:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8012d5:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  8012d9:	48 89 95 18 ff ff ff 	mov    %rdx,-0xe8(%rbp)
  8012e0:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8012e7:	00 00 00 
  8012ea:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8012f1:	00 00 00 
  8012f4:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8012f8:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8012ff:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  801306:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  80130d:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  801314:	48 8b 95 18 ff ff ff 	mov    -0xe8(%rbp),%rdx
  80131b:	48 8b b5 20 ff ff ff 	mov    -0xe0(%rbp),%rsi
  801322:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  801329:	48 89 c7             	mov    %rax,%rdi
  80132c:	48 b8 6f 0d 80 00 00 	movabs $0x800d6f,%rax
  801333:	00 00 00 
  801336:	ff d0                	callq  *%rax
  801338:	c9                   	leaveq 
  801339:	c3                   	retq   

000000000080133a <sprintputch>:
  80133a:	55                   	push   %rbp
  80133b:	48 89 e5             	mov    %rsp,%rbp
  80133e:	48 83 ec 10          	sub    $0x10,%rsp
  801342:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801345:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801349:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80134d:	8b 40 10             	mov    0x10(%rax),%eax
  801350:	8d 50 01             	lea    0x1(%rax),%edx
  801353:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801357:	89 50 10             	mov    %edx,0x10(%rax)
  80135a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80135e:	48 8b 10             	mov    (%rax),%rdx
  801361:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801365:	48 8b 40 08          	mov    0x8(%rax),%rax
  801369:	48 39 c2             	cmp    %rax,%rdx
  80136c:	73 17                	jae    801385 <sprintputch+0x4b>
  80136e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801372:	48 8b 00             	mov    (%rax),%rax
  801375:	48 8d 48 01          	lea    0x1(%rax),%rcx
  801379:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  80137d:	48 89 0a             	mov    %rcx,(%rdx)
  801380:	8b 55 fc             	mov    -0x4(%rbp),%edx
  801383:	88 10                	mov    %dl,(%rax)
  801385:	c9                   	leaveq 
  801386:	c3                   	retq   

0000000000801387 <vsnprintf>:
  801387:	55                   	push   %rbp
  801388:	48 89 e5             	mov    %rsp,%rbp
  80138b:	48 83 ec 50          	sub    $0x50,%rsp
  80138f:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  801393:	89 75 c4             	mov    %esi,-0x3c(%rbp)
  801396:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  80139a:	48 89 4d b0          	mov    %rcx,-0x50(%rbp)
  80139e:	48 8d 45 e8          	lea    -0x18(%rbp),%rax
  8013a2:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  8013a6:	48 8b 0a             	mov    (%rdx),%rcx
  8013a9:	48 89 08             	mov    %rcx,(%rax)
  8013ac:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  8013b0:	48 89 48 08          	mov    %rcx,0x8(%rax)
  8013b4:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  8013b8:	48 89 50 10          	mov    %rdx,0x10(%rax)
  8013bc:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8013c0:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8013c4:	8b 45 c4             	mov    -0x3c(%rbp),%eax
  8013c7:	48 98                	cltq   
  8013c9:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  8013cd:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8013d1:	48 01 d0             	add    %rdx,%rax
  8013d4:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
  8013d8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%rbp)
  8013df:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
  8013e4:	74 06                	je     8013ec <vsnprintf+0x65>
  8013e6:	83 7d c4 00          	cmpl   $0x0,-0x3c(%rbp)
  8013ea:	7f 07                	jg     8013f3 <vsnprintf+0x6c>
  8013ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013f1:	eb 2f                	jmp    801422 <vsnprintf+0x9b>
  8013f3:	48 8d 4d e8          	lea    -0x18(%rbp),%rcx
  8013f7:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  8013fb:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  8013ff:	48 89 c6             	mov    %rax,%rsi
  801402:	48 bf 3a 13 80 00 00 	movabs $0x80133a,%rdi
  801409:	00 00 00 
  80140c:	48 b8 6f 0d 80 00 00 	movabs $0x800d6f,%rax
  801413:	00 00 00 
  801416:	ff d0                	callq  *%rax
  801418:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80141c:	c6 00 00             	movb   $0x0,(%rax)
  80141f:	8b 45 e0             	mov    -0x20(%rbp),%eax
  801422:	c9                   	leaveq 
  801423:	c3                   	retq   

0000000000801424 <snprintf>:
  801424:	55                   	push   %rbp
  801425:	48 89 e5             	mov    %rsp,%rbp
  801428:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  80142f:	48 89 bd 08 ff ff ff 	mov    %rdi,-0xf8(%rbp)
  801436:	89 b5 04 ff ff ff    	mov    %esi,-0xfc(%rbp)
  80143c:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  801443:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80144a:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  801451:	84 c0                	test   %al,%al
  801453:	74 20                	je     801475 <snprintf+0x51>
  801455:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  801459:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80145d:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  801461:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  801465:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  801469:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80146d:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  801471:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  801475:	48 89 95 f8 fe ff ff 	mov    %rdx,-0x108(%rbp)
  80147c:	c7 85 30 ff ff ff 18 	movl   $0x18,-0xd0(%rbp)
  801483:	00 00 00 
  801486:	c7 85 34 ff ff ff 30 	movl   $0x30,-0xcc(%rbp)
  80148d:	00 00 00 
  801490:	48 8d 45 10          	lea    0x10(%rbp),%rax
  801494:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  80149b:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8014a2:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8014a9:	48 8d 85 18 ff ff ff 	lea    -0xe8(%rbp),%rax
  8014b0:	48 8d 95 30 ff ff ff 	lea    -0xd0(%rbp),%rdx
  8014b7:	48 8b 0a             	mov    (%rdx),%rcx
  8014ba:	48 89 08             	mov    %rcx,(%rax)
  8014bd:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  8014c1:	48 89 48 08          	mov    %rcx,0x8(%rax)
  8014c5:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  8014c9:	48 89 50 10          	mov    %rdx,0x10(%rax)
  8014cd:	48 8d 8d 18 ff ff ff 	lea    -0xe8(%rbp),%rcx
  8014d4:	48 8b 95 f8 fe ff ff 	mov    -0x108(%rbp),%rdx
  8014db:	8b b5 04 ff ff ff    	mov    -0xfc(%rbp),%esi
  8014e1:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
  8014e8:	48 89 c7             	mov    %rax,%rdi
  8014eb:	48 b8 87 13 80 00 00 	movabs $0x801387,%rax
  8014f2:	00 00 00 
  8014f5:	ff d0                	callq  *%rax
  8014f7:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%rbp)
  8014fd:	8b 85 4c ff ff ff    	mov    -0xb4(%rbp),%eax
  801503:	c9                   	leaveq 
  801504:	c3                   	retq   

0000000000801505 <strlen>:
  801505:	55                   	push   %rbp
  801506:	48 89 e5             	mov    %rsp,%rbp
  801509:	48 83 ec 18          	sub    $0x18,%rsp
  80150d:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  801511:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  801518:	eb 09                	jmp    801523 <strlen+0x1e>
  80151a:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  80151e:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  801523:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801527:	0f b6 00             	movzbl (%rax),%eax
  80152a:	84 c0                	test   %al,%al
  80152c:	75 ec                	jne    80151a <strlen+0x15>
  80152e:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801531:	c9                   	leaveq 
  801532:	c3                   	retq   

0000000000801533 <strnlen>:
  801533:	55                   	push   %rbp
  801534:	48 89 e5             	mov    %rsp,%rbp
  801537:	48 83 ec 20          	sub    $0x20,%rsp
  80153b:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80153f:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  801543:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  80154a:	eb 0e                	jmp    80155a <strnlen+0x27>
  80154c:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  801550:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  801555:	48 83 6d e0 01       	subq   $0x1,-0x20(%rbp)
  80155a:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  80155f:	74 0b                	je     80156c <strnlen+0x39>
  801561:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801565:	0f b6 00             	movzbl (%rax),%eax
  801568:	84 c0                	test   %al,%al
  80156a:	75 e0                	jne    80154c <strnlen+0x19>
  80156c:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80156f:	c9                   	leaveq 
  801570:	c3                   	retq   

0000000000801571 <strcpy>:
  801571:	55                   	push   %rbp
  801572:	48 89 e5             	mov    %rsp,%rbp
  801575:	48 83 ec 20          	sub    $0x20,%rsp
  801579:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80157d:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  801581:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801585:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  801589:	90                   	nop
  80158a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80158e:	48 8d 50 01          	lea    0x1(%rax),%rdx
  801592:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  801596:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  80159a:	48 8d 4a 01          	lea    0x1(%rdx),%rcx
  80159e:	48 89 4d e0          	mov    %rcx,-0x20(%rbp)
  8015a2:	0f b6 12             	movzbl (%rdx),%edx
  8015a5:	88 10                	mov    %dl,(%rax)
  8015a7:	0f b6 00             	movzbl (%rax),%eax
  8015aa:	84 c0                	test   %al,%al
  8015ac:	75 dc                	jne    80158a <strcpy+0x19>
  8015ae:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8015b2:	c9                   	leaveq 
  8015b3:	c3                   	retq   

00000000008015b4 <strcat>:
  8015b4:	55                   	push   %rbp
  8015b5:	48 89 e5             	mov    %rsp,%rbp
  8015b8:	48 83 ec 20          	sub    $0x20,%rsp
  8015bc:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8015c0:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8015c4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8015c8:	48 89 c7             	mov    %rax,%rdi
  8015cb:	48 b8 05 15 80 00 00 	movabs $0x801505,%rax
  8015d2:	00 00 00 
  8015d5:	ff d0                	callq  *%rax
  8015d7:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8015da:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8015dd:	48 63 d0             	movslq %eax,%rdx
  8015e0:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8015e4:	48 01 c2             	add    %rax,%rdx
  8015e7:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8015eb:	48 89 c6             	mov    %rax,%rsi
  8015ee:	48 89 d7             	mov    %rdx,%rdi
  8015f1:	48 b8 71 15 80 00 00 	movabs $0x801571,%rax
  8015f8:	00 00 00 
  8015fb:	ff d0                	callq  *%rax
  8015fd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801601:	c9                   	leaveq 
  801602:	c3                   	retq   

0000000000801603 <strncpy>:
  801603:	55                   	push   %rbp
  801604:	48 89 e5             	mov    %rsp,%rbp
  801607:	48 83 ec 28          	sub    $0x28,%rsp
  80160b:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80160f:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  801613:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  801617:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80161b:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  80161f:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  801626:	00 
  801627:	eb 2a                	jmp    801653 <strncpy+0x50>
  801629:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80162d:	48 8d 50 01          	lea    0x1(%rax),%rdx
  801631:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  801635:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  801639:	0f b6 12             	movzbl (%rdx),%edx
  80163c:	88 10                	mov    %dl,(%rax)
  80163e:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  801642:	0f b6 00             	movzbl (%rax),%eax
  801645:	84 c0                	test   %al,%al
  801647:	74 05                	je     80164e <strncpy+0x4b>
  801649:	48 83 45 e0 01       	addq   $0x1,-0x20(%rbp)
  80164e:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  801653:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801657:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  80165b:	72 cc                	jb     801629 <strncpy+0x26>
  80165d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801661:	c9                   	leaveq 
  801662:	c3                   	retq   

0000000000801663 <strlcpy>:
  801663:	55                   	push   %rbp
  801664:	48 89 e5             	mov    %rsp,%rbp
  801667:	48 83 ec 28          	sub    $0x28,%rsp
  80166b:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80166f:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  801673:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  801677:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80167b:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  80167f:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  801684:	74 3d                	je     8016c3 <strlcpy+0x60>
  801686:	eb 1d                	jmp    8016a5 <strlcpy+0x42>
  801688:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80168c:	48 8d 50 01          	lea    0x1(%rax),%rdx
  801690:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  801694:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  801698:	48 8d 4a 01          	lea    0x1(%rdx),%rcx
  80169c:	48 89 4d e0          	mov    %rcx,-0x20(%rbp)
  8016a0:	0f b6 12             	movzbl (%rdx),%edx
  8016a3:	88 10                	mov    %dl,(%rax)
  8016a5:	48 83 6d d8 01       	subq   $0x1,-0x28(%rbp)
  8016aa:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  8016af:	74 0b                	je     8016bc <strlcpy+0x59>
  8016b1:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8016b5:	0f b6 00             	movzbl (%rax),%eax
  8016b8:	84 c0                	test   %al,%al
  8016ba:	75 cc                	jne    801688 <strlcpy+0x25>
  8016bc:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8016c0:	c6 00 00             	movb   $0x0,(%rax)
  8016c3:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8016c7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8016cb:	48 29 c2             	sub    %rax,%rdx
  8016ce:	48 89 d0             	mov    %rdx,%rax
  8016d1:	c9                   	leaveq 
  8016d2:	c3                   	retq   

00000000008016d3 <strcmp>:
  8016d3:	55                   	push   %rbp
  8016d4:	48 89 e5             	mov    %rsp,%rbp
  8016d7:	48 83 ec 10          	sub    $0x10,%rsp
  8016db:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8016df:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8016e3:	eb 0a                	jmp    8016ef <strcmp+0x1c>
  8016e5:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  8016ea:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  8016ef:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8016f3:	0f b6 00             	movzbl (%rax),%eax
  8016f6:	84 c0                	test   %al,%al
  8016f8:	74 12                	je     80170c <strcmp+0x39>
  8016fa:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8016fe:	0f b6 10             	movzbl (%rax),%edx
  801701:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801705:	0f b6 00             	movzbl (%rax),%eax
  801708:	38 c2                	cmp    %al,%dl
  80170a:	74 d9                	je     8016e5 <strcmp+0x12>
  80170c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801710:	0f b6 00             	movzbl (%rax),%eax
  801713:	0f b6 d0             	movzbl %al,%edx
  801716:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80171a:	0f b6 00             	movzbl (%rax),%eax
  80171d:	0f b6 c0             	movzbl %al,%eax
  801720:	29 c2                	sub    %eax,%edx
  801722:	89 d0                	mov    %edx,%eax
  801724:	c9                   	leaveq 
  801725:	c3                   	retq   

0000000000801726 <strncmp>:
  801726:	55                   	push   %rbp
  801727:	48 89 e5             	mov    %rsp,%rbp
  80172a:	48 83 ec 18          	sub    $0x18,%rsp
  80172e:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  801732:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801736:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  80173a:	eb 0f                	jmp    80174b <strncmp+0x25>
  80173c:	48 83 6d e8 01       	subq   $0x1,-0x18(%rbp)
  801741:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  801746:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  80174b:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  801750:	74 1d                	je     80176f <strncmp+0x49>
  801752:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801756:	0f b6 00             	movzbl (%rax),%eax
  801759:	84 c0                	test   %al,%al
  80175b:	74 12                	je     80176f <strncmp+0x49>
  80175d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801761:	0f b6 10             	movzbl (%rax),%edx
  801764:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801768:	0f b6 00             	movzbl (%rax),%eax
  80176b:	38 c2                	cmp    %al,%dl
  80176d:	74 cd                	je     80173c <strncmp+0x16>
  80176f:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  801774:	75 07                	jne    80177d <strncmp+0x57>
  801776:	b8 00 00 00 00       	mov    $0x0,%eax
  80177b:	eb 18                	jmp    801795 <strncmp+0x6f>
  80177d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801781:	0f b6 00             	movzbl (%rax),%eax
  801784:	0f b6 d0             	movzbl %al,%edx
  801787:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80178b:	0f b6 00             	movzbl (%rax),%eax
  80178e:	0f b6 c0             	movzbl %al,%eax
  801791:	29 c2                	sub    %eax,%edx
  801793:	89 d0                	mov    %edx,%eax
  801795:	c9                   	leaveq 
  801796:	c3                   	retq   

0000000000801797 <strchr>:
  801797:	55                   	push   %rbp
  801798:	48 89 e5             	mov    %rsp,%rbp
  80179b:	48 83 ec 0c          	sub    $0xc,%rsp
  80179f:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8017a3:	89 f0                	mov    %esi,%eax
  8017a5:	88 45 f4             	mov    %al,-0xc(%rbp)
  8017a8:	eb 17                	jmp    8017c1 <strchr+0x2a>
  8017aa:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8017ae:	0f b6 00             	movzbl (%rax),%eax
  8017b1:	3a 45 f4             	cmp    -0xc(%rbp),%al
  8017b4:	75 06                	jne    8017bc <strchr+0x25>
  8017b6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8017ba:	eb 15                	jmp    8017d1 <strchr+0x3a>
  8017bc:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  8017c1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8017c5:	0f b6 00             	movzbl (%rax),%eax
  8017c8:	84 c0                	test   %al,%al
  8017ca:	75 de                	jne    8017aa <strchr+0x13>
  8017cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d1:	c9                   	leaveq 
  8017d2:	c3                   	retq   

00000000008017d3 <strfind>:
  8017d3:	55                   	push   %rbp
  8017d4:	48 89 e5             	mov    %rsp,%rbp
  8017d7:	48 83 ec 0c          	sub    $0xc,%rsp
  8017db:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8017df:	89 f0                	mov    %esi,%eax
  8017e1:	88 45 f4             	mov    %al,-0xc(%rbp)
  8017e4:	eb 13                	jmp    8017f9 <strfind+0x26>
  8017e6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8017ea:	0f b6 00             	movzbl (%rax),%eax
  8017ed:	3a 45 f4             	cmp    -0xc(%rbp),%al
  8017f0:	75 02                	jne    8017f4 <strfind+0x21>
  8017f2:	eb 10                	jmp    801804 <strfind+0x31>
  8017f4:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  8017f9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8017fd:	0f b6 00             	movzbl (%rax),%eax
  801800:	84 c0                	test   %al,%al
  801802:	75 e2                	jne    8017e6 <strfind+0x13>
  801804:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801808:	c9                   	leaveq 
  801809:	c3                   	retq   

000000000080180a <memset>:
  80180a:	55                   	push   %rbp
  80180b:	48 89 e5             	mov    %rsp,%rbp
  80180e:	48 83 ec 18          	sub    $0x18,%rsp
  801812:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  801816:	89 75 f4             	mov    %esi,-0xc(%rbp)
  801819:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  80181d:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  801822:	75 06                	jne    80182a <memset+0x20>
  801824:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801828:	eb 69                	jmp    801893 <memset+0x89>
  80182a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80182e:	83 e0 03             	and    $0x3,%eax
  801831:	48 85 c0             	test   %rax,%rax
  801834:	75 48                	jne    80187e <memset+0x74>
  801836:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80183a:	83 e0 03             	and    $0x3,%eax
  80183d:	48 85 c0             	test   %rax,%rax
  801840:	75 3c                	jne    80187e <memset+0x74>
  801842:	81 65 f4 ff 00 00 00 	andl   $0xff,-0xc(%rbp)
  801849:	8b 45 f4             	mov    -0xc(%rbp),%eax
  80184c:	c1 e0 18             	shl    $0x18,%eax
  80184f:	89 c2                	mov    %eax,%edx
  801851:	8b 45 f4             	mov    -0xc(%rbp),%eax
  801854:	c1 e0 10             	shl    $0x10,%eax
  801857:	09 c2                	or     %eax,%edx
  801859:	8b 45 f4             	mov    -0xc(%rbp),%eax
  80185c:	c1 e0 08             	shl    $0x8,%eax
  80185f:	09 d0                	or     %edx,%eax
  801861:	09 45 f4             	or     %eax,-0xc(%rbp)
  801864:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801868:	48 c1 e8 02          	shr    $0x2,%rax
  80186c:	48 89 c1             	mov    %rax,%rcx
  80186f:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  801873:	8b 45 f4             	mov    -0xc(%rbp),%eax
  801876:	48 89 d7             	mov    %rdx,%rdi
  801879:	fc                   	cld    
  80187a:	f3 ab                	rep stos %eax,%es:(%rdi)
  80187c:	eb 11                	jmp    80188f <memset+0x85>
  80187e:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  801882:	8b 45 f4             	mov    -0xc(%rbp),%eax
  801885:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  801889:	48 89 d7             	mov    %rdx,%rdi
  80188c:	fc                   	cld    
  80188d:	f3 aa                	rep stos %al,%es:(%rdi)
  80188f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801893:	c9                   	leaveq 
  801894:	c3                   	retq   

0000000000801895 <memmove>:
  801895:	55                   	push   %rbp
  801896:	48 89 e5             	mov    %rsp,%rbp
  801899:	48 83 ec 28          	sub    $0x28,%rsp
  80189d:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8018a1:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8018a5:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  8018a9:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8018ad:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8018b1:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8018b5:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  8018b9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8018bd:	48 3b 45 f0          	cmp    -0x10(%rbp),%rax
  8018c1:	0f 83 88 00 00 00    	jae    80194f <memmove+0xba>
  8018c7:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8018cb:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8018cf:	48 01 d0             	add    %rdx,%rax
  8018d2:	48 3b 45 f0          	cmp    -0x10(%rbp),%rax
  8018d6:	76 77                	jbe    80194f <memmove+0xba>
  8018d8:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8018dc:	48 01 45 f8          	add    %rax,-0x8(%rbp)
  8018e0:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8018e4:	48 01 45 f0          	add    %rax,-0x10(%rbp)
  8018e8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8018ec:	83 e0 03             	and    $0x3,%eax
  8018ef:	48 85 c0             	test   %rax,%rax
  8018f2:	75 3b                	jne    80192f <memmove+0x9a>
  8018f4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8018f8:	83 e0 03             	and    $0x3,%eax
  8018fb:	48 85 c0             	test   %rax,%rax
  8018fe:	75 2f                	jne    80192f <memmove+0x9a>
  801900:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801904:	83 e0 03             	and    $0x3,%eax
  801907:	48 85 c0             	test   %rax,%rax
  80190a:	75 23                	jne    80192f <memmove+0x9a>
  80190c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801910:	48 83 e8 04          	sub    $0x4,%rax
  801914:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  801918:	48 83 ea 04          	sub    $0x4,%rdx
  80191c:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  801920:	48 c1 e9 02          	shr    $0x2,%rcx
  801924:	48 89 c7             	mov    %rax,%rdi
  801927:	48 89 d6             	mov    %rdx,%rsi
  80192a:	fd                   	std    
  80192b:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  80192d:	eb 1d                	jmp    80194c <memmove+0xb7>
  80192f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801933:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  801937:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80193b:	48 8d 70 ff          	lea    -0x1(%rax),%rsi
  80193f:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801943:	48 89 d7             	mov    %rdx,%rdi
  801946:	48 89 c1             	mov    %rax,%rcx
  801949:	fd                   	std    
  80194a:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
  80194c:	fc                   	cld    
  80194d:	eb 57                	jmp    8019a6 <memmove+0x111>
  80194f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801953:	83 e0 03             	and    $0x3,%eax
  801956:	48 85 c0             	test   %rax,%rax
  801959:	75 36                	jne    801991 <memmove+0xfc>
  80195b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80195f:	83 e0 03             	and    $0x3,%eax
  801962:	48 85 c0             	test   %rax,%rax
  801965:	75 2a                	jne    801991 <memmove+0xfc>
  801967:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80196b:	83 e0 03             	and    $0x3,%eax
  80196e:	48 85 c0             	test   %rax,%rax
  801971:	75 1e                	jne    801991 <memmove+0xfc>
  801973:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801977:	48 c1 e8 02          	shr    $0x2,%rax
  80197b:	48 89 c1             	mov    %rax,%rcx
  80197e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801982:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  801986:	48 89 c7             	mov    %rax,%rdi
  801989:	48 89 d6             	mov    %rdx,%rsi
  80198c:	fc                   	cld    
  80198d:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  80198f:	eb 15                	jmp    8019a6 <memmove+0x111>
  801991:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801995:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  801999:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  80199d:	48 89 c7             	mov    %rax,%rdi
  8019a0:	48 89 d6             	mov    %rdx,%rsi
  8019a3:	fc                   	cld    
  8019a4:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
  8019a6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8019aa:	c9                   	leaveq 
  8019ab:	c3                   	retq   

00000000008019ac <memcpy>:
  8019ac:	55                   	push   %rbp
  8019ad:	48 89 e5             	mov    %rsp,%rbp
  8019b0:	48 83 ec 18          	sub    $0x18,%rsp
  8019b4:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8019b8:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8019bc:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8019c0:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8019c4:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  8019c8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8019cc:	48 89 ce             	mov    %rcx,%rsi
  8019cf:	48 89 c7             	mov    %rax,%rdi
  8019d2:	48 b8 95 18 80 00 00 	movabs $0x801895,%rax
  8019d9:	00 00 00 
  8019dc:	ff d0                	callq  *%rax
  8019de:	c9                   	leaveq 
  8019df:	c3                   	retq   

00000000008019e0 <memcmp>:
  8019e0:	55                   	push   %rbp
  8019e1:	48 89 e5             	mov    %rsp,%rbp
  8019e4:	48 83 ec 28          	sub    $0x28,%rsp
  8019e8:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8019ec:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8019f0:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  8019f4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8019f8:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8019fc:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  801a00:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  801a04:	eb 36                	jmp    801a3c <memcmp+0x5c>
  801a06:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801a0a:	0f b6 10             	movzbl (%rax),%edx
  801a0d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801a11:	0f b6 00             	movzbl (%rax),%eax
  801a14:	38 c2                	cmp    %al,%dl
  801a16:	74 1a                	je     801a32 <memcmp+0x52>
  801a18:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801a1c:	0f b6 00             	movzbl (%rax),%eax
  801a1f:	0f b6 d0             	movzbl %al,%edx
  801a22:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801a26:	0f b6 00             	movzbl (%rax),%eax
  801a29:	0f b6 c0             	movzbl %al,%eax
  801a2c:	29 c2                	sub    %eax,%edx
  801a2e:	89 d0                	mov    %edx,%eax
  801a30:	eb 20                	jmp    801a52 <memcmp+0x72>
  801a32:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  801a37:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  801a3c:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801a40:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  801a44:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  801a48:	48 85 c0             	test   %rax,%rax
  801a4b:	75 b9                	jne    801a06 <memcmp+0x26>
  801a4d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a52:	c9                   	leaveq 
  801a53:	c3                   	retq   

0000000000801a54 <memfind>:
  801a54:	55                   	push   %rbp
  801a55:	48 89 e5             	mov    %rsp,%rbp
  801a58:	48 83 ec 28          	sub    $0x28,%rsp
  801a5c:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  801a60:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  801a63:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  801a67:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801a6b:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  801a6f:	48 01 d0             	add    %rdx,%rax
  801a72:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  801a76:	eb 15                	jmp    801a8d <memfind+0x39>
  801a78:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801a7c:	0f b6 10             	movzbl (%rax),%edx
  801a7f:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  801a82:	38 c2                	cmp    %al,%dl
  801a84:	75 02                	jne    801a88 <memfind+0x34>
  801a86:	eb 0f                	jmp    801a97 <memfind+0x43>
  801a88:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  801a8d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801a91:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
  801a95:	72 e1                	jb     801a78 <memfind+0x24>
  801a97:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801a9b:	c9                   	leaveq 
  801a9c:	c3                   	retq   

0000000000801a9d <strtol>:
  801a9d:	55                   	push   %rbp
  801a9e:	48 89 e5             	mov    %rsp,%rbp
  801aa1:	48 83 ec 34          	sub    $0x34,%rsp
  801aa5:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  801aa9:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  801aad:	89 55 cc             	mov    %edx,-0x34(%rbp)
  801ab0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  801ab7:	48 c7 45 f0 00 00 00 	movq   $0x0,-0x10(%rbp)
  801abe:	00 
  801abf:	eb 05                	jmp    801ac6 <strtol+0x29>
  801ac1:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  801ac6:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801aca:	0f b6 00             	movzbl (%rax),%eax
  801acd:	3c 20                	cmp    $0x20,%al
  801acf:	74 f0                	je     801ac1 <strtol+0x24>
  801ad1:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801ad5:	0f b6 00             	movzbl (%rax),%eax
  801ad8:	3c 09                	cmp    $0x9,%al
  801ada:	74 e5                	je     801ac1 <strtol+0x24>
  801adc:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801ae0:	0f b6 00             	movzbl (%rax),%eax
  801ae3:	3c 2b                	cmp    $0x2b,%al
  801ae5:	75 07                	jne    801aee <strtol+0x51>
  801ae7:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  801aec:	eb 17                	jmp    801b05 <strtol+0x68>
  801aee:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801af2:	0f b6 00             	movzbl (%rax),%eax
  801af5:	3c 2d                	cmp    $0x2d,%al
  801af7:	75 0c                	jne    801b05 <strtol+0x68>
  801af9:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  801afe:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)
  801b05:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  801b09:	74 06                	je     801b11 <strtol+0x74>
  801b0b:	83 7d cc 10          	cmpl   $0x10,-0x34(%rbp)
  801b0f:	75 28                	jne    801b39 <strtol+0x9c>
  801b11:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801b15:	0f b6 00             	movzbl (%rax),%eax
  801b18:	3c 30                	cmp    $0x30,%al
  801b1a:	75 1d                	jne    801b39 <strtol+0x9c>
  801b1c:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801b20:	48 83 c0 01          	add    $0x1,%rax
  801b24:	0f b6 00             	movzbl (%rax),%eax
  801b27:	3c 78                	cmp    $0x78,%al
  801b29:	75 0e                	jne    801b39 <strtol+0x9c>
  801b2b:	48 83 45 d8 02       	addq   $0x2,-0x28(%rbp)
  801b30:	c7 45 cc 10 00 00 00 	movl   $0x10,-0x34(%rbp)
  801b37:	eb 2c                	jmp    801b65 <strtol+0xc8>
  801b39:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  801b3d:	75 19                	jne    801b58 <strtol+0xbb>
  801b3f:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801b43:	0f b6 00             	movzbl (%rax),%eax
  801b46:	3c 30                	cmp    $0x30,%al
  801b48:	75 0e                	jne    801b58 <strtol+0xbb>
  801b4a:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  801b4f:	c7 45 cc 08 00 00 00 	movl   $0x8,-0x34(%rbp)
  801b56:	eb 0d                	jmp    801b65 <strtol+0xc8>
  801b58:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  801b5c:	75 07                	jne    801b65 <strtol+0xc8>
  801b5e:	c7 45 cc 0a 00 00 00 	movl   $0xa,-0x34(%rbp)
  801b65:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801b69:	0f b6 00             	movzbl (%rax),%eax
  801b6c:	3c 2f                	cmp    $0x2f,%al
  801b6e:	7e 1d                	jle    801b8d <strtol+0xf0>
  801b70:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801b74:	0f b6 00             	movzbl (%rax),%eax
  801b77:	3c 39                	cmp    $0x39,%al
  801b79:	7f 12                	jg     801b8d <strtol+0xf0>
  801b7b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801b7f:	0f b6 00             	movzbl (%rax),%eax
  801b82:	0f be c0             	movsbl %al,%eax
  801b85:	83 e8 30             	sub    $0x30,%eax
  801b88:	89 45 ec             	mov    %eax,-0x14(%rbp)
  801b8b:	eb 4e                	jmp    801bdb <strtol+0x13e>
  801b8d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801b91:	0f b6 00             	movzbl (%rax),%eax
  801b94:	3c 60                	cmp    $0x60,%al
  801b96:	7e 1d                	jle    801bb5 <strtol+0x118>
  801b98:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801b9c:	0f b6 00             	movzbl (%rax),%eax
  801b9f:	3c 7a                	cmp    $0x7a,%al
  801ba1:	7f 12                	jg     801bb5 <strtol+0x118>
  801ba3:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801ba7:	0f b6 00             	movzbl (%rax),%eax
  801baa:	0f be c0             	movsbl %al,%eax
  801bad:	83 e8 57             	sub    $0x57,%eax
  801bb0:	89 45 ec             	mov    %eax,-0x14(%rbp)
  801bb3:	eb 26                	jmp    801bdb <strtol+0x13e>
  801bb5:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801bb9:	0f b6 00             	movzbl (%rax),%eax
  801bbc:	3c 40                	cmp    $0x40,%al
  801bbe:	7e 48                	jle    801c08 <strtol+0x16b>
  801bc0:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801bc4:	0f b6 00             	movzbl (%rax),%eax
  801bc7:	3c 5a                	cmp    $0x5a,%al
  801bc9:	7f 3d                	jg     801c08 <strtol+0x16b>
  801bcb:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801bcf:	0f b6 00             	movzbl (%rax),%eax
  801bd2:	0f be c0             	movsbl %al,%eax
  801bd5:	83 e8 37             	sub    $0x37,%eax
  801bd8:	89 45 ec             	mov    %eax,-0x14(%rbp)
  801bdb:	8b 45 ec             	mov    -0x14(%rbp),%eax
  801bde:	3b 45 cc             	cmp    -0x34(%rbp),%eax
  801be1:	7c 02                	jl     801be5 <strtol+0x148>
  801be3:	eb 23                	jmp    801c08 <strtol+0x16b>
  801be5:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  801bea:	8b 45 cc             	mov    -0x34(%rbp),%eax
  801bed:	48 98                	cltq   
  801bef:	48 0f af 45 f0       	imul   -0x10(%rbp),%rax
  801bf4:	48 89 c2             	mov    %rax,%rdx
  801bf7:	8b 45 ec             	mov    -0x14(%rbp),%eax
  801bfa:	48 98                	cltq   
  801bfc:	48 01 d0             	add    %rdx,%rax
  801bff:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  801c03:	e9 5d ff ff ff       	jmpq   801b65 <strtol+0xc8>
  801c08:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  801c0d:	74 0b                	je     801c1a <strtol+0x17d>
  801c0f:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  801c13:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  801c17:	48 89 10             	mov    %rdx,(%rax)
  801c1a:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  801c1e:	74 09                	je     801c29 <strtol+0x18c>
  801c20:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801c24:	48 f7 d8             	neg    %rax
  801c27:	eb 04                	jmp    801c2d <strtol+0x190>
  801c29:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801c2d:	c9                   	leaveq 
  801c2e:	c3                   	retq   

0000000000801c2f <strstr>:
  801c2f:	55                   	push   %rbp
  801c30:	48 89 e5             	mov    %rsp,%rbp
  801c33:	48 83 ec 30          	sub    $0x30,%rsp
  801c37:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  801c3b:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  801c3f:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  801c43:	48 8d 50 01          	lea    0x1(%rax),%rdx
  801c47:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  801c4b:	0f b6 00             	movzbl (%rax),%eax
  801c4e:	88 45 ff             	mov    %al,-0x1(%rbp)
  801c51:	80 7d ff 00          	cmpb   $0x0,-0x1(%rbp)
  801c55:	75 06                	jne    801c5d <strstr+0x2e>
  801c57:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801c5b:	eb 6b                	jmp    801cc8 <strstr+0x99>
  801c5d:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  801c61:	48 89 c7             	mov    %rax,%rdi
  801c64:	48 b8 05 15 80 00 00 	movabs $0x801505,%rax
  801c6b:	00 00 00 
  801c6e:	ff d0                	callq  *%rax
  801c70:	48 98                	cltq   
  801c72:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  801c76:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801c7a:	48 8d 50 01          	lea    0x1(%rax),%rdx
  801c7e:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  801c82:	0f b6 00             	movzbl (%rax),%eax
  801c85:	88 45 ef             	mov    %al,-0x11(%rbp)
  801c88:	80 7d ef 00          	cmpb   $0x0,-0x11(%rbp)
  801c8c:	75 07                	jne    801c95 <strstr+0x66>
  801c8e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c93:	eb 33                	jmp    801cc8 <strstr+0x99>
  801c95:	0f b6 45 ef          	movzbl -0x11(%rbp),%eax
  801c99:	3a 45 ff             	cmp    -0x1(%rbp),%al
  801c9c:	75 d8                	jne    801c76 <strstr+0x47>
  801c9e:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801ca2:	48 8b 4d d0          	mov    -0x30(%rbp),%rcx
  801ca6:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801caa:	48 89 ce             	mov    %rcx,%rsi
  801cad:	48 89 c7             	mov    %rax,%rdi
  801cb0:	48 b8 26 17 80 00 00 	movabs $0x801726,%rax
  801cb7:	00 00 00 
  801cba:	ff d0                	callq  *%rax
  801cbc:	85 c0                	test   %eax,%eax
  801cbe:	75 b6                	jne    801c76 <strstr+0x47>
  801cc0:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801cc4:	48 83 e8 01          	sub    $0x1,%rax
  801cc8:	c9                   	leaveq 
  801cc9:	c3                   	retq   

0000000000801cca <syscall>:
  801cca:	55                   	push   %rbp
  801ccb:	48 89 e5             	mov    %rsp,%rbp
  801cce:	53                   	push   %rbx
  801ccf:	48 83 ec 48          	sub    $0x48,%rsp
  801cd3:	89 7d dc             	mov    %edi,-0x24(%rbp)
  801cd6:	89 75 d8             	mov    %esi,-0x28(%rbp)
  801cd9:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  801cdd:	48 89 4d c8          	mov    %rcx,-0x38(%rbp)
  801ce1:	4c 89 45 c0          	mov    %r8,-0x40(%rbp)
  801ce5:	4c 89 4d b8          	mov    %r9,-0x48(%rbp)
  801ce9:	8b 45 dc             	mov    -0x24(%rbp),%eax
  801cec:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  801cf0:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
  801cf4:	4c 8b 45 c0          	mov    -0x40(%rbp),%r8
  801cf8:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  801cfc:	48 8b 75 10          	mov    0x10(%rbp),%rsi
  801d00:	4c 89 c3             	mov    %r8,%rbx
  801d03:	cd 30                	int    $0x30
  801d05:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  801d09:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
  801d0d:	74 3e                	je     801d4d <syscall+0x83>
  801d0f:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  801d14:	7e 37                	jle    801d4d <syscall+0x83>
  801d16:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  801d1a:	8b 45 dc             	mov    -0x24(%rbp),%eax
  801d1d:	49 89 d0             	mov    %rdx,%r8
  801d20:	89 c1                	mov    %eax,%ecx
  801d22:	48 ba a8 4d 80 00 00 	movabs $0x804da8,%rdx
  801d29:	00 00 00 
  801d2c:	be 24 00 00 00       	mov    $0x24,%esi
  801d31:	48 bf c5 4d 80 00 00 	movabs $0x804dc5,%rdi
  801d38:	00 00 00 
  801d3b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d40:	49 b9 83 07 80 00 00 	movabs $0x800783,%r9
  801d47:	00 00 00 
  801d4a:	41 ff d1             	callq  *%r9
  801d4d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801d51:	48 83 c4 48          	add    $0x48,%rsp
  801d55:	5b                   	pop    %rbx
  801d56:	5d                   	pop    %rbp
  801d57:	c3                   	retq   

0000000000801d58 <sys_cputs>:
  801d58:	55                   	push   %rbp
  801d59:	48 89 e5             	mov    %rsp,%rbp
  801d5c:	48 83 ec 20          	sub    $0x20,%rsp
  801d60:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  801d64:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801d68:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801d6c:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801d70:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801d77:	00 
  801d78:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801d7e:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801d84:	48 89 d1             	mov    %rdx,%rcx
  801d87:	48 89 c2             	mov    %rax,%rdx
  801d8a:	be 00 00 00 00       	mov    $0x0,%esi
  801d8f:	bf 00 00 00 00       	mov    $0x0,%edi
  801d94:	48 b8 ca 1c 80 00 00 	movabs $0x801cca,%rax
  801d9b:	00 00 00 
  801d9e:	ff d0                	callq  *%rax
  801da0:	c9                   	leaveq 
  801da1:	c3                   	retq   

0000000000801da2 <sys_cgetc>:
  801da2:	55                   	push   %rbp
  801da3:	48 89 e5             	mov    %rsp,%rbp
  801da6:	48 83 ec 10          	sub    $0x10,%rsp
  801daa:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801db1:	00 
  801db2:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801db8:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801dbe:	b9 00 00 00 00       	mov    $0x0,%ecx
  801dc3:	ba 00 00 00 00       	mov    $0x0,%edx
  801dc8:	be 00 00 00 00       	mov    $0x0,%esi
  801dcd:	bf 01 00 00 00       	mov    $0x1,%edi
  801dd2:	48 b8 ca 1c 80 00 00 	movabs $0x801cca,%rax
  801dd9:	00 00 00 
  801ddc:	ff d0                	callq  *%rax
  801dde:	c9                   	leaveq 
  801ddf:	c3                   	retq   

0000000000801de0 <sys_env_destroy>:
  801de0:	55                   	push   %rbp
  801de1:	48 89 e5             	mov    %rsp,%rbp
  801de4:	48 83 ec 10          	sub    $0x10,%rsp
  801de8:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801deb:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801dee:	48 98                	cltq   
  801df0:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801df7:	00 
  801df8:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801dfe:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801e04:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e09:	48 89 c2             	mov    %rax,%rdx
  801e0c:	be 01 00 00 00       	mov    $0x1,%esi
  801e11:	bf 03 00 00 00       	mov    $0x3,%edi
  801e16:	48 b8 ca 1c 80 00 00 	movabs $0x801cca,%rax
  801e1d:	00 00 00 
  801e20:	ff d0                	callq  *%rax
  801e22:	c9                   	leaveq 
  801e23:	c3                   	retq   

0000000000801e24 <sys_getenvid>:
  801e24:	55                   	push   %rbp
  801e25:	48 89 e5             	mov    %rsp,%rbp
  801e28:	48 83 ec 10          	sub    $0x10,%rsp
  801e2c:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801e33:	00 
  801e34:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801e3a:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801e40:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e45:	ba 00 00 00 00       	mov    $0x0,%edx
  801e4a:	be 00 00 00 00       	mov    $0x0,%esi
  801e4f:	bf 02 00 00 00       	mov    $0x2,%edi
  801e54:	48 b8 ca 1c 80 00 00 	movabs $0x801cca,%rax
  801e5b:	00 00 00 
  801e5e:	ff d0                	callq  *%rax
  801e60:	c9                   	leaveq 
  801e61:	c3                   	retq   

0000000000801e62 <sys_yield>:
  801e62:	55                   	push   %rbp
  801e63:	48 89 e5             	mov    %rsp,%rbp
  801e66:	48 83 ec 10          	sub    $0x10,%rsp
  801e6a:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801e71:	00 
  801e72:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801e78:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801e7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e83:	ba 00 00 00 00       	mov    $0x0,%edx
  801e88:	be 00 00 00 00       	mov    $0x0,%esi
  801e8d:	bf 0b 00 00 00       	mov    $0xb,%edi
  801e92:	48 b8 ca 1c 80 00 00 	movabs $0x801cca,%rax
  801e99:	00 00 00 
  801e9c:	ff d0                	callq  *%rax
  801e9e:	c9                   	leaveq 
  801e9f:	c3                   	retq   

0000000000801ea0 <sys_page_alloc>:
  801ea0:	55                   	push   %rbp
  801ea1:	48 89 e5             	mov    %rsp,%rbp
  801ea4:	48 83 ec 20          	sub    $0x20,%rsp
  801ea8:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801eab:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801eaf:	89 55 f8             	mov    %edx,-0x8(%rbp)
  801eb2:	8b 45 f8             	mov    -0x8(%rbp),%eax
  801eb5:	48 63 c8             	movslq %eax,%rcx
  801eb8:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801ebc:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801ebf:	48 98                	cltq   
  801ec1:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801ec8:	00 
  801ec9:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801ecf:	49 89 c8             	mov    %rcx,%r8
  801ed2:	48 89 d1             	mov    %rdx,%rcx
  801ed5:	48 89 c2             	mov    %rax,%rdx
  801ed8:	be 01 00 00 00       	mov    $0x1,%esi
  801edd:	bf 04 00 00 00       	mov    $0x4,%edi
  801ee2:	48 b8 ca 1c 80 00 00 	movabs $0x801cca,%rax
  801ee9:	00 00 00 
  801eec:	ff d0                	callq  *%rax
  801eee:	c9                   	leaveq 
  801eef:	c3                   	retq   

0000000000801ef0 <sys_page_map>:
  801ef0:	55                   	push   %rbp
  801ef1:	48 89 e5             	mov    %rsp,%rbp
  801ef4:	48 83 ec 30          	sub    $0x30,%rsp
  801ef8:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801efb:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801eff:	89 55 f8             	mov    %edx,-0x8(%rbp)
  801f02:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  801f06:	44 89 45 e4          	mov    %r8d,-0x1c(%rbp)
  801f0a:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  801f0d:	48 63 c8             	movslq %eax,%rcx
  801f10:	48 8b 7d e8          	mov    -0x18(%rbp),%rdi
  801f14:	8b 45 f8             	mov    -0x8(%rbp),%eax
  801f17:	48 63 f0             	movslq %eax,%rsi
  801f1a:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801f1e:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801f21:	48 98                	cltq   
  801f23:	48 89 0c 24          	mov    %rcx,(%rsp)
  801f27:	49 89 f9             	mov    %rdi,%r9
  801f2a:	49 89 f0             	mov    %rsi,%r8
  801f2d:	48 89 d1             	mov    %rdx,%rcx
  801f30:	48 89 c2             	mov    %rax,%rdx
  801f33:	be 01 00 00 00       	mov    $0x1,%esi
  801f38:	bf 05 00 00 00       	mov    $0x5,%edi
  801f3d:	48 b8 ca 1c 80 00 00 	movabs $0x801cca,%rax
  801f44:	00 00 00 
  801f47:	ff d0                	callq  *%rax
  801f49:	c9                   	leaveq 
  801f4a:	c3                   	retq   

0000000000801f4b <sys_page_unmap>:
  801f4b:	55                   	push   %rbp
  801f4c:	48 89 e5             	mov    %rsp,%rbp
  801f4f:	48 83 ec 20          	sub    $0x20,%rsp
  801f53:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801f56:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801f5a:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801f5e:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801f61:	48 98                	cltq   
  801f63:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801f6a:	00 
  801f6b:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801f71:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801f77:	48 89 d1             	mov    %rdx,%rcx
  801f7a:	48 89 c2             	mov    %rax,%rdx
  801f7d:	be 01 00 00 00       	mov    $0x1,%esi
  801f82:	bf 06 00 00 00       	mov    $0x6,%edi
  801f87:	48 b8 ca 1c 80 00 00 	movabs $0x801cca,%rax
  801f8e:	00 00 00 
  801f91:	ff d0                	callq  *%rax
  801f93:	c9                   	leaveq 
  801f94:	c3                   	retq   

0000000000801f95 <sys_env_set_status>:
  801f95:	55                   	push   %rbp
  801f96:	48 89 e5             	mov    %rsp,%rbp
  801f99:	48 83 ec 10          	sub    $0x10,%rsp
  801f9d:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801fa0:	89 75 f8             	mov    %esi,-0x8(%rbp)
  801fa3:	8b 45 f8             	mov    -0x8(%rbp),%eax
  801fa6:	48 63 d0             	movslq %eax,%rdx
  801fa9:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801fac:	48 98                	cltq   
  801fae:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801fb5:	00 
  801fb6:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801fbc:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801fc2:	48 89 d1             	mov    %rdx,%rcx
  801fc5:	48 89 c2             	mov    %rax,%rdx
  801fc8:	be 01 00 00 00       	mov    $0x1,%esi
  801fcd:	bf 08 00 00 00       	mov    $0x8,%edi
  801fd2:	48 b8 ca 1c 80 00 00 	movabs $0x801cca,%rax
  801fd9:	00 00 00 
  801fdc:	ff d0                	callq  *%rax
  801fde:	c9                   	leaveq 
  801fdf:	c3                   	retq   

0000000000801fe0 <sys_env_set_trapframe>:
  801fe0:	55                   	push   %rbp
  801fe1:	48 89 e5             	mov    %rsp,%rbp
  801fe4:	48 83 ec 20          	sub    $0x20,%rsp
  801fe8:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801feb:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801fef:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801ff3:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801ff6:	48 98                	cltq   
  801ff8:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801fff:	00 
  802000:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  802006:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  80200c:	48 89 d1             	mov    %rdx,%rcx
  80200f:	48 89 c2             	mov    %rax,%rdx
  802012:	be 01 00 00 00       	mov    $0x1,%esi
  802017:	bf 09 00 00 00       	mov    $0x9,%edi
  80201c:	48 b8 ca 1c 80 00 00 	movabs $0x801cca,%rax
  802023:	00 00 00 
  802026:	ff d0                	callq  *%rax
  802028:	c9                   	leaveq 
  802029:	c3                   	retq   

000000000080202a <sys_env_set_pgfault_upcall>:
  80202a:	55                   	push   %rbp
  80202b:	48 89 e5             	mov    %rsp,%rbp
  80202e:	48 83 ec 20          	sub    $0x20,%rsp
  802032:	89 7d fc             	mov    %edi,-0x4(%rbp)
  802035:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  802039:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  80203d:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802040:	48 98                	cltq   
  802042:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  802049:	00 
  80204a:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  802050:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  802056:	48 89 d1             	mov    %rdx,%rcx
  802059:	48 89 c2             	mov    %rax,%rdx
  80205c:	be 01 00 00 00       	mov    $0x1,%esi
  802061:	bf 0a 00 00 00       	mov    $0xa,%edi
  802066:	48 b8 ca 1c 80 00 00 	movabs $0x801cca,%rax
  80206d:	00 00 00 
  802070:	ff d0                	callq  *%rax
  802072:	c9                   	leaveq 
  802073:	c3                   	retq   

0000000000802074 <sys_ipc_try_send>:
  802074:	55                   	push   %rbp
  802075:	48 89 e5             	mov    %rsp,%rbp
  802078:	48 83 ec 20          	sub    $0x20,%rsp
  80207c:	89 7d fc             	mov    %edi,-0x4(%rbp)
  80207f:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  802083:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  802087:	89 4d f8             	mov    %ecx,-0x8(%rbp)
  80208a:	8b 45 f8             	mov    -0x8(%rbp),%eax
  80208d:	48 63 f0             	movslq %eax,%rsi
  802090:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  802094:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802097:	48 98                	cltq   
  802099:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  80209d:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  8020a4:	00 
  8020a5:	49 89 f1             	mov    %rsi,%r9
  8020a8:	49 89 c8             	mov    %rcx,%r8
  8020ab:	48 89 d1             	mov    %rdx,%rcx
  8020ae:	48 89 c2             	mov    %rax,%rdx
  8020b1:	be 00 00 00 00       	mov    $0x0,%esi
  8020b6:	bf 0c 00 00 00       	mov    $0xc,%edi
  8020bb:	48 b8 ca 1c 80 00 00 	movabs $0x801cca,%rax
  8020c2:	00 00 00 
  8020c5:	ff d0                	callq  *%rax
  8020c7:	c9                   	leaveq 
  8020c8:	c3                   	retq   

00000000008020c9 <sys_ipc_recv>:
  8020c9:	55                   	push   %rbp
  8020ca:	48 89 e5             	mov    %rsp,%rbp
  8020cd:	48 83 ec 10          	sub    $0x10,%rsp
  8020d1:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8020d5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8020d9:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  8020e0:	00 
  8020e1:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8020e7:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  8020ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8020f2:	48 89 c2             	mov    %rax,%rdx
  8020f5:	be 01 00 00 00       	mov    $0x1,%esi
  8020fa:	bf 0d 00 00 00       	mov    $0xd,%edi
  8020ff:	48 b8 ca 1c 80 00 00 	movabs $0x801cca,%rax
  802106:	00 00 00 
  802109:	ff d0                	callq  *%rax
  80210b:	c9                   	leaveq 
  80210c:	c3                   	retq   

000000000080210d <sys_time_msec>:
  80210d:	55                   	push   %rbp
  80210e:	48 89 e5             	mov    %rsp,%rbp
  802111:	48 83 ec 10          	sub    $0x10,%rsp
  802115:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  80211c:	00 
  80211d:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  802123:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  802129:	b9 00 00 00 00       	mov    $0x0,%ecx
  80212e:	ba 00 00 00 00       	mov    $0x0,%edx
  802133:	be 00 00 00 00       	mov    $0x0,%esi
  802138:	bf 0e 00 00 00       	mov    $0xe,%edi
  80213d:	48 b8 ca 1c 80 00 00 	movabs $0x801cca,%rax
  802144:	00 00 00 
  802147:	ff d0                	callq  *%rax
  802149:	c9                   	leaveq 
  80214a:	c3                   	retq   

000000000080214b <sys_net_transmit>:
  80214b:	55                   	push   %rbp
  80214c:	48 89 e5             	mov    %rsp,%rbp
  80214f:	48 83 ec 20          	sub    $0x20,%rsp
  802153:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  802157:	89 75 f4             	mov    %esi,-0xc(%rbp)
  80215a:	8b 55 f4             	mov    -0xc(%rbp),%edx
  80215d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  802161:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  802168:	00 
  802169:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  80216f:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  802175:	48 89 d1             	mov    %rdx,%rcx
  802178:	48 89 c2             	mov    %rax,%rdx
  80217b:	be 00 00 00 00       	mov    $0x0,%esi
  802180:	bf 0f 00 00 00       	mov    $0xf,%edi
  802185:	48 b8 ca 1c 80 00 00 	movabs $0x801cca,%rax
  80218c:	00 00 00 
  80218f:	ff d0                	callq  *%rax
  802191:	c9                   	leaveq 
  802192:	c3                   	retq   

0000000000802193 <sys_net_receive>:
  802193:	55                   	push   %rbp
  802194:	48 89 e5             	mov    %rsp,%rbp
  802197:	48 83 ec 20          	sub    $0x20,%rsp
  80219b:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  80219f:	89 75 f4             	mov    %esi,-0xc(%rbp)
  8021a2:	8b 55 f4             	mov    -0xc(%rbp),%edx
  8021a5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8021a9:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  8021b0:	00 
  8021b1:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8021b7:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  8021bd:	48 89 d1             	mov    %rdx,%rcx
  8021c0:	48 89 c2             	mov    %rax,%rdx
  8021c3:	be 00 00 00 00       	mov    $0x0,%esi
  8021c8:	bf 10 00 00 00       	mov    $0x10,%edi
  8021cd:	48 b8 ca 1c 80 00 00 	movabs $0x801cca,%rax
  8021d4:	00 00 00 
  8021d7:	ff d0                	callq  *%rax
  8021d9:	c9                   	leaveq 
  8021da:	c3                   	retq   

00000000008021db <sys_ept_map>:
  8021db:	55                   	push   %rbp
  8021dc:	48 89 e5             	mov    %rsp,%rbp
  8021df:	48 83 ec 30          	sub    $0x30,%rsp
  8021e3:	89 7d fc             	mov    %edi,-0x4(%rbp)
  8021e6:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8021ea:	89 55 f8             	mov    %edx,-0x8(%rbp)
  8021ed:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  8021f1:	44 89 45 e4          	mov    %r8d,-0x1c(%rbp)
  8021f5:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  8021f8:	48 63 c8             	movslq %eax,%rcx
  8021fb:	48 8b 7d e8          	mov    -0x18(%rbp),%rdi
  8021ff:	8b 45 f8             	mov    -0x8(%rbp),%eax
  802202:	48 63 f0             	movslq %eax,%rsi
  802205:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  802209:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80220c:	48 98                	cltq   
  80220e:	48 89 0c 24          	mov    %rcx,(%rsp)
  802212:	49 89 f9             	mov    %rdi,%r9
  802215:	49 89 f0             	mov    %rsi,%r8
  802218:	48 89 d1             	mov    %rdx,%rcx
  80221b:	48 89 c2             	mov    %rax,%rdx
  80221e:	be 00 00 00 00       	mov    $0x0,%esi
  802223:	bf 11 00 00 00       	mov    $0x11,%edi
  802228:	48 b8 ca 1c 80 00 00 	movabs $0x801cca,%rax
  80222f:	00 00 00 
  802232:	ff d0                	callq  *%rax
  802234:	c9                   	leaveq 
  802235:	c3                   	retq   

0000000000802236 <sys_env_mkguest>:
  802236:	55                   	push   %rbp
  802237:	48 89 e5             	mov    %rsp,%rbp
  80223a:	48 83 ec 20          	sub    $0x20,%rsp
  80223e:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  802242:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  802246:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  80224a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80224e:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  802255:	00 
  802256:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  80225c:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  802262:	48 89 d1             	mov    %rdx,%rcx
  802265:	48 89 c2             	mov    %rax,%rdx
  802268:	be 00 00 00 00       	mov    $0x0,%esi
  80226d:	bf 12 00 00 00       	mov    $0x12,%edi
  802272:	48 b8 ca 1c 80 00 00 	movabs $0x801cca,%rax
  802279:	00 00 00 
  80227c:	ff d0                	callq  *%rax
  80227e:	c9                   	leaveq 
  80227f:	c3                   	retq   

0000000000802280 <sys_vmx_list_vms>:
  802280:	55                   	push   %rbp
  802281:	48 89 e5             	mov    %rsp,%rbp
  802284:	48 83 ec 10          	sub    $0x10,%rsp
  802288:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  80228f:	00 
  802290:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  802296:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  80229c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8022a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8022a6:	be 00 00 00 00       	mov    $0x0,%esi
  8022ab:	bf 13 00 00 00       	mov    $0x13,%edi
  8022b0:	48 b8 ca 1c 80 00 00 	movabs $0x801cca,%rax
  8022b7:	00 00 00 
  8022ba:	ff d0                	callq  *%rax
  8022bc:	c9                   	leaveq 
  8022bd:	c3                   	retq   

00000000008022be <sys_vmx_sel_resume>:
  8022be:	55                   	push   %rbp
  8022bf:	48 89 e5             	mov    %rsp,%rbp
  8022c2:	48 83 ec 10          	sub    $0x10,%rsp
  8022c6:	89 7d fc             	mov    %edi,-0x4(%rbp)
  8022c9:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8022cc:	48 98                	cltq   
  8022ce:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  8022d5:	00 
  8022d6:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8022dc:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  8022e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8022e7:	48 89 c2             	mov    %rax,%rdx
  8022ea:	be 00 00 00 00       	mov    $0x0,%esi
  8022ef:	bf 14 00 00 00       	mov    $0x14,%edi
  8022f4:	48 b8 ca 1c 80 00 00 	movabs $0x801cca,%rax
  8022fb:	00 00 00 
  8022fe:	ff d0                	callq  *%rax
  802300:	c9                   	leaveq 
  802301:	c3                   	retq   

0000000000802302 <sys_vmx_get_vmdisk_number>:
  802302:	55                   	push   %rbp
  802303:	48 89 e5             	mov    %rsp,%rbp
  802306:	48 83 ec 10          	sub    $0x10,%rsp
  80230a:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  802311:	00 
  802312:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  802318:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  80231e:	b9 00 00 00 00       	mov    $0x0,%ecx
  802323:	ba 00 00 00 00       	mov    $0x0,%edx
  802328:	be 00 00 00 00       	mov    $0x0,%esi
  80232d:	bf 15 00 00 00       	mov    $0x15,%edi
  802332:	48 b8 ca 1c 80 00 00 	movabs $0x801cca,%rax
  802339:	00 00 00 
  80233c:	ff d0                	callq  *%rax
  80233e:	c9                   	leaveq 
  80233f:	c3                   	retq   

0000000000802340 <sys_vmx_incr_vmdisk_number>:
  802340:	55                   	push   %rbp
  802341:	48 89 e5             	mov    %rsp,%rbp
  802344:	48 83 ec 10          	sub    $0x10,%rsp
  802348:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  80234f:	00 
  802350:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  802356:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  80235c:	b9 00 00 00 00       	mov    $0x0,%ecx
  802361:	ba 00 00 00 00       	mov    $0x0,%edx
  802366:	be 00 00 00 00       	mov    $0x0,%esi
  80236b:	bf 16 00 00 00       	mov    $0x16,%edi
  802370:	48 b8 ca 1c 80 00 00 	movabs $0x801cca,%rax
  802377:	00 00 00 
  80237a:	ff d0                	callq  *%rax
  80237c:	c9                   	leaveq 
  80237d:	c3                   	retq   

000000000080237e <fd2num>:
  80237e:	55                   	push   %rbp
  80237f:	48 89 e5             	mov    %rsp,%rbp
  802382:	48 83 ec 08          	sub    $0x8,%rsp
  802386:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  80238a:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  80238e:	48 b8 00 00 00 30 ff 	movabs $0xffffffff30000000,%rax
  802395:	ff ff ff 
  802398:	48 01 d0             	add    %rdx,%rax
  80239b:	48 c1 e8 0c          	shr    $0xc,%rax
  80239f:	c9                   	leaveq 
  8023a0:	c3                   	retq   

00000000008023a1 <fd2data>:
  8023a1:	55                   	push   %rbp
  8023a2:	48 89 e5             	mov    %rsp,%rbp
  8023a5:	48 83 ec 08          	sub    $0x8,%rsp
  8023a9:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8023ad:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8023b1:	48 89 c7             	mov    %rax,%rdi
  8023b4:	48 b8 7e 23 80 00 00 	movabs $0x80237e,%rax
  8023bb:	00 00 00 
  8023be:	ff d0                	callq  *%rax
  8023c0:	48 05 20 00 0d 00    	add    $0xd0020,%rax
  8023c6:	48 c1 e0 0c          	shl    $0xc,%rax
  8023ca:	c9                   	leaveq 
  8023cb:	c3                   	retq   

00000000008023cc <fd_alloc>:
  8023cc:	55                   	push   %rbp
  8023cd:	48 89 e5             	mov    %rsp,%rbp
  8023d0:	48 83 ec 18          	sub    $0x18,%rsp
  8023d4:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8023d8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8023df:	eb 6b                	jmp    80244c <fd_alloc+0x80>
  8023e1:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8023e4:	48 98                	cltq   
  8023e6:	48 05 00 00 0d 00    	add    $0xd0000,%rax
  8023ec:	48 c1 e0 0c          	shl    $0xc,%rax
  8023f0:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  8023f4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8023f8:	48 c1 e8 15          	shr    $0x15,%rax
  8023fc:	48 89 c2             	mov    %rax,%rdx
  8023ff:	48 b8 00 00 00 80 00 	movabs $0x10080000000,%rax
  802406:	01 00 00 
  802409:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  80240d:	83 e0 01             	and    $0x1,%eax
  802410:	48 85 c0             	test   %rax,%rax
  802413:	74 21                	je     802436 <fd_alloc+0x6a>
  802415:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802419:	48 c1 e8 0c          	shr    $0xc,%rax
  80241d:	48 89 c2             	mov    %rax,%rdx
  802420:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  802427:	01 00 00 
  80242a:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  80242e:	83 e0 01             	and    $0x1,%eax
  802431:	48 85 c0             	test   %rax,%rax
  802434:	75 12                	jne    802448 <fd_alloc+0x7c>
  802436:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80243a:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  80243e:	48 89 10             	mov    %rdx,(%rax)
  802441:	b8 00 00 00 00       	mov    $0x0,%eax
  802446:	eb 1a                	jmp    802462 <fd_alloc+0x96>
  802448:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  80244c:	83 7d fc 1f          	cmpl   $0x1f,-0x4(%rbp)
  802450:	7e 8f                	jle    8023e1 <fd_alloc+0x15>
  802452:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802456:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  80245d:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  802462:	c9                   	leaveq 
  802463:	c3                   	retq   

0000000000802464 <fd_lookup>:
  802464:	55                   	push   %rbp
  802465:	48 89 e5             	mov    %rsp,%rbp
  802468:	48 83 ec 20          	sub    $0x20,%rsp
  80246c:	89 7d ec             	mov    %edi,-0x14(%rbp)
  80246f:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  802473:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  802477:	78 06                	js     80247f <fd_lookup+0x1b>
  802479:	83 7d ec 1f          	cmpl   $0x1f,-0x14(%rbp)
  80247d:	7e 07                	jle    802486 <fd_lookup+0x22>
  80247f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802484:	eb 6c                	jmp    8024f2 <fd_lookup+0x8e>
  802486:	8b 45 ec             	mov    -0x14(%rbp),%eax
  802489:	48 98                	cltq   
  80248b:	48 05 00 00 0d 00    	add    $0xd0000,%rax
  802491:	48 c1 e0 0c          	shl    $0xc,%rax
  802495:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  802499:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80249d:	48 c1 e8 15          	shr    $0x15,%rax
  8024a1:	48 89 c2             	mov    %rax,%rdx
  8024a4:	48 b8 00 00 00 80 00 	movabs $0x10080000000,%rax
  8024ab:	01 00 00 
  8024ae:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8024b2:	83 e0 01             	and    $0x1,%eax
  8024b5:	48 85 c0             	test   %rax,%rax
  8024b8:	74 21                	je     8024db <fd_lookup+0x77>
  8024ba:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8024be:	48 c1 e8 0c          	shr    $0xc,%rax
  8024c2:	48 89 c2             	mov    %rax,%rdx
  8024c5:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  8024cc:	01 00 00 
  8024cf:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8024d3:	83 e0 01             	and    $0x1,%eax
  8024d6:	48 85 c0             	test   %rax,%rax
  8024d9:	75 07                	jne    8024e2 <fd_lookup+0x7e>
  8024db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8024e0:	eb 10                	jmp    8024f2 <fd_lookup+0x8e>
  8024e2:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8024e6:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8024ea:	48 89 10             	mov    %rdx,(%rax)
  8024ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8024f2:	c9                   	leaveq 
  8024f3:	c3                   	retq   

00000000008024f4 <fd_close>:
  8024f4:	55                   	push   %rbp
  8024f5:	48 89 e5             	mov    %rsp,%rbp
  8024f8:	48 83 ec 30          	sub    $0x30,%rsp
  8024fc:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  802500:	89 f0                	mov    %esi,%eax
  802502:	88 45 d4             	mov    %al,-0x2c(%rbp)
  802505:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  802509:	48 89 c7             	mov    %rax,%rdi
  80250c:	48 b8 7e 23 80 00 00 	movabs $0x80237e,%rax
  802513:	00 00 00 
  802516:	ff d0                	callq  *%rax
  802518:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  80251c:	48 89 d6             	mov    %rdx,%rsi
  80251f:	89 c7                	mov    %eax,%edi
  802521:	48 b8 64 24 80 00 00 	movabs $0x802464,%rax
  802528:	00 00 00 
  80252b:	ff d0                	callq  *%rax
  80252d:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802530:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802534:	78 0a                	js     802540 <fd_close+0x4c>
  802536:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80253a:	48 39 45 d8          	cmp    %rax,-0x28(%rbp)
  80253e:	74 12                	je     802552 <fd_close+0x5e>
  802540:	80 7d d4 00          	cmpb   $0x0,-0x2c(%rbp)
  802544:	74 05                	je     80254b <fd_close+0x57>
  802546:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802549:	eb 05                	jmp    802550 <fd_close+0x5c>
  80254b:	b8 00 00 00 00       	mov    $0x0,%eax
  802550:	eb 69                	jmp    8025bb <fd_close+0xc7>
  802552:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  802556:	8b 00                	mov    (%rax),%eax
  802558:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  80255c:	48 89 d6             	mov    %rdx,%rsi
  80255f:	89 c7                	mov    %eax,%edi
  802561:	48 b8 bd 25 80 00 00 	movabs $0x8025bd,%rax
  802568:	00 00 00 
  80256b:	ff d0                	callq  *%rax
  80256d:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802570:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802574:	78 2a                	js     8025a0 <fd_close+0xac>
  802576:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80257a:	48 8b 40 20          	mov    0x20(%rax),%rax
  80257e:	48 85 c0             	test   %rax,%rax
  802581:	74 16                	je     802599 <fd_close+0xa5>
  802583:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802587:	48 8b 40 20          	mov    0x20(%rax),%rax
  80258b:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  80258f:	48 89 d7             	mov    %rdx,%rdi
  802592:	ff d0                	callq  *%rax
  802594:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802597:	eb 07                	jmp    8025a0 <fd_close+0xac>
  802599:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8025a0:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8025a4:	48 89 c6             	mov    %rax,%rsi
  8025a7:	bf 00 00 00 00       	mov    $0x0,%edi
  8025ac:	48 b8 4b 1f 80 00 00 	movabs $0x801f4b,%rax
  8025b3:	00 00 00 
  8025b6:	ff d0                	callq  *%rax
  8025b8:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8025bb:	c9                   	leaveq 
  8025bc:	c3                   	retq   

00000000008025bd <dev_lookup>:
  8025bd:	55                   	push   %rbp
  8025be:	48 89 e5             	mov    %rsp,%rbp
  8025c1:	48 83 ec 20          	sub    $0x20,%rsp
  8025c5:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8025c8:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8025cc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8025d3:	eb 41                	jmp    802616 <dev_lookup+0x59>
  8025d5:	48 b8 20 60 80 00 00 	movabs $0x806020,%rax
  8025dc:	00 00 00 
  8025df:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8025e2:	48 63 d2             	movslq %edx,%rdx
  8025e5:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8025e9:	8b 00                	mov    (%rax),%eax
  8025eb:	3b 45 ec             	cmp    -0x14(%rbp),%eax
  8025ee:	75 22                	jne    802612 <dev_lookup+0x55>
  8025f0:	48 b8 20 60 80 00 00 	movabs $0x806020,%rax
  8025f7:	00 00 00 
  8025fa:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8025fd:	48 63 d2             	movslq %edx,%rdx
  802600:	48 8b 14 d0          	mov    (%rax,%rdx,8),%rdx
  802604:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  802608:	48 89 10             	mov    %rdx,(%rax)
  80260b:	b8 00 00 00 00       	mov    $0x0,%eax
  802610:	eb 60                	jmp    802672 <dev_lookup+0xb5>
  802612:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  802616:	48 b8 20 60 80 00 00 	movabs $0x806020,%rax
  80261d:	00 00 00 
  802620:	8b 55 fc             	mov    -0x4(%rbp),%edx
  802623:	48 63 d2             	movslq %edx,%rdx
  802626:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  80262a:	48 85 c0             	test   %rax,%rax
  80262d:	75 a6                	jne    8025d5 <dev_lookup+0x18>
  80262f:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  802636:	00 00 00 
  802639:	48 8b 00             	mov    (%rax),%rax
  80263c:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  802642:	8b 55 ec             	mov    -0x14(%rbp),%edx
  802645:	89 c6                	mov    %eax,%esi
  802647:	48 bf d8 4d 80 00 00 	movabs $0x804dd8,%rdi
  80264e:	00 00 00 
  802651:	b8 00 00 00 00       	mov    $0x0,%eax
  802656:	48 b9 bc 09 80 00 00 	movabs $0x8009bc,%rcx
  80265d:	00 00 00 
  802660:	ff d1                	callq  *%rcx
  802662:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  802666:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  80266d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802672:	c9                   	leaveq 
  802673:	c3                   	retq   

0000000000802674 <close>:
  802674:	55                   	push   %rbp
  802675:	48 89 e5             	mov    %rsp,%rbp
  802678:	48 83 ec 20          	sub    $0x20,%rsp
  80267c:	89 7d ec             	mov    %edi,-0x14(%rbp)
  80267f:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  802683:	8b 45 ec             	mov    -0x14(%rbp),%eax
  802686:	48 89 d6             	mov    %rdx,%rsi
  802689:	89 c7                	mov    %eax,%edi
  80268b:	48 b8 64 24 80 00 00 	movabs $0x802464,%rax
  802692:	00 00 00 
  802695:	ff d0                	callq  *%rax
  802697:	89 45 fc             	mov    %eax,-0x4(%rbp)
  80269a:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80269e:	79 05                	jns    8026a5 <close+0x31>
  8026a0:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8026a3:	eb 18                	jmp    8026bd <close+0x49>
  8026a5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8026a9:	be 01 00 00 00       	mov    $0x1,%esi
  8026ae:	48 89 c7             	mov    %rax,%rdi
  8026b1:	48 b8 f4 24 80 00 00 	movabs $0x8024f4,%rax
  8026b8:	00 00 00 
  8026bb:	ff d0                	callq  *%rax
  8026bd:	c9                   	leaveq 
  8026be:	c3                   	retq   

00000000008026bf <close_all>:
  8026bf:	55                   	push   %rbp
  8026c0:	48 89 e5             	mov    %rsp,%rbp
  8026c3:	48 83 ec 10          	sub    $0x10,%rsp
  8026c7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8026ce:	eb 15                	jmp    8026e5 <close_all+0x26>
  8026d0:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8026d3:	89 c7                	mov    %eax,%edi
  8026d5:	48 b8 74 26 80 00 00 	movabs $0x802674,%rax
  8026dc:	00 00 00 
  8026df:	ff d0                	callq  *%rax
  8026e1:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  8026e5:	83 7d fc 1f          	cmpl   $0x1f,-0x4(%rbp)
  8026e9:	7e e5                	jle    8026d0 <close_all+0x11>
  8026eb:	c9                   	leaveq 
  8026ec:	c3                   	retq   

00000000008026ed <dup>:
  8026ed:	55                   	push   %rbp
  8026ee:	48 89 e5             	mov    %rsp,%rbp
  8026f1:	48 83 ec 40          	sub    $0x40,%rsp
  8026f5:	89 7d cc             	mov    %edi,-0x34(%rbp)
  8026f8:	89 75 c8             	mov    %esi,-0x38(%rbp)
  8026fb:	48 8d 55 d8          	lea    -0x28(%rbp),%rdx
  8026ff:	8b 45 cc             	mov    -0x34(%rbp),%eax
  802702:	48 89 d6             	mov    %rdx,%rsi
  802705:	89 c7                	mov    %eax,%edi
  802707:	48 b8 64 24 80 00 00 	movabs $0x802464,%rax
  80270e:	00 00 00 
  802711:	ff d0                	callq  *%rax
  802713:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802716:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80271a:	79 08                	jns    802724 <dup+0x37>
  80271c:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80271f:	e9 70 01 00 00       	jmpq   802894 <dup+0x1a7>
  802724:	8b 45 c8             	mov    -0x38(%rbp),%eax
  802727:	89 c7                	mov    %eax,%edi
  802729:	48 b8 74 26 80 00 00 	movabs $0x802674,%rax
  802730:	00 00 00 
  802733:	ff d0                	callq  *%rax
  802735:	8b 45 c8             	mov    -0x38(%rbp),%eax
  802738:	48 98                	cltq   
  80273a:	48 05 00 00 0d 00    	add    $0xd0000,%rax
  802740:	48 c1 e0 0c          	shl    $0xc,%rax
  802744:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  802748:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80274c:	48 89 c7             	mov    %rax,%rdi
  80274f:	48 b8 a1 23 80 00 00 	movabs $0x8023a1,%rax
  802756:	00 00 00 
  802759:	ff d0                	callq  *%rax
  80275b:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  80275f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802763:	48 89 c7             	mov    %rax,%rdi
  802766:	48 b8 a1 23 80 00 00 	movabs $0x8023a1,%rax
  80276d:	00 00 00 
  802770:	ff d0                	callq  *%rax
  802772:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  802776:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80277a:	48 c1 e8 15          	shr    $0x15,%rax
  80277e:	48 89 c2             	mov    %rax,%rdx
  802781:	48 b8 00 00 00 80 00 	movabs $0x10080000000,%rax
  802788:	01 00 00 
  80278b:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  80278f:	83 e0 01             	and    $0x1,%eax
  802792:	48 85 c0             	test   %rax,%rax
  802795:	74 73                	je     80280a <dup+0x11d>
  802797:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80279b:	48 c1 e8 0c          	shr    $0xc,%rax
  80279f:	48 89 c2             	mov    %rax,%rdx
  8027a2:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  8027a9:	01 00 00 
  8027ac:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8027b0:	83 e0 01             	and    $0x1,%eax
  8027b3:	48 85 c0             	test   %rax,%rax
  8027b6:	74 52                	je     80280a <dup+0x11d>
  8027b8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8027bc:	48 c1 e8 0c          	shr    $0xc,%rax
  8027c0:	48 89 c2             	mov    %rax,%rdx
  8027c3:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  8027ca:	01 00 00 
  8027cd:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8027d1:	25 07 0e 00 00       	and    $0xe07,%eax
  8027d6:	89 c1                	mov    %eax,%ecx
  8027d8:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8027dc:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8027e0:	41 89 c8             	mov    %ecx,%r8d
  8027e3:	48 89 d1             	mov    %rdx,%rcx
  8027e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8027eb:	48 89 c6             	mov    %rax,%rsi
  8027ee:	bf 00 00 00 00       	mov    $0x0,%edi
  8027f3:	48 b8 f0 1e 80 00 00 	movabs $0x801ef0,%rax
  8027fa:	00 00 00 
  8027fd:	ff d0                	callq  *%rax
  8027ff:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802802:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802806:	79 02                	jns    80280a <dup+0x11d>
  802808:	eb 57                	jmp    802861 <dup+0x174>
  80280a:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80280e:	48 c1 e8 0c          	shr    $0xc,%rax
  802812:	48 89 c2             	mov    %rax,%rdx
  802815:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  80281c:	01 00 00 
  80281f:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  802823:	25 07 0e 00 00       	and    $0xe07,%eax
  802828:	89 c1                	mov    %eax,%ecx
  80282a:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80282e:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  802832:	41 89 c8             	mov    %ecx,%r8d
  802835:	48 89 d1             	mov    %rdx,%rcx
  802838:	ba 00 00 00 00       	mov    $0x0,%edx
  80283d:	48 89 c6             	mov    %rax,%rsi
  802840:	bf 00 00 00 00       	mov    $0x0,%edi
  802845:	48 b8 f0 1e 80 00 00 	movabs $0x801ef0,%rax
  80284c:	00 00 00 
  80284f:	ff d0                	callq  *%rax
  802851:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802854:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802858:	79 02                	jns    80285c <dup+0x16f>
  80285a:	eb 05                	jmp    802861 <dup+0x174>
  80285c:	8b 45 c8             	mov    -0x38(%rbp),%eax
  80285f:	eb 33                	jmp    802894 <dup+0x1a7>
  802861:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802865:	48 89 c6             	mov    %rax,%rsi
  802868:	bf 00 00 00 00       	mov    $0x0,%edi
  80286d:	48 b8 4b 1f 80 00 00 	movabs $0x801f4b,%rax
  802874:	00 00 00 
  802877:	ff d0                	callq  *%rax
  802879:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80287d:	48 89 c6             	mov    %rax,%rsi
  802880:	bf 00 00 00 00       	mov    $0x0,%edi
  802885:	48 b8 4b 1f 80 00 00 	movabs $0x801f4b,%rax
  80288c:	00 00 00 
  80288f:	ff d0                	callq  *%rax
  802891:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802894:	c9                   	leaveq 
  802895:	c3                   	retq   

0000000000802896 <read>:
  802896:	55                   	push   %rbp
  802897:	48 89 e5             	mov    %rsp,%rbp
  80289a:	48 83 ec 40          	sub    $0x40,%rsp
  80289e:	89 7d dc             	mov    %edi,-0x24(%rbp)
  8028a1:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  8028a5:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8028a9:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  8028ad:	8b 45 dc             	mov    -0x24(%rbp),%eax
  8028b0:	48 89 d6             	mov    %rdx,%rsi
  8028b3:	89 c7                	mov    %eax,%edi
  8028b5:	48 b8 64 24 80 00 00 	movabs $0x802464,%rax
  8028bc:	00 00 00 
  8028bf:	ff d0                	callq  *%rax
  8028c1:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8028c4:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8028c8:	78 24                	js     8028ee <read+0x58>
  8028ca:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8028ce:	8b 00                	mov    (%rax),%eax
  8028d0:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  8028d4:	48 89 d6             	mov    %rdx,%rsi
  8028d7:	89 c7                	mov    %eax,%edi
  8028d9:	48 b8 bd 25 80 00 00 	movabs $0x8025bd,%rax
  8028e0:	00 00 00 
  8028e3:	ff d0                	callq  *%rax
  8028e5:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8028e8:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8028ec:	79 05                	jns    8028f3 <read+0x5d>
  8028ee:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8028f1:	eb 76                	jmp    802969 <read+0xd3>
  8028f3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8028f7:	8b 40 08             	mov    0x8(%rax),%eax
  8028fa:	83 e0 03             	and    $0x3,%eax
  8028fd:	83 f8 01             	cmp    $0x1,%eax
  802900:	75 3a                	jne    80293c <read+0xa6>
  802902:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  802909:	00 00 00 
  80290c:	48 8b 00             	mov    (%rax),%rax
  80290f:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  802915:	8b 55 dc             	mov    -0x24(%rbp),%edx
  802918:	89 c6                	mov    %eax,%esi
  80291a:	48 bf f7 4d 80 00 00 	movabs $0x804df7,%rdi
  802921:	00 00 00 
  802924:	b8 00 00 00 00       	mov    $0x0,%eax
  802929:	48 b9 bc 09 80 00 00 	movabs $0x8009bc,%rcx
  802930:	00 00 00 
  802933:	ff d1                	callq  *%rcx
  802935:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80293a:	eb 2d                	jmp    802969 <read+0xd3>
  80293c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802940:	48 8b 40 10          	mov    0x10(%rax),%rax
  802944:	48 85 c0             	test   %rax,%rax
  802947:	75 07                	jne    802950 <read+0xba>
  802949:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80294e:	eb 19                	jmp    802969 <read+0xd3>
  802950:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802954:	48 8b 40 10          	mov    0x10(%rax),%rax
  802958:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  80295c:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  802960:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  802964:	48 89 cf             	mov    %rcx,%rdi
  802967:	ff d0                	callq  *%rax
  802969:	c9                   	leaveq 
  80296a:	c3                   	retq   

000000000080296b <readn>:
  80296b:	55                   	push   %rbp
  80296c:	48 89 e5             	mov    %rsp,%rbp
  80296f:	48 83 ec 30          	sub    $0x30,%rsp
  802973:	89 7d ec             	mov    %edi,-0x14(%rbp)
  802976:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  80297a:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  80297e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  802985:	eb 49                	jmp    8029d0 <readn+0x65>
  802987:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80298a:	48 98                	cltq   
  80298c:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  802990:	48 29 c2             	sub    %rax,%rdx
  802993:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802996:	48 63 c8             	movslq %eax,%rcx
  802999:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80299d:	48 01 c1             	add    %rax,%rcx
  8029a0:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8029a3:	48 89 ce             	mov    %rcx,%rsi
  8029a6:	89 c7                	mov    %eax,%edi
  8029a8:	48 b8 96 28 80 00 00 	movabs $0x802896,%rax
  8029af:	00 00 00 
  8029b2:	ff d0                	callq  *%rax
  8029b4:	89 45 f8             	mov    %eax,-0x8(%rbp)
  8029b7:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  8029bb:	79 05                	jns    8029c2 <readn+0x57>
  8029bd:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8029c0:	eb 1c                	jmp    8029de <readn+0x73>
  8029c2:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  8029c6:	75 02                	jne    8029ca <readn+0x5f>
  8029c8:	eb 11                	jmp    8029db <readn+0x70>
  8029ca:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8029cd:	01 45 fc             	add    %eax,-0x4(%rbp)
  8029d0:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8029d3:	48 98                	cltq   
  8029d5:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  8029d9:	72 ac                	jb     802987 <readn+0x1c>
  8029db:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8029de:	c9                   	leaveq 
  8029df:	c3                   	retq   

00000000008029e0 <write>:
  8029e0:	55                   	push   %rbp
  8029e1:	48 89 e5             	mov    %rsp,%rbp
  8029e4:	48 83 ec 40          	sub    $0x40,%rsp
  8029e8:	89 7d dc             	mov    %edi,-0x24(%rbp)
  8029eb:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  8029ef:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8029f3:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  8029f7:	8b 45 dc             	mov    -0x24(%rbp),%eax
  8029fa:	48 89 d6             	mov    %rdx,%rsi
  8029fd:	89 c7                	mov    %eax,%edi
  8029ff:	48 b8 64 24 80 00 00 	movabs $0x802464,%rax
  802a06:	00 00 00 
  802a09:	ff d0                	callq  *%rax
  802a0b:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802a0e:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802a12:	78 24                	js     802a38 <write+0x58>
  802a14:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802a18:	8b 00                	mov    (%rax),%eax
  802a1a:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  802a1e:	48 89 d6             	mov    %rdx,%rsi
  802a21:	89 c7                	mov    %eax,%edi
  802a23:	48 b8 bd 25 80 00 00 	movabs $0x8025bd,%rax
  802a2a:	00 00 00 
  802a2d:	ff d0                	callq  *%rax
  802a2f:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802a32:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802a36:	79 05                	jns    802a3d <write+0x5d>
  802a38:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802a3b:	eb 75                	jmp    802ab2 <write+0xd2>
  802a3d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802a41:	8b 40 08             	mov    0x8(%rax),%eax
  802a44:	83 e0 03             	and    $0x3,%eax
  802a47:	85 c0                	test   %eax,%eax
  802a49:	75 3a                	jne    802a85 <write+0xa5>
  802a4b:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  802a52:	00 00 00 
  802a55:	48 8b 00             	mov    (%rax),%rax
  802a58:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  802a5e:	8b 55 dc             	mov    -0x24(%rbp),%edx
  802a61:	89 c6                	mov    %eax,%esi
  802a63:	48 bf 13 4e 80 00 00 	movabs $0x804e13,%rdi
  802a6a:	00 00 00 
  802a6d:	b8 00 00 00 00       	mov    $0x0,%eax
  802a72:	48 b9 bc 09 80 00 00 	movabs $0x8009bc,%rcx
  802a79:	00 00 00 
  802a7c:	ff d1                	callq  *%rcx
  802a7e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802a83:	eb 2d                	jmp    802ab2 <write+0xd2>
  802a85:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802a89:	48 8b 40 18          	mov    0x18(%rax),%rax
  802a8d:	48 85 c0             	test   %rax,%rax
  802a90:	75 07                	jne    802a99 <write+0xb9>
  802a92:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  802a97:	eb 19                	jmp    802ab2 <write+0xd2>
  802a99:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802a9d:	48 8b 40 18          	mov    0x18(%rax),%rax
  802aa1:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  802aa5:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  802aa9:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  802aad:	48 89 cf             	mov    %rcx,%rdi
  802ab0:	ff d0                	callq  *%rax
  802ab2:	c9                   	leaveq 
  802ab3:	c3                   	retq   

0000000000802ab4 <seek>:
  802ab4:	55                   	push   %rbp
  802ab5:	48 89 e5             	mov    %rsp,%rbp
  802ab8:	48 83 ec 18          	sub    $0x18,%rsp
  802abc:	89 7d ec             	mov    %edi,-0x14(%rbp)
  802abf:	89 75 e8             	mov    %esi,-0x18(%rbp)
  802ac2:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  802ac6:	8b 45 ec             	mov    -0x14(%rbp),%eax
  802ac9:	48 89 d6             	mov    %rdx,%rsi
  802acc:	89 c7                	mov    %eax,%edi
  802ace:	48 b8 64 24 80 00 00 	movabs $0x802464,%rax
  802ad5:	00 00 00 
  802ad8:	ff d0                	callq  *%rax
  802ada:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802add:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802ae1:	79 05                	jns    802ae8 <seek+0x34>
  802ae3:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802ae6:	eb 0f                	jmp    802af7 <seek+0x43>
  802ae8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802aec:	8b 55 e8             	mov    -0x18(%rbp),%edx
  802aef:	89 50 04             	mov    %edx,0x4(%rax)
  802af2:	b8 00 00 00 00       	mov    $0x0,%eax
  802af7:	c9                   	leaveq 
  802af8:	c3                   	retq   

0000000000802af9 <ftruncate>:
  802af9:	55                   	push   %rbp
  802afa:	48 89 e5             	mov    %rsp,%rbp
  802afd:	48 83 ec 30          	sub    $0x30,%rsp
  802b01:	89 7d dc             	mov    %edi,-0x24(%rbp)
  802b04:	89 75 d8             	mov    %esi,-0x28(%rbp)
  802b07:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  802b0b:	8b 45 dc             	mov    -0x24(%rbp),%eax
  802b0e:	48 89 d6             	mov    %rdx,%rsi
  802b11:	89 c7                	mov    %eax,%edi
  802b13:	48 b8 64 24 80 00 00 	movabs $0x802464,%rax
  802b1a:	00 00 00 
  802b1d:	ff d0                	callq  *%rax
  802b1f:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802b22:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802b26:	78 24                	js     802b4c <ftruncate+0x53>
  802b28:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802b2c:	8b 00                	mov    (%rax),%eax
  802b2e:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  802b32:	48 89 d6             	mov    %rdx,%rsi
  802b35:	89 c7                	mov    %eax,%edi
  802b37:	48 b8 bd 25 80 00 00 	movabs $0x8025bd,%rax
  802b3e:	00 00 00 
  802b41:	ff d0                	callq  *%rax
  802b43:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802b46:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802b4a:	79 05                	jns    802b51 <ftruncate+0x58>
  802b4c:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802b4f:	eb 72                	jmp    802bc3 <ftruncate+0xca>
  802b51:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802b55:	8b 40 08             	mov    0x8(%rax),%eax
  802b58:	83 e0 03             	and    $0x3,%eax
  802b5b:	85 c0                	test   %eax,%eax
  802b5d:	75 3a                	jne    802b99 <ftruncate+0xa0>
  802b5f:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  802b66:	00 00 00 
  802b69:	48 8b 00             	mov    (%rax),%rax
  802b6c:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  802b72:	8b 55 dc             	mov    -0x24(%rbp),%edx
  802b75:	89 c6                	mov    %eax,%esi
  802b77:	48 bf 30 4e 80 00 00 	movabs $0x804e30,%rdi
  802b7e:	00 00 00 
  802b81:	b8 00 00 00 00       	mov    $0x0,%eax
  802b86:	48 b9 bc 09 80 00 00 	movabs $0x8009bc,%rcx
  802b8d:	00 00 00 
  802b90:	ff d1                	callq  *%rcx
  802b92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802b97:	eb 2a                	jmp    802bc3 <ftruncate+0xca>
  802b99:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802b9d:	48 8b 40 30          	mov    0x30(%rax),%rax
  802ba1:	48 85 c0             	test   %rax,%rax
  802ba4:	75 07                	jne    802bad <ftruncate+0xb4>
  802ba6:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  802bab:	eb 16                	jmp    802bc3 <ftruncate+0xca>
  802bad:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802bb1:	48 8b 40 30          	mov    0x30(%rax),%rax
  802bb5:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  802bb9:	8b 4d d8             	mov    -0x28(%rbp),%ecx
  802bbc:	89 ce                	mov    %ecx,%esi
  802bbe:	48 89 d7             	mov    %rdx,%rdi
  802bc1:	ff d0                	callq  *%rax
  802bc3:	c9                   	leaveq 
  802bc4:	c3                   	retq   

0000000000802bc5 <fstat>:
  802bc5:	55                   	push   %rbp
  802bc6:	48 89 e5             	mov    %rsp,%rbp
  802bc9:	48 83 ec 30          	sub    $0x30,%rsp
  802bcd:	89 7d dc             	mov    %edi,-0x24(%rbp)
  802bd0:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  802bd4:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  802bd8:	8b 45 dc             	mov    -0x24(%rbp),%eax
  802bdb:	48 89 d6             	mov    %rdx,%rsi
  802bde:	89 c7                	mov    %eax,%edi
  802be0:	48 b8 64 24 80 00 00 	movabs $0x802464,%rax
  802be7:	00 00 00 
  802bea:	ff d0                	callq  *%rax
  802bec:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802bef:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802bf3:	78 24                	js     802c19 <fstat+0x54>
  802bf5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802bf9:	8b 00                	mov    (%rax),%eax
  802bfb:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  802bff:	48 89 d6             	mov    %rdx,%rsi
  802c02:	89 c7                	mov    %eax,%edi
  802c04:	48 b8 bd 25 80 00 00 	movabs $0x8025bd,%rax
  802c0b:	00 00 00 
  802c0e:	ff d0                	callq  *%rax
  802c10:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802c13:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802c17:	79 05                	jns    802c1e <fstat+0x59>
  802c19:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802c1c:	eb 5e                	jmp    802c7c <fstat+0xb7>
  802c1e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802c22:	48 8b 40 28          	mov    0x28(%rax),%rax
  802c26:	48 85 c0             	test   %rax,%rax
  802c29:	75 07                	jne    802c32 <fstat+0x6d>
  802c2b:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  802c30:	eb 4a                	jmp    802c7c <fstat+0xb7>
  802c32:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  802c36:	c6 00 00             	movb   $0x0,(%rax)
  802c39:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  802c3d:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%rax)
  802c44:	00 00 00 
  802c47:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  802c4b:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%rax)
  802c52:	00 00 00 
  802c55:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  802c59:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  802c5d:	48 89 90 88 00 00 00 	mov    %rdx,0x88(%rax)
  802c64:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802c68:	48 8b 40 28          	mov    0x28(%rax),%rax
  802c6c:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  802c70:	48 8b 4d d0          	mov    -0x30(%rbp),%rcx
  802c74:	48 89 ce             	mov    %rcx,%rsi
  802c77:	48 89 d7             	mov    %rdx,%rdi
  802c7a:	ff d0                	callq  *%rax
  802c7c:	c9                   	leaveq 
  802c7d:	c3                   	retq   

0000000000802c7e <stat>:
  802c7e:	55                   	push   %rbp
  802c7f:	48 89 e5             	mov    %rsp,%rbp
  802c82:	48 83 ec 20          	sub    $0x20,%rsp
  802c86:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  802c8a:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  802c8e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802c92:	be 00 00 00 00       	mov    $0x0,%esi
  802c97:	48 89 c7             	mov    %rax,%rdi
  802c9a:	48 b8 6c 2d 80 00 00 	movabs $0x802d6c,%rax
  802ca1:	00 00 00 
  802ca4:	ff d0                	callq  *%rax
  802ca6:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802ca9:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802cad:	79 05                	jns    802cb4 <stat+0x36>
  802caf:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802cb2:	eb 2f                	jmp    802ce3 <stat+0x65>
  802cb4:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  802cb8:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802cbb:	48 89 d6             	mov    %rdx,%rsi
  802cbe:	89 c7                	mov    %eax,%edi
  802cc0:	48 b8 c5 2b 80 00 00 	movabs $0x802bc5,%rax
  802cc7:	00 00 00 
  802cca:	ff d0                	callq  *%rax
  802ccc:	89 45 f8             	mov    %eax,-0x8(%rbp)
  802ccf:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802cd2:	89 c7                	mov    %eax,%edi
  802cd4:	48 b8 74 26 80 00 00 	movabs $0x802674,%rax
  802cdb:	00 00 00 
  802cde:	ff d0                	callq  *%rax
  802ce0:	8b 45 f8             	mov    -0x8(%rbp),%eax
  802ce3:	c9                   	leaveq 
  802ce4:	c3                   	retq   

0000000000802ce5 <fsipc>:
  802ce5:	55                   	push   %rbp
  802ce6:	48 89 e5             	mov    %rsp,%rbp
  802ce9:	48 83 ec 10          	sub    $0x10,%rsp
  802ced:	89 7d fc             	mov    %edi,-0x4(%rbp)
  802cf0:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  802cf4:	48 b8 00 70 80 00 00 	movabs $0x807000,%rax
  802cfb:	00 00 00 
  802cfe:	8b 00                	mov    (%rax),%eax
  802d00:	85 c0                	test   %eax,%eax
  802d02:	75 1d                	jne    802d21 <fsipc+0x3c>
  802d04:	bf 01 00 00 00       	mov    $0x1,%edi
  802d09:	48 b8 1d 46 80 00 00 	movabs $0x80461d,%rax
  802d10:	00 00 00 
  802d13:	ff d0                	callq  *%rax
  802d15:	48 ba 00 70 80 00 00 	movabs $0x807000,%rdx
  802d1c:	00 00 00 
  802d1f:	89 02                	mov    %eax,(%rdx)
  802d21:	48 b8 00 70 80 00 00 	movabs $0x807000,%rax
  802d28:	00 00 00 
  802d2b:	8b 00                	mov    (%rax),%eax
  802d2d:	8b 75 fc             	mov    -0x4(%rbp),%esi
  802d30:	b9 07 00 00 00       	mov    $0x7,%ecx
  802d35:	48 ba 00 80 80 00 00 	movabs $0x808000,%rdx
  802d3c:	00 00 00 
  802d3f:	89 c7                	mov    %eax,%edi
  802d41:	48 b8 87 45 80 00 00 	movabs $0x804587,%rax
  802d48:	00 00 00 
  802d4b:	ff d0                	callq  *%rax
  802d4d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802d51:	ba 00 00 00 00       	mov    $0x0,%edx
  802d56:	48 89 c6             	mov    %rax,%rsi
  802d59:	bf 00 00 00 00       	mov    $0x0,%edi
  802d5e:	48 b8 c6 44 80 00 00 	movabs $0x8044c6,%rax
  802d65:	00 00 00 
  802d68:	ff d0                	callq  *%rax
  802d6a:	c9                   	leaveq 
  802d6b:	c3                   	retq   

0000000000802d6c <open>:
  802d6c:	55                   	push   %rbp
  802d6d:	48 89 e5             	mov    %rsp,%rbp
  802d70:	48 83 ec 20          	sub    $0x20,%rsp
  802d74:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  802d78:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  802d7b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802d7f:	48 89 c7             	mov    %rax,%rdi
  802d82:	48 b8 05 15 80 00 00 	movabs $0x801505,%rax
  802d89:	00 00 00 
  802d8c:	ff d0                	callq  *%rax
  802d8e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802d93:	7e 0a                	jle    802d9f <open+0x33>
  802d95:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  802d9a:	e9 a5 00 00 00       	jmpq   802e44 <open+0xd8>
  802d9f:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
  802da3:	48 89 c7             	mov    %rax,%rdi
  802da6:	48 b8 cc 23 80 00 00 	movabs $0x8023cc,%rax
  802dad:	00 00 00 
  802db0:	ff d0                	callq  *%rax
  802db2:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802db5:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802db9:	79 08                	jns    802dc3 <open+0x57>
  802dbb:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802dbe:	e9 81 00 00 00       	jmpq   802e44 <open+0xd8>
  802dc3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802dc7:	48 89 c6             	mov    %rax,%rsi
  802dca:	48 bf 00 80 80 00 00 	movabs $0x808000,%rdi
  802dd1:	00 00 00 
  802dd4:	48 b8 71 15 80 00 00 	movabs $0x801571,%rax
  802ddb:	00 00 00 
  802dde:	ff d0                	callq  *%rax
  802de0:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802de7:	00 00 00 
  802dea:	8b 55 e4             	mov    -0x1c(%rbp),%edx
  802ded:	89 90 00 04 00 00    	mov    %edx,0x400(%rax)
  802df3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802df7:	48 89 c6             	mov    %rax,%rsi
  802dfa:	bf 01 00 00 00       	mov    $0x1,%edi
  802dff:	48 b8 e5 2c 80 00 00 	movabs $0x802ce5,%rax
  802e06:	00 00 00 
  802e09:	ff d0                	callq  *%rax
  802e0b:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802e0e:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802e12:	79 1d                	jns    802e31 <open+0xc5>
  802e14:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802e18:	be 00 00 00 00       	mov    $0x0,%esi
  802e1d:	48 89 c7             	mov    %rax,%rdi
  802e20:	48 b8 f4 24 80 00 00 	movabs $0x8024f4,%rax
  802e27:	00 00 00 
  802e2a:	ff d0                	callq  *%rax
  802e2c:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802e2f:	eb 13                	jmp    802e44 <open+0xd8>
  802e31:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802e35:	48 89 c7             	mov    %rax,%rdi
  802e38:	48 b8 7e 23 80 00 00 	movabs $0x80237e,%rax
  802e3f:	00 00 00 
  802e42:	ff d0                	callq  *%rax
  802e44:	c9                   	leaveq 
  802e45:	c3                   	retq   

0000000000802e46 <devfile_flush>:
  802e46:	55                   	push   %rbp
  802e47:	48 89 e5             	mov    %rsp,%rbp
  802e4a:	48 83 ec 10          	sub    $0x10,%rsp
  802e4e:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  802e52:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  802e56:	8b 50 0c             	mov    0xc(%rax),%edx
  802e59:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802e60:	00 00 00 
  802e63:	89 10                	mov    %edx,(%rax)
  802e65:	be 00 00 00 00       	mov    $0x0,%esi
  802e6a:	bf 06 00 00 00       	mov    $0x6,%edi
  802e6f:	48 b8 e5 2c 80 00 00 	movabs $0x802ce5,%rax
  802e76:	00 00 00 
  802e79:	ff d0                	callq  *%rax
  802e7b:	c9                   	leaveq 
  802e7c:	c3                   	retq   

0000000000802e7d <devfile_read>:
  802e7d:	55                   	push   %rbp
  802e7e:	48 89 e5             	mov    %rsp,%rbp
  802e81:	48 83 ec 30          	sub    $0x30,%rsp
  802e85:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  802e89:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  802e8d:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  802e91:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802e95:	8b 50 0c             	mov    0xc(%rax),%edx
  802e98:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802e9f:	00 00 00 
  802ea2:	89 10                	mov    %edx,(%rax)
  802ea4:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802eab:	00 00 00 
  802eae:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  802eb2:	48 89 50 08          	mov    %rdx,0x8(%rax)
  802eb6:	be 00 00 00 00       	mov    $0x0,%esi
  802ebb:	bf 03 00 00 00       	mov    $0x3,%edi
  802ec0:	48 b8 e5 2c 80 00 00 	movabs $0x802ce5,%rax
  802ec7:	00 00 00 
  802eca:	ff d0                	callq  *%rax
  802ecc:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802ecf:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802ed3:	79 08                	jns    802edd <devfile_read+0x60>
  802ed5:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802ed8:	e9 a4 00 00 00       	jmpq   802f81 <devfile_read+0x104>
  802edd:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802ee0:	48 98                	cltq   
  802ee2:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  802ee6:	76 35                	jbe    802f1d <devfile_read+0xa0>
  802ee8:	48 b9 56 4e 80 00 00 	movabs $0x804e56,%rcx
  802eef:	00 00 00 
  802ef2:	48 ba 5d 4e 80 00 00 	movabs $0x804e5d,%rdx
  802ef9:	00 00 00 
  802efc:	be 89 00 00 00       	mov    $0x89,%esi
  802f01:	48 bf 72 4e 80 00 00 	movabs $0x804e72,%rdi
  802f08:	00 00 00 
  802f0b:	b8 00 00 00 00       	mov    $0x0,%eax
  802f10:	49 b8 83 07 80 00 00 	movabs $0x800783,%r8
  802f17:	00 00 00 
  802f1a:	41 ff d0             	callq  *%r8
  802f1d:	81 7d fc 00 10 00 00 	cmpl   $0x1000,-0x4(%rbp)
  802f24:	7e 35                	jle    802f5b <devfile_read+0xde>
  802f26:	48 b9 80 4e 80 00 00 	movabs $0x804e80,%rcx
  802f2d:	00 00 00 
  802f30:	48 ba 5d 4e 80 00 00 	movabs $0x804e5d,%rdx
  802f37:	00 00 00 
  802f3a:	be 8a 00 00 00       	mov    $0x8a,%esi
  802f3f:	48 bf 72 4e 80 00 00 	movabs $0x804e72,%rdi
  802f46:	00 00 00 
  802f49:	b8 00 00 00 00       	mov    $0x0,%eax
  802f4e:	49 b8 83 07 80 00 00 	movabs $0x800783,%r8
  802f55:	00 00 00 
  802f58:	41 ff d0             	callq  *%r8
  802f5b:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802f5e:	48 63 d0             	movslq %eax,%rdx
  802f61:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  802f65:	48 be 00 80 80 00 00 	movabs $0x808000,%rsi
  802f6c:	00 00 00 
  802f6f:	48 89 c7             	mov    %rax,%rdi
  802f72:	48 b8 95 18 80 00 00 	movabs $0x801895,%rax
  802f79:	00 00 00 
  802f7c:	ff d0                	callq  *%rax
  802f7e:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802f81:	c9                   	leaveq 
  802f82:	c3                   	retq   

0000000000802f83 <devfile_write>:
  802f83:	55                   	push   %rbp
  802f84:	48 89 e5             	mov    %rsp,%rbp
  802f87:	48 83 ec 40          	sub    $0x40,%rsp
  802f8b:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  802f8f:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  802f93:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  802f97:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  802f9b:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  802f9f:	48 c7 45 f0 f4 0f 00 	movq   $0xff4,-0x10(%rbp)
  802fa6:	00 
  802fa7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802fab:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
  802faf:	48 0f 46 45 f8       	cmovbe -0x8(%rbp),%rax
  802fb4:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  802fb8:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  802fbc:	8b 50 0c             	mov    0xc(%rax),%edx
  802fbf:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802fc6:	00 00 00 
  802fc9:	89 10                	mov    %edx,(%rax)
  802fcb:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802fd2:	00 00 00 
  802fd5:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  802fd9:	48 89 50 08          	mov    %rdx,0x8(%rax)
  802fdd:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  802fe1:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  802fe5:	48 89 c6             	mov    %rax,%rsi
  802fe8:	48 bf 10 80 80 00 00 	movabs $0x808010,%rdi
  802fef:	00 00 00 
  802ff2:	48 b8 95 18 80 00 00 	movabs $0x801895,%rax
  802ff9:	00 00 00 
  802ffc:	ff d0                	callq  *%rax
  802ffe:	be 00 00 00 00       	mov    $0x0,%esi
  803003:	bf 04 00 00 00       	mov    $0x4,%edi
  803008:	48 b8 e5 2c 80 00 00 	movabs $0x802ce5,%rax
  80300f:	00 00 00 
  803012:	ff d0                	callq  *%rax
  803014:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803017:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  80301b:	79 05                	jns    803022 <devfile_write+0x9f>
  80301d:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803020:	eb 43                	jmp    803065 <devfile_write+0xe2>
  803022:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803025:	48 98                	cltq   
  803027:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  80302b:	76 35                	jbe    803062 <devfile_write+0xdf>
  80302d:	48 b9 56 4e 80 00 00 	movabs $0x804e56,%rcx
  803034:	00 00 00 
  803037:	48 ba 5d 4e 80 00 00 	movabs $0x804e5d,%rdx
  80303e:	00 00 00 
  803041:	be a8 00 00 00       	mov    $0xa8,%esi
  803046:	48 bf 72 4e 80 00 00 	movabs $0x804e72,%rdi
  80304d:	00 00 00 
  803050:	b8 00 00 00 00       	mov    $0x0,%eax
  803055:	49 b8 83 07 80 00 00 	movabs $0x800783,%r8
  80305c:	00 00 00 
  80305f:	41 ff d0             	callq  *%r8
  803062:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803065:	c9                   	leaveq 
  803066:	c3                   	retq   

0000000000803067 <devfile_stat>:
  803067:	55                   	push   %rbp
  803068:	48 89 e5             	mov    %rsp,%rbp
  80306b:	48 83 ec 20          	sub    $0x20,%rsp
  80306f:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  803073:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  803077:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80307b:	8b 50 0c             	mov    0xc(%rax),%edx
  80307e:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  803085:	00 00 00 
  803088:	89 10                	mov    %edx,(%rax)
  80308a:	be 00 00 00 00       	mov    $0x0,%esi
  80308f:	bf 05 00 00 00       	mov    $0x5,%edi
  803094:	48 b8 e5 2c 80 00 00 	movabs $0x802ce5,%rax
  80309b:	00 00 00 
  80309e:	ff d0                	callq  *%rax
  8030a0:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8030a3:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8030a7:	79 05                	jns    8030ae <devfile_stat+0x47>
  8030a9:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8030ac:	eb 56                	jmp    803104 <devfile_stat+0x9d>
  8030ae:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8030b2:	48 be 00 80 80 00 00 	movabs $0x808000,%rsi
  8030b9:	00 00 00 
  8030bc:	48 89 c7             	mov    %rax,%rdi
  8030bf:	48 b8 71 15 80 00 00 	movabs $0x801571,%rax
  8030c6:	00 00 00 
  8030c9:	ff d0                	callq  *%rax
  8030cb:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  8030d2:	00 00 00 
  8030d5:	8b 90 80 00 00 00    	mov    0x80(%rax),%edx
  8030db:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8030df:	89 90 80 00 00 00    	mov    %edx,0x80(%rax)
  8030e5:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  8030ec:	00 00 00 
  8030ef:	8b 90 84 00 00 00    	mov    0x84(%rax),%edx
  8030f5:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8030f9:	89 90 84 00 00 00    	mov    %edx,0x84(%rax)
  8030ff:	b8 00 00 00 00       	mov    $0x0,%eax
  803104:	c9                   	leaveq 
  803105:	c3                   	retq   

0000000000803106 <devfile_trunc>:
  803106:	55                   	push   %rbp
  803107:	48 89 e5             	mov    %rsp,%rbp
  80310a:	48 83 ec 10          	sub    $0x10,%rsp
  80310e:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  803112:	89 75 f4             	mov    %esi,-0xc(%rbp)
  803115:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803119:	8b 50 0c             	mov    0xc(%rax),%edx
  80311c:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  803123:	00 00 00 
  803126:	89 10                	mov    %edx,(%rax)
  803128:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  80312f:	00 00 00 
  803132:	8b 55 f4             	mov    -0xc(%rbp),%edx
  803135:	89 50 04             	mov    %edx,0x4(%rax)
  803138:	be 00 00 00 00       	mov    $0x0,%esi
  80313d:	bf 02 00 00 00       	mov    $0x2,%edi
  803142:	48 b8 e5 2c 80 00 00 	movabs $0x802ce5,%rax
  803149:	00 00 00 
  80314c:	ff d0                	callq  *%rax
  80314e:	c9                   	leaveq 
  80314f:	c3                   	retq   

0000000000803150 <remove>:
  803150:	55                   	push   %rbp
  803151:	48 89 e5             	mov    %rsp,%rbp
  803154:	48 83 ec 10          	sub    $0x10,%rsp
  803158:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  80315c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803160:	48 89 c7             	mov    %rax,%rdi
  803163:	48 b8 05 15 80 00 00 	movabs $0x801505,%rax
  80316a:	00 00 00 
  80316d:	ff d0                	callq  *%rax
  80316f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  803174:	7e 07                	jle    80317d <remove+0x2d>
  803176:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  80317b:	eb 33                	jmp    8031b0 <remove+0x60>
  80317d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803181:	48 89 c6             	mov    %rax,%rsi
  803184:	48 bf 00 80 80 00 00 	movabs $0x808000,%rdi
  80318b:	00 00 00 
  80318e:	48 b8 71 15 80 00 00 	movabs $0x801571,%rax
  803195:	00 00 00 
  803198:	ff d0                	callq  *%rax
  80319a:	be 00 00 00 00       	mov    $0x0,%esi
  80319f:	bf 07 00 00 00       	mov    $0x7,%edi
  8031a4:	48 b8 e5 2c 80 00 00 	movabs $0x802ce5,%rax
  8031ab:	00 00 00 
  8031ae:	ff d0                	callq  *%rax
  8031b0:	c9                   	leaveq 
  8031b1:	c3                   	retq   

00000000008031b2 <sync>:
  8031b2:	55                   	push   %rbp
  8031b3:	48 89 e5             	mov    %rsp,%rbp
  8031b6:	be 00 00 00 00       	mov    $0x0,%esi
  8031bb:	bf 08 00 00 00       	mov    $0x8,%edi
  8031c0:	48 b8 e5 2c 80 00 00 	movabs $0x802ce5,%rax
  8031c7:	00 00 00 
  8031ca:	ff d0                	callq  *%rax
  8031cc:	5d                   	pop    %rbp
  8031cd:	c3                   	retq   

00000000008031ce <copy>:
  8031ce:	55                   	push   %rbp
  8031cf:	48 89 e5             	mov    %rsp,%rbp
  8031d2:	48 81 ec 20 02 00 00 	sub    $0x220,%rsp
  8031d9:	48 89 bd e8 fd ff ff 	mov    %rdi,-0x218(%rbp)
  8031e0:	48 89 b5 e0 fd ff ff 	mov    %rsi,-0x220(%rbp)
  8031e7:	48 8b 85 e8 fd ff ff 	mov    -0x218(%rbp),%rax
  8031ee:	be 00 00 00 00       	mov    $0x0,%esi
  8031f3:	48 89 c7             	mov    %rax,%rdi
  8031f6:	48 b8 6c 2d 80 00 00 	movabs $0x802d6c,%rax
  8031fd:	00 00 00 
  803200:	ff d0                	callq  *%rax
  803202:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803205:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803209:	79 28                	jns    803233 <copy+0x65>
  80320b:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80320e:	89 c6                	mov    %eax,%esi
  803210:	48 bf 8c 4e 80 00 00 	movabs $0x804e8c,%rdi
  803217:	00 00 00 
  80321a:	b8 00 00 00 00       	mov    $0x0,%eax
  80321f:	48 ba bc 09 80 00 00 	movabs $0x8009bc,%rdx
  803226:	00 00 00 
  803229:	ff d2                	callq  *%rdx
  80322b:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80322e:	e9 74 01 00 00       	jmpq   8033a7 <copy+0x1d9>
  803233:	48 8b 85 e0 fd ff ff 	mov    -0x220(%rbp),%rax
  80323a:	be 01 01 00 00       	mov    $0x101,%esi
  80323f:	48 89 c7             	mov    %rax,%rdi
  803242:	48 b8 6c 2d 80 00 00 	movabs $0x802d6c,%rax
  803249:	00 00 00 
  80324c:	ff d0                	callq  *%rax
  80324e:	89 45 f8             	mov    %eax,-0x8(%rbp)
  803251:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  803255:	79 39                	jns    803290 <copy+0xc2>
  803257:	8b 45 f8             	mov    -0x8(%rbp),%eax
  80325a:	89 c6                	mov    %eax,%esi
  80325c:	48 bf a2 4e 80 00 00 	movabs $0x804ea2,%rdi
  803263:	00 00 00 
  803266:	b8 00 00 00 00       	mov    $0x0,%eax
  80326b:	48 ba bc 09 80 00 00 	movabs $0x8009bc,%rdx
  803272:	00 00 00 
  803275:	ff d2                	callq  *%rdx
  803277:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80327a:	89 c7                	mov    %eax,%edi
  80327c:	48 b8 74 26 80 00 00 	movabs $0x802674,%rax
  803283:	00 00 00 
  803286:	ff d0                	callq  *%rax
  803288:	8b 45 f8             	mov    -0x8(%rbp),%eax
  80328b:	e9 17 01 00 00       	jmpq   8033a7 <copy+0x1d9>
  803290:	eb 74                	jmp    803306 <copy+0x138>
  803292:	8b 45 f4             	mov    -0xc(%rbp),%eax
  803295:	48 63 d0             	movslq %eax,%rdx
  803298:	48 8d 8d f0 fd ff ff 	lea    -0x210(%rbp),%rcx
  80329f:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8032a2:	48 89 ce             	mov    %rcx,%rsi
  8032a5:	89 c7                	mov    %eax,%edi
  8032a7:	48 b8 e0 29 80 00 00 	movabs $0x8029e0,%rax
  8032ae:	00 00 00 
  8032b1:	ff d0                	callq  *%rax
  8032b3:	89 45 f0             	mov    %eax,-0x10(%rbp)
  8032b6:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
  8032ba:	79 4a                	jns    803306 <copy+0x138>
  8032bc:	8b 45 f0             	mov    -0x10(%rbp),%eax
  8032bf:	89 c6                	mov    %eax,%esi
  8032c1:	48 bf bc 4e 80 00 00 	movabs $0x804ebc,%rdi
  8032c8:	00 00 00 
  8032cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8032d0:	48 ba bc 09 80 00 00 	movabs $0x8009bc,%rdx
  8032d7:	00 00 00 
  8032da:	ff d2                	callq  *%rdx
  8032dc:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8032df:	89 c7                	mov    %eax,%edi
  8032e1:	48 b8 74 26 80 00 00 	movabs $0x802674,%rax
  8032e8:	00 00 00 
  8032eb:	ff d0                	callq  *%rax
  8032ed:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8032f0:	89 c7                	mov    %eax,%edi
  8032f2:	48 b8 74 26 80 00 00 	movabs $0x802674,%rax
  8032f9:	00 00 00 
  8032fc:	ff d0                	callq  *%rax
  8032fe:	8b 45 f0             	mov    -0x10(%rbp),%eax
  803301:	e9 a1 00 00 00       	jmpq   8033a7 <copy+0x1d9>
  803306:	48 8d 8d f0 fd ff ff 	lea    -0x210(%rbp),%rcx
  80330d:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803310:	ba 00 02 00 00       	mov    $0x200,%edx
  803315:	48 89 ce             	mov    %rcx,%rsi
  803318:	89 c7                	mov    %eax,%edi
  80331a:	48 b8 96 28 80 00 00 	movabs $0x802896,%rax
  803321:	00 00 00 
  803324:	ff d0                	callq  *%rax
  803326:	89 45 f4             	mov    %eax,-0xc(%rbp)
  803329:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
  80332d:	0f 8f 5f ff ff ff    	jg     803292 <copy+0xc4>
  803333:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
  803337:	79 47                	jns    803380 <copy+0x1b2>
  803339:	8b 45 f4             	mov    -0xc(%rbp),%eax
  80333c:	89 c6                	mov    %eax,%esi
  80333e:	48 bf cf 4e 80 00 00 	movabs $0x804ecf,%rdi
  803345:	00 00 00 
  803348:	b8 00 00 00 00       	mov    $0x0,%eax
  80334d:	48 ba bc 09 80 00 00 	movabs $0x8009bc,%rdx
  803354:	00 00 00 
  803357:	ff d2                	callq  *%rdx
  803359:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80335c:	89 c7                	mov    %eax,%edi
  80335e:	48 b8 74 26 80 00 00 	movabs $0x802674,%rax
  803365:	00 00 00 
  803368:	ff d0                	callq  *%rax
  80336a:	8b 45 f8             	mov    -0x8(%rbp),%eax
  80336d:	89 c7                	mov    %eax,%edi
  80336f:	48 b8 74 26 80 00 00 	movabs $0x802674,%rax
  803376:	00 00 00 
  803379:	ff d0                	callq  *%rax
  80337b:	8b 45 f4             	mov    -0xc(%rbp),%eax
  80337e:	eb 27                	jmp    8033a7 <copy+0x1d9>
  803380:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803383:	89 c7                	mov    %eax,%edi
  803385:	48 b8 74 26 80 00 00 	movabs $0x802674,%rax
  80338c:	00 00 00 
  80338f:	ff d0                	callq  *%rax
  803391:	8b 45 f8             	mov    -0x8(%rbp),%eax
  803394:	89 c7                	mov    %eax,%edi
  803396:	48 b8 74 26 80 00 00 	movabs $0x802674,%rax
  80339d:	00 00 00 
  8033a0:	ff d0                	callq  *%rax
  8033a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8033a7:	c9                   	leaveq 
  8033a8:	c3                   	retq   

00000000008033a9 <fd2sockid>:
  8033a9:	55                   	push   %rbp
  8033aa:	48 89 e5             	mov    %rsp,%rbp
  8033ad:	48 83 ec 20          	sub    $0x20,%rsp
  8033b1:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8033b4:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  8033b8:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8033bb:	48 89 d6             	mov    %rdx,%rsi
  8033be:	89 c7                	mov    %eax,%edi
  8033c0:	48 b8 64 24 80 00 00 	movabs $0x802464,%rax
  8033c7:	00 00 00 
  8033ca:	ff d0                	callq  *%rax
  8033cc:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8033cf:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8033d3:	79 05                	jns    8033da <fd2sockid+0x31>
  8033d5:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8033d8:	eb 24                	jmp    8033fe <fd2sockid+0x55>
  8033da:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8033de:	8b 10                	mov    (%rax),%edx
  8033e0:	48 b8 a0 60 80 00 00 	movabs $0x8060a0,%rax
  8033e7:	00 00 00 
  8033ea:	8b 00                	mov    (%rax),%eax
  8033ec:	39 c2                	cmp    %eax,%edx
  8033ee:	74 07                	je     8033f7 <fd2sockid+0x4e>
  8033f0:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  8033f5:	eb 07                	jmp    8033fe <fd2sockid+0x55>
  8033f7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8033fb:	8b 40 0c             	mov    0xc(%rax),%eax
  8033fe:	c9                   	leaveq 
  8033ff:	c3                   	retq   

0000000000803400 <alloc_sockfd>:
  803400:	55                   	push   %rbp
  803401:	48 89 e5             	mov    %rsp,%rbp
  803404:	48 83 ec 20          	sub    $0x20,%rsp
  803408:	89 7d ec             	mov    %edi,-0x14(%rbp)
  80340b:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
  80340f:	48 89 c7             	mov    %rax,%rdi
  803412:	48 b8 cc 23 80 00 00 	movabs $0x8023cc,%rax
  803419:	00 00 00 
  80341c:	ff d0                	callq  *%rax
  80341e:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803421:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803425:	78 26                	js     80344d <alloc_sockfd+0x4d>
  803427:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80342b:	ba 07 04 00 00       	mov    $0x407,%edx
  803430:	48 89 c6             	mov    %rax,%rsi
  803433:	bf 00 00 00 00       	mov    $0x0,%edi
  803438:	48 b8 a0 1e 80 00 00 	movabs $0x801ea0,%rax
  80343f:	00 00 00 
  803442:	ff d0                	callq  *%rax
  803444:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803447:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80344b:	79 16                	jns    803463 <alloc_sockfd+0x63>
  80344d:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803450:	89 c7                	mov    %eax,%edi
  803452:	48 b8 0d 39 80 00 00 	movabs $0x80390d,%rax
  803459:	00 00 00 
  80345c:	ff d0                	callq  *%rax
  80345e:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803461:	eb 3a                	jmp    80349d <alloc_sockfd+0x9d>
  803463:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803467:	48 ba a0 60 80 00 00 	movabs $0x8060a0,%rdx
  80346e:	00 00 00 
  803471:	8b 12                	mov    (%rdx),%edx
  803473:	89 10                	mov    %edx,(%rax)
  803475:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803479:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%rax)
  803480:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803484:	8b 55 ec             	mov    -0x14(%rbp),%edx
  803487:	89 50 0c             	mov    %edx,0xc(%rax)
  80348a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80348e:	48 89 c7             	mov    %rax,%rdi
  803491:	48 b8 7e 23 80 00 00 	movabs $0x80237e,%rax
  803498:	00 00 00 
  80349b:	ff d0                	callq  *%rax
  80349d:	c9                   	leaveq 
  80349e:	c3                   	retq   

000000000080349f <accept>:
  80349f:	55                   	push   %rbp
  8034a0:	48 89 e5             	mov    %rsp,%rbp
  8034a3:	48 83 ec 30          	sub    $0x30,%rsp
  8034a7:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8034aa:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8034ae:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  8034b2:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8034b5:	89 c7                	mov    %eax,%edi
  8034b7:	48 b8 a9 33 80 00 00 	movabs $0x8033a9,%rax
  8034be:	00 00 00 
  8034c1:	ff d0                	callq  *%rax
  8034c3:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8034c6:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8034ca:	79 05                	jns    8034d1 <accept+0x32>
  8034cc:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8034cf:	eb 3b                	jmp    80350c <accept+0x6d>
  8034d1:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  8034d5:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  8034d9:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8034dc:	48 89 ce             	mov    %rcx,%rsi
  8034df:	89 c7                	mov    %eax,%edi
  8034e1:	48 b8 ea 37 80 00 00 	movabs $0x8037ea,%rax
  8034e8:	00 00 00 
  8034eb:	ff d0                	callq  *%rax
  8034ed:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8034f0:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8034f4:	79 05                	jns    8034fb <accept+0x5c>
  8034f6:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8034f9:	eb 11                	jmp    80350c <accept+0x6d>
  8034fb:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8034fe:	89 c7                	mov    %eax,%edi
  803500:	48 b8 00 34 80 00 00 	movabs $0x803400,%rax
  803507:	00 00 00 
  80350a:	ff d0                	callq  *%rax
  80350c:	c9                   	leaveq 
  80350d:	c3                   	retq   

000000000080350e <bind>:
  80350e:	55                   	push   %rbp
  80350f:	48 89 e5             	mov    %rsp,%rbp
  803512:	48 83 ec 20          	sub    $0x20,%rsp
  803516:	89 7d ec             	mov    %edi,-0x14(%rbp)
  803519:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  80351d:	89 55 e8             	mov    %edx,-0x18(%rbp)
  803520:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803523:	89 c7                	mov    %eax,%edi
  803525:	48 b8 a9 33 80 00 00 	movabs $0x8033a9,%rax
  80352c:	00 00 00 
  80352f:	ff d0                	callq  *%rax
  803531:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803534:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803538:	79 05                	jns    80353f <bind+0x31>
  80353a:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80353d:	eb 1b                	jmp    80355a <bind+0x4c>
  80353f:	8b 55 e8             	mov    -0x18(%rbp),%edx
  803542:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  803546:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803549:	48 89 ce             	mov    %rcx,%rsi
  80354c:	89 c7                	mov    %eax,%edi
  80354e:	48 b8 69 38 80 00 00 	movabs $0x803869,%rax
  803555:	00 00 00 
  803558:	ff d0                	callq  *%rax
  80355a:	c9                   	leaveq 
  80355b:	c3                   	retq   

000000000080355c <shutdown>:
  80355c:	55                   	push   %rbp
  80355d:	48 89 e5             	mov    %rsp,%rbp
  803560:	48 83 ec 20          	sub    $0x20,%rsp
  803564:	89 7d ec             	mov    %edi,-0x14(%rbp)
  803567:	89 75 e8             	mov    %esi,-0x18(%rbp)
  80356a:	8b 45 ec             	mov    -0x14(%rbp),%eax
  80356d:	89 c7                	mov    %eax,%edi
  80356f:	48 b8 a9 33 80 00 00 	movabs $0x8033a9,%rax
  803576:	00 00 00 
  803579:	ff d0                	callq  *%rax
  80357b:	89 45 fc             	mov    %eax,-0x4(%rbp)
  80357e:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803582:	79 05                	jns    803589 <shutdown+0x2d>
  803584:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803587:	eb 16                	jmp    80359f <shutdown+0x43>
  803589:	8b 55 e8             	mov    -0x18(%rbp),%edx
  80358c:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80358f:	89 d6                	mov    %edx,%esi
  803591:	89 c7                	mov    %eax,%edi
  803593:	48 b8 cd 38 80 00 00 	movabs $0x8038cd,%rax
  80359a:	00 00 00 
  80359d:	ff d0                	callq  *%rax
  80359f:	c9                   	leaveq 
  8035a0:	c3                   	retq   

00000000008035a1 <devsock_close>:
  8035a1:	55                   	push   %rbp
  8035a2:	48 89 e5             	mov    %rsp,%rbp
  8035a5:	48 83 ec 10          	sub    $0x10,%rsp
  8035a9:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8035ad:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8035b1:	48 89 c7             	mov    %rax,%rdi
  8035b4:	48 b8 8f 46 80 00 00 	movabs $0x80468f,%rax
  8035bb:	00 00 00 
  8035be:	ff d0                	callq  *%rax
  8035c0:	83 f8 01             	cmp    $0x1,%eax
  8035c3:	75 17                	jne    8035dc <devsock_close+0x3b>
  8035c5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8035c9:	8b 40 0c             	mov    0xc(%rax),%eax
  8035cc:	89 c7                	mov    %eax,%edi
  8035ce:	48 b8 0d 39 80 00 00 	movabs $0x80390d,%rax
  8035d5:	00 00 00 
  8035d8:	ff d0                	callq  *%rax
  8035da:	eb 05                	jmp    8035e1 <devsock_close+0x40>
  8035dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8035e1:	c9                   	leaveq 
  8035e2:	c3                   	retq   

00000000008035e3 <connect>:
  8035e3:	55                   	push   %rbp
  8035e4:	48 89 e5             	mov    %rsp,%rbp
  8035e7:	48 83 ec 20          	sub    $0x20,%rsp
  8035eb:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8035ee:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8035f2:	89 55 e8             	mov    %edx,-0x18(%rbp)
  8035f5:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8035f8:	89 c7                	mov    %eax,%edi
  8035fa:	48 b8 a9 33 80 00 00 	movabs $0x8033a9,%rax
  803601:	00 00 00 
  803604:	ff d0                	callq  *%rax
  803606:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803609:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80360d:	79 05                	jns    803614 <connect+0x31>
  80360f:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803612:	eb 1b                	jmp    80362f <connect+0x4c>
  803614:	8b 55 e8             	mov    -0x18(%rbp),%edx
  803617:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  80361b:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80361e:	48 89 ce             	mov    %rcx,%rsi
  803621:	89 c7                	mov    %eax,%edi
  803623:	48 b8 3a 39 80 00 00 	movabs $0x80393a,%rax
  80362a:	00 00 00 
  80362d:	ff d0                	callq  *%rax
  80362f:	c9                   	leaveq 
  803630:	c3                   	retq   

0000000000803631 <listen>:
  803631:	55                   	push   %rbp
  803632:	48 89 e5             	mov    %rsp,%rbp
  803635:	48 83 ec 20          	sub    $0x20,%rsp
  803639:	89 7d ec             	mov    %edi,-0x14(%rbp)
  80363c:	89 75 e8             	mov    %esi,-0x18(%rbp)
  80363f:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803642:	89 c7                	mov    %eax,%edi
  803644:	48 b8 a9 33 80 00 00 	movabs $0x8033a9,%rax
  80364b:	00 00 00 
  80364e:	ff d0                	callq  *%rax
  803650:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803653:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803657:	79 05                	jns    80365e <listen+0x2d>
  803659:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80365c:	eb 16                	jmp    803674 <listen+0x43>
  80365e:	8b 55 e8             	mov    -0x18(%rbp),%edx
  803661:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803664:	89 d6                	mov    %edx,%esi
  803666:	89 c7                	mov    %eax,%edi
  803668:	48 b8 9e 39 80 00 00 	movabs $0x80399e,%rax
  80366f:	00 00 00 
  803672:	ff d0                	callq  *%rax
  803674:	c9                   	leaveq 
  803675:	c3                   	retq   

0000000000803676 <devsock_read>:
  803676:	55                   	push   %rbp
  803677:	48 89 e5             	mov    %rsp,%rbp
  80367a:	48 83 ec 20          	sub    $0x20,%rsp
  80367e:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  803682:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  803686:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  80368a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80368e:	89 c2                	mov    %eax,%edx
  803690:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803694:	8b 40 0c             	mov    0xc(%rax),%eax
  803697:	48 8b 75 f0          	mov    -0x10(%rbp),%rsi
  80369b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8036a0:	89 c7                	mov    %eax,%edi
  8036a2:	48 b8 de 39 80 00 00 	movabs $0x8039de,%rax
  8036a9:	00 00 00 
  8036ac:	ff d0                	callq  *%rax
  8036ae:	c9                   	leaveq 
  8036af:	c3                   	retq   

00000000008036b0 <devsock_write>:
  8036b0:	55                   	push   %rbp
  8036b1:	48 89 e5             	mov    %rsp,%rbp
  8036b4:	48 83 ec 20          	sub    $0x20,%rsp
  8036b8:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8036bc:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8036c0:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8036c4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8036c8:	89 c2                	mov    %eax,%edx
  8036ca:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8036ce:	8b 40 0c             	mov    0xc(%rax),%eax
  8036d1:	48 8b 75 f0          	mov    -0x10(%rbp),%rsi
  8036d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8036da:	89 c7                	mov    %eax,%edi
  8036dc:	48 b8 aa 3a 80 00 00 	movabs $0x803aaa,%rax
  8036e3:	00 00 00 
  8036e6:	ff d0                	callq  *%rax
  8036e8:	c9                   	leaveq 
  8036e9:	c3                   	retq   

00000000008036ea <devsock_stat>:
  8036ea:	55                   	push   %rbp
  8036eb:	48 89 e5             	mov    %rsp,%rbp
  8036ee:	48 83 ec 10          	sub    $0x10,%rsp
  8036f2:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8036f6:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8036fa:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8036fe:	48 be ea 4e 80 00 00 	movabs $0x804eea,%rsi
  803705:	00 00 00 
  803708:	48 89 c7             	mov    %rax,%rdi
  80370b:	48 b8 71 15 80 00 00 	movabs $0x801571,%rax
  803712:	00 00 00 
  803715:	ff d0                	callq  *%rax
  803717:	b8 00 00 00 00       	mov    $0x0,%eax
  80371c:	c9                   	leaveq 
  80371d:	c3                   	retq   

000000000080371e <socket>:
  80371e:	55                   	push   %rbp
  80371f:	48 89 e5             	mov    %rsp,%rbp
  803722:	48 83 ec 20          	sub    $0x20,%rsp
  803726:	89 7d ec             	mov    %edi,-0x14(%rbp)
  803729:	89 75 e8             	mov    %esi,-0x18(%rbp)
  80372c:	89 55 e4             	mov    %edx,-0x1c(%rbp)
  80372f:	8b 55 e4             	mov    -0x1c(%rbp),%edx
  803732:	8b 4d e8             	mov    -0x18(%rbp),%ecx
  803735:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803738:	89 ce                	mov    %ecx,%esi
  80373a:	89 c7                	mov    %eax,%edi
  80373c:	48 b8 62 3b 80 00 00 	movabs $0x803b62,%rax
  803743:	00 00 00 
  803746:	ff d0                	callq  *%rax
  803748:	89 45 fc             	mov    %eax,-0x4(%rbp)
  80374b:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80374f:	79 05                	jns    803756 <socket+0x38>
  803751:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803754:	eb 11                	jmp    803767 <socket+0x49>
  803756:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803759:	89 c7                	mov    %eax,%edi
  80375b:	48 b8 00 34 80 00 00 	movabs $0x803400,%rax
  803762:	00 00 00 
  803765:	ff d0                	callq  *%rax
  803767:	c9                   	leaveq 
  803768:	c3                   	retq   

0000000000803769 <nsipc>:
  803769:	55                   	push   %rbp
  80376a:	48 89 e5             	mov    %rsp,%rbp
  80376d:	48 83 ec 10          	sub    $0x10,%rsp
  803771:	89 7d fc             	mov    %edi,-0x4(%rbp)
  803774:	48 b8 04 70 80 00 00 	movabs $0x807004,%rax
  80377b:	00 00 00 
  80377e:	8b 00                	mov    (%rax),%eax
  803780:	85 c0                	test   %eax,%eax
  803782:	75 1d                	jne    8037a1 <nsipc+0x38>
  803784:	bf 02 00 00 00       	mov    $0x2,%edi
  803789:	48 b8 1d 46 80 00 00 	movabs $0x80461d,%rax
  803790:	00 00 00 
  803793:	ff d0                	callq  *%rax
  803795:	48 ba 04 70 80 00 00 	movabs $0x807004,%rdx
  80379c:	00 00 00 
  80379f:	89 02                	mov    %eax,(%rdx)
  8037a1:	48 b8 04 70 80 00 00 	movabs $0x807004,%rax
  8037a8:	00 00 00 
  8037ab:	8b 00                	mov    (%rax),%eax
  8037ad:	8b 75 fc             	mov    -0x4(%rbp),%esi
  8037b0:	b9 07 00 00 00       	mov    $0x7,%ecx
  8037b5:	48 ba 00 a0 80 00 00 	movabs $0x80a000,%rdx
  8037bc:	00 00 00 
  8037bf:	89 c7                	mov    %eax,%edi
  8037c1:	48 b8 87 45 80 00 00 	movabs $0x804587,%rax
  8037c8:	00 00 00 
  8037cb:	ff d0                	callq  *%rax
  8037cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8037d2:	be 00 00 00 00       	mov    $0x0,%esi
  8037d7:	bf 00 00 00 00       	mov    $0x0,%edi
  8037dc:	48 b8 c6 44 80 00 00 	movabs $0x8044c6,%rax
  8037e3:	00 00 00 
  8037e6:	ff d0                	callq  *%rax
  8037e8:	c9                   	leaveq 
  8037e9:	c3                   	retq   

00000000008037ea <nsipc_accept>:
  8037ea:	55                   	push   %rbp
  8037eb:	48 89 e5             	mov    %rsp,%rbp
  8037ee:	48 83 ec 30          	sub    $0x30,%rsp
  8037f2:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8037f5:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8037f9:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  8037fd:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803804:	00 00 00 
  803807:	8b 55 ec             	mov    -0x14(%rbp),%edx
  80380a:	89 10                	mov    %edx,(%rax)
  80380c:	bf 01 00 00 00       	mov    $0x1,%edi
  803811:	48 b8 69 37 80 00 00 	movabs $0x803769,%rax
  803818:	00 00 00 
  80381b:	ff d0                	callq  *%rax
  80381d:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803820:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803824:	78 3e                	js     803864 <nsipc_accept+0x7a>
  803826:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  80382d:	00 00 00 
  803830:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  803834:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803838:	8b 40 10             	mov    0x10(%rax),%eax
  80383b:	89 c2                	mov    %eax,%edx
  80383d:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  803841:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803845:	48 89 ce             	mov    %rcx,%rsi
  803848:	48 89 c7             	mov    %rax,%rdi
  80384b:	48 b8 95 18 80 00 00 	movabs $0x801895,%rax
  803852:	00 00 00 
  803855:	ff d0                	callq  *%rax
  803857:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80385b:	8b 50 10             	mov    0x10(%rax),%edx
  80385e:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803862:	89 10                	mov    %edx,(%rax)
  803864:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803867:	c9                   	leaveq 
  803868:	c3                   	retq   

0000000000803869 <nsipc_bind>:
  803869:	55                   	push   %rbp
  80386a:	48 89 e5             	mov    %rsp,%rbp
  80386d:	48 83 ec 10          	sub    $0x10,%rsp
  803871:	89 7d fc             	mov    %edi,-0x4(%rbp)
  803874:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  803878:	89 55 f8             	mov    %edx,-0x8(%rbp)
  80387b:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803882:	00 00 00 
  803885:	8b 55 fc             	mov    -0x4(%rbp),%edx
  803888:	89 10                	mov    %edx,(%rax)
  80388a:	8b 55 f8             	mov    -0x8(%rbp),%edx
  80388d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803891:	48 89 c6             	mov    %rax,%rsi
  803894:	48 bf 04 a0 80 00 00 	movabs $0x80a004,%rdi
  80389b:	00 00 00 
  80389e:	48 b8 95 18 80 00 00 	movabs $0x801895,%rax
  8038a5:	00 00 00 
  8038a8:	ff d0                	callq  *%rax
  8038aa:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  8038b1:	00 00 00 
  8038b4:	8b 55 f8             	mov    -0x8(%rbp),%edx
  8038b7:	89 50 14             	mov    %edx,0x14(%rax)
  8038ba:	bf 02 00 00 00       	mov    $0x2,%edi
  8038bf:	48 b8 69 37 80 00 00 	movabs $0x803769,%rax
  8038c6:	00 00 00 
  8038c9:	ff d0                	callq  *%rax
  8038cb:	c9                   	leaveq 
  8038cc:	c3                   	retq   

00000000008038cd <nsipc_shutdown>:
  8038cd:	55                   	push   %rbp
  8038ce:	48 89 e5             	mov    %rsp,%rbp
  8038d1:	48 83 ec 10          	sub    $0x10,%rsp
  8038d5:	89 7d fc             	mov    %edi,-0x4(%rbp)
  8038d8:	89 75 f8             	mov    %esi,-0x8(%rbp)
  8038db:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  8038e2:	00 00 00 
  8038e5:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8038e8:	89 10                	mov    %edx,(%rax)
  8038ea:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  8038f1:	00 00 00 
  8038f4:	8b 55 f8             	mov    -0x8(%rbp),%edx
  8038f7:	89 50 04             	mov    %edx,0x4(%rax)
  8038fa:	bf 03 00 00 00       	mov    $0x3,%edi
  8038ff:	48 b8 69 37 80 00 00 	movabs $0x803769,%rax
  803906:	00 00 00 
  803909:	ff d0                	callq  *%rax
  80390b:	c9                   	leaveq 
  80390c:	c3                   	retq   

000000000080390d <nsipc_close>:
  80390d:	55                   	push   %rbp
  80390e:	48 89 e5             	mov    %rsp,%rbp
  803911:	48 83 ec 10          	sub    $0x10,%rsp
  803915:	89 7d fc             	mov    %edi,-0x4(%rbp)
  803918:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  80391f:	00 00 00 
  803922:	8b 55 fc             	mov    -0x4(%rbp),%edx
  803925:	89 10                	mov    %edx,(%rax)
  803927:	bf 04 00 00 00       	mov    $0x4,%edi
  80392c:	48 b8 69 37 80 00 00 	movabs $0x803769,%rax
  803933:	00 00 00 
  803936:	ff d0                	callq  *%rax
  803938:	c9                   	leaveq 
  803939:	c3                   	retq   

000000000080393a <nsipc_connect>:
  80393a:	55                   	push   %rbp
  80393b:	48 89 e5             	mov    %rsp,%rbp
  80393e:	48 83 ec 10          	sub    $0x10,%rsp
  803942:	89 7d fc             	mov    %edi,-0x4(%rbp)
  803945:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  803949:	89 55 f8             	mov    %edx,-0x8(%rbp)
  80394c:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803953:	00 00 00 
  803956:	8b 55 fc             	mov    -0x4(%rbp),%edx
  803959:	89 10                	mov    %edx,(%rax)
  80395b:	8b 55 f8             	mov    -0x8(%rbp),%edx
  80395e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803962:	48 89 c6             	mov    %rax,%rsi
  803965:	48 bf 04 a0 80 00 00 	movabs $0x80a004,%rdi
  80396c:	00 00 00 
  80396f:	48 b8 95 18 80 00 00 	movabs $0x801895,%rax
  803976:	00 00 00 
  803979:	ff d0                	callq  *%rax
  80397b:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803982:	00 00 00 
  803985:	8b 55 f8             	mov    -0x8(%rbp),%edx
  803988:	89 50 14             	mov    %edx,0x14(%rax)
  80398b:	bf 05 00 00 00       	mov    $0x5,%edi
  803990:	48 b8 69 37 80 00 00 	movabs $0x803769,%rax
  803997:	00 00 00 
  80399a:	ff d0                	callq  *%rax
  80399c:	c9                   	leaveq 
  80399d:	c3                   	retq   

000000000080399e <nsipc_listen>:
  80399e:	55                   	push   %rbp
  80399f:	48 89 e5             	mov    %rsp,%rbp
  8039a2:	48 83 ec 10          	sub    $0x10,%rsp
  8039a6:	89 7d fc             	mov    %edi,-0x4(%rbp)
  8039a9:	89 75 f8             	mov    %esi,-0x8(%rbp)
  8039ac:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  8039b3:	00 00 00 
  8039b6:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8039b9:	89 10                	mov    %edx,(%rax)
  8039bb:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  8039c2:	00 00 00 
  8039c5:	8b 55 f8             	mov    -0x8(%rbp),%edx
  8039c8:	89 50 04             	mov    %edx,0x4(%rax)
  8039cb:	bf 06 00 00 00       	mov    $0x6,%edi
  8039d0:	48 b8 69 37 80 00 00 	movabs $0x803769,%rax
  8039d7:	00 00 00 
  8039da:	ff d0                	callq  *%rax
  8039dc:	c9                   	leaveq 
  8039dd:	c3                   	retq   

00000000008039de <nsipc_recv>:
  8039de:	55                   	push   %rbp
  8039df:	48 89 e5             	mov    %rsp,%rbp
  8039e2:	48 83 ec 30          	sub    $0x30,%rsp
  8039e6:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8039e9:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8039ed:	89 55 e8             	mov    %edx,-0x18(%rbp)
  8039f0:	89 4d dc             	mov    %ecx,-0x24(%rbp)
  8039f3:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  8039fa:	00 00 00 
  8039fd:	8b 55 ec             	mov    -0x14(%rbp),%edx
  803a00:	89 10                	mov    %edx,(%rax)
  803a02:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803a09:	00 00 00 
  803a0c:	8b 55 e8             	mov    -0x18(%rbp),%edx
  803a0f:	89 50 04             	mov    %edx,0x4(%rax)
  803a12:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803a19:	00 00 00 
  803a1c:	8b 55 dc             	mov    -0x24(%rbp),%edx
  803a1f:	89 50 08             	mov    %edx,0x8(%rax)
  803a22:	bf 07 00 00 00       	mov    $0x7,%edi
  803a27:	48 b8 69 37 80 00 00 	movabs $0x803769,%rax
  803a2e:	00 00 00 
  803a31:	ff d0                	callq  *%rax
  803a33:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803a36:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803a3a:	78 69                	js     803aa5 <nsipc_recv+0xc7>
  803a3c:	81 7d fc 3f 06 00 00 	cmpl   $0x63f,-0x4(%rbp)
  803a43:	7f 08                	jg     803a4d <nsipc_recv+0x6f>
  803a45:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803a48:	3b 45 e8             	cmp    -0x18(%rbp),%eax
  803a4b:	7e 35                	jle    803a82 <nsipc_recv+0xa4>
  803a4d:	48 b9 f1 4e 80 00 00 	movabs $0x804ef1,%rcx
  803a54:	00 00 00 
  803a57:	48 ba 06 4f 80 00 00 	movabs $0x804f06,%rdx
  803a5e:	00 00 00 
  803a61:	be 62 00 00 00       	mov    $0x62,%esi
  803a66:	48 bf 1b 4f 80 00 00 	movabs $0x804f1b,%rdi
  803a6d:	00 00 00 
  803a70:	b8 00 00 00 00       	mov    $0x0,%eax
  803a75:	49 b8 83 07 80 00 00 	movabs $0x800783,%r8
  803a7c:	00 00 00 
  803a7f:	41 ff d0             	callq  *%r8
  803a82:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803a85:	48 63 d0             	movslq %eax,%rdx
  803a88:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803a8c:	48 be 00 a0 80 00 00 	movabs $0x80a000,%rsi
  803a93:	00 00 00 
  803a96:	48 89 c7             	mov    %rax,%rdi
  803a99:	48 b8 95 18 80 00 00 	movabs $0x801895,%rax
  803aa0:	00 00 00 
  803aa3:	ff d0                	callq  *%rax
  803aa5:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803aa8:	c9                   	leaveq 
  803aa9:	c3                   	retq   

0000000000803aaa <nsipc_send>:
  803aaa:	55                   	push   %rbp
  803aab:	48 89 e5             	mov    %rsp,%rbp
  803aae:	48 83 ec 20          	sub    $0x20,%rsp
  803ab2:	89 7d fc             	mov    %edi,-0x4(%rbp)
  803ab5:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  803ab9:	89 55 f8             	mov    %edx,-0x8(%rbp)
  803abc:	89 4d ec             	mov    %ecx,-0x14(%rbp)
  803abf:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803ac6:	00 00 00 
  803ac9:	8b 55 fc             	mov    -0x4(%rbp),%edx
  803acc:	89 10                	mov    %edx,(%rax)
  803ace:	81 7d f8 3f 06 00 00 	cmpl   $0x63f,-0x8(%rbp)
  803ad5:	7e 35                	jle    803b0c <nsipc_send+0x62>
  803ad7:	48 b9 2a 4f 80 00 00 	movabs $0x804f2a,%rcx
  803ade:	00 00 00 
  803ae1:	48 ba 06 4f 80 00 00 	movabs $0x804f06,%rdx
  803ae8:	00 00 00 
  803aeb:	be 6d 00 00 00       	mov    $0x6d,%esi
  803af0:	48 bf 1b 4f 80 00 00 	movabs $0x804f1b,%rdi
  803af7:	00 00 00 
  803afa:	b8 00 00 00 00       	mov    $0x0,%eax
  803aff:	49 b8 83 07 80 00 00 	movabs $0x800783,%r8
  803b06:	00 00 00 
  803b09:	41 ff d0             	callq  *%r8
  803b0c:	8b 45 f8             	mov    -0x8(%rbp),%eax
  803b0f:	48 63 d0             	movslq %eax,%rdx
  803b12:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803b16:	48 89 c6             	mov    %rax,%rsi
  803b19:	48 bf 0c a0 80 00 00 	movabs $0x80a00c,%rdi
  803b20:	00 00 00 
  803b23:	48 b8 95 18 80 00 00 	movabs $0x801895,%rax
  803b2a:	00 00 00 
  803b2d:	ff d0                	callq  *%rax
  803b2f:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803b36:	00 00 00 
  803b39:	8b 55 f8             	mov    -0x8(%rbp),%edx
  803b3c:	89 50 04             	mov    %edx,0x4(%rax)
  803b3f:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803b46:	00 00 00 
  803b49:	8b 55 ec             	mov    -0x14(%rbp),%edx
  803b4c:	89 50 08             	mov    %edx,0x8(%rax)
  803b4f:	bf 08 00 00 00       	mov    $0x8,%edi
  803b54:	48 b8 69 37 80 00 00 	movabs $0x803769,%rax
  803b5b:	00 00 00 
  803b5e:	ff d0                	callq  *%rax
  803b60:	c9                   	leaveq 
  803b61:	c3                   	retq   

0000000000803b62 <nsipc_socket>:
  803b62:	55                   	push   %rbp
  803b63:	48 89 e5             	mov    %rsp,%rbp
  803b66:	48 83 ec 10          	sub    $0x10,%rsp
  803b6a:	89 7d fc             	mov    %edi,-0x4(%rbp)
  803b6d:	89 75 f8             	mov    %esi,-0x8(%rbp)
  803b70:	89 55 f4             	mov    %edx,-0xc(%rbp)
  803b73:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803b7a:	00 00 00 
  803b7d:	8b 55 fc             	mov    -0x4(%rbp),%edx
  803b80:	89 10                	mov    %edx,(%rax)
  803b82:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803b89:	00 00 00 
  803b8c:	8b 55 f8             	mov    -0x8(%rbp),%edx
  803b8f:	89 50 04             	mov    %edx,0x4(%rax)
  803b92:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803b99:	00 00 00 
  803b9c:	8b 55 f4             	mov    -0xc(%rbp),%edx
  803b9f:	89 50 08             	mov    %edx,0x8(%rax)
  803ba2:	bf 09 00 00 00       	mov    $0x9,%edi
  803ba7:	48 b8 69 37 80 00 00 	movabs $0x803769,%rax
  803bae:	00 00 00 
  803bb1:	ff d0                	callq  *%rax
  803bb3:	c9                   	leaveq 
  803bb4:	c3                   	retq   

0000000000803bb5 <pipe>:
  803bb5:	55                   	push   %rbp
  803bb6:	48 89 e5             	mov    %rsp,%rbp
  803bb9:	53                   	push   %rbx
  803bba:	48 83 ec 38          	sub    $0x38,%rsp
  803bbe:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  803bc2:	48 8d 45 d8          	lea    -0x28(%rbp),%rax
  803bc6:	48 89 c7             	mov    %rax,%rdi
  803bc9:	48 b8 cc 23 80 00 00 	movabs $0x8023cc,%rax
  803bd0:	00 00 00 
  803bd3:	ff d0                	callq  *%rax
  803bd5:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803bd8:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  803bdc:	0f 88 bf 01 00 00    	js     803da1 <pipe+0x1ec>
  803be2:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803be6:	ba 07 04 00 00       	mov    $0x407,%edx
  803beb:	48 89 c6             	mov    %rax,%rsi
  803bee:	bf 00 00 00 00       	mov    $0x0,%edi
  803bf3:	48 b8 a0 1e 80 00 00 	movabs $0x801ea0,%rax
  803bfa:	00 00 00 
  803bfd:	ff d0                	callq  *%rax
  803bff:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803c02:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  803c06:	0f 88 95 01 00 00    	js     803da1 <pipe+0x1ec>
  803c0c:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  803c10:	48 89 c7             	mov    %rax,%rdi
  803c13:	48 b8 cc 23 80 00 00 	movabs $0x8023cc,%rax
  803c1a:	00 00 00 
  803c1d:	ff d0                	callq  *%rax
  803c1f:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803c22:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  803c26:	0f 88 5d 01 00 00    	js     803d89 <pipe+0x1d4>
  803c2c:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803c30:	ba 07 04 00 00       	mov    $0x407,%edx
  803c35:	48 89 c6             	mov    %rax,%rsi
  803c38:	bf 00 00 00 00       	mov    $0x0,%edi
  803c3d:	48 b8 a0 1e 80 00 00 	movabs $0x801ea0,%rax
  803c44:	00 00 00 
  803c47:	ff d0                	callq  *%rax
  803c49:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803c4c:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  803c50:	0f 88 33 01 00 00    	js     803d89 <pipe+0x1d4>
  803c56:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803c5a:	48 89 c7             	mov    %rax,%rdi
  803c5d:	48 b8 a1 23 80 00 00 	movabs $0x8023a1,%rax
  803c64:	00 00 00 
  803c67:	ff d0                	callq  *%rax
  803c69:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  803c6d:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803c71:	ba 07 04 00 00       	mov    $0x407,%edx
  803c76:	48 89 c6             	mov    %rax,%rsi
  803c79:	bf 00 00 00 00       	mov    $0x0,%edi
  803c7e:	48 b8 a0 1e 80 00 00 	movabs $0x801ea0,%rax
  803c85:	00 00 00 
  803c88:	ff d0                	callq  *%rax
  803c8a:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803c8d:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  803c91:	79 05                	jns    803c98 <pipe+0xe3>
  803c93:	e9 d9 00 00 00       	jmpq   803d71 <pipe+0x1bc>
  803c98:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803c9c:	48 89 c7             	mov    %rax,%rdi
  803c9f:	48 b8 a1 23 80 00 00 	movabs $0x8023a1,%rax
  803ca6:	00 00 00 
  803ca9:	ff d0                	callq  *%rax
  803cab:	48 89 c2             	mov    %rax,%rdx
  803cae:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803cb2:	41 b8 07 04 00 00    	mov    $0x407,%r8d
  803cb8:	48 89 d1             	mov    %rdx,%rcx
  803cbb:	ba 00 00 00 00       	mov    $0x0,%edx
  803cc0:	48 89 c6             	mov    %rax,%rsi
  803cc3:	bf 00 00 00 00       	mov    $0x0,%edi
  803cc8:	48 b8 f0 1e 80 00 00 	movabs $0x801ef0,%rax
  803ccf:	00 00 00 
  803cd2:	ff d0                	callq  *%rax
  803cd4:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803cd7:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  803cdb:	79 1b                	jns    803cf8 <pipe+0x143>
  803cdd:	90                   	nop
  803cde:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803ce2:	48 89 c6             	mov    %rax,%rsi
  803ce5:	bf 00 00 00 00       	mov    $0x0,%edi
  803cea:	48 b8 4b 1f 80 00 00 	movabs $0x801f4b,%rax
  803cf1:	00 00 00 
  803cf4:	ff d0                	callq  *%rax
  803cf6:	eb 79                	jmp    803d71 <pipe+0x1bc>
  803cf8:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803cfc:	48 ba e0 60 80 00 00 	movabs $0x8060e0,%rdx
  803d03:	00 00 00 
  803d06:	8b 12                	mov    (%rdx),%edx
  803d08:	89 10                	mov    %edx,(%rax)
  803d0a:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803d0e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%rax)
  803d15:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803d19:	48 ba e0 60 80 00 00 	movabs $0x8060e0,%rdx
  803d20:	00 00 00 
  803d23:	8b 12                	mov    (%rdx),%edx
  803d25:	89 10                	mov    %edx,(%rax)
  803d27:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803d2b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%rax)
  803d32:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803d36:	48 89 c7             	mov    %rax,%rdi
  803d39:	48 b8 7e 23 80 00 00 	movabs $0x80237e,%rax
  803d40:	00 00 00 
  803d43:	ff d0                	callq  *%rax
  803d45:	89 c2                	mov    %eax,%edx
  803d47:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  803d4b:	89 10                	mov    %edx,(%rax)
  803d4d:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  803d51:	48 8d 58 04          	lea    0x4(%rax),%rbx
  803d55:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803d59:	48 89 c7             	mov    %rax,%rdi
  803d5c:	48 b8 7e 23 80 00 00 	movabs $0x80237e,%rax
  803d63:	00 00 00 
  803d66:	ff d0                	callq  *%rax
  803d68:	89 03                	mov    %eax,(%rbx)
  803d6a:	b8 00 00 00 00       	mov    $0x0,%eax
  803d6f:	eb 33                	jmp    803da4 <pipe+0x1ef>
  803d71:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803d75:	48 89 c6             	mov    %rax,%rsi
  803d78:	bf 00 00 00 00       	mov    $0x0,%edi
  803d7d:	48 b8 4b 1f 80 00 00 	movabs $0x801f4b,%rax
  803d84:	00 00 00 
  803d87:	ff d0                	callq  *%rax
  803d89:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803d8d:	48 89 c6             	mov    %rax,%rsi
  803d90:	bf 00 00 00 00       	mov    $0x0,%edi
  803d95:	48 b8 4b 1f 80 00 00 	movabs $0x801f4b,%rax
  803d9c:	00 00 00 
  803d9f:	ff d0                	callq  *%rax
  803da1:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803da4:	48 83 c4 38          	add    $0x38,%rsp
  803da8:	5b                   	pop    %rbx
  803da9:	5d                   	pop    %rbp
  803daa:	c3                   	retq   

0000000000803dab <_pipeisclosed>:
  803dab:	55                   	push   %rbp
  803dac:	48 89 e5             	mov    %rsp,%rbp
  803daf:	53                   	push   %rbx
  803db0:	48 83 ec 28          	sub    $0x28,%rsp
  803db4:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  803db8:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  803dbc:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  803dc3:	00 00 00 
  803dc6:	48 8b 00             	mov    (%rax),%rax
  803dc9:	8b 80 d8 00 00 00    	mov    0xd8(%rax),%eax
  803dcf:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803dd2:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803dd6:	48 89 c7             	mov    %rax,%rdi
  803dd9:	48 b8 8f 46 80 00 00 	movabs $0x80468f,%rax
  803de0:	00 00 00 
  803de3:	ff d0                	callq  *%rax
  803de5:	89 c3                	mov    %eax,%ebx
  803de7:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803deb:	48 89 c7             	mov    %rax,%rdi
  803dee:	48 b8 8f 46 80 00 00 	movabs $0x80468f,%rax
  803df5:	00 00 00 
  803df8:	ff d0                	callq  *%rax
  803dfa:	39 c3                	cmp    %eax,%ebx
  803dfc:	0f 94 c0             	sete   %al
  803dff:	0f b6 c0             	movzbl %al,%eax
  803e02:	89 45 e8             	mov    %eax,-0x18(%rbp)
  803e05:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  803e0c:	00 00 00 
  803e0f:	48 8b 00             	mov    (%rax),%rax
  803e12:	8b 80 d8 00 00 00    	mov    0xd8(%rax),%eax
  803e18:	89 45 e4             	mov    %eax,-0x1c(%rbp)
  803e1b:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803e1e:	3b 45 e4             	cmp    -0x1c(%rbp),%eax
  803e21:	75 05                	jne    803e28 <_pipeisclosed+0x7d>
  803e23:	8b 45 e8             	mov    -0x18(%rbp),%eax
  803e26:	eb 4f                	jmp    803e77 <_pipeisclosed+0xcc>
  803e28:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803e2b:	3b 45 e4             	cmp    -0x1c(%rbp),%eax
  803e2e:	74 42                	je     803e72 <_pipeisclosed+0xc7>
  803e30:	83 7d e8 01          	cmpl   $0x1,-0x18(%rbp)
  803e34:	75 3c                	jne    803e72 <_pipeisclosed+0xc7>
  803e36:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  803e3d:	00 00 00 
  803e40:	48 8b 00             	mov    (%rax),%rax
  803e43:	8b 90 d8 00 00 00    	mov    0xd8(%rax),%edx
  803e49:	8b 4d e8             	mov    -0x18(%rbp),%ecx
  803e4c:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803e4f:	89 c6                	mov    %eax,%esi
  803e51:	48 bf 3b 4f 80 00 00 	movabs $0x804f3b,%rdi
  803e58:	00 00 00 
  803e5b:	b8 00 00 00 00       	mov    $0x0,%eax
  803e60:	49 b8 bc 09 80 00 00 	movabs $0x8009bc,%r8
  803e67:	00 00 00 
  803e6a:	41 ff d0             	callq  *%r8
  803e6d:	e9 4a ff ff ff       	jmpq   803dbc <_pipeisclosed+0x11>
  803e72:	e9 45 ff ff ff       	jmpq   803dbc <_pipeisclosed+0x11>
  803e77:	48 83 c4 28          	add    $0x28,%rsp
  803e7b:	5b                   	pop    %rbx
  803e7c:	5d                   	pop    %rbp
  803e7d:	c3                   	retq   

0000000000803e7e <pipeisclosed>:
  803e7e:	55                   	push   %rbp
  803e7f:	48 89 e5             	mov    %rsp,%rbp
  803e82:	48 83 ec 30          	sub    $0x30,%rsp
  803e86:	89 7d dc             	mov    %edi,-0x24(%rbp)
  803e89:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  803e8d:	8b 45 dc             	mov    -0x24(%rbp),%eax
  803e90:	48 89 d6             	mov    %rdx,%rsi
  803e93:	89 c7                	mov    %eax,%edi
  803e95:	48 b8 64 24 80 00 00 	movabs $0x802464,%rax
  803e9c:	00 00 00 
  803e9f:	ff d0                	callq  *%rax
  803ea1:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803ea4:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803ea8:	79 05                	jns    803eaf <pipeisclosed+0x31>
  803eaa:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803ead:	eb 31                	jmp    803ee0 <pipeisclosed+0x62>
  803eaf:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  803eb3:	48 89 c7             	mov    %rax,%rdi
  803eb6:	48 b8 a1 23 80 00 00 	movabs $0x8023a1,%rax
  803ebd:	00 00 00 
  803ec0:	ff d0                	callq  *%rax
  803ec2:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  803ec6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  803eca:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  803ece:	48 89 d6             	mov    %rdx,%rsi
  803ed1:	48 89 c7             	mov    %rax,%rdi
  803ed4:	48 b8 ab 3d 80 00 00 	movabs $0x803dab,%rax
  803edb:	00 00 00 
  803ede:	ff d0                	callq  *%rax
  803ee0:	c9                   	leaveq 
  803ee1:	c3                   	retq   

0000000000803ee2 <devpipe_read>:
  803ee2:	55                   	push   %rbp
  803ee3:	48 89 e5             	mov    %rsp,%rbp
  803ee6:	48 83 ec 40          	sub    $0x40,%rsp
  803eea:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  803eee:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  803ef2:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  803ef6:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803efa:	48 89 c7             	mov    %rax,%rdi
  803efd:	48 b8 a1 23 80 00 00 	movabs $0x8023a1,%rax
  803f04:	00 00 00 
  803f07:	ff d0                	callq  *%rax
  803f09:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  803f0d:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803f11:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  803f15:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  803f1c:	00 
  803f1d:	e9 92 00 00 00       	jmpq   803fb4 <devpipe_read+0xd2>
  803f22:	eb 41                	jmp    803f65 <devpipe_read+0x83>
  803f24:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  803f29:	74 09                	je     803f34 <devpipe_read+0x52>
  803f2b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803f2f:	e9 92 00 00 00       	jmpq   803fc6 <devpipe_read+0xe4>
  803f34:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  803f38:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803f3c:	48 89 d6             	mov    %rdx,%rsi
  803f3f:	48 89 c7             	mov    %rax,%rdi
  803f42:	48 b8 ab 3d 80 00 00 	movabs $0x803dab,%rax
  803f49:	00 00 00 
  803f4c:	ff d0                	callq  *%rax
  803f4e:	85 c0                	test   %eax,%eax
  803f50:	74 07                	je     803f59 <devpipe_read+0x77>
  803f52:	b8 00 00 00 00       	mov    $0x0,%eax
  803f57:	eb 6d                	jmp    803fc6 <devpipe_read+0xe4>
  803f59:	48 b8 62 1e 80 00 00 	movabs $0x801e62,%rax
  803f60:	00 00 00 
  803f63:	ff d0                	callq  *%rax
  803f65:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803f69:	8b 10                	mov    (%rax),%edx
  803f6b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803f6f:	8b 40 04             	mov    0x4(%rax),%eax
  803f72:	39 c2                	cmp    %eax,%edx
  803f74:	74 ae                	je     803f24 <devpipe_read+0x42>
  803f76:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803f7a:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  803f7e:	48 8d 0c 02          	lea    (%rdx,%rax,1),%rcx
  803f82:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803f86:	8b 00                	mov    (%rax),%eax
  803f88:	99                   	cltd   
  803f89:	c1 ea 1b             	shr    $0x1b,%edx
  803f8c:	01 d0                	add    %edx,%eax
  803f8e:	83 e0 1f             	and    $0x1f,%eax
  803f91:	29 d0                	sub    %edx,%eax
  803f93:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  803f97:	48 98                	cltq   
  803f99:	0f b6 44 02 08       	movzbl 0x8(%rdx,%rax,1),%eax
  803f9e:	88 01                	mov    %al,(%rcx)
  803fa0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803fa4:	8b 00                	mov    (%rax),%eax
  803fa6:	8d 50 01             	lea    0x1(%rax),%edx
  803fa9:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803fad:	89 10                	mov    %edx,(%rax)
  803faf:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  803fb4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803fb8:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  803fbc:	0f 82 60 ff ff ff    	jb     803f22 <devpipe_read+0x40>
  803fc2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803fc6:	c9                   	leaveq 
  803fc7:	c3                   	retq   

0000000000803fc8 <devpipe_write>:
  803fc8:	55                   	push   %rbp
  803fc9:	48 89 e5             	mov    %rsp,%rbp
  803fcc:	48 83 ec 40          	sub    $0x40,%rsp
  803fd0:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  803fd4:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  803fd8:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  803fdc:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803fe0:	48 89 c7             	mov    %rax,%rdi
  803fe3:	48 b8 a1 23 80 00 00 	movabs $0x8023a1,%rax
  803fea:	00 00 00 
  803fed:	ff d0                	callq  *%rax
  803fef:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  803ff3:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803ff7:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  803ffb:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  804002:	00 
  804003:	e9 8e 00 00 00       	jmpq   804096 <devpipe_write+0xce>
  804008:	eb 31                	jmp    80403b <devpipe_write+0x73>
  80400a:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  80400e:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  804012:	48 89 d6             	mov    %rdx,%rsi
  804015:	48 89 c7             	mov    %rax,%rdi
  804018:	48 b8 ab 3d 80 00 00 	movabs $0x803dab,%rax
  80401f:	00 00 00 
  804022:	ff d0                	callq  *%rax
  804024:	85 c0                	test   %eax,%eax
  804026:	74 07                	je     80402f <devpipe_write+0x67>
  804028:	b8 00 00 00 00       	mov    $0x0,%eax
  80402d:	eb 79                	jmp    8040a8 <devpipe_write+0xe0>
  80402f:	48 b8 62 1e 80 00 00 	movabs $0x801e62,%rax
  804036:	00 00 00 
  804039:	ff d0                	callq  *%rax
  80403b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80403f:	8b 40 04             	mov    0x4(%rax),%eax
  804042:	48 63 d0             	movslq %eax,%rdx
  804045:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  804049:	8b 00                	mov    (%rax),%eax
  80404b:	48 98                	cltq   
  80404d:	48 83 c0 20          	add    $0x20,%rax
  804051:	48 39 c2             	cmp    %rax,%rdx
  804054:	73 b4                	jae    80400a <devpipe_write+0x42>
  804056:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80405a:	8b 40 04             	mov    0x4(%rax),%eax
  80405d:	99                   	cltd   
  80405e:	c1 ea 1b             	shr    $0x1b,%edx
  804061:	01 d0                	add    %edx,%eax
  804063:	83 e0 1f             	and    $0x1f,%eax
  804066:	29 d0                	sub    %edx,%eax
  804068:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  80406c:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  804070:	48 01 ca             	add    %rcx,%rdx
  804073:	0f b6 0a             	movzbl (%rdx),%ecx
  804076:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  80407a:	48 98                	cltq   
  80407c:	88 4c 02 08          	mov    %cl,0x8(%rdx,%rax,1)
  804080:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  804084:	8b 40 04             	mov    0x4(%rax),%eax
  804087:	8d 50 01             	lea    0x1(%rax),%edx
  80408a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80408e:	89 50 04             	mov    %edx,0x4(%rax)
  804091:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  804096:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80409a:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  80409e:	0f 82 64 ff ff ff    	jb     804008 <devpipe_write+0x40>
  8040a4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8040a8:	c9                   	leaveq 
  8040a9:	c3                   	retq   

00000000008040aa <devpipe_stat>:
  8040aa:	55                   	push   %rbp
  8040ab:	48 89 e5             	mov    %rsp,%rbp
  8040ae:	48 83 ec 20          	sub    $0x20,%rsp
  8040b2:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8040b6:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8040ba:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8040be:	48 89 c7             	mov    %rax,%rdi
  8040c1:	48 b8 a1 23 80 00 00 	movabs $0x8023a1,%rax
  8040c8:	00 00 00 
  8040cb:	ff d0                	callq  *%rax
  8040cd:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8040d1:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8040d5:	48 be 4e 4f 80 00 00 	movabs $0x804f4e,%rsi
  8040dc:	00 00 00 
  8040df:	48 89 c7             	mov    %rax,%rdi
  8040e2:	48 b8 71 15 80 00 00 	movabs $0x801571,%rax
  8040e9:	00 00 00 
  8040ec:	ff d0                	callq  *%rax
  8040ee:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8040f2:	8b 50 04             	mov    0x4(%rax),%edx
  8040f5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8040f9:	8b 00                	mov    (%rax),%eax
  8040fb:	29 c2                	sub    %eax,%edx
  8040fd:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  804101:	89 90 80 00 00 00    	mov    %edx,0x80(%rax)
  804107:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80410b:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%rax)
  804112:	00 00 00 
  804115:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  804119:	48 b9 e0 60 80 00 00 	movabs $0x8060e0,%rcx
  804120:	00 00 00 
  804123:	48 89 88 88 00 00 00 	mov    %rcx,0x88(%rax)
  80412a:	b8 00 00 00 00       	mov    $0x0,%eax
  80412f:	c9                   	leaveq 
  804130:	c3                   	retq   

0000000000804131 <devpipe_close>:
  804131:	55                   	push   %rbp
  804132:	48 89 e5             	mov    %rsp,%rbp
  804135:	48 83 ec 10          	sub    $0x10,%rsp
  804139:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  80413d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  804141:	48 89 c6             	mov    %rax,%rsi
  804144:	bf 00 00 00 00       	mov    $0x0,%edi
  804149:	48 b8 4b 1f 80 00 00 	movabs $0x801f4b,%rax
  804150:	00 00 00 
  804153:	ff d0                	callq  *%rax
  804155:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  804159:	48 89 c7             	mov    %rax,%rdi
  80415c:	48 b8 a1 23 80 00 00 	movabs $0x8023a1,%rax
  804163:	00 00 00 
  804166:	ff d0                	callq  *%rax
  804168:	48 89 c6             	mov    %rax,%rsi
  80416b:	bf 00 00 00 00       	mov    $0x0,%edi
  804170:	48 b8 4b 1f 80 00 00 	movabs $0x801f4b,%rax
  804177:	00 00 00 
  80417a:	ff d0                	callq  *%rax
  80417c:	c9                   	leaveq 
  80417d:	c3                   	retq   

000000000080417e <wait>:
  80417e:	55                   	push   %rbp
  80417f:	48 89 e5             	mov    %rsp,%rbp
  804182:	48 83 ec 20          	sub    $0x20,%rsp
  804186:	89 7d ec             	mov    %edi,-0x14(%rbp)
  804189:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  80418d:	75 35                	jne    8041c4 <wait+0x46>
  80418f:	48 b9 55 4f 80 00 00 	movabs $0x804f55,%rcx
  804196:	00 00 00 
  804199:	48 ba 60 4f 80 00 00 	movabs $0x804f60,%rdx
  8041a0:	00 00 00 
  8041a3:	be 0a 00 00 00       	mov    $0xa,%esi
  8041a8:	48 bf 75 4f 80 00 00 	movabs $0x804f75,%rdi
  8041af:	00 00 00 
  8041b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041b7:	49 b8 83 07 80 00 00 	movabs $0x800783,%r8
  8041be:	00 00 00 
  8041c1:	41 ff d0             	callq  *%r8
  8041c4:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8041c7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8041cc:	48 98                	cltq   
  8041ce:	48 69 d0 68 01 00 00 	imul   $0x168,%rax,%rdx
  8041d5:	48 b8 00 00 80 00 80 	movabs $0x8000800000,%rax
  8041dc:	00 00 00 
  8041df:	48 01 d0             	add    %rdx,%rax
  8041e2:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8041e6:	eb 0c                	jmp    8041f4 <wait+0x76>
  8041e8:	48 b8 62 1e 80 00 00 	movabs $0x801e62,%rax
  8041ef:	00 00 00 
  8041f2:	ff d0                	callq  *%rax
  8041f4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8041f8:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  8041fe:	3b 45 ec             	cmp    -0x14(%rbp),%eax
  804201:	75 0e                	jne    804211 <wait+0x93>
  804203:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  804207:	8b 80 d4 00 00 00    	mov    0xd4(%rax),%eax
  80420d:	85 c0                	test   %eax,%eax
  80420f:	75 d7                	jne    8041e8 <wait+0x6a>
  804211:	c9                   	leaveq 
  804212:	c3                   	retq   

0000000000804213 <cputchar>:
  804213:	55                   	push   %rbp
  804214:	48 89 e5             	mov    %rsp,%rbp
  804217:	48 83 ec 20          	sub    $0x20,%rsp
  80421b:	89 7d ec             	mov    %edi,-0x14(%rbp)
  80421e:	8b 45 ec             	mov    -0x14(%rbp),%eax
  804221:	88 45 ff             	mov    %al,-0x1(%rbp)
  804224:	48 8d 45 ff          	lea    -0x1(%rbp),%rax
  804228:	be 01 00 00 00       	mov    $0x1,%esi
  80422d:	48 89 c7             	mov    %rax,%rdi
  804230:	48 b8 58 1d 80 00 00 	movabs $0x801d58,%rax
  804237:	00 00 00 
  80423a:	ff d0                	callq  *%rax
  80423c:	c9                   	leaveq 
  80423d:	c3                   	retq   

000000000080423e <getchar>:
  80423e:	55                   	push   %rbp
  80423f:	48 89 e5             	mov    %rsp,%rbp
  804242:	48 83 ec 10          	sub    $0x10,%rsp
  804246:	48 8d 45 fb          	lea    -0x5(%rbp),%rax
  80424a:	ba 01 00 00 00       	mov    $0x1,%edx
  80424f:	48 89 c6             	mov    %rax,%rsi
  804252:	bf 00 00 00 00       	mov    $0x0,%edi
  804257:	48 b8 96 28 80 00 00 	movabs $0x802896,%rax
  80425e:	00 00 00 
  804261:	ff d0                	callq  *%rax
  804263:	89 45 fc             	mov    %eax,-0x4(%rbp)
  804266:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80426a:	79 05                	jns    804271 <getchar+0x33>
  80426c:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80426f:	eb 14                	jmp    804285 <getchar+0x47>
  804271:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  804275:	7f 07                	jg     80427e <getchar+0x40>
  804277:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
  80427c:	eb 07                	jmp    804285 <getchar+0x47>
  80427e:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  804282:	0f b6 c0             	movzbl %al,%eax
  804285:	c9                   	leaveq 
  804286:	c3                   	retq   

0000000000804287 <iscons>:
  804287:	55                   	push   %rbp
  804288:	48 89 e5             	mov    %rsp,%rbp
  80428b:	48 83 ec 20          	sub    $0x20,%rsp
  80428f:	89 7d ec             	mov    %edi,-0x14(%rbp)
  804292:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  804296:	8b 45 ec             	mov    -0x14(%rbp),%eax
  804299:	48 89 d6             	mov    %rdx,%rsi
  80429c:	89 c7                	mov    %eax,%edi
  80429e:	48 b8 64 24 80 00 00 	movabs $0x802464,%rax
  8042a5:	00 00 00 
  8042a8:	ff d0                	callq  *%rax
  8042aa:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8042ad:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8042b1:	79 05                	jns    8042b8 <iscons+0x31>
  8042b3:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8042b6:	eb 1a                	jmp    8042d2 <iscons+0x4b>
  8042b8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8042bc:	8b 10                	mov    (%rax),%edx
  8042be:	48 b8 20 61 80 00 00 	movabs $0x806120,%rax
  8042c5:	00 00 00 
  8042c8:	8b 00                	mov    (%rax),%eax
  8042ca:	39 c2                	cmp    %eax,%edx
  8042cc:	0f 94 c0             	sete   %al
  8042cf:	0f b6 c0             	movzbl %al,%eax
  8042d2:	c9                   	leaveq 
  8042d3:	c3                   	retq   

00000000008042d4 <opencons>:
  8042d4:	55                   	push   %rbp
  8042d5:	48 89 e5             	mov    %rsp,%rbp
  8042d8:	48 83 ec 10          	sub    $0x10,%rsp
  8042dc:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
  8042e0:	48 89 c7             	mov    %rax,%rdi
  8042e3:	48 b8 cc 23 80 00 00 	movabs $0x8023cc,%rax
  8042ea:	00 00 00 
  8042ed:	ff d0                	callq  *%rax
  8042ef:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8042f2:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8042f6:	79 05                	jns    8042fd <opencons+0x29>
  8042f8:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8042fb:	eb 5b                	jmp    804358 <opencons+0x84>
  8042fd:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  804301:	ba 07 04 00 00       	mov    $0x407,%edx
  804306:	48 89 c6             	mov    %rax,%rsi
  804309:	bf 00 00 00 00       	mov    $0x0,%edi
  80430e:	48 b8 a0 1e 80 00 00 	movabs $0x801ea0,%rax
  804315:	00 00 00 
  804318:	ff d0                	callq  *%rax
  80431a:	89 45 fc             	mov    %eax,-0x4(%rbp)
  80431d:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  804321:	79 05                	jns    804328 <opencons+0x54>
  804323:	8b 45 fc             	mov    -0x4(%rbp),%eax
  804326:	eb 30                	jmp    804358 <opencons+0x84>
  804328:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80432c:	48 ba 20 61 80 00 00 	movabs $0x806120,%rdx
  804333:	00 00 00 
  804336:	8b 12                	mov    (%rdx),%edx
  804338:	89 10                	mov    %edx,(%rax)
  80433a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80433e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%rax)
  804345:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  804349:	48 89 c7             	mov    %rax,%rdi
  80434c:	48 b8 7e 23 80 00 00 	movabs $0x80237e,%rax
  804353:	00 00 00 
  804356:	ff d0                	callq  *%rax
  804358:	c9                   	leaveq 
  804359:	c3                   	retq   

000000000080435a <devcons_read>:
  80435a:	55                   	push   %rbp
  80435b:	48 89 e5             	mov    %rsp,%rbp
  80435e:	48 83 ec 30          	sub    $0x30,%rsp
  804362:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  804366:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  80436a:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  80436e:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  804373:	75 07                	jne    80437c <devcons_read+0x22>
  804375:	b8 00 00 00 00       	mov    $0x0,%eax
  80437a:	eb 4b                	jmp    8043c7 <devcons_read+0x6d>
  80437c:	eb 0c                	jmp    80438a <devcons_read+0x30>
  80437e:	48 b8 62 1e 80 00 00 	movabs $0x801e62,%rax
  804385:	00 00 00 
  804388:	ff d0                	callq  *%rax
  80438a:	48 b8 a2 1d 80 00 00 	movabs $0x801da2,%rax
  804391:	00 00 00 
  804394:	ff d0                	callq  *%rax
  804396:	89 45 fc             	mov    %eax,-0x4(%rbp)
  804399:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80439d:	74 df                	je     80437e <devcons_read+0x24>
  80439f:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8043a3:	79 05                	jns    8043aa <devcons_read+0x50>
  8043a5:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8043a8:	eb 1d                	jmp    8043c7 <devcons_read+0x6d>
  8043aa:	83 7d fc 04          	cmpl   $0x4,-0x4(%rbp)
  8043ae:	75 07                	jne    8043b7 <devcons_read+0x5d>
  8043b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8043b5:	eb 10                	jmp    8043c7 <devcons_read+0x6d>
  8043b7:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8043ba:	89 c2                	mov    %eax,%edx
  8043bc:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8043c0:	88 10                	mov    %dl,(%rax)
  8043c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8043c7:	c9                   	leaveq 
  8043c8:	c3                   	retq   

00000000008043c9 <devcons_write>:
  8043c9:	55                   	push   %rbp
  8043ca:	48 89 e5             	mov    %rsp,%rbp
  8043cd:	48 81 ec b0 00 00 00 	sub    $0xb0,%rsp
  8043d4:	48 89 bd 68 ff ff ff 	mov    %rdi,-0x98(%rbp)
  8043db:	48 89 b5 60 ff ff ff 	mov    %rsi,-0xa0(%rbp)
  8043e2:	48 89 95 58 ff ff ff 	mov    %rdx,-0xa8(%rbp)
  8043e9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8043f0:	eb 76                	jmp    804468 <devcons_write+0x9f>
  8043f2:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
  8043f9:	89 c2                	mov    %eax,%edx
  8043fb:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8043fe:	29 c2                	sub    %eax,%edx
  804400:	89 d0                	mov    %edx,%eax
  804402:	89 45 f8             	mov    %eax,-0x8(%rbp)
  804405:	8b 45 f8             	mov    -0x8(%rbp),%eax
  804408:	83 f8 7f             	cmp    $0x7f,%eax
  80440b:	76 07                	jbe    804414 <devcons_write+0x4b>
  80440d:	c7 45 f8 7f 00 00 00 	movl   $0x7f,-0x8(%rbp)
  804414:	8b 45 f8             	mov    -0x8(%rbp),%eax
  804417:	48 63 d0             	movslq %eax,%rdx
  80441a:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80441d:	48 63 c8             	movslq %eax,%rcx
  804420:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  804427:	48 01 c1             	add    %rax,%rcx
  80442a:	48 8d 85 70 ff ff ff 	lea    -0x90(%rbp),%rax
  804431:	48 89 ce             	mov    %rcx,%rsi
  804434:	48 89 c7             	mov    %rax,%rdi
  804437:	48 b8 95 18 80 00 00 	movabs $0x801895,%rax
  80443e:	00 00 00 
  804441:	ff d0                	callq  *%rax
  804443:	8b 45 f8             	mov    -0x8(%rbp),%eax
  804446:	48 63 d0             	movslq %eax,%rdx
  804449:	48 8d 85 70 ff ff ff 	lea    -0x90(%rbp),%rax
  804450:	48 89 d6             	mov    %rdx,%rsi
  804453:	48 89 c7             	mov    %rax,%rdi
  804456:	48 b8 58 1d 80 00 00 	movabs $0x801d58,%rax
  80445d:	00 00 00 
  804460:	ff d0                	callq  *%rax
  804462:	8b 45 f8             	mov    -0x8(%rbp),%eax
  804465:	01 45 fc             	add    %eax,-0x4(%rbp)
  804468:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80446b:	48 98                	cltq   
  80446d:	48 3b 85 58 ff ff ff 	cmp    -0xa8(%rbp),%rax
  804474:	0f 82 78 ff ff ff    	jb     8043f2 <devcons_write+0x29>
  80447a:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80447d:	c9                   	leaveq 
  80447e:	c3                   	retq   

000000000080447f <devcons_close>:
  80447f:	55                   	push   %rbp
  804480:	48 89 e5             	mov    %rsp,%rbp
  804483:	48 83 ec 08          	sub    $0x8,%rsp
  804487:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  80448b:	b8 00 00 00 00       	mov    $0x0,%eax
  804490:	c9                   	leaveq 
  804491:	c3                   	retq   

0000000000804492 <devcons_stat>:
  804492:	55                   	push   %rbp
  804493:	48 89 e5             	mov    %rsp,%rbp
  804496:	48 83 ec 10          	sub    $0x10,%rsp
  80449a:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  80449e:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8044a2:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8044a6:	48 be 88 4f 80 00 00 	movabs $0x804f88,%rsi
  8044ad:	00 00 00 
  8044b0:	48 89 c7             	mov    %rax,%rdi
  8044b3:	48 b8 71 15 80 00 00 	movabs $0x801571,%rax
  8044ba:	00 00 00 
  8044bd:	ff d0                	callq  *%rax
  8044bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8044c4:	c9                   	leaveq 
  8044c5:	c3                   	retq   

00000000008044c6 <ipc_recv>:
  8044c6:	55                   	push   %rbp
  8044c7:	48 89 e5             	mov    %rsp,%rbp
  8044ca:	48 83 ec 30          	sub    $0x30,%rsp
  8044ce:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8044d2:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8044d6:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  8044da:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  8044df:	75 0e                	jne    8044ef <ipc_recv+0x29>
  8044e1:	48 b8 00 00 80 00 80 	movabs $0x8000800000,%rax
  8044e8:	00 00 00 
  8044eb:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  8044ef:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8044f3:	48 89 c7             	mov    %rax,%rdi
  8044f6:	48 b8 c9 20 80 00 00 	movabs $0x8020c9,%rax
  8044fd:	00 00 00 
  804500:	ff d0                	callq  *%rax
  804502:	89 45 fc             	mov    %eax,-0x4(%rbp)
  804505:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  804509:	79 27                	jns    804532 <ipc_recv+0x6c>
  80450b:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  804510:	74 0a                	je     80451c <ipc_recv+0x56>
  804512:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  804516:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
  80451c:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  804521:	74 0a                	je     80452d <ipc_recv+0x67>
  804523:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  804527:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
  80452d:	8b 45 fc             	mov    -0x4(%rbp),%eax
  804530:	eb 53                	jmp    804585 <ipc_recv+0xbf>
  804532:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  804537:	74 19                	je     804552 <ipc_recv+0x8c>
  804539:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  804540:	00 00 00 
  804543:	48 8b 00             	mov    (%rax),%rax
  804546:	8b 90 0c 01 00 00    	mov    0x10c(%rax),%edx
  80454c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  804550:	89 10                	mov    %edx,(%rax)
  804552:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  804557:	74 19                	je     804572 <ipc_recv+0xac>
  804559:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  804560:	00 00 00 
  804563:	48 8b 00             	mov    (%rax),%rax
  804566:	8b 90 10 01 00 00    	mov    0x110(%rax),%edx
  80456c:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  804570:	89 10                	mov    %edx,(%rax)
  804572:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  804579:	00 00 00 
  80457c:	48 8b 00             	mov    (%rax),%rax
  80457f:	8b 80 08 01 00 00    	mov    0x108(%rax),%eax
  804585:	c9                   	leaveq 
  804586:	c3                   	retq   

0000000000804587 <ipc_send>:
  804587:	55                   	push   %rbp
  804588:	48 89 e5             	mov    %rsp,%rbp
  80458b:	48 83 ec 30          	sub    $0x30,%rsp
  80458f:	89 7d ec             	mov    %edi,-0x14(%rbp)
  804592:	89 75 e8             	mov    %esi,-0x18(%rbp)
  804595:	48 89 55 e0          	mov    %rdx,-0x20(%rbp)
  804599:	89 4d dc             	mov    %ecx,-0x24(%rbp)
  80459c:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  8045a1:	75 10                	jne    8045b3 <ipc_send+0x2c>
  8045a3:	48 b8 00 00 80 00 80 	movabs $0x8000800000,%rax
  8045aa:	00 00 00 
  8045ad:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  8045b1:	eb 0e                	jmp    8045c1 <ipc_send+0x3a>
  8045b3:	eb 0c                	jmp    8045c1 <ipc_send+0x3a>
  8045b5:	48 b8 62 1e 80 00 00 	movabs $0x801e62,%rax
  8045bc:	00 00 00 
  8045bf:	ff d0                	callq  *%rax
  8045c1:	8b 75 e8             	mov    -0x18(%rbp),%esi
  8045c4:	8b 4d dc             	mov    -0x24(%rbp),%ecx
  8045c7:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8045cb:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8045ce:	89 c7                	mov    %eax,%edi
  8045d0:	48 b8 74 20 80 00 00 	movabs $0x802074,%rax
  8045d7:	00 00 00 
  8045da:	ff d0                	callq  *%rax
  8045dc:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8045df:	83 7d fc f8          	cmpl   $0xfffffff8,-0x4(%rbp)
  8045e3:	74 d0                	je     8045b5 <ipc_send+0x2e>
  8045e5:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8045e9:	79 30                	jns    80461b <ipc_send+0x94>
  8045eb:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8045ee:	89 c1                	mov    %eax,%ecx
  8045f0:	48 ba 8f 4f 80 00 00 	movabs $0x804f8f,%rdx
  8045f7:	00 00 00 
  8045fa:	be 4b 00 00 00       	mov    $0x4b,%esi
  8045ff:	48 bf a5 4f 80 00 00 	movabs $0x804fa5,%rdi
  804606:	00 00 00 
  804609:	b8 00 00 00 00       	mov    $0x0,%eax
  80460e:	49 b8 83 07 80 00 00 	movabs $0x800783,%r8
  804615:	00 00 00 
  804618:	41 ff d0             	callq  *%r8
  80461b:	c9                   	leaveq 
  80461c:	c3                   	retq   

000000000080461d <ipc_find_env>:
  80461d:	55                   	push   %rbp
  80461e:	48 89 e5             	mov    %rsp,%rbp
  804621:	48 83 ec 14          	sub    $0x14,%rsp
  804625:	89 7d ec             	mov    %edi,-0x14(%rbp)
  804628:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  80462f:	eb 4e                	jmp    80467f <ipc_find_env+0x62>
  804631:	48 ba 00 00 80 00 80 	movabs $0x8000800000,%rdx
  804638:	00 00 00 
  80463b:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80463e:	48 98                	cltq   
  804640:	48 69 c0 68 01 00 00 	imul   $0x168,%rax,%rax
  804647:	48 01 d0             	add    %rdx,%rax
  80464a:	48 05 d0 00 00 00    	add    $0xd0,%rax
  804650:	8b 00                	mov    (%rax),%eax
  804652:	3b 45 ec             	cmp    -0x14(%rbp),%eax
  804655:	75 24                	jne    80467b <ipc_find_env+0x5e>
  804657:	48 ba 00 00 80 00 80 	movabs $0x8000800000,%rdx
  80465e:	00 00 00 
  804661:	8b 45 fc             	mov    -0x4(%rbp),%eax
  804664:	48 98                	cltq   
  804666:	48 69 c0 68 01 00 00 	imul   $0x168,%rax,%rax
  80466d:	48 01 d0             	add    %rdx,%rax
  804670:	48 05 c0 00 00 00    	add    $0xc0,%rax
  804676:	8b 40 08             	mov    0x8(%rax),%eax
  804679:	eb 12                	jmp    80468d <ipc_find_env+0x70>
  80467b:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  80467f:	81 7d fc ff 03 00 00 	cmpl   $0x3ff,-0x4(%rbp)
  804686:	7e a9                	jle    804631 <ipc_find_env+0x14>
  804688:	b8 00 00 00 00       	mov    $0x0,%eax
  80468d:	c9                   	leaveq 
  80468e:	c3                   	retq   

000000000080468f <pageref>:
  80468f:	55                   	push   %rbp
  804690:	48 89 e5             	mov    %rsp,%rbp
  804693:	48 83 ec 18          	sub    $0x18,%rsp
  804697:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80469b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80469f:	48 c1 e8 15          	shr    $0x15,%rax
  8046a3:	48 89 c2             	mov    %rax,%rdx
  8046a6:	48 b8 00 00 00 80 00 	movabs $0x10080000000,%rax
  8046ad:	01 00 00 
  8046b0:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8046b4:	83 e0 01             	and    $0x1,%eax
  8046b7:	48 85 c0             	test   %rax,%rax
  8046ba:	75 07                	jne    8046c3 <pageref+0x34>
  8046bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8046c1:	eb 53                	jmp    804716 <pageref+0x87>
  8046c3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8046c7:	48 c1 e8 0c          	shr    $0xc,%rax
  8046cb:	48 89 c2             	mov    %rax,%rdx
  8046ce:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  8046d5:	01 00 00 
  8046d8:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8046dc:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8046e0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8046e4:	83 e0 01             	and    $0x1,%eax
  8046e7:	48 85 c0             	test   %rax,%rax
  8046ea:	75 07                	jne    8046f3 <pageref+0x64>
  8046ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8046f1:	eb 23                	jmp    804716 <pageref+0x87>
  8046f3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8046f7:	48 c1 e8 0c          	shr    $0xc,%rax
  8046fb:	48 89 c2             	mov    %rax,%rdx
  8046fe:	48 b8 00 00 a0 00 80 	movabs $0x8000a00000,%rax
  804705:	00 00 00 
  804708:	48 c1 e2 04          	shl    $0x4,%rdx
  80470c:	48 01 d0             	add    %rdx,%rax
  80470f:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  804713:	0f b7 c0             	movzwl %ax,%eax
  804716:	c9                   	leaveq 
  804717:	c3                   	retq   
