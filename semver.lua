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

local function parseExtra(extra)
  if not present(extra) then return end

  local prereleaseWithSign, buildWithSign = extra:match("^(-[^+]+)(+.+)$")
  if not (prereleaseWithSign and buildWithSign) then
    prereleaseWithSign = extra:match("^(-.+)$")
    buildWithSign      = extra:match("^(+.+)$")
  end
  assert(prereleaseWithSign or buildWithSign, ("The parameter %q must begin with + or - to denote a prerelease or a buld"):format(extra))

  local prerelease, build

  if prereleaseWithSign then
    prerelease = prereleaseWithSign:match("^-(%w[%.%w-]*)$")
    assert(prerelease, ("The prerelease %q is not a slash followed by alphanumerics, dots and slashes"):format(prereleaseWithSign))
  end

  if buildWithSign then
    build = buildWithSign:match("^%+(%w[%.%w-]*)$")
    assert(build, ("The build %q is not a + sign followed by alphanumerics, dots and slashes"):format(buildWithSign))
  end

  return prerelease, build
end

local function parseString(str)
  local sMajor, sMinor, sPatch, extra = str:match("^(%d+)%.?(%d*)%.?(%d*)(.-)$")
  assert(type(sMajor) == 'string', ("Could not extract version number(s) from %q"):format(str))
  local major, minor, patch = tonumber(sMajor), tonumber(sMinor), tonumber(sPatch)
  local prerelease, build = parseExtra(extra)
  return major,minor,patch,prerelease,build
end


-- return 0 if a == b, -1 if a < b, and 1 if a > b
local function compare(a,b)
  return a == b and 0 or a < b and -1 or 1
end

local function compareIds(selfId, otherId)
  if not selfId and not otherId then return 0
  elseif not selfId then return             1
  elseif not otherId then return           -1
  end

  local selfNumber, otherNumber = tonumber(selfId), tonumber(otherId)

  if selfNumber and otherNumber then -- numerical comparison
    return compare(selfNumber, otherNumber)
  elseif selfNumber then -- numericals are always smaller than alphanums
    return -1
  else
    return compare(selfId, otherId) -- alphanumerical comparison
  end
end

local function splitByDot(str)
  local t, count = {}, 0
  str:gsub("([^%.]+)", function(c)
    count = count + 1
    t[count] = c
  end)
  return t
end

local function smallerExtra(selfExtra, otherExtra)
  if selfExtra == otherExtra then return false end

  local selfIds, otherIds = splitByDot(selfExtra), splitByDot(otherExtra)
  local selfLength = #selfIds
  local comparison

  for i = 1, selfLength do
    comparison = compareIds(selfIds[i], otherIds[i])
    if comparison ~= 0 then return comparison == -1 end
    -- if comparison == 0, continue loop
  end

  return selfLength < #otherIds
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
         self.prerelease == other.prerelease and
         self.build == other.build
end
function mt:__lt(other)
  return self.major < other.major or
         self.minor < other.minor or
         self.patch < other.patch or
         (self.prerelease and not other.prerelease) or
         smallerExtra(self.prerelease, other.prerelease) or
         (not self.build and other.build) or
         smallerExtra(self.build, other.build)
end
function mt:__pow(other)
  return self.major == other.major and
         self.minor <= other.minor
end
function mt:__tostring()
  local buffer = { ("%d.%d.%d"):format(self.major, self.minor, self.patch) }
  if self.prerelease then table.insert(buffer, "-" .. self.prerelease) end
  if self.build      then table.insert(buffer, "+" .. self.build) end
  return table.concat(buffer)
end


-- defined as local at the begining of the file
version = function(major, minor, patch, prerelease, build)
  assert(major, "At least one parameter is needed")

  if type(major) == 'string' then
    major,minor,patch,prerelease,build = parseString(major)
  end
  patch = patch or 0
  minor = minor or 0

  checkPositiveInteger(major, "major")
  checkPositiveInteger(minor, "minor")
  checkPositiveInteger(patch, "patch")

  local result = {major=major, minor=minor, patch=patch, prerelease=prerelease, build=build}
  return setmetatable(result, mt)
end

return version
