// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {HTTP} from "@src/HTTP.sol";
import {HTTPBuilder} from "@src/HTTPBuilder.sol";
import {strings} from "solidity-stringutils/strings.sol";
import {StringMap} from "@src/StringMap.sol";
import {strings} from "solidity-stringutils/strings.sol";
import {stdJson} from "forge-std/StdJson.sol";

contract HTTPTest is Test {
    using HTTP for HTTP.Request;
    using HTTPBuilder for HTTP.Request;
    using StringMap for StringMap.StringToStringMap;
    using strings for *;
    using stdJson for string;

    HTTP.Request req;
    StringMap.StringToStringMap headers;
    StringMap.StringToStringMap query;

    function test_HTTP_GET() public {
        req.withUrl("https://jsonplaceholder.typicode.com/todos/1").withMethod(HTTP.Method.GET);
        HTTP.Response memory res = req.request();

        assertEq(res.status, 200);
        assertEq(res.data, '{  "userId": 1,  "id": 1,  "title": "delectus aut autem",  "completed": false}');
    }

    function test_HTTP_GET_options() public {
        req.withUrl("https://httpbin.org/headers").withHeader("accept", "application/json").withHeader(
            "Authorization", "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=="
        ).withMethod(HTTP.Method.GET);
        HTTP.Response memory res = req.request();

        assertEq(res.status, 200);

        assertTrue(res.data.toSlice().contains(("QWxhZGRpbjpvcGVuIHNlc2FtZQ==").toSlice()));
        assertTrue(res.data.toSlice().contains(("application/json").toSlice()));
    }

    function test_HTTP_POST_form_data() public {
        req.withUrl("https://httpbin.org/post").withMethod(HTTP.Method.POST).withBody("formfield=myemail@ethereum.org");
        HTTP.Response memory res = req.request();

        assertEq(res.status, 200);

        assertTrue(res.data.toSlice().contains(("formfield").toSlice()));
        assertTrue(res.data.toSlice().contains(("myemail@ethereum.org").toSlice()));
    }

    function test_HTTP_POST_json() public {
        req.withUrl("https://httpbin.org/post").withMethod(HTTP.Method.POST).withBody('{"foo": "bar"}');
        HTTP.Response memory res = req.request();

        assertEq(res.status, 200);
        assertTrue(res.data.toSlice().contains(("foo").toSlice()));
        assertTrue(res.data.toSlice().contains(("bar").toSlice()));
    }

    function test_HTTP_PUT() public {
        req.withUrl("https://httpbin.org/put").withMethod(HTTP.Method.PUT);
        HTTP.Response memory res = req.request();
        assertEq(res.status, 200);
    }

    function test_HTTP_PUT_json() public {
        req.withUrl("https://httpbin.org/put").withMethod(HTTP.Method.PUT).withBody('{"foo": "bar"}').withHeader(
            "Content-Type", "application/json"
        );
        HTTP.Response memory res = req.request();

        assertEq(res.status, 200);
        assertTrue(res.data.toSlice().contains(('"foo"').toSlice()));
        assertTrue(res.data.toSlice().contains(('"bar"').toSlice()));
    }

    function test_HTTP_DELETE() public {
        req.withUrl("https://httpbin.org/delete").withMethod(HTTP.Method.DELETE);
        HTTP.Response memory res = req.request();
        assertEq(res.status, 200);
    }

    function test_HTTP_PATCH() public {
        req.withUrl("https://httpbin.org/patch").withMethod(HTTP.Method.PATCH);
        HTTP.Response memory res = req.request();
        assertEq(res.status, 200);
    }
}
