;GIF Viewer;(C) GREY 2013-2017, KOSHI/MGN 2019;-----------------------------------------------         SAVEBIN "gifview.wmf";--------         ORG #7E00
         INCLUDE "WCHEADER.ASM"
;-----------------------------------------------         ORG #8000;--------
codstart EXA         XOR A         LD (ESTA),A         LD (ESCENKEF),A         LD (wcABT),A         LD (wcENT),A         EXA         OR A:JP NZ,PLUGIN_EXIT ; ��뢠�� ������ ����� ⮫쪮 �� ���७��         PUSH HL,DE
         LD BC,%10 ; 14MHz
         CALL TURBO         LD A,1; time refresh disable         CALL INT_PL         LD BC,CYC,A,CACHE:OUT A; Cache ON         POP DE,HL
        ld (ExSp),sp
        ld (LenL),hl
        ld (LenH),de  ; ��࠭塞 ������ 䠩��
        call CalkLoad ; ���⠥� ᪮�쪮 ���஢/��࠭��/ᥪ�஢ ��㧨��
        ld a,#00
        exa
        ld a,65         
        call wcIN     ; ����砥� - ���������0 � 㧭��� - ����� �� ��࠭��
        ld a,(wcPage3)
        ld (ScrPg),a
        add A,7:ld (EndScr4),a
        add A,8:ld (EndScr8),a
        ld a,#10
        exa
        ld a,65         
        call wcIN       ; ����砥� - ���������1 � 㧭��� - ����� �� ��࠭��
        ld a,(wcPage3)  ; �ᯮ������ ��� 䠩���� ����
        ld (BufPg),a
        ld a,#20
        exa
        ld a,65         
        call wcIN       ; ����砥� - ���������2 � 㧭��� - ����� �� ��࠭��
        ld a,(wcPage3)  ; �ᯮ������ ��� ���ᨢ � ⠡��栬�
        ld (TabPg),a
        ld (ctfirst1),a
        ld (ctfirst2),a
        ld (ctfirst3),a
        inc a
        ld (ctlast1),a
        ld (ctlast2),a
        ld (ctlast3),a
        inc a
        ld (ctlink1),a
        ld (ctlink2),a
        ld (ctlink3),a
        ld (ctlink4),a
        ld (ctlink5),a
        inc a
        ld (palPage),a
        call load_file  ; ��㧨� 䠩� � ����
       
        ld a,#FF
        ld (ClsScr),a   ; ���� ��室 - ��頥� ��࠭
        ld hl,0         ; ��砫쭮� ᬥ饭�� ��࠭�
        xor a
        ld (zagl1),a    ;�����誠 ��� 業�஢�� ��࠭� (⮫쪮 ���� ࠧ 業��㥬)
        ld (ScrX_Scrl),hl
        ld (ScrY_Scrl),hl        CALL USPO
l20_PL  ; 横� ����㧪� ஫��� - ��稭��� � ��砫� 䠩��. 
        ; (⮫쪮 �᫨ ���� 䠩� � �����)
        XOR A        LD (wcABT),A        LD (wcENT),A        
        ld a,(ScrPg)    ; �㤠 � � ����� ����� �ᯠ���뢠��
        ld e,a
        ld a,(BufPg)    ; A - ��稭�� � ����� ��࠭��� ��室���� Gif
        call UnpackGif  ; �����頥� � A ������⮢ 梥⮢ GIF-�
        xor a
        ld (ClsScr),a   ; ��ன ��室 - �� ��頥� ��࠭
        ld hl,(Buf_N_Org)
        ld a,l          ; �᫨ 䠫� ������, ��᪮�쪮 ���஢
        or h            ; � ��� ����� �ࠧ� ����᪠�� ������
        jp nz,WaitBreak ; ���⮬� �室�� �� ��室
        ld a,(wcPage0)
        ld bc,wcPage0
        out (c),a
        ld a,(wcPage3)
        ld bc,wcPage3
        out (c),a
                HALT
        call ESC:JR NZ,EX_ESC
        call ENKE:JR NZ,EX_ENT
        JP l20_PL
EX_ESC  ld hl,0
        xor a
        ld (zagl1),a    ;�����誠 ��� 業�஢�� ��࠭� (⮫쪮 ���� ࠧ 業��㥬)
        ld (ScrX_Scrl),hl
        ld (ScrY_Scrl),hl
        call ScrlScr
        ld a,0
        exa
        ld a,64 ;�MNGV_PL
        call wcIN
        XOR A
        RET;-----------------------------PLUGIN_EXIT LD A,(ESTA)            RET
EX_ENT  
WEnter  ld hl,0
        xor a
        ld (zagl1),a    ;�����誠 ��� 業�஢�� ��࠭� (⮫쪮 ���� ࠧ 業��㥬)
        ld (ScrX_Scrl),hl
        ld (ScrY_Scrl),hl
        LD A,2
        RET

EX_ERR  DI        ld sp,(ExSp)        EI
        ld hl,0
        xor a
        ld (zagl1),a    ;�����誠 ��� 業�஢�� ��࠭� (⮫쪮 ���� ࠧ 業��㥬)
        ld (ScrX_Scrl),hl
        ld (ScrY_Scrl),hl
        ld a,0
        exa
        ld a,64 ;�MNGV_PL
        call wcIN
        LD A,1
        RET

exEnter DI:LD SP,(ExSp):EI        XOR A:LD (wcENT),A        LD A,(ESCENKEF):SET 1,A:LD (ESCENKEF),A
        ld a,(wcPage0)
        ld bc,wcPage0
        out (c),a
        ld a,(wcPage3)
        ld bc,wcPage3
        out (c),a
;HALT
        JP EX_ENT

WaitBreak
        DI        ld sp,0
ExSp    equ $-2        EI
        ld a,(wcPage0)
        ld bc,wcPage0
        out (c),a
        ld a,(wcPage3)
        ld bc,wcPage3
        out (c),a        LD A,(ESCENKEF)        BIT 0,A:JP NZ,EX_ESC        BIT 1,A:JP NZ,EX_ENT
WBloop  HALT
        call ESC:JP NZ,EX_ESC
        call ENKE:JP NZ,EX_ENT
        JR WBloop

