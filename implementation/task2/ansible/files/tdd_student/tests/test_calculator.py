import pytest
from exercises.calculator import add, subtract, multiply, divide


class TestAdd:
    def test_positive(self):
        assert add(2, 3) == 5

    def test_negative(self):
        assert add(-1, -4) == -5

    def test_mixed(self):
        assert add(10, -3) == 7


class TestSubtract:
    def test_positive(self):
        assert subtract(10, 4) == 6

    def test_negative(self):
        assert subtract(-2, -5) == 3

    def test_zero(self):
        assert subtract(5, 5) == 0


class TestMultiply:
    def test_positive(self):
        assert multiply(3, 4) == 12

    def test_by_zero(self):
        assert multiply(7, 0) == 0

    def test_negative(self):
        assert multiply(-2, 3) == -6


class TestDivide:
    def test_exact(self):
        assert divide(10, 2) == 5

    def test_float(self):
        assert divide(7, 2) == pytest.approx(3.5)

    def test_divide_by_zero(self):
        with pytest.raises(ZeroDivisionError):
            divide(1, 0)
