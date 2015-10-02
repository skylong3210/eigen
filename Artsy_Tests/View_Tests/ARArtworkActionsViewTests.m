#import "ARArtworkActionsView.h"
#import "ARAuctionBidderStateLabel.h"
#import "ORStackView+ArtsyViews.h"
#import "ARArtworkPriceView.h"
#import "ARArtworkAuctionPriceView.h"


@interface ARArtworkActionsView ()
@property (nonatomic, strong) Artwork *artwork;
@property (nonatomic, strong) SaleArtwork *saleArtwork;
@property (nonatomic, strong) ARBorderLabel *bidderStatusLabel;
@property (nonatomic, strong) ARArtworkPriceView *priceView;
@property (nonatomic, strong) ARArtworkAuctionPriceView *auctionPriceView;
- (void)updateUI;
- (void)setupCountdownView;

- (void)tappedContactGallery:(id)sender;
- (void)tappedContactRepresentative:(id)sender;
- (void)tappedAuctionInfo:(id)sender;
- (void)tappedConditionsOfSale:(id)sender;
- (void)tappedBidButton:(id)sender;
- (void)tappedBuyersPremium:(id)sender;
- (void)tappedBuyButton:(id)sender;
- (void)tappedAuctionResults:(id)sender;
- (void)tappedMoreInfo:(id)sender;
@end

SpecBegin(ARArtworkActionsView);

__block ARArtworkActionsView *view = nil;
__block id mockView = nil;

beforeEach(^{
    view = [[ARArtworkActionsView alloc] initWithFrame:CGRectMake(0, 0, 320, 310)];
    mockView = [OCMockObject partialMockForObject:view];
    [[mockView stub] setupCountdownView];
});

afterEach(^{
    [mockView stopMocking];

    // Explicitely release the view now so that it won’t receive anymore notifications
    // from e.g. ARAuctionWebViewController.
    view = nil;
});

it(@"displays contact gallery for a for sale artwork", ^{
    view.artwork = [Artwork modelWithJSON:@{
       @"id" : @"artwork-id",
       @"title" : @"Artwork Title",
       @"availability" : @"for sale"
    }];
    [view updateUI];
    [view ensureScrollingWithHeight:CGRectGetHeight(view.bounds)];
    expect(view).to.haveValidSnapshotNamed(@"forSale");
});

it(@"displays buy now for an acquireable work with pricing", ^{
    view.artwork = [Artwork modelWithJSON:@{
        @"id" : @"artwork-id",
        @"title" : @"Artwork Title",
        @"availability" : @"for sale",
        @"acquireable" : @YES
    }];
    [view updateUI];
    [view ensureScrollingWithHeight:CGRectGetHeight(view.bounds)];
    expect(view).to.haveValidSnapshotNamed(@"buy");
});

it(@"displays contact seller when the partner is not a gallery", ^{
    view.artwork = [Artwork modelWithJSON:@{
       @"id" : @"artwork-id",
       @"title" : @"Artwork Title",
       @"availability" : @"for sale",
       @"partner" : @{
               @"id" : @"partner_id",
               @"type" : @"Museum",
               @"name" : @"Guggenheim Museum"
       }
    }];
    [view updateUI];
    [view ensureScrollingWithHeight:CGRectGetHeight(view.bounds)];
    expect(view).to.haveValidSnapshotNamed(@"forSaleByAnInstitution");
});

it(@"does not display contact when artwork is in auction", ^{
    view.artwork = [Artwork modelWithJSON:@{
        @"id" : @"artwork-id",
        @"title" : @"Artwork Title",
        @"availability" : @"for sale",
        @"inquireable" : @YES
    }];
    view.saleArtwork = [SaleArtwork modelWithJSON:@{
        @"high_estimate_cents" : @20000,
        @"low_estimate_cents" : @10000
    }];
    [view updateUI];
    [view ensureScrollingWithHeight:CGRectGetHeight(view.bounds)];
    [view snapshotViewAfterScreenUpdates:YES];
    expect(view).to.haveValidSnapshotNamed(@"forSaleAtAuction");
});

