// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {HTTP} from "@src/HTTP.sol";
import {strings} from "solidity-stringutils/strings.sol";
import {stdJson} from "forge-std/StdJson.sol";

contract HTTPTest is Test {
    using HTTP for HTTP.Builder;
    using HTTP for HTTP.Request;
    using strings for *;
    using stdJson for string;

    HTTP.Builder http;

    function test_HTTP_GET() public {
        HTTP.Response memory res = http.build().GET("https://jsonplaceholder.typicode.com/todos/1").request();

        assertEq(res.status, 200);
        assertEq(res.data, '{  "userId": 1,  "id": 1,  "title": "delectus aut autem",  "completed": false}');
    }

    function test_HTTP_GET_options() public {
        HTTP.Response memory res = http.build().GET("https://httpbin.org/headers").withHeader(
            "accept", "application/json"
        ).withHeader("Authorization", "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==").request();

        assertEq(res.status, 200);

        assertTrue(res.data.toSlice().contains(("QWxhZGRpbjpvcGVuIHNlc2FtZQ==").toSlice()));
        assertTrue(res.data.toSlice().contains(("application/json").toSlice()));
    }

    function test_HTTP_POST_form_data() public {
        HTTP.Response memory res =
            http.build().POST("https://httpbin.org/post").withBody("formfield=myemail@ethereum.org").request();

        assertEq(res.status, 200);

        assertTrue(res.data.toSlice().contains(("formfield").toSlice()));
        assertTrue(res.data.toSlice().contains(("myemail@ethereum.org").toSlice()));
    }

    function test_HTTP_POST_json() public {
        HTTP.Response memory res = http.build().POST("https://httpbin.org/post").withBody('{"foo": "bar"}').request();

        assertEq(res.status, 200);
        assertTrue(res.data.toSlice().contains(("foo").toSlice()));
        assertTrue(res.data.toSlice().contains(("bar").toSlice()));
    }

    function test_HTTP_PUT() public {
        HTTP.Response memory res = http.build().PUT("https://httpbin.org/put").request();
        assertEq(res.status, 200);
    }

    function test_HTTP_PUT_json() public {
        HTTP.Response memory res = http.build().PUT("https://httpbin.org/put").withBody('{"foo": "bar"}').withHeader(
            "Content-Type", "application/json"
        ).request();

        assertEq(res.status, 200);
        assertTrue(res.data.toSlice().contains(('"foo"').toSlice()));
        assertTrue(res.data.toSlice().contains(('"bar"').toSlice()));
    }

    function test_HTTP_DELETE() public {
        HTTP.Response memory res = http.build().DELETE("https://httpbin.org/delete").request();
        assertEq(res.status, 200);
    }

    function test_HTTP_PATCH() public {
        HTTP.Response memory res = http.build().PATCH("https://httpbin.org/patch").request();
        assertEq(res.status, 200);
    }
}
