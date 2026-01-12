// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {HTTP} from "../src/HTTP.sol";
import {strings} from "solidity-stringutils/strings.sol";

contract HTTPTest is Test {
    using HTTP for *;
    using strings for *;

    HTTP.Client http;

    function test_HTTP_GET() public {
        HTTP.Response memory res = http.initialize().GET("https://jsonplaceholder.typicode.com/todos/1").request();

        assertEq(res.status, 200);
        assertEq(res.data, '{  "userId": 1,  "id": 1,  "title": "delectus aut autem",  "completed": false}');
    }

    function test_HTTP_GET_options() public {
        HTTP.Response memory res = http.initialize("https://httpbin.org/headers").GET()
            .withHeader("accept", "application/json").withHeader("Authorization", "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==")
            .request();

        assertEq(res.status, 200);

        assertTrue(res.data.toSlice().contains(("QWxhZGRpbjpvcGVuIHNlc2FtZQ==").toSlice()));
        assertTrue(res.data.toSlice().contains(("application/json").toSlice()));
    }

    function test_HTTP_POST_form_data() public {
        HTTP.Response memory res =
            http.initialize().POST("https://httpbin.org/post").withBody("formfield=myemail@ethereum.org").request();

        assertEq(res.status, 200);

        assertTrue(res.data.toSlice().contains(("formfield").toSlice()));
        assertTrue(res.data.toSlice().contains(("myemail@ethereum.org").toSlice()));
    }

    function test_HTTP_POST_json() public {
        HTTP.Response memory res =
            http.initialize("https://httpbin.org/post").POST().withBody('{"foo": "bar"}').request();

        assertEq(res.status, 200);
        assertTrue(res.data.toSlice().contains(("foo").toSlice()));
        assertTrue(res.data.toSlice().contains(("bar").toSlice()));
    }

    function test_HTTP_PUT() public {
        HTTP.Response memory res = http.initialize().PUT("https://httpbin.org/put").request();
        assertEq(res.status, 200);
    }

    function test_HTTP_PUT_json() public {
        HTTP.Response memory res = http.initialize("https://postman-echo.com/put").PUT().withBody('{"foo": "bar"}')
            .withHeader("Content-Type", "application/json").request();

        assertEq(res.status, 200);
        assertTrue(res.data.toSlice().contains(('"foo"').toSlice()));
        assertTrue(res.data.toSlice().contains(('"bar"').toSlice()));
    }

    function test_HTTP_DELETE() public {
        HTTP.Response memory res = http.initialize().DELETE("https://httpbin.org/delete").request();
        assertEq(res.status, 200);
    }

    function test_HTTP_PATCH() public {
        HTTP.Response memory res = http.initialize().PATCH("https://httpbin.org/patch").request();
        assertEq(res.status, 200);
    }

    function test_HTTP_instance() public {
        HTTP.Request storage req = http.initialize("https://jsonplaceholder.typicode.com/todos/1");
        assertEq(req.url, "https://jsonplaceholder.typicode.com/todos/1");
    }

    function test_HTTP_redirects_disabled_by_default() public {
        HTTP.Response memory res = http.initialize().GET("https://httpbin.org/relative-redirect/1").request();

        assertEq(res.status, 302);
    }

    function test_HTTP_redirects_enabled() public {
        HTTP.Response memory res = http.initialize().GET("https://httpbin.org/relative-redirect/1")
            .withFollowRedirects(true).withMaxRedirects(3).request();

        assertEq(res.status, 200);
        assertTrue(res.data.toSlice().contains(("https://httpbin.org/get").toSlice()));
    }
}
