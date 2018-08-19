# 引入需要的包
from sklearn import tree

# 数据
# features = [[140,"smooth"],[130,"smooth"],[150,"bumpy"],[170,"bumpy"]] # 用0表示粗糙，用1表示光滑
features = [[140,1],[130,1],[150,0],[170,0]]
# labels = ["apple","apple","orange","orange"] # 用0表示苹果，1表示橘子
labels = [0,0,1,1]

# 创建一个分类器
clf = tree.DecisionTreeClassifier()
# 用这些实例数据来训练我们的分类器
clf = clf.fit(features,labels) 
# 使用训练后的分类器对数据进行预测
print(clf.predict([[150,1]]))