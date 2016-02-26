//
//  ZBJCalendarView.m
//  ZBJCalendar
//
//  Created by wanggang on 2/24/16.
//  Copyright © 2016 ZBJ. All rights reserved.
//

#import "ZBJCalendarView.h"
#import "ZBJCalendarCell.h"
#import "ZBJCalendarHeaderView.h"
#import "NSDate+ZBJAddition.h"

@interface ZBJCalendarView() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *calendarData;

@property (nonatomic, strong) NSCalendar *calendar;


@end

static NSString *headerIdentifier = @"header";

@implementation ZBJCalendarView

- (NSDate *)dateForFirstDayInSection:(NSInteger)section {
    
    NSCalendar *calendar = [NSDate gregorianCalendar];
    
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.month = section;
    return [calendar dateByAddingComponents:dateComponents toDate:[self.firstDate firstDateOfMonth] options:0];
}

- (NSDate *)dateAtIndexPath:(NSIndexPath *)indexPath {
    NSDate *firstDay = [self dateForFirstDayInSection:indexPath.section];
    NSInteger weekDay = [firstDay weekday];
    NSDate *dateToReturn = nil;
    
    if (indexPath.row < (weekDay-1)) {
        dateToReturn = nil;
    } else {
        NSCalendar *calendar = [NSDate gregorianCalendar];

        NSDateComponents *components = [calendar components:NSCalendarUnitMonth | NSCalendarUnitDay fromDate:firstDay];
        [components setDay:indexPath.row - (weekDay - 1)];
        [components setMonth:indexPath.section];
        dateToReturn = [calendar dateByAddingComponents:components toDate:[self.firstDate firstDateOfMonth] options:0];
    }
    return dateToReturn;
}









#pragma  mark - Override

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.collectionView];
    }
    return self;
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSDate *firstDay = [self dateForFirstDayInSection:section];
    NSInteger weekDay = [firstDay weekday] -1;
    NSInteger items =  weekDay + [NSDate numberOfDaysInMonth:firstDay];
    return items;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger months = [NSDate numberOfMonthsFormDate:self.firstDate toDate:self.lastDate];
    return months;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZBJCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"identifier" forIndexPath:indexPath];
    NSDate *date = [self dateAtIndexPath:indexPath];
    
    if (date) {
        NSCalendar *calendar = [NSDate gregorianCalendar];
        NSInteger day = [calendar component:NSCalendarUnitDay fromDate:date];
        cell.dayLabel.text = [NSString stringWithFormat:@"%ld", day];
    } else {
        cell.dayLabel.text = nil;
    }
    return cell;
}

#pragma mark UICollectionViewDelegateFlowLayout

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    ZBJCalendarHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerIdentifier forIndexPath:indexPath];
    
    NSDate *firstDateOfMonth = [self dateForFirstDayInSection:indexPath.section];
    
    NSCalendar *calendar = [NSDate gregorianCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:firstDateOfMonth];
    headerView.calendarLabel.text = [NSString stringWithFormat:@"%ld年%ld月", components.year, components.month];
    return headerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    return CGSizeMake(w, 50);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat w = collectionView.bounds.size.width;
    CGFloat cellWidth = (w - 6) / 7;
    return CGSizeMake(cellWidth, cellWidth);
}

#pragma mark - Getters & Setters

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 1;
        layout.minimumInteritemSpacing = 1;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
         [_collectionView registerClass:[ZBJCalendarCell class] forCellWithReuseIdentifier:@"identifier"];
        [_collectionView registerClass:[ZBJCalendarHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerIdentifier];
    }
    return _collectionView;
}
@end