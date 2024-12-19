

int latchPin = A2; // Latch pin of 74HC595 is connected to Digital pin 10
int clockPin = A1; // Clock pin of 74HC595 is connected to Digital pin 9
int dataPin = A0; // Data pin of 74HC595 is connected to Digital pin 8


void setup()
{
 // Set all the pins of 74HC595 as OUTPUT
 pinMode(latchPin, OUTPUT);
 pinMode(dataPin, OUTPUT);
 pinMode(clockPin, OUTPUT);
  

}

void updateShiftRegister2(uint8_t pos, uint8_t val)
{
// fix for adre pmod extnder v 1 
digitalWrite(latchPin, LOW);
// To match bit order of pmod led V.1.1
// uint8_t pos_ = pos << 4 | (pos >> 4) & 0b00001111;

shiftOut(dataPin, clockPin, MSBFIRST, pos);

shiftOut(dataPin, clockPin, MSBFIRST, val);

digitalWrite(latchPin, HIGH);

}


void updateShiftRegister(uint8_t val, uint8_t pos)
{

digitalWrite(latchPin, LOW);
// shiftOut(dataPin, clockPin, MSBFIRST, val);
// shiftOut(dataPin, clockPin, MSBFIRST, pos);



digitalWrite(latchPin, HIGH);

}


void place_on_display(uint8_t val, uint8_t pos){
// on 2 modules 8 laces adress 0 - 7 
// uint8_t base = 0b11000000;


updateShiftRegister2(pos, val);

//  if (pos <= 3){
//   base = 0b11100000;
//  }
//  pos = pos << 2; 
//  updateShiftRegister(val << 1, base | pos );
  
  
}

void displayMessage(const char* message) {
    // Ensure the message is 16 characters long.
    char buffer[17] = {0}; // One extra for null terminator
    strncpy(buffer, message, 16); // Copy at most 16 characters

const uint8_t displayCommands[16][3] = {
    {0b11111111, 0b11111011, 0b11111111},
    {0b11111110, 0b11111010, 0b11111110},
    {0b11111101, 0b11111001, 0b11111101},
    {0b11111100, 0b11111000, 0b11111100},
    {0b11111111, 0b11110111, 0b11111111},
    {0b11111110, 0b11110110, 0b11111110},
    {0b11111101, 0b11110101, 0b11111101},
    {0b11111100, 0b11110100, 0b11111100},
    {0b11111111, 0b11101111, 0b11111111},
    {0b11111110, 0b11101110, 0b11111110},
    {0b11111101, 0b11101101, 0b11111101},
    {0b11111100, 0b11101100, 0b11111100},
    {0b11111111, 0b11011111, 0b11111111},
    {0b11111110, 0b11011110, 0b11111110},
    {0b11111101, 0b11011101, 0b11111101},
    {0b11111100, 0b11011100, 0b11111100}
};


    // Iterate over each character and display it on the corresponding position.
    for (uint8_t i = 0; i < 16; ++i) {
        // uint8_t pos = positions[i];
        char val = buffer[i];
        for(uint8_t k = 0; k < 3; ++ k){
          place_on_display(val, displayCommands[i][k]);
        } 
        
    }
}


