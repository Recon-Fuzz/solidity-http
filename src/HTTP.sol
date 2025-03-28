// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Vm} from "forge-std/Vm.sol";
import {StringMap} from "./StringMap.sol";

library HTTP {
    using StringMap for StringMap.StringToStringMap;

    Vm constant vm = Vm(address(bytes20(uint160(uint256(keccak256("hevm cheat code"))))));

    error HTTPBuilderInvalidArrayLengths(uint256 a, uint256 b);

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

    struct Builder {
        Request[] requests;
    }

    function build(HTTP.Builder storage builder) internal returns (HTTP.Request storage) {
        builder.requests.push();
        return builder.requests[builder.requests.length - 1];
    }

    function withUrl(HTTP.Request storage req, string memory url) internal returns (HTTP.Request storage) {
        req.url = url;
        return req;
    }

    function withMethod(HTTP.Request storage req, HTTP.Method method) internal returns (HTTP.Request storage) {
        req.method = method;
        return req;
    }

    function GET(HTTP.Request storage req) internal returns (HTTP.Request storage) {
        return withMethod(req, HTTP.Method.GET);
    }

    function GET(HTTP.Request storage req, string memory url) internal returns (HTTP.Request storage) {
        return withUrl(withMethod(req, HTTP.Method.GET), url);
    }

    function POST(HTTP.Request storage req) internal returns (HTTP.Request storage) {
        return withMethod(req, HTTP.Method.POST);
    }

    function POST(HTTP.Request storage req, string memory url) internal returns (HTTP.Request storage) {
        return withUrl(withMethod(req, HTTP.Method.POST), url);
    }

    function PUT(HTTP.Request storage req) internal returns (HTTP.Request storage) {
        return withMethod(req, HTTP.Method.PUT);
    }

    function PUT(HTTP.Request storage req, string memory url) internal returns (HTTP.Request storage) {
        return withUrl(withMethod(req, HTTP.Method.PUT), url);
    }

    function DELETE(HTTP.Request storage req) internal returns (HTTP.Request storage) {
        return withMethod(req, HTTP.Method.DELETE);
    }

    function DELETE(HTTP.Request storage req, string memory url) internal returns (HTTP.Request storage) {
        return withUrl(withMethod(req, HTTP.Method.DELETE), url);
    }

    function PATCH(HTTP.Request storage req) internal returns (HTTP.Request storage) {
        return withMethod(req, HTTP.Method.PATCH);
    }

    function PATCH(HTTP.Request storage req, string memory url) internal returns (HTTP.Request storage) {
        return withUrl(withMethod(req, HTTP.Method.PATCH), url);
    }

    function withBody(HTTP.Request storage req, string memory body) internal returns (HTTP.Request storage) {
        req.body = body;
        return req;
    }

    function withHeader(HTTP.Request storage req, string memory key, string memory value)
        internal
        returns (HTTP.Request storage)
    {
        req.headers.set(key, value);
        return req;
    }

    function withHeader(HTTP.Request storage req, string[] memory keys, string[] memory values)
        internal
        returns (HTTP.Request storage)
    {
        if (keys.length != values.length) {
            revert HTTPBuilderInvalidArrayLengths(keys.length, values.length);
        }
        for (uint256 i = 0; i < keys.length; i++) {
            req.headers.set(keys[i], values[i]);
        }
        return req;
    }

    function withQuery(HTTP.Request storage req, string memory key, string memory value)
        internal
        returns (HTTP.Request storage)
    {
        req.query.set(key, value);
        return req;
    }

    function withQuery(HTTP.Request storage req, string[] memory keys, string[] memory values)
        internal
        returns (HTTP.Request storage)
    {
        if (keys.length != values.length) {
            revert HTTPBuilderInvalidArrayLengths(keys.length, values.length);
        }
        for (uint256 i = 0; i < keys.length; i++) {
            req.query.set(keys[i], values[i]);
        }
        return req;
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
