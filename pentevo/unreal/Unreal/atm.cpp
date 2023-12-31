#include "std.h"
#include "emul.h"
#include "vars.h"
#include "memory.h"
#include "draw.h"

void atm_memswap()
{
   if (!conf.atm.mem_swap) return;
   // swap memory address bits A5-A7 and A8-A10
   for (unsigned start_page = 0; start_page < conf.ramsize*1024; start_page += 2048) {
      u8 buffer[2048], *bank = memory + start_page;
      for (unsigned addr = 0; addr < 2048; addr++)
         buffer[addr] = bank[(addr & 0x1F) + ((addr >> 3) & 0xE0) + ((addr << 3) & 0x700)];
      memcpy(bank, buffer, 2048);
   }
}

void AtmApplySideEffectsWhenChangeVideomode(u8 val)
{
	const int NewVideoMode = (val & 7);
	const int OldVideoMode = (comp.pFF77 & 7);

    // ��������� ����� ������ �����, ������ ��� ����� �������� ���2 ��� �� ��������.
    const unsigned tScanlineWidth = 224;
    const unsigned tScreenWidth = 320/2;
    const unsigned tEachBorderWidth = (tScanlineWidth - tScreenWidth)/2;
    const unsigned iLinesAboveBorder = 56;

    auto iRayLine = cpu.t / tScanlineWidth;
    auto iRayOffset = cpu.t % tScanlineWidth;
/*    
    static int iLastLine = 0;
    if ( iLastLine > iRayLine )
    {
        printf("\nNew Frame Begin\n");
        __debugbreak();
    }
    iLastLine = iRayLine;
    printf("%d->%d %d %d\n", OldVideoMode, NewVideoMode, iRayLine, iRayOffset);
*/

    if (OldVideoMode == 3 || NewVideoMode == 3)
    {
        // ������������ ��/� sinclair ����� �� ����� �������� �������� ��������
        // (�� ������ AlCo ���� ������ ���������)
        for (unsigned y = 0; y < 200; y++)
        {
            AtmVideoCtrl.Scanlines[y+56].VideoMode = NewVideoMode;
            AtmVideoCtrl.Scanlines[y+56].Offset = 0x01C0 + ((y & ~7) << 3);
        }
        return;
    }

    if (OldVideoMode != 6 && NewVideoMode != 6)
    {
        // ��� ���������� ������ ������������ ����� ��������� ������� � ������������ ������������.
        // ���������� ������ ��� �� ��, �� ����� ������������. 
        // �������������, ��� � �������� ��������.
        
        // �������������� ����� ���������� �� �������������� ���������
        if (iRayOffset >= tEachBorderWidth)
            ++iRayLine;

        while (iRayLine < 256)
        {
            AtmVideoCtrl.Scanlines[iRayLine++].VideoMode = NewVideoMode;
        }
//        printf("%d->%d SKIPPED!\n",  OldVideoMode, NewVideoMode);
        return;
    }

    //
    // ������������ � ���������:
    // ����� �������� 312 ���������, �� 224����� (noturbo) � ������.
    //
    //  "������" - ������� 3 ���� ������ �������������� ����������������� (�����) ���������
    //  "�����"  - ������� ����� � �����������, � �������� �������� ����� ���������������
    //             ����� �������� � �������������� +8 ��� +64
    //  "�����"  - ��������� ��������. �� ���� ������ �������� "��������".
    //             ������� �������: 
    //          ������ � ����� �� ������: 56 ���������
    //              ����� � ������ �� ������: 32 ����� (64�������).
    // 
    // +64 ����������, ����� CROW 1->0, �� ����:
    //  ���� � ��������� ��� �������� �� ������ 7 �� ������ 0,
    //  ���� ��� ������������ ��������->������� ��� ������ A5=0,
    //  ���� ��� ������������ �������->�������� ��� ������ A5=1 � ������ 0..3
    //
    // +8 ���������� �� ������ � ����� 64-����� �������� (������ 32�����) ���������� �� ������
    // (�����: +8 �� ���������� ������ A3..A5 � ���������� ������� �������� � �������.)
    //
    // ����� A3..A5 (����������� +8) ����������, ����� RCOL 1->0, �� ����:
    //  ���� � ��������� ��� �������� � ������ �� ������,
    //  ���� �� ������� ��� ������������ �������->��������
    //


    if (iRayLine >= 256)
    {
        return;
    }

    // ������� ������ ������� ��������� (���������� ���������� � ������)
    int Offset = AtmVideoCtrl.Scanlines[iRayLine].Offset;

    // �������� �������� ����������, � ������ ����������� ��� ��������� ������.
    // ����� ���������, ���� ��������� +64 ���������� ��� ������������ �����������:
    //  - ���� ��� �� ������� ������ �� ������ ��� �� ������� ����� �� ������ - �������� ������ ��� ������� ���������
    //  - ���� ��� �� ������ ��� �� ������� ������ �� ������ - �������� ������ ��� ��������� ���������
    bool bRayOnBorder = true;
    if ( iRayLine < iLinesAboveBorder || iRayOffset < tEachBorderWidth )
    {
        // ��� �� �������. ���� ������ �� ������, ���� ����� �� ������.
        // ��� ��������� ��������� � ������� ���������.

        // ���������� ������������ �����������.
        if ( NewVideoMode == 6 )
        {
            // ������������ � ��������� �����.
            if ( (Offset & 32) // < �������� ������� "��� ������ A5=1"
                 && (iRayLine & 7) < 4 // < �������� ������� "� ������ 0..3"
               )
            {
//                printf("CASE-1: 0x%.4x Incremented (+64) on line %d\n", Offset, iRayLine);
                Offset += 64;
                AtmVideoCtrl.Scanlines[iRayLine].Offset = Offset;
            }

            AtmVideoCtrl.Scanlines[iRayLine].VideoMode = NewVideoMode;

            // ����� ������� ���� ����� ������ ������� ��������� � ��������� ������ ����� �������� A3..A5
            Offset &= (~0x38); // ����� A3..A5
//            printf("CASE-1a, reset A3..A5: 0x%.4x\n", Offset);
            
            // ������� ������������ ��� ���������� ���������
            while (++iRayLine < 256)
            {
                if ( 0 == (iRayLine & 7))
                {
                    Offset += 64;
                }
                AtmVideoCtrl.Scanlines[iRayLine].Offset = Offset;
                AtmVideoCtrl.Scanlines[iRayLine].VideoMode = NewVideoMode;
            }
        } else {
            // ������������ �� ���������� ������.
            if ( 0 == (Offset & 32) ) // < �������� ������� "��� ������ A5=0"
            {
//                printf("CASE-2: 0x%.4x Incremented (+64) on line %d\n", Offset, iRayLine);
                Offset += 64;
                AtmVideoCtrl.Scanlines[iRayLine].Offset = Offset;
            }
            AtmVideoCtrl.Scanlines[iRayLine].VideoMode = NewVideoMode;

            // ������� ������������ ��� ���������� ���������
            while (++iRayLine < 256)
            {
                AtmVideoCtrl.Scanlines[iRayLine].Offset = Offset;
                AtmVideoCtrl.Scanlines[iRayLine].VideoMode = NewVideoMode;
            }
        }
    } else {
        // ��� ������ �����, ���� ������ ������ �� ������.

        // ��������� ������� �������� �����������

        // ���������� � ����������� ��� +64 ����������, 
        // ��������� � ���� ��������� ������ ������ ���������
        if (iRayLine == AtmVideoCtrl.CurrentRayLine)
        {
            Offset += AtmVideoCtrl.IncCounter_InRaster;
        } else {
            // ������� ����������� ������� (�.�. �������� �� ��������� �������� �� �������)
            // �������������� ��� ��� ������� ���������.
            AtmVideoCtrl.CurrentRayLine = iRayLine;
            AtmVideoCtrl.IncCounter_InRaster = 0;
            AtmVideoCtrl.IncCounter_InBorder = 0;
        }
        
        // ���������� � ����������� ��� +8 ����������, ������������ ��� ��������� ������
        bool bRayInRaster = iRayOffset < (tScreenWidth + tEachBorderWidth);
        
        int iScanlineRemainder = 0; // < ������� +8 ����������� ��� ����� ������� �� ����� ��������� 
                                    //  (�.�. ��� ����� ������������ �����������)
        if ( bRayInRaster )
        {
            // ��� ������ �����. 
            // ���������� � �������� ����������� ������� +8, 
            // ������� ���� ��������� ������������ 64���������� �����.
            const auto i_inc_value = 8 * ((iRayOffset-tEachBorderWidth)/32);
            iScanlineRemainder = 40 - i_inc_value;
//            printf("CASE-4: 0x%.4x Incremented (+%d) on line %d\n", Offset, iIncValue, iRayLine);
            Offset += i_inc_value;
        } else {
            // ��������� ������ ����� ���������.
            // �.�. ��� 5-��� 64-���������� ����� ���� ��������. ���������� � ������ +40.
//            printf("CASE-5: 0x%.4x Incremented (+40) on line %d\n", Offset, iRayLine);
            Offset += 40;

            // ���� ���������� ������� ��� ��������� �����,
            // �� ��� �������� � ������ �� ������ ������ ���� �������� A3..A5
            if (OldVideoMode == 6)
            {
                Offset &= (~0x38); // ����� A3..A5
//                printf("CASE-5a, reset A3..A5: 0x%.4x\n", Offset);
            }
        }

        // ���������� � ����������� ��� +64 ����������, 
        // ��������� � ���� ��������� ������� �� ������� ������ ���������
        Offset += AtmVideoCtrl.IncCounter_InBorder;

        // ������� �������� ����������� ���������. 
        // ������������ ������������ �����������.
        int OffsetInc = 0;
        if ( NewVideoMode == 6 )
        {
            // ������������ � ��������� �����.
            if ( (Offset & 32) // < �������� ������� "��� ������ A5=1"
                && (iRayLine & 7) < 4 // < �������� ������� "� ������ 0..3"
                )
            {
                OffsetInc = 64;
//                printf("CASE-6: 0x%.4x Incremented (+64) on line %d\n", Offset, iRayLine);
                Offset += OffsetInc;
            }
            // ������� ������������ ��� ���������� ���������
            Offset += iScanlineRemainder;
            while (++iRayLine < 256)
            {
                if ( 0 == (iRayLine & 7))
                    Offset += 64;
                AtmVideoCtrl.Scanlines[iRayLine].Offset = Offset;
                AtmVideoCtrl.Scanlines[iRayLine].VideoMode = NewVideoMode;
            }
        } else {
            // ������������ �� ���������� ������.
            if ( 0 == (Offset & 32) ) // < �������� ������� "��� ������ A5=0"
            {
                OffsetInc = 64;
//                printf("CASE-7: 0x%.4x Incremented (+64) on line %d\n", Offset, iRayLine);
                Offset += OffsetInc;
            }

            // ������� ������������ ��� ���������� ���������
            Offset += iScanlineRemainder;
            while (++iRayLine < 256)
            {
                AtmVideoCtrl.Scanlines[iRayLine].Offset = Offset;
                AtmVideoCtrl.Scanlines[iRayLine].VideoMode = NewVideoMode;
                Offset += 40;
            }
        }

        // ���������� ��������� ��������� �� ������, 
        // ���� �� ����� ��������� � ���� ��������� ������� ���������.
        if ( bRayInRaster )
        {
            AtmVideoCtrl.IncCounter_InRaster += OffsetInc;
        } else {
            AtmVideoCtrl.IncCounter_InBorder += OffsetInc;
        }
    }
}

