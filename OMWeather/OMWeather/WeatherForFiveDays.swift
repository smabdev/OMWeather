//
//  ViewController2.swift
//  OMWeather
//
//  Created by Alex on 14.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit

class WeatherForFiveDays: UIViewController {

    @IBOutlet weak var siteNameLabel: UILabel!
    @IBOutlet weak var panel1: UIView!
    @IBOutlet weak var tempButton: UIButton!
    @IBOutlet weak var tempMaskView: UIView!
    @IBOutlet weak var humidityButton: UIButton!
    @IBOutlet weak var humidityMaskView: UIView!
    @IBOutlet weak var pressureButton: UIButton!
    @IBOutlet weak var pressureMaskView: UIView!
    @IBOutlet weak var windButton: UIButton!
    @IBOutlet weak var windMaskView: UIView!
    @IBOutlet weak var graphImage: UIImageView!
    
    var graph = Graph()
    
    override func viewDidLoad() {
        super.viewDidLoad()

       view.scaleFonts()
        
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "sky-2"))
    
            for  subview in (self.tabBarController?.view.subviews[1].subviews)! {
                if subview is UIControl == false {
                    continue
                }
                let frame = CGRect(origin: CGPoint(x: subview.center.x - 49/2, y: self.view.frame.height-49), size: CGSize(width: 49, height: 49))
                let view = UIView(frame: frame)
                view.backgroundColor = UIColor.white
                view.layer.opacity = 0.3
                view.layer.cornerRadius = 49/3
                self.view.addSubview(view)
            }
 
            self.panel1.layer.borderColor = UIColor.blue.cgColor
            self.panel1.layer.borderWidth = 1
        
            self.graphImage.layer.borderColor = UIColor.blue.cgColor
            self.graphImage.layer.borderWidth = 1
            self.graphImage.layer.cornerRadius = 5
        
            self.tempButton.layer.borderColor = UIColor.blue.cgColor
            self.tempButton.layer.borderWidth = 1
            self.tempButton.layer.cornerRadius = 5
        
            self.humidityButton.layer.borderWidth = 1
            self.humidityButton.layer.cornerRadius = 5
        
            self.pressureButton.layer.borderWidth = 1
            self.pressureButton.layer.cornerRadius = 5
        
            self.windButton.layer.borderWidth = 1
            self.windButton.layer.cornerRadius = 5
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
            graph = Graph(imageView: self.graphImage, itemSize: self.panel1.subviews[0].frame.size, font: (self.tempButton.titleLabel?.font)!)
            setInfoPanels ()
            setButton (button: 0)  // temperature
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func tempClick(_ sender: Any) {
        setButton (button: 0)
    }
    
    @IBAction func humidityClick(_ sender: Any) {
        setButton (button: 1)
    }
    
    @IBAction func pressureClick(_ sender: Any) {
        setButton (button: 2)
    }
    
    @IBAction func windClick(_ sender: Any) {
        setButton (button: 3)
    }
    
    // отрисовка окна с графиком
    func setButton (button: Int) {
        DispatchQueue.main.async {
            self.tempButton.layer.borderColor = UIColor.gray.cgColor
            self.tempButton.backgroundColor = UIColor.lightGray
            self.tempMaskView.backgroundColor = UIColor.clear
            self.humidityButton.layer.borderColor = UIColor.gray.cgColor
            self.humidityButton.backgroundColor = UIColor.lightGray
            self.humidityMaskView.backgroundColor = UIColor.clear
            self.pressureButton.layer.borderColor = UIColor.gray.cgColor
            self.pressureButton.backgroundColor = UIColor.lightGray
            self.pressureMaskView.backgroundColor = UIColor.clear
            self.windButton.layer.borderColor = UIColor.gray.cgColor
            self.windButton.backgroundColor = UIColor.lightGray
            self.windMaskView.backgroundColor = UIColor.clear
            
            switch button {
            case 0:
                self.tempButton.layer.borderColor = UIColor.blue.cgColor
                self.tempButton.backgroundColor = self.graphImage.backgroundColor
                self.tempMaskView.backgroundColor = self.graphImage.backgroundColor
            case 1:
                self.humidityButton.layer.borderColor = UIColor.blue.cgColor
                self.humidityButton.backgroundColor = self.graphImage.backgroundColor
                self.humidityMaskView.backgroundColor = self.graphImage.backgroundColor
            case 2:
                self.pressureButton.layer.borderColor = UIColor.blue.cgColor
                self.pressureButton.backgroundColor = self.graphImage.backgroundColor
                self.pressureMaskView.backgroundColor = self.graphImage.backgroundColor
            case 3:
                self.windButton.layer.borderColor = UIColor.blue.cgColor
                self.windButton.backgroundColor = self.graphImage.backgroundColor
                self.windMaskView.backgroundColor = self.graphImage.backgroundColor
            default: return
            }
            self.graph.calculate(forButton: button)
            self.graph.drawGraph()
            self.graphImage.image = self.graph.imageView.image
        }
    }
    
    
    // дни недели/даты, иконки погоды день/ночь с описанием
    func setInfoPanels () {
        
        DispatchQueue.main.async {
            self.siteNameLabel.text = store.localityName
            
            var i = 0
            repeat {
                (self.view.viewWithTag(200)?.subviews[2*i] as! UILabel).text = store.for5Days[i].weekDay
                (self.view.viewWithTag(200)?.subviews[2*i+1] as! UILabel).text = store.for5Days[i].date
                i += 1
            } while i != 5
        
            i = 0
            repeat {
                (self.view.viewWithTag(300)?.subviews[2*i] as! UIImageView).image = weatherIcons[store.for5Days[i].iconDay]
                (self.view.viewWithTag(300)?.subviews[2*i+1] as! UILabel).text = store.for5Days[i].dayDescription
                i += 1
            } while i != 5
        
            i = 0
            repeat {
                (self.view.viewWithTag(400)?.subviews[2*i] as! UIImageView).image = weatherIcons[store.for5Days[i].iconNight]
                (self.view.viewWithTag(400)?.subviews[2*i+1] as! UILabel).text = store.for5Days[i].nightDescription
                i += 1
            } while i != 5
        }
    
    }
    
  

    

    
    

}

