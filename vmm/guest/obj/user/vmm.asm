
vmm/guest/obj/user/vmm:     file format elf64-x86-64


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
  80003c:	e8 bd 05 00 00       	callq  8005fe <libmain>
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
  8000be:	48 b8 c1 1d 80 00 00 	movabs $0x801dc1,%rax
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
  80010e:	48 b8 fc 20 80 00 00 	movabs $0x8020fc,%rax
  800115:	00 00 00 
  800118:	ff d0                	callq  *%rax
  80011a:	89 45 f8             	mov    %eax,-0x8(%rbp)
  80011d:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  800121:	79 30                	jns    800153 <map_in_guest+0x110>
                  panic("spawn: sys_ept_map data: %e", r);
  800123:	8b 45 f8             	mov    -0x8(%rbp),%eax
  800126:	89 c1                	mov    %eax,%ecx
  800128:	48 ba c0 46 80 00 00 	movabs $0x8046c0,%rdx
  80012f:	00 00 00 
  800132:	be 26 00 00 00       	mov    $0x26,%esi
  800137:	48 bf dc 46 80 00 00 	movabs $0x8046dc,%rdi
  80013e:	00 00 00 
  800141:	b8 00 00 00 00       	mov    $0x0,%eax
  800146:	49 b8 a4 06 80 00 00 	movabs $0x8006a4,%r8
  80014d:	00 00 00 
  800150:	41 ff d0             	callq  *%r8
            sys_page_unmap(0, UTEMP);
  800153:	be 00 00 40 00       	mov    $0x400000,%esi
  800158:	bf 00 00 00 00       	mov    $0x0,%edi
  80015d:	48 b8 6c 1e 80 00 00 	movabs $0x801e6c,%rax
  800164:	00 00 00 
  800167:	ff d0                	callq  *%rax
  800169:	e9 38 01 00 00       	jmpq   8002a6 <map_in_guest+0x263>

        } else {
            if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80016e:	ba 07 00 00 00       	mov    $0x7,%edx
  800173:	be 00 00 40 00       	mov    $0x400000,%esi
  800178:	bf 00 00 00 00       	mov    $0x0,%edi
  80017d:	48 b8 c1 1d 80 00 00 	movabs $0x801dc1,%rax
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
  8001a9:	48 b8 d7 28 80 00 00 	movabs $0x8028d7,%rax
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
  8001fb:	48 b8 8e 27 80 00 00 	movabs $0x80278e,%rax
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
  80024b:	48 b8 fc 20 80 00 00 	movabs $0x8020fc,%rax
  800252:	00 00 00 
  800255:	ff d0                	callq  *%rax
  800257:	89 45 f8             	mov    %eax,-0x8(%rbp)
  80025a:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  80025e:	79 30                	jns    800290 <map_in_guest+0x24d>
                panic("spawn: sys_ept_map data: %e", r);
  800260:	8b 45 f8             	mov    -0x8(%rbp),%eax
  800263:	89 c1                	mov    %eax,%ecx
  800265:	48 ba c0 46 80 00 00 	movabs $0x8046c0,%rdx
  80026c:	00 00 00 
  80026f:	be 31 00 00 00       	mov    $0x31,%esi
  800274:	48 bf dc 46 80 00 00 	movabs $0x8046dc,%rdi
  80027b:	00 00 00 
  80027e:	b8 00 00 00 00       	mov    $0x0,%eax
  800283:	49 b8 a4 06 80 00 00 	movabs $0x8006a4,%r8
  80028a:	00 00 00 
  80028d:	41 ff d0             	callq  *%r8
            sys_page_unmap(0, UTEMP);
  800290:	be 00 00 40 00       	mov    $0x400000,%esi
  800295:	bf 00 00 00 00       	mov    $0x0,%edi
  80029a:	48 b8 6c 1e 80 00 00 	movabs $0x801e6c,%rax
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
  8002ea:	48 b8 8f 2b 80 00 00 	movabs $0x802b8f,%rax
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
  80032c:	48 b8 8e 27 80 00 00 	movabs $0x80278e,%rax
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
  800351:	48 b8 97 24 80 00 00 	movabs $0x802497,%rax
  800358:	00 00 00 
  80035b:	ff d0                	callq  *%rax
                cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80035d:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800361:	8b 00                	mov    (%rax),%eax
  800363:	ba 7f 45 4c 46       	mov    $0x464c457f,%edx
  800368:	89 c6                	mov    %eax,%esi
  80036a:	48 bf e7 46 80 00 00 	movabs $0x8046e7,%rdi
  800371:	00 00 00 
  800374:	b8 00 00 00 00       	mov    $0x0,%eax
  800379:	48 b9 dd 08 80 00 00 	movabs $0x8008dd,%rcx
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
  800441:	48 b8 97 24 80 00 00 	movabs $0x802497,%rax
  800448:	00 00 00 
  80044b:	ff d0                	callq  *%rax
        fd = -1;
  80044d:	c7 45 fc ff ff ff ff 	movl   $0xffffffff,-0x4(%rbp)

error:
    close(fd);
  800454:	8b 45 fc             	mov    -0x4(%rbp),%eax
  800457:	89 c7                	mov    %eax,%edi
  800459:	48 b8 97 24 80 00 00 	movabs $0x802497,%rax
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
  80046e:	48 83 ec 50          	sub    $0x50,%rsp
  800472:	89 7d bc             	mov    %edi,-0x44(%rbp)
  800475:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
  800479:	be 00 70 00 00       	mov    $0x7000,%esi
  80047e:	bf 00 00 00 01       	mov    $0x1000000,%edi
  800483:	48 b8 57 21 80 00 00 	movabs $0x802157,%rax
  80048a:	00 00 00 
  80048d:	ff d0                	callq  *%rax
  80048f:	89 45 fc             	mov    %eax,-0x4(%rbp)
  800492:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  800496:	79 2c                	jns    8004c4 <umain+0x5a>
  800498:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80049b:	89 c6                	mov    %eax,%esi
  80049d:	48 bf 08 47 80 00 00 	movabs $0x804708,%rdi
  8004a4:	00 00 00 
  8004a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ac:	48 ba dd 08 80 00 00 	movabs $0x8008dd,%rdx
  8004b3:	00 00 00 
  8004b6:	ff d2                	callq  *%rdx
  8004b8:	48 b8 81 06 80 00 00 	movabs $0x800681,%rax
  8004bf:	00 00 00 
  8004c2:	ff d0                	callq  *%rax
  8004c4:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004c7:	89 45 f8             	mov    %eax,-0x8(%rbp)
  8004ca:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8004cd:	48 be 2b 47 80 00 00 	movabs $0x80472b,%rsi
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
  8004f3:	48 bf 38 47 80 00 00 	movabs $0x804738,%rdi
  8004fa:	00 00 00 
  8004fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800502:	48 ba dd 08 80 00 00 	movabs $0x8008dd,%rdx
  800509:	00 00 00 
  80050c:	ff d2                	callq  *%rdx
  80050e:	48 b8 81 06 80 00 00 	movabs $0x800681,%rax
  800515:	00 00 00 
  800518:	ff d0                	callq  *%rax
  80051a:	be 00 00 00 00       	mov    $0x0,%esi
  80051f:	48 bf 61 47 80 00 00 	movabs $0x804761,%rdi
  800526:	00 00 00 
  800529:	48 b8 8f 2b 80 00 00 	movabs $0x802b8f,%rax
  800530:	00 00 00 
  800533:	ff d0                	callq  *%rax
  800535:	89 45 f4             	mov    %eax,-0xc(%rbp)
  800538:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
  80053c:	79 36                	jns    800574 <umain+0x10a>
  80053e:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800541:	89 c2                	mov    %eax,%edx
  800543:	48 be 61 47 80 00 00 	movabs $0x804761,%rsi
  80054a:	00 00 00 
  80054d:	48 bf 6b 47 80 00 00 	movabs $0x80476b,%rdi
  800554:	00 00 00 
  800557:	b8 00 00 00 00       	mov    $0x0,%eax
  80055c:	48 b9 dd 08 80 00 00 	movabs $0x8008dd,%rcx
  800563:	00 00 00 
  800566:	ff d1                	callq  *%rcx
  800568:	48 b8 81 06 80 00 00 	movabs $0x800681,%rax
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
  8005ae:	48 bf 88 47 80 00 00 	movabs $0x804788,%rdi
  8005b5:	00 00 00 
  8005b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8005bd:	48 ba dd 08 80 00 00 	movabs $0x8008dd,%rdx
  8005c4:	00 00 00 
  8005c7:	ff d2                	callq  *%rdx
  8005c9:	48 b8 81 06 80 00 00 	movabs $0x800681,%rax
  8005d0:	00 00 00 
  8005d3:	ff d0                	callq  *%rax
  8005d5:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8005d8:	be 02 00 00 00       	mov    $0x2,%esi
  8005dd:	89 c7                	mov    %eax,%edi
  8005df:	48 b8 b6 1e 80 00 00 	movabs $0x801eb6,%rax
  8005e6:	00 00 00 
  8005e9:	ff d0                	callq  *%rax
  8005eb:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8005ee:	89 c7                	mov    %eax,%edi
  8005f0:	48 b8 a1 3f 80 00 00 	movabs $0x803fa1,%rax
  8005f7:	00 00 00 
  8005fa:	ff d0                	callq  *%rax
  8005fc:	c9                   	leaveq 
  8005fd:	c3                   	retq   

00000000008005fe <libmain>:
  8005fe:	55                   	push   %rbp
  8005ff:	48 89 e5             	mov    %rsp,%rbp
  800602:	48 83 ec 10          	sub    $0x10,%rsp
  800606:	89 7d fc             	mov    %edi,-0x4(%rbp)
  800609:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  80060d:	48 b8 45 1d 80 00 00 	movabs $0x801d45,%rax
  800614:	00 00 00 
  800617:	ff d0                	callq  *%rax
  800619:	25 ff 03 00 00       	and    $0x3ff,%eax
  80061e:	48 98                	cltq   
  800620:	48 69 d0 68 01 00 00 	imul   $0x168,%rax,%rdx
  800627:	48 b8 00 00 80 00 80 	movabs $0x8000800000,%rax
  80062e:	00 00 00 
  800631:	48 01 c2             	add    %rax,%rdx
  800634:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  80063b:	00 00 00 
  80063e:	48 89 10             	mov    %rdx,(%rax)
  800641:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  800645:	7e 14                	jle    80065b <libmain+0x5d>
  800647:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80064b:	48 8b 10             	mov    (%rax),%rdx
  80064e:	48 b8 00 60 80 00 00 	movabs $0x806000,%rax
  800655:	00 00 00 
  800658:	48 89 10             	mov    %rdx,(%rax)
  80065b:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  80065f:	8b 45 fc             	mov    -0x4(%rbp),%eax
  800662:	48 89 d6             	mov    %rdx,%rsi
  800665:	89 c7                	mov    %eax,%edi
  800667:	48 b8 6a 04 80 00 00 	movabs $0x80046a,%rax
  80066e:	00 00 00 
  800671:	ff d0                	callq  *%rax
  800673:	48 b8 81 06 80 00 00 	movabs $0x800681,%rax
  80067a:	00 00 00 
  80067d:	ff d0                	callq  *%rax
  80067f:	c9                   	leaveq 
  800680:	c3                   	retq   

0000000000800681 <exit>:
  800681:	55                   	push   %rbp
  800682:	48 89 e5             	mov    %rsp,%rbp
  800685:	48 b8 e2 24 80 00 00 	movabs $0x8024e2,%rax
  80068c:	00 00 00 
  80068f:	ff d0                	callq  *%rax
  800691:	bf 00 00 00 00       	mov    $0x0,%edi
  800696:	48 b8 01 1d 80 00 00 	movabs $0x801d01,%rax
  80069d:	00 00 00 
  8006a0:	ff d0                	callq  *%rax
  8006a2:	5d                   	pop    %rbp
  8006a3:	c3                   	retq   

00000000008006a4 <_panic>:
  8006a4:	55                   	push   %rbp
  8006a5:	48 89 e5             	mov    %rsp,%rbp
  8006a8:	53                   	push   %rbx
  8006a9:	48 81 ec f8 00 00 00 	sub    $0xf8,%rsp
  8006b0:	48 89 bd 18 ff ff ff 	mov    %rdi,-0xe8(%rbp)
  8006b7:	89 b5 14 ff ff ff    	mov    %esi,-0xec(%rbp)
  8006bd:	48 89 8d 58 ff ff ff 	mov    %rcx,-0xa8(%rbp)
  8006c4:	4c 89 85 60 ff ff ff 	mov    %r8,-0xa0(%rbp)
  8006cb:	4c 89 8d 68 ff ff ff 	mov    %r9,-0x98(%rbp)
  8006d2:	84 c0                	test   %al,%al
  8006d4:	74 23                	je     8006f9 <_panic+0x55>
  8006d6:	0f 29 85 70 ff ff ff 	movaps %xmm0,-0x90(%rbp)
  8006dd:	0f 29 4d 80          	movaps %xmm1,-0x80(%rbp)
  8006e1:	0f 29 55 90          	movaps %xmm2,-0x70(%rbp)
  8006e5:	0f 29 5d a0          	movaps %xmm3,-0x60(%rbp)
  8006e9:	0f 29 65 b0          	movaps %xmm4,-0x50(%rbp)
  8006ed:	0f 29 6d c0          	movaps %xmm5,-0x40(%rbp)
  8006f1:	0f 29 75 d0          	movaps %xmm6,-0x30(%rbp)
  8006f5:	0f 29 7d e0          	movaps %xmm7,-0x20(%rbp)
  8006f9:	48 89 95 08 ff ff ff 	mov    %rdx,-0xf8(%rbp)
  800700:	c7 85 28 ff ff ff 18 	movl   $0x18,-0xd8(%rbp)
  800707:	00 00 00 
  80070a:	c7 85 2c ff ff ff 30 	movl   $0x30,-0xd4(%rbp)
  800711:	00 00 00 
  800714:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800718:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
  80071f:	48 8d 85 40 ff ff ff 	lea    -0xc0(%rbp),%rax
  800726:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  80072d:	48 b8 00 60 80 00 00 	movabs $0x806000,%rax
  800734:	00 00 00 
  800737:	48 8b 18             	mov    (%rax),%rbx
  80073a:	48 b8 45 1d 80 00 00 	movabs $0x801d45,%rax
  800741:	00 00 00 
  800744:	ff d0                	callq  *%rax
  800746:	8b 8d 14 ff ff ff    	mov    -0xec(%rbp),%ecx
  80074c:	48 8b 95 18 ff ff ff 	mov    -0xe8(%rbp),%rdx
  800753:	41 89 c8             	mov    %ecx,%r8d
  800756:	48 89 d1             	mov    %rdx,%rcx
  800759:	48 89 da             	mov    %rbx,%rdx
  80075c:	89 c6                	mov    %eax,%esi
  80075e:	48 bf c8 47 80 00 00 	movabs $0x8047c8,%rdi
  800765:	00 00 00 
  800768:	b8 00 00 00 00       	mov    $0x0,%eax
  80076d:	49 b9 dd 08 80 00 00 	movabs $0x8008dd,%r9
  800774:	00 00 00 
  800777:	41 ff d1             	callq  *%r9
  80077a:	48 8d 95 28 ff ff ff 	lea    -0xd8(%rbp),%rdx
  800781:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
  800788:	48 89 d6             	mov    %rdx,%rsi
  80078b:	48 89 c7             	mov    %rax,%rdi
  80078e:	48 b8 31 08 80 00 00 	movabs $0x800831,%rax
  800795:	00 00 00 
  800798:	ff d0                	callq  *%rax
  80079a:	48 bf eb 47 80 00 00 	movabs $0x8047eb,%rdi
  8007a1:	00 00 00 
  8007a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a9:	48 ba dd 08 80 00 00 	movabs $0x8008dd,%rdx
  8007b0:	00 00 00 
  8007b3:	ff d2                	callq  *%rdx
  8007b5:	cc                   	int3   
  8007b6:	eb fd                	jmp    8007b5 <_panic+0x111>

00000000008007b8 <putch>:
  8007b8:	55                   	push   %rbp
  8007b9:	48 89 e5             	mov    %rsp,%rbp
  8007bc:	48 83 ec 10          	sub    $0x10,%rsp
  8007c0:	89 7d fc             	mov    %edi,-0x4(%rbp)
  8007c3:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8007c7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8007cb:	8b 00                	mov    (%rax),%eax
  8007cd:	8d 48 01             	lea    0x1(%rax),%ecx
  8007d0:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8007d4:	89 0a                	mov    %ecx,(%rdx)
  8007d6:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8007d9:	89 d1                	mov    %edx,%ecx
  8007db:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8007df:	48 98                	cltq   
  8007e1:	88 4c 02 08          	mov    %cl,0x8(%rdx,%rax,1)
  8007e5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8007e9:	8b 00                	mov    (%rax),%eax
  8007eb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8007f0:	75 2c                	jne    80081e <putch+0x66>
  8007f2:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8007f6:	8b 00                	mov    (%rax),%eax
  8007f8:	48 98                	cltq   
  8007fa:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8007fe:	48 83 c2 08          	add    $0x8,%rdx
  800802:	48 89 c6             	mov    %rax,%rsi
  800805:	48 89 d7             	mov    %rdx,%rdi
  800808:	48 b8 79 1c 80 00 00 	movabs $0x801c79,%rax
  80080f:	00 00 00 
  800812:	ff d0                	callq  *%rax
  800814:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800818:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
  80081e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800822:	8b 40 04             	mov    0x4(%rax),%eax
  800825:	8d 50 01             	lea    0x1(%rax),%edx
  800828:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80082c:	89 50 04             	mov    %edx,0x4(%rax)
  80082f:	c9                   	leaveq 
  800830:	c3                   	retq   

0000000000800831 <vcprintf>:
  800831:	55                   	push   %rbp
  800832:	48 89 e5             	mov    %rsp,%rbp
  800835:	48 81 ec 40 01 00 00 	sub    $0x140,%rsp
  80083c:	48 89 bd c8 fe ff ff 	mov    %rdi,-0x138(%rbp)
  800843:	48 89 b5 c0 fe ff ff 	mov    %rsi,-0x140(%rbp)
  80084a:	48 8d 85 d8 fe ff ff 	lea    -0x128(%rbp),%rax
  800851:	48 8b 95 c0 fe ff ff 	mov    -0x140(%rbp),%rdx
  800858:	48 8b 0a             	mov    (%rdx),%rcx
  80085b:	48 89 08             	mov    %rcx,(%rax)
  80085e:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  800862:	48 89 48 08          	mov    %rcx,0x8(%rax)
  800866:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  80086a:	48 89 50 10          	mov    %rdx,0x10(%rax)
  80086e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800875:	00 00 00 
  800878:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  80087f:	00 00 00 
  800882:	48 8d 8d d8 fe ff ff 	lea    -0x128(%rbp),%rcx
  800889:	48 8b 95 c8 fe ff ff 	mov    -0x138(%rbp),%rdx
  800890:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800897:	48 89 c6             	mov    %rax,%rsi
  80089a:	48 bf b8 07 80 00 00 	movabs $0x8007b8,%rdi
  8008a1:	00 00 00 
  8008a4:	48 b8 90 0c 80 00 00 	movabs $0x800c90,%rax
  8008ab:	00 00 00 
  8008ae:	ff d0                	callq  *%rax
  8008b0:	8b 85 f0 fe ff ff    	mov    -0x110(%rbp),%eax
  8008b6:	48 98                	cltq   
  8008b8:	48 8d 95 f0 fe ff ff 	lea    -0x110(%rbp),%rdx
  8008bf:	48 83 c2 08          	add    $0x8,%rdx
  8008c3:	48 89 c6             	mov    %rax,%rsi
  8008c6:	48 89 d7             	mov    %rdx,%rdi
  8008c9:	48 b8 79 1c 80 00 00 	movabs $0x801c79,%rax
  8008d0:	00 00 00 
  8008d3:	ff d0                	callq  *%rax
  8008d5:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8008db:	c9                   	leaveq 
  8008dc:	c3                   	retq   

00000000008008dd <cprintf>:
  8008dd:	55                   	push   %rbp
  8008de:	48 89 e5             	mov    %rsp,%rbp
  8008e1:	48 81 ec 00 01 00 00 	sub    $0x100,%rsp
  8008e8:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8008ef:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8008f6:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8008fd:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800904:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80090b:	84 c0                	test   %al,%al
  80090d:	74 20                	je     80092f <cprintf+0x52>
  80090f:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800913:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800917:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80091b:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80091f:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800923:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800927:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80092b:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  80092f:	48 89 bd 08 ff ff ff 	mov    %rdi,-0xf8(%rbp)
  800936:	c7 85 30 ff ff ff 08 	movl   $0x8,-0xd0(%rbp)
  80093d:	00 00 00 
  800940:	c7 85 34 ff ff ff 30 	movl   $0x30,-0xcc(%rbp)
  800947:	00 00 00 
  80094a:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80094e:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  800955:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80095c:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800963:	48 8d 85 18 ff ff ff 	lea    -0xe8(%rbp),%rax
  80096a:	48 8d 95 30 ff ff ff 	lea    -0xd0(%rbp),%rdx
  800971:	48 8b 0a             	mov    (%rdx),%rcx
  800974:	48 89 08             	mov    %rcx,(%rax)
  800977:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  80097b:	48 89 48 08          	mov    %rcx,0x8(%rax)
  80097f:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  800983:	48 89 50 10          	mov    %rdx,0x10(%rax)
  800987:	48 8d 95 18 ff ff ff 	lea    -0xe8(%rbp),%rdx
  80098e:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
  800995:	48 89 d6             	mov    %rdx,%rsi
  800998:	48 89 c7             	mov    %rax,%rdi
  80099b:	48 b8 31 08 80 00 00 	movabs $0x800831,%rax
  8009a2:	00 00 00 
  8009a5:	ff d0                	callq  *%rax
  8009a7:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%rbp)
  8009ad:	8b 85 4c ff ff ff    	mov    -0xb4(%rbp),%eax
  8009b3:	c9                   	leaveq 
  8009b4:	c3                   	retq   

00000000008009b5 <printnum>:
  8009b5:	55                   	push   %rbp
  8009b6:	48 89 e5             	mov    %rsp,%rbp
  8009b9:	53                   	push   %rbx
  8009ba:	48 83 ec 38          	sub    $0x38,%rsp
  8009be:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8009c2:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8009c6:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  8009ca:	89 4d d4             	mov    %ecx,-0x2c(%rbp)
  8009cd:	44 89 45 d0          	mov    %r8d,-0x30(%rbp)
  8009d1:	44 89 4d cc          	mov    %r9d,-0x34(%rbp)
  8009d5:	8b 45 d4             	mov    -0x2c(%rbp),%eax
  8009d8:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  8009dc:	77 3b                	ja     800a19 <printnum+0x64>
  8009de:	8b 45 d0             	mov    -0x30(%rbp),%eax
  8009e1:	44 8d 40 ff          	lea    -0x1(%rax),%r8d
  8009e5:	8b 5d d4             	mov    -0x2c(%rbp),%ebx
  8009e8:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8009ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f1:	48 f7 f3             	div    %rbx
  8009f4:	48 89 c2             	mov    %rax,%rdx
  8009f7:	8b 7d cc             	mov    -0x34(%rbp),%edi
  8009fa:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
  8009fd:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
  800a01:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800a05:	41 89 f9             	mov    %edi,%r9d
  800a08:	48 89 c7             	mov    %rax,%rdi
  800a0b:	48 b8 b5 09 80 00 00 	movabs $0x8009b5,%rax
  800a12:	00 00 00 
  800a15:	ff d0                	callq  *%rax
  800a17:	eb 1e                	jmp    800a37 <printnum+0x82>
  800a19:	eb 12                	jmp    800a2d <printnum+0x78>
  800a1b:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  800a1f:	8b 55 cc             	mov    -0x34(%rbp),%edx
  800a22:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800a26:	48 89 ce             	mov    %rcx,%rsi
  800a29:	89 d7                	mov    %edx,%edi
  800a2b:	ff d0                	callq  *%rax
  800a2d:	83 6d d0 01          	subl   $0x1,-0x30(%rbp)
  800a31:	83 7d d0 00          	cmpl   $0x0,-0x30(%rbp)
  800a35:	7f e4                	jg     800a1b <printnum+0x66>
  800a37:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
  800a3a:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800a3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a43:	48 f7 f1             	div    %rcx
  800a46:	48 89 d0             	mov    %rdx,%rax
  800a49:	48 ba f0 49 80 00 00 	movabs $0x8049f0,%rdx
  800a50:	00 00 00 
  800a53:	0f b6 04 02          	movzbl (%rdx,%rax,1),%eax
  800a57:	0f be d0             	movsbl %al,%edx
  800a5a:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  800a5e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800a62:	48 89 ce             	mov    %rcx,%rsi
  800a65:	89 d7                	mov    %edx,%edi
  800a67:	ff d0                	callq  *%rax
  800a69:	48 83 c4 38          	add    $0x38,%rsp
  800a6d:	5b                   	pop    %rbx
  800a6e:	5d                   	pop    %rbp
  800a6f:	c3                   	retq   

0000000000800a70 <getuint>:
  800a70:	55                   	push   %rbp
  800a71:	48 89 e5             	mov    %rsp,%rbp
  800a74:	48 83 ec 1c          	sub    $0x1c,%rsp
  800a78:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  800a7c:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  800a7f:	83 7d e4 01          	cmpl   $0x1,-0x1c(%rbp)
  800a83:	7e 52                	jle    800ad7 <getuint+0x67>
  800a85:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800a89:	8b 00                	mov    (%rax),%eax
  800a8b:	83 f8 30             	cmp    $0x30,%eax
  800a8e:	73 24                	jae    800ab4 <getuint+0x44>
  800a90:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800a94:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800a98:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800a9c:	8b 00                	mov    (%rax),%eax
  800a9e:	89 c0                	mov    %eax,%eax
  800aa0:	48 01 d0             	add    %rdx,%rax
  800aa3:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800aa7:	8b 12                	mov    (%rdx),%edx
  800aa9:	8d 4a 08             	lea    0x8(%rdx),%ecx
  800aac:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800ab0:	89 0a                	mov    %ecx,(%rdx)
  800ab2:	eb 17                	jmp    800acb <getuint+0x5b>
  800ab4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800ab8:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800abc:	48 89 d0             	mov    %rdx,%rax
  800abf:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800ac3:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800ac7:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  800acb:	48 8b 00             	mov    (%rax),%rax
  800ace:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800ad2:	e9 a3 00 00 00       	jmpq   800b7a <getuint+0x10a>
  800ad7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  800adb:	74 4f                	je     800b2c <getuint+0xbc>
  800add:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800ae1:	8b 00                	mov    (%rax),%eax
  800ae3:	83 f8 30             	cmp    $0x30,%eax
  800ae6:	73 24                	jae    800b0c <getuint+0x9c>
  800ae8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800aec:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800af0:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800af4:	8b 00                	mov    (%rax),%eax
  800af6:	89 c0                	mov    %eax,%eax
  800af8:	48 01 d0             	add    %rdx,%rax
  800afb:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800aff:	8b 12                	mov    (%rdx),%edx
  800b01:	8d 4a 08             	lea    0x8(%rdx),%ecx
  800b04:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800b08:	89 0a                	mov    %ecx,(%rdx)
  800b0a:	eb 17                	jmp    800b23 <getuint+0xb3>
  800b0c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800b10:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800b14:	48 89 d0             	mov    %rdx,%rax
  800b17:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800b1b:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800b1f:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  800b23:	48 8b 00             	mov    (%rax),%rax
  800b26:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800b2a:	eb 4e                	jmp    800b7a <getuint+0x10a>
  800b2c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800b30:	8b 00                	mov    (%rax),%eax
  800b32:	83 f8 30             	cmp    $0x30,%eax
  800b35:	73 24                	jae    800b5b <getuint+0xeb>
  800b37:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800b3b:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800b3f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800b43:	8b 00                	mov    (%rax),%eax
  800b45:	89 c0                	mov    %eax,%eax
  800b47:	48 01 d0             	add    %rdx,%rax
  800b4a:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800b4e:	8b 12                	mov    (%rdx),%edx
  800b50:	8d 4a 08             	lea    0x8(%rdx),%ecx
  800b53:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800b57:	89 0a                	mov    %ecx,(%rdx)
  800b59:	eb 17                	jmp    800b72 <getuint+0x102>
  800b5b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800b5f:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800b63:	48 89 d0             	mov    %rdx,%rax
  800b66:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800b6a:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800b6e:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  800b72:	8b 00                	mov    (%rax),%eax
  800b74:	89 c0                	mov    %eax,%eax
  800b76:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800b7a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800b7e:	c9                   	leaveq 
  800b7f:	c3                   	retq   

0000000000800b80 <getint>:
  800b80:	55                   	push   %rbp
  800b81:	48 89 e5             	mov    %rsp,%rbp
  800b84:	48 83 ec 1c          	sub    $0x1c,%rsp
  800b88:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  800b8c:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  800b8f:	83 7d e4 01          	cmpl   $0x1,-0x1c(%rbp)
  800b93:	7e 52                	jle    800be7 <getint+0x67>
  800b95:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800b99:	8b 00                	mov    (%rax),%eax
  800b9b:	83 f8 30             	cmp    $0x30,%eax
  800b9e:	73 24                	jae    800bc4 <getint+0x44>
  800ba0:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800ba4:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800ba8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800bac:	8b 00                	mov    (%rax),%eax
  800bae:	89 c0                	mov    %eax,%eax
  800bb0:	48 01 d0             	add    %rdx,%rax
  800bb3:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800bb7:	8b 12                	mov    (%rdx),%edx
  800bb9:	8d 4a 08             	lea    0x8(%rdx),%ecx
  800bbc:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800bc0:	89 0a                	mov    %ecx,(%rdx)
  800bc2:	eb 17                	jmp    800bdb <getint+0x5b>
  800bc4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800bc8:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800bcc:	48 89 d0             	mov    %rdx,%rax
  800bcf:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800bd3:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800bd7:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  800bdb:	48 8b 00             	mov    (%rax),%rax
  800bde:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800be2:	e9 a3 00 00 00       	jmpq   800c8a <getint+0x10a>
  800be7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  800beb:	74 4f                	je     800c3c <getint+0xbc>
  800bed:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800bf1:	8b 00                	mov    (%rax),%eax
  800bf3:	83 f8 30             	cmp    $0x30,%eax
  800bf6:	73 24                	jae    800c1c <getint+0x9c>
  800bf8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800bfc:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800c00:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800c04:	8b 00                	mov    (%rax),%eax
  800c06:	89 c0                	mov    %eax,%eax
  800c08:	48 01 d0             	add    %rdx,%rax
  800c0b:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800c0f:	8b 12                	mov    (%rdx),%edx
  800c11:	8d 4a 08             	lea    0x8(%rdx),%ecx
  800c14:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800c18:	89 0a                	mov    %ecx,(%rdx)
  800c1a:	eb 17                	jmp    800c33 <getint+0xb3>
  800c1c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800c20:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800c24:	48 89 d0             	mov    %rdx,%rax
  800c27:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800c2b:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800c2f:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  800c33:	48 8b 00             	mov    (%rax),%rax
  800c36:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800c3a:	eb 4e                	jmp    800c8a <getint+0x10a>
  800c3c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800c40:	8b 00                	mov    (%rax),%eax
  800c42:	83 f8 30             	cmp    $0x30,%eax
  800c45:	73 24                	jae    800c6b <getint+0xeb>
  800c47:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800c4b:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800c4f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800c53:	8b 00                	mov    (%rax),%eax
  800c55:	89 c0                	mov    %eax,%eax
  800c57:	48 01 d0             	add    %rdx,%rax
  800c5a:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800c5e:	8b 12                	mov    (%rdx),%edx
  800c60:	8d 4a 08             	lea    0x8(%rdx),%ecx
  800c63:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800c67:	89 0a                	mov    %ecx,(%rdx)
  800c69:	eb 17                	jmp    800c82 <getint+0x102>
  800c6b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800c6f:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800c73:	48 89 d0             	mov    %rdx,%rax
  800c76:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800c7a:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800c7e:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  800c82:	8b 00                	mov    (%rax),%eax
  800c84:	48 98                	cltq   
  800c86:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800c8a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800c8e:	c9                   	leaveq 
  800c8f:	c3                   	retq   

