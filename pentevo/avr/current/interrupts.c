#include <stdio.h>
#include <avr/io.h>
#include <avr/interrupt.h>

#include <util/delay.h>

#include "mytypes.h"
#include "pins.h"
#include "main.h"
#include "ps2.h"
#include "rs232.h"
#include "zx.h"
#include "spi.h"
#include "atx.h"
#include "rtc.h"
#include "joystick.h"

volatile u8 wait_irq_flag;

// PS/2 Timeouts INT
ISR(TIMER2_OVF_vect)
{
	static s8 scankbd=0;
	static s8 cskey=0xff;

		OCR2 = 0xff;	// the intesity of PWR LED, could be changed if need
		// OCR2 = (PINE & _BV(6)) ? 0: 0xff; // to monitor SPIINT

	// PS/2 keyboard timeout tracking
	if ((ps2keyboard_count<12) && (ps2keyboard_count!=0))
	{
		if (((flags_register & FLAG_PS2KEYBOARD_DIRECTION)!=0) && (ps2keyboard_count==11) && (ps2keyboard_timeout<PS2KEYBOARD_TIMEOUT))
		{
			//release clock after first programmed interrupt
		 	PS2KBCLK_PORT |= (1<<PS2KBCLK);  //release ps2keyboard clk pin
		 	PS2KBCLK_DDR &= ~(1<<PS2KBCLK);
		}
		if (ps2keyboard_timeout) ps2keyboard_timeout--;
	}

	// pause for keyboard CS|SS
	if (shift_pause)
		shift_pause--;

	// PS/2 mouse timeout tracking
	if ((ps2mouse_count<12) && (ps2mouse_count!=0))
	{
		if (((flags_register & FLAG_PS2MOUSE_DIRECTION)!=0) && (ps2mouse_count==11) && (ps2mouse_timeout<PS2MOUSE_TIMEOUT))
		{
			//release clock after first programmed interrupt
		 	PS2MSCLK_PORT |= (1<<PS2MSCLK);  //release ps2mouse clk pin
		 	PS2MSCLK_DDR &= ~(1<<PS2MSCLK);
		}
		if (ps2mouse_timeout) ps2mouse_timeout--;
	}

	//check soft reset and F12 key
	if (!(SOFTRES_PIN & (1<<SOFTRES)) || kb_ctrl_status.f12)
	{
		//pressed
		atx_counter++;
	}
	else
	{
		//not pressed
		atx_counter = 0;
	}

    // poll 40-pin keyboard if enabled
    if ((flags_ex_register & FLAG_EX_DISABLE_40PIN_KEYBOARD) == 0) {
        u8 kbd_in = PINA;

        if ( scankbd==0 )
        {
            u8 tmp;
            tmp = kbd_in;
            zx_realkbd[5] = tmp & cskey;
            cskey = tmp | 0xfe;
            DDRC  = 0b00010000;
            PORTC = 0b11001111;
            zx_realkbd[10] = 4;
            scankbd=4;
        }
        else if ( scankbd==1 )
        {
            zx_realkbd[6] = kbd_in;
            DDRC  = 0b00000001;
            PORTC = 0b11011110;
            scankbd=0;
        }
        else if ( scankbd==2 )
        {
            zx_realkbd[7] = kbd_in;
            DDRC  = 0b00000010;
            PORTC = 0b11011101;
            scankbd=1;
        }
        else if ( scankbd==3 )
        {
            zx_realkbd[8] = kbd_in;
            DDRC  = 0b00000100;
            PORTC = 0b11011011;
            scankbd=2;
        }
        else if ( scankbd==4 )
        {
            zx_realkbd[9] = kbd_in;
            DDRC  = 0b00001000;
            PORTC = 0b11010111;
            scankbd=3;
        }
    }

    // pause for autofire
    if (joystick_autofire_delay)
        joystick_autofire_delay--;

	joystick_poll();
}