it(@"displays both bid and buy when artwork is in auction and is acquireable", ^{
    view.artwork = [Artwork modelWithJSON:@{
        @"id" : @"artwork-id",
        @"title" : @"Artwork Title",
        @"availability" : @"for sale",
        @"price" : @"$5,000",
        @"sold" : @NO,
        @"acquireable" : @YES
    }];
    view.saleArtwork = [SaleArtwork modelWithJSON:@{
        @"high_estimate_cents" : @20000,
        @"low_estimate_cents" : @10000
    }];
    view.saleArtwork.auction = [Sale modelWithJSON:@{
        @"start_at" : @"1-12-30 00:00:00",
        @"end_at" : @"4001-01-01 00:00:00"
    }];
    [view updateUI];
    [view snapshotViewAfterScreenUpdates:YES];
    expect(view).to.haveValidSnapshotNamed(@"acquireableAtAuction");
});

it(@"shows a buyers premium notice", ^{
    view.artwork = [Artwork modelWithJSON:@{
        @"id" : @"artwork-id",
        @"title" : @"Artwork Title",
        @"availability" : @"for sale",
        @"price" : @"$5,000",
        @"sold" : @NO,
        @"acquireable" : @YES
    }];
    view.saleArtwork = [SaleArtwork modelWithJSON:@{
        @"high_estimate_cents" : @20000,
        @"low_estimate_cents" : @10000
    }];
    view.saleArtwork.auction = [Sale modelWithJSON:@{
        @"start_at" : @"1-12-30 00:00:00",
        @"end_at" : @"4001-01-01 00:00:00",
        @"buyers_premium" : @{ }
    }];
    [view updateUI];
    [view snapshotViewAfterScreenUpdates:YES];
    expect(view).to.haveValidSnapshot();
});

it(@"displays sold when artwork is in auction and has been acquired", ^{
    view.artwork = [Artwork modelWithJSON:@{
        @"id" : @"artwork-id",
        @"title" : @"Artwork Title",
        @"availability" : @"sold",
        @"sold" : @YES,
        @"price" : @"$5,000",
        @"acquireable" : @NO
    }];
    view.saleArtwork = [SaleArtwork modelWithJSON:@{
        @"high_estimate_cents" : @20000,
        @"low_estimate_cents" : @10000
    }];
    view.saleArtwork.auction = [Sale modelWithJSON:@{
        @"start_at" : @"1-12-30 00:00:00",
        @"end_at" : @"4001-01-01 00:00:00"
    }];
    [view updateUI];
    [view ensureScrollingWithHeight:CGRectGetHeight(view.bounds)];
    [view snapshotViewAfterScreenUpdates:YES];
    expect(view).will.haveValidSnapshotNamed(@"soldAtAuction");
});

context(@"bidderStatus", ^{
    __block ARAuctionBidderStateLabel *bidderStateView;

    it(@"high bidder", ^{
        Bid *highBid = [Bid modelWithJSON:@{ @"id" : @"abc", @"amount_cents" : @(10000000) }];
        SaleArtwork *saleArtwork = [SaleArtwork saleArtworkWithHighBid:highBid AndReserveStatus:ARReserveStatusNoReserve];
        BidderPosition *highPosition = [BidderPosition modelFromDictionary:@{ @"highestBid" : highBid, @"maxBidAmountCents" : highBid.cents }];
        highPosition.highestBid = highBid;
        saleArtwork.positions = @[ highPosition ];
        bidderStateView = [[ARAuctionBidderStateLabel alloc] initWithFrame:CGRectMake(0, 0, 280, 58)];
        [bidderStateView updateWithSaleArtwork:saleArtwork];
        expect(bidderStateView).to.haveValidSnapshotNamed(@"testHighBidder");
    });

    it(@"outbid", ^{
        Bid *highBid = [Bid modelWithJSON:@{ @"id" : @"abc", @"amount_cents" : @(10000000) }];
        SaleArtwork *saleArtwork = [SaleArtwork saleArtworkWithHighBid:highBid AndReserveStatus:ARReserveStatusNoReserve];
        BidderPosition *lowPosition = [BidderPosition modelWithJSON:@{ @"max_bid_amount_cents" : @(100) }];
        saleArtwork.positions = @[ lowPosition ];
        bidderStateView = [[ARAuctionBidderStateLabel alloc] initWithFrame:CGRectMake(0, 0, 280, 37)];
        [bidderStateView updateWithSaleArtwork:saleArtwork];
        expect(bidderStateView).to.haveValidSnapshotNamed(@"testOutbid");
    });
});