0000000000800c90 <vprintfmt>:
  800c90:	55                   	push   %rbp
  800c91:	48 89 e5             	mov    %rsp,%rbp
  800c94:	41 54                	push   %r12
  800c96:	53                   	push   %rbx
  800c97:	48 83 ec 60          	sub    $0x60,%rsp
  800c9b:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  800c9f:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  800ca3:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  800ca7:	48 89 4d 90          	mov    %rcx,-0x70(%rbp)
  800cab:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  800caf:	48 8b 55 90          	mov    -0x70(%rbp),%rdx
  800cb3:	48 8b 0a             	mov    (%rdx),%rcx
  800cb6:	48 89 08             	mov    %rcx,(%rax)
  800cb9:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  800cbd:	48 89 48 08          	mov    %rcx,0x8(%rax)
  800cc1:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  800cc5:	48 89 50 10          	mov    %rdx,0x10(%rax)
  800cc9:	eb 17                	jmp    800ce2 <vprintfmt+0x52>
  800ccb:	85 db                	test   %ebx,%ebx
  800ccd:	0f 84 cc 04 00 00    	je     80119f <vprintfmt+0x50f>
  800cd3:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  800cd7:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800cdb:	48 89 d6             	mov    %rdx,%rsi
  800cde:	89 df                	mov    %ebx,%edi
  800ce0:	ff d0                	callq  *%rax
  800ce2:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800ce6:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800cea:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  800cee:	0f b6 00             	movzbl (%rax),%eax
  800cf1:	0f b6 d8             	movzbl %al,%ebx
  800cf4:	83 fb 25             	cmp    $0x25,%ebx
  800cf7:	75 d2                	jne    800ccb <vprintfmt+0x3b>
  800cf9:	c6 45 d3 20          	movb   $0x20,-0x2d(%rbp)
  800cfd:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%rbp)
  800d04:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%rbp)
  800d0b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%rbp)
  800d12:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%rbp)
  800d19:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800d1d:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800d21:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  800d25:	0f b6 00             	movzbl (%rax),%eax
  800d28:	0f b6 d8             	movzbl %al,%ebx
  800d2b:	8d 43 dd             	lea    -0x23(%rbx),%eax
  800d2e:	83 f8 55             	cmp    $0x55,%eax
  800d31:	0f 87 34 04 00 00    	ja     80116b <vprintfmt+0x4db>
  800d37:	89 c0                	mov    %eax,%eax
  800d39:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  800d40:	00 
  800d41:	48 b8 18 4a 80 00 00 	movabs $0x804a18,%rax
  800d48:	00 00 00 
  800d4b:	48 01 d0             	add    %rdx,%rax
  800d4e:	48 8b 00             	mov    (%rax),%rax
  800d51:	ff e0                	jmpq   *%rax
  800d53:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%rbp)
  800d57:	eb c0                	jmp    800d19 <vprintfmt+0x89>
  800d59:	c6 45 d3 30          	movb   $0x30,-0x2d(%rbp)
  800d5d:	eb ba                	jmp    800d19 <vprintfmt+0x89>
  800d5f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%rbp)
  800d66:	8b 55 d8             	mov    -0x28(%rbp),%edx
  800d69:	89 d0                	mov    %edx,%eax
  800d6b:	c1 e0 02             	shl    $0x2,%eax
  800d6e:	01 d0                	add    %edx,%eax
  800d70:	01 c0                	add    %eax,%eax
  800d72:	01 d8                	add    %ebx,%eax
  800d74:	83 e8 30             	sub    $0x30,%eax
  800d77:	89 45 d8             	mov    %eax,-0x28(%rbp)
  800d7a:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800d7e:	0f b6 00             	movzbl (%rax),%eax
  800d81:	0f be d8             	movsbl %al,%ebx
  800d84:	83 fb 2f             	cmp    $0x2f,%ebx
  800d87:	7e 0c                	jle    800d95 <vprintfmt+0x105>
  800d89:	83 fb 39             	cmp    $0x39,%ebx
  800d8c:	7f 07                	jg     800d95 <vprintfmt+0x105>
  800d8e:	48 83 45 98 01       	addq   $0x1,-0x68(%rbp)
  800d93:	eb d1                	jmp    800d66 <vprintfmt+0xd6>
  800d95:	eb 58                	jmp    800def <vprintfmt+0x15f>
  800d97:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d9a:	83 f8 30             	cmp    $0x30,%eax
  800d9d:	73 17                	jae    800db6 <vprintfmt+0x126>
  800d9f:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800da3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800da6:	89 c0                	mov    %eax,%eax
  800da8:	48 01 d0             	add    %rdx,%rax
  800dab:	8b 55 b8             	mov    -0x48(%rbp),%edx
  800dae:	83 c2 08             	add    $0x8,%edx
  800db1:	89 55 b8             	mov    %edx,-0x48(%rbp)
  800db4:	eb 0f                	jmp    800dc5 <vprintfmt+0x135>
  800db6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800dba:	48 89 d0             	mov    %rdx,%rax
  800dbd:	48 83 c2 08          	add    $0x8,%rdx
  800dc1:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  800dc5:	8b 00                	mov    (%rax),%eax
  800dc7:	89 45 d8             	mov    %eax,-0x28(%rbp)
  800dca:	eb 23                	jmp    800def <vprintfmt+0x15f>
  800dcc:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800dd0:	79 0c                	jns    800dde <vprintfmt+0x14e>
  800dd2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%rbp)
  800dd9:	e9 3b ff ff ff       	jmpq   800d19 <vprintfmt+0x89>
  800dde:	e9 36 ff ff ff       	jmpq   800d19 <vprintfmt+0x89>
  800de3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%rbp)
  800dea:	e9 2a ff ff ff       	jmpq   800d19 <vprintfmt+0x89>
  800def:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800df3:	79 12                	jns    800e07 <vprintfmt+0x177>
  800df5:	8b 45 d8             	mov    -0x28(%rbp),%eax
  800df8:	89 45 dc             	mov    %eax,-0x24(%rbp)
  800dfb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%rbp)
  800e02:	e9 12 ff ff ff       	jmpq   800d19 <vprintfmt+0x89>
  800e07:	e9 0d ff ff ff       	jmpq   800d19 <vprintfmt+0x89>
  800e0c:	83 45 e0 01          	addl   $0x1,-0x20(%rbp)
  800e10:	e9 04 ff ff ff       	jmpq   800d19 <vprintfmt+0x89>
  800e15:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800e18:	83 f8 30             	cmp    $0x30,%eax
  800e1b:	73 17                	jae    800e34 <vprintfmt+0x1a4>
  800e1d:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800e21:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800e24:	89 c0                	mov    %eax,%eax
  800e26:	48 01 d0             	add    %rdx,%rax
  800e29:	8b 55 b8             	mov    -0x48(%rbp),%edx
  800e2c:	83 c2 08             	add    $0x8,%edx
  800e2f:	89 55 b8             	mov    %edx,-0x48(%rbp)
  800e32:	eb 0f                	jmp    800e43 <vprintfmt+0x1b3>
  800e34:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800e38:	48 89 d0             	mov    %rdx,%rax
  800e3b:	48 83 c2 08          	add    $0x8,%rdx
  800e3f:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  800e43:	8b 10                	mov    (%rax),%edx
  800e45:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  800e49:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800e4d:	48 89 ce             	mov    %rcx,%rsi
  800e50:	89 d7                	mov    %edx,%edi
  800e52:	ff d0                	callq  *%rax
  800e54:	e9 40 03 00 00       	jmpq   801199 <vprintfmt+0x509>
  800e59:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800e5c:	83 f8 30             	cmp    $0x30,%eax
  800e5f:	73 17                	jae    800e78 <vprintfmt+0x1e8>
  800e61:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800e65:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800e68:	89 c0                	mov    %eax,%eax
  800e6a:	48 01 d0             	add    %rdx,%rax
  800e6d:	8b 55 b8             	mov    -0x48(%rbp),%edx
  800e70:	83 c2 08             	add    $0x8,%edx
  800e73:	89 55 b8             	mov    %edx,-0x48(%rbp)
  800e76:	eb 0f                	jmp    800e87 <vprintfmt+0x1f7>
  800e78:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800e7c:	48 89 d0             	mov    %rdx,%rax
  800e7f:	48 83 c2 08          	add    $0x8,%rdx
  800e83:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  800e87:	8b 18                	mov    (%rax),%ebx
  800e89:	85 db                	test   %ebx,%ebx
  800e8b:	79 02                	jns    800e8f <vprintfmt+0x1ff>
  800e8d:	f7 db                	neg    %ebx
  800e8f:	83 fb 15             	cmp    $0x15,%ebx
  800e92:	7f 16                	jg     800eaa <vprintfmt+0x21a>
  800e94:	48 b8 40 49 80 00 00 	movabs $0x804940,%rax
  800e9b:	00 00 00 
  800e9e:	48 63 d3             	movslq %ebx,%rdx
  800ea1:	4c 8b 24 d0          	mov    (%rax,%rdx,8),%r12
  800ea5:	4d 85 e4             	test   %r12,%r12
  800ea8:	75 2e                	jne    800ed8 <vprintfmt+0x248>
  800eaa:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  800eae:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800eb2:	89 d9                	mov    %ebx,%ecx
  800eb4:	48 ba 01 4a 80 00 00 	movabs $0x804a01,%rdx
  800ebb:	00 00 00 
  800ebe:	48 89 c7             	mov    %rax,%rdi
  800ec1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec6:	49 b8 a8 11 80 00 00 	movabs $0x8011a8,%r8
  800ecd:	00 00 00 
  800ed0:	41 ff d0             	callq  *%r8
  800ed3:	e9 c1 02 00 00       	jmpq   801199 <vprintfmt+0x509>
  800ed8:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  800edc:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800ee0:	4c 89 e1             	mov    %r12,%rcx
  800ee3:	48 ba 0a 4a 80 00 00 	movabs $0x804a0a,%rdx
  800eea:	00 00 00 
  800eed:	48 89 c7             	mov    %rax,%rdi
  800ef0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef5:	49 b8 a8 11 80 00 00 	movabs $0x8011a8,%r8
  800efc:	00 00 00 
  800eff:	41 ff d0             	callq  *%r8
  800f02:	e9 92 02 00 00       	jmpq   801199 <vprintfmt+0x509>
  800f07:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800f0a:	83 f8 30             	cmp    $0x30,%eax
  800f0d:	73 17                	jae    800f26 <vprintfmt+0x296>
  800f0f:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800f13:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800f16:	89 c0                	mov    %eax,%eax
  800f18:	48 01 d0             	add    %rdx,%rax
  800f1b:	8b 55 b8             	mov    -0x48(%rbp),%edx
  800f1e:	83 c2 08             	add    $0x8,%edx
  800f21:	89 55 b8             	mov    %edx,-0x48(%rbp)
  800f24:	eb 0f                	jmp    800f35 <vprintfmt+0x2a5>
  800f26:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800f2a:	48 89 d0             	mov    %rdx,%rax
  800f2d:	48 83 c2 08          	add    $0x8,%rdx
  800f31:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  800f35:	4c 8b 20             	mov    (%rax),%r12
  800f38:	4d 85 e4             	test   %r12,%r12
  800f3b:	75 0a                	jne    800f47 <vprintfmt+0x2b7>
  800f3d:	49 bc 0d 4a 80 00 00 	movabs $0x804a0d,%r12
  800f44:	00 00 00 
  800f47:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800f4b:	7e 3f                	jle    800f8c <vprintfmt+0x2fc>
  800f4d:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%rbp)
  800f51:	74 39                	je     800f8c <vprintfmt+0x2fc>
  800f53:	8b 45 d8             	mov    -0x28(%rbp),%eax
  800f56:	48 98                	cltq   
  800f58:	48 89 c6             	mov    %rax,%rsi
  800f5b:	4c 89 e7             	mov    %r12,%rdi
  800f5e:	48 b8 54 14 80 00 00 	movabs $0x801454,%rax
  800f65:	00 00 00 
  800f68:	ff d0                	callq  *%rax
  800f6a:	29 45 dc             	sub    %eax,-0x24(%rbp)
  800f6d:	eb 17                	jmp    800f86 <vprintfmt+0x2f6>
  800f6f:	0f be 55 d3          	movsbl -0x2d(%rbp),%edx
  800f73:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  800f77:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800f7b:	48 89 ce             	mov    %rcx,%rsi
  800f7e:	89 d7                	mov    %edx,%edi
  800f80:	ff d0                	callq  *%rax
  800f82:	83 6d dc 01          	subl   $0x1,-0x24(%rbp)
  800f86:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800f8a:	7f e3                	jg     800f6f <vprintfmt+0x2df>
  800f8c:	eb 37                	jmp    800fc5 <vprintfmt+0x335>
  800f8e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
  800f92:	74 1e                	je     800fb2 <vprintfmt+0x322>
  800f94:	83 fb 1f             	cmp    $0x1f,%ebx
  800f97:	7e 05                	jle    800f9e <vprintfmt+0x30e>
  800f99:	83 fb 7e             	cmp    $0x7e,%ebx
  800f9c:	7e 14                	jle    800fb2 <vprintfmt+0x322>
  800f9e:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  800fa2:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800fa6:	48 89 d6             	mov    %rdx,%rsi
  800fa9:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800fae:	ff d0                	callq  *%rax
  800fb0:	eb 0f                	jmp    800fc1 <vprintfmt+0x331>
  800fb2:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  800fb6:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800fba:	48 89 d6             	mov    %rdx,%rsi
  800fbd:	89 df                	mov    %ebx,%edi
  800fbf:	ff d0                	callq  *%rax
  800fc1:	83 6d dc 01          	subl   $0x1,-0x24(%rbp)
  800fc5:	4c 89 e0             	mov    %r12,%rax
  800fc8:	4c 8d 60 01          	lea    0x1(%rax),%r12
  800fcc:	0f b6 00             	movzbl (%rax),%eax
  800fcf:	0f be d8             	movsbl %al,%ebx
  800fd2:	85 db                	test   %ebx,%ebx
  800fd4:	74 10                	je     800fe6 <vprintfmt+0x356>
  800fd6:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
  800fda:	78 b2                	js     800f8e <vprintfmt+0x2fe>
  800fdc:	83 6d d8 01          	subl   $0x1,-0x28(%rbp)
  800fe0:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
  800fe4:	79 a8                	jns    800f8e <vprintfmt+0x2fe>
  800fe6:	eb 16                	jmp    800ffe <vprintfmt+0x36e>
  800fe8:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  800fec:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800ff0:	48 89 d6             	mov    %rdx,%rsi
  800ff3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ff8:	ff d0                	callq  *%rax
  800ffa:	83 6d dc 01          	subl   $0x1,-0x24(%rbp)
  800ffe:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  801002:	7f e4                	jg     800fe8 <vprintfmt+0x358>
  801004:	e9 90 01 00 00       	jmpq   801199 <vprintfmt+0x509>
  801009:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  80100d:	be 03 00 00 00       	mov    $0x3,%esi
  801012:	48 89 c7             	mov    %rax,%rdi
  801015:	48 b8 80 0b 80 00 00 	movabs $0x800b80,%rax
  80101c:	00 00 00 
  80101f:	ff d0                	callq  *%rax
  801021:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  801025:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801029:	48 85 c0             	test   %rax,%rax
  80102c:	79 1d                	jns    80104b <vprintfmt+0x3bb>
  80102e:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  801032:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  801036:	48 89 d6             	mov    %rdx,%rsi
  801039:	bf 2d 00 00 00       	mov    $0x2d,%edi
  80103e:	ff d0                	callq  *%rax
  801040:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801044:	48 f7 d8             	neg    %rax
  801047:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  80104b:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%rbp)
  801052:	e9 d5 00 00 00       	jmpq   80112c <vprintfmt+0x49c>
  801057:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  80105b:	be 03 00 00 00       	mov    $0x3,%esi
  801060:	48 89 c7             	mov    %rax,%rdi
  801063:	48 b8 70 0a 80 00 00 	movabs $0x800a70,%rax
  80106a:	00 00 00 
  80106d:	ff d0                	callq  *%rax
  80106f:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  801073:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%rbp)
  80107a:	e9 ad 00 00 00       	jmpq   80112c <vprintfmt+0x49c>
  80107f:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  801083:	be 03 00 00 00       	mov    $0x3,%esi
  801088:	48 89 c7             	mov    %rax,%rdi
  80108b:	48 b8 70 0a 80 00 00 	movabs $0x800a70,%rax
  801092:	00 00 00 
  801095:	ff d0                	callq  *%rax
  801097:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  80109b:	c7 45 e4 08 00 00 00 	movl   $0x8,-0x1c(%rbp)
  8010a2:	e9 85 00 00 00       	jmpq   80112c <vprintfmt+0x49c>
  8010a7:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  8010ab:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8010af:	48 89 d6             	mov    %rdx,%rsi
  8010b2:	bf 30 00 00 00       	mov    $0x30,%edi
  8010b7:	ff d0                	callq  *%rax
  8010b9:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  8010bd:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8010c1:	48 89 d6             	mov    %rdx,%rsi
  8010c4:	bf 78 00 00 00       	mov    $0x78,%edi
  8010c9:	ff d0                	callq  *%rax
  8010cb:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8010ce:	83 f8 30             	cmp    $0x30,%eax
  8010d1:	73 17                	jae    8010ea <vprintfmt+0x45a>
  8010d3:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8010d7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8010da:	89 c0                	mov    %eax,%eax
  8010dc:	48 01 d0             	add    %rdx,%rax
  8010df:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8010e2:	83 c2 08             	add    $0x8,%edx
  8010e5:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8010e8:	eb 0f                	jmp    8010f9 <vprintfmt+0x469>
  8010ea:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8010ee:	48 89 d0             	mov    %rdx,%rax
  8010f1:	48 83 c2 08          	add    $0x8,%rdx
  8010f5:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  8010f9:	48 8b 00             	mov    (%rax),%rax
  8010fc:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  801100:	c7 45 e4 10 00 00 00 	movl   $0x10,-0x1c(%rbp)
  801107:	eb 23                	jmp    80112c <vprintfmt+0x49c>
  801109:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  80110d:	be 03 00 00 00       	mov    $0x3,%esi
  801112:	48 89 c7             	mov    %rax,%rdi
  801115:	48 b8 70 0a 80 00 00 	movabs $0x800a70,%rax
  80111c:	00 00 00 
  80111f:	ff d0                	callq  *%rax
  801121:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  801125:	c7 45 e4 10 00 00 00 	movl   $0x10,-0x1c(%rbp)
  80112c:	44 0f be 45 d3       	movsbl -0x2d(%rbp),%r8d
  801131:	8b 4d e4             	mov    -0x1c(%rbp),%ecx
  801134:	8b 7d dc             	mov    -0x24(%rbp),%edi
  801137:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80113b:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  80113f:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  801143:	45 89 c1             	mov    %r8d,%r9d
  801146:	41 89 f8             	mov    %edi,%r8d
  801149:	48 89 c7             	mov    %rax,%rdi
  80114c:	48 b8 b5 09 80 00 00 	movabs $0x8009b5,%rax
  801153:	00 00 00 
  801156:	ff d0                	callq  *%rax
  801158:	eb 3f                	jmp    801199 <vprintfmt+0x509>
  80115a:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  80115e:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  801162:	48 89 d6             	mov    %rdx,%rsi
  801165:	89 df                	mov    %ebx,%edi
  801167:	ff d0                	callq  *%rax
  801169:	eb 2e                	jmp    801199 <vprintfmt+0x509>
  80116b:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  80116f:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  801173:	48 89 d6             	mov    %rdx,%rsi
  801176:	bf 25 00 00 00       	mov    $0x25,%edi
  80117b:	ff d0                	callq  *%rax
  80117d:	48 83 6d 98 01       	subq   $0x1,-0x68(%rbp)
  801182:	eb 05                	jmp    801189 <vprintfmt+0x4f9>
  801184:	48 83 6d 98 01       	subq   $0x1,-0x68(%rbp)
  801189:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80118d:	48 83 e8 01          	sub    $0x1,%rax
  801191:	0f b6 00             	movzbl (%rax),%eax
  801194:	3c 25                	cmp    $0x25,%al
  801196:	75 ec                	jne    801184 <vprintfmt+0x4f4>
  801198:	90                   	nop
  801199:	90                   	nop
  80119a:	e9 43 fb ff ff       	jmpq   800ce2 <vprintfmt+0x52>
  80119f:	48 83 c4 60          	add    $0x60,%rsp
  8011a3:	5b                   	pop    %rbx
  8011a4:	41 5c                	pop    %r12
  8011a6:	5d                   	pop    %rbp
  8011a7:	c3                   	retq   

00000000008011a8 <printfmt>:
  8011a8:	55                   	push   %rbp
  8011a9:	48 89 e5             	mov    %rsp,%rbp
  8011ac:	48 81 ec f0 00 00 00 	sub    $0xf0,%rsp
  8011b3:	48 89 bd 28 ff ff ff 	mov    %rdi,-0xd8(%rbp)
  8011ba:	48 89 b5 20 ff ff ff 	mov    %rsi,-0xe0(%rbp)
  8011c1:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8011c8:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8011cf:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8011d6:	84 c0                	test   %al,%al
  8011d8:	74 20                	je     8011fa <printfmt+0x52>
  8011da:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8011de:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8011e2:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8011e6:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8011ea:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8011ee:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8011f2:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8011f6:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  8011fa:	48 89 95 18 ff ff ff 	mov    %rdx,-0xe8(%rbp)
  801201:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  801208:	00 00 00 
  80120b:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  801212:	00 00 00 
  801215:	48 8d 45 10          	lea    0x10(%rbp),%rax
  801219:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  801220:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  801227:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  80122e:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  801235:	48 8b 95 18 ff ff ff 	mov    -0xe8(%rbp),%rdx
  80123c:	48 8b b5 20 ff ff ff 	mov    -0xe0(%rbp),%rsi
  801243:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  80124a:	48 89 c7             	mov    %rax,%rdi
  80124d:	48 b8 90 0c 80 00 00 	movabs $0x800c90,%rax
  801254:	00 00 00 
  801257:	ff d0                	callq  *%rax
  801259:	c9                   	leaveq 
  80125a:	c3                   	retq   

000000000080125b <sprintputch>:
  80125b:	55                   	push   %rbp
  80125c:	48 89 e5             	mov    %rsp,%rbp
  80125f:	48 83 ec 10          	sub    $0x10,%rsp
  801263:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801266:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  80126a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80126e:	8b 40 10             	mov    0x10(%rax),%eax
  801271:	8d 50 01             	lea    0x1(%rax),%edx
  801274:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801278:	89 50 10             	mov    %edx,0x10(%rax)
  80127b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80127f:	48 8b 10             	mov    (%rax),%rdx
  801282:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801286:	48 8b 40 08          	mov    0x8(%rax),%rax
  80128a:	48 39 c2             	cmp    %rax,%rdx
  80128d:	73 17                	jae    8012a6 <sprintputch+0x4b>
  80128f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801293:	48 8b 00             	mov    (%rax),%rax
  801296:	48 8d 48 01          	lea    0x1(%rax),%rcx
  80129a:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  80129e:	48 89 0a             	mov    %rcx,(%rdx)
  8012a1:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8012a4:	88 10                	mov    %dl,(%rax)
  8012a6:	c9                   	leaveq 
  8012a7:	c3                   	retq   

00000000008012a8 <vsnprintf>:
  8012a8:	55                   	push   %rbp
  8012a9:	48 89 e5             	mov    %rsp,%rbp
  8012ac:	48 83 ec 50          	sub    $0x50,%rsp
  8012b0:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  8012b4:	89 75 c4             	mov    %esi,-0x3c(%rbp)
  8012b7:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  8012bb:	48 89 4d b0          	mov    %rcx,-0x50(%rbp)
  8012bf:	48 8d 45 e8          	lea    -0x18(%rbp),%rax
  8012c3:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  8012c7:	48 8b 0a             	mov    (%rdx),%rcx
  8012ca:	48 89 08             	mov    %rcx,(%rax)
  8012cd:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  8012d1:	48 89 48 08          	mov    %rcx,0x8(%rax)
  8012d5:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  8012d9:	48 89 50 10          	mov    %rdx,0x10(%rax)
  8012dd:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8012e1:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8012e5:	8b 45 c4             	mov    -0x3c(%rbp),%eax
  8012e8:	48 98                	cltq   
  8012ea:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  8012ee:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8012f2:	48 01 d0             	add    %rdx,%rax
  8012f5:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
  8012f9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%rbp)
  801300:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
  801305:	74 06                	je     80130d <vsnprintf+0x65>
  801307:	83 7d c4 00          	cmpl   $0x0,-0x3c(%rbp)
  80130b:	7f 07                	jg     801314 <vsnprintf+0x6c>
  80130d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801312:	eb 2f                	jmp    801343 <vsnprintf+0x9b>
  801314:	48 8d 4d e8          	lea    -0x18(%rbp),%rcx
  801318:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  80131c:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  801320:	48 89 c6             	mov    %rax,%rsi
  801323:	48 bf 5b 12 80 00 00 	movabs $0x80125b,%rdi
  80132a:	00 00 00 
  80132d:	48 b8 90 0c 80 00 00 	movabs $0x800c90,%rax
  801334:	00 00 00 
  801337:	ff d0                	callq  *%rax
  801339:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80133d:	c6 00 00             	movb   $0x0,(%rax)
  801340:	8b 45 e0             	mov    -0x20(%rbp),%eax
  801343:	c9                   	leaveq 
  801344:	c3                   	retq   

0000000000801345 <snprintf>:
  801345:	55                   	push   %rbp
  801346:	48 89 e5             	mov    %rsp,%rbp
  801349:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  801350:	48 89 bd 08 ff ff ff 	mov    %rdi,-0xf8(%rbp)
  801357:	89 b5 04 ff ff ff    	mov    %esi,-0xfc(%rbp)
  80135d:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  801364:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80136b:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  801372:	84 c0                	test   %al,%al
  801374:	74 20                	je     801396 <snprintf+0x51>
  801376:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80137a:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80137e:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  801382:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  801386:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80138a:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80138e:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  801392:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  801396:	48 89 95 f8 fe ff ff 	mov    %rdx,-0x108(%rbp)
  80139d:	c7 85 30 ff ff ff 18 	movl   $0x18,-0xd0(%rbp)
  8013a4:	00 00 00 
  8013a7:	c7 85 34 ff ff ff 30 	movl   $0x30,-0xcc(%rbp)
  8013ae:	00 00 00 
  8013b1:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8013b5:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  8013bc:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8013c3:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8013ca:	48 8d 85 18 ff ff ff 	lea    -0xe8(%rbp),%rax
  8013d1:	48 8d 95 30 ff ff ff 	lea    -0xd0(%rbp),%rdx
  8013d8:	48 8b 0a             	mov    (%rdx),%rcx
  8013db:	48 89 08             	mov    %rcx,(%rax)
  8013de:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  8013e2:	48 89 48 08          	mov    %rcx,0x8(%rax)
  8013e6:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  8013ea:	48 89 50 10          	mov    %rdx,0x10(%rax)
  8013ee:	48 8d 8d 18 ff ff ff 	lea    -0xe8(%rbp),%rcx
  8013f5:	48 8b 95 f8 fe ff ff 	mov    -0x108(%rbp),%rdx
  8013fc:	8b b5 04 ff ff ff    	mov    -0xfc(%rbp),%esi
  801402:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
  801409:	48 89 c7             	mov    %rax,%rdi
  80140c:	48 b8 a8 12 80 00 00 	movabs $0x8012a8,%rax
  801413:	00 00 00 
  801416:	ff d0                	callq  *%rax
  801418:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%rbp)
  80141e:	8b 85 4c ff ff ff    	mov    -0xb4(%rbp),%eax
  801424:	c9                   	leaveq 
  801425:	c3                   	retq   

0000000000801426 <strlen>:
  801426:	55                   	push   %rbp
  801427:	48 89 e5             	mov    %rsp,%rbp
  80142a:	48 83 ec 18          	sub    $0x18,%rsp
  80142e:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  801432:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  801439:	eb 09                	jmp    801444 <strlen+0x1e>
  80143b:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  80143f:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  801444:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801448:	0f b6 00             	movzbl (%rax),%eax
  80144b:	84 c0                	test   %al,%al
  80144d:	75 ec                	jne    80143b <strlen+0x15>
  80144f:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801452:	c9                   	leaveq 
  801453:	c3                   	retq   

0000000000801454 <strnlen>:
  801454:	55                   	push   %rbp
  801455:	48 89 e5             	mov    %rsp,%rbp
  801458:	48 83 ec 20          	sub    $0x20,%rsp
  80145c:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  801460:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  801464:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  80146b:	eb 0e                	jmp    80147b <strnlen+0x27>
  80146d:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  801471:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  801476:	48 83 6d e0 01       	subq   $0x1,-0x20(%rbp)
  80147b:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  801480:	74 0b                	je     80148d <strnlen+0x39>
  801482:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801486:	0f b6 00             	movzbl (%rax),%eax
  801489:	84 c0                	test   %al,%al
  80148b:	75 e0                	jne    80146d <strnlen+0x19>
  80148d:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801490:	c9                   	leaveq 
  801491:	c3                   	retq   

0000000000801492 <strcpy>:
  801492:	55                   	push   %rbp
  801493:	48 89 e5             	mov    %rsp,%rbp
  801496:	48 83 ec 20          	sub    $0x20,%rsp
  80149a:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80149e:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8014a2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8014a6:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8014aa:	90                   	nop
  8014ab:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8014af:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8014b3:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8014b7:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8014bb:	48 8d 4a 01          	lea    0x1(%rdx),%rcx
  8014bf:	48 89 4d e0          	mov    %rcx,-0x20(%rbp)
  8014c3:	0f b6 12             	movzbl (%rdx),%edx
  8014c6:	88 10                	mov    %dl,(%rax)
  8014c8:	0f b6 00             	movzbl (%rax),%eax
  8014cb:	84 c0                	test   %al,%al
  8014cd:	75 dc                	jne    8014ab <strcpy+0x19>
  8014cf:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8014d3:	c9                   	leaveq 
  8014d4:	c3                   	retq   

