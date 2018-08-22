# import a dataset
from sklearn import datasets
iris = datasets.load_iris()

x = iris.data
y = iris.target

from sklearn.cross_validation import train_test_split
# 将一半的数据用作训练，一半的数据用作测试
x_train,x_test,y_train,y_test, = train_test_split(x,y,test_size = .5) 

# from sklearn import tree
# my_classifier = tree.DecisionTreeClassifier()

from sklearn.neighbors import KNeighborsClassifier
my_classifier = KNeighborsClassifier()
 
my_classifier.fit(x_train,y_train)

predictions = my_classifier.predict(x_test)

# 将测试数据和真实数据进行比较
from sklearn.metrics import accuracy_score
print(accuracy_score(y_test,predictions))
