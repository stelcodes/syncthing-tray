package main

import (
	"crypto/tls"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"time"
)

func query_syncthing(url string) (string, error) {

	client := &http.Client{
		Transport: &http.Transport{
			Dial: func(netw, addr string) (net.Conn, error) {
				conn, err := net.DialTimeout(netw, addr, time.Second*10)
				if err != nil {
					return nil, err
				}
				conn.SetDeadline(time.Now().Add(time.Second * 120))
				return conn, nil
			},
			TLSClientConfig: &tls.Config{
				InsecureSkipVerify: config.insecure,
			},
			ResponseHeaderTimeout: time.Second * 120,
		},
	}

	req, _ := http.NewRequest("GET", url, nil)
	req.Header.Set("X-API-Key", config.ApiKey)

	response, err := client.Do(req)

	if err != nil {
		log.Printf("ERROR: %s\n", err)
		return "", err
	} else {
		defer response.Body.Close()
		contents, err := ioutil.ReadAll(response.Body)
		if response.StatusCode == 401 {
			log.Fatal("Invalid username or password")
		}
		if err != nil {
			log.Printf("ERROR: %s\n", err)
			return "", err
		}
		return string(contents), err
	}
	return "", err
}
