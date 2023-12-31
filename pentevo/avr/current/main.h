#ifndef __MAIN_H__
#define __MAIN_H__

/**
 * @mainpage  General program for ATMEGA128 ZX Evolution.
 *
 * @section history Revision history
 *
 * @subsection current Current version.
 *
 * - Add any (left or right) Ctrl,Alt keys and exclude mapped Ctrl,Alt keys from Ctrl-Alt-Del functionality (reset).
 * - Add reading state of LWIN,RWIN,MENU keyboard states from RTC register E (bits 0-2)
 * - Add reading state of LCTRL,RCTRL,LALT,RALT,LSHIFT,RSHIFT,F12 keyboard states from RTC register D (bits 0-6).
 * - Add reading state of NUM LOCK LED from RTC register C (bit 0).
 * - Add EEPROM access via RTC interface.
 * - Add reset PS2 keyboard after error. 
 * - Fix change resolution command (need for some PS2 mouses).
 *
 * @subsection ver_2014_04_13 Version 13.04.2014.
 * 
 * - Fix access to users keyboard map.
 *
 * @subsection ver_2013_11_08 Version 08.11.2013.
 *
 * - Add mode 60Hz;
 * - Fix RS232 (clear overrun error flag).
 *
 * @subsection ver_2012_02_13 Version 13.02.2011.
 *
 * - Add SD WRP and SD DET to C gluk's register.
 * - Fix PS2 keyboard hangup.
 * - Add some controls to C gluk's register.
 * - Add access to PS2 keyboards log via gluk extensions.
 *
 * @subsection ver_2011_09_29 Version 29.09.2011.
 *
 *  - Add support BCD or HEX format in emulation Gluk clock.
 *  - Fix RTS line control.
 *
 * @subsection ver_2011_06_11 Version 11.06.2011.
 *
 *  - Add NMI button supporting.
 *  - Fix PS/2 mouse initialization.
 *
 * @subsection ver_2011_05_11 Version 11.05.2011
 *
 * - Direct load UBRR on RS232 mode [if (DLM & 0x80)!=0 ].
 * - Control PLL (ICS501M) via PE2,PE3. Set it to 2X.
 *
 * @subsection ver_2011_04_26 Version 26.04.2011
 *
 * - Add RS232 supporting.
 * - Increase delay for reset FPGA (nCONFIG pin) before download it.
 *
 * @subsection ver_2011_04_02 Version 02.04.2011
 *
 * - Add access to 0..EF cells of PC8583.
 * - Fix RTC PC8583 dayweek 0..6 convert to DS12788 dayweek 1..7 and vice versa.
 *
 * @subsection ver_2010_12_07 Version 07.12.2010
 *
 * - Keyboard mapping without using RAM.
 * - Add setting resolution for PS/2 mouse [1..4].
 *   (left and right mouse buttons and pad'*' - default [1], pad'+' - increment, pad'-' - decrement).
 * - Add PS/2 mouse resolution saving to RTC register.
 *
 * @subsection ver_2010_11_29 Version 29.11.2010
 *
 * - "NumLock" switch mode to beeper/pwm or tapeout ("NumLock" led light on tapeout mode).
 * - Create full translation map (0x00-0x7f for extended scan codes).
 *
 * @subsection ver_2010_10_17 Version 17.10.2010
 *
 * - "F9","F10","F11" on PS/2 keyboard not used for reset function.
 * - "F12" on PS/2 keyboard soft/hard reset. Short press (<5sec) - soft reset, long press (5sec) - hard reset.
 * - "Ctrl-Alt-Del" on PS/2 keyboard reset ZX (hard reset). If all keys is mapped to ZX keyboard - function not work.
 * - Create translation map (PS/2 to ZX keyboard) in eeprom (default in progmem).
 * - Fix PS/2 mouse and keyboard send mode (without 'delay' function).
 * - Support load from tape input.
 *
 * @subsection ver_2010_03_30 Version 30.03.2010
 *
 * - Fix fpga load and ZX part init (optimize).
 *
 * @subsection ver_2010_03_28 Version 28.03.2010
 *
 * - Fix PS/2 mouse error handler (analize error and reinit mouse if need it).
 * - Add support for get version info (via Gluk cmos extra registers 0xF0..0xFF).
 * - Optimize sources, some correction (log, fpga load).
 * - Fix PS/2 timeout error handler.
 *
 * @subsection ver_2010_03_24 Version 24.03.2010
 *
 * - Fix Power Led behavior (it off while atx power off).
 * - "Print Screen" PS2 keyboard key set NMI on ZX.
 * - Soft reset (Z80 only) to service (0) page if pressed "softreset" key <5 seconds.
 *
 * @subsection ver_2010_03_10 Version 10.03.2010
 *
 * - Add PS2 keyboard led controlling: "Scroll Lock" led equal VGA mode.
 * - Fix mapping gluk (DS12887) nvram to PCF8583.
 * - Fix Update Flag in register C (emulation Gluk clock).
 * - Add modes register and save/restore it to RTC NVRAM.
 * - Add support for zx (mechanical) keyboard.
 * - Add support for Kempston joystick.
 *
 * @subsection ver_2010_02_04 Version 04.02.2010 - base version (1.00 in SVN).
 *
 */

