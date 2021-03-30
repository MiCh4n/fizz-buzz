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