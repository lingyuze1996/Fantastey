//
//  AboutVC.swift
//  Fantastey
//
//  Created by Zoe on 5/11/20.
//  Copyright © 2020 Yuze Ling. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {

    @IBOutlet weak var teamMember1img: UIImageView!
    @IBOutlet weak var teamMember2img: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        teamMember1img.image = UIImage(named: "teamMember2.pic")
        teamMember2img.image = UIImage(named: "teamMember1.pic")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
