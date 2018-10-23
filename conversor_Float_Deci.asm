; O programa abaixo converte um numero decimal (ignorando os valores depois da virgula) em um float no padrão IEEE 754, considerando 
; 1 bit pro sinal, sete bits par o expoente e oito bits para o campo fracionario.
; No presente programa o usario entrara com o decimal, e o programa ira ler atraves da função 'scan' criada para tal
; Primeiro passo era transformar a string lida em inteiro para poder trabalhar sobre ele, para isso foi utilizada a função '_toINT'
; Com o numero lido, a função '_binaryBUILD' realiza a tranformação do numero inserido em binario, realizando a operação de 
; dividir por 2 ate que n tenha mais quociente. 
; O numero então foi armazenado no registrado, so que invertido, então para que esteja na orientação correta, a função 'reverse' é 
; chamada, que simplesmente inverte a ordem do numero encontrado.
; E com a função _fillZEROS preenche-se o resto do numero com zeros à direita.
; Foi necessaria a criação da função _copySTR para armazenar o valor fracionario para depois enconrtar o expoente, afim de que evitar 
; a perda de tal informação.
; Finalmente com a função _signCompare encontra-se se o numero digitado, é negativo ou positivo
;
;P.S: Para a entrada do numero, caso queria numero positivo colocar o '+' na frente, caso negativo '-'
; Para execução do progama utiliza a seguinte linha de codigo:
;
;     nasm -felf64 (nome do arquivo).asm && ld (nome do arquivo).o && ./a.out
;

stdIN equ 0
stdOUT equ 1
STDERR equ 2
sREAD equ 0
sWRITE equ 1
sEXIT equ 60

BIAS equ 63

%macro exit 0
    mov rax, sEXIT      
    xor rdi, rdi        
    syscall             
%endmacro

%macro print 2

    mov rax, sWRITE     
    mov rdi, stdOUT     
    mov rsi, %1         
    mov rdx, %2         
    syscall

%endmacro

%macro scan 2

    mov rax, sREAD      
    mov rdi, stdIN      
    mov rsi, %1         
    mov rdx, %2         
    syscall

%endmacro

%macro merge 2

    mov rax, %1
    add rax, '0'
    mov [%2 + r12], rax

%endmacro

%macro reverse 3

    mov r12, %1
    mov r11, 0
    .cicle:
        mov r10, [%2 + r12]
        mov [%3 + r11], r10
        dec r12
        inc r11
        cmp r12, 0
        jnz .cicle

%endmacro

%macro copy 2

    mov rax, [%1]
    mov [%2], rax

%endmacro

section .data
    division db "RESULTADO DIV: "
    resto db "RESTO: "
    inputNUM db "Entre com o decimal",10
    lenght equ $-inputNUM
    digit db 0,10
    buffer times 16 db 0
    invertBUFFER times 16 db 0
    exp times 16 db 0
    frac times 16 db 0
    sign db 0
    numSBit db 0

section .bss
    ascii resb 1

section .text
    global _start

    _start:
        print inputNUM, lenght
        scan sign, 1
        call _signCompare
        scan ascii, 16

        call _toINT
        mov r15, rax

        call _frac
  
        call _exp
        print numSBit, 1
        print invertBUFFER, 16 
        print frac, 16

        exit

    _toINT:                  
        movzx rax, byte[rsi]	
		sub rax, '0'			
		cmp al, 9				
		jbe .loopEntry			
		xor rax, rax			
		ret
		.nextNum:			    
		lea rax, [rax*4 + rax]	
		lea rax, [rax*2 + rcx]	
		.loopEntry:
		inc	rsi					
		movzx rcx, byte[rsi]	
		sub rcx, '0'			
		cmp rcx, 9				
		jbe .nextNum			
		ret						

    _divisionNUM:
        mov rdx, 0              
        mov rcx, 2              
        div rcx                 
        mov r13, rax            
        mov r14, rdx           
        ret

    _binaryBUILD:
        mov rax, r15
        mov r12, 0
        .cicle:
            call _divisionNUM
            inc r12
            merge r14, buffer
            mov rax, r13
            cmp r13, 0
            jnz .cicle
        ret

    _reverse:
        mov r10, 16
        mov r11, 0
        .cicle:
            mov r9, [buffer + r10]
            mov [invertBUFFER + r11], r9
            dec r10
            inc r11
            cmp r10, 0
            jnz .cicle
        ret

    _reverseFrac:
        mov r10, r12
        mov r11, 0
        .cicle:
            mov r9, [buffer + r10 - 1]
            mov [invertBUFFER + r11], r9
            dec r10
            inc r11
            cmp r10, 0
            jnz .cicle
        ret

    _fillZEROS:
        mov r15, 48
        mov r8, r12
        .cicle:
            mov [invertBUFFER + r8], r15
            inc r8
            cmp r8, 8
            jne .cicle
        ret

    _copySTR:
        mov rax, [invertBUFFER]
        mov [frac], rax
        ret

    _exp:
        lea rax, [BIAS + r12]
        dec rax
        mov r15, rax
        call _binaryBUILD
        call _reverse
        mov r15, 0
        mov [invertBUFFER + 0], r15
        ret

    _frac:
        call _binaryBUILD
        call _reverseFrac
        call _fillZEROS
        copy invertBUFFER, frac
        ret

    _signCompare:
        mov r15, [sign]         
        mov r14, 43            
        cmp r15, r14            
        jne .setNeg             
        mov r14, 48             
        mov [numSBit], r14        
        jmp .done
        .setNeg:
            mov r14, 49         
            mov [numSBit], r14    
        .done:
            ret
        ret