context(@"price view", ^{
    context(@"not at auction", ^{
        it(@"price", ^{
            view.artwork = [Artwork modelFromDictionary:@{ @"price" : @"$30,000", @"inquireable" : @(true)}];
            [view updateUI];
            [view ensureScrollingWithHeight:CGRectGetHeight(view.bounds)];
            [view layoutIfNeeded];
            expect(view.priceView).to.haveValidSnapshot();
        });

        it(@"sold", ^{
            view.artwork = [Artwork modelFromDictionary:@{ @"price" : @"$30,000", @"sold" : @(true) }];
            [view updateUI];
            [view ensureScrollingWithHeight:CGRectGetHeight(view.bounds)];
            [view layoutIfNeeded];
            expect(view.priceView).to.haveValidSnapshot();
        });

        it(@"sold but inquireable", ^{
            view.artwork = [Artwork modelFromDictionary:@{ @"sold" : @(true), @"inquireable": @(true), @"forSale": @(false) }];
            [view updateUI];
            [view ensureScrollingWithHeight:CGRectGetHeight(view.bounds)];
            [view layoutIfNeeded];
            expect(view.priceView).to.haveValidSnapshot();
        });

        it(@"contact for price", ^{
            view.artwork = [Artwork modelFromDictionary:@{ @"price" : @"$30,000", @"inquireable" : @(true), @"availability" : @(ARArtworkAvailabilityForSale), @"isPriceHidden" : @(true) }];
            [view updateUI];
            [view ensureScrollingWithHeight:CGRectGetHeight(view.bounds)];
            [view layoutIfNeeded];
            expect(view.priceView).to.haveValidSnapshot();
        });
        it(@"contact for price with no price", ^{
            view.artwork = [Artwork modelFromDictionary:@{ @"inquireable" : @(true), @"availability" : @(ARArtworkAvailabilityForSale), @"isPriceHidden" : @(true) }];
            [view updateUI];
            [view ensureScrollingWithHeight:CGRectGetHeight(view.bounds)];
            [view layoutIfNeeded];
            expect(view.priceView).to.haveValidSnapshot();
        });
    });
    context(@"at auction", ^{
        it(@"no bids", ^{
            view.saleArtwork = [SaleArtwork modelWithJSON:@{ @"opening_bid_cents" : @(1000000) }];
            view.artwork = [Artwork modelFromDictionary:@{ @"sold" : @(false) }];
            [view updateUI];
            [view ensureScrollingWithHeight:CGRectGetHeight(view.bounds)];
            [view layoutIfNeeded];
            expect(view.auctionPriceView).to.haveValidSnapshot();
        });

        it(@"has bids", ^{
            Bid *highBid = [Bid modelWithJSON:@{ @"id" : @"abc", @"amount_cents" : @(10000000) }];
            expect(highBid.cents).to.equal(10000000);
            view.saleArtwork = [SaleArtwork saleArtworkWithHighBid:highBid AndReserveStatus:ARReserveStatusNoReserve];;
            expect(view.saleArtwork.saleHighestBid.cents).to.equal(10000000);
            view.artwork = [Artwork modelFromDictionary:@{ @"sold" : @(false) }];
            [view updateUI];
            [view ensureScrollingWithHeight:CGRectGetHeight(view.bounds)];
            [view layoutIfNeeded];
            expect(view.auctionPriceView).to.haveValidSnapshot();
        });

        it(@"reserve met and has bids", ^{
            Bid *highBid = [Bid modelWithJSON:@{ @"id" : @"abc", @"amount_cents" : @(10000000) }];
            view.saleArtwork = [SaleArtwork saleArtworkWithHighBid:highBid AndReserveStatus:ARReserveStatusReserveMet];
            view.artwork = [Artwork modelFromDictionary:@{ @"sold" : @(false) }];
            [view updateUI];
            [view ensureScrollingWithHeight:CGRectGetHeight(view.bounds)];
            [view layoutIfNeeded];
            expect(view.auctionPriceView).to.haveValidSnapshot();
        });

        it(@"current auction reserve not met and has bids", ^{
            Bid *highBid = [Bid modelWithJSON:@{ @"id" : @"abc", @"amount_cents" : @(10000000) }];
            view.saleArtwork = [SaleArtwork saleArtworkWithHighBid:highBid AndReserveStatus:ARReserveStatusReserveNotMet];
            view.saleArtwork.auction = [Sale modelWithJSON:@{ @"start_at" : @"1-12-30 00:00:00", @"end_at" : @"4001-01-01 00:00:00" }];
            view.artwork = [Artwork modelFromDictionary:@{ @"sold" : @(false) }];
            [view updateUI];
            [view ensureScrollingWithHeight:CGRectGetHeight(view.bounds)];
            [view layoutIfNeeded];
            expect(view.auctionPriceView).to.haveValidSnapshot();
        });
        
        it(@"reserve not met and has no bids", ^{
            view.saleArtwork = [SaleArtwork modelWithJSON:@{ @"opening_bid_cents" : @(1000000), @"reserve_status" : @"reserve_not_met" }];
            view.saleArtwork.auction = [Sale modelWithJSON:@{ @"start_at" : @"1-12-30 00:00:00", @"end_at" : @"1-12-30 00:00:00" }];
            view.artwork = [Artwork modelFromDictionary:@{ @"sold" : @(false) }];
            [view updateUI];
            [view ensureScrollingWithHeight:CGRectGetHeight(view.bounds)];
            [view layoutIfNeeded];
            expect(view.auctionPriceView).to.haveValidSnapshot();
        });
    });
});

