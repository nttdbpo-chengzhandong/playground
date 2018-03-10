package main

import (
	"fmt"
)

func Sqrt(x float64) float64 {
	var z1 float64 = x
	var z2 float64
	for i := 0; i < 10; i++ {
		z2 = z1 - ((z1*z1 - x) / (2 * z1))
		z1 = z2
	}
	return z1
}

func main() {
	fmt.Println(Sqrt(2))
}
