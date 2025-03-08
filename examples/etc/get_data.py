from sklearn.datasets import load_iris
from pandas import DataFrame
iris = load_iris()

data = iris.data
y = iris.target

data = DataFrame(data)
y = DataFrame(y)

data = data.rename(columns={
    0: "x1", 1: "x2", 2: "x3", 3: "x4"
})

y = y.rename(columns={
    0: "y"
})

data["y"] = y


data.to_csv("examples/etc/test_data.csv")