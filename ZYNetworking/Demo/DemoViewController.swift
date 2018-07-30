//
//  ViewController.swift
//  ZYNetworking
//
//  Created by 殷子欣 on 2018/5/4.
//  Copyright © 2018年 殷子欣. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {

    lazy var demoAPIManager: DemoAPIManager = {
        var tempManager = DemoAPIManager()
        tempManager.delegate = self as ZYAPIManagerCallBackDelegate
        
        return tempManager
    }()
    
    lazy var startRequestButton: UIButton = {
        var tempButton = UIButton.init(type: .custom)
        tempButton.frame = CGRect(x: 40, y: 100, width: 100, height: 100)
        tempButton.setTitle("send request", for: .normal)
        tempButton.setTitleColor(UIColor.blue, for: .normal)
        tempButton.addTarget(self, action: #selector(didTappedStartButton(_:)), for: .touchUpInside)
        
        return tempButton
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.addSubview(startRequestButton)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func didTappedStartButton(_ button: UIButton) {
        demoAPIManager.loadData()
    }
}

extension DemoViewController: ZYAPIManagerCallBackDelegate {
    func managerCallAPIDidSuccess(_ manager: ZYBaseAPIManager!) {
        print(manager.fetchDataWithReformer(reformer: nil) ?? "")
    }
    
    func managerCallAPIDidFailed(_ manager: ZYBaseAPIManager!) {
        print(manager.fetchDataWithReformer(reformer: nil) ?? "")
    }
    
    
}
