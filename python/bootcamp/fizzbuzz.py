def fizzbuzz(num):
    buf = ''
    if num % 3 == 0:
        buf += 'Fizz'

    if num % 5 == 0:
        buf += 'Buzz'

    if buf == '':
        return str(num)
    else:
        return buf

for num in range(1, 101):
    print(fizzbuzz(num))

# for num in '𩸽定食':
#     print(num)
