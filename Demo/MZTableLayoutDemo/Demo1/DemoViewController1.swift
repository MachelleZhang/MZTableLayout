//
//  ViewController.swift
//  MZTableLayout
//
//  Created by zhangle on 08/15/2019.
//  Copyright (c) 2019 zhangle. All rights reserved.
//

import UIKit

class DemoViewController1: UIViewController {

    var collectionView: UICollectionView?
    var tableLayout: MZTableLayout?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableLayout = MZTableLayout.init()
        tableLayout?.delegate = self
        collectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height-200), collectionViewLayout: tableLayout!)
        collectionView?.register(UINib.init(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView?.backgroundColor = .lightGray
        collectionView?.dataSource = self;
        collectionView?.isDirectionalLockEnabled = true
        collectionView?.bounces = false
        self.view.addSubview(collectionView!)
    }
}

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

