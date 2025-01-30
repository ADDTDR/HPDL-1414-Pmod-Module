message = "ICEBRKR+PMOD14140"



with open('data', 'w+') as data_file:
    for letter in message.upper():
        print(hex(ord(letter)))
        data_file.write(hex(ord(letter)) + '\n') 
    data_file.close()