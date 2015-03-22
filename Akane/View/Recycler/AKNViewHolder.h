//
// This file is part of Akkane
//
// Created by JC on 22/03/15.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code
//

#import <UIKit/UIKit.h>

@protocol AKNViewHolder <NSObject>

@property(nonatomic, readonly, strong)UIView    *contentView;
@property(nonatomic, strong)UIView              *backgroundView;
@property(nonatomic, strong)UIView              *selectedBackgroundView;

@end