00000000008014d5 <strcat>:
  8014d5:	55                   	push   %rbp
  8014d6:	48 89 e5             	mov    %rsp,%rbp
  8014d9:	48 83 ec 20          	sub    $0x20,%rsp
  8014dd:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8014e1:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8014e5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8014e9:	48 89 c7             	mov    %rax,%rdi
  8014ec:	48 b8 26 14 80 00 00 	movabs $0x801426,%rax
  8014f3:	00 00 00 
  8014f6:	ff d0                	callq  *%rax
  8014f8:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8014fb:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8014fe:	48 63 d0             	movslq %eax,%rdx
  801501:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801505:	48 01 c2             	add    %rax,%rdx
  801508:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80150c:	48 89 c6             	mov    %rax,%rsi
  80150f:	48 89 d7             	mov    %rdx,%rdi
  801512:	48 b8 92 14 80 00 00 	movabs $0x801492,%rax
  801519:	00 00 00 
  80151c:	ff d0                	callq  *%rax
  80151e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801522:	c9                   	leaveq 
  801523:	c3                   	retq   

0000000000801524 <strncpy>:
  801524:	55                   	push   %rbp
  801525:	48 89 e5             	mov    %rsp,%rbp
  801528:	48 83 ec 28          	sub    $0x28,%rsp
  80152c:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  801530:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  801534:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  801538:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80153c:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  801540:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  801547:	00 
  801548:	eb 2a                	jmp    801574 <strncpy+0x50>
  80154a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80154e:	48 8d 50 01          	lea    0x1(%rax),%rdx
  801552:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  801556:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  80155a:	0f b6 12             	movzbl (%rdx),%edx
  80155d:	88 10                	mov    %dl,(%rax)
  80155f:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  801563:	0f b6 00             	movzbl (%rax),%eax
  801566:	84 c0                	test   %al,%al
  801568:	74 05                	je     80156f <strncpy+0x4b>
  80156a:	48 83 45 e0 01       	addq   $0x1,-0x20(%rbp)
  80156f:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  801574:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801578:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  80157c:	72 cc                	jb     80154a <strncpy+0x26>
  80157e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801582:	c9                   	leaveq 
  801583:	c3                   	retq   

0000000000801584 <strlcpy>:
  801584:	55                   	push   %rbp
  801585:	48 89 e5             	mov    %rsp,%rbp
  801588:	48 83 ec 28          	sub    $0x28,%rsp
  80158c:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  801590:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  801594:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  801598:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80159c:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8015a0:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  8015a5:	74 3d                	je     8015e4 <strlcpy+0x60>
  8015a7:	eb 1d                	jmp    8015c6 <strlcpy+0x42>
  8015a9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8015ad:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8015b1:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8015b5:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8015b9:	48 8d 4a 01          	lea    0x1(%rdx),%rcx
  8015bd:	48 89 4d e0          	mov    %rcx,-0x20(%rbp)
  8015c1:	0f b6 12             	movzbl (%rdx),%edx
  8015c4:	88 10                	mov    %dl,(%rax)
  8015c6:	48 83 6d d8 01       	subq   $0x1,-0x28(%rbp)
  8015cb:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  8015d0:	74 0b                	je     8015dd <strlcpy+0x59>
  8015d2:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8015d6:	0f b6 00             	movzbl (%rax),%eax
  8015d9:	84 c0                	test   %al,%al
  8015db:	75 cc                	jne    8015a9 <strlcpy+0x25>
  8015dd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8015e1:	c6 00 00             	movb   $0x0,(%rax)
  8015e4:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8015e8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8015ec:	48 29 c2             	sub    %rax,%rdx
  8015ef:	48 89 d0             	mov    %rdx,%rax
  8015f2:	c9                   	leaveq 
  8015f3:	c3                   	retq   

00000000008015f4 <strcmp>:
  8015f4:	55                   	push   %rbp
  8015f5:	48 89 e5             	mov    %rsp,%rbp
  8015f8:	48 83 ec 10          	sub    $0x10,%rsp
  8015fc:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  801600:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801604:	eb 0a                	jmp    801610 <strcmp+0x1c>
  801606:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  80160b:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  801610:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801614:	0f b6 00             	movzbl (%rax),%eax
  801617:	84 c0                	test   %al,%al
  801619:	74 12                	je     80162d <strcmp+0x39>
  80161b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80161f:	0f b6 10             	movzbl (%rax),%edx
  801622:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801626:	0f b6 00             	movzbl (%rax),%eax
  801629:	38 c2                	cmp    %al,%dl
  80162b:	74 d9                	je     801606 <strcmp+0x12>
  80162d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801631:	0f b6 00             	movzbl (%rax),%eax
  801634:	0f b6 d0             	movzbl %al,%edx
  801637:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80163b:	0f b6 00             	movzbl (%rax),%eax
  80163e:	0f b6 c0             	movzbl %al,%eax
  801641:	29 c2                	sub    %eax,%edx
  801643:	89 d0                	mov    %edx,%eax
  801645:	c9                   	leaveq 
  801646:	c3                   	retq   

0000000000801647 <strncmp>:
  801647:	55                   	push   %rbp
  801648:	48 89 e5             	mov    %rsp,%rbp
  80164b:	48 83 ec 18          	sub    $0x18,%rsp
  80164f:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  801653:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801657:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  80165b:	eb 0f                	jmp    80166c <strncmp+0x25>
  80165d:	48 83 6d e8 01       	subq   $0x1,-0x18(%rbp)
  801662:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  801667:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  80166c:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  801671:	74 1d                	je     801690 <strncmp+0x49>
  801673:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801677:	0f b6 00             	movzbl (%rax),%eax
  80167a:	84 c0                	test   %al,%al
  80167c:	74 12                	je     801690 <strncmp+0x49>
  80167e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801682:	0f b6 10             	movzbl (%rax),%edx
  801685:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801689:	0f b6 00             	movzbl (%rax),%eax
  80168c:	38 c2                	cmp    %al,%dl
  80168e:	74 cd                	je     80165d <strncmp+0x16>
  801690:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  801695:	75 07                	jne    80169e <strncmp+0x57>
  801697:	b8 00 00 00 00       	mov    $0x0,%eax
  80169c:	eb 18                	jmp    8016b6 <strncmp+0x6f>
  80169e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8016a2:	0f b6 00             	movzbl (%rax),%eax
  8016a5:	0f b6 d0             	movzbl %al,%edx
  8016a8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8016ac:	0f b6 00             	movzbl (%rax),%eax
  8016af:	0f b6 c0             	movzbl %al,%eax
  8016b2:	29 c2                	sub    %eax,%edx
  8016b4:	89 d0                	mov    %edx,%eax
  8016b6:	c9                   	leaveq 
  8016b7:	c3                   	retq   

00000000008016b8 <strchr>:
  8016b8:	55                   	push   %rbp
  8016b9:	48 89 e5             	mov    %rsp,%rbp
  8016bc:	48 83 ec 0c          	sub    $0xc,%rsp
  8016c0:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8016c4:	89 f0                	mov    %esi,%eax
  8016c6:	88 45 f4             	mov    %al,-0xc(%rbp)
  8016c9:	eb 17                	jmp    8016e2 <strchr+0x2a>
  8016cb:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8016cf:	0f b6 00             	movzbl (%rax),%eax
  8016d2:	3a 45 f4             	cmp    -0xc(%rbp),%al
  8016d5:	75 06                	jne    8016dd <strchr+0x25>
  8016d7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8016db:	eb 15                	jmp    8016f2 <strchr+0x3a>
  8016dd:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  8016e2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8016e6:	0f b6 00             	movzbl (%rax),%eax
  8016e9:	84 c0                	test   %al,%al
  8016eb:	75 de                	jne    8016cb <strchr+0x13>
  8016ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f2:	c9                   	leaveq 
  8016f3:	c3                   	retq   

00000000008016f4 <strfind>:
  8016f4:	55                   	push   %rbp
  8016f5:	48 89 e5             	mov    %rsp,%rbp
  8016f8:	48 83 ec 0c          	sub    $0xc,%rsp
  8016fc:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  801700:	89 f0                	mov    %esi,%eax
  801702:	88 45 f4             	mov    %al,-0xc(%rbp)
  801705:	eb 13                	jmp    80171a <strfind+0x26>
  801707:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80170b:	0f b6 00             	movzbl (%rax),%eax
  80170e:	3a 45 f4             	cmp    -0xc(%rbp),%al
  801711:	75 02                	jne    801715 <strfind+0x21>
  801713:	eb 10                	jmp    801725 <strfind+0x31>
  801715:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  80171a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80171e:	0f b6 00             	movzbl (%rax),%eax
  801721:	84 c0                	test   %al,%al
  801723:	75 e2                	jne    801707 <strfind+0x13>
  801725:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801729:	c9                   	leaveq 
  80172a:	c3                   	retq   

000000000080172b <memset>:
  80172b:	55                   	push   %rbp
  80172c:	48 89 e5             	mov    %rsp,%rbp
  80172f:	48 83 ec 18          	sub    $0x18,%rsp
  801733:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  801737:	89 75 f4             	mov    %esi,-0xc(%rbp)
  80173a:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  80173e:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  801743:	75 06                	jne    80174b <memset+0x20>
  801745:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801749:	eb 69                	jmp    8017b4 <memset+0x89>
  80174b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80174f:	83 e0 03             	and    $0x3,%eax
  801752:	48 85 c0             	test   %rax,%rax
  801755:	75 48                	jne    80179f <memset+0x74>
  801757:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80175b:	83 e0 03             	and    $0x3,%eax
  80175e:	48 85 c0             	test   %rax,%rax
  801761:	75 3c                	jne    80179f <memset+0x74>
  801763:	81 65 f4 ff 00 00 00 	andl   $0xff,-0xc(%rbp)
  80176a:	8b 45 f4             	mov    -0xc(%rbp),%eax
  80176d:	c1 e0 18             	shl    $0x18,%eax
  801770:	89 c2                	mov    %eax,%edx
  801772:	8b 45 f4             	mov    -0xc(%rbp),%eax
  801775:	c1 e0 10             	shl    $0x10,%eax
  801778:	09 c2                	or     %eax,%edx
  80177a:	8b 45 f4             	mov    -0xc(%rbp),%eax
  80177d:	c1 e0 08             	shl    $0x8,%eax
  801780:	09 d0                	or     %edx,%eax
  801782:	09 45 f4             	or     %eax,-0xc(%rbp)
  801785:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801789:	48 c1 e8 02          	shr    $0x2,%rax
  80178d:	48 89 c1             	mov    %rax,%rcx
  801790:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  801794:	8b 45 f4             	mov    -0xc(%rbp),%eax
  801797:	48 89 d7             	mov    %rdx,%rdi
  80179a:	fc                   	cld    
  80179b:	f3 ab                	rep stos %eax,%es:(%rdi)
  80179d:	eb 11                	jmp    8017b0 <memset+0x85>
  80179f:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8017a3:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8017a6:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  8017aa:	48 89 d7             	mov    %rdx,%rdi
  8017ad:	fc                   	cld    
  8017ae:	f3 aa                	rep stos %al,%es:(%rdi)
  8017b0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8017b4:	c9                   	leaveq 
  8017b5:	c3                   	retq   

00000000008017b6 <memmove>:
  8017b6:	55                   	push   %rbp
  8017b7:	48 89 e5             	mov    %rsp,%rbp
  8017ba:	48 83 ec 28          	sub    $0x28,%rsp
  8017be:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8017c2:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8017c6:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  8017ca:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8017ce:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8017d2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8017d6:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  8017da:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8017de:	48 3b 45 f0          	cmp    -0x10(%rbp),%rax
  8017e2:	0f 83 88 00 00 00    	jae    801870 <memmove+0xba>
  8017e8:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8017ec:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8017f0:	48 01 d0             	add    %rdx,%rax
  8017f3:	48 3b 45 f0          	cmp    -0x10(%rbp),%rax
  8017f7:	76 77                	jbe    801870 <memmove+0xba>
  8017f9:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8017fd:	48 01 45 f8          	add    %rax,-0x8(%rbp)
  801801:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801805:	48 01 45 f0          	add    %rax,-0x10(%rbp)
  801809:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80180d:	83 e0 03             	and    $0x3,%eax
  801810:	48 85 c0             	test   %rax,%rax
  801813:	75 3b                	jne    801850 <memmove+0x9a>
  801815:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801819:	83 e0 03             	and    $0x3,%eax
  80181c:	48 85 c0             	test   %rax,%rax
  80181f:	75 2f                	jne    801850 <memmove+0x9a>
  801821:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801825:	83 e0 03             	and    $0x3,%eax
  801828:	48 85 c0             	test   %rax,%rax
  80182b:	75 23                	jne    801850 <memmove+0x9a>
  80182d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801831:	48 83 e8 04          	sub    $0x4,%rax
  801835:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  801839:	48 83 ea 04          	sub    $0x4,%rdx
  80183d:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  801841:	48 c1 e9 02          	shr    $0x2,%rcx
  801845:	48 89 c7             	mov    %rax,%rdi
  801848:	48 89 d6             	mov    %rdx,%rsi
  80184b:	fd                   	std    
  80184c:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  80184e:	eb 1d                	jmp    80186d <memmove+0xb7>
  801850:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801854:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  801858:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80185c:	48 8d 70 ff          	lea    -0x1(%rax),%rsi
  801860:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801864:	48 89 d7             	mov    %rdx,%rdi
  801867:	48 89 c1             	mov    %rax,%rcx
  80186a:	fd                   	std    
  80186b:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
  80186d:	fc                   	cld    
  80186e:	eb 57                	jmp    8018c7 <memmove+0x111>
  801870:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801874:	83 e0 03             	and    $0x3,%eax
  801877:	48 85 c0             	test   %rax,%rax
  80187a:	75 36                	jne    8018b2 <memmove+0xfc>
  80187c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801880:	83 e0 03             	and    $0x3,%eax
  801883:	48 85 c0             	test   %rax,%rax
  801886:	75 2a                	jne    8018b2 <memmove+0xfc>
  801888:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80188c:	83 e0 03             	and    $0x3,%eax
  80188f:	48 85 c0             	test   %rax,%rax
  801892:	75 1e                	jne    8018b2 <memmove+0xfc>
  801894:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801898:	48 c1 e8 02          	shr    $0x2,%rax
  80189c:	48 89 c1             	mov    %rax,%rcx
  80189f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8018a3:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8018a7:	48 89 c7             	mov    %rax,%rdi
  8018aa:	48 89 d6             	mov    %rdx,%rsi
  8018ad:	fc                   	cld    
  8018ae:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8018b0:	eb 15                	jmp    8018c7 <memmove+0x111>
  8018b2:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8018b6:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8018ba:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  8018be:	48 89 c7             	mov    %rax,%rdi
  8018c1:	48 89 d6             	mov    %rdx,%rsi
  8018c4:	fc                   	cld    
  8018c5:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
  8018c7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8018cb:	c9                   	leaveq 
  8018cc:	c3                   	retq   

00000000008018cd <memcpy>:
  8018cd:	55                   	push   %rbp
  8018ce:	48 89 e5             	mov    %rsp,%rbp
  8018d1:	48 83 ec 18          	sub    $0x18,%rsp
  8018d5:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8018d9:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8018dd:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8018e1:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8018e5:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  8018e9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8018ed:	48 89 ce             	mov    %rcx,%rsi
  8018f0:	48 89 c7             	mov    %rax,%rdi
  8018f3:	48 b8 b6 17 80 00 00 	movabs $0x8017b6,%rax
  8018fa:	00 00 00 
  8018fd:	ff d0                	callq  *%rax
  8018ff:	c9                   	leaveq 
  801900:	c3                   	retq   

0000000000801901 <memcmp>:
  801901:	55                   	push   %rbp
  801902:	48 89 e5             	mov    %rsp,%rbp
  801905:	48 83 ec 28          	sub    $0x28,%rsp
  801909:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80190d:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  801911:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  801915:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801919:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  80191d:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  801921:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  801925:	eb 36                	jmp    80195d <memcmp+0x5c>
  801927:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80192b:	0f b6 10             	movzbl (%rax),%edx
  80192e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801932:	0f b6 00             	movzbl (%rax),%eax
  801935:	38 c2                	cmp    %al,%dl
  801937:	74 1a                	je     801953 <memcmp+0x52>
  801939:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80193d:	0f b6 00             	movzbl (%rax),%eax
  801940:	0f b6 d0             	movzbl %al,%edx
  801943:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801947:	0f b6 00             	movzbl (%rax),%eax
  80194a:	0f b6 c0             	movzbl %al,%eax
  80194d:	29 c2                	sub    %eax,%edx
  80194f:	89 d0                	mov    %edx,%eax
  801951:	eb 20                	jmp    801973 <memcmp+0x72>
  801953:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  801958:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  80195d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801961:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  801965:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  801969:	48 85 c0             	test   %rax,%rax
  80196c:	75 b9                	jne    801927 <memcmp+0x26>
  80196e:	b8 00 00 00 00       	mov    $0x0,%eax
  801973:	c9                   	leaveq 
  801974:	c3                   	retq   

0000000000801975 <memfind>:
  801975:	55                   	push   %rbp
  801976:	48 89 e5             	mov    %rsp,%rbp
  801979:	48 83 ec 28          	sub    $0x28,%rsp
  80197d:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  801981:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  801984:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  801988:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80198c:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  801990:	48 01 d0             	add    %rdx,%rax
  801993:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  801997:	eb 15                	jmp    8019ae <memfind+0x39>
  801999:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80199d:	0f b6 10             	movzbl (%rax),%edx
  8019a0:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  8019a3:	38 c2                	cmp    %al,%dl
  8019a5:	75 02                	jne    8019a9 <memfind+0x34>
  8019a7:	eb 0f                	jmp    8019b8 <memfind+0x43>
  8019a9:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  8019ae:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8019b2:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
  8019b6:	72 e1                	jb     801999 <memfind+0x24>
  8019b8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8019bc:	c9                   	leaveq 
  8019bd:	c3                   	retq   

00000000008019be <strtol>:
  8019be:	55                   	push   %rbp
  8019bf:	48 89 e5             	mov    %rsp,%rbp
  8019c2:	48 83 ec 34          	sub    $0x34,%rsp
  8019c6:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  8019ca:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  8019ce:	89 55 cc             	mov    %edx,-0x34(%rbp)
  8019d1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8019d8:	48 c7 45 f0 00 00 00 	movq   $0x0,-0x10(%rbp)
  8019df:	00 
  8019e0:	eb 05                	jmp    8019e7 <strtol+0x29>
  8019e2:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  8019e7:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8019eb:	0f b6 00             	movzbl (%rax),%eax
  8019ee:	3c 20                	cmp    $0x20,%al
  8019f0:	74 f0                	je     8019e2 <strtol+0x24>
  8019f2:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8019f6:	0f b6 00             	movzbl (%rax),%eax
  8019f9:	3c 09                	cmp    $0x9,%al
  8019fb:	74 e5                	je     8019e2 <strtol+0x24>
  8019fd:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801a01:	0f b6 00             	movzbl (%rax),%eax
  801a04:	3c 2b                	cmp    $0x2b,%al
  801a06:	75 07                	jne    801a0f <strtol+0x51>
  801a08:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  801a0d:	eb 17                	jmp    801a26 <strtol+0x68>
  801a0f:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801a13:	0f b6 00             	movzbl (%rax),%eax
  801a16:	3c 2d                	cmp    $0x2d,%al
  801a18:	75 0c                	jne    801a26 <strtol+0x68>
  801a1a:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  801a1f:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)
  801a26:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  801a2a:	74 06                	je     801a32 <strtol+0x74>
  801a2c:	83 7d cc 10          	cmpl   $0x10,-0x34(%rbp)
  801a30:	75 28                	jne    801a5a <strtol+0x9c>
  801a32:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801a36:	0f b6 00             	movzbl (%rax),%eax
  801a39:	3c 30                	cmp    $0x30,%al
  801a3b:	75 1d                	jne    801a5a <strtol+0x9c>
  801a3d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801a41:	48 83 c0 01          	add    $0x1,%rax
  801a45:	0f b6 00             	movzbl (%rax),%eax
  801a48:	3c 78                	cmp    $0x78,%al
  801a4a:	75 0e                	jne    801a5a <strtol+0x9c>
  801a4c:	48 83 45 d8 02       	addq   $0x2,-0x28(%rbp)
  801a51:	c7 45 cc 10 00 00 00 	movl   $0x10,-0x34(%rbp)
  801a58:	eb 2c                	jmp    801a86 <strtol+0xc8>
  801a5a:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  801a5e:	75 19                	jne    801a79 <strtol+0xbb>
  801a60:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801a64:	0f b6 00             	movzbl (%rax),%eax
  801a67:	3c 30                	cmp    $0x30,%al
  801a69:	75 0e                	jne    801a79 <strtol+0xbb>
  801a6b:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  801a70:	c7 45 cc 08 00 00 00 	movl   $0x8,-0x34(%rbp)
  801a77:	eb 0d                	jmp    801a86 <strtol+0xc8>
  801a79:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  801a7d:	75 07                	jne    801a86 <strtol+0xc8>
  801a7f:	c7 45 cc 0a 00 00 00 	movl   $0xa,-0x34(%rbp)
  801a86:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801a8a:	0f b6 00             	movzbl (%rax),%eax
  801a8d:	3c 2f                	cmp    $0x2f,%al
  801a8f:	7e 1d                	jle    801aae <strtol+0xf0>
  801a91:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801a95:	0f b6 00             	movzbl (%rax),%eax
  801a98:	3c 39                	cmp    $0x39,%al
  801a9a:	7f 12                	jg     801aae <strtol+0xf0>
  801a9c:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801aa0:	0f b6 00             	movzbl (%rax),%eax
  801aa3:	0f be c0             	movsbl %al,%eax
  801aa6:	83 e8 30             	sub    $0x30,%eax
  801aa9:	89 45 ec             	mov    %eax,-0x14(%rbp)
  801aac:	eb 4e                	jmp    801afc <strtol+0x13e>
  801aae:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801ab2:	0f b6 00             	movzbl (%rax),%eax
  801ab5:	3c 60                	cmp    $0x60,%al
  801ab7:	7e 1d                	jle    801ad6 <strtol+0x118>
  801ab9:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801abd:	0f b6 00             	movzbl (%rax),%eax
  801ac0:	3c 7a                	cmp    $0x7a,%al
  801ac2:	7f 12                	jg     801ad6 <strtol+0x118>
  801ac4:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801ac8:	0f b6 00             	movzbl (%rax),%eax
  801acb:	0f be c0             	movsbl %al,%eax
  801ace:	83 e8 57             	sub    $0x57,%eax
  801ad1:	89 45 ec             	mov    %eax,-0x14(%rbp)
  801ad4:	eb 26                	jmp    801afc <strtol+0x13e>
  801ad6:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801ada:	0f b6 00             	movzbl (%rax),%eax
  801add:	3c 40                	cmp    $0x40,%al
  801adf:	7e 48                	jle    801b29 <strtol+0x16b>
  801ae1:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801ae5:	0f b6 00             	movzbl (%rax),%eax
  801ae8:	3c 5a                	cmp    $0x5a,%al
  801aea:	7f 3d                	jg     801b29 <strtol+0x16b>
  801aec:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801af0:	0f b6 00             	movzbl (%rax),%eax
  801af3:	0f be c0             	movsbl %al,%eax
  801af6:	83 e8 37             	sub    $0x37,%eax
  801af9:	89 45 ec             	mov    %eax,-0x14(%rbp)
  801afc:	8b 45 ec             	mov    -0x14(%rbp),%eax
  801aff:	3b 45 cc             	cmp    -0x34(%rbp),%eax
  801b02:	7c 02                	jl     801b06 <strtol+0x148>
  801b04:	eb 23                	jmp    801b29 <strtol+0x16b>
  801b06:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  801b0b:	8b 45 cc             	mov    -0x34(%rbp),%eax
  801b0e:	48 98                	cltq   
  801b10:	48 0f af 45 f0       	imul   -0x10(%rbp),%rax
  801b15:	48 89 c2             	mov    %rax,%rdx
  801b18:	8b 45 ec             	mov    -0x14(%rbp),%eax
  801b1b:	48 98                	cltq   
  801b1d:	48 01 d0             	add    %rdx,%rax
  801b20:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  801b24:	e9 5d ff ff ff       	jmpq   801a86 <strtol+0xc8>
  801b29:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  801b2e:	74 0b                	je     801b3b <strtol+0x17d>
  801b30:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  801b34:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  801b38:	48 89 10             	mov    %rdx,(%rax)
  801b3b:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  801b3f:	74 09                	je     801b4a <strtol+0x18c>
  801b41:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801b45:	48 f7 d8             	neg    %rax
  801b48:	eb 04                	jmp    801b4e <strtol+0x190>
  801b4a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  801b4e:	c9                   	leaveq 
  801b4f:	c3                   	retq   

0000000000801b50 <strstr>:
  801b50:	55                   	push   %rbp
  801b51:	48 89 e5             	mov    %rsp,%rbp
  801b54:	48 83 ec 30          	sub    $0x30,%rsp
  801b58:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  801b5c:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  801b60:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  801b64:	48 8d 50 01          	lea    0x1(%rax),%rdx
  801b68:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  801b6c:	0f b6 00             	movzbl (%rax),%eax
  801b6f:	88 45 ff             	mov    %al,-0x1(%rbp)
  801b72:	80 7d ff 00          	cmpb   $0x0,-0x1(%rbp)
  801b76:	75 06                	jne    801b7e <strstr+0x2e>
  801b78:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801b7c:	eb 6b                	jmp    801be9 <strstr+0x99>
  801b7e:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  801b82:	48 89 c7             	mov    %rax,%rdi
  801b85:	48 b8 26 14 80 00 00 	movabs $0x801426,%rax
  801b8c:	00 00 00 
  801b8f:	ff d0                	callq  *%rax
  801b91:	48 98                	cltq   
  801b93:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  801b97:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801b9b:	48 8d 50 01          	lea    0x1(%rax),%rdx
  801b9f:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  801ba3:	0f b6 00             	movzbl (%rax),%eax
  801ba6:	88 45 ef             	mov    %al,-0x11(%rbp)
  801ba9:	80 7d ef 00          	cmpb   $0x0,-0x11(%rbp)
  801bad:	75 07                	jne    801bb6 <strstr+0x66>
  801baf:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb4:	eb 33                	jmp    801be9 <strstr+0x99>
  801bb6:	0f b6 45 ef          	movzbl -0x11(%rbp),%eax
  801bba:	3a 45 ff             	cmp    -0x1(%rbp),%al
  801bbd:	75 d8                	jne    801b97 <strstr+0x47>
  801bbf:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801bc3:	48 8b 4d d0          	mov    -0x30(%rbp),%rcx
  801bc7:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801bcb:	48 89 ce             	mov    %rcx,%rsi
  801bce:	48 89 c7             	mov    %rax,%rdi
  801bd1:	48 b8 47 16 80 00 00 	movabs $0x801647,%rax
  801bd8:	00 00 00 
  801bdb:	ff d0                	callq  *%rax
  801bdd:	85 c0                	test   %eax,%eax
  801bdf:	75 b6                	jne    801b97 <strstr+0x47>
  801be1:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  801be5:	48 83 e8 01          	sub    $0x1,%rax
  801be9:	c9                   	leaveq 
  801bea:	c3                   	retq   

0000000000801beb <syscall>:
  801beb:	55                   	push   %rbp
  801bec:	48 89 e5             	mov    %rsp,%rbp
  801bef:	53                   	push   %rbx
  801bf0:	48 83 ec 48          	sub    $0x48,%rsp
  801bf4:	89 7d dc             	mov    %edi,-0x24(%rbp)
  801bf7:	89 75 d8             	mov    %esi,-0x28(%rbp)
  801bfa:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  801bfe:	48 89 4d c8          	mov    %rcx,-0x38(%rbp)
  801c02:	4c 89 45 c0          	mov    %r8,-0x40(%rbp)
  801c06:	4c 89 4d b8          	mov    %r9,-0x48(%rbp)
  801c0a:	8b 45 dc             	mov    -0x24(%rbp),%eax
  801c0d:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  801c11:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
  801c15:	4c 8b 45 c0          	mov    -0x40(%rbp),%r8
  801c19:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  801c1d:	48 8b 75 10          	mov    0x10(%rbp),%rsi
  801c21:	4c 89 c3             	mov    %r8,%rbx
  801c24:	cd 30                	int    $0x30
  801c26:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  801c2a:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
  801c2e:	74 3e                	je     801c6e <syscall+0x83>
  801c30:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  801c35:	7e 37                	jle    801c6e <syscall+0x83>
  801c37:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  801c3b:	8b 45 dc             	mov    -0x24(%rbp),%eax
  801c3e:	49 89 d0             	mov    %rdx,%r8
  801c41:	89 c1                	mov    %eax,%ecx
  801c43:	48 ba c8 4c 80 00 00 	movabs $0x804cc8,%rdx
  801c4a:	00 00 00 
  801c4d:	be 24 00 00 00       	mov    $0x24,%esi
  801c52:	48 bf e5 4c 80 00 00 	movabs $0x804ce5,%rdi
  801c59:	00 00 00 
  801c5c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c61:	49 b9 a4 06 80 00 00 	movabs $0x8006a4,%r9
  801c68:	00 00 00 
  801c6b:	41 ff d1             	callq  *%r9
  801c6e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  801c72:	48 83 c4 48          	add    $0x48,%rsp
  801c76:	5b                   	pop    %rbx
  801c77:	5d                   	pop    %rbp
  801c78:	c3                   	retq   

0000000000801c79 <sys_cputs>:
  801c79:	55                   	push   %rbp
  801c7a:	48 89 e5             	mov    %rsp,%rbp
  801c7d:	48 83 ec 20          	sub    $0x20,%rsp
  801c81:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  801c85:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801c89:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801c8d:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801c91:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801c98:	00 
  801c99:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801c9f:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801ca5:	48 89 d1             	mov    %rdx,%rcx
  801ca8:	48 89 c2             	mov    %rax,%rdx
  801cab:	be 00 00 00 00       	mov    $0x0,%esi
  801cb0:	bf 00 00 00 00       	mov    $0x0,%edi
  801cb5:	48 b8 eb 1b 80 00 00 	movabs $0x801beb,%rax
  801cbc:	00 00 00 
  801cbf:	ff d0                	callq  *%rax
  801cc1:	c9                   	leaveq 
  801cc2:	c3                   	retq   

0000000000801cc3 <sys_cgetc>:
  801cc3:	55                   	push   %rbp
  801cc4:	48 89 e5             	mov    %rsp,%rbp
  801cc7:	48 83 ec 10          	sub    $0x10,%rsp
  801ccb:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801cd2:	00 
  801cd3:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801cd9:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801cdf:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ce4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce9:	be 00 00 00 00       	mov    $0x0,%esi
  801cee:	bf 01 00 00 00       	mov    $0x1,%edi
  801cf3:	48 b8 eb 1b 80 00 00 	movabs $0x801beb,%rax
  801cfa:	00 00 00 
  801cfd:	ff d0                	callq  *%rax
  801cff:	c9                   	leaveq 
  801d00:	c3                   	retq   