describe(@"mocked artwork promises", ^{
    beforeEach(^{
        id artwork = [OCMockObject mockForClass:[Artwork class]];
        [[[artwork stub] andReturn:[KSPromise new]] onArtworkUpdate:OCMOCK_ANY failure:OCMOCK_ANY];
        [[[artwork stub] andReturn:[KSPromise new]] onSaleArtworkUpdate:OCMOCK_ANY failure:OCMOCK_ANY];

        view.artwork = artwork;
    });

    it(@"forwards contact gallery to delegate", ^{
        id mockDelegate = [OCMockObject mockForProtocol:@protocol(ARArtworkActionsViewButtonDelegate)];
        view.delegate = mockDelegate;

        [[mockDelegate expect] tappedContactGallery];
        [view tappedContactGallery:nil];

        [mockDelegate verify];
    });

    it(@"forwards contact specialist to delegate", ^{
        id mockDelegate = [OCMockObject mockForProtocol:@protocol(ARArtworkActionsViewButtonDelegate)];
        view.delegate = mockDelegate;

        [[mockDelegate expect] tappedContactRepresentative];
        [view tappedContactRepresentative:nil];

        [mockDelegate verify];
    });

    it(@"forwards auction info to delegate", ^{
        id mockDelegate = [OCMockObject mockForProtocol:@protocol(ARArtworkActionsViewButtonDelegate)];
        view.delegate = mockDelegate;

        [[mockDelegate expect] tappedAuctionInfo];
        [view tappedAuctionInfo:nil];

        [mockDelegate verify];
    });

    it(@"forwards conditions of sale to delegate", ^{
        id mockDelegate = [OCMockObject mockForProtocol:@protocol(ARArtworkActionsViewButtonDelegate)];
        view.delegate = mockDelegate;

        [[mockDelegate expect] tappedConditionsOfSale];
        [view tappedConditionsOfSale:nil];

        [mockDelegate verify];
    });

    it(@"forwards bid button to delegate", ^{
        id mockDelegate = [OCMockObject mockForProtocol:@protocol(ARArtworkActionsViewButtonDelegate)];
        view.delegate = mockDelegate;

        [[mockDelegate expect] tappedBidButton];
        [view tappedBidButton:nil];

        [mockDelegate verify];
    });

    it(@"forwards buyers premium to delegate", ^{
        id mockDelegate = [OCMockObject mockForProtocol:@protocol(ARArtworkActionsViewButtonDelegate)];
        view.delegate = mockDelegate;

        [[mockDelegate expect] tappedBuyersPremium];
        [view tappedBuyersPremium:nil];

        [mockDelegate verify];
    });

    it(@"forwards buy button to delegate", ^{
        id mockDelegate = [OCMockObject mockForProtocol:@protocol(ARArtworkActionsViewButtonDelegate)];
        view.delegate = mockDelegate;

        [[mockDelegate expect] tappedBuyButton];
        [view tappedBuyButton:nil];

        [mockDelegate verify];
    });

    it(@"forwards auction results to delegate", ^{
        id mockDelegate = [OCMockObject mockForProtocol:@protocol(ARArtworkActionsViewButtonDelegate)];
        view.delegate = mockDelegate;

        [[mockDelegate expect] tappedAuctionResults];
        [view tappedAuctionResults:nil];

        [mockDelegate verify];
    });

    it(@"forwards more info to delegate", ^{
        id mockDelegate = [OCMockObject mockForProtocol:@protocol(ARArtworkActionsViewButtonDelegate)];
        view.delegate = mockDelegate;

        [[mockDelegate expect] tappedMoreInfo];
        [view tappedMoreInfo:nil];

        [mockDelegate verify];
    });
});

SpecEnd;