LoadNext;����㧪� ᫥���饣� ����
        ld a,(Buf_N)
        ld l,a
        ld a,(Pag_N)
        ld h,a
        ld a,(Sec_N)
        or h
        or l
        jp z,errGif

        push de
        exa
        exx
        push AF
        push HL
        push BC
        push DE

        ld a,(wcPage0)
        ld bc,Page0
        out (c),a
        ld a,(wcPage3)
        ld bc,Page3
        out (c),a
        call load_file
        ld bc,Page3
        ld a,(BufPg)
        out (c),a

        pop de
        pop bc
        pop hl
        pop AF
        exa
        exx
        pop de

        pop AF
        pop bc
        ld hl,#C000
        ret

load_file 
        ld a,(Buf_N)
        or a
        jp z,LastBuf ; �� ��᫥���� ����
        dec a        ; ���� - ��㧨� 楫� ����
        ld (Buf_N),a
        ld a,(BufPg)
        add A,15
        ld (Pg_Last),a ; ��᫥���� ��୨� ����

        ld a,#10 ;��ࢠ� ����㠫쭠� ��� WC ��࠭�� ����
        ld b,16  ;������⢮ ��࠭�� � ����
LoadPg  ; � � - ������⢮ ����㦠���� 楫��  ��࠭��
        ; � � - ��ࢠ� ����㠫쭠� ��� WC - �㤠 ��㧨��
        push AF
        push bc
        exa
        ld a,65  ;�MNGCVPL
        call wcIN
        ld a,48  ;�LOAD512
        ld hl,#C000
        ld b,32 ; 楫�� ��࠭�� 32 ᥪ�� �� 512 ����
        call wcIN
        pop bc
        pop AF
        inc a
        djnz LoadPg
        ret
LastBuf
        ld a,(Pag_N)
        or a
        ld a,#10 ;��ࢠ� ����㠫쭠� ��� WC ��࠭�� ����
        jp z,LastPage
        ld b,a
        call LoadPg
        xor a
        ld (Pag_N),a
LastPage         ;�� ��᫥���� ��࠭�� � ����
        exa
        ld a,65  ;�MNGCVPL       
        call wcIN        
        ld a,(Sec_N)
        or a
        ret z
        ld b,a   ; ������⢮ ᥪ�஢ �� 512�
        ld a,48  ;�LOAD512
        ld hl,#C000
        call wcIN  
        xor a
        ld (Sec_N),a
        ret     

Buf_N     db 0,0  ;������⮢ ���஢ �� 256� ��� 䠩�
Buf_N_Org db 0,0  ;��ࢮ��砫쭮� ������⮢ ���஢
Pag_N     db 0    ;������⮢ ��࠭�� �� 16� � ��᫥����� ���� 
Sec_N     db 0    ;������⮢ ᥪ�஢ �� 512� �� ��᫥���� ��࠭��
CalkLoad
        push de
        srl d
        rr e
        srl d
        rr e   ; � �� - ������� 楫�� ���஢ �� 256 �
        ld (Buf_N),de
        ld (Buf_N_Org),de
        pop de
        push hl
        ld a,e
        sla h   ; ������� ����� 
        rla     ; 2 ࠧ�, 
        sla h   ; ������� ����� 
        rla     ; 2 ࠧ�, 
        and 63  ; � A - ������⢮/���⮪ 楫�� ��࠭�� � ��᫤���� ����
        ld (Pag_N),a
        pop hl
        ld a,h
        and 1
        or l
        ld a,h
        jr z,nl ; ������� ���� ��⭮ ᥪ��� 512
        srl a
        inc a   ; � ᫥���饬 ᥪ�� ���� ���⮪ 
        ld (Sec_N),a
        ret
nl      srl a ; ������� ���� ��⭮ ᥪ��� 512
        ld (Sec_N),a
        ret

ShowGif cp 17             ; �஢���m - � ����� ०��� 4 ��� �� 8 ��� �����뢠��
        jp c,ShowGif16

        ld a,(wcPage0)
        ld bc,Page0
        out (c),a
        ld bc,Page3
        in a,(c)
        ld (sacep3),a
        ld a,(wcPage3)
        out (c),a

        LD  A,%11000010
        exa
        ld a,66 ;�GVmod
        call wcIN
        ld a,1
        exa
        ld a,64 ;�MNGV_PL
        call wcIN
;HALT
        ld bc,Page3
        ld a,(sacep3)
        out (c),a
        ret

sacep3  db 0
ShowGif16
        ld a,(wcPage0)
        ld bc,Page0
        out (c),a

        ld bc,Page3
        in a,(c)
        ld (sacep3),a
        ld a,(wcPage3)
        out (c),a
        LD  A,%11000001
        exa
        ld a,66 ;�GVmod
        call wcIN
        ld a,1
        exa
        ld a,64 ;�MNGV_PL
        call wcIN
;HALT
        ld bc,Page3
        ld a,(sacep3)
        out (c),a
        ret

ScrlScr    
zagl1   nop
        ld a,(KodZagl)
        ld (zagl1),a    
        push hl
        ld hl,(ScrX_Scrl)
        ld bc,GXOffsL
        out (c),l
        ld bc,GXOffsH
        out (c),h
        ld hl,(ScrY_Scrl)
        ld bc,GYOffsL
        out (c),l
        ld bc,GYOffsH
        out (c),h
        
        ld a,(wcPage0)
        ld bc,Page0
        out (c),a
        ld bc,Page3
        in a,(c)
        ld (sacep3),a
        ld a,(wcPage3)
        out (c),a        
        ld a,67
        ld hl,(ScrY_Scrl)
        call wcIN
        ld a,68
        ld hl,(ScrX_Scrl)
        call wcIN

        ld bc,Page3
        ld a,(sacep3)
        out (c),a

        pop hl
KodZagl ret

;/********************************/
;/* ������⥪� �ᯠ����� GIF � */
;/********************************/

palPage   db 0 ;equ #07;� ���� ���ਬ ������� - ����� ��।�����                ;�१ �� ���� � 512 ����

SysConfig equ   #20AF
DMACtrl   equ   #27AF
DMAStatus equ   #27AF
DMALen    equ   #26AF
DMANum    equ   #28AF
DMASAddrL equ   #1AAF
DMASAddrH equ   #1BAF
DMASAddrX equ   #1CAF
DMADAddrL equ   #1DAF
DMADAddrH equ   #1EAF
DMADAddrX equ   #1FAF
GXOffsL   equ   #02AF
GXOffsH   equ   #03AF
GYOffsL   equ   #04AF
GYOffsH   equ   #05AF

