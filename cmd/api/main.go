package main

import (
	"log"
	"net/http"
)

func main() {
	log.Println("API hearing in :8080")
	log.Fatal(http.ListenAndServe(":8080", newRouter()))
}
