//
//  MZTableLayout.swift
//  MZTableLayout
//
//  Created by zhangle on 2019/8/15.
//

import UIKit

public protocol MZTableLayoutDelegate: class {
    
    /// 表格的基本宽度，1个单位长度实际的像素值，格式(float, float)，例：(50, 50)
    func baseSize(_ collectionView: UICollectionView) -> CGSize
    
    //// 表格的规模大小，格式(int, int)，例：(4, 5)，表示表格总体宽4个单位，高5个单位
    func totalScale(_ colletionView: UICollectionView) -> (Int, Int)
    
    //// 每个cell的大小，用单位个数表示，格式(int, int)，例：(2, 1)，表示当前索引的元素宽2个单位，高1个单位
    func mzLayout(_ colletionView: UICollectionView, cellSizeOf index: Int) -> (Int, Int)
    
    //// 需要冻结的行列，格式(int, int)，例：(1,1)，表示第0行和第0列被冻结，可参照Excel的冻结规则
    //// 不需要冻结时，请设置为（0，0）
    func frozenUnit(_ colletionView: UICollectionView) -> (Int, Int)
}

public class MZTableLayout: UICollectionViewLayout {
    
    public weak var delegate: MZTableLayoutDelegate?
    public var itemMargin: CGFloat = 0
    public var itemSpacing: CGFloat = 0
    var itemAttributes = [UICollectionViewLayoutAttributes]()
    var contentSize = CGSize.init(width: 0, height: 0)
    
    override public func prepare() {
        
        super.prepare()
        
        // 有无数据都需要初始化，因为有复用
        itemAttributes.removeAll()
        
        // 没有元素，返回
        if self.collectionView?.numberOfItems(inSection: 0) == 0 {
            return
        }
        
        //获取需要冻结的行列坐标
        let frozenUnit = (delegate?.frozenUnit(self.collectionView!))!
        let scale = (delegate?.totalScale(self.collectionView!))!
        let baseSize = (delegate?.baseSize(self.collectionView!))!

        //根据规模和基本单位，可以确定content size的大小
        contentSize = CGSize.init(width: CGFloat(scale.0) * baseSize.width + CGFloat(scale.0 - 1) * itemSpacing + 2 * itemMargin,
                                  height: CGFloat(scale.1) * baseSize.height + CGFloat(scale.1 - 1) * itemSpacing + 2 * itemMargin)
        
        //根据规模生成占位数组,例如 3 * 3 的规模
        //  [ [1, 1, 1],
        //    [1, 1, 1],
        //    [1, 1, 1] ]
        var seatArray = [Any]()
        for _ in 0..<scale.1 {
            let rowArray = Array.init(repeating: 1, count: scale.0)
            seatArray.append(rowArray)
        }

        //初始化
        var xOffset = 0; //元素的x坐标(单位坐标系)
        var yOffset = 0; //元素的y坐标

        var endFlag = 0; //结束标志，0=未结束；1=超出范围，结束；2=空间不足，异常退出
        for index in 0..<self.collectionView!.numberOfItems(inSection: 0) {
            let indexPath = IndexPath.init(row: index, section: 0)
            let attributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
            let curItemScale = delegate?.mzLayout(self.collectionView!, cellSizeOf: index)
            var isFind = false //当前索引的元素是否正确插入
            
            var tempX_single = xOffset; //单次寻位的坐标
            var tempY_single = yOffset;
            while !isFind && endFlag == 0 {
                let isFind_single = findTheRightPlace(curItemScale!, &seatArray, tempX_single, tempY_single)
                if !isFind_single {
                    //移向下一个检查起点
                    tempX_single += 1
                    if tempX_single >= scale.0 {
                        tempX_single = 0
                        tempY_single += 1
                    }
                    if tempY_single >= scale.1 {
                        //超出范围，结束
                        endFlag = 1
                    }
                } else {
                    isFind = true;
                    //生成位置属性，保存
                    var atWidth = CGFloat(tempX_single) * baseSize.width + CGFloat(tempX_single) * itemSpacing + itemMargin;
                    var atHeight = CGFloat(tempY_single) * baseSize.height + CGFloat(tempY_single) * itemSpacing + itemMargin;
                    //冻结行列的坐标偏移
                    if frozenUnit.0 != 0 || frozenUnit.1 != 0 {
                        if tempX_single < frozenUnit.0 && tempY_single < frozenUnit.1 {
                            atWidth += (self.collectionView?.contentOffset.x)!;
                            atHeight += (self.collectionView?.contentOffset.y)!;
                            attributes.zIndex = 1024;
                        } else if tempX_single < frozenUnit.0 {
                            atWidth += (self.collectionView?.contentOffset.x)!;
                            attributes.zIndex = 1023;
                        } else if tempY_single < frozenUnit.1 {
                            atHeight += (self.collectionView?.contentOffset.y)!;
                            attributes.zIndex = 1023;
                        }
                    }
                    attributes.frame = CGRect.init(x: atWidth,
                                                   y: atHeight,
                                                   width: CGFloat(curItemScale!.0) * baseSize.width + CGFloat(curItemScale!.0 - 1) * itemSpacing,
                                                   height: CGFloat(curItemScale!.1) * baseSize.height + CGFloat(curItemScale!.1 - 1) * itemSpacing)
                    itemAttributes.append(attributes)
                    //移向下一个元素位置
                    xOffset = tempX_single + curItemScale!.0
                    yOffset = tempY_single
                    if xOffset >= scale.0 {
                        xOffset = 0
                        yOffset += 1
                    }
                    if yOffset >= scale.1 && index+1 != self.collectionView!.numberOfItems(inSection: 0) {
                        endFlag = 2
                    }
                }
            } // while-end
            if endFlag == 2 {
                break;
            }
        }// for-end
        if endFlag == 2 {
            //异常退出时，所有布局显示为空
            itemAttributes.removeAll()
            for i in 0..<self.collectionView!.numberOfItems(inSection: 0) {
                let indexPath = IndexPath.init(row: i, section: 0)
                let attribute = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
                attribute.frame = CGRect.init(x: 0, y: 0, width: 0, height: 0);
                itemAttributes.append(attribute)
            }
        }
    }//prepare-end
    