VConfig   equ   #00AF
VPage     equ   #01AF   
MemConfig equ   #21AF   
MemRet    equ   %00000001   
Page0     equ   #10AF        
Page2     equ   #12AF
Page3     equ   #13AF
trdos     equ   #3D13
FMAddr    EQU   #15AF
PalSel    equ   #07AF

clearScr ; ��頥� ���� ��࠭ 512*512
        ex AF,AF'
        ld bc,Page3
        in a,(c)
        ld (pad3st),a
        ex AF,AF'
        out (c),a
        ex AF,AF'
        ld a,0
back_p  equ $-1

        ld (#C000),a
        ld (#C001),a

        ld bc,DMALen
        ld a,255
        out (c),a
        ld bc,DMANum
        out (c),a
        xor a
        ld bc,DMASAddrL
        out (c),a
        ld bc,DMASAddrH
        out (c),a
        ex AF,AF'
        ld bc,DMASAddrX
        out (c),a
        ex AF,AF'
        ld bc,DMADAddrL
        inc a
        inc a
        out (c),a
        ld bc,DMADAddrH
        dec a
        dec a
        out (c),a
        ex AF,AF'
        ld bc,DMADAddrX
        out (c),a
        ex AF,AF'
        ld a,#1
        ld bc,DMACtrl
        out (c),a

        ld bc,DMACtrl
wtdma   in a,(c)
        bit 7,a
        jp nz,wtdma

        ld bc,DMALen
        ld a,255
        out (c),a
        ld bc,DMANum
        ;ld a,255
        out (c),a
        xor a
        ld bc,DMASAddrL
        out (c),a
        ld bc,DMASAddrH
        out (c),a
        ex AF,AF'
        ld bc,DMASAddrX
        out (c),a
        ex AF,AF'
        ld bc,DMADAddrL
        out (c),a
        ld bc,DMADAddrH
        out (c),a
        ex AF,AF'
        add a,#08
        ld bc,DMADAddrX
        out (c),a
        ex AF,AF'
        ld a,#1
        ld bc,DMACtrl
        out (c),a

        ld bc,Page3
        ld a,0
pad3st  equ $-1
        out (c),a
        ret

UnpackGif
        ex AF,AF'
        ld a,e
        ld (pgloc),a
        ld (pgloc4),a        
        ld (pgScr),a
        ex AF,AF'

        ld (saveSP),SP
        ld bc,Page3
        out (c),a

; /* ��蠥� jamp-� �� �஢��� �஧�筮�� 梥�*/
; /* �� ���砭�� ����� ���� ���� ��� �஧�筮�� 梥�. */
; /* ����稬, �᫨ �㤥� ��� � ����� ���ଠ樨*/
        ld de,notr
        ld (j_notr),de
        ld de,notr1
        ld (j_notr1),de
        ld de,notr2
        ld (j_notr2),de

        LD hl,#C000     ; ��㤠 �⠥�
        LD de,#C000     ; �㤠 �ᯠ���뢠��
        ld (scrofs),de
        ld (scrofs4),de
        ; �஢��塞 ���������, �� �� GIF
        ld a,(hl)
        cp "G"
        jp nz,EX_ERR
        inc hl
        ld a,(hl)
        cp "I"
        jp nz,EX_ERR
        inc hl
        ld a,(hl)
        cp "F"
        jp nz,EX_ERR
        inc hl 
        inc hl
        inc hl
        inc hl
        ; �⠥� ࠧ�襭�� �� X � Y
        ld c,(hl)
        inc hl
        ld b,(hl)
        ld (s_x),bc
        push hl
        ld l,c
        ld h,b
        ld bc,360      ; �஫��㥬 ��࠭, �� �� ����ࠦ���� ��業�஢�����
        OR A:SBC hl,bc ; �� �㦭� ⮫쪮 ��� ��ᬮ��騪�, ��� �ᯠ�����                       ; � ������ - ����
        sra h
        rr l
        ld (ScrX_Scrl),hl
        pop hl
        inc hl
        ld c,(hl)
        inc hl
        ld b,(hl)
        ld (s_y),bc
        push hl
        ld l,c
        ld h,b
        ld bc,288      ; �஫��㥬 ��࠭, �� �� ����ࠦ���� ��業�஢�����
        OR A:SBC hl,bc ; �� �㦭� ⮫쪮 ��� ��ᬮ��騪�, ��� �ᯠ�����                       ; � ������ - ����
        sra h
        rr l
        ld (ScrY_Scrl),hl
        pop hl
        inc hl
        ; �⠥� ���� 䫠���
        ld a,(hl)
        ld (gl_pal),a
        and 7
        inc a
        ld (bitpix),a
        inc hl
        cp 5
        ld a,(hl)
        jr nc,A8btBck
        rlca
        rla
        rla
        rla        
        or (hl)
        ; 梥� 䮭�
A8btBck
        ld (back_p),a
        ld a,0
ClsScr  equ $-1
        or a        
        jp z,nocls
        ld a,(pgScr) 
        call clearScr
nocls   inc hl
        inc hl
        ld a,(bitpix)
        ld de,pixcol
        add a,e ; �� ⠡���� � DE 㧭��� ᮫쪮 梥⮢ � ���� ����ࠦ���� (2^A)
        ld e,a  ; �࠭�� ��ࠣ�� - ���� �� ��室���� �ਡ������ A � DE
        ld a,0
        adc a,d
        ld d,a
        ld a,(de)
        ld (colpix),a
        push hl
        push AF
        call ShowGif
        pop AF
        pop hl
        cp 17
        jp nc,A4bit
        ld de,DoPixel16
        jp A8bit
A4bit   ld de,DoPixel
A8bit   ld (DoPixelHL),de
        ld a,(gl_pal)
        bit 7,a
        call nz,LoadPal ; �᫨ ���� - ����㧨� �������
l15     ld a,(hl)
        cp "!"     ; ���� �ᯮ����⥫��� ������ - ���ࠡ��뢠�� �ࠢ������                   ; ���ଠ�� �� ����ࠦ����
        jp z,blok1
        cp ","
        jp nz,neimg
        call Image ; ���� ����ࠦ����

        ld a,(colpix)
        push hl
        call ShowGif
        pop hl
        ld a,(pgScr)
        ld (pgloc),a
        ld (pgloc4),a
        LD de,#C000     ; �㤠 �ᯠ���뢠��
        ld (scrofs),de
        ld (scrofs4),de    
; /* ��蠥� jamp-� �� �஢��� �஧�筮�� 梥�*/
; /* �� ���砭�� ����� ���� ���� ��� �஧�筮�� 㢥�. */
; /* ����稬, �᫨ �㤥� ��� � ����� ���ଠ樨*/
        ld de,notr
        ld (j_notr),de
        ld de,notr1
        ld (j_notr1),de
        ld de,notr2
        ld (j_notr2),de
        jp l15

neimg   ld a,(hl)
        cp ";"          ; ��� ��� ������ (�᫨ �� ����� �����)
        jp z,endGif
        inc l
        call z,NxPgGif
        jp l15

errGif  DI        ld SP,0
saveSP  equ $-2        EI
        ld bc,Page0
        ld a,(wcPage0)
        out (c),a        
        ld a,(colpix)
        scf
        ret

endGif  ; ����⠭���� �� ����� � ����0 - ���� ����稫�� ��ᨪ 48
        ld bc,Page0
        ld a,(wcPage0)
        out (c),a
        ld a,(colpix)
        or a
        ret ;� A - ������⢮ 䢥⮢ gif  �=0 ��� �訡��

NxPgGif inc h
        ret nz  ; �஢�ઠ �� ����� ��࠭���
        ld h,#C0
        push bc
        push AF        
        ld bc,Page3
        in a,(c)        ; ��� ���, �� �� ����3 ����� ����
        cp 0
Pg_Last equ $-1
        jp z,LoadNext
        inc a
        out (c),a
        pop AF
        pop bc
        ret

blok1   inc l           ; ��� ����� ���� ����஢뢠�� �� 㬥��
        call z,NxPgGif
        ld a,(hl)
        cp #F9
        jp z,gif98a ; �� ��� �� 㬥� - �������⥫��� ���ଠ�� �� ����ࠦ����
        inc l
        call z,NxPgGif
        ld b,(hl)       ; ������ �����
l16     inc l
        call z,NxPgGif
        djnz l16
        inc l
        call z,NxPgGif
        ld b,(hl)
        xor a
        or b
        jp nz,l16  ;errGif  0 - ����� ���� ������ ᫥���饣� �����
        inc l
        call z,NxPgGif
        jp l15

oldTr   db 0
gif98a 
        inc l
        call z,NxPgGif
        ld b,(hl)       ; ������ �����
        inc l
        call z,NxPgGif
        ld a,(oldTr)
        and %11100
        cp %01000
        ld a,(hl)
        ld (oldTr),a
        jp z,Notransp
        and 1
        jp z,Notransp
; /* ��⠢�塞 jamp-� �� �஢��� �஧�筮�� 梥�*/
        ld de,j_notr+2
        ld (j_notr),de
        ld de,j_notr1+2
        ld (j_notr1),de
        ld de,j_notr2+2
        ld (j_notr2),de
Notransp
        inc l
        call z,NxPgGif
        inc l
        call z,NxPgGif
        inc l
        call z,NxPgGif
        ld a,(hl)       ; � ���������� �஧��� 梥�
        ld (trcol),a
        ld (trcol1),a
        ld (trcol2),a        
        inc l
        call z,NxPgGif
        jp l15

LoadPal
        ld bc,Page0
        ld a,(palPage)
        out (c),a
        ld a,(colpix)
        inc a
        ld b,a 
        ld de,#0000+1
lp14
        ld a,(hl)
        inc l
        call z,NxPgGif
        rrca
        and %01111100
        ld c,a
        ld a,(hl)
        rlca
        rlca
        and %00000011
        or c
        ld (de),a
        dec de
        ld a,(hl)
        inc l
        call z,NxPgGif
        rlca
        rlca
        and %11100000
        ld c,a
        ld a,(hl)
        inc l
        call z,NxPgGif
        rrca
        rrca 
        rrca 
        and %00011111
        or c
        ld (de),a
        inc de
        inc de 
        inc de
        djnz lp14

        push hl
        LD  A,%00000000  ; T1PAL[7:6] T0PAL[7:6] GPAL[7:4] Palette selection for 4 bit modes
        LD  BC,PalSel    ; GPAL 0-15 colors
        OUT (C),A
        LD  A,#10;%00010000   ; ����砥� ������� �� ����� #0000
        LD  BC,FMAddr
        OUT (C),A

        ld hl,(colpix)
        inc hl
        add hl,hl
        ld c,l
        ld b,h
        XOR  A
        ld h,a,l,a
        ld d,a,e,a
        ldir

        XOR  A            ; �⪫�砥� �������
        LD  BC,FMAddr
        OUT (C),A        
        pop hl
        ret

Image   ; ���� ����ࠦ����. ��᪨ਯ��, �����쭠� ������, � ���஢� �����
        ld a,(bitpix)   ;  �����뢠�� ࠧ��� ���ᥫ� �� ��������� ��ࠬ��஢
        ld (pixelsize),a
        xor a
        ld (interlaced),a ; ����塞 ०�� �।������ ��ப

        inc l
        call z,NxPgGif
        ld c,(hl)
        inc l
        call z,NxPgGif
        ld b,(hl)
        ld (imagex),bc   ; �⠥� �ᯮ������� � ���⨭�� �� ����㠫쭮� ��࠭�
        ld (xloc),bc
        ld (xloc4),bc
        inc l 
        call z,NxPgGif
        ld c,(hl)
        inc l
        call z,NxPgGif
        ld b,(hl)
        ld (yloc),bc  ; �⠥� �ᯮ������� Y ���⨭�� �� ����㠫쭮� ��࠭�
        ld a,(colpix)
        cp 17
        jp c,I4bit
        ld a,c          ; ��ॢ���� Y � ����� ��࠭��� � ᬥ饭�� ���襣� ����
        sla c           ; ��� 8 ��� ०���
        rl b
        sla c
        rl b
        sla c 
        rl b   
        and 31
        add A,A
        add A,#C0
C0_1    equ $-1             
        ld (scrofs+1),a
        ld a,(pgScr)
        add a,b
        ld (pgloc),a
        jp I8bit

I4bit   ld a,c          ; ��ॢ���� � � ����� ��࠭��� � ᬥ饭�� ���襣� ����
        sla c           ; ��� 4 ��� ०���
        rl b
        sla c 
        rl b           
        and 63
        add A,#C0
C0_2    equ $-1     
        ld (scrofs4+1),a   
        ld a,(pgScr)             
        add a,b
        ld (pgloc4),a

I8bit   call ScrlScr ; wtynhetv 業��㥬 ��ୠ ᮣ��᭮ ���न���
        inc l
        call z,NxPgGif
        ld c,(hl)
        inc l
        call z,NxPgGif
        ld b,(hl)       ; �⠥� ࠧ��� ���⨭��
        ld (imagewide),bc    ; ���� ����� ���� ����� ���� ࠧ���� ࠧ���  
        inc l
        call z,NxPgGif
        ld c,(hl)
        inc l
        call z,NxPgGif
        ld b,(hl)
        ld (imagedeep),bc
        inc l
        call z,NxPgGif
        ld a,(hl)
        bit 7,a
        jp z,locpal
        push AF
        and 7
        inc a
        ld (pixelsize),a
        call local_pal  ; �� - �� �� ���� �����쭠� ����� � �� �㦭� ����㧨��
        pop AF
locpal
        bit 6,a
        jp z,interliv
        ld (interlaced),a
interliv; ����� �㦭� ��ࠡ���� ��ਠ��, ����� ����ࠦ���� �१���筮� ( ०�� ��९��⥭��) �� ���饥
        inc l
        call z,NxPgGif
        ld b,1  ; bufct
        ld a,(hl)
        inc l
        call z,NxPgGif
        ld (codestart),a
        call UnpackImage ; ��� ���ࠤ��� �� ᠬ�� ����� ���஢�� ������
        ret

local_pal
        inc l
        call z,NxPgGif
        ld de,pixcol
        add a,e ; �� ⠡���� � DE 㧭��� ᮫쪮 梥⮢ � ���� ����ࠦ���� (2^A)
        ld e,a  ; ⠪ ��� ⠡��� �� ��ࠢ���� �� �࠭�楪 ����� - ���� �� ��室���� �ਡ����� A � DE
        ld a,0
        adc a,d
        ld d,a
        ld a,(de)
        ld (colpix),a
        call LoadPal
        ret

LenL    dw 0
LenH    dw 0
ScrPg   db 0    ;��ࢠ� ��࠭�� ����� ����0 - ��� ��࠭�.
BufPg   db 0    ;��ࢠ� ��࠭�� ����� ����1 - �ᯮ������ ��� 䠩���� ����.
TabPg   db 0    ;��ࢠ� ��࠭�� ����� ����2 - �ᯮ������� ��� ⠡���� � ���ᨢ���.


ScrX_Scrl dw 0
ScrY_Scrl dw 0

imagex  dw 0
;bufct   dw 0    ; �㤥� �࠭��� � b'
pixelsize  db 0
interlaced db 0
imagewide  dw 0
imagedeep  dw 0
;clearcode  dw 0        ; ��७� �࠭���� ����� ����
codestart  dw 0        
;eoi        dw 0        ; �࠭�� � ����
;reqct      dw 0
oldcode    dw 0
;pass       dw 0
rowcnt     dw 0
;xloc       dw 0
yloc       dw 0
yloc4       dw 0

;pgloc      dw 0
pgScr      db 0
;code       dw 0        ; �࠭�� � ����
nextcode   dw 0
;nextlim    dw 0
;remct      dw 0
rem        dw 0
;scrofs     dw 0

;/******************************/
;        MACRO callGetCode
;
;        cp 9 ;sub hl,de       ; { If reqct<=8 }
;        jp nc,._g01
;        call GetBCode   ;{   then return GetBCode(reqct) }
;        jp ._gex
;._g01   push AF ;push de         
;        ld a,8 ;ld de,8
;        call GetBCode
;        ld (._pushde),de ;{ temp:=GetBCode(8) }
;        pop AF ;pop hl
;        sub 8  ;ld de,8
;        call GetBCode
;        ex de,hl
;        ld h,l
;        ld l,0
;        ld de,0
;._pushde equ $-2
;        ld a,l  
;        or e
;        ld e,a
;        ld a,d
;        or h
;        ld d,a        
;._gex    
;        ENDM
;/******************************/

UnpackImage
        cp 13       ; �� �뢠�� ����� ����� 12 ��� 
        jp nc,errGif; �� � �� � ��� ���ᮢ뢠�� - ����� �� � �� 䨣
        exx
        ld b,a      ; ࠧ��� ������� ���� (⨯� ��� �� ���ᥫ� ⮫쪮 ��� ��娢��� �� 2 ��  ���� 12 
        ld de,1
l17     sla e
        rl d 
        djnz l17    ; ��� ���⪨  clearcode:= 2 � �⥯���  codestart (��� 4 - 10000)
        ld (clearcode),de
        inc de
        ld (eoi),de ;  ��� ���� ��⮪�  eoi:=clearcode+1 
        inc a
        ld (reqct),a; �票�稪 ����⮭���� ᤢ���  reqct:=codestart+1 }
        dec de      ; � de - clearcode
        call InitCodeTable
        ld de,#FFFF
        ld (oldcode),de
        inc de ; de=0
       ;ld (pass),de
       ;ld (xloc),de    ; ����塞   screen position }
        ld (yloc),de
       ;ld (xloc4),de   ; ����塞   screen position }
        ld (yloc4),de
        xor a
