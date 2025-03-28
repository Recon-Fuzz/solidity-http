// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Vm} from "forge-std/Vm.sol";
import {StringMap} from "@src/StringMap.sol";

library HTTP {
    using StringMap for StringMap.StringToStringMap;

    Vm constant vm = Vm(address(bytes20(uint160(uint256(keccak256("hevm cheat code"))))));

    enum Method {
        GET,
        POST,
        PUT,
        DELETE,
        PATCH
    }

    struct Request {
        string url;
        string body;
        Method method;
        StringMap.StringToStringMap headers;
        StringMap.StringToStringMap query;
    }

    struct Response {
        uint256 status;
        string data;
    }

    function request(Request storage req) internal returns (Response memory res) {
        string memory scriptStart = 'response=$(curl -s -w "\\n%{http_code}" ';
        string memory scriptEnd =
            '); status=$(tail -n1 <<< "$response"); data=$(sed "$ d" <<< "$response");data=$(echo "$data" | tr -d "\\n"); cast abi-encode "response(uint256,string)" "$status" "$data";';

        string memory curlParams = "";

        for (uint256 i = 0; i < req.headers.length(); i++) {
            (string memory key, string memory value) = req.headers.at(i);
            curlParams = string.concat(curlParams, '-H "', key, ": ", value, '" ');
        }

        curlParams = string.concat(curlParams, " -X ", toString(req.method), " ");

        if (bytes(req.body).length > 0) {
            curlParams = string.concat(curlParams, "-d '", req.body, "' ");
        }

        string memory quotedURL = string.concat('"', req.url, '"');

        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = string.concat(scriptStart, curlParams, quotedURL, scriptEnd, "");
        bytes memory output = vm.ffi(inputs);

        (res.status, res.data) = abi.decode(output, (uint256, string));
    }

    function toString(Method method) internal pure returns (string memory) {
        if (method == Method.GET) {
            return "GET";
        } else if (method == Method.POST) {
            return "POST";
        } else if (method == Method.PUT) {
            return "PUT";
        } else if (method == Method.DELETE) {
            return "DELETE";
        } else if (method == Method.PATCH) {
            return "PATCH";
        } else {
            revert();
        }
    }
}
