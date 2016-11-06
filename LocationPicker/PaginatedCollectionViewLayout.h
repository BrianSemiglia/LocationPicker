//
//  PaginatedCollectionViewLayout.h
//
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface PaginatedCollectionViewLayout : UICollectionViewFlowLayout

@property (nonatomic) IBInspectable CGFloat leftSectionInset;
@property (nonatomic) IBInspectable CGFloat rightSectionInset;
@property (nonatomic) IBInspectable CGFloat interspacing;

@end