;ld (done),a
        ld (remct),a  
        ld de,(imagewide)
        ld (rowcnt),de;-------
ui01    ld a,0 ;(reqct)    
reqct   equ $-1
;-------callGetCode:        cp 9 ;sub hl,de       ; { If reqct<=8 }
        jp nc,Ag01
        call GetBCode   ;{   then return GetBCode(reqct) }
        jp Agex
Ag01    push AF ;push de         
        ld a,8 ;ld de,8
        call GetBCode
        ld (Apushde),de ;{ temp:=GetBCode(8) }
        pop AF ;pop hl
        sub 8  ;ld de,8
        call GetBCode
        ex de,hl
        ld h,l
        ld l,0
        ld de,0
Apushde equ $-2
        ld a,l  
        or e
        ld e,a
        ld a,d
        or h
        ld d,a        
Agex    ;-------macroend
          ld (code),de  
          ld hl,00        ;(clearcode)
clearcode equ $-2        
          OR A:SBC hl,de:jp nz,ui02
        ld de,(clearcode)
        call InitCodeTable
        ld a,(codestart)
        inc a
        ld (reqct),a ;  reqct:=codestart+1 
        ld de,#FFFF
        ld (oldcode),de
;jp ui07        LD A,(wcABT):OR A:JP NZ,exgif        LD A,(wcENT):OR A:JP NZ,exEnter        JP ui01 
ui02    ld hl,0;(eoi)
eoi     equ $-2        
        OR A:SBC hl,de
        jp nz,ui03
        call FlushIn    ; �����稫��� ��
;ld a,#FF ; 䤠� ��� ��室�
;ld (done),a
;jp ui07        ;LD A,(wcABT):OR A:JP NZ,exgif        ;LD A,(wcENT):OR A:JP NZ,exEnter        EXX        RET
ui03    ld hl,(code)
        add hl,hl
        ld a,0;(ctlink)
ctlink1 equ $-1        
        ld bc,Page0
        out (c),a
        ld e,(hl)
        inc hl
        ld d,(hl)
        ld h,d          ;ld hl,#FEFF;#FFFE ; (-2)
        inc h           ;sub hl,de
        inc h
        jp z,ui05
        ; ��� ��⨬���஢�� �஢�४ - �뫮     ;ld hl,#FFFF
        ld de,(oldcode)                         ;ld de,(oldcode)
        inc d                                   ;sub hl,de
        jp z,ui06
        ld bc,(code)
        ld de,(oldcode)
        call InsertCode
ui04    jp ui06
ui05    ld bc,(oldcode)
        ld d,b ;ld de,(oldcode)
        ld e,c
        call InsertCode
ui06    ld hl,0 ;(code)
code    equ $-2
        ld (oldcode),hl
;/**********************************/
PutX    ld bc,Page3    ; ��襬 ���� � ���� ���ᥫ��
        in a,(c)
        ld (PgGif),a
        ld d,endcode[  ; ld de,0
        ld e,#FF
        ld b,Page0[
px01   
        ld a,0;(ctlast)
ctlast2 equ $-1        
        out (c),a
        ld a,(hl)
        ld (de),a
        inc de
        add hl,hl
        ld a,0;(ctlink)
ctlink3 equ $-1        
        out (c),a
       
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a         ; � ��饬 ��� ��⨬���஢�� �஢���
        ld a,h
        inc a
        jp nz,px01

loop    dec de
        ld a,(de)
        push de
        jp DoPixel ; �뢮��� ���ᥫ�
DoPixelHL equ $-2  ; � ०���� 4/8 ��� - ����⠢����� ࠧ�� ���� ��楤���
ExDoPix pop de
        ld a,d
        cp endcode[
        jp nz,loop
    ;ld bc,Page3   ; Page3 ������ ������� �� DoPixel
        ld a,0
PgGif   equ $-1
        out (c),a        LD A,(wcABT):OR A:JP NZ,exgif        LD A,(wcENT):OR A:JP NZ,exEnter        JP ui01
;/********************************/

;ui07    LD A,(wcABT):OR A:JP NZ,exgif;        LD A,(wcENT):OR A:JP NZ,exEnter
;ld a,0
;done    equ $-1
;or a:jp z,ui01;exx
;ret

exgif   XOR A:LD (wcABT),A        LD A,(ESCENKEF):SET 0,A:LD (ESCENKEF),A        exx
        pop hl
        jp WaitBreak

FlushIn exx      ; � b - bufct  ������ ����� +1
        dec b
        jp z,fi02 
fi01    inc l 
        call z,NxPgGif
        dec b
        jp nz,fi01
fi02    ld b,(hl) ;  bufct
        inc b
        inc l 
        call z,NxPgGif
        dec b
        jp nz,fi01       
        exx
        ret

InsertCode      ; ��⠢�塞 � ⠡��� ���� ���
        push bc ;        ld de,(oldcode)
        ld hl,(nextcode)
        add hl,hl
     
        ld bc,Page0
        ld a,0;(ctlink)
ctlink2 equ $-1
        out (c),a
        ld (hl),e ; ���ᨢ �᫮�  ctlink[nextcode]:=oldcode
        inc hl
        ld (hl),d

        ld a,0;(ctfirst)
ctfirst1 equ $-1
        out (c),a
        pop hl
        ld a,(hl)       ; A = ctfirst[code]
        ld hl,(nextcode)

        ex AF,AF'
        ld a,0;(ctlast)
ctlast1 equ $-1
        out (c),a
        ex AF,AF'
        ld (hl),a       ; ctlast[nextcode]:=A

        ld a,0          ;(ctfirst)
ctfirst2 equ $-1
        out (c),a
        ld a,(de)       ;ld a,(hl)

        ld (hl),a       ; ��� � ᤢ��㫨 ���� ��� � ᫥���騩 ���
        inc hl          ; ctfirst[nextcode]:=ctfirst[oldcode]
        ld de,0         ;(nextlim)
nextlim equ $-2
        ex de,hl        ; �᫨ ���⨣�� ���ᨬ��쭮�� ���� � �㦭� 㢥��稢��� ��� �� ���
        OR A:SBC hl,de
        jp nz,icEx
        ld a,(reqct) ;ld hl,(reqct)
        cp 12  ;ld bc,12        ; �� ������ �� ��� �� ����� ������� 12 ��� 
        jp nc,icEx
        ld a,(reqct)
        inc a
        ld (reqct),a
        ld hl,(nextlim)
        add hl,hl
        ld (nextlim),hl
icEx    ld (nextcode),de
        ret

DoPixel16       ; 4 ��� �� ���ᥫ�
        ld b,Page3[
        ld e,0  ;(pgloc)
pgloc4  equ $-1
        out (c),e
        ld hl,0 ;(xloc)
xloc4   equ $-2
        ld de,0;(scrofs)
scrofs4 equ $-2
        srl h
        rr l
        jp c,lbt4
        add hl,de
        jp c,Xovr16
        jp notr1      ; ��९�루���� �१ �஢��� �஧�筮�� 梥�
j_notr1 equ $-2       ; �᫨ �� �㦭� �஢�����
        cp 0          ; �஢��� �� �஧��� 梥�
trcol1  equ $-1       ; ��� 梥� � ���� ��९�루����� ����⠨������� ��࠭��
        jp z,Xovr16
notr1   rlca
        rla
        rla
        rla
        ld e,a
        ld a,#0F
        and (hl)
        or e
        ld (hl),a
        jp hbt4

lbt4    add hl,de
        jp c,Xovr16
        jp notr2       ; ��९�루���� �१ �஢��� �஧�筮�� 梥�
j_notr2 equ $-2       ; �� ⮦� ᠬ�� ��� ���⭮�� ���㡠�� �窨
        cp 0
trcol2  equ $-1
        jp z,Xovr16
notr2  
        ld e,a
        ld a,#F0
        and (hl)
        or e
        ld (hl),a
hbt4
Xovr16
        ld hl,(xloc4)
        inc hl
        ld (xloc4),hl

        ld hl,(rowcnt)
        dec hl
        ld (rowcnt),hl
        ld a,l
        or h
        jp nz,ExDoPix ;ret nz ;jr nz,_dpex16
        ld hl,(imagex)
        ld (xloc4),hl
        ld hl,(imagewide)
        ld (rowcnt),hl

dp0216  ld hl,(yloc)
        inc hl
        ld (yloc),hl
        ;��� Y
        ld a,(scrofs4+1)
        inc a
        jp nz,dpY16
        ld a,(pgloc4)
        inc a
        cp a,0 ;#1f
EndScr4 equ $-1
        jp nc,ovpg16
        ld (pgloc4),a
ovpg16  ld a,#C0
dpY16   ld (scrofs4+1),a
        jp ExDoPix ;ret

DoPixel          ; 8 ��� �� ���ᥫ�  - ��� 5,6,7 ��� ⮦� �뢠�� 
        ld b,Page3[
        ld e,0  ;(pgloc)
pgloc   equ $-1
        out (c),e
        ld de,0 ;(xloc)
xloc    equ $-2
        ld hl,0 ;(scrofs)
scrofs  equ $-2
        add hl,de
        jp c,Xovr
        jp notr        ; ��९�루���� �१ �஢��� �஧�筮�� 梥�
j_notr  equ $-2
        cp 0
trcol   equ $-1
        jp z,Xovr
notr    ld (hl),a
Xovr    inc de
        ld (xloc),de
        ld hl,(rowcnt)
        dec hl
        ld (rowcnt),hl
        ld a,l
        or h
        jp nz,ExDoPix ;ret nz ;jr nz,_dpex ��������� 横� �뢮�� �窨
        ld hl,(imagex);          � ⠪ 0
        ld (xloc),hl
        ld hl,(imagewide)
        ld (rowcnt),hl

dp02    ld hl,(yloc)
        inc hl
        ld (yloc),hl
        ;��� Y
        ld a,(scrofs+1)
        inc a
        jp z,NdpY
        inc a   ; ��� 256 梥⮢
        jp nz,dpY
NdpY    ld a,(pgloc)
        inc a
        cp a,0 ;#1f
EndScr8 equ $-1
        jp nc,overpg
        ld (pgloc),a
overpg  ld a,#C0
dpY     ld (scrofs+1),a
        jp ExDoPix ;ret
;/*
;CleraLine8      ; ����⪠ ��ப�, ��� �� �⠭����� - �� � ��� �� ��ᨢ� ���栥�
;        ld bc,DMALen
;        ld hl,(imagewide)
;        srl h
;        rr l
;        dec l
;        ret z
;        out (c),l
;        ld bc,DMANum
;        ld a,1
;        out (c),a
;        ld hl,(scrofs)
;        ld bc,DMASAddrL
;        out (c),l
;        ld bc,DMADAddrL
;        inc l
;        out (c),l
;        ld bc,DMASAddrH
;        out (c),h
;        ld bc,DMADAddrH
;        out (c),h
;        ld bc,DMASAddrX
;        ld a,(pgloc)
;        out (c),a
;        ld bc,DMADAddrX
;        out (c),a
;        ld a,#3
;        ld bc,DMACtrl
;        out (c),a
;        ret
;*/
eof     equ #FFFF       ; ������塞 ⠡���� �����
InitCodeTable
        ld hl,(clearcode)
        inc hl          ;ld bc,2
        inc hl          ;add hl,bc
        ld (nextcode),hl
        ld hl,(clearcode)
        add hl,hl
        ld (nextlim),hl
        ld hl,0         ; ��稠�� �  code =0

A01     ld de,(clearcode) ;  ���⨬�� ����  code < HL do ...
        push hl
        OR A:SBC hl,de
        pop hl
        jp nc,A02
        ld a,0;(ctfirst)
ctfirst3 equ $-1
        ld bc,Page0
        out (c),a
        ld (hl),l       ; ctfirst[code]:=code
        ld a,0;(ctlast)
ctlast3 equ $-1
        out (c),a
        ld (hl),l       ;  ctlast[code]:=code 
        add hl,hl
        ld a,0;(ctlink)
ctlink4 equ $-1
        out (c),a
        ld bc,0-1        ;  ctlink[code]:= -1 - ⠡��� 㪠��⥫� �� 楯�窨 �����
        ld (hl),c
        inc hl
        ld (hl),b
        srl h
        rr l
        inc hl
        jp A01
A02     ld de,4096      ; ���ᨠ�쭮 ��������  ࠧ��� ⠡���� �� 12 ����
        ex de,hl
        OR A:SBC hl,de
        ret c
        ex de,hl
        add hl,hl
        ld bc,Page0
        ld a,0;(ctlink)
ctlink5 equ $-1
        out (c),a
        ld bc,#FEFF ;-2
        inc d           ;(+1 �� �� 横� ᤥ���� �� 䫠�� Z )
RepStw  ld (hl),c
        inc hl
        ld (hl),b
        inc hl
        dec e 
        jp nz,RepStw
        dec d
        jp nz,RepStw

        ld bc,#FFFF ;-1
        ld (hl),c
        inc hl
        ld (hl),b
        inc hl        
        ret

;/********************************/
;        MACRO   CallGetGB
;        exx   ; Cp     bufct = 0
;        dec b
;        jp nz,._n02
;        xor a
;        ld b,(hl)       ; ���� bufct
;        or b
;        jp z,._g02
;        inc l
;        call z,NxPgGif
;._n02   ld a,(hl)
;        inc l
;        call z,NxPgGif
;._g02   exx
;        ENDM
;/********************************/

GetBCode 
        ld e,a        ;a  = reqct ; de = reqct
        ld a,0 ;(remct)    ; ���稪 ᤢ���
remct   equ $-1
        or a            ;  If remct=0 
        jp nz,gb01     ;  then rem:=GetGB;------- 
;CallGetGB:        exx   ; Cp bufct = 0
        dec b
        jp nz,A1n02
        xor a
        ld b,(hl)   ; ���� bufct
        or b
        jp z,A1g02
        inc l
        call z,NxPgGif
A1n02   ld a,(hl)
        inc l
        call z,NxPgGif
A1g02   exx;-------
        ld (rem),a
        xor a
        ld (rem+1),a
        ld a,8          ;  remct:=8 }

gb01    cp e          ;  If remct<reqct }
        jp nc,gb02
        ex AF,AF';-------
;CallGetGB:        exx   ; Cp bufct = 0
        dec b:jp nz,A2n02
        xor a:ld b,(hl):or b:jp z,A2g02  ; ���� bufct
        inc l:call z,NxPgGif
A2n02   ld a,(hl)
        inc l:call z,NxPgGif
A2g02   exx;-------
        ld l,a
        ld h,0
        exa

        ld b,a
        exa
        ld a,12
        sub b
        ld (djn),a
        jr $-1
djn     equ $-1 ; ������� ��⠥��� ���� �� �� ������ ����
.12     add hl,hl

        ld a,(rem)      ; ᪠��뢠�� � ���� ᤨ���� ���㡠⮬    rem,a
        or l
        ld (rem),a      ; � ����砥� 12 ��� ᫮�� ����
        ld a,(rem+1)
        or h
        ld (rem+1),a
        ex AF,AF'
        add a,8

gb02    ex AF,AF'
        ld ix,cmask
        ld a,e
        ld (cm1),a
        ld l,(ix+1)
cm1     equ $-1 

        ld h,0
        ld a,(rem)
        and l
        ld l,a
        ld (ax1),hl
        ex AF,AF'
        sub e
        ld (remct),a

        ld a,12
        sub e
        rlca
        rlca
        ld hl,(rem)
        ld (djn1),a
        jr $-1
djn1    equ $-1 ; ������� ��⠥��� ���� �� �� ������ ����
.12     srl h:rr l
        ld (rem),hl
        ld de,0
ax1     equ $-2
        ret;----------------------------------------------INT_PL  EXA:LD A,86:JP WLD;MNGC_PL EXA:LD A,0:JP WLD;MNG0_PL EXA:LD A,78:JP WLD;MNG8_PL EXA:LD A,79:JP WLD;PRWOW   LD A,1:JP WLD;RRESB   LD A,2:JP WLD;PRSRW   LD A,3:JP WLD;PRIAT   EXA:LD A,4:JP WLD;GADRW   LD A,5:JP WLD;CURSOR  LD A,6:JP WLD;CURSER  LD A,7:JP WLD;YN      EXA:LD A,8:JP WLD;ISTR    EXA:LD A,9:JP WLD;NORK    EXA:LD A,10:JP WLD;TXTPR   LD A,11:JP WLD;DMAPL   EXA:LD A,13:JP WLDTURBO   LD A,14:JP WLDGEDPL   LD A,15:JP WLD;-------;KBSCN   EXA:LD A,42:JP WLD;SPKE    LD A,16:JP WLD;UPPP    LD A,17:JP WLD;DWWW    LD A,18:JP WLD;LFFF    LD A,19:JP WLD;RGGG    LD A,20:JP WLD;TABK    LD A,21:JP WLDENKE    LD A,22:JP WLD;BSPC    LD A,24:JP WLD;PGUP    LD A,25:JP WLD;PGDN    LD A,26:JP WLD;DEL     LD A,43:JP WLDESC     LD A,23:JP WLD;HOME    LD A,27:JP WLD;END     LD A,28:JP WLD;F1      LD A,29:JP WLD;F2      LD A,30:JP WLD;F5      LD A,33:JP WLD;F10     LD A,38:JP WLD;ALT     LD A,39:JP WLD;SHIFT   LD A,40:JP WLD;CTRL    LD A,41:JP WLDUSPO    LD A,46:JP WLDNUSP    LD A,47:JP WLD;-------;LOAD512 LD A,48:JP WLD;LOAD256 LD A,60:JP WLD;LOADNON LD A,61:JP WLD;SAVE512 LD A,49:JP WLD;FENTRY  LD A,59:JP WLD;GFILE   LD A,62:JP WLD;MKFILE  LD A,72:JP WLD;DELFL   LD A,75:JP WLD;-------MNGV_PL EXA:LD A,64:JP WLDMNGCVPL EXA:LD A,65:JP WLDMNG0VPL EXA:LD A,80:JP WLDGVmod   EXA:LD A,66:JP WLDGYoff   LD A,67:JP WLDGXoff   LD A,68:JP WLD
;----------------------------------------------ESTA      NOP; Exit StateESCENKEF  NOP; ESC+ENTER Flag (bit 0 = ESC, bit 1 = ENTER)
;---------cmask     db 0,1,3,7,#F,#1F,#3F,#7F,#FF
inctable  db 8,8,4,2,0
startable db 0,4,2,1,0

pixcol    db 1,1,3,7,15,31,63,127,255  ; (0=256) ������⢮ 梥⮢ � ����ᨬ��� �� ���/���ᥫ�
s_x       dw 0    ; sixe of x
s_y       dw 0    ; sixe of y
bitpix    db 0    ; bit �� pyxel
colpix    db 0,0    ; 梥⮢ �� ���ᥫ� - 1 
;back_p db 0    ; 梥⮢ 䮭�
gl_pal    db 0    ; ��� 7 - �᫨ ���� ������쭠� ⠡��� 梥⮢
Pg_Sec    dw 0
;_SI dw 0
        nop
        nop
codendendcode;----------------------------------------------