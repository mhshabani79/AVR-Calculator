#include <mega32.h>
#include <alcd.h>
#include <delay.h>
#include <stdio.h>

void calc(void);

char alpha[] = {'7', '8', '9', '/', '4', '5', '6', '*', '1', '2', '3', '-', 'C', '0', '=', '+', ''};
char number_string[32] = {'\0'};
int number1=0, number2=0;
int column=0,key=13, temp;
char last_operation = ' ';
interrupt [EXT_INT0] void KEY_PRESS(void)
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

    GICR=(1<<INT0);                       
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


