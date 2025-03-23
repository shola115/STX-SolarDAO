

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
