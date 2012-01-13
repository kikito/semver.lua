-- semver.lua - v2.1 (2012-01)
-- Copyright (c) 2012 Enrique García Cota
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-- Based on YaciCode, from Julien Patte and LuaObject, from Sebastien Rocca-Serra

local function checkPositiveInteger(number, name)
  assert(number >= 0, name .. ' must be a valid positive number')
  assert(math.floor(number) == number, name .. ' must be an integer')
end


local mt = {
  __eq = function(self, other)
    return self.major == other.major and
           self.minor == other.minor and
           self.patch == other.patch
  end,
  __lt = function(self, other)
    return self.major < other.major or
           self.minor < other.minor or
           self.patch < other.patch
  end,
  __tostring = function(self)
    return ("%d.%d.%d"):format(self.major, self.minor, self.patch)
  end
}

local function version(major, minor, patch)
  assert(major, "At least one parameter is needed")

  if type(major) == 'string' then
    local sMajor, sMinor, sPatch = major:match("^(%d+)%.?(%d*)%.?(%d*)$")
    assert(type(sMajor) == 'string', ("Could not version number(s) from %q"):format(major))
    major, minor, patch = tonumber(sMajor), tonumber(sMinor), tonumber(sPatch)
  end

  patch = patch or 0
  minor = minor or 0

  checkPositiveInteger(major, "major")
  checkPositiveInteger(minor, "minor")
  checkPositiveInteger(patch, "patch")

  return setmetatable({major=major, minor=minor, patch=patch}, mt)
end

return version