/**
 * @file
 * @brief Main module.
 * @author http://www.nedopc.com
 */

/** Wait port interrupt flag register. */
extern volatile u8 wait_irq_flag;

/** Common flag register. */
extern volatile u8 flags_register;
/** Direction for ps2 mouse data (0 - Receive/1 - Send). */
#define FLAG_PS2MOUSE_DIRECTION 0x01
/** Type of ps2 mouse (0 - classical [3bytes in packet]/1 - msoft [4bytes in packet]). */
#define FLAG_PS2MOUSE_TYPE      0x02
/** Last tape in bit value. */
#define FLAG_LAST_TAPE_VALUE    0x04
/** Direction for ps2 keyboard data (0 - Receive/1 - Send). */
#define FLAG_PS2KEYBOARD_DIRECTION  0x10
/** SysTick event. */
#define FLAG_SYSTICK_INT        0x20
/** Ps2 mouse data for zx (0 - not ready/1 - ready). */
#define FLAG_PS2MOUSE_ZX_READY  0x40
/** Hard reset flag (1 - enable hard reset). */
#define FLAG_HARD_RESET         0x80

/** Common extension flag register. */
extern volatile u8 flags_ex_register;
/** Ps2 mouse command (0 - not/1 - process). */
#define FLAG_EX_PS2MOUSE_CMD    0x01
/** NMI interrupt set (0 - not/1 - set). */
#define FLAG_EX_NMI             0x02
/** Ps2 keyboard map (0 - default/1 - user). */
#define FLAG_EX_PS2KEYBOARD_MAP 0x04
/** Flash from SD card (1 - enable flash) */
#define FLAG_EX_FLASH           0x08
/** Disable 40-pin keyboard (1 - disable) */
#define FLAG_EX_DISABLE_40PIN_KEYBOARD  0x10

/** Common modes register. */
extern volatile u8 modes_register;
/** VGA mode (0 - not set/1 - set). */
#define MODE_VGA          0x01
/** CAPS LED mode (0 - off/1 - on). */
#define MODE_CAPSLED      0x04
/** Tapeout mode (0 - beeper or pwm mode/1 - tapeout). */
#define MODE_TAPEOUT      0x08
/** 60Hz mode (0 - 320 lines / 1 - 262 lines). */
#define MODE_TS_60HZ         0x10
/** Interrupt from wait ports. */
#define MODE_TS_WTP_INT      0x20
/** Floppy swap (0 - normal, 1 - A/C swapped with B/D. */
#define MODE_TS_FSWAP        0x40
/** Tape In sound (0 - off, 1 - on. */
#define MODE_TS_TAPEIN       0x80

/** pentagon/60Hz/48k/128k modes - BaseConf */
#define MODES_BASE_RASTER 0x30
#define MODE_BASE_VIDEO_MASK (MODE_VGA | MODES_BASE_RASTER)

/** Type extensions of gluk registers. */
extern volatile u8 ext_type_gluk;
/** Type is baseconfiguration version. */
#define EXT_TYPE_BASECONF_VERSION     0x00
/** Type is bootloader version. */
#define EXT_TYPE_BOOTLOADER_VERSION   0x01
/** Type is PS2 keyboards log. */
#define EXT_TYPE_PS2KEYBOARDS_LOG     0x02
/** Type is reading some config bytes. */
#define EXT_TYPE_RDCFG                0x03
/** Type is Configuration Interface. */
#define EXT_TYPE_CFGIF                0x0E
/** Type is SPI Flash Interface. */
#define EXT_TYPE_SPIFL                0x10

/** Data buffer. */
extern u8 dbuf[];

/** FPGA data index. */
extern volatile u32 curFpga;

/**
 * Writes specified length of buffer to SPI.
 * @param size [in] - size of buffer.
 */
void put_buffer(u16 size);

#endif //__MAIN_H__
