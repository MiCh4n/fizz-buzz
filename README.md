# My fizz-buzzes
* [Python](https://github.com/MiCh4n/fizz-buzz/blob/main/main.py)
    ```
    i = 1
    while i <= 100:
        if i % 15 == 0:
            print(str(i)+" FizzBuzz!")
        elif i % 3 == 0:
            print(str(i)+" Fizz!")
        elif i % 5 == 0:
            print(str(i)+" Buzz!")
        i += 1
    ```
* [Go](https://github.com/MiCh4n/fizz-buzz/blob/main/main.go)
    ```
    package main

    import(
            "fmt"
    )
    func fizzbuzz(x int){
        if x % 15 == 0 {
            fmt.Println(x, "FizzBuzz!")
        } else if x % 3 == 0 {
            fmt.Println(x, "Fizz!")
        } else if x % 5 == 0 {
            fmt.Println(x, "Buzz!")
        }
    }
    func main(){
        for i := 1; i <= 100; i++ {
            fizzbuzz(i)
        }
    }
    ```
    
    * [Bash](https://github.com/MiCh4n/fizz-buzz/blob/main/main.sh)
    
    ```
    #!/usr/bin/env bash
    for i in {1..100}
    do
        if ! ((i % 5)); then
                printf "$i Fizz!\n"
        fi

        if ! ((i % 3)); then
                printf "$i Buzz!\n"
        fi

        if ! ((i % 15)); then
                printf "$i FizzBuzz!\n"
        fi
    done
    ```
