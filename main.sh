#!/usr/bin/env bash
for i in {1..100}
do
        if ! ((i % 5)); then
                printf "%s Fizz!\\n" "$i"
        fi

        if ! ((i % 3)); then
                printf "%s Buzz!\\n" "$i"
        fi

        if ! ((i % 15)); then
                printf "%s FizzBuzz!\\n" "$i"
        fi
done
