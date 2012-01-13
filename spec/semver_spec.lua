local v = require 'semver'

local function checkVersion(ver, major, minor, patch)
  assert_equal(major, ver.major)
  assert_equal(minor, ver.minor)
  assert_equal(patch, ver.patch)
end

context('semver', function()

  context('creation', function()

    context('from numbers', function()
      it('parses 3 numbers correctly', function()
        checkVersion(v(1,2,3), 1,2,3)
      end)

      it('parses 2 numbers correctly', function()
        checkVersion(v(1,2), 1,2,0)
      end)

      it('parses 1 number correctly', function()
        checkVersion(v(1), 1,0,0)
      end)
    end)

    describe("from strings", function()
      test("1.2.3", function()
        checkVersion( v'1.2.3', 1,2,3)
      end)
      test("10.20.123", function()
        checkVersion( v'10.20.123', 10,20,123)
      end)
      test("2.0", function()
        checkVersion( v'2.0', 2,0,0)
      end)
      test("5", function()
        checkVersion( v'5', 5,0,0)
      end)
    end)

    describe('errors', function()
      it('throws an error if no parameters are passed', function()
        assert_error(function() v() end)
      end)
      it('throws an error on an empty string', function()
        assert_error(function() v("") end)
      end)
      it('throws an error with garbage at the beginning of the string', function()
        assert_error(function() v("foobar1.2.3") end)
      end)
      it('throws an error with garbage at the end of the string', function()
        assert_error(function() v("1.2.3foobar") end)
      end)
    end)

  end)
end)