void print_on_display(const std::string &str){
  // for(uint8_t i = str.length() - 1; i >= 0; -- i){
  //   place_on_display(str[i], 0);
  // }
  // place_on_display('A',  0);
  // place_on_display('B',  1);


// map char position to display module by using int division like // by 4 for is amount of the chars in diplay module 
// offset to represnt xwr signal 
// ignaore first 2 bits 
// last 

// ds modules are from 0 to 3 
//  char 15 map to ds module 3 by 15 // 4 is 3
// position withwin display by resultig 15 - 3 * 4 = 3 bulbde element in dispay module  
// 1
// >>> 15 // 4
// 3
// >>> 13 // 4
// 3
// >>> 15 // 4
// 3
// >>> 14 // 4
// 3
// >>> 13 // 4
// 3
// >>> 12 // 4
// 3
// >>> 11 // 4
// 2





displayMessage("HELLO WORLD !!!!");
delay(800);

  place_on_display('A',  0b11111111);
  place_on_display('A',  0b11111011);
  place_on_display('A',  0b11111111);
  // delay(100);
  place_on_display('2',  0b11111110);
  place_on_display('2',  0b11111010);
  place_on_display('2',  0b11111110);
  // delay(100);
  place_on_display('B',  0b11111101);
  place_on_display('B',  0b11111001);
  place_on_display('B',  0b11111101);
  // delay(100);
  place_on_display('4',  0b11111100);
  place_on_display('4',  0b11111000);
  place_on_display('4',  0b11111100);
  // delay(100);

  place_on_display('5',  0b11111111);
  place_on_display('5',  0b11110111);
  place_on_display('5',  0b11111111);

  place_on_display('6',  0b11111110);
  place_on_display('6',  0b11110110);
  place_on_display('6',  0b11111110); 

  // delay(100);
  place_on_display('7',  0b11111101);
  place_on_display('7',  0b11110101);
  place_on_display('7',  0b11111101);
  // delay(100);

  place_on_display('8',  0b11111100);
  place_on_display('8',  0b11110100);
  place_on_display('8',  0b11111100);
  // delay(100);


  place_on_display('9',  0b11111111);
  place_on_display('9',  0b11101111);
  place_on_display('9',  0b11111111);


  place_on_display('A',  0b11111110);
  place_on_display('A',  0b11101110);
  place_on_display('A',  0b11111110);



  place_on_display('B',  0b11111101);
  place_on_display('B',  0b11101101);
  place_on_display('B',  0b11111101);



  place_on_display('C',  0b11111100);
  place_on_display('C',  0b11101100);
  place_on_display('C',  0b11111100);


  
  place_on_display('D',  0b11111111);
  place_on_display('D',  0b11011111);
  place_on_display('D',  0b11111111);

  place_on_display('E',  0b11111110);
  place_on_display('E',  0b11011110);
  place_on_display('E',  0b11111110);


  place_on_display('F',  0b11111101);
  place_on_display('F',  0b11011101);
  place_on_display('F',  0b11111101);


  place_on_display('G',  0b11111100);
  place_on_display('G',  0b11011100);
  place_on_display('G',  0b11111100);



delay(500);


place_on_display('O',  0b11111111);
  place_on_display('O',  0b11111011);
  place_on_display('O',  0b11111111);
  // delay(100);
  place_on_display('O',  0b11111110);
  place_on_display('O',  0b11111010);
  place_on_display('O',  0b11111110);
  // delay(100);
  place_on_display('P',  0b11111101);
  place_on_display('P',  0b11111001);
  place_on_display('P',  0b11111101);
  // delay(100);
  place_on_display('S',  0b11111100);
  place_on_display('S',  0b11111000);
  place_on_display('S',  0b11111100);
  // delay(100);

  place_on_display('!',  0b11111111);
  place_on_display('!',  0b11110111);
  place_on_display('!',  0b11111111);

  place_on_display(' ',  0b11111110);
  place_on_display(' ',  0b11110110);
  place_on_display(' ',  0b11111110); 

  // delay(100);
  place_on_display('T',  0b11111101);
  place_on_display('T',  0b11110101);
  place_on_display('T',  0b11111101);
  // delay(100);

  place_on_display('R',  0b11111100);
  place_on_display('R',  0b11110100);
  place_on_display('R',  0b11111100);
  // delay(100);


  place_on_display('Y',  0b11111111);
  place_on_display('Y',  0b11101111);
  place_on_display('Y',  0b11111111);


  place_on_display(' ',  0b11111110);
  place_on_display(' ',  0b11101110);
  place_on_display(' ',  0b11111110);



  place_on_display('A',  0b11111101);
  place_on_display('A',  0b11101101);
  place_on_display('A',  0b11111101);



  place_on_display('G',  0b11111100);
  place_on_display('G',  0b11101100);
  place_on_display('G',  0b11111100);


  
  place_on_display('A',  0b11111111);
  place_on_display('A',  0b11011111);
  place_on_display('A',  0b11111111);

  place_on_display('I',  0b11111110);
  place_on_display('I',  0b11011110);
  place_on_display('I',  0b11111110);


  place_on_display('N',  0b11111101);
  place_on_display('N',  0b11011101);
  place_on_display('N',  0b11111101);


  place_on_display('!',  0b11111100);
  place_on_display('!',  0b11011100);
  place_on_display('!',  0b11111100);


delay(500);

  // place_on_display('H',  0b11111101);
  // place_on_display('H',  0b10111101);
  // place_on_display('H',  0b11111101);



  // place_on_display('C',  0b11111100);
  // place_on_display('C',  0b10111100);
  // place_on_display('C',  0b11111100);



  // delay(100);
  // place_on_display('F',  0b11011101);
  // delay(100);
  // place_on_display('G',  0b11011110);
  // delay(100);
  // place_on_display('H',  0b11011111);
  // delay(100);
  // place_on_display('2',  0b11111001);

  // place_on_display('2',  0b11111001);



  // place_on_display('2',  0b01011111);
  // delay(1);
  // place_on_display('2',  0b01011111);


  // place_on_display('3',  0b01111111);
  // delay(1);
  // place_on_display('3',  0b01011111);

  // place_on_display('4',  0b00111111);
  // delay(1);
  // place_on_display('4',  0b00011111);

  // place_on_display('C',  0b10011111);
  // place_on_display('C',  0b11011111);
    //  for(int i =  str.length() -1 ; i >= 0; -- i){
    //   place_on_display(str[i],  str.length() -1 - i); 
    //  }

}

