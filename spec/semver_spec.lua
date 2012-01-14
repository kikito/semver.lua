local v = require 'semver'

local function checkVersion(ver, major, minor, patch, prerelease)
  assert_equal(major, ver.major)
  assert_equal(minor, ver.minor)
  assert_equal(patch, ver.patch)
  assert_equal(prerelease, ver.prerelease)
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

      it('parses prereleases, if they exist', function()
        checkVersion(v(1,2,3,"alpha"), 1,2,3,"alpha")
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
      test("1.2.3-alpha", function()
        checkVersion( v'1.2.3-alpha', 1,2,3,'alpha' )
      end)
    end)

    describe('errors', function()
      test('no parameters are passed', function()
        assert_error(function() v() end)
      end)
      test('negative numbers', function()
        assert_error(function() v(-1, 0, 0) end)
        assert_error(function() v( 0,-1, 0) end)
        assert_error(function() v( 0, 0,-1) end)
      end)
      test('floats', function()
        assert_error(function() v(.1, 0, 0) end)
        assert_error(function() v( 0,.1, 0) end)
        assert_error(function() v( 0, 0,.1) end)
      end)
      test('empty string', function()
        assert_error(function() v("") end)
      end)
      test('garbage at the beginning of the string', function()
        assert_error(function() v("foobar1.2.3") end)
      end)
      test('garbage at the end of the string', function()
        assert_error(function() v("1.2.3foobar") end)
      end)
      test('a non-string or number is passed', function()
        assert_error(function() v({}) end)
      end)
    end)
  end)

  describe("tostring", function()
    it("works with major, minor and patch", function()
      assert_equal("1.2.3", tostring(v(1,2,3)))
    end)

    it("works with a prerelease", function()
      assert_equal("1.2.3-beta", tostring(v(1,2,3,'beta')))
    end)
  end)

  describe("==", function()
    it("is true when major, minor and patch are the same", function()
      assert_equal(v(1,2,3), v'1.2.3')
    end)
    it("is false when major, minor and patch are not the same", function()
      assert_not_equal(v(1,2,3), v(4,5,6))
    end)
    it("false if all is the same except the prerelease", function()
      assert_not_equal(v(1,2,3), v'1.2.3-alpha')
    end)
  end)

  describe("<", function()
    test("true if major < minor", function()
      assert_less_than(v'1.100.10', v'2.0.0')
    end)
    test("false if major > minor", function()
      assert_greater_than(v'2', v'1')
    end)
    test("true if major = major but minor < minor", function()
      assert_less_than(v'1.2.0', v'1.3.0')
    end)
    test("false if minor < minor", function()
      assert_greater_than(v'1.1', v'1.0')
    end)
    test("true if major =, minor =, but patch <", function()
      assert_less_than(v'0.0.1', v'0.0.10')
    end)
    test("false if major =, minor =, but patch >", function()
      assert_greater_than(v'0.0.2', v'0.0.1')
    end)
  end)

  describe("nextPatch", function()
    it("increases the patch number by 1", function()
      assert_equal(v'1.0.1', v'1.0.0':nextPatch())
    end)
  end)

  describe("nextMinor", function()
    it("increases the minor number by 1", function()
      assert_equal(v'1.2.0', v'1.1.0':nextMinor())
    end)
    it("resets the patch number", function()
      assert_equal(v'1.2.0', v'1.1.7':nextMinor())
    end)
  end)

  describe("nextMajor", function()
    it("increases the major number by 1", function()
      assert_equal(v'2.0.0', v'1.0.0':nextMajor())
    end)
    it("resets the patch number", function()
      assert_equal(v'2.0.0', v'1.2.3':nextMajor())
    end)
  end)


  -- This works like the "pessimisstic operator" in Rubygems.
  -- if a and b are versions, a ^ b means "b is backwards-compatible with a"
  -- in other words, "it's safe to upgrade from a to b"
  describe("^", function()
    test("true for self", function()
      assert_true(v(1,2,3) ^ v(1,2,3))
    end)
    test("different major versions mean it's always unsafe", function()
      assert_false(v(2,0,0) ^ v(3,0,0))
      assert_false(v(2,0,0) ^ v(1,0,0))
    end)

    test("patch versions are always compatible", function()
      assert_true(v(1,2,3) ^ v(1,2,0))
      assert_true(v(1,2,3) ^ v(1,2,5))
    end)

    test("it's safe to upgrade to a newer minor version", function()
      assert_true(v(1,2,0) ^ v(1,5,0))
    end)
    test("it's unsafe to downgrade to an earlier minor version", function()
      assert_false(v(1,5,0) ^ v(1,2,0))
    end)
  end)

end)