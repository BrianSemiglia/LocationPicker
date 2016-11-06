//
//  PaginatedCollectionViewLayout.m
//
//

#import "PaginatedCollectionViewLayout.h"

@implementation PaginatedCollectionViewLayout

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposed withScrollingVelocity:(CGPoint)velocity {
  
  CGFloat proposedContentOffsetCenterX = proposed.x + self.collectionView.bounds.size.width * 0.5f;
  CGRect proposedRect = self.collectionView.bounds;
  UICollectionViewLayoutAttributes* candidateAttributes;
  
  for (UICollectionViewLayoutAttributes* attributes in [self layoutAttributesForElementsInRect:proposedRect]) {
    
    // == Skip comparison with non-cell items (headers and footers) == //
    if (attributes.representedElementCategory != UICollectionElementCategoryCell) {
      continue;
    }
    
    // == First time in the loop == //
    if (!candidateAttributes) {
      candidateAttributes = attributes;
      continue;
    }
    
    if (fabs(attributes.center.x - proposedContentOffsetCenterX) < fabs(candidateAttributes.center.x - proposedContentOffsetCenterX)) {
      candidateAttributes = attributes;
    }
  }
  
  if (candidateAttributes) {
    return CGPointMake(candidateAttributes.center.x - self.collectionView.bounds.size.width * 0.5f, proposed.y);
  } else {
    return [super targetContentOffsetForProposedContentOffset:proposed withScrollingVelocity:velocity];
  }
}

- (void)awakeFromNib {
  [super awakeFromNib];
  self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
  self.minimumLineSpacing = self.interspacing;
  self.sectionInset = UIEdgeInsetsMake(0, self.leftSectionInset, 0, self.rightSectionInset);
}

@end