// Function to rotate the string and display it
void rotate_string_and_display(const std::string &str, int delay_ms) {
    std::string rotated_str = str;
    int cy =0;
    // Run indefinitely
    while (cy < 85) {
        for (size_t i = 0; i < rotated_str.length(); ++i) {
            // Create a circular substring by appending the first characters at the end
            std::string display_str = rotated_str.substr(i, 8);
            if (display_str.length() < 8) {
                display_str += rotated_str.substr(0, 8 - display_str.length());
            }

            // Print the display substring
            print_on_display(display_str);
            delay(delay_ms);
            cy = cy + 1; 
        }
    }
}

std::string jokes[] = {
    "I TOLD MY WIFE SHE WAS DRAWING HER EYEBROWS TOO HIGH. SHE LOOKED SURPRISED.  ",
    "WHY DON’T SKELETONS FIGHT EACH OTHER? THEY DON’T HAVE THE GUTS.",
    "I WOULD AVOID THE SUSHI IF I WAS YOU. IT’S A LITTLE FISHY.",
    "WHAT’S ORANGE AND SOUNDS LIKE A PARROT? A CARROT.",
    "I ONLY KNOW 25 LETTERS OF THE ALPHABET. I DON’T KNOW Y.",
    "WHY DID THE SCARECROW WIN AN AWARD? BECAUSE HE WAS OUT-STANDING IN HIS FIELD.",
    "I USED TO BE IN SHAPE. THEN I CHOSE ROUND.",
    "WHY CAN'T YOU GIVE Elsa A BALLOON? BECAUSE SHE WILL LET IT GO.",
    "WHAT DO YOU CALL FAKE SPAGHETTI? AN IMPASTA.",
    "I'M READING A BOOK ON ANTI-GRAVITY. IT'S IMPOSSIBLE TO PUT DOWN!",
    "WHY DID THE GOLFER BRING TWO PAIRS OF PANTS? IN CASE HE GOT A HOLE IN ONE.",
    "WHAT DO YOU CALL A BEAR WITH NO TEETH? A GUMMY BEAR.",
    "I TOLD MY COMPUTER I NEEDED A BREAK, AND NOW IT WON'T STOP SENDING ME BEACH PICTURES.",
    "WHY DID THE CHMISTRY TEACHER BREAK UP WITH THE BIOLOGY TEACHER? THERE WAS NO CHEMISTRY."
};

// X X WR1 WR2 
void loop() {
//  state_1();
// delay(500);
// print_on_display("PLAYTHIS");

// delay(500);
// print_on_display("12345678");

  
    // int jokeIndex = random(0, sizeof(jokes) / sizeof(jokes[0]));
    // rotate_string_and_display(jokes[jokeIndex], 150);

      for (const std::string& joke : jokes) {
        rotate_string_and_display(joke, 120);
      }



}











