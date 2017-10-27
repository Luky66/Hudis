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
    @IBOutlet weak var innerCard: UIView!
    
    @IBOutlet weak var cardTitleLabel: UILabel!
    @IBOutlet weak var holderNameLabel: UILabel!
    @IBOutlet weak var infoTable: UITableView!
    
    var focusPoint = CGPoint();
    var vc = ViewController();
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        commonInit(frame: frame)
    }
    
    init(frame: CGRect, viewController: ViewController)
    {
        self.vc = viewController;
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
        vc.view.addSubview(contentView)
        contentView.frame = frame;
        
        self.focusPoint = self.center;
        
        
        // Shadow
        self.contentView.clipsToBounds = false
        self.contentView.layer.shadowColor = UIColor.black.cgColor
        self.contentView.layer.shadowOpacity = 1
        self.contentView.layer.shadowOffset = CGSize.zero
        self.contentView.layer.shadowRadius = 15
        self.contentView.layer.shadowPath = UIBezierPath(roundedRect: self.contentView.bounds, cornerRadius: 15).cgPath

        self.innerCard.clipsToBounds = true
        self.innerCard.layer.cornerRadius = 15
     

        self.setBelowFocusPoint()
    }
    
    @IBAction func blockButtonAction(_ sender: UIBarButtonItem) {
        
    }
    @IBAction func detailsButtonAction(_ sender: UIBarButtonItem) {
        
    }
    @IBAction func saveButtonAction(_ sender: UIBarButtonItem) {
        
    }
    
    
    func setBelowFocusPoint()
    {
        self.contentView.center = CGPoint(x: self.focusPoint.x, y: self.focusPoint.y+self.vc.view.bounds.height);
    }
    
    func setOnFocusPoint()
    {
        self.contentView.center = self.focusPoint;
    }
    
    func moveBelowFocusPoint(time: Double)
    {
        UIView.animate(withDuration: time) {
            self.setBelowFocusPoint();
        }
    }
    func moveToFocusPoint(time: Double)
    {
        UIView.animate(withDuration: time) {
            self.setOnFocusPoint();
        }
    }
    func moveLeft(time: Double)
    {
        self.focusPoint.x -= self.vc.cardSlotWidth;
        self.moveToFocusPoint(time: time);
    }
    func moveRight(time: Double)
    {
        self.focusPoint.x += self.vc.cardSlotWidth;
        self.moveToFocusPoint(time: time);
    }
    func dismiss(time: Double)
    {
        // swipes it down and removes it
        
        // move down
        UIView.animate(withDuration: time, animations: {
            self.setBelowFocusPoint();
        }, completion: { finished in
            self.contentView.removeFromSuperview()
        })
    }
    func dismissAndRemove(time: Double)
    {
        self.dismiss(time: time)
        let cardIndex = self.vc.cards.index(of: self)!
        self.vc.cards.remove(at: cardIndex) // remove the current card from the array
        for i in Int(cardIndex)..<self.vc.cards.count-1
        {
            self.vc.cards[i].moveLeft(time: 0.3)
        }
        if(cardIndex >= self.vc.cards.count)
        {
            for card in self.vc.cards {
                card.moveRight(time: 0.3)
            }
        }
    }
    
    
    @IBAction func panCard(_ sender: UIPanGestureRecognizer)
    {
        // sender.view is the current card view being moved
        // self is the card that is moved
        // self.vc is the view controller
        // movement is the translation of the card since panning
        
        let movement = sender.translation(in: self.vc.view)
        
        sender.view!.center.y = self.focusPoint.y+movement.y
        
        for card in self.vc.cards {
            card.contentView.center.x = card.focusPoint.x+movement.x
        }
        
        
        if(sender.state == UIGestureRecognizerState.ended)
        {
            if(sender.view!.center.y >= (self.focusPoint.y+75))
            {
                // The card is so far down, just let it go away

                // However, calculate the time from the velocity
                let velocityY = sender.velocity(in: vc.view!).y;
                var duration = Double(sender.view!.bounds.height / velocityY);

                if(duration > 0.5)
                {
                    duration = 0.5;
                }
                self.dismissAndRemove(time: duration);
            }
            else
            {
                // Check if we have move to a different card slot
                let distanceOffStart = self.vc.cards[0].contentView.center.x-self.vc.cards[0].focusPoint.x
                vc.infoText.text = String(describing: distanceOffStart);
                
                if(distanceOffStart >= self.vc.cardSlotWidth/2)
                {
                    // Move cards right
                    
                    let velocityX = sender.velocity(in: vc.view!).x;
                    var duration = Double(self.vc.cardSlotWidth / velocityX);
                    
                    if(duration > 0.5)
                    {
                        duration = 0.5;
                    }
                    
                    for card in self.vc.cards {
                        card.moveRight(time: duration)
                    }
                    
                    
                }
                else if (distanceOffStart < -self.vc.cardSlotWidth/2)
                {
                    // Move cards left
                    
                    let velocityX = sender.velocity(in: vc.view!).x;
                    var duration = Double(self.vc.cardSlotWidth / velocityX);
                    
                    if(duration > 0.5)
                    {
                        duration = 0.5;
                    }
                    
                    for card in self.vc.cards {
                        card.moveLeft(time: duration)
                    }
                    
                    
                }
                else
                {
                    // put them back where they were
                    for card in self.vc.cards
                    {
                        card.moveToFocusPoint(time: 0.3);
                    }
                }
            }
        }
    }
}

extension UIView
{
    func getCardFromView(allCards: [CardView]) -> CardView?
    {
        for card in allCards {
            if(card.contentView!.superview == self)
            {
                // We found the card for this view
                return card
            }
        }
        return nil
    }
}