0000000000801d01 <sys_env_destroy>:
  801d01:	55                   	push   %rbp
  801d02:	48 89 e5             	mov    %rsp,%rbp
  801d05:	48 83 ec 10          	sub    $0x10,%rsp
  801d09:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801d0c:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801d0f:	48 98                	cltq   
  801d11:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801d18:	00 
  801d19:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801d1f:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801d25:	b9 00 00 00 00       	mov    $0x0,%ecx
  801d2a:	48 89 c2             	mov    %rax,%rdx
  801d2d:	be 01 00 00 00       	mov    $0x1,%esi
  801d32:	bf 03 00 00 00       	mov    $0x3,%edi
  801d37:	48 b8 eb 1b 80 00 00 	movabs $0x801beb,%rax
  801d3e:	00 00 00 
  801d41:	ff d0                	callq  *%rax
  801d43:	c9                   	leaveq 
  801d44:	c3                   	retq   

0000000000801d45 <sys_getenvid>:
  801d45:	55                   	push   %rbp
  801d46:	48 89 e5             	mov    %rsp,%rbp
  801d49:	48 83 ec 10          	sub    $0x10,%rsp
  801d4d:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801d54:	00 
  801d55:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801d5b:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801d61:	b9 00 00 00 00       	mov    $0x0,%ecx
  801d66:	ba 00 00 00 00       	mov    $0x0,%edx
  801d6b:	be 00 00 00 00       	mov    $0x0,%esi
  801d70:	bf 02 00 00 00       	mov    $0x2,%edi
  801d75:	48 b8 eb 1b 80 00 00 	movabs $0x801beb,%rax
  801d7c:	00 00 00 
  801d7f:	ff d0                	callq  *%rax
  801d81:	c9                   	leaveq 
  801d82:	c3                   	retq   

0000000000801d83 <sys_yield>:
  801d83:	55                   	push   %rbp
  801d84:	48 89 e5             	mov    %rsp,%rbp
  801d87:	48 83 ec 10          	sub    $0x10,%rsp
  801d8b:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801d92:	00 
  801d93:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801d99:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801d9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801da4:	ba 00 00 00 00       	mov    $0x0,%edx
  801da9:	be 00 00 00 00       	mov    $0x0,%esi
  801dae:	bf 0b 00 00 00       	mov    $0xb,%edi
  801db3:	48 b8 eb 1b 80 00 00 	movabs $0x801beb,%rax
  801dba:	00 00 00 
  801dbd:	ff d0                	callq  *%rax
  801dbf:	c9                   	leaveq 
  801dc0:	c3                   	retq   

0000000000801dc1 <sys_page_alloc>:
  801dc1:	55                   	push   %rbp
  801dc2:	48 89 e5             	mov    %rsp,%rbp
  801dc5:	48 83 ec 20          	sub    $0x20,%rsp
  801dc9:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801dcc:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801dd0:	89 55 f8             	mov    %edx,-0x8(%rbp)
  801dd3:	8b 45 f8             	mov    -0x8(%rbp),%eax
  801dd6:	48 63 c8             	movslq %eax,%rcx
  801dd9:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801ddd:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801de0:	48 98                	cltq   
  801de2:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801de9:	00 
  801dea:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801df0:	49 89 c8             	mov    %rcx,%r8
  801df3:	48 89 d1             	mov    %rdx,%rcx
  801df6:	48 89 c2             	mov    %rax,%rdx
  801df9:	be 01 00 00 00       	mov    $0x1,%esi
  801dfe:	bf 04 00 00 00       	mov    $0x4,%edi
  801e03:	48 b8 eb 1b 80 00 00 	movabs $0x801beb,%rax
  801e0a:	00 00 00 
  801e0d:	ff d0                	callq  *%rax
  801e0f:	c9                   	leaveq 
  801e10:	c3                   	retq   

0000000000801e11 <sys_page_map>:
  801e11:	55                   	push   %rbp
  801e12:	48 89 e5             	mov    %rsp,%rbp
  801e15:	48 83 ec 30          	sub    $0x30,%rsp
  801e19:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801e1c:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801e20:	89 55 f8             	mov    %edx,-0x8(%rbp)
  801e23:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  801e27:	44 89 45 e4          	mov    %r8d,-0x1c(%rbp)
  801e2b:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  801e2e:	48 63 c8             	movslq %eax,%rcx
  801e31:	48 8b 7d e8          	mov    -0x18(%rbp),%rdi
  801e35:	8b 45 f8             	mov    -0x8(%rbp),%eax
  801e38:	48 63 f0             	movslq %eax,%rsi
  801e3b:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801e3f:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801e42:	48 98                	cltq   
  801e44:	48 89 0c 24          	mov    %rcx,(%rsp)
  801e48:	49 89 f9             	mov    %rdi,%r9
  801e4b:	49 89 f0             	mov    %rsi,%r8
  801e4e:	48 89 d1             	mov    %rdx,%rcx
  801e51:	48 89 c2             	mov    %rax,%rdx
  801e54:	be 01 00 00 00       	mov    $0x1,%esi
  801e59:	bf 05 00 00 00       	mov    $0x5,%edi
  801e5e:	48 b8 eb 1b 80 00 00 	movabs $0x801beb,%rax
  801e65:	00 00 00 
  801e68:	ff d0                	callq  *%rax
  801e6a:	c9                   	leaveq 
  801e6b:	c3                   	retq   

0000000000801e6c <sys_page_unmap>:
  801e6c:	55                   	push   %rbp
  801e6d:	48 89 e5             	mov    %rsp,%rbp
  801e70:	48 83 ec 20          	sub    $0x20,%rsp
  801e74:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801e77:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801e7b:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801e7f:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801e82:	48 98                	cltq   
  801e84:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801e8b:	00 
  801e8c:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801e92:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801e98:	48 89 d1             	mov    %rdx,%rcx
  801e9b:	48 89 c2             	mov    %rax,%rdx
  801e9e:	be 01 00 00 00       	mov    $0x1,%esi
  801ea3:	bf 06 00 00 00       	mov    $0x6,%edi
  801ea8:	48 b8 eb 1b 80 00 00 	movabs $0x801beb,%rax
  801eaf:	00 00 00 
  801eb2:	ff d0                	callq  *%rax
  801eb4:	c9                   	leaveq 
  801eb5:	c3                   	retq   

0000000000801eb6 <sys_env_set_status>:
  801eb6:	55                   	push   %rbp
  801eb7:	48 89 e5             	mov    %rsp,%rbp
  801eba:	48 83 ec 10          	sub    $0x10,%rsp
  801ebe:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801ec1:	89 75 f8             	mov    %esi,-0x8(%rbp)
  801ec4:	8b 45 f8             	mov    -0x8(%rbp),%eax
  801ec7:	48 63 d0             	movslq %eax,%rdx
  801eca:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801ecd:	48 98                	cltq   
  801ecf:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801ed6:	00 
  801ed7:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801edd:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801ee3:	48 89 d1             	mov    %rdx,%rcx
  801ee6:	48 89 c2             	mov    %rax,%rdx
  801ee9:	be 01 00 00 00       	mov    $0x1,%esi
  801eee:	bf 08 00 00 00       	mov    $0x8,%edi
  801ef3:	48 b8 eb 1b 80 00 00 	movabs $0x801beb,%rax
  801efa:	00 00 00 
  801efd:	ff d0                	callq  *%rax
  801eff:	c9                   	leaveq 
  801f00:	c3                   	retq   

0000000000801f01 <sys_env_set_trapframe>:
  801f01:	55                   	push   %rbp
  801f02:	48 89 e5             	mov    %rsp,%rbp
  801f05:	48 83 ec 20          	sub    $0x20,%rsp
  801f09:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801f0c:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801f10:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801f14:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801f17:	48 98                	cltq   
  801f19:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801f20:	00 
  801f21:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801f27:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  801f2d:	48 89 d1             	mov    %rdx,%rcx
  801f30:	48 89 c2             	mov    %rax,%rdx
  801f33:	be 01 00 00 00       	mov    $0x1,%esi
  801f38:	bf 09 00 00 00       	mov    $0x9,%edi
  801f3d:	48 b8 eb 1b 80 00 00 	movabs $0x801beb,%rax
  801f44:	00 00 00 
  801f47:	ff d0                	callq  *%rax
  801f49:	c9                   	leaveq 
  801f4a:	c3                   	retq   

0000000000801f4b <sys_env_set_pgfault_upcall>:
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
  801f82:	bf 0a 00 00 00       	mov    $0xa,%edi
  801f87:	48 b8 eb 1b 80 00 00 	movabs $0x801beb,%rax
  801f8e:	00 00 00 
  801f91:	ff d0                	callq  *%rax
  801f93:	c9                   	leaveq 
  801f94:	c3                   	retq   

0000000000801f95 <sys_ipc_try_send>:
  801f95:	55                   	push   %rbp
  801f96:	48 89 e5             	mov    %rsp,%rbp
  801f99:	48 83 ec 20          	sub    $0x20,%rsp
  801f9d:	89 7d fc             	mov    %edi,-0x4(%rbp)
  801fa0:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  801fa4:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  801fa8:	89 4d f8             	mov    %ecx,-0x8(%rbp)
  801fab:	8b 45 f8             	mov    -0x8(%rbp),%eax
  801fae:	48 63 f0             	movslq %eax,%rsi
  801fb1:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  801fb5:	8b 45 fc             	mov    -0x4(%rbp),%eax
  801fb8:	48 98                	cltq   
  801fba:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  801fbe:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  801fc5:	00 
  801fc6:	49 89 f1             	mov    %rsi,%r9
  801fc9:	49 89 c8             	mov    %rcx,%r8
  801fcc:	48 89 d1             	mov    %rdx,%rcx
  801fcf:	48 89 c2             	mov    %rax,%rdx
  801fd2:	be 00 00 00 00       	mov    $0x0,%esi
  801fd7:	bf 0c 00 00 00       	mov    $0xc,%edi
  801fdc:	48 b8 eb 1b 80 00 00 	movabs $0x801beb,%rax
  801fe3:	00 00 00 
  801fe6:	ff d0                	callq  *%rax
  801fe8:	c9                   	leaveq 
  801fe9:	c3                   	retq   

0000000000801fea <sys_ipc_recv>:
  801fea:	55                   	push   %rbp
  801feb:	48 89 e5             	mov    %rsp,%rbp
  801fee:	48 83 ec 10          	sub    $0x10,%rsp
  801ff2:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  801ff6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  801ffa:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  802001:	00 
  802002:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  802008:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  80200e:	b9 00 00 00 00       	mov    $0x0,%ecx
  802013:	48 89 c2             	mov    %rax,%rdx
  802016:	be 01 00 00 00       	mov    $0x1,%esi
  80201b:	bf 0d 00 00 00       	mov    $0xd,%edi
  802020:	48 b8 eb 1b 80 00 00 	movabs $0x801beb,%rax
  802027:	00 00 00 
  80202a:	ff d0                	callq  *%rax
  80202c:	c9                   	leaveq 
  80202d:	c3                   	retq   

000000000080202e <sys_time_msec>:
  80202e:	55                   	push   %rbp
  80202f:	48 89 e5             	mov    %rsp,%rbp
  802032:	48 83 ec 10          	sub    $0x10,%rsp
  802036:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  80203d:	00 
  80203e:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  802044:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  80204a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80204f:	ba 00 00 00 00       	mov    $0x0,%edx
  802054:	be 00 00 00 00       	mov    $0x0,%esi
  802059:	bf 0e 00 00 00       	mov    $0xe,%edi
  80205e:	48 b8 eb 1b 80 00 00 	movabs $0x801beb,%rax
  802065:	00 00 00 
  802068:	ff d0                	callq  *%rax
  80206a:	c9                   	leaveq 
  80206b:	c3                   	retq   

000000000080206c <sys_net_transmit>:
  80206c:	55                   	push   %rbp
  80206d:	48 89 e5             	mov    %rsp,%rbp
  802070:	48 83 ec 20          	sub    $0x20,%rsp
  802074:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  802078:	89 75 f4             	mov    %esi,-0xc(%rbp)
  80207b:	8b 55 f4             	mov    -0xc(%rbp),%edx
  80207e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  802082:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  802089:	00 
  80208a:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  802090:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  802096:	48 89 d1             	mov    %rdx,%rcx
  802099:	48 89 c2             	mov    %rax,%rdx
  80209c:	be 00 00 00 00       	mov    $0x0,%esi
  8020a1:	bf 0f 00 00 00       	mov    $0xf,%edi
  8020a6:	48 b8 eb 1b 80 00 00 	movabs $0x801beb,%rax
  8020ad:	00 00 00 
  8020b0:	ff d0                	callq  *%rax
  8020b2:	c9                   	leaveq 
  8020b3:	c3                   	retq   

00000000008020b4 <sys_net_receive>:
  8020b4:	55                   	push   %rbp
  8020b5:	48 89 e5             	mov    %rsp,%rbp
  8020b8:	48 83 ec 20          	sub    $0x20,%rsp
  8020bc:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8020c0:	89 75 f4             	mov    %esi,-0xc(%rbp)
  8020c3:	8b 55 f4             	mov    -0xc(%rbp),%edx
  8020c6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8020ca:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  8020d1:	00 
  8020d2:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8020d8:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  8020de:	48 89 d1             	mov    %rdx,%rcx
  8020e1:	48 89 c2             	mov    %rax,%rdx
  8020e4:	be 00 00 00 00       	mov    $0x0,%esi
  8020e9:	bf 10 00 00 00       	mov    $0x10,%edi
  8020ee:	48 b8 eb 1b 80 00 00 	movabs $0x801beb,%rax
  8020f5:	00 00 00 
  8020f8:	ff d0                	callq  *%rax
  8020fa:	c9                   	leaveq 
  8020fb:	c3                   	retq   

00000000008020fc <sys_ept_map>:
  8020fc:	55                   	push   %rbp
  8020fd:	48 89 e5             	mov    %rsp,%rbp
  802100:	48 83 ec 30          	sub    $0x30,%rsp
  802104:	89 7d fc             	mov    %edi,-0x4(%rbp)
  802107:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  80210b:	89 55 f8             	mov    %edx,-0x8(%rbp)
  80210e:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  802112:	44 89 45 e4          	mov    %r8d,-0x1c(%rbp)
  802116:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  802119:	48 63 c8             	movslq %eax,%rcx
  80211c:	48 8b 7d e8          	mov    -0x18(%rbp),%rdi
  802120:	8b 45 f8             	mov    -0x8(%rbp),%eax
  802123:	48 63 f0             	movslq %eax,%rsi
  802126:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  80212a:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80212d:	48 98                	cltq   
  80212f:	48 89 0c 24          	mov    %rcx,(%rsp)
  802133:	49 89 f9             	mov    %rdi,%r9
  802136:	49 89 f0             	mov    %rsi,%r8
  802139:	48 89 d1             	mov    %rdx,%rcx
  80213c:	48 89 c2             	mov    %rax,%rdx
  80213f:	be 00 00 00 00       	mov    $0x0,%esi
  802144:	bf 11 00 00 00       	mov    $0x11,%edi
  802149:	48 b8 eb 1b 80 00 00 	movabs $0x801beb,%rax
  802150:	00 00 00 
  802153:	ff d0                	callq  *%rax
  802155:	c9                   	leaveq 
  802156:	c3                   	retq   

0000000000802157 <sys_env_mkguest>:
  802157:	55                   	push   %rbp
  802158:	48 89 e5             	mov    %rsp,%rbp
  80215b:	48 83 ec 20          	sub    $0x20,%rsp
  80215f:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  802163:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  802167:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  80216b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80216f:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  802176:	00 
  802177:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  80217d:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  802183:	48 89 d1             	mov    %rdx,%rcx
  802186:	48 89 c2             	mov    %rax,%rdx
  802189:	be 00 00 00 00       	mov    $0x0,%esi
  80218e:	bf 12 00 00 00       	mov    $0x12,%edi
  802193:	48 b8 eb 1b 80 00 00 	movabs $0x801beb,%rax
  80219a:	00 00 00 
  80219d:	ff d0                	callq  *%rax
  80219f:	c9                   	leaveq 
  8021a0:	c3                   	retq   

00000000008021a1 <fd2num>:
  8021a1:	55                   	push   %rbp
  8021a2:	48 89 e5             	mov    %rsp,%rbp
  8021a5:	48 83 ec 08          	sub    $0x8,%rsp
  8021a9:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8021ad:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8021b1:	48 b8 00 00 00 30 ff 	movabs $0xffffffff30000000,%rax
  8021b8:	ff ff ff 
  8021bb:	48 01 d0             	add    %rdx,%rax
  8021be:	48 c1 e8 0c          	shr    $0xc,%rax
  8021c2:	c9                   	leaveq 
  8021c3:	c3                   	retq   

00000000008021c4 <fd2data>:
  8021c4:	55                   	push   %rbp
  8021c5:	48 89 e5             	mov    %rsp,%rbp
  8021c8:	48 83 ec 08          	sub    $0x8,%rsp
  8021cc:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8021d0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8021d4:	48 89 c7             	mov    %rax,%rdi
  8021d7:	48 b8 a1 21 80 00 00 	movabs $0x8021a1,%rax
  8021de:	00 00 00 
  8021e1:	ff d0                	callq  *%rax
  8021e3:	48 05 20 00 0d 00    	add    $0xd0020,%rax
  8021e9:	48 c1 e0 0c          	shl    $0xc,%rax
  8021ed:	c9                   	leaveq 
  8021ee:	c3                   	retq   

00000000008021ef <fd_alloc>:
  8021ef:	55                   	push   %rbp
  8021f0:	48 89 e5             	mov    %rsp,%rbp
  8021f3:	48 83 ec 18          	sub    $0x18,%rsp
  8021f7:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8021fb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  802202:	eb 6b                	jmp    80226f <fd_alloc+0x80>
  802204:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802207:	48 98                	cltq   
  802209:	48 05 00 00 0d 00    	add    $0xd0000,%rax
  80220f:	48 c1 e0 0c          	shl    $0xc,%rax
  802213:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  802217:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80221b:	48 c1 e8 15          	shr    $0x15,%rax
  80221f:	48 89 c2             	mov    %rax,%rdx
  802222:	48 b8 00 00 00 80 00 	movabs $0x10080000000,%rax
  802229:	01 00 00 
  80222c:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  802230:	83 e0 01             	and    $0x1,%eax
  802233:	48 85 c0             	test   %rax,%rax
  802236:	74 21                	je     802259 <fd_alloc+0x6a>
  802238:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80223c:	48 c1 e8 0c          	shr    $0xc,%rax
  802240:	48 89 c2             	mov    %rax,%rdx
  802243:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  80224a:	01 00 00 
  80224d:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  802251:	83 e0 01             	and    $0x1,%eax
  802254:	48 85 c0             	test   %rax,%rax
  802257:	75 12                	jne    80226b <fd_alloc+0x7c>
  802259:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80225d:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  802261:	48 89 10             	mov    %rdx,(%rax)
  802264:	b8 00 00 00 00       	mov    $0x0,%eax
  802269:	eb 1a                	jmp    802285 <fd_alloc+0x96>
  80226b:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  80226f:	83 7d fc 1f          	cmpl   $0x1f,-0x4(%rbp)
  802273:	7e 8f                	jle    802204 <fd_alloc+0x15>
  802275:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802279:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  802280:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  802285:	c9                   	leaveq 
  802286:	c3                   	retq   

0000000000802287 <fd_lookup>:
  802287:	55                   	push   %rbp
  802288:	48 89 e5             	mov    %rsp,%rbp
  80228b:	48 83 ec 20          	sub    $0x20,%rsp
  80228f:	89 7d ec             	mov    %edi,-0x14(%rbp)
  802292:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  802296:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  80229a:	78 06                	js     8022a2 <fd_lookup+0x1b>
  80229c:	83 7d ec 1f          	cmpl   $0x1f,-0x14(%rbp)
  8022a0:	7e 07                	jle    8022a9 <fd_lookup+0x22>
  8022a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8022a7:	eb 6c                	jmp    802315 <fd_lookup+0x8e>
  8022a9:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8022ac:	48 98                	cltq   
  8022ae:	48 05 00 00 0d 00    	add    $0xd0000,%rax
  8022b4:	48 c1 e0 0c          	shl    $0xc,%rax
  8022b8:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8022bc:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8022c0:	48 c1 e8 15          	shr    $0x15,%rax
  8022c4:	48 89 c2             	mov    %rax,%rdx
  8022c7:	48 b8 00 00 00 80 00 	movabs $0x10080000000,%rax
  8022ce:	01 00 00 
  8022d1:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8022d5:	83 e0 01             	and    $0x1,%eax
  8022d8:	48 85 c0             	test   %rax,%rax
  8022db:	74 21                	je     8022fe <fd_lookup+0x77>
  8022dd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8022e1:	48 c1 e8 0c          	shr    $0xc,%rax
  8022e5:	48 89 c2             	mov    %rax,%rdx
  8022e8:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  8022ef:	01 00 00 
  8022f2:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8022f6:	83 e0 01             	and    $0x1,%eax
  8022f9:	48 85 c0             	test   %rax,%rax
  8022fc:	75 07                	jne    802305 <fd_lookup+0x7e>
  8022fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802303:	eb 10                	jmp    802315 <fd_lookup+0x8e>
  802305:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  802309:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  80230d:	48 89 10             	mov    %rdx,(%rax)
  802310:	b8 00 00 00 00       	mov    $0x0,%eax
  802315:	c9                   	leaveq 
  802316:	c3                   	retq   

0000000000802317 <fd_close>:
  802317:	55                   	push   %rbp
  802318:	48 89 e5             	mov    %rsp,%rbp
  80231b:	48 83 ec 30          	sub    $0x30,%rsp
  80231f:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  802323:	89 f0                	mov    %esi,%eax
  802325:	88 45 d4             	mov    %al,-0x2c(%rbp)
  802328:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80232c:	48 89 c7             	mov    %rax,%rdi
  80232f:	48 b8 a1 21 80 00 00 	movabs $0x8021a1,%rax
  802336:	00 00 00 
  802339:	ff d0                	callq  *%rax
  80233b:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  80233f:	48 89 d6             	mov    %rdx,%rsi
  802342:	89 c7                	mov    %eax,%edi
  802344:	48 b8 87 22 80 00 00 	movabs $0x802287,%rax
  80234b:	00 00 00 
  80234e:	ff d0                	callq  *%rax
  802350:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802353:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802357:	78 0a                	js     802363 <fd_close+0x4c>
  802359:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80235d:	48 39 45 d8          	cmp    %rax,-0x28(%rbp)
  802361:	74 12                	je     802375 <fd_close+0x5e>
  802363:	80 7d d4 00          	cmpb   $0x0,-0x2c(%rbp)
  802367:	74 05                	je     80236e <fd_close+0x57>
  802369:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80236c:	eb 05                	jmp    802373 <fd_close+0x5c>
  80236e:	b8 00 00 00 00       	mov    $0x0,%eax
  802373:	eb 69                	jmp    8023de <fd_close+0xc7>
  802375:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  802379:	8b 00                	mov    (%rax),%eax
  80237b:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  80237f:	48 89 d6             	mov    %rdx,%rsi
  802382:	89 c7                	mov    %eax,%edi
  802384:	48 b8 e0 23 80 00 00 	movabs $0x8023e0,%rax
  80238b:	00 00 00 
  80238e:	ff d0                	callq  *%rax
  802390:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802393:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802397:	78 2a                	js     8023c3 <fd_close+0xac>
  802399:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80239d:	48 8b 40 20          	mov    0x20(%rax),%rax
  8023a1:	48 85 c0             	test   %rax,%rax
  8023a4:	74 16                	je     8023bc <fd_close+0xa5>
  8023a6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8023aa:	48 8b 40 20          	mov    0x20(%rax),%rax
  8023ae:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  8023b2:	48 89 d7             	mov    %rdx,%rdi
  8023b5:	ff d0                	callq  *%rax
  8023b7:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8023ba:	eb 07                	jmp    8023c3 <fd_close+0xac>
  8023bc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8023c3:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8023c7:	48 89 c6             	mov    %rax,%rsi
  8023ca:	bf 00 00 00 00       	mov    $0x0,%edi
  8023cf:	48 b8 6c 1e 80 00 00 	movabs $0x801e6c,%rax
  8023d6:	00 00 00 
  8023d9:	ff d0                	callq  *%rax
  8023db:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8023de:	c9                   	leaveq 
  8023df:	c3                   	retq   

00000000008023e0 <dev_lookup>:
  8023e0:	55                   	push   %rbp
  8023e1:	48 89 e5             	mov    %rsp,%rbp
  8023e4:	48 83 ec 20          	sub    $0x20,%rsp
  8023e8:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8023eb:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8023ef:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8023f6:	eb 41                	jmp    802439 <dev_lookup+0x59>
  8023f8:	48 b8 20 60 80 00 00 	movabs $0x806020,%rax
  8023ff:	00 00 00 
  802402:	8b 55 fc             	mov    -0x4(%rbp),%edx
  802405:	48 63 d2             	movslq %edx,%rdx
  802408:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  80240c:	8b 00                	mov    (%rax),%eax
  80240e:	3b 45 ec             	cmp    -0x14(%rbp),%eax
  802411:	75 22                	jne    802435 <dev_lookup+0x55>
  802413:	48 b8 20 60 80 00 00 	movabs $0x806020,%rax
  80241a:	00 00 00 
  80241d:	8b 55 fc             	mov    -0x4(%rbp),%edx
  802420:	48 63 d2             	movslq %edx,%rdx
  802423:	48 8b 14 d0          	mov    (%rax,%rdx,8),%rdx
  802427:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80242b:	48 89 10             	mov    %rdx,(%rax)
  80242e:	b8 00 00 00 00       	mov    $0x0,%eax
  802433:	eb 60                	jmp    802495 <dev_lookup+0xb5>
  802435:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  802439:	48 b8 20 60 80 00 00 	movabs $0x806020,%rax
  802440:	00 00 00 
  802443:	8b 55 fc             	mov    -0x4(%rbp),%edx
  802446:	48 63 d2             	movslq %edx,%rdx
  802449:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  80244d:	48 85 c0             	test   %rax,%rax
  802450:	75 a6                	jne    8023f8 <dev_lookup+0x18>
  802452:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  802459:	00 00 00 
  80245c:	48 8b 00             	mov    (%rax),%rax
  80245f:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  802465:	8b 55 ec             	mov    -0x14(%rbp),%edx
  802468:	89 c6                	mov    %eax,%esi
  80246a:	48 bf f8 4c 80 00 00 	movabs $0x804cf8,%rdi
  802471:	00 00 00 
  802474:	b8 00 00 00 00       	mov    $0x0,%eax
  802479:	48 b9 dd 08 80 00 00 	movabs $0x8008dd,%rcx
  802480:	00 00 00 
  802483:	ff d1                	callq  *%rcx
  802485:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  802489:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  802490:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802495:	c9                   	leaveq 
  802496:	c3                   	retq   

0000000000802497 <close>:
  802497:	55                   	push   %rbp
  802498:	48 89 e5             	mov    %rsp,%rbp
  80249b:	48 83 ec 20          	sub    $0x20,%rsp
  80249f:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8024a2:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  8024a6:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8024a9:	48 89 d6             	mov    %rdx,%rsi
  8024ac:	89 c7                	mov    %eax,%edi
  8024ae:	48 b8 87 22 80 00 00 	movabs $0x802287,%rax
  8024b5:	00 00 00 
  8024b8:	ff d0                	callq  *%rax
  8024ba:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8024bd:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8024c1:	79 05                	jns    8024c8 <close+0x31>
  8024c3:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8024c6:	eb 18                	jmp    8024e0 <close+0x49>
  8024c8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8024cc:	be 01 00 00 00       	mov    $0x1,%esi
  8024d1:	48 89 c7             	mov    %rax,%rdi
  8024d4:	48 b8 17 23 80 00 00 	movabs $0x802317,%rax
  8024db:	00 00 00 
  8024de:	ff d0                	callq  *%rax
  8024e0:	c9                   	leaveq 
  8024e1:	c3                   	retq   

00000000008024e2 <close_all>:
  8024e2:	55                   	push   %rbp
  8024e3:	48 89 e5             	mov    %rsp,%rbp
  8024e6:	48 83 ec 10          	sub    $0x10,%rsp
  8024ea:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8024f1:	eb 15                	jmp    802508 <close_all+0x26>
  8024f3:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8024f6:	89 c7                	mov    %eax,%edi
  8024f8:	48 b8 97 24 80 00 00 	movabs $0x802497,%rax
  8024ff:	00 00 00 
  802502:	ff d0                	callq  *%rax
  802504:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  802508:	83 7d fc 1f          	cmpl   $0x1f,-0x4(%rbp)
  80250c:	7e e5                	jle    8024f3 <close_all+0x11>
  80250e:	c9                   	leaveq 
  80250f:	c3                   	retq   

