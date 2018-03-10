package main

import (
	"bytes"
	"fmt"
	"github.com/elazarl/goproxy"
	"io/ioutil"
	"log"
	"net/http"
	"os"
)

func handleResponse(resp *http.Response, ctx *goproxy.ProxyCtx) *http.Response {
	fmt.Printf("[%d] <-- %d %s\n", ctx.Session, resp.StatusCode, ctx.Req.URL.String())

	return resp
}

func main() {
	proxy := goproxy.NewProxyHttpServer()
	// proxy.Verbose = true

	proxy.OnRequest().DoFunc(
		func(r *http.Request, ctx *goproxy.ProxyCtx) (*http.Request, *http.Response) {
			u := r.URL
			path := u.Path[1:]
			// fmt.Printf("%s\n", path)

			_, err := os.Stat(path)
			if err == nil {

				u.Scheme = "http"
				u.Host = "localhost:8090"

				buffer, err := ioutil.ReadAll(r.Body)
				if err != nil {
					log.Fatal(err.Error())
				}

				nreq, err := http.NewRequest(r.Method, u.String(), bytes.NewBuffer(buffer))
				if err != nil {
					log.Fatal(err.Error())
				}
				client := new(http.Client)
				res, _ := client.Do(nreq)

				// fmt.Printf("%s\n", res)

				return r, res
			}
			return r, nil
		})

	// proxy.OnResponse().DoFunc(handleResponse)

	proxy.OnRequest().
		HandleConnect(goproxy.AlwaysMitm)

	server := http.Server{Addr: ":8080", Handler: proxy}
	log.Fatal(server.ListenAndServe())
}
