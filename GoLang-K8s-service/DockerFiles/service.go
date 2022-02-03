package main

import (
	"encoding/json"
	"flag"
	"github.com/globalsign/mgo"
	"log"
	"net/http"
	"net/url"
	"os"
)

var InfoLogger = log.New(os.Stdout, "INFO ", log.Ldate+log.Lmicroseconds)
var FatalLogger = log.New(os.Stdout, "FATAL ", log.Ldate+log.Lmicroseconds)

var (
	mongodb    = flag.String("mongo_url", "localhost:27017", "")
)

var session *mgo.Session
var err error
var db *MongoStorage

func main() {
	flag.Parse()

	session, err = mgo.Dial(*mongodb)
	if err != nil && session == nil {
		log.Fatal("Can not connect to database : ", err)
	} else {
		log.Println("Connected to database")
	}
	db, err = NewMongoStorage(session)

	handler := http.NewServeMux()
	handler.HandleFunc("/hellops", SayHello)
	handler.HandleFunc("/insertitem", InsertItem)
	handler.HandleFunc("/showitems", ShowItems)

	InfoLogger.Println("Service is running up...")
	err = http.ListenAndServe(":8080", handler);
	if err != nil {
		FatalLogger.Println(err)
	}
}

type Resp struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

type Info struct {
	Name    string    `json:"name"`
	Surname string `json:"surname"`
}

type Payload struct {
	Infos []Info `json:"infos"`
}

func ShowItems(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	if r.Method != http.MethodGet {
		w.WriteHeader(http.StatusMethodNotAllowed)
		res := Resp{
			Code:    http.StatusMethodNotAllowed,
			Message: "Method not allowed!",
		}
		json.NewEncoder(w).Encode(res)
	} else {
		infos, _ := db.getAll()
		w.WriteHeader(http.StatusOK)
		payload := Payload{
			infos,
		}
		json.NewEncoder(w).Encode(payload)
	}
}

func InsertItem(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		res := Resp{
			Code:    http.StatusMethodNotAllowed,
			Message: "Method not allowed!",
		}
		json.NewEncoder(w).Encode(res)
	} else {
		params, _ := url.ParseQuery(r.URL.RawQuery)
		name := params["name"][0]
		surname := params["surname"][0]
		info := Info{name,surname}
		err = db.insert(info)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			res := Resp{
				Code:    http.StatusInternalServerError,
				Message: "Internal Server Error",
			}
			json.NewEncoder(w).Encode(res)
		}
		w.WriteHeader(http.StatusOK)
		res := Resp{
			Code:    http.StatusAccepted,
			Message: "Info is inserted!",
		}
		json.NewEncoder(w).Encode(res)
	}
}

func SayHello(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	if r.Method != http.MethodGet {
		w.WriteHeader(http.StatusMethodNotAllowed)
		res := Resp{
			Code:    http.StatusMethodNotAllowed,
			Message: "Method not allowed!",
		}
		json.NewEncoder(w).Encode(res)
	} else {
		w.WriteHeader(http.StatusOK)
		res := Resp{
			Code:    http.StatusOK,
			Message: "Hello PublicSonar!",
		}
		json.NewEncoder(w).Encode(res)
	}
}

type MongoStorage struct {
	db *mgo.Session
}

func NewMongoStorage(session *mgo.Session) (*MongoStorage, error) {
	return &MongoStorage{
		db: session,
	}, nil
}

func (ms *MongoStorage) Close() {
	ms.db.Close()
}

func (ms *MongoStorage) insert(info Info) error {
	return ms.db.DB("devops").C("publicsonar").Insert(info)
}

func (ms *MongoStorage) getAll() ([]Info, error) {
	var info []Info
	return info, ms.db.DB("devops").C("publicsonar").Find(nil).All(&info)
}