0000000000802510 <dup>:
  802510:	55                   	push   %rbp
  802511:	48 89 e5             	mov    %rsp,%rbp
  802514:	48 83 ec 40          	sub    $0x40,%rsp
  802518:	89 7d cc             	mov    %edi,-0x34(%rbp)
  80251b:	89 75 c8             	mov    %esi,-0x38(%rbp)
  80251e:	48 8d 55 d8          	lea    -0x28(%rbp),%rdx
  802522:	8b 45 cc             	mov    -0x34(%rbp),%eax
  802525:	48 89 d6             	mov    %rdx,%rsi
  802528:	89 c7                	mov    %eax,%edi
  80252a:	48 b8 87 22 80 00 00 	movabs $0x802287,%rax
  802531:	00 00 00 
  802534:	ff d0                	callq  *%rax
  802536:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802539:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80253d:	79 08                	jns    802547 <dup+0x37>
  80253f:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802542:	e9 70 01 00 00       	jmpq   8026b7 <dup+0x1a7>
  802547:	8b 45 c8             	mov    -0x38(%rbp),%eax
  80254a:	89 c7                	mov    %eax,%edi
  80254c:	48 b8 97 24 80 00 00 	movabs $0x802497,%rax
  802553:	00 00 00 
  802556:	ff d0                	callq  *%rax
  802558:	8b 45 c8             	mov    -0x38(%rbp),%eax
  80255b:	48 98                	cltq   
  80255d:	48 05 00 00 0d 00    	add    $0xd0000,%rax
  802563:	48 c1 e0 0c          	shl    $0xc,%rax
  802567:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  80256b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80256f:	48 89 c7             	mov    %rax,%rdi
  802572:	48 b8 c4 21 80 00 00 	movabs $0x8021c4,%rax
  802579:	00 00 00 
  80257c:	ff d0                	callq  *%rax
  80257e:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  802582:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802586:	48 89 c7             	mov    %rax,%rdi
  802589:	48 b8 c4 21 80 00 00 	movabs $0x8021c4,%rax
  802590:	00 00 00 
  802593:	ff d0                	callq  *%rax
  802595:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  802599:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80259d:	48 c1 e8 15          	shr    $0x15,%rax
  8025a1:	48 89 c2             	mov    %rax,%rdx
  8025a4:	48 b8 00 00 00 80 00 	movabs $0x10080000000,%rax
  8025ab:	01 00 00 
  8025ae:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8025b2:	83 e0 01             	and    $0x1,%eax
  8025b5:	48 85 c0             	test   %rax,%rax
  8025b8:	74 73                	je     80262d <dup+0x11d>
  8025ba:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8025be:	48 c1 e8 0c          	shr    $0xc,%rax
  8025c2:	48 89 c2             	mov    %rax,%rdx
  8025c5:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  8025cc:	01 00 00 
  8025cf:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8025d3:	83 e0 01             	and    $0x1,%eax
  8025d6:	48 85 c0             	test   %rax,%rax
  8025d9:	74 52                	je     80262d <dup+0x11d>
  8025db:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8025df:	48 c1 e8 0c          	shr    $0xc,%rax
  8025e3:	48 89 c2             	mov    %rax,%rdx
  8025e6:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  8025ed:	01 00 00 
  8025f0:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8025f4:	25 07 0e 00 00       	and    $0xe07,%eax
  8025f9:	89 c1                	mov    %eax,%ecx
  8025fb:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8025ff:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802603:	41 89 c8             	mov    %ecx,%r8d
  802606:	48 89 d1             	mov    %rdx,%rcx
  802609:	ba 00 00 00 00       	mov    $0x0,%edx
  80260e:	48 89 c6             	mov    %rax,%rsi
  802611:	bf 00 00 00 00       	mov    $0x0,%edi
  802616:	48 b8 11 1e 80 00 00 	movabs $0x801e11,%rax
  80261d:	00 00 00 
  802620:	ff d0                	callq  *%rax
  802622:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802625:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802629:	79 02                	jns    80262d <dup+0x11d>
  80262b:	eb 57                	jmp    802684 <dup+0x174>
  80262d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  802631:	48 c1 e8 0c          	shr    $0xc,%rax
  802635:	48 89 c2             	mov    %rax,%rdx
  802638:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  80263f:	01 00 00 
  802642:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  802646:	25 07 0e 00 00       	and    $0xe07,%eax
  80264b:	89 c1                	mov    %eax,%ecx
  80264d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  802651:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  802655:	41 89 c8             	mov    %ecx,%r8d
  802658:	48 89 d1             	mov    %rdx,%rcx
  80265b:	ba 00 00 00 00       	mov    $0x0,%edx
  802660:	48 89 c6             	mov    %rax,%rsi
  802663:	bf 00 00 00 00       	mov    $0x0,%edi
  802668:	48 b8 11 1e 80 00 00 	movabs $0x801e11,%rax
  80266f:	00 00 00 
  802672:	ff d0                	callq  *%rax
  802674:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802677:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80267b:	79 02                	jns    80267f <dup+0x16f>
  80267d:	eb 05                	jmp    802684 <dup+0x174>
  80267f:	8b 45 c8             	mov    -0x38(%rbp),%eax
  802682:	eb 33                	jmp    8026b7 <dup+0x1a7>
  802684:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802688:	48 89 c6             	mov    %rax,%rsi
  80268b:	bf 00 00 00 00       	mov    $0x0,%edi
  802690:	48 b8 6c 1e 80 00 00 	movabs $0x801e6c,%rax
  802697:	00 00 00 
  80269a:	ff d0                	callq  *%rax
  80269c:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8026a0:	48 89 c6             	mov    %rax,%rsi
  8026a3:	bf 00 00 00 00       	mov    $0x0,%edi
  8026a8:	48 b8 6c 1e 80 00 00 	movabs $0x801e6c,%rax
  8026af:	00 00 00 
  8026b2:	ff d0                	callq  *%rax
  8026b4:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8026b7:	c9                   	leaveq 
  8026b8:	c3                   	retq   

00000000008026b9 <read>:
  8026b9:	55                   	push   %rbp
  8026ba:	48 89 e5             	mov    %rsp,%rbp
  8026bd:	48 83 ec 40          	sub    $0x40,%rsp
  8026c1:	89 7d dc             	mov    %edi,-0x24(%rbp)
  8026c4:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  8026c8:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8026cc:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  8026d0:	8b 45 dc             	mov    -0x24(%rbp),%eax
  8026d3:	48 89 d6             	mov    %rdx,%rsi
  8026d6:	89 c7                	mov    %eax,%edi
  8026d8:	48 b8 87 22 80 00 00 	movabs $0x802287,%rax
  8026df:	00 00 00 
  8026e2:	ff d0                	callq  *%rax
  8026e4:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8026e7:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8026eb:	78 24                	js     802711 <read+0x58>
  8026ed:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8026f1:	8b 00                	mov    (%rax),%eax
  8026f3:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  8026f7:	48 89 d6             	mov    %rdx,%rsi
  8026fa:	89 c7                	mov    %eax,%edi
  8026fc:	48 b8 e0 23 80 00 00 	movabs $0x8023e0,%rax
  802703:	00 00 00 
  802706:	ff d0                	callq  *%rax
  802708:	89 45 fc             	mov    %eax,-0x4(%rbp)
  80270b:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80270f:	79 05                	jns    802716 <read+0x5d>
  802711:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802714:	eb 76                	jmp    80278c <read+0xd3>
  802716:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80271a:	8b 40 08             	mov    0x8(%rax),%eax
  80271d:	83 e0 03             	and    $0x3,%eax
  802720:	83 f8 01             	cmp    $0x1,%eax
  802723:	75 3a                	jne    80275f <read+0xa6>
  802725:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  80272c:	00 00 00 
  80272f:	48 8b 00             	mov    (%rax),%rax
  802732:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  802738:	8b 55 dc             	mov    -0x24(%rbp),%edx
  80273b:	89 c6                	mov    %eax,%esi
  80273d:	48 bf 17 4d 80 00 00 	movabs $0x804d17,%rdi
  802744:	00 00 00 
  802747:	b8 00 00 00 00       	mov    $0x0,%eax
  80274c:	48 b9 dd 08 80 00 00 	movabs $0x8008dd,%rcx
  802753:	00 00 00 
  802756:	ff d1                	callq  *%rcx
  802758:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80275d:	eb 2d                	jmp    80278c <read+0xd3>
  80275f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802763:	48 8b 40 10          	mov    0x10(%rax),%rax
  802767:	48 85 c0             	test   %rax,%rax
  80276a:	75 07                	jne    802773 <read+0xba>
  80276c:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  802771:	eb 19                	jmp    80278c <read+0xd3>
  802773:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802777:	48 8b 40 10          	mov    0x10(%rax),%rax
  80277b:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  80277f:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  802783:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  802787:	48 89 cf             	mov    %rcx,%rdi
  80278a:	ff d0                	callq  *%rax
  80278c:	c9                   	leaveq 
  80278d:	c3                   	retq   

000000000080278e <readn>:
  80278e:	55                   	push   %rbp
  80278f:	48 89 e5             	mov    %rsp,%rbp
  802792:	48 83 ec 30          	sub    $0x30,%rsp
  802796:	89 7d ec             	mov    %edi,-0x14(%rbp)
  802799:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  80279d:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  8027a1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8027a8:	eb 49                	jmp    8027f3 <readn+0x65>
  8027aa:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8027ad:	48 98                	cltq   
  8027af:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  8027b3:	48 29 c2             	sub    %rax,%rdx
  8027b6:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8027b9:	48 63 c8             	movslq %eax,%rcx
  8027bc:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8027c0:	48 01 c1             	add    %rax,%rcx
  8027c3:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8027c6:	48 89 ce             	mov    %rcx,%rsi
  8027c9:	89 c7                	mov    %eax,%edi
  8027cb:	48 b8 b9 26 80 00 00 	movabs $0x8026b9,%rax
  8027d2:	00 00 00 
  8027d5:	ff d0                	callq  *%rax
  8027d7:	89 45 f8             	mov    %eax,-0x8(%rbp)
  8027da:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  8027de:	79 05                	jns    8027e5 <readn+0x57>
  8027e0:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8027e3:	eb 1c                	jmp    802801 <readn+0x73>
  8027e5:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  8027e9:	75 02                	jne    8027ed <readn+0x5f>
  8027eb:	eb 11                	jmp    8027fe <readn+0x70>
  8027ed:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8027f0:	01 45 fc             	add    %eax,-0x4(%rbp)
  8027f3:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8027f6:	48 98                	cltq   
  8027f8:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  8027fc:	72 ac                	jb     8027aa <readn+0x1c>
  8027fe:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802801:	c9                   	leaveq 
  802802:	c3                   	retq   

0000000000802803 <write>:
  802803:	55                   	push   %rbp
  802804:	48 89 e5             	mov    %rsp,%rbp
  802807:	48 83 ec 40          	sub    $0x40,%rsp
  80280b:	89 7d dc             	mov    %edi,-0x24(%rbp)
  80280e:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  802812:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  802816:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  80281a:	8b 45 dc             	mov    -0x24(%rbp),%eax
  80281d:	48 89 d6             	mov    %rdx,%rsi
  802820:	89 c7                	mov    %eax,%edi
  802822:	48 b8 87 22 80 00 00 	movabs $0x802287,%rax
  802829:	00 00 00 
  80282c:	ff d0                	callq  *%rax
  80282e:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802831:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802835:	78 24                	js     80285b <write+0x58>
  802837:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80283b:	8b 00                	mov    (%rax),%eax
  80283d:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  802841:	48 89 d6             	mov    %rdx,%rsi
  802844:	89 c7                	mov    %eax,%edi
  802846:	48 b8 e0 23 80 00 00 	movabs $0x8023e0,%rax
  80284d:	00 00 00 
  802850:	ff d0                	callq  *%rax
  802852:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802855:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802859:	79 05                	jns    802860 <write+0x5d>
  80285b:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80285e:	eb 75                	jmp    8028d5 <write+0xd2>
  802860:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802864:	8b 40 08             	mov    0x8(%rax),%eax
  802867:	83 e0 03             	and    $0x3,%eax
  80286a:	85 c0                	test   %eax,%eax
  80286c:	75 3a                	jne    8028a8 <write+0xa5>
  80286e:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  802875:	00 00 00 
  802878:	48 8b 00             	mov    (%rax),%rax
  80287b:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  802881:	8b 55 dc             	mov    -0x24(%rbp),%edx
  802884:	89 c6                	mov    %eax,%esi
  802886:	48 bf 33 4d 80 00 00 	movabs $0x804d33,%rdi
  80288d:	00 00 00 
  802890:	b8 00 00 00 00       	mov    $0x0,%eax
  802895:	48 b9 dd 08 80 00 00 	movabs $0x8008dd,%rcx
  80289c:	00 00 00 
  80289f:	ff d1                	callq  *%rcx
  8028a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8028a6:	eb 2d                	jmp    8028d5 <write+0xd2>
  8028a8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8028ac:	48 8b 40 18          	mov    0x18(%rax),%rax
  8028b0:	48 85 c0             	test   %rax,%rax
  8028b3:	75 07                	jne    8028bc <write+0xb9>
  8028b5:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  8028ba:	eb 19                	jmp    8028d5 <write+0xd2>
  8028bc:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8028c0:	48 8b 40 18          	mov    0x18(%rax),%rax
  8028c4:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  8028c8:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8028cc:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  8028d0:	48 89 cf             	mov    %rcx,%rdi
  8028d3:	ff d0                	callq  *%rax
  8028d5:	c9                   	leaveq 
  8028d6:	c3                   	retq   

00000000008028d7 <seek>:
  8028d7:	55                   	push   %rbp
  8028d8:	48 89 e5             	mov    %rsp,%rbp
  8028db:	48 83 ec 18          	sub    $0x18,%rsp
  8028df:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8028e2:	89 75 e8             	mov    %esi,-0x18(%rbp)
  8028e5:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  8028e9:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8028ec:	48 89 d6             	mov    %rdx,%rsi
  8028ef:	89 c7                	mov    %eax,%edi
  8028f1:	48 b8 87 22 80 00 00 	movabs $0x802287,%rax
  8028f8:	00 00 00 
  8028fb:	ff d0                	callq  *%rax
  8028fd:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802900:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802904:	79 05                	jns    80290b <seek+0x34>
  802906:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802909:	eb 0f                	jmp    80291a <seek+0x43>
  80290b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80290f:	8b 55 e8             	mov    -0x18(%rbp),%edx
  802912:	89 50 04             	mov    %edx,0x4(%rax)
  802915:	b8 00 00 00 00       	mov    $0x0,%eax
  80291a:	c9                   	leaveq 
  80291b:	c3                   	retq   

000000000080291c <ftruncate>:
  80291c:	55                   	push   %rbp
  80291d:	48 89 e5             	mov    %rsp,%rbp
  802920:	48 83 ec 30          	sub    $0x30,%rsp
  802924:	89 7d dc             	mov    %edi,-0x24(%rbp)
  802927:	89 75 d8             	mov    %esi,-0x28(%rbp)
  80292a:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  80292e:	8b 45 dc             	mov    -0x24(%rbp),%eax
  802931:	48 89 d6             	mov    %rdx,%rsi
  802934:	89 c7                	mov    %eax,%edi
  802936:	48 b8 87 22 80 00 00 	movabs $0x802287,%rax
  80293d:	00 00 00 
  802940:	ff d0                	callq  *%rax
  802942:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802945:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802949:	78 24                	js     80296f <ftruncate+0x53>
  80294b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80294f:	8b 00                	mov    (%rax),%eax
  802951:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  802955:	48 89 d6             	mov    %rdx,%rsi
  802958:	89 c7                	mov    %eax,%edi
  80295a:	48 b8 e0 23 80 00 00 	movabs $0x8023e0,%rax
  802961:	00 00 00 
  802964:	ff d0                	callq  *%rax
  802966:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802969:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80296d:	79 05                	jns    802974 <ftruncate+0x58>
  80296f:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802972:	eb 72                	jmp    8029e6 <ftruncate+0xca>
  802974:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802978:	8b 40 08             	mov    0x8(%rax),%eax
  80297b:	83 e0 03             	and    $0x3,%eax
  80297e:	85 c0                	test   %eax,%eax
  802980:	75 3a                	jne    8029bc <ftruncate+0xa0>
  802982:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  802989:	00 00 00 
  80298c:	48 8b 00             	mov    (%rax),%rax
  80298f:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  802995:	8b 55 dc             	mov    -0x24(%rbp),%edx
  802998:	89 c6                	mov    %eax,%esi
  80299a:	48 bf 50 4d 80 00 00 	movabs $0x804d50,%rdi
  8029a1:	00 00 00 
  8029a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8029a9:	48 b9 dd 08 80 00 00 	movabs $0x8008dd,%rcx
  8029b0:	00 00 00 
  8029b3:	ff d1                	callq  *%rcx
  8029b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8029ba:	eb 2a                	jmp    8029e6 <ftruncate+0xca>
  8029bc:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8029c0:	48 8b 40 30          	mov    0x30(%rax),%rax
  8029c4:	48 85 c0             	test   %rax,%rax
  8029c7:	75 07                	jne    8029d0 <ftruncate+0xb4>
  8029c9:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  8029ce:	eb 16                	jmp    8029e6 <ftruncate+0xca>
  8029d0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8029d4:	48 8b 40 30          	mov    0x30(%rax),%rax
  8029d8:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8029dc:	8b 4d d8             	mov    -0x28(%rbp),%ecx
  8029df:	89 ce                	mov    %ecx,%esi
  8029e1:	48 89 d7             	mov    %rdx,%rdi
  8029e4:	ff d0                	callq  *%rax
  8029e6:	c9                   	leaveq 
  8029e7:	c3                   	retq   

00000000008029e8 <fstat>:
  8029e8:	55                   	push   %rbp
  8029e9:	48 89 e5             	mov    %rsp,%rbp
  8029ec:	48 83 ec 30          	sub    $0x30,%rsp
  8029f0:	89 7d dc             	mov    %edi,-0x24(%rbp)
  8029f3:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  8029f7:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  8029fb:	8b 45 dc             	mov    -0x24(%rbp),%eax
  8029fe:	48 89 d6             	mov    %rdx,%rsi
  802a01:	89 c7                	mov    %eax,%edi
  802a03:	48 b8 87 22 80 00 00 	movabs $0x802287,%rax
  802a0a:	00 00 00 
  802a0d:	ff d0                	callq  *%rax
  802a0f:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802a12:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802a16:	78 24                	js     802a3c <fstat+0x54>
  802a18:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802a1c:	8b 00                	mov    (%rax),%eax
  802a1e:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  802a22:	48 89 d6             	mov    %rdx,%rsi
  802a25:	89 c7                	mov    %eax,%edi
  802a27:	48 b8 e0 23 80 00 00 	movabs $0x8023e0,%rax
  802a2e:	00 00 00 
  802a31:	ff d0                	callq  *%rax
  802a33:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802a36:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802a3a:	79 05                	jns    802a41 <fstat+0x59>
  802a3c:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802a3f:	eb 5e                	jmp    802a9f <fstat+0xb7>
  802a41:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802a45:	48 8b 40 28          	mov    0x28(%rax),%rax
  802a49:	48 85 c0             	test   %rax,%rax
  802a4c:	75 07                	jne    802a55 <fstat+0x6d>
  802a4e:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  802a53:	eb 4a                	jmp    802a9f <fstat+0xb7>
  802a55:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  802a59:	c6 00 00             	movb   $0x0,(%rax)
  802a5c:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  802a60:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%rax)
  802a67:	00 00 00 
  802a6a:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  802a6e:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%rax)
  802a75:	00 00 00 
  802a78:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  802a7c:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  802a80:	48 89 90 88 00 00 00 	mov    %rdx,0x88(%rax)
  802a87:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802a8b:	48 8b 40 28          	mov    0x28(%rax),%rax
  802a8f:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  802a93:	48 8b 4d d0          	mov    -0x30(%rbp),%rcx
  802a97:	48 89 ce             	mov    %rcx,%rsi
  802a9a:	48 89 d7             	mov    %rdx,%rdi
  802a9d:	ff d0                	callq  *%rax
  802a9f:	c9                   	leaveq 
  802aa0:	c3                   	retq   

0000000000802aa1 <stat>:
  802aa1:	55                   	push   %rbp
  802aa2:	48 89 e5             	mov    %rsp,%rbp
  802aa5:	48 83 ec 20          	sub    $0x20,%rsp
  802aa9:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  802aad:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  802ab1:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802ab5:	be 00 00 00 00       	mov    $0x0,%esi
  802aba:	48 89 c7             	mov    %rax,%rdi
  802abd:	48 b8 8f 2b 80 00 00 	movabs $0x802b8f,%rax
  802ac4:	00 00 00 
  802ac7:	ff d0                	callq  *%rax
  802ac9:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802acc:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802ad0:	79 05                	jns    802ad7 <stat+0x36>
  802ad2:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802ad5:	eb 2f                	jmp    802b06 <stat+0x65>
  802ad7:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  802adb:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802ade:	48 89 d6             	mov    %rdx,%rsi
  802ae1:	89 c7                	mov    %eax,%edi
  802ae3:	48 b8 e8 29 80 00 00 	movabs $0x8029e8,%rax
  802aea:	00 00 00 
  802aed:	ff d0                	callq  *%rax
  802aef:	89 45 f8             	mov    %eax,-0x8(%rbp)
  802af2:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802af5:	89 c7                	mov    %eax,%edi
  802af7:	48 b8 97 24 80 00 00 	movabs $0x802497,%rax
  802afe:	00 00 00 
  802b01:	ff d0                	callq  *%rax
  802b03:	8b 45 f8             	mov    -0x8(%rbp),%eax
  802b06:	c9                   	leaveq 
  802b07:	c3                   	retq   

0000000000802b08 <fsipc>:
  802b08:	55                   	push   %rbp
  802b09:	48 89 e5             	mov    %rsp,%rbp
  802b0c:	48 83 ec 10          	sub    $0x10,%rsp
  802b10:	89 7d fc             	mov    %edi,-0x4(%rbp)
  802b13:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  802b17:	48 b8 00 70 80 00 00 	movabs $0x807000,%rax
  802b1e:	00 00 00 
  802b21:	8b 00                	mov    (%rax),%eax
  802b23:	85 c0                	test   %eax,%eax
  802b25:	75 1d                	jne    802b44 <fsipc+0x3c>
  802b27:	bf 01 00 00 00       	mov    $0x1,%edi
  802b2c:	48 b8 b6 45 80 00 00 	movabs $0x8045b6,%rax
  802b33:	00 00 00 
  802b36:	ff d0                	callq  *%rax
  802b38:	48 ba 00 70 80 00 00 	movabs $0x807000,%rdx
  802b3f:	00 00 00 
  802b42:	89 02                	mov    %eax,(%rdx)
  802b44:	48 b8 00 70 80 00 00 	movabs $0x807000,%rax
  802b4b:	00 00 00 
  802b4e:	8b 00                	mov    (%rax),%eax
  802b50:	8b 75 fc             	mov    -0x4(%rbp),%esi
  802b53:	b9 07 00 00 00       	mov    $0x7,%ecx
  802b58:	48 ba 00 80 80 00 00 	movabs $0x808000,%rdx
  802b5f:	00 00 00 
  802b62:	89 c7                	mov    %eax,%edi
  802b64:	48 b8 aa 43 80 00 00 	movabs $0x8043aa,%rax
  802b6b:	00 00 00 
  802b6e:	ff d0                	callq  *%rax
  802b70:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802b74:	ba 00 00 00 00       	mov    $0x0,%edx
  802b79:	48 89 c6             	mov    %rax,%rsi
  802b7c:	bf 00 00 00 00       	mov    $0x0,%edi
  802b81:	48 b8 e9 42 80 00 00 	movabs $0x8042e9,%rax
  802b88:	00 00 00 
  802b8b:	ff d0                	callq  *%rax
  802b8d:	c9                   	leaveq 
  802b8e:	c3                   	retq   

0000000000802b8f <open>:
  802b8f:	55                   	push   %rbp
  802b90:	48 89 e5             	mov    %rsp,%rbp
  802b93:	48 83 ec 20          	sub    $0x20,%rsp
  802b97:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  802b9b:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  802b9e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802ba2:	48 89 c7             	mov    %rax,%rdi
  802ba5:	48 b8 26 14 80 00 00 	movabs $0x801426,%rax
  802bac:	00 00 00 
  802baf:	ff d0                	callq  *%rax
  802bb1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802bb6:	7e 0a                	jle    802bc2 <open+0x33>
  802bb8:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  802bbd:	e9 a5 00 00 00       	jmpq   802c67 <open+0xd8>
  802bc2:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
  802bc6:	48 89 c7             	mov    %rax,%rdi
  802bc9:	48 b8 ef 21 80 00 00 	movabs $0x8021ef,%rax
  802bd0:	00 00 00 
  802bd3:	ff d0                	callq  *%rax
  802bd5:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802bd8:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802bdc:	79 08                	jns    802be6 <open+0x57>
  802bde:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802be1:	e9 81 00 00 00       	jmpq   802c67 <open+0xd8>
  802be6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802bea:	48 89 c6             	mov    %rax,%rsi
  802bed:	48 bf 00 80 80 00 00 	movabs $0x808000,%rdi
  802bf4:	00 00 00 
  802bf7:	48 b8 92 14 80 00 00 	movabs $0x801492,%rax
  802bfe:	00 00 00 
  802c01:	ff d0                	callq  *%rax
  802c03:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802c0a:	00 00 00 
  802c0d:	8b 55 e4             	mov    -0x1c(%rbp),%edx
  802c10:	89 90 00 04 00 00    	mov    %edx,0x400(%rax)
  802c16:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802c1a:	48 89 c6             	mov    %rax,%rsi
  802c1d:	bf 01 00 00 00       	mov    $0x1,%edi
  802c22:	48 b8 08 2b 80 00 00 	movabs $0x802b08,%rax
  802c29:	00 00 00 
  802c2c:	ff d0                	callq  *%rax
  802c2e:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802c31:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802c35:	79 1d                	jns    802c54 <open+0xc5>
  802c37:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802c3b:	be 00 00 00 00       	mov    $0x0,%esi
  802c40:	48 89 c7             	mov    %rax,%rdi
  802c43:	48 b8 17 23 80 00 00 	movabs $0x802317,%rax
  802c4a:	00 00 00 
  802c4d:	ff d0                	callq  *%rax
  802c4f:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802c52:	eb 13                	jmp    802c67 <open+0xd8>
  802c54:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802c58:	48 89 c7             	mov    %rax,%rdi
  802c5b:	48 b8 a1 21 80 00 00 	movabs $0x8021a1,%rax
  802c62:	00 00 00 
  802c65:	ff d0                	callq  *%rax
  802c67:	c9                   	leaveq 
  802c68:	c3                   	retq   

0000000000802c69 <devfile_flush>:
  802c69:	55                   	push   %rbp
  802c6a:	48 89 e5             	mov    %rsp,%rbp
  802c6d:	48 83 ec 10          	sub    $0x10,%rsp
  802c71:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  802c75:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  802c79:	8b 50 0c             	mov    0xc(%rax),%edx
  802c7c:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802c83:	00 00 00 
  802c86:	89 10                	mov    %edx,(%rax)
  802c88:	be 00 00 00 00       	mov    $0x0,%esi
  802c8d:	bf 06 00 00 00       	mov    $0x6,%edi
  802c92:	48 b8 08 2b 80 00 00 	movabs $0x802b08,%rax
  802c99:	00 00 00 
  802c9c:	ff d0                	callq  *%rax
  802c9e:	c9                   	leaveq 
  802c9f:	c3                   	retq   

0000000000802ca0 <devfile_read>:
  802ca0:	55                   	push   %rbp
  802ca1:	48 89 e5             	mov    %rsp,%rbp
  802ca4:	48 83 ec 30          	sub    $0x30,%rsp
  802ca8:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  802cac:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  802cb0:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  802cb4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802cb8:	8b 50 0c             	mov    0xc(%rax),%edx
  802cbb:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802cc2:	00 00 00 
  802cc5:	89 10                	mov    %edx,(%rax)
  802cc7:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802cce:	00 00 00 
  802cd1:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  802cd5:	48 89 50 08          	mov    %rdx,0x8(%rax)
  802cd9:	be 00 00 00 00       	mov    $0x0,%esi
  802cde:	bf 03 00 00 00       	mov    $0x3,%edi
  802ce3:	48 b8 08 2b 80 00 00 	movabs $0x802b08,%rax
  802cea:	00 00 00 
  802ced:	ff d0                	callq  *%rax
  802cef:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802cf2:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802cf6:	79 08                	jns    802d00 <devfile_read+0x60>
  802cf8:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802cfb:	e9 a4 00 00 00       	jmpq   802da4 <devfile_read+0x104>
  802d00:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802d03:	48 98                	cltq   
  802d05:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  802d09:	76 35                	jbe    802d40 <devfile_read+0xa0>
  802d0b:	48 b9 76 4d 80 00 00 	movabs $0x804d76,%rcx
  802d12:	00 00 00 
  802d15:	48 ba 7d 4d 80 00 00 	movabs $0x804d7d,%rdx
  802d1c:	00 00 00 
  802d1f:	be 89 00 00 00       	mov    $0x89,%esi
  802d24:	48 bf 92 4d 80 00 00 	movabs $0x804d92,%rdi
  802d2b:	00 00 00 
  802d2e:	b8 00 00 00 00       	mov    $0x0,%eax
  802d33:	49 b8 a4 06 80 00 00 	movabs $0x8006a4,%r8
  802d3a:	00 00 00 
  802d3d:	41 ff d0             	callq  *%r8
  802d40:	81 7d fc 00 10 00 00 	cmpl   $0x1000,-0x4(%rbp)
  802d47:	7e 35                	jle    802d7e <devfile_read+0xde>
  802d49:	48 b9 a0 4d 80 00 00 	movabs $0x804da0,%rcx
  802d50:	00 00 00 
  802d53:	48 ba 7d 4d 80 00 00 	movabs $0x804d7d,%rdx
  802d5a:	00 00 00 
  802d5d:	be 8a 00 00 00       	mov    $0x8a,%esi
  802d62:	48 bf 92 4d 80 00 00 	movabs $0x804d92,%rdi
  802d69:	00 00 00 
  802d6c:	b8 00 00 00 00       	mov    $0x0,%eax
  802d71:	49 b8 a4 06 80 00 00 	movabs $0x8006a4,%r8
  802d78:	00 00 00 
  802d7b:	41 ff d0             	callq  *%r8
  802d7e:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802d81:	48 63 d0             	movslq %eax,%rdx
  802d84:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  802d88:	48 be 00 80 80 00 00 	movabs $0x808000,%rsi
  802d8f:	00 00 00 
  802d92:	48 89 c7             	mov    %rax,%rdi
  802d95:	48 b8 b6 17 80 00 00 	movabs $0x8017b6,%rax
  802d9c:	00 00 00 
  802d9f:	ff d0                	callq  *%rax
  802da1:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802da4:	c9                   	leaveq 
  802da5:	c3                   	retq   

0000000000802da6 <devfile_write>:
  802da6:	55                   	push   %rbp
  802da7:	48 89 e5             	mov    %rsp,%rbp
  802daa:	48 83 ec 40          	sub    $0x40,%rsp
  802dae:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  802db2:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  802db6:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  802dba:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  802dbe:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  802dc2:	48 c7 45 f0 f4 0f 00 	movq   $0xff4,-0x10(%rbp)
  802dc9:	00 
  802dca:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  802dce:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
  802dd2:	48 0f 46 45 f8       	cmovbe -0x8(%rbp),%rax
  802dd7:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  802ddb:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  802ddf:	8b 50 0c             	mov    0xc(%rax),%edx
  802de2:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802de9:	00 00 00 
  802dec:	89 10                	mov    %edx,(%rax)
  802dee:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802df5:	00 00 00 
  802df8:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  802dfc:	48 89 50 08          	mov    %rdx,0x8(%rax)
  802e00:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  802e04:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  802e08:	48 89 c6             	mov    %rax,%rsi
  802e0b:	48 bf 10 80 80 00 00 	movabs $0x808010,%rdi
  802e12:	00 00 00 
  802e15:	48 b8 b6 17 80 00 00 	movabs $0x8017b6,%rax
  802e1c:	00 00 00 
  802e1f:	ff d0                	callq  *%rax
  802e21:	be 00 00 00 00       	mov    $0x0,%esi
  802e26:	bf 04 00 00 00       	mov    $0x4,%edi
  802e2b:	48 b8 08 2b 80 00 00 	movabs $0x802b08,%rax
  802e32:	00 00 00 
  802e35:	ff d0                	callq  *%rax
  802e37:	89 45 ec             	mov    %eax,-0x14(%rbp)
  802e3a:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  802e3e:	79 05                	jns    802e45 <devfile_write+0x9f>
  802e40:	8b 45 ec             	mov    -0x14(%rbp),%eax
  802e43:	eb 43                	jmp    802e88 <devfile_write+0xe2>
  802e45:	8b 45 ec             	mov    -0x14(%rbp),%eax
  802e48:	48 98                	cltq   
  802e4a:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  802e4e:	76 35                	jbe    802e85 <devfile_write+0xdf>
  802e50:	48 b9 76 4d 80 00 00 	movabs $0x804d76,%rcx
  802e57:	00 00 00 
  802e5a:	48 ba 7d 4d 80 00 00 	movabs $0x804d7d,%rdx
  802e61:	00 00 00 
  802e64:	be a8 00 00 00       	mov    $0xa8,%esi
  802e69:	48 bf 92 4d 80 00 00 	movabs $0x804d92,%rdi
  802e70:	00 00 00 
  802e73:	b8 00 00 00 00       	mov    $0x0,%eax
  802e78:	49 b8 a4 06 80 00 00 	movabs $0x8006a4,%r8
  802e7f:	00 00 00 
  802e82:	41 ff d0             	callq  *%r8
  802e85:	8b 45 ec             	mov    -0x14(%rbp),%eax
  802e88:	c9                   	leaveq 
  802e89:	c3                   	retq   

