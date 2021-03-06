# MZTableLayout
类似Excel的布局样式

[Objective-C版本](https://github.com/MachelleZhang/MZMultiHeadersSheet)

## 示例
![Demo](Images/demo1.jpg)

## 安装方法

```
pod 'MZTableLayout', '~> 1.2.0'
```

## 用法

![free_layout.png](Images/free_layout.png)<br>
在已知表格样式的前提下，按从左到右，从上到下，依次添加索引，已编号的掠过，参考上图的索引规则<br>

1.设置代理

```Swift
tableLayout = MZTableLayout.init()
tableLayout?.delegate = self
```

2.需要实现的主要代理方法

```Swift
extension DemoViewController1: MZTableLayoutDelegate {
    func totalScale(_ colletionView: UICollectionView) -> (Int, Int) {
        return (20, 20)
    }
    
    func baseWidth(_ collectionView: UICollectionView, cellWidthOf index: Int) -> CGFloat {
        if index == 5 {
            return 40
        }
        return 90
    }
    
    func baseHeight(_ collectionView: UICollectionView, cellHeightOf index: Int) -> CGFloat {
        if index == 2 {
            return 40
        }
        return 70
    }
    
    func frozenUnit(_ colletionView: UICollectionView) -> (Int, Int) {
        (1, 0)
    }
}

extension DemoViewController1: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.title.text = String.init(indexPath.row)
        cell.backgroundColor = .lightGray
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.black.cgColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 400
    }
}
```

## 版本更新历史
版本号|版本描述
---|---
v. 1.0.0|初始版本，包含基本表格功能
v. 1.1.0|增加margin和spacing属性，可方便、美观地控制间隔
v. 1.2.0|修改width和height的计算方式，各行列可自由调整

## 作者

ZhangLe, 407916482@qq.com