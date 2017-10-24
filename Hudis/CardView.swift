//
//  CardView.swift
//  Hudis
//
//  Created by Lukas Bühler on 23.10.17.
//  Copyright © 2017 Lukas Bühler. All rights reserved.
//

import UIKit

class CardView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var outerCard: UIView!
    @IBOutlet weak var innerCard: UIView!
    
    @IBOutlet weak var cardTitleLabel: UILabel!
    @IBOutlet weak var holderNameLabel: UILabel!
    @IBOutlet weak var infoTable: UITableView!
    
    var startingPoint = CGPoint();
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        commonInit(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        commonInit(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
        print("oiii");
    }
    
    
    private func commonInit(frame: CGRect)
    {
        Bundle.main.loadNibNamed("CardView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = frame;
        
        self.startingPoint = self.center;
        
        self.outerCard.clipsToBounds = false
        self.outerCard.layer.shadowColor = UIColor.black.cgColor
        self.outerCard.layer.shadowOpacity = 1
        self.outerCard.layer.shadowOffset = CGSize.zero
        self.outerCard.layer.shadowRadius = 15
        self.outerCard.layer.shadowPath = UIBezierPath(roundedRect: self.outerCard.bounds, cornerRadius: 15).cgPath

        self.innerCard.clipsToBounds = true
        self.innerCard.layer.cornerRadius = 15
    }

    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {
        let card = sender.view!
        let point = sender.translation(in: self)
        card.center = CGPoint(x: self.startingPoint.x+point.x, y: self.startingPoint.y+point.y)
        
        if(sender.state == UIGestureRecognizerState.ended)
        {
            if(card.center.y >= (self.frame.height-275))
            {
                // The card is so far down, just let it go away
                
                // However, calculate the time from the velocity
                let velocityY = sender.velocity(in: self).y;
                var duration = Double(self.frame.height / velocityY);
                if(duration > 0.5)
                {
                    duration = 0.5;
                }
                
                print("Hide me")
                //hideCardWithAnimation(card: card, time: duration);
            }
            else
            {
                print("Put me back")
                //showCardWithAnimation(card: card, time: 0.3);
            }
        }
    }
    
    @IBAction func blockButtonAction(_ sender: UIBarButtonItem) {
        
    }
    @IBAction func detailsButtonAction(_ sender: UIBarButtonItem) {
        
    }
    @IBAction func saveButtonAction(_ sender: UIBarButtonItem) {
        
    }
}