0000000000802e8a <devfile_stat>:
  802e8a:	55                   	push   %rbp
  802e8b:	48 89 e5             	mov    %rsp,%rbp
  802e8e:	48 83 ec 20          	sub    $0x20,%rsp
  802e92:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  802e96:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  802e9a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  802e9e:	8b 50 0c             	mov    0xc(%rax),%edx
  802ea1:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802ea8:	00 00 00 
  802eab:	89 10                	mov    %edx,(%rax)
  802ead:	be 00 00 00 00       	mov    $0x0,%esi
  802eb2:	bf 05 00 00 00       	mov    $0x5,%edi
  802eb7:	48 b8 08 2b 80 00 00 	movabs $0x802b08,%rax
  802ebe:	00 00 00 
  802ec1:	ff d0                	callq  *%rax
  802ec3:	89 45 fc             	mov    %eax,-0x4(%rbp)
  802ec6:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  802eca:	79 05                	jns    802ed1 <devfile_stat+0x47>
  802ecc:	8b 45 fc             	mov    -0x4(%rbp),%eax
  802ecf:	eb 56                	jmp    802f27 <devfile_stat+0x9d>
  802ed1:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  802ed5:	48 be 00 80 80 00 00 	movabs $0x808000,%rsi
  802edc:	00 00 00 
  802edf:	48 89 c7             	mov    %rax,%rdi
  802ee2:	48 b8 92 14 80 00 00 	movabs $0x801492,%rax
  802ee9:	00 00 00 
  802eec:	ff d0                	callq  *%rax
  802eee:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802ef5:	00 00 00 
  802ef8:	8b 90 80 00 00 00    	mov    0x80(%rax),%edx
  802efe:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  802f02:	89 90 80 00 00 00    	mov    %edx,0x80(%rax)
  802f08:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802f0f:	00 00 00 
  802f12:	8b 90 84 00 00 00    	mov    0x84(%rax),%edx
  802f18:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  802f1c:	89 90 84 00 00 00    	mov    %edx,0x84(%rax)
  802f22:	b8 00 00 00 00       	mov    $0x0,%eax
  802f27:	c9                   	leaveq 
  802f28:	c3                   	retq   

0000000000802f29 <devfile_trunc>:
  802f29:	55                   	push   %rbp
  802f2a:	48 89 e5             	mov    %rsp,%rbp
  802f2d:	48 83 ec 10          	sub    $0x10,%rsp
  802f31:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  802f35:	89 75 f4             	mov    %esi,-0xc(%rbp)
  802f38:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  802f3c:	8b 50 0c             	mov    0xc(%rax),%edx
  802f3f:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802f46:	00 00 00 
  802f49:	89 10                	mov    %edx,(%rax)
  802f4b:	48 b8 00 80 80 00 00 	movabs $0x808000,%rax
  802f52:	00 00 00 
  802f55:	8b 55 f4             	mov    -0xc(%rbp),%edx
  802f58:	89 50 04             	mov    %edx,0x4(%rax)
  802f5b:	be 00 00 00 00       	mov    $0x0,%esi
  802f60:	bf 02 00 00 00       	mov    $0x2,%edi
  802f65:	48 b8 08 2b 80 00 00 	movabs $0x802b08,%rax
  802f6c:	00 00 00 
  802f6f:	ff d0                	callq  *%rax
  802f71:	c9                   	leaveq 
  802f72:	c3                   	retq   

0000000000802f73 <remove>:
  802f73:	55                   	push   %rbp
  802f74:	48 89 e5             	mov    %rsp,%rbp
  802f77:	48 83 ec 10          	sub    $0x10,%rsp
  802f7b:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  802f7f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  802f83:	48 89 c7             	mov    %rax,%rdi
  802f86:	48 b8 26 14 80 00 00 	movabs $0x801426,%rax
  802f8d:	00 00 00 
  802f90:	ff d0                	callq  *%rax
  802f92:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802f97:	7e 07                	jle    802fa0 <remove+0x2d>
  802f99:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  802f9e:	eb 33                	jmp    802fd3 <remove+0x60>
  802fa0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  802fa4:	48 89 c6             	mov    %rax,%rsi
  802fa7:	48 bf 00 80 80 00 00 	movabs $0x808000,%rdi
  802fae:	00 00 00 
  802fb1:	48 b8 92 14 80 00 00 	movabs $0x801492,%rax
  802fb8:	00 00 00 
  802fbb:	ff d0                	callq  *%rax
  802fbd:	be 00 00 00 00       	mov    $0x0,%esi
  802fc2:	bf 07 00 00 00       	mov    $0x7,%edi
  802fc7:	48 b8 08 2b 80 00 00 	movabs $0x802b08,%rax
  802fce:	00 00 00 
  802fd1:	ff d0                	callq  *%rax
  802fd3:	c9                   	leaveq 
  802fd4:	c3                   	retq   

0000000000802fd5 <sync>:
  802fd5:	55                   	push   %rbp
  802fd6:	48 89 e5             	mov    %rsp,%rbp
  802fd9:	be 00 00 00 00       	mov    $0x0,%esi
  802fde:	bf 08 00 00 00       	mov    $0x8,%edi
  802fe3:	48 b8 08 2b 80 00 00 	movabs $0x802b08,%rax
  802fea:	00 00 00 
  802fed:	ff d0                	callq  *%rax
  802fef:	5d                   	pop    %rbp
  802ff0:	c3                   	retq   

0000000000802ff1 <copy>:
  802ff1:	55                   	push   %rbp
  802ff2:	48 89 e5             	mov    %rsp,%rbp
  802ff5:	48 81 ec 20 02 00 00 	sub    $0x220,%rsp
  802ffc:	48 89 bd e8 fd ff ff 	mov    %rdi,-0x218(%rbp)
  803003:	48 89 b5 e0 fd ff ff 	mov    %rsi,-0x220(%rbp)
  80300a:	48 8b 85 e8 fd ff ff 	mov    -0x218(%rbp),%rax
  803011:	be 00 00 00 00       	mov    $0x0,%esi
  803016:	48 89 c7             	mov    %rax,%rdi
  803019:	48 b8 8f 2b 80 00 00 	movabs $0x802b8f,%rax
  803020:	00 00 00 
  803023:	ff d0                	callq  *%rax
  803025:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803028:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80302c:	79 28                	jns    803056 <copy+0x65>
  80302e:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803031:	89 c6                	mov    %eax,%esi
  803033:	48 bf ac 4d 80 00 00 	movabs $0x804dac,%rdi
  80303a:	00 00 00 
  80303d:	b8 00 00 00 00       	mov    $0x0,%eax
  803042:	48 ba dd 08 80 00 00 	movabs $0x8008dd,%rdx
  803049:	00 00 00 
  80304c:	ff d2                	callq  *%rdx
  80304e:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803051:	e9 74 01 00 00       	jmpq   8031ca <copy+0x1d9>
  803056:	48 8b 85 e0 fd ff ff 	mov    -0x220(%rbp),%rax
  80305d:	be 01 01 00 00       	mov    $0x101,%esi
  803062:	48 89 c7             	mov    %rax,%rdi
  803065:	48 b8 8f 2b 80 00 00 	movabs $0x802b8f,%rax
  80306c:	00 00 00 
  80306f:	ff d0                	callq  *%rax
  803071:	89 45 f8             	mov    %eax,-0x8(%rbp)
  803074:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  803078:	79 39                	jns    8030b3 <copy+0xc2>
  80307a:	8b 45 f8             	mov    -0x8(%rbp),%eax
  80307d:	89 c6                	mov    %eax,%esi
  80307f:	48 bf c2 4d 80 00 00 	movabs $0x804dc2,%rdi
  803086:	00 00 00 
  803089:	b8 00 00 00 00       	mov    $0x0,%eax
  80308e:	48 ba dd 08 80 00 00 	movabs $0x8008dd,%rdx
  803095:	00 00 00 
  803098:	ff d2                	callq  *%rdx
  80309a:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80309d:	89 c7                	mov    %eax,%edi
  80309f:	48 b8 97 24 80 00 00 	movabs $0x802497,%rax
  8030a6:	00 00 00 
  8030a9:	ff d0                	callq  *%rax
  8030ab:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8030ae:	e9 17 01 00 00       	jmpq   8031ca <copy+0x1d9>
  8030b3:	eb 74                	jmp    803129 <copy+0x138>
  8030b5:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8030b8:	48 63 d0             	movslq %eax,%rdx
  8030bb:	48 8d 8d f0 fd ff ff 	lea    -0x210(%rbp),%rcx
  8030c2:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8030c5:	48 89 ce             	mov    %rcx,%rsi
  8030c8:	89 c7                	mov    %eax,%edi
  8030ca:	48 b8 03 28 80 00 00 	movabs $0x802803,%rax
  8030d1:	00 00 00 
  8030d4:	ff d0                	callq  *%rax
  8030d6:	89 45 f0             	mov    %eax,-0x10(%rbp)
  8030d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
  8030dd:	79 4a                	jns    803129 <copy+0x138>
  8030df:	8b 45 f0             	mov    -0x10(%rbp),%eax
  8030e2:	89 c6                	mov    %eax,%esi
  8030e4:	48 bf dc 4d 80 00 00 	movabs $0x804ddc,%rdi
  8030eb:	00 00 00 
  8030ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8030f3:	48 ba dd 08 80 00 00 	movabs $0x8008dd,%rdx
  8030fa:	00 00 00 
  8030fd:	ff d2                	callq  *%rdx
  8030ff:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803102:	89 c7                	mov    %eax,%edi
  803104:	48 b8 97 24 80 00 00 	movabs $0x802497,%rax
  80310b:	00 00 00 
  80310e:	ff d0                	callq  *%rax
  803110:	8b 45 f8             	mov    -0x8(%rbp),%eax
  803113:	89 c7                	mov    %eax,%edi
  803115:	48 b8 97 24 80 00 00 	movabs $0x802497,%rax
  80311c:	00 00 00 
  80311f:	ff d0                	callq  *%rax
  803121:	8b 45 f0             	mov    -0x10(%rbp),%eax
  803124:	e9 a1 00 00 00       	jmpq   8031ca <copy+0x1d9>
  803129:	48 8d 8d f0 fd ff ff 	lea    -0x210(%rbp),%rcx
  803130:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803133:	ba 00 02 00 00       	mov    $0x200,%edx
  803138:	48 89 ce             	mov    %rcx,%rsi
  80313b:	89 c7                	mov    %eax,%edi
  80313d:	48 b8 b9 26 80 00 00 	movabs $0x8026b9,%rax
  803144:	00 00 00 
  803147:	ff d0                	callq  *%rax
  803149:	89 45 f4             	mov    %eax,-0xc(%rbp)
  80314c:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
  803150:	0f 8f 5f ff ff ff    	jg     8030b5 <copy+0xc4>
  803156:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
  80315a:	79 47                	jns    8031a3 <copy+0x1b2>
  80315c:	8b 45 f4             	mov    -0xc(%rbp),%eax
  80315f:	89 c6                	mov    %eax,%esi
  803161:	48 bf ef 4d 80 00 00 	movabs $0x804def,%rdi
  803168:	00 00 00 
  80316b:	b8 00 00 00 00       	mov    $0x0,%eax
  803170:	48 ba dd 08 80 00 00 	movabs $0x8008dd,%rdx
  803177:	00 00 00 
  80317a:	ff d2                	callq  *%rdx
  80317c:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80317f:	89 c7                	mov    %eax,%edi
  803181:	48 b8 97 24 80 00 00 	movabs $0x802497,%rax
  803188:	00 00 00 
  80318b:	ff d0                	callq  *%rax
  80318d:	8b 45 f8             	mov    -0x8(%rbp),%eax
  803190:	89 c7                	mov    %eax,%edi
  803192:	48 b8 97 24 80 00 00 	movabs $0x802497,%rax
  803199:	00 00 00 
  80319c:	ff d0                	callq  *%rax
  80319e:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8031a1:	eb 27                	jmp    8031ca <copy+0x1d9>
  8031a3:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8031a6:	89 c7                	mov    %eax,%edi
  8031a8:	48 b8 97 24 80 00 00 	movabs $0x802497,%rax
  8031af:	00 00 00 
  8031b2:	ff d0                	callq  *%rax
  8031b4:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8031b7:	89 c7                	mov    %eax,%edi
  8031b9:	48 b8 97 24 80 00 00 	movabs $0x802497,%rax
  8031c0:	00 00 00 
  8031c3:	ff d0                	callq  *%rax
  8031c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8031ca:	c9                   	leaveq 
  8031cb:	c3                   	retq   

00000000008031cc <fd2sockid>:
  8031cc:	55                   	push   %rbp
  8031cd:	48 89 e5             	mov    %rsp,%rbp
  8031d0:	48 83 ec 20          	sub    $0x20,%rsp
  8031d4:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8031d7:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  8031db:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8031de:	48 89 d6             	mov    %rdx,%rsi
  8031e1:	89 c7                	mov    %eax,%edi
  8031e3:	48 b8 87 22 80 00 00 	movabs $0x802287,%rax
  8031ea:	00 00 00 
  8031ed:	ff d0                	callq  *%rax
  8031ef:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8031f2:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8031f6:	79 05                	jns    8031fd <fd2sockid+0x31>
  8031f8:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8031fb:	eb 24                	jmp    803221 <fd2sockid+0x55>
  8031fd:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803201:	8b 10                	mov    (%rax),%edx
  803203:	48 b8 a0 60 80 00 00 	movabs $0x8060a0,%rax
  80320a:	00 00 00 
  80320d:	8b 00                	mov    (%rax),%eax
  80320f:	39 c2                	cmp    %eax,%edx
  803211:	74 07                	je     80321a <fd2sockid+0x4e>
  803213:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  803218:	eb 07                	jmp    803221 <fd2sockid+0x55>
  80321a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80321e:	8b 40 0c             	mov    0xc(%rax),%eax
  803221:	c9                   	leaveq 
  803222:	c3                   	retq   

0000000000803223 <alloc_sockfd>:
  803223:	55                   	push   %rbp
  803224:	48 89 e5             	mov    %rsp,%rbp
  803227:	48 83 ec 20          	sub    $0x20,%rsp
  80322b:	89 7d ec             	mov    %edi,-0x14(%rbp)
  80322e:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
  803232:	48 89 c7             	mov    %rax,%rdi
  803235:	48 b8 ef 21 80 00 00 	movabs $0x8021ef,%rax
  80323c:	00 00 00 
  80323f:	ff d0                	callq  *%rax
  803241:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803244:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803248:	78 26                	js     803270 <alloc_sockfd+0x4d>
  80324a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80324e:	ba 07 04 00 00       	mov    $0x407,%edx
  803253:	48 89 c6             	mov    %rax,%rsi
  803256:	bf 00 00 00 00       	mov    $0x0,%edi
  80325b:	48 b8 c1 1d 80 00 00 	movabs $0x801dc1,%rax
  803262:	00 00 00 
  803265:	ff d0                	callq  *%rax
  803267:	89 45 fc             	mov    %eax,-0x4(%rbp)
  80326a:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80326e:	79 16                	jns    803286 <alloc_sockfd+0x63>
  803270:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803273:	89 c7                	mov    %eax,%edi
  803275:	48 b8 30 37 80 00 00 	movabs $0x803730,%rax
  80327c:	00 00 00 
  80327f:	ff d0                	callq  *%rax
  803281:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803284:	eb 3a                	jmp    8032c0 <alloc_sockfd+0x9d>
  803286:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80328a:	48 ba a0 60 80 00 00 	movabs $0x8060a0,%rdx
  803291:	00 00 00 
  803294:	8b 12                	mov    (%rdx),%edx
  803296:	89 10                	mov    %edx,(%rax)
  803298:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80329c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%rax)
  8032a3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8032a7:	8b 55 ec             	mov    -0x14(%rbp),%edx
  8032aa:	89 50 0c             	mov    %edx,0xc(%rax)
  8032ad:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8032b1:	48 89 c7             	mov    %rax,%rdi
  8032b4:	48 b8 a1 21 80 00 00 	movabs $0x8021a1,%rax
  8032bb:	00 00 00 
  8032be:	ff d0                	callq  *%rax
  8032c0:	c9                   	leaveq 
  8032c1:	c3                   	retq   

00000000008032c2 <accept>:
  8032c2:	55                   	push   %rbp
  8032c3:	48 89 e5             	mov    %rsp,%rbp
  8032c6:	48 83 ec 30          	sub    $0x30,%rsp
  8032ca:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8032cd:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8032d1:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  8032d5:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8032d8:	89 c7                	mov    %eax,%edi
  8032da:	48 b8 cc 31 80 00 00 	movabs $0x8031cc,%rax
  8032e1:	00 00 00 
  8032e4:	ff d0                	callq  *%rax
  8032e6:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8032e9:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8032ed:	79 05                	jns    8032f4 <accept+0x32>
  8032ef:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8032f2:	eb 3b                	jmp    80332f <accept+0x6d>
  8032f4:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  8032f8:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  8032fc:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8032ff:	48 89 ce             	mov    %rcx,%rsi
  803302:	89 c7                	mov    %eax,%edi
  803304:	48 b8 0d 36 80 00 00 	movabs $0x80360d,%rax
  80330b:	00 00 00 
  80330e:	ff d0                	callq  *%rax
  803310:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803313:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803317:	79 05                	jns    80331e <accept+0x5c>
  803319:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80331c:	eb 11                	jmp    80332f <accept+0x6d>
  80331e:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803321:	89 c7                	mov    %eax,%edi
  803323:	48 b8 23 32 80 00 00 	movabs $0x803223,%rax
  80332a:	00 00 00 
  80332d:	ff d0                	callq  *%rax
  80332f:	c9                   	leaveq 
  803330:	c3                   	retq   

0000000000803331 <bind>:
  803331:	55                   	push   %rbp
  803332:	48 89 e5             	mov    %rsp,%rbp
  803335:	48 83 ec 20          	sub    $0x20,%rsp
  803339:	89 7d ec             	mov    %edi,-0x14(%rbp)
  80333c:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  803340:	89 55 e8             	mov    %edx,-0x18(%rbp)
  803343:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803346:	89 c7                	mov    %eax,%edi
  803348:	48 b8 cc 31 80 00 00 	movabs $0x8031cc,%rax
  80334f:	00 00 00 
  803352:	ff d0                	callq  *%rax
  803354:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803357:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80335b:	79 05                	jns    803362 <bind+0x31>
  80335d:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803360:	eb 1b                	jmp    80337d <bind+0x4c>
  803362:	8b 55 e8             	mov    -0x18(%rbp),%edx
  803365:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  803369:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80336c:	48 89 ce             	mov    %rcx,%rsi
  80336f:	89 c7                	mov    %eax,%edi
  803371:	48 b8 8c 36 80 00 00 	movabs $0x80368c,%rax
  803378:	00 00 00 
  80337b:	ff d0                	callq  *%rax
  80337d:	c9                   	leaveq 
  80337e:	c3                   	retq   

000000000080337f <shutdown>:
  80337f:	55                   	push   %rbp
  803380:	48 89 e5             	mov    %rsp,%rbp
  803383:	48 83 ec 20          	sub    $0x20,%rsp
  803387:	89 7d ec             	mov    %edi,-0x14(%rbp)
  80338a:	89 75 e8             	mov    %esi,-0x18(%rbp)
  80338d:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803390:	89 c7                	mov    %eax,%edi
  803392:	48 b8 cc 31 80 00 00 	movabs $0x8031cc,%rax
  803399:	00 00 00 
  80339c:	ff d0                	callq  *%rax
  80339e:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8033a1:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8033a5:	79 05                	jns    8033ac <shutdown+0x2d>
  8033a7:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8033aa:	eb 16                	jmp    8033c2 <shutdown+0x43>
  8033ac:	8b 55 e8             	mov    -0x18(%rbp),%edx
  8033af:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8033b2:	89 d6                	mov    %edx,%esi
  8033b4:	89 c7                	mov    %eax,%edi
  8033b6:	48 b8 f0 36 80 00 00 	movabs $0x8036f0,%rax
  8033bd:	00 00 00 
  8033c0:	ff d0                	callq  *%rax
  8033c2:	c9                   	leaveq 
  8033c3:	c3                   	retq   

00000000008033c4 <devsock_close>:
  8033c4:	55                   	push   %rbp
  8033c5:	48 89 e5             	mov    %rsp,%rbp
  8033c8:	48 83 ec 10          	sub    $0x10,%rsp
  8033cc:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8033d0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8033d4:	48 89 c7             	mov    %rax,%rdi
  8033d7:	48 b8 28 46 80 00 00 	movabs $0x804628,%rax
  8033de:	00 00 00 
  8033e1:	ff d0                	callq  *%rax
  8033e3:	83 f8 01             	cmp    $0x1,%eax
  8033e6:	75 17                	jne    8033ff <devsock_close+0x3b>
  8033e8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8033ec:	8b 40 0c             	mov    0xc(%rax),%eax
  8033ef:	89 c7                	mov    %eax,%edi
  8033f1:	48 b8 30 37 80 00 00 	movabs $0x803730,%rax
  8033f8:	00 00 00 
  8033fb:	ff d0                	callq  *%rax
  8033fd:	eb 05                	jmp    803404 <devsock_close+0x40>
  8033ff:	b8 00 00 00 00       	mov    $0x0,%eax
  803404:	c9                   	leaveq 
  803405:	c3                   	retq   

0000000000803406 <connect>:
  803406:	55                   	push   %rbp
  803407:	48 89 e5             	mov    %rsp,%rbp
  80340a:	48 83 ec 20          	sub    $0x20,%rsp
  80340e:	89 7d ec             	mov    %edi,-0x14(%rbp)
  803411:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  803415:	89 55 e8             	mov    %edx,-0x18(%rbp)
  803418:	8b 45 ec             	mov    -0x14(%rbp),%eax
  80341b:	89 c7                	mov    %eax,%edi
  80341d:	48 b8 cc 31 80 00 00 	movabs $0x8031cc,%rax
  803424:	00 00 00 
  803427:	ff d0                	callq  *%rax
  803429:	89 45 fc             	mov    %eax,-0x4(%rbp)
  80342c:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803430:	79 05                	jns    803437 <connect+0x31>
  803432:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803435:	eb 1b                	jmp    803452 <connect+0x4c>
  803437:	8b 55 e8             	mov    -0x18(%rbp),%edx
  80343a:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  80343e:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803441:	48 89 ce             	mov    %rcx,%rsi
  803444:	89 c7                	mov    %eax,%edi
  803446:	48 b8 5d 37 80 00 00 	movabs $0x80375d,%rax
  80344d:	00 00 00 
  803450:	ff d0                	callq  *%rax
  803452:	c9                   	leaveq 
  803453:	c3                   	retq   

0000000000803454 <listen>:
  803454:	55                   	push   %rbp
  803455:	48 89 e5             	mov    %rsp,%rbp
  803458:	48 83 ec 20          	sub    $0x20,%rsp
  80345c:	89 7d ec             	mov    %edi,-0x14(%rbp)
  80345f:	89 75 e8             	mov    %esi,-0x18(%rbp)
  803462:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803465:	89 c7                	mov    %eax,%edi
  803467:	48 b8 cc 31 80 00 00 	movabs $0x8031cc,%rax
  80346e:	00 00 00 
  803471:	ff d0                	callq  *%rax
  803473:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803476:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80347a:	79 05                	jns    803481 <listen+0x2d>
  80347c:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80347f:	eb 16                	jmp    803497 <listen+0x43>
  803481:	8b 55 e8             	mov    -0x18(%rbp),%edx
  803484:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803487:	89 d6                	mov    %edx,%esi
  803489:	89 c7                	mov    %eax,%edi
  80348b:	48 b8 c1 37 80 00 00 	movabs $0x8037c1,%rax
  803492:	00 00 00 
  803495:	ff d0                	callq  *%rax
  803497:	c9                   	leaveq 
  803498:	c3                   	retq   

0000000000803499 <devsock_read>:
  803499:	55                   	push   %rbp
  80349a:	48 89 e5             	mov    %rsp,%rbp
  80349d:	48 83 ec 20          	sub    $0x20,%rsp
  8034a1:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8034a5:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8034a9:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8034ad:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8034b1:	89 c2                	mov    %eax,%edx
  8034b3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8034b7:	8b 40 0c             	mov    0xc(%rax),%eax
  8034ba:	48 8b 75 f0          	mov    -0x10(%rbp),%rsi
  8034be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8034c3:	89 c7                	mov    %eax,%edi
  8034c5:	48 b8 01 38 80 00 00 	movabs $0x803801,%rax
  8034cc:	00 00 00 
  8034cf:	ff d0                	callq  *%rax
  8034d1:	c9                   	leaveq 
  8034d2:	c3                   	retq   

00000000008034d3 <devsock_write>:
  8034d3:	55                   	push   %rbp
  8034d4:	48 89 e5             	mov    %rsp,%rbp
  8034d7:	48 83 ec 20          	sub    $0x20,%rsp
  8034db:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8034df:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8034e3:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8034e7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8034eb:	89 c2                	mov    %eax,%edx
  8034ed:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8034f1:	8b 40 0c             	mov    0xc(%rax),%eax
  8034f4:	48 8b 75 f0          	mov    -0x10(%rbp),%rsi
  8034f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8034fd:	89 c7                	mov    %eax,%edi
  8034ff:	48 b8 cd 38 80 00 00 	movabs $0x8038cd,%rax
  803506:	00 00 00 
  803509:	ff d0                	callq  *%rax
  80350b:	c9                   	leaveq 
  80350c:	c3                   	retq   

000000000080350d <devsock_stat>:
  80350d:	55                   	push   %rbp
  80350e:	48 89 e5             	mov    %rsp,%rbp
  803511:	48 83 ec 10          	sub    $0x10,%rsp
  803515:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  803519:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  80351d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803521:	48 be 0a 4e 80 00 00 	movabs $0x804e0a,%rsi
  803528:	00 00 00 
  80352b:	48 89 c7             	mov    %rax,%rdi
  80352e:	48 b8 92 14 80 00 00 	movabs $0x801492,%rax
  803535:	00 00 00 
  803538:	ff d0                	callq  *%rax
  80353a:	b8 00 00 00 00       	mov    $0x0,%eax
  80353f:	c9                   	leaveq 
  803540:	c3                   	retq   

0000000000803541 <socket>:
  803541:	55                   	push   %rbp
  803542:	48 89 e5             	mov    %rsp,%rbp
  803545:	48 83 ec 20          	sub    $0x20,%rsp
  803549:	89 7d ec             	mov    %edi,-0x14(%rbp)
  80354c:	89 75 e8             	mov    %esi,-0x18(%rbp)
  80354f:	89 55 e4             	mov    %edx,-0x1c(%rbp)
  803552:	8b 55 e4             	mov    -0x1c(%rbp),%edx
  803555:	8b 4d e8             	mov    -0x18(%rbp),%ecx
  803558:	8b 45 ec             	mov    -0x14(%rbp),%eax
  80355b:	89 ce                	mov    %ecx,%esi
  80355d:	89 c7                	mov    %eax,%edi
  80355f:	48 b8 85 39 80 00 00 	movabs $0x803985,%rax
  803566:	00 00 00 
  803569:	ff d0                	callq  *%rax
  80356b:	89 45 fc             	mov    %eax,-0x4(%rbp)
  80356e:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803572:	79 05                	jns    803579 <socket+0x38>
  803574:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803577:	eb 11                	jmp    80358a <socket+0x49>
  803579:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80357c:	89 c7                	mov    %eax,%edi
  80357e:	48 b8 23 32 80 00 00 	movabs $0x803223,%rax
  803585:	00 00 00 
  803588:	ff d0                	callq  *%rax
  80358a:	c9                   	leaveq 
  80358b:	c3                   	retq   

000000000080358c <nsipc>:
  80358c:	55                   	push   %rbp
  80358d:	48 89 e5             	mov    %rsp,%rbp
  803590:	48 83 ec 10          	sub    $0x10,%rsp
  803594:	89 7d fc             	mov    %edi,-0x4(%rbp)
  803597:	48 b8 04 70 80 00 00 	movabs $0x807004,%rax
  80359e:	00 00 00 
  8035a1:	8b 00                	mov    (%rax),%eax
  8035a3:	85 c0                	test   %eax,%eax
  8035a5:	75 1d                	jne    8035c4 <nsipc+0x38>
  8035a7:	bf 02 00 00 00       	mov    $0x2,%edi
  8035ac:	48 b8 b6 45 80 00 00 	movabs $0x8045b6,%rax
  8035b3:	00 00 00 
  8035b6:	ff d0                	callq  *%rax
  8035b8:	48 ba 04 70 80 00 00 	movabs $0x807004,%rdx
  8035bf:	00 00 00 
  8035c2:	89 02                	mov    %eax,(%rdx)
  8035c4:	48 b8 04 70 80 00 00 	movabs $0x807004,%rax
  8035cb:	00 00 00 
  8035ce:	8b 00                	mov    (%rax),%eax
  8035d0:	8b 75 fc             	mov    -0x4(%rbp),%esi
  8035d3:	b9 07 00 00 00       	mov    $0x7,%ecx
  8035d8:	48 ba 00 a0 80 00 00 	movabs $0x80a000,%rdx
  8035df:	00 00 00 
  8035e2:	89 c7                	mov    %eax,%edi
  8035e4:	48 b8 aa 43 80 00 00 	movabs $0x8043aa,%rax
  8035eb:	00 00 00 
  8035ee:	ff d0                	callq  *%rax
  8035f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8035f5:	be 00 00 00 00       	mov    $0x0,%esi
  8035fa:	bf 00 00 00 00       	mov    $0x0,%edi
  8035ff:	48 b8 e9 42 80 00 00 	movabs $0x8042e9,%rax
  803606:	00 00 00 
  803609:	ff d0                	callq  *%rax
  80360b:	c9                   	leaveq 
  80360c:	c3                   	retq   

000000000080360d <nsipc_accept>:
  80360d:	55                   	push   %rbp
  80360e:	48 89 e5             	mov    %rsp,%rbp
  803611:	48 83 ec 30          	sub    $0x30,%rsp
  803615:	89 7d ec             	mov    %edi,-0x14(%rbp)
  803618:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  80361c:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  803620:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803627:	00 00 00 
  80362a:	8b 55 ec             	mov    -0x14(%rbp),%edx
  80362d:	89 10                	mov    %edx,(%rax)
  80362f:	bf 01 00 00 00       	mov    $0x1,%edi
  803634:	48 b8 8c 35 80 00 00 	movabs $0x80358c,%rax
  80363b:	00 00 00 
  80363e:	ff d0                	callq  *%rax
  803640:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803643:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803647:	78 3e                	js     803687 <nsipc_accept+0x7a>
  803649:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803650:	00 00 00 
  803653:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  803657:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80365b:	8b 40 10             	mov    0x10(%rax),%eax
  80365e:	89 c2                	mov    %eax,%edx
  803660:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  803664:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803668:	48 89 ce             	mov    %rcx,%rsi
  80366b:	48 89 c7             	mov    %rax,%rdi
  80366e:	48 b8 b6 17 80 00 00 	movabs $0x8017b6,%rax
  803675:	00 00 00 
  803678:	ff d0                	callq  *%rax
  80367a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80367e:	8b 50 10             	mov    0x10(%rax),%edx
  803681:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803685:	89 10                	mov    %edx,(%rax)
  803687:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80368a:	c9                   	leaveq 
  80368b:	c3                   	retq   

