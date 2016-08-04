# semver.lua

[![Build Status](https://travis-ci.org/kikito/semver.lua.svg?branch=master)](https://travis-ci.org/kikito/semver.lua)

Semantic versioning for Lua.

See http://semver.org/ for details about semantic versioning.

# Documentation

``` lua
local v = require 'semver'

-- two ways of creating it: with separate parameters, or with one string
v1 = v(1,0,0)
v2_5_1 = v('2.5.1')

-- When using one string one can skip the parenthesis:
v2_5_1 = v'2.5.1' -- valid in Lua

-- major, minor and patch attributes
v2_5_1.major -- 2
v2_5_1.minor -- 5
v2_5_1.patch -- 1

-- prereleases:
a = v(1,0,0,'alpha')
a.prerelease -- 'alpha'
b = v('1.0.0-beta')
b.prerelease -- 'beta'

-- builds
c = v(1,0,0,nil,'build-1')
c.build -- 'build-1'

d = v('0.9.5+no.extensions.22')
d.build -- 'no.extensions.22'

-- comparison & sorting
v'1.2.3' == v(1,2,3)         -- true
v'1.2.3' < v(4,5,6)          -- true
v'1.2.3-alpha' < v'1.2.3'    -- true
v'1.2.3' < v'1.2.3+build.1'  -- false, builds are ignored when comparing versions in semver
-- (see the "notes" section for more informaion about version comparison)

-- "pessimistic upgrade" operator: ^
-- a ^ b returns true if it's safe to update from a to b
v'2.0.1' ^ v'2.5.1' -- true - it's safe to upgrade from 2.0.1 to 2.5.1
v'1.0.0' ^ v'2.0.0' -- false - 2.0.0 is not supposed to be backwards-compatible
v'2.5.1' ^ v'2.0.1' -- false - 2.5.1 is more modern than 2.0.1.

-- getting newer versions
v(1,0,0):nextPatch() -- v1.0.1
v(1,2,3):nextMinor() -- v1.3.0 . Notice the patch resets to 0
v(1,2,3):nextMajor() -- v2.0.0 . Minor and patch are reset to 0

```

# Installation

Just copy the semver.lua file wherever you want it (for example on a lib/ folder). Then write this in any Lua file where you want to use it. You must assign the require to a global or local variable (I use a local `v`):

``` lua
local v = require 'semver'
```

Using `v` allows for the nice string syntax: `v'1.2.3-alpha'`.

The `package.path` variable must be configured so that the folder in which middleclass.lua is copied is available, of course.

Please make sure that you read the license, too (for your convenience it's now included at the beginning of the semver.lua file).

# Notes about version comparison

Version comparison is done according to the semver 2.0.0 specs:

Major, minor, and patch versions are always compared numerically.

Pre-release precedence MUST be determined by comparing each dot-separated identifier as follows:

* Identifiers consisting of only digits are compared numerically
* Identifiers with letters or dashes are compared lexically in ASCII sort order.
* Numeric identifiers always have lower precedence than non-numeric identifiers

Builds are ignored when calculating precedence: version 1.2.3 and 1.2.3+build5 are considered equal.

# Specs

This project uses "busted":http://olivinelabs.com/busted/ for its specs. If you want to run the specs, you will have to install telescope first. Then just execute the following from the root inspect folder:

```
busted
```

# Changelog

## v1.1.1:
* Removed global variable which was declared by mistake
* Changed spec tool from telescope to busted
* Changed README format from textile to markdown

## v.1.2.0:
* Fix error: builds were being used for comparison, but according with semver 2.0.0 they should be ignored (so v'1.0.0+build1' is equal to v'1.0.0+build2')
* Fix several errors and inconsistencies in the way the comparisons where implemented.
* Added a lot more tests to cover more edge cases when comparing versions

## v.1.2.1
* Fix error on pessimistic update operator when applied to a 0.x.x version

