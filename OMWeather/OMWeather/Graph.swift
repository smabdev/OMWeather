//
//  Graph_class.swift
//  OMWeather
//
//  Created by Alex on 19.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit
import Foundation

class Graph {
    
    var imageView = UIImageView()
    var itemWidth: CGFloat = 0
    var itemHeight: CGFloat = 0
    var itemFont = UIFont()
    

    // координаты в точках
    var maxValuesPosY = Array(repeating: CGFloat(), count: 5)
    var minValuesPosY = Array(repeating: CGFloat(), count: 5)
    var posX = [CGFloat]()
    
    // значения
    var maxValues = [CGFloat]()
    var minValues = [CGFloat]()
    
    // отступ от краев graphView по Y
    var tabValue = CGFloat()
    var button = 0
    
    
    init () { }
    
    init (imageView: UIImageView, itemSize: CGSize, font: UIFont) {
        self.imageView = imageView
        self.itemWidth = itemSize.width
        self.itemHeight = itemSize.height
        self.itemFont = font
        self.tabValue = itemSize.height*2
        
        for i in -2 ..< 3 {
            posX.append( imageView.center.x + CGFloat(i) * itemWidth )
        }
    }
    
    
    
    // рассчитывает координаты для графиков
    func calculate (forButton button: Int) {
        
        self.button = button
        maxValues = [store.for5Days[0][button], store.for5Days[1][button], store.for5Days[2][button], store.for5Days[3][button], store.for5Days[4][button]]
        minValues = [store.for5Days[0][button+4], store.for5Days[1][button+4], store.for5Days[2][button+4], store.for5Days[3][button+4], store.for5Days[4][button+4]]
        
        let mediumValue =  (maxValues.max()! - minValues.min()!) / 2
        var ptForValue = (imageView.frame.height - tabValue*2) / (mediumValue*2)
        if ptForValue.isFinite == false {
            ptForValue = 1
        }
        
        for i in 0 ..< maxValues.count {
            maxValuesPosY[i] = (tabValue + (maxValues.max()! - store.for5Days[i][button]) * ptForValue )
            
            minValuesPosY[i] = (imageView.frame.height - tabValue - (store.for5Days[i][button+4] - minValues.min()!) * ptForValue )
        }
    }
    
    
    // рисует графики
    func drawGraph() {
        
        // очистка
        for subView in imageView.subviews {
            subView.removeFromSuperview()
        }
        
        UIGraphicsBeginImageContext(imageView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        context?.clear(imageView.frame)
        
        context?.setStrokeColor(UIColor.red.cgColor)
        drawGraphLine(context: context!, description: "max")
        context?.setStrokeColor(UIColor.blue.cgColor)
        drawGraphLine(context: context!, description: "min")
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        context?.synchronize()
    }
    
    
    
    // рисует график, точки и их значения
    func drawGraphLine(context: CGContext, description: String) {
        
        var values = [CGFloat]()
        var valuesPosY = [CGFloat]()
        var labelYCorrection = CGFloat()
        
        switch description {
        case "max":
            values = maxValues
            valuesPosY = maxValuesPosY
            labelYCorrection = -itemHeight-5
        case "min":
            values = minValues
            valuesPosY = minValuesPosY
            labelYCorrection = 5
        default: return
        }
        
        let path = UIBezierPath()
        path.lineWidth = 2.0
        
        for i in 0 ... posX.count-1 {
            switch i {
            case 0:
                path.move(to: CGPoint(x: posX[i] - imageView.frame.origin.x, y: valuesPosY[i]))
            default:
                path.addLine(to: CGPoint(x: posX[i] - imageView.frame.origin.x, y: valuesPosY[i]))
            }
        }
    
        path.stroke()
        path.removeAllPoints()
       
        
        
        
        for i in 0..<posX.count {
            context.fillEllipse(in: CGRect(x: posX[i] - imageView.frame.origin.x - 3, y: valuesPosY[i]-3, width: 6, height: 6))
            
            let label = UILabel(frame: CGRect(x: posX[i] - imageView.frame.origin.x - itemWidth/2, y: valuesPosY[i] + labelYCorrection, width: itemWidth, height: itemHeight))
            label.textAlignment = .center
            label.font = itemFont
            
            switch button {
            case 0...2:     label.text = (Int(values[i])).description
            case 3:         label.text = String(format: "%.1f", values[i] )
            default:        return
            }
            
            imageView.addSubview(label)
        }
    }
    
    
    
}

