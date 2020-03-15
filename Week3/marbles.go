package main

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
)

type Marble struct {
	ObjectType string        `json:"docType"`
	Id         string        `json:"id"`
	Color      string        `json:"color"`
	Size       uint          `json:"size"`
	Owner      OwnerRelation `json:"owner"`
}

type Owner struct {
	ObjectType string `json:"docType"`
	Id         string `json:"Id"`
	Username   string `json:"username"`
	Company    string `json:"company"`
	Enabled    bool   `json:"enabled"`
}

type OwnerRelation struct {
	Id       string `json:"id"`
	Username string `json:"username"`
	Company  string `json:"company"`
}

func Init(stub shim.ChaincodeStubInterface) peer.Response {
	fmt.Println(stub.GetFunctionAndParameters())
	fmt.Println(stub.GetStringArgs())
	fmt.Println(stub.GetTxID())
}

func init_marble(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if (len(args) != 5) {
		return
	}

	var marble = Marble{
		Id: args[1],
		Color: args[2],
		Size: args[3],
		Owner: args[4]
	}

	marbleBytes, _ := json.Marshal(marble)

	err := stub.PutState(args[0], marbleBytes)

	if err != nil {
		return shim.Error(fmt.Println("Failed to record marble %s", args[0]))
	}

	return shim.Success(nil)
}


func get_marble(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if (len(args) != 1) {
		return 
	}

	marbleBytes := stub.GetState(args[0])

	if marbleBytes == nil {
		return shim.Error(fmt.Println("Error getting marble"))
	}

	return shim.Success(marbleBytes)
}

func delete_marble(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if (len(args) != 1) {
		return
	}

	err := stub.DeleteState(args[0])
	if err != nil {
		return shim.Error(fmt.Println("Error deleting marble"))
	}

	return shim.Success(nil)
}

func init_owner(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	
}