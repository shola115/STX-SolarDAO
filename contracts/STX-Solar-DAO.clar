

;; Constants and Configuration
(define-constant CONTRACT-OWNER tx-sender)
(define-constant MIN-INVESTMENT u1000000) ;; 1 STX minimum
(define-constant SHARE-SCALE u1000000)    ;; 6 decimal places
(define-constant VOTE-THRESHOLD u75)       ;; 75% threshold for proposals
(define-constant MAINTENANCE-WINDOW u144)  ;; ~24 hours in blocks

;; Error Codes
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-ASSET-EXISTS (err u402))
(define-constant ERR-INVALID-AMOUNT (err u403))
(define-constant ERR-ASSET-NOT-FOUND (err u404))
(define-constant ERR-INSUFFICIENT-SHARES (err u405))
(define-constant ERR-TRANSFER-FAILED (err u406))
(define-constant ERR-NOT-FOUND (err u407))
(define-constant ERR-INVALID-NAME (err u408))
(define-constant ERR-INVALID-ASSET-TYPE (err u409))
(define-constant ERR-INVALID-RECIPIENT (err u410))
(define-constant ERR-SELF-TRANSFER (err u411))
(define-constant ERR-ZERO-SHARES (err u412))
(define-constant ERR-PROPOSAL-ACTIVE (err u413))
(define-constant ERR-PROPOSAL-EXPIRED (err u414))
(define-constant ERR-ALREADY-VOTED (err u415))
(define-constant ERR-INVALID-STATUS (err u416))
(define-constant ERR-INSUFFICIENT-QUORUM (err u417))

;; Data Types
(define-trait asset-owner-trait
  (
    (transfer-ownership (uint principal uint) (response bool uint))
    (claim-revenue (uint) (response uint uint))
  )
)

;; Enhanced Asset Structure
(define-map assets
    { asset-id: uint }
    {
        name: (string-ascii 50),
        asset-type: (string-ascii 20),
        total-shares: uint,
        available-shares: uint,
        share-price: uint,
        total-revenue: uint,
        revenue-per-share: uint,
        status: (string-ascii 10),
        creation-height: uint,
        last-updated: uint,
        location: {
            latitude: int,
            longitude: int
        }
    }
)

;; Enhanced Ownership Structure
(define-map ownership
    { asset-id: uint, owner: principal }
    {
        shares: uint,
        revenue-claimed: uint,
        last-claim-height: uint,
        voting-power: uint
    }
)

;; Enhanced Asset Metrics
(define-map asset-metrics
    { asset-id: uint }
    {
        energy-produced: uint,
        operational-hours: uint,
        maintenance-cost: uint,
        efficiency-rating: uint,
        carbon-offset: uint,
        peak-output: uint,
        lifetime-roi: uint
    }
)

;; Governance Structure
(define-map governance-settings
    { asset-id: uint }
    {
        min-quorum: uint,
        vote-period: uint,
        min-vote-threshold: uint,
        cooldown-period: uint
    }
)

;; Enhanced Proposal System
(define-map proposals
    { asset-id: uint, proposal-id: uint }
    {
        proposer: principal,
        proposal-type: (string-ascii 20),
        description: (string-ascii 500),
        amount: uint,
        votes-for: uint,
        votes-against: uint,
        status: (string-ascii 10),
        start-height: uint,
        end-height: uint,
        execution-delay: uint,
        quorum-reached: bool
    }
)

;; State Variables
(define-data-var asset-counter uint u0)
(define-data-var proposal-counter uint u0)
(define-data-var maintenance-counter uint u0)

;; Private Helper Functions
(define-private (is-valid-name (name (string-ascii 50)))
    (let ((name-length (len name)))
        (and 
            (> name-length u0)
            (<= name-length u50)
            (not (is-eq name "")))))

(define-private (is-valid-asset-type (asset-type (string-ascii 20)))
    (or 
        (is-eq asset-type "solar")
        (is-eq asset-type "wind")
        (is-eq asset-type "hydro")
        (is-eq asset-type "biomass")))

