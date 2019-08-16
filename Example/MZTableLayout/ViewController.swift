//
//  ViewController.swift
//  MZTableLayout
//
//  Created by zhangle on 08/15/2019.
//  Copyright (c) 2019 zhangle. All rights reserved.
//

import UIKit

import MZTableLayout

class ViewController: UIViewController, MZTableLayoutDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var collectionView: UICollectionView?
    var tableLayout: MZTableLayout?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableLayout = MZTableLayout.init()
        tableLayout?.delegate = self
        collectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height-200), collectionViewLayout: tableLayout!)
        collectionView?.register(UINib.init(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView?.backgroundColor = .lightGray
        collectionView?.delegate = self;
        collectionView?.dataSource = self;
        collectionView?.isDirectionalLockEnabled = true
        collectionView?.bounces = false
        self.view.addSubview(collectionView!)
    }
    
    //MARK: - MZTableLayoutDelegate
    func baseSize(_ collectionView: UICollectionView) -> CGSize {
        return CGSize.init(width: UIScreen.main.bounds.size.width/2.0, height: (UIScreen.main.bounds.size.height-200)/4.0)
    }
    
    func totalScale(_ colletionView: UICollectionView) -> (Int, Int) {
        return (2, 4)
    }
    
    func mzLayout(_ colletionView: UICollectionView, cellSizeOf index: Int) -> (Int, Int) {
        if index == 1 {
            return (1, 2)
        } else if index == 3 {
            return (2, 1)
        }
        return (1, 1)
    }
    
    func frozenUnit(_ colletionView: UICollectionView) -> (Int, Int) {
        return (0, 0)
    }
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.title.text = String.init(indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
}

