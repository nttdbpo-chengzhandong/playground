package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	fmt.Printf("%s\n", "aaaa")

	res, err := http.Get("https://www.google.co.jp")
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("%d\n", res.StatusCode)
}
