-- semver.lua - v2.1 (2012-01)
-- Copyright (c) 2012 Enrique García Cota
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-- Based on YaciCode, from Julien Patte and LuaObject, from Sebastien Rocca-Serra

local version

local function checkPositiveInteger(number, name)
  assert(number >= 0, name .. ' must be a valid positive number')
  assert(math.floor(number) == number, name .. ' must be an integer')
end

local function present(value)
  return value and value ~= ''
end

local function parsePrerelease(extra)
  if not present(extra) then return end

  local prerelease = extra:match("-([%w-][%.%w-]+)")
  assert(prerelease, ("The prerelease %q must start with a dash and be followed by dashes, alphanumerics or dots."):format(extra))
  return prerelease
end

local methods = {}

function methods:nextMajor()
  return version(self.major + 1, 0, 0)
end
function methods:nextMinor()
  return version(self.major, self.minor + 1, 0)
end
function methods:nextPatch()
  return version(self.major, self.minor, self.patch + 1)
end

local mt = { __index = methods }
function mt:__eq(other)
  return self.major == other.major and
         self.minor == other.minor and
         self.patch == other.patch and
         self.prerelease == other.prerelease
end
function mt:__lt(other)
  return self.major < other.major or
         self.minor < other.minor or
         self.patch < other.patch
end
function mt:__pow(other)
  return self.major == other.major and
         self.minor <= other.minor
end
function mt:__tostring()
  local buffer = { ("%d.%d.%d"):format(self.major, self.minor, self.patch) }
  if self.prerelease then table.insert(buffer, "-" .. self.prerelease) end
  return table.concat(buffer)
end


-- defined as local at the begining of the file
version = function(major, minor, patch, extra)
  assert(major, "At least one parameter is needed")

  if type(major) == 'string' then
    local sMajor, sMinor, sPatch
    sMajor, sMinor, sPatch, extra = major:match("^(%d+)%.?(%d*)%.?(%d*)(.-)$")
    assert(type(sMajor) == 'string', ("Could not extract version number(s) from %q"):format(major))
    major, minor, patch = tonumber(sMajor), tonumber(sMinor), tonumber(sPatch)
  end

  patch = patch or 0
  minor = minor or 0

  checkPositiveInteger(major, "major")
  checkPositiveInteger(minor, "minor")
  checkPositiveInteger(patch, "patch")

  local prerelease = parsePrerelease(extra)

  local result = {major=major, minor=minor, patch=patch, prerelease=prerelease}
  return setmetatable(result, mt)
end

return version
