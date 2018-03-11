package main

import (
	"bytes"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
)

// Proxy ...
type Proxy struct {
	TargetHost string
}

// proxyHandler ...
func (proxy *Proxy) proxyHandler(w http.ResponseWriter, req *http.Request) {

	t, err := url.Parse(proxy.TargetHost)
	if err != nil {
		log.Fatal(err.Error())
	}

	u := req.URL
	path := u.Path[1:]

	fmt.Printf("%s\n", path)
	_, err = os.Stat(path)
	if err == nil {
		http.ServeFile(w, req, path)
		return
	}

	u.Scheme = t.Scheme
	u.Host = t.Host

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

	p := httputil.NewSingleHostReverseProxy(t)

	p.ServeHTTP(w, nreq)
}

func main() {
	host := flag.String("host", "https://google.com", "target host")
	port := flag.Int("port", 8090, "listen port")
	flag.Parse()

	proxy := Proxy{TargetHost: *host}

	http.HandleFunc("/", proxy.proxyHandler)

	err := http.ListenAndServe(fmt.Sprintf(":%d", *port), nil)
	if err != nil {
		log.Fatal(err.Error())
	}
}