000000000080368c <nsipc_bind>:
  80368c:	55                   	push   %rbp
  80368d:	48 89 e5             	mov    %rsp,%rbp
  803690:	48 83 ec 10          	sub    $0x10,%rsp
  803694:	89 7d fc             	mov    %edi,-0x4(%rbp)
  803697:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  80369b:	89 55 f8             	mov    %edx,-0x8(%rbp)
  80369e:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  8036a5:	00 00 00 
  8036a8:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8036ab:	89 10                	mov    %edx,(%rax)
  8036ad:	8b 55 f8             	mov    -0x8(%rbp),%edx
  8036b0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8036b4:	48 89 c6             	mov    %rax,%rsi
  8036b7:	48 bf 04 a0 80 00 00 	movabs $0x80a004,%rdi
  8036be:	00 00 00 
  8036c1:	48 b8 b6 17 80 00 00 	movabs $0x8017b6,%rax
  8036c8:	00 00 00 
  8036cb:	ff d0                	callq  *%rax
  8036cd:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  8036d4:	00 00 00 
  8036d7:	8b 55 f8             	mov    -0x8(%rbp),%edx
  8036da:	89 50 14             	mov    %edx,0x14(%rax)
  8036dd:	bf 02 00 00 00       	mov    $0x2,%edi
  8036e2:	48 b8 8c 35 80 00 00 	movabs $0x80358c,%rax
  8036e9:	00 00 00 
  8036ec:	ff d0                	callq  *%rax
  8036ee:	c9                   	leaveq 
  8036ef:	c3                   	retq   

00000000008036f0 <nsipc_shutdown>:
  8036f0:	55                   	push   %rbp
  8036f1:	48 89 e5             	mov    %rsp,%rbp
  8036f4:	48 83 ec 10          	sub    $0x10,%rsp
  8036f8:	89 7d fc             	mov    %edi,-0x4(%rbp)
  8036fb:	89 75 f8             	mov    %esi,-0x8(%rbp)
  8036fe:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803705:	00 00 00 
  803708:	8b 55 fc             	mov    -0x4(%rbp),%edx
  80370b:	89 10                	mov    %edx,(%rax)
  80370d:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803714:	00 00 00 
  803717:	8b 55 f8             	mov    -0x8(%rbp),%edx
  80371a:	89 50 04             	mov    %edx,0x4(%rax)
  80371d:	bf 03 00 00 00       	mov    $0x3,%edi
  803722:	48 b8 8c 35 80 00 00 	movabs $0x80358c,%rax
  803729:	00 00 00 
  80372c:	ff d0                	callq  *%rax
  80372e:	c9                   	leaveq 
  80372f:	c3                   	retq   

0000000000803730 <nsipc_close>:
  803730:	55                   	push   %rbp
  803731:	48 89 e5             	mov    %rsp,%rbp
  803734:	48 83 ec 10          	sub    $0x10,%rsp
  803738:	89 7d fc             	mov    %edi,-0x4(%rbp)
  80373b:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803742:	00 00 00 
  803745:	8b 55 fc             	mov    -0x4(%rbp),%edx
  803748:	89 10                	mov    %edx,(%rax)
  80374a:	bf 04 00 00 00       	mov    $0x4,%edi
  80374f:	48 b8 8c 35 80 00 00 	movabs $0x80358c,%rax
  803756:	00 00 00 
  803759:	ff d0                	callq  *%rax
  80375b:	c9                   	leaveq 
  80375c:	c3                   	retq   

000000000080375d <nsipc_connect>:
  80375d:	55                   	push   %rbp
  80375e:	48 89 e5             	mov    %rsp,%rbp
  803761:	48 83 ec 10          	sub    $0x10,%rsp
  803765:	89 7d fc             	mov    %edi,-0x4(%rbp)
  803768:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  80376c:	89 55 f8             	mov    %edx,-0x8(%rbp)
  80376f:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803776:	00 00 00 
  803779:	8b 55 fc             	mov    -0x4(%rbp),%edx
  80377c:	89 10                	mov    %edx,(%rax)
  80377e:	8b 55 f8             	mov    -0x8(%rbp),%edx
  803781:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803785:	48 89 c6             	mov    %rax,%rsi
  803788:	48 bf 04 a0 80 00 00 	movabs $0x80a004,%rdi
  80378f:	00 00 00 
  803792:	48 b8 b6 17 80 00 00 	movabs $0x8017b6,%rax
  803799:	00 00 00 
  80379c:	ff d0                	callq  *%rax
  80379e:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  8037a5:	00 00 00 
  8037a8:	8b 55 f8             	mov    -0x8(%rbp),%edx
  8037ab:	89 50 14             	mov    %edx,0x14(%rax)
  8037ae:	bf 05 00 00 00       	mov    $0x5,%edi
  8037b3:	48 b8 8c 35 80 00 00 	movabs $0x80358c,%rax
  8037ba:	00 00 00 
  8037bd:	ff d0                	callq  *%rax
  8037bf:	c9                   	leaveq 
  8037c0:	c3                   	retq   

00000000008037c1 <nsipc_listen>:
  8037c1:	55                   	push   %rbp
  8037c2:	48 89 e5             	mov    %rsp,%rbp
  8037c5:	48 83 ec 10          	sub    $0x10,%rsp
  8037c9:	89 7d fc             	mov    %edi,-0x4(%rbp)
  8037cc:	89 75 f8             	mov    %esi,-0x8(%rbp)
  8037cf:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  8037d6:	00 00 00 
  8037d9:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8037dc:	89 10                	mov    %edx,(%rax)
  8037de:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  8037e5:	00 00 00 
  8037e8:	8b 55 f8             	mov    -0x8(%rbp),%edx
  8037eb:	89 50 04             	mov    %edx,0x4(%rax)
  8037ee:	bf 06 00 00 00       	mov    $0x6,%edi
  8037f3:	48 b8 8c 35 80 00 00 	movabs $0x80358c,%rax
  8037fa:	00 00 00 
  8037fd:	ff d0                	callq  *%rax
  8037ff:	c9                   	leaveq 
  803800:	c3                   	retq   

0000000000803801 <nsipc_recv>:
  803801:	55                   	push   %rbp
  803802:	48 89 e5             	mov    %rsp,%rbp
  803805:	48 83 ec 30          	sub    $0x30,%rsp
  803809:	89 7d ec             	mov    %edi,-0x14(%rbp)
  80380c:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  803810:	89 55 e8             	mov    %edx,-0x18(%rbp)
  803813:	89 4d dc             	mov    %ecx,-0x24(%rbp)
  803816:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  80381d:	00 00 00 
  803820:	8b 55 ec             	mov    -0x14(%rbp),%edx
  803823:	89 10                	mov    %edx,(%rax)
  803825:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  80382c:	00 00 00 
  80382f:	8b 55 e8             	mov    -0x18(%rbp),%edx
  803832:	89 50 04             	mov    %edx,0x4(%rax)
  803835:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  80383c:	00 00 00 
  80383f:	8b 55 dc             	mov    -0x24(%rbp),%edx
  803842:	89 50 08             	mov    %edx,0x8(%rax)
  803845:	bf 07 00 00 00       	mov    $0x7,%edi
  80384a:	48 b8 8c 35 80 00 00 	movabs $0x80358c,%rax
  803851:	00 00 00 
  803854:	ff d0                	callq  *%rax
  803856:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803859:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80385d:	78 69                	js     8038c8 <nsipc_recv+0xc7>
  80385f:	81 7d fc 3f 06 00 00 	cmpl   $0x63f,-0x4(%rbp)
  803866:	7f 08                	jg     803870 <nsipc_recv+0x6f>
  803868:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80386b:	3b 45 e8             	cmp    -0x18(%rbp),%eax
  80386e:	7e 35                	jle    8038a5 <nsipc_recv+0xa4>
  803870:	48 b9 11 4e 80 00 00 	movabs $0x804e11,%rcx
  803877:	00 00 00 
  80387a:	48 ba 26 4e 80 00 00 	movabs $0x804e26,%rdx
  803881:	00 00 00 
  803884:	be 62 00 00 00       	mov    $0x62,%esi
  803889:	48 bf 3b 4e 80 00 00 	movabs $0x804e3b,%rdi
  803890:	00 00 00 
  803893:	b8 00 00 00 00       	mov    $0x0,%eax
  803898:	49 b8 a4 06 80 00 00 	movabs $0x8006a4,%r8
  80389f:	00 00 00 
  8038a2:	41 ff d0             	callq  *%r8
  8038a5:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8038a8:	48 63 d0             	movslq %eax,%rdx
  8038ab:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8038af:	48 be 00 a0 80 00 00 	movabs $0x80a000,%rsi
  8038b6:	00 00 00 
  8038b9:	48 89 c7             	mov    %rax,%rdi
  8038bc:	48 b8 b6 17 80 00 00 	movabs $0x8017b6,%rax
  8038c3:	00 00 00 
  8038c6:	ff d0                	callq  *%rax
  8038c8:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8038cb:	c9                   	leaveq 
  8038cc:	c3                   	retq   

00000000008038cd <nsipc_send>:
  8038cd:	55                   	push   %rbp
  8038ce:	48 89 e5             	mov    %rsp,%rbp
  8038d1:	48 83 ec 20          	sub    $0x20,%rsp
  8038d5:	89 7d fc             	mov    %edi,-0x4(%rbp)
  8038d8:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8038dc:	89 55 f8             	mov    %edx,-0x8(%rbp)
  8038df:	89 4d ec             	mov    %ecx,-0x14(%rbp)
  8038e2:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  8038e9:	00 00 00 
  8038ec:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8038ef:	89 10                	mov    %edx,(%rax)
  8038f1:	81 7d f8 3f 06 00 00 	cmpl   $0x63f,-0x8(%rbp)
  8038f8:	7e 35                	jle    80392f <nsipc_send+0x62>
  8038fa:	48 b9 4a 4e 80 00 00 	movabs $0x804e4a,%rcx
  803901:	00 00 00 
  803904:	48 ba 26 4e 80 00 00 	movabs $0x804e26,%rdx
  80390b:	00 00 00 
  80390e:	be 6d 00 00 00       	mov    $0x6d,%esi
  803913:	48 bf 3b 4e 80 00 00 	movabs $0x804e3b,%rdi
  80391a:	00 00 00 
  80391d:	b8 00 00 00 00       	mov    $0x0,%eax
  803922:	49 b8 a4 06 80 00 00 	movabs $0x8006a4,%r8
  803929:	00 00 00 
  80392c:	41 ff d0             	callq  *%r8
  80392f:	8b 45 f8             	mov    -0x8(%rbp),%eax
  803932:	48 63 d0             	movslq %eax,%rdx
  803935:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803939:	48 89 c6             	mov    %rax,%rsi
  80393c:	48 bf 0c a0 80 00 00 	movabs $0x80a00c,%rdi
  803943:	00 00 00 
  803946:	48 b8 b6 17 80 00 00 	movabs $0x8017b6,%rax
  80394d:	00 00 00 
  803950:	ff d0                	callq  *%rax
  803952:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803959:	00 00 00 
  80395c:	8b 55 f8             	mov    -0x8(%rbp),%edx
  80395f:	89 50 04             	mov    %edx,0x4(%rax)
  803962:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  803969:	00 00 00 
  80396c:	8b 55 ec             	mov    -0x14(%rbp),%edx
  80396f:	89 50 08             	mov    %edx,0x8(%rax)
  803972:	bf 08 00 00 00       	mov    $0x8,%edi
  803977:	48 b8 8c 35 80 00 00 	movabs $0x80358c,%rax
  80397e:	00 00 00 
  803981:	ff d0                	callq  *%rax
  803983:	c9                   	leaveq 
  803984:	c3                   	retq   

0000000000803985 <nsipc_socket>:
  803985:	55                   	push   %rbp
  803986:	48 89 e5             	mov    %rsp,%rbp
  803989:	48 83 ec 10          	sub    $0x10,%rsp
  80398d:	89 7d fc             	mov    %edi,-0x4(%rbp)
  803990:	89 75 f8             	mov    %esi,-0x8(%rbp)
  803993:	89 55 f4             	mov    %edx,-0xc(%rbp)
  803996:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  80399d:	00 00 00 
  8039a0:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8039a3:	89 10                	mov    %edx,(%rax)
  8039a5:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  8039ac:	00 00 00 
  8039af:	8b 55 f8             	mov    -0x8(%rbp),%edx
  8039b2:	89 50 04             	mov    %edx,0x4(%rax)
  8039b5:	48 b8 00 a0 80 00 00 	movabs $0x80a000,%rax
  8039bc:	00 00 00 
  8039bf:	8b 55 f4             	mov    -0xc(%rbp),%edx
  8039c2:	89 50 08             	mov    %edx,0x8(%rax)
  8039c5:	bf 09 00 00 00       	mov    $0x9,%edi
  8039ca:	48 b8 8c 35 80 00 00 	movabs $0x80358c,%rax
  8039d1:	00 00 00 
  8039d4:	ff d0                	callq  *%rax
  8039d6:	c9                   	leaveq 
  8039d7:	c3                   	retq   

00000000008039d8 <pipe>:
  8039d8:	55                   	push   %rbp
  8039d9:	48 89 e5             	mov    %rsp,%rbp
  8039dc:	53                   	push   %rbx
  8039dd:	48 83 ec 38          	sub    $0x38,%rsp
  8039e1:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  8039e5:	48 8d 45 d8          	lea    -0x28(%rbp),%rax
  8039e9:	48 89 c7             	mov    %rax,%rdi
  8039ec:	48 b8 ef 21 80 00 00 	movabs $0x8021ef,%rax
  8039f3:	00 00 00 
  8039f6:	ff d0                	callq  *%rax
  8039f8:	89 45 ec             	mov    %eax,-0x14(%rbp)
  8039fb:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  8039ff:	0f 88 bf 01 00 00    	js     803bc4 <pipe+0x1ec>
  803a05:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803a09:	ba 07 04 00 00       	mov    $0x407,%edx
  803a0e:	48 89 c6             	mov    %rax,%rsi
  803a11:	bf 00 00 00 00       	mov    $0x0,%edi
  803a16:	48 b8 c1 1d 80 00 00 	movabs $0x801dc1,%rax
  803a1d:	00 00 00 
  803a20:	ff d0                	callq  *%rax
  803a22:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803a25:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  803a29:	0f 88 95 01 00 00    	js     803bc4 <pipe+0x1ec>
  803a2f:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  803a33:	48 89 c7             	mov    %rax,%rdi
  803a36:	48 b8 ef 21 80 00 00 	movabs $0x8021ef,%rax
  803a3d:	00 00 00 
  803a40:	ff d0                	callq  *%rax
  803a42:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803a45:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  803a49:	0f 88 5d 01 00 00    	js     803bac <pipe+0x1d4>
  803a4f:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803a53:	ba 07 04 00 00       	mov    $0x407,%edx
  803a58:	48 89 c6             	mov    %rax,%rsi
  803a5b:	bf 00 00 00 00       	mov    $0x0,%edi
  803a60:	48 b8 c1 1d 80 00 00 	movabs $0x801dc1,%rax
  803a67:	00 00 00 
  803a6a:	ff d0                	callq  *%rax
  803a6c:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803a6f:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  803a73:	0f 88 33 01 00 00    	js     803bac <pipe+0x1d4>
  803a79:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803a7d:	48 89 c7             	mov    %rax,%rdi
  803a80:	48 b8 c4 21 80 00 00 	movabs $0x8021c4,%rax
  803a87:	00 00 00 
  803a8a:	ff d0                	callq  *%rax
  803a8c:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  803a90:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803a94:	ba 07 04 00 00       	mov    $0x407,%edx
  803a99:	48 89 c6             	mov    %rax,%rsi
  803a9c:	bf 00 00 00 00       	mov    $0x0,%edi
  803aa1:	48 b8 c1 1d 80 00 00 	movabs $0x801dc1,%rax
  803aa8:	00 00 00 
  803aab:	ff d0                	callq  *%rax
  803aad:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803ab0:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  803ab4:	79 05                	jns    803abb <pipe+0xe3>
  803ab6:	e9 d9 00 00 00       	jmpq   803b94 <pipe+0x1bc>
  803abb:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803abf:	48 89 c7             	mov    %rax,%rdi
  803ac2:	48 b8 c4 21 80 00 00 	movabs $0x8021c4,%rax
  803ac9:	00 00 00 
  803acc:	ff d0                	callq  *%rax
  803ace:	48 89 c2             	mov    %rax,%rdx
  803ad1:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803ad5:	41 b8 07 04 00 00    	mov    $0x407,%r8d
  803adb:	48 89 d1             	mov    %rdx,%rcx
  803ade:	ba 00 00 00 00       	mov    $0x0,%edx
  803ae3:	48 89 c6             	mov    %rax,%rsi
  803ae6:	bf 00 00 00 00       	mov    $0x0,%edi
  803aeb:	48 b8 11 1e 80 00 00 	movabs $0x801e11,%rax
  803af2:	00 00 00 
  803af5:	ff d0                	callq  *%rax
  803af7:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803afa:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  803afe:	79 1b                	jns    803b1b <pipe+0x143>
  803b00:	90                   	nop
  803b01:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803b05:	48 89 c6             	mov    %rax,%rsi
  803b08:	bf 00 00 00 00       	mov    $0x0,%edi
  803b0d:	48 b8 6c 1e 80 00 00 	movabs $0x801e6c,%rax
  803b14:	00 00 00 
  803b17:	ff d0                	callq  *%rax
  803b19:	eb 79                	jmp    803b94 <pipe+0x1bc>
  803b1b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803b1f:	48 ba e0 60 80 00 00 	movabs $0x8060e0,%rdx
  803b26:	00 00 00 
  803b29:	8b 12                	mov    (%rdx),%edx
  803b2b:	89 10                	mov    %edx,(%rax)
  803b2d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803b31:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%rax)
  803b38:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803b3c:	48 ba e0 60 80 00 00 	movabs $0x8060e0,%rdx
  803b43:	00 00 00 
  803b46:	8b 12                	mov    (%rdx),%edx
  803b48:	89 10                	mov    %edx,(%rax)
  803b4a:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803b4e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%rax)
  803b55:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803b59:	48 89 c7             	mov    %rax,%rdi
  803b5c:	48 b8 a1 21 80 00 00 	movabs $0x8021a1,%rax
  803b63:	00 00 00 
  803b66:	ff d0                	callq  *%rax
  803b68:	89 c2                	mov    %eax,%edx
  803b6a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  803b6e:	89 10                	mov    %edx,(%rax)
  803b70:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  803b74:	48 8d 58 04          	lea    0x4(%rax),%rbx
  803b78:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803b7c:	48 89 c7             	mov    %rax,%rdi
  803b7f:	48 b8 a1 21 80 00 00 	movabs $0x8021a1,%rax
  803b86:	00 00 00 
  803b89:	ff d0                	callq  *%rax
  803b8b:	89 03                	mov    %eax,(%rbx)
  803b8d:	b8 00 00 00 00       	mov    $0x0,%eax
  803b92:	eb 33                	jmp    803bc7 <pipe+0x1ef>
  803b94:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803b98:	48 89 c6             	mov    %rax,%rsi
  803b9b:	bf 00 00 00 00       	mov    $0x0,%edi
  803ba0:	48 b8 6c 1e 80 00 00 	movabs $0x801e6c,%rax
  803ba7:	00 00 00 
  803baa:	ff d0                	callq  *%rax
  803bac:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803bb0:	48 89 c6             	mov    %rax,%rsi
  803bb3:	bf 00 00 00 00       	mov    $0x0,%edi
  803bb8:	48 b8 6c 1e 80 00 00 	movabs $0x801e6c,%rax
  803bbf:	00 00 00 
  803bc2:	ff d0                	callq  *%rax
  803bc4:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803bc7:	48 83 c4 38          	add    $0x38,%rsp
  803bcb:	5b                   	pop    %rbx
  803bcc:	5d                   	pop    %rbp
  803bcd:	c3                   	retq   

0000000000803bce <_pipeisclosed>:
  803bce:	55                   	push   %rbp
  803bcf:	48 89 e5             	mov    %rsp,%rbp
  803bd2:	53                   	push   %rbx
  803bd3:	48 83 ec 28          	sub    $0x28,%rsp
  803bd7:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  803bdb:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  803bdf:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  803be6:	00 00 00 
  803be9:	48 8b 00             	mov    (%rax),%rax
  803bec:	8b 80 d8 00 00 00    	mov    0xd8(%rax),%eax
  803bf2:	89 45 ec             	mov    %eax,-0x14(%rbp)
  803bf5:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803bf9:	48 89 c7             	mov    %rax,%rdi
  803bfc:	48 b8 28 46 80 00 00 	movabs $0x804628,%rax
  803c03:	00 00 00 
  803c06:	ff d0                	callq  *%rax
  803c08:	89 c3                	mov    %eax,%ebx
  803c0a:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803c0e:	48 89 c7             	mov    %rax,%rdi
  803c11:	48 b8 28 46 80 00 00 	movabs $0x804628,%rax
  803c18:	00 00 00 
  803c1b:	ff d0                	callq  *%rax
  803c1d:	39 c3                	cmp    %eax,%ebx
  803c1f:	0f 94 c0             	sete   %al
  803c22:	0f b6 c0             	movzbl %al,%eax
  803c25:	89 45 e8             	mov    %eax,-0x18(%rbp)
  803c28:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  803c2f:	00 00 00 
  803c32:	48 8b 00             	mov    (%rax),%rax
  803c35:	8b 80 d8 00 00 00    	mov    0xd8(%rax),%eax
  803c3b:	89 45 e4             	mov    %eax,-0x1c(%rbp)
  803c3e:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803c41:	3b 45 e4             	cmp    -0x1c(%rbp),%eax
  803c44:	75 05                	jne    803c4b <_pipeisclosed+0x7d>
  803c46:	8b 45 e8             	mov    -0x18(%rbp),%eax
  803c49:	eb 4f                	jmp    803c9a <_pipeisclosed+0xcc>
  803c4b:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803c4e:	3b 45 e4             	cmp    -0x1c(%rbp),%eax
  803c51:	74 42                	je     803c95 <_pipeisclosed+0xc7>
  803c53:	83 7d e8 01          	cmpl   $0x1,-0x18(%rbp)
  803c57:	75 3c                	jne    803c95 <_pipeisclosed+0xc7>
  803c59:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  803c60:	00 00 00 
  803c63:	48 8b 00             	mov    (%rax),%rax
  803c66:	8b 90 d8 00 00 00    	mov    0xd8(%rax),%edx
  803c6c:	8b 4d e8             	mov    -0x18(%rbp),%ecx
  803c6f:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803c72:	89 c6                	mov    %eax,%esi
  803c74:	48 bf 5b 4e 80 00 00 	movabs $0x804e5b,%rdi
  803c7b:	00 00 00 
  803c7e:	b8 00 00 00 00       	mov    $0x0,%eax
  803c83:	49 b8 dd 08 80 00 00 	movabs $0x8008dd,%r8
  803c8a:	00 00 00 
  803c8d:	41 ff d0             	callq  *%r8
  803c90:	e9 4a ff ff ff       	jmpq   803bdf <_pipeisclosed+0x11>
  803c95:	e9 45 ff ff ff       	jmpq   803bdf <_pipeisclosed+0x11>
  803c9a:	48 83 c4 28          	add    $0x28,%rsp
  803c9e:	5b                   	pop    %rbx
  803c9f:	5d                   	pop    %rbp
  803ca0:	c3                   	retq   

0000000000803ca1 <pipeisclosed>:
  803ca1:	55                   	push   %rbp
  803ca2:	48 89 e5             	mov    %rsp,%rbp
  803ca5:	48 83 ec 30          	sub    $0x30,%rsp
  803ca9:	89 7d dc             	mov    %edi,-0x24(%rbp)
  803cac:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  803cb0:	8b 45 dc             	mov    -0x24(%rbp),%eax
  803cb3:	48 89 d6             	mov    %rdx,%rsi
  803cb6:	89 c7                	mov    %eax,%edi
  803cb8:	48 b8 87 22 80 00 00 	movabs $0x802287,%rax
  803cbf:	00 00 00 
  803cc2:	ff d0                	callq  *%rax
  803cc4:	89 45 fc             	mov    %eax,-0x4(%rbp)
  803cc7:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  803ccb:	79 05                	jns    803cd2 <pipeisclosed+0x31>
  803ccd:	8b 45 fc             	mov    -0x4(%rbp),%eax
  803cd0:	eb 31                	jmp    803d03 <pipeisclosed+0x62>
  803cd2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  803cd6:	48 89 c7             	mov    %rax,%rdi
  803cd9:	48 b8 c4 21 80 00 00 	movabs $0x8021c4,%rax
  803ce0:	00 00 00 
  803ce3:	ff d0                	callq  *%rax
  803ce5:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  803ce9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  803ced:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  803cf1:	48 89 d6             	mov    %rdx,%rsi
  803cf4:	48 89 c7             	mov    %rax,%rdi
  803cf7:	48 b8 ce 3b 80 00 00 	movabs $0x803bce,%rax
  803cfe:	00 00 00 
  803d01:	ff d0                	callq  *%rax
  803d03:	c9                   	leaveq 
  803d04:	c3                   	retq   

0000000000803d05 <devpipe_read>:
  803d05:	55                   	push   %rbp
  803d06:	48 89 e5             	mov    %rsp,%rbp
  803d09:	48 83 ec 40          	sub    $0x40,%rsp
  803d0d:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  803d11:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  803d15:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  803d19:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803d1d:	48 89 c7             	mov    %rax,%rdi
  803d20:	48 b8 c4 21 80 00 00 	movabs $0x8021c4,%rax
  803d27:	00 00 00 
  803d2a:	ff d0                	callq  *%rax
  803d2c:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  803d30:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803d34:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  803d38:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  803d3f:	00 
  803d40:	e9 92 00 00 00       	jmpq   803dd7 <devpipe_read+0xd2>
  803d45:	eb 41                	jmp    803d88 <devpipe_read+0x83>
  803d47:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  803d4c:	74 09                	je     803d57 <devpipe_read+0x52>
  803d4e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803d52:	e9 92 00 00 00       	jmpq   803de9 <devpipe_read+0xe4>
  803d57:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  803d5b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803d5f:	48 89 d6             	mov    %rdx,%rsi
  803d62:	48 89 c7             	mov    %rax,%rdi
  803d65:	48 b8 ce 3b 80 00 00 	movabs $0x803bce,%rax
  803d6c:	00 00 00 
  803d6f:	ff d0                	callq  *%rax
  803d71:	85 c0                	test   %eax,%eax
  803d73:	74 07                	je     803d7c <devpipe_read+0x77>
  803d75:	b8 00 00 00 00       	mov    $0x0,%eax
  803d7a:	eb 6d                	jmp    803de9 <devpipe_read+0xe4>
  803d7c:	48 b8 83 1d 80 00 00 	movabs $0x801d83,%rax
  803d83:	00 00 00 
  803d86:	ff d0                	callq  *%rax
  803d88:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803d8c:	8b 10                	mov    (%rax),%edx
  803d8e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803d92:	8b 40 04             	mov    0x4(%rax),%eax
  803d95:	39 c2                	cmp    %eax,%edx
  803d97:	74 ae                	je     803d47 <devpipe_read+0x42>
  803d99:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803d9d:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  803da1:	48 8d 0c 02          	lea    (%rdx,%rax,1),%rcx
  803da5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803da9:	8b 00                	mov    (%rax),%eax
  803dab:	99                   	cltd   
  803dac:	c1 ea 1b             	shr    $0x1b,%edx
  803daf:	01 d0                	add    %edx,%eax
  803db1:	83 e0 1f             	and    $0x1f,%eax
  803db4:	29 d0                	sub    %edx,%eax
  803db6:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  803dba:	48 98                	cltq   
  803dbc:	0f b6 44 02 08       	movzbl 0x8(%rdx,%rax,1),%eax
  803dc1:	88 01                	mov    %al,(%rcx)
  803dc3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803dc7:	8b 00                	mov    (%rax),%eax
  803dc9:	8d 50 01             	lea    0x1(%rax),%edx
  803dcc:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803dd0:	89 10                	mov    %edx,(%rax)
  803dd2:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  803dd7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803ddb:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  803ddf:	0f 82 60 ff ff ff    	jb     803d45 <devpipe_read+0x40>
  803de5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803de9:	c9                   	leaveq 
  803dea:	c3                   	retq   

0000000000803deb <devpipe_write>:
  803deb:	55                   	push   %rbp
  803dec:	48 89 e5             	mov    %rsp,%rbp
  803def:	48 83 ec 40          	sub    $0x40,%rsp
  803df3:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  803df7:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  803dfb:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  803dff:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803e03:	48 89 c7             	mov    %rax,%rdi
  803e06:	48 b8 c4 21 80 00 00 	movabs $0x8021c4,%rax
  803e0d:	00 00 00 
  803e10:	ff d0                	callq  *%rax
  803e12:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  803e16:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  803e1a:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  803e1e:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  803e25:	00 
  803e26:	e9 8e 00 00 00       	jmpq   803eb9 <devpipe_write+0xce>
  803e2b:	eb 31                	jmp    803e5e <devpipe_write+0x73>
  803e2d:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  803e31:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  803e35:	48 89 d6             	mov    %rdx,%rsi
  803e38:	48 89 c7             	mov    %rax,%rdi
  803e3b:	48 b8 ce 3b 80 00 00 	movabs $0x803bce,%rax
  803e42:	00 00 00 
  803e45:	ff d0                	callq  *%rax
  803e47:	85 c0                	test   %eax,%eax
  803e49:	74 07                	je     803e52 <devpipe_write+0x67>
  803e4b:	b8 00 00 00 00       	mov    $0x0,%eax
  803e50:	eb 79                	jmp    803ecb <devpipe_write+0xe0>
  803e52:	48 b8 83 1d 80 00 00 	movabs $0x801d83,%rax
  803e59:	00 00 00 
  803e5c:	ff d0                	callq  *%rax
  803e5e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803e62:	8b 40 04             	mov    0x4(%rax),%eax
  803e65:	48 63 d0             	movslq %eax,%rdx
  803e68:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803e6c:	8b 00                	mov    (%rax),%eax
  803e6e:	48 98                	cltq   
  803e70:	48 83 c0 20          	add    $0x20,%rax
  803e74:	48 39 c2             	cmp    %rax,%rdx
  803e77:	73 b4                	jae    803e2d <devpipe_write+0x42>
  803e79:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803e7d:	8b 40 04             	mov    0x4(%rax),%eax
  803e80:	99                   	cltd   
  803e81:	c1 ea 1b             	shr    $0x1b,%edx
  803e84:	01 d0                	add    %edx,%eax
  803e86:	83 e0 1f             	and    $0x1f,%eax
  803e89:	29 d0                	sub    %edx,%eax
  803e8b:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  803e8f:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  803e93:	48 01 ca             	add    %rcx,%rdx
  803e96:	0f b6 0a             	movzbl (%rdx),%ecx
  803e99:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  803e9d:	48 98                	cltq   
  803e9f:	88 4c 02 08          	mov    %cl,0x8(%rdx,%rax,1)
  803ea3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803ea7:	8b 40 04             	mov    0x4(%rax),%eax
  803eaa:	8d 50 01             	lea    0x1(%rax),%edx
  803ead:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  803eb1:	89 50 04             	mov    %edx,0x4(%rax)
  803eb4:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  803eb9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803ebd:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  803ec1:	0f 82 64 ff ff ff    	jb     803e2b <devpipe_write+0x40>
  803ec7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803ecb:	c9                   	leaveq 
  803ecc:	c3                   	retq   