(define-private (is-valid-recipient (recipient principal))
    (and
        (not (is-eq recipient tx-sender))
        (not (is-eq recipient (as-contract tx-sender)))))

(define-private (calculate-voting-power (shares uint) (total-shares uint))
    (/ (* shares SHARE-SCALE) total-shares))


;; Public Functions - Asset Management

(define-public (register-asset 
    (name (string-ascii 50))
    (asset-type (string-ascii 20))
    (total-shares uint)
    (share-price uint)
    (latitude int)
    (longitude int))
    (let ((asset-id (+ (var-get asset-counter) u1)))
        (asserts! (is-valid-name name) ERR-INVALID-NAME)
        (asserts! (is-valid-asset-type asset-type) ERR-INVALID-ASSET-TYPE)
        (asserts! (> total-shares u0) ERR-INVALID-AMOUNT)
        (asserts! (> share-price u0) ERR-INVALID-AMOUNT)
        (asserts! (>= (* share-price total-shares) MIN-INVESTMENT) ERR-INVALID-AMOUNT)

        (begin
            (map-set assets
                { asset-id: asset-id }
                {
                    name: name,
                    asset-type: asset-type,
                    total-shares: total-shares,
                    available-shares: total-shares,
                    share-price: share-price,
                    total-revenue: u0,
                    revenue-per-share: u0,
                    status: "proposed",
                    creation-height: stacks-block-height,
                    last-updated: stacks-block-height,
                    location: {
                        latitude: latitude,
                        longitude: longitude
                    }
                })
            (map-set asset-metrics
                { asset-id: asset-id }
                {
                    energy-produced: u0,
                    operational-hours: u0,
                    maintenance-cost: u0,
                    efficiency-rating: u100,
                    carbon-offset: u0,
                    peak-output: u0,
                    lifetime-roi: u0
                })
            (map-set governance-settings
                { asset-id: asset-id }
                {
                    min-quorum: u50,          ;; 50% quorum
                    vote-period: u144,        ;; ~24 hours
                    min-vote-threshold: u75,   ;; 75% threshold
                    cooldown-period: u72      ;; ~12 hours
                })
            (var-set asset-counter asset-id)
            (ok asset-id))))

;; Enhanced Share Purchase
(define-public (purchase-shares (asset-id uint) (share-count uint))
    (let ((asset (unwrap! (map-get? assets { asset-id: asset-id })
                          ERR-ASSET-NOT-FOUND))
          (current-ownership (default-to 
                                { 
                                    shares: u0, 
                                    revenue-claimed: u0,
                                    last-claim-height: stacks-block-height,
                                    voting-power: u0
                                }
                                (map-get? ownership 
                                    { asset-id: asset-id, owner: tx-sender }))))
        (asserts! (> share-count u0) ERR-ZERO-SHARES)
        (asserts! (<= share-count (get available-shares asset)) 
                 ERR-INSUFFICIENT-SHARES)
        (asserts! (is-eq (get status asset) "active") ERR-INVALID-STATUS)

        (let ((cost (* share-count (get share-price asset)))
              (new-voting-power (calculate-voting-power 
                                (+ share-count (get shares current-ownership))
                                (get total-shares asset))))
            (begin
                (try! (stx-transfer? cost tx-sender (as-contract tx-sender)))
                (map-set assets
                    { asset-id: asset-id }
                    (merge asset {
                        available-shares: (- (get available-shares asset) 
                                           share-count),
                        last-updated: stacks-block-height
                    }))
                (map-set ownership
                    { asset-id: asset-id, owner: tx-sender }
                    {
                        shares: (+ (get shares current-ownership) share-count),
                        revenue-claimed: (get revenue-claimed current-ownership),
                        last-claim-height: (get last-claim-height current-ownership),
                        voting-power: new-voting-power
                    })
                (ok true)))))
