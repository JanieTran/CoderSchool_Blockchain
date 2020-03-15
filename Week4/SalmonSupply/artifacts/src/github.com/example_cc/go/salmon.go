package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
)

// ==================================================================================================
// STRUCTS INIT
// ==================================================================================================

type SmartContract struct{}

type Salmon struct {
	Vessel   string `json:"vessel"`
	DateTime string `json:"datetime"`
	Location string `json:"location"`
	Holder   string `json:"holder"`
}

// ==================================================================================================
// INIT AND INVOKE FUNCTIONS
// ==================================================================================================

func (s *SmartContract) Init(stub shim.ChaincodeStubInterface) peer.Response {
	fmt.Println(stub.GetFunctionAndParameters())
	fmt.Println(stub.GetStringArgs())
	fmt.Println(stub.GetTxID())

	return shim.Success(nil)
}

func (s *SmartContract) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
	function, args := stub.GetFunctionAndParameters()

	if function == "recordSalmon" {
		return s.recordSalmon(stub, args)
	} else if function == "changeSalmonHolder" {
		return s.changeSalmonHolder(stub, args)
	} else if function == "querySalmon" {
		return s.querySalmon(stub, args)
	} else if function == "queryAllSalmon" {
		return s.queryAllSalmon(stub)
	} else if function == "InitLedger" {
		return s.InitLedger(stub)
	}

	return shim.Error("Invalid function")
}

func (s *SmartContract) InitLedger(stub shim.ChaincodeStubInterface) peer.Response {
	salmons := []Salmon{
		Salmon{Vessel: "A", DateTime: "050418", Location: "Hokkaido", Holder: "Fredrick"},
		Salmon{Vessel: "B", DateTime: "040418", Location: "Venice", Holder: "Alice"},
		Salmon{Vessel: "C", DateTime: "030418", Location: "Santorini", Holder: "Bob"},
	}

	for i := 0; i < len(salmons); i++ {
		salmonBytes, _ := json.Marshal(salmons[i])
		err := stub.PutState(strconv.Itoa(i+1), salmonBytes)
		if err != nil {
			fmt.Println(err.Error())
		}
	}

	return shim.Success(nil)
}

// ==================================================================================================
// TRANSACTION FUNCTION
// ==================================================================================================

func (s *SmartContract) recordSalmon(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 5 {
		return shim.Error("Invalid args for recordSalmon()")
	}

	salmon := Salmon{
		Vessel:   args[1],
		DateTime: args[2],
		Location: args[3],
		Holder:   args[4],
	}

	salmonBytes, _ := json.Marshal(salmon)

	err := stub.PutState(args[0], salmonBytes)

	if err != nil {
		return shim.Error("Failed to record salmon")
	}

	return shim.Success(nil)
}

func (s *SmartContract) changeSalmonHolder(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 2 {
		return shim.Error("Invalid args for changeSalmonHolder()")
	}

	salmonBytes, _ := stub.GetState(args[0])
	salmon := Salmon{}

	json.Unmarshal(salmonBytes, &salmon)

	salmon.Holder = args[1]
	salmonBytes, _ = json.Marshal(salmon)

	err := stub.PutState(args[0], salmonBytes)
	if err != nil {
		return shim.Error("Failed to change holder")
	}

	return shim.Success(nil)
}

func (s *SmartContract) querySalmon(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 1 {
		return shim.Error("Invalid args for querySalmon()")
	}

	salmonBytes, _ := stub.GetState(args[0])
	if salmonBytes == nil {
		return shim.Error("Salmon not found")
	}

	return shim.Success(salmonBytes)
}

func (s *SmartContract) queryAllSalmon(stub shim.ChaincodeStubInterface) peer.Response {
	startKey := "0"
	endKey := "9999"

	resultsIterator, err := stub.GetStateByRange(startKey, endKey)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}

		if bArrayMemberAlreadyWritten {
			buffer.WriteString(",")
		}

		buffer.WriteString("{\"Key\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Record\":")
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")

		bArrayMemberAlreadyWritten = true
	}

	buffer.WriteString("]")

	fmt.Println(buffer.String())

	return shim.Success(buffer.Bytes())
}

// ==================================================================================================
// MAIN FUNCTION
// ==================================================================================================

func main() {
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Println(err.Error())
	}
}
