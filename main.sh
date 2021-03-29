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
