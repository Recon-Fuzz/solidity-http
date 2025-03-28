// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {HTTP} from "@src/HTTP.sol";
import {StringMap} from "@src/StringMap.sol";

library HTTPBuilder {
    using StringMap for StringMap.StringToStringMap;

    error HTTPBuilderInvalidArrayLengths(uint256 a, uint256 b);

    function withUrl(HTTP.Request storage req, string memory url) internal returns (HTTP.Request storage) {
        req.url = url;
        return req;
    }

    function withMethod(HTTP.Request storage req, HTTP.Method method) internal returns (HTTP.Request storage) {
        req.method = method;
        return req;
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
}
