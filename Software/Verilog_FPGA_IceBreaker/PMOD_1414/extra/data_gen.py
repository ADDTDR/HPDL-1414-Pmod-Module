message = "TINY TAPEOUT 10!"


print('Message length', len(message))
print(message)

with open('data', 'w+') as data_file:
    for letter in message.upper():
        print(hex(ord(letter)))
        data_file.write(hex(ord(letter)) + '\n') 
    data_file.close()