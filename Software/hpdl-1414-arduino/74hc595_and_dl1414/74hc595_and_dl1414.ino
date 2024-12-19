#include <Arduino.h>


int latchPin = A2; // Latch pin of 74HC595 is connected to Digital pin 10
int clockPin = A1; // Clock pin of 74HC595 is connected to Digital pin 9
int dataPin = A0; // Data pin of 74HC595 is connected to Digital pin 8


void setup()
{
 // Set all the pins for  74HC595 as OUTPUT
 pinMode(latchPin, OUTPUT);
 pinMode(dataPin, OUTPUT);
 pinMode(clockPin, OUTPUT);

}

void updateShiftRegister2(uint8_t pos, uint8_t val)
{
// fix for adre pmod extnder v 1 
digitalWrite(latchPin, LOW);
shiftOut(dataPin, clockPin, MSBFIRST, pos);
shiftOut(dataPin, clockPin, MSBFIRST, val);
digitalWrite(latchPin, HIGH);

}


void place_on_display(uint8_t val, uint8_t pos){
updateShiftRegister2(pos, val);
}

void displayMessage(const char* message) {

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
 displayMessage("HELLO WORLD !!!!");
}



std::string jokes[] = {
    "I TOLD MY WIFE SHE WAS DRAWING HER EYEBROWS TOO HIGH. SHE LOOKED SURPRISED.  ",
    "WHY DON’T SKELETONS FIGHT EACH OTHER? THEY DON’T HAVE THE GUTS.",
    "I WOULD AVOID THE SUSHI IF I WAS YOU. IT’S A LITTLE FISHY.",
    "WHAT’S ORANGE AND SOUNDS LIKE A PARROT? A CARROT.",
    "I ONLY KNOW 25 LETTERS OF THE ALPHABET. I DON’T KNOW Y.",
    "WHY DID THE SCARECROW WIN AN AWARD? BECAUSE HE WAS OUT-STANDING IN HIS FIELD.",
    "I USED TO BE IN SHAPE. THEN I CHOSE ROUND.",
    "WHY CAN'T YOU GIVE ELSA A BALLOON? BECAUSE SHE WILL LET IT GO.",
    "WHAT DO YOU CALL FAKE SPAGHETTI? AN IMPASTA.",
    "I'M READING A BOOK ON ANTI-GRAVITY. IT'S IMPOSSIBLE TO PUT DOWN!",
    "WHY DID THE GOLFER BRING TWO PAIRS OF PANTS? IN CASE HE GOT A HOLE IN ONE.",
    "WHAT DO YOU CALL A BEAR WITH NO TEETH? A GUMMY BEAR.",
    "I TOLD MY COMPUTER I NEEDED A BREAK, AND NOW IT WON'T STOP SENDING ME BEACH PICTURES.",
    "WHY DID THE CHMISTRY TEACHER BREAK UP WITH THE BIOLOGY TEACHER? THERE WAS NO CHEMISTRY."
};

const int numJokes = sizeof(jokes) / sizeof(jokes[0]);
int currentJokeIndex = 0;
int rotationCount = 0;

void rotateAndDisplayJokes() {
    std::string currentJoke = jokes[currentJokeIndex] + " "; // Add a space for rotation
    int jokeLength = currentJoke.length();
    
    // Display the joke twice in a rotating manner
    for (int round = 0; round < 2; ++round) {
        for (int i = 0; i < jokeLength; ++i) {
            std::string visible = currentJoke.substr(i) + currentJoke.substr(0, i);
            displayMessage(visible.c_str()); // Convert to const char*
            delay(150); // Adjust for desired scroll speed
        }
    }
    displayMessage("                ");

    // Move to the next joke or reset if we've displayed all
    currentJokeIndex = (currentJokeIndex + 1) % numJokes;
    rotationCount++;
}


void loop() {

  rotateAndDisplayJokes();
  delay(886);


}











