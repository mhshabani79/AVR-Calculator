
#pragma used+
sfrb TWBR=0;
sfrb TWSR=1;
sfrb TWAR=2;
sfrb TWDR=3;
sfrb ADCL=4;
sfrb ADCH=5;
sfrw ADCW=4;      
sfrb ADCSRA=6;
sfrb ADCSR=6;     
sfrb ADMUX=7;
sfrb ACSR=8;
sfrb UBRRL=9;
sfrb UCSRB=0xa;
sfrb UCSRA=0xb;
sfrb UDR=0xc;
sfrb SPCR=0xd;
sfrb SPSR=0xe;
sfrb SPDR=0xf;
sfrb PIND=0x10;
sfrb DDRD=0x11;
sfrb PORTD=0x12;
sfrb PINC=0x13;
sfrb DDRC=0x14;
sfrb PORTC=0x15;
sfrb PINB=0x16;
sfrb DDRB=0x17;
sfrb PORTB=0x18;
sfrb PINA=0x19;
sfrb DDRA=0x1a;
sfrb PORTA=0x1b;
sfrb EECR=0x1c;
sfrb EEDR=0x1d;
sfrb EEARL=0x1e;
sfrb EEARH=0x1f;
sfrw EEAR=0x1e;   
sfrb UBRRH=0x20;
sfrb UCSRC=0X20;
sfrb WDTCR=0x21;
sfrb ASSR=0x22;
sfrb OCR2=0x23;
sfrb TCNT2=0x24;
sfrb TCCR2=0x25;
sfrb ICR1L=0x26;
sfrb ICR1H=0x27;
sfrb OCR1BL=0x28;
sfrb OCR1BH=0x29;
sfrw OCR1B=0x28;  
sfrb OCR1AL=0x2a;
sfrb OCR1AH=0x2b;
sfrw OCR1A=0x2a;  
sfrb TCNT1L=0x2c;
sfrb TCNT1H=0x2d;
sfrw TCNT1=0x2c;  
sfrb TCCR1B=0x2e;
sfrb TCCR1A=0x2f;
sfrb SFIOR=0x30;
sfrb OSCCAL=0x31;
sfrb TCNT0=0x32;
sfrb TCCR0=0x33;
sfrb MCUCSR=0x34;
sfrb MCUCR=0x35;
sfrb TWCR=0x36;
sfrb SPMCR=0x37;
sfrb TIFR=0x38;
sfrb TIMSK=0x39;
sfrb GIFR=0x3a;
sfrb GICR=0x3b;
sfrb OCR0=0X3c;
sfrb SPL=0x3d;
sfrb SPH=0x3e;
sfrb SREG=0x3f;
#pragma used-

#asm
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x80
	.EQU __sm_mask=0x70
	.EQU __sm_powerdown=0x20
	.EQU __sm_powersave=0x30
	.EQU __sm_standby=0x60
	.EQU __sm_ext_standby=0x70
	.EQU __sm_adc_noise_red=0x10
	.SET power_ctrl_reg=mcucr
	#endif
#endasm

void _lcd_write_data(unsigned char data);

unsigned char lcd_read_byte(unsigned char addr);

void lcd_write_byte(unsigned char addr, unsigned char data);

void lcd_gotoxy(unsigned char x, unsigned char y);

void lcd_clear(void);
void lcd_putchar(char c);

void lcd_puts(char *str);

void lcd_putsf(char flash *str);

void lcd_putse(char eeprom *str);

void lcd_init(unsigned char lcd_columns);

#pragma library alcd.lib

#pragma used+

void delay_us(unsigned int n);
void delay_ms(unsigned int n);

#pragma used-

typedef char *va_list;

#pragma used+

char getchar(void);
void putchar(char c);
void puts(char *str);
void putsf(char flash *str);
int printf(char flash *fmtstr,...);
int sprintf(char *str, char flash *fmtstr,...);
int vprintf(char flash * fmtstr, va_list argptr);
int vsprintf(char *str, char flash * fmtstr, va_list argptr);

char *gets(char *str,unsigned int len);
int snprintf(char *str, unsigned int size, char flash *fmtstr,...);
int vsnprintf(char *str, unsigned int size, char flash * fmtstr, va_list argptr);

int scanf(char flash *fmtstr,...);
int sscanf(char *str, char flash *fmtstr,...);

#pragma used-

#pragma library stdio.lib

void calc(void);

char alpha[] = {'7', '8', '9', '/', '4', '5', '6', '*', '1', '2', '3', '-', 'C', '0', '=', '+', ''};
char number_string[32] = {'\0'};
int number1=0, number2=0;
int column=0,key=13, temp;
char last_operation = ' ';
interrupt [2] void KEY_PRESS(void)
{   
PORTC=0X00;
delay_ms(1);   

for(column=1,temp=1;column<=4;temp*=2,column++)
{  
PORTA&=0XF0;  
PORTA|=temp;  
switch(PINC&0X0F) 
{
case 0X01:{              
key=column;
}break;
case 0X02:{                
key=4+column;
}break;
case 0X04:{                
key=8+column;
}break;
case 0X08:{                 
key=12+column;
}break;
}
do{}while((PINC&0X0F)!=0);  
} 

PORTA|=0X0F;    
key = key-1;

switch(alpha[key])
{
case '*':
{
calc();
last_operation = '*';
lcd_putchar('*');          
break;
}
case '+':
{
calc();
last_operation = '+';
lcd_putchar('+'); 
break;
}
case '-':
{
calc();
last_operation = '-';
lcd_putchar('-');     
break;
}
case '/':
{
calc();
last_operation = '/';
lcd_putchar('/');         
break;
}
case 'C':
{
lcd_clear();  
lcd_gotoxy(0, 0);         
number1 = 0;
number2 = 0;
last_operation = ' ';
break;
}
case '=':
{
lcd_clear();  
lcd_gotoxy(0, 0);  
calc();
sprintf(number_string, "%d", number2);
number1 = number2;
number2=0;
lcd_puts(number_string);
last_operation = ' ';
break;
}
default:
{
number1 = number1*10 + alpha[key] -48;
lcd_putchar(alpha[key]);
break;
}
}
}

void main()
{
DDRB=0XFF;
DDRC=0X00;
DDRA=0XFF;
PORTA=0XFF;          
DDRD=0X00;  

lcd_init(16);  

GICR=(1<<6       );                       
SREG|=0X80;
MCUCR=0X03;

while(1)
{
}
}

void calc(void)
{
switch(last_operation)
{
case '+':
{
number2 = number2 + number1; 
number1 = 0;
break;
}
case '-':
{
number2 = number2 - number1; 
number1 = 0;
break;
}  
case '*':
{
number2 = number2 * number1; 
number1 = 0;
break;
}
case '/':
{
if(number1 == 0)
{
lcd_clear();
lcd_gotoxy(0, 0);
lcd_puts("Divide By Zero!");
delay_ms(1500);
lcd_clear();
lcd_gotoxy(0, 0);
number1 = 0;
number2 = 0;
last_operation = ' ';
break;
}
number2 = number2 / number1; 
number1 = 0;
break;
}
case ' ':
{
number2 = number1;
number1 = 0;
break;
}     
}
}