void set_turbo(void)
{
	if (comp.pFF77 & 8)
		turbo(3);	// 1x = 14MHz (actually effective 11MHz)
	else
	{
		if (comp.pEFF7 & 16)
			turbo(1);	// 01 = 3.5MHz
		else
			turbo(2);	// 00 = 7MHz
	}
}

void set_atm_FF77(unsigned port, u8 val)
{
   if ((comp.pFF77 ^ val) & 1)
       atm_memswap();
   

   if ((comp.pFF77 & 7) ^ (val & 7))
   {
        // ���������� ������������ �����������
        AtmApplySideEffectsWhenChangeVideomode(val);
   }

   comp.pFF77 = val;
   comp.aFF77 = port;
   cpu.int_gate = ((comp.pFF77 & 0x20) != false) || (conf.mem_model==MM_ATM3); // lvd added no INT gate to pentevo (atm3)
   set_banks();
}

void set_atm_aFE(u8 addr)
{
   u8 old_aFE = comp.aFE;
   comp.aFE = addr;
   if ((addr ^ old_aFE) & 0x40) atm_memswap();
   if ((addr ^ old_aFE) & 0x80) set_banks();
}

static u8 atm_pal[0x10] = { 0 };

void atm_writepal(u8 val)
{
   // assert(comp.border_attr < 0x10); // commented (tsl)
   atm_pal[comp.ts.border & 0xF] = val;
   val ^= 0xFF;		// inverted RU2 value
   comp.cram[comp.ts.border] =
	   ((val & 0x02) << 13) |	// R (CLUT bit 14)
	   ((val & 0x40) <<  7) |	// r (CLUT bit 13)
	   ((val & 0x10) <<  5) |	// G (CLUT bit 9)
	   ((val & 0x80) <<  1) |	// g (CLUT bit 8)
	   ((val & 0x01) <<  4) |	// B (CLUT bit 4)
	   ((val & 0x20) >>  2);	// b (CLUT bit 3)
   update_clut(comp.ts.border);
   temp.comp_pal_changed = 1; // check it to remove!
}

u8 atm_readpal()
{
   return atm_pal[comp.ts.border & 0xF];
}

u8 atm450_z(unsigned t)
{
   // PAL hardware gives 3 zeros in secret short time intervals
   if (conf.frame < 80000) { // NORMAL SPEED mode
      if ((unsigned)(t-7200) < 40 || (unsigned)(t-7284) < 40 || (unsigned)(t-7326) < 40) return 0;
   } else { // TURBO mode
      if ((unsigned)(t-21514) < 40 || (unsigned)(t-21703) < 80 || (unsigned)(t-21808) < 40) return 0;
   }
   return 0x80;
}
