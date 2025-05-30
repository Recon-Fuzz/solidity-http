// SPDX-License-Identifier: MIT
// Inspired by https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.2.0/contracts/utils/structs/EnumerableMap.sol
pragma solidity ^0.8.13;

import {StringSet} from "./StringSet.sol";

library StringMap {
    using StringSet for StringSet.Set;

    /**
     * @dev Query for a nonexistent map key.
     */
    error EnumerableMapNonexistentKey(string key);

    struct StringToStringMap {
        // Storage of keys
        StringSet.Set _keys;
        mapping(string key => string) _values;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(StringToStringMap storage map, string memory key, string memory value) internal returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(StringToStringMap storage map, string memory key) internal returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(StringToStringMap storage map, string memory key) internal view returns (bool) {
        return map._keys.contains(key);
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function length(StringToStringMap storage map) internal view returns (uint256) {
        return map._keys.length();
    }

    /**
     * @dev Returns the key-value pair stored at position `index` in the map. O(1).
     *
     * Note that there are no guarantees on the ordering of entries inside the
     * array, and it may change when more entries are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(StringToStringMap storage map, uint256 index)
        internal
        view
        returns (string memory key, string memory value)
    {
        string memory atKey = map._keys.at(index);
        return (atKey, map._values[atKey]);
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(StringToStringMap storage map, string memory key)
        internal
        view
        returns (bool exists, string memory value)
    {
        string memory val = map._values[key];
        if (bytes(val).length == 0) {
            return (contains(map, key), "");
        } else {
            return (true, val);
        }
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(StringToStringMap storage map, string memory key) internal view returns (string memory) {
        string memory value = map._values[key];
        if (bytes(value).length == 0 && !contains(map, key)) {
            revert EnumerableMapNonexistentKey(key);
        }
        return value;
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(StringToStringMap storage map) internal view returns (string[] memory) {
        return map._keys.values();
    }
}
