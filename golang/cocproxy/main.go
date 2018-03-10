package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
)

// proxyHandler ...
func proxyHandler(w http.ResponseWriter, req *http.Request) {

	u := req.URL
	path := u.Path[1:]

	fmt.Printf("%s\n", path)
	_, err := os.Stat(path)
	if err == nil {
		http.ServeFile(w, req, path)
		return
	}

	u.Scheme = "http"
	u.Host = "mailback.me"

	buffer, err := ioutil.ReadAll(req.Body)
	if err != nil {
		log.Fatal(err.Error())
	}

	nreq, err := http.NewRequest(req.Method, u.String(), bytes.NewBuffer(buffer))
	if err != nil {
		log.Fatal(err.Error())
	}

	fmt.Printf("%s\n", u.String())

	nreq.Header = req.Header
	nreq.URL.Scheme = u.Scheme
	nreq.Host = u.Host

	t, err := url.Parse("http://mailback.me")
	if err != nil {
		log.Fatal(err.Error())
	}

	p := httputil.NewSingleHostReverseProxy(t)

	p.ServeHTTP(w, nreq)
}

func main() {
	http.HandleFunc("/", proxyHandler)

	err := http.ListenAndServe(":8090", nil)
	if err != nil {
		log.Fatal(err.Error())
	}
}
