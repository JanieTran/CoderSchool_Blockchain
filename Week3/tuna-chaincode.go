package main

import (
	"encoding/json"
	"fmt"
)

type SmartContract struct {
}

type Tuna struct {
	Vessel    string `json:"vessel"`
	Timestamp string `json:"timestamp"`
	Location  string `json:"location"`
	Holder    string `json:"holder"`
}

func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) {
	return shim.Success(nil)
}

func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) {
	function, args := APIstub.GetFunctionAndParameters()
	if function == "queryTuna" {
		return s.queryTuna(APIstub, args)
	} else if function == "recordTuna" {
		return s.recordTuna(APIstub, args)
	} else if function == "changeTunaHolder" {
		return s.changeTunaHolder(APIstub, args)
	}
}

func (s *SmartContract) recordTuna(APIstub shim.ChaincodeStubInterface, args []string) {
	if len(args) != 5 {
		return shim.Error("Incorrect number of args")
	}

	var tuna = Tuna{Vessel: args[1], Location: args[2], Timestamp: args[3], Holder: args[4]}

	tunaAsBytes, _ := json.Marshal(tuna)

	err := APIstub.PutState(args[0], tunaAsBytes)

	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to record tuna %s", args[0]))
	}

	return shim.Success(nil)
}

func (s *SmartContract) queryTuna(APIstub shim.ChaincodeStubInterface, args []string) {
	if len(args) != 1 {
		return shim.Error("Incorrect number of args")
	}

	tunaAsBytes, _ := APIstub.GetState(args[0])

	if tunaAsBytes == nil {
		return shim.Error("Could not locate tuna")
	}

	return shim.Success(tunaAsBytes)
}

func (s *SmartContract) changeTunaHolder(APIstub shim.ChaincodeStubInterface, args []string) {
	if len(args) != 2 {

	}

	tunaAsBytes, _ := APIstub.GetState(args[0])
	tuna := Tuna{}

	err := json.Unmarshal(tunaAsBytes, &tuna)
	if err != nil {
		return shim.Error()
	}

	tuna.Holder = args[1]

	tunaAsBytes, _ = json.Marshal(tuna)

	err := APIstub.PutState(args[0], tunaAsBytes)

	if err != nil {

	}

	return shim.Success(nil)
}