0000000000803ecd <devpipe_stat>:
  803ecd:	55                   	push   %rbp
  803ece:	48 89 e5             	mov    %rsp,%rbp
  803ed1:	48 83 ec 20          	sub    $0x20,%rsp
  803ed5:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  803ed9:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  803edd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  803ee1:	48 89 c7             	mov    %rax,%rdi
  803ee4:	48 b8 c4 21 80 00 00 	movabs $0x8021c4,%rax
  803eeb:	00 00 00 
  803eee:	ff d0                	callq  *%rax
  803ef0:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  803ef4:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803ef8:	48 be 6e 4e 80 00 00 	movabs $0x804e6e,%rsi
  803eff:	00 00 00 
  803f02:	48 89 c7             	mov    %rax,%rdi
  803f05:	48 b8 92 14 80 00 00 	movabs $0x801492,%rax
  803f0c:	00 00 00 
  803f0f:	ff d0                	callq  *%rax
  803f11:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803f15:	8b 50 04             	mov    0x4(%rax),%edx
  803f18:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803f1c:	8b 00                	mov    (%rax),%eax
  803f1e:	29 c2                	sub    %eax,%edx
  803f20:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803f24:	89 90 80 00 00 00    	mov    %edx,0x80(%rax)
  803f2a:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803f2e:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%rax)
  803f35:	00 00 00 
  803f38:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  803f3c:	48 b9 e0 60 80 00 00 	movabs $0x8060e0,%rcx
  803f43:	00 00 00 
  803f46:	48 89 88 88 00 00 00 	mov    %rcx,0x88(%rax)
  803f4d:	b8 00 00 00 00       	mov    $0x0,%eax
  803f52:	c9                   	leaveq 
  803f53:	c3                   	retq   

0000000000803f54 <devpipe_close>:
  803f54:	55                   	push   %rbp
  803f55:	48 89 e5             	mov    %rsp,%rbp
  803f58:	48 83 ec 10          	sub    $0x10,%rsp
  803f5c:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  803f60:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803f64:	48 89 c6             	mov    %rax,%rsi
  803f67:	bf 00 00 00 00       	mov    $0x0,%edi
  803f6c:	48 b8 6c 1e 80 00 00 	movabs $0x801e6c,%rax
  803f73:	00 00 00 
  803f76:	ff d0                	callq  *%rax
  803f78:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  803f7c:	48 89 c7             	mov    %rax,%rdi
  803f7f:	48 b8 c4 21 80 00 00 	movabs $0x8021c4,%rax
  803f86:	00 00 00 
  803f89:	ff d0                	callq  *%rax
  803f8b:	48 89 c6             	mov    %rax,%rsi
  803f8e:	bf 00 00 00 00       	mov    $0x0,%edi
  803f93:	48 b8 6c 1e 80 00 00 	movabs $0x801e6c,%rax
  803f9a:	00 00 00 
  803f9d:	ff d0                	callq  *%rax
  803f9f:	c9                   	leaveq 
  803fa0:	c3                   	retq   

0000000000803fa1 <wait>:
  803fa1:	55                   	push   %rbp
  803fa2:	48 89 e5             	mov    %rsp,%rbp
  803fa5:	48 83 ec 20          	sub    $0x20,%rsp
  803fa9:	89 7d ec             	mov    %edi,-0x14(%rbp)
  803fac:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  803fb0:	75 35                	jne    803fe7 <wait+0x46>
  803fb2:	48 b9 75 4e 80 00 00 	movabs $0x804e75,%rcx
  803fb9:	00 00 00 
  803fbc:	48 ba 80 4e 80 00 00 	movabs $0x804e80,%rdx
  803fc3:	00 00 00 
  803fc6:	be 0a 00 00 00       	mov    $0xa,%esi
  803fcb:	48 bf 95 4e 80 00 00 	movabs $0x804e95,%rdi
  803fd2:	00 00 00 
  803fd5:	b8 00 00 00 00       	mov    $0x0,%eax
  803fda:	49 b8 a4 06 80 00 00 	movabs $0x8006a4,%r8
  803fe1:	00 00 00 
  803fe4:	41 ff d0             	callq  *%r8
  803fe7:	8b 45 ec             	mov    -0x14(%rbp),%eax
  803fea:	25 ff 03 00 00       	and    $0x3ff,%eax
  803fef:	48 98                	cltq   
  803ff1:	48 69 d0 68 01 00 00 	imul   $0x168,%rax,%rdx
  803ff8:	48 b8 00 00 80 00 80 	movabs $0x8000800000,%rax
  803fff:	00 00 00 
  804002:	48 01 d0             	add    %rdx,%rax
  804005:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  804009:	eb 0c                	jmp    804017 <wait+0x76>
  80400b:	48 b8 83 1d 80 00 00 	movabs $0x801d83,%rax
  804012:	00 00 00 
  804015:	ff d0                	callq  *%rax
  804017:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80401b:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  804021:	3b 45 ec             	cmp    -0x14(%rbp),%eax
  804024:	75 0e                	jne    804034 <wait+0x93>
  804026:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80402a:	8b 80 d4 00 00 00    	mov    0xd4(%rax),%eax
  804030:	85 c0                	test   %eax,%eax
  804032:	75 d7                	jne    80400b <wait+0x6a>
  804034:	c9                   	leaveq 
  804035:	c3                   	retq   

0000000000804036 <cputchar>:
  804036:	55                   	push   %rbp
  804037:	48 89 e5             	mov    %rsp,%rbp
  80403a:	48 83 ec 20          	sub    $0x20,%rsp
  80403e:	89 7d ec             	mov    %edi,-0x14(%rbp)
  804041:	8b 45 ec             	mov    -0x14(%rbp),%eax
  804044:	88 45 ff             	mov    %al,-0x1(%rbp)
  804047:	48 8d 45 ff          	lea    -0x1(%rbp),%rax
  80404b:	be 01 00 00 00       	mov    $0x1,%esi
  804050:	48 89 c7             	mov    %rax,%rdi
  804053:	48 b8 79 1c 80 00 00 	movabs $0x801c79,%rax
  80405a:	00 00 00 
  80405d:	ff d0                	callq  *%rax
  80405f:	c9                   	leaveq 
  804060:	c3                   	retq   

0000000000804061 <getchar>:
  804061:	55                   	push   %rbp
  804062:	48 89 e5             	mov    %rsp,%rbp
  804065:	48 83 ec 10          	sub    $0x10,%rsp
  804069:	48 8d 45 fb          	lea    -0x5(%rbp),%rax
  80406d:	ba 01 00 00 00       	mov    $0x1,%edx
  804072:	48 89 c6             	mov    %rax,%rsi
  804075:	bf 00 00 00 00       	mov    $0x0,%edi
  80407a:	48 b8 b9 26 80 00 00 	movabs $0x8026b9,%rax
  804081:	00 00 00 
  804084:	ff d0                	callq  *%rax
  804086:	89 45 fc             	mov    %eax,-0x4(%rbp)
  804089:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80408d:	79 05                	jns    804094 <getchar+0x33>
  80408f:	8b 45 fc             	mov    -0x4(%rbp),%eax
  804092:	eb 14                	jmp    8040a8 <getchar+0x47>
  804094:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  804098:	7f 07                	jg     8040a1 <getchar+0x40>
  80409a:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
  80409f:	eb 07                	jmp    8040a8 <getchar+0x47>
  8040a1:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  8040a5:	0f b6 c0             	movzbl %al,%eax
  8040a8:	c9                   	leaveq 
  8040a9:	c3                   	retq   

00000000008040aa <iscons>:
  8040aa:	55                   	push   %rbp
  8040ab:	48 89 e5             	mov    %rsp,%rbp
  8040ae:	48 83 ec 20          	sub    $0x20,%rsp
  8040b2:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8040b5:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  8040b9:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8040bc:	48 89 d6             	mov    %rdx,%rsi
  8040bf:	89 c7                	mov    %eax,%edi
  8040c1:	48 b8 87 22 80 00 00 	movabs $0x802287,%rax
  8040c8:	00 00 00 
  8040cb:	ff d0                	callq  *%rax
  8040cd:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8040d0:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8040d4:	79 05                	jns    8040db <iscons+0x31>
  8040d6:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8040d9:	eb 1a                	jmp    8040f5 <iscons+0x4b>
  8040db:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8040df:	8b 10                	mov    (%rax),%edx
  8040e1:	48 b8 20 61 80 00 00 	movabs $0x806120,%rax
  8040e8:	00 00 00 
  8040eb:	8b 00                	mov    (%rax),%eax
  8040ed:	39 c2                	cmp    %eax,%edx
  8040ef:	0f 94 c0             	sete   %al
  8040f2:	0f b6 c0             	movzbl %al,%eax
  8040f5:	c9                   	leaveq 
  8040f6:	c3                   	retq   

00000000008040f7 <opencons>:
  8040f7:	55                   	push   %rbp
  8040f8:	48 89 e5             	mov    %rsp,%rbp
  8040fb:	48 83 ec 10          	sub    $0x10,%rsp
  8040ff:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
  804103:	48 89 c7             	mov    %rax,%rdi
  804106:	48 b8 ef 21 80 00 00 	movabs $0x8021ef,%rax
  80410d:	00 00 00 
  804110:	ff d0                	callq  *%rax
  804112:	89 45 fc             	mov    %eax,-0x4(%rbp)
  804115:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  804119:	79 05                	jns    804120 <opencons+0x29>
  80411b:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80411e:	eb 5b                	jmp    80417b <opencons+0x84>
  804120:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  804124:	ba 07 04 00 00       	mov    $0x407,%edx
  804129:	48 89 c6             	mov    %rax,%rsi
  80412c:	bf 00 00 00 00       	mov    $0x0,%edi
  804131:	48 b8 c1 1d 80 00 00 	movabs $0x801dc1,%rax
  804138:	00 00 00 
  80413b:	ff d0                	callq  *%rax
  80413d:	89 45 fc             	mov    %eax,-0x4(%rbp)
  804140:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  804144:	79 05                	jns    80414b <opencons+0x54>
  804146:	8b 45 fc             	mov    -0x4(%rbp),%eax
  804149:	eb 30                	jmp    80417b <opencons+0x84>
  80414b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80414f:	48 ba 20 61 80 00 00 	movabs $0x806120,%rdx
  804156:	00 00 00 
  804159:	8b 12                	mov    (%rdx),%edx
  80415b:	89 10                	mov    %edx,(%rax)
  80415d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  804161:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%rax)
  804168:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80416c:	48 89 c7             	mov    %rax,%rdi
  80416f:	48 b8 a1 21 80 00 00 	movabs $0x8021a1,%rax
  804176:	00 00 00 
  804179:	ff d0                	callq  *%rax
  80417b:	c9                   	leaveq 
  80417c:	c3                   	retq   

000000000080417d <devcons_read>:
  80417d:	55                   	push   %rbp
  80417e:	48 89 e5             	mov    %rsp,%rbp
  804181:	48 83 ec 30          	sub    $0x30,%rsp
  804185:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  804189:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  80418d:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  804191:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  804196:	75 07                	jne    80419f <devcons_read+0x22>
  804198:	b8 00 00 00 00       	mov    $0x0,%eax
  80419d:	eb 4b                	jmp    8041ea <devcons_read+0x6d>
  80419f:	eb 0c                	jmp    8041ad <devcons_read+0x30>
  8041a1:	48 b8 83 1d 80 00 00 	movabs $0x801d83,%rax
  8041a8:	00 00 00 
  8041ab:	ff d0                	callq  *%rax
  8041ad:	48 b8 c3 1c 80 00 00 	movabs $0x801cc3,%rax
  8041b4:	00 00 00 
  8041b7:	ff d0                	callq  *%rax
  8041b9:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8041bc:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8041c0:	74 df                	je     8041a1 <devcons_read+0x24>
  8041c2:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8041c6:	79 05                	jns    8041cd <devcons_read+0x50>
  8041c8:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8041cb:	eb 1d                	jmp    8041ea <devcons_read+0x6d>
  8041cd:	83 7d fc 04          	cmpl   $0x4,-0x4(%rbp)
  8041d1:	75 07                	jne    8041da <devcons_read+0x5d>
  8041d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8041d8:	eb 10                	jmp    8041ea <devcons_read+0x6d>
  8041da:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8041dd:	89 c2                	mov    %eax,%edx
  8041df:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8041e3:	88 10                	mov    %dl,(%rax)
  8041e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8041ea:	c9                   	leaveq 
  8041eb:	c3                   	retq   

00000000008041ec <devcons_write>:
  8041ec:	55                   	push   %rbp
  8041ed:	48 89 e5             	mov    %rsp,%rbp
  8041f0:	48 81 ec b0 00 00 00 	sub    $0xb0,%rsp
  8041f7:	48 89 bd 68 ff ff ff 	mov    %rdi,-0x98(%rbp)
  8041fe:	48 89 b5 60 ff ff ff 	mov    %rsi,-0xa0(%rbp)
  804205:	48 89 95 58 ff ff ff 	mov    %rdx,-0xa8(%rbp)
  80420c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  804213:	eb 76                	jmp    80428b <devcons_write+0x9f>
  804215:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
  80421c:	89 c2                	mov    %eax,%edx
  80421e:	8b 45 fc             	mov    -0x4(%rbp),%eax
  804221:	29 c2                	sub    %eax,%edx
  804223:	89 d0                	mov    %edx,%eax
  804225:	89 45 f8             	mov    %eax,-0x8(%rbp)
  804228:	8b 45 f8             	mov    -0x8(%rbp),%eax
  80422b:	83 f8 7f             	cmp    $0x7f,%eax
  80422e:	76 07                	jbe    804237 <devcons_write+0x4b>
  804230:	c7 45 f8 7f 00 00 00 	movl   $0x7f,-0x8(%rbp)
  804237:	8b 45 f8             	mov    -0x8(%rbp),%eax
  80423a:	48 63 d0             	movslq %eax,%rdx
  80423d:	8b 45 fc             	mov    -0x4(%rbp),%eax
  804240:	48 63 c8             	movslq %eax,%rcx
  804243:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  80424a:	48 01 c1             	add    %rax,%rcx
  80424d:	48 8d 85 70 ff ff ff 	lea    -0x90(%rbp),%rax
  804254:	48 89 ce             	mov    %rcx,%rsi
  804257:	48 89 c7             	mov    %rax,%rdi
  80425a:	48 b8 b6 17 80 00 00 	movabs $0x8017b6,%rax
  804261:	00 00 00 
  804264:	ff d0                	callq  *%rax
  804266:	8b 45 f8             	mov    -0x8(%rbp),%eax
  804269:	48 63 d0             	movslq %eax,%rdx
  80426c:	48 8d 85 70 ff ff ff 	lea    -0x90(%rbp),%rax
  804273:	48 89 d6             	mov    %rdx,%rsi
  804276:	48 89 c7             	mov    %rax,%rdi
  804279:	48 b8 79 1c 80 00 00 	movabs $0x801c79,%rax
  804280:	00 00 00 
  804283:	ff d0                	callq  *%rax
  804285:	8b 45 f8             	mov    -0x8(%rbp),%eax
  804288:	01 45 fc             	add    %eax,-0x4(%rbp)
  80428b:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80428e:	48 98                	cltq   
  804290:	48 3b 85 58 ff ff ff 	cmp    -0xa8(%rbp),%rax
  804297:	0f 82 78 ff ff ff    	jb     804215 <devcons_write+0x29>
  80429d:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8042a0:	c9                   	leaveq 
  8042a1:	c3                   	retq   

00000000008042a2 <devcons_close>:
  8042a2:	55                   	push   %rbp
  8042a3:	48 89 e5             	mov    %rsp,%rbp
  8042a6:	48 83 ec 08          	sub    $0x8,%rsp
  8042aa:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8042ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8042b3:	c9                   	leaveq 
  8042b4:	c3                   	retq   

00000000008042b5 <devcons_stat>:
  8042b5:	55                   	push   %rbp
  8042b6:	48 89 e5             	mov    %rsp,%rbp
  8042b9:	48 83 ec 10          	sub    $0x10,%rsp
  8042bd:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8042c1:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8042c5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8042c9:	48 be a8 4e 80 00 00 	movabs $0x804ea8,%rsi
  8042d0:	00 00 00 
  8042d3:	48 89 c7             	mov    %rax,%rdi
  8042d6:	48 b8 92 14 80 00 00 	movabs $0x801492,%rax
  8042dd:	00 00 00 
  8042e0:	ff d0                	callq  *%rax
  8042e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8042e7:	c9                   	leaveq 
  8042e8:	c3                   	retq   

00000000008042e9 <ipc_recv>:
  8042e9:	55                   	push   %rbp
  8042ea:	48 89 e5             	mov    %rsp,%rbp
  8042ed:	48 83 ec 30          	sub    $0x30,%rsp
  8042f1:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8042f5:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8042f9:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  8042fd:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  804302:	75 0e                	jne    804312 <ipc_recv+0x29>
  804304:	48 b8 00 00 80 00 80 	movabs $0x8000800000,%rax
  80430b:	00 00 00 
  80430e:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  804312:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  804316:	48 89 c7             	mov    %rax,%rdi
  804319:	48 b8 ea 1f 80 00 00 	movabs $0x801fea,%rax
  804320:	00 00 00 
  804323:	ff d0                	callq  *%rax
  804325:	89 45 fc             	mov    %eax,-0x4(%rbp)
  804328:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80432c:	79 27                	jns    804355 <ipc_recv+0x6c>
  80432e:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  804333:	74 0a                	je     80433f <ipc_recv+0x56>
  804335:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  804339:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
  80433f:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  804344:	74 0a                	je     804350 <ipc_recv+0x67>
  804346:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80434a:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
  804350:	8b 45 fc             	mov    -0x4(%rbp),%eax
  804353:	eb 53                	jmp    8043a8 <ipc_recv+0xbf>
  804355:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  80435a:	74 19                	je     804375 <ipc_recv+0x8c>
  80435c:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  804363:	00 00 00 
  804366:	48 8b 00             	mov    (%rax),%rax
  804369:	8b 90 0c 01 00 00    	mov    0x10c(%rax),%edx
  80436f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  804373:	89 10                	mov    %edx,(%rax)
  804375:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  80437a:	74 19                	je     804395 <ipc_recv+0xac>
  80437c:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  804383:	00 00 00 
  804386:	48 8b 00             	mov    (%rax),%rax
  804389:	8b 90 10 01 00 00    	mov    0x110(%rax),%edx
  80438f:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  804393:	89 10                	mov    %edx,(%rax)
  804395:	48 b8 08 70 80 00 00 	movabs $0x807008,%rax
  80439c:	00 00 00 
  80439f:	48 8b 00             	mov    (%rax),%rax
  8043a2:	8b 80 08 01 00 00    	mov    0x108(%rax),%eax
  8043a8:	c9                   	leaveq 
  8043a9:	c3                   	retq   

00000000008043aa <ipc_send>:
  8043aa:	55                   	push   %rbp
  8043ab:	48 89 e5             	mov    %rsp,%rbp
  8043ae:	48 83 ec 30          	sub    $0x30,%rsp
  8043b2:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8043b5:	89 75 e8             	mov    %esi,-0x18(%rbp)
  8043b8:	48 89 55 e0          	mov    %rdx,-0x20(%rbp)
  8043bc:	89 4d dc             	mov    %ecx,-0x24(%rbp)
  8043bf:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  8043c4:	75 10                	jne    8043d6 <ipc_send+0x2c>
  8043c6:	48 b8 00 00 80 00 80 	movabs $0x8000800000,%rax
  8043cd:	00 00 00 
  8043d0:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  8043d4:	eb 0e                	jmp    8043e4 <ipc_send+0x3a>
  8043d6:	eb 0c                	jmp    8043e4 <ipc_send+0x3a>
  8043d8:	48 b8 83 1d 80 00 00 	movabs $0x801d83,%rax
  8043df:	00 00 00 
  8043e2:	ff d0                	callq  *%rax
  8043e4:	8b 75 e8             	mov    -0x18(%rbp),%esi
  8043e7:	8b 4d dc             	mov    -0x24(%rbp),%ecx
  8043ea:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8043ee:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8043f1:	89 c7                	mov    %eax,%edi
  8043f3:	48 b8 95 1f 80 00 00 	movabs $0x801f95,%rax
  8043fa:	00 00 00 
  8043fd:	ff d0                	callq  *%rax
  8043ff:	89 45 fc             	mov    %eax,-0x4(%rbp)
  804402:	83 7d fc f8          	cmpl   $0xfffffff8,-0x4(%rbp)
  804406:	74 d0                	je     8043d8 <ipc_send+0x2e>
  804408:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80440c:	79 30                	jns    80443e <ipc_send+0x94>
  80440e:	8b 45 fc             	mov    -0x4(%rbp),%eax
  804411:	89 c1                	mov    %eax,%ecx
  804413:	48 ba af 4e 80 00 00 	movabs $0x804eaf,%rdx
  80441a:	00 00 00 
  80441d:	be 4b 00 00 00       	mov    $0x4b,%esi
  804422:	48 bf c5 4e 80 00 00 	movabs $0x804ec5,%rdi
  804429:	00 00 00 
  80442c:	b8 00 00 00 00       	mov    $0x0,%eax
  804431:	49 b8 a4 06 80 00 00 	movabs $0x8006a4,%r8
  804438:	00 00 00 
  80443b:	41 ff d0             	callq  *%r8
  80443e:	c9                   	leaveq 
  80443f:	c3                   	retq   

0000000000804440 <ipc_host_recv>:
  804440:	55                   	push   %rbp
  804441:	48 89 e5             	mov    %rsp,%rbp
  804444:	53                   	push   %rbx
  804445:	48 83 ec 28          	sub    $0x28,%rsp
  804449:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  80444d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
  804454:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%rbp)
  80445b:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  804460:	75 0e                	jne    804470 <ipc_host_recv+0x30>
  804462:	48 b8 00 00 80 00 80 	movabs $0x8000800000,%rax
  804469:	00 00 00 
  80446c:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
  804470:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  804474:	ba 07 00 00 00       	mov    $0x7,%edx
  804479:	48 89 c6             	mov    %rax,%rsi
  80447c:	bf 00 00 00 00       	mov    $0x0,%edi
  804481:	48 b8 c1 1d 80 00 00 	movabs $0x801dc1,%rax
  804488:	00 00 00 
  80448b:	ff d0                	callq  *%rax
  80448d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  804491:	48 c1 e8 0c          	shr    $0xc,%rax
  804495:	48 89 c2             	mov    %rax,%rdx
  804498:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  80449f:	01 00 00 
  8044a2:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8044a6:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8044ac:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  8044b0:	b8 03 00 00 00       	mov    $0x3,%eax
  8044b5:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8044b9:	48 89 d3             	mov    %rdx,%rbx
  8044bc:	0f 01 c1             	vmcall 
  8044bf:	89 f2                	mov    %esi,%edx
  8044c1:	89 45 ec             	mov    %eax,-0x14(%rbp)
  8044c4:	89 55 e8             	mov    %edx,-0x18(%rbp)
  8044c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  8044cb:	79 05                	jns    8044d2 <ipc_host_recv+0x92>
  8044cd:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8044d0:	eb 03                	jmp    8044d5 <ipc_host_recv+0x95>
  8044d2:	8b 45 e8             	mov    -0x18(%rbp),%eax
  8044d5:	48 83 c4 28          	add    $0x28,%rsp
  8044d9:	5b                   	pop    %rbx
  8044da:	5d                   	pop    %rbp
  8044db:	c3                   	retq   

00000000008044dc <ipc_host_send>:
  8044dc:	55                   	push   %rbp
  8044dd:	48 89 e5             	mov    %rsp,%rbp
  8044e0:	53                   	push   %rbx
  8044e1:	48 83 ec 38          	sub    $0x38,%rsp
  8044e5:	89 7d dc             	mov    %edi,-0x24(%rbp)
  8044e8:	89 75 d8             	mov    %esi,-0x28(%rbp)
  8044eb:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  8044ef:	89 4d cc             	mov    %ecx,-0x34(%rbp)
  8044f2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
  8044f9:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  8044fe:	75 0e                	jne    80450e <ipc_host_send+0x32>
  804500:	48 b8 00 00 80 00 80 	movabs $0x8000800000,%rax
  804507:	00 00 00 
  80450a:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  80450e:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  804512:	48 c1 e8 0c          	shr    $0xc,%rax
  804516:	48 89 c2             	mov    %rax,%rdx
  804519:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  804520:	01 00 00 
  804523:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  804527:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  80452d:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  804531:	b8 02 00 00 00       	mov    $0x2,%eax
  804536:	8b 7d dc             	mov    -0x24(%rbp),%edi
  804539:	8b 4d d8             	mov    -0x28(%rbp),%ecx
  80453c:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  804540:	8b 75 cc             	mov    -0x34(%rbp),%esi
  804543:	89 fb                	mov    %edi,%ebx
  804545:	0f 01 c1             	vmcall 
  804548:	89 45 ec             	mov    %eax,-0x14(%rbp)
  80454b:	eb 26                	jmp    804573 <ipc_host_send+0x97>
  80454d:	48 b8 83 1d 80 00 00 	movabs $0x801d83,%rax
  804554:	00 00 00 
  804557:	ff d0                	callq  *%rax
  804559:	b8 02 00 00 00       	mov    $0x2,%eax
  80455e:	8b 7d dc             	mov    -0x24(%rbp),%edi
  804561:	8b 4d d8             	mov    -0x28(%rbp),%ecx
  804564:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  804568:	8b 75 cc             	mov    -0x34(%rbp),%esi
  80456b:	89 fb                	mov    %edi,%ebx
  80456d:	0f 01 c1             	vmcall 
  804570:	89 45 ec             	mov    %eax,-0x14(%rbp)
  804573:	83 7d ec f8          	cmpl   $0xfffffff8,-0x14(%rbp)
  804577:	74 d4                	je     80454d <ipc_host_send+0x71>
  804579:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  80457d:	79 30                	jns    8045af <ipc_host_send+0xd3>
  80457f:	8b 45 ec             	mov    -0x14(%rbp),%eax
  804582:	89 c1                	mov    %eax,%ecx
  804584:	48 ba af 4e 80 00 00 	movabs $0x804eaf,%rdx
  80458b:	00 00 00 
  80458e:	be 83 00 00 00       	mov    $0x83,%esi
  804593:	48 bf c5 4e 80 00 00 	movabs $0x804ec5,%rdi
  80459a:	00 00 00 
  80459d:	b8 00 00 00 00       	mov    $0x0,%eax
  8045a2:	49 b8 a4 06 80 00 00 	movabs $0x8006a4,%r8
  8045a9:	00 00 00 
  8045ac:	41 ff d0             	callq  *%r8
  8045af:	48 83 c4 38          	add    $0x38,%rsp
  8045b3:	5b                   	pop    %rbx
  8045b4:	5d                   	pop    %rbp
  8045b5:	c3                   	retq   

00000000008045b6 <ipc_find_env>:
  8045b6:	55                   	push   %rbp
  8045b7:	48 89 e5             	mov    %rsp,%rbp
  8045ba:	48 83 ec 14          	sub    $0x14,%rsp
  8045be:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8045c1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8045c8:	eb 4e                	jmp    804618 <ipc_find_env+0x62>
  8045ca:	48 ba 00 00 80 00 80 	movabs $0x8000800000,%rdx
  8045d1:	00 00 00 
  8045d4:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8045d7:	48 98                	cltq   
  8045d9:	48 69 c0 68 01 00 00 	imul   $0x168,%rax,%rax
  8045e0:	48 01 d0             	add    %rdx,%rax
  8045e3:	48 05 d0 00 00 00    	add    $0xd0,%rax
  8045e9:	8b 00                	mov    (%rax),%eax
  8045eb:	3b 45 ec             	cmp    -0x14(%rbp),%eax
  8045ee:	75 24                	jne    804614 <ipc_find_env+0x5e>
  8045f0:	48 ba 00 00 80 00 80 	movabs $0x8000800000,%rdx
  8045f7:	00 00 00 
  8045fa:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8045fd:	48 98                	cltq   
  8045ff:	48 69 c0 68 01 00 00 	imul   $0x168,%rax,%rax
  804606:	48 01 d0             	add    %rdx,%rax
  804609:	48 05 c0 00 00 00    	add    $0xc0,%rax
  80460f:	8b 40 08             	mov    0x8(%rax),%eax
  804612:	eb 12                	jmp    804626 <ipc_find_env+0x70>
  804614:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  804618:	81 7d fc ff 03 00 00 	cmpl   $0x3ff,-0x4(%rbp)
  80461f:	7e a9                	jle    8045ca <ipc_find_env+0x14>
  804621:	b8 00 00 00 00       	mov    $0x0,%eax
  804626:	c9                   	leaveq 
  804627:	c3                   	retq   

0000000000804628 <pageref>:
  804628:	55                   	push   %rbp
  804629:	48 89 e5             	mov    %rsp,%rbp
  80462c:	48 83 ec 18          	sub    $0x18,%rsp
  804630:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  804634:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  804638:	48 c1 e8 15          	shr    $0x15,%rax
  80463c:	48 89 c2             	mov    %rax,%rdx
  80463f:	48 b8 00 00 00 80 00 	movabs $0x10080000000,%rax
  804646:	01 00 00 
  804649:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  80464d:	83 e0 01             	and    $0x1,%eax
  804650:	48 85 c0             	test   %rax,%rax
  804653:	75 07                	jne    80465c <pageref+0x34>
  804655:	b8 00 00 00 00       	mov    $0x0,%eax
  80465a:	eb 53                	jmp    8046af <pageref+0x87>
  80465c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  804660:	48 c1 e8 0c          	shr    $0xc,%rax
  804664:	48 89 c2             	mov    %rax,%rdx
  804667:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  80466e:	01 00 00 
  804671:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  804675:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  804679:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80467d:	83 e0 01             	and    $0x1,%eax
  804680:	48 85 c0             	test   %rax,%rax
  804683:	75 07                	jne    80468c <pageref+0x64>
  804685:	b8 00 00 00 00       	mov    $0x0,%eax
  80468a:	eb 23                	jmp    8046af <pageref+0x87>
  80468c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  804690:	48 c1 e8 0c          	shr    $0xc,%rax
  804694:	48 89 c2             	mov    %rax,%rdx
  804697:	48 b8 00 00 a0 00 80 	movabs $0x8000a00000,%rax
  80469e:	00 00 00 
  8046a1:	48 c1 e2 04          	shl    $0x4,%rdx
  8046a5:	48 01 d0             	add    %rdx,%rax
  8046a8:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  8046ac:	0f b7 c0             	movzwl %ax,%eax
  8046af:	c9                   	leaveq 
  8046b0:	c3                   	retq   