    //单个元素寻位
    func findTheRightPlace(_ itemScale: (Int, Int), _ seatArray: inout Array<Any>, _ startX: Int, _ startY: Int) -> Bool {
        var tempSeatArray = [CGSize]()
        var isAllSeatAvailable = true
        for m in 0..<itemScale.1 {
            var isRestart = false; //外循环停止标志
            let tempY = startY + m;
            for n in 0..<itemScale.0 {
                let tempX = startX + n;
                //超出数组范围，寻位失败
                let firstArray = seatArray[0] as! Array<Int>
                let rowCount = firstArray.count
                if tempY >= seatArray.count || tempX >= rowCount {
                    isRestart = true;
                    isAllSeatAvailable = false;
                    break;
                }
                let rowArray = seatArray[tempY] as! Array<Int>
                if rowArray[tempX] == 1 {
                    let seatLocation = CGSize.init(width: tempX, height: tempY)
                    tempSeatArray.append(seatLocation)
                } else {
                    //停止内层循环，告知此次寻位失败
                    isRestart = true;
                    isAllSeatAvailable = false;
                    break;
                }
            }//n-for-end
            //停止外层循环
            if isRestart {
                break
            }
        }//m-for-end
        if isAllSeatAvailable {
            //找到正确位置，flag占位
            for i in 0..<tempSeatArray.count {
                let seatLocation = tempSeatArray[i]
                let x = Int(seatLocation.width)
                let y = Int(seatLocation.height)
                var rowArray = seatArray[y] as! Array<Int>
                rowArray[x] = 0
                seatArray[y] = rowArray
            }
            return true
        } else {
            return false
        }
    }//findTheRightPlace-end
    
    //// 返回在指定rect内的布局属性
    //// 这里是通过判断元素的frame和rect是否有交集来确定是否需要显示
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = itemAttributes.filter { (attribute) -> Bool in
            rect.intersects(attribute.frame)
        }
        return attributes
    }
    
    //// 返回每个位置的布局属性
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return itemAttributes[indexPath.row]
    }
    
    //// 返回整个content size的大小
    override public var collectionViewContentSize: CGSize {
        get {
            return contentSize
        }
    }
    
    //// 当边界值改变时，是否刷新
    //// 返回yes则会在每次滚动时调用prepareLayout
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}//class-end