// receive/send PS/2 keyboard data
ISR(INT4_vect)
{
	if ((flags_register & FLAG_PS2KEYBOARD_DIRECTION) != 0)
	{
		//send mode
		if (--ps2keyboard_count)
		{
			if (ps2keyboard_shifter & 1) PS2KBDAT_PORT |= (1<<PS2KBDAT);
			else PS2KBDAT_PORT &= ~(1<<PS2KBDAT);

			ps2keyboard_shifter >>= 1;

			if (ps2keyboard_count == 11)
			{
				//first interrupt is programmed
				PS2KBDAT_DDR |= (1<<PS2KBDAT);	 //ps2keyboard data pin to output mode
				//_delay_us(250);  //hold ps2keyboard clk pin ~250us
				//PS2KBCLK_PORT |= (1<<PS2KBCLK);  //release ps2keyboard clk pin
				//PS2KBCLK_DDR &= ~(1<<PS2KBCLK);
			}
			else if (ps2keyboard_count == 1)
			{
				PS2KBDAT_DDR &= ~(1<<PS2KBDAT); //ps2keyboard data pin to input mode
			}
		}
		else
		{
			//ack received
			PS2KBCLK_PORT &= ~(1<<PS2KBCLK);
			PS2KBCLK_DDR  |= (1<<PS2KBCLK);
		}
	}
	else
	{
		//receive mode
		ps2keyboard_shifter >>= 1;
		if ((PS2KBDAT_PIN & (1<<PS2KBDAT))) ps2keyboard_shifter |= 0x8000;

		if ((--ps2keyboard_count) == 1)
		{
			PS2KBCLK_PORT &= ~(1<<PS2KBCLK);
			PS2KBCLK_DDR  |= (1<<PS2KBCLK);
			ps2keyboard_count = 0;
		}
	}

	EIFR = (1<<INTF4);

	//set timeout
	ps2keyboard_timeout = PS2KEYBOARD_TIMEOUT;
}

// receive/send PS/2 mouse data
ISR(INT5_vect)
{
	if ((flags_register & FLAG_PS2MOUSE_DIRECTION) != 0)
	{
		//send mode
		if (--ps2mouse_count)
		{
			if (ps2mouse_shifter & 1) PS2MSDAT_PORT |= (1<<PS2MSDAT);
			else PS2MSDAT_PORT &= ~(1<<PS2MSDAT);

			ps2mouse_shifter >>= 1;

			if (ps2mouse_count == 11)
			{
				//first interrupt is programmed
				//must hold pin >250us
				PS2MSDAT_DDR |= (1<<PS2MSDAT);	 //ps2mouse data pin to output mode
				//_delay_us(250);  //hold ps2mouse clk pin ~250us
				//PS2MSCLK_PORT |= (1<<PS2MSCLK);  //release ps2mouse clk pin
				//PS2MSCLK_DDR &= ~(1<<PS2MSCLK);
			}
			else if (ps2mouse_count == 1)
			{
				PS2MSDAT_DDR &= ~(1<<PS2MSDAT); //ps2mouse data pin to input mode
			}
		}
		else
		{
			//ack received
			PS2MSCLK_PORT &= ~(1<<PS2MSCLK);
			PS2MSCLK_DDR  |= (1<<PS2MSCLK);
		}
	}
	else
	{
		//receive mode
		ps2mouse_shifter >>= 1;
		if ((PS2MSDAT_PIN & (1<<PS2MSDAT))) ps2mouse_shifter |= 0x8000;

		if ((--ps2mouse_count) == 1)
		{
			PS2MSCLK_PORT &= ~(1<<PS2MSCLK);
			PS2MSCLK_DDR  |= (1<<PS2MSCLK);
			ps2mouse_count = 0;
		}
	}

	EIFR = (1<<INTF5);

	//set timeout
	ps2mouse_timeout = PS2MOUSE_TIMEOUT;
}

 // SPI_INT
ISR(INT6_vect)
{
	wait_irq_flag = 1;
	EIFR = (1<<INTF6);
}

// SysTick INT
ISR(TIMER1_COMPA_vect)
{
	u8 t;
  
  // flags_register |= FLAG_SYSTICK_INT;
  
  t = rs_tmo_cnt;
  if (t < 255)
    rs_tmo_cnt = t + 1;
  
  t = zf_tmo_cnt;
  if (t < 255)
    zf_tmo_cnt = t + 1;;
}

 // RTC up data
ISR(INT7_vect)
{
	gluk_inc();
	EIFR = (1<<INTF7);
}

